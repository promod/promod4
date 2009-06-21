/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" )
		return;

	// Continuous Message Center
	if (getDvar("promod_messagecenter_enable") == "" || getDvarInt("promod_messagecenter_enable") < 1)
		return;

	if (getDvarInt("promod_mc_restart_every_round") )
		setDvar("mc_current_msg", "0");

	if (getDvar("mc_current_msg") == "")
		setDvar("mc_current_msg", "0");

	Run_Messages();
}

Run_Messages()
{
	level endon("mc_restart");

	// Set up Generic timer
	if(getDvar("promod_mc_delay") == "")
		setDvar("promod_mc_delay", "20");
	generic_delay = 20;

	//Check to see if max messages is set, if not default to 20
	if (getDvar("promod_mc_maxmessages") == "")
		setDvar("promod_mc_maxmessages" , 20);

	while (1)
	{
		// Set up Maximum Messages
		max = getDvarInt("promod_mc_maxmessages") +1;

		last_message = getDvarInt("mc_current_msg");

		// Run Through Possible Messages
		for (i=last_message;i<max;i++)
		{
			// No message, continue looking
			if (getDvar("promod_mc_message_" + i) == "")
			{
				wait .05;
				continue;
			}
			else
			{
				// Found Message, set it up for display
				message = getDvar("promod_mc_message_" + i);

				//First check for message specific timer
				if (getDvar("promod_mc_messagedelay_" +i) == "")
				{
					// No message specific timer, use generic timer
					if (generic_delay != getDvarInt("promod_mc_delay"))
					{
						generic_delay = getDvarInt("promod_mc_delay");
						if (generic_delay < 5)
						{
							setDvar("promod_mc_delay" , "5");
							generic_delay = 5;
						}
					}

					delay = generic_delay;
				}
				else
				{
					delay = getDvarInt("promod_mc_messagedelay_" +i);
					if (delay < 0)
						delay = 0;
				}

				//Lets see if this is a SPECIAL message
				if (message == "<*nextmap*>")
					message = Get_Next_Map();
				else if (message == "<*gtrules*>")
					message = GameTypeRules();


				if (!isDefined(message))
				{
					wait .05;
					continue;
				}

				// Run Timer
				wait delay;

				iprintln(message);

				next_msg = i+1;
				setDvar("mc_current_msg", next_msg);
			}
		}

		// Reset Message Loop
		setDvar("mc_current_msg", "0");

		loopdelay = getDvarInt("promod_mc_loopdelay");
		if (loopdelay < 5)
		{
			setDvar("promod_mc_loopdelay" , "5");
			loopdelay = 5;
		}

		wait loopdelay;
	}
}

GameTypeRules()
{
	if (!isdefined(level.gametype) || level.gametype == "")
		return undefined;

	message = getDvar("promod_mc_rules_" + level.gametype);

	if (message == "")
		return undefined;
	else
		return message;
}

Get_Next_Map()
{
	maprot = "";

	// Get current maprotation
	maprot = strip(getDvar("sv_maprotationcurrent"));

	// Get maprotation if current empty or not the one we want
	if(maprot == "")
		maprot = strip(getDvar("sv_maprotation"));

	// No map rotation setup!
	if(maprot == "")
		return undefined;

	// Explode entries into an array
	j=0;
	temparr2[j] = "";
	for(i=0;i<maprot.size;i++)
	{
		if(maprot[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	map = undefined;
	gt = undefined;

	for(i=0;i<temparr2.size;i++)
	{
		if (isDefined(map))
			break;

		if (temparr2[i] == "gametype")
		{
			n = temparr2.size - i;
			for (x=1;x<n ;x++ )
			{
				if (temparr2[i+x] != " ")
					gt = temparr2[i+x];
					break;
			}
		}
		else if (temparr2[i] == "map")
		{
			n = temparr2.size - i;
			for (x=1;x<n ;x++ )
			{
				if (temparr2[i+x] != " ")
				{
					map = temparr2[i+x];
					break;
				}
			}
		}
	}

	if (!isdefined(map))
		return undefined;

	if (!isdefined(gt))
		gt = getDvar("g_gametype");

	//Construct string
	nextmap = "^3Next Map: ^2" + map + " (" + gt + ")";

	return nextmap;
}

////////////////////////////////////////////////////////////////////
/* BELOW CODE ORIGINALLY FROM CODAM AND/OR AWE FOR COD AND COD:UO */
////////////////////////////////////////////////////////////////////

// Strip blanks at start and end of string
strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";

	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}

	return s3;
}