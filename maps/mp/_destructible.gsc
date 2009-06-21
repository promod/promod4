/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );
init()
{
	if ( getdvar( "debug_destructibles" ) == "" )
		setdvar( "debug_destructibles", "0" );

	if ( getdvar( "destructibles_enable_physics" ) == "" )
		setdvar( "destructibles_enable_physics", "1" );

	level.destructibleSpawnedEntsLimit = 25;
	level.destructibleSpawnedEnts = [];

	find_destructibles();

	array_levelthread( getEntArray( "delete_on_load", "targetname" ), ::deleteEnt );
}

destructible_create( type, health, validAttackers, validDamageZone, validDamageCause )
{
	//---------------------------------------------------------------------
	// Creates a new information structure for a destructible object
	//---------------------------------------------------------------------
	assert( isdefined( type ) );

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
	//---------------------------------------------------------------------
	// Adds a part to the last created destructible information structure
	// This part will be created and attached to the specified bone on load
	//---------------------------------------------------------------------
	destructibleIndex = ( level.destructible_type.size - 1 );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts.size ) );

	partIndex = level.destructible_type[ destructibleIndex ].parts.size;
	assert( partIndex > 0 );

	stateIndex = 0;

	destructible_info( partIndex, stateIndex, tagName, modelName, health, noDraw, validDamageZone, validDamageCause, alsoDamageParent, physicsOnExplosion );
}

destructible_state( tagName, modelName, health, noDraw, validDamageZone, validDamageCause )
{
	//---------------------------------------------------------------------
	// Adds a new part that is a state of the last created part
	// When the previous part reaches zero health this part will show up
	// and the previous part will be removed
	//---------------------------------------------------------------------

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size );

	destructible_info( partIndex, stateIndex, tagName, modelName, health, noDraw, validDamageZone, validDamageCause );
}

destructible_fx( tagName, fxName, useTagAngles )
{
	assert( isdefined( tagName ) );
	assert( isdefined( fxName ) );

	if ( !isdefined( useTagAngles ) )
		useTagAngles = true;

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "fx_filename" ] = fxName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "fx_tag" ] = tagName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "fx_useTagAngles" ] = useTagAngles;
}

destructible_loopfx( tagName, fxName, loopRate )
{
	assert( isdefined( tagName ) );
	assert( isdefined( fxName ) );
	assert( isdefined( loopRate ) );
	assert( loopRate > 0 );

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopfx_filename" ] = fxName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopfx_tag" ] = tagName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopfx_rate" ] = loopRate;
}

destructible_healthdrain( amount, interval )
{
	assert( isdefined( amount ) );

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "healthdrain_amount" ] = amount;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "healthdrain_interval" ] = interval;
}

destructible_sound( soundAlias, soundCause )
{
	assert( isdefined( soundAlias ) );

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

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
	assert( isdefined( soundAlias ) );

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	if ( !isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ] ) )
	{
		level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ] = [];
		level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsoundCause" ] = [];
	}

	index = level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ].size;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsound" ][ index ] = soundAlias;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "loopsoundCause" ][ index ] = loopsoundCause;
}

destructible_anim( animName, animTree, animType )
{
	assert( isdefined( anim ) );
	assert( isdefined( animtree ) );

	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "anim" ] = animName;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "animTree" ] = animtree;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "animType" ] = animType;
}

destructible_physics()
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "physics" ] = true;
}

destructible_explode( force_min, force_max, range, mindamage, maxdamage )
{
	destructibleIndex = ( level.destructible_type.size - 1 );
	partIndex = ( level.destructible_type[ destructibleIndex ].parts.size - 1 );
	stateIndex = ( level.destructible_type[ destructibleIndex ].parts[ partIndex ].size - 1 );

	assert( isdefined( level.destructible_type ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ] ) );
	assert( isdefined( level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ] ) );

	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_force_min" ] = force_min;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_force_max" ] = force_max;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_range" ] = range;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_mindamage" ] = mindamage;
	level.destructible_type[ destructibleIndex ].parts[ partIndex ][ stateIndex ].v[ "explode_maxdamage" ] = maxdamage;
}

