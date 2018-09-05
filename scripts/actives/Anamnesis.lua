local ItemId = pExodus.ItemId

pExodus.ItemId.ANAMNESIS = Isaac.GetItemIdByName("Anamnesis")

function pExodus.anamnesisUse(active)
	local player = Isaac.GetPlayer(0)
	
	if active == ItemId.ANAMNESIS then
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
			
			if pickup and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType > 0 then
				pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectibleList[math.random(#collectibleList)], true)
			end
		end
		
		pExodus.LiftActive = true
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.anamnesisUse, ItemId.ANAMNESIS)