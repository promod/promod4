/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	thread Server_DVAR_Monitor();
	thread Gametype_DVAR_Monitors();
}

Server_DVAR_Monitor()
{
	o_fftype = getDvarInt("scr_team_fftype");
	o_player_numlives = getDvarInt("scr_player_numlives");
	o_bg_fallDamageMinHeight = getDvarInt("bg_fallDamageMinHeight");
	o_bg_fallDamageMaxHeight = getDvarInt("bg_fallDamageMaxHeight");
	o_hiticon = getDvarInt("scr_enable_hiticon");
	o_forceuav = getDvarInt("scr_game_forceuav");
	o_assault_allowdrop = getDvarInt("class_assault_allowdrop");
	o_assault_limit = getDvarInt("class_assault_limit");
	o_demolitions_allowdrop = getDvarInt("class_demolitions_allowdrop");
	o_demolitions_limit = getDvarInt("class_demolitions_limit");
	o_sniper_allowdrop = getDvarInt("class_sniper_allowdrop");
	o_sniper_limit = getDvarInt("class_sniper_limit");
	o_specops_allowdrop = getDvarInt("class_specops_allowdrop");
	o_specops_limit = getDvarInt("class_specops_limit");
	o_killcam = getDvarInt("scr_game_allowkillcam");
	o_drawfriend = getDvarInt("scr_drawfriend");
	o_spectatetype = getDvarInt("scr_game_spectatetype");
	o_timelimit = getDvarFloat("scr_" + level.gametype + "_timelimit");
	o_numlives = getDvarFloat("scr_" + level.gametype + "_numlives");
	o_playernumlives = getDvarInt("scr_player_numlives");
	o_playerrespawndelay = getDvarFloat("scr_" + level.gametype + "_playerrespawndelay");
	o_roundlimit = getDvarFloat("scr_" + level.gametype + "_roundlimit");
	o_scorelimit = getDvarFloat("scr_" + level.gametype + "_scorelimit");
	o_waverespawndelay = getDvarFloat("scr_" + level.gametype + "_waverespawndelay");
	o_hardcore = getDvarInt("scr_hardcore");

	while (1)
	{
		wait 1.5;

		fftype = getDvarInt("scr_team_fftype");
		if (o_fftype != fftype)
			o_fftype = dVar_Changed("scr_team_fftype", fftype);

		player_numlives = getDvarInt("scr_player_numlives");
		if (o_player_numlives != player_numlives)
			o_player_numlives = dVar_Changed("scr_player_numlives", player_numlives);

		bg_fallDamageMinHeight = getDvarInt("bg_fallDamageMinHeight");
		if (o_bg_fallDamageMinHeight != bg_fallDamageMinHeight)
			o_bg_fallDamageMinHeight = dVar_Changed("bg_fallDamageMinHeight", bg_fallDamageMinHeight);

		bg_fallDamageMaxHeight = getDvarInt("bg_fallDamageMaxHeight");
		if (o_bg_fallDamageMaxHeight != bg_fallDamageMaxHeight)
			o_bg_fallDamageMaxHeight = dVar_Changed("bg_fallDamageMaxHeight", bg_fallDamageMaxHeight);

		hiticon = getDvarInt("scr_enable_hiticon");
		if (o_hiticon != hiticon)
			o_hiticon = dVar_Changed("scr_enable_hiticon", hiticon);

		forceuav = getDvarInt("scr_game_forceuav");
		if (o_forceuav != forceuav)
			o_forceuav = dVar_Changed("scr_game_forceuav", forceuav);

		assault_allowdrop = getDvarInt("class_assault_allowdrop");
		if (o_assault_allowdrop != assault_allowdrop)
			o_assault_allowdrop = dVar_Changed("class_assault_allowdrop", assault_allowdrop);

		assault_limit = getDvarInt("class_assault_limit");
		if (o_assault_limit != assault_limit)
			o_assault_limit = dVar_Changed("class_assault_limit", assault_limit);

		demolitions_allowdrop = getDvarInt("class_demolitions_allowdrop");
		if (o_demolitions_allowdrop != demolitions_allowdrop)
			o_demolitions_allowdrop = dVar_Changed("class_demolitions_allowdrop", demolitions_allowdrop);

		demolitions_limit = getDvarInt("class_demolitions_limit");
		if (o_demolitions_limit != demolitions_limit)
			o_demolitions_limit = dVar_Changed("class_demolitions_limit", demolitions_limit);

		sniper_allowdrop = getDvarInt("class_sniper_allowdrop");
		if (o_sniper_allowdrop != sniper_allowdrop)
			o_sniper_allowdrop = dVar_Changed("class_sniper_allowdrop", sniper_allowdrop);

		sniper_limit = getDvarInt("class_sniper_limit");
		if (o_sniper_limit != sniper_limit)
			o_sniper_limit = dVar_Changed("class_sniper_limit", sniper_limit);

		specops_allowdrop = getDvarInt("class_specops_allowdrop");
		if (o_specops_allowdrop != specops_allowdrop)
			o_specops_allowdrop = dVar_Changed("class_specops_allowdrop", specops_allowdrop);

		specops_limit = getDvarInt("class_specops_limit");
		if (o_specops_limit != specops_limit)
			o_specops_limit = dVar_Changed("class_specops_limit", specops_limit);

		killcam = getDvarInt("scr_game_allowkillcam");
		if (o_killcam != killcam)
			o_killcam = dVar_Changed("scr_game_allowkillcam", killcam);

		drawfriend = getDvarInt("scr_drawfriend");
		if (o_drawfriend != drawfriend)
			o_drawfriend = dVar_Changed("scr_drawfriend", drawfriend);

		spectatetype = getDvarInt("scr_game_spectatetype");
		if (o_spectatetype != spectatetype)
			o_spectatetype = dVar_Changed("scr_game_spectatetype", spectatetype);

		timelimit = getDvarFloat("scr_" + level.gametype + "_timelimit");
		if (o_timelimit != timelimit)
			o_timelimit = dVar_Changed("scr_" + level.gametype + "_timelimit", timelimit);

		numlives = getDvarInt("scr_" + level.gametype + "_numlives");
		if (o_numlives != numlives)
			o_numlives = dVar_Changed("scr_" + level.gametype + "_numlives", numlives);

		playernumlives = getDvarInt("scr_player_numlives");
		if (o_playernumlives != playernumlives)
			o_playernumlives = dVar_Changed("scr_player_numlives", playernumlives);

		playerrespawndelay = getDvarFloat("scr_" + level.gametype + "_playerrespawndelay");
		if (o_playerrespawndelay != playerrespawndelay)
			o_playerrespawndelay = dVar_Changed("scr_" + level.gametype + "_playerrespawndelay", playerrespawndelay);

		roundlimit = getDvarFloat("scr_" + level.gametype + "_roundlimit");
		if (o_roundlimit != roundlimit)
			o_roundlimit = dVar_Changed("scr_" + level.gametype + "_roundlimit", roundlimit);

		scorelimit = getDvarFloat("scr_" + level.gametype + "_scorelimit");
		if (o_scorelimit != scorelimit)
			o_scorelimit = dVar_Changed("scr_" + level.gametype + "_scorelimit", scorelimit);

		waverespawndelay = getDvarFloat("scr_" + level.gametype + "_waverespawndelay");
		if (o_waverespawndelay != waverespawndelay)
			o_waverespawndelay = dVar_Changed("scr_" + level.gametype + "_waverespawndelay", waverespawndelay);

		hardcore = getDvarInt("scr_hardcore");
		if (o_hardcore != hardcore)
			o_hardcore = dVar_Changed("scr_hardcore", hardcore);
	}
}

