Config = {}


-- # General Settings

Config.Framework = "qb"  -- | # | You can specify this part as "esx" or "qb" or "oldqb"
Config.Ox_Inventory = false
Config.Database_Location = "database/db.json"  -- | # | Don't edit this side.

Config.Reset_Stats = true  -- | # | This command is for players to reset their stats.
Config.Reset_Stats_Command = "resetstats" 

Config.Leave_Training_Command = "leavetraining"  -- | # | If players want to leave the training before the end of the training, they can do so with this command.

Config.Get_Steam_PP = true  -- | # | If you are getting an error, it means that the Steam Profile photo is not being fetched on your server. In this case, set this option to false.
Config.Server_Logo = ""  -- | # | If the Config.Get_Steam_PP option is set to false, enter the link to your server's logo here.

-- # Anticheat Settings

Config.Aimlab_Anticheat = true  -- | # | This is an obstacle for those who will try to score points with their executors.
Config.Anticheat_Client_Location = "./resources/viber-aimlab/client/anticheat/main.lua"  -- | # | Edit this part according to the location of the script.

Config.Anticheat_Discord_Log = true
Config.Anticheat_Webhook = ""
Config.Anticheat_Webhook_Color = 15158332 -- (Red)

-- # Interaction Settings

Config.Interaction_Type = "npc"  -- | # | You can specify this part as "npc" or "command" or "trigger"
Config.Command = "aimlab"  -- | # | If the Interaction_Type part is set to "command", you can specify the command in this section.

Config.NPC_Settings = {  -- | # | If the Interaction_Type part is set to "npc", you can specify the npc settings in this section.
    {
        Model = "mp_m_weapexp_01",
        Coords = vector3(370.5602, -378.185, 45.855),
        Heading = 176.9,
        DrawText = "E - AimLab Menu",
        Interaction_Key = 38
    },
}

-- # Aimlab Settings

Config.Training_Settings = {
    ["Bot_Training"] = {
        spawn_coord = vector3(-2642.24, -1162.66, 704.66),
        spawn_heading = 272.67,
        ---------------
        easy_delay = 1500,
        medium_delay = 1000,
        hard_delay = 700,
        ---------------
        training_ped = "a_m_y_dhill_01",
        ---------------
        shoot_score = 0.5,
    },
    ["Spider_Shot"] = {
        spawn_coord = vector3(-2738.90, -1144.28, 695.63),
        spawn_heading = 171.2,
        ---------------
        easy_delay = 1500,
        medium_delay = 1000,
        hard_delay = 700,
        ---------------
        training_prop = "prop_swiss_ball_01",
        ---------------
        shoot_score = 0.5,
    },
    ["Strafe_Shooting"] = {
        spawn_coord = vector3(-2755.57, -1145.89, 694.89),
        spawn_heading = 177.04,
        ---------------
        easy_delay = 2000,
        medium_delay = 1000,
        hard_delay = 500,
        ---------------
        training_prop = "prop_beachball_01",
        ---------------
        shoot_score = 0.5,
    },
    ["Dynamic_Clicking"] = {
        spawn_coord = vector3(-2738.90, -1144.28, 695.63),
        spawn_heading = 171.2,
        ---------------
        training_prop = "prop_beachball_01",
        prop_spawn_coord = vector3(-2738.50, -1155.24, 698.02),
        ---------------
        shoot_score = 0.5,
        training_second = 60,
    },
    ["Target_Track"] = {
        spawn_coord = vector3(-2738.90, -1144.28, 695.63),
        spawn_heading = 171.2,
        ---------------
        training_prop = "prop_beachball_01",
        prop_spawn_coord = vector3(-2738.50, -1155.24, 698.02),
        ---------------
        training_second = 60,
    },
    ["Realistic_Track"] = {
        spawn_coord = vector3(-2642.24, -1162.66, 704.66),
        spawn_heading = 272.67,
        ---------------
        training_ped = "a_m_y_dhill_01",
        ---------------
        training_second = 60,
    },
}

