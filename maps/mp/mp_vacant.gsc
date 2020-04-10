/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
    maps\mp\_load::main();
    maps\mp\_compass::setupMiniMap("compass_map_mp_vacant");

    game["allies"] = "sas";
    game["axis"] = "russian";
    game["attackers"] = "allies";
    game["defenders"] = "axis";
    game["allies_soldiertype"] = "woodland";
    game["axis_soldiertype"] = "woodland";

    level.sunlight = 1.3;
}
