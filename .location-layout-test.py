# Requires Lupa: python -m pip install --target .test-runtime lupa
# Run from the addon directory: python .location-layout-test.py
import sys
from pathlib import Path
sys.path.insert(0, str(Path('.test-runtime').resolve()))
from lupa import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
unpack=table.unpack; SlashCmdList={}; DEFAULT_CHAT_FRAME={AddMessage=function() end}
local M={}
function M:SetParent(p) self.parent=p; if p then p.children[#p.children+1]=self end end
function M:GetChildren() local t={}; for _,v in ipairs(self.children) do if v.parent==self then t[#t+1]=v end end; return table.unpack(t) end
function M:SetPoint(...) self.points={{...}} end
function M:GetPoint(i) return table.unpack(self.points[i] or {}) end
function M:GetNumPoints() return #self.points end
function M:ClearAllPoints() self.points={} end
function M:SetSize(w,h) self.w=w;self.h=h end
function M:GetSize() return self.w,self.h end
function M:GetScale() return 1 end
function M:SetScale() end
function M:GetEffectiveScale() return 1 end
function M:GetWidth() return self.w end
function M:GetHeight() return self.h end
function M:GetFrameLevel() return 1 end
function M:SetFrameLevel() end
function M:SetUserPlaced(v) assert(self.movable, 'SetUserPlaced requires a movable frame'); self.placed=v end
function M:IsUserPlaced() return self.placed or false end
function M:SetMovable(v) self.movable=v end
function M:IsMovable() return self.movable or false end
function M:Hide() self.shown=false end
function M:IsShown() return self.shown end
function M:SetShown(v) self.shown=v end
function M:SetAllPoints() end
function M:EnableMouse() end
function M:RegisterForDrag() end
function M:RegisterEvent() end
function M:SetScript(k,v) self.scripts[k]=v end
function M:MarkDirty() self.dirty=true end
function M:StartMoving() self.moving=true end
function M:StopMovingOrSizing() self.moving=false end
function M:GetCenter()
 if self.dragX then return self.dragX,300 end
 local p=self.points[1]; if not p or p[2]==UIParent then return p and p[4] or 0,300 end
 local x=p[2]:GetCenter(); return x+(p[4] or 0),300
end
function M:Layout()
 local left,right
 for _,f in ipairs({self:GetChildren()}) do
  if not f.ignoreInLayout and (f.shown or f.includeAsLayoutChildWhenHidden) then
   local x=f:GetCenter(); left=math.min(left or x,x-f.w/2);right=math.max(right or x,x+f.w/2)
  end
 end
 self.w=right-left; self.dirty=false
end
frames={}
function CreateFrame(_,_,parent) local f=setmetatable({children={},points={},scripts={},w=150,h=23,shown=true},{__index=M}); f:SetParent(parent);frames[#frames+1]=f;return f end
function hooksecurefunc(f,k,fn) if type(f)=='string' then return end;local old=f[k];f[k]=function(self,...) old(self,...);fn(self,...) end end
function InCombatLockdown() return combat end
UIParent=CreateFrame(); UIParent:SetSize(1000,800)
MinimapCluster=CreateFrame('Frame',nil,UIParent);MinimapCluster.placed=true;MinimapCluster:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',-200,0)
local c=MinimapCluster
c.MinimapContainer=CreateFrame('Frame',nil,c);c.MinimapContainer:SetSize(215,226);c.MinimapContainer:SetPoint('TOP',UIParent,'TOP',900,0)
c.ZoneTextButton=CreateFrame('Frame',nil,c);c.ZoneTextButton:SetPoint('TOP',c.MinimapContainer,'TOP',10,0)
c.Tracking=CreateFrame('Frame',nil,c);c.Tracking:SetPoint('RIGHT',c.ZoneTextButton,'LEFT',-20,0)
GameTimeFrame=CreateFrame('Frame',nil,c);GameTimeFrame:SetPoint('LEFT',c.ZoneTextButton,'RIGHT',20,0)
c:Layout(); baseline=c.w
LH_TweaksDB={locationBar=false,locationBarPosition={x=0.1,y=0.4}}
''')
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute('''
local e=frames[#frames];function event(s,n) e.scripts.OnEvent(e,s,n) end
function cmd(s) SlashCmdList.LH_TWEAKS(s) end
event('ADDON_LOADED','LH_Tweaks');assert(not MinimapCluster.ZoneTextButton.ignoreInLayout)
combat=true;event('PLAYER_ENTERING_WORLD');assert(LH_TweaksDB.minimapPositionRepair==nil)
combat=false;event('PLAYER_REGEN_ENABLED')
local c=MinimapCluster;local bar=c.ZoneTextButton
assert(c.points[1][1]=='TOPRIGHT' and c.points[1][4]==0 and not c.placed and not c:IsMovable())
assert(LH_TweaksDB.minimapPositionRepair==1)
assert(bar.ignoreInLayout and c.Tracking.ignoreInLayout and GameTimeFrame.ignoreInLayout)
assert(not c.MinimapContainer.ignoreInLayout)
c:Layout();assert(c.w==baseline, 'Saved header position changed minimap bounds')
cmd('unlock-location-bar on')
local handle
for _,f in ipairs(frames) do if f.scripts.OnDragStart then handle=f end end
handle.scripts.OnDragStart();bar.dragX=50;handle.scripts.OnDragStop();bar.dragX=nil
c:Layout();assert(c.w==baseline,'Dragging changed minimap bounds')
cmd('unlock-location-bar off');assert(not handle.shown)
bar.placed=true
c:Layout();assert(c.w==baseline)
cmd('unlock-location-bar reset');assert(not bar.ignoreInLayout and not c.Tracking.ignoreInLayout)
assert(not bar:IsMovable() and not bar:IsUserPlaced())
c:Layout();assert(c.w==baseline and LH_TweaksDB.locationBarPosition==nil)
c:SetPoint('CENTER',UIParent,'CENTER',123,0);event('PLAYER_ENTERING_WORLD');assert(c.points[1][1]=='CENTER','Repair repeated')
cmd('unlock-location-bar on');handle.scripts.OnDragStart();bar.dragX=30;handle.scripts.OnDragStop();bar.dragX=nil
c:Layout();assert(c.w==baseline,'Second drag changed bounds')
''')
print('PASS: saved-position restoration, drag/off/reset/repeated drag preserve minimap bounds; attached frames excluded; one-time standard-position repair; startup and combat deferral; Lua syntax')
