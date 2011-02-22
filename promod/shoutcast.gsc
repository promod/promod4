/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	self endon ( "disconnect" );
	self endon ( "killspec" );
	self endon ( "spawned_player" );

	for(;;)
	{
		self waittill( "updateshoutcast" );

		if(self.pers["team"] != "allies" && self.pers["team"] != "axis")
			break;

		for( i = 0; i < level.players.size; i++ )
			if( level.players[i].pers["team"] == "spectator" )
				level.players[i] setClientDvars( "shout_"+ self.pers["team"] + self.shoutNumber, self.name, "shout_"+ self.pers["team"] + "health" + self.shoutNumber, self.health / self.maxhealth );
	}
}

resetShoutcast()
{
	for ( i = 1; i < 6; i++ )
	{
		self setClientDvars("shout_allies" + i, "",
							"shout_alliesclass" + i, "",
							"shout_allieshealth" + i, "",
							"shout_axis" + i, "",
							"shout_axisclass" + i, "",
							"shout_axishealth" + i, "",
							"shout_spec" + i, "");
	}

	assignShoutID();
	setShoutClass();
}

assignShoutID()
{
	axisNum = 0;
	alliesNum = 0;

	players = getentarray("player", "classname");
	for( i = 0; i < players.size; i++ )
	{
		if( isDefined( players[i] ) && isDefined( players[i].pers["class"] ) && isDefined( players[i].pers["team"] ) && ( players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis" ) )
		{
			if( players[i].pers["team"] == "axis" )
			{
				axisNum++;
				players[i].shoutNumber = axisNum;
			}
			else if( players[i].pers["team"] == "allies" )
			{
				alliesNum++;
				players[i].shoutNumber = alliesNum;
			}

			wait 0.05;

			players[i] notify( "updateshoutcast" );
		}
	}

	waittillframeend;

	num = 0;
	players = getentarray("player", "classname");
	for ( i = 0; i < players.size; i++ )
	{
		if( players[i].pers["team"] == "spectator" )
		{
			num++;
			players[i].specNumber = num;
			players[i].shoutNumber = undefined;

			for ( j = 0; j < players.size; j++ )
				if( players[j].pers["team"] == "spectator" )
					players[j] setClientDvar( "shout_spec" + num, players[i].name );
		}
	}
}

setShoutClass()
{
	wait 0.2;

	players = getentarray("player", "classname");
	for( i = 0; i < players.size; i++ )
	{
		if ( isDefined( players[i].shoutNumber ) && isDefined( players[i].curClass ) )
		{
			players = getentarray("player", "classname");
			for( j = 0; j < players.size; j++ )
				if( players[j].pers["team"] == "spectator" )
					players[j] setClientDvar( "shout_"+ players[i].pers["team"] + "class" + players[i].shoutNumber, maps\mp\gametypes\_quickmessages::chooseClassName( players[i].curClass ) );
		}
	}
}