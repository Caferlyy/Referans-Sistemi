#include <referal_system>
#include <tas>
#undef REQUIRE_PLUGIN
#include <shop>

#pragma semicolon 1
#pragma newdecls required

#include "referal_system/vars.sp"
#include "referal_system/database.sp"
#include "referal_system/config.sp"
#include "referal_system/menu.sp"
#include "referal_system/api.sp"

public Plugin myinfo = 
{
    name = "Referal System", 
    author = "Samoletik1337 aka asdf", 
    version = "1.1.1f", 
    url = "vk.com/samoletik2009"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("Shop_GiveClientCredits");
    CreateApi();
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations("referal_system.phrases");
    ReadConfig();
    ConnectToDB();
    RegAdminCmd("sm_reload_rscfg", ReloadCfg, ADMFLAG_ROOT);
    CreateTimer(1.0,view(Timer,SoNeed));
}

public Action ReloadCfg(int client,int argc)
{
	ReadConfig();
	ReplyToCommand(client, "Configuration reloaded!");
}

public void OnClientPostAdminCheck(int client)
{
    for(int i; i < 4;i++)
        g_iData[client][i] = 0;
    g_bInMenu[client] = false;
    g_iTarget[client] = 0;
    if(!g_hDatabase || IsFakeClient(client)) 
        return;
    char szQuery[256], 
         szAuth[32];
    GetClientAuthId(client, AuthId_Steam2, szAuth, sizeof(szAuth), true); 
    FormatEx(szQuery, sizeof(szQuery), "SELECT `id`, `points`, `invitations`,`invite`,`playedtime` FROM `referal_users` WHERE `auth` = '%s';", szAuth);  
    g_hDatabase.Query(SQL_Callback_SelectClient, szQuery, USERID(client)); 
}

public void Info(Timer blya_y,int client)
{
    client = INDEX(client);
    if(client < 1)
        return;
    if(g_bInfo)
        TAS_PrintToChat(client,"%t", "PrintInfo");
    if(g_bMenu)
        OpenReferalMenu(client);
}

public Action ReferalMenyo(int client,int args)
{
    if(client)
        OpenReferalMenu(client);
    return Plugin_Handled;
}

void AddTime()
{
    for(int i = 1; i <= MaxClients;i++) if(IsClientInGame(i) && !IsFakeClient(i) && g_iData[i][ID])
        g_iData[i][Time]++;
}

public void OnClientDisconnect(int client)
{
    if(!g_hDatabase || IsFakeClient(client) || g_iData[client][ID] < 1) 
        return;
    char szName[MAX_NAME_LENGTH*2+1],szQuery[512];
    GetClientName(client, szQuery, MAX_NAME_LENGTH);
    g_hDatabase.Escape(szQuery, szName, sizeof(szName)); 
    FormatEx(szQuery, sizeof(szQuery), "UPDATE `referal_users` SET `points` = %i, `invitations` = %i,`invite` = %b,`name` = '%s',`lastvisit` = %i,`playedtime` = %i WHERE `id` = %i;", g_iData[client][Points], g_iData[client][Invites],g_bInvited[client],szName, GetTime(),g_iData[client][Time],g_iData[client][ID]);
    g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery);
}