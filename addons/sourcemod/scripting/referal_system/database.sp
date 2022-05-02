void ConnectToDB()
{
    if (SQL_CheckConfig("referal_system"))
        Database.Connect(OnDBConnect, "referal_system",0);
    else
    {
        KeyValues hKeyValues = new KeyValues(NULL_STRING);
        hKeyValues.SetString("driver", "sqlite");
        hKeyValues.SetString("database", "referal_system");

        char szError[256];
        g_hDatabase = SQL_ConnectCustom(hKeyValues, SZF(szError),false);

        delete hKeyValues;
    
        OnDBConnect(g_hDatabase, szError, 1);
    }
}

public void OnDBConnect(Database hDatabase, const char[] szError, any data)
{
    if (hDatabase == null || szError[0])
    {
        SetFailState("OnDBConnect %s", szError);
        return;
    }

    g_hDatabase = hDatabase;
    
    if (data == 1)
        g_bMySQL = false;
    else
    {
        char szDriver[8];
        g_hDatabase.Driver.GetIdentifier(SZF(szDriver));
        g_bMySQL = (szDriver[0] == 'm');
    }
    
    CreateTables();
}

void CreateTables()
{
    if (g_bMySQL)
    {
        g_hDatabase.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `referal_users` (\
                                                    `id` int(10) NOT NULL AUTO_INCREMENT,\
                                                    `auth` varchar(64) DEFAULT NULL,\
                                                    `name` varchar(64) DEFAULT 'unknown',\
                                                    `points` int(10) NOT NULL DEFAULT '0',\
                                                    `invitations` int(10) NOT NULL DEFAULT '0',\
                                                    `invite` int(1) NOT NULL DEFAULT '0', \
                                                    `lastvisit` int(10) unsigned NOT NULL DEFAULT '0',\
                                                    `playedtime` int(10) unsigned NOT NULL DEFAULT '0',\
                                                    PRIMARY KEY (`id`)\
                                                    ) DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ");
    }
    else
    {
        g_hDatabase.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `referal_users`(\
                                                    `id` INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                    `auth` VARCHAR(64) NOT NULL default 'unknown', \
                                                    `name` VARCHAR(64) NOT NULL default 'unknown', \
                                                    `points` INTEGER NOT NULL default 0, \
                                                    `invitations` INTEGER NOT NULL default 0, \
                                                    `invite` INTEGER NOT NULL default 0, \
                                                    `lastvisit` INTEGER UNSIGNED NOT NULL default 0,\
                                                    `playedtime` INTEGER UNSIGNED NOT NULL default 0)");
    }
}

public void SQL_Callback_TableCreate(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
    if (szError[0])
    {
        SetFailState("SQL_Callback_TableCreate: %s", szError);
        return;
    }

    Call_StartForward(g_hOnPluginLoaded);
    Call_Finish();
    g_bLoaded = true;
    
    if(!g_bMySQL)
        return;

    g_hDatabase.SetCharset("utf8");
}

public void SQL_Callback_ErrorCheck(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
    if (szError[0])
        LogError("SQL_Callback_ErrorCheck: %s", szError);
}

