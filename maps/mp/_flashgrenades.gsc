/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	precacheShellshock("flashbang");
}

startMonitoringFlash()
{
	self thread monitorFlash();
}

stopMonitoringFlash(disconnected)
{
	self notify("stop_monitoring_flash");
}

flashRumbleLoop( duration )
{
	self endon("stop_monitoring_flash");

	self endon("flash_rumble_loop");
	self notify("flash_rumble_loop");

	goalTime = getTime() + duration * 1000;

	while ( getTime() < goalTime )
	{
		self PlayRumbleOnEntity( "damage_heavy" );
		wait 0.05;
	}
}

monitorFlash()
{
	self endon("disconnect");

	self.flashEndTime = 0;
	for(;;)
	{
		self waittill( "flashbang", amount_distance, amount_angle, attacker );

		if ( !isalive( self ) || ( isDefined( level.rdyup ) && level.rdyup && ( !isDefined( self.ruptally ) || self.ruptally < 0 ) ) || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" && isDefined( self.flying ) && self.flying || isDefined( game["PROMOD_KNIFEROUND"] ) && game["PROMOD_KNIFEROUND"] )
			continue;

		hurtattacker = false;
		hurtvictim = true;

		if ( amount_angle < 0.35 )
			amount_angle = 0.35;
		else if ( amount_angle > 0.8 )
			amount_angle = 1;

		duration = amount_distance * amount_angle * 6;

		if ( duration < 0.25 )
			continue;

		rumbleduration = undefined;
		if ( duration > 2 )
			rumbleduration = 0.75;
		else
			rumbleduration = 0.25;

		if (level.teamBased && isdefined(attacker) && isdefined(attacker.pers["team"]) && isdefined(self.pers["team"]) && attacker.pers["team"] == self.pers["team"] && attacker != self)
		{
			if(!level.friendlyfire)
				continue;
			else if(level.friendlyfire == 2)
			{
				duration = duration * 0.5;
				rumbleduration = rumbleduration * 0.5;
				hurtvictim = false;
				hurtattacker = true;
			}
			else if(level.friendlyfire == 3)
			{
				duration = duration * 0.5;
				rumbleduration = rumbleduration * 0.5;
				hurtattacker = true;
			}
		}

		if (hurtvictim)
			self thread applyFlash(duration, rumbleduration);
		if (hurtattacker)
			attacker thread applyFlash(duration, rumbleduration);
	}
}

applyFlash(duration, rumbleduration)
{
	if ( !isDefined( self.flashDuration ) || duration > self.flashDuration )
	{
		self notify ("strongerFlash");
		self.flashDuration = duration;
	}
	else if( duration < self.flashDuration )
		return;

	if ( !isDefined( self.flashRumbleDuration ) || rumbleduration > self.flashRumbleDuration )
		self.flashRumbleDuration = rumbleduration;

	wait 0.05;

	if ( isDefined( self.flashDuration ) )
	{
		self shellshock( "flashbang", self.flashDuration);
		self.flashEndTime = getTime() + (self.flashDuration * 1000);
	}

	self thread overlapProtect(duration);

	if ( isDefined( self.flashRumbleDuration ) )
		self thread flashRumbleLoop( self.flashRumbleDuration );

	self.flashRumbleDuration = undefined;
}

overlapProtect(duration)
{
	self endon( "disconnect" );
	self endon ( "strongerFlash" );
	for(;duration > 0;)
	{
		duration -= 0.05;
		self.flashDuration = duration;
		wait 0.05;
	}
}

isFlashbanged()
{
	return isDefined( self.flashEndTime ) && gettime() < self.flashEndTime;
}