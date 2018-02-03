local itemPool = pExodus.ItemPool
local game = pExodus.Game
local ItemId = pExodus.ItemId

pExodus.ItemId.BLUE_MOON = Isaac.GetTrinketIdByName("Blue Moon")

function pExodus.blueMoonUpdate(room)
    for pIndex = 1, pExodus.PlayerCount do
        local player = pExodus.Players[pIndex].ref
        
        if player:HasTrinket(ItemId.BLUE_MOON) then
            if room:GetType() == RoomType.ROOM_SECRET then
                for i = 1, room:GetGridSize() do
                    local gridEnt = room:GetGridEntity(i)
                    
                    if gridEnt then
                        if gridEnt:GetType() ~= GridEntityType.GRID_WALL and gridEnt:GetType() ~= GridEntityType.GRID_DOOR then
                            room:RemoveGridEntity(i, 0, true)
                        end
                    end
                end
                
                if room:IsFirstVisit() then
                    local startSeed = game:GetSeeds():GetStartSeed()
                    local item = itemPool:GetCollectible(ItemPoolType.POOL_BOSS, true, startSeed)
                    local item2 = itemPool:GetCollectible(ItemPoolType.POOL_BOSS, true, startSeed)
                    
                    for u, entity in pairs(pExodus.RoomEntities) do
                        if entity ~= nil then
                            if entity.Type > 3 and entity.Type ~= EntityType.ENTITY_EFFECT then
                                entity:Remove()
                            end
                        end
                    end
                    
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, Isaac.GetFreeNearPosition(room:GetCenterPos() - Vector(-32, 0), 7), pExodus.NullVector, nil)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item2, Isaac.GetFreeNearPosition(room:GetCenterPos() + Vector(-32, 0), 7), pExodus.NullVector, nil)
                    else
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, Isaac.GetFreeNearPosition(room:GetCenterPos(), 7), pExodus.NullVector, nil)
                    end
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.blueMoonUpdate)