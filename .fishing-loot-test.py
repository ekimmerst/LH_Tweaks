from pathlib import Path

# Reuse the host's full native-settings regression environment.
exec(Path('.settings-test.py').read_text())
lua.execute('''
local M=getmetatable(UIParent).__index
function M:GetScript(key) return self.scripts[key] end
local timers, native, attempts = {}, {}, {}
local loot, fishing, collect, fail = {}, true, true, false
C_Timer={After=function(delay,fn) assert(delay==1);table.insert(timers,fn) end}
function IsFishingLoot() return fishing end
function GetNumLootItems() return #loot end
function LootSlot(slot)
 table.insert(attempts,slot)
 if fail then error('Loot API failed') end
 if collect then
  table.remove(loot,slot)
  LootFrame.scripts.OnEvent(LootFrame,'LOOT_SLOT_CLEARED',slot)
 end
end
local function original(frame,event,...)
 table.insert(native,{event,...})
 if event=='LOOT_OPENED' then frame.shown=true end
 if event=='LOOT_CLOSED' then frame.shown=false end
end
local function newFrame()
 local f=CreateFrame('Frame');f:SetScript('OnEvent',original);f.shown=false;return f
end
local function send(event,...) LootFrame.scripts.OnEvent(LootFrame,event,...) end
local function flush() local current=timers;timers={};for _,fn in ipairs(current) do fn() end end
local function begin(isFishing,canCollect)
 native,attempts={},{};fishing=isFishing;collect=canCollect;loot={'a','b','c'}
 LootFrame.shown=false;send('LOOT_OPENED',true)
end
local function cmd(text) SlashCmdList.LH_TWEAKS(text) end
LootFrame=newFrame()
assert(not LH_TweaksDB.instantFishingLoot)
begin(true,true);assert(#attempts==0 and LootFrame.shown and native[1][2]==true)
cmd('instant-fishing-loot on')
local wrapper=LootFrame:GetScript('OnEvent');assert(wrapper~=original)
cmd('instant-fishing-loot on');assert(LootFrame:GetScript('OnEvent')==wrapper)
begin(true,true)
assert(#attempts==3 and attempts[1]==3 and attempts[3]==1 and #loot==0)
assert(not LootFrame.shown and #native==0,'Fishing loot window flashed')
send('LOOT_SLOT_CHANGED',1);assert(#native==0)
send('LOOT_CLOSED');flush();assert(#native==1 and native[1][1]=='LOOT_CLOSED')
begin(false,true);assert(#attempts==0 and LootFrame.shown and native[1][2]==true)
send('LOOT_SLOT_CHANGED',1);assert(#native==2)
-- Full bags or an uncollectable item get the native recovery UI after one second.
begin(true,false);assert(not LootFrame.shown and #native==0)
flush();assert(LootFrame.shown and #native==1 and native[1][2]==false)
send('LOOT_SLOT_CLEARED',1);assert(#native==2)
-- Closed or superseded sessions must never reopen another loot window.
begin(true,false);send('LOOT_CLOSED');flush();assert(not LootFrame.shown and #native==1)
begin(true,false);fishing=false;send('LOOT_OPENED',true);flush()
assert(#native==1 and native[1][2]==true)
begin(true,false);send('LOOT_OPENED',true);flush();assert(#native==1)
-- Disabling mid-session still exposes remaining items, then passes future loot through.
begin(true,false);cmd('instant-fishing-loot off');flush();assert(LootFrame.shown)
begin(true,true);assert(#attempts==0 and LootFrame.shown)
cmd('instant-fishing-loot invalid');assert(not LH_TweaksDB.instantFishingLoot)
cmd('instant-fishing-loot on extra');assert(not LH_TweaksDB.instantFishingLoot)
registry.LH_Tweaks_instantFishingLoot.set(true)
assert(LH_TweaksDB.instantFishingLoot and notices.LH_Tweaks_instantFishingLoot>0)
fail=true;begin(true,true);fail=false
assert(LootFrame.shown and #native==1,'Loot API failure did not recover')
-- Synchronous LOOT_CLOSED aborts attempts and invalidates delayed recovery.
local normalLootSlot=LootSlot
LootSlot=function(slot) table.insert(attempts,slot);send('LOOT_CLOSED') end
begin(true,true);flush();assert(#attempts==1 and #native==1 and not LootFrame.shown)
LootSlot=normalLootSlot
cmd('all off');assert(not LH_TweaksDB.instantFishingLoot)
cmd('all on');assert(LH_TweaksDB.instantFishingLoot)
LH_Tweaks:RestoreDefaults();assert(not LH_TweaksDB.instantFishingLoot)
-- Hook installation handles a late loot UI and waits until combat ends.
LootFrame=nil;combat=true;cmd('instant-fishing-loot on')
LootFrame=newFrame();coreEvent.scripts.OnEvent(coreEvent,'ADDON_LOADED','Blizzard_UIPanels_Game')
assert(LootFrame:GetScript('OnEvent')==original)
combat=false;coreEvent.scripts.OnEvent(coreEvent,'PLAYER_REGEN_ENABLED')
assert(LootFrame:GetScript('OnEvent')~=original)
begin(true,true);flush();assert(not LootFrame.shown and #attempts==3)
''')
source = Path('../BetterFishing/BetterFishing.lua').read_text()
assert 'InstallFishingLootHandler' not in source and 'silentLoot' not in source
print('PASS: silent fishing loot, descending slots, native passthrough, recovery, stale sessions, toggles/defaults, synchronous closure, API errors, late UI/combat deferral and BetterFishing migration')
