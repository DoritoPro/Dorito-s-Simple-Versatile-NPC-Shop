AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self.nick = "Simple Server Shop NPC"
    self:SetModel( (SIMPLESERVERSHOP.Theme["ShopNPCModel"]) )
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()

    self:SetNPCState(NPC_STATE_IDLE)
    self:SetSolid(SOLID_BBOX)
    self:DropToFloor()

    self:SetMoveType(MOVETYPE_NONE) 
    self:SetSolidFlags(FSOLID_NOT_STANDABLE) 

    self:CapabilitiesClear()

    -- Set a unique ID for the NPC based on its creation time and entity index
    self:SetNWInt("UniqueID", os.time() * 1000 + self:EntIndex())

    -- Load the NPC position on initialization
    self:LoadShopNPCPosition()
end

-- Function to save the NPC's position
function ENT:SaveShopNPCPosition()

    local posData = {
        position = self:GetPos(),
        angles = self:GetAngles(),
        uniqueID = self:GetNWInt("UniqueID") -- Include the unique ID in the save data
    }

    local jsonPosData = util.TableToJSON(posData)

    file.Write("npcshop_positions/" .. self:GetNWInt("UniqueID") .. ".txt", jsonPosData)
    
end

-- Function to load the NPC's position
function ENT:LoadShopNPCPosition()
    local fileName = "npcshop_positions/" .. self:GetNWInt("UniqueID") .. ".txt"
    if file.Exists(fileName, "DATA") then
        local jsonPosData = file.Read(fileName, "DATA")
        local posData = util.JSONToTable(jsonPosData)
        if posData then
            self:SetPos(posData.position)
            self:SetAngles(posData.angles)
        end
    end
end

-- EVEN IF THIS IS USELESS AND I DONT NEED IT, DONT TOUCH IT
local function DeleteNPCFiles()
    local files = file.Find("npcshop_positions/*.txt", "DATA")
    for _, fileName in ipairs(files) do
        file.Delete("npcshop_positions/" .. fileName)
    end
end


-- Load NPC positions on server start
hook.Add("InitPostEntity", "SpawnSavedShopNPCs", function()
    -- Load saved NPC positions and spawn NPCs
    for _, fileName in ipairs(file.Find("npcshop_positions/*.txt", "DATA")) do
        local uniqueID = tonumber(string.match(fileName, "(%d+)%.txt"))
        if uniqueID then
            local jsonPosData = file.Read("npcshop_positions/" .. fileName, "DATA")
            local posData = util.JSONToTable(jsonPosData)
            if posData then
                local npc = ents.Create("shop_npc")
                if IsValid(npc) then
                    npc:SetPos(posData.position)
                    npc:SetAngles(posData.angles)
                    npc:SetNWInt("UniqueID", uniqueID) -- Set the UniqueID here
                    npc:Spawn()
                end
            end
        end
    end
end)

concommand.Add("sshopnpc", function(ply, cmd, args)
    local NPCShopUserGroups = SIMPLESERVERSHOP.Theme["NPCDataUserGroups"]
    local hasPermission = false

    for _, group in ipairs(NPCShopUserGroups) do
        if ply:IsUserGroup(group) then
            hasPermission = true
            break
        end
    end
    
    if not hasPermission then
        ply:ChatPrint("You don't have permission to use this command.")
        return ""
    end


    --LITERALLY SAT HERE FOR AGES RIPPING MY HAIR ON WHY THE DIRECTORY WASN'T BEING CREATED TO ONLY FIGURE OUT THAT THIS WAS OUTSIDE OF THE COMMAND, FUUUUUUUU--
    if not file.IsDir("npcshop_positions", "DATA") then
        file.CreateDir("npcshop_positions")
    end

    local npcShop = ents.FindByClass("shop_npc") -- Get a list of all NPCs of class "test_npc"
    local savedCount = 0 -- Counter for the number of NPCs saved
    for _, npc in ipairs(npcShop) do
        local uniqueID = npc:GetNWInt("UniqueID")
        local fileName = "npcshop_positions/" .. uniqueID .. ".txt"
        local posData = {
            position = npc:GetPos(),
            angles = npc:GetAngles(),
            uniqueID = uniqueID
        }
        local jsonPosData = util.TableToJSON(posData)
        file.Write(fileName, jsonPosData) -- Write position data to file
        savedCount = savedCount + 1
    end
    ply:ChatPrint("Saved position data for " .. savedCount .. " NPCs.")
end)

concommand.Add("rshopnpc", function(ply, cmd, args)
    local NPCShopUserGroups = SIMPLESERVERSHOP.Theme["NPCDataUserGroups"]
    local hasPermission = false
    
    for _, group in ipairs(NPCShopUserGroups) do
        if ply:IsUserGroup(group) then
            hasPermission = true
            break
        end
    end
    
    if not hasPermission then
        ply:ChatPrint("You don't have permission to use this command.")
        return
    end

    local shopnpcList = ents.FindByClass("shop_npc") -- Get a list of all NPCs of class "test_npc"
    local removedCount = 0 -- Counter for the number of NPCs removed

    for _, npc in ipairs(shopnpcList) do
        npc:Remove() -- Remove the NPC entity
        removedCount = removedCount + 1
    end

    ply:ChatPrint("Removed " .. removedCount .. " NPCs.")

    -- Remove associated files only if there are NPCs removed
    if removedCount > 0 then
        local files = file.Find("npcshop_positions/*.txt", "DATA")
        for _, fileName in ipairs(files) do
            file.Delete("npcshop_positions/" .. fileName)
        end
        ply:ChatPrint("Deleted associated files.")
    else
        ply:ChatPrint("No NPCs removed. No associated files deleted.")
    end
end)
----------------------------------------------------------------------
util.AddNetworkString("ShopItem_Purchase")

net.Receive("ShopItem_Purchase", function (len, ply)
    local itemID = net.ReadInt(32)
    local itemData = SIMPLESERVERSHOP.Items[itemID]
    if not itemData then 
        return 
    end

    local canAfforditem = ply:canAfford(itemData.price)
    local hasItem = ply:HasWeapon(itemData.classname)

    if hasItem then
        ply:ChatPrint("You Already Own This Weapon!")
    elseif not canAfforditem then
        ply:ChatPrint("You Can't Afford This Item!")
    else
        if itemData.access then
            local hasAccess = false
            for _, group in ipairs(itemData.access) do
                if ply:IsUserGroup(group) then
                    hasAccess = true
                    break
                end
            end
            if not hasAccess then
                ply:ChatPrint("You are not in the right user group! Only [" .. table.concat(itemData.access, ", ") .. "] can purchase this item!")
                return
            end
        end

        ply:addMoney(-itemData.price)
        ply:Give(itemData.classname)
        ply:ChatPrint("Item Purchased!")
    end
end)

