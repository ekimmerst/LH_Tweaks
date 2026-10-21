from pathlib import Path

source = Path('.location-layout-test.py').read_text()
exec(source.split("lua.execute(Path('LH_Tweaks.lua')")[0])
lua.execute('''
LH_TweaksDB={minimapPositionRepair=1,autoRepair=true}
registry={}; registered={}; notices={}; callbacks={}; buttons={}
Settings={}
function Settings.RegisterVerticalLayoutCategory(name)
 local category={name=name};local layout={rows={}}
 function layout:AddInitializer(row) table.insert(self.rows,row) end
 category.layout=layout;return category,layout
end
function Settings.RegisterVerticalLayoutSubcategory(parent,name)
 local c,l=Settings.RegisterVerticalLayoutCategory(name);c.parent=parent;return c,l
end
function Settings.RegisterProxySetting(c,v,t,label,default,get,set)
 assert(not registry[v]);local s={category=c,default=default,get=get,set=set,label=label}
 registry[v]=s;return s
end
function Settings.CreateCheckbox(c,s,tooltip)
 local row={setting=s,tooltip=tooltip}
 function row:AddModifyPredicate(fn) self.canModify=fn end
 table.insert(c.layout.rows,row);return row
end
function Settings.RegisterAddOnCategory(c) table.insert(registered,c) end
function Settings.NotifyUpdate(v) notices[v]=(notices[v] or 0)+1 end
function CreateSettingsListSectionHeaderInitializer(title)
 local row={header=title};function row:AddShownPredicate(fn) self.shouldShow=fn end;return row
end
function CreateSettingsButtonInitializer(label,text,callback,tooltip)
 buttons[label]=callback;return {label=label,text=text,callback=callback}
end
SettingsPanel={list={Header={Title={SetText=function(self,t) self.text=t end}}}}
function SettingsPanel:DisplayCategory(c) self.list.Header.Title:SetText(c.name) end
function SettingsPanel:GetSettingsList() return self.list end
EventRegistry={}
function EventRegistry:RegisterCallback(event,callback,owner) callbacks[event]={callback,owner} end
function fire(event,...) local c=callbacks[event];c[1](c[2],...) end
''')
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute("coreEvent=frames[#frames];coreEvent.scripts.OnEvent(coreEvent,'ADDON_LOADED','LH_Tweaks')")
lua.execute(Path('Settings.lua').read_text(), 'LH_Tweaks')
lua.execute('''
local e=frames[#frames]
e.scripts.OnEvent(e,'ADDON_LOADED','LH_Tweaks')
local c=LH_Tweaks.category
assert(c.name=='LH Tweaks' and #registered==1)
SettingsPanel:DisplayCategory(c);assert(SettingsPanel.list.Header.Title.text=='LiteHawk Tweaks')
SettingsPanel:DisplayCategory({name='Other'});assert(SettingsPanel.list.Header.Title.text=='Other')
local count=0
for _,feature in ipairs(LH_Tweaks.features) do
 local s=registry['LH_Tweaks_'..feature.key];assert(s and s.default==false)
 s.set(true);assert(s.get()==true and LH_TweaksDB[feature.key]==true)
 s.set(false);assert(s.get()==false);count=count+1
end
assert(count==8)
SlashCmdList.LH_TWEAKS('auto-repair on')
assert(registry.LH_Tweaks_autoRepair.get() and notices.LH_Tweaks_autoRepair>0)
combat=true;registry.LH_Tweaks_moveChatBarToTop.set(true)
assert(LH_TweaksDB.moveChatBarToTop and LH_Tweaks:IsPending())
LH_TweaksDB.locationBarPosition={x=.3,y=.2};LH_TweaksDB.tooltipPosition={x=.4,y=.4}
fire('Settings.CategoryDefaulted', {name='Other'});assert(LH_TweaksDB.locationBarPosition)
fire('Settings.CategoryDefaulted',c)
for _,f in ipairs(LH_Tweaks.features) do assert(not LH_TweaksDB[f.key]) end
assert(not LH_TweaksDB.locationBarPosition and not LH_TweaksDB.tooltipPosition)
assert(LH_TweaksDB.minimapPositionRepair==1 and LH_Tweaks:IsPending())
combat=false;coreEvent.scripts.OnEvent(coreEvent,'PLAYER_REGEN_ENABLED')
buttons['Enable all tweaks']();for _,f in ipairs(LH_Tweaks.features) do assert(LH_TweaksDB[f.key]) end
buttons['Disable all tweaks']();for _,f in ipairs(LH_Tweaks.features) do assert(not LH_TweaksDB[f.key]) end
LH_TweaksDB.locationBarPosition={x=.2,y=.3};buttons['Location bar position']();assert(not LH_TweaksDB.locationBarPosition)
LH_TweaksDB.tooltipPosition={x=.2,y=.3};buttons['Tooltip position']();assert(not LH_TweaksDB.tooltipPosition)
LH_Tweaks:RegisterModule('demo','Demo',function(category,layout) layout:AddInitializer({header='Demo settings'}) end)
assert(#registered==2 and LH_Tweaks.modules.demo.category.parent==c)
LH_Tweaks:RegisterModule('demo','Demo',function() error('duplicate') end)
e.scripts.OnEvent(e,'PLAYER_LOGIN');assert(#registered==2)
''')
print('PASS: native category, title isolation, eight controls, chat/UI synchronization, combat deferral, scoped defaults, position resets, bulk controls and module registration')
