/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include common_scripts\utility;
#include maps\mp\_utility;

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
	}
}

findBoxCenter( mins, maxs )
{
	center = ( 0, 0, 0 );
	center = maxs - mins;
	center = ( center[0]/2, center[1]/2, center[2]/2 ) + mins;
	return center;
}

expandMins( mins, point )
{
	if ( mins[0] > point[0] )
		mins = ( point[0], mins[1], mins[2] );
	if ( mins[1] > point[1] )
		mins = ( mins[0], point[1], mins[2] );
	if ( mins[2] > point[2] )
		mins = ( mins[0], mins[1], point[2] );
	return mins;
}

expandMaxs( maxs, point )
{
	if ( maxs[0] < point[0] )
		maxs = ( point[0], maxs[1], maxs[2] );
	if ( maxs[1] < point[1] )
		maxs = ( maxs[0], point[1], maxs[2] );
	if ( maxs[2] < point[2] )
		maxs = ( maxs[0], maxs[1], point[2] );
	return maxs;
}

addSpawnPoints( team, spawnPointName )
{
	oldSpawnPoints = [];
	if ( level.teamSpawnPoints[team].size )
		oldSpawnPoints = level.teamSpawnPoints[team];

	level.teamSpawnPoints[team] = getEntArray( spawnPointName, "classname" );

	if ( !level.teamSpawnPoints[team].size )
	{
		println( "^1No " + spawnPointName + " spawnpoints found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		wait 1; // so we don't try to abort more than once before the frame ends
		return;
	}

	if ( !isDefined( level.spawnpoints ) )
		level.spawnpoints = [];

	for ( index = 0; index < level.teamSpawnPoints[team].size; index++ )
	{
		spawnpoint = level.teamSpawnPoints[team][index];

		if ( !isdefined( spawnpoint.inited ) )
		{
			spawnpoint spawnPointInit();
			level.spawnpoints[ level.spawnpoints.size ] = spawnpoint;
		}
	}

	for ( index = 0; index < oldSpawnPoints.size; index++ )
	{
		origin = oldSpawnPoints[index].origin;

		// are these 2 lines necessary? we already did it in spawnPointInit
		level.spawnMins = expandMins( level.spawnMins, origin );
		level.spawnMaxs = expandMaxs( level.spawnMaxs, origin );

		level.teamSpawnPoints[team][ level.teamSpawnPoints[team].size ] = oldSpawnPoints[index];
	}
}

placeSpawnPoints( spawnPointName )
{
	spawnPoints = getEntArray( spawnPointName, "classname" );

	if ( !spawnPoints.size )
	{
		println( "^1No " + spawnPointName + " spawnpoints found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		wait 1; // so we don't try to abort more than once before the frame ends
		return;
	}

	for( index = 0; index < spawnPoints.size; index++ )
	{
		spawnPoints[index] spawnPointInit();
	}
}

spawnPointInit()
{
	spawnpoint = self;
	origin = spawnpoint.origin;

	level.spawnMins = expandMins( level.spawnMins, origin );
	level.spawnMaxs = expandMaxs( level.spawnMaxs, origin );

	spawnpoint placeSpawnpoint();
	spawnpoint.forward = anglesToForward( spawnpoint.angles );
	spawnpoint.sightTracePoint = spawnpoint.origin + (0,0,50);

	spawnpoint.inited = true;
}

getTeamSpawnPoints( team )
{
	return level.teamSpawnPoints[team];
}

getSpawnpoint_Final( spawnpoints, useweights )
{
	prof_begin( " spawn_final" );

	bestspawnpoint = undefined;

	if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
		return undefined;

	if ( !isdefined( useweights ) )
		useweights = true;

	if ( useweights )
	{
		// choose spawnpoint with best weight
		// (if a tie, choose randomly from the best)
		bestspawnpoint = getBestWeightedSpawnpoint( spawnpoints );
	}
	else
	{
		// (only place we actually get here from is getSpawnpoint_Random() )
		// no weights. prefer spawnpoints toward beginning of array
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if( isdefined( self.lastspawnpoint ) && self.lastspawnpoint == spawnpoints[i] )
				continue;

			if ( positionWouldTelefrag( spawnpoints[i].origin ) )
				continue;

			bestspawnpoint = spawnpoints[i];
			break;
		}
		if ( !isdefined( bestspawnpoint ) )
		{
			// Couldn't find a useable spawnpoint. All spawnpoints either telefragged or were our last spawnpoint
			// Our only hope is our last spawnpoint - unless it too will telefrag...
			if ( isdefined( self.lastspawnpoint ) && !positionWouldTelefrag( self.lastspawnpoint.origin ) )
			{
				// (make sure our last spawnpoint is in the valid array of spawnpoints to use)
				for ( i = 0; i < spawnpoints.size; i++ )
				{
					if ( spawnpoints[i] == self.lastspawnpoint )
					{
						bestspawnpoint = spawnpoints[i];
						break;
					}
				}
			}
		}
	}

	if ( !isdefined( bestspawnpoint ) )
	{
		// couldn't find a useable spawnpoint! all will telefrag.
		if ( useweights )
		{
			// at this point, forget about weights. just take a random one.
			bestspawnpoint = spawnpoints[randomint(spawnpoints.size)];
		}
		else
		{
			bestspawnpoint = spawnpoints[0];
		}
	}

	time = getTime();

	self.lastspawnpoint = bestspawnpoint;
	self.lastspawntime = time;
	bestspawnpoint.lastspawnedplayer = self;
	bestspawnpoint.lastspawntime = time;

	prof_end( " spawn_final" );

	return bestspawnpoint;
}

getBestWeightedSpawnpoint( spawnpoints )
{
	maxSightTracedSpawnpoints = 3;
	for ( try = 0; try <= maxSightTracedSpawnpoints; try++ )
	{
		bestspawnpoints = [];
		bestweight = undefined;
		bestspawnpoint = undefined;
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if ( !isdefined( bestweight ) || spawnpoints[i].weight > bestweight )
			{
				if ( positionWouldTelefrag( spawnpoints[i].origin ) )
					continue;

				bestspawnpoints = [];
				bestspawnpoints[0] = spawnpoints[i];
				bestweight = spawnpoints[i].weight;
			}
			else if ( spawnpoints[i].weight == bestweight )
			{
				if ( positionWouldTelefrag( spawnpoints[i].origin ) )
					continue;

				bestspawnpoints[bestspawnpoints.size] = spawnpoints[i];
			}
		}
		if ( bestspawnpoints.size == 0 )
			return undefined;

		// pick randomly from the available spawnpoints with the best weight
		bestspawnpoint = bestspawnpoints[randomint( bestspawnpoints.size )];

		if ( try == maxSightTracedSpawnpoints )
			return bestspawnpoint;

		if ( isdefined( bestspawnpoint.lastSightTraceTime ) && bestspawnpoint.lastSightTraceTime == gettime() )
			return bestspawnpoint;

		if ( !lastMinuteSightTraces( bestspawnpoint ) )
			return bestspawnpoint;

		penalty = getLosPenalty();

		bestspawnpoint.weight -= penalty;

		bestspawnpoint.lastSightTraceTime = gettime();
	}
}

