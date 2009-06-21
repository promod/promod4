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
	setClientNameMode( "auto_change" );

	level thread Strat_Time();
	level thread Strat_Time_Timer();

	level waittill( "strat_over" );
	level notify( "kill_bypass_hud" );

	setDvar( "g_speed", 190 );
	setClientNameMode( "manual_change" );

	wait .1;

	players = getentarray("player", "classname");
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		classType = player.pers["class"];

		if ( player.pers["team"] == "allies" || player.pers["team"] == "axis" )
		{
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
	level.strat_bypass = false;
	level.allies_bypassed = 0;
	level.axis_bypassed = 0;
	level.strat_bypass_active = true;

	thread Check_Player_Bypass();

	level.strat_time_left = 10;
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
	}

	level notify( "strat_over" );

	game["promod_allies_bypassed_by"] = 0;
	game["promod_axis_bypassed_by"] = 0;
}

Strat_Time_Timer()
{
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -80 );
	matchStartText.sort = 1001;
	matchStartText setText( "Strat Time" );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = false;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartTimer setTimer( 10 );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = false;

	level waittill( "kill_strat_timer" );

	if ( isDefined( matchStartText ) )
		matchStartText destroy();

	if ( isDefined( matchStartTimer ) )
		matchStartTimer destroy();
}

Check_Player_Bypass()
{
	while ( level.strat_bypass_active )
	{
		wait .25;

		if ( level.strat_time_left < 2 )
		{
			level notify("kill_bypass_hud");
			level.strat_bypass_active = false;
		}

		bypass = false;

		alliesNum = 0;
		axisNum = 0;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if ( player.pers["team"] == "allies" || player.pers["team"] == "axis" )
			{
				if ( player.pers["team"] == "allies" )
				{
					alliesNum++;

					if ( !isDefined( player.strat_init ) )
					{
						player.strat_init = true;
						player thread bypass_hud();
					}
				}
				else
				{
					axisNum++;

					if ( !isDefined( player.strat_init ) )
					{
						player.strat_init = true;
						player thread bypass_hud();
					}
				}
			}
		}

		wait .05;

		if ( !alliesNum )
			level.allies_bypassed = 1;

		if ( !axisNum )
			level.axis_bypassed = 1;

		if ( level.allies_bypassed && level.axis_bypassed )
			bypass = true;

		if ( bypass )
		{
			level notify( "kill_strat_timer" );
			level.strat_bypass_active = false;
			wait .05;
			Strat_Hud_Bypassed();
		}
	}
}

Strat_Hud_Bypassed()
{
	matchStartText2 = createServerFontString( "objective", 1.5 );
	matchStartText2 setPoint( "CENTER", "CENTER", 0, -100 );
	matchStartText2.sort = 1001;
	matchStartText2 setText( "Strat Time Bypassed" );
	matchStartText2.foreground = false;
	matchStartText2.hidewheninmenu = false;

	matchStartText3 = createServerFontString( "objective", 1.5 );
	matchStartText3 setPoint( "CENTER", "CENTER", 0, -80 );
	matchStartText3.sort = 1001;
	matchStartText3 setText( "Round Starting!" );
	matchStartText3.foreground = false;
	matchStartText3.hidewheninmenu = false;

	wait 2;

	if ( isDefined( matchStartText2 ) )
		matchStartText2 destroy();

	if ( isDefined( matchStartText3 ) )
		matchStartText3 destroy();

	level.strat_over = true;
}

bypass_hud()
{
	self endon("disconnect");

	readyhud = newClientHudElem(self);
	readyhud.x = 320;
	readyhud.y = 180;
	readyhud.alignX = "center";
	readyhud.alignY = "middle";
	readyhud.fontScale = 1.5;
	readyhud.font = "objective";
	readyhud.hidewheninmenu = false;

	while( level.strat_bypass_active )
	{
		if ( !isdefined( self ) || !isPlayer( self ) )
			return;

		team_bypassed = 0;

		if ( self.pers["team"] == "allies" )
			team_bypassed =	level.allies_bypassed;
		else if ( self.pers["team"] == "axis" )
			team_bypassed = level.axis_bypassed;

		if ( self useButtonPressed() && !team_bypassed )
		{
			if ( self.pers["team"] == "allies" )
				level.allies_bypassed = 1;
			else if ( self.pers["team"] == "axis" )
				level.axis_bypassed = 1;

			game["promod_" + self.pers["team"] + "_bypassed_by"] = self.name;
		}
		else
			wait .1;

		if ( team_bypassed )
			readyhud setText("Bypassed by ^3" + game["promod_" + self.pers["team"] + "_bypassed_by"]);
		else
			readyhud setText( "Press ^3[{+activate}] ^7to Bypass" );
	}

	level waittill( "kill_bypass_hud" );

	if ( isDefined( readyhud ) )
		readyhud destroy();
}