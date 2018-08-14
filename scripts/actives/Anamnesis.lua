local ItemId = pExodus.ItemId
local playerVars = {}

pExodus.ItemId.ANAMNESIS = Isaac.GetItemIdByName("Anamnesis")

function pExodus.anamnesisResetTable()
    playerVars = {
        { IsHolding = false, Charge = 0 },
        { IsHolding = false, Charge = 0 },
        { IsHolding = false, Charge = 0 },
        { IsHolding = false, Charge = 0 }
    }
end

pExodus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, pExodus.anamnesisResetTable)

function pExodus.anamnesisUse()
	local player = pExodus:UsedPlayer().ref
	
	local config = Isaac.GetItemConfig()
	local collectibleList = {}
	
	for i = 1, #config:GetCollectibles() do
		local value = config:GetCollectible(i)
		
		if value and player:HasCollectible(value.ID) then
			table.insert(collectibleList, value.ID)
		end
	end
	
	for i, entity in pairs(pExodus.RoomEntities) do
		local pickup = entity:ToPickup()
		
		if pickup and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectibleList[math.random(#collectibleList)], true)
		end
	end
	
	return true
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.anamnesisUse, ItemId.ANAMNESIS)

function pExodus.anamnesisUpdate()
    for pIndex = 1, pExodus.PlayerCount do
        local player = pExodus.Players[pIndex].ref
        
        if player:HasCollectible(ItemId.ANAMNESIS) then
            local charge = player:GetActiveCharge()
            
            if not playerVars[pIndex].IsHolding then
                if charge == 6 and playerVars[pIndex].Charge ~= 6 then
                    player:SetActiveCharge(0)
                    playerVars[pIndex].Charge = 0  
                elseif charge ~= playerVars[pIndex].Charge then
                    player:SetActiveCharge(playerVars[pIndex].Charge)
                end    
                
                playerVars[pIndex].IsHolding = true
            else
                playerVars[pIndex].Charge = charge
            end
        elseif playerVars[pIndex].IsHolding then
            playerVars[pIndex].IsHolding = false
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.anamnesisUpdate)