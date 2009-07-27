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

	for(;;)
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			shout_attack_team = self.pers["team"] == "allies";
			shout_defence_team = self.pers["team"] == "axis";
		}
		else
		{
			shout_attack_team = self.pers["team"] == "axis";
			shout_defence_team = self.pers["team"] == "allies";
		}

		health = self.health / self.maxhealth;

		if( shout_attack_team )
		{
			for( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if( player.pers["team"] == "spectator" )
				{
					player setClientDvar( "shout_allies" + self.shoutNumber, self.name );
					player setClientDvar( "shout_allieshealth" + self.shoutNumber, health );
				}
			}
		}
		else if( shout_defence_team )
		{
			for( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if( player.pers["team"] == "spectator" )
				{
					player setClientDvar( "shout_axis" + self.shoutNumber, self.name );
					player setClientDvar( "shout_axishealth" + self.shoutNumber, health );
				}
			}
		}

		self waittill( "updateshoutcast" );
	}
}

resetShoutcast()
{
	self setClientDvars(	"shout_allies1", "",
							"shout_allies2", "",
							"shout_allies3", "",
							"shout_allies4", "",
							"shout_allies5", "" );

	self setClientDvars(	"shout_allieshealth1", "",
							"shout_allieshealth2", "",
							"shout_allieshealth3", "",
							"shout_allieshealth4", "",
							"shout_allieshealth5", "" );

	self setClientDvars(	"shout_axis1", "",
							"shout_axis2", "",
							"shout_axis3", "",
							"shout_axis4", "",
							"shout_axis5", "" );

	self setClientDvars(	"shout_axishealth1", "",
							"shout_axishealth2", "",
							"shout_axishealth3", "",
							"shout_axishealth4", "",
							"shout_axishealth5", "" );

	wait 0.05;

	if ( isDefined( self ) )
		assignShoutID();
}

assignShoutID()
{
	self endon ( "disconnect" );

	axisNum = 0;
	alliesNum = 0;
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( player.pers["team"] == "allies" || player.pers["team"] == "axis" )
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