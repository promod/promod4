/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	mode = toLower( getDvar( "promod_mode" ) );
	if ( !validMode( mode ) )
	{
		mode = "comp_public";
		setDvar( "promod_mode", mode );
	}

	setMode(mode);
}

validMode( mode )
{
	switch ( mode )
	{
		case "comp_public":
		case "comp_public_hc":
		case "custom_public":
		case "comp_public_lan":
		case "comp_public_hc_lan":
		case "custom_public_lan":
		case "strat":
		case "match":
		case "knockout":
			return true;
	}

	keys = strtok(mode, "_");
	if(keys.size <= 1) return false;
	switches = [];
	switches["match_knockout"] = false;
	switches["1v1_2v2"] = false;
	switches["lan_pb"] = false;
	switches["hc_done"] = false;
	switches["knife_done"] = false;
	switches["mr_done"] = false;
	switches["scores_done"] = false;

	for(i=0;i<keys.size;i++)
	{
		switch(keys[i])
		{
			case "match":
			case "knockout":
				if(switches["match_knockout"]) return false;
				switches["match_knockout"] = true;
				break;
			case "1v1":
			case "2v2":
				if(switches["1v1_2v2"]) return false;
				switches["1v1_2v2"] = true;
				break;
			case "lan":
			case "pb":
				if(switches["lan_pb"]) return false;
				switches["lan_pb"] = true;
				break;
			case "knife":
				if(switches["scores_done"]) return false;
			case "hc":
				if(switches[keys[i]+"_done"]) return false;
				switches[keys[i]+"_done"] = true;
				break;
			default:
				if(keys[i] != "mr" && isSubStr(keys[i],"mr") && "mr"+int(strtok(keys[i], "mr")[0]) == keys[i] && int(strtok(keys[i], "mr")[0]) > 0 && !switches["mr_done"])
					switches["mr_done"] = true;
				else if ( ( isSubStr( keys[i], ":" ) ) && strtok( keys[i], ":" ).size == 2 && int(strtok( keys[i], ":" )[0]) >= 0 && int(strtok( keys[i], ":" )[1]) >= 0 && !switches["scores_done"] && !switches["knife_done"] )
					switches["scores_done"] = true;
				else
					return false;
				break;
		}
	}
	return switches["match_knockout"];
}

monitorMode()
{
	o_mode = toLower( getDvar( "promod_mode" ) );
	o_cheats = getDvarInt( "sv_cheats" );

	for(;;)
	{
		mode = toLower( getDvar( "promod_mode" ) );
		cheats = getDvarInt( "sv_cheats" );

		if ( mode != o_mode )
		{
			if ( isDefined( game["state"] ) && game["state"] == "postgame" )
			{
				setDvar( "promod_mode", o_mode );
				continue;
			}

			if ( validMode( mode ) )
			{
				level notify ( "restarting" );

				iPrintLN( "Changing To Mode: ^1" + mode + "\nPlease Wait While It Loads..." );
				setMode( mode );

				wait 2;

				map_restart( false );
				setDvar( "promod_mode", mode );
			}
			else
			{
				if ( isDefined( mode ) && mode != "" )
					iPrintLN( "Error Changing To Mode: ^1" + mode + "\nSyntax: match|knockout_lan|pb_hc_knife_1v1|2v2_mr#_#:#,\nNormal Modes: comp_public(_lan), comp_public_hc(_lan), custom_public(_lan), strat" );

				setDvar( "promod_mode", o_mode );
			}
		}
		else if ( cheats != o_cheats )
		{
			map_restart( false );
			break;
		}

		wait 0.1;
	}
}

