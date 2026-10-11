local addonName = ...
local states = {}
local functionHooks = {}
local editStates = {}
local scrollStates = {}
local chatBarApplied = false
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

local function PositionChatBar(editBox, state)
    if state.busy then return end
    if InCombat() then pending = true; return end
    state.busy = true
    local chat = state.chat
    editBox:ClearAllPoints()
    if chatBarApplied then
        editBox:SetPoint("BOTTOMLEFT", chat, "TOPLEFT", -5, 2)
    else
        editBox:SetPoint("TOPLEFT", chat, "BOTTOMLEFT", -5, -2)
    end
    -- Preserve Blizzard's horizontal alignment with the scrollbar when available.
    editBox:SetPoint("RIGHT", chat.ScrollBar or chat, "RIGHT", chat.ScrollBar and 8 or 5, 0)
    state.busy = false
end

local function ApplyChatBars(frames)
    chatBarApplied = TweakMeDB.moveChatBarToTop == true
    local foundPrimary = false
    for _, chat in ipairs(frames) do
        local name = chat.GetName and chat:GetName()
        local editBox = chat.editBox or (name and _G[name .. "EditBox"])
        if editBox and editBox.ClearAllPoints and editBox.SetPoint then
            if chat == ChatFrame1 then foundPrimary = true end
            local state = editStates[editBox]
            if not state then
                state = { chat = chat }
                editStates[editBox] = state
                local function EnforcePosition(self)
                    if chatBarApplied and not state.busy then PositionChatBar(self, state) end
                end
                hooksecurefunc(editBox, "SetPoint", EnforcePosition)
                hooksecurefunc(editBox, "ClearAllPoints", EnforcePosition)
            end
            state.chat = chat
            PositionChatBar(editBox, state)
        end
    end
    if chatBarApplied and not foundPrimary then pending = true end
end

local function ApplyScrollBars(frames)
    for _, chat in ipairs(frames) do
        local name = chat.GetName and chat:GetName()
        local bar = chat.ScrollBar or (name and _G[name .. "ScrollBar"])
        if applied and bar and bar.IsShown and bar.Show and bar.Hide then
            local state = scrollStates[bar]
            if not state then
                state = {}
                scrollStates[bar] = state
                local function Requested(self, shown)
                    if state.busy or state.original == nil then return end
                    state.original = shown and true or false
                    if not applied then return end
                    if InCombat() then pending = true; return end
                    state.busy = true
                    self:Hide()
                    state.busy = false
                end
                hooksecurefunc(bar, "Show", function(self) Requested(self, true) end)
                hooksecurefunc(bar, "Hide", function(self) Requested(self, false) end)
                if bar.SetShown then hooksecurefunc(bar, "SetShown", Requested) end
            end
            if state.original == nil then state.original = bar:IsShown() end
            state.busy = true
            bar:Hide()
            state.busy = false
        end
    end
    if not applied then
        for bar, state in pairs(scrollStates) do
            if state.original ~= nil then
                local original = state.original
                state.original = nil
                state.busy = true
                if original then bar:Show() else bar:Hide() end
                state.busy = false
            end
        end
    end
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
    ApplyScrollBars(frames)
    ApplyChatBars(frames)
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

local function AutoSellGreys()
    if not TweakMeDB.autoSellGreys then return end
    if C_MerchantFrame and C_MerchantFrame.SellAllJunkItems then
        C_MerchantFrame.SellAllJunkItems()
        return
    end
    -- Support clients without the merchant's built-in sell-junk operation.
    local container = C_Container or _G
    if not container.GetContainerNumSlots or not container.GetContainerItemInfo or not container.UseContainerItem then return end
    if CursorHasItem and CursorHasItem() then return end
    if InRepairMode and InRepairMode() then return end
    for bag = 0, (NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4) do
        for slot = 1, container.GetContainerNumSlots(bag) do
            local info, count, locked, quality, readable, lootable, link, filtered, noValue = container.GetContainerItemInfo(bag, slot)
            if type(info) == "table" then
                locked, quality, noValue = info.isLocked, info.quality, info.hasNoValue
            end
            if info and quality == 0 and not locked and not noValue then
                container.UseContainerItem(bag, slot)
            end
        end
    end
end

