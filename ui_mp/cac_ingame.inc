/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#define CHOICE_X_START			0
#define CHOICE_Y_START			34

#include "ui_mp/menustyle.inc"
#include "ui/choices_setup_common.menu"

#undef BUTTON_BG_COLOR
#define BUTTON_BG_COLOR		0 0 0 0

#define ORIGIN_STATUS			390 64
#define MENU_FONT_COLOR2		1 1 1 0.5

#include "ui_mp/stats_info.inc"

menuDef	{
	name			CAC_MENU_NAME
	rect			0 0 640 480
	focuscolor		COLOR_FOCUSED
	style			WINDOW_STYLE_EMPTY
	blurWorld		7
	onESC { scriptMenuResponse "back"; }

	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
		backcolor		0 0 0 0.75
		visible			1
		decoration
	}
	itemDef
	{
		style			WINDOW_STYLE_SHADER
		rect			0 0 854 75 HORIZONTAL_ALIGN_FULLSCREEN 0
		background		"gradient_top"
		visible			1
		decoration
	}
	itemDef
	{
		style			WINDOW_STYLE_SHADER
		rect			0 405 854 75 HORIZONTAL_ALIGN_FULLSCREEN 0
		background		"gradient_bottom"
		visible			1
		decoration
	}

	CHOICE_MENU_TITLE( "INVENTORY" )

	#define BACK_OPEN;
	#include "ui_mp/navcontrols.inc"

	#define CAC_SETUP_ACTION1 \
		play "mouse_click"; \
		execOnDvarStringValue loadout_class assault "set selected_weapon_class assault;set ui_weapon_class_selected @MPUI_ASSAULT_RIFLES"; \
		execOnDvarStringValue loadout_class specops "set selected_weapon_class specops;set ui_weapon_class_selected @MPUI_SUB_MACHINE_GUNS"; \
		execOnDvarStringValue loadout_class demolitions "set selected_weapon_class demolitions;set ui_weapon_class_selected @MPUI_SHOTGUNS"; \
		execOnDvarStringValue loadout_class sniper "set selected_weapon_class sniper;set ui_weapon_class_selected @MPUI_SNIPER_RIFLES"; \
		uiScript openMenuOnDvar loadout_class assault "ocd_popup_cac_assault"; \
		uiScript openMenuOnDvar loadout_class specops "ocd_popup_cac_SMG"; \
		uiScript openMenuOnDvar loadout_class demolitions "ocd_popup_cac_shotgun"; \
		uiScript openMenuOnDvar loadout_class sniper "ocd_popup_cac_sniper";

	CHOICE_BUTTON( 1, "1. Primary Weapon", CAC_SETUP_ACTION1 )
	execKey "1" { CAC_SETUP_ACTION1; }

	#define CAC_SETUP_ACTION_ATTACHMENT \
		play "mouse_click"; \
		uiScript openMenuOnDvar loadout_class assault "ocd_attachment_popup_assault"; \
		uiScript openMenuOnDvar loadout_class specops "ocd_attachment_popup_SMG";

	CHOICE_BUTTON_VIS( 2, "2. Primary Attachment", CAC_SETUP_ACTION_ATTACHMENT, when( dvarString( loadout_primary ) != "mp44" && dvarString( loadout_class ) != "demolitions" && dvarString( loadout_class ) != "sniper" ) )
	CHOICE_DBUTTON_VIS( 2, "2. Primary Attachment", when( dvarString( loadout_primary ) == "mp44" || dvarString( loadout_class ) == "demolitions" || dvarString( loadout_class ) == "sniper" ) )
	execKey "2" { CAC_SETUP_ACTION_ATTACHMENT; }

	#define CAC_SETUP_ACTION2 \
		play "mouse_click"; \
		open "ocd_popup_cac_secondary";

	CHOICE_BUTTON( 3, "3. Side Arm", CAC_SETUP_ACTION2 )
	execKey "3" { CAC_SETUP_ACTION2; }

	#define CAC_SETUP_ACTION3 \
		play "mouse_click"; \
		open "ocd_popup_cac_extra";

	CHOICE_BUTTON( 4, "4. Grenade", CAC_SETUP_ACTION3 )
	execKey "4" { CAC_SETUP_ACTION3 }

	#define CAC_SETUP_CAMOX \
		open "ocd_popup_cac_camo";

	CHOICE_BUTTON( 5, "5. Camo", CAC_SETUP_CAMOX )
	execKey "5" { CAC_SETUP_CAMOX; }

	#define CAC_SETUP_ACTIONGO \
		play "mouse_click"; \
		scriptMenuResponse "go";

	CHOICE_BUTTON( 6, "6. Start!", CAC_SETUP_ACTIONGO )
	execKey "6" { CAC_SETUP_ACTIONGO; }

	#define STAT_CAC_PRIMARY				tableLookup("mp/statstable.csv", 4, dvarString( loadout_primary ), 0)
	#define STAT_CAC_PRIMARY_ATTACHMENT		tableLookup("mp/attachmentTable.csv", 4, dvarString( loadout_primary_attachment ), 9)
	#define STAT_CAC_SECONDARY				tableLookup("mp/statstable.csv", 4, dvarString( loadout_secondary ), 0)
	#define STAT_CAC_SECONDARY_ATTACHMENT	tableLookup("mp/attachmentTable.csv", 4, dvarString( loadout_secondary_attachment ), 9)
	#define STAT_CAC_CAMO					tableLookup("mp/attachmentTable.csv", 4, dvarString( loadout_camo ), 11)

	#include "ui_mp/cac_loadout_ingame.inc"
}

