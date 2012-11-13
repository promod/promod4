/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;

onPlayerConnect()
{
	for(;;)
		level waittill("connected", player);
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
		if ( isDefined( level.restarting ) )
		{
			setdvar("g_gametype", "dm");
			setDvar( "o_gametype", "dm" );
		}
		else
			maps\mp\gametypes\_callbacksetup::AbortLevel();

		wait 1;
		return;
	}

	if ( !isDefined( level.spawnpoints ) )
		level.spawnpoints = [];

	for ( i = 0; i < level.teamSpawnPoints[team].size; i++ )
	{
		spawnpoint = level.teamSpawnPoints[team][i];

		if ( !isdefined( spawnpoint.inited ) )
		{
			spawnpoint spawnPointInit();
			level.spawnpoints[ level.spawnpoints.size ] = spawnpoint;
		}
	}

	for ( i = 0; i < oldSpawnPoints.size; i++ )
	{
		origin = oldSpawnPoints[i].origin;

		level.spawnMins = expandMins( level.spawnMins, origin );
		level.spawnMaxs = expandMaxs( level.spawnMaxs, origin );

		level.teamSpawnPoints[team][ level.teamSpawnPoints[team].size ] = oldSpawnPoints[i];
	}
}

placeSpawnPoints( spawnPointName )
{
	spawnPoints = getEntArray( spawnPointName, "classname" );

	if ( !spawnPoints.size )
	{
		if ( isDefined( level.restarting ) )
		{
			setdvar("g_gametype", "dm");
			setDvar( "o_gametype", "dm" );
		}
		else
			maps\mp\gametypes\_callbacksetup::AbortLevel();

		wait 1;
		return;
	}

	for( i = 0; i < spawnPoints.size; i++ )
		spawnPoints[i] spawnPointInit();
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
	prof_begin( "spawn_final" );

	bestspawnpoint = undefined;

	if ( !isdefined( spawnpoints ) || !spawnpoints.size )
		return undefined;

	if ( !isdefined( useweights ) )
		useweights = true;

	if ( useweights )
		bestspawnpoint = getBestWeightedSpawnpoint( spawnpoints );
	else
	{
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if( ( isdefined( self.lastspawnpoint ) && self.lastspawnpoint == spawnpoints[i] ) || positionWouldTelefrag( spawnpoints[i].origin ) )
				continue;

			bestspawnpoint = spawnpoints[i];
			break;
		}
		if ( !isdefined( bestspawnpoint ) && isdefined( self.lastspawnpoint ) && !positionWouldTelefrag( self.lastspawnpoint.origin ) )
		{
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

	if ( !isdefined( bestspawnpoint ) )
	{
		if ( useweights )
			bestspawnpoint = spawnpoints[randomint(spawnpoints.size)];
		else
			bestspawnpoint = spawnpoints[0];
	}

	time = getTime();

	self.lastspawnpoint = bestspawnpoint;
	self.lastspawntime = time;
	bestspawnpoint.lastspawnedplayer = self;
	bestspawnpoint.lastspawntime = time;

	prof_end( "spawn_final" );

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
		if ( !bestspawnpoints.size )
			return undefined;

		bestspawnpoint = bestspawnpoints[randomint( bestspawnpoints.size )];

		if ( try == maxSightTracedSpawnpoints || ( isdefined( bestspawnpoint.lastSightTraceTime ) && bestspawnpoint.lastSightTraceTime == gettime() ) || !lastMinuteSightTraces( bestspawnpoint ) )
			return bestspawnpoint;

		penalty = getLosPenalty();

		bestspawnpoint.weight -= penalty;

		bestspawnpoint.lastSightTraceTime = gettime();
	}
}

getSpawnpoint_Random(spawnpoints)
{
	if(!isdefined(spawnpoints))
		return undefined;

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

	for(i = 0; i < level.players.size; i++)
	{
		if ( !isdefined( level.players[i] ) || ( level.players[i].sessionstate != "playing" || level.players[i] == self ) )
			continue;

		aliveplayers[aliveplayers.size] = level.players[i];
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

initWeights(spawnpoints)
{
	for (i = 0; i < spawnpoints.size; i++)
		spawnpoints[i].weight = 0;
}

getSpawnpoint_NearTeam( spawnpoints, favoredspawnpoints )
{
	if(!isdefined(spawnpoints))
		return undefined;

	prof_begin("basic_spawnlogic");

	initWeights(spawnpoints);

	prof_begin("getteams");
	obj = spawnstruct();
	getAllAlliedAndEnemyPlayers(obj);
	prof_end("getteams");

	numplayers = obj.allies.size + obj.enemies.size;

	alliedDistanceWeight = 2;

	prof_begin("sumdists");
	myTeam = self.pers["team"];
	enemyTeam = getOtherTeam( myTeam );
	for (i = 0; i < spawnpoints.size; i++)
	{
		spawnpoint = spawnpoints[i];

		if ( isDefined( spawnpoint.numPlayersAtLastUpdate ) && spawnpoint.numPlayersAtLastUpdate > 0 )
		{
			allyDistSum = spawnpoint.distSum[ myTeam ];
			enemyDistSum = spawnpoint.distSum[ enemyTeam ];

			spawnpoint.weight = (enemyDistSum - alliedDistanceWeight*allyDistSum) / spawnpoint.numPlayersAtLastUpdate;
		}
		else
			spawnpoint.weight = 0;
	}
	prof_end("sumdists");

	if (isdefined(favoredspawnpoints))
		for (i = 0; i < favoredspawnpoints.size; i++)
			favoredspawnpoints[i].weight += 25000;

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
	if(!isdefined(spawnpoints))
		return undefined;

	initWeights(spawnpoints);

	aliveplayers = getAllOtherPlayers();

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

			spawnpoints[i].weight = wellDistancedAmount - nearbyBadAmount * 2 + randomfloat(0.2);
		}
	}

	avoidSameSpawn(spawnpoints);
	avoidSpawnReuse(spawnpoints, false);
	avoidWeaponDamage(spawnpoints);
	avoidVisibleEnemies(spawnpoints, false);

	return getSpawnpoint_Final(spawnpoints);
}

