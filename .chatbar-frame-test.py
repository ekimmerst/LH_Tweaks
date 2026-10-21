from pathlib import Path

source = Path('.location-layout-test.py').read_text()
exec(source.split("lua.execute(Path('LH_Tweaks.lua')")[0])
lua.execute('''
local M = getmetatable(UIParent).__index
function M:GetName() return self.name end
function M:SetClampedToScreen(v) self.clamped=v end
function M:IsClampedToScreen() return self.clamped or false end
function M:SetAlpha(v) self.alpha=v end
function M:GetAlpha() return self.alpha or 1 end
function M:SetBackdrop(v) self.backdrop=v end
function M:SetBackdropColor(...) self.bg={...} end
function M:SetBackdropBorderColor(...) self.border={...} end
function M:EnableMouse(v) self.mouse=v end
function M:SetAllPoints(v) self.allPoints=v end
function M:Show() self.shown=true end
function makeChat(name)
 local chat=CreateFrame('Frame',nil,UIParent);chat.name=name
 local edit=CreateFrame('EditBox',nil,UIParent);edit.name=name..'EditBox'
 chat.editBox=edit;edit.text='unfinished message';edit.focused=true
 for _,suffix in ipairs({'Left','Mid','Right','FocusLeft','FocusMid','FocusRight'}) do
  local region=CreateFrame('Texture',nil,edit)
  region.alpha=0.6;region.shown=suffix:sub(1,5)~='Focus'
  _G[edit.name..suffix]=region
 end
 edit.focusLeft=_G[edit.name..'FocusLeft']
 return chat
end
ChatFrame1=makeChat('ChatFrame1')
CHAT_FRAMES={'ChatFrame1'}
LH_TweaksDB={minimapPositionRepair=1}
''')
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute('''
local e=frames[#frames]
local function event(s,n) e.scripts.OnEvent(e,s,n) end
local function cmd(s) SlashCmdList.LH_TWEAKS(s) end
local function border(edit)
 for _,child in ipairs(edit.children) do if child.backdrop then return child end end
end
event('ADDON_LOADED','LH_Tweaks')
local edit=ChatFrame1.editBox
assert(not LH_TweaksDB.replaceChatBarFrame and not border(edit))
cmd('replace-chatbar-frame on')
local b=border(edit)
assert(b.shown and b.allPoints==edit and not b.mouse)
assert(b.backdrop.edgeSize==8 and b.backdrop.insets.left==2)
assert(b.bg[4]==1 and b.border[1]==0.65 and b.border[2]==0.59)
assert(ChatFrame1EditBoxLeft:GetAlpha()==0 and not edit.focusLeft.shown)
edit.focusLeft:Show();edit.focusLeft:SetAlpha(0.8)
assert(edit.focusLeft:GetAlpha()==0)
assert(edit.text=='unfinished message' and edit.focused)
cmd('replace-chatbar-frame off')
assert(not b.shown and ChatFrame1EditBoxLeft:GetAlpha()==0.6)
assert(edit.focusLeft:GetAlpha()==0.8 and edit.focusLeft.shown)
cmd('replace-chatbar-frame on extra');assert(not LH_TweaksDB.replaceChatBarFrame)
combat=true;cmd('replace-chatbar-frame on');assert(not b.shown)
combat=false;event('PLAYER_REGEN_ENABLED');assert(b.shown)
combat=true;cmd('replace-chatbar-frame off');assert(b.shown)
combat=false;event('PLAYER_REGEN_ENABLED');assert(not b.shown)
cmd('replace-chatbar-frame on')
ChatFrame2=makeChat('ChatFrame2');CHAT_FRAMES[2]='ChatFrame2'
event('UPDATE_CHAT_WINDOWS')
assert(border(ChatFrame2.editBox).shown and ChatFrame2EditBoxRight:GetAlpha()==0)
cmd('all off');assert(not b.shown and not border(ChatFrame2.editBox).shown)
cmd('all on');assert(b.shown and border(ChatFrame2.editBox).shown)
cmd('all off')
LH_TweaksDB.replaceChatBarFrame=true
''')
# A fresh addon instance must apply the saved mode at ADDON_LOADED.
lua.execute(Path('LH_Tweaks.lua').read_text(), 'LH_Tweaks')
lua.execute("local e=frames[#frames];e.scripts.OnEvent(e,'ADDON_LOADED','LH_Tweaks');assert(LH_TweaksDB.replaceChatBarFrame)")
print('PASS: chat border style, native/focus texture restoration, input preservation, combat deferral, late windows, bulk toggles, invalid input and saved mode')