#define PREPROC_ATTACH_CLOSEALL \
close "ocd_popup_cac_primary"; \
close "ocd_popup_cac_secondary"; \
close "ocd_popup_cac_assault"; \
close "ocd_popup_cac_SMG"; \
close "ocd_popup_cac_sniper"; \
close "ocd_popup_cac_shotgun"; \
close "ocd_attachment_popup_assault"; \
close "ocd_attachment_popup_SMG"; \
close "ocd_attachment_popup_pistol"; \
close "ocd_popup_cac_camo"; \

#include "ui_mp/weaponinfo.menu"
#include "ui_mp/popupstyle.inc"
#include "ui/choices_setup_popmenu.menu"

#undef CHOICE_SIZE_X
#define CHOICE_SIZE_X			216

#undef NEW_X_OFFSET
#define NEW_X_OFFSET	(0-CHOICE_SIZE_X)

#undef NEW_Y_OFFSET
#define NEW_Y_OFFSET	(0-2)

#define LOCAL_WEAPON_INFO_WINDOW( highlight_dvar ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH-6) -4 280 CHOICE_POPUP_HEIGHT( 7 ) CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "white", CHOICE_POPUP_BORDER_COLOR, 1, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" && dvarString(ui_inside_popup) != "camo" ); ) \
	LOADOUT_PLATING_RAW( CHOICE_POPUP_WIDTH 8, -2, 0, 280, (CHOICE_POPUP_HEIGHT( 7 )-4), CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN visible when( dvarString(ui_inside_popup) != "attachment" && dvarString(ui_inside_popup) != "camo" );, 0, 0 )\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+6) 30 256 48 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "gradient_bottom", 1 1 1 0.3, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" && dvarString(ui_inside_popup) != "camo" ); ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+72) -6 180 90 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, tablelookup("mp/statsTable.csv",4,dvarString(highlight_dvar),6), 1 1 1 1, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" && dvarString(ui_inside_popup) != "camo" ); ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 58 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/statstable.csv",4,dvarString(highlight_dvar),3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE visible when( dvarString(ui_inside_popup) != "attachment" && dvarString(ui_inside_popup) != "camo" ); ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 80 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/statstable.csv",4,dvarString(highlight_dvar),7), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR ) \

#define LOCAL_PRIMARY_WEAPON_ACTION( suffix, weapClass, weapRef ) \
	play "mouse_click"; \
	execOnDvarStringValue loadout_primary_attachment gl ""; \
	scriptMenuResponse "loadout_primary:"weapRef;\
	setdvar loadout_primary weapRef; \
	close self;

#define WI_FOCUS_ACTION( weaponRef ) \
	exec "set ui_primary_highlighted "weaponRef;

#define LOCAL_WEAPON_ITEM( suffix, itemNum, weaponName, weaponClass, weaponRef )\
	CHOICE_BUTTON_FOCUS_VIS_NOHI( itemNum, "", ;, WI_FOCUS_ACTION( weaponRef ), ;, when( !dvarBool( "weap_allow_"weaponRef ) ); ) \
	CHOICE_DBUTTON_VIS( itemNum, weaponName, when( 1 ); ) \
	CHOICE_BUTTON_FOCUS_VIS_ADV( itemNum, weaponName, LOCAL_PRIMARY_WEAPON_ACTION( suffix, weaponClass, weaponRef ), \
	WI_FOCUS_ACTION( weaponRef ), ;, when( dvarBool( "weap_allow_"weaponRef ) );, \
	dvarBool( "weap_allow_"weaponRef ) ) \

