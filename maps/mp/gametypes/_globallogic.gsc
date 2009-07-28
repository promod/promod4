/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	if ( !isDefined( level.tweakablesInitialized ) )
		maps\mp\gametypes\_tweakables::init();

	level.splitscreen = 0;
	level.xenon = 0;
	level.ps3 = 0;
	level.console = 0;

	level.onlineGame = false;
	level.rankedMatch = false;

	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );

	level.otherTeam["allies"] = "axis";
	level.otherTeam["axis"] = "allies";

	level.teamBased = false;

	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;

	level.endGameOnScoreLimit = true;
	level.endGameOnTimeLimit = true;

	precacheString( &"MP_HALFTIME" );
	precacheString( &"MP_OVERTIME" );
	precacheString( &"MP_ROUNDEND" );
	precacheString( &"MP_INTERMISSION" );
	precacheString( &"MP_SWITCHING_SIDES" );
	precacheString( &"MP_FRIENDLY_FIRE_WILL_NOT" );
	precacheString( &"MP_CONNECTED" );

	level.halftimeType = "halftime";
	level.halftimeSubCaption = &"MP_SWITCHING_SIDES";

	level.lastStatusTime = 0;
	level.wasWinning = "none";

	level.lastSlowProcessFrame = 0;

	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];

	level.postRoundTime = 5.0;

	level.inOvertime = false;

	level.dropTeam = getdvarint( "sv_maxclients" );
	level.players = [];

	registerDvars();

	level.oldschool = 0;

	precacheModel( "tag_origin" );

	precacheShader( "faction_128_usmc" );
	precacheShader( "faction_128_arab" );
	precacheShader( "faction_128_ussr" );
	precacheShader( "faction_128_sas" );

	if ( !isDefined( game["tiebreaker"] ) )
		game["tiebreaker"] = false;

	promod\promod_modes::main();

	level.hardcoreMode = getDvarInt( "scr_hardcore" );

	if ( level.hardcoreMode )
	{
		logString( "game mode: hardcore" );
		setDvar( "scr_player_maxhealth", "30" );
	}
	else
		setDvar( "scr_player_maxhealth", "100" );
}

registerDvars()
{
	setDvar( "ui_bomb_timer", 0 );
	makeDvarServerInfo( "ui_bomb_timer" );
}

SetupCallbacks()
{
	level.spawnPlayer = ::spawnPlayer;
	level.spawnClient = ::spawnClient;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
	level.onPlayerScore = ::default_onPlayerScore;
	level.onTeamScore = ::default_onTeamScore;

	level.onXPEvent = ::onXPEvent;
	level.waveSpawnTimer = ::waveSpawnTimer;

	level.onSpawnPlayer = ::blank;
	level.onSpawnSpectator = ::default_onSpawnSpectator;
	level.onSpawnIntermission = ::default_onSpawnIntermission;
	level.onRespawnDelay = ::blank;

	level.onTimeLimit = ::default_onTimeLimit;
	level.onScoreLimit = ::default_onScoreLimit;
	level.onDeadEvent = ::default_onDeadEvent;
	level.onOneLeftEvent = ::default_onOneLeftEvent;
	level.giveTeamScore = ::giveTeamScore;
	level.givePlayerScore = ::givePlayerScore;

	level._setTeamScore = ::_setTeamScore;
	level._setPlayerScore = ::_setPlayerScore;

	level._getTeamScore = ::_getTeamScore;
	level._getPlayerScore = ::_getPlayerScore;

	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;

	level.onEndGame = ::blank;

	level.autoassign = ::menuAutoAssign;
	level.spectator = ::menuSpectator;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
}

WaitTillSlowProcessAllowed()
{
	while ( level.lastSlowProcessFrame == gettime() )
		wait .05;

	level.lastSlowProcessFrame = gettime();
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}

default_onDeadEvent( team )
{
	if ( team == "allies" )
	{
		iPrintLn( game["strings"]["allies_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["allies_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["allies_eliminated"] );

		logString( "team eliminated, win: opfor, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "axis", game["strings"]["allies_eliminated"] );
	}
	else if ( team == "axis" )
	{
		iPrintLn( game["strings"]["axis_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["axis_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["axis_eliminated"] );

		logString( "team eliminated, win: allies, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "allies", game["strings"]["axis_eliminated"] );
	}
	else
	{
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["tie"] );
		setDvar( "ui_text_endreason", game["strings"]["tie"] );

		logString( "tie, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		if ( level.teamBased )
			thread endGame( "tie", game["strings"]["tie"] );
		else
			thread endGame( undefined, game["strings"]["tie"] );
	}
}

default_onOneLeftEvent( team )
{
	if ( !level.teamBased )
	{
		winner = getHighestScoringPlayer();

		if ( isDefined( winner ) )
			logString( "last one alive, win: " + winner.name );
		else
			logString( "last one alive, win: unknown" );

		thread endGame( winner, &"MP_ENEMIES_ELIMINATED" );
	}
}

default_onTimeLimit()
{
	winner = undefined;

	if ( level.teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";

		logString( "time limit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();

		if ( isDefined( winner ) )
			logString( "time limit, win: " + winner.name );
		else
			logString( "time limit, tie" );
	}

	makeDvarServerInfo( "ui_text_endreason", game["strings"]["time_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );

	thread endGame( winner, game["strings"]["time_limit_reached"] );
}

default_onScoreLimit()
{
	if ( !level.endGameOnScoreLimit )
		return;

	winner = undefined;

	if ( level.teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
		logString( "scorelimit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "scorelimit, win: " + winner.name );
		else
			logString( "scorelimit, tie" );
	}

	makeDvarServerInfo( "ui_text_endreason", game["strings"]["score_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["score_limit_reached"] );

	level.forcedEnd = true;
	thread endGame( winner, game["strings"]["score_limit_reached"] );
}

updateGameEvents()
{
	if ( !level.numLives && !level.inOverTime )
		return;

	if ( level.inGracePeriod )
		return;

	if ( level.teamBased )
	{
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["allies"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && !level.playerLives["allies"] )
		{
			[[level.onDeadEvent]]( "allies" );
			return;
		}

		if ( level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "axis" );
			return;
		}

		if ( level.lastAliveCount["allies"] > 1 && level.aliveCount["allies"] == 1 && level.playerLives["allies"] == 1 )
		{
			[[level.onOneLeftEvent]]( "allies" );
			return;
		}

		if ( level.lastAliveCount["axis"] > 1 && level.aliveCount["axis"] == 1 && level.playerLives["axis"] == 1 )
		{
			[[level.onOneLeftEvent]]( "axis" );
			return;
		}
	}
	else
	{
		if ( (!level.aliveCount["allies"] && !level.aliveCount["axis"]) && (!level.playerLives["allies"] && !level.playerLives["axis"]) && level.maxPlayerCount > 1 )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		if ( (level.aliveCount["allies"] + level.aliveCount["axis"] == 1) && (level.playerLives["allies"] + level.playerLives["axis"] == 1) && level.maxPlayerCount > 1 )
		{
			[[level.onOneLeftEvent]]( "all" );
			return;
		}
	}
}

matchStartTimer()
{
	visionSetNaked( "mpIntro", 0 );

	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer setTimer( level.prematchPeriod );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;

	if ( level.prematchPeriodEnd > 0 && !game["promod_do_readyup"])
	{
		matchStartText setText( game["strings"]["match_starting_in"] );
		matchStartTimer setTimer( level.prematchPeriodEnd );

		wait level.prematchPeriodEnd;
	}

	visionSetNaked( getDvar( "mapname" ), 2.0 );

	matchStartText destroyElem();
	matchStartTimer destroyElem();
}

matchStartTimerSkip()
{
	visionSetNaked( getDvar( "mapname" ), 0 );
}

spawnPlayer()
{
	prof_begin( "spawnPlayer_preUTS" );

	self endon("disconnect");
	self endon("joined_spectators");
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();

	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
	if ( isDefined( self.xpBar ) )
		self.xpBar destroyElem();

	if ( level.teamBased )
		self.sessionteam = self.team;
	else
		self.sessionteam = "none";

	hadSpawned = self.hasSpawned;

	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;

	self.maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );
	self.health = self.maxhealth;
	self.friendlydamage = undefined;
	self.hasSpawned = true;
	self.spawnTime = getTime();
	self.afk = false;
	if ( self.pers["lives"] )
		self.pers["lives"]--;

	if ( !self.wasAliveAtMatchStart )
	{
		acceptablePassedTime = 20;
		if ( level.timeLimit > 0 && acceptablePassedTime < level.timeLimit * 60 / 4 )
			acceptablePassedTime = level.timeLimit * 60 / 4;

		if ( level.inGracePeriod || getTimePassed() < acceptablePassedTime * 1000 )
			self.wasAliveAtMatchStart = true;
	}

	[[level.onSpawnPlayer]]();

	prof_end( "spawnPlayer_preUTS" );

	level thread updateTeamStatus();

	prof_begin( "spawnPlayer_postUTS" );

	assert( isValidClass( self.class ) );
	self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );

	if ( level.inPrematchPeriod && game["promod_do_readyup"])
	{
		self freezeControls( true );
		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
	}
	else if ( level.inPrematchPeriod )
	{
		self freezeControls( true );

		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );

		team = self.pers["team"];

		thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team] );
	}
	else
	{
		self freezeControls( false );
		self enableWeapons();
		if ( !hadSpawned && isDefined( game["state"] ) && game["state"] == "playing" )
		{
			team = self.team;
			thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team] );
			self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
		}
	}

	prof_end( "spawnPlayer_postUTS" );

	waittillframeend;
	self notify( "spawned_player" );

	self logstring( "S " + self.origin[0] + " " + self.origin[1] + " " + self.origin[2] );

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	{
		assert( !level.intermission );
		self freezePlayerForRoundEnd();
	}

	waittillframeend;

	self.statusicon = "";

	axisNum = 0;
	alliesNum = 0;
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( player.pers["team"] == "axis" )
		{
			axisNum++;
			player.shoutNumber = axisNum;
		}
		else if( player.pers["team"] == "allies" )
		{
			alliesNum++;
			player.shoutNumber = alliesNum;
		}
	}

	self thread promod\shoutcast::updateHealthbar();
}

spawnSpectator( origin, angles )
{
	self notify("spawned");
	self notify("end_respawn");
	in_spawnSpectator( origin, angles );
}

respawn_asSpectator( origin, angles )
{
	in_spawnSpectator( origin, angles );
}

in_spawnSpectator( origin, angles )
{
	self setSpawnVariables();

	if ( self.pers["team"] == "spectator" )
		self clearLowerMessage();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";

	maps\mp\gametypes\_spectating::setSpectatePermissions();

	[[level.onSpawnSpectator]]( origin, angles );

	level thread updateTeamStatus();
}

getPlayerFromClientNum( clientNum )
{
	if ( clientNum < 0 )
		return undefined;

	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i] getEntityNumber() == clientNum )
			return level.players[i];
	}
	return undefined;
}

