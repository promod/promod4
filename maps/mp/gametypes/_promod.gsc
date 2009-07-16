/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	level.serverDvars = [];

	// classes
	setServerDvarDefault( "class_assault_limit", 64, 0, 64 );
	setServerDvarDefault( "class_specops_limit", 2, 0, 64 );
	setServerDvarDefault( "class_demolitions_limit", 1, 0, 64 );
	setServerDvarDefault( "class_sniper_limit", 1, 0, 64 );

	setDvarDefault( "class_assault_allowdrop", 1, 0, 1 );
	setDvarDefault( "class_specops_allowdrop", 1, 0, 1 );
	setDvarDefault( "class_demolitions_allowdrop", 0, 0, 1 );
	setDvarDefault( "class_sniper_allowdrop", 0, 0, 1 );

	// assault rifles
	setDvarDefault( "weap_allow_m16", 1, 0, 1 );
	setDvarDefault( "weap_allow_ak47", 1, 0, 1 );
	setDvarDefault( "weap_allow_m4", 1, 0, 1 );
	setDvarDefault( "weap_allow_g3", 1, 0, 1 );
	setDvarDefault( "weap_allow_g36c", 1, 0, 1 );
	setDvarDefault( "weap_allow_m14", 1, 0, 1 );
	setDvarDefault( "weap_allow_mp44", 1, 0, 1 );

	// assault attachments
	setDvarDefault( "attach_allow_assault_none", 1, 0, 1 );
	setDvarDefault( "attach_allow_assault_silencer", 1, 0, 1 );

	// smgs
	setDvarDefault( "weap_allow_mp5", 1, 0, 1 );
	setDvarDefault( "weap_allow_uzi", 1, 0, 1 );
	setDvarDefault( "weap_allow_ak74u", 1, 0, 1 );

	// smg attachments
	setDvarDefault( "attach_allow_smg_none", 1, 0, 1 );
	setDvarDefault( "attach_allow_smg_silencer", 1, 0, 1 );

	// shotguns
	setDvarDefault( "weap_allow_m1014", 1, 0, 1 );
	setDvarDefault( "weap_allow_winchester1200", 1, 0, 1 );

	// sniper rifles
	setDvarDefault( "weap_allow_m40a3", 1, 0, 1 );
	setDvarDefault( "weap_allow_remington700", 1, 0, 1 );

	// pistols
	setServerDvarDefault( "weap_allow_beretta", 1, 0, 1 );
	setServerDvarDefault( "weap_allow_colt45", 1, 0, 1 );
	setServerDvarDefault( "weap_allow_usp", 1, 0, 1 );
	setServerDvarDefault( "weap_allow_deserteagle", 1, 0, 1 );
	setServerDvarDefault( "weap_allow_deserteaglegold", 1, 0, 1 );

	// pistol attachments
	setServerDvarDefault( "attach_allow_pistol_none", 1, 0, 1 );
	setServerDvarDefault( "attach_allow_pistol_silencer", 1, 0, 1 );

	// grenades
	setServerDvarDefault( "weap_allow_frag_grenade", 1, 0, 1 );
	setServerDvarDefault( "weap_allow_flash_grenade", 1, 0, 1 );
	setServerDvarDefault( "weap_allow_smoke_grenade", 1, 0, 1 );

	// client menu only
	setServerDvarDefault( "allies_allow_assault", 1, 0, 1 );
	setServerDvarDefault( "allies_allow_specops", 1, 0, 1 );
	setServerDvarDefault( "allies_allow_demolitions", 1, 0, 1 );
	setServerDvarDefault( "allies_allow_sniper", 1, 0, 1 );
	setServerDvarDefault( "axis_allow_assault", 1, 0, 1 );
	setServerDvarDefault( "axis_allow_specops", 1, 0, 1 );
	setServerDvarDefault( "axis_allow_demolitions", 1, 0, 1 );
	setServerDvarDefault( "axis_allow_sniper", 1, 0, 1 );

	// assault class default loadout
	setDvarDefault( "class_assault_primary", "ak47" );
	setDvarDefault( "class_assault_primary_attachment", "none" );
	setDvarDefault( "class_assault_secondary", "deserteagle" );
	setDvarDefault( "class_assault_secondary_attachment", "none" );
	setDvarDefault( "class_assault_grenade", "smoke_grenade" );
	setDvarDefault( "class_assault_camo", "camo_none" );

	// specops class default loadout
	setDvarDefault( "class_specops_primary", "ak74u" );
	setDvarDefault( "class_specops_primary_attachment", "none" );
	setDvarDefault( "class_specops_secondary", "deserteagle" );
	setDvarDefault( "class_specops_secondary_attachment", "none" );
	setDvarDefault( "class_specops_grenade", "smoke_grenade" );
	setDvarDefault( "class_specops_camo", "camo_none" );

	// demolitions class default loadout
	setDvarDefault( "class_demolitions_primary", "winchester1200" );
	setDvarDefault( "class_demolitions_primary_attachment", "none" );
	setDvarDefault( "class_demolitions_secondary", "deserteagle" );
	setDvarDefault( "class_demolitions_secondary_attachment", "none" );
	setDvarDefault( "class_demolitions_grenade", "smoke_grenade" );
	setDvarDefault( "class_demolitions_camo", "camo_none" );

	// sniper class default loadout
	setDvarDefault( "class_sniper_primary", "m40a3" );
	setDvarDefault( "class_sniper_primary_attachment", "none" );
	setDvarDefault( "class_sniper_secondary", "deserteagle" );
	setDvarDefault( "class_sniper_secondary_attachment", "none" );
	setDvarDefault( "class_sniper_grenade", "smoke_grenade" );
	setDvarDefault( "class_sniper_camo", "camo_none" );

	setDvarDefault( "scr_enable_hiticon", 2, 0, 2 );
	setDvarDefault( "scr_enable_scoretext", 1, 0, 1 );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );
		player thread updateServerDvars();
	}
}