menuDef
{
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_primary", 5, (CHOICE_X( 1 )-2), (CHOICE_Y( 1 )-4), ;, execnow "set ui_inside_popup weapon_class; set ui_show_preview 1";, 1 )
	onClose{ execnow "set ui_show_preview 0; set ui_primary_highlighted 0; set ui_attachment_highlighted 0"; }

	#define LOCAL_WEAPON_CLASS( itemNum, ptext, plabel ) \
		CHOICE_BUTTON_EX( itemNum, plabel, play "mouse_click"; execnow "set selected_weapon_class "ptext"; set ui_weapon_class_selected "plabel; open "ocd_popup_cac_"ptext;, name ptext )

	LOCAL_WEAPON_CLASS( 1, "assault", "@MPUI_ASSAULT_RIFLES" )
	LOCAL_WEAPON_CLASS( 2, "SMG", "@MPUI_SUB_MACHINE_GUNS" )
	LOCAL_WEAPON_CLASS( 4, "shotgun", "@MPUI_SHOTGUNS" )
	LOCAL_WEAPON_CLASS( 5, "sniper", "@MPUI_SNIPER_RIFLES" )
}

#undef UI_FOCUSFIRST
#define UI_FOCUSFIRST "ui_primary_highlighted"

#define LOCAL_MASTER_WEAPON_GROUP( suffix, pos, y_offset )\
menuDef	{\
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_assault"suffix, 7, (CHOICE_X( pos )-2), (CHOICE_Y( pos )-28+y_offset), ;, execnow "set "UI_FOCUSFIRST" "REF_AK47"; set ui_inside_popup assault";, 0 )\
	LOCAL_WEAPON_INFO_WINDOW( "ui_primary_highlighted" )\
	LOCAL_WEAPON_ITEM( suffix, 1, "1. M16A4", "assault", REF_M16 )\
	LOCAL_WEAPON_ITEM( suffix, 2, "2. AK-47", "assault", REF_AK47 )\
	LOCAL_WEAPON_ITEM( suffix, 3, "3. M4 Carbine", "assault", REF_M4 )\
	LOCAL_WEAPON_ITEM( suffix, 4, "4. G3", "assault", REF_G3 )\
	LOCAL_WEAPON_ITEM( suffix, 5, "5. G36C", "assault", REF_G36C )\
	LOCAL_WEAPON_ITEM( suffix, 6, "6. M14", "assault", REF_M14 )\
	LOCAL_WEAPON_ITEM( suffix, 7, "7. MP44", "assault", REF_MP44 )\
	execKey "1" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_M16 ); }\
	execKey "2" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_AK47 ); }\
	execKey "3" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_M4 ); }\
	execKey "4" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_G3 ); }\
	execKey "5" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_G36C ); }\
	execKey "6" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_M14 ); }\
	execKey "7" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "assault", REF_MP44 ); }\
}\
menuDef	{\
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_SMG"suffix, 7, (CHOICE_X( pos )-2), (CHOICE_Y( pos )-28+y_offset), ;, execnow "set "UI_FOCUSFIRST" "REF_MP5";set ui_inside_popup smg";, 0 )\
	LOCAL_WEAPON_INFO_WINDOW( "ui_primary_highlighted" )\
	LOCAL_WEAPON_ITEM( suffix, 1, "1. MP5", "SMG", REF_MP5 )\
	LOCAL_WEAPON_ITEM( suffix, 2, "2. Mini-Uzi", "SMG", REF_UZI )\
	LOCAL_WEAPON_ITEM( suffix, 3, "3. AK-74u", "SMG", REF_AK74U )\
	execKey "1" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "SMG", REF_MP5 ); }\
	execKey "2" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "SMG", REF_UZI ); }\
	execKey "3" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "SMG", REF_AK74U ); }\
}\
menuDef	{\
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_shotgun"suffix, 7, (CHOICE_X( pos )-2), (CHOICE_Y( pos )-28+y_offset), ;, execnow "set "UI_FOCUSFIRST" "REF_WINCHESTER1200"; set ui_inside_popup shotgun";, 0 )\
	LOCAL_WEAPON_INFO_WINDOW( "ui_primary_highlighted" )\
	LOCAL_WEAPON_ITEM( suffix, 1, "1. W1200", "shotgun", REF_WINCHESTER1200 )\
	LOCAL_WEAPON_ITEM( suffix, 2, "2. M1014", "shotgun", REF_BENELLIM4 )\
	execKey "1" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "shotgun", REF_WINCHESTER1200 ); }\
	execKey "2" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "shotgun", REF_BENELLIM4 ); }\
}\
menuDef	{\
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_sniper"suffix, 7, (CHOICE_X( pos )-2), (CHOICE_Y( pos )-28+y_offset), ;, execnow "set "UI_FOCUSFIRST" "REF_M40A3"; set ui_inside_popup sniper";, 0 )\
	LOCAL_WEAPON_INFO_WINDOW( "ui_primary_highlighted" )\
	LOCAL_WEAPON_ITEM( suffix, 1, "1. M40A3", "sniper", REF_M40A3 )\
	LOCAL_WEAPON_ITEM( suffix, 2, "2. R700", "sniper", REF_REMINGTON700 )\
	execKey "1" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "sniper", REF_M40A3 ); }\
	execKey "2" { LOCAL_PRIMARY_WEAPON_ACTION( suffix, "sniper", REF_REMINGTON700 ); }\
}

