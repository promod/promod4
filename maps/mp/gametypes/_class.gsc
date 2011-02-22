/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	level.primary_weapon_array = [];

	weapon_class_register( "m16_mp", "weapon_assault" );
	weapon_class_register( "m16_silencer_mp", "weapon_assault" );
	weapon_class_register( "ak47_mp", "weapon_assault" );
	weapon_class_register( "ak47_silencer_mp", "weapon_assault" );
	weapon_class_register( "m4_mp", "weapon_assault" );
	weapon_class_register( "m4_silencer_mp", "weapon_assault" );
	weapon_class_register( "g3_mp", "weapon_assault" );
	weapon_class_register( "g3_silencer_mp", "weapon_assault" );
	weapon_class_register( "g36c_mp", "weapon_assault" );
	weapon_class_register( "g36c_silencer_mp", "weapon_assault" );
	weapon_class_register( "m14_mp", "weapon_assault" );
	weapon_class_register( "m14_silencer_mp", "weapon_assault" );
	weapon_class_register( "mp44_mp", "weapon_assault" );
	weapon_class_register( "mp5_mp", "weapon_smg" );
	weapon_class_register( "mp5_silencer_mp", "weapon_smg" );
	weapon_class_register( "uzi_mp", "weapon_smg" );
	weapon_class_register( "uzi_silencer_mp", "weapon_smg" );
	weapon_class_register( "ak74u_mp", "weapon_smg" );
	weapon_class_register( "ak74u_silencer_mp", "weapon_smg" );
	weapon_class_register( "winchester1200_mp", "weapon_shotgun" );
	weapon_class_register( "m1014_mp", "weapon_shotgun" );
	weapon_class_register( "m40a3_mp", "weapon_sniper" );
	weapon_class_register( "remington700_mp", "weapon_sniper" );

	level thread onPlayerConnecting();
}

weapon_class_register( weapon, weapon_type )
{
	level.primary_weapon_array[weapon] = weapon_type;
}

giveLoadout( team, class )
{
	self takeAllWeapons();

	self setClass( class );

	sidearmWeapon = self.pers[class]["loadout_secondary"];

	if ( sidearmWeapon != "none" && sidearmWeapon != "deserteaglegold" && sidearmWeapon != "deserteagle" && sidearmWeapon != "colt45" && sidearmWeapon != "usp" && sidearmWeapon != "beretta" )
		sidearmWeapon = getDvar( "class_" + class + "_secondary" );

	if ( sideArmWeapon != "none" )
	{
		if ( self.pers[class]["loadout_secondary_attachment"] == "silencer" )
			sidearmWeapon = sidearmWeapon + "_silencer_mp";
		else
		{
			self.pers[class]["loadout_secondary_attachment"] = "none";
			sidearmWeapon = sidearmWeapon + "_mp";
		}

		self giveWeapon( sidearmWeapon );
		self giveMaxAmmo( sidearmWeapon );
	}

	primaryWeapon = self.pers[class]["loadout_primary"];

	if ( primaryWeapon != "none" && primaryWeapon != "m16" && primaryWeapon != "ak47" && primaryWeapon != "m4" && primaryWeapon != "g3" && primaryWeapon != "g36c" && primaryWeapon != "m14" && primaryWeapon != "mp44" && primaryWeapon != "mp5" && primaryWeapon != "uzi" && primaryWeapon != "ak74u" && primaryWeapon != "winchester1200" && primaryWeapon != "m1014" && primaryWeapon != "m40a3" && primaryWeapon != "remington700" )
		primaryWeapon = getDvar( "class_" + class + "_primary" );

	if ( !isDefined( self.pers[class]["loadout_camo"] ) )
		self.pers[class]["camo_num"] = 0;
	else if ( self.pers[class]["loadout_camo"] == "camo_brockhaurd" )
		self.pers[class]["camo_num"] = 1;
	else if ( self.pers[class]["loadout_camo"] == "camo_bushdweller" )
		self.pers[class]["camo_num"] = 2;
	else if ( self.pers[class]["loadout_camo"] == "camo_blackwhitemarpat" )
		self.pers[class]["camo_num"] = 3;
	else if ( self.pers[class]["loadout_camo"] == "camo_tigerred" )
		self.pers[class]["camo_num"] = 4;
	else if ( self.pers[class]["loadout_camo"] == "camo_stagger" )
		self.pers[class]["camo_num"] = 5;
	else if ( self.pers[class]["loadout_camo"] == "camo_gold" && ( primaryWeapon == "ak47" || primaryWeapon == "uzi" || primaryWeapon == "m1014" ) )
		self.pers[class]["camo_num"] = 6;
	else if ( self.pers[class]["loadout_camo"] == "camo_none" )
		self.pers[class]["camo_num"] = 0;
	else
	{
		self.pers[class]["loadout_camo"] = "camo_none";
		self.pers[class]["camo_num"] = 0;
	}

	if ( primaryWeapon != "none" )
	{
		if ( self.pers[class]["loadout_primary_attachment"] == "silencer" )
			primaryWeapon = primaryWeapon + "_silencer_mp";
		else
		{
			self.pers[class]["loadout_primary_attachment"] = "none";
			primaryWeapon = primaryWeapon + "_mp";
		}

		self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers[class]["loadout_primary"] );
		self giveWeapon( primaryWeapon, self.pers[class]["camo_num"] );
		self setSpawnWeapon( primaryWeapon );
		self giveMaxAmmo( primaryWeapon );
	}

	if ( getDvarInt( "weap_allow_frag_grenade" ) && ( isDefined( level.strat_over ) && level.strat_over || !isDefined( level.strat_over ) ) )
	{
		if ( level.hardcoreMode )
		{
			self giveWeapon( "frag_grenade_short_mp" );
			self setWeaponAmmoClip( "frag_grenade_short_mp", 1 );
			self switchToOffhand( "frag_grenade_short_mp" );
		}
		else
		{
			self giveWeapon( "frag_grenade_mp" );
			self setWeaponAmmoClip( "frag_grenade_mp", 1 );
			self switchToOffhand( "frag_grenade_mp" );
		}
	}

	if ( self.pers[class]["loadout_grenade"] != "none" && ( getDvarInt( "weap_allow_flash_grenade" ) || getDvarInt( "weap_allow_smoke_grenade" ) ) )
	{
		if ( self.pers[class]["loadout_grenade"] == "flash_grenade" && getDvarInt("weap_allow_flash_grenade") )
			self setOffhandSecondaryClass("flash");
		else if ( self.pers[class]["loadout_grenade"] == "smoke_grenade" && getDvarInt("weap_allow_smoke_grenade") )
			self setOffhandSecondaryClass("smoke");

		if ( isDefined( level.strat_over ) && level.strat_over || !isDefined( level.strat_over ) )
		{
			self giveWeapon( self.pers[class]["loadout_grenade"] + "_mp" );
			self setWeaponAmmoClip( self.pers[class]["loadout_grenade"] + "_mp", 1 );
		}
	}

	self setMoveSpeedScale( ( 1.0 - 0.05 * int( class == "assault" ) ) * !int( isDefined( level.strat_over ) && !level.strat_over ) );
}