destructible_info( partIndex, stateIndex, tagName, modelName, health, noDraw, validDamageZone, validDamageCause, alsoDamageParent, physicsOnExplosion )
{
	assert( isdefined( partIndex ) );
	assert( isdefined( stateIndex ) );
	assert( isdefined( level.destructible_type ) );
	assert( level.destructible_type.size > 0 );

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
	//---------------------------------------------------------------------
	// Find all destructibles by their targetnames and run the setup
	//---------------------------------------------------------------------
	array_thread( getentarray( "destructible", "targetname" ), ::setup_destructibles );
}


precache_destructibles(  )
{
	// I needed this to be seperate for vehicle scripts.
	//---------------------------------------------------------------------
	// Precache referenced models and load referenced effects
	//---------------------------------------------------------------------
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
	//---------------------------------------------------------------------
	// Figure out what destructible information this entity should use
	//---------------------------------------------------------------------
	destuctableInfo = undefined;
	assertEx( isdefined( self.destructible_type ), "Destructible object with targetname 'destructible' does not have a 'destructible_type' key/value" );

	self.destuctableInfo = maps\mp\_destructible_types::makeType( self.destructible_type );
	//println( "### DESTRUCTIBLE ### assigned infotype index: " + self.destuctableInfo );
//	assert( self.destuctableInfo >= 0 );
	if ( self.destuctableInfo < 0 )
		return;

	precache_destructibles();

	//---------------------------------------------------------------------
	// Attach all parts to the entity
	//---------------------------------------------------------------------
	if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts ) )
	{
		self.destructible_parts = [];
		for( i = 0 ; i < level.destructible_type[ self.destuctableInfo ].parts.size ; i++ )
		{
			self.destructible_parts[ i ] = spawnStruct();

			// set it's current state to 0 since it has never taken damage yet and will be on it's first state
			self.destructible_parts[ i ].v[ "currentState" ] = 0;

			// if it has a health value then store it's value
			if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "health" ] ) )
				self.destructible_parts[ i ].v[ "health" ] = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "health" ];

			// continue if it's the base model since its not an attached part
			if ( i == 0 )
				continue;

			// attach the part now
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

	//---------------------------------------------------------------------
	// Make this entity take damage and wait for events
	//---------------------------------------------------------------------
	if(	self.classname != "script_vehicle" )
		self setCanDamage( true );
	self thread destructible_think();
}

damage_mirror( parent, modelName, tagName )
{
	self notify( "stop_damage_mirror" );
	self endon( "stop_damage_mirror" );
	parent endon( "stop_taking_damage" );

	self setCanDamage( true );
	for ( ;; )
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type );
		parent notify ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName );
	}
}

destructible_think()
{
	//---------------------------------------------------------------------
	// Wait until this entity takes damage
	//---------------------------------------------------------------------
	self endon( "stop_taking_damage" );
	for(;;)
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags );

		if ( !isdefined( damage ) )
			continue;
		if ( damage <= 0 )
			continue;

		if ( isDefined( attacker ) && isPlayer( attacker ) )
			self.damageOwner = attacker;

		type = getDamageType( type );
		assert( isdefined( type ) );

		if ( getdvar( "debug_destructibles" ) == "1" )
		{
			print3d( point, ".", ( 1, 1, 1 ), 1.0, 0.5, 100 );
			iprintln( "damage amount: " + damage );
			iprintln( "hit model: " + modelName );
			if ( isdefined( tagName ) )
				iprintln( "hit model tag: " + tagName );
			else
				iprintln( "hit model tag: " );
		}

		// override for when base model is damaged. We dont want to pass in empty strings
		assert( isdefined( modelName ) );
		if ( modelName == "" )
		{
			assert( isdefined( self.model ) );
			modelName = self.model;
		}
		if ( isdefined( tagName ) && tagName == "" )
		{
			if ( isdefined( partName ) && partName != "" && partName != "tag_body" )
				tagName = partName;
			else
				tagName = undefined;
		}

		// special handling for splash and projectile damage
		if ( type == "splash" )
		{
			if ( getdvar( "debug_destructibles" ) == "1" )
				iprintln( "type = splash" );

			damage *= 2.75;

			self destructible_splash_damage( int( damage ), point, direction_vec, attacker, type );
			continue;
		}

		self thread destructible_update_part( int( damage ), modelName, tagName, point, direction_vec, attacker, type );
	}
}

