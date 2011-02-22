/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	level.destructibleSpawnedEntsLimit = 25;
	level.destructibleSpawnedEnts = [];

	find_destructibles();

	array_levelthread( getEntArray( "delete_on_load", "targetname" ), ::deleteEnt );
}

destructible_create( type, health, validAttackers, validDamageZone, validDamageCause )
{
	if( !isdefined( level.destructible_type ) )
		level.destructible_type = [];

	destructibleIndex = level.destructible_type.size;

	destructibleIndex = level.destructible_type.size;
	level.destructible_type[ destructibleIndex ] = spawnStruct();
	level.destructible_type[ destructibleIndex ].v[ "type" ] = type;

	level.destructible_type[ destructibleIndex ].parts = [];
	level.destructible_type[ destructibleIndex ].parts[ 0 ][ 0 ] = spawnStruct();
	level.destructible_type[ destructibleIndex ].parts[ 0 ][ 0 ].v[ "modelName" ] = self.model;
	level.destructible_type[ destructibleIndex ].parts[ 0 ][ 0 ].v[ "health" ] = health;
	level.destructible_type[ destructibleIndex ].parts[ 0 ][ 0 ].v[ "validAttackers" ] = validAttackers;
	level.destructible_type[ destructibleIndex ].parts[ 0 ][ 0 ].v[ "validDamageZone" ] = validDamageZone;
	level.destructible_type[ destructibleIndex ].parts[ 0 ][ 0 ].v[ "validDamageCause" ] = validDamageCause;
}

destructible_part( tagName, modelName, health, noDraw, validDamageZone, validDamageCause, alsoDamageParent, physicsOnExplosion )
{
	destructibleIndex = ( level.destructible_type.size - 1 );

	partIndex = level.destructible_type[ destructibleIndex ].parts.size;

	stateIndex = 0;

	destructible_info( partIndex, stateIndex, tagName, modelName, health, noDraw, validDamageZone, validDamageCause, alsoDamageParent, physicsOnExplosion );
}

destructible_state( tagName, modelName, health, noDraw, validDamageZone, validDamageCause )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size );

	destructible_info( partIndex, stateIndex, tagName, modelName, health, noDraw, validDamageZone, validDamageCause );
}

destructible_fx( tagName, fxName, useTagAngles )
{
	if ( !isdefined( useTagAngles ) )
		useTagAngles = true;

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "fx_filename" ] = fxName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "fx_tag" ] = tagName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "fx_useTagAngles" ] = useTagAngles;
}

destructible_loopfx( tagName, fxName, loopRate )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopfx_filename" ] = fxName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopfx_tag" ] = tagName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopfx_rate" ] = loopRate;
}

destructible_healthdrain( amount, interval )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "healthdrain_amount" ] = amount;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "healthdrain_interval" ] = interval;
}

destructible_sound( soundAlias, soundCause )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	if ( !isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "sound" ] ) )
	{
		level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "sound" ] = [];
		level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "soundCause" ] = [];
	}

	index = level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "sound" ].size;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "sound" ][ index ] = soundAlias;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "soundCause" ][ index ] = soundCause;
}

destructible_loopsound( soundAlias, loopsoundCause )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	if ( !isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ] ) )
	{
		level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ] = [];
		level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsoundCause" ] = [];
	}

	index = level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ].size;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ][ index ] = soundAlias;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsoundCause" ][ index ] = loopsoundCause;
}

destructible_physics()
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "physics" ] = true;
}

destructible_explode( force_min, force_max, range, mindamage, maxdamage )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_force_min" ] = force_min;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_force_max" ] = force_max;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_range" ] = range;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_mindamage" ] = mindamage;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_maxdamage" ] = maxdamage;
}