releaseClass( teamName, classType )
{
	game[teamName + "_" + classType + "_count"]--;
	updateClassAvailability( teamName, classType );
	//println("^1releaseClass;" + " TEAM; " + teamName + "; classType; " + classType + " ^7" + "ALLIES: " + game["allies_assault_count"] + " " + game["allies_specops_count"] + " " + game["allies_demolitions_count"] + " " + game["allies_sniper_count"] + " " + "AXIS: " + game["axis_assault_count"] + " " + game["axis_specops_count"] + " " + game["axis_demolitions_count"] + " " + game["axis_sniper_count"] );
}

claimClass( teamName, classType )
{
	game[teamName + "_" + classType + "_count"]++;
	updateClassAvailability( teamName, classType );
	//println("^2claimClass;" + " TEAM; " + teamName + "; classType; " + classType + " ^7" + "ALLIES: " + game["allies_assault_count"] + " " + game["allies_specops_count"] + " " + game["allies_demolitions_count"] + " " + game["allies_sniper_count"] + " " + "AXIS: " + game["axis_assault_count"] + " " + game["axis_specops_count"] + " " + game["axis_demolitions_count"] + " " + game["axis_sniper_count"] );
}

setClassChoice( classType )
{
	if ( !isDefined( self.curClass ) )
		self maps\mp\gametypes\_promod::claimClass( self.pers["team"], classType );

	if ( isDefined( self.curClass ) && self.curClass != classType )
		self releaseClass( self.pers["team"], self.curClass );

	if ( isDefined( self.curClass ) && self.curClass != classType )
		self claimClass( self.pers["team"], classType );

	self.pers["class"] = classType;
	self.class = classType;
	self.curClass = classType;

	self setClientDvar( "loadout_class", classType );
	self setDvarsFromClass( classType );

	switch ( classType )
	{
		case "assault":
			self setClientDvars(
					"weap_allow_m16", getDvar( "weap_allow_m16" ),
					"weap_allow_ak47", getDvar( "weap_allow_ak47" ),
					"weap_allow_m4", getDvar( "weap_allow_m4" ),
					"weap_allow_g3", getDvar( "weap_allow_g3" ),
					"weap_allow_g36c", getDvar( "weap_allow_g36c" ),
					"weap_allow_m14", getDvar( "weap_allow_m14" ),
					"weap_allow_mp44", getDvar( "weap_allow_mp44" ),
					"attach_allow_assault_none", getDvar( "attach_allow_assault_none" ),
					"attach_allow_assault_silencer", getDvar( "attach_allow_assault_silencer" ) );
			break;
		case "specops":
			self setClientDvars(
					"weap_allow_mp5", getDvar( "weap_allow_mp5" ),
					"weap_allow_uzi", getDvar( "weap_allow_uzi" ),
					"weap_allow_ak74u", getDvar( "weap_allow_ak74u" ),
					"attach_allow_smg_none", getDvar( "attach_allow_smg_none" ),
					"attach_allow_smg_silencer", getDvar( "attach_allow_smg_silencer" ) );
			break;
		case "demolitions":
			self setClientDvars(
					"weap_allow_m1014", getDvar( "weap_allow_m1014" ),
					"weap_allow_winchester1200", getDvar( "weap_allow_winchester1200" ) );
			break;
		case "sniper":
			self setClientDvars(
					"weap_allow_m40a3", getDvar( "weap_allow_m40a3" ),
					"weap_allow_remington700", getDvar( "weap_allow_remington700" ) );
			break;
	}
}