LOCAL_MASTER_WEAPON_GROUP( "", 1, 0 )

#define LOCAL_ATTACHMENT_INFO_WINDOW( parentDvar ) \
	\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH-6) -4 280 CHOICE_POPUP_HEIGHT( 6 ) CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "white", CHOICE_POPUP_BORDER_COLOR, 1, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "camo" ); ) \
	LOADOUT_PLATING_RAW( CHOICE_POPUP_WIDTH 8, -2, 0, 280, (CHOICE_POPUP_HEIGHT( 6 )-4), CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN visible when( dvarString(ui_inside_popup) != "camo" );, 0, 0 ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+6) 30 256 48 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "gradient_bottom", 1 1 1 0.3, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "camo" ); ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+182) 6 64 64 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, tablelookup("mp/attachmentTable.csv",4,dvarString(ui_attachment_highlighted),6), 1 1 1 1, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "camo" ); ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 58 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/attachmentTable.csv",4,dvarString(ui_attachment_highlighted),3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE visible when( dvarString(ui_inside_popup) != "camo" ); ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 80 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/attachmentTable.csv",4,dvarString(ui_attachment_highlighted),7), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR )\

#define LOCAL_ATTACHMENT_ACTION( attachmentDvar, attachmentName, paction, groupArg ) \
	setdvar loadout_primary_attachment attachmentName; \
	scriptMenuResponse "loadout_primary_attachment:"groupArg":"attachmentName;\
	PREPROC_ATTACH_CLOSEALL

#define LOCAL_ATTACHMENT_ACTION2( attachmentDvar, attachmentName, paction, groupArg ) \
	setdvar loadout_secondary_attachment attachmentName; \
	scriptMenuResponse "loadout_secondary_attachment:"groupArg":"attachmentName;\
	PREPROC_ATTACH_CLOSEALL

#define AI_FOCUS_ACTION( groupArg, weaponRef ) \
	exec "set ui_attachment_highlighted "weaponRef;

#define LOCAL_ATTACHMENT_ITEM( itemNum, buttonText, p_setstat, groupArg ,p_numref, pname, paction, ptype, statDvar, bitMask)\
	CHOICE_BUTTON_FOCUS_VIS_ADV( itemNum, buttonText, LOCAL_ATTACHMENT_ACTION( statDvar, pname, paction, groupArg );, AI_FOCUS_ACTION(groupArg,pname), ;, when( ptype == "primary" && dvarBool( "attach_allow_"groupArg"_"pname ) ), ptype == "primary" && dvarBool( "attach_allow_"groupArg"_"pname ) ) \
	CHOICE_BUTTON_FOCUS_VIS_ADV( itemNum, buttonText, LOCAL_ATTACHMENT_ACTION2( statDvar, pname, paction, groupArg );, AI_FOCUS_ACTION(groupArg,pname), ;, when( ptype == "secondary" && dvarBool( "attach_allow_"groupArg"_"pname ) ), ptype == "primary" && dvarBool( "attach_allow_"groupArg"_"pname ) ) \
	CHOICE_BUTTON_FOCUS_VIS_NOHI( itemNum, "", ;, AI_FOCUS_ACTION(groupArg,pname), ;, when( !dvarBool( "attach_allow_"groupArg"_"pname ) ); ) \
	CHOICE_DBUTTON_VIS( itemNum, buttonText, when( !dvarBool( "attach_allow_"groupArg"_"pname ) ); )

#undef UI_FOCUSFIRST
#define UI_FOCUSFIRST "ui_attachment_highlighted"

