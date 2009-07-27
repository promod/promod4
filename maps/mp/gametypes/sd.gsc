/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 3, 0, 999 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 2.5, 0, 1440 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 4, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 0, 0, 999 );
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 1, 0, 10 );

	level.teamBased = true;
	level.overrideTeamScore = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onDeadEvent = ::onDeadEvent;
	level.onTimeLimit = ::onTimeLimit;
	level.onRoundSwitch = ::onRoundSwitch;

	level.endGameOnScoreLimit = false;
}

onPrecacheGameType()
{
	game["bomb_dropped_sound"] = "mp_war_objective_lost";
	game["bomb_recovered_sound"] = "mp_war_objective_taken";

	precacheShader("waypoint_bomb");
	precacheShader("hud_suitcase_bomb");
	precacheShader("waypoint_target");
	precacheShader("waypoint_target_a");
	precacheShader("waypoint_target_b");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defend_a");
	precacheShader("waypoint_defend_b");
	precacheShader("waypoint_defuse");
	precacheShader("waypoint_defuse_a");
	precacheShader("waypoint_defuse_b");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_target_a");
	precacheShader("compass_waypoint_target_b");
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_defend_a");
	precacheShader("compass_waypoint_defend_b");
	precacheShader("compass_waypoint_defuse");
	precacheShader("compass_waypoint_defuse_a");
	precacheShader("compass_waypoint_defuse_b");

	precacheString( &"MP_EXPLOSIVES_RECOVERED_BY" );
	precacheString( &"MP_EXPLOSIVES_DROPPED_BY" );
	precacheString( &"MP_EXPLOSIVES_PLANTED_BY" );
	precacheString( &"MP_EXPLOSIVES_DEFUSED_BY" );
	precacheString( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	precacheString( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	precacheString( &"MP_CANT_PLANT_WITHOUT_BOMB" );
	precacheString( &"MP_PLANTING_EXPLOSIVE" );
	precacheString( &"MP_DEFUSING_EXPLOSIVE" );
}

onRoundSwitch()
{
	level.halftimeType = "halftime";
}

getBetterTeam()
{
	kills["allies"] = 0;
	kills["axis"] = 0;
	deaths["allies"] = 0;
	deaths["axis"] = 0;

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		team = player.pers["team"];
		if ( isDefined( team ) && (team == "allies" || team == "axis") )
		{
			kills[ team ] += player.kills;
			deaths[ team ] += player.deaths;
		}
	}

	if ( kills["allies"] > kills["axis"] )
		return "allies";
	else if ( kills["axis"] > kills["allies"] )
		return "axis";

	if ( deaths["allies"] < deaths["axis"] )
		return "allies";
	else if ( deaths["axis"] < deaths["allies"] )
		return "axis";

	if ( randomint(2) == 0 )
		return "allies";
	return "axis";
}

onStartGameType()
{
	setClientNameMode("manual_change");
	game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";
	game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";

	precacheString( game["strings"]["target_destroyed"] );
	precacheString( game["strings"]["bomb_defused"] );

	level._effect["bombexplosion"] = loadfx("explosions/tanker_explosion");

	maps\mp\gametypes\_globallogic::setObjectiveText( game["attackers"], &"OBJECTIVES_SD_ATTACKER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( game["defenders"], &"OBJECTIVES_SD_DEFENDER" );

	maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_SCORE" );

	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_attacker" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_defender" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread updateGametypeDvars();

	thread bombs();
}

onSpawnPlayer()
{
	self.isPlanting = false;
	self.isDefusing = false;
	self.isBombCarrier = false;

	if(self.pers["team"] == game["attackers"])
		spawnPointName = "mp_sd_spawn_attacker";
	else
		spawnPointName = "mp_sd_spawn_defender";

	self setclientdvar("ui_drawbombicon", 0);
	if ( level.multiBomb && !isDefined( self.carryIcon ) && self.pers["team"] == game["attackers"] && !level.bombPlanted )
	{
		self.carryIcon = createIcon( "hud_suitcase_bomb", 50, 50 );
		self.carryIcon setPoint( "CENTER", "CENTER", 223, 167 );
		self.carryIcon.alpha = 0.75;
		self setclientdvar("ui_drawbombicon", 1);
	}

	spawnPoints = getEntArray( spawnPointName, "classname" );
	assert( spawnPoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

	self spawn( spawnpoint.origin, spawnpoint.angles );

	level notify ( "spawned_player" );
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	thread checkAllowSpectating();
}

checkAllowSpectating()
{
	wait ( 0.05 );

	update = false;
	if ( !level.aliveCount[ game["attackers"] ] )
	{
		level.spectateOverride[game["attackers"]].allowEnemySpectate = 1;
		update = true;
	}
	if ( !level.aliveCount[ game["defenders"] ] )
	{
		level.spectateOverride[game["defenders"]].allowEnemySpectate = 1;
		update = true;
	}
	if ( update )
		maps\mp\gametypes\_spectating::updateSpectateSettings();
}

sd_endGame( winningTeam, endReasonText )
{
	if ( isdefined( winningTeam ) )
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );

	thread maps\mp\gametypes\_globallogic::endGame( winningTeam, endReasonText );
}

onDeadEvent( team )
{
	if ( level.bombExploded || level.bombDefused )
		return;

	if ( team == "all" )
	{
		if ( level.bombPlanted )
			sd_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
		else
			sd_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["attackers"] )
	{
		if ( level.bombPlanted )
			return;

		sd_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["defenders"] )
	{
		sd_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
	}
}

onTimeLimit()
{
	if ( level.teamBased )
		sd_endGame( game["defenders"], game["strings"]["time_limit_reached"] );
	else
		sd_endGame( undefined, game["strings"]["time_limit_reached"] );
}

updateGametypeDvars()
{
	level.plantTime = dvarFloatValue( "planttime", 5, 0, 20 );
	level.defuseTime = dvarFloatValue( "defusetime", 7, 0, 20 );
	level.bombTimer = dvarFloatValue( "bombtimer", 45, 1, 300 );
	level.multiBomb = dvarIntValue( "multibomb", 0, 0, 1 );
}

bombs()
{
	level.bombPlanted = false;
	level.bombDefused = false;
	level.bombExploded = false;

	trigger = getEnt( "sd_bomb_pickup_trig", "targetname" );
	if ( !isDefined( trigger ) )
	{
		maps\mp\_utility::error("No sd_bomb_pickup_trig trigger found in map.");
		return;
	}

	visuals[0] = getEnt( "sd_bomb", "targetname" );
	if ( !isDefined( visuals[0] ) )
	{
		maps\mp\_utility::error("No sd_bomb script_model found in map.");
		return;
	}

	precacheModel( "prop_suitcase_bomb" );
	visuals[0] setModel( "prop_suitcase_bomb" );

	if ( !level.multiBomb && isDefined( game["promod_do_readyup"] ) && !game["promod_do_readyup"] && isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] != "strat" )
	{
		level.sdBomb = maps\mp\gametypes\_gameobjects::createCarryObject( game["attackers"], trigger, visuals, (0,0,32) );
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "friendly" );
		level.sdBomb maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_bomb" );
		level.sdBomb maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setCarryIcon( "hud_suitcase_bomb" );
		level.sdBomb.allowWeapons = true;
		level.sdBomb.onPickup = ::onPickup;
		level.sdBomb.onDrop = ::onDrop;
	}
	else
	{
		trigger delete();
		visuals[0] delete();
	}

	level.bombZones = [];

	bombZones = getEntArray( "bombzone", "targetname" );

	for ( index = 0; index < bombZones.size; index++ )
	{
		trigger = bombZones[index];
		visuals = getEntArray( bombZones[index].target, "targetname" );

		bombZone = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, (0,0,64) );
		bombZone maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
		bombZone maps\mp\gametypes\_gameobjects::setUseTime( level.plantTime );
		bombZone maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE" );
		bombZone maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
		if ( !level.multiBomb )
			bombZone maps\mp\gametypes\_gameobjects::setKeyObject( level.sdBomb );
		label = bombZone maps\mp\gametypes\_gameobjects::getLabel();
		bombZone.label = label;
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" + label );
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" + label );

		bombZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );

		bombZone.onBeginUse = ::onBeginUse;
		bombZone.onEndUse = ::onEndUse;
		bombZone.onUse = ::onUsePlantObject;
		bombZone.onCantUse = ::onCantUse;

		for ( i = 0; i < visuals.size; i++ )
		{
			if ( isDefined( visuals[i].script_exploder ) )
			{
				bombZone.exploderIndex = visuals[i].script_exploder;
				break;
			}
		}

		level.bombZones[level.bombZones.size] = bombZone;

		bombZone.bombDefuseTrig = getent( visuals[0].target, "targetname" );
		assert( isdefined( bombZone.bombDefuseTrig ) );
		bombZone.bombDefuseTrig.origin += (0,0,-10000);
		bombZone.bombDefuseTrig.label = label;
	}

	for ( index = 0; index < level.bombZones.size; index++ )
	{
		array = [];
		for ( otherindex = 0; otherindex < level.bombZones.size; otherindex++ )
		{
			if ( otherindex != index )
				array[ array.size ] = level.bombZones[otherindex];
		}
		level.bombZones[index].otherBombZones = array;
	}
}