setMode( mode )
{
	limited_mode = 0;
	knockout_mode = 0;
	mr_rating = 0;

	game["CUSTOM_MODE"] = 0;
	game["LAN_MODE"] = 0;
	game["HARDCORE_MODE"] = 0;
	game["PROMOD_STRATTIME"] = 6;
	game["PROMOD_MODE_HUD"] = "";
	game["PROMOD_MATCH_MODE"] = "";
	game["PROMOD_PB_OFF"] = 0;
	game["PROMOD_KNIFEROUND"] = 0;
	game["SCORES_ATTACK"] = 0;
	game["SCORES_DEFENCE"] = 0;

	if ( mode == "comp_public" )
	{
		promod\comp::main();
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_MODE_HUD"] = "^4Competitive ^3Public";
		pub();
	}
	else if ( mode == "comp_public_hc" )
	{
		promod\comp::main();
		game["PROMOD_MATCH_MODE"] = "pub";
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE_HUD"] = "^4Competitive ^3Public ^6HC";
		pub();
	}
	else if ( mode == "custom_public" )
	{
		promod_ruleset\custom_public::main();
		game["CUSTOM_MODE"] = 1;
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_MODE_HUD"] = "^4Custom ^3Public";
		game["PROMOD_KNIFEROUND"] = getDvarInt("promod_kniferound");
	}
	else if ( mode == "comp_public_lan" )
	{
		promod\comp::main();
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_MODE_HUD"] = "^4Competitive ^3Public";
		game["LAN_MODE"] = 1;
		pub();
	}
	else if ( mode == "comp_public_hc_lan" )
	{
		promod\comp::main();
		game["PROMOD_MATCH_MODE"] = "pub";
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE_HUD"] = "^4Competitive ^3Public ^6HC";
		game["LAN_MODE"] = 1;
		pub();
	}
	else if ( mode == "custom_public_lan" )
	{
		promod_ruleset\custom_public::main();
		game["CUSTOM_MODE"] = 1;
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_MODE_HUD"] = "^4Custom ^3Public";
		game["PROMOD_KNIFEROUND"] = getDvarInt("promod_kniferound");
		game["LAN_MODE"] = 1;
	}
	else if ( mode == "strat" )
	{
		promod\comp::main();
		game["PROMOD_MODE_HUD"] = "^4Strat ^3Mode";
		game["PROMOD_MATCH_MODE"] = "strat";
		setDvar( "class_specops_limit", 64 );
		setDvar( "class_demolitions_limit", 64 );
		setDvar( "class_sniper_limit", 64 );
	}

	if ( game["PROMOD_MATCH_MODE"] == "" )
	{
		exploded = StrTok( mode, "_" );
		for ( i = 0; i < exploded.size; i++ )
		{
			switch(exploded[i])
			{
				case "match":
					game["PROMOD_MATCH_MODE"] = "match";
					break;
				case "knockout":
					knockout_mode = 1;
					game["PROMOD_MATCH_MODE"] = "match";
					break;
				case "lan":
					game["LAN_MODE"] = 1;
					break;
				case "1v1":
				case "2v2":
					limited_mode = int(strtok(exploded[i],"v")[0]);
					break;
				case "knife":
					game["PROMOD_KNIFEROUND"] = 1;
					break;
				case "pb":
					game["PROMOD_PB_OFF"] = 1;
					break;
				case "hc":
					game["HARDCORE_MODE"] = 1;
					break;
				default:
					if ( isSubStr( exploded[i], "mr" ) )
						mr_rating = int(strtok(exploded[i], "mr")[0]);
					else if ( isSubStr( exploded[i], ":" ) )
					{
						game["SCORES_ATTACK"] = int(strtok( exploded[i], ":" )[0]);
						game["SCORES_DEFENCE"] = int(strtok( exploded[i], ":" )[1]);
					}
					break;
			}
		}
	}

	if ( game["PROMOD_MATCH_MODE"] == "match" )
		promod\comp::main();

	if ( knockout_mode && !mr_rating )
		mr_rating = 10;

	if ( limited_mode )
	{
		setDvar( "class_demolitions_limit", 0 );
		setDvar( "class_sniper_limit", 0 );
		game["PROMOD_MODE_HUD"] += "^2"+limited_mode+"V"+limited_mode+" ";
	}

	if( knockout_mode )
		game["PROMOD_MODE_HUD"] += "^4Knockout";
	else if ( game["PROMOD_MATCH_MODE"] == "match" )
		game["PROMOD_MODE_HUD"] += "^4Match";

	if ( game["PROMOD_KNIFEROUND"] && game["PROMOD_MATCH_MODE"] == "match" && level.gametype == "sd" )
		game["PROMOD_MODE_HUD"] += " ^5Knife";

	if ( game["LAN_MODE"] )
	{
		setDvar( "g_antilag", 0 );
		setDvar( "g_smoothClients", 0 );
		game["PROMOD_MODE_HUD"] += " ^4LAN";
		if( knockout_mode )
			game["PROMOD_STRATTIME"] = 10;
	}

	if ( game["HARDCORE_MODE"] )
	{
		if(game["PROMOD_MATCH_MODE"] == "match")
			game["PROMOD_MODE_HUD"] += " ^6HC";
		setDvar( "scr_hardcore", 1 );
	}

	maxscore = 0;
	if ( mr_rating > 0 && ( level.gametype == "sd" || level.gametype == "sab" ) )
	{
		maxscore = mr_rating * ( 2 - 1 * knockout_mode ) + ( - 1 * !knockout_mode );

		game["PROMOD_MODE_HUD"] += " " + "^3MR" + mr_rating;

		setDvar( "scr_" + level.gametype + "_roundswitch", mr_rating );
		setDvar( "scr_" + level.gametype + "_roundlimit", mr_rating * 2 );

		if ( knockout_mode && level.gametype == "sd" )
			setDvar( "scr_sd_scorelimit", mr_rating + 1 );
	}
	else if ( game["PROMOD_MATCH_MODE"] == "match" )
	{
		game["PROMOD_MODE_HUD"] += " ^3Standard";
		mr_rating = 10;
		maxscore = mr_rating * ( 2 - 1 * knockout_mode ) + ( - 1 * !knockout_mode );
	}

	if ( level.gametype != "sd" || !knockout_mode && game["SCORES_ATTACK"] + game["SCORES_DEFENCE"] > maxscore || knockout_mode && ( ( game["SCORES_ATTACK"] > maxscore || game["SCORES_DEFENCE"] > maxscore ) || ( game["SCORES_ATTACK"] + game["SCORES_DEFENCE"] >= int( mr_rating ) * 2 ) ) )
	{
		game["SCORES_ATTACK"] = 0;
		game["SCORES_DEFENCE"] = 0;
	}

	if( game["PROMOD_PB_OFF"] && getDvarInt( "sv_cheats" ) && !getDvarInt( "sv_punkbuster" ) )
		game["PROMOD_MODE_HUD"] += " ^1PB: OFF & CHEATS";
	else if( game["PROMOD_PB_OFF"] && !getDvarInt( "sv_punkbuster" ) )
		game["PROMOD_MODE_HUD"] += " ^1PB: OFF";
	else if ( getDvarInt( "sv_cheats" ) )
		game["PROMOD_MODE_HUD"] += " ^1CHEATS";

	if(level.gametype != "sd") game["PROMOD_KNIFEROUND"] = 0;
}

pub()
{
	setDvar( "scr_team_fftype", 0 );
	setDvar( "scr_team_teamkillpointloss", 0 );
	setDvar( "scr_war_roundswitch", 0 );
	setDvar( "scr_war_roundlimit", 1 );
	setDvar( "weap_allow_flash_grenade", 0 );
	setDvar( "weap_allow_frag_grenade", 0 );
	setDvar( "weap_allow_smoke_grenade", 0 );
	setDvar( "class_specops_limit", 64 );
	setDvar( "class_assault_grenade", "none" );
	setDvar( "class_specops_grenade", "none" );
	setDvar( "class_demolitions_grenade", "none" );
	setDvar( "class_sniper_grenade", "none" );
}