-- # Coords

Config.Bot_Training_Coords = {
	[1] = {coords = vector3(-2628.30, -1161.97, 704.66), heading = 92.75}, 
	[2] = {coords = vector3(-2627.98, -1157.11, 704.66), heading = 84.64}, 
	[3] = {coords = vector3(-2628.04, -1166.83, 704.66), heading = 92.62}, 
	[4] = {coords = vector3(-2628.42, -1171.41, 704.66), heading = 90.96}, 
	[5] = {coords = vector3(-2628.25, -1151.93, 704.66), heading = 99.16}, 
}

Config.Spider_Shot_Coords = {
	[1] = {coords = vector3(-2738.76, -1155.74, 697.63)}, 
	[2] = {coords = vector3(-2741.74, -1156.05, 697.63)}, 
	[3] = {coords = vector3(-2745.38, -1156.08, 697.63)}, 
	[4] = {coords = vector3(-2735.73, -1155.78, 697.63)}, 
	[5] = {coords = vector3(-2731.60, -1155.75, 697.63)}, 
    [6] = {coords = vector3(-2733.82, -1157.53, 697.63)}, 
    [7] = {coords = vector3(-2743.96, -1157.67, 697.63)}, 
    [8] = {coords = vector3(-2738.67, -1158.18, 697.63)}, 
    [9] = {coords = vector3(-2738.76, -1155.74, 698.4)}, 
	[10] = {coords = vector3(-2741.74, -1156.05, 698.4)}, 
	[11] = {coords = vector3(-2745.38, -1156.08, 698.4)}, 
	[12] = {coords = vector3(-2735.73, -1155.78, 698.4)}, 
	[13] = {coords = vector3(-2731.60, -1155.75, 698.4)}, 
    [14] = {coords = vector3(-2733.82, -1157.53, 698.4)}, 
    [15] = {coords = vector3(-2743.96, -1157.67, 698.4)}, 
    [16] = {coords = vector3(-2738.67, -1158.18, 698.4)}, 
    [17] = {coords = vector3(-2738.76, -1155.74, 696.9)}, 
	[18] = {coords = vector3(-2741.74, -1156.05, 696.9)}, 
	[19] = {coords = vector3(-2745.38, -1156.08, 696.9)}, 
	[20] = {coords = vector3(-2735.73, -1155.78, 696.9)}, 
	[21] = {coords = vector3(-2731.60, -1155.75, 696.9)}, 
    [22] = {coords = vector3(-2733.82, -1157.53, 696.9)}, 
    [23] = {coords = vector3(-2743.96, -1157.67, 696.9)}, 
    [24] = {coords = vector3(-2738.67, -1158.18, 696.9)}, 
}

Config.Strafe_Shooting_Coords = {
    [1] = {coords = vector3(-2756.88, -1154.61, 696.1)},
    [2] = {coords = vector3(-2756.36, -1154.61, 696.1)},
    [3] = {coords = vector3(-2755.84, -1154.58, 696.1)},
    [4] = {coords = vector3(-2755.31, -1154.60, 696.1)},
    [5] = {coords = vector3(-2754.79, -1154.56, 696.1)},
    [6] = {coords = vector3(-2754.26, -1154.61, 696.1)},
}

Config.Realistic_Track_Coords = {
	[1] = {coords = vector3(-2628.30, -1161.97, 704.66), heading = 92.75}, 
	[2] = {coords = vector3(-2627.98, -1157.11, 704.66), heading = 84.64}, 
	[3] = {coords = vector3(-2628.04, -1166.83, 704.66), heading = 92.62}, 
	[4] = {coords = vector3(-2628.42, -1171.41, 704.66), heading = 90.96}, 
	[5] = {coords = vector3(-2628.25, -1151.93, 704.66), heading = 99.16}, 
}