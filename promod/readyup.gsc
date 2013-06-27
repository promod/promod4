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
	if ( isDefined( level.scorebot ) && level.scorebot )
	{

		if( game["promod_in_timeout"] )
			sb_text = "timeout";
		else
		{
			if( game["promod_first_readyup_done"] )
				sb_text = "2nd_half";
			else
				sb_text = "1st_half";
		}

		game["promod_scorebot_ticker_buffer"] += "" + sb_text+"_ready_up";
	}

	level.timeLimitOverride = true;
	level.rdyup = true;
	level.rup_txt_fx = true;

	setDvar( "g_deadChat", 1 );
	setClientNameMode( "auto_change" );
	setGameEndTime( 0 );

	thread periodAnnounce();

	level.ready_up_over = false;
	previous_not_ready_count = 0;

	thread updatePlayerHUDInterval();
	thread lastPlayerReady();

	while ( !level.ready_up_over )
	{
		all_players_ready = true;
		level.not_ready_count = 0;

		if ( level.players.size < 1 )
		{
			all_players_ready = false;

			wait 0.2;
			continue;
		}

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( !isDefined( player.looped ) )
			{
				player setclientdvar("self_ready", 0);

				player.looped = true;
				player.ready = false;
				player.update = false;
				player.statusicon = "compassping_enemy";
				player thread selfLoop();
			}

			player.oldready = player.update;

			if ( player.ready )
			{
				player.update = true;

				if ( !isDefined( player.pers["record_reminder_done"] ) && ( isAlive( player ) && isDefined( player.pers["class"] ) && !isDefined( player.inrecmenu ) && !player promod\client::get_config( "PROMOD_RECORD" ) ) )
				{
					player.pers["record_reminder_done"] = true;

					player openMenu( game["menu_demo"] );
					player.inrecmenu = true;
				}
			}

			if ( !player.ready || isDefined( player.inrecmenu ) && player.inrecmenu && !player promod\client::get_config( "PROMOD_RECORD" ) )
			{
				level.not_ready_count++;
				all_players_ready = false;
				player.update = false;
			}

			player.newready = player.update;

			if ( player.oldready != player.newready && ( !isDefined( player.inrecmenu ) || !player.inrecmenu ) )
			{
				player setclientdvar("self_ready", int(player.ready));
				player.oldready = player.newready;

				if ( player.ready )
					player.statusicon = "compassping_friendlyfiring_mp";
				else
					player.statusicon = "compassping_enemy";
			}
		}

		if(previous_not_ready_count != level.not_ready_count)
		{
			for(i=0;i<level.players.size;i++)
			{
				level.players[i] setclientdvar("waiting_on", level.not_ready_count);
				level.players[i] ShowScoreBoard();
				previous_not_ready_count = level.not_ready_count;
			}
		}

		if ( all_players_ready )
			level.ready_up_over = true;

		wait 0.05;
	}

	level notify("kill_ru_period");
	level notify("header_destroy");

	for(i=0;i<level.players.size;i++)
	{
		level.players[i] setclientdvars("self_ready","", "ui_hud_hardcore", 1 );
		level.players[i].statusicon = "";
	}
	for(i=0;i<level.players.size;i++)
		level.players[i] ShowScoreBoard();

	game["state"] = "postgame";

	visionSetNaked( "mpIntro", 1 );

	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -75 );
	matchStartText.sort = 1001;
	matchStartText setText( "All Players are Ready!" );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = false;
	matchStartText.glowColor = (0.6, 0.64, 0.69);
	matchStartText.glowAlpha = 1;
	matchStartText setPulseFX( 100, 4000, 1000 );

	matchStartText2 = createServerFontString( "objective", 1.5 );
	matchStartText2 setPoint( "CENTER", "CENTER", 0, -60 );
	matchStartText2.sort = 1001;
	matchStartText2 setText( game["strings"]["match_starting_in"] );
	matchStartText2.foreground = false;
	matchStartText2.hidewheninmenu = false;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, -45 );
	matchStartTimer setTimer( 5 );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = false;

	wait 5;

	visionSetNaked( getDvar( "mapname" ), 1 );

	matchStartText destroyElem();
	matchStartText2 destroyElem();
	matchStartTimer destroyElem();

	game["promod_do_readyup"] = false;
	game["promod_first_readyup_done"] = 1;
	game["state"] = "playing";

	map_restart( true );
}