preserveClass( class )
{
	CLASS_PRIMARY = "";
	CLASS_PRIMARY_ATTACHMENT = "";
	CLASS_SECONDARY = "";
	CLASS_SECONDARY_ATTACHMENT = "";
	CLASS_GRENADE = "";
	CLASS_CAMO = "";

	if ( class == "assault" )
	{
		CLASS_PRIMARY = "ASSAULT_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "ASSAULT_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "ASSAULT_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "ASSAULT_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "ASSAULT_GRENADE";
		CLASS_CAMO = "ASSAULT_CAMO";
	}
	else if ( class == "specops" )
	{
		CLASS_PRIMARY = "SPECOPS_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "SPECOPS_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "SPECOPS_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "SPECOPS_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "SPECOPS_GRENADE";
		CLASS_CAMO = "SPECOPS_CAMO";
	}
	else if ( class == "demolitions" )
	{
		CLASS_PRIMARY = "DEMOLITIONS_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "DEMOLITIONS_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "DEMOLITIONS_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "DEMOLITIONS_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "DEMOLITIONS_GRENADE";
		CLASS_CAMO = "DEMOLITIONS_CAMO";
	}
	else if ( class == "sniper" )
	{
		CLASS_PRIMARY = "SNIPER_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "SNIPER_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "SNIPER_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "SNIPER_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "SNIPER_GRENADE";
		CLASS_CAMO = "SNIPER_CAMO";
	}

	CLASS_PRIMARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary"], 0 ) );
	CLASS_PRIMARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary_attachment"], 0 ) );
	CLASS_SECONDARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary"], 0 ) );
	CLASS_SECONDARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary_attachment"], 0 ) );
	CLASS_GRENADE_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_grenade"], 0 ) );
	CLASS_CAMO_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_camo"], 0 ) );

	self set_config( CLASS_PRIMARY, CLASS_PRIMARY_VALUE );
	self set_config( CLASS_PRIMARY_ATTACHMENT, CLASS_PRIMARY_ATTACHMENT_VALUE );
	self set_config( CLASS_SECONDARY, CLASS_SECONDARY_VALUE );
	self set_config( CLASS_SECONDARY_ATTACHMENT, CLASS_SECONDARY_ATTACHMENT_VALUE );
	self set_config( CLASS_GRENADE, CLASS_GRENADE_VALUE );
	self set_config( CLASS_CAMO, CLASS_CAMO_VALUE );
}

set_config( dataName, value )
{
	self setStat( int( tableLookup( "promod/customStatsTable.csv", 1, dataName, 0 ) ), value );
}

onPlayerConnecting()
{
	for(;;)
	{
		level waittill( "connecting", player );

		if ( !isDefined( player.pers["class"] ) )
			player.pers["class"] = undefined;

		player.class = player.pers["class"];
	}
}

setClass( newClass )
{
	self setClientDvar( "loadout_curclass", newClass );
	self.curClass = newClass;

	thread promod\shoutcast::setShoutClass();
}

cac_modified_damage( victim, attacker, damage, meansofdeath )
{
	if( !isdefined( victim) || !isdefined( attacker ) || !isplayer( attacker ) || !isplayer( victim ) )
		return damage;
	if( attacker.sessionstate != "playing" || !isdefined( damage ) || !isdefined( meansofdeath ) )
		return damage;
	if( meansofdeath == "" )
		return damage;

	final_damage = damage;

	if( isPrimaryDamage( meansofdeath ) )
			final_damage = damage*1.4;

	return int( final_damage );
}

isPrimaryDamage( meansofdeath )
{
	if( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" )
		return true;
	return false;
}