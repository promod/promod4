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
		setDvar( "promod_mode", "comp_public" );
		mode = toLower( getDvar( "promod_mode" ) );
	}

	explodeMode( mode );
}

explodeMode( mode )
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

	if ( mode == "comp_public" )
	{
		promod\comp::main();
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_MODE_HUD"] = "^4Competitive ^3Public";
		unified();
	}
	if ( mode == "comp_public_hc" )
	{
		promod\comp::main();
		game["PROMOD_MATCH_MODE"] = "pub";
		game["HARDCORE_MODE"] = 1;
		game["PROMOD_MODE_HUD"] = "^4Competitive ^3Public";
		unified();
	}
	else if ( mode == "custom_public" )
	{
		promod_ruleset\custom_public::main();
		game["CUSTOM_MODE"] = 1;
		game["PROMOD_MATCH_MODE"] = "pub";
		game["PROMOD_MODE_HUD"] = "^4Custom ^3Public";
	}
	else if ( mode == "strat" )
	{
		promod\comp::main();
		level thread promod\stratmode::main();
		game["PROMOD_MODE_HUD"] = "^4Strat ^3Mode";
		game["PROMOD_MATCH_MODE"] = "strat";
		unified();
	}

	if ( game["PROMOD_MATCH_MODE"] == "" )
	{
		exploded = StrTok( mode, "_" );
		for ( i = 0; i < exploded.size; i++ )
		{
			exp = exploded[i];

			if ( exp == "match" || exp == "knockout" )
			{
				game["PROMOD_MATCH_MODE"] = "match";

				if ( exp == "knockout" )
				{
					knockout_mode = 1;
					game["PROMOD_STRATTIME"] = 10;
					game["PROMOD_MODE_HUD"] += "^4Knockout";
				}
				else
					game["PROMOD_MODE_HUD"] += "^4Match";
			}
			else if ( exp == "lan" )
			{
				game["LAN_MODE"] = 1;
				game["PROMOD_MODE_HUD"] += " ^4LAN";
			}
			else if ( exp == "1v1" || exp == "2v2" )
			{
				limited_mode = 1;

				if ( exp == "1v1" )
					game["PROMOD_MODE_HUD"] += " ^21V1";
				else
					game["PROMOD_MODE_HUD"] += " ^22V2";
			}
			else if ( exp == "hc" )
			{
				game["HARDCORE_MODE"] = 1;
				game["PROMOD_MODE_HUD"] += " ^6HC";
			}
			else if ( isSubStr( exp, "mr" ) )
				mr_rating = mrrating( "mr", exp );
		}
	}

	if ( game["PROMOD_MATCH_MODE"] == "match" )
	{
		promod\comp::main();
		unified();
	}

	if ( game["LAN_MODE"] )
	{
		setDvar( "g_antilag", 0 );
		setDvar( "g_smoothClients", 0 );
	}

	if ( game["HARDCORE_MODE"] )
		setDvar( "scr_hardcore", 1 );

	if ( limited_mode )
	{
		setDvar( "class_demolitions_limit", 0 );
		setDvar( "class_sniper_limit", 0 );
	}

	if ( int( mr_rating ) > 0 && ( level.gametype == "sd" || level.gametype == "sab" ) )
	{
		game["PROMOD_MODE_HUD"] += " " + "^3MR" + int( mr_rating );

		setDvar( "scr_" + level.gametype + "_roundswitch", int( mr_rating ) );
		setDvar( "scr_" + level.gametype + "_roundlimit", int( mr_rating ) * 2 );

		if ( knockout_mode && level.gametype == "sd" )
			setDvar( "scr_sd_scorelimit", int( mr_rating ) + 1 );
	}
	else if ( game["PROMOD_MATCH_MODE"] == "match" )
		game["PROMOD_MODE_HUD"] += " ^3Standard";

	if ( getDvarInt( "sv_cheats" ) )
		game["PROMOD_MODE_HUD"] += " ^1CHEATS";
}

mrrating( pretext, mode )
{
	rating = "";
	for ( i = pretext.size; i < mode.size; i++ )
		rating += mode[i];

	return rating;
}

unified()
{
	if ( game["PROMOD_MATCH_MODE"] == "match" )
	{
		setDvar( "scr_war_roundswitch", 1 );
		setDvar( "scr_war_roundlimit", 2 );
		setDvar( "class_specops_limit", 2 );
	}
	else if ( game["PROMOD_MATCH_MODE"] == "pub" )
	{
		setDvar( "scr_team_fftype", 0 );
		setDvar( "scr_team_teamkillpointloss", 0 );
		setDvar( "scr_war_roundswitch", 0 );
		setDvar( "scr_war_roundlimit", 1 );
		setDvar( "weap_allow_flash_grenade", 0 );
		setDvar( "weap_allow_frag_grenade", 0 );
		setDvar( "weap_allow_smoke_grenade", 0 );
		setDvar( "class_assault_grenade", "none" );
		setDvar( "class_specops_grenade", "none" );
		setDvar( "class_demolitions_grenade", "none" );
		setDvar( "class_sniper_grenade", "none" );
	}
	else
	{
		setDvar( "class_demolitions_limit", 64 );
		setDvar( "class_sniper_limit", 64 );
	}
}

