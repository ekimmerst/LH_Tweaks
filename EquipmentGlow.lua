-- Extra quality glow for equippable items in Blizzard bags and on the paper doll.
local Hub = LH_Tweaks
local overlays = setmetatable({}, { __mode = "k" })
local slots = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
    "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0",
    "Trinket1", "MainHand", "SecondaryHand", "Ranged",
}
local characterButtons = {}
for _, slot in ipairs(slots) do characterButtons["Character" .. slot .. "Slot"] = true end

local function IsEquipment(item)
    if not item then return false end
    if IsEquippableItem then return IsEquippableItem(item) end
    if GetItemInfoInstant then
        local _, _, _, equipLocation = GetItemInfoInstant(item)
        return equipLocation and equipLocation ~= ""
    end
    return false
end

local function BagID(button)
    if button.GetBagID then
        local bag = button:GetBagID()
        if bag ~= nil then return bag end
    end
    local name = button.GetName and button:GetName()
    if name and name:match("^ContainerFrame%d+Item%d+$") then
        local parent = button:GetParent()
        return parent and parent.GetID and parent:GetID()
    end
end

local function SetGlow(button, quality, item)
    local name = button.GetName and button:GetName()
    local onCharacter = name and characterButtons[name]
    local bag = not onCharacter and BagID(button)
    if not onCharacter and (type(bag) ~= "number" or bag < 0 or bag > (NUM_BAG_SLOTS or 5)) then return end

    local glow = overlays[button]
    local enabled = LH_TweaksDB and LH_TweaksDB.glowEquipment
    if not enabled or type(quality) ~= "number" or quality < 2
        or (not onCharacter and not IsEquipment(item)) then
        if glow then glow:Hide() end
        return
    end

    local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if not color then
        if glow then glow:Hide() end
        return
    end
    if not glow then
        glow = button:CreateTexture(nil, "OVERLAY")
        glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        glow:SetBlendMode("ADD")
        glow:SetPoint("CENTER", button, "CENTER", 0, 0)
        overlays[button] = glow
    end
    -- The artwork is mostly transparent; this size makes its colored ring thicker.
    glow:SetSize((button:GetWidth() or 37) * 1.7, (button:GetHeight() or 37) * 1.7)
    glow:SetVertexColor(color.r, color.g, color.b, 1)
    glow:Show()
end

local function RefreshBagButton(button)
    local bag = BagID(button)
    if type(bag) ~= "number" or bag < 0 or bag > (NUM_BAG_SLOTS or 5) then return end
    local slot = button.GetID and button:GetID()
    if not slot or slot < 1 then return end
    local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
    if info then
        SetGlow(button, info.quality, info.itemID or info.hyperlink)
    elseif GetContainerItemInfo then
        local _, _, _, quality, _, _, link, _, _, itemID = GetContainerItemInfo(bag, slot)
        SetGlow(button, quality, itemID or link)
    else
        SetGlow(button)
    end
end

local function Scan(frame, depth)
    if not frame or depth > 10 or not frame.GetChildren then return end
    for _, child in ipairs({ frame:GetChildren() }) do
        if child.GetBagID or (child.GetName and (child:GetName() or ""):match("^ContainerFrame%d+Item%d+$")) then
            RefreshBagButton(child)
        end
        Scan(child, depth + 1)
    end
end

function Hub:RefreshEquipmentGlow()
    for button, glow in pairs(overlays) do
        if not LH_TweaksDB or not LH_TweaksDB.glowEquipment then glow:Hide() end
    end
    if not LH_TweaksDB or not LH_TweaksDB.glowEquipment then return end
    for _, slot in ipairs(slots) do
        local button = _G["Character" .. slot .. "Slot"]
        if button then
            local id = button:GetID()
            SetGlow(button, GetInventoryItemQuality("player", id), GetInventoryItemID("player", id))
        end
    end
    for i = 1, (NUM_CONTAINER_FRAMES or 13) do
        local frame = _G["ContainerFrame" .. i]
        if frame and frame:IsShown() then Scan(frame, 0) end
    end
    if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() then
        Scan(ContainerFrameCombinedBags, 0)
    end
end

local hooked = false
local function InstallHook()
    if hooked or type(SetItemButtonQuality) ~= "function" then return end
    hooked = true
    hooksecurefunc("SetItemButtonQuality", function(button, quality, item)
        SetGlow(button, quality, item)
    end)
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "BAG_UPDATE_DELAYED",
    "PLAYER_EQUIPMENT_CHANGED", "GET_ITEM_INFO_RECEIVED" }) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then InstallHook() end
    if Hub:IsReady() then Hub:RefreshEquipmentGlow() end
end)