waveSpawnTimer()
{
	level endon( "game_ended" );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		time = getTime();

		if ( time - level.lastWave["allies"] > (level.waveDelay["allies"] * 1000) )
		{
			level notify ( "wave_respawn_allies" );
			level.lastWave["allies"] = time;
			level.wavePlayerSpawnIndex["allies"] = 0;
		}

		if ( time - level.lastWave["axis"] > (level.waveDelay["axis"] * 1000) )
		{
			level notify ( "wave_respawn_axis" );
			level.lastWave["axis"] = time;
			level.wavePlayerSpawnIndex["axis"] = 0;
		}

		wait ( 0.05 );
	}
}

default_onSpawnSpectator( origin, angles)
{
	if( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn(origin, angles);
		return;
	}

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	assert( spawnpoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self spawn(spawnpoint.origin, spawnpoint.angles);
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();

	self clearLowerMessage();

	self freezeControls( false );

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	[[level.onSpawnIntermission]]();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}

default_onSpawnIntermission()
{
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = spawnPoints[0];

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

timeUntilRoundEnd()
{
	if ( level.gameEnded )
	{
		timePassed = (getTime() - level.gameEndTime) / 1000;
		timeRemaining = level.postRoundTime - timePassed;

		if ( timeRemaining < 0 )
			return 0;

		return timeRemaining;
	}

	if ( level.inOvertime )
		return undefined;

	if ( level.timeLimit <= 0 )
		return undefined;

	if ( !isDefined( level.startTime ) )
		return undefined;

	timePassed = (getTime() - level.startTime)/1000;
	timeRemaining = (level.timeLimit * 60) - timePassed;

	return timeRemaining + level.postRoundTime;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();
}

freeGameplayHudElems()
{
	if ( isDefined( self.lowerMessage ) )
		self.lowerMessage destroyElem();
	if ( isDefined( self.lowerTimer ) )
		self.lowerTimer destroyElem();

	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
}

endGame( winner, endReasonText )
{
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

	if ( isDefined( level.onEndGame ) )
		[[level.onEndGame]]( winner );

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" )
		setDvar( "g_deadChat", "1" );

	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;

	level notify ( "game_ended" );

	setGameEndTime( 0 );

	updatePlacement();

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		player freezePlayerForRoundEnd();
		player thread roundEndDoF( 4.0 );
		player freeGameplayHudElems();
	}

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		winners = "";
		if ( winner == "allies" )
		{
			if ( game["attackers"] == "allies" && game["defenders"] == "axis" )
				winners = "attack";
			else
				winners = "defence";
		}
		else if ( winner == "axis" )
		{
			if ( game["attackers"] == "allies" && game["defenders"] == "axis" )
				winners = "defence";
			else
				winners = "attack";
		}
		else
			winners = "tie";

		attack_score = game["teamScores"]["allies"];
		defence_score = game["teamScores"]["axis"];

		game["promod_scorebot_ticker_buffer"] += "round_winner" + winners + "" + attack_score + "" + defence_score;
	}

	if ( (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) && !level.forcedEnd )
	{
		if ( level.displayRoundEndText )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( level.teamBased )
					player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText, 0.75 );
				else
					player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText, 0.75 );

				if ( isDefined( player.pers["team"] ) && player.pers["team"] == "spectator" )
					continue;

				player setClientDvars( 	"ui_hud_hardcore", 1,
										"cg_drawSpectatorMessages", 0,
										"g_compassShowEnemies", 0 );
			}

			level thread [[level.promod_hud_header_create]]();

			if ( hitRoundLimit() || hitScoreLimit() )
				roundEndWait( level.roundEndDelay / 2 );
			else
				roundEndWait( level.roundEndDelay );
		}

		game["roundsplayed"]++;
		roundSwitching = false;
		if ( !hitRoundLimit() && !hitScoreLimit() )
			roundSwitching = checkRoundSwitch();

		if ( roundSwitching && level.teamBased )
		{
			level.swap_score = true;

			old_score = game["teamScores"]["allies"];
			game["teamScores"]["allies"] = game["teamScores"]["axis"];
			game["teamScores"]["axis"] = old_score;

			game["allies_timeout_called"] = 0;
			game["axis_timeout_called"] = 0;

			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}

				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else
					{
						switchType = "intermission";
					}
				}

				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
				player setClientDvar( "ui_hud_hardcore", 1 );

				if ( player.pers["team"] == "axis" )
				{
					player.switching = true;
					player menuAllies();
				}
				else if( player.pers["team"] == "allies" )
				{
					player.switching = true;
					player menuAxis();
				}
			}

			thread maps\mp\gametypes\_promod::updateClassAvailability( "allies" );
			thread maps\mp\gametypes\_promod::updateClassAvailability( "axis" );

			roundEndWait( level.halftimeRoundEndDelay );
		}
		else if ( !hitRoundLimit() && !hitScoreLimit() && !level.displayRoundEndText && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}

				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "roundend";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchTime = "roundend";
					}
				}

				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, endReasonText );
				player setClientDvar( "ui_hud_hardcore", 1 );
			}

			roundEndWait( level.halftimeRoundEndDelay );
		}

		if ( !hitRoundLimit() && !hitScoreLimit() )
		{
			level notify ( "restarting" );
			game["state"] = "playing";
			map_restart( true );
			return;
		}

		if ( hitRoundLimit() )
			endReasonText = game["strings"]["round_limit_reached"];
		else if ( hitScoreLimit() )
			endReasonText = game["strings"]["score_limit_reached"];
		else
			endReasonText = game["strings"]["time_limit_reached"];
	}

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			attack_score = game["teamScores"]["allies"];
			defence_score = game["teamScores"]["axis"];
		}
		else
		{
			attack_score = game["teamScores"]["axis"];
			defence_score = game["teamScores"]["allies"];
		}

		game["promod_scorebot_ticker_buffer"] += "map_completeattack" + attack_score + "defence" + defence_score;
	}

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
		{
			player [[level.spawnIntermission]]();
			player closeMenu();
			player closeInGameMenu();
			continue;
		}

		if ( level.teamBased )
		{
			winner = getWinningTeam();

			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}
		else
		{
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
		}

		player setClientDvars(	"ui_hud_hardcore", 1,
								"cg_drawSpectatorMessages", 0,
								"g_compassShowEnemies", 0 );
	}

	roundEndWait( level.postRoundTime );

	level.intermission = true;

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread spawnIntermission();
		player setClientDvar( "ui_hud_hardcore", 0 );
	}

	logString( "game ended" );

	wait 4;

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" )
	{
		map_restart( false );
		return;
	}

	exitLevel( false );
}

getWinningTeam()
{
	if ( getGameScore( "allies" ) == getGameScore( "axis" ) )
		winner = "tie";
	else if ( getGameScore( "allies" ) > getGameScore( "axis" ) )
		winner = "allies";
	else
		winner = "axis";

	return winner;
}

roundEndWait( defaultDelay )
{
	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;

			notifiesDone = false;
		}
		wait ( 0.5 );
	}

	wait ( defaultDelay );
}

roundEndDOF( time )
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}

getHighestScoringPlayer()
{
	players = level.players;
	winner = undefined;
	tie = false;

	for( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i].score ) )
			continue;

		if ( players[i].score < 1 )
			continue;

		if ( !isDefined( winner ) || players[i].score > winner.score )
		{
			winner = players[i];
			tie = false;
		}
		else if ( players[i].score == winner.score )
		{
			tie = true;
		}
	}

	if ( tie || !isDefined( winner ) )
		return undefined;
	else
		return winner;
}

checkTimeLimit()
{
	if ( isDefined( level.timeLimitOverride ) && level.timeLimitOverride )
		return;

	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.timeLimit <= 0 )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.inPrematchPeriod )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( !isdefined( level.startTime ) )
		return;

	timeLeft = getTimeRemaining();

	setGameEndTime( getTime() + int(timeLeft) );

	if ( timeLeft > 0 )
		return;

	[[level.onTimeLimit]]();
}

getTimeRemaining()
{
	return level.timeLimit * 60 * 1000 - getTimePassed();
}

checkScoreLimit()
{
	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
		return;

	if ( level.scoreLimit <= 0 )
		return;

	if ( level.teamBased )
	{
		if( game["teamScores"]["allies"] < level.scoreLimit && game["teamScores"]["axis"] < level.scoreLimit )
			return;
	}
	else
	{
		if ( !isPlayer( self ) )
			return;

		if ( self.score < level.scoreLimit )
			return;
	}

	[[level.onScoreLimit]]();
}

hitRoundLimit()
{
	if( level.roundLimit <= 0 )
		return false;

	return ( game["roundsplayed"] >= level.roundLimit );
}

hitScoreLimit()
{
	if( level.scoreLimit <= 0 )
		return false;

	if ( level.teamBased )
	{
		if( game["teamScores"]["allies"] >= level.scoreLimit || game["teamScores"]["axis"] >= level.scoreLimit )
			return true;
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.score ) && player.score >= level.scorelimit )
				return true;
		}
	}
	return false;
}

registerRoundSwitchDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundswitch");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );

	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );

	level.roundswitchDvar = dvarString;
	level.roundswitchMin = minValue;
	level.roundswitchMax = maxValue;
	level.roundswitch = getDvarInt( level.roundswitchDvar );
}

registerRoundLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundlimit");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );

	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );

	level.roundLimitDvar = dvarString;
	level.roundlimitMin = minValue;
	level.roundlimitMax = maxValue;
	level.roundLimit = getDvarInt( level.roundLimitDvar );
}

registerScoreLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_scorelimit");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );

	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );

	level.scoreLimitDvar = dvarString;
	level.scorelimitMin = minValue;
	level.scorelimitMax = maxValue;
	level.scoreLimit = getDvarInt( level.scoreLimitDvar );

	setDvar( "ui_scorelimit", level.scoreLimit );
}

registerTimeLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_timelimit");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );

	if ( getDvarFloat( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarFloat( dvarString ) < minValue )
		setDvar( dvarString, minValue );

	level.timeLimitDvar = dvarString;
	level.timelimitMin = minValue;
	level.timelimitMax = maxValue;
	level.timelimit = getDvarFloat( level.timeLimitDvar );

	setDvar( "ui_timelimit", level.timelimit );
}

registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_numlives");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );

	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );

	level.numLivesDvar = dvarString;
	level.numLivesMin = minValue;
	level.numLivesMax = maxValue;
	level.numLives = getDvarInt( level.numLivesDvar );
}

getValueInRange( value, minValue, maxValue )
{
	if ( value > maxValue )
		return maxValue;
	else if ( value < minValue )
		return minValue;
	else
		return value;
}

updateGameTypeDvars()
{
	level endon ( "game_ended" );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		roundlimit = getValueInRange( getDvarInt( level.roundLimitDvar ), level.roundLimitMin, level.roundLimitMax );
		if ( roundlimit != level.roundlimit )
		{
			level.roundlimit = roundlimit;
			level notify ( "update_roundlimit" );
		}

		timeLimit = getValueInRange( getDvarFloat( level.timeLimitDvar ), level.timeLimitMin, level.timeLimitMax );
		if ( timeLimit != level.timeLimit )
		{
			level.timeLimit = timeLimit;
			setDvar( "ui_timelimit", level.timeLimit );
			level notify ( "update_timelimit" );
		}
		thread checkTimeLimit();

		scoreLimit = getValueInRange( getDvarInt( level.scoreLimitDvar ), level.scoreLimitMin, level.scoreLimitMax );
		if ( scoreLimit != level.scoreLimit )
		{
			level.scoreLimit = scoreLimit;
			setDvar( "ui_scorelimit", level.scoreLimit );
			level notify ( "update_scorelimit" );
		}
		thread checkScoreLimit();

		if ( isdefined( level.startTime ) )
		{
			if ( getTimeRemaining() < 3000 )
			{
				wait .1;
				continue;
			}
		}
		wait 1;
	}
}

menuAutoAssign()
{
	teams[0] = "allies";
	teams[1] = "axis";
	assignment = teams[randomInt(2)];

	self closeMenus();

	if ( level.teamBased )
	{
		playerCounts = self maps\mp\gametypes\_teams::CountPlayers();

		if ( playerCounts["allies"] == playerCounts["axis"] )
		{
			if( getTeamScore( "allies" ) == getTeamScore( "axis" ) )
				assignment = teams[randomInt(2)];
			else if ( getTeamScore( "allies" ) < getTeamScore( "axis" ) )
				assignment = "allies";
			else
				assignment = "axis";
		}
		else if( playerCounts["allies"] < playerCounts["axis"] )
		{
			assignment = "allies";
		}
		else
		{
			assignment = "axis";
		}

		if ( assignment == self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead") )
		{
			self beginClassChoice();
			return;
		}
	}

	if ( assignment != self.pers["team"] && self.sessionstate == "playing" )
	{
		self.switching_teams = true;
		self.joining_team = assignment;
		self.leaving_team = self.pers["team"];
		self suicide();
	}

	oldTeam = self.pers["team"];

	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["team"] = assignment;
	self.team = assignment;
	self.pers["teamTime"] = getTime();
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self setClientDvar(	"loadout_curclass", "" );

	self updateObjectiveText();

	if ( level.teamBased )
		self.sessionteam = assignment;
	else
	{
		self.sessionteam = "none";
	}

	if ( !isAlive( self ) )
		self.statusicon = "hud_status_dead";
	else
		self.statusicon = "";

	self notify("joined_team");
	self notify("end_respawn");

	if( self.pers["team"] == "allies" && oldTeam != self.pers["team"] )
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
			iPrintLN(self.name + " Joined Attack");
		else
			iPrintLN(self.name + " Joined Defence");
	}
	else if( self.pers["team"] == "axis" && oldTeam != self.pers["team"] )
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
			iPrintLN(self.name + " Joined Defence");
		else
			iPrintLN(self.name + " Joined Attack");
	}

	if ( oldTeam != self.pers["team"] && ( self.pers["team"] == "allies" || self.pers["team"] == "axis" ) )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

	self setClientDvars(	"g_compassShowEnemies", "0",
							"r_contrast", "1",
							"r_brightness", "0" );

	self beginClassChoice();

	self setclientdvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );
}

updateObjectiveText()
{
	if ( self.pers["team"] == "spectator" )
	{
		self setClientDvar( "cg_objectiveText", "" );
		return;
	}

	if( level.scorelimit > 0 )
	{
		self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ), level.scorelimit );
	}
	else
	{
		self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers["team"] ) );
	}
}

closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}

beginClassChoice( forceNewChoice )
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];
	self openMenu( game[ "menu_changeclass_" + team ] );
}

menuAllies()
{
	self closeMenus();

	if ( !isDefined( self.switching ) )
		self.switching = false;

	if ( self.pers["team"] != "allies" )
	{
		if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] != "match" )
		{
			if ( level.teamBased && !self.switching && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
			{
				self openMenu(game["menu_team"]);
				return;
			}
		}

		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
			self.hasSpawned = false;

		if( self.sessionstate == "playing" && !self.switching )
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		oldTeam = self.pers["team"];

		if ( self.switching )
		{
			self.pers["team"] = "allies";
			self.team = "allies";
		}
		else
		{
			self.pers["class"] = undefined;
			self.class = undefined;
			self.pers["team"] = "allies";
			self.team = "allies";
			self.pers["teamTime"] = getTime();
			self.pers["weapon"] = undefined;
			self.pers["savedmodel"] = undefined;
			self setClientDvar(	"loadout_curclass", "" );
		}

		self updateObjectiveText();

		if ( level.teamBased )
			self.sessionteam = "allies";
		else
			self.sessionteam = "none";

		self setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);

		self notify("joined_team");
		self notify("end_respawn");

		if( game["attackers"] == "allies" && game["defenders"] == "axis" && !self.switching )
			iprintln(self.name + " Joined Attack");
		else if ( !self.switching )
			iprintln(self.name + " Joined Defence");

		for( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if( player.pers["team"] == "spectator" )
			{
				player thread promod\shoutcast::resetShoutcast();
			}
		}

		if ( oldTeam == "axis" )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

		self setClientDvars(	"g_compassShowEnemies", "0",
								"r_contrast", "1",
								"r_brightness", "0" );
	}

	if ( !self.switching )
		self beginClassChoice();

	self.switching = false;
}

menuAxis()
{
	self closeMenus();

	if ( !isDefined( self.switching ) )
		self.switching = false;

	if ( self.pers["team"] != "axis" )
	{
		if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] != "match" )
		{
			if ( level.teamBased && !self.switching && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
			{
				self openMenu(game["menu_team"]);
				return;
			}
		}

		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
			self.hasSpawned = false;

		if( self.sessionstate == "playing" && !self.switching )
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		oldTeam = self.pers["team"];

		if ( self.switching )
		{
			self.pers["team"] = "axis";
			self.team = "axis";
		}
		else
		{
			self.pers["class"] = undefined;
			self.class = undefined;
			self.pers["team"] = "axis";
			self.team = "axis";
			self.pers["teamTime"] = getTime();
			self.pers["weapon"] = undefined;
			self.pers["savedmodel"] = undefined;
			self setClientDvar(	"loadout_curclass", "" );
		}

		self updateObjectiveText();

		if ( level.teamBased )
			self.sessionteam = "axis";
		else
			self.sessionteam = "none";

		self setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);

		self notify("joined_team");
		self notify("end_respawn");

		if( game["attackers"] == "allies" && game["defenders"] == "axis" && !self.switching )
			iprintln(self.name + " Joined Defence");
		else if ( !self.switching )
			iprintln(self.name + " Joined Attack");

		for( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if( player.pers["team"] == "spectator" )
			{
				player thread promod\shoutcast::resetShoutcast();
			}
		}

		if ( oldTeam == "allies" )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

		self setClientDvars(	"g_compassShowEnemies", "0",
								"r_contrast", "1",
								"r_brightness", "0" );
	}

	if ( !self.switching )
		self beginClassChoice();

	self.switching = false;
}

menuSpectator()
{
	self closeMenus();

	if(self.pers["team"] != "spectator")
	{
		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		oldTeam = self.pers["team"];

		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.pers["teamTime"] = undefined;
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;
		self setClientDvar(	"loadout_curclass", "" );

		self updateObjectiveText();

		self.sessionteam = "spectator";
		[[level.spawnSpectator]]();

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			self setClientDvars(	"shout_scores_attack", game["teamScores"]["allies"],
									"shout_scores_defence", game["teamScores"]["axis"] );
		}
		else
		{
			self setClientDvars(	"shout_scores_attack", game["teamScores"]["axis"],
									"shout_scores_defence", game["teamScores"]["allies"] );
		}

		self setclientdvar( "g_scriptMainMenu", game["menu_shoutcast"] );

		self notify("joined_spectators");
		iprintln(self.name + " Joined Shoutcaster");

		for( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if( player.pers["team"] == "spectator" )
			{
				player thread promod\shoutcast::resetShoutcast();
			}
		}

		if ( oldTeam == "allies" || oldTeam == "axis" )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

		self setClientDvars(	"g_compassShowEnemies", "1",
								"r_contrast", "1",
								"r_brightness", "0" );
	}
}

removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
			found = true;

		if ( found )
			level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
		return;

	level.placement["all"][ numPlayers - 1 ] = undefined;
	assert( level.placement["all"].size == numPlayers - 1 );

	updateTeamPlacement();

	if ( level.teamBased )
		return;

	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}

}

updatePlacement()
{
	prof_begin("updatePlacement");

	if ( !level.players.size )
		return;

	level.placement["all"] = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( level.players[index].team == "allies" || level.players[index].team == "axis" )
			level.placement["all"][level.placement["all"].size] = level.players[index];
	}

	placementAll = level.placement["all"];

	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.score;
		for ( j = i - 1; j >= 0 && (playerScore > placementAll[j].score || (playerScore == placementAll[j].score && player.deaths < placementAll[j].deaths)); j-- )
			placementAll[j + 1] = placementAll[j];
		placementAll[j + 1] = player;
	}

	level.placement["all"] = placementAll;

	updateTeamPlacement();

	prof_end("updatePlacement");
}

