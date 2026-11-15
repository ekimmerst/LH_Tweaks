local Hub = LH_Tweaks
local tooltip = GameTooltip
if not tooltip then return end

local build = select(4, GetBuildInfo()) or 0
local forever = build >= 16000 and build < 20000
local legacyInspect = not forever and type(GetTalentTabInfo) == "function" and build < 100000
local treeNames = {
    WARRIOR = { "Arms", "Fury", "Protection" },
    PALADIN = { "Holy", "Protection", "Retribution" },
    HUNTER = { "Beast Mastery", "Marksmanship", "Survival" },
    ROGUE = { "Assassination", "Combat", "Subtlety" },
    PRIEST = { "Discipline", "Holy", "Shadow" },
    SHAMAN = { "Elemental", "Enhancement", "Restoration" },
    MAGE = { "Arcane", "Fire", "Frost" },
    WARLOCK = { "Affliction", "Demonology", "Destruction" },
    DRUID = { "Balance", "Feral", "Restoration" },
}
local inspectConfig = Constants and Constants.TraitConsts and Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID or -1
local nodeTrees = {}
local cache = {}
local activeInspect, lastInspect, lastInspectTime
local shownGUID, detailsLine, originalColor

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if ok then return a, b, c, d, e end
end

local function Plain(value)
    if issecretvalue and SafeCall(issecretvalue, value) then return nil end
    return value
end

local function LegacyTalents(inspect)
    local count = Plain(SafeCall(GetNumTalentTabs, inspect))
    if type(count) ~= "number" or count < 3 then return nil end
    local points, names = {}, {}
    for i = 1, 3 do
        local first, second, third, _, fifth = SafeCall(GetTalentTabInfo, i, inspect)
        local spent = Plain(fifth)
        if type(spent) ~= "number" then spent = Plain(third) end
        if type(spent) ~= "number" then return nil end
        names[i] = type(Plain(first)) == "string" and Plain(first) or Plain(second)
        points[i] = spent
    end
    return points, names
end

local function ForeverTalents(unit, inspect)
    local traits, classTalents = C_Traits, C_ClassTalents
    if not (traits and traits.GetConfigInfo and traits.GetTreeNodes and traits.GetNodeInfo) then return nil end
    local configID = inspect and inspectConfig or SafeCall(classTalents and classTalents.GetActiveConfigID)
    if not configID then return nil end
    local config = SafeCall(traits.GetConfigInfo, configID)
    if type(config) ~= "table" or type(config.treeIDs) ~= "table" then return nil end
    local points, found = { 0, 0, 0 }, false
    for _, treeID in ipairs(config.treeIDs) do
        local nodes = SafeCall(traits.GetTreeNodes, treeID)
        if type(nodes) == "table" then
            for _, nodeID in ipairs(nodes) do
                local node = SafeCall(traits.GetNodeInfo, configID, nodeID)
                local id = type(node) == "table" and Plain(node.ID)
                if type(id) == "number" and id ~= 0 then
                    found = true
                    local tree = nodeTrees[nodeID]
                    if not tree then
                        local x = Plain(node.posX)
                        if type(x) == "number" then
                            tree = x < 4000 and 1 or x < 8000 and 2 or 3
                            nodeTrees[nodeID] = tree
                        end
                    end
                    local rank = Plain(node.ranksPurchased or node.currentRank or node.activeRank)
                    if tree and type(rank) == "number" then points[tree] = points[tree] + rank end
                end
            end
        end
    end
    return found and points or nil
end

local function MainTree(points, names)
    if not points then return nil end
    local best = 1
    for i = 2, 3 do if points[i] > points[best] then best = i end end
    if points[best] == 0 then return nil end
    return names and names[best]
end

local function ModernSpec(unit, self)
    local api = C_SpecializationInfo
    local specID
    if self then
        local getSpec = api and api.GetSpecialization or GetSpecialization
        local getInfo = api and api.GetSpecializationInfo or GetSpecializationInfo
        local index = Plain(SafeCall(getSpec))
        if index then specID = Plain(SafeCall(getInfo, index)) end
    else
        specID = Plain(SafeCall(api and api.GetInspectSpecialization or GetInspectSpecialization, unit))
    end
    if type(specID) ~= "number" or specID <= 0 then return nil end
    local getByID = api and api.GetSpecializationInfoByID or GetSpecializationInfoByID
    local _, name = SafeCall(getByID, specID)
    return Plain(name)
end

