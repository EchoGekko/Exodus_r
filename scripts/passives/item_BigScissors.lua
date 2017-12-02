local Triggered = {}
local rng = pExodus.rng

function pExodus.bigScissorsUpdate()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i]
        
        if Triggered[player.Index] and rng:RandomInt(3) == 0 then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 3, player.Position, pExodus.NullVector, player)
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_UPDATE, pExodus.bigScissorsUpdate)

function pExodus.bigScissorsDamage(target, amount, flags, source, cdtimer)
    local player = target:ToPlayer()
    
    if player and player:HasCollectible(pExodus.ItemId.BIG_SCISSORS) then
        Triggered[player.Index] = true
        
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY + CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end 
end

pExodus:AddModCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.bigScissorsDamage, { EntityType.ENTITY_PLAYER })

function pExodus.bigScissorsNewRoom()
    Triggered = {}
    
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i]
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY + CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.bigScissorsNewRoom)

function pExodus.bigScissorsCache(player, flag)
    if player:HasCollectible(pExodus.ItemId.BIG_SCISSORS) then
        if flag == CacheFlag.CACHE_SPEED then
            if not Triggered[player.Index] then
                player.MoveSpeed = player.MoveSpeed + 0.4
            end
        end
        if flag == CacheFlag.CACHE_FIREDELAY then
            if Triggered[player.Index] then
                player.MaxFireDelay = player.MaxFireDelay - 2
            end
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.bigScissorsCache, CacheFlag.CACHE_SPEED + CacheFlag.CACHE_FIREDELAY)