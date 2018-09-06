local ItemId = pExodus.ItemId
local ItemVariables = pExodus.ItemVariables
local game = pExodus.Game

pExodus.ItemId.PSEUDOBULBAR_AFFECT = Isaac.GetItemIdByName("The Pseudobulbar Affect")

function pExodus.pseudobulbarTurretUpdate()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        local level = game:GetLevel()
        local room = game:GetRoom()
        
        if data.IsPseudobulbarTurret then
            if player.FireDelay == player.MaxFireDelay then
                if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
                    pExodus:FireTurretBullet(entity.Position + Vector(-1 * entity.Size, 0) , Vector(-15, 0) * player.ShotSpeed + entity.Velocity, entity)
                elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
                    pExodus:FireTurretBullet(entity.Position + Vector(entity.Size, 0), Vector(15, 0) * player.ShotSpeed + entity.Velocity, entity)
                elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
                    pExodus:FireTurretBullet(entity.Position + Vector(0, -1 * entity.Size), Vector(0, -15) * player.ShotSpeed + entity.Velocity, entity)
                elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
                    pExodus:FireTurretBullet(entity.Position + Vector(0, entity.Size), Vector(0, 15) * player.ShotSpeed + entity.Velocity, entity)
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.pseudobulbarTurretUpdate)

function pExodus.pseudobulbarAffectRender()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.PSEUDOBULBAR_AFFECT) then
        ItemVariables.PSEUDOBULBAR_AFFECT.Icon.Color = Color(1, 1, 1, 0.5, 0, 0, 0)
        ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Update()
        ItemVariables.PSEUDOBULBAR_AFFECT.Icon:LoadGraphics()
        
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:GetData().IsPseudobulbarTurret then
                ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Render(game:GetRoom():WorldToScreenPosition(entity.Position + Vector(0, entity.Size)), pExodus.NullVector, pExodus.NullVector)
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_RENDER, pExodus.pseudobulbarAffectRender)

function pExodus.pseudobulbarAffectUse(active)
    local player = Isaac.GetPlayer(0)
	
	if active == ItemId.PSEUDOBULBAR_AFFECT then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy() then
				entity:GetData().IsPseudobulbarTurret = true
			end
		end
		
		pExodus.LiftActive = true
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.pseudobulbarAffectUse)