getSpawnpoint_Random(spawnpoints)
{
//	level endon("game_ended");

	// There are no valid spawnpoints in the map
	if(!isdefined(spawnpoints))
		return undefined;

	// randomize order
	for(i = 0; i < spawnpoints.size; i++)
	{
		j = randomInt(spawnpoints.size);
		spawnpoint = spawnpoints[i];
		spawnpoints[i] = spawnpoints[j];
		spawnpoints[j] = spawnpoint;
	}

	return getSpawnpoint_Final(spawnpoints, false);
}

getAllOtherPlayers()
{
	aliveplayers = [];

	// Make a list of fully connected, non-spectating, alive players
	for(i = 0; i < level.players.size; i++)
	{
		if ( !isdefined( level.players[i] ) )
			continue;
		player = level.players[i];

		if ( player.sessionstate != "playing" || player == self )
			continue;

		aliveplayers[aliveplayers.size] = player;
	}
	return aliveplayers;
}

getAllAlliedAndEnemyPlayers( obj )
{
	if ( level.teambased )
	{
		if ( self.pers["team"] == "allies" )
		{
			obj.allies = level.alivePlayers["allies"];
			obj.enemies = level.alivePlayers["axis"];
		}
		else
		{
			assert( self.pers["team"] == "axis" );
			obj.allies = level.alivePlayers["axis"];
			obj.enemies = level.alivePlayers["allies"];
		}
	}
	else
	{
		obj.allies = [];
		obj.enemies = level.activePlayers;
	}
}

// weight array manipulation code
initWeights(spawnpoints)
{
	for (i = 0; i < spawnpoints.size; i++)
		spawnpoints[i].weight = 0;
}

