local ItemId = pExodus.ItemId
local ItemVariables = pExodus.ItemVariables

pExodus.ItemId.MUTANT_CLOVER = Isaac.GetItemIdByName("Mutant Clover")

function pExodus.mutantCloverNewRoom()
    local player = Isaac.GetPlayer(0)
    
    ItemVariables.MUTANT_CLOVER.Used = 0
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
    player:EvaluateItems()
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.mutantCloverNewRoom)

function pExodus.mutantCloverCache(player, flag)
    if player:HasCollectible(ItemId.MUTANT_CLOVER) and ItemVariables.MUTANT_CLOVER.Used > 0 then
        if flag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + (10 * ItemVariables.MUTANT_CLOVER.Used)
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.mutantCloverCache)

function pExodus.mutantCloverUse(active)
    local player = Isaac.GetPlayer(0)

	if active == ItemId.MUTANT_CLOVER then
		ItemVariables.MUTANT_CLOVER.Used = ItemVariables.MUTANT_CLOVER.Used + 1
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
		
		pExodus.LiftActive = true
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.mutantCloverUse)