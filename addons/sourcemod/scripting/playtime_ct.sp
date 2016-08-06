#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "good_live"
#define PLUGIN_VERSION "1.0.<BUILD_ID>"

#include <sourcemod>
#include <sdktools>
#include <playtime>
#include <multicolors>
#include <cstrike>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Playtime - CT Authentication",
	author = PLUGIN_AUTHOR,
	description = "Allows to define a minimal amount of playtime to play on the CT - Team (Usefull for Jailbreak)",
	version = PLUGIN_VERSION,
	url = "good_live"
};

ConVar g_cMinTime;

public void OnPluginStart()
{
	LoadTranslations("playtime_ct.phrases");
	
	g_cMinTime = CreateConVar("pt_ct_min_time", "180000", "Minimal time (in secounds) to play as CT");
	
	AddCommandListener(Event_OnJoinTeam, "jointeam");
}

public Action Event_OnJoinTeam(int client, const char[] szCommand, int iArgCount)
{
	if(iArgCount < 1)
		return Plugin_Stop;
	
	char szData[2];
	GetCmdArg(1, szData, sizeof(szData));
	int iTeam = StringToInt(szData);
	
	if(iTeam != CS_TEAM_CT)
		return Plugin_Continue;
	
	if(PT_GetPlayTime(client) < g_cMinTime.IntValue)
	{
		CPrintToChat(client, "%t %t", "Tag", "Not enough playtime", g_cMinTime.IntValue/60);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
