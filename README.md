# LH_Tweaks

Version: 0.8.0

LH_Tweaks adds simple quality-of-life tweaks to WoW Forever Beta: customize your chat layout, reposition the location bar, repair automatically and sell grey items with less clicking.

## Features

- Move standard chat windows to and beyond the screen edges and hide their scrollbars.
- Place the chat input above the chat window.
- Replace the chat input border with LH_ExpBar's dark background and muted gold border.
- Reposition the default tooltip using a small circle at its bottom-right corner.
- Move the location bar independently of the minimap, together with its attached tracking, calendar and other buttons.
- Automatically repair at repair-capable merchants using your own money, when you can afford the full cost.
- Automatically sell grey (poor-quality) items from your bags when visiting a merchant.

## Commands

Type `/lh_tweaks all on` to enable all features, or choose individual tweaks:

| Command | Action |
| --- | --- |
| `/lh_tweaks all on` | Enable all features. |
| `/lh_tweaks remove-chatwindow-move-limit on` | Allow chat windows beyond the screen edges and hide scrollbars. |
| `/lh_tweaks replace-chatbar-frame on` | Use the LH_ExpBar-style border for chat input. |
| `/lh_tweaks replace-chatbar-frame off` | Restore the standard Blizzard chat input border. |
| `/lh_tweaks move-chatbar-to-top on` | Move chat input above the chat window. |
| `/lh_tweaks unlock-location-bar on` | Unlock the location bar; drag its zone-name area with the left mouse button. |
| `/lh_tweaks unlock-tooltip on` | Show a small circle at the tooltip's bottom-right corner; drag it with the left mouse button. |
| `/lh_tweaks unlock-tooltip off` | Hide the circle and lock the tooltip at the chosen position. |
| `/lh_tweaks unlock-tooltip reset` | Forget the saved position and restore Blizzard's default anchor; keep the current lock setting. |
| `/lh_tweaks unlock-location-bar off` | Lock the location bar at its current position. |
| `/lh_tweaks unlock-location-bar reset` | Restore its original anchors and forget its saved position; keep the current lock setting. |
| `/lh_tweaks auto-repair on` | Enable automatic repairs. |
| `/lh_tweaks auto-sell-greys on` | Enable automatic grey-item sales. |
| `/lh_tweaks status` | Show your current settings. |
| `/lh_tweaks help` | Show all commands. |

Replace `on` with `off` to disable any feature. Use `/lh_tweaks all off` to disable them all, including locking the location bar and tooltip at their chosen positions. You can change individual settings at any time. Both `unlock-location-bar` and `unlock-tooltip` accept `reset`.

All features are off by default, and your choices, location-bar position and tooltip position are saved for each character. While unlocked, the drag area covers the zone-name button; lock it again to use that button normally. Attached buttons keep their existing anchors and click behavior. The minimap stays in place. Reset restores the anchors captured before LH_Tweaks first moved the bar in the current session, relative to the minimap's current layout.

Use Edit Mode to move the main chat window. Chat and location-bar layout changes made during combat take effect after combat ends; dragging is unavailable during combat. Automatic repairs and sales begin on your next merchant visit.

## Installation and upgrade

Place the `LH_Tweaks` folder in your game's `Interface/AddOns` folder. It must contain `LH_Tweaks.toc`, `LH_Tweaks.lua` and `Icon.tga`. Restart WoW and enable **LH_Tweaks** in the addon list.

When upgrading from TweakMe, replace the old folder and fully restart WoW. Do not enable both versions together. Commands now use `/lh_tweaks`.

To retain your settings and saved positions, close WoW and back up each character's `WTF/Account/<account>/<realm>/<character>/SavedVariables/TweakMe.lua` file. Copy it to `LH_Tweaks.lua` in the same SavedVariables folder, then change `TweakMeDB` to `LH_TweaksDB` inside the copy. Copy the entire table, including `minimapPositionRepair`, to preserve its completed repair state. Migrate before first using the renamed addon; do not overwrite an existing `LH_Tweaks.lua` containing settings you want to keep. Without migration, features start disabled, saved positions are absent and the one-time minimap position repair runs again.

## Version 0.8.0

Added `replace-chatbar-frame on|off`, included in `all on|off`, help and status. The option defaults to off and is saved per character. It applies the same black background, border texture, size and muted gold color used by LH_ExpBar to standard chat input fields, including later-created chat windows. LH_ExpBar does not need to be enabled. Turning the option off restores the native border artwork, including focus textures. Changes made during combat take effect afterward.

The user confirmed on October 21, 2026 that the chat input border option works in game.

## Version 0.7.1

Renamed TweakMe to LH_Tweaks, including the folder, Lua/TOC files, metadata, icon path, chat prefix, command registration, saved-variable table and test references. Commands now use `/lh_tweaks`. Updated English documentation and added settings migration instructions.

## Version 0.7.0

Added `unlock-tooltip on|off|reset`, included in `all on|off`, help and status. The drag circle remains available while unlocked even when the tooltip is hidden. Positions are saved per character as `tooltipPosition`, with the unlock setting in `unlockTooltip`. The default tooltip stays anchored by its bottom-right corner and grows upward and leftward. Tooltips explicitly anchored to individual controls retain their normal behavior; the saved position applies through Blizzard's default-anchor function. Layout changes and dragging are deferred or blocked during combat. Reset restores Blizzard's current default anchor without changing the lock setting. On October 17, 2026, the user confirmed that unlock-tooltip works in game. Detailed compatibility checks remain pending.

The Lupa simulation in `.tooltip-test.py` passed dragging, locking, reset, bottom-right anchoring, command validation, combat deferral, bulk toggles and saved-position reload. The existing location-layout regression simulation also passed.

## Version 0.6.3

Fixed an invalid `SetUserPlaced(false)` call on a non-movable minimap cluster during the one-time repair. This Lua error could interrupt layout commands, leaving their text in the chat input after pressing Enter. The repair and location-bar reset now temporarily enable movement only when changing the user-placed flag, then restore the previous movement state.

The stricter Lupa regression test reproduced the invalid call before the fix and passes with the fix, including resetting a locked location bar and preserving the minimap's movement state. On October 16, 2026, the user confirmed in game that the reported command/Enter issue is resolved. Detailed compatibility checks remain pending.

## Version 0.6.2

Fixed the minimap shifting left after reloading with a saved location-bar position. The detached header and its attached frames no longer enlarge the minimap's automatic layout bounds; hidden placeholders preserve their original footprint. Location-bar restoration waits until entering the world.

On the first world entry after this update, LH_Tweaks resets the minimap cluster to the standard top-right anchor, deferring during combat. This repair runs once per character (`LH_TweaksDB.minimapPositionRepair`); later minimap positioning remains independent. Saved location-bar positions are preserved.

The Lupa regression simulation in `.location-layout-test.py` passed saved-position restoration, dragging, locking, reset, repeated dragging, attached-frame layout isolation, one-time minimap repair and startup/combat deferral. In-game reload verification is pending.

## Version 0.6.1

Renamed the command to `unlock-location-bar on|off|reset` without an old-command alias. Existing per-character settings and positions are preserved. Help, status and command feedback use the new name.

## Version 0.6.0

Added `location-bar on|off|reset`, per-character position storage, combat deferral and integration with `all on|off` and `status`. A temporary Lupa simulation passed dragging, locking, reset, anchor enforcement, combat deferral, command validation, bulk toggles and saved-position reload. In-game verification, including attached-button behavior, is pending.
