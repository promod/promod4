/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_destructible;

makeType( destructibleType )
{
	infoIndex = getInfoIndex( destructibleType );
	if ( infoIndex >= 0 )
		return infoIndex;

	switch( destructibleType )
	{
		case "vehicle_80s_sedan1_green":
		case "vehicle_80s_sedan1_red":
		case "vehicle_80s_sedan1_silv":
		case "vehicle_80s_sedan1_tan":
		case "vehicle_80s_sedan1_yel":
		case "vehicle_80s_sedan1_brn":
			vehicle_80s_sedan1( GetSubStr( destructibleType, 19 ) );
			break;
		case "vehicle_80s_wagon1_green":
		case "vehicle_80s_wagon1_red":
		case "vehicle_80s_wagon1_silv":
		case "vehicle_80s_wagon1_tan":
		case "vehicle_80s_wagon1_yel":
		case "vehicle_80s_wagon1_brn":
			vehicle_80s_wagon1( GetSubStr( destructibleType, 19 ) );
			break;
		case "vehicle_80s_hatch1_green":
		case "vehicle_80s_hatch1_red":
		case "vehicle_80s_hatch1_silv":
		case "vehicle_80s_hatch1_tan":
		case "vehicle_80s_hatch1_yel":
		case "vehicle_80s_hatch1_brn":
			vehicle_80s_hatch1( GetSubStr( destructibleType, 19 ) );
			break;
		case "vehicle_80s_hatch2_green":
			return -1;
		case "vehicle_small_wagon_blue":
		case "vehicle_small_wagon_green":
		case "vehicle_small_wagon_turq":
		case "vehicle_small_wagon_white":
			vehicle_small_wagon( GetSubStr( destructibleType, 20 ) );
			break;
		case "vehicle_small_hatch_blue":
		case "vehicle_small_hatch_green":
		case "vehicle_small_hatch_turq":
		case "vehicle_small_hatch_white":
			vehicle_small_hatch( GetSubStr( destructibleType, 20 ) );
			break;
		default:
			break;
	}

	infoIndex = getInfoIndex( destructibleType );
	return infoIndex;
}

getInfoIndex( destructibleType )
{
	if ( !isdefined( level.destructible_type ) || !level.destructible_type.size )
		return -1;

	for( i = 0 ; i < level.destructible_type.size ; i++ )
	{
		if ( destructibleType == level.destructible_type[ i ].v[ "type" ] )
			return i;
	}

	return -1;
}

