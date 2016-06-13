public void BlockBounces(int client)
{	
	//KICK THOSE CHEATERS
	QueryClientConVar(client, "cl_showpos", ConVarQueryFinished:BlockShowpos, client);
	QueryClientConVar(client, "cl_pitchdown", ConVarQueryFinished:BlockPitchDown, client);
	QueryClientConVar(client, "cl_pitchup", ConVarQueryFinished:BlockPitchUp, client);	
}

public void BlockShowpos(QueryCookie cookie, int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
    if(!StrEqual(cvarValue, "0"))
    {
        KickClient(client, "The use of cl_showpos on this server is disabled. Please disable it before re-connecting to the server");
    }
}
public void BlockPitchDown(QueryCookie cookie, int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
    if(!StrEqual(cvarValue, "89"))
    {
        KickClient(client, "The use of cl_pitchdown on this server is disabled. Please disable it before re-connecting to the server");
    }
}public void BlockPitchUp(QueryCookie cookie, int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
    if(!StrEqual(cvarValue, "89"))
    {
        KickClient(client, "The use of cl_pitchup on this server is disabled. Please disable it before re-connecting to the server");
    }
}

/*public void BlockBounces(int client)
{
	//cl_showpos
	char showPos[8];
	if (GetClientInfo(client, "name", showPos, sizeof(showPos)))
	{
		//Return successful	
		PrintToChatAll("Value: \"%s\"", showPos);
	}
	else
	{
		PrintToChatAll("Error checking showpos of client %i", client);
	}
}
*/