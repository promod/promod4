/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	if ( getDvar( "promod_enable_scorebot" ) == "" )
		setDvar( "promod_enable_scorebot", 0 );

	level.scorebot = getDvarInt( "promod_enable_scorebot" ) && isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" && level.teambased;

	if ( level.scorebot )
	{
		thread updateTimer();
		thread actionTicker();
	}
}

updateTimer()
{
	if ( !isDefined( game["prevtime"] ) )
		game["prevtime"] = gettime();

	for(;;)
	{
		game["passedtime"] = gettime() - game["prevtime"];
		if ( game["passedtime"] >= 10000 )
		{
			level notify("update_ticker");
			game["prevtime"] = gettime();
		}

		wait 0.05;
	}
}

actionTicker()
{
	while ( !isDefined( game["promod_scorebot_attack_ticker_buffer"] ) || !isDefined( game["promod_scorebot_defence_ticker_buffer"] ) )
		wait 0.05;

	setDvar( "__promod_attack_score", game["promod_scorebot_attack_ticker_buffer"], true );
	setDvar( "__promod_defence_score", game["promod_scorebot_defence_ticker_buffer"], true );
	setDvar( "__promod_mode", toLower( getDvar( "promod_mode" ) ), true );
	setDvar( "__promod_ticker", getDvar( "__promod_ticker" ), true );
	setDvar( "__promod_version", "Promod LIVE V2.20 EU", true );

	for(;;)
	{
		level waittill( "update_ticker" );

		num = getDvarInt( "promod_scorebot_ticker_num" ) + 1;

		if ( num == 10 )
			num = 0;

		setDvar( "promod_scorebot_ticker_num", num );

		if ( isDefined( game["promod_scorebot_ticker_buffer"] ) )
		{
			setDvar( "__promod_ticker", game["promod_scorebot_ticker_buffer"], true );
			setDvar( "__promod_attack_score", game["promod_scorebot_attack_ticker_buffer"], true );
			setDvar( "__promod_defence_score", game["promod_scorebot_defence_ticker_buffer"], true );
			game["promod_scorebot_ticker_buffer"] = num;
		}
	}
}