local addonName = ...
local states = {}
local functionHooks = {}
local editStates = {}
local scrollStates = {}
local chatBarApplied = false
local chatFrameStates = {}
local initialized, applied, pending = false, false, false
local locationState
local locationReset = false
local worldReady = false
local tooltipState, tooltipReset

local function UpdateLocationLayout(state, detached)
    local cluster = MinimapCluster
    if detached and not state.layout then
        -- Keep the header's original footprint in ResizeLayoutFrame. Otherwise a
        -- distant header enlarges the right-anchored cluster and shifts the map.
        local candidates = { cluster:GetChildren() }
        local affected = { [state.bar] = true }
        local changed = true
        while changed do
            changed = false
            for _, frame in ipairs(candidates) do
                if not affected[frame] and frame ~= cluster.MinimapContainer then
                    for i = 1, frame:GetNumPoints() do
                        local _, relative = frame:GetPoint(i)
                        if affected[relative] then affected[frame] = true; changed = true; break end
                    end
                end
            end
        end
        state.layout = {}
        local replacements = {}
        for _, frame in ipairs(candidates) do
            if affected[frame] then
                local proxy = CreateFrame("Frame", nil, cluster)
                proxy:Hide()
                proxy.includeAsLayoutChildWhenHidden = frame:IsShown() or frame.includeAsLayoutChildWhenHidden
                proxy.ignoreInLayout = frame.ignoreInLayout
                proxy:SetSize(frame:GetSize())
                proxy:SetScale(frame:GetScale())
                replacements[frame] = proxy
                state.layout[#state.layout + 1] = { frame = frame, proxy = proxy, ignore = frame.ignoreInLayout }
            end
        end
        for _, entry in ipairs(state.layout) do
            for i = 1, entry.frame:GetNumPoints() do
                local point, relative, relativePoint, x, y = entry.frame:GetPoint(i)
                entry.proxy:SetPoint(point, replacements[relative] or relative, relativePoint, x, y)
            end
            entry.frame.ignoreInLayout = true
        end
    elseif not detached and state.layout then
        for _, entry in ipairs(state.layout) do
            entry.frame.ignoreInLayout = entry.ignore
            entry.proxy.ignoreInLayout = true
            entry.proxy.includeAsLayoutChildWhenHidden = nil
            entry.proxy:ClearAllPoints()
            entry.proxy:SetParent(nil)
        end
        state.layout = nil
    end
    if cluster.MarkDirty then cluster:MarkDirty() end
end

local function ValidLocation(position)
    return type(position) == "table" and type(position.x) == "number" and type(position.y) == "number"
        and position.x == position.x and position.y == position.y
        and math.abs(position.x) < 10 and math.abs(position.y) < 10
end

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99LH_Tweaks|r: " .. message)
end

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function RestoreUserPlaced(frame, placed)
    if frame:IsUserPlaced() == placed then return end
    -- SetUserPlaced requires a movable or resizable frame, even when clearing it.
    local movable = frame:IsMovable()
    if not movable then frame:SetMovable(true) end
    frame:SetUserPlaced(placed)
    if not movable then frame:SetMovable(false) end
end

local function ApplyLocationBar()
    if not worldReady then pending = true; return end
    local cluster = MinimapCluster
    local zone = cluster and cluster.ZoneTextButton
    if not zone then
        if LH_TweaksDB.locationBar or LH_TweaksDB.locationBarPosition or locationReset then pending = true end
        return
    end
    if not locationState and not (LH_TweaksDB.locationBar or LH_TweaksDB.locationBarPosition) then
        locationReset = false
        return
    end
    if not locationState then
        -- On older layouts the header artwork is the common anchor; Camelot uses the zone button itself.
        local _, relative = zone:GetPoint(1)
        local bar = cluster.BorderTop and relative == cluster.BorderTop and cluster.BorderTop or zone
        local state = { bar = bar, points = {}, movable = bar:IsMovable(), userPlaced = bar:IsUserPlaced() }
        locationState = state
        for i = 1, bar:GetNumPoints() do state.points[i] = { bar:GetPoint(i) } end
        local handle = CreateFrame("Frame", nil, zone)
        state.handle = handle
        handle:SetAllPoints(zone)
        handle:SetFrameLevel(zone:GetFrameLevel() + 5)
        handle:EnableMouse(true)
        handle:RegisterForDrag("LeftButton")
        handle:SetScript("OnDragStart", function()
            if InCombat() or not LH_TweaksDB.locationBar then return end
            UpdateLocationLayout(state, true)
            state.dragging = true
            bar:StartMoving()
        end)
        local function StopDrag()
            if not state.dragging then return end
            if InCombat() then pending = true; return end
            state.busy = true
            bar:StopMovingOrSizing()
            state.dragging = false
            local x, y = bar:GetCenter()
            if x and y then
                local scale = bar:GetEffectiveScale() / UIParent:GetEffectiveScale()
                LH_TweaksDB.locationBarPosition = { x = x * scale / UIParent:GetWidth(), y = y * scale / UIParent:GetHeight() }
            end
            state.busy = false
            ApplyLocationBar()
        end
        state.stop = StopDrag
        handle:SetScript("OnDragStop", StopDrag)
        handle:SetScript("OnHide", StopDrag)
        local function EnforceLocation()
            if state.busy or state.dragging or not LH_TweaksDB.locationBarPosition then return end
            if InCombat() then pending = true; return end
            ApplyLocationBar()
        end
        hooksecurefunc(bar, "SetPoint", EnforceLocation)
        hooksecurefunc(bar, "ClearAllPoints", EnforceLocation)
    end
    local state = locationState
    if state.dragging then state.stop() end
    state.busy = true
    local bar = state.bar
    if locationReset then
        LH_TweaksDB.locationBarPosition = nil
        bar:ClearAllPoints()
        for _, point in ipairs(state.points) do bar:SetPoint(unpack(point)) end
        RestoreUserPlaced(bar, state.userPlaced)
        UpdateLocationLayout(state, false)
        locationReset = false
    elseif LH_TweaksDB.locationBarPosition then
        UpdateLocationLayout(state, true)
        local position = LH_TweaksDB.locationBarPosition
        local scale = UIParent:GetEffectiveScale() / bar:GetEffectiveScale()
        bar:ClearAllPoints()
        bar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", position.x * UIParent:GetWidth() * scale, position.y * UIParent:GetHeight() * scale)
    end
    bar:SetMovable(LH_TweaksDB.locationBar or state.movable)
    state.handle:SetShown(LH_TweaksDB.locationBar)
    state.busy = false
end

local function ApplyTooltip()
    if not worldReady then pending = true; return end
    if not GameTooltip then
        if LH_TweaksDB.unlockTooltip or LH_TweaksDB.tooltipPosition then pending = true end
        return
    end
    if not tooltipState and not (LH_TweaksDB.unlockTooltip or LH_TweaksDB.tooltipPosition) then
        tooltipReset = nil
        return
    end
    if not tooltipState then
        local state = {}
        tooltipState = state
        local handle = CreateFrame("Frame", nil, UIParent)
        state.handle = handle
        handle:SetSize(16, 16)
        handle:SetFrameStrata("TOOLTIP")
        handle:SetClampedToScreen(true)
        handle:SetMovable(true)
        handle:EnableMouse(true)
        handle:RegisterForDrag("LeftButton")
        local preview = CreateFrame("Frame", nil, UIParent)
        state.preview = preview
        preview:SetSize(170, 48)
        preview:SetFrameStrata("TOOLTIP")
        preview:SetPoint("BOTTOMRIGHT", handle, "CENTER", 0, 0)
        preview:EnableMouse(false)
        handle:SetFrameLevel(preview:GetFrameLevel() + 2)
        local background = preview:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.04, 0.05, 0.05, 0.9)
        local label = preview:CreateFontString(nil, "OVERLAY")
        label:SetPoint("CENTER", preview, "CENTER", 0, 0)
        label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        label:SetTextColor(1, 0.82, 0.4)
        label:SetText("Tooltip position")
        local circle = handle:CreateTexture(nil, "OVERLAY")
        circle:SetAllPoints()
        circle:SetTexture("Interface\\AddOns\\LH_Tweaks\\DragCircle.tga")
        local function PositionHandle()
            if state.dragging then return end
            local position = LH_TweaksDB.tooltipPosition
            local x = position and position.x * UIParent:GetWidth() or UIParent:GetWidth() - 120
            local y = position and position.y * UIParent:GetHeight() or 180
            handle:ClearAllPoints()
            handle:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        end
        state.position = function(tooltip)
            -- Keep the saved anchor when Blizzard places a nonprotected tooltip in combat.
            if InCombat() and tooltip.IsProtected and tooltip:IsProtected() then
                pending = true
                return
            end
            local position = LH_TweaksDB.tooltipPosition
            if position then
                local scale = UIParent:GetEffectiveScale() / tooltip:GetEffectiveScale()
                tooltip:ClearAllPoints()
                tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT",
                    position.x * UIParent:GetWidth() * scale, position.y * UIParent:GetHeight() * scale)
            end
            if tooltip == GameTooltip then PositionHandle() end
        end
        if type(GameTooltip_SetDefaultAnchor) == "function" then
            hooksecurefunc("GameTooltip_SetDefaultAnchor", state.position)
        end
        GameTooltip:HookScript("OnShow", state.position)
        handle:SetScript("OnDragStart", function()
            if InCombat() or not LH_TweaksDB.unlockTooltip then return end
            state.dragging = true
            handle:StartMoving()
        end)
        state.stop = function()
            if not state.dragging then return end
            handle:StopMovingOrSizing()
            state.dragging = false
            if InCombat() then pending = true; PositionHandle(); return end
            local x, y = handle:GetCenter()
            if x and y then
                LH_TweaksDB.tooltipPosition = { x = x / UIParent:GetWidth(), y = y / UIParent:GetHeight() }
            end
            state.position(GameTooltip)
        end
        handle:SetScript("OnDragStop", state.stop)
        handle:SetScript("OnHide", state.stop)
        handle:SetScript("OnUpdate", function()
            if not state.dragging then return end
            if InCombat() then state.stop(); return end
            local x, y = handle:GetCenter()
            if not x or not y then return end
            local scale = UIParent:GetEffectiveScale() / GameTooltip:GetEffectiveScale()
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", x * scale, y * scale)
        end)
        PositionHandle()
    end
    local state = tooltipState
    if state.dragging then state.stop() end
    if tooltipReset then
        LH_TweaksDB.tooltipPosition = nil
        tooltipReset = nil
        if type(GameTooltip_SetDefaultAnchor) == "function" then
            GameTooltip_SetDefaultAnchor(GameTooltip, GameTooltip:GetOwner() or UIParent)
        end
    elseif LH_TweaksDB.tooltipPosition then
        state.position(GameTooltip)
    end
    state.handle:SetShown(LH_TweaksDB.unlockTooltip)
    state.preview:SetShown(LH_TweaksDB.unlockTooltip)
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

