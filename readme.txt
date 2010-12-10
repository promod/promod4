Promod LIVE V2.10 EU - README
http://www.codpromod.com
2010-12-10 <promod [at] codpromod.com>
#codpromod @ QuakeNet

Developers: Trivve & Ingram
Manager: abhi

Sponsored by FragNet
http://www.fragnet.net

In association with Vita Nova
http://www.thevitanova.org
#Vita-Nova @ QuakeNet

In this zip-package (promodlive210_eu.zip):

promodlive210\mod.ff
promodlive210\promodlive210.iwd
promodlive210\z_custom_ruleset.iwd
readme.txt
server_setup.txt
server.cfg
iwd.cfg

CHANGES

LIVE V2.10:

- Game code optimizations which reduce the size of mod over 50% compared to V2.04
- Killspec mode. Commits suicide, releases current class spot and does not respawn the player before a class is selected again. Can be activated through quickmessage menu: B-4-4 or by console command openscriptmenu quickpromod killspec
- Moved game timer closer to the edge of the screen for shoutcasters
- Improved server integrity checks
- Defaulted "promod_mode" to strat when starting a new server from main menu
- Knife round. For match modes adds an extra round and ready-up mode, in public games it will be the first round of map. It can be toggled via knife keyword in promod_mode (for example match_mr10_knife) or dvar "promod_kniferound" in public games. Scorebot announces knife round via knife_round keyword
- Ready-up mode is more responsive
- Improved promod_mode, for use see below
- Increased dropped weapon disappearing time to 3 minutes
- Promod Commands and Promod Graphics menus can be accessed via openscriptmenu quickpromod controls / graphics respectively
- Added tactical timeouts for lan mode. It is possible to take unlimited amount of timeouts for unlimited time
- Improved strat mode
- Fixed public server weapons glitch
- Forced fs_game for match modes. If you don't know how to change fs_game setting, please contact your Game Server Provider
- Removed red enemy dots from large map
- Included with package: PunkBuster MD5Tool checks for main/iw_##.iwd files. This needs to be set up manually, see below
- Added echo command, which will display text only to yourself in game message box. Usage: openscriptmenu echo text_I_want_to_display - note that underscores are replaced with spaces. Works also with colors. However stacking two openscriptmenu commands to one bind will not work
- Shoutcasters can now choose who to follow using binds and even toggle players by their current class

Plus many other visual, non-gameplay related improvements.

LIVE V2.04:

- Reintroduced "cl_maxpackets" enforcement to "100"
- Small fix in the scorebot
- Weapon class availability fixed on halftime

LIVE V2.03:

After one hotfix and several release candidates:

- Added delay in the end of the round for movie-makers
- Several minor bugs fixed
- Prevention for "spec-nading"
- Updated promod modes
- Forcing for maxpackets (100) removed, it's now possible to use 60 - 100 (some regions need this, if leagues need fixed values, use punkbuster scripts to force)
- Team auto-balancing has been removed, which was causing severe issues, for instance HUD-disappearing and invariability bug
- The in-game stats has been removed, due to big inaccuracies in values

Big thanks to the community for reporting bugs and other issues.
Especially thanks to paradox-, and other that we might forgot. Also thanks to giunuz and SirXenos for extensive bug testing.

LIVE V2:

Except various bug fixes and code-enhancements:

- Fully functional shoutcaster overlay for all resolutions and aspect ratios
- Class loadouts are preserved in the rank file
- Class related binds
- Enhanced client- and server-security
- Small changes/improvements to the hud and menus
- Players left-HUD is rebuilt and therefore possible to get rid of for those nice-looking frag-movies
- Full Hardcore-mode support, including support for all gametypes, HC mode will also use cook-nades
- Red enemy crosshair glitch through smoke fixed
- Added a strat mode (promod_mode strat) with nadetraining possibility, similar to AM4PAM
- Client-side scorebot functionality implemented, similar to the PAM4 ditto.
- Disabled ammo-sharing between SMG-class and M9 Beretta, as well as reduced weapon switch on M16
- All taunt sounds removed

FAQ

Q: What about the hardcore, and support for all gametypes, how do I use them?
A: For a complete list of "promod_modes", see below.

Q: Can the rulesets be customized to fit my needs?
A: Promod has always been about an unified ruleset. Therefore they only thing you can change in the regular match-modes is mr-rating (SD and SAB only).

Q: I want to run my own custom promod-server with skins etc, how?
A: In order to run your own custom promod-server you'll need to change the fs_game to anything besides "mods/promodlive210" as well as not using match-modes. You will now be able to modify the Promod IWDs and add additional iwd-files.

