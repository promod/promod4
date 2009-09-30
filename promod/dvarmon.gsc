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

	dvars = strTok( "scr_team_fftype|bg_falldamageminheight|scr_enable_hiticon|class_assault_allowdrop|class_assault_limit|class_demolitions_allowdrop|class_demolitions_limit|class_sniper_allowdrop|class_sniper_limit|class_specops_limit|class_specops_allowdrop|scr_game_allowkillcam|scr_drawfriend|scr_game_spectatetype|scr_" + level.gametype + "_timelimit|scr_" + level.gametype + "_numlives|scr_" + level.gametype + "_playerrespawndelay|scr_hardcore|scr_" + level.gametype + "_roundswitch|scr_sd_multibomb|scr_sab_hotpotato|scr_" + level.gametype + "_bombtimer|scr_" + level.gametype + "_defusetime|scr_" + level.gametype + "_planttime|koth_autodestroytime|koth_delayplayer|koth_destroytime|koth_spawnDelay|koth_spawntime", "|" );

	current_values = [];
	for ( d = 0; d < dvars.size; d++ )
		current_values[d] = getDvar(dvars[d]);

	for (;;)
	{
		wait 1;
		for ( c = 0; c < dvars.size; c++ )
		{
			if ( getDvar(dvars[c]) != current_values[c] )
			{
				iPrintLn("^1Warning: ^3DVAR Change Detected: ^1" + dvars[c] + " ^3--> ^1" + getDvar(dvars[c]));
				current_values[c] = getDvar(dvars[c]);
			}
		}
	}
}