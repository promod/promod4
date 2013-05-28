/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	level.saytext[0] = &"QUICKMESSAGE_FOLLOW_ME";
	level.saytext[1] = &"QUICKMESSAGE_MOVE_IN";
	level.saytext[2] = &"QUICKMESSAGE_FALL_BACK";
	level.saytext[3] = &"QUICKMESSAGE_SUPPRESSING_FIRE";
	level.saytext[4] = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
	level.saytext[5] = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
	level.saytext[6] = &"QUICKMESSAGE_HOLD_THIS_POSITION";
	level.saytext[7] = &"QUICKMESSAGE_REGROUP";
	level.saytext[8] = &"QUICKMESSAGE_ENEMY_SPOTTED";
	level.saytext[9] = &"QUICKMESSAGE_ENEMIES_SPOTTED";
	level.saytext[10] = &"QUICKMESSAGE_IM_IN_POSITION";
	level.saytext[11] = &"QUICKMESSAGE_AREA_SECURE";
	level.saytext[12] = &"QUICKMESSAGE_WATCH_SIX";
	level.saytext[13] = &"QUICKMESSAGE_SNIPER";
	level.saytext[14] = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
	level.saytext[15] = &"QUICKMESSAGE_YES_SIR";
	level.saytext[16] = &"QUICKMESSAGE_NO_SIR";
	level.saytext[17] = &"QUICKMESSAGE_IM_ON_MY_WAY";
	level.saytext[18] = &"QUICKMESSAGE_SORRY";
	level.saytext[19] = &"QUICKMESSAGE_GREAT_SHOT";
	level.saytext[20] = &"QUICKMESSAGE_COME_ON";
	for(i=0;i<21;i++) precacheString(level.saytext[i]);
	level.soundalias = strtok("followme|movein|fallback|suppressfire|attackleftflank|attackrightflank|holdposition|regroup|enemyspotted|enemiesspotted|iminposition|areasecure|watchsix|sniper|needreinforcements|yessir|nosir|onmyway|sorry|greatshot|comeon", "|");
}

getSoundPrefixForTeam()
{
	a = "";
	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
			a = "UK";
		else
			a = "US";
	}
	else
	{
		if ( game["axis"] == "russian" )
			a = "RU";
		else
			a = "AB";
	}
	return a+"_";
}

doQuickMessage( t, i )
{
	if( self.sessionstate == "playing" && isdefined(self.pers["team"]) && self.pers["team"] != "spectator" && !isdefined(self.spamdelay) )
	{
		maxsize = 7;
		offset = 8;
		type = "stm";

		if(t == "quickcommands")
		{
			maxsize = 8;
			offset = 0;
			type = "cmd";
		}
		else if(t == "quickresponses")
		{
			maxsize = 6;
			offset = 15;
			type = "rsp";
		}
		if( i >= 0 && i < maxsize )
		{
			self.spamdelay = true;

			self playSound( self getSoundPrefixForTeam()+"mp_"+type+"_"+level.soundalias[offset+i] );
			saytext = level.saytext[offset+i];
			if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
				self sayAll( saytext );
			else
			{
				self sayTeam( saytext );
				self pingPlayer();
			}
			wait 3;
			self.spamdelay = undefined;
		}
	}
}