onBeginUse( player )
{
	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		player playSound( "mp_bomb_defuse" );
		player.isDefusing = true;

		if ( isDefined( level.sdBombModel ) )
			level.sdBombModel hide();
	}
	else
	{
		player playSound( "mp_bomb_plant" );
		player.isPlanting = true;

		if ( level.multibomb )
		{
			for ( i = 0; i < self.otherBombZones.size; i++ )
			{
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::disableObject();
			}
		}
	}
}

onEndUse( team, player, result )
{
	if ( isAlive( player ) )
	{
		player.isDefusing = false;
		player.isPlanting = false;
	}

	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		if ( isDefined( level.sdBombModel ) && !result )
		{
			level.sdBombModel show();
		}
	}
	else
	{
		if ( level.multibomb && !result )
		{
			for ( i = 0; i < self.otherBombZones.size; i++ )
			{
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::enableObject();
			}
		}
	}
}

onCantUse( player )
{
	player iPrintLnBold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}

onUsePlantObject( player )
{
	timeLeft = maps\mp\gametypes\_globallogic::getTimeRemaining();

	if (timeLeft < 10 )
		return;

	if ( !self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		player notify ( "bomb_planted" );
		player logString( "bomb planted: " + self.label );

		if ( !level.hardcoreMode )
			iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player.name );

		maps\mp\gametypes\_globallogic::givePlayerScore( "plant", player );

		for ( index = 0; index < level.bombZones.size; index++ )
		{
			if ( level.bombZones[index] == self )
				continue;

			level.bombZones[index] maps\mp\gametypes\_gameobjects::disableObject();
		}

		for ( i = 0; i < level.players.size; i++ )
		{
			level.players[i] playLocalSound("promod_planted");
		}

		player thread [[level.onXPEvent]]( "plant" );
		level thread bombPlanted( self, player );

		if ( isDefined( level.scorebot ) && level.scorebot )
			game["promod_scorebot_ticker_buffer"] += "planted_by" + player.name;
	}
}