destructible_info( partIndex, stateIndex, tagName, modelName, health, noDraw, validDamageZone, validDamageCause, alsoDamageParent, physicsOnExplosion )
{
	if ( isDefined( modelName ) )
		modelName = toLower( modelName );

	destructibleIndex = ( level.destructible_type.size - 1 );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] = spawnStruct();
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "modelName" ] = modelName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "tagName" ] = tagName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "health" ] = health;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "noDraw" ] = noDraw;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "validDamageZone" ] = validDamageZone;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "validDamageCause" ] = validDamageCause;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "alsoDamageParent" ] = alsoDamageParent;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "physicsOnExplosion" ] = physicsOnExplosion;
}

find_destructibles()
{
	array_thread( getentarray( "destructible", "targetname" ), ::setup_destructibles );
}

precache_destructibles()
{
	if ( isdefined( level.destructible_type[self.destuctableInfo].parts ) )
	{
		for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts.size ; i++ )
		{
			for( j = 0 ; j < level.destructible_type[ self.destuctableInfo ].parts[ i ].size ; j++ )
			{
				if( level.destructible_type[ self.destuctableInfo ].parts[ i ].size <= j )
					continue;

				if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "modelName" ] ) )
					precacheModel( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "modelName" ] );

				if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "fx_filename" ] ) )
					level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "fx" ] = loadfx( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "fx_filename" ] );

				if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "loopfx_filename" ] ) )
					level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "loopfx" ] = loadfx( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "loopfx_filename" ] );
			}
		}
	}
}

setup_destructibles()
{
	destuctableInfo = undefined;

	self.destuctableInfo = maps\mp\_destructible_types::makeType( self.destructible_type );

	if ( self.destuctableInfo < 0 )
		return;

	precache_destructibles();

	if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts ) )
	{
		self.destructible_parts = [];
		for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts.size ; i++ )
		{
			self.destructible_parts[ i ] = spawnStruct();

			self.destructible_parts[ i ].v[ "currentState" ] = 0;

			if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "health" ] ) )
				self.destructible_parts[ i ].v[ "health" ] = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "health" ];

			if ( !i )
				continue;

			modelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "modelName" ];
			tagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "tagName" ];

			stateIndex = 1;
			while ( isDefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ] ) )
			{
				stateTagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ];
				stateModelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "modelName" ];
				if ( isDefined( stateTagName ) && stateTagName != tagName )
					self hideapart( stateTagName );
				stateIndex++;
			}
		}
	}

	if( self.classname != "script_vehicle" )
		self setCanDamage( true );
	self thread destructible_think();
}

damage_mirror( parent, modelName, tagName )
{
	self notify( "stop_damage_mirror" );
	self endon( "stop_damage_mirror" );
	parent endon( "stop_taking_damage" );

	self setCanDamage( true );
	for(;;)
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type );
		parent notify ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName );
	}
}

destructible_think()
{
	self endon( "stop_taking_damage" );
	for(;;)
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags );

		if ( !isdefined( damage ) || damage <= 0 || ( isDefined( level.strat_over ) && !level.strat_over ) )
			continue;

		if ( isDefined( attacker ) && isPlayer( attacker ) )
			self.damageOwner = attacker;

		type = getDamageType( type );

		if ( modelName == "" )
			modelName = self.model;

		if ( isdefined( tagName ) && tagName == "" )
		{
			if ( isdefined( partName ) && partName != "" && partName != "tag_body" )
				tagName = partName;
			else
				tagName = undefined;
		}

		if ( type == "splash" )
		{
			damage *= 2.75;

			self destructible_splash_damage( int( damage ), point, direction_vec, attacker, type );
			continue;
		}

		self thread destructible_update_part( int( damage ), modelName, tagName, point, direction_vec, attacker, type );
	}
}