Q: Can I use this mod as a movie mod?
A: Yes, you can! Commands (which are important for movie-making) are only forced on the clients once connected (with one exception, see below). Demos needs to be loaded using devmap before starting a demo ("devmap mp_crash;disconnect"). If you only having black screen, change "r_contrast" to "1" as well as "r_brightness" to "0".

Q: How do I get the scorebot running?
A: See below how to enable scorebot.

Q: Class related binds, how do they work?
A: See below for a list of commands.

Q: My question is not answered here.
A: Easiest way to contact us is via mail or join #codpromod @ QuakeNet.

PROMOD MODES

The promod_mode dvar follows a specific syntax. However the game accepts the bits between underscores (_) in any order.

match: standard match mode, conflicts with knockout mode. Round limit = mr#*2
knockout: knockout match mode, conflicts with standard match mode. Score limit = mr#+1
mr#: maxrounds - see above for use. Default is 10. Works only in Search & Destroy and Sabotage.
lan: lan mode - g_antilag 0, punkbuster messages turned off. Conflicts with pb mode.
hc: hardcore mode (disables some HUD elements and reduces health level to 30).
knife: knife round - adds a knife round and an extra ready-up mode to Search & Destroy matches.
1v1/2v2: used for 1v1 and 2v2 matches, disables Demolitions and Sniper classes.
pb: disables punkbuster warnings for online modes. Conflicts with lan mode.

For example "promod_mode match_mr10_knife_pb" will enable knife round and disable punkbuster warnings in standard maxrounds 10 mode.

There are also some other modes:

comp_public
comp_public_hc
custom_public
strat

SCOREBOT

To enable scorebot, add this line to your server-config:

seta promod_enable_scorebot "1"

FORCED COMMANDS

All these dvars are forced by Promod (automatically), make sure they stay untouched/within range to avoid being punished!

dynent_active 0
rate 25000
cg_nopredict 0
sm_enable 0
r_dlightLimit 0
r_lodscalerigid 1
r_lodscaleskinned 1
r_filmtweakInvert 0
r_zfeather 1
cg_viewzsmoothingmin 1
cg_viewzsmoothingmax 16
cg_viewzsmoothingtime 0.1
cg_huddamageiconheight 64
cg_huddamageiconwidth 128
developer 0

com_maxfps 40 - 250
cl_maxpackets 60 - 100
compassplayerwidth EQUAL TO compassplayerheight
compassfriendlywidth EQUAL TO compassfriendlyheight

CLASS BINDS

You can bind them via the in-game menu. (Controls - Multiplayer Controls…)
Alternatively you can manually bind them in the console/config.

bind [KEY] [COMMAND]

openscriptmenu quickpromod silencer //toggles silencer on/off on the primary weapon
openscriptmenu quickpromod grenade //toggles between flash/smoke-grenade
openscriptmenu quickpromod assault
openscriptmenu quickpromod specops
openscriptmenu quickpromod demolitions
openscriptmenu quickpromod sniper

SHOUTCASTER BINDS

You can bind them via the Shoutcaster main-menu.
Alternatively you can manually bind them in the console/config.

bind [KEY] [COMMAND]

openscriptmenu shoutcast_setup number
openscriptmenu shoutcast_setup assault
openscriptmenu shoutcast_setup specops
openscriptmenu shoutcast_setup demolitions
openscriptmenu shoutcast_setup sniper

Number being 1-10, it's very easy to understand which player corresponds the correct number.
1-5 symbolizes players on Attacking side from top to down looking at the shoutcaster-bars.
6-10 same goes here, players on Defending side.

Putting the class instead of a number will cycle through players using that class.

CUSTOM MAPS

In case Promod is throwing an error while playing on custom maps, make sure the IWD-files inside "usermaps/mapname" folder have the same map name in them.
For example map "mp_dahman_b3" contains a file called "mp_dahman_b3.iwd" and therefore it is not marked as a violation.

NOTES FOR SERVER-ADMINS AND SERVER-HOSTING COMPANIES

The dvar fs_game "mods/promodlive210" is forced for match-servers and do not rename any files or modify contents of them.
We recommend using the iwd.cfg which you can put in the pb-folder, it contains checksums for the stock iwd-files for preventing custom skins and such and can be loaded by typing "rcon pb_sv_load iwd.cfg".
However custom servers with skins etc. must use something else than "mods/promodlive210" for example "mods/promodlive210_custom", it's not restricted and you are free to modify files as well.

On another note of security, the IWD-file "z_custom_ruleset.iwd" is now running integrity checks if server is running match-mode which means you have to decide whether the server should run "promod_mode custom_public" or not.
If you later want to run match-modes you will have to use the original unmodified "z_custom_ruleset.iwd" supplied in this package. Sorry for any inconvenience caused.