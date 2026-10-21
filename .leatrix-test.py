from pathlib import Path

exec(Path('.settings-test.py').read_text())
lua.execute('''
local loaded=false
C_AddOns={IsAddOnLoaded=function(name) return loaded and name=='Leatrix_Plus' end}
LeaPlusDB={AutoSellJunk='On',AutoRepairGear='On'}
local sold,repaired=0,0
C_MerchantFrame={SellAllJunkItems=function() sold=sold+1 end}
function CanMerchantRepair() return true end
function GetRepairAllCost() return 100,true end
function GetMoney() return 1000 end
function RepairAllItems(guild) assert(guild==false);repaired=repaired+1 end
local function merchant() coreEvent.scripts.OnEvent(coreEvent,'MERCHANT_SHOW') end
local function enable() LH_Tweaks:RunCommand('all on') end
local function row(key)
 for _,r in ipairs(LH_Tweaks.category.layout.rows) do
  if r.setting==registry['LH_Tweaks_'..key] then return r end
 end
end
enable();merchant();assert(sold==1 and repaired==1)
assert(not LH_Tweaks:IsFeatureManaged('autoRepair'))
loaded=true
assert(LH_Tweaks:IsFeatureManaged('autoRepair') and LH_Tweaks:IsFeatureManaged('autoSellGreys'))
assert(not row('autoRepair').canModify() and not row('autoSellGreys').canModify())
assert(row('autoRepair').tooltip():find('Already handled by Leatrix Plus',1,true))
assert(not registry.LH_Tweaks_autoRepair.get() and not registry.LH_Tweaks_autoSellGreys.get())
merchant();assert(sold==1 and repaired==1)
local notices=0
for _,r in ipairs(LH_Tweaks.category.layout.rows) do
 if r.shouldShow and r.shouldShow() then notices=notices+1 end
end
assert(notices==2)
-- Each external feature is evaluated independently.
LeaPlusDB.AutoSellJunk='Off';merchant();assert(sold==2 and repaired==1)
assert(row('autoSellGreys').canModify() and not row('autoRepair').canModify())
LeaPlusDB.AutoRepairGear='Off';merchant();assert(sold==3 and repaired==2)
assert(row('autoRepair').canModify())
-- Block direct and bulk activation while the corresponding external option is on.
LH_Tweaks:RunCommand('all off');LeaPlusDB.AutoRepairGear='On'
registry.LH_Tweaks_autoRepair.set(true);assert(not LH_TweaksDB.autoRepair)
LeaPlusDB.AutoSellJunk='On';LH_Tweaks:RunCommand('auto-sell-greys on');assert(not LH_TweaksDB.autoSellGreys)
enable();merchant();assert(sold==3 and repaired==2)
-- Unknown, absent and disabled data do not disable the controls.
LeaPlusDB={};assert(row('autoRepair').canModify() and row('autoSellGreys').canModify())
LeaPlusDB=nil;assert(not LH_Tweaks:IsFeatureManaged('autoRepair'))
LeaPlusDB={AutoRepairGear=true,AutoSellJunk=true};assert(LH_Tweaks:IsFeatureManaged('autoRepair'))
loaded=false;assert(not LH_Tweaks:IsFeatureManaged('autoRepair'))
merchant();assert(sold==4 and repaired==3)
''')
print('PASS: Leatrix absent/disabled/loaded, separate options, retained visible controls and notices, runtime suppression, direct/bulk commands and preference recovery')
