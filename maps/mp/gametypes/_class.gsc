/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include common_scripts\utility;
// check if below includes are removable
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.classMap["assault_mp"] = "CLASS_ASSAULT";
	level.classMap["specops_mp"] = "CLASS_SPECOPS";
	level.classMap["demolitions_mp"] = "CLASS_DEMOLITIONS";
	level.classMap["sniper_mp"] = "CLASS_SNIPER";

	level.classMap["offline_class1_mp"] = "OFFLINE_CLASS1";
	level.classMap["offline_class2_mp"] = "OFFLINE_CLASS2";
	level.classMap["offline_class3_mp"] = "OFFLINE_CLASS3";
	level.classMap["offline_class4_mp"] = "OFFLINE_CLASS4";
	level.classMap["offline_class5_mp"] = "OFFLINE_CLASS5";
	level.classMap["offline_class6_mp"] = "OFFLINE_CLASS6";
	level.classMap["offline_class7_mp"] = "OFFLINE_CLASS7";
	level.classMap["offline_class8_mp"] = "OFFLINE_CLASS8";
	level.classMap["offline_class9_mp"] = "OFFLINE_CLASS9";
	level.classMap["offline_class10_mp"] = "OFFLINE_CLASS10";

	level.classMap["custom1"] = "CLASS_CUSTOM1";
	level.classMap["custom2"] = "CLASS_CUSTOM2";
	level.classMap["custom3"] = "CLASS_CUSTOM3";
	level.classMap["custom4"] = "CLASS_CUSTOM4";
	level.classMap["custom5"] = "CLASS_CUSTOM5";

	level.weapons["frag"] = "frag_grenade_mp";
	level.weapons["smoke"] = "smoke_grenade_mp";
	level.weapons["flash"] = "flash_grenade_mp";

	level.perkNames = [];
	level.perkIcons = [];

	initPerkData( "specialty_bulletdamage" );
	initPerkData( "specialty_extraammo" );

	// generating weapon type arrays which classifies the weapon as primary (back stow), pistol, or inventory (side pack stow)
	// using mp/statstable.csv's weapon grouping data ( numbering 0 - 149 )
	level.primary_weapon_array = [];
	level.side_arm_array = [];
	level.grenade_array = [];
	level.inventory_array = [];
	max_weapon_num = 149;
	for( i = 0; i < max_weapon_num; i++ )
	{
		weapon = tableLookup( "mp/statsTable.csv", 0, i, 4 );
		if ( !isDefined( weapon ) || weapon == "" )
			continue;

		weapon_type = tableLookup( "mp/statsTable.csv", 0, i, 2 );
		attachment = tableLookup( "mp/statsTable.csv", 0, i, 8 );

		weapon_class_register( weapon+"_mp", weapon_type );

		if( !isdefined( attachment ) || attachment == "" )
			continue;

		attachment_tokens = strTok( attachment, " " );
		if( !isDefined( attachment_tokens ) )
			continue;

		if( attachment_tokens.size == 0 )
		{
			weapon_class_register( weapon+"_"+attachment+"_mp", weapon_type );
		}
		else
		{
			// multiple attachment options
			for( k = 0; k < attachment_tokens.size; k++ )
				weapon_class_register( weapon+"_"+attachment_tokens[k]+"_mp", weapon_type );
		}
	}

	precacheShader( "waypoint_bombsquad" );

	level.tbl_CamoSkin = [];
	for( i=0; i<8; i++ )
	{
		// this for-loop is shared because there are equal number of attachments and camo skins.
		level.tbl_CamoSkin[i]["bitmask"] = int( tableLookup( "mp/attachmentTable.csv", 11, i, 10 ) );

		level.tbl_WeaponAttachment[i]["bitmask"] = int( tableLookup( "mp/attachmentTable.csv", 9, i, 10 ) );
		level.tbl_WeaponAttachment[i]["reference"] = tableLookup( "mp/attachmentTable.csv", 9, i, 4 );
	}

	level thread onPlayerConnecting();
}

initPerkData( perkRef )
{
	level.perkNames[perkRef] = tableLookupIString( "mp/statsTable.csv", 4, perkRef, 3 );
	level.perkIcons[perkRef] = tableLookup( "mp/statsTable.csv", 4, perkRef, 6 );
	precacheString( level.perkNames[perkRef] );
	precacheShader( level.perkIcons[perkRef] );
}

