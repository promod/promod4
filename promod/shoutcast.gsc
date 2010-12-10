/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

updateHealthbar()
{
	self endon ( "disconnect" );
	self endon ( "killspec" );

	for(;;)
	{
		if(self.pers["team"] != "allies" && self.pers["team"] != "axis")
			break;

		for( i = 0; i < level.players.size; i++ )
			if( level.players[i].pers["team"] == "spectator" )
				level.players[i] setClientDvars( "shout_"+ self.pers["team"] + self.shoutNumber, self.name, "shout_"+ self.pers["team"] + "health" + self.shoutNumber, self.health / self.maxhealth );

		self thread setShoutClass();

		self waittill( "updateshoutcast" );
	}
}

resetShoutcast()
{
	self setClientDvars(	"shout_allies1", "",
							"shout_allies2", "",
							"shout_allies3", "",
							"shout_allies4", "",
							"shout_allies5", "",
							"shout_alliesclass1", "",
							"shout_alliesclass2", "",
							"shout_alliesclass3", "",
							"shout_alliesclass4", "",
							"shout_alliesclass5", "",
							"shout_allieshealth1", "",
							"shout_allieshealth2", "",
							"shout_allieshealth3", "",
							"shout_allieshealth4", "",
							"shout_allieshealth5", "",
							"shout_axis1", "",
							"shout_axis2", "",
							"shout_axis3", "",
							"shout_axis4", "",
							"shout_axis5", "",
							"shout_axisclass1", "",
							"shout_axisclass2", "",
							"shout_axisclass3", "",
							"shout_axisclass4", "",
							"shout_axisclass5", "",
							"shout_axishealth1", "",
							"shout_axishealth2", "",
							"shout_axishealth3", "",
							"shout_axishealth4", "",
							"shout_axishealth5", "" );

	wait 0.05;

	if ( isDefined( self ) )
		thread assignShoutID();
}

assignShoutID()
{
	self endon ( "disconnect" );

	axisNum = 0;
	alliesNum = 0;
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( ( player.pers["team"] == "allies" || player.pers["team"] == "axis" ) && isDefined( player.pers["class"] ) )
		{
			if( player.pers["team"] == "axis" )
			{
				axisNum++;
				player.shoutNumber = axisNum;
			}
			else if( player.pers["team"] == "allies" )
			{
				alliesNum++;
				player.shoutNumber = alliesNum;
			}

			wait 0.05;

			player notify( "updateshoutcast" );
		}
	}
}

setShoutClass()
{
	if ( !isDefined( self.shoutNumber ) || !isDefined( self.curClass ) )
		return;

	for( i = 0; i < level.players.size; i++ )
	{
		if( level.players[i].pers["team"] == "spectator" )
			level.players[i] setClientDvar( "shout_"+ self.pers["team"] + "class" + self.shoutNumber, maps\mp\gametypes\_quickmessages::chooseClassName(self.curClass) );
	}
}