#define LOCAL_MASTER_ATTACHMENT_GROUP( stat_slot, suffix, pos, ptype, y_offset, statDvar )\
menuDef { \
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_attachment_popup_assault"suffix, 6, (CHOICE_X( pos )-2), (CHOICE_Y( pos )+26+y_offset), ;, execnow "set "UI_FOCUSFIRST" "REF_ATTACHMENT_NONE"; set ui_inside_popup attachment";, 0 )\
	onClose{execnow "set ui_inside_popup 0";} \
	LOCAL_ATTACHMENT_INFO_WINDOW( "loadout_"ptype )\
	LOCAL_ATTACHMENT_ITEM( 1, "1. No Attachment", stat_slot, "assault", NUM_NONE, "none", ;, ptype, statDvar, 0 )\
	LOCAL_ATTACHMENT_ITEM( 2, "2. Silencer", stat_slot, "assault", NUM_SUPPRESSOR, "silencer", ;, ptype, statDvar, SILENCER_NEW_BITMASK )\
	execKey "1" { LOCAL_ATTACHMENT_ACTION( 1, "none", 1, "assault" ); }\
	execKey "2" { LOCAL_ATTACHMENT_ACTION( 2, "silencer", 1, "assault" ); }\
}\
menuDef	{ \
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_attachment_popup_SMG"suffix, 6, (CHOICE_X( pos )-2), (CHOICE_Y( pos )+26+y_offset), ;, execnow "set "UI_FOCUSFIRST" "REF_ATTACHMENT_NONE"; set ui_inside_popup attachment";, 0 )\
	onClose{execnow "set ui_inside_popup 0";} \
	LOCAL_ATTACHMENT_INFO_WINDOW( "loadout_"ptype )\
	LOCAL_ATTACHMENT_ITEM( 1, "1. No Attachment", stat_slot, "specops", NUM_NONE, "none", ;, ptype, statDvar, 0 )\
	LOCAL_ATTACHMENT_ITEM( 2, "2. Silencer", stat_slot, "specops", NUM_SUPPRESSOR, "silencer", ;, ptype, statDvar, SILENCER_NEW_BITMASK )\
	execKey "1" { LOCAL_ATTACHMENT_ACTION( 1, "none", 1, "specops" ); }\
	execKey "2" { LOCAL_ATTACHMENT_ACTION( 2, "silencer", 1, "specops" ); }\
}
menuDef	{
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_attachment_popup_pistol", 6, (CHOICE_X( 2 )-2), (CHOICE_Y( 2 )), ;, execnow "set "UI_FOCUSFIRST" "REF_ATTACHMENT_NONE"; set ui_inside_popup attachment";, 0 )
	onClose{execnow "set ui_inside_popup 0";}
	LOCAL_ATTACHMENT_INFO_WINDOW( "loadout_secondary" )
	LOCAL_ATTACHMENT_ITEM( 1, "1. No Attachment", CAC_SECONDARY_ATTACHMENT, "pistol", NUM_NONE, "none", ;, "secondary", "ui_secondary_weapon", 0 )
	LOCAL_ATTACHMENT_ITEM( 2, "2. Silencer", CAC_SECONDARY_ATTACHMENT, "pistol", NUM_SUPPRESSOR, "silencer", ;, "secondary", "ui_secondary_weapon", SILENCER_NEW_BITMASK )
	execKey "1" { LOCAL_ATTACHMENT_ACTION2( 1, "none", 1, "pistol" ); }
	execKey "2" { LOCAL_ATTACHMENT_ACTION2( 2, "silencer", 1, "pistol" ); }
}

LOCAL_MASTER_ATTACHMENT_GROUP( CAC_PRIMARY_ATTACHMENT, "", 1, "primary", -30, "loadout_primary_attachment" )

#define LOCAL_SIDEARM_INFO_WINDOW( highlight_dvar ) \
	\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH-6) -4 280 CHOICE_POPUP_HEIGHT( 6 ) CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "white", CHOICE_POPUP_BORDER_COLOR, 1, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" ); ) \
	LOADOUT_PLATING_RAW( CHOICE_POPUP_WIDTH 8, -2, 0, 280, (CHOICE_POPUP_HEIGHT( 6 )-4), CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN visible when( dvarString(ui_inside_popup) != "attachment" );, 0, 0 )\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+6) 30 256 48 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "gradient_bottom", 1 1 1 0.3, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" ); ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+138) -12 90 90 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, tablelookup("mp/statsTable.csv",4,dvarString(highlight_dvar),6), 1 1 1 1, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" ); ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 58 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/statstable.csv",4,dvarString(highlight_dvar),3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE visible when( dvarString(ui_inside_popup) != "attachment" ); ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 80 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/statstable.csv",4,dvarString(highlight_dvar),7), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR )\

