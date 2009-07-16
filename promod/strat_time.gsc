/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\gametypes\_hud_util;

main()
{
	if ( game["promod_timeout_called"] )
	{
		thread promod\timeout::main();
		return;
	}

	setDvar( "g_speed", 0 );

	level thread Strat_Time();
	level thread Strat_Time_Timer();

	level waittill( "strat_over" );
	setDvar( "g_speed", 190 );
	wait .1;

	players = getentarray("player", "classname");
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		classType = player.pers["class"];

		if ( ( player.pers["team"] == "allies" || player.pers["team"] == "axis" ) && player.sessionstate == "playing" )
		{
			if ( level.hardcoreMode )
				player giveWeapon( "frag_grenade_short_mp" );
			else
				player giveWeapon( "frag_grenade_mp" );

			player giveWeapon( player.pers[classType]["loadout_grenade"] + "_mp" );
			player shellShock( "damage_mp", 0.01 );
			player allowsprint(true);
		}
	}

	setDvar( "player_sustainAmmo", 0 );

	if ( game["promod_timeout_called"] )
	{
		thread promod\timeout::main();
		return;
	}
}

Strat_Time()
{
	level.strat_over = false;
	level.strat_time_left = game["PROMOD_STRATTIME"];
	time_increment = .25;

	setDvar( "player_sustainAmmo", 1 );

	while ( !level.strat_over )
	{
		wait time_increment;

		level.strat_time_left -= time_increment;

		players = getentarray("player", "classname");
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( player.pers["team"] == "allies" || player.pers["team"] == "axis" )
				player allowsprint(false);
		}

		if ( level.strat_time_left <= 0 )
		{
			level notify( "kill_strat_timer" );
			level.strat_over = true;
		}

		if ( game["promod_timeout_called"] )
		{
			level notify( "kill_strat_timer" );
			level.strat_over = true;
		}
	}

	level notify( "strat_over" );
}

Strat_Time_Timer()
{
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	matchStartText.sort = 1001;
	matchStartText setText( "Strat Time" );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = false;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer setTimer( game["PROMOD_STRATTIME"] );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = false;

	level waittill( "kill_strat_timer" );

	if ( isDefined( matchStartText ) )
		matchStartText destroy();

	if ( isDefined( matchStartTimer ) )
		matchStartTimer destroy();
}