local function ApplyChatBarFrame(editBox)
    local enabled = LH_TweaksDB.replaceChatBarFrame == true
    local state = chatFrameStates[editBox]
    if not state and not enabled then return end
    if not state then
        state = { regions = {} }
        chatFrameStates[editBox] = state
        local frame = CreateFrame("Frame", nil, editBox, "BackdropTemplate")
        state.frame = frame
        frame:EnableMouse(false)
        frame:SetAllPoints(editBox)
        frame:SetFrameLevel(math.max(0, editBox:GetFrameLevel() - 1))
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        frame:SetBackdropColor(0, 0, 0, 1)
        frame:SetBackdropBorderColor(0.65, 0.59, 0.45, 1)
    end
    state.enabled = enabled
    local name = editBox:GetName()
    -- Only replace border artwork, leaving text, headers and focus untouched.
    for _, suffix in ipairs({ "Left", "Mid", "Right", "FocusLeft", "FocusMid", "FocusRight" }) do
        local key = suffix:sub(1, 1):lower() .. suffix:sub(2)
        local region = editBox[key] or editBox[suffix] or (name and _G[name .. suffix])
        if region and not state.regions[region] and enabled then
            local data = { alpha = region:GetAlpha() }
            state.regions[region] = data
            hooksecurefunc(region, "SetAlpha", function(self, alpha)
                if data.busy then return end
                data.alpha = alpha
                if state.enabled then
                    data.busy = true
                    self:SetAlpha(0)
                    data.busy = false
                end
            end)
        end
    end
    for region, data in pairs(state.regions) do
        data.busy = true
        region:SetAlpha(enabled and 0 or data.alpha)
        data.busy = false
    end
    state.frame:SetShown(enabled)
