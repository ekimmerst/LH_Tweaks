from pathlib import Path

source = Path('.location-layout-test.py').read_text()
exec(source.split("lua.execute(Path('LH_Tweaks.lua')")[0])
lua.execute('''
local M=getmetatable(frames[1]).__index
function M:GetName() return self.name end
function M:GetID() return self.id end
function M:CreateTexture()
 local t={shown=false}
 function t:SetTexture(v) self.texture=v end
 function t:SetBlendMode(v) self.blend=v end
 function t:SetPoint() end
 function t:SetSize(w,h) self.w=w;self.h=h end
 function t:SetVertexColor(r,g,b,a) self.r=r;self.g=g;self.b=b;self.a=a end
 function t:Show() self.shown=true end
 function t:Hide() self.shown=false end
 self.glow=t;return t
end
function hooksecurefunc(object,key,fn)
 if type(object)=='string' then
  local old=_G[object];_G[object]=function(...) old(...);key(...) end
 else
  local old=object[key];object[key]=function(self,...) old(self,...);fn(self,...) end
 end
end
function SetItemButtonQuality() end
function IsEquippableItem(item) return item==1001 or item==1002 end
ITEM_QUALITY_COLORS={[1]={r=1,g=1,b=1},[3]={r=.1,g=.4,b=1}}
NUM_BAG_SLOTS=5
local bag=CreateFrame('Frame',nil,UIParent);bag.name='ContainerFrame1';bag.id=0
ContainerFrame1=bag
bagButton=CreateFrame('Button',nil,bag);bagButton.name='ContainerFrame1Item1';bagButton.id=1
bagButton.w=37;bagButton.h=37
function bagButton:GetBagID() return 0 end
charButton=CreateFrame('Button',nil,UIParent);charButton.name='CharacterHeadSlot';charButton.id=1
CharacterHeadSlot=charButton
function GetInventoryItemQuality(_,slot) if slot==1 then return 3 end end
function GetInventoryItemID(_,slot) if slot==1 then return 1002 end end
C_Container={GetContainerItemInfo=function(_,slot)
 if slot==1 then return {quality=3,itemID=1001} end
end}
''')
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute(Path('EquipmentGlow.lua').read_text(), 'LH_Tweaks')
lua.execute('''
local core,glowEvents=frames[#frames-1],frames[#frames]
core.scripts.OnEvent(core,'ADDON_LOADED','LH_Tweaks')
glowEvents.scripts.OnEvent(glowEvents,'ADDON_LOADED','LH_Tweaks')
assert(LH_TweaksDB.glowEquipment==true)
SetItemButtonQuality(bagButton,3,1001)
assert(bagButton.glow.shown and bagButton.glow.blend=='ADD')
assert(bagButton.glow.w==37*1.7 and bagButton.glow.b==1)
SetItemButtonQuality(charButton,3,1002)
assert(charButton.glow.shown)
SetItemButtonQuality(bagButton,1,1001)
assert(not bagButton.glow.shown)
SetItemButtonQuality(charButton,1,1002)
assert(not charButton.glow.shown)
SetItemButtonQuality(charButton,3,1002)
SetItemButtonQuality(bagButton,3,2000)
assert(not bagButton.glow.shown)
SetItemButtonQuality(bagButton,3,1001)
SlashCmdList.LH_TWEAKS('glow-equipment off')
assert(not bagButton.glow.shown and not charButton.glow.shown)
SlashCmdList.LH_TWEAKS('glow-equipment on')
assert(bagButton.glow.shown and charButton.glow.shown)
SetItemButtonQuality(charButton,nil,nil)
assert(not charButton.glow.shown)
LH_Tweaks:RestoreDefaults()
assert(LH_TweaksDB.glowEquipment and bagButton.glow.shown)
''')
print('PASS: default glow, bag and character quality, white item borders, equippable filter, live toggles, empty slots and defaults')