weapon_class_register( weapon, weapon_type )
{
	if( isSubstr( "weapon_smg weapon_assault weapon_projectile weapon_sniper weapon_shotgun weapon_lmg", weapon_type ) )
		level.primary_weapon_array[weapon] = weapon_type;
	else if( weapon_type == "weapon_pistol" )
		level.side_arm_array[weapon] = 1;
	else if( weapon_type == "weapon_grenade" )
		level.grenade_array[weapon] = 1;
	else if( weapon_type == "weapon_explosive" )
		level.inventory_array[weapon] = 1;
	else
		assertex( false, "Weapon group info is missing from statsTable for: " + weapon_type );
}

giveLoadout( team, class )
{
	self takeAllWeapons();

	self setClass( class );

	// hardcoded perks
	self.specialty = [];
	self.specialty[0] = "specialty_extraammo";
	self.specialty[1] = "specialty_bulletdamage";

	self register_perks();

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

	// give frag grenade
	if ( getDvarInt( "weap_allow_frag_grenade" ) )
	{
		if (isDefined( level.strat_over ) && level.strat_over || !isDefined( level.strat_over ) )
		{
			self giveWeapon( "frag_grenade_mp" );
			self setWeaponAmmoClip( "frag_grenade_mp", 1 );
			self switchToOffhand( "frag_grenade_mp" );
		}
	}

	// give special grenade
	if ( self.pers[class]["loadout_grenade"] != "none" && (getDvarInt("weap_allow_flash_grenade") || getDvarInt("weap_allow_smoke_grenade")) )
	{
		if ( self.pers[class]["loadout_grenade"] == "flash_grenade" && getDvarInt("weap_allow_flash_grenade") )
			self setOffhandSecondaryClass("flash");
		if ( self.pers[class]["loadout_grenade"] == "smoke_grenade" && getDvarInt("weap_allow_smoke_grenade") )
			self setOffhandSecondaryClass("smoke");

		if (isDefined( level.strat_over ) && level.strat_over || !isDefined( level.strat_over ) )
		{
			self giveWeapon( self.pers[class]["loadout_grenade"] + "_mp" );
			self setWeaponAmmoClip( self.pers[class]["loadout_grenade"] + "_mp", 1 );
		}
	}

	switch ( class )
	{
		case "assault":
			self setMoveSpeedScale( getDvarFloat( "class_assault_movespeed" ) );
			break;
		case "specops":
			self setMoveSpeedScale( getDvarFloat( "class_specops_movespeed" ) );
			break;
		case "demolitions":
			self setMoveSpeedScale( getDvarFloat( "class_demolitions_movespeed" ) );
			break;
		case "sniper":
			self setMoveSpeedScale( getDvarFloat( "class_sniper_movespeed" ) );
			break;
		default:
			self setMoveSpeedScale( 1.0 );
			break;
	}

	CLASS_PRIMARY = "";
	CLASS_PRIMARY_ATTACHMENT = "";
	CLASS_SECONDARY = "";
	CLASS_SECONDARY_ATTACHMENT = "";
	CLASS_GRENADE = "";
	CLASS_CAMO = "";

	CLASS_PRIMARY_VALUE = "";
	CLASS_PRIMARY_ATTACHMENT_VALUE = "";
	CLASS_SECONDARY_VALUE = "";
	CLASS_SECONDARY_ATTACHMENT_VALUE = "";
	CLASS_GRENADE_VALUE = "";
	CLASS_CAMO_VALUE = "";

	if ( class == "assault" )
	{
		CLASS_PRIMARY = "ASSAULT_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "ASSAULT_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "ASSAULT_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "ASSAULT_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "ASSAULT_GRENADE";
		CLASS_CAMO = "ASSAULT_CAMO";

		CLASS_PRIMARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary"], 0 ) );
		CLASS_PRIMARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary_attachment"], 0 ) );
		CLASS_SECONDARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary"], 0 ) );
		CLASS_SECONDARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary_attachment"], 0 ) );
		CLASS_GRENADE_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_grenade"], 0 ) );
		CLASS_CAMO_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_camo"], 0 ) );
	}
	else if ( class == "specops" )
	{
		CLASS_PRIMARY = "SPECOPS_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "SPECOPS_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "SPECOPS_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "SPECOPS_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "SPECOPS_GRENADE";
		CLASS_CAMO = "SPECOPS_CAMO";

		CLASS_PRIMARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary"], 0 ) );
		CLASS_PRIMARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary_attachment"], 0 ) );
		CLASS_SECONDARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary"], 0 ) );
		CLASS_SECONDARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary_attachment"], 0 ) );
		CLASS_GRENADE_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_grenade"], 0 ) );
		CLASS_CAMO_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_camo"], 0 ) );

	}
	else if ( class == "demolitions" )
	{
		CLASS_PRIMARY = "DEMOLITIONS_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "DEMOLITIONS_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "DEMOLITIONS_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "DEMOLITIONS_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "DEMOLITIONS_GRENADE";
		CLASS_CAMO = "DEMOLITIONS_CAMO";

		CLASS_PRIMARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary"], 0 ) );
		CLASS_PRIMARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary_attachment"], 0 ) );
		CLASS_SECONDARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary"], 0 ) );
		CLASS_SECONDARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary_attachment"], 0 ) );
		CLASS_GRENADE_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_grenade"], 0 ) );
		CLASS_CAMO_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_camo"], 0 ) );

	}
	else if ( class == "sniper" )
	{
		CLASS_PRIMARY = "SNIPER_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "SNIPER_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "SNIPER_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "SNIPER_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "SNIPER_GRENADE";
		CLASS_CAMO = "SNIPER_CAMO";

		CLASS_PRIMARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary"], 0 ) );
		CLASS_PRIMARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_primary_attachment"], 0 ) );
		CLASS_SECONDARY_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary"], 0 ) );
		CLASS_SECONDARY_ATTACHMENT_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_secondary_attachment"], 0 ) );
		CLASS_GRENADE_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_grenade"], 0 ) );
		CLASS_CAMO_VALUE = int( tablelookup( "promod/customStatsTable.csv", 1, self.pers[class]["loadout_camo"], 0 ) );

	}

	self set_config( CLASS_PRIMARY, CLASS_PRIMARY_VALUE );
	self set_config( CLASS_PRIMARY_ATTACHMENT, CLASS_PRIMARY_ATTACHMENT_VALUE );
	self set_config( CLASS_SECONDARY, CLASS_SECONDARY_VALUE );
	self set_config( CLASS_SECONDARY_ATTACHMENT, CLASS_SECONDARY_ATTACHMENT_VALUE );
	self set_config( CLASS_GRENADE, CLASS_GRENADE_VALUE );
	self set_config( CLASS_CAMO, CLASS_CAMO_VALUE );

	self maps\mp\gametypes\_class::cac_selector();
	return true;
}

