void ReadConfig()
{
    char sBuff[128];
    KeyValues kv = new KeyValues("Settings");

    BuildPath(Path_SM, sBuff, sizeof(sBuff), "configs/referal_system.ini");
    if(!kv.ImportFromFile(sBuff))
    {
        LogMessage("Configuration file is missing!");
        LogMessage("Loading default settings.");
    }
    kv.Rewind();

    g_iWorkType = kv.GetNum("referal_type", 0);
    g_iCredits  = kv.GetNum("referal_credits", 1000);
    g_iVIPTime  = kv.GetNum("referal_viptime", 3600);
    g_iPoints   = kv.GetNum("referal_points", 1);  
    g_iMinTime  = kv.GetNum("referal_minimaltime", 86400); 
    g_fTime     = kv.GetFloat("referal_menutime", 5.0); 
    kv.GetString("referal_vipgroup", g_sVIPGroup, 64);
    kv.GetString("referal_command", g_sCommand, 64);  
    kv.GetString("referal_commands", sBuff, 128);
    g_bLog = view(bool,kv.GetNum("referal_log", 1));  
    g_bInfo = view(bool,kv.GetNum("referal_info", 1));  
    g_bMenu = view(bool,kv.GetNum("referal_menu", 0));  

    char buffer2[8][16];
    int max = ExplodeString(sBuff, ";", buffer2, 8, 16);
    for (int i; i < max; i++)
        RegConsoleCmd(buffer2[i],ReferalMenyo);

    kv.GetString("referal_log_path", g_sLogPath, 128);
    delete kv;

    if(g_iMinTime)
    {
        if(g_hTimer)    
        {
            KillTimer(g_hTimer); 
            g_hTimer = null;       
        }
        g_hTimer = CreateTimer(1.0,view(Timer,AddTime),_,TIMER_REPEAT);
    }
}