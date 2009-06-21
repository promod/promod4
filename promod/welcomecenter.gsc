/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

/*
Dvar List:
pam_welcomecenter_enable
pam_wc_line1
pam_wc_line2
pam_wc_line3
pam_wc_line4
pam_wc_line5
*/
main()
{
	if (getDvar("pam_welcomecenter_enable") == "" || getDvarInt("pam_welcomecenter_enable") < 1)
		return;

	//Verify there are welcome center messages
	exists = Verify_Messages();
	if (!exists)
	{
		setDvar("pam_welcomecenter_enable", 0);
		iprintln("^1Welcome Center Disabled: ^3No Welcome Messages");
		return;
	}

	level thread onPlayerConnect();
}

Verify_Messages()
{
	exists = false;
	if (getDvar("pam_wc_line1") != "" || getDvar("pam_wc_line2") != "" || getDvar("pam_wc_line3") != "" || getDvar("pam_wc_line4") != "" || getDvar("pam_wc_line5") != "")
		exists = true;

	return exists;
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		if (!isdefined(player.pers["welcomed"]))
			player thread onPlayerSpawned();
		else
			return;
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		self thread Welcome_Me();
	}
}

Welcome_Me()
{
	self endon("disconnect");

	self waittill("spawned");

	while (self.pers["team"] == "spectator" || !isDefined(self.pers["weapon"]))
		wait .5;

	// Do Welcome Messages
	for (i=1; i<6; i++)
	{
		message = getDvar("pam_wc_line" +i);
		self iprintlnbold(message);
		wait .05;
	}

	// Prevent from welcoming twice
	self.pers["welcomed"] = true;
}