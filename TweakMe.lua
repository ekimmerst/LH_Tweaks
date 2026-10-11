local addonName = ...
local states = {}
local functionHooks = {}
local initialized, applied, pending = false, false, false

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99TweakMe|r: " .. message)
end

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function DiscoverFrames()
    local frames, seen = {}, {}
    local function Add(frame)
        if frame and not seen[frame] and frame.SetClampedToScreen and frame.IsClampedToScreen then
            seen[frame] = true
            frames[#frames + 1] = frame
        end
    end
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local chat = _G["ChatFrame" .. i]
        Add(chat)
        if chat then Add(chat.Selection) end
    end
    for _, entry in pairs(CHAT_FRAMES or {}) do
        local chat = type(entry) == "string" and _G[entry] or entry
        Add(chat)
        if chat then Add(chat.Selection) end
    end
    return frames
end

local function Enforce(frame, state)
    if state.busy or not applied then return end
    if InCombat() then pending = true; return end
    state.busy = true
    frame:SetClampedToScreen(false)
    state.busy = false
end

local Apply
local function InstallFunctionHooks()
    for _, name in ipairs({"FCF_OpenNewWindow", "FCF_OpenTemporaryWindow", "FCF_RestorePositionAndDimensions", "FCF_SetWindowPosition"}) do
        if type(_G[name]) == "function" and not functionHooks[name] then
            functionHooks[name] = true
            hooksecurefunc(name, function() if initialized then Apply() end end)
        end
    end
end

Apply = function()
    if not initialized then return end
    if InCombat() then pending = true; return end
    pending = false
    applied = TweakMeDB.chatWindow == true
    InstallFunctionHooks()
    local frames = DiscoverFrames()
    if applied and not ChatFrame1 then pending = true end
    for _, frame in ipairs(frames) do
        local state = states[frame]
        if applied then
            if not state then
                state = {}
                states[frame] = state
                hooksecurefunc(frame, "SetClampedToScreen", function(self, clamped)
                    if not state.busy and state.original ~= nil then
                        -- Remember Blizzard's latest requested normal mode.
                        state.original = clamped and true or false
                    end
                    Enforce(self, state)
                end)
                if frame.SetClampRectInsets then
                    hooksecurefunc(frame, "SetClampRectInsets", function(self) Enforce(self, state) end)
                end
            end
            if state.original == nil then state.original = frame:IsClampedToScreen() end
            Enforce(frame, state)
        end
    end
    if not applied then
        for frame, state in pairs(states) do
            if state.original ~= nil then
                local original = state.original
                state.original = nil
                state.busy = true
                frame:SetClampedToScreen(original)
                state.busy = false
            end
        end
    end
end

local function Help()
    Print("/tweakme chatwindow on - allow standard chat windows to move beyond the screen edges.")
    Print("/tweakme chatwindow off - restore normal screen constraints.")
    Print("/tweakme status - show the saved setting; /tweakme help - show commands.")
end

SLASH_TWEAKME1 = "/tweakme"
SlashCmdList.TWEAKME = function(message)
    local command, value, extra = (message or ""):lower():match("^%s*(%S*)%s*(%S*)%s*(.-)%s*$")
    if (command == "" or command == "help") and value == "" and extra == "" then
        Help()
    elseif command == "status" and value == "" and extra == "" then
        Print("chatwindow: " .. (TweakMeDB.chatWindow and "on" or "off") .. (pending and " (pending)" or ""))
    elseif command == "chatwindow" and (value == "on" or value == "off") and extra == "" then
        TweakMeDB.chatWindow = value == "on"
        Apply()
        Print("chatwindow: " .. value .. (pending and " (pending; applies after combat or when chat frames load)" or ""))
    else
        Print("Invalid command. Use /tweakme help.")
    end
end

local events = CreateFrame("Frame")
for _, event in ipairs({"ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UPDATE_CHAT_WINDOWS", "UPDATE_FLOATING_CHAT_WINDOWS"}) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        if type(TweakMeDB) ~= "table" then TweakMeDB = {} end
        TweakMeDB.chatWindow = TweakMeDB.chatWindow == true
        initialized = true
    end
    if initialized then Apply() end
end)