#define LOCAL_SIDEARM_ACTION( pstat, weaponRef ) \
		play "mouse_click"; \
		setdvar	loadout_secondary weaponRef; \
		setdvar	loadout_secondary_attachment none; \
		scriptMenuResponse "loadout_secondary:"weaponRef;\
		PREPROC_ATTACH_CLOSEALL

#define LOCAL_SIDEARM_ACTION2( pstat, weaponRef ) \
		play "mouse_click"; \
		setdvar	loadout_secondary weaponRef; \
		setdvar	loadout_secondary_attachment none; \
		scriptMenuResponse "loadout_secondary:"weaponRef;\
		uiScript openMenuOnDvar "selected_weapon_class" pistol "ocd_attachment_popup_pistol";

#define SI_FOCUS_ACTION( weaponRef ) \
	exec "set ui_sidearm_highlighted "weaponRef;

#define LOCAL_SIDEARM_ITEM( itemNum, weaponName, weaponStat, weaponRef, highlight_dvar )\
	CHOICE_BUTTON_FOCUS_VIS_ADV( itemNum, weaponName, LOCAL_SIDEARM_ACTION( weaponStat, weaponRef ), SI_FOCUS_ACTION( weaponRef ), ;, \
	when( dvarBool( "weap_allow_"weaponRef ) && ( weaponRef == REF_DESERTEAGLE || weaponRef == REF_DESERTEAGLEGOLD ) );, \
		dvarBool( "weap_allow_"weaponRef ) && ( weaponRef == REF_DESERTEAGLE || weaponRef == REF_DESERTEAGLEGOLD ) ) \
	CHOICE_BUTTON_FOCUS_VIS_ADV( itemNum, weaponName, LOCAL_SIDEARM_ACTION2( weaponStat, weaponRef ), SI_FOCUS_ACTION( weaponRef ), ;, \
	when( dvarBool( "weap_allow_"weaponRef ) && weaponRef != REF_DESERTEAGLE && weaponRef != REF_DESERTEAGLEGOLD );, \
		dvarBool( "weap_allow_"weaponRef ) && weaponRef != REF_DESERTEAGLE && weaponRef != REF_DESERTEAGLEGOLD ) \
	CHOICE_BUTTON_FOCUS_VIS_NOHI( itemNum, "", ;, SI_FOCUS_ACTION( weaponRef ), ;, when( !dvarBool( "weap_allow_"weaponRef ) ); ) \
	CHOICE_DBUTTON_VIS( itemNum, weaponName, when( !dvarBool( "weap_allow_"weaponRef ) ); )

#undef UI_FOCUSFIRST
#define UI_FOCUSFIRST "ui_sidearm_highlighted"

menuDef
{
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_secondary", 6, (CHOICE_X( 2 )-2), (CHOICE_Y( 2 )), ;, execnow "set "UI_FOCUSFIRST" "REF_M9BERETTA"; set selected_weapon_class pistol; set ui_inside_popup pistol";, 0 )
	onClose{execnow "set ui_inside_popup 0";}
	LOCAL_SIDEARM_INFO_WINDOW( "ui_sidearm_highlighted" )
	LOCAL_SIDEARM_ITEM( 1, "1. Gold Desert Eagle", STAT_PISTOL_DESERTEAGLEGOLD, REF_DESERTEAGLEGOLD, "ui_sidearm_highlighted" )
	LOCAL_SIDEARM_ITEM( 2, "2. Desert Eagle", STAT_PISTOL_DESERTEAGLE, REF_DESERTEAGLE, "ui_sidearm_highlighted" )
	LOCAL_SIDEARM_ITEM( 3, "3. M1911 .45", STAT_PISTOL_COLT45, REF_COLT45, "ui_sidearm_highlighted" )
	LOCAL_SIDEARM_ITEM( 4, "4. USP .45", STAT_PISTOL_USP, REF_USP, "ui_sidearm_highlighted" )
	LOCAL_SIDEARM_ITEM( 5, "5. M9", STAT_PISTOL_M9BERETTA, REF_M9BERETTA, "ui_sidearm_highlighted" )

	execKey "1" { LOCAL_SIDEARM_ACTION(STAT_PISTOL_DESERTEAGLEGOLD,REF_DESERTEAGLEGOLD); }
	execKey "2" { LOCAL_SIDEARM_ACTION(STAT_PISTOL_DESERTEAGLE,REF_DESERTEAGLE); }
	execKey "3" { LOCAL_SIDEARM_ACTION2(STAT_PISTOL_COLT45,REF_COLT45); }
	execKey "4" { LOCAL_SIDEARM_ACTION2(STAT_PISTOL_USP,REF_USP); }
	execKey "5" { LOCAL_SIDEARM_ACTION2(STAT_PISTOL_M9BERETTA,REF_M9BERETTA); }
}

