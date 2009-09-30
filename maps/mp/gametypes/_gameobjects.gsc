/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main(allowed)
{
	entitytypes = getentarray();
	for(i = 0; i < entitytypes.size; i++)
	{
		if(isdefined(entitytypes[i].script_gameobjectname))
		{
			dodelete = true;

			gameobjectnames = strtok(entitytypes[i].script_gameobjectname, " ");

			for(j = 0; j < allowed.size; j++)
			{
				for (k = 0; k < gameobjectnames.size; k++)
				{
					if(gameobjectnames[k] == allowed[j])
					{
						dodelete = false;
						break;
					}
				}
				if (!dodelete)
					break;
			}

			if(dodelete)
			{
				entitytypes[i] delete();
			}
		}
	}
}

init()
{
	level.numGametypeReservedObjectives = 0;

	precacheItem( "briefcase_bomb_mp" );
	precacheItem( "briefcase_bomb_defuse_mp" );
	precacheModel( "prop_suitcase_bomb" );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	level endon ( "game_ended" );

	for( ;; )
	{
		level waittill( "connecting", player );

		player thread onPlayerSpawned();
		player thread onDisconnect();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon ( "game_ended" );

	for(;;)
	{
		self waittill( "spawned_player" );

		self thread onDeath();
		self.touchTriggers = [];
		self.carryObject = undefined;
		self.claimTrigger = undefined;
		self.canPickupObject = true;
		self.disabledWeapon = 0;
		self.killedInUse = undefined;
	}
}

onDeath()
{
	level endon ( "game_ended" );

	self waittill ( "death" );
	if ( isDefined( self.carryObject ) )
		self.carryObject thread setDropped();
}

onDisconnect()
{
	level endon ( "game_ended" );

	self waittill ( "disconnect" );
	if ( isDefined( self.carryObject ) )
		self.carryObject thread setDropped();
}

createCarryObject( ownerTeam, trigger, visuals, offset )
{
	carryObject = spawnStruct();
	carryObject.type = "carryObject";
	carryObject.curOrigin = trigger.origin;
	carryObject.ownerTeam = ownerTeam;
	carryObject.entNum = trigger getEntityNumber();

	if ( isSubStr( trigger.classname, "use" ) )
		carryObject.triggerType = "use";
	else
		carryObject.triggerType = "proximity";

	trigger.baseOrigin = trigger.origin;
	carryObject.trigger = trigger;

	carryObject.useWeapon = undefined;

	if ( !isDefined( offset ) )
		offset = (0,0,0);

	carryObject.offset3d = offset;

	for ( index = 0; index < visuals.size; index++ )
	{
		visuals[index].baseOrigin = visuals[index].origin;
		visuals[index].baseAngles = visuals[index].angles;
	}
	carryObject.visuals = visuals;

	carryObject.compassIcons = [];
	carryObject.objIDAllies = getNextObjID();
	carryObject.objIDAxis = getNextObjID();
	carryObject.objIDPingFriendly = false;
	carryObject.objIDPingEnemy = false;
	level.objIDStart += 2;

	objective_add( carryObject.objIDAllies, "invisible", carryObject.curOrigin );
	objective_add( carryObject.objIDAxis, "invisible", carryObject.curOrigin );
	objective_team( carryObject.objIDAllies, "allies" );
	objective_team( carryObject.objIDAxis, "axis" );

	carryObject.objPoints["allies"] = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_allies_" + carryObject.entNum, carryObject.curOrigin + offset, "allies", undefined );
	carryObject.objPoints["axis"] = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_axis_" + carryObject.entNum, carryObject.curOrigin + offset, "axis", undefined );

	carryObject.objPoints["allies"].alpha = 0;
	carryObject.objPoints["axis"].alpha = 0;

	carryObject.carrier = undefined;

	carryObject.isResetting = false;
	carryObject.interactTeam = "none";
	carryObject.allowWeapons = false;

	carryObject.worldIcons = [];
	carryObject.carrierVisible = false;
	carryObject.visibleTeam = "none";

	carryObject.carryIcon = undefined;

	carryObject.onDrop = undefined;
	carryObject.onPickup = undefined;
	carryObject.onReset = undefined;

	if ( carryObject.triggerType == "use" )
		carryObject thread carryObjectUseThink();
	else
		carryObject thread carryObjectProxThink();

	carryObject thread updateCarryObjectOrigin();

	return carryObject;
}

carryObjectUseThink()
{
	level endon ( "game_ended" );

	while ( true )
	{
		self.trigger waittill ( "trigger", player );

		if ( self.isResetting )
			continue;

		if ( !isAlive( player ) )
			continue;

		if ( !self canInteractWith( player.pers["team"] ) )
			continue;

		if ( !player.canPickupObject )
			continue;

		if ( player.throwingGrenade )
			continue;

		if ( isDefined( self.carrier ) )
			continue;

		self setPickedUp( player );
	}
}

carryObjectProxThink()
{
	level endon ( "game_ended" );

	while ( true )
	{
		self.trigger waittill ( "trigger", player );

		if ( self.isResetting )
			continue;

		if ( !isAlive( player ) )
			continue;

		if ( !self canInteractWith( player.pers["team"] ) )
			continue;

		if ( !player.canPickupObject )
			continue;

		if ( isDefined( self.carrier ) )
			continue;

		if (isDefined(level.timeout_over) && !level.timeout_over)
			return;

		self setPickedUp( player );
	}
}

pickupObjectDelay( origin )
{
	level endon ( "game_ended" );

	self endon("death");
	self endon("disconnect");

	self.canPickupObject = false;

	for( ;; )
	{
		if ( distanceSquared( self.origin, origin ) > 4096 )
			break;

		wait 0.2;
	}

	self.canPickupObject = true;
}

setPickedUp( player )
{
	if ( isDefined( player.carryObject ) )
	{
		if ( isDefined( self.onPickupFailed ) )
			self [[self.onPickupFailed]]( player );

		return;
	}

	player giveObject( self );

	self setCarrier( player );

	for ( index = 0; index < self.visuals.size; index++ )
		self.visuals[index] hide();

	self.trigger.origin += (0,0,10000);

	self notify ( "pickup_object" );
	if ( isDefined( self.onPickup ) )
		self [[self.onPickup]]( player );

	self updateCompassIcons();
	self updateWorldIcons();
}

updateCarryObjectOrigin()
{
	level endon ( "game_ended" );

	objPingDelay = 5.0;
	for ( ;; )
	{
		if ( isDefined( self.carrier ) )
		{
			self.curOrigin = self.carrier.origin + (0,0,75);
			self.objPoints["allies"] maps\mp\gametypes\_objpoints::updateOrigin( self.curOrigin );
			self.objPoints["axis"] maps\mp\gametypes\_objpoints::updateOrigin( self.curOrigin );

			if ( (self.visibleTeam == "friendly" || self.visibleTeam == "any") && self isFriendlyTeam( "allies" ) && self.objIDPingFriendly )
			{
				if ( self.objPoints["allies"].isShown )
				{
					self.objPoints["allies"].alpha = self.objPoints["allies"].baseAlpha;
					self.objPoints["allies"] fadeOverTime( objPingDelay + 1.0 );
					self.objPoints["allies"].alpha = 0;
				}
				objective_position( self.objIDAllies, self.curOrigin );
			}
			else if ( (self.visibleTeam == "friendly" || self.visibleTeam == "any") && self isFriendlyTeam( "axis" ) && self.objIDPingFriendly )
			{
				if ( self.objPoints["axis"].isShown )
				{
					self.objPoints["axis"].alpha = self.objPoints["axis"].baseAlpha;
					self.objPoints["axis"] fadeOverTime( objPingDelay + 1.0 );
					self.objPoints["axis"].alpha = 0;
				}
				objective_position( self.objIDAxis, self.curOrigin );
			}

			if ( (self.visibleTeam == "enemy" || self.visibleTeam == "any") && !self isFriendlyTeam( "allies" ) && self.objIDPingEnemy )
			{
				if ( self.objPoints["allies"].isShown )
				{
					self.objPoints["allies"].alpha = self.objPoints["allies"].baseAlpha;
					self.objPoints["allies"] fadeOverTime( objPingDelay + 1.0 );
					self.objPoints["allies"].alpha = 0;
				}
				objective_position( self.objIDAllies, self.curOrigin );
			}
			else if ( (self.visibleTeam == "enemy" || self.visibleTeam == "any") && !self isFriendlyTeam( "axis" ) && self.objIDPingEnemy )
			{
				if ( self.objPoints["axis"].isShown )
				{
					self.objPoints["axis"].alpha = self.objPoints["axis"].baseAlpha;
					self.objPoints["axis"] fadeOverTime( objPingDelay + 1.0 );
					self.objPoints["axis"].alpha = 0;
				}
				objective_position( self.objIDAxis, self.curOrigin );
			}

			self wait_endon( objPingDelay, "dropped", "reset" );
		}
		else
		{
			self.objPoints["allies"] maps\mp\gametypes\_objpoints::updateOrigin( self.curOrigin + self.offset3d );
			self.objPoints["axis"] maps\mp\gametypes\_objpoints::updateOrigin( self.curOrigin + self.offset3d );

			wait ( .05 );
		}
	}
}

giveObject( object )
{
	assert( !isDefined( self.carryObject ) );

	self.carryObject = object;
	self thread trackCarrier();

	if ( !object.allowWeapons )
	{
		self _disableWeapon();
		self thread manualDropThink();
	}

	if ( isDefined( object.carryIcon ) )
	{
		self.carryIcon = createIcon( object.carryIcon, 50, 50 );

		if ( !object.allowWeapons )
			self.carryIcon setPoint( "CENTER", "CENTER", 0, 60 );
		else
			self.carryIcon setPoint( "CENTER", "CENTER", 223, 167 );
	}
}

returnHome()
{
	self.isResetting = true;

	self notify ( "reset" );
	for ( index = 0; index < self.visuals.size; index++ )
	{
		self.visuals[index].origin = self.visuals[index].baseOrigin;
		self.visuals[index].angles = self.visuals[index].baseAngles;
		self.visuals[index] show();
	}
	self.trigger.origin = self.trigger.baseOrigin;

	self.curOrigin = self.trigger.origin;

	if ( isDefined( self.onReset ) )
		self [[self.onReset]]();

	self clearCarrier();

	updateWorldIcons();
	updateCompassIcons();

	self.isResetting = false;
}

setPosition( origin, angles )
{
	self.isResetting = true;

	for ( index = 0; index < self.visuals.size; index++ )
	{
		self.visuals[index].origin = self.origin;
		self.visuals[index].angles = self.angles;
		self.visuals[index] show();
	}
	self.trigger.origin = origin;

	self.curOrigin = self.trigger.origin;

	self clearCarrier();

	updateWorldIcons();
	updateCompassIcons();

	self.isResetting = false;
}

setDropped()
{
	self.isResetting = true;

	self notify ( "dropped" );

	if ( isDefined( self.carrier ) )
	{
		trace = playerPhysicsTrace( self.carrier.origin + (0,0,20), self.carrier.origin - (0,0,2000), false, self.carrier.body );
		angleTrace = bulletTrace( self.carrier.origin + (0,0,20), self.carrier.origin - (0,0,2000), false, self.carrier.body );
	}
	else
	{
		trace = playerPhysicsTrace( self.safeOrigin + (0,0,20), self.safeOrigin - (0,0,20), false, undefined );
		angleTrace = bulletTrace( self.safeOrigin + (0,0,20), self.safeOrigin - (0,0,20), false, undefined );
	}

	droppingPlayer = self.carrier;

	if ( isDefined( trace ) )
	{
		tempAngle = randomfloat( 360 );

		dropOrigin = trace;
		if ( angleTrace["fraction"] < 1 && distance( angleTrace["position"], trace ) < 10.0 )
		{
			forward = (cos( tempAngle ), sin( tempAngle ), 0);
			forward = vectornormalize( forward - vector_scale( angleTrace["normal"], vectordot( forward, angleTrace["normal"] ) ) );
			dropAngles = vectortoangles( forward );
		}
		else
		{
			dropAngles = (0,tempAngle,0);
		}

		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[index].origin = dropOrigin;
			self.visuals[index].angles = dropAngles;
			self.visuals[index] show();
		}
		self.trigger.origin = dropOrigin;

		self.curOrigin = self.trigger.origin;

		self thread pickupTimeout();
	}
	else
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[index].origin = self.visuals[index].baseOrigin;
			self.visuals[index].angles = self.visuals[index].baseAngles;
			self.visuals[index] show();
		}
		self.trigger.origin = self.trigger.baseOrigin;

		self.curOrigin = self.trigger.baseOrigin;
	}

	if ( isDefined( self.onDrop ) )
		self [[self.onDrop]]( droppingPlayer );

	self clearCarrier();

	self updateCompassIcons();
	self updateWorldIcons();

	self.isResetting = false;
}