end

local function ApplyChatBars(frames)
    chatBarApplied = LH_TweaksDB.moveChatBarToTop == true
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
            ApplyChatBarFrame(editBox)
        end
    end
    if (chatBarApplied or LH_TweaksDB.replaceChatBarFrame) and not foundPrimary then pending = true end
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
local fishingLootFrame
local function InstallFishingLootHandler()
    if not LH_TweaksDB.instantFishingLoot or not LootFrame or fishingLootFrame == LootFrame then return end
    if not (IsFishingLoot and GetNumLootItems and LootSlot and C_Timer and C_Timer.After) then return end
    local original = LootFrame:GetScript("OnEvent")
    if type(original) ~= "function" then return end
    fishingLootFrame = LootFrame
    local session
    LootFrame:SetScript("OnEvent", function(frame, event, ...)
        if event == "LOOT_OPENED" then
            session = nil
            if LH_TweaksDB.instantFishingLoot and IsFishingLoot() then
                -- Intercept before Blizzard displays the window. Hiding it later
                -- would flash on screen and OnHide could close uncollected loot.
                local current = {}
                session = current
                for slot = GetNumLootItems(), 1, -1 do
                    if session ~= current then break end
                    local ok = pcall(LootSlot, slot)
                    if not ok then
                        session = nil
                        original(frame, "LOOT_OPENED", false)
                        return
                    end
                end
                C_Timer.After(1, function()
                    if session ~= current then return end
                    session = nil
                    -- Full bags or other failures retain the normal recovery UI.
                    if GetNumLootItems() > 0 then original(frame, "LOOT_OPENED", false) end
                end)
                return
            end
        elseif event == "LOOT_CLOSED" then
            session = nil
        elseif session and (event == "LOOT_SLOT_CLEARED" or event == "LOOT_SLOT_CHANGED") then
            return
        end
        original(frame, event, ...)
    end)
