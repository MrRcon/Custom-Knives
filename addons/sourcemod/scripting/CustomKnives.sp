#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <clientprefs>
#include <cstrike>
#include <fpvm_interface>

#pragma newdecls required // let's go new syntax! 

int iTridaggerModel,iTridaggerSteelModel,iBlackDagger,iKabar,iOldKnife,iUltimateKnife;
int KnifeSelection[MAXPLAYERS+1];
Handle g_hMySelection;
Handle g_hMyFirstJoin;
int showMenu[MAXPLAYERS+1] = 1;

#define DATA "2.0"

public Plugin myinfo =
{
	name = "Custom Knife Models",
	author = "Mr.Derp & Franc1sco franug",
	description = "Custom Knife Models",
	version = DATA,
	url = "http://steamcommunity.com/id/iLoveAnime69"
}

public void OnPluginStart()
{
	CreateConVar("sm_customknifemodels_version", DATA, "plugin info", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
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

public void OnMapStart()
{
	iTridaggerModel = PrecacheModel("models/weapons/v_knife_tridagger_v2.mdl");
	iTridaggerSteelModel = PrecacheModel("models/weapons/v_knife_tridagger_steel.mdl");
	iBlackDagger = PrecacheModel("models/weapons/v_knife_reaper.mdl");
	iKabar = PrecacheModel("models/weapons/v_knife_kabar_v2.mdl");
	iOldKnife = PrecacheModel("models/weapons/crashz.mdl");
	iUltimateKnife = PrecacheModel("models/weapons/v_knife_ultimate.mdl");

	//Tridagger
	AddFileToDownloadsTable("models/weapons/v_knife_tridagger_v2.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_knife_tridagger_v2.mdl");
	AddFileToDownloadsTable("models/weapons/v_knife_tridagger_v2.vvd");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/tridagger.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/tridagger.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/tridagger_exp.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/tridagger_normal.vtf");
	//Tridagger Steel
	AddFileToDownloadsTable("models/weapons/v_knife_tridagger_steel.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_knife_tridagger_steel.mdl");
	AddFileToDownloadsTable("models/weapons/v_knife_tridagger_steel.vvd");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/steel/tridagger.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/steel/tridagger_elite.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/steel/tridagger_exp.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/tridagger/steel/tridagger_elite_normal.vtf");
	//Black Dagger
	AddFileToDownloadsTable("models/weapons/v_knife_reaper.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_knife_reaper.mdl");
	AddFileToDownloadsTable("models/weapons/v_knife_reaper.vvd");
	AddFileToDownloadsTable("materials/models/weapons/v_models/dtb_dagger/dtb.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/dtb_dagger/dtb.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/dtb_dagger/dtb_exp.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/dtb_dagger/dtb_normal.vtf");
	//Kabar
	AddFileToDownloadsTable("models/weapons/v_knife_kabar_v2.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_knife_kabar_v2.mdl");
	AddFileToDownloadsTable("models/weapons/v_knife_kabar_v2.vvd");
	AddFileToDownloadsTable("materials/models/weapons/kabar/KABAR.vmt");
	AddFileToDownloadsTable("materials/models/weapons/kabar/kabar.vtf");
	AddFileToDownloadsTable("materials/models/weapons/kabar/kabar_G.vtf");
	AddFileToDownloadsTable("materials/models/weapons/kabar/kabar_n.vtf");
	//1.6 Knife
	AddFileToDownloadsTable("materials/models/weapons/v_models/knife_ct/bowieknife.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/knife_ct/knife.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/knife_ct/knife_env.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/knife_ct/knife_normal.vtf");
	AddFileToDownloadsTable("models/weapons/crashz.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/crashz.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/crashz.mdl");
	AddFileToDownloadsTable("models/weapons/crashz.sw.vtx");
	AddFileToDownloadsTable("models/weapons/crashz.vvd");
	//Ultimate Knife
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_1.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_1.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_2.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_2.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_3.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_3.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_4.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_4.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_5.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_5.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_6.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_6.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_7.vmt");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/texture_7.vtf");
	AddFileToDownloadsTable("materials/models/weapons/ultimate/");
	AddFileToDownloadsTable("models/weapons/v_knife_ultimate.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_knife_ultimate.mdl");
	AddFileToDownloadsTable("models/weapons/v_knife_ultimate.vvd");
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
	Menu menu_knives = new Menu(mh_KnifeHandler, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(menu_knives, "Select Knife");

	AddMenuItem(menu_knives, "default", "Default Knife");
	AddMenuItem(menu_knives, "tridagger", "Tri-Dagger Black");
	AddMenuItem(menu_knives, "tridagger_steel", "Tri-Dagger Steel");
	AddMenuItem(menu_knives, "kabar", "Ka-Bar");
	AddMenuItem(menu_knives, "reaper", "Reaper Dagger");
	AddMenuItem(menu_knives, "css", "1.6/CSS Knife");
	AddMenuItem(menu_knives, "ultimate", "Bear Grylls Knife");

	DisplayMenu(menu_knives, client, 0);
}

public int mh_KnifeHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

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
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
					remove_knife(param1);
					FPVMI_RemoveViewModelToClient(param1, "weapon_knife");
					GivePlayerItem(param1, "weapon_knife");
		}
		KnifeSelection[param1] = 0;
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "tridagger"))
	{
		KnifeSelection[param1] = 1;
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
			remove_knife(param1);
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iTridaggerModel);
			GivePlayerItem(param1, "weapon_knife");
		}
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "tridagger_steel"))
	{
		KnifeSelection[param1] = 2;
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
			remove_knife(param1);
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iTridaggerSteelModel);
			GivePlayerItem(param1, "weapon_knife");
		}
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "kabar"))
	{
		KnifeSelection[param1] = 3;
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
			remove_knife(param1);
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iKabar);
			GivePlayerItem(param1, "weapon_knife");
		}
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "reaper"))
	{
		KnifeSelection[param1] = 4;
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
			remove_knife(param1);
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iBlackDagger);
			GivePlayerItem(param1, "weapon_knife");
		}
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "css"))
	{
		KnifeSelection[param1] = 5;
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
			remove_knife(param1);
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iOldKnife);
			GivePlayerItem(param1, "weapon_knife");
		}
		IntToString(KnifeSelection[param1], item2, sizeof(item2));
		SetClientCookie(param1, g_hMySelection, item2);
	}
	else if (StrEqual(item, "ultimate"))
	{
		KnifeSelection[param1] = 6;
		if (IsPlayerAlive(param1) && HasKnife(param1))
		{
			remove_knife(param1);
			FPVMI_AddViewModelToClient(param1, "weapon_knife", iUltimateKnife);
			GivePlayerItem(param1, "weapon_knife");
		}
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
		default:
		{
					// Blah
		}
	}
}