local function AutoRepair()
    if not TweakMeDB.autoRepair or not CanMerchantRepair() then return end
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or not cost or cost <= 0 then return end
    if GetMoney() < cost then
        Print("Auto-repair skipped: not enough money.")
        return
    end
    -- Use the merchant's repair-all operation with personal funds only.
    RepairAllItems(false)
end

local function Help()
    Print("/tweakme all on|off - enable or disable all tweaks; merchant actions start on the next visit.")
    Print("/tweakme remove-chatwindow-move-limit on - allow standard chat windows to move beyond the screen edges and hide their scrollbars.")
    Print("/tweakme remove-chatwindow-move-limit off - restore normal screen constraints and scrollbar visibility.")
    Print("/tweakme move-chatbar-to-top on - place chat input above the chat window.")
    Print("/tweakme move-chatbar-to-top off - place chat input at its default position below the chat window.")
    Print("/tweakme auto-repair on - automatically repair all items at repair-capable merchants using your own money.")
    Print("/tweakme auto-repair off - disable automatic repairs.")
    Print("/tweakme auto-sell-greys on - automatically sell grey items when visiting a merchant.")
    Print("/tweakme auto-sell-greys off - disable automatic grey-item sales.")
    Print("/tweakme status - show saved settings; /tweakme help - show commands.")
end

SLASH_TWEAKME1 = "/tweakme"
SlashCmdList.TWEAKME = function(message)
    local command, value, extra = (message or ""):lower():match("^%s*(%S*)%s*(%S*)%s*(.-)%s*$")
    if (command == "" or command == "help") and value == "" and extra == "" then
        Help()
    elseif command == "status" and value == "" and extra == "" then
        Print("remove-chatwindow-move-limit: " .. (TweakMeDB.chatWindow and "on" or "off") .. (pending and " (pending)" or ""))
        Print("move-chatbar-to-top: " .. (TweakMeDB.moveChatBarToTop and "on" or "off") .. (pending and " (pending)" or ""))
        Print("auto-repair: " .. (TweakMeDB.autoRepair and "on" or "off"))
        Print("auto-sell-greys: " .. (TweakMeDB.autoSellGreys and "on" or "off"))
    elseif command == "all" and (value == "on" or value == "off") and extra == "" then
        local enabled = value == "on"
        TweakMeDB.chatWindow = enabled
        TweakMeDB.moveChatBarToTop = enabled
        TweakMeDB.autoRepair = enabled
        TweakMeDB.autoSellGreys = enabled
        Apply()
        Print("All tweaks: " .. value .. (pending and " (chat changes pending; apply after combat or when chat frames load)" or ""))
    elseif command == "auto-sell-greys" and (value == "on" or value == "off") and extra == "" then
        TweakMeDB.autoSellGreys = value == "on"
        Print("auto-sell-greys: " .. value)
    elseif command == "auto-repair" and (value == "on" or value == "off") and extra == "" then
        TweakMeDB.autoRepair = value == "on"
        Print("auto-repair: " .. value)
    elseif command == "move-chatbar-to-top" and (value == "on" or value == "off") and extra == "" then
        TweakMeDB.moveChatBarToTop = value == "on"
        Apply()
        Print("move-chatbar-to-top: " .. value .. (pending and " (pending; applies after combat or when chat frames load)" or ""))
    elseif command == "remove-chatwindow-move-limit" and (value == "on" or value == "off") and extra == "" then
        TweakMeDB.chatWindow = value == "on"
        Apply()
        Print("remove-chatwindow-move-limit: " .. value .. (pending and " (pending; applies after combat or when chat frames load)" or ""))
    else
        Print("Invalid command. Use /tweakme help.")
    end
end

local events = CreateFrame("Frame")
for _, event in ipairs({"ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UPDATE_CHAT_WINDOWS", "UPDATE_FLOATING_CHAT_WINDOWS", "MERCHANT_SHOW"}) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        if type(TweakMeDB) ~= "table" then TweakMeDB = {} end
        TweakMeDB.chatWindow = TweakMeDB.chatWindow == true
        TweakMeDB.moveChatBarToTop = TweakMeDB.moveChatBarToTop == true
        TweakMeDB.autoRepair = TweakMeDB.autoRepair == true
        TweakMeDB.autoSellGreys = TweakMeDB.autoSellGreys == true
        initialized = true
    end
    if event == "MERCHANT_SHOW" then
        if initialized then
            AutoSellGreys()
            AutoRepair()
        end
        return
    end
    if initialized then Apply() end
end)