setDvarWrapper( dvarName, setVal )
{
	setDvar( dvarName, setVal );
	if ( isDefined( level.serverDvars[dvarName] ) )
	{
		level.serverDvars[dvarName] = setVal;
		players = level.players;
		for ( index = 0; index < level.players.size; index++ )
			players[index] setClientDvar( dvarName, setVal );
	}
}

setDvarDefault( dvarName, setVal, minVal, maxVal )
{
	// no value set
	if ( getDvar( dvarName ) != "" )
	{
		if ( isString( setVal ) )
			setVal = getDvar( dvarName );
		else
			setVal = getDvarFloat( dvarName );
	}

	if ( isDefined( minVal ) && !isString( setVal ) )
		setVal = max( setVal, minVal );

	if ( isDefined( maxVal ) && !isString( setVal ) )
		setVal = min( setVal, maxVal );

	setDvar( dvarName, setVal );
	return setVal;
}

setServerDvarDefault( dvarName, setVal, minVal, maxVal )
{
	setVal = setDvarDefault( dvarName, setVal, minVal, maxVal );

	level.serverDvars[dvarName] = setVal;
}

setServerInfoDvarDefault( dvarName, setVal, minVal, maxVal )
{
	makeDvarServerInfo( dvarName, setVal );

	setVal = setDvarDefault( dvarName, setVal, minVal, maxVal );
}

initClassAvailability()
{
	self setClientDvars( self.pers["team"] + "_allow_assault", game[self.pers["team"] + "_assault_count"] < getDvarInt( "class_assault_limit" ),
						 self.pers["team"] + "_allow_specops", game[self.pers["team"] + "_specops_count"] < getDvarInt( "class_specops_limit" ),
						 self.pers["team"] + "_allow_demolitions", game[self.pers["team"] + "_demolitions_count"] < getDvarInt( "class_demolitions_limit" ),
						 self.pers["team"] + "_allow_sniper", game[self.pers["team"] + "_sniper_count"] < getDvarInt( "class_sniper_limit" ) );
}

initClassLoadouts()
{
	self initLoadoutForClass( "assault" );
	self initLoadoutForClass( "specops" );
	self initLoadoutForClass( "demolitions" );
	self initLoadoutForClass( "sniper" );
}