destructible_update_part( damage, modelName, tagName, point, direction_vec, attacker, damageType )
{
	//---------------------------------------------------------------------
	// Find what part this is, or is a child of. If the base model was
	// the entity that was damaged the part index will be -1
	//---------------------------------------------------------------------
	if ( !isdefined( self.destructible_parts ) )
		return;
	if ( self.destructible_parts.size == 0 )
		return;

	if ( isDefined( level.strat_over ) )
	{
		while (!level.strat_over)
			return;
	}

	partIndex = -1;
	stateIndex = -1;
	assert( isdefined( self.model ) );
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

		if( level.destructible_type[ self.destuctableInfo ].parts[ i ].size <= stateIndex )
			continue;

		if( !isdefined( tagName ) )
			continue;

		if( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "modelName" ] ) )
			continue;

		if ( isDefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ] ) )
		{
			if ( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ] == tagName )
			{
				partIndex = i;
				break;
			}
		}
	}
	assert( stateIndex >= 0 );

	if ( partIndex < 0 )
		return;

	//---------------------------------------------------------------------
	// Deduct the damage amount from the part's health
	// If the part runs out of health go to the next state
	//---------------------------------------------------------------------
	state_before = stateIndex;
	updateHealthValue = false;
	delayModelSwap = false;
	for(;;)
	{
		stateIndex = self.destructible_parts[ partIndex ].v[ "currentState" ];

		// there isn't another state to go to when damaged
		if ( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ] ) )
			break;

		// see if the model is also supposed to damage the parent
		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ 0 ].v[ "alsoDamageParent" ] ) )
		{
			if ( getDamageType( damageType ) != "splash" )
			{
				ratio = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ 0 ].v[ "alsoDamageParent" ];
				parentDamage = int( damage * ratio );
				self thread notifyDamageAfterFrame( parentDamage, attacker, direction_vec, point, damageType, "", "" );
			}
		}

		if ( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "health" ] ) )
			break;
		if ( !isdefined( self.destructible_parts[ partIndex ].v[ "health" ] ) )
			break;

		if ( updateHealthValue )
			self.destructible_parts[ partIndex ].v[ "health" ] = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "health" ];
		updateHealthValue = false;

		if ( getdvar( "debug_destructibles" ) == "1" )
		{
			iprintln( "stateindex: " + stateIndex );
			iprintln( "damage: " + damage );
			iprintln( "health (before): " + self.destructible_parts[ partIndex ].v[ "health" ] );
		}

		// apply the damage to the part if the attacker was a valid attacker
		validAttacker = self isAttackerValid( partIndex, stateIndex, attacker );
		if ( validAttacker )
		{
			validDamageCause = self isValidDamageCause( partIndex, stateIndex, damageType );
			if ( validDamageCause )
			{
				if ( damageType == "melee" || damageType == "impact" )
					damage = 100000;

				self.destructible_parts[ partIndex ].v[ "health" ] -= damage;
			}
		}

		if ( getdvar( "debug_destructibles" ) == "1" )
			iprintln( "health (after): " + self.destructible_parts[ partIndex ].v[ "health" ] );

		// if the part still has health left then we're done
		if ( self.destructible_parts[ partIndex ].v[ "health" ] > 0 )
		{
			return;
		}

		// if the part ran out of health then carry over to the next part
		damage = int( abs( self.destructible_parts[ partIndex ].v[ "health" ] ) );
		if ( damage < 0 )
		{
			return;
		}
		self.destructible_parts[ partIndex ].v[ "currentState" ]++;
		stateIndex = self.destructible_parts[ partIndex ].v[ "currentState" ];
		actionStateIndex = ( stateIndex - 1 );

		if ( !isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ] ) )
		{
			return;
		}

		//---------------------------------------------------------------------
		// A state change is required so detach the old model or replace it if
		// it's the base model that took the damage.
		// Then attach the model ( if specified ) used for the new state
		// Only do this if there is another state to go to, some parts might have
		// fx or anims, or sounds but no next model to go to
		//---------------------------------------------------------------------

		// if the part is meant to explode on this state set a flag. Actual explosion will be done down below
		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "explode_force_min" ] ) )
			self.exploding = true;

		// stop all previously looped sounds
		if ( ( isdefined( self.loopingSoundStopNotifies ) ) && ( isdefined( self.loopingSoundStopNotifies[ string( partIndex ) ] ) ) )
		{
			for( i = 0 ; i < self.loopingSoundStopNotifies[ string( partIndex ) ].size ; i++ )
			{
				self notify( self.loopingSoundStopNotifies[ string( partIndex ) ][ i ] );
			}
			self.loopingSoundStopNotifies[ string( partIndex ) ] = undefined;
		}

		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ] ) )
		{
			if ( partIndex == 0 )
			{
				newModel = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "modelName" ];
				self setModel( newModel );
			}
			else
			{
				// handle a part getting damaged here - must be detached and reattached
				self hideapart( tagName );
				modelName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "modelName" ];
				tagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "tagName" ];

				if ( isdefined( modelName ) && isdefined( tagName ) )
					self showapart( tagName );
			}
		}

		// if the part has an fx then play it now
		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx" ] ) )
		{
			assert( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx_tag" ] ) );
			fx = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx" ];
			fx_tag = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx_tag" ];
			self notify( "FX_State_Change" + partIndex );
			if ( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "fx_useTagAngles" ] )
			{
				playfxontag ( fx, self, fx_tag );
			}
			else
			{
				fxOrigin = self getTagOrigin( fx_tag );
				forward = ( fxOrigin + ( 0, 0, 100 ) ) - fxOrigin;
				playfx ( fx, fxOrigin, forward );
			}
		}

		// if the part has a looping fx then play it now
		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx" ] ) )
		{
			assert( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx_tag" ] ) );
			loopfx = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx" ];
			loopfx_tag = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx_tag" ];
			loopRate = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "loopfx_rate" ];
			self notify( "FX_State_Change" + partIndex );
			self thread loopfx_onTag( loopfx, loopfx_tag, loopRate, partIndex );
		}

		// if the part has an anim then play it now
		if ( !isdefined( self.exploded ) )
		{
			if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "anim" ] ) )
			{
				animName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "anim" ];
				animTree = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "animTree" ];
				self useanimtree( animTree );
				animType = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "animType" ];
				if ( !isdefined( self.animsApplied ) )
					self.animsApplied = [];
				self.animsApplied[ self.animsApplied.size ] = animName;

				if ( isdefined( self.exploding ) )
				{
					//clear all previously blended anims if the vehicle is exploding so the explosion doesn't have to blend with anything
					if ( isdefined( self.animsApplied ) )
					{
						for( i = 0 ; i < self.animsApplied.size ; i++ )
						{
							self clearAnim( self.animsApplied[ i ], 0 );
						}
					}
				}

				if ( animType == "setanim" )
					self setAnim( animName, 1.0, 1.0, 1.0 );
				else if ( animType == "setanimknob" )
					self setAnimKnob( animName, 1.0, 1.0, 1.0 );
				else
					assertMsg( "Tried to play an animation on a destructible with an invalid animType: " + animType );

				if ( partIndex == 0 )
					self thread explodeAnim();
					}
		}

		// if the part has a soundalias then play it now
		if ( !isdefined( self.exploded ) )
		{
			if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "sound" ] ) )
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
		}

		// if the part has a looping soundalias then start looping it now
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

		// if the part should drain health then start the drain
		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "healthdrain_amount" ] ) )
		{
			self notify( "Health_Drain_State_Change" + partIndex );
			healthdrain_amount 		= level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "healthdrain_amount" ];
			healthdrain_interval 	= level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "healthdrain_interval" ];
			healthdrain_modelName 	= level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "modelName" ];
			healthdrain_tagName 	= level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "tagName" ];
			if ( healthdrain_amount > 0 )
			{
				assert( ( isdefined( healthdrain_interval ) ) && ( healthdrain_interval > 0 ) );
				self thread health_drain( healthdrain_amount, healthdrain_interval, partIndex, healthdrain_modelName, healthdrain_tagName );
			}
		}

		// if the part is meant to explode on this state then do it now. Causes all attached models to become physics with the specified force
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

		// if the part should do physics here then initiate the physics and velocity
		if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ actionStateIndex ].v[ "physics" ] ) )
		{
			initial_velocity = point;
			impactDir = ( 0, 0, 0 );
			if ( isdefined( attacker ) )
			{
				impactDir = attacker.origin;
				//if ( attacker == level.player )
				//	impactDir = level.player getEye();
				initial_velocity = vectorNormalize( point - impactDir);
				initial_velocity = vectorScale( initial_velocity, 200 );
			}
			self thread physics_launch( partIndex, actionStateIndex, point, initial_velocity );
			return;
		}

		updateHealthValue = true;
	}
}