end

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
    InstallFishingLootHandler()
    if worldReady and LH_TweaksDB.minimapPositionRepair ~= 1 then
        if MinimapCluster and MinimapCluster.MinimapContainer then
            -- One-time repair for the location-bar layout bug in 0.6.0/0.6.1.
            MinimapCluster:ClearAllPoints()
            MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
            RestoreUserPlaced(MinimapCluster, false)
            if MinimapCluster.MarkDirty then MinimapCluster:MarkDirty() end
            LH_TweaksDB.minimapPositionRepair = 1
        else
            pending = true
        end
    end
    ApplyLocationBar()
    ApplyTooltip()
    applied = LH_TweaksDB.chatWindow == true
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

local function LeatrixHandles(key)
    local option = key == "autoSellGreys" and "AutoSellJunk"
        or key == "autoRepair" and "AutoRepairGear"
    if not option then return false end
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if not isLoaded or not isLoaded("Leatrix_Plus") then return false end
    local settings = _G.LeaPlusDB
    if type(settings) ~= "table" then return false end
    return settings[option] == "On" or settings[option] == true
end

local function AutoSellGreys()
    if not LH_TweaksDB.autoSellGreys or LeatrixHandles("autoSellGreys") then return end
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
    if not LH_TweaksDB.autoRepair or LeatrixHandles("autoRepair") or not CanMerchantRepair() then return end
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
    Print("/lh_tweaks instant-fishing-loot on|off - collect fishing loot without flashing the loot window; show remaining items if collection fails.")
    Print("/lh_tweaks replace-chatbar-frame on|off - use the LH_ExpBar border for chat input, or restore the standard border.")
    Print("/lh_tweaks unlock-tooltip on|off|reset - drag the bottom-right circle, lock the tooltip, or restore its default position.")
    Print("/lh_tweaks unlock-location-bar on|off|reset - drag the location bar with its attached buttons, lock it in place, or restore its original position.")
    Print("/lh_tweaks all on|off - enable or disable all tweaks; merchant actions start on the next visit.")
    Print("/lh_tweaks remove-chatwindow-move-limit on - allow standard chat windows to move beyond the screen edges and hide their scrollbars.")
    Print("/lh_tweaks remove-chatwindow-move-limit off - restore normal screen constraints and scrollbar visibility.")
    Print("/lh_tweaks move-chatbar-to-top on - place chat input above the chat window.")
    Print("/lh_tweaks move-chatbar-to-top off - place chat input at its default position below the chat window.")
    Print("/lh_tweaks auto-repair on - automatically repair all items at repair-capable merchants using your own money.")
    Print("/lh_tweaks auto-repair off - disable automatic repairs.")
    Print("/lh_tweaks auto-sell-greys on - automatically sell grey items when visiting a merchant.")
    Print("/lh_tweaks auto-sell-greys off - disable automatic grey-item sales.")
    Print("/lh_tweaks status - show saved settings; /lh_tweaks help - show commands.")
