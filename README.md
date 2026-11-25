<h1 style="color: #d9a94b;">LH Tweaks</h1>

<p>Add a shared settings hub for LH addons and small WoW UI improvements for chat, tooltips, merchants, quests, and fishing.</p>

<p>Small changes to the World of Warcraft UI, with a place for all my LH addons in the game's own Settings menu.</p>

<h2 style="color: #c78be6;">Why I made these addons</h2>

<p>I'm well aware that an addon already exists for almost everything here. Some do things a little differently; others offer far more features than I need. I wanted a UI that still feels like WoW's own UI, with a few useful changes that fit into it naturally.</p>

<p>Splitting this collection into small addons was a deliberate choice. Install only the pieces you actually want. LH Tweaks provides the shared settings page and a handful of everyday improvements; each companion addon has its own job.</p>

<p>I made these addons mainly for my own use. If one or two of them happen to make your time in WoW a little nicer too, that makes me happy.</p>

<p>If you like the whole setup, install LH Tweaks and LH HideMe, enable all tweaks and choose <strong>Hide all</strong> in LH HideMe. Then arrange the remaining UI in WoW's Edit Mode to suit you, and you're ready to play. You can always switch individual options back off later.</p>

<h2 style="color: #73c9c4;">What LH Tweaks does</h2>

<ul>
  <li><strong>Chat window freedom:</strong> Move standard chat windows beyond the screen edges and hide their scrollbars. Place the chat input above the window and give it a simple dark background with a muted gold border.</li>
  <li><strong>Move the location bar and tooltip:</strong> Unlock and drag the zone name bar with its attached buttons, or move the default tooltip using its small drag handle and position preview. Lock either one at its saved position or reset it. Choose the texture of the health bar below the tooltip from a dropdown with previews of available status bar textures.</li>
  <li><strong>Player tooltip details:</strong> Enable <strong>Show player class and talents</strong> under the Tooltip section, or type <code>/lh_tweaks tooltip-player-details on</code>. Player names use their class color. A second line shows the specialization and talent distribution, such as <code>Feral (3/10/5)</code>, when the client provides those details. Other players may require a brief inspection delay; if their talents cannot be read, the tooltip shows only the available information. This option is off by default.</li>
  <li><strong>Target's target in the tooltip:</strong> Enable <strong>Show target's target in tooltip</strong> under Tooltip, or type <code>/lh_tweaks tooltip-target-of-target on</code>. A Target line shows whom the unit in the tooltip is targeting. Players appear in their class color; if the target is you, the line reads <code>MYSELF</code>. This option is off by default and works independently of player tooltip details.</li>
  <li><strong>Tooltip cast bar:</strong> Enable <strong>Show tooltip cast bar</strong> under Tooltip, or type <code>/lh_tweaks tooltip-castbar on</code>. While the unit whose tooltip is open is casting or channeling, its spell name and progress appear in a bar below the tooltip's health bar. The cast bar matches the health bar's height and texture. It hides when the cast ends or the tooltip closes. This option is off by default.</li>
  <li><strong>Merchant chores:</strong> Automatically repair your gear with your own gold when you can afford it, and sell grey items from your bags. If Leatrix Plus already handles either action, LH Tweaks leaves that action to it.</li>
  <li><strong>Fishing loot:</strong> Pick up fishing catches without briefly opening the loot window. If something remains, the normal loot window appears so you can collect it yourself. Other loot works as usual.</li>
  <li><strong>Equipment glow:</strong> Show a thicker, brighter quality-colored border on uncommon or better equipment in Blizzard bags and on the character sheet. Common white items keep their standard border. This is enabled by default and can be turned off in Settings or with <code>/lh_tweaks glow-equipment off</code>.</li>
  <li><strong>Group controls:</strong> Optionally hide Blizzard's left-side raid controls and marker menu while in a party or raid. The controls return when you leave the group. Enable <strong>Hide raid controls while grouped</strong> in Settings or use <code>/lh_tweaks hide-raid-manager-in-group on</code>. This option is off by default.</li>
  <li><strong>Quest tracker order:</strong> On clients without secret auras, optionally sort tracked quests by quest level, lowest first. Quests at the same level keep their tracked order. Enable it in Settings or with <code>/lh_tweaks sort-quests-by-level on</code>. The option is unavailable on clients with secret auras to prevent Blizzard objective-tracker errors.</li>
</ul>