#define LOCAL_SGRENADE_INFO_WINDOW( highlight_dvar ) \
	\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH-6) -4 280 CHOICE_POPUP_HEIGHT(5) CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "white", CHOICE_POPUP_BORDER_COLOR, 1, 2, CHOICE_POPUP_BORDER_COLOR ) \
	LOADOUT_PLATING_RAW( CHOICE_POPUP_WIDTH 8, -2, 0, 280, (CHOICE_POPUP_HEIGHT( 5 )-4), CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN visible when( dvarString(ui_inside_popup) != "attachment" );, 0, 0 )\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+6) 6 256 48 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "gradient_bottom", 1 1 1 0.3, 0, 2, CHOICE_POPUP_BORDER_COLOR visible when( dvarString(ui_inside_popup) != "attachment" ); ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+178) -6 64 64 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, tablelookup("mp/statsTable.csv",4,dvarString(highlight_dvar),6), 1 1 1 1, 0, 2, CHOICE_POPUP_BORDER_COLOR ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 34 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/statstable.csv",4,dvarString(highlight_dvar),3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 56 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/statstable.csv",4,dvarString(highlight_dvar),7), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR )

#define LOCAL_SGRENADE_ACTION( weaponRef ) \
		play "mouse_click"; \
		setdvar loadout_grenade weaponRef; \
		scriptMenuResponse "loadout_grenade:"weaponRef;\
		close "ocd_popup_cac_extra"

#define LOCAL_SGRENADE_ITEM( itemNum, weaponName, weaponStat, weaponRef, highlight_dvar )\
	CHOICE_BUTTON_FOCUS_VIS_ADV( itemNum, weaponName, LOCAL_SGRENADE_ACTION( weaponRef ), execnow "set "highlight_dvar" "weaponRef, ;, when( dvarBool("weap_allow_"weaponRef) );, dvarBool("weap_allow_"weaponRef) ) \
	CHOICE_DBUTTON_VIS( itemNum, weaponName, when( !dvarBool("weap_allow_"weaponRef) ); )

#undef UI_FOCUSFIRST
#define UI_FOCUSFIRST "ui_sgrenade_highlighted"

