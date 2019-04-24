#include <sourcemod>
#include <sdktools>
#include <menus>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_AUTHOR "Moonly Days"
#define PLUGIN_VERSION "0.05"

int BlockSelected[MAXPLAYERS+1];
int BlockLimit = 2560;
//修改上限

public Plugin myinfo =
{
	name = "MineFortress Plugin",
	description = "Adds blocks to build with",
	author = PLUGIN_AUTHOR,
	version = PLUGIN_VERSION,
	url = "rcatf2.ru"
};

public void OnPluginStart()
{
	AddNormalSoundHook(NormalSHook:Hook_EntitySound);
	RegConsoleCmd("minecraft_build", cBuildBlock, "Builds a block", 0);
	RegConsoleCmd("minecraft_block", cSelBlock, "Selects a block", 0);
	RegConsoleCmd("minecraft_break", cDestroyBlock, "Destroys a block", 0);
	RegConsoleCmd("minecraft_limit", cCurrentLimit, "Displays Block limit", 0);
	RegAdminCmd("minecraft_clearblocks", cKillBlocks, ADMFLAG_BAN, "Clears all Minecraft Blocks");
}

public Action Hook_EntitySound(int clients[64],  int &numClients,  char sample[PLATFORM_MAX_PATH],  int &client,  int &channel,  float &volume,  int &level,  int &pitch,  int &flags,  char soundEntry[PLATFORM_MAX_PATH],  int &seed) //Yes, a sound hook is literally the best way to hook this event.
{
	if(!(1<=client<=MaxClients) || !IsClientInGame(client))return Plugin_Continue;
	if(StrContains(sample, "hit", false) != -1) 
	{
		new Float:angles[3];
		new Float:eyepos[3];
		GetClientEyeAngles(client, angles);
		GetClientEyePosition(client, eyepos);
				
		TR_TraceRayFilter(eyepos, angles, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceEntityFilterPlayer, client);
		new ent = TR_GetEntityIndex();

		if (IsValidEntity(ent))
		{
			decl Float:EntPos[3];
			decl Float:ClientPos[3];
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", EntPos);
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
			new Float:Distance = GetVectorDistance(EntPos, ClientPos, false);
			if (Distance < 100.0)
			{
				if (IsValidBlock(ent))
				{
					ClientCommand(client, "playgamesound minecraft/stone2.mp3");
					RemoveEdict(ent);
				}
			}
		}
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	AddFileToDownloadsTable("materials/mcmod/bedrock.vtf");
	AddFileToDownloadsTable("materials/mcmod/bedrock.vmt");
	AddFileToDownloadsTable("materials/mcmod/bookshelf.vtf");
	AddFileToDownloadsTable("materials/mcmod/bookshelf.vmt");
	AddFileToDownloadsTable("materials/mcmod/brick.vtf");
	AddFileToDownloadsTable("materials/mcmod/brick.vmt");
	AddFileToDownloadsTable("materials/mcmod/chest.vtf");
	AddFileToDownloadsTable("materials/mcmod/chest.vmt");
	AddFileToDownloadsTable("materials/mcmod/coal_ore.vtf");
	AddFileToDownloadsTable("materials/mcmod/coal_ore.vmt");
	AddFileToDownloadsTable("materials/mcmod/cobblestone.vtf");
	AddFileToDownloadsTable("materials/mcmod/cobblestone.vmt");
	AddFileToDownloadsTable("materials/mcmod/crafting_table.vtf");
	AddFileToDownloadsTable("materials/mcmod/crafting_table.vmt");
	AddFileToDownloadsTable("materials/mcmod/diamond_block.vtf");
	AddFileToDownloadsTable("materials/mcmod/diamond_block.vmt");
	AddFileToDownloadsTable("materials/mcmod/diamond_ore.vtf");
	AddFileToDownloadsTable("materials/mcmod/diamond_ore.vmt");
	AddFileToDownloadsTable("materials/mcmod/dirt.vtf");
	AddFileToDownloadsTable("materials/mcmod/dirt.vmt");
	AddFileToDownloadsTable("materials/mcmod/furnace.vtf");
	AddFileToDownloadsTable("materials/mcmod/furnace.vmt");
	AddFileToDownloadsTable("materials/mcmod/glass.vtf");
	AddFileToDownloadsTable("materials/mcmod/glass.vmt");
	AddFileToDownloadsTable("materials/mcmod/gold_block.vtf");
	AddFileToDownloadsTable("materials/mcmod/gold_block.vmt");
	AddFileToDownloadsTable("materials/mcmod/gold_ore.vtf");
	AddFileToDownloadsTable("materials/mcmod/gold_ore.vmt");
	AddFileToDownloadsTable("materials/mcmod/grass.vtf");
	AddFileToDownloadsTable("materials/mcmod/grass.vmt");
	AddFileToDownloadsTable("materials/mcmod/iron_block.vtf");
	AddFileToDownloadsTable("materials/mcmod/iron_block.vmt");
	AddFileToDownloadsTable("materials/mcmod/iron_ore.vtf");
	AddFileToDownloadsTable("materials/mcmod/iron_ore.vmt");
	AddFileToDownloadsTable("materials/mcmod/leaves.vtf");
	AddFileToDownloadsTable("materials/mcmod/leaves.vmt");
	AddFileToDownloadsTable("materials/mcmod/log.vtf");
	AddFileToDownloadsTable("materials/mcmod/log.vmt");
	AddFileToDownloadsTable("materials/mcmod/planks.vtf");
	AddFileToDownloadsTable("materials/mcmod/planks.vmt");
	AddFileToDownloadsTable("materials/mcmod/pumpkin.vtf");
	AddFileToDownloadsTable("materials/mcmod/pumpkin.vmt");
	AddFileToDownloadsTable("materials/mcmod/sand.vtf");
	AddFileToDownloadsTable("materials/mcmod/sand.vmt");
	AddFileToDownloadsTable("materials/mcmod/steve.vtf");
	AddFileToDownloadsTable("materials/mcmod/steve.vmt");
	AddFileToDownloadsTable("materials/mcmod/stone.vtf");
	AddFileToDownloadsTable("materials/mcmod/stone.vmt");
	AddFileToDownloadsTable("materials/mcmod/tnt.vtf");
	AddFileToDownloadsTable("materials/mcmod/tnt.vmt");
	
	AddFileToDownloadsTable("models/mcmod/mcblock.dx80.vtx");
	AddFileToDownloadsTable("models/mcmod/mcblock.dx90.vtx");
	AddFileToDownloadsTable("models/mcmod/mcblock.mdl");
	AddFileToDownloadsTable("models/mcmod/mcblock.phy");
	AddFileToDownloadsTable("models/mcmod/mcblock.sw.vtx");
	AddFileToDownloadsTable("models/mcmod/mcblock.vvd");
	
	AddFileToDownloadsTable("sound/minecraft/stone1.mp3");
	AddFileToDownloadsTable("sound/minecraft/stone2.mp3");
	
}

public int mBlocks(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[11];
		menu.GetItem(param2, info, sizeof(info));
		int ID = StringToInt(info);
		BlockSelected[param1] = ID;
		PrintToChat(param1, "[Minecraft] 已選擇編號: %s  方塊", info);
	}else if (action == MenuAction_End)
	{
			delete menu;
	}
	return 0;
}

