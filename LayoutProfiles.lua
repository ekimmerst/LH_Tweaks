-- Shared settings snapshots for the LH addons. The source choice lives in each
-- addon's per-character database; snapshots are available across characters.
LH_LayoutProfiles = LH_LayoutProfiles or {}
local profiles = LH_LayoutProfiles
local active = {}

local function CurrentCharacter()
    local name = UnitName("player")
    local realm = (GetNormalizedRealmName and GetNormalizedRealmName())
        or (GetRealmName and GetRealmName())
    if not name or not realm then return end
    return name .. "-" .. realm:gsub("%s+", "")
end

local function CurrentDisplayName()
    local full = GetUnitName and GetUnitName("player")
    if type(full) == "string" and full:find(" ", 1, true) then return full end
    local name, surname
    if UnitFullName then name, surname = UnitFullName("player") end
    local realm = GetRealmName and GetRealmName()
    local normalized = GetNormalizedRealmName and GetNormalizedRealmName()
    if type(name) == "string" and type(surname) == "string" and surname ~= ""
        and surname ~= realm and surname ~= normalized then
        return name:find(" ", 1, true) and name or name .. " " .. surname
    end
    return type(full) == "string" and full or name or UnitName("player")
end

local function ProfileLabel(id, key)
    local snapshot = LH_TweaksLayoutProfiles[id] and LH_TweaksLayoutProfiles[id][key]
    return type(snapshot) == "table" and snapshot.__displayName
        or key:match("^[^-]+") or key
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function Read(db, path)
    local value = db
    for part in path:gmatch("[^.]+") do
        if type(value) ~= "table" then return nil end
        value = value[part]
    end
    return value
end

