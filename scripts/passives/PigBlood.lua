local ItemId = pExodus.ItemId

pExodus.ItemId.PIG_BLOOD = Isaac.GetItemIdByName("Pig Blood")
pExodus.CostumeId.PIG_BLOOD = Isaac.GetCostumeIdByPath("gfx/characters/costume_Pig Blood.anm2")
pExodus:AddItemCostume(ItemId.PIG_BLOOD, pExodus.CostumeId.PIG_BLOOD)

function pExodus.pigBloodUpdate()
    local roomType = pExodus.Room:GetType()
    
    for pIndex = 1, pExodus.PlayerCount do
        local player = pExodus.Players[pIndex].ref
        
        if player:HasCollectible(ItemId.PIG_BLOOD) then
            if roomType == RoomType.ROOM_DEVIL then
                for i, entity in pairs(pExodus.RoomEntities) do
                    local data = entity:GetData()
                    
                    if entity.Type == EntityType.ENTITY_PICKUP and entity:IsDead() and not data.IsRestocked and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE or entity.Variant == PickupVariant.PICKUP_SHOPITEM) then 
                        data.IsRestocked = true
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, entity.Position, pExodus.NullVector, entity)
                    end
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.pigBloodUpdate)

function pExodus.pigBloodAdd(player)
    for i = 1, 3 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, Isaac.GetFreeNearPosition(player.ref.Position, 50), pExodus.NullVector, nil)
    end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.pigBloodAdd, ItemId.PIG_BLOOD)