# TweakMe

TweakMe adds simple quality-of-life tweaks to WoW Forever Beta: customize your chat layout, reposition the location bar, repair automatically and sell grey items with less clicking.

## Features

- Move standard chat windows to and beyond the screen edges and hide their scrollbars.
- Place the chat input above the chat window.
- Reposition the default tooltip using a small circle at its bottom-right corner.
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
| `/tweakme unlock-tooltip on` | Show a small circle at the tooltip's bottom-right corner; drag it with the left mouse button. |
| `/tweakme unlock-tooltip off` | Hide the circle and lock the tooltip at the chosen position. |
| `/tweakme unlock-tooltip reset` | Forget the saved position and restore Blizzard's default anchor; keep the current lock setting. |
| `/tweakme unlock-location-bar off` | Lock the location bar at its current position. |
| `/tweakme unlock-location-bar reset` | Restore its original anchors and forget its saved position; keep the current lock setting. |
| `/tweakme auto-repair on` | Enable automatic repairs. |
| `/tweakme auto-sell-greys on` | Enable automatic grey-item sales. |
| `/tweakme status` | Show your current settings. |
| `/tweakme help` | Show all commands. |

Replace `on` with `off` to disable any feature. Use `/tweakme all off` to disable them all, including locking the location bar and tooltip at their chosen positions. You can change individual settings at any time. Both `unlock-location-bar` and `unlock-tooltip` accept `reset`.

All features are off by default, and your choices, location-bar position and tooltip position are saved for each character. While unlocked, the drag area covers the zone-name button; lock it again to use that button normally. Attached buttons keep their existing anchors and click behavior. The minimap stays in place. Reset restores the anchors captured before TweakMe first moved the bar in the current session, relative to the minimap's current layout.

Use Edit Mode to move the main chat window. Chat and location-bar layout changes made during combat take effect after combat ends; dragging is unavailable during combat. Automatic repairs and sales begin on your next merchant visit.

## Version 0.7.0

Added `unlock-tooltip on|off|reset`, included in `all on|off`, help and status. The drag circle remains available while unlocked even when the tooltip is hidden. Positions are saved per character as `tooltipPosition`, with the unlock setting in `unlockTooltip`. The default tooltip stays anchored by its bottom-right corner and grows upward and leftward. Tooltips explicitly anchored to individual controls retain their normal behavior; the saved position applies through Blizzard's default-anchor function. Layout changes and dragging are deferred or blocked during combat. Reset restores Blizzard's current default anchor without changing the lock setting. On October 17, 2026, the user confirmed that unlock-tooltip works in game. Detailed compatibility checks remain pending.

The Lupa simulation in `.tooltip-test.py` passed dragging, locking, reset, bottom-right anchoring, command validation, combat deferral, bulk toggles and saved-position reload. The existing location-layout regression simulation also passed.

## Version 0.6.3

Fixed an invalid `SetUserPlaced(false)` call on a non-movable minimap cluster during the one-time repair. This Lua error could interrupt layout commands, leaving their text in the chat input after pressing Enter. The repair and location-bar reset now temporarily enable movement only when changing the user-placed flag, then restore the previous movement state.

The stricter Lupa regression test reproduced the invalid call before the fix and passes with the fix, including resetting a locked location bar and preserving the minimap's movement state. On October 16, 2026, the user confirmed in game that the reported command/Enter issue is resolved. Detailed compatibility checks remain pending.

## Version 0.6.2

Fixed the minimap shifting left after reloading with a saved location-bar position. The detached header and its attached frames no longer enlarge the minimap's automatic layout bounds; hidden placeholders preserve their original footprint. Location-bar restoration waits until entering the world.

On the first world entry after this update, TweakMe resets the minimap cluster to the standard top-right anchor, deferring during combat. This repair runs once per character (`TweakMeDB.minimapPositionRepair`); later minimap positioning remains independent. Saved location-bar positions are preserved.

The Lupa regression simulation in `.location-layout-test.py` passed saved-position restoration, dragging, locking, reset, repeated dragging, attached-frame layout isolation, one-time minimap repair and startup/combat deferral. In-game reload verification is pending.

## Version 0.6.1

Renamed the command to `unlock-location-bar on|off|reset` without an old-command alias. Existing per-character settings and positions are preserved. Help, status and command feedback use the new name.

## Version 0.6.0

Added `location-bar on|off|reset`, per-character position storage, combat deferral and integration with `all on|off` and `status`. A temporary Lupa simulation passed dragging, locking, reset, anchor enforcement, combat deferral, command validation, bulk toggles and saved-position reload. In-game verification, including attached-button behavior, is pending.
