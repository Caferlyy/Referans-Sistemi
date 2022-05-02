#define MAX MAXPLAYERS+1
#define SZF(%0) %0, sizeof(%0)
#define USERID(%1) GetClientUserId(%1)
#define INDEX(%1) GetClientOfUserId(%1)
#define view(%1,%2) view_as<%1>(%2)

/* PLUGIN VARS */
Database g_hDatabase;

bool g_bMySQL,g_bInfo,
     g_bMenu,g_bLoaded,
     g_bLog;
int g_iWorkType,
    g_iCredits,
    g_iVIPTime,
    g_iPoints,
    g_iMinTime;
float g_fTime;
char g_sVIPGroup[64],
     g_sCommand[64],
     g_sLogPath[128];

Handle g_hOnPluginLoaded,
       g_hOnPlayerChosen,
       g_hTimer;
/* PLUGIN VARS */

/* CLIENT VARS */
int g_iData[MAX][INFO],
    g_iTarget[MAX];
bool g_bInvited[MAX],
     g_bInMenu[MAX];
/* CLIENT VARS */