public Action cSelBlock(int client, int args)
{
	Menu menu = new Menu(mBlocks);
	menu.SetTitle("選擇方塊");
	menu.AddItem("0", "草地");
	menu.AddItem("1", "泥土");
	menu.AddItem("2", "石頭");
	menu.AddItem("3", "鵝卵石");
	menu.AddItem("4", "基岩");
	menu.AddItem("5", "煤礦");
	menu.AddItem("6", "鐵礦");
	menu.AddItem("7", "金礦");
	menu.AddItem("8", "鑽石礦");
	menu.AddItem("9", "木頭");
	menu.AddItem("10", "黑橡木原木");
	menu.AddItem("11", "書櫃");
	menu.AddItem("12", "工作台");
	menu.AddItem("13", "紅磚");
	menu.AddItem("14", "TNT");
	menu.AddItem("15", "儲物箱");
	menu.AddItem("16", "沙子");
	menu.AddItem("17", "南瓜");
	menu.AddItem("18", "熔爐");
	menu.AddItem("19", "叢林木樹葉");
	menu.AddItem("20", "鐵磚");
	menu.AddItem("21", "金磚");
	menu.AddItem("22", "鑽石磚");
	menu.AddItem("23", "玻璃");
	menu.ExitButton = true;
	menu.Display(client, 20);
	return Plugin_Handled;
}