getSpawnpoint_NearTeam( spawnpoints, favoredspawnpoints )
{
	// There are no valid spawnpoints in the map
	if(!isdefined(spawnpoints))
		return undefined;

	prof_begin("basic_spawnlogic");

	initWeights(spawnpoints);

	prof_begin(" getteams");
	obj = spawnstruct();
	getAllAlliedAndEnemyPlayers(obj);
	prof_end(" getteams");

	numplayers = obj.allies.size + obj.enemies.size;

	alliedDistanceWeight = 2;

	prof_begin(" sumdists");
	myTeam = self.pers["team"];
	enemyTeam = getOtherTeam( myTeam );
	for (i = 0; i < spawnpoints.size; i++)
	{
		spawnpoint = spawnpoints[i];

		if ( isDefined( spawnpoint.numPlayersAtLastUpdate ) && spawnpoint.numPlayersAtLastUpdate > 0 )
		{
			allyDistSum = spawnpoint.distSum[ myTeam ];
			enemyDistSum = spawnpoint.distSum[ enemyTeam ];

			// high enemy distance is good, high ally distance is bad
			spawnpoint.weight = (enemyDistSum - alliedDistanceWeight*allyDistSum) / spawnpoint.numPlayersAtLastUpdate;
		}
		else
		{
			spawnpoint.weight = 0;
		}
	}
	prof_end(" sumdists");

	if (isdefined(favoredspawnpoints))
	{
		for (i = 0; i < favoredspawnpoints.size; i++) {
			favoredspawnpoints[i].weight += 25000;
		}
	}

	prof_end("basic_spawnlogic");

	prof_begin("complex_spawnlogic");

	avoidSameSpawn(spawnpoints);
	avoidSpawnReuse(spawnpoints, true);
	avoidWeaponDamage(spawnpoints);
	avoidVisibleEnemies(spawnpoints, true);

	prof_end("complex_spawnlogic");

	result = getSpawnpoint_Final(spawnpoints);

	return result;
}

getSpawnpoint_DM(spawnpoints)
{
//	level endon("game_ended");

	// There are no valid spawnpoints in the map
	if(!isdefined(spawnpoints))
		return undefined;

	initWeights(spawnpoints);

	aliveplayers = getAllOtherPlayers();

	// new logic: we want most players near idealDist units away.
	// players closer than badDist units will be considered negatively
	idealDist = 1600;
	badDist = 1200;

	if (aliveplayers.size > 0)
	{
		for (i = 0; i < spawnpoints.size; i++)
		{
			totalDistFromIdeal = 0;
			nearbyBadAmount = 0;
			for (j = 0; j < aliveplayers.size; j++)
			{
				dist = distance(spawnpoints[i].origin, aliveplayers[j].origin);

				if (dist < badDist)
					nearbyBadAmount += (badDist - dist) / badDist;

				distfromideal = abs(dist - idealDist);
				totalDistFromIdeal += distfromideal;
			}
			avgDistFromIdeal = totalDistFromIdeal / aliveplayers.size;

			wellDistancedAmount = (idealDist - avgDistFromIdeal) / idealDist;
			// if (wellDistancedAmount < 0) wellDistancedAmount = 0;

			// wellDistancedAmount is between -inf and 1, 1 being best (likely around 0 to 1)
			// nearbyBadAmount is between 0 and inf,
			// and it is very important that we get a bad weight if we have a high nearbyBadAmount.

			spawnpoints[i].weight = wellDistancedAmount - nearbyBadAmount * 2 + randomfloat(.2);
		}
	}

	avoidSameSpawn(spawnpoints);
	avoidSpawnReuse(spawnpoints, false);
	avoidWeaponDamage(spawnpoints);
	avoidVisibleEnemies(spawnpoints, false);

	return getSpawnpoint_Final(spawnpoints);
}

// called once at start of game
init()
{
	// start keeping track of deaths
	level.spawnlogic_deaths = [];

	level.players = [];
	level.grenades = [];
	level.pipebombs = [];

	level thread onPlayerConnect();
	level thread trackGrenades();
}

updateDeathInfo()
{
	prof_begin(" updateDeathInfo");

	time = getTime();
	for (i = 0; i < level.spawnlogic_deaths.size; i++)
	{
		// if the killer has walked away or enough time has passed, get rid of this death information
		deathInfo = level.spawnlogic_deaths[i];

		if (time - deathInfo.time > 1000*90 || // if 90 seconds have passed
			!isdefined(deathInfo.killer) ||
			!isalive(deathInfo.killer) ||
			(deathInfo.killer.pers["team"] != "axis" && deathInfo.killer.pers["team"] != "allies") ||
			distance(deathInfo.killer.origin, deathInfo.killOrg) > 400) {
			level.spawnlogic_deaths[i].remove = true;
		}
	}

	// remove all deaths with remove set
	oldarray = level.spawnlogic_deaths;
	level.spawnlogic_deaths = [];

	// never keep more than the 1024 most recent entries in the array
	start = 0;
	if (oldarray.size - 1024 > 0) start = oldarray.size - 1024;

	for (i = start; i < oldarray.size; i++)
	{
		if (!isdefined(oldarray[i].remove))
			level.spawnlogic_deaths[level.spawnlogic_deaths.size] = oldarray[i];
	}

	prof_end(" updateDeathInfo");
}