lastPlayerReady()
{
	wait 0.5;

	while ( !level.ready_up_over )
	{
		maxwait = 0;
		while ( !level.ready_up_over && level.not_ready_count == 1 && level.players.size > 1 && maxwait <= 5 )
		{
			wait 0.05;
			maxwait += 0.05;
		}

		if( level.not_ready_count == 1 && level.players.size > 1 )
		{
			for(i=0;i<level.players.size;i++)
			{
				player = level.players[i];

				if( player.ready )
				{
					player.soundplayed = undefined;
					player.timesplayed = undefined;
				}
				else
				{
					if ( ( !isDefined( player.soundplayed ) || gettime() - 20000 > player.soundplayed ) && ( !isDefined( player.timesplayed ) || player.timesplayed < 4 ) && ( !isDefined( player.inrecmenu ) || !player.inrecmenu ) )
					{
						player PlayLocalSound( player maps\mp\gametypes\_quickmessages::getSoundPrefixForTeam()+"1mc_lastalive" );
						player.soundplayed = gettime();

						if ( isDefined( player.timesplayed ) )
							player.timesplayed++;
						else
							player.timesplayed = 1;
					}
				}
			}
		}

		wait 0.05;
	}
}

updatePlayerHUDInterval()
{
	level endon("kill_ru_period");

	while ( !level.ready_up_over )
	{
		wait 5;

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( isDefined( player ) )
			{
				if ( isDefined( player.ready ) && !isDefined( player.inrecmenu ) )
					player setclientdvar("self_ready", int(player.ready));

				if ( isDefined( level.not_ready_count ) )
					player setclientdvar("waiting_on", level.not_ready_count);
			}
		}
	}
}

selfLoop()
{
	self endon("disconnect");

	self thread onSpawn();
	self thread clientHUD();

	self setClientDvar( "self_kills", "" );

	while ( !level.ready_up_over )
	{
		while ( !isDefined( self.pers["team"] ) || self.pers["team"] == "none" )
			wait 0.05;

		wait 0.05;

		if ( self useButtonPressed() )
			self.ready = !self.ready;

		while ( self useButtonPressed() )
			wait 0.1;
	}
}

clientHUD()
{
	self endon("disconnect");

	if ( !game["promod_first_readyup_done"] )
		self waittill("spawned_player");

	text = "";
	if ( !game["promod_first_readyup_done"] )
		text = "Pre-Match";
	else if ( game["promod_in_timeout"] )
		text = "Timeout";
	else
		text = "Half-Time";

	self.periodtext = createFontString( "objective", 1.6 );
	self.periodtext setPoint( "CENTER", "CENTER", 0, -75 );
	self.periodtext.sort = 1001;
	self.periodtext setText( text + " Ready-Up Period" );
	self.periodtext.foreground = false;
	self.periodtext.hidewheninmenu = true;

	self.halftimetext = createFontString( "objective", 1.5 );
	self.halftimetext.alpha = 0;
	self.halftimetext setPoint( "CENTER", "CENTER", 0, 200 );
	self.halftimetext.sort = 1001;

	self.halftimetext.foreground = false;
	self.halftimetext.hidewheninmenu = true;

	if ( game["promod_first_readyup_done"] && game["promod_in_timeout"] && (!isDefined( game["LAN_MODE"] ) || !game["LAN_MODE"]) )
		text = "Remaining";
	else
		text = "Elapsed";

	self.halftimetext setText( "Time " + text );

	self thread moveOver();

	level waittill("kill_ru_period");

	if ( isDefined( self.periodtext ) )
		self.periodtext destroy();

	if ( isDefined( self.halftimetext ) )
		self.halftimetext destroy();

}

onSpawn()
{
	self endon("disconnect");

	while ( !level.ready_up_over )
	{
		self waittill("spawned_player");
		self iprintlnbold("Press ^3[{+activate}] ^7to Ready-Up");
	}
}

periodAnnounce()
{
	level.halftimetimer = createServerTimer( "objective", 1.4 );
	level.halftimetimer.alpha = 0;
	level.halftimetimer setPoint( "CENTER", "CENTER", 0, 215 );

	if ( !game["promod_in_timeout"] || isDefined( game["LAN_MODE"] ) && game["LAN_MODE"] )
		level.halftimetimer setTimerUp( 0 );
	else
		level.halftimetimer setTimer( 300 );

	level.halftimetimer.sort = 1001;
	level.halftimetimer.foreground = false;
	level.halftimetimer.hideWhenInMenu = true;

	level waittill("kill_ru_period");

	if ( isDefined( level.halftimetimer ) )
		level.halftimetimer destroy();
}

moveOver()
{
	level endon("kill_ru_period");
	self endon("disconnect");

	if( level.rup_txt_fx )
	{
		wait 3;
		self.periodtext MoveOverTime( 2.5 );
	}

	self.periodtext setPoint( "CENTER", "CENTER", 0, 185 );

	if( level.rup_txt_fx )
	{
		wait 2.6;
		if( isDefined( level.halftimetimer ) )
			level.halftimetimer.alpha = 1;
		level.rup_txt_fx = false;
	}

	if( isDefined( self.halftimetext ) )
		self.halftimetext.alpha = 1;
}