<p>Find these options under <strong>Options → AddOns → LH Tweaks</strong>. Settings are saved per character. Use <strong>Enable all</strong> or <strong>Disable all</strong> there, or type <code>/lh_tweaks all on</code> or <code>/lh_tweaks all off</code>. Type <code>/lh_tweaks help</code> for individual commands. Merchant options take effect on your next merchant visit.</p>

<h2 style="color: #c78be6;">Use another character's settings</h2>

<p>Configure the main character, then log out to save its settings. On another character, choose the main character under <strong>Use settings from</strong> in LH Tweaks. The choice is applied to every enabled LH addon with a settings profile. <strong>Apply to all</strong> repeats it after enabling another addon. You can choose a different source for any addon on its own settings page. Choose <strong>This character</strong> in LH Tweaks to restore each addon's own settings. The UI reloads when a source changes. Display, appearance, visibility, and other general options are borrowed. Monitored buffs and exceptions in LH BuffReminders, class spells in LH Range, per-character cooldown filters, and combat-session data remain separate. A source character appears in an addon's list after that addon has been loaded on the character and the character has logged out. WoW: Forever's complete first and last name is shown after that character logs in once with this version. If an addon has no saved settings for the selected source, the bulk action leaves that addon's choice unchanged.</p>

<h2 style="color: #d9a94b;">The companion addons</h2>

<p>Each of these is a separate download and uses LH Tweaks for its settings:</p>

<ul>
  <li><strong>LH AuraBars:</strong> Compact bars for buffs, debuffs and spell cooldowns across classes, races and factions.</li>
  <li><strong>LH CooldownPulse:</strong> Flashes an ability icon near the center of the screen when its cooldown finishes.</li>
  <li><strong>LH ExpBar:</strong> A minimal experience bar, including rested XP, sized to match the minimap.</li>
  <li><strong>LH HideMe:</strong> Hides selected parts of the default UI, with individual switches and a Hide all button.</li>
  <li><strong>LH JobsDone:</strong> Plays the familiar Warcraft peasant voice when a quest is ready to turn in.</li>
  <li><strong>LH MailBags:</strong> Opens your Blizzard bags or Baganator at a mailbox, with an optional close action.</li>
  <li><strong>LH MP5:</strong> Shows an estimated five-second mana timer on the Blizzard player mana bar.</li>
  <li><strong>LH NameplateQuestInfo:</strong> Adds quest markers and objective progress to relevant nameplates.</li>
  <li><strong>LH NameplateThreatColors:</strong> Colors Blizzard nameplate health bars by threat for your role while grouped.</li>
  <li><strong>LH PetStats:</strong> Shows pet loyalty by the pet portrait, with a matching small progress bar.</li>
  <li><strong>LH Range:</strong> Shows melee range, configurable spell-range zones for every class, and a live non-Mana resource bar in melee range.</li>
  <li><strong>LH BuffReminders:</strong> Reminds you when class buffs are missing.</li>
  <li><strong>LH Skills:</strong> Shows profession skills in a compact, movable display with rank colors and skill-up flashes.</li>
  <li><strong>LH Socials:</strong> Shows a compact, auto-hiding guild roster from a handle at the screen edge, with online members, sorting and whispers.</li>
  <li><strong>LH Stats:</strong> Keeps your money, free bag slots and remaining ammo visible below the minimap.</li>
  <li><strong>LH SwingTimer:</strong> Adds minimal main-hand and ranged swing timers beneath the player cast bar.</li>
  <li><strong>LH TinyDPS:</strong> A compact damage and healing display using the game's built-in meter data.</li>
</ul>

<h2 style="color: #c78be6;">Installation</h2>

<p>Install LH Tweaks first, then add whichever companion addons you want. LH NameplateQuestInfo can also run without LH Tweaks; the other companions require it. For a manual installation, keep each addon in its own <code>Interface/AddOns</code> folder and restart the game after adding new addons.</p>

<h2 style="color: #c78be6;">Feedback</h2>

<p>I'd love to hear what works for you and what could be better. If you have feedback, an idea for an improvement or a feature request, please leave a comment here on CurseForge.</p>

<h2 style="color: #73c9c4;">Thank you</h2>

<p>Thanks to Woffle of Dark Iron [US] and discoteq for <a href="https://www.curseforge.com/wow/addons/doomcooldownpulse">Doom_CooldownPulse</a>, and to Sideshow and Talyrius for <a href="https://www.curseforge.com/wow/addons/tinydps">TinyDPS</a>. Their work deserves recognition. LH CooldownPulse carries that pulse idea forward for this UI; LH TinyDPS is my own compact display for WoW's built-in meter data.</p>

