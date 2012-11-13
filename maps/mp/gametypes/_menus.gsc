/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	game["menu_team"] = "team_marinesopfor";
	if(game["attackers"] == "axis" && game["defenders"] == "allies")
		game["menu_team"] += "_flipped";
	game["menu_class_allies"] = "class_marines";
	game["menu_changeclass_allies"] = "changeclass_marines_mw";
	game["menu_class_axis"] = "class_opfor";
	game["menu_changeclass_axis"] = "changeclass_opfor_mw";
	game["menu_class"] = "class";
	game["menu_changeclass"] = "changeclass_mw";
	game["menu_changeclass_offline"] = "changeclass_offline";
	game["menu_shoutcast"] = "shoutcast";
	game["menu_shoutcast_map"] = "shoutcast_map";
	game["menu_shoutcast_setup"] = "shoutcast_setup";
	game["menu_callvote"] = "callvote";
	game["menu_muteplayer"] = "muteplayer";
	game["menu_quickcommands"] = "quickcommands";
	game["menu_quickstatements"] = "quickstatements";
	game["menu_quickresponses"] = "quickresponses";
	game["menu_quickpromod"] = "quickpromod";
	game["menu_quickpromodgfx"] = "quickpromodgfx";
	game["menu_demo"] = "demo";

	precacheMenu("quickcommands");
	precacheMenu("quickstatements");
	precacheMenu("quickresponses");
	precacheMenu("quickpromod");
	precacheMenu("quickpromodgfx");
	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu("class_marines");
	precacheMenu("changeclass_marines_mw");
	precacheMenu("class_opfor");
	precacheMenu("changeclass_opfor_mw");
	precacheMenu("class");
	precacheMenu("changeclass_mw");
	precacheMenu("changeclass_offline");
	precacheMenu("callvote");
	precacheMenu("muteplayer");
	precacheMenu("shoutcast");
	precacheMenu("shoutcast_map");
	precacheMenu("shoutcast_setup");
	precacheMenu("shoutcast_setup_binds");
	precacheMenu("echo");
	precacheMenu("demo");

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	level endon("restarting");
	self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if ( !isDefined( self.pers["team"] ) )
			continue;

		if( getSubStr( response, 0, 7 ) == "loadout" )
		{
			self maps\mp\gametypes\_promod::processLoadoutResponse( response );
			continue;
		}

		switch( response )
		{
			case "back":
				if ( self.pers["team"] == "none" )
					continue;

				if( menu == game["menu_changeclass"] && ( self.pers["team"] == "axis" || self.pers["team"] == "allies" ) )
				{
					if( isDefined(self.pers["class"]) )
					{
						self maps\mp\gametypes\_promod::setClassChoice( self.pers["class"] );
						self maps\mp\gametypes\_promod::menuAcceptClass( "go" );
					}

					self openMenu( game["menu_changeclass_"+self.pers["team"]] );
				}
				else
				{
					self closeMenu();
					self closeInGameMenu();
				}
				continue;

			case "demo":
				if ( menu == "demo" )
					self.inrecmenu = false;
				continue;

			case "changeteam":
				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_team"]);
				continue;

			case "shoutcast_setup":
				if ( self.pers["team"] != "spectator" )
					continue;

				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_shoutcast_setup"]);
				continue;

			case "changeclass_marines":
			case "changeclass_opfor":
				if ( self.pers["team"] == "axis" || self.pers["team"] == "allies" )
				{
					self closeMenu();
					self closeInGameMenu();
					self openMenu( game["menu_changeclass_"+self.pers["team"]] );
				}
				continue;
		}

		switch( menu )
		{
			case "echo":
				k = strtok(response, "_");
				buf = k[0];
				for(i=1;i<k.size;i++)
					buf += " "+k[i];
				self iprintln(buf);
				continue;
			case "team_marinesopfor":
			case "team_marinesopfor_flipped":
				switch(response)
				{
					case "allies":
						self [[level.allies]]();
						break;

					case "axis":
						self [[level.axis]]();
						break;

					case "autoassign":
						self [[level.autoassign]]();
						break;

					case "shoutcast":
						self [[level.spectator]]();
						break;
				}
				continue;
			case "changeclass_marines_mw":
			case "changeclass_opfor_mw":
				if ( response == "killspec" )
				{
					self [[level.killspec]]();
					continue;
				}

				if ( maps\mp\gametypes\_quickmessages::chooseClassName( response ) == "" || !self maps\mp\gametypes\_promod::verifyClassChoice( self.pers["team"], response ) )
					continue;

				self maps\mp\gametypes\_promod::setClassChoice( response );
				self closeMenu();
				self closeInGameMenu();
				self openMenu( game["menu_changeclass"] );
				continue;

			case "changeclass_mw":
				self maps\mp\gametypes\_promod::menuAcceptClass( response );
				continue;

			case "shoutcast_setup":
				if ( self.pers["team"] == "spectator" )
				{
					if( response == "assault" || response == "specops" || response == "demolitions" || response == "sniper" )
						self promod\shoutcast::followClass(response);
					else if (response == "getdetails")
					{
						self promod\shoutcast::loadOne();
						classes = [];
						classes["assault"] = 0;
						classes["specops"] = 0;
						classes["demolitions"] = 0;
						classes["sniper"] = 0;

						for(i=0;i<level.players.size;i++)
						{
							if(isDefined(level.players[i].curClass))
								classes[level.players[i].curClass]++;
							if(isDefined(level.players[i].pers["shoutnum"]) && isDefined(level.players[i].curClass))
								self setclientdvar("shout_class"+level.players[i].pers["shoutnum"], maps\mp\gametypes\_quickmessages::chooseClassName(level.players[i].curClass));
						}
						self setClientDvars("shout_class_assault", classes["assault"],
											"shout_class_specops", classes["specops"],
											"shout_class_demolitions", classes["demolitions"],
											"shout_class_sniper", classes["sniper"]);
					}
					else if ( int( response ) < 11 && int( response ) > 0 )
						self promod\shoutcast::followBar(int(response)-1);
				}
				continue;

			case "quickcommands":
			case "quickstatements":
			case "quickresponses":
				maps\mp\gametypes\_quickmessages::doQuickMessage( menu, int(response)-1 );
				continue;

			case "quickpromod":
				maps\mp\gametypes\_quickmessages::quickpromod( response );
				continue;

			case "quickpromodgfx":
				maps\mp\gametypes\_quickmessages::quickpromodgfx( response );
				continue;
		}
	}
}