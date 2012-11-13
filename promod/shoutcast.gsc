/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

addPlayer()
{
	if(isDefined(self.pers["class"]) && !isDefined(self.pers["shoutnum"]) && (self.pers["team"] == "allies" || self.pers["team"] == "axis"))
	{
		offset = int(self.pers["team"] == "axis")*5;
		for(i=0;i<5;i++)
			if(!isDefined(level.shoutbars[i+offset]))
			{
				self.pers["shoutnum"] = i+offset;
				level.shoutbars[self.pers["shoutnum"]] = self;
				self updatePlayer();
				break;
			}
	}
}

removePlayer()
{
	if(isDefined(self.pers["shoutnum"]))
	{
		level.shoutbars[self.pers["shoutnum"]] = undefined;
		self.pers["shoutnum"] = undefined;

		// Find replacements for current slots.
		for(i=0;i<level.players.size;i++)
			level.players[i] addPlayer();

		// pad others to the top
		for(i=0;i<5;i++)
			if(!isDefined(level.shoutbars[i]))
				for(j=i+1;j<5;j++)
					if(isDefined(level.shoutbars[j]))
					{
						level.shoutbars[i] = level.shoutbars[j];
						level.shoutbars[i].pers["shoutnum"] = i;
						level.shoutbars[j] = undefined;
						break;
					}

		for(i=5;i<10;i++)
			if(!isDefined(level.shoutbars[i]))
				for(j=i+1;j<10;j++)
					if(isDefined(level.shoutbars[j]))
					{
						level.shoutbars[i] = level.shoutbars[j];
						level.shoutbars[i].pers["shoutnum"] = i;
						level.shoutbars[j] = undefined;
						break;
					}

		loadAll();
	}
}

updatePlayer()
{
	for(i=0;i<level.players.size;i++)
		if(level.players[i].pers["team"] == "spectator" && isDefined(self.pers["shoutnum"]))
			level.players[i] setClientDvars("shout_name"+self.pers["shoutnum"], self.name,
											"shout_health"+self.pers["shoutnum"], self.health/100);
}

loadAll()
{
	for(i=0;i<level.players.size;i++)
		if(level.players[i].pers["team"] == "spectator")
			level.players[i] loadOne();
}

loadOne()
{
	for(j=0;j<10;j++)
		if(isDefined(level.shoutbars[j]))
			self setClientDvars("shout_name"+j, level.shoutbars[j].name,
								"shout_health"+j, level.shoutbars[j].health/100);
		else
			self setClientDvars("shout_name"+j, "",
								"shout_health"+j, "");
}

followBar(n)
{
	if(isDefined(n) && isDefined(level.shoutbars[n]))
	{
		num = level.shoutbars[n] getEntityNumber();

		if ( num != -1 )
		{
			self.spectatorclient = num;
			self.spectatorlast = num;
			self.freelook = false;
			wait 0.05;
			self.spectatorclient = -1;
		}
	}
}

followClass(class)
{
	if(class == "assault" || class == "specops" || class == "demolitions" || class == "sniper")
	{
		if(!isDefined(self.specpos) || self.specpos > level.players.size)
			self.specpos = 0;

		if(!isDefined(self.followclass))
			self.followclass = [];

		if(self.followclass.size > 0)
		{
			temp = [];
			for(i=0;i<self.followclass.size;i++)
				if(isDefined(self.followclass[i]) && isDefined(self.followclass[i].curClass) && self.followclass[i].curClass == class)
					temp[temp.size] = self.followclass[i];
			self.followclass = temp;
		}

		if(self.followclass.size == 0)
			for(i=0;i<level.players.size;i++)
				if(isDefined(level.players[i].curClass) && level.players[i].curClass == class)
					self.followclass[self.followclass.size] = level.players[i];

		if(self.followclass.size > 0)
		{
			num = self.followclass[self.followclass.size-1] getEntityNumber();
			self.followclass[self.followclass.size-1] = undefined;

			if ( num != -1 )
			{
				self.spectatorclient = num;
				self.spectatorlast = num;
				self.freelook = false;
				wait 0.05;
				self.spectatorclient = -1;
			}
		}
	}
}