destructible_update_part( damage, modelName, tagName, point, direction_vec, attacker, damageType )
{
	if ( !isdefined( self.destructible_parts ) || !self.destructible_parts.size )
		return;

	partIndex = -1;
	stateIndex = -1;

	if ( ( tolower( modelName ) == tolower( self.model ) ) && ( !isdefined( tagName ) ) )
	{
		modelName = self.model;
		tagName = undefined;
		partIndex = 0;
		stateIndex = 0;
	}

	for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts.size ; i++ )
	{
		stateIndex = self.destructible_parts[ i ].v[ "currentState" ];

		if( level.destructible_type[ self.destuctableInfo ].parts[ i ].size <= stateIndex || !isdefined( tagName ) || !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "modelName" ] ) )
			continue;

		if ( isDefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ] ) && level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ] == tagName )
		{
			partIndex = i;
			break;
		}
	}

	if ( partIndex < 0 )
		return;

	state_before = stateIndex;
	updateHealthValue = false;
	delayModelSwap = false;
	for(;;)
	{
		stateIndex = self.destructible_parts[ partIndex ].v[ "currentState" ];

		if ( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ] ) )
			break;

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ 0 ].v[ "alsoDamageParent" ] ) && getDamageType( damageType ) != "splash" )
		{
			ratio = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ 0 ].v[ "alsoDamageParent" ];
			parentDamage = int( damage * ratio );
			self thread notifyDamageAfterFrame( parentDamage, attacker, direction_vec, point, damageType, "", "" );
		}

		if ( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "health" ] ) || !isdefined( self.destructible_parts[ partIndex ].v[ "health" ] ) )
			break;

		if ( updateHealthValue )
			self.destructible_parts[ partIndex ].v[ "health" ] = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "health" ];
		updateHealthValue = false;

		validDamageCause = self isValidDamageCause( partIndex, stateIndex, damageType );
		if ( validDamageCause )
		{
			if ( damageType == "melee" || damageType == "impact" )
				damage = 100000;

			self.destructible_parts[ partIndex ].v[ "health" ] -= damage;
		}

		if ( self.destructible_parts[ partIndex ].v[ "health" ] > 0 )
			return;

		damage = int( abs( self.destructible_parts[ partIndex ].v[ "health" ] ) );
		if ( damage < 0 )
			return;
		self.destructible_parts[ partIndex ].v[ "currentState" ]++;
		stateIndex = self.destructible_parts[ partIndex ].v[ "currentState" ];
		actionStateIndex = ( stateIndex - 1 );

		if ( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ] ) )
			return;

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_force_min" ] ) )
			self.exploding = true;

		if ( ( isdefined( self.loopingSoundStopNotifies ) ) && ( isdefined( self.loopingSoundStopNotifies[ string( partIndex ) ] ) ) )
		{
			for( i = 0 ; i < self.loopingSoundStopNotifies[ string( partIndex ) ].size ; i++ )
				self notify( self.loopingSoundStopNotifies[ string( partIndex ) ][ i ] );
			self.loopingSoundStopNotifies[ string( partIndex ) ] = undefined;
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ] ) )
		{
			if ( !partIndex )
			{
				newModel = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "modelName" ];
				self setModel( newModel );
			}
			else
			{
				self hideapart( tagName );
				modelName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "modelName" ];
				tagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "tagName" ];

				if ( isdefined( modelName ) && isdefined( tagName ) )
					self showapart( tagName );
			}
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx" ] ) )
		{
			fx = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx" ];
			fx_tag = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx_tag" ];
			self notify( "FX_State_Change" + partIndex );
			if ( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx_useTagAngles" ] )
				playfxontag ( fx, self, fx_tag );
			else
			{
				fxOrigin = self getTagOrigin( fx_tag );
				forward = ( fxOrigin + ( 0, 0, 100 ) ) - fxOrigin;
				playfx ( fx, fxOrigin, forward );
			}
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx" ] ) )
		{
			loopfx = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx" ];
			loopfx_tag = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx_tag" ];
			loopRate = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx_rate" ];
			self notify( "FX_State_Change" + partIndex );
			self thread loopfx_onTag( loopfx, loopfx_tag, loopRate, partIndex );
		}

		if ( !isdefined( self.exploded ) && isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "sound" ] ) )
		{
			for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "sound" ].size ; i++ )
			{
				validSoundCause = self isValidSoundCause( "soundCause", partIndex, actionStateIndex, i, damageType );
				if ( validSoundCause )
				{
					soundAlias = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "sound" ][ i ];
					soundTagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "tagName" ];

					self thread play_sound_on_tag( soundAlias, soundTagName );
				}
			}
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopsound" ] ) )
		{
			for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopsound" ].size ; i++ )
			{
				validSoundCause = self isValidSoundCause( "loopsoundCause", partIndex, actionStateIndex, i, damageType );
				if ( validSoundCause )
				{
					loopsoundAlias = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopsound" ][ i ];
					loopsoundTagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "tagName" ];
					self thread play_loop_sound_on_destructible( loopsoundAlias, loopsoundTagName );

					if ( !isdefined( self.loopingSoundStopNotifies ) )
						self.loopingSoundStopNotifies = [];
					if ( !isdefined( self.loopingSoundStopNotifies[ string( partIndex ) ] ) )
						self.loopingSoundStopNotifies[ string( partIndex ) ] = [];
					size = self.loopingSoundStopNotifies[ string( partIndex ) ].size;
					self.loopingSoundStopNotifies[ string( partIndex ) ][ size ] = "stop sound" + loopsoundAlias;
				}
			}
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "healthdrain_amount" ] ) )
		{
			self notify( "Health_Drain_State_Change" + partIndex );
			healthdrain_amount = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "healthdrain_amount" ];
			healthdrain_interval = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "healthdrain_interval" ];
			healthdrain_modelName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "modelName" ];
			healthdrain_tagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "tagName" ];
			if ( healthdrain_amount > 0 )
				self thread health_drain( healthdrain_amount, healthdrain_interval, partIndex, healthdrain_modelName, healthdrain_tagName );
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_force_min" ] ) )
		{
			delayModelSwap = true;
			force_min = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_force_min" ];
			force_max = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_force_max" ];
			range = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_range" ];
			mindamage = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_mindamage" ];
			maxdamage = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_maxdamage" ];
			self thread explode( partIndex, force_min, force_max, range, mindamage, maxdamage );
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "physics" ] ) )
			return;

		updateHealthValue = true;
	}
}

