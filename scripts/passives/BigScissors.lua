local Triggered = false
local rng = RNG()

pExodus.ItemId.BIG_SCISSORS = Isaac.GetItemIdByName("Big Scissors")

function pExodus.bigScissorsUpdate()
	local player = Isaac.GetPlayer(0)
	
	if Triggered and rng:RandomInt(3) == 0 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 3, player.Position, pExodus.NullVector, player)
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.bigScissorsUpdate)

function pExodus.bigScissorsDamage(target, amount, flags, source, cdtimer)
    local player = Isaac.GetPlayer(0)

    if target.Type == EntityType.ENTITY_PLAYER and player:HasCollectible(pExodus.ItemId.BIG_SCISSORS) then
        Triggered = true
        
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY + CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end 
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.bigScissorsDamage, EntityType.ENTITY_PLAYER)

function pExodus.bigScissorsNewRoom()
    Triggered = false

    local player = Isaac.GetPlayer(0)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY + CacheFlag.CACHE_SPEED)
	player:EvaluateItems()
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.bigScissorsNewRoom)

function pExodus.bigScissorsCache(player, flag)
    if player:HasCollectible(pExodus.ItemId.BIG_SCISSORS) then
        if flag == CacheFlag.CACHE_SPEED then
            if not Triggered then
                player.MoveSpeed = player.MoveSpeed + 0.4
            end
        end
        if flag == CacheFlag.CACHE_FIREDELAY then
            if Triggered then
                player.MaxFireDelay = player.MaxFireDelay - 2
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.bigScissorsCache, CacheFlag.CACHE_SPEED + CacheFlag.CACHE_FIREDELAY)