#if defined _tas_included_
  #endinput
#endif
#define _tas_included_

EngineVersion g_Engine;
bool g_bChecked,g_bProtobuf;
StringMap hColorsTrie;
StringMapSnapshot hTrieSnapshot;

stock void TAS_PrintToChat(int client,const char[] text, any ...) 
{
    if(!g_bChecked)
        GetGame();
    char sMessage[1024],sBuffer[32],sColor[32];
    SetGlobalTransTarget(client);
    VFormat(sMessage, sizeof(sMessage), text, 3); 
    Format(sMessage, sizeof(sMessage), g_Engine == Engine_CSGO ? " \x01%s":"\x01%s", sMessage);
    int tlength = strlen(sMessage)+128; 
    ReplaceString(sMessage, tlength, "\\n", "\n");    
    for(int i,hlength = hTrieSnapshot.Length; i < hlength; i++) 
    {
        hTrieSnapshot.GetKey(i, sBuffer, sizeof(sBuffer));
        hColorsTrie.GetString(sBuffer, sColor, sizeof(sColor));
        ReplaceString(sMessage, tlength, sBuffer, sColor);
    }
    SayText2(client,0,sMessage);
}

stock void TAS_PrintToChatAll(const char[] text, any ...) 
{
    if(!g_bChecked)
        GetGame();
    char sMessage[1024],sBuffer[32],sColor[32];
    VFormat(sMessage, sizeof(sMessage), text, 2);   
    Format(sMessage, sizeof(sMessage), g_Engine == Engine_CSGO ? " \x01%s":"\x01%s", sMessage);
    int tlength = strlen(sMessage)+128;   
    ReplaceString(sMessage, tlength, "\\n", "\n");   
    for(int i,hlength = hTrieSnapshot.Length; i < hlength; i++) 
    {
        hTrieSnapshot.GetKey(i, sBuffer, sizeof(sBuffer));
        hColorsTrie.GetString(sBuffer, sColor, sizeof(sColor));
        ReplaceString(sMessage, tlength, sBuffer, sColor);
    }
    for(int i = 1; i <= MaxClients;i++) if(IsClientInGame(i) && !IsFakeClient(i))
    {
        SetGlobalTransTarget(i);
        SayText2(i,0,sMessage);   
    }
}

