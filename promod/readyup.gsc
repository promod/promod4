/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;

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

	disableBombsites();

	setDvar( "g_deadChat", "1" );
	setClientNameMode( "auto_change" );
	setGameEndTime( 0 );

	readyup_text = Get_Readyup_Period();
	thread Period_Announce( readyup_text );

	thread Waiting_On_Players_HUD_Loop();

	Ready_Up_Monitor_Loop();

	thread Kill_HUD_Stuff();

	wait .5;

	Ready_up_matchStartTimer();

	game["promod_do_readyup"] = false;
	game["promod_first_readyup_done"] = 1;

	game["state"] = "playing";
	map_restart( true );
}

disableBombsites()
{
	if( level.gametype == "sd" && isDefined( level.bombZones ) )
		for ( j = 0; j < level.bombZones.size; j++ )
			level.bombZones[j] maps\mp\gametypes\_gameobjects::disableObject();
}

Ready_Up_Monitor_Loop()
{
	level.ready_up_over = false;

	while (!level.ready_up_over)
	{
		wait .5;
		all_players_ready = true;
		not_ready_count = 0;

		players = getentarray("player", "classname");

		if (players.size < 1)
		{
			all_players_ready = false;
			wait 2;
			continue;
		}

		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if ( !isDefined(player.looped) )
			{
				player.looped = true;
				player.ready = false;
				player.ruptally = -1;
				player thread Player_Ready_Up_Loop();
				all_players_ready = false;
			}

			if (!player.ready)
			{
				not_ready_count++;
				all_players_ready = false;
			}
		}

		level.not_ready_count = not_ready_count;

		if (all_players_ready)
			level.ready_up_over = true;
	}

	if(isdefined(level.waiting))
		level.waiting destroy();
}

Player_Ready_Up_Loop()
{
	self.pers["autoready"] = 0;

	self endon("disconnect");

	if (isDefined(self.in_ready_up_loop))
		return;

	self.in_ready_up_loop = true;

	self thread on_Spawn();

	status = newClientHudElem(self);
	status.x = -40;
	status.y = 145;
	status.horzAlign = "right";
	status.vertAlign = "top";
	status.alignX = "center";
	status.alignY = "middle";
	status.fontScale = 1.4;
	status.font = "default";
	status.color = (.8, 1, 1);
	status.hidewheninmenu = true;
	status setText("Status");

	readyhud = newClientHudElem(self);
	readyhud.x = -40;
	readyhud.y = 160;
	readyhud.horzAlign = "right";
	readyhud.vertAlign = "top";
	readyhud.alignX = "center";
	readyhud.alignY = "middle";
	readyhud.fontScale = 1.4;
	readyhud.font = "default";
	readyhud.color = (1, .66, .66);
	readyhud.hidewheninmenu = true;
	readyhud setText("Not Ready");

	killing = newClientHudElem(self);
	killing.x = -40;
	killing.y = 285;
	killing.horzAlign = "right";
	killing.vertAlign = "top";
	killing.alignX = "center";
	killing.alignY = "middle";
	killing.fontScale = 1.4;
	killing.font = "default";
	killing.color = (.8, 1, 1);
	killing.hidewheninmenu = true;
	killing setText("Killing");

	readytally = newClientHudElem(self);
	readytally.x = -40;
	readytally.y = 300;
	readytally.horzAlign = "right";
	readytally.vertAlign = "top";
	readytally.alignX = "center";
	readytally.alignY = "middle";
	readytally.fontScale = 1.4;
	readytally.font = "default";
	readytally.color = (1, .66, .66);
	readytally.hidewheninmenu = true;
	readytally setText("Disabled");

	if (self.pers["autoready"] == 0) self.statusicon = "compassping_enemy";

	while (!level.ready_up_over)
	{
		wait .05;

		if (self.ruptally >= 0)
		{
			killing setText("Kills");
			readytally setValue(self.ruptally);
			wait 0.1;
		}

		if(self useButtonPressed() == true)
		{
			self.ready = !self.ready;

			if (self.ready)
			{
				self.statusicon = "compassping_friendlyfiring_mp";

				readyhud.color = (.73, .99, .73);
				readyhud setText("Ready");
			}
			else
			{
				self.statusicon = "compassping_enemy";

				readyhud.color = (1, .66, .66);
				readyhud setText("Not Ready");
			}

			while (self useButtonPressed() == true)
				wait .05;
		}
		else
		{
			if (self.ready && self.statusicon != "compassping_friendlyfiring_mp" )
			{
				if (self.pers["autoready"] == 0) self.statusicon = "compassping_friendlyfiring_mp";

				readyhud.color = (.73, .99, .73);
				readyhud setText("Ready");
			}
			else if (!self.ready && self.statusicon != "compassping_enemy" )
			{
				if (self.pers["autoready"] == 0) self.statusicon = "compassping_enemy";

				readyhud.color = (1, .66, .66);
				readyhud setText("Not Ready");
			}
		}
	}

	level waittill("kill_ru_huds");

	if (self.pers["autoready"] == 0) self.statusicon = "";

	if(isdefined(readyhud))
		readyhud destroy();
	if(isdefined(status))
		status destroy();
	if(isdefined(killing))
		killing destroy();
	if(isdefined(readytally))
		readytally destroy();
}

Waiting_On_Players_HUD_Loop()
{
	while (!isDefined(level.not_ready_count))
		wait .1;

	level.waitingon = newHudElem(self);
	level.waitingon.x = -40;
	level.waitingon.y = 80;
	level.waitingon.horzAlign = "right";
	level.waitingon.vertAlign = "top";
	level.waitingon.alignX = "center";
	level.waitingon.alignY = "middle";
	level.waitingon.fontScale = 1.4;
	level.waitingon.font = "default";
	level.waitingon.color = (.8, 1, 1);
	level.waitingon.hidewheninmenu = true;
	level.waitingon setText("Waiting On");

	level.playerstext = newHudElem(self);
	level.playerstext.x = -40;
	level.playerstext.y = 120;
	level.playerstext.horzAlign = "right";
	level.playerstext.vertAlign = "top";
	level.playerstext.alignX = "center";
	level.playerstext.alignY = "middle";
	level.playerstext.fontScale = 1.4;
	level.playerstext.font = "default";
	level.playerstext.color = (.8, 1, 1);
	level.playerstext.hidewheninmenu = true;
	level.playerstext setText("Players");

	level.notreadyhud = newHudElem(self);
	level.notreadyhud.x = -40;
	level.notreadyhud.y = 100;
	level.notreadyhud.horzAlign = "right";
	level.notreadyhud.vertAlign = "top";
	level.notreadyhud.alignX = "center";
	level.notreadyhud.alignY = "middle";
	level.notreadyhud.fontScale = 1.4;
	level.notreadyhud.font = "default";
	level.notreadyhud.color = (.98, .98, .60);
	level.notreadyhud.hidewheninmenu = true;

	while(!level.ready_up_over)
	{
		level.notreadyhud setValue(level.not_ready_count);
		wait .1;
	}

	level.notreadyhud setValue(0);

	level waittill("kill_ru_huds");

	if(isdefined(level.notreadyhud))
		level.notreadyhud destroy();
	if(isdefined(level.waitingon))
		level.waitingon destroy();
	if(isdefined(level.playerstext))
		level.playerstext destroy();
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

	visionSetNaked( getDvar( "mapname" ), 2.0 );

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

	if(isdefined(RU_Period))
		RU_Period destroy();
}