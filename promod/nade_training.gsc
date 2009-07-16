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
	game["TrainingNadeHint1"] = "^7Press ^3[{+attack}] ^7to stop the Flight";
	game["TrainingNadeHint2"] = "^7Press ^3[{+activate}] ^7to Return to throw position";

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
	self notify( "onPlayerSpawned" );
	self endon( "onPlayerSpawned" );

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
	self notify( "nadescript_end" );
	self endon( "nadescript_end" );

	self endon( "disconnect" );
	level endon ( "game_ended" );

	granaten_anzahl_alt = self maps\mp\gametypes\_weapons::getFragGrenadeCount();
	smokegranaten_anzahl_alt = self maps\mp\gametypes\_weapons::getSmokeGrenadeCount();
	flashgranaten_anzahl_alt = self maps\mp\gametypes\_weapons::getFlashGrenadeCount();

	for(;;)
	{
		granaten_anzahl = self maps\mp\gametypes\_weapons::getFragGrenadeCount();
		smokegranaten_anzahl = self maps\mp\gametypes\_weapons::getSmokeGrenadeCount();
		flashgranaten_anzahl = self maps\mp\gametypes\_weapons::getFlashGrenadeCount();

		if(granaten_anzahl != granaten_anzahl_alt || smokegranaten_anzahl != smokegranaten_anzahl_alt || flashgranaten_anzahl != flashgranaten_anzahl_alt) {

			self giveWeapon( "frag_grenade_mp" );
			self setWeaponAmmoClip( "frag_grenade_mp", 1 );
			self giveWeapon( "smoke_grenade_mp" );
			self setWeaponAmmoClip( "smoke_grenade_mp", 1 );
			self giveWeapon( "flash_grenade_mp" );
			self setWeaponAmmoClip( "flash_grenade_mp", 1 );

			grenades = getentarray("grenade","classname");

			for ( i=0;i<grenades.size;i++ )
			{
				if ( isDefined( grenades[i].origin ) && !isDefined( grenades[i].running ) )
				{
					if( distance(grenades[i].origin, self.origin) < 140 )
					{
						self deleteHudElementByName("TrainingNadeHint1");
						self deleteHudElementByName("TrainingNadeHint2");
						self createTextHudElement("TrainingNadeHint1", 380, game["TrainingNadeHint1"]);
						self createTextHudElement("TrainingNadeHint2", 410, game["TrainingNadeHint2"]);

						grenades[i].running = true;
						grenades[i] thread Fly(self);
					}
				}
			}
		}

		granaten_anzahl_alt = granaten_anzahl;
		smokegranaten_anzahl_alt = smokegranaten_anzahl;
		flashgranaten_anzahl_alt = flashgranaten_anzahl;

		wait 0.1;
	}
}

Fly(player)
{
	player notify( "flying_ende" );
	player endon( "flying_ende" );

	player endon( "disconnect" );
	level endon ( "game_ended" );

	old_player_origin = player.origin;

	player.hilfsObjekt = spawn("script_model", player.origin );
	player.hilfsObjekt.angles = player.angles;
	player.hilfsObjekt linkto(self);

	player linkto(player.hilfsObjekt);

	time = 2.8;

	old_origin = (0,0,0);

	attack_button_pressed = false;
	use_button_pressed = false;

	while( isDefined( self ) )
	{
		wait 0.1;
		time -= 0.1;

		if( isDefined( self ) )
		{
			if ( self.origin == old_origin )
			{
				break;
			}

			old_origin = self.origin;
		}

		if(player attackButtonPressed())
		{
			player deleteHudElementByName("TrainingNadeHint1");
			attack_button_pressed = true;
			self.flying = false;
			break;
		}

		if(player useButtonPressed())
		{
			player deleteHudElementByName("TrainingNadeHint2");
			use_button_pressed = true;
			break;
		}
	}

	wait 0.1;

	//if ( !isDefined( self ) )
	//	return;

	player.hilfsObjekt unlink();

	if( !use_button_pressed )
	{
		if( attack_button_pressed )
		{
			player deleteHudElementByName("TrainingNadeHint1");

			for( i=0;i<3.5;i+=0.1 )
			{
				wait 0.1;
				if( player useButtonPressed() )
					break;
			}
		}
		else
		{
			player.hilfsObjekt moveto(player.origin+(0,0,20),0.1);
			wait 0.2;

			for(i=0;i<1;i+=0.1)
			{
				wait 0.1;
				if( player useButtonPressed() )
					break;
			}
		}
	}

	player.hilfsObjekt moveto(old_player_origin,0.1);
	wait 0.2;

	player unlink();
	if(isDefined(player.hilfsObjekt))
		player.hilfsObjekt delete();

	player deleteHudElementByName("TrainingNadeHint1");
	player deleteHudElementByName("TrainingNadeHint2");
}

createTextHudElement(hud_element_name, y, text)
{
	self endon( "death" );
	self endon( "disconnect" );

	while(isDefined(self.globalLevelHUDChange)) wait 0.1;
	self.globalLevelHUDChange = true;

	if(!isDefined(self.hud)) self.hud = [];

	count = self.hud.size;

	self.hud[count] = newClientHudElem(self);
	self.hud[count].x = 320;
	self.hud[count].y = y;
	self.hud[count].alignX = "center";
	self.hud[count].alignY = "middle";
	self.hud[count].horzAlign = "fullscreen";
	self.hud[count].vertAlign = "fullscreen";
	self.hud[count].foreground = true;
	self.hud[count].sort = 1;
	self.hud[count].alpha = 1;
	self.hud[count].color = ( 1, 1, 1 );
	self.hud[count].fontScale = 1.5;

	if ( isDefined( text ) )
		self.hud[count] setText(text);

	self.hud[count].name = hud_element_name;
	self.hud[count].font_scale = 1.5;

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