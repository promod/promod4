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
	precacheItem( "frag_grenade_short_mp" );
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

		player.usedWeapons = false;
		player.hits = 0;

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
		self thread watchWeaponChange();

		self.droppedDeathWeapon = undefined;
		self.tookWeaponFrom = [];

		self thread updateStowedWeapon();
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

isPistol( weapon )
{
	return isdefined( level.side_arm_array[ weapon ] );
}

isHackWeapon( weapon )
{
	if ( weapon == "radar_mp" || weapon == "airstrike_mp" || weapon == "helicopter_mp" )
		return true;
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
	return true;
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

	switch ( level.primary_weapon_array[weapon] )
	{
		case "weapon_sniper":
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

	self.droppedDeathWeapon = true;

	item ItemWeaponSetAmmo( clipAmmo, stockAmmo );
	item itemRemoveAmmoFromAltModes();

	item.owner = self;
	item.ownersattacker = attacker;

	item thread watchPickup();

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

watchPickup()
{
	self endon("death");

	weapname = self getItemWeaponName();

	while(1)
	{
		self waittill( "trigger", player, droppedItem );

		if ( isdefined( droppedItem ) )
			break;
		// otherwise, player merely acquired ammo and didn't pick this up
	}

	assert( isdefined( player.tookWeaponFrom ) );

	// make sure the owner information on the dropped item is preserved
	droppedWeaponName = droppedItem getItemWeaponName();
	if ( isdefined( player.tookWeaponFrom[ droppedWeaponName ] ) )
	{
		droppedItem.owner = player.tookWeaponFrom[ droppedWeaponName ];
		droppedItem.ownersattacker = player;
		player.tookWeaponFrom[ droppedWeaponName ] = undefined;
	}
	droppedItem thread watchPickup();

	// take owner information from self and put it onto player
	if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
	{
		player.tookWeaponFrom[ weapname ] = self.owner;
	}
	else
	{
		player.tookWeaponFrom[ weapname ] = undefined;
	}
}

itemRemoveAmmoFromAltModes()
{
	origweapname = self getItemWeaponName();

	curweapname = weaponAltWeaponName( origweapname );

	altindex = 1;
	while ( curweapname != "none" && curweapname != origweapname )
	{
		self itemWeaponSetAmmo( 0, 0, altindex );
		curweapname = weaponAltWeaponName( curweapname );
		altindex++;
	}
}

dropOffhand()
{
	grenadeTypes = [];

	for ( index = 0; index < grenadeTypes.size; index++ )
	{
		if ( !self hasWeapon( grenadeTypes[index] ) )
			continue;

		count = self getAmmoCount( grenadeTypes[index] );

		if ( !count )
			continue;

		self dropItem( grenadeTypes[index] );
	}
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

watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	self.firingWeapon = false;

	for ( ;; )
	{
		self waittill ( "begin_firing" );
		self.hasDoneCombat = true;
		self.firingWeapon = true;

		curWeapon = self getCurrentWeapon();

		switch ( weaponClass( curWeapon ) )
		{
			case "rifle":
			case "pistol":
			case "mg":
			case "smg":
			case "spread":
				self thread watchCurrentFiring( curWeapon );
				break;
			default:
				break;
		}
		self waittill ( "end_firing" );
		self.firingWeapon = false;
	}
}

watchCurrentFiring( curWeapon )
{
	self endon("disconnect");

	startAmmo = self getWeaponAmmoClip( curWeapon );

	self waittill ( "end_firing" );

	if ( !self hasWeapon( curWeapon ) )
		return;

	shotsFired = startAmmo - (self getWeaponAmmoClip( curWeapon )) + 1;

	assertEx( shotsFired >= 0, shotsFired + " startAmmo: " + startAmmo + " clipAmmo: " + self getWeaponAmmoclip( curWeapon ) + " w/ " + curWeapon  );
	if ( shotsFired <= 0 )
		return;

	if ( isDefined( level.rdyup ) && level.rdyup || isDefined( level.strat_over ) && !level.strat_over )
	{
		self.hits = 0;
		return;
	}

	if ( !isDefined( self.pers["total"] ) )
		self.pers["total"] = 0;

	if ( !isDefined( self.pers["hits"] ) )
		self.pers["hits"] = 0;

	self.pers["total"] = self.pers["total"] + shotsFired;
	self.pers["hits"] = self.pers["hits"] + self.hits;

	self.pers["accuracy"] = int(self.pers["hits"] * 100 / self.pers["total"] );
	self.hits = 0;
}

checkHit( sWeapon )
{
	switch ( weaponClass( sWeapon ) )
	{
		case "rifle":
		case "pistol":
		case "mg":
		case "smg":
			self.hits++;
			break;
		case "spread":
			self.hits = 1;
			break;
		default:
			break;
	}
}

// returns true if damage should be done to the item given its owner and the attacker
friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
	if ( !isdefined(owner) ) // owner has disconnected? allow it
		return true;

	if ( !level.teamBased ) // not a team based mode? allow it
		return true;

	friendlyFireRule = level.friendlyfire;
	if ( isdefined( forcedFriendlyFireRule ) )
		friendlyFireRule = forcedFriendlyFireRule;

	if ( friendlyFireRule != 0 ) // friendly fire is on? allow it
		return true;

	if ( attacker == owner ) // owner may attack his own items
		return true;

	if (!isdefined(attacker.pers["team"])) // attacker not on a team? allow it
		return true;

	if ( attacker.pers["team"] != owner.pers["team"] ) // attacker not on the same team as the owner? allow it
		return true;

	return false; // disallow it
}

watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.throwingGrenade = false;
	self.gotPullbackNotify = false;

	self thread watchForThrowbacks();

	for ( ;; )
	{
		self waittill ( "grenade_pullback", weaponName );

		self.hasDoneCombat = true;

		if ( weaponName == "claymore_mp" )
			continue;

		self.throwingGrenade = true;
		self.gotPullbackNotify = true;

		self beginGrenadeTracking();
	}
}

beginGrenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	startTime = getTime();

	self waittill ( "grenade_fire", grenade, weaponName );

	if ( (getTime() - startTime > 1000) )
		grenade.isCooked = true;

	if ( weaponName == "frag_grenade_mp" )
	{
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}

	self.throwingGrenade = false;
}

watchForThrowbacks()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for ( ;; )
	{
		self waittill ( "grenade_fire", grenade, weapname );
		if ( self.gotPullbackNotify )
		{
			self.gotPullbackNotify = false;
			continue;
		}
		if ( !isSubStr( weapname, "frag_" ) )
			continue;

		// no grenade_pullback notify! we must have picked it up off the ground.
		grenade.threwBack = true;

		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}
}

onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	switch( sWeapon )
	{
		default:
			// shellshock will only be done if meansofdeath is an appropriate type and if there is enough damage.
			maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
		break;
	}
}

// weapon stowing logic ===================================================================

// weapon class boolean helpers
isPrimaryWeapon( weaponname )
{
	return isdefined( level.primary_weapon_array[weaponname] );
}

isSideArm( weaponname )
{
	return isdefined( level.side_arm_array[weaponname] );
}

isInventory( weaponname )
{
	return isdefined( level.inventory_array[weaponname] );
}

isGrenade( weaponname )
{
	return isdefined( level.grenade_array[weaponname] );
}

getWeaponClass_array( current )
{
	if( isPrimaryWeapon( current ) )
		return level.primary_weapon_array;
	else if( isSideArm( current ) )
		return level.side_arm_array;
	else if( isGrenade( current ) )
		return level.grenade_array;
	else
		return level.inventory_array;
}

