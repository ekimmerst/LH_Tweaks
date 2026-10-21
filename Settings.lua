local addonName = ...
local Hub = LH_Tweaks
local variables = {}

local function Header(layout, title)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end

local function Button(layout, label, text, callback, tooltip)
    layout:AddInitializer(CreateSettingsButtonInitializer(label, text, callback, tooltip, true))
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
    local section
    for _, feature in ipairs(Hub.features) do
        if section ~= feature.section then
            section = feature.section
            Header(layout, section)
        end
        local variable = "LH_Tweaks_" .. feature.key
        variables[#variables + 1] = variable
        local setting = Settings.RegisterProxySetting(category, variable, "boolean", feature.label, false,
            function() return Hub:GetFeature(feature.key) end,
            function(value) Hub:RunCommand(feature.command .. (value and " on" or " off")) end)
        local initializer = Settings.CreateCheckbox(category, setting, function()
            if Hub:IsFeatureManaged(feature.key) then
                return "Already handled by Leatrix Plus. Disable the corresponding option in Leatrix Plus to use LH Tweaks instead."
            end
            return feature.tooltip .. " Changes are saved per character; layout changes wait until combat ends."
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
    Header(layout, "All features")
    Button(layout, "Enable all tweaks", "Enable all", function() Hub:RunCommand("all on") end,
        "Enable every feature, including automatic repairs, grey-item sales and position unlocking.")
    Button(layout, "Disable all tweaks", "Disable all", function() Hub:RunCommand("all off") end,
        "Disable every feature and keep saved positions. Defaults also clears saved positions.")

    -- Keep Blizzard's list, controls and right-aligned Defaults button intact.
    -- Only the content heading differs from the navigation label.
    hooksecurefunc(SettingsPanel, "DisplayCategory", function(panel, selected)
        if selected == category then
            panel:GetSettingsList().Header.Title:SetText("LiteHawk Tweaks")
            Hub:RefreshSettings()
        end
    end)
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