public Action remove_knife(int client)
{
	for (int i = 0; i <16; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);
		if(weapon == -1)
		{
			continue;
		} else if (Entity_ClassNameMatches(weapon, "weapon_knife", true) || Entity_ClassNameMatches(weapon, "weapon_bayonet", false))
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
		}
	}
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	
	CPrintToChat(iClient, "[{GREEN}Custom Knives{DEFAULT}] This server has custom knives! Type in {LIGHTBLUE}!ck{DEFAULT} or {LIGHTBLUE}!customknife{DEFAULT} to select your knife!");
	
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

bool HasKnife(int client)
{
	if (IsValidClient(client))
	{
		int weapon = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
		if (IsValidEntity(weapon))
		{
		    char weapon_name[32];
		    GetEntityClassname(weapon, weapon_name, 32);
		    if (StrContains(weapon_name, "knife", false))
		    {
		        return true;
		    }
		}
	}
	return false;
}

stock bool IsValidClient(int client, bool nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}

stock bool Entity_ClassNameMatches(int entity, char[] className, bool partialMatch=false)
{
	char entity_className[64];
	Entity_GetClassName(entity, entity_className, sizeof(entity_className));

	if (partialMatch) {
		return (StrContains(entity_className, className) != -1);
	}

	return StrEqual(entity_className, className);
}

stock int Entity_GetClassName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);	
}