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
	if ( !game["promod_first_readyup_done"] && !game["promod_timeout_called"] )
		sb_text = "1st_half_ready_up";
	else if ( game["promod_first_readyup_done"] && !game["promod_timeout_called"] )
		sb_text = "2nd_half_ready_up";
	else
		sb_text = "timeout_ready_up";
	if ( isDefined( level.scorebot ) && level.scorebot )
		game["promod_scorebot_ticker_buffer"] += "" + sb_text;

	level.timeLimitOverride = true;
	level.rdyup = 1;

	thread disableBombsites();

	setDvar( "g_deadChat", 1 );
	setClientNameMode( "auto_change" );
	setGameEndTime( 0 );

	readyup_text = Get_Readyup_Period();
	thread Period_Announce( readyup_text );

	thread Waiting_On_Players_HUD_Loop();

	Ready_Up_Monitor_Loop();

	thread Kill_HUD_Stuff();

	game["state"] = "postgame";

	wait 0.5;

	Ready_up_matchStartTimer();

	game["promod_do_readyup"] = false;
	game["promod_first_readyup_done"] = 1;

	game["state"] = "playing";
	map_restart( true );
}

disableBombsites()
{
	if ( level.gametype == "sd" && isDefined( level.bombZones ) )
		for ( j = 0; j < level.bombZones.size; j++ )
			level.bombZones[j] maps\mp\gametypes\_gameobjects::disableObject();
}

Ready_Up_Monitor_Loop()
{
	level.ready_up_over = false;

	while ( !level.ready_up_over )
	{
		wait 0.05;

		all_players_ready = true;
		not_ready_count = 0;

		players = getentarray("player", "classname");

		if ( players.size < 1 )
		{
			all_players_ready = false;
			continue;
		}

		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !isDefined( player.looped ) )
			{
				player.looped = true;
				player.ready = false;
				player thread Player_Ready_Up_Loop();
				all_players_ready = false;
			}

			if ( !player.ready )
			{
				not_ready_count++;
				all_players_ready = false;
			}
		}

		level.not_ready_count = not_ready_count;

		if ( all_players_ready )
			level.ready_up_over = true;
	}

	if ( isdefined( level.waiting ) )
		level.waiting destroy();
}

Player_Ready_Up_Loop()
{
	self endon("disconnect");

	self thread on_Spawn();

	status = newClientHudElem(self);
	status.x = -36;
	status.y = 145;
	status.horzAlign = "right";
	status.vertAlign = "top";
	status.alignX = "center";
	status.alignY = "middle";
	status.fontScale = 1.4;
	status.font = "default";
	status.color = (0.8, 1, 1);
	status.hidewheninmenu = true;
	status setText("Status");

	readyhud = newClientHudElem(self);
	readyhud.x = -36;
	readyhud.y = 160;
	readyhud.horzAlign = "right";
	readyhud.vertAlign = "top";
	readyhud.alignX = "center";
	readyhud.alignY = "middle";
	readyhud.fontScale = 1.4;
	readyhud.font = "default";
	readyhud.color = (1, 0.66, 0.66);
	readyhud.hidewheninmenu = true;
	readyhud setText("Not Ready");

	killing = newClientHudElem(self);
	killing.x = -36;
	killing.y = 310;
	killing.horzAlign = "right";
	killing.vertAlign = "top";
	killing.alignX = "center";
	killing.alignY = "middle";
	killing.fontScale = 1.4;
	killing.font = "default";
	killing.color = (0.8, 1, 1);
	killing.hidewheninmenu = true;
	killing setText("Killing");

	readytally = newClientHudElem(self);
	readytally.x = -36;
	readytally.y = 325;
	readytally.horzAlign = "right";
	readytally.vertAlign = "top";
	readytally.alignX = "center";
	readytally.alignY = "middle";
	readytally.fontScale = 1.4;
	readytally.font = "default";
	readytally.color = (1, 0.66, 0.66);
	readytally.hidewheninmenu = true;
	readytally setText("Disabled");

	self.statusicon = "compassping_enemy";

	while ( !level.ready_up_over )
	{
		wait 0.05;

		if ( isDefined( self.ruptally ) && self.ruptally >= 0 )
		{
			killing setText("Kills");
			readytally setValue(self.ruptally);
			wait 0.1;
		}

		if ( self useButtonPressed() )
		{
			self.ready = !self.ready;

			if ( self.ready )
			{
				readyhud.color = (0.73, 0.99, 0.73);
				readyhud setText("Ready");
				self.statusicon = "compassping_friendlyfiring_mp";

				for ( i = 0; i < level.players.size; i++ )
					level.players[i] ShowScoreBoard();
			}
			else
			{
				readyhud.color = (1, 0.66, 0.66);
				readyhud setText("Not Ready");
				self.statusicon = "compassping_enemy";

				for ( i = 0; i < level.players.size; i++ )
					level.players[i] ShowScoreBoard();
			}
		}

		if ( self.ready )
			self.statusicon = "compassping_friendlyfiring_mp";
		else
			self.statusicon = "compassping_enemy";

		while ( self useButtonPressed() )
			wait 0.05;
	}

	level waittill("kill_ru_huds");

	self.statusicon = "";

	if ( isDefined( readyhud ) )
		readyhud destroy();

	if ( isDefined( status ) )
		status destroy();

	if ( isDefined( killing ) )
		killing destroy();

	if ( isDefined( readytally ) )
		readytally destroy();
}