onUseDefuseObject( player )
{
	wait .01;

	if ( level.bombExploded )
		return;

	player notify ( "bomb_defused" );
	player logString( "bomb defused: " + self.label );
	level thread bombDefused();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] playLocalSound("promod_defused");
	}

	self maps\mp\gametypes\_gameobjects::disableObject();

	if ( !level.hardcoreMode )
		iPrintLn( &"MP_EXPLOSIVES_DEFUSED_BY", player.name );

	maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", player );
	player thread [[level.onXPEvent]]( "defuse" );

	if ( isDefined( level.scorebot ) && level.scorebot )
		game["promod_scorebot_ticker_buffer"] += "defused_by" + player.name;

}

onDrop( player )
{
	if ( !level.bombPlanted )
	{
		if ( isDefined( player ) && isDefined( player.name ) )
			printOnTeamArg( &"MP_EXPLOSIVES_DROPPED_BY", game["attackers"], player );

		if ( isDefined( level.scorebot ) && level.scorebot && isDefined( player ) && isDefined( player.name ) )
				game["promod_scorebot_ticker_buffer"] += "dropped_bomb" + player.name;

		if ( isDefined( player ) )
		 	player logString( "bomb dropped" );
		 else
		 	logString( "bomb dropped" );
	}

	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );

	if ( level.bombPlanted )
		return;
	else
	maps\mp\_utility::playSoundOnPlayers( game["bomb_dropped_sound"], game["attackers"] );
}

