void CreateApi()
{
    CreateNative("Referal_GetDatabase", Native_GetDatabase);
    CreateNative("Referal_IsLoaded", Native_IsLoaded);
    CreateNative("Referal_GetClientData", Native_GetClientData);
    CreateNative("Referal_SetClientData", Native_SetClientData);
    g_hOnPluginLoaded = CreateGlobalForward("Referal_System_Loaded", ET_Ignore);
    g_hOnPlayerChosen = CreateGlobalForward("Referal_OnPlayerChosen", ET_Ignore,Param_Cell,Param_Cell);
    RegPluginLibrary("referal_system");
}

public int Native_GetDatabase(Handle hPlugin, int iNumParams){
    return view(int,(CloneHandle(g_hDatabase, hPlugin)));
}

public int Native_IsLoaded(Handle hPlugin, int iNumParams){
    return g_bLoaded;
}

public int Native_GetClientData(Handle hPlugin, int iNumParams)
{
    int client = GetNativeCell(1);
    if(client < 1 || !IsClientInGame(client) || IsFakeClient(client))
    {
        ThrowNativeError(SP_ERROR_NATIVE, "Invalid client");
        return 0;
    }
    return g_iData[client][GetNativeCell(2)];
}

public int Native_SetClientData(Handle hPlugin, int iNumParams)
{
    int client = GetNativeCell(1);
    if(client < 1 || !IsClientInGame(client) || IsFakeClient(client))
    {
        ThrowNativeError(SP_ERROR_NATIVE, "Invalid client");
        return 0;
    }
    g_iData[client][GetNativeCell(2)] = GetNativeCell(3);
    return 1;
}