end

SLASH_LH_TWEAKS1 = "/lh_tweaks"
SlashCmdList.LH_TWEAKS = function(message)
    local command, value, extra = (message or ""):lower():match("^%s*(%S*)%s*(%S*)%s*(.-)%s*$")
    if (command == "" or command == "help") and value == "" and extra == "" then
        Help()
    elseif command == "status" and value == "" and extra == "" then
        Print("remove-chatwindow-move-limit: " .. (LH_TweaksDB.chatWindow and "on" or "off") .. (pending and " (pending)" or ""))
        Print("move-chatbar-to-top: " .. (LH_TweaksDB.moveChatBarToTop and "on" or "off") .. (pending and " (pending)" or ""))
        Print("replace-chatbar-frame: " .. (LH_TweaksDB.replaceChatBarFrame and "on" or "off") .. (pending and " (pending)" or ""))
        Print("auto-repair: " .. (LeatrixHandles("autoRepair") and "already handled by Leatrix Plus" or LH_TweaksDB.autoRepair and "on" or "off"))
        Print("auto-sell-greys: " .. (LeatrixHandles("autoSellGreys") and "already handled by Leatrix Plus" or LH_TweaksDB.autoSellGreys and "on" or "off"))
        Print("unlock-location-bar: " .. (LH_TweaksDB.locationBar and "on" or "off") .. (pending and " (pending)" or ""))
        Print("unlock-tooltip: " .. (LH_TweaksDB.unlockTooltip and "on" or "off") .. (pending and " (pending)" or ""))
        Print("instant-fishing-loot: " .. (LH_TweaksDB.instantFishingLoot and "on" or "off"))
    elseif command == "all" and (value == "on" or value == "off") and extra == "" then
        local enabled = value == "on"
        LH_TweaksDB.chatWindow = enabled
        LH_TweaksDB.moveChatBarToTop = enabled
        LH_TweaksDB.replaceChatBarFrame = enabled
        LH_TweaksDB.autoRepair = enabled
        LH_TweaksDB.autoSellGreys = enabled
        LH_TweaksDB.locationBar = enabled
        LH_TweaksDB.unlockTooltip = enabled
        LH_TweaksDB.instantFishingLoot = enabled
        Apply()
        Print("All tweaks: " .. value .. (pending and " (layout changes pending; apply after combat or when UI frames load)" or ""))
    elseif command == "unlock-location-bar" and (value == "on" or value == "off" or value == "reset") and extra == "" then
        if value == "reset" then
            LH_TweaksDB.locationBarPosition = nil
            locationReset = true
        else
            LH_TweaksDB.locationBar = value == "on"
        end
        Apply()
        Print("unlock-location-bar: " .. value .. (pending and " (pending; applies after combat or when the location bar loads)" or ""))
    elseif command == "unlock-tooltip" and (value == "on" or value == "off" or value == "reset") and extra == "" then
        if value == "reset" then
            tooltipReset = true
            LH_TweaksDB.tooltipPosition = nil
        else
            LH_TweaksDB.unlockTooltip = value == "on"
        end
        Apply()
        Print("unlock-tooltip: " .. value .. (pending and " (pending; applies after combat or when the tooltip loads)" or ""))
    elseif command == "instant-fishing-loot" and (value == "on" or value == "off") and extra == "" then
        LH_TweaksDB.instantFishingLoot = value == "on"
        Apply()
        Print("instant-fishing-loot: " .. value)
    elseif command == "auto-sell-greys" and (value == "on" or value == "off") and extra == "" then
        if value == "on" and LeatrixHandles("autoSellGreys") then
            Print("Auto-sell greys is already handled by Leatrix Plus.")
            return
        end
        LH_TweaksDB.autoSellGreys = value == "on"
        Print("auto-sell-greys: " .. value)
    elseif command == "auto-repair" and (value == "on" or value == "off") and extra == "" then
        if value == "on" and LeatrixHandles("autoRepair") then
            Print("Auto-repair is already handled by Leatrix Plus.")
            return
        end
        LH_TweaksDB.autoRepair = value == "on"
        Print("auto-repair: " .. value)
    elseif command == "replace-chatbar-frame" and (value == "on" or value == "off") and extra == "" then
        LH_TweaksDB.replaceChatBarFrame = value == "on"
        Apply()
        Print("replace-chatbar-frame: " .. value .. (pending and " (pending; applies after combat or when chat frames load)" or ""))
    elseif command == "move-chatbar-to-top" and (value == "on" or value == "off") and extra == "" then
        LH_TweaksDB.moveChatBarToTop = value == "on"
        Apply()
        Print("move-chatbar-to-top: " .. value .. (pending and " (pending; applies after combat or when chat frames load)" or ""))
    elseif command == "remove-chatwindow-move-limit" and (value == "on" or value == "off") and extra == "" then
        LH_TweaksDB.chatWindow = value == "on"
        Apply()
        Print("remove-chatwindow-move-limit: " .. value .. (pending and " (pending; applies after combat or when chat frames load)" or ""))
    else
        Print("Invalid command. Use /lh_tweaks help.")
    end
    if LH_Tweaks and LH_Tweaks.RefreshSettings then LH_Tweaks:RefreshSettings() end
