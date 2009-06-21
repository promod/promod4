/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;

wipedata()
{
	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["damagedone"] = 0;
		player.pers["damagetaken"] = 0;
		player.pers["fdamagedone"] = 0;
		player.pers["fdamagetaken"] = 0;
		player.pers["accuracy"] = 0;
		player.pers["total"] = 0;
		player.pers["hits"] = 0;
	}
}

senddata()
{
	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if ( !isDefined( player.pers["damagedone"] ) )
			player.pers["damagedone"] = 0;

		if ( !isDefined( player.pers["damagetaken"] ) )
			player.pers["damagetaken"] = 0;

		if ( !isDefined( player.pers["fdamagedone"] ) )
			player.pers["fdamagedone"] = 0;

		if ( !isDefined( player.pers["fdamagetaken"] ) )
			player.pers["fdamagetaken"] = 0;

		if ( !isDefined( player.pers["accuracy"] ) )
			player.pers["accuracy"] = 0;

		if ( !isDefined( player.pers["total"] ) )
			player.pers["total"] = 0;

		if ( !isDefined( player.pers["hits"] ) )
			player.pers["hits"] = 0;

		iprintln("^3" + player.name);
		iprintln("Damage Done: ^2" + player.pers["damagedone"] + "^7 Damage Taken: ^1" + player.pers["damagetaken"]);
		iprintln("Friendly Damage Done: ^2" + player.pers["fdamagedone"] + "^7 Friendly Damage Taken: ^1" + player.pers["fdamagetaken"]);
		iprintln("Shots Fired: ^2" + player.pers["total"] + "^7 Shots Hit: ^2" + player.pers["hits"] + "^7 Accuracy: ^1" + player.pers["accuracy"]);
	}

	wipedata();
}

selfsenddata()
{
	if ( !isDefined( self.pers["damagedone"] ) )
		self.pers["damagedone"] = 0;

	if ( !isDefined( self.pers["damagetaken"] ) )
		self.pers["damagetaken"] = 0;

	if ( !isDefined( self.pers["fdamagedone"] ) )
		self.pers["fdamagedone"] = 0;

	if ( !isDefined( self.pers["fdamagetaken"] ) )
		self.pers["fdamagetaken"] = 0;

	if ( !isDefined( self.pers["accuracy"] ) )
		self.pers["accuracy"] = 0;

	if ( !isDefined( self.pers["total"] ) )
		self.pers["total"] = 0;

	if ( !isDefined( self.pers["hits"] ) )
		self.pers["hits"] = 0;

	self iprintln("^3" + self.name);
	self iprintln("Damage Done: ^2" + self.pers["damagedone"] + "^7 Damage Taken: ^1" + self.pers["damagetaken"]);
	self iprintln("Friendly Damage Done: ^2" + self.pers["fdamagedone"] + "^7 Friendly Damage Taken: ^1" + self.pers["fdamagetaken"]);
	self iprintln("Shots Fired: ^2" + self.pers["total"] + "^7 Shots Hit: ^2" + self.pers["hits"] + "^7 Accuracy: ^1" + self.pers["accuracy"]);
}