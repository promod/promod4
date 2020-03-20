/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

giveLoadout( team, class )
{
	self takeAllWeapons();

	self setClientDvar( "loadout_curclass", class );
	self.curClass = class;
	if(isDefined(game["knife_end"]) && game["knife_end"] == 2 )return;
	sidearmWeapon();
	primaryWeapon();

	if(getDvarInt("weap_allow_frag_grenade") && (!isDefined( level.strat_over ) || level.strat_over))
	{
		s = "";
		if ( level.hardcoreMode )
			s = "_short";
		self giveWeapon( "frag_grenade"+s+"_mp" );
		self setWeaponAmmoClip( "frag_grenade"+s+"_mp", 1 );
		self switchToOffhand( "frag_grenade"+s+"_mp" );
	}

	gren = self.pers[class]["loadout_grenade"];
	if((gren == "flash_grenade" || gren == "smoke_grenade") && getDvarInt("weap_allow_"+gren))
	{
		self setOffhandSecondaryClass(GetSubStr(gren, 0, 5));
		if(!isDefined(level.strat_over) || level.strat_over)
		{
			self giveWeapon(gren+"_mp");
			self setWeaponAmmoClip(gren+"_mp", 1);
		}
	}

	self setMoveSpeedScale( ( 1.0 - 0.05 * int( class == "assault" ) ) * !int( isDefined( level.strat_over ) && !level.strat_over ) );
}

sidearmWeapon()
{
	class = self.pers["class"];
	sidearmWeapon = self.pers[class]["loadout_secondary"];

	if ( sidearmWeapon != "none" && sidearmWeapon != "deserteaglegold" && sidearmWeapon != "deserteagle" && sidearmWeapon != "colt45" && sidearmWeapon != "usp" && sidearmWeapon != "beretta" )
		sidearmWeapon = getDvar( "class_" + class + "_secondary" );

	if ( sideArmWeapon != "none" )
	{
		s = "";
		if ( self.pers[class]["loadout_secondary_attachment"] == "silencer" )
			s = "_silencer";
		else
			self.pers[class]["loadout_secondary_attachment"] = "none";

		sidearmWeapon += s+"_mp";

		if ( isDefined( level.strat_over ) && level.strat_over && ( !isDefined( game["PROMOD_KNIFEROUND"] ) || !game["PROMOD_KNIFEROUND"] ) || !isDefined( level.strat_over ) )
		{
			self giveWeapon( sidearmWeapon );
			self giveMaxAmmo( sidearmWeapon );
		}
	}
}

primaryWeapon()
{
	class = self.pers["class"];
	primaryWeapon = self.pers[class]["loadout_primary"];

	switch(primaryWeapon)
	{
		case "none":
		case "m16":
		case "ak47":
		case "m4":
		case "g3":
		case "g36c":
		case "m14":
		case "mp44":
		case "mp5":
		case "uzi":
		case "ak74u":
		case "winchester1200":
		case "m1014":
		case "m40a3":
		case "remington700":
			break;
		default:
			primaryWeapon = getDvar("class_"+class+"_primary");
	}

	camos = strtok("camo_brockhaurd|camo_bushdweller|camo_blackwhitemarpat|camo_tigerred|camo_stagger", "|");
	camonum = 0;

	if(isDefined(self.pers[class]["loadout_camo"]))
	{
		for(i=0;i<camos.size;i++)
			if(self.pers[class]["loadout_camo"] == camos[i])
			{
				camonum = i+1;
				break;
			}

		if(self.pers[class]["loadout_camo"] == "camo_gold" && (primaryWeapon == "ak47" || primaryWeapon == "uzi" || primaryWeapon == "m1014"))
			camonum = 6;
	}
	else
		self.pers[class]["loadout_camo"] = "camo_none";

	if(primaryWeapon != "none")
	{
		s = "";
		if(self.pers[class]["loadout_primary_attachment"] == "silencer")
			s = "_silencer";
		else
			self.pers[class]["loadout_primary_attachment"] = "none";

		primaryWeapon += s+"_mp";

		self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers[class]["loadout_primary"] );

		if ( isDefined( level.strat_over ) && level.strat_over && ( !isDefined( game["PROMOD_KNIFEROUND"] ) || !game["PROMOD_KNIFEROUND"] ) || !isDefined( level.strat_over ) )
		{
			self giveWeapon( primaryWeapon, camonum );
			self setSpawnWeapon( primaryWeapon );
			self giveMaxAmmo( primaryWeapon );
		}
	}
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