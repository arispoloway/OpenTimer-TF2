#define FWD		0
#define SIDE	1

public Action OnPlayerRunCmd(	int client,
								int &buttons,
								int &impulse, // Not used
								float vel[3],
								float angles[3],
								int &weapon )
{
	if ( !IsPlayerAlive( client ) ) return Plugin_Continue;
	
	
	// Shared between recording and mimicing.
#if defined RECORD
	static int		iFrame[FRAME_SIZE];
	static float	vecPos[3];
#endif
	
	if ( !IsFakeClient( client ) )
	{
		bool bOnGround = ( GetEntityFlags( client ) & FL_ONGROUND ) ? true : false;
		
		//MoveType iMoveType = GetEntityMoveType( client );
		
		if ( bOnGround )
		{

			
#if defined ANTI_DOUBLESTEP
			if ( g_bClientHoldingJump[client] ) buttons |= IN_JUMP;
#endif
		}
		// AUTOHOP
		/*else if ( bIsInValidAir && !HasScroll( client ) )
		{
			buttons &= ~IN_JUMP;
			//SetClientOldButtons( client, GetClientOldButtons( client ) & ~IN_JUMP );
		}*/
		
		// Reset field of view in case they reloaded their gun.
		if ( buttons & IN_RELOAD )
		{
			SetClientFOV( client, 90 );
		}
		
		// Rest what we do is done in running only.
		if ( g_iClientState[client] != STATE_RUNNING ) return Plugin_Continue;
		
		
		///////////////
		// RECORDING //
		///////////////
#if defined RECORD
		if ( g_bClientRecording[client] && g_hClientRec[client] != null )
		{
			// Remove distracting buttons.
			iFrame[FRAME_FLAGS] = ( buttons & IN_DUCK ) ? FRAMEFLAG_CROUCH : 0;
			
			// Do weapons.
			// 0 = No changed weapon.
#if defined RECORD_SAVE_WEPSWITCHING
			if ( weapon )
			{
				switch ( FindSlotByWeapon( client, weapon ) )
				{
					case SLOT_PRIMARY :
					{
						iFrame[FRAME_FLAGS] |= FRAMEFLAG_PRIMARY;
					}
					case SLOT_SECONDARY :
					{
						iFrame[FRAME_FLAGS] |= FRAMEFLAG_SECONDARY;
					}
					case SLOT_MELEE :
					{
						iFrame[FRAME_FLAGS] |= FRAMEFLAG_MELEE;
					}
				}
			}
#endif
#if defined RECORD_SAVE_ATTACKS
			if ( buttons & IN_ATTACK )
			{
				iFrame[FRAME_FLAGS] |= FRAMEFLAG_ATTACK;
			}
			else if ( buttons & IN_ATTACK2 )
			{
				iFrame[FRAME_FLAGS] |= FRAMEFLAG_ATTACK2;
			}
#endif

			ArrayCopy( angles, iFrame[FRAME_ANG], 2 );
			
			GetEntPropVector( client, Prop_Send, "m_vecOrigin", vecPos );
			ArrayCopy( vecPos, iFrame[FRAME_POS], 3 );
			
			
			// Is our recording longer than max length.
			if ( ++g_nClientTick[client] > g_iRecMaxLength[ g_iClientRun[client] ][ g_iClientStyle[client] ][ g_iClientMode[client] ] )
			{
				if ( g_nClientTick[client] >= RECORDING_MAX_LENGTH )
					PRINTCHAT( client, CHAT_PREFIX..."Your time was too long to be recorded!" );
				
				g_nClientTick[client] = 0;
				g_bClientRecording[client] = false;
				
				if ( g_hClientRec[client] != null )
				{
					delete g_hClientRec[client];
					g_hClientRec[client] = null;
				}
			}
			else
			{
				g_hClientRec[client].PushArray( iFrame, view_as<int>( RecData ) );
			}
		}
#endif

		
		
		
		// MODES
		// No longer check with buttons.
		// Ignore ladders and noclip.
		//if ( iMoveType == MOVETYPE_WALK || ( !g_bIgnoreLadderStyle && iMoveType == MOVETYPE_LADDER ) )
		//{
		//}
		
		switch (g_iClientStyle[client]){
			case STYLE_CROUCHED:
			{
				buttons |= IN_DUCK;
			}
		}
			

		
		return Plugin_Continue;
	}
	
	
#if defined RECORD
	//////////////
	// PLAYBACK //
	//////////////
	if ( !g_bPlayback ) return Plugin_Handled;
	
	if ( !g_bClientMimicing[client] ) return Plugin_Handled;
	
	if ( g_hRec[ g_iClientRun[client] ][ g_iClientStyle[client] ][ g_iClientMode[client] ] == null ) return Plugin_Handled;
	
	
	if ( g_nClientTick[client] == PLAYBACK_PRE )
	{
		g_hRec[ g_iClientRun[client] ][ g_iClientStyle[client] ][ g_iClientMode[client] ].GetArray( 0, iFrame, view_as<int>( RecData ) );
		
		buttons = ( iFrame[FRAME_FLAGS] & FRAMEFLAG_CROUCH ) ? IN_DUCK : 0;
		
		ArrayCopy( iFrame[FRAME_POS], vecPos, 3 );
		ArrayCopy( iFrame[FRAME_ANG], angles, 2 );
		
		TeleportEntity( client, vecPos, angles, g_vecNull );
		
		return Plugin_Changed;
	}
	
	if ( g_nClientTick[client] < g_iRecLen[ g_iClientRun[client] ][ g_iClientStyle[client] ][ g_iClientMode[client] ] )
	{
		g_hRec[ g_iClientRun[client] ][ g_iClientStyle[client] ][ g_iClientMode[client] ].GetArray( g_nClientTick[client], iFrame, view_as<int>( RecData ) );
		
		// Do buttons and weapons.
		buttons = ( iFrame[FRAME_FLAGS] & FRAMEFLAG_CROUCH ) ? IN_DUCK : 0;
		
#if defined RECORD_SAVE_WEPSWITCHING
		static int wep;
		if ( iFrame[FRAME_FLAGS] & FRAMEFLAG_PRIMARY )
		{
			if ( (wep = GetPlayerWeaponSlot( client, SLOT_PRIMARY )) > 0 )
			{
				weapon = wep;
			}
		}
		else if ( iFrame[FRAME_FLAGS] & FRAMEFLAG_SECONDARY )
		{
			if ( (wep = GetPlayerWeaponSlot( client, SLOT_SECONDARY )) > 0 )
			{
				weapon = wep;
			}
		}
		else if ( iFrame[FRAME_FLAGS] & FRAMEFLAG_MELEE )
		{
			if ( (wep = GetPlayerWeaponSlot( client, SLOT_MELEE )) > 0 )
			{
				weapon = wep;
			}
		}
#endif // RECORD_SAVE_WEPSWITCHING
#if defined RECORD_SAVE_ATTACKS
		if ( iFrame[FRAME_FLAGS] & FRAMEFLAG_ATTACK )
		{
			buttons |= IN_ATTACK;
		}
		else if ( iFrame[FRAME_FLAGS] & FRAMEFLAG_ATTACK2 )
		{
			buttons |= IN_ATTACK2;
		}
#endif // RECORD_SAVE_ATTACKS
		
		vel = g_vecNull;
		ArrayCopy( iFrame[FRAME_ANG], angles, 2 );
		
		
		ArrayCopy( iFrame[FRAME_POS], vecPos, 3 );
		
		static float vecPrevPos[3];
		GetEntPropVector( client, Prop_Send, "m_vecOrigin", vecPrevPos );
		
		if ( GetVectorDistance( vecPos, vecPrevPos, true ) > MIN_TICK_DIST_SQ )
		{
			TeleportEntity( client, vecPos, angles, NULL_VECTOR );
		}
		else
		{
			// Make the velocity!
			static float vecDirVel[3];
			vecDirVel[0] = ( vecPos[0] - vecPrevPos[0] ) * g_flTickRate;
			vecDirVel[1] = ( vecPos[1] - vecPrevPos[1] ) * g_flTickRate;
			vecDirVel[2] = ( vecPos[2] - vecPrevPos[2] ) * g_flTickRate;
			
			
			TeleportEntity( client, NULL_VECTOR, angles, vecDirVel );
			
			// If server ops want more responsive but choppy movement, here it is.
			if ( !g_bSmoothPlayback )
				SetEntPropVector( client, Prop_Send, "m_vecOrigin", vecPos );
		}
		
		// Are we done with our recording?
		if ( ++g_nClientTick[client] >= g_iRecLen[ g_iClientRun[client] ][ g_iClientStyle[client] ][ g_iClientMode[client] ] )
		{
			CreateTimer( 2.0, Timer_Rec_Restart, client, TIMER_FLAG_NO_MAPCHANGE );
		}
		
		return Plugin_Changed;
	}
#endif // RECORD
	
	// Freezes bots when they don't need to do anything. I.e. at the start/end of the run.
	return Plugin_Handled;
}