setCarrier( carrier )
{
	self.carrier = carrier;

	self thread updateVisibilityAccordingToRadar();
}

clearCarrier()
{
	if ( !isdefined( self.carrier ) )
		return;

	self.carrier takeObject( self );

	self.carrier = undefined;

	self notify("carrier_cleared");
}

pickupTimeout()
{
	self endon ( "pickup_object" );
	self endon ( "stop_pickup_timeout" );

	wait ( .05 );

	mineTriggers = getEntArray( "minefield", "targetname" );
	hurtTriggers = getEntArray( "trigger_hurt", "classname" );

	for ( index = 0; index < mineTriggers.size; index++ )
	{
		if ( !self.visuals[0] isTouching( mineTriggers[index] ) )
			continue;

		self returnHome();
		return;
	}

	for ( index = 0; index < hurtTriggers.size; index++ )
	{
		if ( !self.visuals[0] isTouching( hurtTriggers[index] ) )
			continue;

		self returnHome();
		return;
	}

	if ( isDefined( self.autoResetTime ) )
	{
		wait ( self.autoResetTime );

		if ( !isDefined( self.carrier ) )
			self returnHome();
	}
}

takeObject( object )
{
	if ( isDefined( self.carryIcon ) )
		self.carryIcon destroyElem();

	if ( !isAlive( self ) )
		return;

	self.carryObject = undefined;
	self notify ( "drop_object" );

	if ( object.triggerType == "proximity" )
		self thread pickupObjectDelay( object.trigger.origin );

	if ( !object.allowWeapons )
	{
		self _enableWeapon();
	}
}

