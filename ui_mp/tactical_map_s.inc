/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#define MAP_OFFSET				0 0
#define FULL_SCREEN				0 30 640 420

itemDef
{
	name			"mini_map2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compass_map_default"
	ownerdraw		CG_PLAYER_FULLMAP_MAP
	visible			1
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	name			"mini_map2_overlay"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	exp				material( tableLookup( "mp/mapsTable.csv", 0, dvarString( mapname ), 7 ) )
	visible			1
	decoration
}
itemDef
{
	name			"compasspointers2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"objective_line"
	ownerdraw		CG_PLAYER_FULLMAP_POINTERS
	visible			1
	decoration
}
itemDef
{
	name			"compassfriendlies2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_friendly"
	ownerdraw		CG_PLAYER_FULLMAP_FRIENDS
	visible			1
	decoration
}
itemDef
{
	name			"compassenemies2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_enemy"
	ownerdraw		CG_PLAYER_FULLMAP_ENEMIES
	visible			1
	decoration
}
itemDef
{
	name			"compassplayer2"
	rect			FULL_SCREEN
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_player"
	ownerdraw		CG_PLAYER_FULLMAP_PLAYER
	visible			1
	decoration
}