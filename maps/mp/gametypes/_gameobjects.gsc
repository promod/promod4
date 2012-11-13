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
				entitytypes[i] delete();
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

	for(;;)
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

	if ( !isDefined( offset ) )
		offset = (0,0,0);

	carryObject.offset3d = offset;

	for ( i = 0; i < visuals.size; i++ )
	{
		visuals[i].baseOrigin = visuals[i].origin;
		visuals[i].baseAngles = visuals[i].angles;
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

	for(;;)
	{
		self.trigger waittill ( "trigger", player );

		if ( self.isResetting || !isAlive( player ) || !self canInteractWith( player.pers["team"] ) || !player.canPickupObject || player.throwingGrenade || isDefined( self.carrier ) )
			continue;

		self setPickedUp( player );
	}
}

carryObjectProxThink()
{
	level endon ( "game_ended" );

	for(;;)
	{
		self.trigger waittill ( "trigger", player );

		if ( self.isResetting || !isAlive( player ) || !self canInteractWith( player.pers["team"] ) || !player.canPickupObject || isDefined( self.carrier ) )
			continue;

		if ( (isDefined( level.timeout_over ) && !level.timeout_over) || ( isDefined( game["PROMOD_KNIFEROUND"] ) && game["PROMOD_KNIFEROUND"] ) )
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

	for(;;)
	{
		if ( distanceSquared( self.origin, origin ) > 4096 )
			break;

		wait 0.2;
	}

	self.canPickupObject = true;
}

setPickedUp( player )
{
	player giveObject( self );

	self.carrier = player;

	for ( i = 0; i < self.visuals.size; i++ )
		self.visuals[i] hide();

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

	objPingDelay = 5;
	for(;;)
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
					self.objPoints["allies"] fadeOverTime( objPingDelay + 1 );
					self.objPoints["allies"].alpha = 0;
				}
				objective_position( self.objIDAllies, self.curOrigin );
			}
			else if ( (self.visibleTeam == "friendly" || self.visibleTeam == "any") && self isFriendlyTeam( "axis" ) && self.objIDPingFriendly )
			{
				if ( self.objPoints["axis"].isShown )
				{
					self.objPoints["axis"].alpha = self.objPoints["axis"].baseAlpha;
					self.objPoints["axis"] fadeOverTime( objPingDelay + 1 );
					self.objPoints["axis"].alpha = 0;
				}
				objective_position( self.objIDAxis, self.curOrigin );
			}

			if ( (self.visibleTeam == "enemy" || self.visibleTeam == "any") && !self isFriendlyTeam( "allies" ) && self.objIDPingEnemy )
			{
				if ( self.objPoints["allies"].isShown )
				{
					self.objPoints["allies"].alpha = self.objPoints["allies"].baseAlpha;
					self.objPoints["allies"] fadeOverTime( objPingDelay + 1 );
					self.objPoints["allies"].alpha = 0;
				}
				objective_position( self.objIDAllies, self.curOrigin );
			}
			else if ( (self.visibleTeam == "enemy" || self.visibleTeam == "any") && !self isFriendlyTeam( "axis" ) && self.objIDPingEnemy )
			{
				if ( self.objPoints["axis"].isShown )
				{
					self.objPoints["axis"].alpha = self.objPoints["axis"].baseAlpha;
					self.objPoints["axis"] fadeOverTime( objPingDelay + 1 );
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

			wait 0.05;
		}
	}
}

giveObject( object )
{
	self.carryObject = object;
	self thread trackCarrier();

	if ( isDefined( object.carryIcon ) )
	{
		self.carryIcon = createIcon( object.carryIcon, 50, 50 );
		self.carryIcon setPoint( "CENTER", "CENTER", 223, 167 );
	}

	if ( isDefined( level.scorebot ) && level.scorebot )
		level thread maps\mp\gametypes\_globallogic::updateTeamStatus();
}