trackCarrier()
{
	level endon ( "game_ended" );
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon ( "drop_object" );

	while ( isDefined( self.carryObject ) && isAlive( self ) )
	{
		if ( self isOnGround() )
		{
			trace = bulletTrace( self.origin + (0,0,20), self.origin - (0,0,20), false, undefined );
			if ( trace["fraction"] < 1 )
				self.carryObject.safeOrigin = trace["position"];
		}
		wait ( .05 );
	}
}

manualDropThink()
{
	level endon ( "game_ended" );

	self endon ( "disconnect" );
	self endon ( "death" );
	self endon ( "drop_object" );

	for( ;; )
	{
		while ( self attackButtonPressed() || self fragButtonPressed() || self secondaryOffhandButtonPressed() || self meleeButtonPressed() )
			wait .05;

		while ( !self attackButtonPressed() && !self fragButtonPressed() && !self secondaryOffhandButtonPressed() && !self meleeButtonPressed() )
			wait .05;

		if ( isDefined( self.carryObject ) && !self useButtonPressed() )
			self.carryObject thread setDropped();
	}
}

createUseObject( ownerTeam, trigger, visuals, offset )
{
	useObject = spawnStruct();
	useObject.type = "useObject";
	useObject.curOrigin = trigger.origin;
	useObject.ownerTeam = ownerTeam;
	useObject.entNum = trigger getEntityNumber();
	useObject.keyObject = undefined;

	if ( isSubStr( trigger.classname, "use" ) )
		useObject.triggerType = "use";
	else
		useObject.triggerType = "proximity";

	useObject.trigger = trigger;

	for ( index = 0; index < visuals.size; index++ )
	{
		visuals[index].baseOrigin = visuals[index].origin;
		visuals[index].baseAngles = visuals[index].angles;
	}
	useObject.visuals = visuals;

	if ( !isDefined( offset ) )
		offset = (0,0,0);

	useObject.offset3d = offset;

	useObject.compassIcons = [];
	useObject.objIDAllies = getNextObjID();
	useObject.objIDAxis = getNextObjID();

	objective_add( useObject.objIDAllies, "invisible", useObject.curOrigin );
	objective_add( useObject.objIDAxis, "invisible", useObject.curOrigin );
	objective_team( useObject.objIDAllies, "allies" );
	objective_team( useObject.objIDAxis, "axis" );

	useObject.objPoints["allies"] = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_allies_" + useObject.entNum, useObject.curOrigin + offset, "allies", undefined );
	useObject.objPoints["axis"] = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_axis_" + useObject.entNum, useObject.curOrigin + offset, "axis", undefined );

	useObject.objPoints["allies"].alpha = 0;
	useObject.objPoints["axis"].alpha = 0;

	useObject.interactTeam = "none";

	useObject.worldIcons = [];
	useObject.visibleTeam = "none";

	useObject.onUse = undefined;
	useObject.onCantUse = undefined;

	useObject.useText = "default";
	useObject.useTime = 10000;
	useObject.curProgress = 0;

	if ( useObject.triggerType == "proximity" )
	{
		useObject.numTouching["neutral"] = 0;
		useObject.numTouching["axis"] = 0;
		useObject.numTouching["allies"] = 0;
		useObject.numTouching["none"] = 0;
		useObject.touchList["neutral"] = [];
		useObject.touchList["axis"] = [];
		useObject.touchList["allies"] = [];
		useObject.touchList["none"] = [];
		useObject.useRate = 0;
		useObject.claimTeam = "none";
		useObject.claimPlayer = undefined;
		useObject.lastClaimTeam = "none";
		useObject.lastClaimTime = 0;

		useObject thread useObjectProxThink();
	}
	else
	{
		useObject.useRate = 1;
		useObject thread useObjectUseThink();
	}

	return useObject;
}

