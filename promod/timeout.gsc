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
	game["promod_in_timeout"] = 1;

	thread promod\readyup::main();
	level.timeout_over = false;

	game["promod_timeout_called"] = false;
	level.Timeout_time_left = 300;

	if ( !isDefined( game["LAN_MODE"] ) || !game["LAN_MODE"] )
		level thread Timeout_Timer();

	level thread Timeout_Time();
	level thread Timeout_Time_Timer();
}

Timeout_Timer()
{
	while( !level.timeout_over )
	{
		wait 0.25;
		level.Timeout_time_left -= 0.25;
	}
}

Timeout_Time()
{
	if ( !isDefined( level.ready_up_over ) )
		level.ready_up_over = false;

	while ( !level.timeout_over )
	{
		wait 0.25;

		if ( level.Timeout_time_left <= 0 || level.ready_up_over )
		{
			level notify("kill_Timeout_timer");
			level.timeout_over = true;
			level.ready_up_over = 1;
		}
	}
}

Timeout_Time_Timer()
{
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -60 );
	matchStartText.sort = 1001;
	if ( isDefined( game["LAN_MODE"] ) && game["LAN_MODE"] )
		matchStartText setText( "Timeout Elapsed" );
	else
		matchStartText setText( "Timeout Remaining" );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, -40 );
	if ( isDefined( game["LAN_MODE"] ) && game["LAN_MODE"] )
		matchStartTimer setTimerUp( 0 );
	else
		matchStartTimer setTimer( 300 );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;

	level waittill("kill_Timeout_timer");

	if ( isDefined(matchStartText) )
		matchStartText destroy();

	if ( isDefined(matchStartTimer) )
		matchStartTimer destroy();
}

Timeout_Call()
{
	if ( (isDefined( level.ready_up_over ) && !level.ready_up_over || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] != "match") || ( level.gametype != "sd" && level.gametype != "sab" ) )
		return;

	if ( game["promod_timeout_called"] )
	{
		self iprintln("^3Timeout already called by " + game["promod_timeout_called_by"]);
		return;
	}

	if ( game[self.pers["team"] + "_timeout_called"] && (!isDefined( game["LAN_MODE"] ) || !game["LAN_MODE"]) )
	{
		self iprintln("^3Only one timeout per team/half allowed");
		return;
	}

	game["promod_timeout_called_by"] = self.name;
	iprintln("^3Timeout called by " + game["promod_timeout_called_by"]);

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		timeout_team = "";
		if ( self.pers["team"] == game["attackers"] )
			timeout_team = "attack";
		else if ( self.pers["team"] == game["defenders"] )
			timeout_team = "defence";

		game["promod_scorebot_ticker_buffer"] += "timeout_called" + timeout_team + "" + self.name;
	}

	if ( level.gametype == "sd" )
		game[self.pers["team"] + "_timeout_called"] = 1;

	game["promod_timeout_called"] = true;
}