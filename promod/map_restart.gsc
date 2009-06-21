/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	Reset_Server_Vars();
	Reset_Player_Vars();
	Reset_Player_Stats();

	level notify ( "restarting" );
	map_restart( false );
}

Reset_Server_Vars()
{
	game["gamestarted"] = undefined;
	game["roundMillisecondsAlreadyPassed"] = undefined;
	game["timepassed"] = undefined;
	game["state"] = undefined;
	game["roundsplayed"] = undefined;
	game["tiebreaker"] = undefined;
	game["promod_do_readyup"] = undefined;
	game["promod_match_mode"] = undefined;
	game["promod_first_readyup_done"] = undefined;
}

Reset_Player_Vars()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player.pers["teamkills"] = undefined;
		player.pers["lives"] = undefined;
		player.pers["score"] = undefined;
		player.pers["team"] = undefined;
		player.pers["class"] = undefined;
		player.pers["weapon"] = undefined;
		player.pers["savedmodel"] = undefined;
		player.pers["deaths"] = undefined;
		player.pers["suicides"] = undefined;
		player.pers["headshots"] = undefined;
		player.pers["assists"] = undefined;
	}
}

Reset_Player_Stats()
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