monitorMode()
{
	o_mode = toLower( getDvar( "promod_mode" ) );
	o_cheats = getDvarInt( "sv_cheats" );

	while ( 1 )
	{
		mode = toLower( getDvar( "promod_mode" ) );
		cheats = getDvarInt( "sv_cheats" );

		if ( mode != o_mode || cheats != o_cheats )
		{
			if ( isDefined( game["state"] ) && game["state"] == "postgame" )
			{
				setDvar( "promod_mode", o_mode );
				continue;
			}

			if ( validMode( mode ) )
			{
				level notify ( "restarting" );

				iPrintLN( "Changing To Mode:  ^1" + level.mode );
				iPrintLN( "Please Wait While It Loads..." );

				explodeMode( level.mode );

				wait 2;

				map_restart( false );
				return;
			}
			else
			{
				if ( isDefined( mode ) && mode != "" )
				{
					iPrintLN( "Error Changing To Mode:  " + "''" + "^1" + mode + "^7''" );
					iPrintLN( "Valid Modes:" );
					iPrintLN( "^7match( ^1_^7lan^1_^7xvx^1_^7hc^1_^7mrx )^1,  ^7knockout( ^1_^7lan^1_^7xvx^1_^7hc )^1_^7mrx^1," );
					iPrintLN( "^7comp^1_^7public^1,  ^7comp^1_^7public_hc^1,  ^7custom^1_^7public^1,  ^7strat" );
				}

				setDvar( "promod_mode", o_mode );
			}
		}

		wait 0.5;
	}
}

validMode( mode )
{
	if ( !isDefined( mode ) || mode == "" )
		return false;

	level.mode = mode;

	if (
		mode == "comp_public" ||
		mode == "comp_public_hc" ||
		mode == "custom_public" ||
		mode == "strat" )
		return true;

	mr_mode = "";
	mr_rating = "";

	exploded = StrTok( mode, "_" );
	for ( i = 0; i < exploded.size; i++ )
	{
 		exp = exploded[i];

		if ( !isSubStr( exp, "mr" ) )
			mr_mode += exp + "_";
		else
			mr_rating = exp;
	}

	if (
		mr_mode == "match_" ||
		mr_mode == "match_hc_" ||
		mr_mode == "match_1v1_" ||
		mr_mode == "match_1v1_hc_" ||
		mr_mode == "match_2v2_" ||
		mr_mode == "match_2v2_hc_" ||
		mr_mode == "match_lan_" ||
		mr_mode == "match_lan_hc_" ||
		mr_mode == "match_lan_1v1_" ||
		mr_mode == "match_lan_1v1_hc_" ||
		mr_mode == "match_lan_2v2_" ||
		mr_mode == "match_lan_2v2_hc_" ||
		mr_mode == "knockout_" ||
		mr_mode == "knockout_hc_" ||
		mr_mode == "knockout_1v1_" ||
		mr_mode == "knockout_1v1_hc_" ||
		mr_mode == "knockout_2v2_" ||
		mr_mode == "knockout_2v2_hc_" ||
		mr_mode == "knockout_lan_" ||
		mr_mode == "knockout_lan_hc_" ||
		mr_mode == "knockout_lan_1v1_" ||
		mr_mode == "knockout_lan_1v1_hc_" ||
		mr_mode == "knockout_lan_2v2_" ||
		mr_mode == "knockout_lan_2v2_hc_" )
		if ( isSubStr( mr_mode, "match" ) && !isSubStr( mr_rating, "mr" ) )
			return true;
		else if (
				isSubStr( mr_rating, "mr1" ) ||
				isSubStr( mr_rating, "mr2" ) ||
				isSubStr( mr_rating, "mr3" ) ||
				isSubStr( mr_rating, "mr4" ) ||
				isSubStr( mr_rating, "mr5" ) ||
				isSubStr( mr_rating, "mr6" ) ||
				isSubStr( mr_rating, "mr7" ) ||
				isSubStr( mr_rating, "mr8" ) ||
				isSubStr( mr_rating, "mr9" ) )
				{
					result = StrTok( mr_rating, "mr" )[0];

					if ( ( !int( result ) ) )
						return false;

					level.mode = mr_mode + "mr" + int( result );
					setDvar( "promod_mode", level.mode );
					return true;
				}

	return false;
}