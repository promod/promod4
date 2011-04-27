/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	setDvar( "scr_sd_bombtimer", 45 );
	setDvar( "scr_sd_defusetime", 7 );
	setDvar( "scr_sd_multibomb", 0 );
	setDvar( "scr_sd_numlives", 1 );
	setDvar( "scr_sd_planttime", 5 );
	setDvar( "scr_sd_playerrespawndelay", 0 );
	setDvar( "scr_sd_roundlimit", 20 );
	setDvar( "scr_sd_roundswitch", 10 );
	setDvar( "scr_sd_scorelimit", 0 );
	setDvar( "scr_sd_timelimit", 1.75 );
	setDvar( "scr_sd_waverespawndelay", 0 );

	setDvar( "scr_dom_numlives", 0 );
	setDvar( "scr_dom_playerrespawndelay", 7 );
	setDvar( "scr_dom_roundlimit", 2 );
	setDvar( "scr_dom_roundswitch", 1 );
	setDvar( "scr_dom_scorelimit", 0 );
	setDvar( "scr_dom_timelimit", 15 );
	setDvar( "scr_dom_waverespawndelay", 0 );

	setDvar( "koth_autodestroytime", 120 );
	setDvar( "koth_capturetime", 20 );
	setDvar( "koth_delayPlayer", 0 );
	setDvar( "koth_destroytime", 10 );
	setDvar( "koth_kothmode", 0 );
	setDvar( "koth_spawnDelay", 45 );
	setDvar( "koth_spawntime", 10 );
	setDvar( "scr_koth_numlives", 0 );
	setDvar( "scr_koth_playerrespawndelay", 0 );
	setDvar( "scr_koth_roundlimit", 2 );
	setDvar( "scr_koth_roundswitch", 1 );
	setDvar( "scr_koth_scorelimit", 0 );
	setDvar( "scr_koth_timelimit", 20 );
	setDvar( "scr_koth_waverespawndelay", 0 );

	setDvar( "scr_sab_bombtimer", 45 );
	setDvar( "scr_sab_defusetime", 5 );
	setDvar( "scr_sab_hotpotato", 0 );
	setDvar( "scr_sab_numlives", 0 );
	setDvar( "scr_sab_planttime", 5 );
	setDvar( "scr_sab_playerrespawndelay", 7 );
	setDvar( "scr_sab_roundlimit", 4 );
	setDvar( "scr_sab_roundswitch", 2 );
	setDvar( "scr_sab_scorelimit", 0 );
	setDvar( "scr_sab_timelimit", 10 );
	setDvar( "scr_sab_waverespawndelay", 0 );

	setDvar( "scr_war_numlives", 0 );
	setDvar( "scr_war_playerrespawndelay", 0 );
	setDvar( "scr_war_roundlimit", 2 );
	setDvar( "scr_war_scorelimit", 0 );
	setDvar( "scr_war_roundswitch", 1 );
	setDvar( "scr_war_timelimit", 15 );
	setDvar( "scr_war_waverespawndelay", 0 );

	setDvar( "scr_dm_numlives", 0 );
	setDvar( "scr_dm_playerrespawndelay", 0 );
	setDvar( "scr_dm_roundlimit", 1 );
	setDvar( "scr_dm_scorelimit", 0 );
	setDvar( "scr_dm_timelimit", 10 );
	setDvar( "scr_dm_waverespawndelay", 0 );

	setDvar( "class_assault_limit", 64 );
	setDvar( "class_specops_limit", 2 );
	setDvar( "class_demolitions_limit", 1 );
	setDvar( "class_sniper_limit", 1 );

	setDvar( "class_assault_allowdrop", 1 );
	setDvar( "class_specops_allowdrop", 1 );
	setDvar( "class_demolitions_allowdrop", 0 );
	setDvar( "class_sniper_allowdrop", 0 );

	setDvar( "weap_allow_m16", 1 );
	setDvar( "weap_allow_ak47", 1 );
	setDvar( "weap_allow_m4", 1 );
	setDvar( "weap_allow_g3", 1 );
	setDvar( "weap_allow_g36c", 1 );
	setDvar( "weap_allow_m14", 1 );
	setDvar( "weap_allow_mp44", 1 );

	setDvar( "attach_allow_assault_none", 1 );
	setDvar( "attach_allow_assault_silencer", 1 );

	setDvar( "weap_allow_mp5", 1 );
	setDvar( "weap_allow_uzi", 1 );
	setDvar( "weap_allow_ak74u", 1 );

	setDvar( "attach_allow_specops_none", 1 );
	setDvar( "attach_allow_specops_silencer", 1 );

	setDvar( "weap_allow_m1014", 1 );
	setDvar( "weap_allow_winchester1200", 1 );

	setDvar( "weap_allow_m40a3", 1 );
	setDvar( "weap_allow_remington700", 1 );

	setDvar( "weap_allow_beretta", 1 );
	setDvar( "weap_allow_colt45", 1 );
	setDvar( "weap_allow_usp", 1 );
	setDvar( "weap_allow_deserteagle", 1 );
	setDvar( "weap_allow_deserteaglegold", 1 );

	setDvar( "attach_allow_pistol_none", 1 );
	setDvar( "attach_allow_pistol_silencer", 1 );

	setDvar( "weap_allow_flash_grenade", 1 );
	setDvar( "weap_allow_frag_grenade", 1 );
	setDvar( "weap_allow_smoke_grenade", 1 );

	setDvar( "class_assault_primary", "ak47" );
	setDvar( "class_assault_primary_attachment", "none" );
	setDvar( "class_assault_secondary", "deserteagle" );
	setDvar( "class_assault_secondary_attachment", "none" );
	setDvar( "class_assault_grenade", "smoke_grenade" );
	setDvar( "class_assault_camo", "camo_none" );

	setDvar( "class_specops_primary", "ak74u" );
	setDvar( "class_specops_primary_attachment", "none" );
	setDvar( "class_specops_secondary", "deserteagle" );
	setDvar( "class_specops_secondary_attachment", "none" );
	setDvar( "class_specops_grenade", "smoke_grenade" );
	setDvar( "class_specops_camo", "camo_none" );

	setDvar( "class_demolitions_primary", "winchester1200" );
	setDvar( "class_demolitions_primary_attachment", "none" );
	setDvar( "class_demolitions_secondary", "deserteagle" );
	setDvar( "class_demolitions_secondary_attachment", "none" );
	setDvar( "class_demolitions_grenade", "smoke_grenade" );
	setDvar( "class_demolitions_camo", "camo_none" );

	setDvar( "class_sniper_primary", "m40a3" );
	setDvar( "class_sniper_primary_attachment", "none" );
	setDvar( "class_sniper_secondary", "deserteagle" );
	setDvar( "class_sniper_secondary_attachment", "none" );
	setDvar( "class_sniper_grenade", "smoke_grenade" );
	setDvar( "class_sniper_camo", "camo_none" );

	setDvar( "scr_team_fftype", 1 );
	setDvar( "scr_team_teamkillpointloss", 5 );
	setDvar( "scr_game_deathpointloss", 0 );
	setDvar( "scr_game_suicidepointloss", 0 );
	setDvar( "scr_player_suicidespawndelay", 0 );
	setDvar( "scr_player_forcerespawn", 1 );

	setDvar( "bg_fallDamageMinHeight", 140 );
	setDvar( "bg_fallDamageMaxHeight", 350 );

	setDvar( "scr_game_matchstarttime", 10 );
	setDvar( "scr_enable_hiticon", 2 );
	setDvar( "scr_enable_scoretext", 1 );

	setDvar( "logfile", 1 );
	setDvar( "g_log", "games_mp.log" );
	setDvar( "g_logSync", 0 );

	setDvar( "g_inactivity", 0 );
	setDvar( "g_no_script_spam", 1 );
	setDvar( "g_antilag", 1 );
	setDvar( "g_smoothClients", 1 );
	setDvar( "sv_allowDownload", 1 );
	setDvar( "sv_maxPing", 0 );
	setDvar( "sv_minPing", 0 );
	setDvar( "sv_reconnectlimit", 3 );
	setDvar( "sv_timeout", 240 );
	setDvar( "sv_zombietime", 2 );
	setDvar( "sv_floodprotect", 4 );
	setDvar( "sv_kickBanTime", 0 );
	setDvar( "sv_disableClientConsole", 0 );
	setDvar( "sv_voice", 0 );
	setDvar( "sv_clientarchive", 1 );
	setDvar( "timescale", 1 );

	setDvar( "g_allowVote", 0 );
	setDvar( "scr_game_allowkillcam", 0 );
	setDvar( "scr_game_spectatetype", 1 );
	setDvar( "scr_hardcore", 0 );
}