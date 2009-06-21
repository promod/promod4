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

	// class limits
	setDvar( "class_assault_limit", "64" );
	setDvar( "class_specops_limit", "2" );
	setDvar( "class_demolitions_limit", "1" );
	setDvar( "class_sniper_limit", "1" );

	setDvar( "class_assault_allowdrop", "1" );
	setDvar( "class_specops_allowdrop", "1" );
	setDvar( "class_demolitions_allowdrop", "0" );
	setDvar( "class_sniper_allowdrop", "0" );

	// assault rifles
	setDvar( "weap_allow_m16", "1" );
	setDvar( "weap_allow_ak47", "1" );
	setDvar( "weap_allow_m4", "1" );
	setDvar( "weap_allow_g3", "1" );
	setDvar( "weap_allow_g36c", "1" );
	setDvar( "weap_allow_m14", "1" );
	setDvar( "weap_allow_mp44", "1" );

	// assault attachments
	setDvar( "attach_allow_assault_none", "1" );
	setDvar( "attach_allow_assault_silencer", "1" );

	// smgs
	setDvar( "weap_allow_mp5", "1" );
	setDvar( "weap_allow_uzi", "1" );
	setDvar( "weap_allow_ak74u", "1" );

	// smg attachments
	setDvar( "attach_allow_smg_none", "1" );
	setDvar( "attach_allow_smg_silencer", "1" );

	// shotguns
	setDvar( "weap_allow_m1014", "1" );
	setDvar( "weap_allow_winchester1200", "1" );

	// sniper rifles
	setDvar( "weap_allow_dragunov", "0" );
	setDvar( "weap_allow_m40a3", "1" );
	setDvar( "weap_allow_barrett", "0" );
	setDvar( "weap_allow_remington700", "1" );
	setDvar( "weap_allow_m21", "0" );

	// pistols
	setDvar( "weap_allow_beretta", "1" );
	setDvar( "weap_allow_colt45", "1" );
	setDvar( "weap_allow_usp", "1" );
	setDvar( "weap_allow_deserteagle", "1" );
	setDvar( "weap_allow_deserteaglegold", "1" );

	// pistol attachments
	setDvar( "attach_allow_pistol_none", "1" );
	setDvar( "attach_allow_pistol_silencer", "1" );

	// assault class default loadout
	setDvar( "class_assault_primary", "ak47" );
	setDvar( "class_assault_primary_attachment", "none" );
	setDvar( "class_assault_secondary", "deserteagle" );
	setDvar( "class_assault_secondary_attachment", "none" );
	setDvar( "class_assault_grenade", "smoke_grenade" );
	setDvar( "class_assault_camo", "camo_none" );

	// specops class default loadout
	setDvar( "class_specops_primary", "ak74u" );
	setDvar( "class_specops_primary_attachment", "none" );
	setDvar( "class_specops_secondary", "deserteagle" );
	setDvar( "class_specops_secondary_attachment", "none" );
	setDvar( "class_specops_grenade", "smoke_grenade" );
	setDvar( "class_specops_camo", "camo_none" );

	// demolitions class default loadout
	setDvar( "class_demolitions_primary", "winchester1200" );
	setDvar( "class_demolitions_primary_attachment", "none" );
	setDvar( "class_demolitions_secondary", "deserteagle" );
	setDvar( "class_demolitions_secondary_attachment", "none" );
	setDvar( "class_demolitions_grenade", "smoke_grenade" );
	setDvar( "class_demolitions_camo", "camo_none" );

	// sniper class default loadout
	setDvar( "class_sniper_primary", "m40a3" );
	setDvar( "class_sniper_primary_attachment", "none" );
	setDvar( "class_sniper_secondary", "deserteagle" );
	setDvar( "class_sniper_secondary_attachment", "none" );
	setDvar( "class_sniper_grenade", "smoke_grenade" );
	setDvar( "class_sniper_camo", "camo_none" );

	setDvar( "class_assault_movespeed", "0.95" );
	setDvar( "class_specops_movespeed", "1.00" );
	setDvar( "class_demolitions_movespeed", "1.00" );
	setDvar( "class_sniper_movespeed", "1.00" );

	// mode
	setDvar( "scr_hardcore", "0" );
	setDvar( "scr_game_onlyheadshots", "0" );

	// team killing
	setDvar( "scr_team_fftype", "1");
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
	setDvar( "scr_game_matchstarttime", "10" );
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
	setDvar( "g_deadChat", "1" );
	setDvar( "scr_teambalance", "0" );
	setDvar( "scr_game_allowkillcam", "0" );
	setDvar( "scr_game_spectatetype", "1" );
	setDvar( "scr_drawfriend", "1" );
	setDvar( "sv_voice", "0" );
	setDvar( "scr_enable_hiticon", "2" );
	setDvar( "scr_enable_scoretext", "1" );

	// scorebot
	setDvar( "promod_enable_scorebot", "0" );

	// website
	setDvar( "promod_hud_show_website", "1" );
	setDvar( "promod_hud_website", "www.callofduty.com" );

	// messagecenter
	setDvar( "promod_messagecenter_enable", "0" ); //enable or disable messagecenter
	setDvar( "promod_mc_restart_every_round", "0" ); //if round-based, messages restarts everyround
	setDvar( "promod_mc_delay", "45" ); //delay between messages (seconds)
	setDvar( "promod_mc_loopdelay", "45" ); //delay (seconds) between the last message in the cue and the first message re-appearing
	setDvar( "promod_mc_maxmessages", "3" ); //numbers of messages to look for
	setDvar( "promod_mc_message_1", "Message Center ON" );
	setDvar( "promod_mc_message_2", "Set Me Up Or Turn Me OFF" );
	setDvar( "promod_mc_message_3", "<*nextmap*>" );
	setDvar( "promod_mc_messagedelay_1", "0" ); //override the default delay between messages
	setDvar( "promod_mc_messagedelay_2", "0" );
	setDvar( "promod_mc_messagedelay_3", "0" );
}