Gametype_DVAR_Monitors()
{
	switch (level.gametype)
	{
		case "sd":
			thread SD_DVAR_Monitor(); thread BOMB_DVAR_MONITOR(); thread RoundSwitch_DVAR_Monitor(); break;
		case "war":
			thread RoundSwitch_DVAR_Monitor(); break;
		case "sab":
			thread SAB_DVAR_Monitor(); thread BOMB_DVAR_MONITOR(); thread RoundSwitch_DVAR_Monitor(); break;
		case "koth":
			thread KOTH_DVAR_Monitor(); thread RoundSwitch_DVAR_Monitor(); break;
	}
}

SD_DVAR_Monitor()
{
	o_multibomb = getDvarInt("scr_sd_multibomb");

	while (1)
	{
		wait 1.5;

		multibomb = getDvarInt("scr_sd_multibomb");
		if (o_multibomb != multibomb)
			o_multibomb = dVar_Changed("scr_sd_multibomb", multibomb);
	}
}

SAB_DVAR_Monitor()
{
	o_hotpotato = getDvarInt("scr_sab_hotpotato");

	while (1)
	{
		wait 1.5;

		hotpotato = getDvarInt("scr_sab_hotpotato");
		if (o_hotpotato != hotpotato)
			o_hotpotato = dVar_Changed("scr_sab_hotpotato", hotpotato);
	}
}