end

-- Shared configuration host. Companion addons can register their own pages.
LH_Tweaks = { modules = {} }
local Hub = LH_Tweaks
Hub.features = {
    { key = "chatWindow", command = "remove-chatwindow-move-limit", section = "Chat", label = "Allow chat windows beyond screen edges", tooltip = "Remove movement limits and hide standard chat scrollbars." },
    { key = "moveChatBarToTop", command = "move-chatbar-to-top", section = "Chat", label = "Move chat input above the chat window", tooltip = "Place the input field above the chat window instead of below it." },
    { key = "replaceChatBarFrame", command = "replace-chatbar-frame", section = "Chat", label = "Replace the chat input border", tooltip = "Use the black background and muted gold border from LH_ExpBar. Disable to restore the Blizzard border." },
    { key = "locationBar", command = "unlock-location-bar", section = "Positioning", label = "Unlock the location bar", tooltip = "Drag the zone-name area to move the location bar and its attached buttons. Disable to lock it at the saved position." },
    { key = "unlockTooltip", command = "unlock-tooltip", section = "Positioning", label = "Unlock the default tooltip", tooltip = "Drag the small circle at the tooltip's bottom-right corner. Disable to lock the saved position." },
    { key = "autoRepair", command = "auto-repair", section = "Merchants", label = "Automatically repair equipment", tooltip = "Repair at merchants using your own money when the full repair cost is affordable." },
    { key = "autoSellGreys", command = "auto-sell-greys", section = "Merchants", label = "Automatically sell grey items", tooltip = "Sell poor-quality items from your bags on your next merchant visit." },
    { key = "instantFishingLoot", command = "instant-fishing-loot", section = "Fishing", label = "Loot fishing catches without a loot window", tooltip = "Collect fishing loot immediately when you interact with the bobber, including by right-click. If items remain after one second, show the normal loot window for manual recovery. Normal non-fishing loot is unchanged. BetterFishing is not required." },
}

