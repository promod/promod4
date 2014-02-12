/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	precacheItem( "ak47_mp" );
	precacheItem( "ak47_silencer_mp" );
	precacheItem( "ak74u_mp" );
	precacheItem( "ak74u_silencer_mp" );
	precacheItem( "beretta_mp" );
	precacheItem( "beretta_silencer_mp" );
	precacheItem( "colt45_mp" );
	precacheItem( "colt45_silencer_mp" );
	precacheItem( "deserteagle_mp" );
	precacheItem( "deserteaglegold_mp" );
	precacheItem( "frag_grenade_mp" );
	precacheItem( "frag_grenade_short_mp" );
	precacheItem( "g3_mp" );
	precacheItem( "g3_silencer_mp" );
	precacheItem( "g36c_mp" );
	precacheItem( "g36c_silencer_mp" );
	precacheItem( "m4_mp" );
	precacheItem( "m4_silencer_mp" );
	precacheItem( "m14_mp" );
	precacheItem( "m14_silencer_mp" );
	precacheItem( "m16_mp" );
	precacheItem( "m16_silencer_mp" );
	precacheItem( "m40a3_mp" );
	precacheItem( "m1014_mp" );
	precacheItem( "mp5_mp" );
	precacheItem( "mp5_silencer_mp" );
	precacheItem( "mp44_mp" );
	precacheItem( "remington700_mp" );
	precacheItem( "usp_mp" );
	precacheItem( "usp_silencer_mp" );
	precacheItem( "uzi_mp" );
	precacheItem( "uzi_silencer_mp" );
	precacheItem( "winchester1200_mp" );
	precacheItem( "smoke_grenade_mp" );
	precacheItem( "flash_grenade_mp" );
	precacheItem( "destructible_car" );
	precacheShellShock( "default" );
	thread maps\mp\_flashgrenades::main();
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		self.hasDoneCombat = false;
		self thread watchWeaponUsage();
		self thread watchGrenadeUsage();
		self thread watchGrenadeAmmo();

		if(!isDefined(self.pers["shots"]))
			self.pers["shots"] = 0;
		self thread shotCounter();
	}
}

watchGrenadeAmmo()
{
	self endon("death");
	self endon("disconnect");
	self endon("game_ended");

	prim = true;
	sec = true;

	while(prim || sec)
	{
		self waittill("grenade_fire");

		if((isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"]) || (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat") || getDvarInt("sv_cheats"))
			break;

		wait 0.25; // 5 frames, ought to be enough

		pg = "";
		if(self hasWeapon("frag_grenade_mp"))
			pg = "frag_grenade_mp";
		else if(self hasWeapon("frag_grenade_short_mp"))
			pg = "frag_grenade_short_mp";
		else
			prim = false;

		sg = "";
		if(self hasWeapon("flash_grenade_mp"))
			sg = "flash_grenade_mp";
		else if(self hasWeapon("smoke_grenade_mp"))
			sg = "smoke_grenade_mp";
		else
			sec = false;

		if(prim && pg != "" && self GetAmmoCount(pg) < 1)
		{
			self TakeWeapon(pg);
			prim = false;
		}

		if(sec && sg != "" && self GetAmmoCount(sg) < 1)
		{
			self TakeWeapon(sg);
			sec = false;
		}
	}
}

shotCounter()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	for(;;)
	{
		self waittill("weapon_fired");
		if(!isDefined( level.rdyup ) || !level.rdyup)
			self.pers["shots"]++;
	}
}

