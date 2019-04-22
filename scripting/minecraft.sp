#include <sourcemod>
#include <sdktools>
#include <menus>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_AUTHOR "Moonly Days"
#define PLUGIN_VERSION "1.01"

int BlockSelected[MAXPLAYERS+1];
int BlockLimit = 256;


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
	RegConsoleCmd("sm_build", cBuildBlock, "Builds a block", 0);
	RegConsoleCmd("sm_block", cSelBlock, "Selects a block", 0);
	RegConsoleCmd("sm_break", cDestroyBlock, "Destroys a block", 0);
	RegConsoleCmd("sm_limit", cCurrentLimit, "Displays Block limit", 0);
	RegAdminCmd("sm_clearblocks", cKillBlocks, ADMFLAG_BAN, "Clears all Minecraft Blocks");
}

public Action Hook_EntitySound(int clients[64],
  int &numClients,
  char sample[PLATFORM_MAX_PATH],
  int &client,
  int &channel,
  float &volume,
  int &level,
  int &pitch,
  int &flags,
  char soundEntry[PLATFORM_MAX_PATH],
  int &seed) //Yes, a sound hook is literally the best way to hook this event.
{
	if(StrContains(sample, "hit", false) != -1) //When a Homewrecker or Neon sign sound goes off
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
			if (Distance < 100.0) //Make sure they're close enough to the building, it's pretty easy to trigger the sound without being in range
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
		PrintToChat(param1, "[Minecraft] Selected block: %s", info);
	}else if (action == MenuAction_End)
	{
			delete menu;
	}
	return 0;
}

public Action cSelBlock(int client, int args)
{
	Menu menu = new Menu(mBlocks);
	menu.SetTitle("Select block");
	menu.AddItem("0", "Grass");
	menu.AddItem("1", "Dirt");
	menu.AddItem("2", "Stone");
	menu.AddItem("3", "Cobblestone");
	menu.AddItem("4", "Bedrock");
	menu.AddItem("5", "Coal Ore");
	menu.AddItem("6", "Iron Ore");
	menu.AddItem("7", "Gold Ore");
	menu.AddItem("8", "Diamond Ore");
	menu.AddItem("9", "Wooden Planks");
	menu.AddItem("10", "Oak Log");
	menu.AddItem("11", "Bookshelf");
	menu.AddItem("12", "Crafting Table");
	menu.AddItem("13", "Bricks");
	menu.AddItem("14", "TNT");
	menu.AddItem("15", "Chest");
	menu.AddItem("16", "Sand");
	menu.AddItem("17", "Pumpkin");
	menu.AddItem("18", "Furnace");
	menu.AddItem("19", "Leaves");
	menu.AddItem("20", "Iron Block");
	menu.AddItem("21", "Gold Block");
	menu.AddItem("22", "Diamond Block");
	menu.AddItem("23", "Glass");
	menu.ExitButton = true;
	menu.Display(client, 20);
	return Plugin_Handled;
}

public Action cBuildBlock(int client, int args)
{
	if (BlocksAmount() >= BlockLimit)
	{
		PrintToChat(client, "[Minecraft] Limit of %d exceeded. Destroy some other blocks to build", BlockLimit);
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
	PrintToChatAll("[Minecraft] All blocks were removed. Map is now clean!");
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