destructible_splash_damage( damage, point, direction_vec, attacker, damageType )
{
	if ( damage <= 0 )
		return;

	if ( isDefined( self.exploded ) )
		return;

	//------------------------------------------------------------------------
	// Fill an array of all possible parts that might have been splash damaged
	//------------------------------------------------------------------------
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
					// see how far the part is from the splash damage origin
					modelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "modelName" ];
					assert( isdefined( modelName ) );

					// special handling for the base model which doesn't use a tag
					if ( i == 0 )
					{
						d = distance( point, self.origin );
						tagName = undefined;
					}
					else
					{
						tagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ j ].v[ "tagName" ];
						assert( isdefined( tagName ) );
						d = distance( point, self getTagOrigin( tagName ) );
					}

					if ( ( !isdefined( closestPartDist ) ) || ( d < closestPartDist ) )
						closestPartDist = d;

					// add the part to the list of parts to be damaged
					index = damagedParts.size;
					damagedParts[ index ] = spawnStruct();
					damagedParts[ index ].v[ "modelName" ] = modelName;
					damagedParts[ index ].v[ "tagName" ] = tagName;
					damagedParts[ index ].v[ "distance" ] = d;
				}
			}
		}
	}

	if ( !isdefined( closestPartDist ) )
		return;
	if ( closestPartDist < 0 )
		return;
	if ( damagedParts.size <= 0 )
		return;

	//--------------------------------------------------------------------------
	// Damage each part depending on how close it was to the splash damage point
	//--------------------------------------------------------------------------
	for( i = 0 ; i < damagedParts.size ; i++ )
	{
		distanceMod = ( damagedParts[ i ].v[ "distance" ] * 1.4 );
		damageAmount = ( damage - ( distanceMod - closestPartDist ) );

		if ( damageAmount <= 0 )
			continue;

		if ( isDefined( self.exploded ) )
			continue;

		if ( getdvar( "debug_destructibles" ) == "1" )
		{
			if ( isdefined( damagedParts[ i ].v[ "tagName" ] ) )
				print3d( self getTagOrigin( damagedParts[ i ].v[ "tagName" ] ), damageAmount, ( 1, 1, 1 ), 1.0, 0.5, 200 );
		}

		self thread destructible_update_part( damageAmount, damagedParts[ i ].v[ "modelName" ], damagedParts[ i ].v[ "tagName" ], point, direction_vec, attacker, damageType);
	}
}