setKeyObject( object )
{
	self.keyObject = object;
}

useObjectUseThink()
{
	if ( (isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"]) || (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ))
		return;

	level endon ( "game_ended" );

	while ( true )
	{
		self.trigger waittill ( "trigger", player );

		if ( !isAlive( player ) )
			continue;

		if ( isDefined(player.attaching) && player.attaching )
			continue;

		if ( !self canInteractWith( player.pers["team"] ) )
			continue;

		if ( !player isOnGround() )
			continue;

		if ( !player isTouching( self.trigger ) )
			continue;

		if ( isDefined( self.keyObject ) && (!isDefined( player.carryObject ) || player.carryObject != self.keyObject ) )
		{
			if ( isDefined( self.onCantUse ) )
				self [[self.onCantUse]]( player );
			continue;
		}

		result = true;
		if ( self.useTime > 0 )
		{
			if ( isDefined( self.onBeginUse ) )
				self [[self.onBeginUse]]( player );

			team = player.pers["team"];

			result = self useHoldThink( player );

			if ( isDefined( self.onEndUse ) )
				self [[self.onEndUse]]( team, player, result );
		}

		if ( !result )
			continue;

		if ( isDefined( self.onUse ) )
			self [[self.onUse]]( player );
	}
}

getEarliestClaimPlayer()
{
	assert( self.claimTeam != "none" );
	team = self.claimTeam;

	earliestPlayer = self.claimPlayer;

	if ( self.touchList[team].size > 0 )
	{
		earliestTime = undefined;
		players = getArrayKeys( self.touchList[team] );
		for ( index = 0; index < players.size; index++ )
		{
			touchdata = self.touchList[team][players[index]];
			if ( !isdefined( earliestTime ) || touchdata.starttime < earliestTime )
			{
				earliestPlayer = touchdata.player;
				earliestTime = touchdata.starttime;
			}
		}
	}

	return earliestPlayer;
}

useObjectProxThink()
{
	if ( (isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"]) || (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ) )
		return;

	level endon ( "game_ended" );

	self thread proxTriggerThink();

	while ( true )
	{
		if ( self.useTime && self.curProgress >= self.useTime )
		{
			self.curProgress = 0;

			creditPlayer = getEarliestClaimPlayer();

			if ( isDefined( self.onEndUse ) )
				self [[self.onEndUse]]( self getClaimTeam(), creditPlayer, isDefined( creditPlayer ) );

			if ( isDefined( creditPlayer ) && isDefined( self.onUse ) )
				self [[self.onUse]]( creditPlayer );

			self setClaimTeam( "none" );
			self.claimPlayer = undefined;
		}

		if ( self.claimTeam != "none" )
		{
			if ( self.useTime )
			{
				if ( !self.numTouching[self.claimTeam] )
				{
					if ( isDefined( self.onEndUse ) )
						self [[self.onEndUse]]( self getClaimTeam(), self.claimPlayer, false );

					self setClaimTeam( "none" );
					self.claimPlayer = undefined;
				}
				else
				{
					self.curProgress += (50 * self.useRate);
					if ( isDefined( self.onUseUpdate ) )
						self [[self.onUseUpdate]]( self getClaimTeam(), self.curProgress / self.useTime, (50*self.useRate) / self.useTime );
				}
			}
			else
			{
				if ( isDefined( self.onUse ) )
					self [[self.onUse]]( self.claimPlayer );

				self setClaimTeam( "none" );
				self.claimPlayer = undefined;
			}
		}

		wait ( .05 );
	}
}

proxTriggerThink()
{
	level endon ( "game_ended" );

	entityNumber = self.entNum;

	while ( true )
	{
		self.trigger waittill ( "trigger", player );

		if ( !isAlive( player ) )
			continue;

		if ( self canInteractWith( player.pers["team"] ) && self.claimTeam == "none" )
		{
			if ( !isDefined( self.keyObject ) || (isDefined( player.carryObject ) && player.carryObject == self.keyObject ) )
			{
				setClaimTeam( player.pers["team"] );
				self.claimPlayer = player;

				if ( self.useTime && isDefined( self.onBeginUse ) )
					self [[self.onBeginUse]]( self.claimPlayer );
			}
			else
			{
				if ( isDefined( self.onCantUse ) )
					self [[self.onCantUse]]( player );
			}
		}

		if ( self.useTime && isAlive( player ) && !isDefined( player.touchTriggers[entityNumber] ) )
			player thread triggerTouchThink( self );
	}
}

setClaimTeam( newTeam )
{
	assert( newTeam != self.claimTeam );

	if ( self.claimTeam == "none" && getTime() - self.lastClaimTime > 1000 )
		self.curProgress = 0;
	else if ( newTeam != "none" && newTeam != self.lastClaimTeam )
		self.curProgress = 0;

	self.lastClaimTeam = self.claimTeam;
	self.lastClaimTime = getTime();
	self.claimTeam = newTeam;

	self updateUseRate();
}

getClaimTeam()
{
	return self.claimTeam;
}

triggerTouchThink( object )
{
	team = self.pers["team"];

	object.numTouching[team]++;
	object updateUseRate();

	touchName = "player" + self.clientid;
	struct = spawnstruct();
	struct.player = self;
	struct.starttime = gettime();
	object.touchList[team][touchName] = struct;

	self.touchTriggers[object.entNum] = object.trigger;

	while ( isAlive( self ) && self isTouching( object.trigger ) && !level.gameEnded )
	{
		self updateProxBar( object, false );
		wait ( .05 );
	}

	if ( isDefined( self ) )
	{
		self updateProxBar( object, true );
		self.touchTriggers[object.entNum] = undefined;
	}

	if ( level.gameEnded )
		return;

	object.touchList[team][touchName] = undefined;

	object.numTouching[team]--;
	object updateUseRate();
}

updateProxBar( object, forceRemove )
{
	if ( forceRemove || !object canInteractWith( self.pers["team"] ) || self.pers["team"] != object.claimTeam )
	{
		if ( isDefined( self.proxBar ) )
			self.proxBar hideElem();

		if ( isDefined( self.proxBarText ) )
			self.proxBarText hideElem();
		return;
	}

	if ( !isDefined( self.proxBar ) )
	{
		self.proxBar = createPrimaryProgressBar();
		self.proxBar.lastUseRate = -1;
	}

	if ( self.proxBar.hidden )
	{
		self.proxBar showElem();
		self.proxBar.lastUseRate = -1;
	}

	if ( !isDefined( self.proxBarText ) )
	{
		self.proxBarText = createPrimaryProgressBarText();
		self.proxBarText setText( object.useText );
	}

	if ( self.proxBarText.hidden )
	{
		self.proxBarText showElem();
		self.proxBarText setText( object.useText );
	}

	if ( self.proxBar.lastUseRate != object.useRate )
	{
		if( object.curProgress > object.useTime)
			object.curProgress = object.useTime;

		self.proxBar updateBar( object.curProgress / object.useTime , (1000 / object.useTime) * object.useRate );
		self.proxBar.lastUseRate = object.useRate;
	}
}

updateUseRate()
{
	numClaimants = self.numTouching[self.claimTeam];
	numOther = 0;

	if ( self.claimTeam != "axis" )
		numOther += self.numTouching["axis"];
	if ( self.claimTeam != "allies" )
		numOther += self.numTouching["allies"];

	self.useRate = 0;

	if ( numClaimants && !numOther )
		self.useRate = numClaimants;
}

attachUseModel()
{
	self endon("death");
	self endon("disconnect");
	self endon("done_using");

	wait 1.3;

	self attach( "prop_suitcase_bomb", "tag_inhand", true );
	self.attachedUseModel = "prop_suitcase_bomb";
}

useHoldThink( player )
{
	player notify ( "use_hold" );
	player linkTo( self.trigger );
	player clientClaimTrigger( self.trigger );
	player.claimTrigger = self.trigger;

	lastWeapon = player getCurrentWeapon();

	player _disableWeapon();

	self.curProgress = 0;
	self.inUse = true;
	self.useRate = 0;

	player thread personalUseBar( self );

	result = useHoldThinkLoop( player, lastWeapon );

	if ( isDefined( player ) )
	{
		player detachUseModels();
		player notify( "done_using" );
	}

	if ( isdefined( result ) && result )
		return true;

	if ( isDefined( player ) )
	{
		player.claimTrigger = undefined;
		player _enableWeapon();
		player unlink();

		if ( !isAlive( player ) )
			player.killedInUse = true;
	}

	self.inUse = false;
	self.trigger releaseClaimedTrigger();
	return false;
}

detachUseModels()
{
	if ( isDefined( self.attachedUseModel ) )
	{
		self detach( self.attachedUseModel, "tag_inhand" );
		self.attachedUseModel = undefined;
	}
}

useHoldThinkLoop( player, lastWeapon )
{
	level endon ( "game_ended" );
	self endon("disabled");

	waitForWeapon = true;
	timedOut = 0;

	maxWaitTime = 1.5;

	while( isAlive( player ) && player isTouching( self.trigger ) && player useButtonPressed() && !player.throwingGrenade && !player meleeButtonPressed() && self.curProgress < self.useTime && (self.useRate || waitForWeapon) && !(waitForWeapon && timedOut > maxWaitTime) )
	{
		timedOut += .05;

		self.curProgress += (50 * self.useRate);
		self.useRate = 1;
		waitForWeapon = false;

		if ( self.curProgress >= self.useTime )
		{
			self.inUse = false;
			player clientReleaseTrigger( self.trigger );
			player.claimTrigger = undefined;
			player _enableWeapon();
			player unlink();

			return isAlive( player );
		}

		wait .05;
	}

	return false;
}

personalUseBar( object )
{
	self endon("disconnect");

	useBar = createPrimaryProgressBar();
	useBarText = createPrimaryProgressBarText();
	useBarText setText( object.useText );

	lastRate = -1;

	while ( isAlive( self ) && object.inUse && self useButtonPressed() && !level.gameEnded )
	{
		if ( lastRate != object.useRate )
		{
			if( object.curProgress > object.useTime)
				object.curProgress = object.useTime;
			useBar updateBar( object.curProgress / object.useTime, (1000 / object.useTime) * object.useRate );

			if ( !object.useRate )
			{
				useBar hideElem();
				useBarText hideElem();
			}
			else
			{
				useBar showElem();
				useBarText showElem();
			}
		}
		lastRate = object.useRate;
		wait ( .05 );
	}

	useBar destroyElem();
	useBarText destroyElem();
}

updateTrigger()
{
	if ( self.triggerType != "use" )
		return;

	if ( self.interactTeam == "none" )
	{
		self.trigger.origin -= (0,0,50000);
	}
	else if ( self.interactTeam == "any" )
	{
		self.trigger.origin = self.curOrigin;
		self.trigger setTeamForTrigger( "none" );
	}
	else if ( self.interactTeam == "friendly" )
	{
		self.trigger.origin = self.curOrigin;
		if ( self.ownerTeam == "allies" )
			self.trigger setTeamForTrigger( "allies" );
		else if ( self.ownerTeam == "axis" )
			self.trigger setTeamForTrigger( "axis" );
		else
			self.trigger.origin -= (0,0,50000);
	}
	else if ( self.interactTeam == "enemy" )
	{
		self.trigger.origin = self.curOrigin;
		if ( self.ownerTeam == "allies" )
			self.trigger setTeamForTrigger( "axis" );
		else if ( self.ownerTeam == "axis" )
			self.trigger setTeamForTrigger( "allies" );
		else
			self.trigger setTeamForTrigger( "none" );
	}
}

updateWorldIcons()
{
	if ( self.visibleTeam == "any" )
	{
		updateWorldIcon( "friendly", true );
		updateWorldIcon( "enemy", true );
	}
	else if ( self.visibleTeam == "friendly" )
	{
		updateWorldIcon( "friendly", true );
		updateWorldIcon( "enemy", false );
	}
	else if ( self.visibleTeam == "enemy" )
	{
		updateWorldIcon( "friendly", false );
		updateWorldIcon( "enemy", true );
	}
	else
	{
		updateWorldIcon( "friendly", false );
		updateWorldIcon( "enemy", false );
	}
}

updateWorldIcon( relativeTeam, showIcon )
{
	if ( !isDefined( self.worldIcons[relativeTeam] ) )
		showIcon = false;

	updateTeams = getUpdateTeams( relativeTeam );

	for ( index = 0; index < updateTeams.size; index++ )
	{
		opName = "objpoint_" + updateTeams[index] + "_" + self.entNum;
		objPoint = maps\mp\gametypes\_objpoints::getObjPointByName( opName );

		objPoint notify( "stop_flashing_thread" );
		objPoint thread maps\mp\gametypes\_objpoints::stopFlashing();

		if ( showIcon )
		{
			objPoint setShader( self.worldIcons[relativeTeam], level.objPointSize, level.objPointSize );
			objPoint fadeOverTime( 0.05 );
			objPoint.alpha = objPoint.baseAlpha;
			objPoint.isShown = true;

			if ( isDefined( self.compassIcons[relativeTeam] ) )
				objPoint setWayPoint( true, self.worldIcons[relativeTeam] );
			else
				objPoint setWayPoint( true );

			if ( self.type == "carryObject" )
			{
				if ( isDefined( self.carrier ) && !shouldPingObject( relativeTeam ) )
					objPoint SetTargetEnt( self.carrier );
				else
					objPoint ClearTargetEnt();
			}
		}
		else
		{
			objPoint fadeOverTime( 0.05 );
			objPoint.alpha = 0;
			objPoint.isShown = false;
			objPoint ClearTargetEnt();
		}
	}
}

updateCompassIcons()
{
	if ( self.visibleTeam == "any" )
	{
		updateCompassIcon( "friendly", true );
		updateCompassIcon( "enemy", true );
	}
	else if ( self.visibleTeam == "friendly" )
	{
		updateCompassIcon( "friendly", true );
		updateCompassIcon( "enemy", false );
	}
	else if ( self.visibleTeam == "enemy" )
	{
		updateCompassIcon( "friendly", false );
		updateCompassIcon( "enemy", true );
	}
	else
	{
		updateCompassIcon( "friendly", false );
		updateCompassIcon( "enemy", false );
	}
}

updateCompassIcon( relativeTeam, showIcon )
{
	updateTeams = getUpdateTeams( relativeTeam );

	for ( index = 0; index < updateTeams.size; index++ )
	{
		showIconThisTeam = showIcon;
		if ( !showIconThisTeam && shouldShowCompassDueToRadar( updateTeams[ index ] ) )
			showIconThisTeam = true;

		objId = self.objIDAllies;
		if ( updateTeams[ index ] == "axis" )
			objId = self.objIDAxis;

		if ( !isDefined( self.compassIcons[relativeTeam] ) || !showIconThisTeam )
		{
			objective_state( objId, "invisible" );
			continue;
		}

		objective_icon( objId, self.compassIcons[relativeTeam] );
		objective_state( objId, "active" );

		if ( self.type == "carryObject" )
		{
			if ( isAlive( self.carrier ) && !shouldPingObject( relativeTeam ) )
				objective_onentity( objId, self.carrier );
			else
				objective_position( objId, self.curOrigin );
		}
	}
}

shouldPingObject( relativeTeam )
{
	if ( relativeTeam == "friendly" && self.objIDPingFriendly )
		return true;
	else if ( relativeTeam == "enemy" && self.objIDPingEnemy )
		return true;

	return false;
}

getUpdateTeams( relativeTeam )
{
	updateTeams = [];
	if ( relativeTeam == "friendly" )
	{
		if ( self isFriendlyTeam( "allies" ) )
			updateTeams[0] = "allies";
		else if ( self isFriendlyTeam( "axis" ) )
			updateTeams[0] = "axis";
	}
	else if ( relativeTeam == "enemy" )
	{
		if ( !self isFriendlyTeam( "allies" ) )
			updateTeams[updateTeams.size] = "allies";

		if ( !self isFriendlyTeam( "axis" ) )
			updateTeams[updateTeams.size] = "axis";
	}

	return updateTeams;
}

shouldShowCompassDueToRadar( team )
{
	if ( !isdefined( self.carrier ) )
		return false;

	return getTeamRadar(team);
}

updateVisibilityAccordingToRadar()
{
	self endon("death");
	self endon("carrier_cleared");

	while(1)
	{
		level waittill("radar_status_change");
		self updateCompassIcons();
	}
}

setOwnerTeam( team )
{
	self.ownerTeam = team;
	self updateTrigger();
	self updateCompassIcons();
	self updateWorldIcons();
}

getOwnerTeam()
{
	return self.ownerTeam;
}

setUseTime( time )
{
	self.useTime = int( time * 1000 );
}

setUseText( text )
{
	self.useText = text;
}

setUseHintText( text )
{
	self.trigger setHintString( text );
}

allowCarry( relativeTeam )
{
	self.interactTeam = relativeTeam;
}

allowUse( relativeTeam )
{
	self.interactTeam = relativeTeam;
	updateTrigger();
}

setVisibleTeam( relativeTeam )
{
	self.visibleTeam = relativeTeam;

	updateCompassIcons();
	updateWorldIcons();
}

setModelVisibility( visibility )
{
	if ( visibility )
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[index] show();
			if ( self.visuals[index].classname == "script_brushmodel" || self.visuals[index].classname == "script_model" )
			{
				self.visuals[index] thread makeSolid();
			}
		}
	}
	else
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[index] hide();
			if ( self.visuals[index].classname == "script_brushmodel" || self.visuals[index].classname == "script_model" )
			{
				self.visuals[index] notify("changing_solidness");
				self.visuals[index] notsolid();
			}
		}
	}
}

