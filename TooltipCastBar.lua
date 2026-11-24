local Hub = LH_Tweaks
local tooltip = GameTooltip
if not tooltip then return end

local healthBar = GameTooltipStatusBar
local bar = CreateFrame("StatusBar", nil, tooltip)
bar:SetHeight(17)
bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar:SetFrameLevel(tooltip:GetFrameLevel() + 2)
bar:SetStatusBarColor(1, 0.7, 0.2)
bar:Hide()

local background = bar:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints()
background:SetColorTexture(0.08, 0.08, 0.08, 0.95)

local label = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
label:SetPoint("LEFT", bar, "LEFT", 5, 0)
label:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
label:SetJustifyH("CENTER")

local castStart, castEnd, channeling, shownUnit, shownGUID, shownName

local function Plain(value)
    if issecretvalue and issecretvalue(value) then return nil end
    return value
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f = pcall(fn, ...)
    if ok then return a, b, c, d, e, f end
end

local function Hide()
    castStart, castEnd, channeling, shownUnit, shownGUID, shownName = nil, nil, nil, nil, nil, nil
    bar:Hide()
end

local function Place()
    local anchor = healthBar and healthBar:IsShown() and healthBar or tooltip
    if bar.anchor ~= anchor then
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -3)
        bar.anchor = anchor
    end
    local width = anchor:GetWidth()
    if bar:GetWidth() ~= width then bar:SetWidth(width) end
end

local function Refresh()
    if not LH_TweaksDB or not LH_TweaksDB.tooltipCastBar or not tooltip:IsShown() then Hide(); return end
    local _, unit = SafeCall(tooltip.GetUnit, tooltip)
    unit = Plain(unit)
    if type(unit) ~= "string" then Hide(); return end
    local guid = Plain(SafeCall(UnitGUID, unit))
    if type(guid) ~= "string" then Hide(); return end

    local name, _, _, _, startTime, endTime = SafeCall(UnitCastingInfo, unit)
    local isChannel = false
    if not Plain(name) then
        name, _, _, _, startTime, endTime = SafeCall(UnitChannelInfo, unit)
        isChannel = true
    end
    name, startTime, endTime = Plain(name), Plain(startTime), Plain(endTime)
    if type(name) ~= "string" or type(startTime) ~= "number" or type(endTime) ~= "number"
        or endTime <= startTime or GetTime() * 1000 >= endTime then
        Hide()
        return
    end

    local changed = shownGUID ~= guid or shownUnit ~= unit or shownName ~= name or castStart ~= startTime
        or castEnd ~= endTime or channeling ~= isChannel
    castStart, castEnd, channeling, shownUnit, shownGUID, shownName = startTime, endTime, isChannel, unit, guid, name
    if changed then
        label:SetText(name)
        if isChannel then
            bar:SetStatusBarColor(0.25, 0.7, 1)
        else
            bar:SetStatusBarColor(1, 0.7, 0.2)
        end
        bar:SetMinMaxValues(0, (endTime - startTime) / 1000)
    end
    Place()
    local elapsed = GetTime() - startTime / 1000
    bar:SetValue(isChannel and (endTime - startTime) / 1000 - elapsed or elapsed)
    bar:Show()
end

local events = CreateFrame("Frame")
for _, event in ipairs({
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP", "UNIT_SPELLCAST_EMPOWER_UPDATE",
    "PLAYER_TARGET_CHANGED",
}) do
    if not (C_EventUtils and C_EventUtils.IsEventValid) or C_EventUtils.IsEventValid(event) then
        pcall(events.RegisterEvent, events, event)
    end
end
events:SetScript("OnEvent", function()
    if tooltip:IsShown() then Refresh() end
end)

bar:SetScript("OnUpdate", function(self, elapsed)
    self.refreshElapsed = (self.refreshElapsed or 0) + elapsed
    if self.refreshElapsed >= 0.05 then
        self.refreshElapsed = 0
        Refresh()
    end
end)
tooltip:HookScript("OnHide", Hide)
tooltip:HookScript("OnTooltipCleared", Hide)
tooltip:HookScript("OnShow", Refresh)
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
    and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(frame)
        if frame == tooltip then Refresh() end
    end)
else
    tooltip:HookScript("OnTooltipSetUnit", Refresh)
end

function Hub:RefreshTooltipCastBar()
    Refresh()
end