local function TalentText(unit, inspect)
    local _, class = SafeCall(UnitClass, unit)
    class = Plain(class)
    local points, names
    if forever then
        points, names = ForeverTalents(unit, inspect), treeNames[class]
    else
        points, names = LegacyTalents(inspect)
    end
    local spec = MainTree(points, names)
    if not forever and not spec then spec = ModernSpec(unit, not inspect) end
    local distribution = points and string.format("%d/%d/%d", points[1], points[2], points[3])
    if spec and distribution then return spec .. " (" .. distribution .. ")" end
    return spec or distribution
end

local function CurrentUnit()
    local _, unit = SafeCall(tooltip.GetUnit, tooltip)
    unit = Plain(unit)
    if not unit or not Plain(SafeCall(UnitIsPlayer, unit)) then return nil end
    local guid = Plain(SafeCall(UnitGUID, unit))
    if type(guid) ~= "string" then return nil end
    return unit, guid
end

local function FirstLine()
    return _G[(tooltip:GetName() or "GameTooltip") .. "TextLeft1"]
end

local function RestoreName()
    local line = FirstLine()
    if line and originalColor then line:SetTextColor(unpack(originalColor)) end
    originalColor = nil
end

local function Draw()
    if not LH_TweaksDB or not LH_TweaksDB.tooltipPlayerDetails then
        RestoreName()
        if detailsLine then detailsLine:SetText("") end
        return
    end
    local unit, guid = CurrentUnit()
    if not unit then return end
    if shownGUID ~= guid then
        RestoreName()
        if detailsLine then detailsLine:SetText("") end
        shownGUID, detailsLine = guid, nil
    end
    local _, class = SafeCall(UnitClass, unit)
    class = Plain(class)
    local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    local line = FirstLine()
    if line and color then
        if not originalColor then originalColor = { line:GetTextColor() } end
        line:SetTextColor(color.r, color.g, color.b)
    end
    local self = Plain(SafeCall(UnitIsUnit, unit, "player"))
    local text
    if self then
        text = TalentText(unit, false)
    else
        local item = cache[guid]
        if item and GetTime() - item.time < 300 then text = item.text end
    end
    if text then
        if detailsLine then
            detailsLine:SetText(text)
        else
            tooltip:AddLine(text, 0.8, 0.8, 0.8)
            detailsLine = _G[(tooltip:GetName() or "GameTooltip") .. "TextLeft" .. tooltip:NumLines()]
            tooltip:Show()
        end
    end
    if not self and type(NotifyInspect) == "function" and type(CanInspect) == "function"
        and not (InCombatLockdown and InCombatLockdown())
        and (not cache[guid] or not cache[guid].text or GetTime() - cache[guid].time >= 300)
        and (not activeInspect or GetTime() - lastInspectTime > 5)
        and (not lastInspect or lastInspect ~= guid or GetTime() - lastInspectTime > 30)
        and Plain(SafeCall(CanInspect, unit)) then
        lastInspect, lastInspectTime, activeInspect = guid, GetTime(), { guid = guid, unit = unit }
        SafeCall(NotifyInspect, unit)
    end
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "INSPECT_READY", "INSPECT_TALENT_READY", "PLAYER_TALENT_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "TRAIT_CONFIG_UPDATED" }) do
    if not (C_EventUtils and C_EventUtils.IsEventValid) or C_EventUtils.IsEventValid(event) then
        pcall(events.RegisterEvent, events, event)
    end
end
events:SetScript("OnEvent", function(_, event, guid)
    if event == "INSPECT_READY" or event == "INSPECT_TALENT_READY" then
        if (event == "INSPECT_TALENT_READY") ~= legacyInspect then return end
        local request = activeInspect
        if not request or (guid and guid ~= request.guid) then return end
        activeInspect = nil
        if Plain(SafeCall(UnitGUID, request.unit)) ~= request.guid then return end
        cache[request.guid] = { text = TalentText(request.unit, true), time = GetTime() }
        local _, currentGUID = CurrentUnit()
        if currentGUID == request.guid then Draw() end
    elseif shownGUID then
        local unit, currentGUID = CurrentUnit()
        if unit and currentGUID == shownGUID then Draw() end
    end
end)

tooltip:HookScript("OnTooltipCleared", function()
    shownGUID, detailsLine, originalColor = nil, nil, nil
end)
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
    and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(frame)
        if frame == tooltip then Draw() end
    end)
else
    tooltip:HookScript("OnTooltipSetUnit", Draw)
end

function Hub:RefreshTooltipPlayerDetails()
    Draw()
end