onPickup( player )
{
	player.isBombCarrier = true;

	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );

	if ( !level.bombDefused )
	{
		if ( isDefined( player ) && isDefined( player.name ) )
			printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", game["attackers"], player );

		player logString( "bomb taken" );

		if ( isDefined( level.scorebot ) && level.scorebot && isDefined( player ) && isDefined( player.name ) )
			game["promod_scorebot_ticker_buffer"] += "pickup_bomb" + player.name;
	}
	maps\mp\_utility::playSoundOnPlayers( game["bomb_recovered_sound"], game["attackers"] );
}

onReset()
{
}

bombPlanted( destroyedObj, player )
{
	wait .05;

	maps\mp\gametypes\_globallogic::pauseTimer();
	level.bombPlanted = true;

	destroyedObj.visuals[0] thread maps\mp\gametypes\_globallogic::playTickingSound();
	level.tickingObject = destroyedObj.visuals[0];

	level.timeLimitOverride = true;
	setGameEndTime( int( gettime() + (level.bombTimer * 1000) ) );
	setDvar( "ui_bomb_timer", 1 );

	if ( !level.multiBomb )
	{
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
		level.sdBombModel = level.sdBomb.visuals[0];
	}
	else
	{

		for ( index = 0; index < level.players.size; index++ )
		{
			if ( isDefined( level.players[index].carryIcon ) )
				level.players[index].carryIcon destroyElem();
		}

		trace = bulletTrace( player.origin + (0,0,20), player.origin - (0,0,2000), false, player );

		tempAngle = randomfloat( 360 );
		forward = (cos( tempAngle ), sin( tempAngle ), 0);
		forward = vectornormalize( forward - vector_scale( trace["normal"], vectordot( forward, trace["normal"] ) ) );
		dropAngles = vectortoangles( forward );

		level.sdBombModel = spawn( "script_model", trace["position"] );
		level.sdBombModel.angles = dropAngles;
		level.sdBombModel setModel( "prop_suitcase_bomb" );
	}
	destroyedObj maps\mp\gametypes\_gameobjects::allowUse( "none" );
	destroyedObj maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );

	label = destroyedObj maps\mp\gametypes\_gameobjects::getLabel();

	trigger = destroyedObj.bombDefuseTrig;
	trigger.origin = level.sdBombModel.origin;
	visuals = [];
	defuseObject = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, (0,0,32) );
	defuseObject maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime);
	defuseObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	defuseObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defuse" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_defend" + label );

	defuseObject.label = label;
	defuseObject.onBeginUse = ::onBeginUse;
	defuseObject.onEndUse = ::onEndUse;
	defuseObject.onUse = ::onUseDefuseObject;

	BombTimerWait();
	setDvar( "ui_bomb_timer", 0 );

	destroyedObj.visuals[0] maps\mp\gametypes\_globallogic::stopTickingSound();

	if ( level.gameEnded || level.bombDefused )
		return;

	level.bombExploded = true;

	if ( isDefined( level.scorebot ) && level.scorebot )
		game["promod_scorebot_ticker_buffer"] += "bomb_exploded";

	explosionOrigin = level.sdBombModel.origin;
	level.sdBombModel hide();

	if ( isdefined( player ) )
		destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20, player );
	else
		destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20 );

	rot = randomfloat(360);
	explosionEffect = spawnFx( level._effect["bombexplosion"], explosionOrigin + (0,0,50), (0,0,1), (cos(rot),sin(rot),0) );
	triggerFx( explosionEffect );

	thread playSoundinSpace( "exp_suitcase_bomb_main", explosionOrigin );

	for ( index = 0; index < level.bombZones.size; index++ )
		level.bombZones[index] maps\mp\gametypes\_gameobjects::disableObject();
	defuseObject maps\mp\gametypes\_gameobjects::disableObject();

	setGameEndTime( 0 );

	wait 2;

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] playLocalSound("promod_destroyed");
	}

	sd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
}

BombTimerWait()
{
	level endon("game_ended");
	level endon("bomb_defused");
	wait level.bombTimer;
}

playSoundinSpace( alias, origin )
{
	org = spawn( "script_origin", origin );
	org.origin = origin;
	org playSound( alias );
	wait 10;
	org delete();
}

bombDefused()
{
	level.tickingObject maps\mp\gametypes\_globallogic::stopTickingSound();
	level.bombDefused = true;
	setDvar( "ui_bomb_timer", 0 );
	level notify("bomb_defused");

	wait .05;

	setGameEndTime( 0 );

	sd_endGame( game["defenders"], game["strings"]["bomb_defused"] );
}