isValidSoundCause( soundCauseVar, partIndex, stateIndex, soundIndex, damageType )
{
	soundCause = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ soundCauseVar ][ soundIndex ];
	if ( !isdefined( soundCause ) )
		return true;

	if ( soundCause == damageType )
		return true;

	return false;
}

isAttackerValid( partIndex, stateIndex, attacker )
{
	if ( !isdefined( attacker ) )
		return true;

	return true;
}

isValidDamageCause( partIndex, stateIndex, damageType )
{
	if ( !isdefined( damageType ) )
		return true;

	validType = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "validDamageCause" ];
	if ( !isdefined( validType ) )
		return true;

	if ( ( validType == "no_melee" ) && damageType == "melee" || damageType == "impact" )
		return false;

	return true;
}

getDamageType( type )
{
	//returns a simple damage type: melee, bullet, splash, or unknown

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
		case "unknown":
			return "unknown";
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
		if ( getdvar( "debug_destructibles" ) == "1" )
		{
			iprintln( "health before damage: " + self.destructible_parts[ partIndex ].v[ "health" ] );
			iprintln( "doing " + amount + " damage" );
		}
		self notify( "damage", amount, self, ( 0, 0, 0 ) , ( 0, 0, 0 ), "MOD_UNKNOWN", modelName, tagName );
		wait interval;
	}
}

physics_launch( partIndex, stateIndex, point, initial_velocity )
{
	modelName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "modelName" ];
	tagName = level.destructible_type[ self.destuctableInfo ].parts[ partIndex ][ stateIndex ].v[ "tagName" ];

	self hideapart( tagName );

	if ( getdvar( "destructibles_enable_physics" ) == "0" )
		return;

	// If we've reached the max number of spawned physics models for destructible vehicles then delete one before creating another
	if ( level.destructibleSpawnedEnts.size >= level.destructibleSpawnedEntsLimit )
		physics_object_remove( level.destructibleSpawnedEnts[ 0 ] );

	// Spawn a model to use for physics using the modelname and position of the part
	physicsObject = spawn( "script_model", self getTagOrigin( tagName ) );
	physicsObject.angles = self getTagAngles( tagName );
	physicsObject setModel( modelName );

	// Keep track of the new part so it can be removed later if we reach the max
	level.destructibleSpawnedEnts[ level.destructibleSpawnedEnts.size ] = physicsObject;

	// Do physics on the model
	physicsObject physicsLaunch( point, initial_velocity );
}

