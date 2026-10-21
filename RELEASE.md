# LiteHawk core and CurseForge dependencies

LH_Tweaks is the shared configuration host. Its folder name and dependency identifier remain `LH_Tweaks`; its user-facing title is **LH Tweaks**.

## Publishing

1. Publish the LH_Tweaks project with `LH_Tweaks.lua`, `Settings.lua`, `LH_Tweaks.toc`, icons and documentation. Exclude Git metadata, test runtimes and local test scripts from release archives.
2. Publish each companion addon in its own project. Keep `## Dependencies: LH_Tweaks` in its TOC.
3. For each companion release, add the published LH_Tweaks CurseForge project as a **Required Dependency** in the file's relations. Use the actual project identifier assigned by CurseForge.
4. Check a clean CurseForge client installation of a companion release: it should install both folders and enable LH_Tweaks before loading the companion.

TOC dependencies enforce installation presence and load order in WoW. CurseForge file relations provide automatic download through the CurseForge client. Manual ZIP installations require both addon folders.

No CurseForge project or release relation is created by these local files. Configure the required relation when the projects are published.

## Adding a module settings page

A companion must list `LH_Tweaks` as a required dependency. Register its configuration page from its Lua code:

```lua
LH_Tweaks:RegisterModule("LH_Example", "Example", function(category, layout)
    -- Register the module's native settings controls in this category.
    -- Keep the module's own saved variables and application logic.
end)
```

The callback receives a Blizzard vertical settings subcategory and layout beneath LH Tweaks. Registration is queued if the root settings category is not yet available. Module identifiers must be unique. Registering the same identifier again is ignored.

The root Defaults action resets only core features. Each module should register its own defaults using the native Settings API and handle position resets for its own category if needed.
