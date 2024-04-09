print("Dorito's Simple Versatile NPC Shop Addon Loaded")
ENT.Type = "ai" 
ENT.Base = "base_ai" 

ENT.PrintName = "Simple Versatile NPC Shop"
ENT.Spawnable = true
ENT.Category = "SimpleVNPCShop"
ENT.Author = "Dorito"
ENT.Description = "SIMPLE SHOP NPC | USE "

ENT.SetAutomaticFrameAdvance = false

SIMPLESERVERSHOP = SIMPLESERVERSHOP or {}
-------------------------------------------------


--- CHANGE SOME ASPECTS OF YOUR SHOP HERE ---
SIMPLESERVERSHOP.Theme = {
    ["ShopNPCModel"] = "models/Humans/Group03/Male_04.mdl", -- Change the model to whatever you want here. Just make sure the model exists within your server
    ["NPCDataUserGroups"] = {"superadmin", "owner"}, -- THIS IS FOR WHO HAS ACCESS TO THE NPC DATA SAVING COMMANDS IN CONSOLE
    ["NPCSHOPNAME"] = "Weapon Shop", -- Change the name of your shop. It can be changed to the theme of your shop such as "Knife Shop" or whatever you please.
}


-- EXAMPLE:
--{   
    --name = "AK-47",  -- CAN BE ANY NAME
    --model = "models/weapons/w_rif_ak47.mdl", -- GRAB THE MODEL I HAVE SET UP A COMMAND IN CONSOLE TO ALLOW FOR T HE RETREIVAL OF CURRENT HELD WEAPON MODELS (wep_model)
    --classname = "weapon_ak472", -- FIND THE WEAPON IN THE Q MENU, LEFT CLICK AND COPY TO CLIPBOARD AND THE PASTE HERE.
    --price = 5000, -- CHOOSE A PRICE
    --description = "A powerful assault rifle.", -- CREATE A SHORT DESCRIPTION.
    --access = {"VIP", "MVP", "user"}  -- REMOVE THIS OR ADD TO ANY WEAPON IF YOU WISH TO SPECIFY WHO HAS ACCESS TO PURCHASE IT. REMOVE IT COMPLETELY IF YOU WANT EVERYONE TO HAVE ACCESS
--},


SIMPLESERVERSHOP.Items = {

    --- ADD NEW WEAPONS BELOW! FOLLOW THE FORMAT ---
    {   
        name = "AK-47",  
        model = "models/weapons/w_rif_ak47.mdl", 
        classname = "weapon_ak472", 
        price = 5000, 
        description = "A powerful assault rifle.",
        access = {"VIP", "MVP", "user"}  
    },


    {   
        name = "Deagle", 
        model = "models/weapons/w_pist_deagle.mdl",
        classname = "weapon_deagle2", 
        price = 2000, 
        description = "A semi-automatic handgun."
    },

    {   
        name = "Five Seven", 
        model = "models/weapons/w_pist_fiveseven.mdl",
        classname = "weapon_fiveseven2", 
        price = 1250, 
        description = "A compact pistol.",
    },

    {   
        name = "Glock", 
        model = "models/weapons/w_pist_glock18.mdl",
        classname = "weapon_glock2", 
        price = 1000, 
        description = "A reliable and versatile pistol.",
    },

    {   
        name = "M4", 
        model = "models/weapons/w_rif_m4a1.mdl",
        classname = "weapon_m42", 
        price = 4000, 
        description = "A versatile carbine rifle.",
    },

    {   
        name = "MP5", 
        model = "models/weapons/w_smg_mp5.mdl",
        classname = "weapon_mp52", 
        price = 3000, 
        description = "A compact submachine gun.",
    },

    {   
        name = "Mac10", 
        model = "models/weapons/w_smg_mac10.mdl",
        classname = "weapon_mac102", 
        price = 2500, 
        description = "A compact machine pistol.",
    },

    {   
        name = "Medic Kit", 
        model = "models/weapons/w_medkit.mdl",
        classname = "med_kit", 
        price = 10000, 
        description = "A medical kit for treating injuries and wounds.",
    },

    
}