physics_object_remove( ent )
{
	newArray = [];
	for( i = 0 ; i < level.destructibleSpawnedEnts.size ; i++ )
	{
		if ( level.destructibleSpawnedEnts[ i ] == ent )
			continue;
		newArray[ newArray.size ] = level.destructibleSpawnedEnts[ i ];
	}
	level.destructibleSpawnedEnts = newArray;
	ent delete();
}

explode( partIndex, force_min, force_max, range, mindamage, maxdamage )
{
	assert( isdefined( force_min ) );
	assert( isdefined( force_max ) );
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

	if ( isdefined( level.destructible_type[self.destuctableInfo].parts ) )
	{
		for( i = ( level.destructible_type[ self.destuctableInfo ].parts.size - 1 ) ; i >= 0  ; i-- )
		{
			if ( i == partIndex )
				continue;

			stateIndex = self.destructible_parts[ i ].v[ "currentState" ];
			if ( stateIndex >= level.destructible_type[ self.destuctableInfo ].parts[ i ].size )
				stateIndex = level.destructible_type[ self.destuctableInfo ].parts[ i ].size - 1;
			modelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "modelName" ];
			tagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ];

			if ( !isdefined( modelName ) )
				continue;
			if ( !isdefined( tagName ) )
				continue;

			if ( self.destructible_parts[ i ] isLinked() )
			{
				// dont do physics on parts that are supposed to be removed on explosion
				if ( isdefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "physicsOnExplosion" ] ) )
				{
					if ( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "physicsOnExplosion" ] > 0 )
					{
						velocityScaler = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "physicsOnExplosion" ];

						point = self getTagOrigin( tagName );
						initial_velocity = vectorNormalize( point - explosionOrigin );
						initial_velocity = vectorScale( initial_velocity, randomfloatrange( force_min, force_max ) * velocityScaler );

						self thread physics_launch( i, stateIndex, point, initial_velocity );
						continue;
					}
				}
//				self.destructible_parts[ i ] hide();
			}
		}
	}

	self notify( "stop_taking_damage" );
	wait 0.05;

	if ( !isDefined( self.damageOwner ) )
	{
		self radiusDamage( explosionOrigin + ( 0, 0, 80 ), range, maxdamage, mindamage );
	}
	else
	{
		self radiusDamage( explosionOrigin + ( 0, 0, 80 ), range, maxdamage, mindamage, self.damageOwner );
		self.damageOwner notify ( "destroyed_car" );
	}
}

isLinked()
{
	return !isDefined( self.unlinked );
	/*
	qAttached = false;

	modelName = tolower( modelName );
	tagName = tolower( tagName );

	assert( isdefined( modelName ) );
	if( !isdefined( tagName ) )
		return qAttached;

	attachedModelCount = self getattachsize();
	attachedModels = [];
	for ( i = 0 ; i < attachedModelCount ; i++ )
		attachedModels[ i ] = tolower( self getAttachModelName( i ) );

	for( i = 0 ; i < attachedModels.size ; i++ )
	{
		if ( attachedModels[ i ] != modelName )
			continue;

		sName = tolower( self getattachtagname( i ) );
		if ( tagName != sName )
			continue;

		qAttached = true;
		break;
	}
	return qAttached;
	*/
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
	// created so entities can be deleted using array_thread
	ent delete();
}

setAnim( animName, val, val, val )
{
}

setAnimKnob( animName, val, val, val )
{
}

clearAnim( animName, value )
{
}

useAnimTree( animTree )
{
}


hideapart( tagName )
{
//	println( "Hiding part: " + tagName );
	self hidepart( tagName );
}

showapart( tagName )
{
//	println( "Showing part: " + tagName );
	self showpart( tagName );
}

explodeAnim()
{
	self moveZ( 16, 0.3, 0, 0.2 );
	self rotatePitch( 10, 0.3, 0, 0.2 );
	wait ( 0.3 );
	self moveZ( -16, 0.3, 0.15, 0 );
	self rotatePitch( -10, 0.3, 0.15, 0 );
}