menuDef
{
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_extra", 5, (CHOICE_X( 3 )-2), (CHOICE_Y( 3 )+4), ;, execnow "set "UI_FOCUSFIRST" "REF_FLASH_X1"; set ui_inside_popup sgrenade";, 0 )
	onClose{ execnow "set ui_inside_popup 0"; }
	LOCAL_SGRENADE_INFO_WINDOW( "ui_sgrenade_highlighted" )
	LOCAL_SGRENADE_ITEM( 1, "1. Flash", STAT_FLASH_X1, REF_FLASH_X1, "ui_sgrenade_highlighted" )
	LOCAL_SGRENADE_ITEM( 2, "2. Smoke", STAT_SMOKE_X1, REF_SMOKE_X1, "ui_sgrenade_highlighted" )
	execKey "1" { LOCAL_SGRENADE_ACTION(REF_FLASH_X1); }
	execKey "2" { LOCAL_SGRENADE_ACTION(REF_SMOKE_X1); }
}

	#define LOCAL_CAMO_INFO_WINDOW( highlight_dvar ) \
	\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH-6) -4 280 CHOICE_POPUP_HEIGHT( 7 ) CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "white", CHOICE_POPUP_BORDER_COLOR, 1, 2, CHOICE_POPUP_BORDER_COLOR ) \
	LOADOUT_PLATING_RAW( CHOICE_POPUP_WIDTH 8, -2, 0, 280, (CHOICE_POPUP_HEIGHT( 7 )-4), CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0, 0 )\
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+6) 30 256 48 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "gradient_bottom", 1 1 1 0.3, 0, 2, CHOICE_POPUP_BORDER_COLOR ) \
	PREPROC_SHADER_DRAW_ALIGNED( (CHOICE_POPUP_WIDTH+184) 0 64 64 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, tablelookup("mp/attachmentTable.csv",4,dvarString(highlight_dvar),6), 1 1 1 0.75, 1, 7, 0.2 0.2 0.225 1 ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 58 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/attachmenttable.csv",4,dvarString(highlight_dvar),3), TEXTSIZE_DEFAULT, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, COLOR_TITLE ) \
	PREPROC_TEXT_DRAW_ALIGNED_EXP( (CHOICE_POPUP_WIDTH+10) 80 256 20 CHOICE_HORIZONTAL_ALIGN CHOICE_VERTICAL_ALIGN, 0 0, "@"+tablelookup("mp/attachmenttable.csv",4,dvarString(highlight_dvar),7), TEXTSIZE_SMALL, 0, 0, ITEM_ALIGN_MIDDLE_LEFT, CHOICE_TEXTCOLOR )\

#define LOCAL_CAMO_ACTION( camoRef ) \
		play "mouse_click"; \
		setdvar loadout_camo camoRef;\
		scriptMenuResponse "loadout_camo:" camoRef;\
		PREPROC_ATTACH_CLOSEALL

#define LOCAL_CAMO_ITEM( itemNum, camoName, pnum, camoRef, highlight_dvar, bitMask, visArg )\
	CHOICE_BUTTON_FOCUS( itemNum, camoName, LOCAL_CAMO_ACTION( camoRef );, execnow "set "highlight_dvar" "camoRef;, ; );

#define LOCAL_CAMO_ITEM2( itemNum, camoName, pnum, camoRef, highlight_dvar, bitMask, visArg )\
	CHOICE_BUTTON_FOCUS_VIS( itemNum, camoName, LOCAL_CAMO_ACTION( camoRef );, execnow "set "highlight_dvar" "camoRef;, ;, when( dvarString( loadout_primary ) == "ak47" || dvarString( loadout_primary ) == "uzi" || dvarString( loadout_primary ) == "m1014" ) ) \
	CHOICE_DBUTTON_VIS( itemNum, camoName, when( dvarString( loadout_primary ) != "ak47" && dvarString( loadout_primary ) != "uzi" && dvarString( loadout_primary ) != "m1014" ) )

#undef UI_FOCUSFIRST
#define UI_FOCUSFIRST "ui_camo_highlighted"

#define LOCAL_CAMO_GROUP( prefix, onLeave )\
menuDef	\
{\
	IMPROVED_POPUP_SETUP_ONOPEN( "ocd_popup_cac_camo"prefix, 7, (CHOICE_X( 1 )-2), (CHOICE_Y( 1 )+68), ;, execnow "set "UI_FOCUSFIRST" "REF_CAMO_NONE"; set ui_inside_popup camo";, 0 )\
	onClose{onLeave;} \
	LOCAL_CAMO_INFO_WINDOW( "ui_camo_highlighted" )\
	LOCAL_CAMO_ITEM( 1, "1. None", CAMO_NONE, REF_CAMO_NONE, "ui_camo_highlighted", 0, 1 )\
	LOCAL_CAMO_ITEM( 2, "2. Desert", CAMO_BROCKHUARD, REF_BROCKHUARD, "ui_camo_highlighted", DESERT_NEW_BITMASK, 1 )\
	LOCAL_CAMO_ITEM( 3, "3. Woodland", CAMO_BUSHDWELLER, REF_BUSHDWELLER, "ui_camo_highlighted", WOODLAND_NEW_BITMASK, 1 )\
	LOCAL_CAMO_ITEM( 4, "4. Digital", CAMO_BLACKWHITEMARPAT, REF_BLACKWHITEMARPAT, "ui_camo_highlighted", DIGITAL_NEW_BITMASK, 1 )\
	LOCAL_CAMO_ITEM( 5, "5. Red Tiger", CAMO_TIGERRED, REF_TIGERRED, "ui_camo_highlighted", REDTIGER_NEW_BITMASK, 1 )\
	LOCAL_CAMO_ITEM( 6, "6. Blue Tiger", CAMO_STAGGER, REF_STAGGER, "ui_camo_highlighted", BLUETIGER_NEW_BITMASK, 1 )\
	LOCAL_CAMO_ITEM2( 7, "7. Golden", CAMO_GOLDEN, REF_GOLDEN, "ui_camo_highlighted", GOLDEN_NEW_BITMASK, 1 )\
	execKey "1" { LOCAL_CAMO_ACTION(REF_CAMO_NONE); }\
	execKey "2" { LOCAL_CAMO_ACTION(REF_BROCKHUARD); }\
	execKey "3" { LOCAL_CAMO_ACTION(REF_BUSHDWELLER); }\
	execKey "4" { LOCAL_CAMO_ACTION(REF_BLACKWHITEMARPAT); }\
	execKey "5" { LOCAL_CAMO_ACTION(REF_TIGERRED); }\
	execKey "6" { LOCAL_CAMO_ACTION(REF_STAGGER); }\
	execKey "7" { LOCAL_CAMO_ACTION(REF_GOLDEN); }\
}

LOCAL_CAMO_GROUP( "", execnow "set ui_inside_popup attachment" )