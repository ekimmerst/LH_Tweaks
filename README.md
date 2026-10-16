# TweakMe

TweakMe adds simple quality-of-life tweaks to WoW Forever Beta: customize your chat layout, reposition the location bar, repair automatically and sell grey items with less clicking.

## Features

- Move standard chat windows to and beyond the screen edges and hide their scrollbars.
- Place the chat input above the chat window.
- Move the location bar independently of the minimap, together with its attached tracking, calendar and other buttons.
- Automatically repair at repair-capable merchants using your own money, when you can afford the full cost.
- Automatically sell grey (poor-quality) items from your bags when visiting a merchant.

## Commands

Type `/tweakme all on` to enable all features, or choose individual tweaks:

| Command | Action |
| --- | --- |
| `/tweakme all on` | Enable all features. |
| `/tweakme remove-chatwindow-move-limit on` | Allow chat windows beyond the screen edges and hide scrollbars. |
| `/tweakme move-chatbar-to-top on` | Move chat input above the chat window. |
| `/tweakme unlock-location-bar on` | Unlock the location bar; drag its zone-name area with the left mouse button. |
| `/tweakme unlock-location-bar off` | Lock the location bar at its current position. |
| `/tweakme unlock-location-bar reset` | Restore its original anchors and forget its saved position; keep the current lock setting. |
| `/tweakme auto-repair on` | Enable automatic repairs. |
| `/tweakme auto-sell-greys on` | Enable automatic grey-item sales. |
| `/tweakme status` | Show your current settings. |
| `/tweakme help` | Show all commands. |

Replace `on` with `off` to disable any feature. Use `/tweakme all off` to disable them all, including locking the location bar at its current position. You can change individual settings at any time. Only `unlock-location-bar` accepts `reset`.

All features are off by default, and your choices and location-bar position are saved for each character. While unlocked, the drag area covers the zone-name button; lock it again to use that button normally. Attached buttons keep their existing anchors and click behavior. The minimap stays in place. Reset restores the anchors captured before TweakMe first moved the bar in the current session, relative to the minimap's current layout.

Use Edit Mode to move the main chat window. Chat and location-bar layout changes made during combat take effect after combat ends; dragging is unavailable during combat. Automatic repairs and sales begin on your next merchant visit.

## Version 0.6.1

Renamed the command to `unlock-location-bar on|off|reset` without an old-command alias. Existing per-character settings and positions are preserved. Help, status and command feedback use the new name.

## Version 0.6.0

Added `location-bar on|off|reset`, per-character position storage, combat deferral and integration with `all on|off` and `status`. A temporary Lupa simulation passed dragging, locking, reset, anchor enforcement, combat deferral, command validation, bulk toggles and saved-position reload. In-game verification, including attached-button behavior, is pending.
