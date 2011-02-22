/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	if ( (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match") || getDvar("promod_mc_enable") == "" || getDvarInt("promod_mc_enable") < 1 )
		return;

	if (getDvarInt("promod_mc_rs_every_round") )
		setDvar("mc_current_msg", "0");

	if (getDvar("mc_current_msg") == "")
		setDvar("mc_current_msg", "0");

	Run_Messages();
}

Run_Messages()
{
	level endon("mc_restart");

	if(getDvar("promod_mc_delay") == "")
		setDvar("promod_mc_delay", "20");
	generic_delay = 20;

	if (getDvar("promod_mc_maxmessages") == "")
		setDvar("promod_mc_maxmessages" , 20);

	for(;;)
	{
		max = getDvarInt("promod_mc_maxmessages") +1;

		last_message = getDvarInt("mc_current_msg");

		for (i=last_message;i<max;i++)
		{
			if (getDvar("promod_mc_message_" + i) == "")
			{
				wait 0.05;
				continue;
			}
			else
			{
				message = getDvar("promod_mc_message_" + i);

				if (getDvar("promod_mc_messagedelay_" +i) == "")
				{
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

				if (message == "<*nextmap*>")
					message = Get_Next_Map();

				if (!isDefined(message))
				{
					wait 0.05;
					continue;
				}

				wait delay;

				iprintln(message);

				next_msg = i+1;
				setDvar("mc_current_msg", next_msg);
			}
		}

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

Get_Next_Map()
{
	maprot = "";

	maprot = strip(getDvar("sv_maprotationcurrent"));

	if(maprot == "")
		maprot = strip(getDvar("sv_maprotation"));

	if(maprot == "")
		return undefined;

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

	nextmap = "^3Next Map: ^2" + map + " (" + gt + ")";

	return nextmap;
}

strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	if(i==s.size)
		return "";

	for(;i<s.size;i++)
		s2 += s[i];

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
		s3 += s2[j];

	return s3;
}