<h2 style="color: #73c9c4;">Changelog</h2>

<p><strong>0.11.7 - Forever and Retail</strong></p>

<ul>
  <li>Added an optional setting to hide Blizzard's left-side raid controls while grouped and restore them when leaving the group. Changes made in combat apply after combat ends.</li>
</ul>

<p><strong>0.11.6 - Forever and Retail</strong></p>

<ul>
  <li>Fixed the tooltip cast bar for mouseover units and client-provided cast durations. Matched its height and texture to the tooltip health bar.</li>
</ul>

<p><strong>0.11.5 - Forever and Retail</strong></p>

<ul>
  <li>Added separate tooltip options to show the displayed unit's target in class color (or MYSELF for you) and its current cast or channel below the tooltip health bar.</li>
</ul>

<p><strong>0.11.4 - Forever and Retail</strong></p>

<ul>
  <li>Added an optional class-colored player name and talent or specialization line to the default tooltip, including Forever's three talent trees when their data is available.</li>
</ul>

<p><strong>0.11.3 - Forever and Retail</strong></p>

<ul>
  <li>Prevented an objective-tracker taint error during secret aura checks by leaving Blizzard's quest tracker methods untouched on affected clients. Quest-level sorting is unavailable there and remains available on older clients.</li>
</ul>

<p><strong>0.11.2 - Forever and Retail</strong></p>

<ul>
  <li>Added a per-character tooltip health bar texture dropdown with previews of built-in and available LibSharedMedia status bar textures.</li>
</ul>

<p><strong>0.11.1 - Forever and Retail</strong></p>

<ul>
  <li>Use cached quest levels when sorting the tracker and leave its order unchanged if the client supplies restricted quest data.</li>
  <li>Added LH Socials to the companion addon list.</li>
</ul>

<p><strong>0.11.0 - Forever and Retail</strong></p>

<ul>
  <li>Added per-addon character settings profiles and an account-wide snapshot store for sharing general options across characters.</li>
  <li>Choosing a source in LH Tweaks applies it to enabled companion addons; Apply to all repeats the choice after enabling another addon.</li>
  <li>Show WoW: Forever first and last names in the source list after each character logs in with this version. Existing profile keys remain compatible.</li>
</ul>

<p><strong>0.10.9 - Forever and Retail</strong></p>

<ul>
  <li>Added an optional ascending quest-level order to Blizzard's quest tracker.</li>
</ul>

<p><strong>0.10.8 - Forever and Retail</strong></p>

<ul>
  <li>Keep the standard border on common white equipment; the extra glow now starts at uncommon quality.</li>
</ul>

<p><strong>0.10.7 - Forever and Retail</strong></p>

<ul>
  <li>Added an enabled-by-default quality glow for equipment in Blizzard bags and on the character sheet.</li>
</ul>

<p><strong>0.10.6 - Forever and Retail</strong></p>

<ul>
  <li>Fixed an error when hovering over Enable all or Disable all in the LH Tweaks settings header.</li>
</ul>

<p><strong>0.10.5 - Forever and Retail</strong></p>

<ul>
  <li>Limit Leatrix Plus settings refreshes to the LH Tweaks page so Blizzard's game options are not rebuilt by the addon.</li>
</ul>

<p><strong>0.10.4 - Forever and Retail</strong></p>

<ul>
  <li>Positioning is now the first settings section on every LH page that offers it.</li>
</ul>

<p><strong>0.10.3 - Forever and Retail</strong></p>

<ul>
  <li>Positioning settings now begin with enabled-by-default Lock location bar and Lock tooltip controls.</li>
  <li>The other movable LH addons use the same lock-first settings layout.</li>
</ul>

<p><strong>0.10.2 - Forever and Retail</strong></p>

<ul>
  <li>Moved Enable all and Disable all into the settings title bar, directly left of Defaults.</li>
  <li>Hide all and Show all on LH HideMe use the same title bar placement.</li>
</ul>

<p><strong>0.10.1 - Forever</strong></p>

<ul>
  <li>Added a movable tooltip-position preview and improved saved tooltip anchoring during combat.</li>
</ul>

<hr>

<p><sup>*</sup> These addons were implemented with the help of Codex and GPT-6-SOL. Some features may not yet work for every class or race. If you notice anything that doesn't work as expected, please report it in the CurseForge comments so I can take a look.</p>
