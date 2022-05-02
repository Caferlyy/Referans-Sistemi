void OpenReferalMenu(int client)
{
    if(g_iData[client][ID] < 1)
    {
        TAS_PrintToChat(client,"%t", "Loading_Data");
        return;
    }
    Menu menu = new Menu(MainMenuHandler);
    char sBuff[128];

    menu.SetTitle("%T", "main_menu_title",client);

    bool time = g_iMinTime > g_iData[client][Time];

    FormatEx(sBuff, sizeof(sBuff), "%T", "Select_inviter",client);
    menu.AddItem(NULL_STRING, sBuff, (time || g_bInvited[client] || (INDEX(g_iTarget[client]) > 0) ) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

    FormatEx(sBuff, sizeof(sBuff), "%T", "Top10_Inviters",client);
    menu.AddItem(NULL_STRING, sBuff);

    if(time)
    {
        FormatEx(sBuff, sizeof(sBuff), "%T", "WhyICant",client);
        menu.AddItem(NULL_STRING, sBuff);
    }

    menu.Display(client, MENU_TIME_FOREVER);
    return;
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select)
    {
        switch(item)
        {
            case 0: OpenPlayersMenu(client);
            case 1: OpenTopPlayers(client);
            case 2: 
            {
                int lastseconds = g_iMinTime-g_iData[client][Time];
                int hours = (lastseconds/60)/60;
                TAS_PrintToChat(client,"%t", "InfoTime",hours,(lastseconds - (hours * 60 * 60)) / 60);
                OpenReferalMenu(client);
                return;
            }
        }
    }
    else if (action == MenuAction_End) 
        delete menu;
}

void OpenTopPlayers(int client)
{
    char szQuery[256];
    FormatEx(szQuery, sizeof(szQuery), "SELECT `name`,`invitations` FROM `referal_users` WHERE `invitations` > 0 ORDER BY `invitations` DESC LIMIT 10");   
    g_hDatabase.Query(SQL_Callback_TopPlayers, szQuery, USERID(client)); 
}

void OpenPlayersMenu(int client)
{
    Menu menu = new Menu(PlayersMenuHandler);
    char sUserId[8],sName[128];

    menu.ExitBackButton = true;
    menu.SetTitle("%T: \n", "Select_Player",client);

    for(int i = 1;i <= MaxClients;i++) if(IsClientInGame(i) && !IsFakeClient(i) && i != client)
    {
        IntToString(USERID(i), SZF(sUserId));
        FormatEx(SZF(sName), "%N",i);
        menu.AddItem(sUserId,sName,g_bInMenu[i] ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT );
    }

    if (!menu.ItemCount)
    {
        FormatEx(sName, sizeof(sName), "%T", "NoMatching",client);
        menu.AddItem(NULL_STRING,sName,ITEMDRAW_DISABLED);
    }

    menu.Display(client, MENU_TIME_FOREVER);
    return;
}

public int PlayersMenuHandler(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select)
    {
        char sUserId[11];
        GetMenuItem(menu, item,SZF(sUserId));  
        int userid = StringToInt(sUserId),
        target = INDEX(userid);
        if(target < 1 || (INDEX(g_iTarget[client]) > 0) || g_bInMenu[target])
        {
            TAS_PrintToChat(client,"%t", "not_available");
            OpenPlayersMenu(client);
            return;
        }
        g_bInMenu[target] = true;
        g_iTarget[client] = userid;
        g_iTarget[target] = USERID(client);
        TAS_PrintToChat(client,"%t", "thanks_for_choose");
        TAS_PrintToChat(target,"%t", "player_choose_you",client);
        SendMenuTo(target);
    }
    else if(action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        OpenReferalMenu(client);
    else if (action == MenuAction_End) 
        delete menu;
}

