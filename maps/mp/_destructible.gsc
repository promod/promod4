/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	filename = "promod/destructible.csv";
	level.destructible_effects = [];
	for(i=0;i<8;i++)
		level.destructible_effects[tablelookup(filename, 0, i, 1)] = LoadFX(tablelookup(filename, 0, i, 2));

	level.destructible_breakable_objects = [];
	for(i=8;i<22;i++)
		level.destructible_breakable_objects[tablelookup(filename, 0, i, 1)] = 1;

	entities = getentarray("destructible", "targetname");
	for(i=0;i<entities.size;i++)
		entities[i] thread dmg();
}

dmg()
{
	self endon("explosion");

	dt = self.destructible_type;
	precachemodel(dt+"_destroyed");
	precachemodel(dt+"_mirror_R");
	precachemodel(dt+"_mirror_L");

	// Hide damaged parts
	mdl = self.model;
	np = getnumparts(mdl);
	while(np)
	{
		np--;
		pn = getpartname(mdl, np);
		if(isdefined(pn) && getsubstr(pn, pn.size-2) == "_d")
			self hidepart(pn);
	}

	self setcandamage(1);
	self.damageTaken = 0;
	self.damageOwner = undefined;
	smk = true;
	brn = true;
	self thread explosion();

	for(;;)
	{
		self waittill("damage", damage, attacker, direction_vec, point, type, modelname, tagname, partname);

		if(isdefined(damage) && isdefined(partname) && partname != "left_wheel_01_jnt" && partname != "right_wheel_01_jnt" && partname != "left_wheel_02_jnt" && partname != "right_wheel_02_jnt")
		{
			if(isdefined(level.destructible_breakable_objects[partname]))
				self breakpart(partname);
			else if(type != "MOD_MELEE" && type != "MOD_IMPACT")
			{
				if(type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" || type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" || type == "MOD_EXPLOSIVE")
				{
					numparts = getnumparts(mdl);
					closest = undefined;
					distance = distance(point, self.origin);
					for(i=0;i<numparts;i++)
					{
						part = getpartname(mdl, i);
						dist = distance(point, self gettagorigin(part));
						if(dist <= 256 && isdefined(level.destructible_breakable_objects[part]))
							self breakpart(part);

						if(!isdefined(closest) || dist < closest)
							closest = dist;

						if((isSubStr(part, "tag_hood") || isSubStr(part, "tag_trunk") || isSubStr(part, "tag_door_") || isSubStr(part, "tag_bumper_")) && dist < distance)
							distance = dist;
					}
					if(!isdefined(closest))
						closest = distance;

					damage = int(11 * damage - 5.6 * distance + 4 * closest);
				}

				if(damage > 0)
				{
					self.damageOwner = attacker;
					self.damageTaken += damage;
				}
			}
		}

		if(self.damageTaken > 250 && smk)
		{
			smk = false;
			self thread smoke();
		}
		if(self.damageTaken > 550 && brn)
		{
			brn = false;
			self thread burn();
		}
	}
}

breakpart(partname)
{
	switch(partname)
	{
		case "tag_glass_left_front":
		case "tag_glass_right_front":
		case "tag_glass_left_back":
		case "tag_glass_right_back":
		case "tag_glass_front":
		case "tag_glass_back":
		case "tag_glass_left_back2":
		case "tag_glass_right_back2":
			self playsound("veh_glass_break_large");
			fx = "medium";
			if(strtok(partname, "_").size == 3)
				fx = "large";
			playfxontag(level.destructible_effects["car_glass_"+fx], self, partname+"_fx");
			self hidepart(partname);
			break;
		case "tag_light_left_front":
		case "tag_light_right_front":
		case "tag_light_left_back":
		case "tag_light_right_back":
			self playsound("veh_glass_break_small");
			playfxontag(level.destructible_effects["light_"+strtok(partname, "_")[3]], self, partname);
			self hidepart(partname);
			self showpart(partname+"_d");
			break;
		case "tag_mirror_left":
		case "tag_mirror_right":
			self hidepart(partname);
			physicsobject = spawn("script_model", self gettagorigin(partname));
			physicsobject.angles = self gettagangles(partname);
			s = "R";
			if(getsubstr(partname, 11, 12) == "l") s = "L";
			physicsobject setmodel(self.destructible_type+"_mirror_"+s);
			physicsobject physicslaunch(self gettagorigin(partname), vectornormalize(self gettagorigin(partname)) * 200);
			physicsobject thread deleteovertime();
			break;
	}
}

deleteovertime()
{
	wait 5;
	self delete();
}

smoke()
{
	self endon("explosion");

	for(fx="white_smoke";;)
	{
		if(self.damageTaken > 550)
			fx = "black_smoke_fire";
		else if(self.damageTaken > 450)
			fx = "black_smoke";

		playfxontag(level.destructible_effects[fx], self, "tag_hood_fx");
		wait 0.4;
	}
}

burn()
{
	self endon("explosion");

	self playsound("fire_vehicle_flareup_med");
	self playloopsound("fire_vehicle_med");

	for(;self.damageTaken < 1250;wait 0.2)
		self.damageTaken += 12;
}

explosion()
{
	while(self.damageTaken < 1250)
		wait 0.05;

	self stoploopsound("fire_vehicle_med");

	self notify("explosion");

	self playsound("car_explode");
	playfxontag(level.destructible_effects["small_vehicle_explosion"], self, "tag_death_fx");
	origin = self.origin+(0, 0, 80);
	rng = 250;
	if(getsubstr(self.destructible_type, 0, 19) == "vehicle_80s_sedan1_")
		rng = 375;
	if(isdefined(self.damageOwner))
		self radiusdamage(origin, rng, 300, 20, self.damageOwner);
	else
		self radiusdamage(origin, rng, 300, 20);

	self movez(16, 0.3, 0, 0.2);
	self rotatepitch(10, 0.3, 0, 0.2);
	self setmodel(self.destructible_type+"_destroyed");
	wait 0.3;
	self movez(-16, 0.3, 0.15, 0);
	self rotatepitch(-10, 0.3, 0.15, 0);
}