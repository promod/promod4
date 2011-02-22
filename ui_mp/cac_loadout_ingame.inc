/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#define LOADOUT_WIDTH 270
#define ORIGIN_LOADOUT	((-(LOADOUT_WIDTH - RIGHTITEM_OFFSET))-80) 38
#define LOADOUT_ALIGN	RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
#define LOADOUT_PLATING( py, ph, vis_gradient_top, vis_gradient_bottom ) \
		LOADOUT_PLATING_RAW( ORIGIN_LOADOUT, 0, py, (LOADOUT_WIDTH+8), ph, LOADOUT_ALIGN, vis_gradient_top, vis_gradient_bottom )

PREPROC_SHADER_DRAW_ALIGNED( -4 0 (LOADOUT_WIDTH+8) 210 LOADOUT_ALIGN, ORIGIN_LOADOUT, "gradient_center", 0.3 0.3 0.325 0.6, 0, 0, 0 0 0 0 )
PREPROC_SHADER_DRAW_ALIGNED( 274 -4 20 222 LOADOUT_ALIGN, ORIGIN_LOADOUT, "gradient", 1 1 1 0.65, 0, 0, 0 0 0 0 )
PREPROC_SHADER_DRAW_ALIGNED( -24 -4 -20 222 LOADOUT_ALIGN, ORIGIN_LOADOUT, "gradient", 1 1 1 0.65, 0, 0, 0 0 0 0 )

PREPROC_SHADER_DRAW_ALIGNED( -4 4 ((LOADOUT_WIDTH+8)/4) 80 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/attachmenttable.csv", 11, STAT_CAC_CAMO, 6 ), 1 1 1 0.5, 0, 1, 1 1 1 1)
PREPROC_SHADER_DRAW_ALIGNED( (((LOADOUT_WIDTH+8)/4)-4) 4 ((LOADOUT_WIDTH+8)/4) 80 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/attachmenttable.csv", 11, STAT_CAC_CAMO, 6 ), 1 1 1 0.5, 0, 1, 1 1 1 1)
PREPROC_SHADER_DRAW_ALIGNED( (((LOADOUT_WIDTH+8)/2)-4) 4 ((LOADOUT_WIDTH+8)/4) 80 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/attachmenttable.csv", 11, STAT_CAC_CAMO, 6 ), 1 1 1 0.5, 0, 1, 1 1 1 1)
PREPROC_SHADER_DRAW_ALIGNED( ((((LOADOUT_WIDTH+8)/4)*3)-4) 4 ((LOADOUT_WIDTH+8)/4) 80 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/attachmenttable.csv", 11, STAT_CAC_CAMO, 6 ), 1 1 1 0.5, 0, 1, 1 1 1 1)

LOADOUT_PLATING( 4, 8, 0, 1 )
LOADOUT_PLATING( 218, 8, 1, 0 )
LOADOUT_PLATING( 92, 8, 1, 1 )
LOADOUT_PLATING( 180, 8, 1, 1 )

PREPROC_TEXT_DRAW_ALIGNED_EXP( 0 8 (LOADOUT_WIDTH+8) 20 LOADOUT_ALIGN, ORIGIN_LOADOUT, "@"+tablelookup("mp/statstable.csv", 0, STAT_CAC_PRIMARY, 3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE )

PREPROC_TEXT_DRAW_ALIGNED_EXP( 0 62 (LOADOUT_WIDTH+8) 20 LOADOUT_ALIGN, ORIGIN_LOADOUT, "@"+tablelookup("mp/attachmenttable.csv", 9, STAT_CAC_PRIMARY_ATTACHMENT, 3), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR )

PREPROC_SHADER_DRAW_ALIGNED( 74 -2 180 90 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/statstable.csv", 0, STAT_CAC_PRIMARY, 6 ), 1 1 1 1, 0, 1, 1 1 1 1)

PREPROC_SHADER_DRAW_ALIGNED( 2 30 32 32 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/attachmenttable.csv", 9, STAT_CAC_PRIMARY_ATTACHMENT, 6 ), 1 1 1 1, 0, 1, 1 1 1 1)

PREPROC_TEXT_DRAW_ALIGNED_EXP( 0 (20+76) (LOADOUT_WIDTH+8) 20 LOADOUT_ALIGN, ORIGIN_LOADOUT, "@" + tablelookup("mp/statstable.csv", 0, STAT_CAC_SECONDARY, 3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE )

PREPROC_TEXT_DRAW_ALIGNED_EXP( 0 (74+76) (LOADOUT_WIDTH+8) 20 LOADOUT_ALIGN, ORIGIN_LOADOUT, "@"+tablelookup("mp/attachmenttable.csv", 9, STAT_CAC_SECONDARY_ATTACHMENT, 3), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR )

PREPROC_SHADER_DRAW_ALIGNED( 160 (6+80) 90 90 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/statstable.csv", 0, STAT_CAC_SECONDARY, 6 ), 1 1 1 1, 0, 1, 1 1 1 1 )

PREPROC_SHADER_DRAW_ALIGNED( 2 118 32 32 LOADOUT_ALIGN, ORIGIN_LOADOUT, tablelookup( "mp/attachmenttable.csv", 9, STAT_CAC_SECONDARY_ATTACHMENT, 6 ), 1 1 1 1, 0, 1, 1 1 1 1)

PREPROC_SHADER_DRAW_ALIGNED( 3 178 32 32 LOADOUT_ALIGN, ORIGIN_LOADOUT, "weapon_fraggrenade", 1 1 1 1, 0, 1, 1 1 1 1 visible when( dvarInt( weap_allow_frag_grenade ) != "0" ) )
PREPROC_SHADER_DRAW_ALIGNED( 32 178 32 32 LOADOUT_ALIGN, ORIGIN_LOADOUT, "weapon_smokegrenade", 1 1 1 1, 0, 1, 1 1 1 1 visible when( dvarInt( weap_allow_smoke_grenade ) != 0 && dvarString( loadout_grenade ) == "smoke_grenade" ) )
PREPROC_SHADER_DRAW_ALIGNED( 32 178 32 32 LOADOUT_ALIGN, ORIGIN_LOADOUT, "weapon_flashbang", 1 1 1 1, 0, 1, 1 1 1 1 visible when( dvarInt( weap_allow_flash_grenade ) != 0 && dvarString( loadout_grenade ) == "flash_grenade" ) )

PREPROC_TEXT_DRAW_ALIGNED_EXP( 0 183 (LOADOUT_WIDTH+8) 20 LOADOUT_ALIGN, ORIGIN_LOADOUT, 1, TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE visible when( dvarInt( weap_allow_frag_grenade ) != "0" ) )
PREPROC_TEXT_DRAW_ALIGNED_EXP( 30 183 (LOADOUT_WIDTH+8) 20 LOADOUT_ALIGN, ORIGIN_LOADOUT, 1, TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE visible when( dvarInt( weap_allow_flash_grenade ) != "0" && dvarInt( weap_allow_smoke_grenade ) != "0" ) )