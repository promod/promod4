/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	level endon ( "restarting" );

	level thread dvarHistory();

	level.dvarmon = [];

	dvars = strTok( "class_assault_allowdrop|class_assault_limit|class_assault_primary|class_demolitions_allowdrop|class_demolitions_limit|class_demolitions_primary|class_sniper_allowdrop|class_sniper_limit|class_sniper_primary|class_specops_allowdrop|class_specops_limit|class_specops_primary|scr_game_allowkillcam|scr_game_spectatetype|scr_" + level.gametype + "_timelimit|scr_" + level.gametype + "_numlives|scr_" + level.gametype + "_playerrespawndelay|scr_" + level.gametype + "_roundswitch|scr_" + level.gametype + "_bombtimer|scr_" + level.gametype + "_defusetime|scr_" + level.gametype + "_planttime|scr_hardcore|scr_sd_multibomb|scr_sab_hotpotato|scr_team_fftype|scr_enable_hiticon|koth_autodestroytime|koth_delayplayer|koth_destroytime|koth_spawnDelay|koth_spawntime", "|" );

	current_values = [];
	for( d = 0; d < dvars.size; d++ )
		current_values[d] = getDvar(dvars[d]);

	for(;;wait 0.05)
		for ( c = 0; c < dvars.size; c++ )
			if ( getDvar(dvars[c]) != current_values[c] )
			{
				level.dvarmon[level.dvarmon.size] = "^1" + dvars[c] + " ^3" + current_values[c] + " ^1--> ^3" + getDvar(dvars[c]);
				iprintln("^1Warning: ^3DVAR Change Detected: ^1" + dvars[c] + " ^3" + current_values[c] + " ^1--> ^3" + getDvar(dvars[c]));
				current_values[c] = getDvar(dvars[c]);

				if ( isSubStr( dvars[c], "_limit" ) )
				{
					thread maps\mp\gametypes\_promod::updateClassAvailability( "allies" );
					thread maps\mp\gametypes\_promod::updateClassAvailability( "axis" );
				}
			}
}

dvarHistory()
{
	level endon ( "restarting" );

	wait 0.1;

	if ( isDefined( level.rdyup ) && level.rdyup )
	{
		for(;!isDefined( game["state"] ) || game["state"] != "postgame";wait 0.5){}
		if ( level.dvarmon.size )
		{
			iprintln("^3DVAR Change History:");

			for ( i = 0; i < level.dvarmon.size; i++ )
				iprintln(level.dvarmon[i]);
		}
	}
}