printStats()
{
	if(isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "match" && isDefined(self.hasDoneCombat) && self.hasDoneCombat && isDefined(level.gameEnded) && !level.gameEnded && (!isDefined( game["promod_do_readyup"] ) || !game["promod_do_readyup"]))
		self iprintln("Can't display stats. Wait for the round to end.");
	else
	{
		if ( !isDefined( self.pers["damage_done"] ) )
			self.pers["damage_done"] = 0;

		if ( !isDefined( self.pers["damage_taken"] ) )
			self.pers["damage_taken"] = 0;

		if ( !isDefined( self.pers["friendly_damage_done"] ) )
			self.pers["friendly_damage_done"] = 0;

		if ( !isDefined( self.pers["friendly_damage_taken"] ) )
			self.pers["friendly_damage_taken"] = 0;

		if ( !isDefined( self.pers["shots"] ) )
			self.pers["shots"] = 0;

		if ( !isDefined( self.pers["hits"] ) )
			self.pers["hits"] = 0;

		// Log, print, reset
		if(self.pers["damage_done"] > 0 || self.pers["damage_taken"] > 0 || self.pers["friendly_damage_done"] > 0 || self.pers["friendly_damage_taken"] > 0 || self.pers["shots"] > 0 || self.pers["hits"] > 0)
			logPrint("P_A;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + ";" + self.pers["shots"] + ";" + self.pers["hits"] + ";" + self.pers["damage_done"] + ";" + self.pers["damage_taken"] + ";" + self.pers["friendly_damage_done"] + ";" + self.pers["friendly_damage_taken"] + "\n");

		self iprintln("^3" + self.name);
		self iprintln("Damage Done: ^2" + self.pers["damage_done"] + "^7 Damage Taken: ^1" + self.pers["damage_taken"]);
		if( level.teamBased )
			self iprintln("Friendly Damage Done: ^2" + self.pers["friendly_damage_done"] + "^7 Friendly Damage Taken: ^1" + self.pers["friendly_damage_taken"]);
		acc = 0;
		if(self.pers["shots"] > 0) // avoid division by 0
			acc = int(self.pers["hits"]/self.pers["shots"]*10000)/100;
		self iprintln("Shots Fired: ^2" + self.pers["shots"] + "^7 Shots Hit: ^2" + self.pers["hits"] + "^7 Accuracy: ^1" + acc + " pct");

		// Reset the stats afterwards
		self.pers["damage_done"] = 0;
		self.pers["damage_taken"] = 0;
		self.pers["friendly_damage_done"] = 0;
		self.pers["friendly_damage_taken"] = 0;
		self.pers["shots"] = 0;
		self.pers["hits"] = 0;
	}
}

dropWeaponForDeath( attacker )
{
	weapon = self getCurrentWeapon();

	if ( !isDefined( weapon ) || !self hasWeapon( weapon ) )
		return;

	switch ( weapon )
	{
		case "m16_mp":
		case "m16_silencer_mp":
		case "ak47_mp":
		case "ak47_silencer_mp":
		case "m4_mp":
		case "m4_silencer_mp":
		case "g3_mp":
		case "g3_silencer_mp":
		case "g36c_mp":
		case "g36c_silencer_mp":
		case "m14_mp":
		case "m14_silencer_mp":
		case "mp44_mp":
			if ( !getDvarInt( "class_assault_allowdrop" ) )
				return;
			break;
		case "mp5_mp":
		case "mp5_silencer_mp":
		case "uzi_mp":
		case "uzi_silencer_mp":
		case "ak74u_mp":
		case "ak74u_silencer_mp":
			if ( !getDvarInt( "class_specops_allowdrop" ) )
				return;
			break;
		case "m40a3_mp":
		case "remington700_mp":
			if ( !getDvarInt( "class_sniper_allowdrop" ) )
				return;
			break;
		case "winchester1200_mp":
		case "m1014_mp":
			if ( !getDvarInt( "class_demolitions_allowdrop" ) )
				return;
			break;
		default:
			return;
	}

	clipAmmo = self GetWeaponAmmoClip( weapon );

	if ( !clipAmmo )
		return;

	stockAmmo = self GetWeaponAmmoStock( weapon );
	stockMax = WeaponMaxAmmo( weapon );
	if ( stockAmmo > stockMax )
		stockAmmo = stockMax;

	item = self dropItem( weapon );

	item ItemWeaponSetAmmo( clipAmmo, stockAmmo );

	if( !isDefined(game["PROMOD_MATCH_MODE"]) || game["PROMOD_MATCH_MODE"] != "match" || (game["PROMOD_MATCH_MODE"] == "match" && level.gametype != "sd") || game["promod_do_readyup"] )
		item thread deletePickupAfterAWhile();
}

deletePickupAfterAWhile()
{
	self endon("death");

	wait 180;

	if ( !isDefined( self ) )
		return;

	self delete();
}

watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	self waittill ( "begin_firing" );
	self.hasDoneCombat = true;
}

watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.throwingGrenade = false;

	for(;;)
	{
		self waittill ( "grenade_pullback", weaponName );

		self.hasDoneCombat = true;
		self.throwingGrenade = true;
		self beginGrenadeTracking();
	}
}

beginGrenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	self waittill ( "grenade_fire", grenade, weaponName );

	if ( weaponName == "frag_grenade_mp" || weaponName == "frag_grenade_short_mp" )
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();

	self.throwingGrenade = false;
}

onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
}