void SendMenuTo(int client)
{
    Menu menu = new Menu(ChooseMenuHandler);
    char sBuffer[128];
    
    menu.ExitButton = false;
    menu.SetTitle("%T: \n", "Select_Bonus",client);

    switch(g_iWorkType)
    {
        case 0: FormatEx(SZF(sBuffer),"%t","BonusCredits",g_iCredits);
        case 1: FormatEx(SZF(sBuffer),"%t","BonusVIP");
        case 2: FormatEx(SZF(sBuffer),"%t","BonusCommand");
        case 3: FormatEx(SZF(sBuffer),"%t","BonusPoint",g_iPoints);
    }
    if(g_iWorkType == 4)
    {
        FormatEx(SZF(sBuffer),"%t","BonusCredits",g_iCredits);
        menu.AddItem("c",sBuffer);
        FormatEx(SZF(sBuffer),"%t","BonusVIP");
        menu.AddItem("v",sBuffer);
    }
    else
        menu.AddItem("b",sBuffer);
        
    FormatEx(SZF(sBuffer), "%t", "Refuse");
    menu.AddItem("r",sBuffer);

    menu.Display(client, MENU_TIME_FOREVER);
    return;
}

public int ChooseMenuHandler(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select)
    {
        int sender = INDEX(g_iTarget[client]);
        if(sender < 1)
        {
            ResetData(client,0);
            TAS_PrintToChat(client,"%t", "choose_player_left");
            return;
        }
        char sbuffer[8],prize[128];
        menu.GetItem(item, SZF(sbuffer));
        switch(sbuffer[0])
        {
            case 'b':
            {
                switch(g_iWorkType)
                {
                    case 0: GiveCredits(client,prize);
                    case 1: GiveVip(client,prize);
                    case 2:
                    {
                        char sCommand[64],clientAuth[32],clientUser[11];
                        strcopy(sCommand,64,g_sCommand);
                        GetClientAuthId(client, AuthId_Steam2, clientAuth, sizeof(clientAuth));
                        FormatEx(clientUser, sizeof(clientUser), "#%d", USERID(client));
                        ReplaceString(sCommand, 64, "{Auth}", clientAuth);
                        ReplaceString(sCommand, 64, "{UserId}", clientUser);
                        ServerCommand(sCommand);
                        FormatEx(SZF(prize),"выполнение команды %s",sCommand);
                        TAS_PrintToChat(client,"%t", "GiveCommand");
                    }
                    case 3:
                    {
                        g_iData[client][Points] += g_iPoints;
                        TAS_PrintToChat(client,"%t", "GivePoints",g_iPoints);
                        FormatEx(SZF(prize),"%d поинтов, стало %d",g_iPoints,g_iData[client][Points]);
                    }
                }
            }
            case 'r':  
            {
                FormatEx(SZF(prize),"Ничего, т.к отказался от бонуса.");
                TAS_PrintToChat(client,"%t", "RefuseChat");
            }
            case 'c':  GiveCredits(client,prize);
            case 'v':  GiveVip(client,prize);
        }
        if(g_bLog)
            LogToFile(g_sLogPath, "Игрок %N выбрал %N, как пригласившего и %N получил %s",sender,client,client,prize);
        g_bInvited[sender] = true;
        g_iData[client][Invites]++;
        ResetData(client,sender);
        Call_StartForward(g_hOnPlayerChosen);
        Call_PushCell(client);
        Call_PushCell(sender);
        Call_Finish();
        SaveData(sender,client);
    }
    else if(action == MenuAction_Cancel)
    {
        int sender = INDEX(g_iTarget[client]);
        ResetData(client,sender < 1 ? 0 : sender);
    }
    else if (action == MenuAction_End) 
        delete menu;
}

void GiveVip(int client,char[] prize)
{
    FormatEx(prize,128,"вип %s на %d",g_sVIPGroup,g_iVIPTime);
    ServerCommand("sm_addvip \"steam\" \"#%d\" \"%d\" \"%s\"",GetClientUserId(client),g_iVIPTime,g_sVIPGroup);
    TAS_PrintToChat(client,"%t", "GiveVIP");
}

void GiveCredits(int client,char[] prize)
{
    FormatEx(prize,128,"%d кредитов",g_iCredits);
    Shop_GiveClientCredits(client, g_iCredits, -5);
    TAS_PrintToChat(client,"%t", "GiveCredits",g_iCredits);
}

void ResetData(int client,int sender)
{
    g_iTarget[client] = 0;
    if(sender > 0)
        g_iTarget[sender] = 0;
    g_bInMenu[client] = false;
}