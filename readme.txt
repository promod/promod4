Promod LIVE V2.20 EU - README
http://www.codpromod.com
2014-05-13 <promod [at] codpromod.com>
#codpromod @ QuakeNet

Maintained by Ingram

Sponsored by FragNet
http://www.fragnet.net

Zip-package (promodlive220_eu.zip) contains:

LICENSE
pml220\mod.ff
pml220\pml220.iwd
pml220\z_c_r.iwd
pb\stock_iwd_md5.cfg
pb\promod_iwd_md5.cfg
pb\pbsvuser.cfg
readme.txt
server_setup.txt
server.cfg

LIVE V2.20:
- Fixed issues with vehicle damage source being different compared to previous releases

LIVE V2.19:
- Fixed a server crash related to damage inflicted via exploding barrels
- Re-implemented vehicle handling. This fixes two known issues:
  1) Cars would keep burning and not explode after a while
  2) Throwing a grenade to one of the headlights would explode the car

LIVE V2.18:
- Fixed the exploit where players could hide behind floodlights (solution found by Gunner)
- Removed the flashbang blinding effect during kniferound

LIVE V2.17:
- Shortened file and folder names in order to fix (or avoid) "file sum/name mismatch" error. Please note that fs_game naming scheme is slighly different from now on.
- Added timer to pre-match ready up period.

Public server owners should rename their z_custom_ruleset.iwd to the new shorter version of z_c_r.iwd, nothing inside is changed.

LIVE V2.16:
- Fixed a small bug that appeared during 2.15. We're sorry about that!

LIVE V2.15:
- Fixed a bug where players could fall silently by holding down a grenade key and not having any grenades in inventory
- Reworked damage logic, no changes in damage values, but minimal performance boost
- Included a reworked version of damage and accuracy statistics (B-4-6), counters will reset after displaying current values
- Included new log prints:
    Accuracy and damage: P_A;<player guid>;<player entity number>;<player name>;<shots fired>;<shots hit>;<damage done>;<damage taken>;<friendly damage done>;<friendly damage taken>
    Bomb plants (SD & SAB): P_P;<player guid>;<player entity number>;<player name>
    Bomb defuses (SD & SAB): P_D;<player guid>;<player entity number>;<player name>
    Flag captures (DOM): P_F;<player guid>;<player entity number>;<player name>
    Headquarters captures (KOTH): P_HQC;<player guid>;<player entity number>;<player name>
    Headquarters destroys (KOTH): P_HQD;<player guid>;<player entity number>;<player name>

LIVE V2.14:
- Fixed boosting with modified g_knockback value
- Game will message all players if any serverside DVars are being modified
- Added comp_public_lan, comp_public_hc_lan and custom_public_lan modes
- Fixed an issue with scorebot messages being generated incorrectly

LIVE V2.13:

- Implemented MOTD (message of the day), can be set via dvar "scr_motd"
- Various fixes and improvements to the shoutcaster UI
- Fixed problems with loading preserved classes
- Invalid gametypes on custom maps will no longer cause server to crash
- Added possibility to set scores with promod_mode (more info in promod modes section)
- Removed flinching animation when player get shot
- Removed ability to shoot during strat time
- Improved custom maps compability
- Player is immune to flashbangs in ready up and start mode flying
- Main menu changes (not much)
- Serverside performance improvements
- Knife round fixes, weapon abuse eliminated
- Fixed ready-up messages
- Other various UI tweaks and improvements

LIVE V2.12:

- Protection against clientside executable modification
- Fixed knife-round to always remove the weapons and ammo, all other damage than from the knife is disabled as an extra measure
- Record-menu will no longer appear twice in knife-rounds
- Fixed choosing team menu on custom maps
- Various fixes which improve server performance

LIVE V2.11:

- Soften smoke edges (also known as r_zfeather) is back to being forced off
- Dead chat is no longer automatically handled in public-modes
- Promod will properly force player to reconnect to the server if "vid_restart" was called
- The "You killed..." text's Y-position can be modified in devmap for movie-makers (see below)
- Removed player head-icons from Marines and SAS (stock bug, as opposing teams don't have head-icons)
- Fixed planted/defused/destroyed announcer sounds
- Promod header will inform about the usage of knife round feature
- Specular effect on car-glasses made transparent
- Better overall handling of player status icons
- The bomb-briefcase is no longer visible in timeout or knife-round
- Ability to cancel timeouts by the caller (by calling another timeout)
- Ready-up hud will always display own status (important for shoutcasters)
- Shoutcaster will automatically follow another player when current player dies
- Shoutcasters have ability to spectate another shoutcaster when that shoutcaster is using follow-player-binds
- Full map restart is called when server admin changes game type and issues a fast restart
- Fixed a bug where a player could sprint longer after planting/defusing
- Ragdolls removed because of random behaviour
- Added an option for custom map developers to specify default sunlight (level.sunlight) in map script to correctly set with Promod "stock" sunlight option
- Strattime and knife round in public-modes are now working properly
- Scorebot improvements and fixes, see FAQ for comprehensive documentation
- Different game menu adjustments
- Dvar-monitor will now display both the old and the new value when change is detected
- Before a match starts, a list of dvar changes during ready-up mode is displayed
- Some additions to strictly forced server settings
- Fixed several issues with bomb-drop
- Added training-dummy feature for strat mode, which will only work on listen/local servers with PunkBuster turned off
- Added a record-menu which will popup once a player is ready, this menu can optionally be disabled in the quickmessage menu: B-4-5
- Added a sound notification to the last player to ready-up

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

FAQ

Q: What about the hardcore, and support for all gametypes, how do I use them?
A: For a complete list of "promod_modes", see below.

Q: I want to run my own custom Promod-server with skins etc, how?
A: In order to run your own custom Promod-server you'll need to change the fs_game to anything besides "mods/pml220" as well as not using match-modes. You will now be able to modify the Promod IWDs and add additional iwd-files.

Q: Can I use this mod as a movie mod?
A: Yes, you can! Commands (which are important for movie-making) are only forced on the clients once connected. Demos needs to be loaded using devmap before starting a demo ("devmap mp_crash;disconnect").

Q: How do I get the scorebot running?
A: See below how to enable scorebot.

Q: Class related binds, how do they work?
A: See below for a list of commands.

Q: What's the difference between the EU and NE version of Promod?
A: The NE version of Promod has rate and cl_maxpackets settings unlocked and radar does not display enemy indicators while shooting. NE stands for Non-Europe.

Q: My question is not answered here.
A: Easiest way to contact us is via mail or join #codpromod @ QuakeNet.

Q: How do I get the training-dummy to work?
A: First put up a local home-hosted server without PB (set sv_punkbuster to "0" in your config, start game, launch Promod from the mods-menu and load a map with the console or menu). The default button for spawning a bot is the "N" button (bind X "+actionslot 1").

PROMOD MODES

The promod_mode dvar follows a specific syntax. However the game accepts the bits between underscores ( _ ) in any order.

match: standard match mode, may not be used with knockout mode. Round limit = mr#*2
knockout: knockout match mode, may not be used with standard match mode. Score limit = mr#+1
mr#: maxrounds - see above for use. Default is 10. Works only in Search & Destroy and Sabotage.
lan: lan mode - g_antilag 0, PunkBuster messages turned off, may not be used with pb mode.
hc: hardcore mode (disables some HUD elements and reduces health level to 30).
knife: knife round - adds a knife round and an extra ready-up mode to Search & Destroy matches.
1v1/2v2: used for 1v1 and 2v2 matches, disables Demolitions and Sniper classes.
pb: disables PunkBuster warnings for online modes, may not be used with lan mode.
#:#: will set match score in S&D using A:D format - useful in case of a restart, may not be used with knife mode.

For example "promod_mode match_mr10_knife_pb" will enable knife round and disable PunkBuster warnings in standard maxrounds 10 mode.

There are also some other modes, these can not be combined with the tags above.

comp_public - the default mode for competitive public
comp_public_lan - same as above, but for LAN servers
comp_public_hc - competitive public in hardcore mode
comp_public_hc_lan - same as above, but for LAN servers
custom_public - custom public mode reading settings from z_c_r.iwd
custom_public_lan - same as above, but for LAN servers
strat - strategy mode for practicing

SCOREBOT

The "ticker" is updating events every 10 seconds, each event is starting with a number from 0-9.
Messages are delimited by the "SOH" character (start of header).
To enable scorebot, add this line to the server-config:

seta promod_enable_scorebot "1"

Static info:

attack_score "SOH" player_name "SOH" player_alive "SOH" player_kills "SOH" player_assists "SOH" player_deaths "SOH" player_bombcarrier
defence_score "SOH" player_name "SOH" player_alive "SOH" player_kills "SOH" player_assists "SOH" player_deaths "SOH" player_bombcarrier

Ticker events:

"SOH" "round_winner" "SOH" winners "SOH" attack_score "SOH" defence_score
"SOH" "map_complete" "SOH" "attack" "SOH" attack_score "SOH" "defence" "SOH" defence_score
"SOH" "knife_round"
"SOH" start_text "SOH" starting_round
"SOH" "map" "SOH" mapname "SOH" gametype
"SOH" "kill" "SOH" killer_name "SOH" weapon "SOH" killed_name "SOH" headshot
"SOH" "assist_by" "SOH" player_name
"SOH" rdy_text
"SOH" "timeout_cancelled" "SOH" timeout_team "SOH" player_name
"SOH" "timeout_called" "SOH" timeout_team "SOH" player_name
"SOH" "captured" label "SOH" player_name //dom
"SOH" "hq_captured" "SOH" player_name //hq
"SOH" "hq_destroyed" "SOH" player_name //hq
"SOH" "pickup_bomb" "SOH" player_name //sab, sd
"SOH" "dropped_bomb" "SOH" player_name //sab, sd
"SOH" "defused_by" "SOH" player_name //sab, sd
"SOH" "bomb_exploded" //sab, sd
"SOH" "planted_by" "SOH" player_name // sab, sd

Definitions:

attack_score = score of the attacking side, integer
defence_score = score of the defending side, integer
player_name = name of the player
player_alive = if player is alive, integer
player_assists = number of assists, integer
player_deaths = number of deaths, integer
player_bombcarrier = if player is carrying bomb, integer
winners = attack, defence or tie
start_text = "1st_half_started", "2nd_half_started", "match_resumed" (from timeout), "round_start"
starting_round = the round starting, integer
mapname = the map name in "mp_" format
gametype = the gametype in short format
killer_name = the name of the killer
weapon = weapon used by the killer
killed_name = the name of the player who got killed
headshot = if it was a headshot, integer
rdy_text = 1st_half_ready_up, 2nd_half_ready_up, timeout_ready_up
timeout_team = the team of the player who made a timeout
label = A, B, C etc

Broadcasted dvars:

__promod_attack_score
__promod_defence_score
__promod_mode
__promod_ticker
__promod_version

FORCED COMMANDS

All these dvars are forced by Promod (automatically), make sure they stay untouched/within range to avoid being punished!
Note that these does not apply in Shoutcaster mode.

dynent_active 0
rate 25000
cg_nopredict 0
sm_enable 0
r_dlightLimit 0
r_lodscalerigid 1
r_lodscaleskinned 1
r_filmtweakInvert 0
r_zfeather 0
cg_viewzsmoothingmin 1
cg_viewzsmoothingmax 16
cg_viewzsmoothingtime 0.1
cg_huddamageiconheight 64
cg_huddamageiconwidth 128
cg_huddamageiconinscope 0
cg_huddamageiconoffset 128
cg_huddamageicontime 2000
developer 0
phys_gravity -800

com_maxfps 40 - 250
cl_maxpackets 60 - 100
compassplayerwidth EQUAL TO compassplayerheight
compassfriendlywidth EQUAL TO compassfriendlyheight

DEMO VIEWING

There are some special dvars made to control hud-elements for demo/movie purposes.
They will only work in maps loaded with cheats (devmap). Don't forget the "set" prefix to add new dvars in the console.

These include:

promod_movie_hidescorebar // [0-1] (hides the mini-scorebar completely including timer)
promod_centermessage_position // [x+-] (overrides default Y-position of the "You killed..." text)

CLASS BINDS

It is possible to bind these via the in-game menu (Controls - Multiplayer Controls...).
Alternatively you can manually bind them in the console/config.

bind [KEY] [COMMAND]

Commands:

openscriptmenu quickpromod assault
openscriptmenu quickpromod specops
openscriptmenu quickpromod demolitions
openscriptmenu quickpromod sniper
openscriptmenu quickpromod silencer
openscriptmenu quickpromod grenade

SHOUTCASTER BINDS

You can bind them via the in-game menu (Shoutcast Setup).
Alternatively you can manually bind them in the console/config.

bind [KEY] [COMMAND]

Commands:

openscriptmenu shoutcast_setup number
openscriptmenu shoutcast_setup assault
openscriptmenu shoutcast_setup specops
openscriptmenu shoutcast_setup demolitions
openscriptmenu shoutcast_setup sniper

Number being 1-10 for players, it's very easy to understand which player corresponds the correct number.
1-5 symbolizes players on Attacking side from top to bottom looking at the Shoutcaster-bars.
6-10 being on the Defending side.

Setting a class (lowercase) instead of a number will cycle through players using that class.

CUSTOM MAPS

In case Promod is throwing an error while playing on custom maps, make sure the IWD-files inside "usermaps/mapname" folder have the same map name in them.
For example map "mp_dahman_b3" contains a file called "mp_dahman_b3.iwd" and therefore it is not marked as a violation.

NOTES FOR SERVER-ADMINS AND SERVER-HOSTING COMPANIES

The dvar fs_game "mods/pml220" is forced for match-servers and do not rename any files or modify contents of them.
However custom servers with skins etc. must use something else than "mods/pml220" for example "mods/pml220_custom", it's not restricted and you are free to add additional iwd files or modify existing ones.

Included with Promod are two PunkBuster MD5 configs, "stock_iwd_md5.cfg" and "promod_iwd_md5.cfg" which you can put in the pb-folder on your server, it contains checksums for the stock IWD-files as well as Promod-IWD for use with PunkBuster MD5 facility to prevent custom skins and other forms of cheating and abusing and can be loaded in-game by typing "\rcon pb_sv_load stock_iwd_md5.cfg" and "\rcon pb_sv_load promod_iwd_md5.cfg".

In order to be automatically-executed, the list of checks needs to be included into the automatically-executed PunkBuster configuration files on your server (pbsv.cfg or pbsvuser.cfg):

pb_sv_load stock_iwd_md5.cfg
pb_sv_load promod_iwd_md5.cfg // match-server only

In case your server doesn't have any pbsv.cfg file, go in-game and type: "\rcon pb_sv_writecfg". Depending on if your server is streaming to any third-party anti-cheat site(s) you may or may not already have a pbsvuser.cfg, if you don't you can just copy all three files included to your server's PB-folder, or if the file exist add above lines to it.

We STRONGLY encourage use of these MD5-checks! (This goes for leagues as well!)

Due to several game engine exploits, we recommend to specify the rcon-password in the command-line of your server. If this is not possible, rename the server-config to something other than server.cfg, which would make finding rcon password more difficult.

On another note of security, the IWD-file "z_c_r.iwd" is now running integrity checks if server is running match-mode which means you have to decide whether the server should run "promod_mode custom_public" or not.
If you later want to run match-modes you will have to use the original unmodified "z_c_r.iwd" supplied in this package. Sorry for any inconvenience caused.