returnHome()
{
	self.isResetting = true;

	self notify ( "reset" );
	for ( i = 0; i < self.visuals.size; i++ )
	{
		self.visuals[i].origin = self.visuals[i].baseOrigin;
		self.visuals[i].angles = self.visuals[i].baseAngles;
		self.visuals[i] show();
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
		if ( angleTrace["fraction"] < 1 && distance( angleTrace["position"], trace ) < 10 )
		{
			forward = (cos( tempAngle ), sin( tempAngle ), 0);
			forward = vectornormalize( forward - vector_scale( angleTrace["normal"], vectordot( forward, angleTrace["normal"] ) ) );
			dropAngles = vectortoangles( forward );
		}
		else
			dropAngles = (0,tempAngle,0);

		for ( i = 0; i < self.visuals.size; i++ )
		{
			self.visuals[i].origin = dropOrigin;
			self.visuals[i].angles = dropAngles;
			self.visuals[i] show();
		}
		self.trigger.origin = dropOrigin;

		self.curOrigin = self.trigger.origin;

		self thread pickupTimeout();
	}
	else
	{
		for ( i = 0; i < self.visuals.size; i++ )
		{
			self.visuals[i].origin = self.visuals[i].baseOrigin;
			self.visuals[i].angles = self.visuals[i].baseAngles;
			self.visuals[i] show();
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

clearCarrier()
{
	if ( !isdefined( self.carrier ) )
		return;

	self.carrier takeObject( self );
	self.carrier.carryObject = undefined;
	self.carrier = undefined;
}

pickupTimeout()
{
	self endon ( "pickup_object" );

	wait 0.05;

	mineTriggers = getEntArray( "minefield", "targetname" );
	hurtTriggers = getEntArray( "trigger_hurt", "classname" );

	for ( i = 0; i < mineTriggers.size; i++ )
	{
		if ( !self.visuals[0] isTouching( mineTriggers[i] ) )
			continue;

		self returnHome();
		return;
	}

	for ( i = 0; i < hurtTriggers.size; i++ )
	{
		if ( !self.visuals[0] isTouching( hurtTriggers[i] ) )
			continue;

		self returnHome();
		return;
	}

	if ( isDefined( self.autoResetTime ) )
	{
		wait self.autoResetTime;

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

	if ( isDefined( level.scorebot ) && level.scorebot )
		level thread maps\mp\gametypes\_globallogic::updateTeamStatus();
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
		wait 0.05;
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

	for ( i = 0; i < visuals.size; i++ )
	{
		visuals[i].baseOrigin = visuals[i].origin;
		visuals[i].baseAngles = visuals[i].angles;
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

	for(;;)
	{
		self.trigger waittill ( "trigger", player );

		while ( isDefined( player ) && player isTouching( self.trigger ) && !player isOnGround() )
			wait 0.05;

		if ( !isAlive( player ) || !self canInteractWith( player.pers["team"] ) || !player isTouching( self.trigger ) || !player useButtonPressed() )
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

			if ( isDefined( self.onEndUse ) && isDefined( player ) )
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
	team = self.claimTeam;

	earliestPlayer = self.claimPlayer;

	if ( self.touchList[team].size > 0 )
	{
		earliestTime = undefined;
		players = getArrayKeys( self.touchList[team] );
		for ( i = 0; i < players.size; i++ )
		{
			touchdata = self.touchList[team][players[i]];
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

	for(;;)
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

		wait 0.05;
	}
}

proxTriggerThink()
{
	level endon ( "game_ended" );

	entityNumber = self.entNum;

	for(;;)
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

	while ( isDefined( self ) && isAlive( self ) && self isTouching( object.trigger ) && !level.gameEnded )
	{
		self updateProxBar( object, false );
		wait 0.05;
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
		self.proxBar setShader( "progress_bar_bg", 120, 8 );
		self.proxBar.alpha = 1;
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

useHoldThink( player )
{
	player clientClaimTrigger( self.trigger );
	player.claimTrigger = self.trigger;

	player linkTo( self.trigger );
	player _disableWeapon();

	self.curProgress = 0;
	self.inUse = true;
	self.useRate = 0;

	player thread personalUseBar( self );

	result = useHoldThinkLoop( player );

	if ( isdefined( result ) && result )
		return true;

	if ( isDefined( player ) )
	{
		player.claimTrigger = undefined;
		player _enableWeapon();

		if ( !isAlive( player ) )
			player.killedInUse = true;
	}

	self.inUse = false;
	self.trigger releaseClaimedTrigger();
	return false;
}

useHoldThinkLoop( player )
{
	level endon ( "game_ended" );
	self endon("disabled");

	waitForWeapon = true;
	timedOut = 0;

	maxWaitTime = 1.5;

	while( isDefined( player ) && isAlive( player ) && player isTouching( self.trigger ) && player useButtonPressed() && !player.throwingGrenade && !player meleeButtonPressed() && self.curProgress < self.useTime && (self.useRate || waitForWeapon) && !(waitForWeapon && timedOut > maxWaitTime) )
	{
		timedOut += 0.05;

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

		wait 0.05;
	}

	return false;
}

personalUseBar( object )
{
	self endon("disconnect");

	useBar = createPrimaryProgressBar();
	useBar setShader( "progress_bar_bg", 120, 8 );
	useBar.alpha = 1;
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
		wait 0.05;
	}

	if ( level.gameEnded )
	{
		self _enableWeapon();
		self unlink();
	}

	useBar destroyElem();
	useBarText destroyElem();
}

updateTrigger()
{
	if ( self.triggerType != "use" )
		return;

	if ( self.interactTeam == "none" )
		self.trigger.origin -= (0,0,50000);
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

	for ( i = 0; i < updateTeams.size; i++ )
	{
		opName = "objpoint_" + updateTeams[i] + "_" + self.entNum;
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

	for ( i = 0; i < updateTeams.size; i++ )
	{
		showIconThisTeam = showIcon;

		objId = self.objIDAllies;
		if ( updateTeams[i] == "axis" )
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
	if ( ( relativeTeam == "friendly" && self.objIDPingFriendly ) || ( relativeTeam == "enemy" && self.objIDPingEnemy ) )
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
		for ( i = 0; i < self.visuals.size; i++ )
		{
			self.visuals[i] show();
			if ( self.visuals[i].classname == "script_brushmodel" || self.visuals[i].classname == "script_model" )
				self.visuals[i] thread makeSolid();
		}
	}
	else
	{
		for ( i = 0; i < self.visuals.size; i++ )
		{
			self.visuals[i] hide();
			if ( self.visuals[i].classname == "script_brushmodel" || self.visuals[i].classname == "script_model" )
			{
				self.visuals[i] notify("changing_solidness");
				self.visuals[i] notsolid();
			}
		}
	}
}

makeSolid()
{
	self endon("death");
	self notify("changing_solidness");
	self endon("changing_solidness");

	for(;;)
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
		wait 0.05;
	}
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

		for ( i = 0; i < self.visuals.size; i++ )
			self.visuals[i] hide();
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
		for ( i = 0; i < self.visuals.size; i++ )
			self.visuals[i] show();
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
	if ( self.ownerTeam == "any" || self.ownerTeam == team )
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
			return false;
	}
}

_disableWeapon()
{
	self allowsprint(false);
	self allowjump(false);
	self setMoveSpeedScale( 0 );

	self disableweapons();

	self thread xunlink();
}

xunlink()
{
	self endon("disconnect");

	wait 0.05;
	self unlink();
}

_enableWeapon()
{
	self endon("disconnect");

	self enableweapons();

	wait 0.05;

	self allowsprint(true);
	self allowjump(true);
	self setMoveSpeedScale( 1.0 - 0.05 * int( isDefined( self.curClass ) && self.curClass == "assault" ) );
}

getEnemyTeam( team )
{
	switch(team)
	{
		case "allies":
			return "axis";
		case "axis":
			return "allies";
		default:
			return "none";
	}
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