updateTeamPlacement()
{
	placement["allies"]		= [];
	placement["axis"]		= [];
	placement["spectator"]	= [];

	if ( !level.teamBased )
		return;

	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;

	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];

		placement[team][ placement[team].size ] = player;
	}

	level.placement["allies"] = placement["allies"];
	level.placement["axis"] = placement["axis"];
}

onXPEvent( event )
{
	self maps\mp\gametypes\_rank::giveRankXP( event );
}

givePlayerScore( event, player, victim )
{
	if ( level.overridePlayerScore )
		return;

	score = player.pers["score"];
	[[level.onPlayerScore]]( event, player, victim );

	if ( score == player.pers["score"] )
		return;

	player.score = player.pers["score"];

	if ( !level.teambased )
		thread sendUpdatedDMScores();

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}

default_onPlayerScore( event, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	assert( isDefined( score ) );

	player.pers["score"] += score;
}

_setPlayerScore( player, score )
{
	if ( score == player.pers["score"] )
		return;

	player.pers["score"] = score;
	player.score = player.pers["score"];

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}

_getPlayerScore( player )
{
	return player.pers["score"];
}

giveTeamScore( event, team, player, victim )
{
	if ( level.overrideTeamScore )
		return;

	teamScore = game["teamScores"][team];
	[[level.onTeamScore]]( event, team, player, victim );

	if ( teamScore == game["teamScores"][team] )
		return;

	updateTeamScores( team );

	thread checkScoreLimit();
}

_setTeamScore( team, teamScore )
{
	if ( teamScore == game["teamScores"][team] )
		return;

	game["teamScores"][team] = teamScore;

	updateTeamScores( team );

	thread checkScoreLimit();
}

updateTeamScores( team1, team2 )
{
	setTeamScore( team1, getGameScore( team1 ) );
	if ( isdefined( team2 ) )
		setTeamScore( team2, getGameScore( team2 ) );

	if ( level.teambased )
		thread sendUpdatedTeamScores();
}

_getTeamScore( team )
{
	return game["teamScores"][team];
}

default_onTeamScore( event, team, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	assert( isDefined( score ) );

	otherTeam = level.otherTeam[team];

	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		level.wasWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		level.wasWinning = otherTeam;

	game["teamScores"][team] += score;

	isWinning = "none";
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		isWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		isWinning = otherTeam;

	if ( isWinning != "none" && isWinning != level.wasWinning && getTime() - level.lastStatusTime > 5000 )
	{
		level.lastStatusTime = getTime();
	}

	if ( isWinning != "none" )
		level.wasWinning = isWinning;
}

sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait .05;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateScores();
	}

	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( player.pers["team"] == "spectator" )
		{
			if( game["attackers"] == "allies" && game["defenders"] == "axis" )
			{
				player setClientDvars(	"shout_scores_attack", game["teamScores"]["allies"],
										"shout_scores_defence", game["teamScores"]["axis"] );
			}
			else
			{
				player setClientDvars(	"shout_scores_attack", game["teamScores"]["axis"],
										"shout_scores_defence", game["teamScores"]["allies"] );
			}
		}
	}

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		if ( !isDefined( level.allies_team ) )
			level.allies_team = "none";
		if ( !isDefined( level.axis_team ) )
			level.axis_team = "none";

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			game["promod_scorebot_attack_ticker_buffer"] = game["teamScores"]["allies"] + level.allies_team;
			game["promod_scorebot_defence_ticker_buffer"] = game["teamScores"]["axis"] + level.axis_team;
		}
		else
		{
			game["promod_scorebot_attack_ticker_buffer"] = game["teamScores"]["axis"] + level.axis_team;
			game["promod_scorebot_defence_ticker_buffer"] = game["teamScores"]["allies"] + level.allies_team;
		}
	}
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait .05;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateDMScores();
		level.players[i].updatedDMScores = true;
	}
}

initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
		self.pers[dataName] = 0;
}

getPersStat( dataName )
{
	return self.pers[dataName];
}

incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;
}

updateTeamStatus()
{
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

	resetTimeout();

	prof_begin( "updateTeamStatus" );

	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;

	level.lastAliveCount["allies"] = level.aliveCount["allies"];
	level.lastAliveCount["axis"] = level.aliveCount["axis"];
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		team = player.team;
		class = player.class;

		if ( team != "spectator" && (isDefined( class ) && class != "") )
		{
			level.playerCount[team]++;

			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;

				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers.size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;
				}
			}
			else
			{
				if ( player maySpawn() )
					level.playerLives[team]++;
			}
		}
	}

	if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
		level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];

	if ( level.aliveCount["allies"] )
		level.everExisted["allies"] = true;
	if ( level.aliveCount["axis"] )
		level.everExisted["axis"] = true;

	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( player.pers["team"] == "allies" || player.pers["team"] == "axis" )
		{
			player setClientDvars( 	"allies_alive", level.aliveCount["allies"],
									"axis_alive", level.aliveCount["axis"] );
		}
	}

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		level.allies_team = "";
		level.axis_team = "";

		for( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( player.pers["team"] == "allies" )
			{
				if ( player.sessionstate == "playing" )
					player_allies_alive = 1;
				else
					player_allies_alive = 0;

				level.allies_team += "" + player.name + "" + player_allies_alive + "" + player.kills + "" + player.assists + "" + player.deaths;
			}
			else if ( player.pers["team"] == "axis" )
			{
				if ( player.sessionstate == "playing" )
					player_axis_alive = 1;
				else
					player_axis_alive = 0;

				level.axis_team += "" + player.name + "" + player_axis_alive + "" + player.kills + "" + player.assists + "" + player.deaths;
			}
		}

		if ( level.allies_team == "" )
			level.allies_team = "none";
		if ( level.axis_team == "" )
			level.axis_team = "none";

		level.allies_string = game["teamScores"]["allies"] + level.allies_team;
		level.axis_string = game["teamScores"]["axis"] + level.axis_team;

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			game["promod_scorebot_attack_ticker_buffer"] = level.allies_string;
			game["promod_scorebot_defence_ticker_buffer"] = level.axis_string;
		}
		else
		{
			game["promod_scorebot_attack_ticker_buffer"] = level.axis_string;
			game["promod_scorebot_defence_ticker_buffer"] = level.allies_string;
		}
	}

	prof_end( "updateTeamStatus" );

	level updateGameEvents();
}

isValidClass( class )
{
	return isdefined( class ) && class != "";
}

playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");
	level endon("game_ended");

	while(1)
	{
		self playSound( "ui_mp_suitcasebomb_timer" );
		wait 1.0;
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon ( "game_ended" );

	wait .05;

	clockObject = spawn( "script_origin", (0,0,0) );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		if ( !level.timerStopped && level.timeLimit )
		{
			timeLeft = getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5);

			if ( timeLeftInt >= 30 && timeLeftInt <= 60 )
				level notify ( "match_ending_soon" );

			if ( timeLeftInt <= 10 || (timeLeftInt <= 30 && timeLeftInt % 2 == 0) )
			{
				level notify ( "match_ending_very_soon" );

				if ( timeLeftInt == 0 )
					break;

				clockObject playSound( "ui_mp_timer_countdown" );
			}

			if ( timeLeft - floor(timeLeft) >= .05 )
				wait timeLeft - floor(timeLeft);
		}

		wait ( 1.0 );
	}
}

gameTimer()
{
	level endon ( "game_ended" );

	level waittill("prematch_over");

	level.startTime = getTime();
	level.discardTime = 0;

	if ( isDefined( game["roundMillisecondsAlreadyPassed"] ) )
	{
		level.startTime -= game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"] = undefined;
	}

	prevtime = gettime();

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		if ( !level.timerStopped )
		{
			game["timepassed"] += gettime() - prevtime;
		}
		prevtime = gettime();
		wait ( 1.0 );
	}
}

getTimePassed()
{
	if ( !isDefined( level.startTime ) )
		return 0;

	if ( level.timerStopped )
		return (level.timerPauseTime	- level.startTime) - level.discardTime;
	else
		return (gettime()				- level.startTime) - level.discardTime;

}

pauseTimer()
{
	if ( level.timerStopped )
		return;

	level.timerStopped = true;
	level.timerPauseTime = gettime();
}

resumeTimer()
{
	if ( !level.timerStopped )
		return;

	level.timerStopped = false;
	level.discardTime += gettime() - level.timerPauseTime;
}

startGame()
{
	level thread [[level.promod_hud_header_create]]();

	thread gameTimer();
	level.timerStopped = true;
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	prematchPeriod();

	if ( isDefined( game["promod_timeout_called"] ) && game["promod_timeout_called"] )
	{
		thread promod\timeout::main();
		return;
	}

	if ( isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"] )
	{
		thread promod\readyup::main();
		return;
	}

	if ( ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" || getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] ) && level.gametype == "sd" )
		promod\strat_time::main();

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "strat" )
	{
		level thread [[level.promod_hud_header_create]]();
		level thread promod\readyup::disableBombsites();
		setDvar( "g_deadChat", "1" );
		return;
	}
	else if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" )
		setDvar( "g_deadChat", "0" );

	if ( isDefined( level.timeout_over ) && !level.timeout_over )
		return;

	level.timerStopped = false;

	level notify("prematch_over");
	level notify("header_destroy");

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		sb_text = "";

		if ( game["roundsplayed"] == 0 && !game["promod_in_timeout"] )
			sb_text = "1st_half_started";
		else if ( isDefined( level.roundswitch ) && level.roundswitch > 0 && game["roundsplayed"] % level.roundswitch == 0 && !game["promod_in_timeout"] )
			sb_text = "2nd_half_started";
		else if ( game["promod_in_timeout"] )
			sb_text = "match_resumed";
		else
			sb_text = "round_start";

		game["promod_scorebot_ticker_buffer"] += "" + sb_text + "" + ( game["roundsplayed"] + 1 );
	}

	game["promod_in_timeout"] = 0;

	thread timeLimitClock();
	thread gracePeriod();
}

prematchPeriod()
{
	makeDvarServerInfo( "ui_hud_hardcore", 1 );
	setDvar( "ui_hud_hardcore", 1 );
	level endon( "game_ended" );

	if ( level.prematchPeriod > 0 )
	{
		matchStartTimer();
	}
	else
	{
		matchStartTimerSkip();
	}

	level.inPrematchPeriod = false;

	for ( index = 0; index < level.players.size; index++ )
	{
		level.players[index] freezeControls( false );
		level.players[index] enableWeapons();

		hintMessage = getObjectiveHintText( level.players[index].pers["team"] );
		if ( !isDefined( hintMessage ) || !level.players[index].hasSpawned )
			continue;

		level.players[index] setClientDvar( "scr_objectiveText", hintMessage );
		level.players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
	}

	setDvar( "ui_hud_hardcore", level.hardcoreMode );
}

