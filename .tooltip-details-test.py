from pathlib import Path
import sys

sys.path.insert(0, str(Path('.test-runtime').resolve()))
from lupa import LuaRuntime

lua = LuaRuntime()
lua.execute('''
LH_Tweaks = {}
LH_TweaksDB = { tooltipTargetOfTarget = true }
_G = {}
mode = "owner"
local function Line()
    return {
        SetText = function(self, value) self.text = value end,
        SetTextColor = function(self, r, g, b) self.r, self.g, self.b = r, g, b end,
    }
end
GameTooltip = { n = 1, shown = true }
function GameTooltip:GetUnit()
    if mode == "enemy" then return "Enemy", "target" end
    return "Me", "player"
end
function GameTooltip:GetOwner()
    if mode == "owner" then return { unit = "target" } end
end
function GameTooltip:GetName() return "GameTooltip" end
function GameTooltip:NumLines() return self.n end
function GameTooltip:AddDoubleLine()
    self.n = self.n + 1
    _G["GameTooltipTextLeft" .. self.n] = Line()
    _G["GameTooltipTextRight" .. self.n] = Line()
end
function GameTooltip:Show() self.shown = true end
function GameTooltip:IsShown() return self.shown end
function GameTooltip:HookScript(name, fn) self[name] = fn end
GetBuildInfo = function() return nil, nil, nil, 16001 end
CreateFrame = function() return { RegisterEvent = function() end, SetScript = function() end } end
UnitExists = function(unit)
    if unit == "target" then return true end
    return unit == "targettarget" and mode == "enemy"
end
UnitName = function(unit) return unit == "targettarget" and "Bob" or "Me" end
UnitClass = function() return "Mage", "MAGE" end
UnitIsUnit = function(a, b)
    return (a == "target" and b == "player" and mode ~= "enemy")
        or (a == "target" and b == "target")
end
UnitIsPlayer = function() return false end
UnitGUID = function() return "guid" end
RAID_CLASS_COLORS = { MAGE = { r = 0.25, g = 0.75, b = 1 } }
''')
lua.execute(Path('TooltipDetails.lua').read_text(encoding='utf-8'))
lua.execute('''
GameTooltip.OnTooltipSetUnit()
assert(_G.GameTooltipTextLeft2.text == "Target:")
assert(_G.GameTooltipTextRight2.text == "MYSELF")
assert(_G.GameTooltipTextRight2.r == 0.25)
mode = "player"
GameTooltip.OnUpdate(GameTooltip, 0.2)
assert(_G.GameTooltipTextRight2.text == "MYSELF")
mode = "enemy"
GameTooltip.OnUpdate(GameTooltip, 0.2)
assert(_G.GameTooltipTextRight2.text == "Bob")
assert(GameTooltip.n == 2)
LH_TweaksDB.tooltipTargetOfTarget = false
LH_Tweaks:RefreshTooltipDetails()
assert(_G.GameTooltipTextRight2.text == "")
''')
print('PASS: target-frame owner, player unit, MYSELF, class color, target changes, and toggle')