quickpromod(response)
{
	self endon ( "disconnect" );

	switch(response)
	{
		case "1":
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			self thread promod\timeout::timeoutCall();
			break;

		case "2":
			if ( self.sessionstate == "playing" && (!isDefined( self.isPlanting ) || !self.isPlanting) && !level.gameEnded && isDefined( self.carryObject ) )
				self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
			break;

		case "3":
			self suicide();
			break;

		case "4":
			a = "en";
			if ( self promod\client::toggle("PROMOD_RECORD") )
				a = "dis";
			self iprintln("Record reminder has been "+a+"abled");
			break;

		case "5":
			self maps\mp\gametypes\_weapons::printStats();
			break;

		case "silencer":
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" || !isDefined( self.pers["class"] ) || !getDvarInt( "attach_allow_" + self.pers["class"] + "_silencer" ) || self.pers[self.pers["class"]]["loadout_primary"] == "mp44" || self.pers["class"] == "sniper" || self.pers["class"] == "demolitions" )
				return;

			attach = "none";
			if(self.pers[self.pers["class"]]["loadout_primary_attachment"] == "none")
			{
				attach = "silencer";
				self iprintln("Silencer attached");
			}
			else
				self iprintln("Silencer detached");

			self.pers[self.pers["class"]]["loadout_primary_attachment"] = attach;

			self maps\mp\gametypes\_promod::menuAcceptClass( "go" );
			break;

		case "grenade":
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" || !isDefined( self.pers["class"] ) )
				return;

			classType = self.pers["class"];

			if ( self.pers[classType]["loadout_grenade"] == "smoke_grenade" && getDvarInt( "weap_allow_flash_grenade" ) )
			{
				self.pers[classType]["loadout_grenade"] = "flash_grenade";
				self iprintln("Flash selected");
			}
			else if ( self.pers[classType]["loadout_grenade"] == "flash_grenade" && getDvarInt( "weap_allow_smoke_grenade" ) )
			{
				self.pers[classType]["loadout_grenade"] = "smoke_grenade";
				self iprintln("Smoke selected");
			}
			else
				return;

			self maps\mp\gametypes\_promod::menuAcceptClass( "go" );
			break;

		case "assault":
		case "specops":
		case "demolitions":
		case "sniper":
			if ( ( self.pers["team"] != "axis" && self.pers["team"] != "allies" ) )
				return;

			if ( !self maps\mp\gametypes\_promod::verifyClassChoice( self.pers["team"], response ) )
			{
				self iprintln(chooseClassName(response)+" is unavailable");
				return;
			}

			if ( !isDefined( self.pers["class"] ) || self.pers["class"] != response )
				self iprintln(chooseClassName(response)+" selected");

			self maps\mp\gametypes\_promod::setClassChoice( response );
			self maps\mp\gametypes\_promod::menuAcceptClass();
			break;

		case "X":
			if ( self.pers["team"] == "axis" || self.pers["team"] == "allies" )
				self openMenu( game["menu_changeclass_" + self.pers["team"] ] );
			break;

		case "shoutcaster":
			if ( self.pers["team"] == "spectator" )
				self openMenu( game["menu_shoutcast"] );
			break;

		case "overview":
			if ( self.pers["team"] == "spectator" )
				self openmenu( game["menu_shoutcast_map"] );
			break;

		case "controls":
			self openMenu("quickpromod");
			break;

		case "graphics":
			self openMenu("quickpromodgfx");
			break;

		case "killspec":
			self [[level.killspec]]();
			break;
	}
}

quickpromodgfx(response)
{
	self endon ( "disconnect" );

	switch(response)
	{
		case "1":
			self promod\client::setsunlight(self promod\client::loopthrough("PROMOD_SUNLIGHT", 2));
			break;

		case "2":
			self setclientdvar("r_filmusetweaks", self promod\client::toggle("PROMOD_FILMTWEAK"));
			break;

		case "3":
			self setclientdvar("r_texfilterdisable", self promod\client::toggle("PROMOD_TEXTURE"));
			break;

		case "4":
			self setclientdvar("r_normalmap", self promod\client::toggle("PROMOD_NORMALMAP"));
			break;

		case "5":
			self setclientdvar("cg_fovscale", 1 + int(!self promod\client::toggle("PROMOD_FOVSCALE")) * 0.125);
			break;

		case "6":
			self setclientdvar("r_blur", 0.2 * self promod\client::loopthrough("PROMOD_GFXBLUR", 5));
			break;
	}
}

chooseClassName( classname )
{
	if ( !isDefined( classname ) )
		return "";

	switch( classname )
	{
		case "assault":
			return "Assault";
		case "specops":
			return "Spec Ops";
		case "demolitions":
			return "Demolitions";
		case "sniper":
			return "Sniper";
		default:
			return "";
	}
}