gracePeriod()
{
	level endon("game_ended");

	wait ( level.gracePeriod );

	level notify ( "grace_period_ending" );
	wait ( .05 );

	level.inGracePeriod = false;

	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
		return;

	if ( level.numLives )
	{
		players = level.players;

		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) )
				player.statusicon = "hud_status_dead";
		}
	}

	level thread updateTeamStatus();
}

TimeUntilWaveSpawn( minimumWait )
{
	earliestSpawnTime = gettime() + minimumWait * 1000;

	lastWaveTime = level.lastWave[self.pers["team"]];
	waveDelay = level.waveDelay[self.pers["team"]] * 1000;

	numWavesPassedEarliestSpawnTime = (earliestSpawnTime - lastWaveTime) / waveDelay;

	numWaves = ceil( numWavesPassedEarliestSpawnTime );

	timeOfSpawn = lastWaveTime + numWaves * waveDelay;

	if ( isdefined( self.waveSpawnIndex ) )
		timeOfSpawn += 50 * self.waveSpawnIndex;

	return (timeOfSpawn - gettime()) / 1000;
}

TeamKillDelay()
{
	teamkills = self.pers["teamkills"];
	if ( level.minimumAllowedTeamKills < 0 || teamkills <= level.minimumAllowedTeamKills )
		return 0;
	exceeded = (teamkills - level.minimumAllowedTeamKills);
	return maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillspawndelay" ) * exceeded;
}

TimeUntilSpawn( includeTeamkillDelay )
{
	if ( level.inGracePeriod && !self.hasSpawned )
		return 0;

	if ( isDefined( level.rdyup ) && level.rdyup )
		return 0;

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "strat" )
		return 0;

	respawnDelay = 0;
	if ( self.hasSpawned )
	{
		result = self [[level.onRespawnDelay]]();
		if ( isDefined( result ) )
			respawnDelay = result;
		else
		respawnDelay = getDvarInt( "scr_" + level.gameType + "_playerrespawndelay" );

		if ( includeTeamkillDelay && self.teamKillPunish )
			respawnDelay += TeamKillDelay();
	}

	waveBased = (getDvarInt( "scr_" + level.gameType + "_waverespawndelay" ) > 0);

	if ( waveBased )
		return self TimeUntilWaveSpawn( respawnDelay );

	return respawnDelay;
}

maySpawn()
{
	if ( isDefined( level.rdyup ) && level.rdyup )
		return true;

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "strat" )
		return true;

	if ( level.inOvertime )
		return false;

	if ( level.numLives )
	{
		if ( level.teamBased )
			gameHasStarted = ( level.everExisted[ "axis" ] && level.everExisted[ "allies" ] );
		else
			gameHasStarted = (level.maxPlayerCount > 1);

		if ( !self.pers["lives"] && gameHasStarted )
		{
			return false;
		}
		else if ( gameHasStarted )
		{
			if ( !level.inGracePeriod && !self.hasSpawned )
				return false;
		}
	}
	return true;
}

spawnClient( timeAlreadyPassed )
{
	assert(	isDefined( self.team ) );
	assert(	isValidClass( self.class ) );

	if ( !self maySpawn() )
	{
		currentorigin =	self.origin;
		currentangles =	self.angles;

		shouldShowRespawnMessage = true;
		if ( level.roundLimit > 1 && game["roundsplayed"] >= (level.roundLimit - 1) )
			shouldShowRespawnMessage = false;
		if ( level.scoreLimit > 1 && level.teambased && game["teamScores"]["allies"] >= level.scoreLimit - 1 && game["teamScores"]["axis"] >= level.scoreLimit - 1 )
			shouldShowRespawnMessage = false;
		if ( shouldShowRespawnMessage )
		{
			setLowerMessage( game["strings"]["spawn_next_round"] );
			self thread removeSpawnMessageShortly( 3 );
		}
		self thread	[[level.spawnSpectator]]( currentorigin	+ (0, 0, 60), currentangles	);
		return;
	}

	if ( self.waitingToSpawn )
		return;
	self.waitingToSpawn = true;

	self waitAndSpawnClient( timeAlreadyPassed );

	if ( isdefined( self ) )
		self.waitingToSpawn = false;
}

waitAndSpawnClient( timeAlreadyPassed )
{
	self endon ( "disconnect" );
	self endon ( "end_respawn" );
	self endon ( "game_ended" );

	if ( !isdefined( timeAlreadyPassed ) )
		timeAlreadyPassed = 0;

	spawnedAsSpectator = false;

	if ( self.teamKillPunish )
	{
		teamKillDelay = TeamKillDelay();
		if ( teamKillDelay > timeAlreadyPassed )
		{
			teamKillDelay -= timeAlreadyPassed;
			timeAlreadyPassed = 0;
		}
		else
		{
			timeAlreadyPassed -= teamKillDelay;
			teamKillDelay = 0;
		}

		if ( teamKillDelay > 0 )
		{
			setLowerMessage( &"MP_FRIENDLY_FIRE_WILL_NOT", teamKillDelay );

			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
			spawnedAsSpectator = true;

			wait( teamKillDelay );
		}

		self.teamKillPunish = false;
	}

	if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
	{
		self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
		level.wavePlayerSpawnIndex[self.team]++;
	}

	timeUntilSpawn = TimeUntilSpawn( false );
	if ( timeUntilSpawn > timeAlreadyPassed )
	{
		timeUntilSpawn -= timeAlreadyPassed;
		timeAlreadyPassed = 0;
	}
	else
	{
		timeAlreadyPassed -= timeUntilSpawn;
		timeUntilSpawn = 0;
	}

	if ( timeUntilSpawn > 0 )
	{
		setLowerMessage( game["strings"]["waiting_to_spawn"], timeUntilSpawn );

		if ( !spawnedAsSpectator )
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitForTimeOrNotify( timeUntilSpawn, "force_spawn" );
	}

	waveBased = (getDvarInt( "scr_" + level.gameType + "_waverespawndelay" ) > 0);
	if ( maps\mp\gametypes\_tweakables::getTweakableValue( "player", "forcerespawn" ) == 0 && self.hasSpawned && !waveBased )
	{
		setLowerMessage( game["strings"]["press_to_spawn"] );

		if ( !spawnedAsSpectator )
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitRespawnButton();
	}

	self.waitingToSpawn = false;

	self clearLowerMessage();

	self.waveSpawnIndex = undefined;

	self thread	[[level.spawnPlayer]]();
}

waitForTimeOrNotify( time, notifyname )
{
	self endon( notifyname );
	wait time;
}

removeSpawnMessageShortly( delay )
{
	self endon("disconnect");

	waittillframeend;

	self endon("end_respawn");

	wait delay;

	self clearLowerMessage( 2.0 );
}

