/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	violationSystem();
}

violationSystem()
{
	for(;;)
	{
		if ( getDvarInt( "sv_cheats" ) )
			break;

		if ( getDvarInt( "sv_disableClientConsole" ) != 0 )
			setDvar( "sv_disableClientConsole", 0 );

		if ( getDvarInt( "sv_fps" ) != 20 )
			setDvar( "sv_fps", 20 );

		if ( getDvarInt( "sv_pure" ) != 1 )
			setDvar( "sv_pure", 1 );

		if ( getDvarInt( "sv_maxrate" ) != 25000 )
			setDvar( "sv_maxrate", 25000 );

		if ( getDvarInt( "g_gravity" ) != 800 )
			setDvar( "g_gravity", 800 );

		if ( getDvarInt( "g_knockback" ) != 1000 )
			setDvar( "g_knockback", 1000 );

		if ( getDvar( "authServerName" ) != "cod4master.activision.com" )
			setDvar( "authServerName", "cod4master.activision.com" );

		if ( getDvarInt( "sv_punkbuster" ) != 1 && game["LAN_MODE"] != 1 )
			iPrintLNBold("^1Server Violation ^3#0100^7: Punkbuster Disabled");

		if ( getDvarInt( "scr_player_maxhealth" ) != 100 && game["HARDCORE_MODE"] != 1 && game["CUSTOM_MODE"] != 1 || getDvarInt( "scr_player_maxhealth" ) != 30 && game["HARDCORE_MODE"] == 1 && game["CUSTOM_MODE"] != 1 )
			iPrintLNBold("^1Server Violation ^3#0101^7: Modified Player");

		if ( getDvarInt( "g_speed" ) != 0 && getDvarInt( "g_speed" ) != 190 )
			iPrintLNBold("^1Server Violation ^3#0102^7: Modified Environment");

		if ( getDvarInt( "g_antilag" ) != 1 && getDvarInt( "dedicated" ) != 1 )
			iPrintLNBold("^1Server Violation ^3#0103^7: Modified Connection");

		if ( !isSubStr( getDvar( "fs_game" ), "_custom" ) || !game["CUSTOM_MODE"] )
		{
			badIWDnames = 0;
			badIWDsums = 0;

			cacheIWDnames = StrTok( getDvar( "sv_iwdnames" ), " " );
			cacheIWDsums = StrTok( getDvar( "sv_iwds" ), " " );

			for ( i = 0; i < cacheIWDnames.size; i++ )
			{
				a = cacheIWDnames[i];

				if ( a != "iw_00" && a != "iw_01" && a != "iw_02" && a != "iw_03" && a != "iw_04" && a != "iw_05" && a != "iw_06" && a != "iw_07" && a != "iw_08" && a != "iw_09" && a != "iw_10" && a != "iw_11" && a != "iw_12" && a != "iw_13" && a != "promodlive205" && a != "z_custom_ruleset" )
					badIWDnames = 1;

				if ( a == "promodlive205" && cacheIWDsums[i] != "-740633290" )
					badIWDsums = 1;
			}

			if ( badIWDnames )
				iPrintLNBold("^1Server Violation ^3#0104^7: Additional IWD Files Detected");

			if ( badIWDsums )
				iPrintLNBold("^1Server Violation ^3#0105^7: Bad Promod IWD Checksum");
		}

		wait 3;
	}
}