function Hub:IsReady() return initialized end
function Hub:IsPending() return pending end
function Hub:IsFeatureManaged(key) return LeatrixHandles(key) end
function Hub:GetFeature(key)
    return not LeatrixHandles(key) and LH_TweaksDB and LH_TweaksDB[key] == true or false
end
function Hub:RunCommand(command) SlashCmdList.LH_TWEAKS(command) end
function Hub:RegisterModule(id, title, build)
    assert(type(id) == "string" and type(title) == "string" and type(build) == "function", "Invalid LH Tweaks settings module")
    if self.modules[id] then return end
    self.modules[id] = { title = title, build = build }
    if self.RegisterModulePage then self:RegisterModulePage(id) end
end

function Hub:RestoreDefaults()
    if not initialized then return end
    for _, feature in ipairs(self.features) do LH_TweaksDB[feature.key] = false end
    LH_TweaksDB.locationBarPosition, LH_TweaksDB.tooltipPosition = nil, nil
    locationReset, tooltipReset = true, true
    Apply()
    if self.RefreshSettings then self:RefreshSettings() end
end

local events = CreateFrame("Frame")
for _, event in ipairs({"ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UPDATE_CHAT_WINDOWS", "UPDATE_FLOATING_CHAT_WINDOWS", "MERCHANT_SHOW"}) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, name)
    if event == "PLAYER_ENTERING_WORLD" then worldReady = true end
    if event == "ADDON_LOADED" and name == addonName then
        if type(LH_TweaksDB) ~= "table" then LH_TweaksDB = {} end
        LH_TweaksDB.chatWindow = LH_TweaksDB.chatWindow == true
        LH_TweaksDB.moveChatBarToTop = LH_TweaksDB.moveChatBarToTop == true
        LH_TweaksDB.replaceChatBarFrame = LH_TweaksDB.replaceChatBarFrame == true
        LH_TweaksDB.autoRepair = LH_TweaksDB.autoRepair == true
        LH_TweaksDB.autoSellGreys = LH_TweaksDB.autoSellGreys == true
        LH_TweaksDB.locationBar = LH_TweaksDB.locationBar == true
        LH_TweaksDB.unlockTooltip = LH_TweaksDB.unlockTooltip == true
        LH_TweaksDB.instantFishingLoot = LH_TweaksDB.instantFishingLoot == true
        if not ValidLocation(LH_TweaksDB.tooltipPosition) then LH_TweaksDB.tooltipPosition = nil end
        if not ValidLocation(LH_TweaksDB.locationBarPosition) then LH_TweaksDB.locationBarPosition = nil end
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
