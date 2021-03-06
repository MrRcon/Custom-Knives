/*  Custom Knife Models
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <clientprefs>
#include <cstrike>
#include <fpvm_interface>

#pragma newdecls required // let's go new syntax! 

int iTridaggerModel,iTridaggerSteelModel,iBlackDagger,iKabar,iOldKnife,iUltimateKnife, ifu, ides;
int KnifeSelection[MAXPLAYERS+1];
Handle g_hMySelection;
Handle g_hMyFirstJoin;
int showMenu[MAXPLAYERS+1] = 1;

#define DATA "2.3.1"

Handle cvar_time, timers, trie_times, cvar_times;
int g_veces, g_time;

public Plugin myinfo =
{
	name = "Custom Knife Models",
	author = "Mr.Derp & Franc1sco franug",
	description = "Custom Knife Models",
	version = DATA,
	url = "http://steamcommunity.com/id/franug/"
}

public void OnPluginStart()
{
	trie_times = CreateTrie();
	
	CreateConVar("sm_customknifemodels_version", DATA, "plugin info", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	cvar_time = CreateConVar("sm_customknifemodels_time", "20", "time in the round start that a normal client can use the !ck command. 0 = disabled.");
	cvar_times = CreateConVar("sm_customknifemodels_times", "5", "times in the map that a normal client can use the !ck command. 0 = disabled.");
	g_veces = GetConVarInt(cvar_times);
	g_time = GetConVarInt(cvar_time);
	HookConVarChange(cvar_time, OnConVarChanged);
	HookConVarChange(cvar_times, OnConVarChanged);
	
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	HookEvent("round_start", Event_Start);
	RegConsoleCmd("sm_customknife", Cmd_sm_customknife, "Knife Menu");
	RegConsoleCmd("sm_ck", Cmd_sm_customknife, "Knife Menu");
	g_hMySelection = RegClientCookie("ck_selection", "Knife Selection", CookieAccess_Protected);
	g_hMyFirstJoin = RegClientCookie("ck_firstjoin", "Knife Menu Show", CookieAccess_Protected);
	
	for (int i = MaxClients; i > 0; --i)
    {
        if (!AreClientCookiesCached(i))
        {
            continue;
        }
        
        OnClientCookiesCached(i);
    }
}

public void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == cvar_time)
	{
		g_time = StringToInt(newValue);
	}
	else if (convar == cvar_times)
	{
		g_veces = StringToInt(newValue);
	}
}

public void OnMapStart()
{
	ClearTrie(trie_times);
	
	iTridaggerModel = PrecacheModel("models/weaponf/v_knife_tridagger_v2.mdl");
	iTridaggerSteelModel = PrecacheModel("models/weaponf/v_knife_tridagger_steel.mdl");
	iBlackDagger = PrecacheModel("models/weaponf/v_knife_reaper.mdl");
	iKabar = PrecacheModel("models/weaponf/v_knife_kabar_v2.mdl");
	iOldKnife = PrecacheModel("models/weaponf/crashz.mdl");
	iUltimateKnife = PrecacheModel("models/weaponf/v_knife_ultimate.mdl");
	
	ifu = PrecacheModel("models/weapons/v_gongfu.mdl");
	ides = PrecacheModel("models/weapons/caleon1/screwdriver/v_knife_screwdriver.mdl");

	//Tridagger
	AddFileToDownloadsTable("models/weaponf/v_knife_tridagger_v2.dx90.vtx");
	AddFileToDownloadsTable("models/weaponf/v_knife_tridagger_v2.mdl");
	AddFileToDownloadsTable("models/weaponf/v_knife_tridagger_v2.vvd");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/tridagger.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/tridagger.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/tridagger_exp.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/tridagger_normal.vtf");
	//Tridagger Steel
	AddFileToDownloadsTable("models/weaponf/v_knife_tridagger_steel.dx90.vtx");
	AddFileToDownloadsTable("models/weaponf/v_knife_tridagger_steel.mdl");
	AddFileToDownloadsTable("models/weaponf/v_knife_tridagger_steel.vvd");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/steel/tridagger.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/steel/tridagger_elite.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/steel/tridagger_exp.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/tridagger/steel/tridagger_elite_normal.vtf");
	//Black Dagger
	AddFileToDownloadsTable("models/weaponf/v_knife_reaper.dx90.vtx");
	AddFileToDownloadsTable("models/weaponf/v_knife_reaper.mdl");
	AddFileToDownloadsTable("models/weaponf/v_knife_reaper.vvd");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/dtb_dagger/dtb.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/dtb_dagger/dtb.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/dtb_dagger/dtb_exp.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/dtb_dagger/dtb_normal.vtf");
	//Kabar
	AddFileToDownloadsTable("models/weaponf/v_knife_kabar_v2.dx90.vtx");
	AddFileToDownloadsTable("models/weaponf/v_knife_kabar_v2.mdl");
	AddFileToDownloadsTable("models/weaponf/v_knife_kabar_v2.vvd");
	AddFileToDownloadsTable("materials/models/weaponf/kabar/KABAR.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/kabar/kabar.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/kabar/kabar_G.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/kabar/kabar_n.vtf");
	//1.6 Knife
	AddFileToDownloadsTable("materials/models/weaponf/v_models/knife_ct/bowieknife.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/knife_ct/knife.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/knife_ct/knife_env.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/v_models/knife_ct/knife_normal.vtf");
	AddFileToDownloadsTable("models/weaponf/crashz.dx80.vtx");
	AddFileToDownloadsTable("models/weaponf/crashz.dx90.vtx");
	AddFileToDownloadsTable("models/weaponf/crashz.mdl");
	AddFileToDownloadsTable("models/weaponf/crashz.sw.vtx");
	AddFileToDownloadsTable("models/weaponf/crashz.vvd");
	//Ultimate Knife
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_1.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_1.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_2.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_2.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_3.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_3.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_4.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_4.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_5.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_5.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_6.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_6.vtf");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_7.vmt");
	AddFileToDownloadsTable("materials/models/weaponf/ultimate/texture_7.vtf");
	AddFileToDownloadsTable("models/weaponf/v_knife_ultimate.dx90.vtx");
	AddFileToDownloadsTable("models/weaponf/v_knife_ultimate.mdl");
	AddFileToDownloadsTable("models/weaponf/v_knife_ultimate.vvd");
	
	AddFileToDownloadsTable("models/weapons/v_gongfu.mdl");
	AddFileToDownloadsTable("models/weapons/v_gongfu.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_gongfu.vvd");

	AddFileToDownloadsTable("materials/models/weapons/gongfu/v_models/knife_t/tm_leet_lowerbody_variantb.vmt");
	AddFileToDownloadsTable("materials/models/weapons/gongfu/v_models/knife_t/tm_leet_lowerbody_variantb.vtf");
	AddFileToDownloadsTable("materials/models/weapons/gongfu/v_models/knife_t/tm_leet_lowerbody_variantb_exponent.vtf");
	AddFileToDownloadsTable("materials/models/weapons/gongfu/v_models/knife_t/tm_leet_lowerbody_variantb_normal.vtf");

	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/v_knife_screwdriver.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/v_knife_screwdriver.mdl");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/v_knife_screwdriver.vvd");

	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/yellow.vtf");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/black.vmt");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/black.vtf");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/metal.vmt");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/metal.vtf");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/yellow.vmt");
}

public Action Cmd_sm_customknife(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	ShowKnifeMenu(client);
	return Plugin_Handled;
}

void ShowKnifeMenu(int client)
{
	Menu menu_knives = new Menu(mh_KnifeHandler);
	SetMenuTitle(menu_knives, "Select Knife");

	AddMenuItem(menu_knives, "default", "Default Knife");
	AddMenuItem(menu_knives, "tridagger", "Tri-Dagger Black");
	AddMenuItem(menu_knives, "tridagger_steel", "Tri-Dagger Steel");
	AddMenuItem(menu_knives, "kabar", "Ka-Bar");
	AddMenuItem(menu_knives, "reaper", "Reaper Dagger");
	AddMenuItem(menu_knives, "css", "1.6/CSS Knife");
	AddMenuItem(menu_knives, "ultimate", "Bear Grylls Knife");
	AddMenuItem(menu_knives, "ifu", "Gong Fu");
	AddMenuItem(menu_knives, "ides", "Screwdriver");
	SetMenuPagination(menu_knives, 0);
	//SetMenuExitButton(menu_knives, true);
	DisplayMenu(menu_knives, client, 0);
}

public int mh_KnifeHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item
			if(GetUserAdmin(param1) == INVALID_ADMIN_ID)
			{
				if(g_time > 0 && timers == INVALID_HANDLE)
				{
				
					CPrintToChat(param1, "[{GREEN}Custom Knives{DEFAULT}] You can use this plugin only the first %i seconds of this round!", g_time);
					return;
				}
			
				char steamid[64];
				int times;
				GetClientAuthId(param1, AuthId_Steam2,  steamid, sizeof(steamid));
			
				if(!GetTrieValue(trie_times, steamid, times))
				{
					times = 0;
				}
				
				if(g_veces > 0 && times >= g_veces)
				{
					CPrintToChat(param1, "[{GREEN}Custom Knives{DEFAULT}] You can use this plugin only %i times in this map!", g_veces);
					return;
				}
				++times;
	
				SetTrieValue(trie_times, steamid, times);
			}
			
			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			SetKnife(param1, item);
			
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

void SetKnife(int param1, char[] item)
{
	char item2[16];
	if (StrEqual(item, "default"))
	{
		FPVMI_RemoveViewModelToClient(param1, "weapon_knife");
		KnifeSelection[param1] = 0;
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "tridagger"))
	{
		KnifeSelection[param1] = 1;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", iTridaggerModel);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "tridagger_steel"))
	{
		KnifeSelection[param1] = 2;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", iTridaggerSteelModel);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "kabar"))
	{
		KnifeSelection[param1] = 3;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", iKabar);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "reaper"))
	{
		KnifeSelection[param1] = 4;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", iBlackDagger);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "css"))
	{
		KnifeSelection[param1] = 5;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", iOldKnife);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "ultimate"))
	{
		KnifeSelection[param1] = 6;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", iUltimateKnife);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "ifu"))
	{
		KnifeSelection[param1] = 7;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", ifu);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "ides"))
	{
		KnifeSelection[param1] = 8;
		FPVMI_AddViewModelToClient(param1, "weapon_knife", ides);
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
}



public void OnClientCookiesCached(int client)
{
	char sCookieValue[11];
	GetClientCookie(client, g_hMySelection, sCookieValue, sizeof(sCookieValue));
	KnifeSelection[client] = StringToInt(sCookieValue);
	char sCookieValue2[11];
	GetClientCookie(client, g_hMyFirstJoin, sCookieValue2, sizeof(sCookieValue2));
	showMenu[client] = StringToInt(sCookieValue2);
}

public void OnClientPostAdminCheck(int client)
{
	if(AreClientCookiesCached(client)) SetKnife_saved(client);
}

void SetKnife_saved(int param1)
{
	switch (KnifeSelection[param1])
	{
		case 1:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iTridaggerModel);
		}
		case 2:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iTridaggerSteelModel);
		}
		case 3:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iKabar);
		}
		case 4:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iBlackDagger);
		}
		case 5:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iOldKnife);
		}
		case 6:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iUltimateKnife);	
		}
		case 7:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", ifu);	
		}
		case 8:
		{
			FPVMI_AddViewModelToClient(param1, "weapon_knife", ides);	
		}
		default:
		{
					// Blah
		}
	}
}

public Action Event_Start(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	if(timers != INVALID_HANDLE) KillTimer(timers);
	timers = CreateTimer(GetConVarInt(cvar_time) * 1.0, Passed);
	
}

public Action Passed(Handle timer)
{
	timers = INVALID_HANDLE;
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	
	if (AreClientCookiesCached(iClient))
	{
		if (showMenu[iClient] == 0)
		{
			showMenu[iClient] = 1;
			ShowKnifeMenu(iClient);
			SetClientCookie(iClient, g_hMyFirstJoin, "1");
		}
	}
}

stock bool IsValidClient(int client, bool nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}