stock void SayText2(int client, int author = 0, const char[] sMessage)
{
    int[] clients = new int[1];
    clients[0] = client;
    
    Handle hBuffer;
    hBuffer = StartMessage("SayText2", clients, 1, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
    if(g_bProtobuf)
    {
        PbSetInt(hBuffer, "ent_idx", author);
        PbSetBool(hBuffer, "chat", true);
        PbSetString(hBuffer, "msg_name", sMessage);
        PbAddString(hBuffer, "params", "");
        PbAddString(hBuffer, "params", "");
        PbAddString(hBuffer, "params", "");
        PbAddString(hBuffer, "params", "");
    }
    else
    {
        BfWriteByte(hBuffer, author);
        BfWriteByte(hBuffer, true);
        BfWriteString(hBuffer, sMessage);
    }
    EndMessage();
}

stock void GetGame()
{
    g_Engine = GetEngineVersion();
    g_bChecked = true;
    InitColors(g_Engine == Engine_SourceSDK2006 ? Engine_SourceSDK2006:g_Engine == Engine_CSGO ? Engine_CSGO:Engine_CSS); 
    hTrieSnapshot = hColorsTrie.Snapshot(); 
    g_bProtobuf = (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf);
}

stock void InitColors(EngineVersion engine)
{
    hColorsTrie = new StringMap();
    if(engine == Engine_CSS)
    {
        hColorsTrie.SetString("{aliceblue}", "\x07F0F8FF");
        hColorsTrie.SetString("{allies}", "\x074D7942");
        hColorsTrie.SetString("{antiquewhite}", "\x07FAEBD7");
        hColorsTrie.SetString("{aqua}", "\x0700FFFF");
        hColorsTrie.SetString("{aquamarine}", "\x077FFFD4");
        hColorsTrie.SetString("{axis}", "\x07FF4040");
        hColorsTrie.SetString("{azure}", "\x07007FFF");
        hColorsTrie.SetString("{beige}", "\x07F5F5DC");
        hColorsTrie.SetString("{bisque}", "\x07FFE4C4");
        hColorsTrie.SetString("{black}", "\x07000000");
        hColorsTrie.SetString("{blanchedalmond}", "\x07FFEBCD");
        hColorsTrie.SetString("{blue}", "\x0799CCFF");
        hColorsTrie.SetString("{blueviolet}", "\x078A2BE2");
        hColorsTrie.SetString("{brown}", "\x07A52A2A");
        hColorsTrie.SetString("{burlywood}", "\x07DEB887");
        hColorsTrie.SetString("{cadetblue}", "\x075F9EA0");
        hColorsTrie.SetString("{chartreuse}", "\x077FFF00");
        hColorsTrie.SetString("{chocolate}", "\x07D2691E");
        hColorsTrie.SetString("{community}", "\x0770B04A");
        hColorsTrie.SetString("{coral}", "\x07FF7F50");
        hColorsTrie.SetString("{cornflowerblue}", "\x076495ED");
        hColorsTrie.SetString("{cornsilk}", "\x07FFF8DC");
        hColorsTrie.SetString("{crimson}", "\x07DC143C");
        hColorsTrie.SetString("{cyan}", "\x0700FFFF");
        hColorsTrie.SetString("{darkblue}", "\x0700008B");
        hColorsTrie.SetString("{darkcyan}", "\x07008B8B");
        hColorsTrie.SetString("{darkgoldenrod}", "\x07B8860B");
        hColorsTrie.SetString("{darkgray}", "\x07A9A9A9");
        hColorsTrie.SetString("{darkgreen}", "\x07006400");
        hColorsTrie.SetString("{darkkhaki}", "\x07BDB76B");
        hColorsTrie.SetString("{darkmagenta}", "\x078B008B");
        hColorsTrie.SetString("{darkolivegreen}", "\x07556B2F");
        hColorsTrie.SetString("{darkorange}", "\x07FF8C00");
        hColorsTrie.SetString("{darkorchid}", "\x079932CC");
        hColorsTrie.SetString("{darkred}", "\x078B0000");
        hColorsTrie.SetString("{darksalmon}", "\x07E9967A");
        hColorsTrie.SetString("{darkseagreen}", "\x078FBC8F");
        hColorsTrie.SetString("{darkslateblue}", "\x07483D8B");
        hColorsTrie.SetString("{darkslategray}", "\x072F4F4F");
        hColorsTrie.SetString("{darkturquoise}", "\x0700CED1");
        hColorsTrie.SetString("{darkviolet}", "\x079400D3");
        hColorsTrie.SetString("{deeppink}", "\x07FF1493");
        hColorsTrie.SetString("{deepskyblue}", "\x0700BFFF");
        hColorsTrie.SetString("{dimgray}", "\x07696969");
        hColorsTrie.SetString("{dodgerblue}", "\x071E90FF");
        hColorsTrie.SetString("{firebrick}", "\x07B22222");
        hColorsTrie.SetString("{floralwhite}", "\x07FFFAF0");
        hColorsTrie.SetString("{forestgreen}", "\x07228B22");
        hColorsTrie.SetString("{fuchsia}", "\x07FF00FF");
        hColorsTrie.SetString("{fullblue}", "\x070000FF");
        hColorsTrie.SetString("{fullred}", "\x07FF0000");
        hColorsTrie.SetString("{gainsboro}", "\x07DCDCDC");
        hColorsTrie.SetString("{genuine}", "\x074D7455"); 
        hColorsTrie.SetString("{ghostwhite}", "\x07F8F8FF");
        hColorsTrie.SetString("{gold}", "\x07FFD700");
        hColorsTrie.SetString("{goldenrod}", "\x07DAA520");
        hColorsTrie.SetString("{gray}", "\x07CCCCCC"); 
        hColorsTrie.SetString("{grey}", "\x07CCCCCC");
        hColorsTrie.SetString("{green}", "\x073EFF3E");
        hColorsTrie.SetString("{greenyellow}", "\x07ADFF2F");
        hColorsTrie.SetString("{haunted}", "\x0738F3AB"); 
        hColorsTrie.SetString("{honeydew}", "\x07F0FFF0");
        hColorsTrie.SetString("{hotpink}", "\x07FF69B4");
        hColorsTrie.SetString("{indianred}", "\x07CD5C5C");
        hColorsTrie.SetString("{indigo}", "\x074B0082");
        hColorsTrie.SetString("{ivory}", "\x07FFFFF0");
        hColorsTrie.SetString("{khaki}", "\x07F0E68C");
        hColorsTrie.SetString("{lavender}", "\x07E6E6FA");
        hColorsTrie.SetString("{lavenderblush}", "\x07FFF0F5");
        hColorsTrie.SetString("{lawngreen}", "\x077CFC00");
        hColorsTrie.SetString("{lemonchiffon}", "\x07FFFACD");
        hColorsTrie.SetString("{lightblue}", "\x07ADD8E6");
        hColorsTrie.SetString("{lightcoral}", "\x07F08080");
        hColorsTrie.SetString("{lightcyan}", "\x07E0FFFF");
        hColorsTrie.SetString("{lightgoldenrodyellow}", "\x07FAFAD2");
        hColorsTrie.SetString("{lightgray}", "\x07D3D3D3");
        hColorsTrie.SetString("{lightgreen}", "\x0799FF99");
        hColorsTrie.SetString("{lightpink}", "\x07FFB6C1");
        hColorsTrie.SetString("{lightsalmon}", "\x07FFA07A");
        hColorsTrie.SetString("{lightseagreen}", "\x0720B2AA");
        hColorsTrie.SetString("{lightskyblue}", "\x0787CEFA");
        hColorsTrie.SetString("{lightslategray}", "\x07778899");
        hColorsTrie.SetString("{lightsteelblue}", "\x07B0C4DE");
        hColorsTrie.SetString("{lightyellow}", "\x07FFFFE0");
        hColorsTrie.SetString("{lime}", "\x0700FF00");
        hColorsTrie.SetString("{limegreen}", "\x0732CD32");
        hColorsTrie.SetString("{linen}", "\x07FAF0E6");
        hColorsTrie.SetString("{magenta}", "\x07FF00FF");
        hColorsTrie.SetString("{maroon}", "\x07800000");
        hColorsTrie.SetString("{mediumaquamarine}", "\x0766CDAA");
        hColorsTrie.SetString("{mediumblue}", "\x070000CD");
        hColorsTrie.SetString("{mediumorchid}", "\x07BA55D3");
        hColorsTrie.SetString("{mediumpurple}", "\x079370D8");
        hColorsTrie.SetString("{mediumseagreen}", "\x073CB371");
        hColorsTrie.SetString("{mediumslateblue}", "\x077B68EE");
        hColorsTrie.SetString("{mediumspringgreen}", "\x0700FA9A");
        hColorsTrie.SetString("{mediumturquoise}", "\x0748D1CC");
        hColorsTrie.SetString("{mediumvioletred}", "\x07C71585");
        hColorsTrie.SetString("{midnightblue}", "\x07191970");
        hColorsTrie.SetString("{mintcream}", "\x07F5FFFA");
        hColorsTrie.SetString("{mistyrose}", "\x07FFE4E1");
        hColorsTrie.SetString("{moccasin}", "\x07FFE4B5");
        hColorsTrie.SetString("{navajowhite}", "\x07FFDEAD");
        hColorsTrie.SetString("{navy}", "\x07000080");
        hColorsTrie.SetString("{normal}", "\x07B2B2B2");
        hColorsTrie.SetString("{oldlace}", "\x07FDF5E6");
        hColorsTrie.SetString("{olive}", "\x079EC34F");
        hColorsTrie.SetString("{olivedrab}", "\x076B8E23");
        hColorsTrie.SetString("{orange}", "\x07FFA500");
        hColorsTrie.SetString("{orangered}", "\x07FF4500");
        hColorsTrie.SetString("{orchid}", "\x07DA70D6");
        hColorsTrie.SetString("{palegoldenrod}", "\x07EEE8AA");
        hColorsTrie.SetString("{palegreen}", "\x0798FB98");
        hColorsTrie.SetString("{paleturquoise}", "\x07AFEEEE");
        hColorsTrie.SetString("{palevioletred}", "\x07D87093");
        hColorsTrie.SetString("{papayawhip}", "\x07FFEFD5");
        hColorsTrie.SetString("{peachpuff}", "\x07FFDAB9");
        hColorsTrie.SetString("{peru}", "\x07CD853F");
        hColorsTrie.SetString("{pink}", "\x07FFC0CB");
        hColorsTrie.SetString("{plum}", "\x07DDA0DD");
        hColorsTrie.SetString("{powderblue}", "\x07B0E0E6");
        hColorsTrie.SetString("{purple}", "\x07800080");
        hColorsTrie.SetString("{red}", "\x07FF4040");
        hColorsTrie.SetString("{rosybrown}", "\x07BC8F8F");
        hColorsTrie.SetString("{royalblue}", "\x074169E1");
        hColorsTrie.SetString("{saddlebrown}", "\x078B4513");
        hColorsTrie.SetString("{salmon}", "\x07FA8072");
        hColorsTrie.SetString("{sandybrown}", "\x07F4A460");
        hColorsTrie.SetString("{seagreen}", "\x072E8B57");
        hColorsTrie.SetString("{seashell}", "\x07FFF5EE");
        hColorsTrie.SetString("{selfmade}", "\x0770B04A"); 
        hColorsTrie.SetString("{sienna}", "\x07A0522D");
        hColorsTrie.SetString("{silver}", "\x07C0C0C0");
        hColorsTrie.SetString("{skyblue}", "\x0787CEEB");
        hColorsTrie.SetString("{slateblue}", "\x076A5ACD");
        hColorsTrie.SetString("{slategray}", "\x07708090");
        hColorsTrie.SetString("{snow}", "\x07FFFAFA");
        hColorsTrie.SetString("{springgreen}", "\x0700FF7F");
        hColorsTrie.SetString("{steelblue}", "\x074682B4");
        hColorsTrie.SetString("{strange}", "\x07CF6A32"); 
        hColorsTrie.SetString("{tan}", "\x07D2B48C");
        hColorsTrie.SetString("{teal}", "\x07008080");
        hColorsTrie.SetString("{thistle}", "\x07D8BFD8");
        hColorsTrie.SetString("{tomato}", "\x07FF6347");
        hColorsTrie.SetString("{turquoise}", "\x0740E0D0");
        hColorsTrie.SetString("{unique}", "\x07FFD700"); 
        hColorsTrie.SetString("{unusual}", "\x078650AC");
        hColorsTrie.SetString("{valve}", "\x07A50F79"); 
        hColorsTrie.SetString("{vintage}", "\x07476291");
        hColorsTrie.SetString("{violet}", "\x07EE82EE");
        hColorsTrie.SetString("{wheat}", "\x07F5DEB3");
        hColorsTrie.SetString("{white}", "\x07FFFFFF");
        hColorsTrie.SetString("{whitesmoke}", "\x07F5F5F5");
        hColorsTrie.SetString("{yellow}", "\x07FFFF00");
        hColorsTrie.SetString("{yellowgreen}", "\x079ACD32");
        return;
    }
    else if(engine == Engine_CSGO)
    {
        hColorsTrie.SetString("{white}", "\x01"); 
        hColorsTrie.SetString("{red}", "\x02");
        hColorsTrie.SetString("{lightpurple}", "\x03");
        hColorsTrie.SetString("{green}", "\x04");
        hColorsTrie.SetString("{lime}", "\x05");
        hColorsTrie.SetString("{lightgreen}", "\x06");
        hColorsTrie.SetString("{lightred}", "\x07"); 
        hColorsTrie.SetString("{gray}", "\x08");
        hColorsTrie.SetString("{lightolive}", "\x09"); 
        hColorsTrie.SetString("{olive}", "\x10");
        hColorsTrie.SetString("{lightblue}", "\x0B");
        hColorsTrie.SetString("{blue}", "\x0C");
        hColorsTrie.SetString("{purple}", "\x0E");
        return;
    }
    else if(engine == Engine_SourceSDK2006)
    {
        hColorsTrie.SetString("{default}", "\x01"); 
        hColorsTrie.SetString("{green}", "\x04");
        hColorsTrie.SetString("{lightgreen}", "\x03");
        hColorsTrie.SetString("{red}", "\x03"); 
        hColorsTrie.SetString("{blue}", "\x03");
        hColorsTrie.SetString("{olive}", "\x05");
        return;
    }
}