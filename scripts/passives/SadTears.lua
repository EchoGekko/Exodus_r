local ItemId = pExodus.ItemId
local rng = RNG()

pExodus.ItemId.SAD_TEARS = Isaac.GetItemIdByName("Sad Tears")
pExodus.CostumeId.SAD_TEARS = Isaac.GetCostumeIdByPath("gfx/characters/costume_Sad Tears.anm2")
pExodus:AddItemCostume(ItemId.SAD_TEARS, pExodus.CostumeId.SAD_TEARS)

function pExodus.sadTearsUpdate()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.SAD_TEARS) then
		for i, entity in pairs(pExodus.RoomEntities) do
			local data = entity:GetData()
			
			if entity.Type == EntityType.ENTITY_TEAR and data.IsSadTear ~= true then
				if player.FireDelay == player.MaxFireDelay and rng:RandomInt(math.max(1, 5 - player.Luck)) == 0 and entity.FrameCount > 1 then
					local shot_tear = player:FireTear(entity.Position, RandomVector() * entity.Velocity:Length() * ((player.ShotSpeed + 0.4) / player.ShotSpeed), false, false, false)
					data.IsSadTear = true
				end
			end
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.sadTearsUpdate)

function pExodus.sadTearsCache(player, flag)
    if player:HasCollectible(ItemId.SAD_TEARS) then
        if flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = math.max(player.ShotSpeed - 0.35, 0.4)
        end
        if flag == CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight - 2.5
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.sadTearsCache, CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE)