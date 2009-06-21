/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

create()
{
	level.prover_hud = newHudElem();
	level.prover_hud.x = -7;
	level.prover_hud.y = 35;
	level.prover_hud.horzAlign = "right";
	level.prover_hud.vertAlign = "top";
	level.prover_hud.alignX = "right";
	level.prover_hud.alignY = "middle";
	level.prover_hud.alpha = 1;
	level.prover_hud.fontScale = 1.4;
	level.prover_hud.hidewheninmenu = true;
	level.prover_hud.color = (.8, 1, 1);
	level.prover_hud setText( game["PROMOD_VERSION"] );
	
	level.hud_league_text = newHudElem();
	level.hud_league_text.x = -7;
	level.hud_league_text.y = 50;
	level.hud_league_text.horzAlign = "right";
	level.hud_league_text.vertAlign = "top";
	level.hud_league_text.alignX = "right";
	level.hud_league_text.alignY = "middle";
	level.hud_league_text.alpha = 1;
	level.hud_league_text.fontScale = 1.4;
	level.hud_league_text.hidewheninmenu = true;
	level.hud_league_text.color = (1,1,0);
	level.hud_league_text setText( game["PROMOD_MODE_HUD"] );

	level waittill("header_destroy");

	if(isdefined(level.prover_hud))
		level.prover_hud destroy();

	if(isdefined(level.hud_league_text))
		level.hud_league_text destroy();

	wait .05;
}