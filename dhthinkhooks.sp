#pragma semicolon 1
#include <sourcemod>
#include <dukehacks>

#define PLUGIN_VERSION "0.0.1.5"

public Plugin:myinfo = 
{
	name = "think example",
	author = "L. Duke",
	description = "Think hooks",
	version = PLUGIN_VERSION,
	url = "www.LDuke.com"
}

public OnPluginStart()
{
	// setup convars
	CreateConVar("sm_thnk_version", PLUGIN_VERSION, "think hooks version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	// register the TraceAttackHook function to be notified of attack trace
	dhAddClientHook(CHK_PreThink, PreThinkHook);
	dhAddClientHook(CHK_PostThink, PostThinkHook);
}

public Action:PreThinkHook(client)
{

	SetEntPropFloat(client, Prop_Data, "m_flMaxspeed",400.0);
	
	// use Plugin_Continue (other options are ignored on PreThink hook)
	return Plugin_Continue;
}

public Action:PostThinkHook(client)
{
	
	
	// use Plugin_Continue (other options are ignored on PreThink hook)
	return Plugin_Continue;
}