public Action cBuildBlock(int client, int args)
{
	if (BlocksAmount() >= BlockLimit)
	{
		PrintToChat(client, "[Minecraft] 上限超出 %d . 摧毀先前方塊來建造", BlockLimit);
		return Plugin_Handled;
	}
	float start[3];
	float angle[3];
	float pos[3];
	GetClientEyePosition(client, start);
	GetClientEyeAngles(client, angle);
	
	TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer, client); 
	
	if (TR_DidHit(INVALID_HANDLE))
	{
		TR_GetEndPosition(pos, INVALID_HANDLE);
	}
	int i = 0;
	while (i < 3)
	{
		pos[i] = RoundToNearest(pos[i] / 50) * 50.0;
		i++;
	}
	
	
	new block;
	while((block=FindEntityByClassname(block, "prop_dynamic"))!=INVALID_ENT_REFERENCE)
	{
		if (IsValidBlock(block))
		{
			float position[3];
			GetEntPropVector(block, Prop_Send, "m_vecOrigin", position);
			if(pos[0] == position[0] && pos[1] == position[1] && pos[2] == position[2])
			{
				return Plugin_Handled;
			}
		}
	}
	
	if (!NoPlayersInRange(pos, 100.0))
	{
		return Plugin_Handled;
	}
	
	float position[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", position, 0);
	
	if (GetVectorDistance(pos, position, true) > 90000)
	{
		return Plugin_Handled;
	}
	int BlockID = BlockSelected[client];
	
	if (!IsPlayerAlive(client) || GetClientTeam(client) < 2)
	{
		return Plugin_Handled;
	}
	int ent = CreateEntityByName("prop_dynamic_override");
	if (IsValidEdict(ent))
	{
		ClientCommand(client, "playgamesound minecraft/stone1.mp3");
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		PrecacheModel("models/mcmod/mcblock.mdl");
		SetEntityModel(ent, "models/mcmod/mcblock.mdl");
		SetEntProp(ent, Prop_Send, "m_nSkin", BlockID, 4);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
		DispatchKeyValue(ent, "targetname", "tf2_block");
		DispatchSpawn(ent);
		ActivateEntity(ent);
		return Plugin_Handled;
	}
	PrintToChat(client, "[Minecraft] Invalid index");
	return Plugin_Handled;
}

public Action cCurrentLimit(int client, int args)
{
	PrintToChat(client, "[Minecraft] Current block limit: %d", BlocksAmount());
	return Plugin_Handled;
}

public Action cKillBlocks(int client, int args)
{
	new block;
	while((block=FindEntityByClassname(block, "prop_dynamic"))!=INVALID_ENT_REFERENCE)
	{
		if (IsValidBlock(block))
		{
			AcceptEntityInput(block, "Kill", -1, -1);
		}
	}
	PrintToChatAll("[Minecraft]所有方塊已經被清除. 嗯!真乾淨!");
	return Plugin_Handled;
}

public Action cDestroyBlock(int client, int args)
{
	int target = GetClientAimTarget(client, false);
	if (IsValidBlock(target))
	{
		float pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		float position[3];
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
		if (GetVectorDistance(pos, position, true) > 90000)
		{
			return Plugin_Handled;
		}
		ClientCommand(client, "playgamesound minecraft/stone2.mp3");
		RemoveEdict(target);
	}
	return Plugin_Handled;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
	return entity > MaxClients;
}

public bool IsValidBlock(int entity)
{
	if (entity > 0)
	{
		char strName[16];
		GetEntPropString(entity, Prop_Data, "m_iName", strName, 16);
		if (StrEqual(strName, "tf2_block", true))
		{
			return true;
		}
	}
	return false;
}

public bool NoPlayersInRange(float pos[3], float range)
{
	for (new i = 1; i < MaxClients;i++){
		if (IsClientInGame(i))
		{
			if (IsPlayerAlive(i))
			{
				float position[3];
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", position, 0);
				if (GetVectorDistance(pos, position, true) < range* range)
				{
					return false;
				}
			}
		}
	}
	return true;
}

public int BlocksAmount()
{
	new BlockAmount;
	new block;
	while((block=FindEntityByClassname(block, "prop_dynamic"))!=INVALID_ENT_REFERENCE)
	{
		if (IsValidBlock(block))
		{
			BlockAmount++;
		}
	}
	return BlockAmount;
}

stock GetSlotFromPlayerWeapon(iClient, iWeapon)
{
    for (new i = 0; i <= 5; i++)
    {
        if (iWeapon == GetPlayerWeaponSlot(iClient, i))
        {
            return i;
        }
    }
    return -1;
}