vehicle_80s_sedan1( color )
{
	destructible_create( "vehicle_80s_sedan1_" + color, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, "vehicle_80s_sedan1_" + color + "_destructible_mp", 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, "vehicle_80s_sedan1_" + color + "_destructible_mp", 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 12, 0.15 );
			destructible_state( undefined, "vehicle_80s_sedan1_" + color + "_destructible_mp", 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, "vehicle_80s_sedan1_" + color + "_destructible_mp", 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 375, 20, 300 );
			destructible_state( undefined, "vehicle_80s_sedan1_" + color + "_destroyed", undefined, 32, "no_melee" );

		destructible_part( "tag_hood", "vehicle_80s_sedan1_" + color + "_hood", undefined, undefined, undefined, undefined, 1.0 );

		destructible_part( "tag_trunk", "vehicle_80s_sedan1_" + color + "_trunk", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_wheel_front_right", "vehicle_80s_sedan1_" + color + "_wheel_LF", undefined, undefined, undefined, "no_melee", undefined, 0.7 );
		destructible_part( "tag_wheel_back_right", "vehicle_80s_sedan1_" + color + "_wheel_LF", undefined, undefined, undefined, "no_melee", undefined, 0.7 );

		destructible_part( "tag_door_left_front", "vehicle_80s_sedan1_" + color + "_door_LF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_left_back", "vehicle_80s_sedan1_" + color + "_door_LB", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_front", "vehicle_80s_sedan1_" + color + "_door_RF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_back", "vehicle_80s_sedan1_" + color + "_door_RB", undefined, undefined, undefined, undefined, 1.0 );

		tag = "tag_glass_front";
		destructible_part( tag, "vehicle_80s_sedan1_glass_F", 0 );
			destructible_fx( "tag_glass_front_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_back";
		destructible_part( tag, "vehicle_80s_sedan1_glass_B", 0 );
			destructible_fx( "tag_glass_back_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_front";
		destructible_part( tag, "vehicle_80s_sedan1_glass_LF", 0 );
			destructible_fx( "tag_glass_left_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_front";
		destructible_part( tag, "vehicle_80s_sedan1_glass_RF", 0 );
			destructible_fx( "tag_glass_right_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_back";
		destructible_part( tag, "vehicle_80s_sedan1_glass_LB", 0 );
			destructible_fx( "tag_glass_left_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_back";
		destructible_part( tag, "vehicle_80s_sedan1_glass_RB", 0 );
			destructible_fx( "tag_glass_right_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_light_left_front";
		destructible_part( tag, "vehicle_80s_sedan1_" + color + "_light_LF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_sedan1_" + color + "_light_LF_dam" );

		tag = "tag_light_right_front";
		destructible_part( tag, "vehicle_80s_sedan1_" + color + "_light_RF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_sedan1_" + color + "_light_RF_dam" );

		tag = "tag_light_left_back";
		destructible_part( tag, "vehicle_80s_sedan1_" + color + "_light_LB", 20 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_sedan1_" + color + "_light_LB_dam" );

		tag = "tag_light_right_back";
		destructible_part( tag, "vehicle_80s_sedan1_" + color + "_light_RB", 20 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_sedan1_" + color + "_light_RB_dam" );

		destructible_part( "tag_bumper_front", "vehicle_80s_sedan1_" + color + "_bumper_F", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_bumper_back", "vehicle_80s_sedan1_" + color + "_bumper_B", undefined, undefined, undefined, undefined, 1.0 );
}
vehicle_80s_wagon1( color )
{
	destructible_create( "vehicle_80s_wagon1_" + color, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, "vehicle_80s_wagon1_" + color + "_destructible_mp", 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, "vehicle_80s_wagon1_" + color + "_destructible_mp", 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 12, 0.15 );
			destructible_state( undefined, "vehicle_80s_wagon1_" + color + "_destructible_mp", 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, "vehicle_80s_wagon1_" + color + "_destructible_mp", 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 250, 20, 300 );
			destructible_state( undefined, "vehicle_80s_wagon1_" + color + "_destroyed", undefined, 32, "no_melee" );

		destructible_part( "tag_hood", "vehicle_80s_wagon1_" + color + "_hood", 800, undefined, undefined, undefined, 1.0 );

		destructible_part( "tag_door_left_front", "vehicle_80s_wagon1_" + color + "_door_LF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_left_back", "vehicle_80s_wagon1_" + color + "_door_LB", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_front", "vehicle_80s_wagon1_" + color + "_door_RF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_back", "vehicle_80s_wagon1_" + color + "_door_RB", undefined, undefined, undefined, undefined, 1.0 );

		tag = "tag_glass_front";
		destructible_part( tag, "vehicle_80s_wagon1_glass_F", 0 );
			destructible_fx( "tag_glass_front_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_back";
		destructible_part( tag, "vehicle_80s_wagon1_glass_B", 0 );
			destructible_fx( "tag_glass_back_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_front";
		destructible_part( tag, "vehicle_80s_wagon1_glass_LF", 0 );
			destructible_fx( "tag_glass_left_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_front";
		destructible_part( tag, "vehicle_80s_wagon1_glass_RF", 0 );
			destructible_fx( "tag_glass_right_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_back";
		destructible_part( tag, "vehicle_80s_wagon1_glass_LB", 0 );
			destructible_fx( "tag_glass_left_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_back";
		destructible_part( tag, "vehicle_80s_wagon1_glass_RB", 0 );
			destructible_fx( "tag_glass_right_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_back2";
		destructible_part( tag, "vehicle_80s_wagon1_glass_LB2", 0 );
			destructible_fx( "tag_glass_left_back2_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_back2";
		destructible_part( tag, "vehicle_80s_wagon1_glass_RB2", 0 );
			destructible_fx( "tag_glass_right_back2_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_light_left_front";
		destructible_part( tag, "vehicle_80s_wagon1_" + color + "_light_LF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_wagon1_" + color + "_light_LF_dam" );

		tag = "tag_light_right_front";
		destructible_part( tag, "vehicle_80s_wagon1_" + color + "_light_RF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_wagon1_" + color + "_light_RF_dam" );

		tag = "tag_light_left_back";
		destructible_part( tag, "vehicle_80s_wagon1_" + color + "_light_LB", 20 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_wagon1_" + color + "_light_LB_dam" );

		tag = "tag_light_right_back";
		destructible_part( tag, "vehicle_80s_wagon1_" + color + "_light_RB", 20 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_wagon1_" + color + "_light_RB_dam" );

		destructible_part( "tag_bumper_front", "vehicle_80s_wagon1_" + color + "_bumper_F", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_bumper_back", "vehicle_80s_wagon1_" + color + "_bumper_B", undefined, undefined, undefined, undefined, 1.0 );
}

vehicle_80s_hatch1( color )
{
	destructible_create( "vehicle_80s_hatch1_" + color, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, "vehicle_80s_hatch1_" + color + "_destructible_mp", 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, "vehicle_80s_hatch1_" + color + "_destructible_mp", 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 12, 0.15 );
			destructible_state( undefined, "vehicle_80s_hatch1_" + color + "_destructible_mp", 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, "vehicle_80s_hatch1_" + color + "_destructible_mp", 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 250, 20, 300 );
			destructible_state( undefined, "vehicle_80s_hatch1_" + color + "_destroyed", undefined, 32, "no_melee" );

		destructible_part( "tag_hood", "vehicle_80s_hatch1_" + color + "_hood", 800, undefined, undefined, undefined, 1.0 );

		destructible_part( "tag_door_left_front", "vehicle_80s_hatch1_" + color + "_door_LF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_front", "vehicle_80s_hatch1_" + color + "_door_RF", undefined, undefined, undefined, undefined, 1.0 );

		tag = "tag_glass_front";
		destructible_part( tag, "vehicle_80s_hatch1_glass_F", 0 );
			destructible_fx( "tag_glass_front_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_back";
		destructible_part( tag, "vehicle_80s_hatch1_glass_B", 0 );
			destructible_fx( "tag_glass_back_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_front";
		destructible_part( tag, "vehicle_80s_hatch1_glass_LF", 0 );
			destructible_fx( "tag_glass_left_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_front";
		destructible_part( tag, "vehicle_80s_hatch1_glass_RF", 0 );
			destructible_fx( "tag_glass_right_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_back";
		destructible_part( tag, "vehicle_80s_hatch1_glass_LB", 0 );
			destructible_fx( "tag_glass_left_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_back";
		destructible_part( tag, "vehicle_80s_hatch1_glass_RB", 0 );
			destructible_fx( "tag_glass_right_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_light_left_front";
		destructible_part( tag, "vehicle_80s_hatch1_" + color + "_light_LF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_hatch1_" + color + "_light_LF_dam" );

		tag = "tag_light_right_front";
		destructible_part( tag, "vehicle_80s_hatch1_" + color + "_light_RF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_hatch1_" + color + "_light_RF_dam" );

		tag = "tag_light_left_back";
		destructible_part( tag, "vehicle_80s_hatch1_" + color + "_light_LB", 20 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_hatch1_" + color + "_light_LB_dam" );

		tag = "tag_light_right_back";
		destructible_part( tag, "vehicle_80s_hatch1_" + color + "_light_RB", 20 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_80s_hatch1_" + color + "_light_RB_dam" );
}

vehicle_small_wagon( color )
{
	destructible_create( "vehicle_small_wagon_" + color, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, "vehicle_small_wagon_" + color + "_destructible_mp", 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, "vehicle_small_wagon_" + color + "_destructible_mp", 100, "player_only", 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 12, 0.15 );
			destructible_state( undefined, "vehicle_small_wagon_" + color + "_destructible_mp", 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, "vehicle_small_wagon_" + color + "_destructible_mp", 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 250, 20, 300 );
			destructible_state( undefined, "vehicle_small_wagon_" + color + "_destroyed", undefined, 32, "no_melee" );

		tag = "tag_hood";
		destructible_part( tag, "vehicle_small_wagon_" + color + "_hood", 800, undefined, undefined, undefined, 1.0 );

		destructible_part( "tag_door_left_front", "vehicle_small_wagon_" + color + "_door_LF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_front", "vehicle_small_wagon_" + color + "_door_RF", undefined, undefined, undefined, undefined, 1.0 );

		tag = "tag_glass_front";
		destructible_part( tag, "vehicle_small_wagon_glass_F", 0 );
			destructible_fx( "tag_glass_front_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_back";
		destructible_part( tag, "vehicle_small_wagon_glass_B", 0 );
			destructible_fx( "tag_glass_back_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_front";
		destructible_part( tag, "vehicle_small_wagon_glass_LF", 0 );
			destructible_fx( "tag_glass_left_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_front";
		destructible_part( tag, "vehicle_small_wagon_glass_RF", 0 );
			destructible_fx( "tag_glass_right_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_back";
		destructible_part( tag, "vehicle_small_wagon_glass_LB", 0 );
			destructible_fx( "tag_glass_left_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_back";
		destructible_part( tag, "vehicle_small_wagon_glass_RB", 0 );
			destructible_fx( "tag_glass_right_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_light_left_front";
		destructible_part( tag, "vehicle_small_wagon_" + color + "_light_LF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_wagon_" + color + "_light_LF_dam" );

		tag = "tag_light_right_front";
		destructible_part( tag, "vehicle_small_wagon_" + color + "_light_RF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_wagon_" + color + "_light_RF_dam" );

		tag = "tag_light_left_back";
		destructible_part( tag, "vehicle_small_wagon_" + color + "_light_LB", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_wagon_" + color + "_light_LB_dam" );

		tag = "tag_light_right_back";
		destructible_part( tag, "vehicle_small_wagon_" + color + "_light_RB", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_wagon_" + color + "_light_RB_dam" );
}

vehicle_small_hatch( color )
{
	destructible_create( "vehicle_small_hatch_" + color, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, "vehicle_small_hatch_" + color + "_destructible_mp", 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, "vehicle_small_hatch_" + color + "_destructible_mp", 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 15, 0.2 );
			destructible_state( undefined, "vehicle_small_hatch_" + color + "_destructible_mp", 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, "vehicle_small_hatch_" + color + "_destructible_mp", 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 250, 20, 300 );
			destructible_state( undefined, "vehicle_small_hatch_" + color + "_destroyed", undefined, 32, "no_melee" );

		destructible_part( "tag_hood", "vehicle_small_hatch_" + color + "_hood", 800, undefined, undefined, undefined, 1.0 );

		destructible_part( "tag_door_left_front", "vehicle_small_hatch_" + color + "_door_LF", undefined, undefined, undefined, undefined, 1.0 );
		destructible_part( "tag_door_right_front", "vehicle_small_hatch_" + color + "_door_RF", undefined, undefined, undefined, undefined, 1.0 );

		tag = "tag_glass_front";
		destructible_part( tag, "vehicle_small_hatch_glass_F", 0 );
			destructible_fx( "tag_glass_front_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_back";
		destructible_part( tag, "vehicle_small_hatch_glass_B", 0 );
			destructible_fx( "tag_glass_back_fx", "props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_front";
		destructible_part( tag, "vehicle_small_hatch_glass_LF", 0 );
			destructible_fx( "tag_glass_left_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_front";
		destructible_part( tag, "vehicle_small_hatch_glass_RF", 0 );
			destructible_fx( "tag_glass_right_front_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_left_back";
		destructible_part( tag, "vehicle_small_hatch_glass_LB", 0 );
			destructible_fx( "tag_glass_left_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_glass_right_back";
		destructible_part( tag, "vehicle_small_hatch_glass_RB", 0 );
			destructible_fx( "tag_glass_right_back_fx", "props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( tag+"_d" );

		tag = "tag_light_left_front";
		destructible_part( tag, "vehicle_small_hatch_" + color + "_light_LF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_hatch_" + color + "_light_LF_dam" );

		tag = "tag_light_right_front";
		destructible_part( tag, "vehicle_small_hatch_" + color + "_light_RF", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_hatch_" + color + "_light_RF_dam" );

		tag = "tag_light_left_back";
		destructible_part( tag, "vehicle_small_hatch_" + color + "_light_LB", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_hatch_" + color + "_light_LB_dam" );

		tag = "tag_light_right_back";
		destructible_part( tag, "vehicle_small_hatch_" + color + "_light_RB", 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "props/car_glass_brakelight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag+"_d", "vehicle_small_hatch_" + color + "_light_RB_dam" );
}