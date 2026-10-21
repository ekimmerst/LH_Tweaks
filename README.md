# LH_Tweaks

Version: 0.10.0

LH_Tweaks adds simple quality-of-life tweaks to WoW Forever Beta: customize your chat layout, reposition the location bar, repair automatically, sell grey items and collect fishing catches without flashing the loot window.

## Features

- Move standard chat windows to and beyond the screen edges and hide their scrollbars.
- Place the chat input above the chat window.
- Replace the chat input border with LH_ExpBar's dark background and muted gold border.
- Reposition the default tooltip using a small circle at its bottom-right corner.
- Move the location bar independently of the minimap, together with its attached tracking, calendar and other buttons.
- Automatically repair at repair-capable merchants using your own money, when you can afford the full cost.
- Automatically sell grey (poor-quality) items from your bags when visiting a merchant.

## Configuration

Open **Settings > AddOns > LH Tweaks**. The **LiteHawk Tweaks** page uses Blizzard's native settings controls, scrolling and right-aligned **Defaults** button. Sections cover Chat, Positioning and Merchants. All seven features are configurable here, including chat input borders, chat positioning, movement limits, location-bar and tooltip unlocking, automatic repairs and grey-item sales.

Changes are saved per character and use the same settings as the chat commands. Layout changes wait until combat ends. **Reset position** restores the location bar or tooltip position while preserving its lock setting. **Enable all** and **Disable all** change every feature together. **Defaults** disables every feature and clears both saved positions; the completed minimap repair marker is retained.

LH_Tweaks is the required core for the LiteHawk addon collection. Companion addons load after it. Expand the LH Tweaks category to access module pages. LH HideMe provides its hiding controls as a native subpage. Additional module pages can be added as they are implemented.

## Leatrix Plus compatibility

If **Leatrix Plus** is loaded and its automatic repair or junk-selling option is enabled, the corresponding LH Tweaks checkbox stays visible but is disabled, with the note **Already handled by Leatrix Plus**. Each function is checked separately. LH Tweaks also skips that merchant action, including when all features were enabled together. Leatrix Maps alone does not affect these options.

Your existing LH Tweaks preferences are retained while Leatrix Plus handles the function. The control becomes available again when the corresponding Leatrix Plus option is disabled or Leatrix Plus is no longer loaded. Unknown or missing Leatrix settings do not disable LH Tweaks. The settings page reevaluates the detected state while open. Leatrix Plus settings are never modified.

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
| `/lh_tweaks instant-fishing-loot on` | Collect fishing loot immediately without showing the loot window. |
| `/lh_tweaks instant-fishing-loot off` | Restore the normal fishing-loot behavior. |
| `/lh_tweaks status` | Show your current settings. |
| `/lh_tweaks help` | Show all commands. |

Replace `on` with `off` to disable any feature. Use `/lh_tweaks all off` to disable them all, including locking the location bar and tooltip at their chosen positions. You can change individual settings at any time. Both `unlock-location-bar` and `unlock-tooltip` accept `reset`.

All features are off by default, and your choices, location-bar position and tooltip position are saved for each character. While unlocked, the drag area covers the zone-name button; lock it again to use that button normally. Attached buttons keep their existing anchors and click behavior. The minimap stays in place. Reset restores the anchors captured before LH_Tweaks first moved the bar in the current session, relative to the minimap's current layout.

Use Edit Mode to move the main chat window. Chat and location-bar layout changes made during combat take effect after combat ends; dragging is unavailable during combat. Automatic repairs and sales begin on your next merchant visit.

## Instant fishing loot

Enable **Loot fishing catches without a loot window** in the native LH Tweaks page's **Fishing** section, or use `/lh_tweaks instant-fishing-loot on`. It defaults to off and is saved per character as `LH_TweaksDB.instantFishingLoot`, alongside the other tweaks. `all on`, `all off`, help, status and native Defaults include it.

