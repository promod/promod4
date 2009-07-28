/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	if ( isDefined( game["promod_mode_loaded"] ) && game["promod_mode_loaded"] == 1 )
		return;

	game["promod_mode_loaded"] = 1;
	game["PROMOD_VERSION"] = "Promod ^1LIVE ^7V2.04 EU";

	promod_mode = toLower(getDvar("promod_mode") );

	if ( !Is_Valid_Promod_Mode( promod_mode ) )
		setDvar("promod_mode", "comp_public");

	Promod_Mode_Explode();
}

Promod_Mode_Explode()
{
	game["PROMOD_MODE"] = toLower( getDvar( "promod_mode" ) );
	game["CUSTOM_MODE"] = 0;
	game["LAN_MODE"] = 0;
	game["HARDCORE_MODE"] = 0;
	game["KNOCKOUT_MODE"] = 0;
	game["COMP_PUBLIC"] = 0;
	game["PROMOD_LIMITED"] = 0;
	game["MR_RATING"] = 0;
	game["PROMOD_STRATTIME"] = 6;

	if ( isSubStr( game["PROMOD_MODE"], "knockout_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "knockout_mr", game["PROMOD_MODE"] );
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4Match Knockout ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "knockout_hc_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "knockout_hc_mr", game["PROMOD_MODE"] );
		game["KNOCKOUT_MODE"] = 1;
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4Match Knockout ^1HC ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "knockout_lan_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode("knockout_lan_mr",game["PROMOD_MODE"]);
		game["LAN_MODE"] = 1;
		game["KNOCKOUT_MODE"] = 1;
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4LAN Knockout ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "knockout_lan_hc_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "knockout_lan_hc_mr", game["PROMOD_MODE"] );
		game["LAN_MODE"] = 1;
		game["HARDCORE_MODE"] = 1;
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4LAN Knockout ^1HC ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "knockout_1v1_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "knockout_1v1_mr", game["PROMOD_MODE"] );
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^41v1 Knockout ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr(game["PROMOD_MODE"], "knockout_1v1_hc_mr") )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "knockout_1v1_hc_mr", game["PROMOD_MODE"] );
		game["HARDCORE_MODE"] = 1;
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^41v1 Knockout ^1HC ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "knockout_2v2_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode("knockout_2v2_mr",game["PROMOD_MODE"]);
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^42v2 Knockout ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "knockout_2v2_hc_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "knockout_2v2_hc_mr", game["PROMOD_MODE"] );
		game["HARDCORE_MODE"] = 1;
		game["KNOCKOUT_MODE"] = 1;
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^42v2 Knockout ^1HC ^3MR" + game["MR_RATING"];
		game["PROMOD_STRATTIME"] = 10;
	}
	else if ( isSubStr( game["PROMOD_MODE"], "match_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "match_mr", game["PROMOD_MODE"] );
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4Match ^3MR" + game["MR_RATING"];
	}
	else if ( isSubStr( game["PROMOD_MODE"], "match_hc_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "match_hc_mr", game["PROMOD_MODE"] );
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4Match ^1HC ^3MR" + game["MR_RATING"];
	}
	else if ( isSubStr( game["PROMOD_MODE"], "lan_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode("lan_mr",game["PROMOD_MODE"]);
		game["LAN_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4LAN ^3MR" + game["MR_RATING"];
	}
	else if ( isSubStr( game["PROMOD_MODE"], "lan_hc_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "lan_hc_mr", game["PROMOD_MODE"] );
		game["LAN_MODE"] = 1;
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4LAN ^1HC ^3MR" + game["MR_RATING"];
	}
	else if ( isSubStr( game["PROMOD_MODE"], "1v1_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "1v1_mr", game["PROMOD_MODE"] );
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^41v1 ^3MR" + game["MR_RATING"];
	}
	else if (isSubStr(game["PROMOD_MODE"], "1v1_hc_mr"))
	{
		game["MR_RATING"] = Generic_Strip_Mode( "1v1_hc_mr", game["PROMOD_MODE"] );
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^41v1 ^1HC ^3MR" + game["MR_RATING"];
	}
	else if ( isSubStr( game["PROMOD_MODE"], "2v2_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode("2v2_mr",game["PROMOD_MODE"]);
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^42v2 ^3MR" + game["MR_RATING"];
	}
	else if ( isSubStr( game["PROMOD_MODE"], "2v2_hc_mr" ) )
	{
		game["MR_RATING"] = Generic_Strip_Mode( "2v2_hc_mr", game["PROMOD_MODE"] );
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_LIMITED"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^42v2 ^1HC ^3MR" + game["MR_RATING"];
	}
	else if ( game["PROMOD_MODE"] == "match" )
	{
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4Match ^3Standard";
	}
	else if ( game["PROMOD_MODE"] == "match_hc" )
	{
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4Match ^1HC ^3Standard";
	}
	else if ( game["PROMOD_MODE"] == "lan" )
	{
		game["LAN_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4LAN ^3Standard";
	}
	else if ( game["PROMOD_MODE"] == "lan_hc" )
	{
		game["HARDCORE_MODE"] = 1;
		game["LAN_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_match";
		game["PROMOD_MODE_HUD"] = "^4LAN ^1HC ^3Standard";
	}
	else if ( game["PROMOD_MODE"] == "comp_public" )
	{
		game["PROMOD_MODE"] = "comp_public";
		game["PROMOD_MODE_HUD"] = "Competitive Public";
	}
	else if ( game["PROMOD_MODE"] == "comp_public_hc" )
	{
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE"] = "comp_public";
		game["PROMOD_MODE_HUD"] = "Competitive Public ^1HC";
	}
	else if ( game["PROMOD_MODE"] == "custom_public" )
	{
		game["CUSTOM_MODE"] = 1;
		game["PROMOD_MODE"] = "custom_public";
		game["PROMOD_MODE_HUD"] = "Custom Public";
	}
	else if ( game["PROMOD_MODE"] == "strat" )
	{
		game["PROMOD_MODE"] = "strat";
		game["PROMOD_MODE_HUD"] = "^4Strat ^3Mode";
	}

	if ( game["PROMOD_MODE"] == "comp_match" )
	{
		promod\rules\comp::main();
		game["promod_match_mode"] = "match";
	}
	else if ( game["PROMOD_MODE"] == "comp_public" )
	{
		promod\rules\comp::main();
		game["promod_match_mode"] = "pub";
	}
	else if ( game["PROMOD_MODE"] == "custom_public" )
	{
		promod_ruleset\custom_public::main();
		game["promod_match_mode"] = "pub";
	}
	else if ( game["PROMOD_MODE"] == "strat" )
	{
		promod\rules\comp::main();
		game["promod_match_mode"] = "strat";
		level thread promod\nade_training::main();
	}
	else
	{
		iprintln("Shouldn't be here, is " + game["PROMOD_MODE"] + " really a valid mode?");
		wait 2;
		iprintln("Switching to PUB-mode");
		promod\rules\comp::main();
		game["promod_match_mode"] = "pub";
	}

	if ( game["PROMOD_MODE"] == "comp_match" || game["PROMOD_MODE"] == "strat" || game["PROMOD_MODE"] == "comp_public" )
		Standardized_Server_Settings();

	if ( int( game["MR_RATING"] ) > 0 && ( level.gametype == "sd" || level.gametype == "sab" ) )
	{
		setDvar( "scr_" + level.gametype + "_roundswitch", int( game["MR_RATING"] ) );
		setDvar( "scr_" + level.gametype + "_roundlimit", int( game["MR_RATING"] ) * 2 );

		if( game["KNOCKOUT_MODE"] == 1 && level.gametype == "sd" )
			setDvar( "scr_sd_scorelimit", int( game["MR_RATING"] ) + 1 );
	}

	if ( game["PROMOD_LIMITED"] == 1 )
	{
		setDvar("class_demolitions_limit", "0");
		setDvar("class_sniper_limit", "0");
	}

	if ( game["HARDCORE_MODE"] == 1 )
		setDvar("scr_hardcore", "1");

	if ( getDvarInt( "sv_cheats" ) == 1 )
		game["PROMOD_MODE_HUD"] += "^1 CHEATS";

	if ( game["LAN_MODE"] == 1 )
	{
		setDvar("g_antilag", "0");
		setDvar("g_smoothClients", "0");
	}
	else
	{
		setDvar("g_antilag", "1");
		setDvar("g_smoothClients", "1");
	}
}

Generic_Strip_Mode( pretext, mode )
{
	reconstruct = "";

	for (i=pretext.size;i<mode.size;i++)
		reconstruct += mode[i];

	return reconstruct;
}

Standardized_Server_Settings()
{
	setDvar( "class_assault_limit", "64" );
	setDvar( "class_demolitions_limit", "1" );
	setDvar( "class_sniper_limit", "1" );

	setDvar( "class_assault_allowdrop", "1" );
	setDvar( "class_specops_allowdrop", "1" );
	setDvar( "class_demolitions_allowdrop", "0" );
	setDvar( "class_sniper_allowdrop", "0" );

	setDvar( "weap_allow_m16", "1" );
	setDvar( "weap_allow_ak47", "1" );
	setDvar( "weap_allow_m4", "1" );
	setDvar( "weap_allow_g3", "1" );
	setDvar( "weap_allow_g36c", "1" );
	setDvar( "weap_allow_m14", "1" );
	setDvar( "weap_allow_mp44", "1" );

	setDvar( "attach_allow_assault_none", "1" );
	setDvar( "attach_allow_assault_silencer", "1" );

	setDvar( "weap_allow_mp5", "1" );
	setDvar( "weap_allow_uzi", "1" );
	setDvar( "weap_allow_ak74u", "1" );

	setDvar( "attach_allow_smg_none", "1" );
	setDvar( "attach_allow_smg_silencer", "1" );

	setDvar( "weap_allow_m1014", "1" );
	setDvar( "weap_allow_winchester1200", "1" );

	setDvar( "weap_allow_dragunov", "0" );
	setDvar( "weap_allow_m40a3", "1" );
	setDvar( "weap_allow_barrett", "0" );
	setDvar( "weap_allow_remington700", "1" );
	setDvar( "weap_allow_m21", "0" );

	setDvar( "weap_allow_beretta", "1" );
	setDvar( "weap_allow_colt45", "1" );
	setDvar( "weap_allow_usp", "1" );
	setDvar( "weap_allow_deserteagle", "1" );
	setDvar( "weap_allow_deserteaglegold", "1" );

	setDvar( "attach_allow_pistol_none", "1" );
	setDvar( "attach_allow_pistol_silencer", "1" );

	setDvar( "class_assault_primary", "ak47" );
	setDvar( "class_assault_primary_attachment", "none" );
	setDvar( "class_assault_secondary", "deserteagle" );
	setDvar( "class_assault_secondary_attachment", "none" );
	setDvar( "class_assault_camo", "camo_none" );

	setDvar( "class_specops_primary", "ak74u" );
	setDvar( "class_specops_primary_attachment", "none" );
	setDvar( "class_specops_secondary", "deserteagle" );
	setDvar( "class_specops_secondary_attachment", "none" );
	setDvar( "class_specops_camo", "camo_none" );

	setDvar( "class_demolitions_primary", "winchester1200" );
	setDvar( "class_demolitions_primary_attachment", "none" );
	setDvar( "class_demolitions_secondary", "deserteagle" );
	setDvar( "class_demolitions_secondary_attachment", "none" );
	setDvar( "class_demolitions_camo", "camo_none" );

	setDvar( "class_sniper_primary", "m40a3" );
	setDvar( "class_sniper_primary_attachment", "none" );
	setDvar( "class_sniper_secondary", "deserteagle" );
	setDvar( "class_sniper_secondary_attachment", "none" );
	setDvar( "class_sniper_camo", "camo_none" );

	setDvar( "scr_enable_hiticon", "2" );
	setDvar( "scr_enable_scoretext", "1" );

	if ( game["PROMOD_MODE"] == "comp_match" )
	{
		setDvar( "class_specops_limit", "2" );
		setDvar( "weap_allow_flash_grenade", "1" );
		setDvar( "weap_allow_frag_grenade", "1" );
		setDvar( "weap_allow_smoke_grenade", "1" );
		setDvar( "scr_team_fftype", "1" );
		setDvar( "class_assault_grenade", "smoke_grenade" );
		setDvar( "class_specops_grenade", "smoke_grenade" );
		setDvar( "class_demolitions_grenade", "smoke_grenade" );
		setDvar( "class_sniper_grenade", "smoke_grenade" );
		setDvar( "scr_war_roundswitch", "1" );
		setDvar( "scr_war_roundlimit", "2" );
		setDvar( "scr_team_teamkillpointloss", "5" );
	}
	else if ( game["PROMOD_MODE"] == "comp_public" )
	{
		setDvar( "class_specops_limit", "64" );
		setDvar( "weap_allow_flash_grenade", "0" );
		setDvar( "weap_allow_frag_grenade", "0" );
		setDvar( "weap_allow_smoke_grenade", "0" );
		setDvar( "scr_team_fftype", "0" );
		setDvar( "class_assault_grenade", "none" );
		setDvar( "class_specops_grenade", "none" );
		setDvar( "class_demolitions_grenade", "none" );
		setDvar( "class_sniper_grenade", "none" );
		setDvar( "scr_war_roundswitch", "0" );
		setDvar( "scr_war_roundlimit", "1" );
		setDvar( "g_deadChat", "1" );
		setDvar( "scr_team_teamkillpointloss", "0" );
	}
	else
	{
		setDvar( "class_specops_limit", "64" );
		setDvar( "class_demolitions_limit", "64" );
		setDvar( "class_sniper_limit", "64" );
		setDvar( "weap_allow_flash_grenade", "1" );
		setDvar( "weap_allow_frag_grenade", "1" );
		setDvar( "weap_allow_smoke_grenade", "1" );
		setDvar( "scr_team_fftype", "1");
		setDvar( "class_assault_grenade", "smoke_grenade" );
		setDvar( "class_specops_grenade", "smoke_grenade" );
		setDvar( "class_demolitions_grenade", "smoke_grenade" );
		setDvar( "class_sniper_grenade", "smoke_grenade" );
		setDvar( "scr_game_matchstarttime", "0" );
		setDvar( "scr_game_playerwaittime", "0" );
		setDvar( "scr_team_teamkillpointloss", "5" );
	}
}

Monitor_Promod_Mode()
{
	old_promod_mode = toLower( getDvar( "promod_mode" ) );
	old_cheats = getDvar( "sv_cheats" );

	while (1)
	{
		wait 1;

		promod_mode = toLower( getDvar( "promod_mode" ) );
		cheats = getDvar( "sv_cheats" );

		if ( promod_mode != old_promod_mode || cheats != old_cheats )
		{
			old_cheats = cheats;

			if ( Is_Valid_Promod_Mode( promod_mode ) )
			{
				iPrintLN("^5Changing To Mode: ^2" + promod_mode );
				iPrintLN("^5Please Wait While It Loads...");

				wait 1;

				map_restart( false );
				return;
			}
			else
			{
				wait 1;

				iPrintLN("^5Error Changing To Mode: ^1" + promod_mode);
				iPrintLN("^5Valid Modes: knockout/match_mr[x], knockout/match_hc_mr[x], knockout/lan_mr[x], knockout/lan_hc_mr[x],");
				iPrintLN("^5knockout/1v1_mr[x], knockout/1v1_hc_mr[x], knockout/2v2_mr[x], knockout/2v2_hc_mr[x], match, match_hc,");
				iPrintLN("^5lan, lan_hc, comp_public, comp_public_hc, custom_public, strat");

				setDvar("promod_mode", old_promod_mode);
			}
		}
	}
}

Is_Valid_Promod_Mode( mode )
{
	if ( mode == "match" || mode == "match_hc" || mode == "lan" || mode == "lan_hc" || mode == "comp_public" || mode == "comp_public_hc" || mode == "custom_public" || mode == "strat" )
		return true;

	if ( !isSubStr( mode, "1" ) && !isSubStr( mode, "2" ) && !isSubStr( mode, "3" ) && !isSubStr( mode, "4" ) && !isSubStr( mode, "5" ) && !isSubStr( mode, "6" ) && !isSubStr( mode, "7" ) && !isSubStr( mode, "8" ) && !isSubStr( mode, "9" ) )
		return false;

	if ( isSubStr( mode, "match_mr" ) || isSubStr( mode, "match_hc_mr" ) || isSubStr( mode, "lan_mr" ) || isSubStr( mode, "lan_hc_mr" ) || isSubStr( mode, "1v1_mr" ) || isSubStr( mode, "1v1_hc_mr" ) || isSubStr( mode, "2v2_mr" ) || isSubStr( mode, "2v2_hc_mr" ) || isSubStr( mode, "knockout_mr" ) || isSubStr( mode, "knockout_hc_mr" ) || isSubStr( mode, "knockout_lan_mr" ) || isSubStr( mode, "knockout_lan_hc_mr" ) || isSubStr( mode, "knockout_1v1_mr" ) || isSubStr( mode, "knockout_1v1_hc_mr" ) || isSubStr( mode, "knockout_2v2_mr" ) || isSubStr( mode, "knockout_2v2_hc_mr" ) )
		return true;
	else
		return false;
}