Callback_StartGameType()
{
	level.prematchPeriod = 0;
	level.prematchPeriodEnd = 0;

	level.intermission = false;
	game["state"] = "playing";

	if ( !isDefined( game["gamestarted"] ) )
	{
		if ( !isDefined( game["allies"] ) )
			game["allies"] = "marines";
		if ( !isDefined( game["axis"] ) )
			game["axis"] = "opfor";
		if ( !isDefined( game["attackers"] ) )
			game["attackers"] = "allies";
		if ( !isDefined( game["defenders"] ) )
			game["defenders"] = "axis";

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";

		precacheStatusIcon("hud_status_dead");
		precacheStatusIcon("hud_status_connecting");
		precacheStatusIcon("compassping_friendlyfiring_mp");
		precacheStatusIcon("compassping_enemy");

		precacheRumble( "damage_heavy" );

		precacheShader( "white" );
		precacheShader( "black" );

		makeDvarServerInfo( "scr_allies", "usmc" );
		makeDvarServerInfo( "scr_axis", "arab" );

		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
		if ( level.teamBased )
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_PLAYERS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}

		game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
		game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
		game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";

		game["strings"]["tie"] = &"MP_MATCH_TIE";
		game["strings"]["round_draw"] = &"MP_ROUND_DRAW";

		game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			game["strings"]["allies_name"] = &"PROMOD_ATTACK_NAME";
			game["strings"]["axis_name"] = &"PROMOD_DEFENCE_NAME";
			game["strings"]["allies_eliminated"] = &"PROMOD_ATTACK_ELIMINATED";
			game["strings"]["axis_eliminated"] = &"PROMOD_DEFENCE_ELIMINATED";
			game["strings"]["allies_forfeited"] = &"PROMOD_ATTACK_FORFEITED";
			game["strings"]["axis_forfeited"] = &"PROMOD_DEFENCE_FORFEITED";
		}
		else
		{
			game["strings"]["allies_name"] = &"PROMOD_DEFENCE_NAME";
			game["strings"]["axis_name"] = &"PROMOD_ATTACK_NAME";
			game["strings"]["allies_eliminated"] = &"PROMOD_DEFENCE_ELIMINATED";
			game["strings"]["axis_eliminated"] = &"PROMOD_ATTACK_ELIMINATED";
			game["strings"]["allies_forfeited"] = &"PROMOD_DEFENCE_FORFEITED";
			game["strings"]["axis_forfeited"] = &"PROMOD_ATTACK_FORFEITED";
		}

		switch ( game["allies"] )
		{
			case "sas":
				game["strings"]["allies_win"] = &"MP_SAS_WIN_MATCH";
				game["strings"]["allies_win_round"] = &"MP_SAS_WIN_ROUND";
				game["strings"]["allies_mission_accomplished"] = &"MP_SAS_MISSION_ACCOMPLISHED";

				game["icons"]["allies"] = "faction_128_sas";
				game["colors"]["allies"] = (0.6,0.64,0.69);
				game["voice"]["allies"] = "UK_1mc_";
				setDvar( "scr_allies", "sas" );
				break;
			case "marines":
			default:
				game["strings"]["allies_win"] = &"MP_MARINES_WIN_MATCH";
				game["strings"]["allies_win_round"] = &"MP_MARINES_WIN_ROUND";
				game["strings"]["allies_mission_accomplished"] = &"MP_MARINES_MISSION_ACCOMPLISHED";

				game["icons"]["allies"] = "faction_128_usmc";
				game["colors"]["allies"] = (0.6,0.64,0.69);
				game["voice"]["allies"] = "US_1mc_";
				setDvar( "scr_allies", "usmc" );
				break;
		}
		switch ( game["axis"] )
		{
			case "russian":
				game["strings"]["axis_win"] = &"MP_SPETSNAZ_WIN_MATCH";
				game["strings"]["axis_win_round"] = &"MP_SPETSNAZ_WIN_ROUND";
				game["strings"]["axis_mission_accomplished"] = &"MP_SPETSNAZ_MISSION_ACCOMPLISHED";

				game["icons"]["axis"] = "faction_128_ussr";
				game["colors"]["axis"] = (0.52,0.28,0.28);
				game["voice"]["axis"] = "RU_1mc_";
				setDvar( "scr_axis", "ussr" );
				break;
			case "arab":
			case "opfor":
			default:
				game["strings"]["axis_win"] = &"MP_OPFOR_WIN_MATCH";
				game["strings"]["axis_win_round"] = &"MP_OPFOR_WIN_ROUND";
				game["strings"]["axis_mission_accomplished"] = &"MP_OPFOR_MISSION_ACCOMPLISHED";

				game["icons"]["axis"] = "faction_128_arab";
				game["colors"]["axis"] = (0.65,0.57,0.41);
				game["voice"]["axis"] = "AB_1mc_";
				setDvar( "scr_axis", "arab" );
				break;
		}

		[[level.onPrecacheGameType]]();

		game["gamestarted"] = true;

		game["teamScores"]["allies"] = 0;
		game["teamScores"]["axis"] = 0;

		level.prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "playerwaittime" );
		level.prematchPeriodEnd = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );

		thread promod\set_variables::main();

		if ( !isDefined( game["promod_scorebot_ticker_buffer"] ) )
		{
			setDvar( "promod_scorebot_ticker_num", -1 );
			game["promod_scorebot_ticker_buffer"] = -1;
		}

		mapname = getDvar("mapname");
		game["promod_scorebot_ticker_buffer"] += "map" + mapname + "" + level.gametype;
	}

	if ( !isdefined( game["timepassed"] ) )
		game["timepassed"] = 0;

	if ( !isdefined( game["roundsplayed"] ) )
		game["roundsplayed"] = 0;

	if ( !isDefined( game["promod_do_readyup"] ) )
		game["promod_do_readyup"] = false;

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" || getDvarInt( "promod_allow_readyup" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] )
		if ( game["roundsplayed"] == 0 && !game["promod_first_readyup_done"] )
			game["promod_do_readyup"] = true;

	level.gameEnded = false;
	level.teamSpawnPoints["axis"] = [];
	level.teamSpawnPoints["allies"] = [];

	level.objIDStart = 0;
	level.forcedEnd = false;

	level.useStartSpawns = true;

	setdvar( "scr_teamKillPunishCount", "0" );
	level.minimumAllowedTeamKills = getdvarint( "scr_teamKillPunishCount" ) - 1;

	thread maps\mp\gametypes\_promod::init();
	thread maps\mp\gametypes\_class::init();
	thread maps\mp\gametypes\_rank::init();
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_oldschool::deletePickups();

	thread promod\dvar_monitor::main();
	thread promod\promod_modes::Monitor_Promod_Mode();
	thread promod\scorebot::main();

	if ( level.teamBased )
		thread maps\mp\gametypes\_friendicons::init();

	thread maps\mp\gametypes\_hud_message::init();

	thread maps\mp\gametypes\_quickmessages::init();

	stringNames = getArrayKeys( game["strings"] );
	for ( index = 0; index < stringNames.size; index++ )
		precacheString( game["strings"][stringNames[index]] );

	level.maxPlayerCount = 0;
	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.lastAliveCount["allies"] = 0;
	level.lastAliveCount["axis"] = 0;
	level.everExisted["allies"] = false;
	level.everExisted["axis"] = false;
	level.waveDelay["allies"] = 0;
	level.waveDelay["axis"] = 0;
	level.lastWave["allies"] = 0;
	level.lastWave["axis"] = 0;
	level.wavePlayerSpawnIndex["allies"] = 0;
	level.wavePlayerSpawnIndex["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	if ( !isDefined( level.timeLimit ) )
		registerTimeLimitDvar( "default", 10, 1, 1440 );

	if ( !isDefined( level.scoreLimit ) )
		registerScoreLimitDvar( "default", 100, 1, 500 );

	if ( !isDefined( level.roundLimit ) )
		registerRoundLimitDvar( "default", 1, 0, 999 );

	makeDvarServerInfo( "ui_scorelimit" );
	makeDvarServerInfo( "ui_timelimit" );

	waveDelay = getDvarInt( "scr_" + level.gameType + "_waverespawndelay" );
	if ( waveDelay )
	{
		level.waveDelay["allies"] = waveDelay;
		level.waveDelay["axis"] = waveDelay;
		level.lastWave["allies"] = 0;
		level.lastWave["axis"] = 0;

		level thread [[level.waveSpawnTimer]]();
	}

	level.inPrematchPeriod = true;

	level.gracePeriod = 4;

	level.inGracePeriod = true;

	level.roundEndDelay = 4;
	level.halftimeRoundEndDelay = 3;

	updateTeamScores( "axis", "allies" );

	if ( !level.teamBased )
		thread initialDMScoreUpdate();

	[[level.onStartGameType]]();

	level.promod_hud_header_create = promod\header::create;

	thread promod\messagecenter::main();
	thread promod\hud_website::main();

	deletePlacedEntity("misc_turret");

	thread startGame();

	level thread updateGameTypeDvars();
}

initialDMScoreUpdate()
{
	wait .2;
	numSent = 0;
	while(1)
	{
		didAny = false;

		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !isdefined( player ) )
				continue;

			if ( isdefined( player.updatedDMScores ) )
				continue;

			player.updatedDMScores = true;
			player updateDMScores();

			didAny = true;
			wait .5;
		}

		if ( !didAny )
			wait 3;
	}
}

checkRoundSwitch()
{
	if ( !isdefined( level.roundSwitch ) || !level.roundSwitch )
		return false;
	if ( !isdefined( level.onRoundSwitch ) )
		return false;

	assert( game["roundsplayed"] > 0 );

	if ( game["roundsplayed"] % level.roundswitch == 0 )
	{
		if ( ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" || getDvarInt( "promod_allow_readyup" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] ) && game["promod_first_readyup_done"] )
			game["promod_do_readyup"] = true;

		game["promod_timeout_called"] = false;

		[[level.onRoundSwitch]]();
		return true;
	}

	return false;
}

getGameScore( team )
{
	return game["teamScores"][team];
}

Callback_PlayerConnect()
{
	thread notifyConnecting();

	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	waittillframeend;
	self.statusicon = "";

	level notify( "connected", self );

	if( !isdefined( self.pers["score"] ) )
		iPrintLn( &"MP_CONNECTED", self.name );

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	self setClientDvars( "cg_drawSpectatorMessages", 1,
						 "fx_drawClouds", 0,
						 "ui_hud_hardcore", getDvar( "ui_hud_hardcore" ) );

	if ( level.hardcoreMode )
	{
		self setClientDvars( "cg_drawTalk", 3,
							 "cg_drawCrosshair", 0,
							 "cg_hudGrenadeIconMaxRangeFrag", 0 );
	}
	else
	{
		self setClientDvars( "cg_drawCrosshair", 1,
							 "cg_hudGrenadeIconMaxRangeFrag", 250 );
	}

	self setClientDvars(	"cg_hudGrenadeIconHeight", "25",
							"cg_hudGrenadeIconWidth", "25",
							"cg_hudGrenadeIconOffset", "50",
							"cg_hudGrenadePointerHeight", "12",
							"cg_hudGrenadePointerWidth", "25",
							"cg_hudGrenadePointerPivot", "12 27" );

	self initPersStat( "score" );
	self.score = self.pers["score"];

	self initPersStat( "deaths" );
	self.deaths = self getPersStat( "deaths" );

	self initPersStat( "suicides" );
	self.suicides = self getPersStat( "suicides" );

	self initPersStat( "kills" );
	self.kills = self getPersStat( "kills" );

	self initPersStat( "headshots" );
	self.headshots = self getPersStat( "headshots" );

	self initPersStat( "assists" );
	self.assists = self getPersStat( "assists" );

	self initPersStat( "teamkills" );
	self.teamKillPunish = false;
	if ( level.minimumAllowedTeamKills >= 0 && self.pers["teamkills"] > level.minimumAllowedTeamKills )
		self thread reduceTeamKillsOverTime();

	self.lastGrenadeSuicideTime = -1;

	self.teamkillsThisRound = 0;

	self.pers["lives"] = level.numLives;

	self.hasSpawned = false;
	self.waitingToSpawn = false;
	self.deathCount = 0;

	self.wasAliveAtMatchStart = false;

	self thread maps\mp\_flashgrenades::monitorFlash();

	level.players[level.players.size] = self;

	if ( level.teambased )
		self updateScores();

	level endon( "game_ended" );

	if ( isDefined( self.pers["team"] ) )
		self.team = self.pers["team"];

	if ( isDefined( self.pers["class"] ) )
		self.class = self.pers["class"];

	if ( !isDefined( self.pers["team"] ) )
	{
		self.pers["team"] = "none";
		self.team = "none";
		self.sessionstate = "dead";

		self setClientDvars(	"loadout_curclass", "",
								"r_contrast", "0",
								"r_brightness", "-1" );

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		self thread promod\promod_client_dvars::main();
		self thread maps\mp\gametypes\_promod::initClassLoadouts();

		self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
		self openMenu( game["menu_team"] );

		if ( level.teamBased )
		{
			self.sessionteam = self.pers["team"];

			if ( !isAlive( self ) )
				self.statusicon = "hud_status_dead";

			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
		}
	}
	else if ( self.pers["team"] == "spectator" )
	{
		self setclientdvar( "g_scriptMainMenu", game["menu_shoutcast"] );
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam = self.pers["team"];
		self.sessionstate = "dead";

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		if ( isValidClass( self.pers["class"] ) )
		{
			self thread [[level.spawnClient]]();
		}

		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
}

Callback_PlayerDisconnect()
{
	self removePlayerOnDisconnect();

	if ( isDefined( self.score ) && isDefined( self.pers["team"] ) )
	{
		setPlayerTeamRank( self, level.dropTeam, self.score - 5 * self.deaths );
		self logString( "team: score " + self.pers["team"] + ":" + self.score );
		level.dropTeam += 1;
	}

	[[level.onPlayerDisconnect]]();

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}

	if ( level.gameEnded )
		self removeDisconnectedPlayerFromPlacement();

	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( player.pers["team"] == "spectator" )
		{
			player thread promod\shoutcast::resetShoutcast();
		}
	}

	if ( isDefined( self.pers["team"] ) && ( self.pers["team"] == "allies" || self.pers["team"] == "axis" ) )
		thread maps\mp\gametypes\_promod::updateClassAvailability( self.pers["team"] );

	level thread updateTeamStatus();
}

