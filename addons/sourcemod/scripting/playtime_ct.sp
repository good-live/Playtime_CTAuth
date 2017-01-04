#pragma semicolon 1

#define PLUGIN_AUTHOR "good_live, shanapu"
#define PLUGIN_VERSION "1.0.<BUILD_ID>"

#include <sourcemod>
#include <sdktools>
#include <playtime>
#include <multicolors>
#include <cstrike>
#include <myjailbreak>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Playtime - CT Authentication",
	author = PLUGIN_AUTHOR,
	description = "Allows to define a minimal amount of playtime to play on the CT - Team (Usefull for Jailbreak)",
	version = PLUGIN_VERSION,
	url = "painlessgaming.eu"
};

ConVar g_cMinTime;

public void OnPluginStart()
{
	LoadTranslations("playtime_ct.phrases");
	
	g_cMinTime = CreateConVar("pt_ct_min_time", "180000", "Minimal time (in secounds) to play as CT");
	AutoExecConfig(true);
	
	//Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("myratio"))
		SetFailState("You're missing the MyJailbreak - Ratio (ratio.smx) plugin");
}

public Action MyJailbreak_OnJoinGuardQueue(int client)
{
	if(PT_GetPlayTime(client) < g_cMinTime.IntValue)
	{
		CPrintToChat(client, "%t %t", "Tag", "Not enough playtime", g_cMinTime.IntValue/60);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (GetClientTeam(client) != 3) 
		return Plugin_Continue;
		
	if (!IsClientValid(client))
		return Plugin_Continue;
		
	if (PT_GetPlayTime(client) < g_cMinTime.IntValue)
	{
		CPrintToChat(client, "%t %t", "Tag", "Not enough playtime", g_cMinTime.IntValue/60);
		CreateTimer(5.0, Timer_SlayPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}


public Action Timer_SlayPlayer(Handle hTimer, any iUserId) 
{
	int client = GetClientOfUserId(iUserId);
	
	if ((IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_CT))
	{
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
		MinusDeath(client);
	}
	return Plugin_Stop;
}


void MinusDeath(int client)
{
	if (IsClientValid(client))
	{
		int frags = GetEntProp(client, Prop_Data, "m_iFrags");
		int deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		SetEntProp(client, Prop_Data, "m_iFrags", (frags+1));
		SetEntProp(client, Prop_Data, "m_iDeaths", (deaths-1));
	}
}

bool IsClientValid(int client)
{
	if (1 <= client <= MaxClients && IsClientConnected(client))
	{
		return true;
	}
	return false;
}
