/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	self.pers["PROMOD_CACHE_SUNLIGHT"] = get_config( "PROMOD_SUNLIGHT" );
	self.pers["PROMOD_CACHE_TEXTURE"] = get_config( "PROMOD_TEXTURE" );
	self.pers["PROMOD_CACHE_FILMTWEAK"] = get_config( "PROMOD_FILMTWEAK" );
	self.pers["PROMOD_CACHE_FOVSCALE"] = get_config( "PROMOD_FOVSCALE" );
	self.pers["PROMOD_CACHE_NORMALMAP"] = get_config( "PROMOD_NORMALMAP" );
	self.pers["PROMOD_CACHE_GFXBLUR"] = get_config( "PROMOD_GFXBLUR" );
	self.pers["PROMOD_CACHE_FIRSTTIME"] = get_config( "PROMOD_FIRSTTIME" );

	self use_config();
}

get_config( dataName )
{
	return self getStat( int( tableLookup( "promod/customStatsTable.csv", 1, dataName, 0 ) ) );
}

set_config( dataName, value )
{
	self setStat( int( tableLookup( "promod/customStatsTable.csv", 1, dataName, 0 ) ), value );
	self use_config();
}

toggle_sunlight()
{
	if ( !self.pers["PROMOD_CACHE_SUNLIGHT"] )
		self.pers["PROMOD_CACHE_SUNLIGHT"] = 1;
	else if ( self.pers["PROMOD_CACHE_SUNLIGHT"] == 1 )
		self.pers["PROMOD_CACHE_SUNLIGHT"] = 2;
	else
		self.pers["PROMOD_CACHE_SUNLIGHT"] = 0;

	self set_config( "PROMOD_SUNLIGHT", self.pers["PROMOD_CACHE_SUNLIGHT"] );
}

toggle_filmtweak()
{
	if ( !self.pers["PROMOD_CACHE_FILMTWEAK"] )
		self.pers["PROMOD_CACHE_FILMTWEAK"] = 1;
	else
		self.pers["PROMOD_CACHE_FILMTWEAK"] = 0;

	self set_config( "PROMOD_FILMTWEAK", self.pers["PROMOD_CACHE_FILMTWEAK"] );
}

toggle_fovscale()
{
	if ( !self.pers["PROMOD_CACHE_FOVSCALE"] )
		self.pers["PROMOD_CACHE_FOVSCALE"] = 1;
	else
		self.pers["PROMOD_CACHE_FOVSCALE"] = 0;

	self set_config( "PROMOD_FOVSCALE", self.pers["PROMOD_CACHE_FOVSCALE"] );
}

toggle_texture()
{
	if ( !self.pers["PROMOD_CACHE_TEXTURE"] )
		self.pers["PROMOD_CACHE_TEXTURE"] = 1;
	else
		self.pers["PROMOD_CACHE_TEXTURE"] = 0;

	self set_config( "PROMOD_TEXTURE", self.pers["PROMOD_CACHE_TEXTURE"] );
}

toggle_normalmap()
{
	if ( !self.pers["PROMOD_CACHE_NORMALMAP"] )
		self.pers["PROMOD_CACHE_NORMALMAP"] = 1;
	else
		self.pers["PROMOD_CACHE_NORMALMAP"] = 0;

	self set_config( "PROMOD_NORMALMAP", self.pers["PROMOD_CACHE_NORMALMAP"] );
}

toggle_gfxblur()
{
	if ( self.pers["PROMOD_CACHE_GFXBLUR"] < 5 )
		self.pers["PROMOD_CACHE_GFXBLUR"]++;
	else
		self.pers["PROMOD_CACHE_GFXBLUR"] = 0;

	self set_config( "PROMOD_GFXBLUR", self.pers["PROMOD_CACHE_GFXBLUR"] );
}

