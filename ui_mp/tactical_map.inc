/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#define MAP_X					(- (MAP_WIDTH - RIGHTITEM_OFFSET + 20 ))
#define MAP_Y					114
#define MAP_WIDTH				240
#define MAP_HEIGHT				268
#define ORIGIN_MAP_FRAME		MAP_X MAP_Y
#define MAP_WIDTH2				(MAP_WIDTH+5)

#define UI_MAP_NAME		"@"+tablelookup("mp/mapsTable.csv",0,dvarString(mapname),3)
#define MAP_OFFSET		0 21

itemDef
{
	name			"mini_map2"
	rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
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
	rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	exp				material( tableLookup( "mp/mapsTable.csv", 0, dvarString( mapname ), 7 ) )
	visible			1
	decoration
}

itemDef
{
	name			"compasspointers2"
	rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
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
	rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
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
	rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_enemy"
	ownerdraw		CG_PLAYER_FULLMAP_ENEMIES
	visible			when( dvarInt( g_compassShowEnemies ) );
	decoration
}
itemDef
{
	name			"compassplayer2"
	rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
	origin			MAP_OFFSET
	forecolor		1 1 1 1
	background		"compassping_player"
	ownerdraw		CG_PLAYER_FULLMAP_PLAYER
	visible			when( team( name ) != "TEAM_FREE" )
	decoration
}

PREPROC_SHADER_DRAW_ALIGNED( ORIGIN_MAP_FRAME (-(MAP_WIDTH)) 20 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, 5 0, "white", 0 0 0 0.3, 0, 0, 0 0 0 0 )
PREPROC_SHADER_DRAW_ALIGNED( ORIGIN_MAP_FRAME (-(MAP_WIDTH)) 20 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, 5 0, "gradient_fadein", 0.9 0.95 1 0.4, 0, 0, 0 0 0 0 )

UI_EDGE_REVERSE( ORIGIN_MAP_FRAME, RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, 0, 0, 0 0 0 0.3 )
UI_EDGE_REVERSE( ORIGIN_MAP_FRAME, RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, 0, 0, 0.9 0.95 1 0.4 )

PREPROC_SHADER_DRAW_ALIGNED( ORIGIN_MAP_FRAME (-(MAP_WIDTH2)) 6 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, 0 (MAP_HEIGHT-6), "gradient_fadein",0.9 0.95 1 0.35, 0, 0, 0 0 0 0 )
PREPROC_SHADER_DRAW_ALIGNED( ORIGIN_MAP_FRAME -80 20 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, (MAP_WIDTH-78) 0, "ui_perforation", 1 1 1 1, 0, 0, 0 0 0 0 )
PREPROC_TEXT_DRAW_ALIGNED_EXP( ORIGIN_MAP_FRAME MAP_WIDTH 0 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, 5 20, UI_MAP_NAME, TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_LEFT, 1 1 1 0.7 )