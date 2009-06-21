/*
  Copyright (c) 2008 Matthias Lorenz
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	game["TrainingNadeHint1"] 	= "^7Press ^3[{+attack}] ^7to stop the Flight";
	game["TrainingNadeHint2"] 	= "^7Press ^3[{+activate}] ^7to Return to throw position";
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	self notify("onPlayerConnect");
	self endon("onPlayerConnect");

	for(;;)
	{
		level waittill("connecting", player);

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self notify("onPlayerSpawned");
	self endon("onPlayerSpawned");

	self endon( "disconnect" );
	level endon ( "game_ended" );

	for(;;)
	{
		self waittill("spawned");
		self thread NadeTraining();
		wait 1;
	}
}

NadeTraining()
{
	self notify("nadescript_ende");
	self endon("nadescript_ende");

	self endon( "disconnect" );
	level endon ( "game_ended" );

	grenade_counter = 0;

	granaten_anzahl_alt	 		= self maps\mp\gametypes\_weapons::getFragGrenadeCount();
	smokegranaten_anzahl_alt 	= self maps\mp\gametypes\_weapons::getSmokeGrenadeCount();
	flashgranaten_anzahl_alt 	= self maps\mp\gametypes\_weapons::getFlashGrenadeCount();

	for(;;)
	{

		granaten_anzahl 		= self maps\mp\gametypes\_weapons::getFragGrenadeCount();
		smokegranaten_anzahl 	= self maps\mp\gametypes\_weapons::getSmokeGrenadeCount();
		flashgranaten_anzahl	= self maps\mp\gametypes\_weapons::getFlashGrenadeCount();

		if(granaten_anzahl != granaten_anzahl_alt || smokegranaten_anzahl != smokegranaten_anzahl_alt || flashgranaten_anzahl != flashgranaten_anzahl_alt) {

			self giveWeapon( "frag_grenade_mp" );
			self setWeaponAmmoClip( "frag_grenade_mp", 1 );
			self giveWeapon( "smoke_grenade_mp" );
			self setWeaponAmmoClip( "smoke_grenade_mp", 1 );
			self giveWeapon( "flash_grenade_mp" );
			self setWeaponAmmoClip( "flash_grenade_mp", 1 );

			grenades = getentarray("grenade","classname");

			for(i=0;i<grenades.size;i++) {

				if(isDefined(grenades[i].origin) && !isDefined(grenades[i].running)) {


					// * Nur wenn es die eigene Nade ist (Nahe am Player) *
					if(distance(grenades[i].origin, self.origin) < 140) {

						self createTextHudElement("TrainingNadeHint1", 320,380,"center","middle","fullscreen","fullscreen",true,game["TrainingNadeHint1"],undefined,1.5,1,1,1.0,1.0,1.0);
						self createTextHudElement("TrainingNadeHint2", 320,410,"center","middle","fullscreen","fullscreen",true,game["TrainingNadeHint2"],undefined,1.5,1,1,1.0,1.0,1.0);

						grenades[i].running = true;
						grenades[i] thread Fly(self);
					}

				}
			}
		}

		granaten_anzahl_alt	 		= granaten_anzahl;
		smokegranaten_anzahl_alt 	= smokegranaten_anzahl;

		wait 0.1;
	}
}

Fly(player)
{
	player notify("flying_ende");
	player endon("flying_ende");

	player endon( "disconnect" );
	level endon ( "game_ended" );

	old_player_origin = player.origin;

	// * Hilfsobjekt *
	player.hilfsObjekt = spawn("script_model", player.origin );
	player.hilfsObjekt.angles = player.angles;
	player.hilfsObjekt linkto(self);

	player linkto(player.hilfsObjekt);

	time = 2.8;

	old_origin = (0,0,0);

	attack_button_pressed = false;
	use_button_pressed = false;

	while(isDefined(self)) {

		wait 0.1;
		time -= 0.1;


		if(isDefined(self)) {

			// * solange warten bis Granate sich nicht mehr bewegt *
			if(self.origin == old_origin) {

				break;
			}

			old_origin = self.origin;
		}

		if(player attackButtonPressed()) {

			player deleteHudElementByName("TrainingNadeHint1");
			attack_button_pressed = true;
			break;
		}

		if(player useButtonPressed()) {

			player deleteHudElementByName("TrainingNadeHint2");
			use_button_pressed = true;
			break;
		}


	}

	wait 0.1;

	player.hilfsObjekt unlink();


	if(!use_button_pressed) {

		if(attack_button_pressed) {

			player deleteHudElementByName("TrainingNadeHint1");

			for(i=0;i<3.5;i+=0.1) {

				wait 0.1;
				if(player useButtonPressed()) break;
			}
		}
		else {

			player.hilfsObjekt moveto(player.origin+(0,0,20),0.1);
			wait 0.2;

			for(i=0;i<1;i+=0.1) {

				wait 0.1;
				if(player useButtonPressed()) break;
			}
		}
	}


	player.hilfsObjekt moveto(old_player_origin,0.1);
	wait 0.2;

	player unlink();
	if(isDefined(player.hilfsObjekt)) player.hilfsObjekt delete();


	player deleteHudElementByName("TrainingNadeHint1");
	player deleteHudElementByName("TrainingNadeHint2");


}

createLevelTextHudElement(hud_element_name, x,y,xAlign,yAlign,horzAlign,vertAlign,foreground,text,value,font_scale,sort,alpha,color_r,color_g,color_b)
{
	while(isDefined(level.globalLevelHUDChange)) wait 0.1;
	level.globalLevelHUDChange = true;

	if(!isDefined(level.hud)) level.hud = [];

	count = level.hud.size;

	level.hud[count] = newHudElem();
	level.hud[count].x = x;
	level.hud[count].y = y;
	level.hud[count].alignX = xAlign;
	level.hud[count].alignY = yAlign;
	level.hud[count].horzAlign = horzAlign;
	level.hud[count].vertAlign = vertAlign;
	level.hud[count].foreground = foreground;
	level.hud[count].sort = sort;
	level.hud[count].alpha = alpha;
	level.hud[count].color = (color_r,color_g,color_b);
	level.hud[count].fontScale = font_scale;

	if(isDefined(text)) level.hud[count] setText(text);
	if(isDefined(value)) level.hud[count] setValue(value);

	level.hud[count].name 			= hud_element_name;
	level.hud[count].shader_text 	= text;
	level.hud[count].font_scale 	= font_scale;

	level.globalLevelHUDChange = undefined;
}

changeLevelTextHudElementByName(hud_element_name,text,value,font_size,alpha,color)
{
	while(isDefined(level.globalLevelHUDChange)) wait 0.1;
	level.globalLevelHUDChange = true;

	// * Alle HUD-Elemente des Levels durchsuchen *
	if(isDefined(level.hud) && level.hud.size > 0) {

		for(i=0;i<level.hud.size;i++) {

			if(isDefined(level.hud[i]) && isDefined(level.hud[i].name) && level.hud[i].name == hud_element_name) {

				if(font_size < 0.1) 	font_size = 0;

				if(isDefined(level.hud[i]) && isDefined(text)) 	level.hud[i] setText(text);
				if(isDefined(level.hud[i]) && isDefined(value)) level.hud[i] setValue(value);

 				if(isDefined(level.hud[i])) level.hud[i].fontScale = font_size;
				if(isDefined(level.hud[i])) level.hud[i].alpha = alpha;
				if(isDefined(level.hud[i])) level.hud[i].color = color;

				break;
			}
		}
	}

	level.globalLevelHUDChange = undefined;
}

deleteLevelHudElementByName(hud_element_name)
{
	while(isDefined(level.globalLevelHUDChange)) wait 0.1;
	level.globalLevelHUDChange = true;

	// * HUD-Elemente entfernen *
	if(isDefined(level.hud) && level.hud.size > 0) {

		for(i=0;i<level.hud.size;i++) {

			if(isDefined(level.hud[i]) && isDefined(level.hud[i].name) && level.hud[i].name == hud_element_name) {

				level.hud[i] destroy();
				level.hud[i].name = undefined;
			}
		}

		new_ar = [];

		for(i=0;i<level.hud.size;i++) {

			if(isDefined(level.hud[i]) && isDefined(level.hud[i].name)) new_ar[new_ar.size] = level.hud[i];
		}

		level.hud = new_ar;
	}

	level.globalLevelHUDChange = undefined;

}

createTextHudElement(hud_element_name, x,y,xAlign,yAlign,horzAlign,vertAlign,foreground,text,value,font_scale,sort,alpha,color_r,color_g,color_b)
{
	self endon("death");
	self endon("disconnect");

	while(isDefined(self.globalLevelHUDChange)) wait 0.1;
	self.globalLevelHUDChange = true;

	if(!isDefined(self.hud)) self.hud = [];

	count = self.hud.size;

	self.hud[count] = newClientHudElem(self);
	self.hud[count].x = x;
	self.hud[count].y = y;
	self.hud[count].alignX = xAlign;
	self.hud[count].alignY = yAlign;
	self.hud[count].horzAlign = horzAlign;
	self.hud[count].vertAlign = vertAlign;
	self.hud[count].foreground = foreground;
	self.hud[count].sort = sort;
	self.hud[count].alpha = alpha;
	self.hud[count].color = (color_r,color_g,color_b);
	self.hud[count].fontScale = font_scale;

	if(isDefined(text)) 	self.hud[count] setText(text);
	if(isDefined(value)) 	self.hud[count] setValue(value);

	self.hud[count].name 		= hud_element_name;
	self.hud[count].font_scale 	= font_scale;

	self.globalLevelHUDChange = undefined;
}

changeTextHudElementByName(hud_element_name,text,value,font_size,alpha,color)
{
	self endon("death");
	self endon("disconnect");

	while(isDefined(self.globalLevelHUDChange)) wait 0.1;
	self.globalLevelHUDChange = true;

	// * Alle HUD-Elemente des Levels durchsuchen *
	if(isDefined(self.hud) && self.hud.size > 0) {

		for(i=0;i<self.hud.size;i++) {

			if(isDefined(self.hud[i]) && isDefined(self.hud[i].name) && self.hud[i].name == hud_element_name) {

				if(font_size < 0.1) 	font_size = 0;

				if(isDefined(self.hud[i]) && isDefined(text)) 	self.hud[i] setText(text);
				if(isDefined(self.hud[i]) && isDefined(value)) self.hud[i] setValue(value);

 				if(isDefined(self.hud[i])) self.hud[i].fontScale = font_size;
				if(isDefined(self.hud[i])) self.hud[i].alpha = alpha;
				if(isDefined(self.hud[i])) self.hud[i].color = color;

				break;
			}
		}
	}

	self.globalLevelHUDChange = undefined;
}

deleteHudElementByName(hud_element_name)
{
	self endon("death");
	self endon("disconnect");

	while(isDefined(self.globalLevelHUDChange)) wait 0.1;
	self.globalLevelHUDChange = true;

	// * HUD-Elemente entfernen *
	if(isDefined(self.hud) && self.hud.size > 0) {

		for(i=0;i<self.hud.size;i++) {

			if(isDefined(self.hud[i]) && isDefined(self.hud[i].name) && self.hud[i].name == hud_element_name) {

				self.hud[i] destroy();
				self.hud[i].name = undefined;
			}
		}

		new_ar = [];

		for(i=0;i<self.hud.size;i++) {

			if(isDefined(self.hud[i]) && isDefined(self.hud[i].name)) new_ar[new_ar.size] = self.hud[i];
		}

		self.hud = new_ar;
	}

	self.globalLevelHUDChange = undefined;
}