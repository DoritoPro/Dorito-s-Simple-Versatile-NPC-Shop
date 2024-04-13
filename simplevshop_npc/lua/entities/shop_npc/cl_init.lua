include("shared.lua")

surface.CreateFont("statnpc_55", {
    font = "DermaLarge", 
    size = 55, 
    weight = 500, 
    antialias = true, 
})


surface.CreateFont("statnpc_30", {
    font = "Roboto", 
    size = 30, 
    weight = 500, 
    antialias = true, 
})

surface.CreateFont("statnpc_40", {
    font = "Roboto", 
    size = 40, 
    weight = 500, 
    antialias = true, 
})

surface.CreateFont("statnpc_18", {
    font = "Roboto", 
    size = 18, 
    weight = 500, 
    antialias = true, 
})

surface.CreateFont("statnpc_15", {
    font = "Roboto", 
    size = 15, 
    weight = 500, 
    antialias = true, 
})

concommand.Add("wep_model", function (ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    
    print(wep:GetWeaponWorldModel())
end)

ENT.RenderGroup = RENDERGROUP_OPAQUE

local interacting = false -- Flag to track if interaction is currently happening

local function CreateShopNPCPanel()
    local statpanel = vgui.Create("DFrame")
    statpanel:SetSize(450, 550)
    statpanel:SetPos(ScrW() / 2 - 225 , ScrH() / 2 - 325)
    statpanel:MakePopup()
    statpanel:SetDraggable(false)
    statpanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(30, 30, 30))
    end
    
    local scroll = vgui.Create("DScrollPanel", statpanel)
    scroll:Dock(FILL)
    
    local vBar = scroll:GetVBar()
    vBar:SetWide(20)  -- Set the width of the scrollbar
    vBar:SetHideButtons(true)  -- Hide the scroll buttons
    vBar.Paint = function(self, w, h)
        -- Custom scrollbar painting
        draw.RoundedBox(5, 0, 0, w, h, Color(100, 100, 100))
    end
    vBar.btnGrip.Paint = function(self, w, h)
        -- Custom grip painting
        draw.RoundedBox(5, 0, 0, w, h, Color(0, 132, 255))
    end


    local headerHeight = 40
    local statheader = vgui.Create("DPanel", statpanel)
    statheader:SetSize(statpanel:GetWide(), 40)
    statheader:SetPos(0, 0)
    statheader.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(0, 132, 255))
        draw.SimpleText((SIMPLESERVERSHOP.Theme["NPCSHOPNAME"]), "statnpc_30", 10, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local headeroutline = vgui.Create("DPanel", statpanel)
    headeroutline:SetSize(statpanel:GetWide(), 1)
    headeroutline:SetPos(0, 40)
    headeroutline.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 100))
    end

    
    local statdpanelbutton = vgui.Create("DButton", statheader)
    statdpanelbutton:SetText("X")
    statdpanelbutton:SetFont("statnpc_30")
    statdpanelbutton:SetSize(50, 30)
    statdpanelbutton:SetPos(statheader:GetWide() - statdpanelbutton:GetWide() - 5, (statheader:GetTall() - statdpanelbutton:GetTall()) / 2)
    statdpanelbutton.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(0, 132, 255)) -- Button background color
    end
    statdpanelbutton:SetTextColor(Color(255, 255, 255)) -- Set the text color to white
    statdpanelbutton.DoClick = function(self)
        statpanel:Remove()
    end
    

    local shopheight = statpanel:GetTall()
    local margin = 15
    local availableHeight = statpanel:GetTall() - headerHeight - margin * 26.5 - statheader:GetTall()
    local yspace = shopheight * 0.008
    for k, itemData in pairs (SIMPLESERVERSHOP.Items) do
        local itemPanel = vgui.Create("DPanel", scroll)
        itemPanel:SetSize(statpanel:GetWide() - 30, availableHeight)
        itemPanel:DockMargin(10, 25, 10, yspace)
        itemPanel:SetTall(shopheight * 0.115)
        itemPanel:Dock(TOP)
        itemPanel.Paint = function(me, w, h)
        surface.SetDrawColor(0, 132, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.RoundedBox(5, 1, 1, w - 2, h - 2, Color(100, 100, 100, 35))
            draw.SimpleText(itemData.name, "statnpc_18", w * 0.05, h * 0.2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            if type(itemData.access) == "table" then
                local accessString = table.concat(itemData.access, ", ")
                draw.SimpleText("Access: " .. accessString, "statnpc_15", w * 0.05, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            elseif itemData.access then
                draw.SimpleText("Access: " .. itemData.access, "statnpc_15", w * 0.05, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("Access: All", "statnpc_15", w * 0.05, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            draw.SimpleText(itemData.description, "statnpc_15", w * 0.05, h * 0.8, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local icon = vgui.Create("DModelPanel", itemPanel)
        icon:SetWide(110) -- Adjust width as needed
        icon:SetTall(100)
        icon:SetModel(itemData.model)
        icon:SetFOV(50)
        local num = 0.7
        local min, max = icon.Entity:GetRenderBounds()
        icon:SetCamPos(min:Distance(max) * Vector(num, num, num))
        icon:SetLookAt((max + min) / 2)
        function icon:LayoutEntity(ENTITY) return end
        local buttonWidth = 100  -- Width of the button
        local margin = 10  -- Margin between the icon and button
        local iconX = itemPanel:GetWide() - buttonWidth - margin - icon:GetWide() 
        local iconY = (itemPanel:GetTall() - icon:GetTall()) / 2
        icon:SetPos(iconX, iconY)
                        
        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:Dock(RIGHT)
        buyButton:SetWide(100)
        buyButton:SetFont("statnpc_15")
        buyButton:SetText(DarkRP.formatMoney(itemData.price))
        buyButton:SetTextColor(Color(255, 255, 255))
        buyButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(65, 105, 225) or Color(30, 144, 255) -- Change color on hover
            draw.RoundedBox(2, 0, 0, w, h, bgColor)
        end
        buyButton:SetText(DarkRP.formatMoney(itemData.price))
        buyButton.DoClick = function (self)
            
            net.Start("ShopItem_Purchase")
            net.WriteInt(k,32)
            net.SendToServer()
        end
    end

end


local interactingNPCs = {} -- Table to track interacting NPCs

function ENT:Interact(player)
    if not interacting then 
        interacting = true 
        CreateShopNPCPanel() 
        timer.Simple(1.5, function()
            interacting = false
        end)
    end
end

hook.Add("KeyPress", "NPCShopInteractionKeyPress", function(ply, key)
    if key == IN_USE then
        local trace = ply:GetEyeTrace()
        local entity = trace.Entity
        if IsValid(entity) and isfunction(entity.Interact) then
            if entity:IsNPC() and not interactingNPCs[entity] then
                entity:Interact(ply)
                interactingNPCs[entity] = true
            end
        end
    end
end)

-- Clean up function to reset interaction flags when an NPC entity is removed
hook.Add("EntityRemoved", "NPCShopEntityRemoved", function(ent)
    if ent:IsNPC() then
        interactingNPCs[ent] = nil -- Reset interaction flag for the removed NPC entity
    end
end)

-- Clean up function to reset interaction flag when the entity is removed
function ENT:OnRemove()
    interacting = false 
    entReference = nil 
end

hook.Add("PostDrawOpaqueRenderables", "DrawShopNPCName", function()
    for _, ent in ipairs(ents.FindByClass("shop_npc")) do
        local pos = ent:GetPos() + Vector(0, 0, 80) -- Adjust the offset as needed
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        local iconSize = 100 -- Adjust the size of the icon
        local textOffset = iconSize / 2 + 10 -- Adjust the offset between icon and text
        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1) -- Adjust the scale as needed
            draw.SimpleTextOutlined((SIMPLESERVERSHOP.Theme["NPCSHOPNAME"]), "statnpc_55", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        cam.End3D2D()
    end
end)
