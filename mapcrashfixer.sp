#include <sourcemod>
#include <sdktools>
#include <bbcolors>

#pragma semicolon 1
#pragma tabsize 0
#pragma newdecls required

public Plugin myinfo =
{
	name		= "CSGO Panorama Map Change Crashe Fixer",
    author      = "BOT Benson",
    description = "CSGO Panorama Map Change Crashe Fixer",
    version     = "1.0.0.7",
    url         = "https://www.botbenson.com"
};

ConVar _maxRound , _nextmapVote , _winlimit;

bool _retry = false;
public void OnPluginStart()
{

	_maxRound    = FindConVar("mp_maxrounds");
	_winlimit    = FindConVar("mp_winlimit");
	_nextmapVote = FindConVar("mp_endmatch_votenextmap");

	HookEvent("round_end", OnRoundEnd);

	RegAdminCmd( "sm_mapend" , Command_MapEnd , ADMFLAG_CHANGEMAP );
	RegAdminCmd( "sm_changenextmap" , Command_ChangeNextMap , ADMFLAG_CHANGEMAP );

}

public void OnMapStart()
{

   	SetIntCvar("mp_match_end_changelevel" , 0);
   	SetIntCvar("mp_endmatch_votenextmap" , 0);
   	SetIntCvar("mp_endmatch_votenextleveltime" , 0);
   	SetIntCvar("mp_match_end_restart" , 0);

	_retry = false;

}


public Action Command_ChangeNextMap( int client , int args )
{

	char mapName[PLATFORM_MAX_PATH];
	GetCmdArg(1, mapName, sizeof(mapName));

	switch (FindMap(mapName, mapName, sizeof(mapName)))
	{
		case FindMap_Found:
			SetNextMap( mapName );
		case FindMap_FuzzyMatch:
			SetNextMap( mapName );
	}
	
	return Plugin_Handled;
}

public Action Command_MapEnd( int client , int args )
{

   	SetIntCvar("mp_timelimit" , 0);
   	SetIntCvar("mp_maxrounds" , 0);
   	SetIntCvar("mp_respawn_on_death_t" , 0);
   	SetIntCvar("mp_respawn_on_death_ct" , 0);

	return Plugin_Handled;
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	
	if( !_retry && CheckMapEnd() )
	{

		CreateTimer( 14.9 , Timer_RetryPlayers , _ , TIMER_FLAG_NO_MAPCHANGE );
		_retry = true;

	}
	
}

public Action Timer_RetryPlayers( Handle timer , int _any )
{


	for( int i = 1; i <= MaxClients; i++ )
	{

		if( !IsClientInGame( i ) || IsFakeClient( i ) || !IsClientConnected( i ) )
			continue;

		ClientCommand( i , "retry" );

	}

	return Plugin_Stop;
}

bool CheckMapEnd()
{

	if( _nextmapVote.IntValue != 0 )
		return false;

	int maxround = _maxRound.IntValue;
	if(maxround > 0)
	{

		int CTScore  = GetTeamScore( 3 );
		int TScore   = GetTeamScore( 2 );
		int winscore = _winlimit.IntValue;

		if( maxround > winscore )
			winscore = ( maxround / 2 ) + 1;

		if( CTScore >= winscore || TScore >= winscore )
			return true;

		maxround = maxround / 2;
		int winTeamScore = maxround + 1;
		if( CTScore >= winTeamScore || TScore >= winTeamScore )
			return true;

		if( CTScore == maxround && TScore == maxround) 
			return true;

		return false;
	}
		
	int timeleft;
	GetMapTimeLeft(timeleft);
	if (timeleft <= 0) 
		return true;
	
	return false;
}

bool SetIntCvar(char[] scvar, int value)
{
	
	ConVar cvar = FindConVar(scvar);
	if (cvar == null) 
		return false;
		
	cvar.SetInt(value);
	return true;
}
