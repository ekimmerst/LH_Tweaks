from pathlib import Path

# Reuse the existing frame simulation without running its assertions.
source = Path('.location-layout-test.py').read_text()
exec(source.split("lua.execute(Path('LH_Tweaks.lua')")[0])
lua.execute('''
local M=getmetatable(UIParent).__index
function M:SetFrameStrata() end
function M:SetClampedToScreen() end
function M:CreateTexture() return setmetatable({}, {__index=M}) end
function M:SetTexture() end
function M:SetVertexColor() end
function M:GetOwner() return UIParent end
function M:GetRight() local p=self.points[1];return p and p[4] or 900 end
function M:GetBottom() local p=self.points[1];return p and p[5] or 40 end
function M:GetCenter() return self.dragX or 900,self.dragY or 40 end
function GameTooltip_SetDefaultAnchor(t,p)
 t:ClearAllPoints();t:SetPoint('BOTTOMRIGHT',UIParent,'BOTTOMLEFT',900,40)
end
local oldhook=hooksecurefunc
function hooksecurefunc(f,k,fn)
 if type(f)=='string' then
  local old=_G[f];_G[f]=function(...) old(...);k(...) end
 else oldhook(f,k,fn) end
end
GameTooltip=CreateFrame('GameTooltip',nil,UIParent)
GameTooltip.shown=false
LH_TweaksDB={minimapPositionRepair=1}
''')
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute('''
local e=frames[#frames]
function event(s,n) e.scripts.OnEvent(e,s,n) end
function cmd(s) SlashCmdList.LH_TWEAKS(s) end
event('ADDON_LOADED','LH_Tweaks');event('PLAYER_ENTERING_WORLD')
assert(not LH_TweaksDB.unlockTooltip and not LH_TweaksDB.tooltipPosition)
cmd('unlock-tooltip on')
local h=frames[#frames]
assert(h.shown and h.w==16 and h.points[1][4]==900)
h.scripts.OnDragStart();h.dragX=600;h.dragY=200;h.scripts.OnUpdate()
assert(GameTooltip.points[1][1]=='BOTTOMRIGHT' and GameTooltip.points[1][4]==600)
h.scripts.OnDragStop()
assert(LH_TweaksDB.tooltipPosition.x==0.6 and LH_TweaksDB.tooltipPosition.y==0.25)
cmd('unlock-tooltip off');assert(not h.shown)
GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
assert(GameTooltip.points[1][4]==600 and GameTooltip.points[1][5]==200)
cmd('unlock-tooltip on extra');assert(not LH_TweaksDB.unlockTooltip)
combat=true;cmd('unlock-tooltip on');assert(not h.shown)
combat=false;event('PLAYER_REGEN_ENABLED');assert(h.shown)
combat=true;h.scripts.OnDragStart();assert(not h.moving)
cmd('unlock-tooltip reset');assert(GameTooltip.points[1][4]==600)
combat=false;event('PLAYER_REGEN_ENABLED')
assert(h.shown and not LH_TweaksDB.tooltipPosition and GameTooltip.points[1][4]==900)
cmd('unlock-tooltip off');cmd('unlock-tooltip reset');assert(not h.shown)
cmd('all on');assert(LH_TweaksDB.unlockTooltip and h.shown)
cmd('all off');assert(not LH_TweaksDB.unlockTooltip and not h.shown)
LH_TweaksDB.tooltipPosition={x=0.3,y=0.2}
''')
# Simulate a new addon session with a saved, locked position.
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute('''
local e=frames[#frames];e.scripts.OnEvent(e,'ADDON_LOADED','LH_Tweaks')
e.scripts.OnEvent(e,'PLAYER_ENTERING_WORLD')
assert(GameTooltip.points[1][4]==300 and GameTooltip.points[1][5]==160)
assert(not frames[#frames].shown)
''')
print('PASS: tooltip default/off, circle, drag, bottom-right anchor, locking, reset, validation, combat deferral, bulk toggles and saved-position reload; Lua syntax')