When you interact with a fishing bobber, including by right-click, LH_Tweaks intercepts fishing loot before Blizzard displays the loot window and collects slots in descending order. Non-fishing loot continues through the original handler with its original arguments. No auto-loot CVar or fishing cast/key binding is changed. If items remain after one second (for example, with full bags), the normal loot window opens for manual recovery. Ending the loot session or opening another loot source cancels the previous delayed recovery. A pending fishing session still exposes remaining items if the setting is turned off while looting. Initial handler installation waits until combat ends if necessary and retries when the loot UI loads later.

This moves the local instant-loot addition from BetterFishing into LH_Tweaks. The bundled local BetterFishing version 66-lh.1 no longer installs that handler; its casting, keybind, double-click and sound features remain independent. BetterFishing is not required for the LH_Tweaks feature. Reload after updating both addons, then enable the new option to retain the previous local instant-loot behavior.

## Installation and upgrade

Place the `LH_Tweaks` folder in your game's `Interface/AddOns` folder. It must contain `LH_Tweaks.toc`, `LH_Tweaks.lua`, `Settings.lua` and `Icon.tga`. Restart WoW and enable **LH_Tweaks** in the addon list.

When upgrading from TweakMe, replace the old folder and fully restart WoW. Do not enable both versions together. Commands now use `/lh_tweaks`.

To retain your settings and saved positions, close WoW and back up each character's `WTF/Account/<account>/<realm>/<character>/SavedVariables/TweakMe.lua` file. Copy it to `LH_Tweaks.lua` in the same SavedVariables folder, then change `TweakMeDB` to `LH_TweaksDB` inside the copy. Copy the entire table, including `minimapPositionRepair`, to preserve its completed repair state. Migrate before first using the renamed addon; do not overwrite an existing `LH_Tweaks.lua` containing settings you want to keep. Without migration, features start disabled, saved positions are absent and the one-time minimap position repair runs again.

## Version 0.10.0

Added `instant-fishing-loot on|off` and its native Fishing checkbox, including bulk toggles, help/status, per-character persistence and Defaults. Moved the local BetterFishing loot interceptor into LH_Tweaks, with normal loot passthrough, a one-second recovery window, stale-session guards and immediate native recovery on loot API errors.

`.fishing-loot-test.py` passed silent successful catches, descending slot order, normal loot passthrough, uncollected-item recovery, closed/superseded sessions, command validation, proxy synchronization, bulk/default behavior, synchronous loot closure, API failures and late UI/combat-deferred installation. In-game verification remains pending: reload both updated addons, enable the option, right-click a bobber, check a normal loot source, test with full bags and verify that turning the option off restores normal fishing loot.

## Version 0.9.2


Explicitly set the native AddOn-list group to LH_Tweaks so LH HideMe appears as a child under LH Tweaks. Its native settings subpage is available by expanding LH Tweaks.

## Version 0.9.1

Added independent Leatrix Plus detection for automatic repairs and junk sales, disabled visible controls with explanatory notes, and duplicate-action prevention at merchants.

The user confirmed normal in-game operation on October 21, 2026. Integration with an installed Leatrix Plus still requires in-game verification.

## Version 0.9.0

Added the native **LH Tweaks** settings category, headed **LiteHawk Tweaks**, with all seven feature controls, individual position resets, bulk controls and Defaults. UI and chat commands stay synchronized. Added the shared module-page registration API and made LH_Tweaks a required dependency of the LiteHawk companion addons. CurseForge release dependencies must additionally be configured when publishing; a TOC dependency controls loading but does not download missing addons.

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

## Addon icon

The LH Tweaks icon uses the same gold, chamfered frame style as the **Spoken** addon icon, with large, high-contrast **LH** lettering in the center for readability at small sizes. The artwork was generated using Spoken's icon as the frame reference. Spoken is not required to display it. `Icon.png` contains the source artwork; `Icon.tga` is the bundled 256-by-256 game texture with transparency.
