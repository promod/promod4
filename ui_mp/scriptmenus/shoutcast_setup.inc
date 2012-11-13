/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#define BACK_OPEN;
#include "ui_mp/navcontrols.inc"

CHOICE_MENU_TITLE( "Shoutcast Setup" )

#undef CHOICE_X_START
#define CHOICE_X_START		-247

#undef CHOICE_HORIZONTAL_ALIGN
#define CHOICE_HORIZONTAL_ALIGN HORIZONTAL_ALIGN_CENTER

CHOICE_BUTTON( 14, "Players...", close self; open shoutcast_setup )
CHOICE_BUTTON( 15, "Binds...", close self; open shoutcast_setup_binds )