# TweakMe

Standalone chat-controlled addon for WoW Forever Beta. Version 0.5.0; interface 16001, matching the installed HideMe and ShowMe addons. No dependencies.

## Installation and commands

Keep TweakMe in Interface/AddOns and enable it in the AddOns menu. Restart the client if installed while the game is running.

Version 0.3.1 adds a custom fantasy wrench icon to the AddOn list through the IconTexture metadata. Keep Icon.tga in the addon folder; Icon.png is a preview. Restart the client after installing the new texture. The icon is an uncompressed 256x256, 24-bit TGA; format and metadata were checked, but in-game display verification is pending.

Icon generated with the built-in ImageGen tool. Prompt: a square, hand-painted World of Warcraft-style inventory icon featuring a large diagonal forged-steel wrench with brass accents and bright edge highlights against a dark blue background with a warm glow, readable at small sizes, without text, logos or a decorative frame.

- /tweakme all on: enable all four settings (remove-chatwindow-move-limit, move-chatbar-to-top, auto-repair and auto-sell-greys).
- /tweakme all off: disable all four settings.
- /tweakme remove-chatwindow-move-limit on: remove screen constraints from standard chat windows so they can be moved to and beyond the screen edges, and hide their scrollbars.
- /tweakme remove-chatwindow-move-limit off: restore the screen constraints and scrollbar visibility requested before or during the tweak.
- /tweakme move-chatbar-to-top on: place standard chat input fields above their chat windows.
- /tweakme move-chatbar-to-top off: place input fields at the default position below their chat windows.
- /tweakme auto-repair on: automatically repair all items when opening a repair-capable merchant.
- /tweakme auto-repair off: disable automatic repairs.
- /tweakme auto-sell-greys on: automatically sell grey (poor-quality) bag items when opening a merchant.
- /tweakme auto-sell-greys off: disable automatic grey-item sales.
- /tweakme status: show the saved setting and pending changes.
- /tweakme help, or /tweakme without arguments: show usage.

Disabled by default. Settings persist per character through /reload and restarts. Commands ignore case and surrounding whitespace; invalid or extra arguments do not change settings. Chat layout changes during combat apply after combat ends.

## Behavior

The all command updates the four existing per-character settings together, without adding a separate saved all flag. Chat changes apply immediately outside combat and are deferred during combat. Merchant actions take effect on the next merchant visit. Individual commands can override any setting afterward; status shows each setting separately. Invalid or extra arguments leave all settings unchanged.

Auto-sell-greys defaults off and is saved per character as TweakMeDB.autoSellGreys. It runs on MERCHANT_SHOW before auto-repair and takes effect on the next merchant visit. When available, the client's standard sell-junk operation handles sales and its normal bag exclusions. Older clients use a bag scan that sells only unlocked grey items with vendor value, skipping unknown quality, occupied item cursors and repair mode. Equipped items and bank contents are not scanned. White and higher-quality items are preserved. Both merchant settings work independently.

Auto-repair is independent of chat settings and saved as TweakMeDB.autoRepair. On MERCHANT_SHOW, a repair-capable merchant repairs all damaged equipped items and repairable items in your bags using the standard repair-all operation. Only personal money is used; guild funds are never used. No action is taken when repairs are unnecessary or the merchant cannot repair. If personal funds do not cover the full cost, repairs are skipped with a chat message. Enabling the setting takes effect on the next merchant visit; off leaves manual repairs available.

Use the existing Edit Mode to move the primary chat window, then save the layout normally. Undocked windows retain their normal movement controls. TweakMe disables SetClampedToScreen for standard chat windows and their Edit Mode selection frames. It preserves the clamp insets and existing anchors. Secure post-hooks reapply the tweak when Blizzard requests screen clamping or changes clamp insets. New and temporary windows are discovered through events and available chat creation functions.

Off restores each frame's previous clamp state, including an originally unclamped frame. Blizzard clamp requests made while enabled update the state to restore. Re-enabling captures the current state again. The addon does not move or resize windows automatically. Grid and alignment snapping remain controlled by the Edit Mode settings; disable snapping there if desired. Custom chat replacements and other addons controlling clamping can affect the result.

The input position setting is independent of screen constraints and saved as TweakMeDB.moveChatBarToTop. Top mode anchors the input two pixels above the window; off uses Blizzard's default bottom anchors. Horizontal alignment follows the scrollbar when available and the chat frame otherwise. Guarded secure anchor hooks maintain top mode after layout updates. Input text, focus, visibility and scripts are preserved, including HideMe chat-bar behavior. Changes wait until combat ends.

## Verification

Version 0.5.0: a temporary Lupa simulation passed bulk on/off for all four settings, invalid arguments, individual overrides, merchant action timing, chat application/restoration, combat deferral and saved setting normalization. In-game verification, including /reload persistence, remains pending.

Version 0.4.0: temporary Lupa simulations passed native sell-junk, modern container and legacy container paths, default/off, on, invalid commands, saved setting normalization and use together with auto-repair. Bag-scan tests verified grey stacks across bags, preservation of higher-quality, locked, valueless and unknown-quality items, and cursor/repair-mode guards. In-game verification is pending. Check on/off, /reload persistence, grey stacks across bags, preservation of white and higher-quality items, empty bags, unsellable or locked items, and use together with auto-repair.

Version 0.3.0: a temporary Lupa simulation passed default/off, repair-capable and ordinary merchants, repair need and zero cost, insufficient/exactly sufficient/sufficient money, personal funds, invalid commands, saved setting normalization and independence from chat settings. The user confirmed on October 11, 2026 that auto-repair works in game. Detailed compatibility checks remain pending: on/off and /reload persistence, damaged gear and bag items, ordinary merchants, undamaged items and insufficient money.

The version 0.2.1 temporary Lupa simulation passed toggling, repeated on, originally hidden scrollbars, latest Show/Hide/SetShown requests, clamp restoration, new windows and combat deferral. The user confirmed on October 11, 2026 that scrollbar hiding works in game. Detailed compatibility checks remain pending.

Version 0.2.1 also hides standard chat scrollbars while remove-chatwindow-move-limit is on. Guarded secure hooks preserve the latest Show, Hide or SetShown request for restoration on off, including originally hidden bars. New and temporary chat windows share the existing discovery and combat deferral. Scrollbar anchors and chat input alignment remain unchanged. Detailed in-game checks of restoration, layout updates, new windows and combat deferral remain pending.

Files and implementation were inspected. The initial automated Lua simulation could not run: the existing temporary Lupa installation was unavailable and downloading a fresh runtime failed because network access was blocked. A temporary runtime became available for the version 0.2.1 checks described above. The user confirmed on October 11, 2026 that the addon works in the WoW Forever Beta client. Detailed compatibility checks remain pending.

In-game checks: enable on, open Edit Mode, move chat to each edge and partly beyond it, save, reopen Edit Mode, test /reload, and switch off to check normal constraints. Also test undocked/new windows, repeated on/off, invalid arguments and changes during combat.

Reference: Blizzard Edit Mode source defines an expanded chat selection frame and computes clamp offsets from it:
https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EditMode/Shared/EditModeSystemTemplates.lua
https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EditMode/Shared/EditModeSystemTemplates.xml

Version 0.2.0: check top/off, Return typing and Escape, resizing/moving windows, new windows, /reload, combat-deferred changes and both settings independently. The user confirmed on October 11, 2026 that input placement works in game. Detailed compatibility checks remain pending.