set_config( dataName, value )
{
	self setStat( int( tableLookup( "promod/customStatsTable.csv", 1, dataName, 0 ) ), value );
}

setWeaponAmmoOverall( weaponname, amount )
{
	if ( isWeaponClipOnly( weaponname ) )
	{
		self setWeaponAmmoClip( weaponname, amount );
	}
	else
	{
		self setWeaponAmmoClip( weaponname, amount );
		diff = amount - self getWeaponAmmoClip( weaponname );
		assert( diff >= 0 );
		self setWeaponAmmoStock( weaponname, diff );
	}
}

onPlayerConnecting()
{
	for(;;)
	{
		level waittill( "connecting", player );

		if ( !isDefined( player.pers["class"] ) )
			player.pers["class"] = undefined;
		player.class = player.pers["class"];
		player.detectExplosives = false;
		player.bombSquadIcons = [];
		player.bombSquadIds = [];
	}
}

fadeAway( waitDelay, fadeDelay )
{
	wait waitDelay;

	self fadeOverTime( fadeDelay );
	self.alpha = 0;
}

setClass( newClass )
{
	self setClientDvar( "loadout_curclass", newClass );
	self.curClass = newClass;
}

cac_selector()
{
	for ( index = 0; index < self.bombSquadIcons.size; index++ )
		self.bombSquadIcons[index] destroy();

	self.bombSquadIcons = [];
}

register_perks()
{
	perks = self.specialty;
	self clearPerks();
	for( i=0; i<perks.size; i++ )
	{
		perk = perks[i];

		if ( perk != "specialty_extraammo" && perk != "specialty_bulletdamage" )
			continue;

		self setPerk( perk );
	}
}

cac_hasSpecialty( perk_reference )
{
	return_value = self hasPerk( perk_reference );
	return return_value;
}

cac_modified_damage( victim, attacker, damage, meansofdeath )
{
	// skip conditions
	if( !isdefined( victim) || !isdefined( attacker ) || !isplayer( attacker ) || !isplayer( victim ) )
		return damage;
	if( attacker.sessionstate != "playing" || !isdefined( damage ) || !isdefined( meansofdeath ) )
		return damage;
	if( meansofdeath == "" )
		return damage;

	old_damage = damage;
	final_damage = damage;

	// if attacker has bullet damage then increase bullet damage
	if( attacker cac_hasSpecialty( "specialty_bulletdamage" ) && isPrimaryDamage( meansofdeath ) )
			final_damage = damage*(100+40)/100; //hardcoded

	// return unchanged damage
	return int( final_damage );
}

// if primary weapon damage
isPrimaryDamage( meansofdeath )
{
	// including pistols as well since sometimes they share ammo
	if( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" )
		return true;
	return false;
}