// thread loop life = player's life
updateStowedWeapon()
{
	self endon( "spawned" );
	self endon( "killed_player" );
	self endon( "disconnect" );

	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;

	team = self.pers["team"];
	class = self.pers["class"];

	while ( true )
	{
		self waittill( "weapon_change", newWeapon );

		// weapon array reset, might have swapped weapons off the ground
		self.weapon_array_primary =[];
		self.weapon_array_sidearm = [];
		self.weapon_array_grenade = [];
		self.weapon_array_inventory =[];

		// populate player's weapon stock arrays
		weaponsList = self GetWeaponsList();
		for( idx = 0; idx < weaponsList.size; idx++ )
		{
			if ( isPrimaryWeapon( weaponsList[idx] ) )
				self.weapon_array_primary[self.weapon_array_primary.size] = weaponsList[idx];
			else if ( isSideArm( weaponsList[idx] ) )
				self.weapon_array_sidearm[self.weapon_array_sidearm.size] = weaponsList[idx];
			else if ( isGrenade( weaponsList[idx] ) )
				self.weapon_array_grenade[self.weapon_array_grenade.size] = weaponsList[idx];
			else if ( isInventory( weaponsList[idx] ) )
				self.weapon_array_inventory[self.weapon_array_inventory.size] = weaponsList[idx];
		}

		detach_all_weapons();
		stow_on_back();
		stow_on_hip();
	}
}

detach_all_weapons()
{
	if( isDefined( self.tag_stowed_back ) )
	{
		self detach( self.tag_stowed_back, "tag_stowed_back" );
		self.tag_stowed_back = undefined;
	}
	if( isDefined( self.tag_stowed_hip ) )
	{
		detach_model = getWeaponModel( self.tag_stowed_hip );
		self detach( detach_model, "tag_stowed_hip_rear" );
		self.tag_stowed_hip = undefined;
	}
}

stow_on_back()
{
	current = self getCurrentWeapon();

	self.tag_stowed_back = undefined;

	// large projectile weaponry always show
	if ( self hasWeapon( "rpg_mp" ) && current != "rpg_mp" )
	{
		self.tag_stowed_back = "weapon_rpg7_stow";
	}
	else
	{
		for ( idx = 0; idx < self.weapon_array_primary.size; idx++ )
		{
			index_weapon = self.weapon_array_primary[idx];
			assertex( isdefined( index_weapon ), "Primary weapon list corrupted." );

			if ( index_weapon == current )
				continue;

			if( isSubStr( current, "gl_" ) || isSubStr( index_weapon, "gl_" ) )
			{
				index_weapon_tok = strtok( index_weapon, "_" );
				current_tok = strtok( current, "_" );
				// finding the alt-mode of current weapon; the tokens of both weapons are subsets of each other
				for( i=0; i<index_weapon_tok.size; i++ )
				{
					if( !isSubStr( current, index_weapon_tok[i] ) || index_weapon_tok.size != current_tok.size )
					{
						i = 0;
						break;
					}
				}
				if( i == index_weapon_tok.size )
					continue;
			}
				self.tag_stowed_back = getWeaponModel( index_weapon, 0 );
		}
	}

	if ( !isDefined( self.tag_stowed_back ) )
		return;

	self attach( self.tag_stowed_back, "tag_stowed_back", true );
}

stow_on_hip()
{
	current = self getCurrentWeapon();

	self.tag_stowed_hip = undefined;

	for ( idx = 0; idx < self.weapon_array_inventory.size; idx++ )
	{
		if ( self.weapon_array_inventory[idx] == current )
			continue;

		if ( !self GetWeaponAmmoStock( self.weapon_array_inventory[idx] ) )
			continue;

		self.tag_stowed_hip = self.weapon_array_inventory[idx];
	}

	if ( !isDefined( self.tag_stowed_hip ) )
		return;

	weapon_model = getWeaponModel( self.tag_stowed_hip );
	self attach( weapon_model, "tag_stowed_hip_rear", true );
}

stow_inventory( inventories, current )
{
	// deatch last weapon attached
	if( isdefined( self.inventory_tag ) )
	{
		detach_model = getweaponmodel( self.inventory_tag );
		self detach( detach_model, "tag_stowed_hip_rear" );
		self.inventory_tag = undefined;
	}

	if( !isdefined( inventories[0] ) || self GetWeaponAmmoStock( inventories[0] ) == 0 )
		return;

	if( inventories[0] != current )
	{
		self.inventory_tag = inventories[0];
		weapon_model = getweaponmodel( self.inventory_tag );
		self attach( weapon_model, "tag_stowed_hip_rear", true );
	}
}