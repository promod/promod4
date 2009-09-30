/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

create()
{
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		wait 0.75;

	promod_ver = newHudElem();
	promod_ver.x = -7;
	promod_ver.y = 35;
	promod_ver.horzAlign = "right";
	promod_ver.vertAlign = "top";
	promod_ver.alignX = "right";
	promod_ver.alignY = "middle";
	promod_ver.fontScale = 1.4;
	promod_ver.hidewheninmenu = true;
	promod_ver.color = (.8, 1, 1);
	promod_ver setText( game["PROMOD_VERSION"] );

	promod_mode = newHudElem();
	promod_mode.x = -7;
	promod_mode.y = 50;
	promod_mode.horzAlign = "right";
	promod_mode.vertAlign = "top";
	promod_mode.alignX = "right";
	promod_mode.alignY = "middle";
	promod_mode.fontScale = 1.4;
	promod_mode.hidewheninmenu = true;
	promod_mode.color = (1,1,0);
	promod_mode setText( game["PROMOD_MODE_HUD"] );

	level waittill( "header_destroy" );

	if ( isDefined( promod_ver ) )
		promod_ver destroy();

	if ( isDefined( promod_mode ) )
		promod_mode destroy();
}