initLoadoutForClass( classType )
{
	CLASS_PRIMARY = "";
	CLASS_PRIMARY_ATTACHMENT = "";
	CLASS_SECONDARY = "";
	CLASS_SECONDARY_ATTACHMENT = "";
	CLASS_GRENADE = "";
	CLASS_CAMO = "";

	if ( classType == "assault" )
	{
		CLASS_PRIMARY = "ASSAULT_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "ASSAULT_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "ASSAULT_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "ASSAULT_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "ASSAULT_GRENADE";
		CLASS_CAMO = "ASSAULT_CAMO";
	}
	else if ( classType == "specops" )
	{
		CLASS_PRIMARY = "SPECOPS_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "SPECOPS_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "SPECOPS_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "SPECOPS_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "SPECOPS_GRENADE";
		CLASS_CAMO = "SPECOPS_CAMO";
	}
	else if ( classType == "demolitions" )
	{
		CLASS_PRIMARY = "DEMOLITIONS_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "DEMOLITIONS_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "DEMOLITIONS_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "DEMOLITIONS_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "DEMOLITIONS_GRENADE";
		CLASS_CAMO = "DEMOLITIONS_CAMO";
	}
	else if ( classType == "sniper" )
	{
		CLASS_PRIMARY = "SNIPER_PRIMARY";
		CLASS_PRIMARY_ATTACHMENT = "SNIPER_PRIMARY_ATTACHMENT";
		CLASS_SECONDARY = "SNIPER_SECONDARY";
		CLASS_SECONDARY_ATTACHMENT = "SNIPER_SECONDARY_ATTACHMENT";
		CLASS_GRENADE = "SNIPER_GRENADE";
		CLASS_CAMO = "SNIPER_CAMO";
	}

	if ( !self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, CLASS_PRIMARY, 0 ) ) ) )
		self.pers[classType]["loadout_primary"] = getDvar( "class_" + classType + "_primary" );
	else if ( getDvarInt( "weap_allow_" + get_config( CLASS_PRIMARY ) ) )
		self.pers[classType]["loadout_primary"] = get_config( CLASS_PRIMARY );
	else
		self.pers[classType]["loadout_primary"] = getDvar( "class_" + classType + "_primary" );

	if ( !self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, CLASS_PRIMARY_ATTACHMENT, 0 ) ) ) )
		self.pers[classType]["loadout_primary_attachment"] = getDvar( "class_" + classType + "_primary_attachment" );
	else if ( getDvarInt( "attach_allow_assault_" + get_config( CLASS_PRIMARY_ATTACHMENT ) ) && classType == "assault" || getDvarInt( "attach_allow_smg_" + get_config( CLASS_PRIMARY_ATTACHMENT ) ) && classType == "specops" )
		self.pers[classType]["loadout_primary_attachment"] = get_config( CLASS_PRIMARY_ATTACHMENT );
	else
		self.pers[classType]["loadout_primary_attachment"] = getDvar( "class_" + classType + "_primary_attachment" );

	if ( !self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, CLASS_SECONDARY, 0 ) ) ) )
		self.pers[classType]["loadout_secondary"] = getDvar( "class_" + classType + "_secondary" );
	else if ( getDvarInt( "weap_allow_" + get_config( CLASS_SECONDARY ) ) )
		self.pers[classType]["loadout_secondary"] = get_config( CLASS_SECONDARY );
	else
		self.pers[classType]["loadout_secondary"] = getDvar( "class_" + classType + "_secondary" );

	if ( !self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, CLASS_SECONDARY_ATTACHMENT, 0 ) ) ) )
		self.pers[classType]["loadout_secondary_attachment"] = getDvar( "class_" + classType + "_secondary_attachment" );
	else if ( getDvarInt( "attach_allow_pistol_" + get_config( CLASS_SECONDARY_ATTACHMENT ) ) )
		self.pers[classType]["loadout_secondary_attachment"] = get_config( CLASS_SECONDARY_ATTACHMENT );
	else
		self.pers[classType]["loadout_secondary_attachment"] = getDvar( "class_" + classType + "_secondary_attachment" );

	if ( !self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, CLASS_GRENADE, 0 ) ) ) )
		self.pers[classType]["loadout_grenade"] = getDvar( "class_" + classType + "_grenade" );
	else if ( getDvarInt( "weap_allow_" + get_config( CLASS_GRENADE ) ) )
		self.pers[classType]["loadout_grenade"] = get_config( CLASS_GRENADE );
	else
		self.pers[classType]["loadout_grenade"] = getDvar( "class_" + classType + "_grenade" );

	if ( !self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, CLASS_CAMO, 0 ) ) ) )
		self.pers[classType]["loadout_camo"] = getDvar( "class_" + classType + "_camo" );
	else
		self.pers[classType]["loadout_camo"] = get_config( CLASS_CAMO );
}