local function Write(db, path, value)
    local parts = {}
    for part in path:gmatch("[^.]+") do parts[#parts + 1] = part end
    local target = db
    for index = 1, #parts - 1 do
        local part = parts[index]
        if type(target[part]) ~= "table" then
            if value == nil then return end
            target[part] = {}
        end
        target = target[part]
    end
    target[parts[#parts]] = Copy(value)
end

local function Snapshot(db, keys)
    local result = {__profileKeys = {}}
    for _, key in ipairs(keys) do
        result.__profileKeys[key] = true -- Also remember keys whose value is nil.
        result[key] = Copy(Read(db, key))
    end
    return result
end

local function Apply(db, keys, values)
    for _, key in ipairs(keys) do
        -- Older snapshots lack newly shared options. Leave those local values alone
        -- until the source character logs in with the newer addon version.
        if (values.__profileKeys and values.__profileKeys[key]) or values[key] ~= nil then
            Write(db, key, values[key])
        end
    end
end

function profiles:Register(id, db, owner, keys)
    if active[id] or type(db) ~= "table" or type(owner) ~= "table" then return end
    LH_TweaksLayoutProfiles = type(LH_TweaksLayoutProfiles) == "table" and LH_TweaksLayoutProfiles or {}
    local character = CurrentCharacter()
    if not character then return end
    local snapshots = LH_TweaksLayoutProfiles[id]
    if type(snapshots) ~= "table" then
        snapshots = {}
        LH_TweaksLayoutProfiles[id] = snapshots
    end
    -- Migrate older LH Tweaks choices that were never sent to companion addons.
    -- This runs before each companion builds its frames, so no reload is needed.
    local tweaks = active.LH_Tweaks
    if id ~= "LH_Tweaks" and tweaks and tweaks.owner.layoutSource
        and not tweaks.owner.profileBroadcastV2 and not owner.layoutSource
        and type(snapshots[tweaks.owner.layoutSource]) == "table" then
        owner.layoutSource = tweaks.owner.layoutSource
    end
    local own = Snapshot(db, keys)
    local displayName = CurrentDisplayName()
    own.__displayName = displayName
    if type(snapshots[character]) == "table" then
        snapshots[character].__displayName = displayName
    end
    local source = owner.layoutSource
    local borrowed = false
    if type(source) ~= "string" or source == "" or source == character then
        owner.layoutSource = nil
        snapshots[character] = own
    elseif type(snapshots[source]) == "table" then
        Apply(db, keys, snapshots[source])
        borrowed = true
    end
    active[id] = {db = db, owner = owner, keys = keys, own = own,
        character = character, displayName = displayName, borrowed = borrowed}
end

local function ChangeSource(id, entry, source)
    if source == "" or source == entry.character then source = nil end
    if source and not (LH_TweaksLayoutProfiles[id] or {})[source] then return false end
    if entry.owner.layoutSource == source then return false end
    if not entry.borrowed then
        local snapshot = Snapshot(entry.db, entry.keys)
        snapshot.__displayName = entry.displayName
        LH_TweaksLayoutProfiles[id][entry.character] = snapshot
    end
    entry.owner.layoutSource = source
    return true
end

function profiles:SetSource(id, source)
    local entry = active[id]
    if not entry or not ChangeSource(id, entry, source) then return end
    if id == "LH_Tweaks" then
        entry.owner.profileBroadcastV2 = true
        self:ApplyTweaksSourceToAll(true)
    else
        ReloadUI()
    end
end

function profiles:ApplyTweaksSourceToAll(reloadTweaks)
    local tweaks = active.LH_Tweaks
    if not tweaks then return end
    local source = tweaks.owner.layoutSource
    local changed, missing = 0, {}
    for id, entry in pairs(active) do
        if id ~= "LH_Tweaks" then
            if source and not (LH_TweaksLayoutProfiles[id] or {})[source] then
                missing[#missing + 1] = id
            elseif ChangeSource(id, entry, source) then
                changed = changed + 1
            end
        end
    end
    local notice
    if #missing > 0 then
        table.sort(missing)
        notice = "LH Tweaks: No saved settings from " .. ProfileLabel("LH_Tweaks", source) .. " for "
            .. table.concat(missing, ", ")
            .. ". Log into that character with these addons enabled, then log out and apply again."
    end
    if changed > 0 or reloadTweaks then
        if notice then tweaks.owner.layoutProfileNotice = notice end
        ReloadUI()
    elseif notice then
        print(notice)
    end
end

function profiles:AddSetting(category, layout, id)
    local entry = active[id]
    if not entry or not Settings or not Settings.CreateDropdown then return end
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Settings profile"))
    local variable = id .. "_layoutSource"
    local setting = Settings.RegisterProxySetting(category, variable, "string", "Use settings from", "",
        function() return entry.owner.layoutSource or "" end,
        function(value) profiles:SetSource(id, value) end)
    local function Choices()
        local container = Settings.CreateControlTextContainer()
        container:Add("", "This character", "Keep this character's own settings.")
        local names = {}
        for name in pairs(LH_TweaksLayoutProfiles[id] or {}) do
            if name ~= entry.character then names[#names + 1] = name end
        end
        table.sort(names)
        for _, name in ipairs(names) do
            container:Add(name, ProfileLabel(id, name), "Use this character's saved settings.")
        end
        return container:GetData()
    end
    Settings.CreateDropdown(category, setting, Choices,
        "Configure the source character first, then log out. Edit shared settings on that character. Changes made here while using a source last only until logout. Character-specific lists and combat data remain separate.")
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        local tweaks = active.LH_Tweaks
        if tweaks then tweaks.owner.profileBroadcastV2 = true end
        if type(LH_TweaksDB) == "table" and LH_TweaksDB.layoutProfileNotice then
            print(LH_TweaksDB.layoutProfileNotice)
            LH_TweaksDB.layoutProfileNotice = nil
        end
        return
    end
    for id, entry in pairs(active) do
        if entry.borrowed then
            -- Do not serialize borrowed values into the character/class/account DB.
            Apply(entry.db, entry.keys, entry.own)
        elseif not entry.owner.layoutSource then
            local snapshot = Snapshot(entry.db, entry.keys)
            snapshot.__displayName = entry.displayName
            LH_TweaksLayoutProfiles[id][entry.character] = snapshot
        end
    end
end)