trackGrenades()
{
	while ( 1 )
	{
		level.grenades = getentarray("grenade", "classname");
		wait .05;
	}
}

// used by spawning; needs to be fast.
isPointVulnerable(playerorigin)
{
	pos = self.origin + level.claymoremodelcenteroffset;
	playerpos = playerorigin + (0,0,32);
	distsqrd = distancesquared(pos, playerpos);

	forward = anglestoforward(self.angles);

	if (distsqrd < level.claymoreDetectionRadius*level.claymoreDetectionRadius)
	{
		playerdir = vectornormalize(playerpos - pos);
		angle = acos(vectordot(playerdir, forward));
		if (angle < level.claymoreDetectionConeAngle) {
			return true;
		}
	}
	return false;
}

avoidWeaponDamage(spawnpoints)
{
	prof_begin(" spawn_grenade");

	weaponDamagePenalty = 100000;
	if (getdvar("scr_spawnpointweaponpenalty") != "" && getdvar("scr_spawnpointweaponpenalty") != "0")
		weaponDamagePenalty = getdvarfloat("scr_spawnpointweaponpenalty");

	mingrenadedistsquared = 250*250; // (actual grenade radius is 220, 250 includes a safety area of 30 units)

	for (i = 0; i < spawnpoints.size; i++)
	{
		for (j = 0; j < level.grenades.size; j++)
		{
			if ( !isdefined( level.grenades[j] ) )
				continue;

			// could also do a sight check to see if it's really dangerous.
			if (distancesquared(spawnpoints[i].origin, level.grenades[j].origin) < mingrenadedistsquared)
				spawnpoints[i].weight -= weaponDamagePenalty;
		}

		if ( !isDefined( level.artilleryDangerCenters ) )
			continue;

		airstrikeDanger = maps\mp\gametypes\_hardpoints::getAirstrikeDanger( spawnpoints[i].origin ); // 0 = none, 1 = full, might be > 1 for more than 1 airstrike

		if ( airstrikeDanger > 0 )
		{
			worsen = airstrikeDanger * weaponDamagePenalty;
			spawnpoints[i].weight -= worsen;
		}
	}

	prof_end("spawn_grenade");
}

spawnPerFrameUpdate()
{
	spawnpointindex = 0;

	// each frame, do sight checks against a spawnpoint

	prevspawnpoint = undefined;

	while(1)
	{
		wait .05;

		prof_begin("spawn_sight_checks");

		//time = gettime();

		if ( !isDefined( level.spawnPoints ) )
			return;

		spawnpointindex = (spawnpointindex + 1) % level.spawnPoints.size;
		spawnpoint = level.spawnPoints[spawnpointindex];

		if ( level.teambased )
		{
			spawnpoint.sights["axis"] = 0;
			spawnpoint.sights["allies"] = 0;

			spawnpoint.nearbyPlayers["axis"] = [];
			spawnpoint.nearbyPlayers["allies"] = [];
		}
		else
		{
			spawnpoint.sights = 0;

			spawnpoint.nearbyPlayers["all"] = [];
		}

		spawnpointdir = spawnpoint.forward;

		spawnpoint.distSum["all"] = 0;
		spawnpoint.distSum["allies"] = 0;
		spawnpoint.distSum["axis"] = 0;

		spawnpoint.numPlayersAtLastUpdate = 0;

		for (i = 0; i < level.players.size; i++)
		{
			player = level.players[i];

			if ( player.sessionstate != "playing" )
				continue;

			diff = player.origin - spawnpoint.origin;
			dist = length( diff ); // needs to be actual distance for distSum value

			team = "all";
			if ( level.teambased )
				team = player.pers["team"];

			if ( dist < 1024 )
			{
				spawnpoint.nearbyPlayers[team][spawnpoint.nearbyPlayers[team].size] = player;
			}

			spawnpoint.distSum[ team ] += dist;
			spawnpoint.numPlayersAtLastUpdate++;

			pdir = anglestoforward(player.angles);
			if (vectordot(spawnpointdir, diff) < 0 && vectordot(pdir, diff) > 0)
				continue; // player and spawnpoint are looking in opposite directions

			// do sight check
			losExists = bullettracepassed(player.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined);

			spawnpoint.lastSightTraceTime = gettime();

			if (losExists)
			{
				if ( level.teamBased )
					spawnpoint.sights[player.pers["team"]]++;
				else
					spawnpoint.sights++;
			}
		}

		prof_end("spawn_sight_checks");
	}
}

