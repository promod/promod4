/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include common_scripts\utility;
#include maps\mp\_utility;

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
	thread maps\mp\_entityheadicons::init();
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
		self thread watchGrenadeUsage();
		self thread watchWeaponChange();

		self.droppedDeathWeapon = undefined;
	}
}

watchWeaponChange()
{
	self endon("death");
	self endon("disconnect");

	self.lastDroppableWeapon = undefined;

	if ( mayDropWeapon( self getCurrentWeapon() ) )
		self.lastDroppableWeapon = self getCurrentWeapon();

	while(1)
	{
		self waittill( "weapon_change", newWeapon );

		if ( mayDropWeapon( newWeapon ) )
			self.lastDroppableWeapon = newWeapon;
	}
}

isHackWeapon( weapon )
{
	if ( weapon == "briefcase_bomb_mp" )
		return true;

	return false;
}

mayDropWeapon( weapon )
{
	if ( weapon == "none" )
		return false;

	if ( isHackWeapon( weapon ) )
		return false;

	invType = WeaponInventoryType( weapon );
	if ( invType != "primary" )
		return false;

	if ( weapon == "none" )
		return false;

	if ( !isPrimaryWeapon( weapon ) )
		return false;

	switch ( level.primary_weapon_array[weapon] )
	{
		case "weapon_assault":
			return ( getDvarInt( "class_assault_allowdrop" ) );
		case "weapon_smg":
			return ( getDvarInt( "class_specops_allowdrop" ) );
		case "weapon_sniper":
			return ( getDvarInt( "class_sniper_allowdrop" ) );
		case "weapon_shotgun":
			return ( getDvarInt( "class_demolitions_allowdrop" ) );
	}
	return false;
}

dropWeaponForDeath( attacker )
{
	weapon = self.lastDroppableWeapon;

	if ( isdefined( self.droppedDeathWeapon ) )
		return;

	if ( !isdefined( weapon ) )
		return;

	if ( weapon == "none" )
		return;

	if ( !self hasWeapon( weapon ) )
		return;

	if ( !(self AnyAmmoForWeaponModes( weapon )) )
		return;

	clipAmmo = self GetWeaponAmmoClip( weapon );

	if ( !clipAmmo )
		return;

	stockAmmo = self GetWeaponAmmoStock( weapon );
	stockMax = WeaponMaxAmmo( weapon );
	if ( stockAmmo > stockMax )
		stockAmmo = stockMax;

	item = self dropItem( weapon );

	self.droppedDeathWeapon = true;

	item ItemWeaponSetAmmo( clipAmmo, stockAmmo );

	item.owner = self;
	item.ownersattacker = attacker;

	item thread deletePickupAfterAWhile();
}

deletePickupAfterAWhile()
{
	self endon("death");

	wait 60;

	if ( !isDefined( self ) )
		return;

	self delete();
}

getItemWeaponName()
{
	classname = self.classname;
	assert( getsubstr( classname, 0, 7 ) == "weapon_" );
	weapname = getsubstr( classname, 7 );
	return weapname;
}

getWeaponBasedGrenadeCount(weapon)
{
	return 2;
}

getWeaponBasedSmokeGrenadeCount(weapon)
{
	return 1;
}

getFragGrenadeCount()
{
	if ( level.hardcoreMode )
		grenadetype = "frag_grenade_short_mp";
	else
		grenadetype = "frag_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}

getSmokeGrenadeCount()
{
	grenadetype = "smoke_grenade_mp";
	count = self getammocount(grenadetype);
	return count;
}

getFlashGrenadeCount()
{
	grenadetype = "flash_grenade_mp";
	count = self getammocount(grenadetype);
	return count;
}

friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
	if ( !isdefined(owner) )
		return true;

	if ( !level.teamBased )
		return true;

	friendlyFireRule = level.friendlyfire;
	if ( isdefined( forcedFriendlyFireRule ) )
		friendlyFireRule = forcedFriendlyFireRule;

	if ( friendlyFireRule != 0 )
		return true;

	if ( attacker == owner )
		return true;

	if (!isdefined(attacker.pers["team"]))
		return true;

	if ( attacker.pers["team"] != owner.pers["team"] )
		return true;

	return false;
}

watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.throwingGrenade = false;

	for ( ;; )
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

	startTime = getTime();

	self waittill ( "grenade_fire", grenade, weaponName );

	if ( weaponName == "frag_grenade_mp" || weaponName == "frag_grenade_short_mp" )
	{
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}

	self.throwingGrenade = false;
}

onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	switch( sWeapon )
	{
		default:
			maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
		break;
	}
}

isPrimaryWeapon( weaponname )
{
	return isdefined( level.primary_weapon_array[weaponname] );
}