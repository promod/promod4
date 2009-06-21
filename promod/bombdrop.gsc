/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

Bomb_Drop()
{
	if ( level.gameType != "sd" && level.gameType != "sab" )
		return;

	if( level.gameType == "sd" && self.pers["team"] != game["attackers"] )
		return;

	if (self.sessionstate != "playing")
		return;

	if( !self.isBombCarrier )
		return;

	if( self.isPlanting )
		return;

	self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
	self.isBombCarrier = false;
}