getLosPenalty()
{
	if (getdvar("scr_spawnpointlospenalty") != "" && getdvar("scr_spawnpointlospenalty") != "0")
		return getdvarfloat("scr_spawnpointlospenalty");
	return 100000;
}

lastMinuteSightTraces( spawnpoint )
{
	prof_begin(" spawn_lastminutesc");

	team = "all";
	if ( level.teambased )
		team = getOtherTeam( self.pers["team"] );

	if ( !isdefined( spawnpoint.nearbyPlayers ) )
		return false;

	closest = undefined;
	closestDistsq = undefined;
	secondClosest = undefined;
	secondClosestDistsq = undefined;
	for ( i = 0; i < spawnpoint.nearbyPlayers[team].size; i++ )
	{
		player = spawnpoint.nearbyPlayers[team][i];

		if ( !isdefined( player ) )
			continue;
		if ( player.sessionstate != "playing" )
			continue;
		if ( player == self )
			continue;

		distsq = distanceSquared( spawnpoint.origin, player.origin );
		if ( !isdefined( closest ) || distsq < closestDistsq )
		{
			secondClosest = closest;
			secondClosestDistsq = closestDistsq;

			closest = player;
			closestDistSq = distsq;
		}
		else if ( !isdefined( secondClosest ) || distsq < secondClosestDistSq )
		{
			secondClosest = player;
			secondClosestDistSq = distsq;
		}
	}

	if ( isdefined( closest ) )
	{
		if ( bullettracepassed( closest.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined) )
			return true;
	}
	if ( isdefined( secondClosest ) )
	{
		if ( bullettracepassed( secondClosest.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined) )
			return true;
	}

	return false;
}

avoidVisibleEnemies(spawnpoints, teambased)
{
	lospenalty = getLosPenalty();

	otherteam = "axis";
	if ( self.pers["team"] == "axis" )
		otherteam = "allies";

	if ( teambased )
	{
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if ( !isdefined(spawnpoints[i].sights) )
				continue;

			penalty = lospenalty * spawnpoints[i].sights[otherteam];
			spawnpoints[i].weight -= penalty;
		}
	}
	else
	{
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if ( !isdefined(spawnpoints[i].sights) )
				continue;

			penalty = lospenalty * spawnpoints[i].sights;
			spawnpoints[i].weight -= penalty;
		}
	}
}

avoidSpawnReuse(spawnpoints, teambased)
{
	prof_begin(" spawn_reuse");

	time = getTime();

	maxtime = 10*1000;
	maxdistSq = 800 * 800;

	for (i = 0; i < spawnpoints.size; i++)
	{
		if (!isdefined(spawnpoints[i].lastspawnedplayer) || !isdefined(spawnpoints[i].lastspawntime) ||
			!isalive(spawnpoints[i].lastspawnedplayer))
			continue;

		if (spawnpoints[i].lastspawnedplayer == self)
			continue;
		if (teambased && spawnpoints[i].lastspawnedplayer.pers["team"] == self.pers["team"])
			continue;

		timepassed = time - spawnpoints[i].lastspawntime;
		if (timepassed < maxtime)
		{
			distSq = distanceSquared(spawnpoints[i].lastspawnedplayer.origin, spawnpoints[i].origin);
			if (distSq < maxdistSq)
			{
				worsen = 1000 * (1 - distSq/maxdistSq) * (1 - timepassed/maxtime);
				spawnpoints[i].weight -= worsen;
			}
			else
				spawnpoints[i].lastspawnedplayer = undefined; // don't worry any more about this spawnpoint
		}
		else
			spawnpoints[i].lastspawnedplayer = undefined; // don't worry any more about this spawnpoint
	}

	prof_end(" spawn_reuse");
}

avoidSameSpawn(spawnpoints)
{
	prof_begin(" spawn_samespwn");

	if (!isdefined(self.lastspawnpoint))
		return;

	for (i = 0; i < spawnpoints.size; i++)
	{
		if (spawnpoints[i] == self.lastspawnpoint)
		{
			spawnpoints[i].weight -= 50000; // (half as bad as a likely spawn kill)
			break;
		}
	}

	prof_end(" spawn_samespwn");
}