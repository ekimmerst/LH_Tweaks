# TweakMe project rules

- Communicate with the user in German. Keep addon messages, comments, metadata and documentation in English, consistent with HideMe and ShowMe.
- Work only in TweakMe unless the user requests otherwise. Read TweakMe.lua, TweakMe.toc and README.md before changes.
- Standalone WoW Forever Beta addon, interface 16001, version 0.5.0. Local Git repository on branch main; private GitHub repository ekimmerst/tweakme configured as origin over HTTPS.
- Version 0.5.0 adds all on|off, updating chatWindow, moveChatBarToTop, autoRepair and autoSellGreys together without a separate saved flag. Apply chat settings once, preserve combat deferral, and run merchant actions on the next visit. Individual commands remain independent. In-game verification is pending.
- Version 0.5.0 temporary Lupa simulation passed bulk on/off, invalid arguments, individual overrides, merchant timing, chat application/restoration, combat deferral and saved setting normalization.
- Version 0.4.0 adds auto-sell-greys on|off, default false, saved as TweakMeDB.autoSellGreys. On MERCHANT_SHOW, use C_MerchantFrame.SellAllJunkItems when available; otherwise scan equipped bags with modern or legacy container APIs, selling only unlocked quality-0 items with vendor value. Preserve higher qualities, equipped items, bank contents and other settings. In-game verification is pending.
- Version 0.4.0 temporary Lupa simulations passed native/modern/legacy API paths, settings and command validation, bag-item selection, cursor/repair-mode guards and independence from auto-repair and chat settings.
- Version 0.3.1 adds Icon.tga via IconTexture metadata for the AddOn list, with Icon.png as a preview. Preserve the uncompressed 256x256 24-bit TGA. In-game icon verification is pending.
- /tweakme remove-chatwindow-move-limit on|off controls screen constraints and hides/restores chat scrollbars, not chat visibility. Defaults off; SavedVariablesPerCharacter: TweakMeDB.chatWindow.
- Preserve original false clamp states, restore the latest normal clamp request, guard recursive secure hooks, defer changes and hook installation during combat, discover new and temporary frames.
- Do not replace Blizzard movement methods or edit global snapping settings. Preserve chat-window anchors, clamp insets, input text/focus/visibility/scripts and other addons.
- Update version and README for functional changes. Never claim unrun tests passed.
- Version 0.3.0 adds auto-repair on|off, default false, saved as TweakMeDB.autoRepair. On MERCHANT_SHOW, check CanMerchantRepair, GetRepairAllCost and GetMoney before RepairAllItems(false). Use personal funds only, skip unnecessary or unaffordable repairs, and keep merchant handling independent of chat layout. Repair-all includes repairable bag items. The user confirmed on October 11, 2026 that auto-repair works in game; detailed compatibility checks remain pending.
- Version 0.3.0 temporary Lupa simulation passed default/off, merchant capability, repair need, zero cost, insufficient/exact/sufficient money, personal funds, command validation, saved setting normalization and chat independence.
- Initial automated Lua test could not run because temporary Lupa was inaccessible and the network prevented installing it. The user confirmed on October 11, 2026 that the addon works in game; detailed compatibility checks remain pending.

- Version 0.1.1 renames the command parameter to remove-chatwindow-move-limit; no old-command alias. Preserve TweakMeDB.chatWindow so saved settings remain intact.

- Version 0.2.1 temporary Lupa simulation passed toggling, repeated on, hidden scrollbar preservation, latest visibility requests, clamp restoration, new windows and combat deferral. The user confirmed on October 11, 2026 that scrollbar hiding works in game; detailed compatibility checks remain pending.

- Version 0.2.1 adds scrollbar hiding to remove-chatwindow-move-limit. Preserve originally hidden bars and latest normal Show/Hide/SetShown requests; guard recursive hooks and defer all changes and hook installation during combat.

- Version 0.2.0 adds move-chatbar-to-top on|off, saved per character as TweakMeDB.moveChatBarToTop, default false. ApplyChatBars anchors above (BOTTOMLEFT to TOPLEFT, -5, 2) or at the Blizzard default below (TOPLEFT to BOTTOMLEFT, -5, -2), plus horizontal RIGHT alignment. Secure SetPoint/ClearAllPoints hooks enforce only top mode with recursion guards. Combat deferral and chat discovery are shared with the existing setting. The user confirmed on October 11, 2026 that input placement works in game; detailed compatibility checks remain pending.
