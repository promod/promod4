/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

main()
{
	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" )
		return;

	if (getDvarInt("promod_hud_show_website") > 0)
		thread MessageCenterHUD();
}

MessageCenterHUD()
{
	if (isDefined(level.mc_hud))
		level.mc_hud destroy();

	wait .05;

	text = getDvar("promod_hud_website");

	level.mc_hud = newHudElem();
	level.mc_hud.x = 7;
	level.mc_hud.y = 415;
	level.mc_hud.horzAlign = "left";
	level.mc_hud.vertAlign = "top";
	level.mc_hud.alignX = "left";
	level.mc_hud.alignY = "middle";
	level.mc_hud.alpha = 1;
	level.mc_hud.fontScale = 1.4;
	level.mc_hud.hidewheninmenu = true;
	level.mc_hud.color = (.99, .99, .75);
	level.mc_hud setText( text );
}