setDvarsFromClass( classType )
{
	self setClientDvars(
		"loadout_primary", self.pers[classType]["loadout_primary"],
		"loadout_primary_attachment", self.pers[classType]["loadout_primary_attachment"],
		"loadout_secondary", self.pers[classType]["loadout_secondary"],
		"loadout_secondary_attachment", self.pers[classType]["loadout_secondary_attachment"],
		"loadout_grenade", self.pers[classType]["loadout_grenade"],
		"loadout_camo", self.pers[classType]["loadout_camo"] );
}

processLoadoutResponse( respString )
{
	commandTokens = strTok( respString, "," );

	for ( index = 0; index < commandTokens.size; index++ )
	{
		subTokens = strTok( commandTokens[index], ":" );
		assert( subTokens.size > 1 );

		switch ( subTokens[0] )
		{
			case "loadout_primary":
			case "loadout_secondary":
				if ( respString != "loadout_primary:m16" && respString != "loadout_primary:ak47" && respString != "loadout_primary:m4" && respString != "loadout_primary:g3" && respString != "loadout_primary:g36c" && respString != "loadout_primary:m14" && respString != "loadout_primary:mp44" && respString != "loadout_primary:mp5" && respString != "loadout_primary:uzi" && respString != "loadout_primary:ak74u" && respString != "loadout_primary:winchester1200" && respString != "loadout_primary:m1014" && respString != "loadout_primary:m40a3" && respString != "loadout_primary:remington700" && respString != "loadout_secondary:deserteaglegold" && respString != "loadout_secondary:deserteagle" && respString != "loadout_secondary:colt45" && respString != "loadout_secondary:usp" && respString != "loadout_secondary:beretta" )
					return;

				if ( getDvarInt( "weap_allow_" + subTokens[1] ) && self verifyWeaponChoice( subTokens[1], self.class ) )
				{
					self.pers[self.class][subTokens[0]] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
					if ( subTokens[1] == "mp44" )
					{
						self.pers[self.class]["loadout_primary_attachment"] = "none";
						self setClientDvar( "loadout_primary_attachment", "none" );
					}
					else if ( subTokens[1] == "deserteagle" || subTokens[1] == "deserteaglegold" )
					{
						self.pers[self.class]["loadout_secondary_attachment"] = "none";
						self setClientDvar( "loadout_secondary_attachment", "none" );
					}
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;

			case "loadout_primary_attachment":
			case "loadout_secondary_attachment":
				if( respString != "loadout_primary_attachment:assault:none" && respString != "loadout_primary_attachment:assault:silencer" && respString != "loadout_primary_attachment:smg:none" && respString != "loadout_primary_attachment:smg:silencer" && respString != "loadout_secondary_attachment:pistol:none" && respString != "loadout_secondary_attachment:pistol:silencer" )
					return;

				if ( subTokens[0] == "loadout_primary_attachment" && self.pers[self.class]["loadout_primary"] == "mp44" )
				{
					self.pers[self.class]["loadout_primary_attachment"] = "none";
					self setClientDvar( "loadout_primary_attachment", "none" );
				}
				else if ( getDvarInt( "attach_allow_" + subTokens[1] + "_" + subTokens[2] ) )
				{
					self.pers[self.class][subTokens[0]] = subTokens[2];
					self setClientDvar( subTokens[0], subTokens[2] );
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;

			case "loadout_grenade":
				if( respString != "loadout_grenade:flash_grenade" && respString != "loadout_grenade:smoke_grenade" )
					return;

				if ( getDvarInt( "weap_allow_" + subTokens[1] ) )
				{
					self.pers[self.class][subTokens[0]] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;

			case "loadout_camo":
				if( respString != "loadout_camo:camo_none" && respString != "loadout_camo:camo_brockhaurd" && respString != "loadout_camo:camo_bushdweller" && respString != "loadout_camo:camo_blackwhitemarpat" && respString != "loadout_camo:camo_tigerred" && respString != "loadout_camo:camo_stagger" && respString != "loadout_camo:camo_gold" )
					return;

				switch ( subTokens[1] )
				{
					case "camo_none": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
					case "camo_brockhaurd": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
					case "camo_bushdweller": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
					case "camo_blackwhitemarpat": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
					case "camo_tigerred": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
					case "camo_stagger": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
					case "camo_gold": self.pers[self.class][subTokens[0]] = subTokens[1]; break;
				}
		}
	}
}

verifyWeaponChoice( weaponName, classType )
{
	if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_pistol" )
		return true;

	switch ( classType )
	{
		case "assault":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_assault" )
				return true;
			break;
		case "specops":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_smg" )
				return true;
			break;
		case "demolitions":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_shotgun" )
				return true;
			break;
		case "sniper":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_sniper" )
				return true;
			break;
	}

	return false;
}

verifyClassChoice( teamName, classType )
{
	if ((teamName == "allies" || teamName == "axis") && (classType == "assault" || classType == "specops" || classType == "demolitions" || classType == "sniper")) {

	if ( isDefined( self.curClass ) && self.curClass == classType && getDvarInt( "class_" + classType + "_limit" ) )
		return true;

	return ( game[teamName + "_" + classType + "_count"] < getDvarInt( "class_" + classType + "_limit" ) );
	}
}

updateClassAvailability( teamName, classType )
{
	if ((teamName == "allies" || teamName == "axis") && (classType == "assault" || classType == "specops" || classType == "demolitions" || classType == "sniper")) {
		setDvarWrapper( teamName + "_allow_" + classType, game[teamName + "_" + classType + "_count"] < getDvarInt( "class_" + classType + "_limit" ) );
	}
}

menuAcceptClass()
{
	self maps\mp\gametypes\_globallogic::closeMenus();

	// this should probably be an assert
	if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return;

	// already playing
	if ( self.sessionstate == "playing" )
	{
		self.pers["primary"] = undefined;
		self.pers["weapon"] = undefined;

		if ( level.inGracePeriod && !self.hasDoneCombat || isDefined( level.rdyup ) && level.rdyup || isDefined( level.strat_over ) && !level.strat_over || isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "strat" )
		{
			self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
		}
		else
		{
			if ( isDefined( self.oldClass ) && self.oldClass != self.pers["class"] )
			{
				self iPrintLnBold( game["strings"]["change_class"] );
				self setClientDvar( "loadout_curclass", self.pers["class"] );
				self.curClass = self.pers["class"];
			}
		}
	}
	else
	{
		self.pers["primary"] = undefined;
		self.pers["weapon"] = undefined;

		self setClientDvar( "loadout_curclass", self.pers["class"] );
		self.curClass = self.pers["class"];

		if ( isDefined( game["state"] ) && game["state"] == "postgame" )
			return;

		if ( isDefined( game["state"] ) && game["state"] == "playing" )
			self thread [[level.spawnClient]]();
	}

	//level thread maps\mp\gametypes\_globallogic::updateTeamStatus();
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

updateServerDvars()
{
	self endon ( "disconnect" );

	dvarKeys = getArrayKeys( level.serverDvars );
	for ( index = 0; index < dvarKeys.size; index++ )
	{
		self setClientDvar( dvarKeys[index], level.serverDvars[dvarKeys[index]] );
		wait ( 0.05 );
	}
}

get_config( dataName )
{
	self.dataValue = self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, dataName, 0 ) ) );
	self.dataString = tablelookup( "promod/customStatsTable.csv", 0, self.dataValue, 1 );

	return self.dataString;
}