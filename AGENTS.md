# TweakMe project rules

- Communicate with the user in German. Keep addon messages, comments, metadata and documentation in English, consistent with HideMe and ShowMe.
- Work only in TweakMe unless the user requests otherwise. Read TweakMe.lua, TweakMe.toc and README.md before changes.
- Standalone WoW Forever Beta addon, interface 16001, version 0.1.1. Local Git repository on branch main; not published and no remote configured.
- /tweakme remove-chatwindow-move-limit on|off controls screen constraints, not chat visibility. Defaults off; SavedVariablesPerCharacter: TweakMeDB.chatWindow.
- Preserve original false clamp states, restore the latest normal clamp request, guard recursive secure hooks, defer changes and hook installation during combat, discover new and temporary frames.
- Do not replace Blizzard movement methods or edit global snapping settings. Preserve anchors, insets, chat text, input and other addons.
- Update version and README for functional changes. Never claim unrun tests passed.
- Initial automated Lua test could not run because temporary Lupa was inaccessible and the network prevented installing it. The user confirmed on October 11, 2026 that the addon works in game; detailed compatibility checks remain pending.

- Version 0.1.1 renames the command parameter to remove-chatwindow-move-limit; no old-command alias. Preserve TweakMeDB.chatWindow so saved settings remain intact.
