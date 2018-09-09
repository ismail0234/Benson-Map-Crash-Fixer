#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma tabsize 0
#pragma newdecls required

public Plugin myinfo =
{
	name		= "CSGO Panorama Map Change Crashe Fixer",
    author      = "BOT Benson",
    description = "CSGO Panorama Map Change Crashe Fixer",
    version     = "1.0.3",
    url         = "https://www.botbenson.com"
};
ConVar mapChangeDelay;
public void OnPluginStart()
{

	mapChangeDelay = FindConVar("mp_match_restart_delay");

	HookEventEx("cs_win_panel_match", Event_MapEnd);

	RegAdminCmd( "sm_mapend" , Command_MapEnd , ADMFLAG_CHANGEMAP );
	RegAdminCmd( "sm_changenextmap" , Command_ChangeNextMap , ADMFLAG_CHANGEMAP );

}

public void OnMapStart()
{

   	SetIntCvar("mp_match_end_changelevel" , 0);
   	SetIntCvar("mp_endmatch_votenextmap" , 0);
   	SetIntCvar("mp_endmatch_votenextleveltime" , 0);
   	SetIntCvar("mp_match_end_restart" , 0);

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

public void Event_MapEnd(Event event, const char[] name, bool dontBroadcast)
{

	CreateTimer( float( mapChangeDelay.IntValue ) , Timer_RetryPlayers , _ );

}

public Action Timer_RetryPlayers( Handle timer , int _any )
{


	for( int i = 1; i <= MaxClients; i++ )
	{

		if( !IsClientInGame( i ) || IsFakeClient( i ) || !IsClientConnected( i ) )
			continue;

		ReconnectClient( i );

	}

	return Plugin_Stop;
}

bool SetIntCvar(char[] scvar, int value)
{
	
	ConVar cvar = FindConVar(scvar);
	if (cvar == null) 
		return false;
		
	cvar.SetInt(value);
	return true;
}