public void SQL_Callback_SelectClient(Database hDatabase, DBResultSet hResults, const char[] sError, int client)
{
    if(sError[0]) 
    {
        LogError("SQL_Callback_SelectClient: %s", sError); 
        return; 
    }
    int userid = client;
    client = INDEX(client);
    if(client < 1)
        return;
    char szQuery[256];

    if(hResults.HasResults && hResults.FetchRow()) 
    {
        g_iData[client][ID]      = hResults.FetchInt(0);
        g_iData[client][Points]  = hResults.FetchInt(1);
        g_iData[client][Invites] = hResults.FetchInt(2);
        g_bInvited[client] = view(bool,hResults.FetchInt(3));
        g_iData[client][Time] = hResults.FetchInt(4);
        if(!g_bInvited[client] && g_iData[client][Time] > g_iMinTime && (g_bInfo || g_bMenu))
            CreateTimer(g_fTime,view(Timer,Info),userid,TIMER_FLAG_NO_MAPCHANGE);
    }
    else
    {
        char szAuth[32], szName[MAX_NAME_LENGTH*2+1];
        GetClientName(client, szQuery, MAX_NAME_LENGTH);
        for (int i = 0, len = strlen(szQuery), CharBytes; i < len;)
            if((CharBytes = GetCharBytes(szQuery[i])) == 4)	{
                len -= 4;
                for (int u = i; u <= len; u++)
                    szQuery[u] = szQuery[u+4];
            }	
            else 
                i += CharBytes;
        g_hDatabase.Escape(szQuery, szName, sizeof(szName)); 
        GetClientAuthId(client, AuthId_Steam2, szAuth, sizeof(szAuth));
        FormatEx(szQuery, sizeof(szQuery), "INSERT INTO `referal_users` (`auth`, `name`,`lastvisit`) VALUES ( '%s', '%s','%d');", szAuth, szName,GetTime());
        g_hDatabase.Query(SQL_Callback_CreateClient, szQuery, USERID(client));
    }
}

public void SQL_Callback_CreateClient(Database hDatabase, DBResultSet results, const char[] szError, int client)
{
    if(szError[0])
    {
        LogError("SQL_Callback_CreateClient: %s", szError);
        return;
    }
    int userid = client;
    client = INDEX(client);
    if(client)
    {
        g_iData[client][ID] = results.InsertId;
        if(!g_iMinTime && (g_bInfo || g_bMenu) )
            CreateTimer(g_fTime,view(Timer,Info),userid,TIMER_FLAG_NO_MAPCHANGE);
    }
}

public void SQL_Callback_TopPlayers(Database hDatabase, DBResultSet hResults, const char[] sError, int client)
{
    if(sError[0]) 
    {
        LogError("SQL_Callback_TopPlayers: %s", sError); 
        return; 
    }
    client = INDEX(client);
    if(client < 1)
        return;
    char sName[MAX_NAME_LENGTH],sTemp[512],sBuffer[256];
    Menu menu = new Menu(ToppMenuHandler);
    menu.ExitButton = false;  
    int i,invitations;
    while(hResults.FetchRow())
    {
        i++;
        hResults.FetchString(0, sName, sizeof(sName));
        invitations = hResults.FetchInt(1);
        FormatEx(sBuffer, sizeof(sBuffer), "#%d | %s [%d] \n",i, sName, invitations);
        if(strlen(sTemp) + strlen(sBuffer) < 512)
        {
            Format(sTemp, sizeof(sTemp), "%s%s", sTemp, sBuffer);
            sBuffer = "\0";
        }
    } 
    Format(sTemp, sizeof(sTemp), "==============\n%s \n==============\n ", sTemp);
    menu.SetTitle(sTemp);
    if(!i)
    {
        FormatEx(sTemp, sizeof(sTemp), "%T", "NoMatching",client);
        menu.AddItem(NULL_STRING,sTemp,ITEMDRAW_DISABLED);
    }

    FormatEx(sTemp, sizeof(sTemp), "%T", "Back",client);
    menu.AddItem(NULL_STRING,sTemp);
    menu.Display(client, MENU_TIME_FOREVER);
}

public int ToppMenuHandler(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) 
        delete menu;
    else if(action == MenuAction_Select)
        OpenReferalMenu(client);     
}

void SaveData(int sender,int client)
{
    char szQuery[512];
    FormatEx(szQuery, sizeof(szQuery), "UPDATE `referal_users` SET `points` = %i, `invitations` = %i WHERE `id` = %i;", g_iData[client][Points], g_iData[client][Invites],g_iData[client][ID]);
    g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery);
    FormatEx(szQuery, sizeof(szQuery), "UPDATE `referal_users` SET `invite` = %b WHERE `id` = %i;", g_bInvited[sender],g_iData[sender][ID]);
    g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery);
}

void SoNeed(){
    for(int i = 1;i <= MaxClients;i++) if(IsClientInGame(i) && !IsFakeClient(i))
        OnClientPostAdminCheck(i);
}