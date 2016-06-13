float EULERS_NUMBER = 2.71828182845904523536028747135266249775724709369995;

//We run this function any time a user finishes either their first run, or a run that breaks a PB/record
public void UpdatePointTotals(int client, char[] szName, int run, int style, int mode, float flNewTime, float flOldBestTime, float flPrevMapBest)
{	
	//SpamChatShit();
	//First check to see if user takes WR
	if ((flNewTime < flPrevMapBest) && !(flNewTime <= TIME_INVALID))
	{	
		PrintToChatAll("WR Broken, %s receives %i points. All other users adjusted", szName, PointsAwarded(flNewTime, flNewTime, getCurrentCountByRun(run)));
	}
	
	//Next check to see if they instead beat their current PB
	else if ((flNewTime <flOldBestTime) && !(flNewTime <= TIME_INVALID) && (flOldBestTime <= TIME_INVALID))
	{		
		PrintToChatAll("PB Broken, %s improves from %i points to %i points. All other users adjusted", szName, PointsAwarded(flPrevMapBest, flOldBestTime, getCurrentCountByRun(run)), PointsAwarded(flPrevMapBest, flNewTime, getCurrentCountByRun(run)));
	}
	
	//If neither are true, it's a new run
	else
	{
		PrintToChatAll("WR Broken, %s receives %i points. All other users adjusted", szName, PointsAwarded(flPrevMapBest, flNewTime, getCurrentCountByRun(run)));			
	}
}

public void SpamChatShit()
{
	for (int i = 0; i < MAX_DB_RECORDS;i++)
	{
		PrintToChatAll("Entry %i, time is %f", i, g_flMapDuringRankings[0][i][1]);
		
		if (g_flMapDuringRankings[0][i][1] <= TIME_INVALID)
		{
			break;
		}
	}
}

public int getCurrentCountByRun (int run)
{
	int ranks = 0;
	
	//Loop through max array size
	for (int i = 0; i < MAX_DB_RECORDS;i++)
	{
		//If it's a valid time, we add as much
		if (!g_flMapDuringRankings[run][i][1] <= TIME_INVALID)
		{
			ranks++;
		}
		//If it is not a valid time, we have reached the end of the array, don't check all remaining, just break
		else
		{
			break;
		}		
	}
	PrintToChatAll("Found %i ranks for run %i", ranks, run);
	return ranks;
}

//Tom "Tim" Sinister's point weight scaling algorithm
public int PointsAwarded(float map_wr, float map_pb, int map_completions)
{
	float wr_points=0.0;
	float scale_factor=0.0;
	int points_awarded=0;
	
	wr_points = 200 *(50 + Logarithm(map_completions, EULERS_NUMBER));
	
	scale_factor = map_wr / (map_wr + (map_pb - map_wr) * Logarithm(map_completions, EULERS_NUMBER));
	
	points_awarded = RoundFloat(wr_points * scale_factor);
	
	//PrintToChatAll("Calculation says, you earn %i points!", points_awarded);
	
	return points_awarded;
}