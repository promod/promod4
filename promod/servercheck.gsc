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
	wait .05;

	while( 1 )
	{
		if ( getDvarInt( "sv_cheats" ) == 1 )
			break;

		cacheIWDname = toLower( getDvar( "sv_iwdnames" ) );
		cacheIWDsum = getDvar( "sv_iwds" );

		if ( getDvarInt( "sv_fps" ) != 20 )
			iPrintLNBold("^1Server Violation ^3#0100^7: Illegal Server FPS");

		if ( getDvarInt( "sv_maxrate" ) != 25000 )
			iPrintLNBold("^1Server Violation ^3#0101^7: Illegal Server Maxrate");

		if ( getDvarInt( "sv_punkbuster" ) != 1 && game["LAN_MODE"] != 1 )
			iPrintLNBold("^1Server Violation ^3#0102^7: Punkbuster Disabled");

		if ( getDvarInt( "scr_player_maxhealth" ) != 100 && game["HARDCORE_MODE"] != 1 && game["CUSTOM_MODE"] != 1 || getDvarInt( "scr_player_maxhealth" ) != 30 && game["HARDCORE_MODE"] == 1 && game["CUSTOM_MODE"] != 1 )
			iPrintLNBold("^1Server Violation ^3#0103^7: Modified Player");

		if ( getDvarInt( "g_speed" ) != 0 && getDvarInt( "g_speed" ) != 190 || getDvarInt( "g_gravity" ) != 800 )
			iPrintLNBold("^1Server Violation ^3#0104^7: Modified Environment");

		if ( getDvarInt( "sv_disableClientConsole" ) != 0 )
			iPrintLNBold("^1Server Violation ^3#0105^7: Modified Client");

		if ( getDvarInt( "g_antilag" ) != 1 && game["LAN_MODE"] != 1 )
			iPrintLNBold("^1Server Violation ^3#0106^7: Modified Connection");

		if ( getDvarInt( "sv_pure" ) != 1 )
			iPrintLNBold("^1Server Violation ^3#0107^7: Impure Server");

		if ( getDvar( "fs_game" ) != ( "mods/promodlive2" ) && game["CUSTOM_MODE"] != 0 )
		{
			if ( getDvar( "fs_game" ) != ( "mods/promodlive2_custom" ) )
				iPrintLNBold("^1Server Violation ^3#0108^7: Bad Server Path (fs_game)");
		}
		else
		{
			if ( getDvar( "fs_game" ) != ( "mods/promodlive2" ) )
				iPrintLNBold("^1Server Violation ^3#0108^7: Bad Server Path (fs_game)");

			if ( isSubStr( cacheIWDname, "svr" ) )
				iPrintLNBold("^1Server Violation ^3#0109^7: No Additional IWD Files Allowed");

			if ( !isSubStr( cacheIWDsum, "1488399193" ) )
				iPrintLNBold("^1Server Violation ^3#0200^7: Promod IWD Checksum Failed");
		}

		wait 3;
	}
}