# TweakMe

Standalone chat-controlled addon for WoW Forever Beta. Version 0.2.0; interface 16001, matching the installed HideMe and ShowMe addons. No dependencies.

## Installation and commands

Keep TweakMe in Interface/AddOns and enable it in the AddOns menu. Restart the client if installed while the game is running.

- /tweakme remove-chatwindow-move-limit on: remove screen constraints from standard chat windows so they can be moved to and beyond the screen edges.
- /tweakme remove-chatwindow-move-limit off: restore the screen constraints requested before or during the tweak.
- /tweakme move-chatbar-to-top on: place standard chat input fields above their chat windows.
- /tweakme move-chatbar-to-top off: place input fields at the default position below their chat windows.
- /tweakme status: show the saved setting and pending changes.
- /tweakme help, or /tweakme without arguments: show usage.

Disabled by default. Settings persist per character through /reload and restarts. Commands ignore case and surrounding whitespace; invalid or extra arguments do not change settings. Combat changes apply after combat ends.

## Behavior

Use the existing Edit Mode to move the primary chat window, then save the layout normally. Undocked windows retain their normal movement controls. TweakMe disables SetClampedToScreen for standard chat windows and their Edit Mode selection frames. It preserves the clamp insets and existing anchors. Secure post-hooks reapply the tweak when Blizzard requests screen clamping or changes clamp insets. New and temporary windows are discovered through events and available chat creation functions.

Off restores each frame's previous clamp state, including an originally unclamped frame. Blizzard clamp requests made while enabled update the state to restore. Re-enabling captures the current state again. The addon does not move or resize windows automatically. Grid and alignment snapping remain controlled by the Edit Mode settings; disable snapping there if desired. Custom chat replacements and other addons controlling clamping can affect the result.

The input position setting is independent of screen constraints and saved as TweakMeDB.moveChatBarToTop. Top mode anchors the input two pixels above the window; off uses Blizzard's default bottom anchors. Horizontal alignment follows the scrollbar when available and the chat frame otherwise. Guarded secure anchor hooks maintain top mode after layout updates. Input text, focus, visibility and scripts are preserved, including HideMe chat-bar behavior. Changes wait until combat ends.

## Verification

Files and implementation were inspected. Automated Lua simulation was prepared but could not run: the existing temporary Lupa installation was unavailable and downloading a fresh runtime failed because network access was blocked. The user confirmed on October 11, 2026 that the addon works in the WoW Forever Beta client. Detailed compatibility checks remain pending.

In-game checks: enable on, open Edit Mode, move chat to each edge and partly beyond it, save, reopen Edit Mode, test /reload, and switch off to check normal constraints. Also test undocked/new windows, repeated on/off, invalid arguments and changes during combat.

Reference: Blizzard Edit Mode source defines an expanded chat selection frame and computes clamp offsets from it:
https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EditMode/Shared/EditModeSystemTemplates.lua
https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EditMode/Shared/EditModeSystemTemplates.xml

Version 0.2.0: check top/off, Return typing and Escape, resizing/moving windows, new windows, /reload, combat-deferred changes and both settings independently. The user confirmed on October 11, 2026 that input placement works in game. Detailed compatibility checks remain pending.