use_config()
{
	if ( !self.pers["PROMOD_CACHE_SUNLIGHT"] )
	{
		self setClientDvars( "r_lighttweaksunlight", 1.2,
							 "sunlight", 1.2 );
	}
	else if ( self.pers["PROMOD_CACHE_SUNLIGHT"] == 1 )
	{
		if ( getDvar( "mapname" ) == "mp_backlot" )
			self setClientDvar( "r_lighttweaksunlight", 1.3 );
		else if ( getDvar( "mapname" ) == "mp_bloc" )
			self setClientDvar( "r_lighttweaksunlight", 0.9 );
		else if ( getDvar( "mapname" ) == "mp_bog" )
			self setClientDvar( "r_lighttweaksunlight", 0.8 );
		else if ( getDvar( "mapname" ) == "mp_broadcast" )
			self setClientDvar( "r_lighttweaksunlight", 1.4 );
		else if ( getDvar( "mapname" ) == "mp_carentan" )
			self setClientDvar( "r_lighttweaksunlight", 0.75 );
		else if ( getDvar( "mapname" ) == "mp_cargoship" )
			self setClientDvar( "r_lighttweaksunlight", 1.3 );
		else if ( getDvar( "mapname" ) == "mp_citystreets" )
			self setClientDvar( "r_lighttweaksunlight", 0.78 );
		else if ( getDvar( "mapname" ) == "mp_convoy" )
			self setClientDvar( "r_lighttweaksunlight", 1.6 );
		else if ( getDvar( "mapname" ) == "mp_countdown" )
			self setClientDvar( "r_lighttweaksunlight", 1.5 );
		else if ( getDvar( "mapname" ) == "mp_crash" )
			self setClientDvar( "r_lighttweaksunlight", 1.3 );
		else if ( getDvar( "mapname" ) == "mp_crash_snow" )
			self setClientDvar( "r_lighttweaksunlight", 0.25 );
		else if ( getDvar( "mapname" ) == "mp_creek" )
			self setClientDvar( "r_lighttweaksunlight", 1.5 );
		else if ( getDvar( "mapname" ) == "mp_crossfire" )
			self setClientDvar( "r_lighttweaksunlight", 1 );
		else if ( getDvar( "mapname" ) == "mp_farm" )
			self setClientDvar( "r_lighttweaksunlight", 1 );
		else if ( getDvar( "mapname" ) == "mp_killhouse" )
			self setClientDvar( "r_lighttweaksunlight", 1.5 );
		else if ( getDvar( "mapname" ) == "mp_overgrown" )
			self setClientDvar( "r_lighttweaksunlight", 1.1 );
		else if ( getDvar( "mapname" ) == "mp_pipeline" )
			self setClientDvar( "r_lighttweaksunlight", 1.15 );
		else if ( getDvar( "mapname" ) == "mp_shipment" )
			self setClientDvar( "r_lighttweaksunlight", 1.3 );
		else if ( getDvar( "mapname" ) == "mp_showdown" )
			self setClientDvar( "r_lighttweaksunlight", 1.6 );
		else if ( getDvar( "mapname" ) == "mp_strike" )
			self setClientDvar( "r_lighttweaksunlight", 1 );
		else if ( getDvar( "mapname" ) == "mp_vacant" )
			self setClientDvar( "r_lighttweaksunlight", 1.3 );
		else
			self setClientDvar( "r_lighttweaksunlight", 1.2 );

		self setClientDvar( "sunlight", "Stock" );
	}
	else
		self setClientDvars( "r_lighttweaksunlight", 0,
							 "sunlight", "Off" );

	if ( !self.pers["PROMOD_CACHE_FOVSCALE"] )
		self setClientDvar( "cg_fovscale", 1.125 );
	else
		self setClientDvar( "cg_fovscale", 1 );

	if ( !self.pers["PROMOD_CACHE_GFXBLUR"] )
		self setClientDvar( "r_blur", 0 );
	else if ( self.pers["PROMOD_CACHE_GFXBLUR"] == 1 )
		self setClientDvar( "r_blur", 0.2 );
	else if ( self.pers["PROMOD_CACHE_GFXBLUR"] == 2 )
		self setClientDvar( "r_blur", 0.4 );
	else if ( self.pers["PROMOD_CACHE_GFXBLUR"] == 3 )
		self setClientDvar( "r_blur", 0.6 );
	else if ( self.pers["PROMOD_CACHE_GFXBLUR"] == 4 )
		self setClientDvar( "r_blur", 0.8 );
	else if ( self.pers["PROMOD_CACHE_GFXBLUR"] == 5 )
		self setClientDvar( "r_blur", 1 );

	if ( !self.pers["PROMOD_CACHE_FIRSTTIME"] )
	{
		self.pers["PROMOD_CACHE_FIRSTTIME"] = 1;
		self setClientDvar( "cg_voiceIconSize", 1 );
		self set_config( "PROMOD_FIRSTTIME", 1 );
	}

	self setClientDvars(
	"aim_automelee_enabled", 0,
	"aim_automelee_range", 0,
	"dynent_active", 0,
	"snaps", 30,
	"cg_nopredict", 0,
	"sm_enable", 0,
	"r_dlightlimit", 0,
	"r_lodscalerigid", 1,
	"r_lodscaleskinned", 1,
	"cg_drawcrosshairnames", 0,
	"cg_viewzsmoothingmin", 1,
	"cg_viewzsmoothingmax", 16,
	"cg_viewzsmoothingtime", 0.1,
	"cg_huddamageiconheight", 64,
	"cg_huddamageiconwidth", 128,
	"r_filmtweakinvert", 0,
	"r_desaturation", 0,
	"r_specularcolorscale", 0,
	"fx_drawclouds", 0,
	"r_fog", 0,
	"developer", 0,
	"r_normalmap", self.pers["PROMOD_CACHE_NORMALMAP"],
	"r_texfilterdisable", self.pers["PROMOD_CACHE_TEXTURE"],
	"r_filmusetweaks", self.pers["PROMOD_CACHE_FILMTWEAK"] );
}