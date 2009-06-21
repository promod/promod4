/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	if ( getDvarInt( "promod_enable_scorebot" ) != 1 || level.gametype != "sd" )
	{
		level.scorebot = false;
		game["promod_scorebot_ticker_buffer"] = "";
		return;
	}

	level.scorebot = true;

	level thread Update_Timer();
	level thread Action_Ticker();
}

Update_Timer()
{
	wait .5;

	timer = 10;

	while ( 1 )
	{
		if ( timer > 0)
		{
			wait 1;
			timer = timer - 1;
			continue;
		}

		level notify( "update_ticker" );
		timer = 10;
	}
}

Action_Ticker()
{
	if ( !isDefined( game["ticker_started"] ) )
	{
		game["ticker_started"] = true;
		setDvar( "__promod_ticker", game["promod_scorebot_ticker_buffer"] );
		wait 9;
	}

	wait .5;

	setDvar( "__promod_ticker", game["promod_scorebot_ticker_buffer"] );

	while ( 1 )
	{
		level waittill( "update_ticker" );

		num = getDvarInt( "promod_scorebot_ticker_num" );
		num++;

		if ( num == 10 )
			num = 0;

		setDvar( "promod_scorebot_ticker_num", num );

		waittillframeend;

		setDvar( "__promod_ticker", game["promod_scorebot_ticker_buffer"] );
		game["promod_scorebot_ticker_buffer"] = getDvar( "promod_scorebot_ticker_num" );
	}
}