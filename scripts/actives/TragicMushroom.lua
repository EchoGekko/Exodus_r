local ItemId = pExodus.ItemId
local sfx = pExodus.SFX
local ItemVariables = pExodus.ItemVariables

pExodus.ItemId.TRAGIC_MUSHROOM = Isaac.GetItemIdByName("Tragic Mushroom")

function pExodus.tragicMushroomCache(player, flag)
    for i = 1, ItemVariables.TRAGIC_MUSHROOM.Uses do
        local ratio = 1 / (1<<(i - 1))
        
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = (player.Damage + (0.8 * ratio)) * (ratio + 1)
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight - (7.25 * ratio)
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + (0.6 * ratio)
        end
    end
end
    
pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.tragicMushroomCache)

function pExodus.tragicMushroomUse(active)
    local player = Isaac.GetPlayer(0)

	if active == ItemId.TRAGIC_MUSHROOM then
		if player:GetPlayerType() == PlayerType.PLAYER_XXX then
			local maxhp = player:GetSoulHearts() - 2
			player:AddSoulHearts(-maxhp)
		else
			local maxhp = player:GetMaxHearts() - 2
			player:AddSoulHearts(-player:GetSoulHearts())
			player:AddMaxHearts(-maxhp)
			player:AddHearts(2)
		end
		
		ItemVariables.TRAGIC_MUSHROOM.Uses = ItemVariables.TRAGIC_MUSHROOM.Uses + 1
		sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE + CacheFlag.CACHE_RANGE + CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
		player:RemoveCollectible(ItemId.TRAGIC_MUSHROOM)
		
		pExodus.LiftActive = true
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.tragicMushroomUse)