destructible_splash_damage( damage, point, direction_vec, attacker, damageType )
{
	if ( damage <= 0 || isDefined( self.exploded ) )
		return;

	damagedParts = [];
	closestPartDist = undefined;
	if ( isdefined( level.destructible_type[self.destuctableInfo].parts ) )
	{
		for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts.size ; i++ )
		{
			for( j = 0 ; j < level.destructible_type[ self.destuctableInfo ].parts[ i ].size ; j++ )
			{
				if( level.destructible_type[ self.destuctableInfo ].parts[ i ].size <= j )
					continue;

				if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "modelName" ] ) )
				{
					modelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "modelName" ];

					if ( !i )
					{
						d = distance( point, self.origin );
						tagName = undefined;
					}
					else
					{
						tagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "tagName" ];
						d = distance( point, self getTagOrigin( tagName ) );
					}

					if ( ( !isdefined( closestPartDist ) ) || ( d < closestPartDist ) )
						closestPartDist = d;

					index = damagedParts.size;
					damagedParts[ index ] = spawnStruct();
					damagedParts[ index ].v[ "modelName" ] = modelName;
					damagedParts[ index ].v[ "tagName" ] = tagName;
					damagedParts[ index ].v[ "distance" ] = d;
				}
			}
		}
	}

	if ( !isdefined( closestPartDist ) || closestPartDist < 0 || damagedParts.size <= 0 )
		return;

	for( i = 0 ; i < damagedParts.size ; i++ )
	{
		distanceMod = ( damagedParts[ i ].v[ "distance" ] * 1.4 );
		damageAmount = ( damage - ( distanceMod - closestPartDist ) );

		if ( damageAmount <= 0 || isDefined( self.exploded ) )
			continue;

		self thread destructible_update_part( damageAmount, damagedParts[ i ].v[ "modelName" ], damagedParts[ i ].v[ "tagName" ], point, direction_vec, attacker, damageType);
	}
}

isValidSoundCause( soundCauseVar, partIndex, stateIndex, soundIndex, damageType )
{
	soundCause = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ soundCauseVar ][ soundIndex ];
	if ( !isdefined( soundCause ) || soundCause == damageType )
		return true;

	return false;
}

isValidDamageCause( partIndex, stateIndex, damageType )
{
	validType = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "validDamageCause" ];
	if ( !isdefined( damageType ) || !isdefined( validType ) )
		return true;

	if ( ( validType == "no_melee" ) && damageType == "melee" || damageType == "impact" )
		return false;

	return true;
}

getDamageType( type )
{
	if ( !isdefined( type ) )
		return "unknown";

	type = tolower( type );
	switch( type )
	{
		case "mod_melee":
		case "mod_crush":
		case "melee":
			return "melee";
		case "mod_pistol_bullet":
		case "mod_rifle_bullet":
		case "bullet":
			return "bullet";
		case "mod_grenade":
		case "mod_grenade_splash":
		case "mod_projectile":
		case "mod_projectile_splash":
		case "mod_explosive":
		case "splash":
			return "splash";
		case "mod_impact":
			return "impact";
		default:
			return "unknown";
	}
}

loopfx_onTag( loopfx, loopfx_tag, loopRate, partIndex )
{
	self endon( "FX_State_Change" + partIndex );
	for(;;)
	{
		playfxontag( loopfx, self, loopfx_tag );
		wait loopRate;
	}
}

health_drain( amount, interval, partIndex, modelName, tagName )
{
	self endon( "Health_Drain_State_Change" + partIndex );
	wait interval;

	uniqueName = undefined;

	while( self.destructible_parts[ partIndex ].v[ "health" ] > 0 )
	{
		self notify( "damage", amount, self, ( 0, 0, 0 ) , ( 0, 0, 0 ), "MOD_UNKNOWN", modelName, tagName );
		wait interval;
	}
}

explode( partIndex, force_min, force_max, range, mindamage, maxdamage )
{
	if ( isdefined( self.exploded ) )
		return;

	self.exploded = true;

	if(self.classname == "script_vehicle")
		self notify ("death");

	wait 0.05;

	tagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ self.destructible_parts[ partIndex ].v[ "currentState" ] ].v[ "tagName" ];
	if ( isdefined( tagName ) )
		explosionOrigin = self getTagOrigin( tagName );
	else
		explosionOrigin = self.origin;

	self notify( "damage", maxdamage, self, ( 0, 0, 0 ), explosionOrigin, "MOD_EXPLOSIVE", "", "" );

	waittillframeend;

	self notify( "stop_taking_damage" );
	wait 0.05;

	if ( !isDefined( self.damageOwner ) )
		self radiusDamage( explosionOrigin + ( 0, 0, 80 ), range, maxdamage, mindamage );
	else
	{
		self radiusDamage( explosionOrigin + ( 0, 0, 80 ), range, maxdamage, mindamage, self.damageOwner );
		self.damageOwner notify ( "destroyed_car" );
	}
}

play_loop_sound_on_destructible( alias, tag )
{
	org = spawn ( "script_origin", ( 0, 0, 0 ) );
	if ( isdefined ( tag ) )
		org.origin = self getTagOrigin( tag );
	else
		org.origin = self.origin;

	org playloopsound ( alias );
	self waittill ( "stop sound" + alias );
	org stoploopsound ( alias );
	org delete();
}

notifyDamageAfterFrame( damage, attacker, direction_vec, point, damageType, modelName, tagName )
{
	if ( isdefined( level.notifyDamageAfterFrame ) )
		return;
	level.notifyDamageAfterFrame = true;
	waittillframeend;
	if ( isdefined( self.exploded ) )
	{
		level.notifyDamageAfterFrame = undefined;
		return;
	}
	self notify( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );
	level.notifyDamageAfterFrame = undefined;
}

string( num )
{
	return ( "" + num );
}

deleteEnt( ent )
{
	ent delete();
}

hideapart( tagName )
{
	self hidepart( tagName );
}

showapart( tagName )
{
	self showpart( tagName );
}