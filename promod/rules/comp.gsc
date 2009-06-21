/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	// sd
	setDvar( "scr_sd_bombtimer", "45" );
	setDvar( "scr_sd_defusetime", "7" );
	setDvar( "scr_sd_multibomb", "0" );
	setDvar( "scr_sd_numlives", "1" );
	setDvar( "scr_sd_planttime", "5" );
	setDvar( "scr_sd_playerrespawndelay", "0" );
	setDvar( "scr_sd_roundlimit", "20" );
	setDvar( "scr_sd_roundswitch", "10" );
	setDvar( "scr_sd_scorelimit", "0" );
	setDvar( "scr_sd_timelimit", "1.75" );
	setDvar( "scr_sd_waverespawndelay", "0" );

	// dom
	setDvar( "scr_dom_numlives", "0" );
	setDvar( "scr_dom_playerrespawndelay", "7" );
	setDvar( "scr_dom_roundlimit", "2" );
	setDvar( "scr_dom_scorelimit", "0" );
	setDvar( "scr_dom_timelimit", "15" );
	setDvar( "scr_dom_waverespawndelay", "0" );
	setDvar( "scr_dom_roundswitch", "1" );

	// koth
	setDvar( "koth_autodestroytime", "120" );
	setDvar( "koth_capturetime", "20" );
	setDvar( "koth_delayPlayer", "0" );
	setDvar( "koth_destroytime", "10" );
	setDvar( "koth_kothmode", "0" );
	setDvar( "koth_spawnDelay", "45" );
	setDvar( "koth_spawntime", "10" );
	setDvar( "scr_koth_numlives", "0" );
	setDvar( "scr_koth_playerrespawndelay", "0" );
	setDvar( "scr_koth_roundlimit", "2" );
	setDvar( "scr_koth_roundswitch", "1" );
	setDvar( "scr_koth_scorelimit", "0" );
	setDvar( "scr_koth_timelimit", "15" );
	setDvar( "scr_koth_waverespawndelay", "0" );

	// sab
	setDvar( "scr_sab_bombtimer", "45" );
	setDvar( "scr_sab_defusetime", "5" );
	setDvar( "scr_sab_hotpotato", "0" );
	setDvar( "scr_sab_numlives", "0" );
	setDvar( "scr_sab_planttime", "5" );
	setDvar( "scr_sab_playerrespawndelay", "7" );
	setDvar( "scr_sab_roundlimit", "4" );
	setDvar( "scr_sab_roundswitch", "2" );
	setDvar( "scr_sab_scorelimit", "0" );
	setDvar( "scr_sab_timelimit", "10" );
	setDvar( "scr_sab_waverespawndelay", "0" );

	// tdm
	setDvar( "scr_war_numlives", "0" );
	setDvar( "scr_war_playerrespawndelay", "0" );
	setDvar( "scr_war_roundlimit", "2" );
	setDvar( "scr_war_scorelimit", "0" );
	setDvar( "scr_war_timelimit", "15" );
	setDvar( "scr_war_waverespawndelay", "0" );
	setDvar( "scr_war_roundswitch", "1" );

	// dm
	setDvar( "scr_dm_numlives", "0" );
	setDvar( "scr_dm_playerrespawndelay", "0" );
	setDvar( "scr_dm_roundlimit", "2" );
	setDvar( "scr_dm_scorelimit", "0" );
	setDvar( "scr_dm_timelimit", "10" );
	setDvar( "scr_dm_waverespawndelay", "0" );

	// mode
	setDvar( "scr_hardcore", "0" );
	setDvar( "scr_game_onlyheadshots", "0" );

	// team killing
	setDvar( "scr_team_teamkillpointloss", "5" );
	setDvar( "scr_team_teamkillspawndelay", "0" );
	setDvar( "scr_team_kickteamkillers", "0" );

	// player death/respawn settings
	setDvar( "scr_player_numlives", "1" );
	setDvar( "scr_player_forcerespawn", "1" );
	setDvar( "scr_player_respawndelay", "0" );
	setDvar( "scr_game_deathpointloss", "0" );
	setDvar( "scr_game_suicidepointloss", "0" );
	setDvar( "scr_player_suicidespawndelay", "0" );

	// player default movement speeds
	setDvar( "scr_player_sprinttime", "4" );

	// player fall damage
	setDvar( "bg_fallDamageMinHeight", "140" );
	setDvar( "bg_fallDamageMaxHeight", "350" );

	// game timers
	setDvar( "scr_game_matchstarttime", "5" );
	setDvar( "scr_game_playerwaittime", "15" );

	// hud
	setDvar( "g_maxDroppedWeapons", "16" );
	setDvar( "ui_hud_showdeathicons", "0" );

	// grenades
	setDvar( "weap_allow_flash_grenade", "1" );
	setDvar( "weap_allow_frag_grenade", "1" );
	setDvar( "weap_allow_smoke_grenade", "1" );

	// logging
	setDvar( "logfile", "1" );
	setDvar( "g_log", "games_mp.log" );
	setDvar( "g_logSync", "0" );
	setDvar( "loc_warnings", "0" );

	// client issues
	setDvar( "sv_maxPing", "0" );
	setDvar( "sv_maxRate", "25000" );
	setDvar( "sv_minPing", "0" );
	setDvar( "sv_reconnectlimit", "3" );
	setDvar( "g_inactivity", "0" );
	setDvar( "g_banIPs", "" );
	setDvar( "sv_kickBanTime", "0" );
	setDvar( "sv_disableClientConsole", "0" );

	// various
	setDvar( "sv_allowDownload", "1" );
	setDvar( "g_allowVote", "0" );
	setDvar( "scr_teambalance", "0" );
	setDvar( "scr_game_allowkillcam", "0" );
	setDvar( "scr_game_spectatetype", "1" );
	setDvar( "scr_drawfriend", "1" );
	setDvar( "sv_voice", "0" );
}