init()
{
	level.spawnlogic_deaths = [];

	level.players = [];
	level.grenades = [];
	level.pipebombs = [];

	level thread onPlayerConnect();
	level thread trackGrenades();
}

updateDeathInfo()
{
	prof_begin("updateDeathInfo");

	time = getTime();
	for (i = 0; i < level.spawnlogic_deaths.size; i++)
	{
		deathInfo = level.spawnlogic_deaths[i];

		if (time - deathInfo.time > 90000 ||
			!isdefined(deathInfo.killer) ||
			!isalive(deathInfo.killer) ||
			(deathInfo.killer.pers["team"] != "axis" && deathInfo.killer.pers["team"] != "allies") ||
			distance(deathInfo.killer.origin, deathInfo.killOrg) > 400) {
			level.spawnlogic_deaths[i].remove = true;
		}
	}

	oldarray = level.spawnlogic_deaths;
	level.spawnlogic_deaths = [];

	start = 0;
	if (oldarray.size - 1024 > 0) start = oldarray.size - 1024;

	for (i = start; i < oldarray.size; i++)
	{
		if (!isdefined(oldarray[i].remove))
			level.spawnlogic_deaths[level.spawnlogic_deaths.size] = oldarray[i];
	}

	prof_end("updateDeathInfo");
}

trackGrenades()
{
	for(;;)
	{
		level.grenades = getentarray("grenade", "classname");
		wait 0.05;
	}
}

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
		if (angle < level.claymoreDetectionConeAngle)
			return true;
	}
	return false;
}

avoidWeaponDamage(spawnpoints)
{
	prof_begin("spawn_grenade");

	for (i = 0; i < spawnpoints.size; i++)
	{
		for (j = 0; j < level.grenades.size; j++)
		{
			if ( !isdefined( level.grenades[j] ) )
				continue;

			if (distancesquared(spawnpoints[i].origin, level.grenades[j].origin) < 62500)
				spawnpoints[i].weight -= 100000;
		}
	}

	prof_end("spawn_grenade");
}

spawnPerFrameUpdate()
{
	spawnpointindex = 0;

	prevspawnpoint = undefined;

	for(;;)
	{
		wait 0.05;

		prof_begin("spawn_sight_checks");

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
			dist = length( diff );

			team = "all";
			if ( level.teambased )
				team = player.pers["team"];

			if ( dist < 1024 )
				spawnpoint.nearbyPlayers[team][spawnpoint.nearbyPlayers[team].size] = player;

			spawnpoint.distSum[ team ] += dist;
			spawnpoint.numPlayersAtLastUpdate++;

			pdir = anglestoforward(player.angles);
			if (vectordot(spawnpointdir, diff) < 0 && vectordot(pdir, diff) > 0)
				continue;

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
	return 100000;
}

lastMinuteSightTraces( spawnpoint )
{
	prof_begin("spawn_lastminutesc");

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

		if ( !isdefined( player ) || player.sessionstate != "playing" || player == self )
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

	if ( isdefined( closest ) && bullettracepassed( closest.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined) || ( isdefined( secondClosest ) && bullettracepassed( secondClosest.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined) ) )
		return true;

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
	prof_begin("spawn_reuse");

	time = getTime();

	maxtime = 10000;
	maxdistSq = 640000;

	for (i = 0; i < spawnpoints.size; i++)
	{
		if (!isdefined(spawnpoints[i].lastspawnedplayer) || !isdefined(spawnpoints[i].lastspawntime) || !isalive(spawnpoints[i].lastspawnedplayer) || spawnpoints[i].lastspawnedplayer == self || ( teambased && spawnpoints[i].lastspawnedplayer.pers["team"] == self.pers["team"] ) )
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
				spawnpoints[i].lastspawnedplayer = undefined;
		}
		else
			spawnpoints[i].lastspawnedplayer = undefined;
	}

	prof_end("spawn_reuse");
}

avoidSameSpawn(spawnpoints)
{
	prof_begin("spawn_samespwn");

	if (!isdefined(self.lastspawnpoint))
		return;

	for (i = 0; i < spawnpoints.size; i++)
	{
		if (spawnpoints[i] == self.lastspawnpoint)
		{
			spawnpoints[i].weight -= 50000;
			break;
		}
	}

	prof_end("spawn_samespwn");
}