makeSolid()
{
	self endon("death");
	self notify("changing_solidness");
	self endon("changing_solidness");

	while(1)
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[i] isTouching( self ) )
				break;
		}
		if ( i == level.players.size )
		{
			self solid();
			break;
		}
		wait .05;
	}
}

setCarrierVisible( relativeTeam )
{
	self.carrierVisible = relativeTeam;
}

setCanUse( relativeTeam )
{
	self.useTeam = relativeTeam;
}

set2DIcon( relativeTeam, shader )
{
	if ((isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"]) || (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ))
		return;

	self.compassIcons[relativeTeam] = shader;
	updateCompassIcons();
}

set3DIcon( relativeTeam, shader )
{
	if ((isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"]) || (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ))
		return;

	self.worldIcons[relativeTeam] = shader;
	updateWorldIcons();
}

set3DUseIcon( relativeTeam, shader )
{
	if ((isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"]) || (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ))
		return;

	self.worldUseIcons[relativeTeam] = shader;
}

setCarryIcon( shader )
{
	self.carryIcon = shader;
}

disableObject()
{
	self notify("disabled");

	if ( self.type == "carryObject" )
	{
		if ( isDefined( self.carrier ) )
			self.carrier takeObject( self );

		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[index] hide();
		}
	}

	self.trigger triggerOff();

	if ( level.gametype == "sd" )
		self setVisibleTeam( game["defenders"] );
	else
		self setVisibleTeam( "none" );
}

enableObject()
{
	if ( self.type == "carryObject" )
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[index] show();
		}
	}

	self.trigger triggerOn();
	self setVisibleTeam( "any" );
}

getRelativeTeam( team )
{
	if ( team == self.ownerTeam )
		return "friendly";
	else if ( team == self.enemyTeam )
		return "enemy";
	else
		return "neutral";
}

isFriendlyTeam( team )
{
	if ( self.ownerTeam == "any" )
		return true;

	if ( self.ownerTeam == team )
		return true;

	return false;
}

canInteractWith( team )
{
	switch( self.interactTeam )
	{
		case "none":
			return false;

		case "any":
			return true;

		case "friendly":
			if ( team == self.ownerTeam )
				return true;
			else
				return false;

		case "enemy":
			if ( team != self.ownerTeam )
				return true;
			else
				return false;

		default:
			assertEx( 0, "invalid interactTeam" );
			return false;
	}
}

isTeam( team )
{
	if ( team == "neutral" )
		return true;
	if ( team == "allies" )
		return true;
	if ( team == "axis" )
		return true;
	if ( team == "any" )
		return true;
	if ( team == "none" )
		return true;

	return false;
}

isRelativeTeam( relativeTeam )
{
	if ( relativeTeam == "friendly" )
		return true;
	if ( relativeTeam == "enemy" )
		return true;
	if ( relativeTeam == "any" )
		return true;
	if ( relativeTeam == "none" )
		return true;

	return false;
}

_disableWeapon()
{
	self.disabledWeapon++;
	self disableWeapons();
}

_enableWeapon()
{
	self.disabledWeapon--;

	if ( !self.disabledWeapon )
		self enableWeapons();
}

getEnemyTeam( team )
{
	if ( team == "neutral" )
		return "none";
	else if ( team == "allies" )
		return "axis";
	else
		return "allies";
}

getNextObjID()
{
	nextID = level.numGametypeReservedObjectives;

	level.numGametypeReservedObjectives++;
	return nextID;
}

getLabel()
{
	label = self.trigger.script_label;
	if ( !isDefined( label ) )
	{
		label = "";
		return label;
	}

	if ( label[0] != "_" )
		return ("_" + label);

	return label;
}