removePlayerOnDisconnect()
{
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
}

isHeadShot( sWeapon, sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT";
}

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if (!isDefined( level.rdyup ) )
		level.rdyup = false;

	iDamage = maps\mp\gametypes\_class::cac_modified_damage( self, eAttacker, iDamage, sMeansOfDeath );
	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

	if ( self.sessionteam == "spectator" )
		return;

	if ( isDefined( self.canDoCombat ) && !self.canDoCombat )
		return;

	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;

	prof_begin( "Callback_PlayerDamage flags/tweaks" );

	if ( level.rdyup )
	{
		if ( isDefined( eAttacker ) )
		{
			if ( isPlayer( eAttacker ) )
			{
				if ( eAttacker != self )
				{
					if ( !isDefined(eAttacker.ruptally ) )
						eAttacker.ruptally = 0;

					if ( eAttacker.ruptally < 0 )
						eAttacker.ruptally = 0;

					if ( !isDefined( self.ruptally ) )
						self.ruptally = -1;

					if ( self.ruptally < 0)
						return;
				}
			}
		}
	}

	if ( isDefined( level.ready_up_over ) && level.ready_up_over || isDefined( level.strat_over ) && !level.strat_over || isDefined( level.bombDefused ) && level.bombDefused || isDefined( level.bombExploded ) && level.bombExploded && self.pers["team"] == game["attackers"] )
		return;

	if( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = false;

	if ( (level.teamBased && (self.health == self.maxhealth)) || !isDefined( self.attackers ) )
	{
		self.attackers = [];
		self.attackerData = [];
	}

	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if ( sWeapon == "none" && isDefined( eInflictor ) )
	{
		if ( isDefined( eInflictor.targetname ) && eInflictor.targetname == "explodable_barrel" )
			sWeapon = "explodable_barrel";
		else if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) )
			sWeapon = "destructible_car";
	}

	prof_end( "Callback_PlayerDamage flags/tweaks" );

	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		if ( (isSubStr( sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( sMeansOfDeath, "MOD_EXPLOSIVE" ) || isSubStr( sMeansOfDeath, "MOD_PROJECTILE" )) && isDefined( eInflictor ) )
		{
			if ( game["promod_match_mode"] != "match" )
			{
				if ( eInflictor.classname == "grenade" && ( ( self.lastSpawnTime + 3500) > getTime() && distance( eInflictor.origin, self.lastSpawnPoint.origin ) < 250 || !isDefined ( eAttacker.pers["class"] ) ) )
				{
					prof_end( "Callback_PlayerDamage player" );
					return;
				}
			}
		}

		if ( level.teamBased && isPlayer( eAttacker ) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]) )
		{
			prof_begin( "Callback_PlayerDamage player" );
			if ( level.friendlyfire == 0 )
			{
				return;
			}
			else if ( level.friendlyfire == 1 )
			{
				if ( iDamage < 1 )
					iDamage = 1;

				self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			}
			else if ( level.friendlyfire == 2 && isAlive( eAttacker ) )
			{
				iDamage = int(iDamage * .5);

				if(iDamage < 1)
					iDamage = 1;

				eAttacker.friendlydamage = true;
				eAttacker finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker.friendlydamage = undefined;
			}
			else if ( level.friendlyfire == 3 && isAlive( eAttacker ) )
			{
				iDamage = int(iDamage * .5);

				if ( iDamage < 1 )
					iDamage = 1;

				self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker.friendlydamage = true;
				eAttacker finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker.friendlydamage = undefined;
			}

			friendly = true;
		}
		else
		{
			prof_begin( "Callback_PlayerDamage world" );

			if(iDamage < 1)
				iDamage = 1;

			if ( level.teamBased && isDefined( eAttacker ) && isPlayer( eAttacker ) )
			{
				if ( !isdefined( self.attackerData[eAttacker.clientid] ) )
				{
					self.attackers[ self.attackers.size ] = eAttacker;
					self.attackerData[eAttacker.clientid] = false;
				}
				if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( sWeapon ) )
					self.attackerData[eAttacker.clientid] = true;
			}

			self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

			prof_end( "Callback_PlayerDamage world" );
		}

		if ( isDefined(eAttacker) && eAttacker != self )
		{
			if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
				thread dinkNoise(eAttacker, self);

			hasBodyArmor = false;

			if ( iDamage > 0 && getDvarInt( "scr_enable_hiticon" ) == 1 )
				eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor );
			else if ( iDamage > 0 && getDvarInt( "scr_enable_hiticon" ) == 2 && !(iDFlags & level.iDFLAGS_PENETRATION) )
				eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor );
		}

		self.hasDoneCombat = true;
	}

	if ( isdefined( eAttacker ) && eAttacker != self && !friendly )
		level.useStartSpawns = false;

	prof_begin( "Callback_PlayerDamage log" );

	if(self.sessionstate != "dead")
	{
		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfGuid = self getGuid();
		lpattackerteam = "";

		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		logPrint("D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}

	damagestring = "";
	unitstring = "";
	metrestring = "";

	if ( isDefined( sHitLoc ) && sHitLoc != "none")
	{
		if( isSubStr( sHitLoc, "torso_upper" ) )
			damagestring = ("upper torso" );
		else if( isSubStr( sHitLoc, "torso_lower" ) )
			damagestring = ("lower torso" );
		else if( isSubStr( sHitLoc, "leg_upper" ) )
			damagestring = ("upper leg" );
		else if( isSubStr( sHitLoc, "leg_lower" ) )
			damagestring = ("lower leg" );
		else if( isSubStr( sHitLoc, "arm_upper" ) )
			damagestring = ("upper arm" );
		else if( isSubStr( sHitLoc, "arm_lower" ) )
			damagestring = ("lower arm" );
		else if( isSubStr( sHitLoc, "head" ) || isSubStr( sHitLoc, "helmet" ) )
			damagestring = ("head" );
		else if( isSubStr( sHitLoc, "neck" ) )
			damagestring = ("neck" );
		else if( isSubStr( sHitLoc, "foot" ) )
			damagestring = ("foot" );
		else if( isSubStr( sHitLoc, "hand" ) )
			damagestring = ("hand" );

		unitstring = distance(self.origin, eAttacker.origin);
		metrestring = unitstring / 50 * 1.27;
	}

	if ( isDefined( eAttacker ) )
	{
		if ( isPlayer( eAttacker ) )
		{
			if ( eAttacker.name != self.name && ( isDefined( level.rdyup ) && level.rdyup || isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "strat" ) )
			{
				if ( isDefined( sHitLoc ) && sHitLoc != "none" )
				{
					eAttacker iprintln("You did " + "^2" + iDamage + "^7 damage at a distance of " + "^2" + metrestring + "^7 metres in the " + "^2" + damagestring + "^7 to " + self.name);
					self iprintln(eAttacker.name + " did " + "^1" + iDamage + "^7 damage at a distance of " + "^1" + metrestring + "^7 metres in the " + "^1" + damagestring + "^7 to you");
				}
				else if ( isDefined( sHitLoc ) && sHitLoc == "none" )
				{
					eAttacker iprintln("You did " + "^2" + iDamage + "^7 damage to " + self.name);
					self iprintln(eAttacker.name + " did " + "^1" + iDamage + "^7 damage to you");
				}
			}
			else if ( eAttacker.name == self.name && ( isDefined( level.rdyup ) && level.rdyup || game["promod_match_mode"] == "strat" ) )
			{
				if ( isDefined( sHitLoc ) && sHitLoc == "none" )
				{
					self iprintln("You did ^1" + iDamage + "^7 damage to yourself");
				}
			}
		}
	}
	else if ( isDefined( level.rdyup ) && level.rdyup || game["promod_match_mode"] == "strat" )
	{
		if ( sMeansOfDeath == "MOD_FALLING" )
		{
			self iprintln("You did ^1" + iDamage + "^7 damage to yourself");
		}
	}

	prof_end( "Callback_PlayerDamage log" );

	if ( !isDefined( self.switching_teams ) )
		self notify("updateshoutcast");
}

dinkNoise( player1, player2 )
{
	player1 playLocalSound("bullet_impact_headshot_2");
	player2 playLocalSound("bullet_impact_headshot_2");
}

finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
}

damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage )
{
	self thread maps\mp\gametypes\_weapons::onWeaponDamage( eInflictor, sWeapon, sMeansOfDeath, iDamage );
	self PlayRumbleOnEntity( "damage_heavy" );
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (!isDefined( level.rdyup ) )
		level.rdyup = false;

	self endon( "spawned" );
	self notify( "killed_player" );

	if ( self.sessionteam == "spectator" )
		return;

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

	prof_begin( "PlayerKilled pre constants" );

	if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
		attacker = attacker.owner;

	if( level.teamBased && isDefined( attacker.pers ) && self.team == attacker.team && sMeansOfDeath == "MOD_GRENADE" && level.friendlyfire == 0 )
		obituary(self, self, sWeapon, sMeansOfDeath);
	else
		obituary(self, attacker, sWeapon, sMeansOfDeath);

	if ( !level.inGracePeriod )
		self maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );

	self.sessionstate = "dead";

	self.statusicon = "hud_status_dead";

	self.pers["weapon"] = undefined;

	if (level.rdyup)
	{
		if (isDefined( attacker.pers ) && ( attacker != self ))
		{
			attacker.ruptally++;
		}
	}

	if (!level.rdyup)
	{
		self.deathCount++;

		if (isDefined( attacker.pers ))

		if( !isDefined( self.switching_teams ) )
		{
			self incPersStat( "deaths", 1 );
			self.deaths = self getPersStat( "deaths" );
		}
	}

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpattackGuid = "";
	lpattackname = "";
	lpselfteam = "";
	lpselfguid = self getGuid();
	lpattackerteam = "";

	lpattacknum = -1;

	prof_end( "PlayerKilled pre constants" );

	if( isPlayer( attacker ) )
	{
		lpattackGuid = attacker getGuid();
		lpattackname = attacker.name;

		if ( attacker == self )
		{
			doKillcam = false;

			if ( isDefined( self.switching_teams ) )
			{
				if ( !level.teamBased && ((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies")) )
				{
					playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
					playerCounts[self.leaving_team]--;
					playerCounts[self.joining_team]++;

					if( (playerCounts[self.joining_team] - playerCounts[self.leaving_team]) > 1 )
					{
						if (!level.rdyup)
						{
							self thread [[level.onXPEvent]]( "suicide" );
							self incPersStat( "suicides", 1 );
							self.suicides = self getPersStat( "suicides" );
						}
					}
				}
			}
			else
			{
				if (!level.rdyup)
				{
					self thread [[level.onXPEvent]]( "suicide" );
					self incPersStat( "suicides", 1 );
					self.suicides = self getPersStat( "suicides" );

					scoreSub = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "suicidepointloss" );
					_setPlayerScore( self, _getPlayerScore( self ) - scoreSub );
				}
				if ( sMeansOfDeath == "MOD_SUICIDE" && sHitLoc == "none" && self.throwingGrenade )
				{
					self.lastGrenadeSuicideTime = gettime();
				}
			}

			if( isDefined( self.friendlydamage ) )
				self iPrintLn(&"MP_FRIENDLY_FIRE_WILL_NOT");
		}
		else
		{
			prof_begin( "PlayerKilled attacker" );

			lpattacknum = attacker getEntityNumber();

			doKillcam = true;

			if ( level.teamBased && self.pers["team"] == attacker.pers["team"] && sMeansOfDeath == "MOD_GRENADE" && level.friendlyfire == 0 )
			{
			}
			else if ( level.teamBased && self.pers["team"] == attacker.pers["team"] )
			{
				if (!level.rdyup)
				{
					attacker thread [[level.onXPEvent]]( "teamkill" );

					attacker.pers["teamkills"] += 1.0;

					attacker.teamkillsThisRound++;

					if ( maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillpointloss" ) )
					{
						scoreSub = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
						_setPlayerScore( attacker, _getPlayerScore( attacker ) - scoreSub );
					}
				}
			}
			else
			{
				prof_begin( "pks1" );

				if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
				{
					attacker incPersStat( "headshots", 1 );
					attacker.headshots = attacker getPersStat( "headshots" );
					value = maps\mp\gametypes\_rank::getScoreInfoValue( "headshot" );
					attacker thread maps\mp\gametypes\_rank::giveRankXP( "headshot", value );
					attacker playLocalSound( "bullet_impact_headshot_2" );
				}
				else
				{
					value = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
					attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", value );
				}

				if (!level.rdyup)
				{
					attacker incPersStat( "kills", 1 );
					attacker.kills = attacker getPersStat( "kills" );

					givePlayerScore( "kill", attacker, self );

					giveTeamScore( "kill", attacker.pers["team"], attacker, self );

					scoreSub = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "deathpointloss" );
					_setPlayerScore( self, _getPlayerScore( self ) - scoreSub );
				}

				prof_end( "pks1" );
				if (!level.rdyup)
				{
					if ( level.teamBased )
					{
						prof_begin( "PlayerKilled assists" );

						if ( isdefined( self.attackers ) )
						{
							for ( j = 0; j < self.attackers.size; j++ )
							{
								player = self.attackers[j];

								if ( !isDefined( player ) )
									continue;

								if ( player == attacker )
									continue;

								player thread processAssist( self );
							}
							self.attackers = [];
						}

						prof_end( "PlayerKilled assists" );
					}
				}
			}

			prof_end( "PlayerKilled attacker" );
		}
	}
	else
	{
		doKillcam = false;
		killedByEnemy = false;

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";

		if ( isDefined( attacker ) && isDefined( attacker.team ) && (attacker.team == "axis" || attacker.team == "allies") )
		{
			if ( attacker.team != self.pers["team"] )
			{
				killedByEnemy = true;
				if ( level.teamBased )
					giveTeamScore( "kill", attacker.team, attacker, self );
			}
		}

	}

	if ( !isDefined( self.switching_teams ) )
		self notify("updateshoutcast");

	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;

	prof_begin( "PlayerKilled post constants" );

	logPrint( "K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n" );

	if ( sMeansOfDeath == "MOD_MELEE" )
		scWeapon = "knife_mp";
	else
		scWeapon = sWeapon;

	if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
		sHeadshot = 1;
	else
		sHeadshot = 0;

	if ( isDefined( level.scorebot ) && level.scorebot && !level.rdyup )
		game["promod_scorebot_ticker_buffer"] += "kill" + lpattackname + "" + scWeapon + "" + lpselfname + "" + sHeadshot;

	attackerString = "none";
	if ( isPlayer( attacker ) )
		attackerString = attacker getXuid() + "(" + lpattackname + ")";
	self logstring( "d " + sMeansOfDeath + "(" + sWeapon + ") a:" + attackerString + " d:" + iDamage + " l:" + sHitLoc + " @ " + int( self.origin[0] ) + " " + int( self.origin[1] ) + " " + int( self.origin[2] ) );

	level thread updateTeamStatus();

	body = self clonePlayer( deathAnimDuration );
	if ( self isOnLadder() || self isMantling() )
		body startRagDoll();

	thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );

	self.body = body;

	self thread [[level.onPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);

	if ( sWeapon == "none" )
		doKillcam = false;

	killcamentity = -1;

	self.deathTime = getTime();

	wait ( 0.25 );

	self.cancelKillcam = false;
	self thread cancelKillCamOnUse();

	if ( isDefined( game["promod_match_mode"] ) && game["promod_match_mode"] == "match" && level.gametype == "sd" )
		postDeathDelay = waitForTimeOrNotifies( 0.75 );
	else
		postDeathDelay = waitForTimeOrNotifies( 1.75 );

	self notify ( "death_delay_finished" );

	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
		return;

	respawnTimerStartTime = gettime();

	if ( !self.cancelKillcam && doKillcam && level.killcam )
	{
		livesLeft = !(level.numLives && !self.pers["lives"]);
		timeUntilSpawn = TimeUntilSpawn( true );
		willRespawnImmediately = livesLeft && (timeUntilSpawn <= 0);

		self maps\mp\gametypes\_killcam::killcam( lpattacknum, killcamentity, sWeapon, postDeathDelay, psOffsetTime, willRespawnImmediately, timeUntilRoundEnd(), [], attacker );
	}

	prof_end( "PlayerKilled post constants" );

	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}

	if ( isValidClass( self.class ) )
	{
		timePassed = (gettime() - respawnTimerStartTime) / 1000;
		self thread [[level.spawnClient]]( timePassed );
	}
}

cancelKillCamOnUse()
{
	self endon ( "death_delay_finished" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		if ( !self UseButtonPressed() )
		{
			wait ( 0.05 );
			continue;
		}

		buttonTime = 0;
		while( self UseButtonPressed() )
		{
			buttonTime += 0.05 ;
			wait ( 0.05 );
		}

		if ( buttonTime >= 0.5 )
			continue;

		buttonTime = 0;

		while ( !self UseButtonPressed() && buttonTime < 0.5 )
		{
			buttonTime += 0.05 ;
			wait ( 0.05 );
		}

		if ( buttonTime >= 0.5 )
			continue;

		self.cancelKillcam = true;
		return;
	}
}

waitForTimeOrNotifies( desiredDelay )
{
	startedWaiting = getTime();

	waitedTime = (getTime() - startedWaiting)/1000;

	if ( waitedTime < desiredDelay )
	{
		wait desiredDelay - waitedTime;
		return desiredDelay;
	}
	else
	{
		return waitedTime;
	}
}

reduceTeamKillsOverTime()
{
	timePerOneTeamkillReduction = 20.0;
	reductionPerSecond = 1.0 / timePerOneTeamkillReduction;

	while(1)
	{
		if ( isAlive( self ) )
		{
			self.pers["teamkills"] -= reductionPerSecond;
			if ( self.pers["teamkills"] < level.minimumAllowedTeamKills )
			{
				self.pers["teamkills"] = level.minimumAllowedTeamKills;
				break;
			}
		}
		wait 1;
	}
}

processAssist( killedplayer )
{
	self endon("disconnect");
	killedplayer endon("disconnect");

	wait .05;
	WaitTillSlowProcessAllowed();

	if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
		return;

	if ( self.pers["team"] == killedplayer.pers["team"] )
		return;

	self thread [[level.onXPEvent]]( "assist" );
	self incPersStat( "assists", 1 );
	self.assists = self getPersStat( "assists" );

	givePlayerScore( "assist", self, killedplayer );

	if (!isDefined( level.rdyup ) )
		level.rdyup = false;

	if ( isDefined( level.scorebot ) && level.scorebot && !level.rdyup )
		game["promod_scorebot_ticker_buffer"] += "assist_by" + self.name;
}

Callback_PlayerLastStand()
{
}

setSpawnVariables()
{
	resetTimeout();

	self StopShellshock();
	self StopRumble( "damage_heavy" );
}

notifyConnecting()
{
	self setRank( 0, 1 );

	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}

setObjectiveText( team, text )
{
	game["strings"]["objective_"+team] = text;
	precacheString( text );
}

setObjectiveScoreText( team, text )
{
	game["strings"]["objective_score_"+team] = text;
	precacheString( text );
}

setObjectiveHintText( team, text )
{
	game["strings"]["objective_hint_"+team] = text;
	precacheString( text );
}

getObjectiveText( team )
{
	if ( !isDefined( game["strings"]["objective_"+team] ) )
		return "";

	return game["strings"]["objective_"+team];
}

getObjectiveScoreText( team )
{
	if ( !isDefined( game["strings"]["objective_score_"+team] ) )
		return "";

	return game["strings"]["objective_score_"+team];
}

getObjectiveHintText( team )
{
	if ( !isDefined( game["strings"]["objective_hint_"+team] ) )
		return "";

	return game["strings"]["objective_hint_"+team];
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}

	wait( 0.2 );

	if ( !isDefined( ent ) )
		return;

	if ( ent isRagDoll() )
		return;

	deathAnim = ent getcorpseanim();

	startFrac = 0.35;

	if ( animhasnotetrack( deathAnim, "start_ragdoll" ) )
	{
		times = getnotetracktimes( deathAnim, "start_ragdoll" );
		if ( isDefined( times ) )
			startFrac = times[0];
	}

	waitTime = startFrac * getanimlength( deathAnim );
	wait( waitTime );

	if ( isDefined( ent ) )
	{
		ent startragdoll( 1 );
	}
}