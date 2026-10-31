local addonName = ...
local Hub = LH_Tweaks
local variables = {}
local lockLabels = {locationBar = "Lock location bar", unlockTooltip = "Lock tooltip"}
local headerActions = {}
local headerButtons

local function Header(layout, title)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end

local function Button(layout, label, text, callback, tooltip)
    layout:AddInitializer(CreateSettingsButtonInitializer(label, text, callback, tooltip, true))
end

local function SyncHeaderActions(panel, category)
    local actions = headerActions[category]
    local searching = panel.SearchBox and panel.SearchBox.HasText and panel.SearchBox:HasText()
    if not actions or searching then
        if headerButtons then
            for _, button in ipairs(headerButtons) do button:Hide() end
        end
        return
    end
    local header = panel:GetSettingsList().Header
    if not header or not header.DefaultsButton then return end
    if not headerButtons then
        headerButtons = {}
        for i = 1, 2 do
            local button = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
            button:SetSize(96, 22)
            button:SetScript("OnEnter", function(self)
                if not self.tooltip then return end
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
                GameTooltip:SetText(self.tooltip, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            headerButtons[i] = button
        end
        headerButtons[2]:ClearAllPoints()
        headerButtons[2]:SetPoint("RIGHT", header.DefaultsButton, "LEFT", -8, 0)
        headerButtons[1]:ClearAllPoints()
        headerButtons[1]:SetPoint("RIGHT", headerButtons[2], "LEFT", -6, 0)
    end
    for i, action in ipairs(actions) do
        local button = headerButtons[i]
        button:SetText(action.text)
        button.tooltip = action.tooltip
        button:SetScript("OnClick", action.callback)
        button:Show()
    end
end

function Hub:RegisterHeaderActions(category, first, second)
    headerActions[category] = {first, second}
end

function Hub:RefreshSettings()
    if self.notifying or not Settings or not Settings.NotifyUpdate then return end
    self.notifying = true
    for _, variable in ipairs(variables) do Settings.NotifyUpdate(variable) end
    self.notifying = false
end

function Hub:RegisterModulePage(id)
    if not self.category then return end
    local module = self.modules[id]
    if not module or module.category then return end
    local category, layout = Settings.RegisterVerticalLayoutSubcategory(self.category, module.title)
    module.category = category
    module.build(category, layout)
    Settings.RegisterAddOnCategory(category)
end

local function RegisterSettings()
    if Hub.category or not Hub:IsReady() then return end
    if not (Settings and Settings.RegisterVerticalLayoutCategory and Settings.RegisterProxySetting
        and Settings.CreateCheckbox and Settings.RegisterAddOnCategory
        and CreateSettingsListSectionHeaderInitializer and CreateSettingsButtonInitializer
        and SettingsPanel and EventRegistry) then return end

    local category, layout = Settings.RegisterVerticalLayoutCategory("LH Tweaks")
    Hub.category = category
    local orderedFeatures = {}
    for _, feature in ipairs(Hub.features) do
        if feature.section == "Positioning" then orderedFeatures[#orderedFeatures + 1] = feature end
    end
    for _, feature in ipairs(Hub.features) do
        if feature.section ~= "Positioning" then orderedFeatures[#orderedFeatures + 1] = feature end
    end
    local section
    for _, feature in ipairs(orderedFeatures) do
        if section ~= feature.section then
            section = feature.section
            Header(layout, section)
        end
        local variable = "LH_Tweaks_" .. feature.key
        variables[#variables + 1] = variable
        local isLock = lockLabels[feature.key] ~= nil
        local setting = Settings.RegisterProxySetting(category, variable, "boolean",
            lockLabels[feature.key] or feature.label, isLock,
            function()
                local enabled = Hub:GetFeature(feature.key)
                if isLock then return not enabled end
                return enabled
            end,
            function(value)
                Hub:RunCommand(feature.command .. ((isLock ~= value) and " on" or " off"))
            end)
        local initializer = Settings.CreateCheckbox(category, setting, function()
            if Hub:IsFeatureManaged(feature.key) then
                return "Already handled by Leatrix Plus. Disable the corresponding option in Leatrix Plus to use LH Tweaks instead."
            end
            local tooltip = feature.tooltip
            if feature.key == "locationBar" then
                tooltip = "Disable to drag the zone-name area and its attached buttons. Enable to lock the location bar at its saved position."
            elseif feature.key == "unlockTooltip" then
                tooltip = "Disable to drag the circle at the tooltip's bottom-right corner. Enable to lock its saved position."
            end
            return tooltip .. " Changes are saved per character; layout changes wait until combat ends."
        end)
        initializer:AddModifyPredicate(function() return not Hub:IsFeatureManaged(feature.key) end)
        if feature.key == "autoRepair" or feature.key == "autoSellGreys" then
            local notice = CreateSettingsListSectionHeaderInitializer("Already handled by Leatrix Plus")
            notice:AddShownPredicate(function() return Hub:IsFeatureManaged(feature.key) end)
            layout:AddInitializer(notice)
        end
        if feature.key == "locationBar" then
            Button(layout, "Location bar position", "Reset position", function()
                Hub:RunCommand("unlock-location-bar reset")
            end, "Restore the location bar's original position without changing its lock setting.")
        elseif feature.key == "unlockTooltip" then
            Button(layout, "Tooltip position", "Reset position", function()
                Hub:RunCommand("unlock-tooltip reset")
            end, "Restore Blizzard's default tooltip anchor without changing its lock setting.")
        end
    end
    Hub:RegisterHeaderActions(category,
        {text = "Enable all", callback = function() Hub:RunCommand("all on") end,
            tooltip = "Enable every feature, including automatic repairs, grey-item sales and position unlocking."},
        {text = "Disable all", callback = function() Hub:RunCommand("all off") end,
            tooltip = "Disable every feature, including instant fishing loot, and keep saved positions. Defaults also clears saved positions."})

    hooksecurefunc(SettingsPanel, "DisplayCategory", function(panel, selected)
        if selected == category then
            panel:GetSettingsList().Header.Title:SetText("LiteHawk Tweaks")
            Hub:RefreshSettings()
        end
        SyncHeaderActions(panel, selected)
    end)
    if SettingsPanel.OnSearchTextChanged then
        hooksecurefunc(SettingsPanel, "OnSearchTextChanged", function(panel)
            SyncHeaderActions(panel, panel:GetCurrentCategory())
        end)
    end
    EventRegistry:RegisterCallback("Settings.CategoryDefaulted", function(_, selected)
        if selected == category then Hub:RestoreDefaults() end
    end, Hub)
    EventRegistry:RegisterCallback("Settings.Defaulted", function() Hub:RestoreDefaults() end, Hub)
    Settings.RegisterAddOnCategory(category)
    for id in pairs(Hub.modules) do Hub:RegisterModulePage(id) end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
    -- Retry if Blizzard's settings UI is loaded after this addon.
    if event == "PLAYER_LOGIN" or name == addonName or name == "Blizzard_Settings"
        or name == "Blizzard_Settings_Shared" then RegisterSettings() end
    if name == "Leatrix_Plus" or event == "PLAYER_LOGIN" then Hub:RefreshSettings() end
end)

-- Leatrix has no public setting-change event. Reevaluate only while settings are open.
local elapsed, previous = 0, {}
events:SetScript("OnUpdate", function(_, delta)
    if not Hub.category or not SettingsPanel or not SettingsPanel.IsShown or not SettingsPanel:IsShown() then return end
    elapsed = elapsed + delta
    if elapsed < 0.5 then return end
    elapsed = 0
    local changed = false
    for _, key in ipairs({ "autoRepair", "autoSellGreys" }) do
        local managed = Hub:IsFeatureManaged(key)
        if previous[key] ~= managed then previous[key], changed = managed, true end
    end
    if changed then
        Hub:RefreshSettings()
        if SettingsPanel.RepairDisplay then SettingsPanel:RepairDisplay() end
    end
end)