Waiting_On_Players_HUD_Loop()
{
	while ( !isDefined( level.not_ready_count ) )
		wait 0.1;

	waitingon = newHudElem();
	waitingon.x = -36;
	waitingon.y = 80;
	waitingon.horzAlign = "right";
	waitingon.vertAlign = "top";
	waitingon.alignX = "center";
	waitingon.alignY = "middle";
	waitingon.fontScale = 1.4;
	waitingon.font = "default";
	waitingon.color = (0.8, 1, 1);
	waitingon.hidewheninmenu = true;
	waitingon setText("Waiting On");

	playerstext = newHudElem();
	playerstext.x = -36;
	playerstext.y = 120;
	playerstext.horzAlign = "right";
	playerstext.vertAlign = "top";
	playerstext.alignX = "center";
	playerstext.alignY = "middle";
	playerstext.fontScale = 1.4;
	playerstext.font = "default";
	playerstext.color = (0.8, 1, 1);
	playerstext.hidewheninmenu = true;
	playerstext setText("Players");

	notreadyhud = newHudElem();
	notreadyhud.x = -36;
	notreadyhud.y = 100;
	notreadyhud.horzAlign = "right";
	notreadyhud.vertAlign = "top";
	notreadyhud.alignX = "center";
	notreadyhud.alignY = "middle";
	notreadyhud.fontScale = 1.4;
	notreadyhud.font = "default";
	notreadyhud.color = (0.98, 0.98, 0.60);
	notreadyhud.hidewheninmenu = true;

	while ( !level.ready_up_over )
	{
		notreadyhud setValue( level.not_ready_count );
		wait 0.005;
	}

	notreadyhud setValue(0);

	level waittill("kill_ru_huds");

	if ( isDefined( notreadyhud ) )
		notreadyhud destroy();

	if ( isDefined( waitingon ) )
		waitingon destroy();

	if ( isDefined( playerstext ) )
		playerstext destroy();
}

on_Spawn()
{
	self endon("disconnect");

	while (!level.ready_up_over)
	{
		self waittill("spawned_player");
		self iprintlnbold("Press ^3[{+activate}] ^7to Ready-Up");
	}
}

Ready_up_matchStartTimer()
{
	timer = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );

	visionSetNaked( "mpIntro", 1 );

	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText setText( "All Players are Ready!" );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = false;
	matchStartText.glowColor = (0.3, 0.6, 0.3);
	matchStartText.glowAlpha = 1;
	matchStartText setPulseFX( 100, 2000, 2000 );

	matchStartText2 = createServerFontString( "objective", 1.5 );
	matchStartText2 setPoint( "CENTER", "CENTER", 0, -20 );
	matchStartText2.sort = 1001;
	matchStartText2 setText( game["strings"]["match_starting_in"] );
	matchStartText2.foreground = false;
	matchStartText2.hidewheninmenu = false;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer setTimer( timer );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = false;

	wait timer;

	visionSetNaked( getDvar( "mapname" ), 1 );

	matchStartText destroyElem();
	matchStartText2 destroyElem();
	matchStartTimer destroyElem();
}

Kill_HUD_Stuff()
{
	level notify("kill_ru_period");

	wait 2;

	level notify("kill_ru_huds");
	level notify("header_destroy");
}

Get_Readyup_Period()
{
	if (!game["promod_first_readyup_done"])
		return "Pre-Match Ready-Up Period";
	else if ( game["promod_timeout_called"] )
		return "Timeout Ready-Up Period";
	else
		return "Half-Time Ready-Up Period";
}

Period_Announce( text )
{
	RU_Period = createServerFontString( "objective", 1.6 );
	RU_Period setPoint( "CENTER", "CENTER", 0, -75 );
	RU_Period.sort = 1001;
	RU_Period setText( text );
	RU_Period.foreground = false;
	RU_Period.hidewheninmenu = true;

	level waittill("kill_ru_period");

	if ( isdefined( RU_Period ) )
		RU_Period destroy();
}