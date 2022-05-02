enum
{
    ID,
    Invites,
    Points,
    Time,
    INFO
};

/*  Получаем handle бд плагина */
native Database Referal_GetDatabase();

/*  Проверяем подключился ли к бд плагин */
native bool Referal_IsLoaded();

/*  Получаем данные игрока , значения в enum выше */
native int Referal_GetClientData(int client,int INFO);

/*  Устанавливаем данные игроку, значения в enum выше , ID не трогать */
native int Referal_SetClientData(int client,int INFO,int value);

/* Вызывается когда плагин подключился к бд */
forward void Referal_System_Loaded();

/* Вызывается когда один игрок выбрал своего реферала */
forward void Referal_OnPlayerChosen(int target,int inviter);