BOMB_DVAR_MONITOR()
{
	o_bombtimer = getDvarFloat("scr_" + level.gametype + "_bombtimer");
	o_defusetime = getDvarFloat("scr_" + level.gametype + "_defusetime");
	o_planttime = getDvarFloat("scr_" + level.gametype + "_planttime");

	while (1)
	{
		wait 1.5;

		bombtimer = getDvarFloat("scr_" + level.gametype + "_bombtimer");
		if (o_bombtimer != bombtimer)
			o_bombtimer = dVar_Changed("scr_" + level.gametype + "_bombtimer", bombtimer);

		defusetime = getDvarFloat("scr_" + level.gametype + "_defusetime");
		if (o_defusetime != defusetime)
			o_defusetime = dVar_Changed("scr_" + level.gametype + "_defusetime", defusetime);

		planttime = getDvarFloat("scr_" + level.gametype + "_planttime");
		if (o_planttime != planttime)
			o_planttime = dVar_Changed("scr_" + level.gametype + "_planttime", planttime);
	}
}

KOTH_DVAR_Monitor()
{
	o_autodestroytime = getDvarFloat("koth_autodestroytime");
	o_capturetime = getDvarFloat("koth_capturetime");
	o_delayplayer = getDvarFloat("koth_delayplayer");
	o_destroytime = getDvarFloat("koth_destroytime");
	o_kothmode = getDvarFloat("koth_kothmode");
	o_spawndelay = getDvarFloat("koth_spawnDelay");
	o_spawntime = getDvarFloat("koth_spawntime");

	while (1)
	{
		wait 1.5;

		autodestroytime = getDvarFloat("koth_autodestroytime");
		if (o_autodestroytime != autodestroytime)
			o_autodestroytime = dVar_Changed("koth_autodestroytime", autodestroytime);

		capturetime = getDvarFloat("koth_capturetime");
		if (o_capturetime != capturetime)
			o_capturetime = dVar_Changed("koth_capturetime", capturetime);

		delayplayer = getDvarFloat("koth_delayPlayer");
		if (o_delayplayer != delayplayer)
			o_delayplayer = dVar_Changed("koth_delayplayer", delayplayer);

		destroytime = getDvarFloat("koth_destroytime");
		if (o_destroytime != destroytime)
			o_destroytime = dVar_Changed("koth_destroytime", destroytime);

		kothmode = getDvarFloat("koth_kothmode");
		if (o_kothmode != kothmode)
			o_kothmode = dVar_Changed("koth_kothmode", kothmode);

		spawndelay = getDvarFloat("koth_spawnDelay");
		if (o_spawndelay != spawndelay)
			o_spawndelay = dVar_Changed("koth_spawndelay", spawndelay);

		spawntime = getDvarFloat("koth_spawntime");
		if (o_spawntime != spawntime)
			o_spawntime = dVar_Changed("koth_spawntime", spawntime);
	}
}

RoundSwitch_DVAR_Monitor()
{
	o_roundswitch = getDvarInt("scr_" + level.gametype + "_roundswitch");

	while(1)
	{
		wait 1.5;
		roundswitch = getDvarInt("scr_" + level.gametype + "_roundswitch");
		if (o_roundswitch != roundswitch)
			o_roundswitch = dVar_Changed("scr_" + level.gametype + "_roundswitch", roundswitch);
	}
}

dVar_Changed(dvar, value)
{
	IPrintLn("^1Warning: ^3DVAR Change Detected: ^1" + dvar + " ^3--> ^1" + value);
		return value;
}