local ItemVariables = pExodus.ItemVariables
local ItemId = pExodus.ItemId
local sfx = pExodus.SFX

pExodus.ItemId.DADS_BOOTS = Isaac.GetItemIdByName("Dad's Boots")
pExodus.CostumeId.DADS_BOOTS = Isaac.GetCostumeIdByPath("gfx/characters/costume_Dad's Boots.anm2")
pExodus:AddItemCostume(ItemId.DADS_BOOTS, pExodus.CostumeId.DADS_BOOTS)

local Squishables = {
    { id = EntityType.ENTITY_MAGGOT }, --ID 21
    { id = EntityType.ENTITY_CHARGER }, --ID 23
    { id = EntityType.ENTITY_BOIL }, --ID 30
    { id = EntityType.ENTITY_SPITY }, --ID 31
    { id = EntityType.ENTITY_BRAIN }, --ID 32
    { id = EntityType.ENTITY_LUMP }, --ID 56
    { id = EntityType.ENTITY_PARA_BITE }, --ID 58
    { id = EntityType.ENTITY_EMBRYO }, --ID 77
    { id = EntityType.ENTITY_SPIDER }, --ID 85
    { id = EntityType.ENTITY_BIGSPIDER }, --ID 94
    { id = EntityType.ENTITY_BABY_LONG_LEGS, variant = Isaac.GetEntityVariantByName("Small Baby Long Legs") }, --ID 206, Variant 1
    { id = EntityType.ENTITY_CRAZY_LONG_LEGS, variant = Isaac.GetEntityVariantByName("Small Crazy Long Legs") }, --ID 207, Variant 1
    { id = EntityType.ENTITY_SPIDER_L2 }, --ID 215
    { id = EntityType.ENTITY_CORN_MINE }, --ID 217
    { id = EntityType.ENTITY_CONJOINED_SPITTY }, --ID 243
    { id = EntityType.ENTITY_ROUND_WORM }, --ID 244
    { id = EntityType.ENTITY_RAGLING }, --ID 246
    { id = EntityType.ENTITY_NIGHT_CRAWLER } --ID 255
} 

function pExodus.dadsBootsUpdate()
    for pIndex = 1, pExodus.PlayerCount do
        local player = pExodus.Players[pIndex].ref
        
        if player:HasCollectible(ItemId.DADS_BOOTS) then
            for i, entity in pairs(pExodus.RoomEntities) do
                if entity:IsActiveEnemy(false) then
                    for v, squishy in pairs(Squishables) do
                        if squishy.id == entity.Type and (squishy.variant == entity.Variant or squishy.variant == nil) and (squishy.subtype == entity.SubType or squishy.subtype == nil) and
                        entity.Position:DistanceSquared(player.Position) < (player.Size + entity.Size)^2 and pExodus:PlayerIsMoving(player) then
                            entity:Die()
                            sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, entity.Size / 8)
                        end
                    end
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.dadsBootsUpdate)

function pExodus.dadsBootsDamage(target, amount, flag, source, cdtimer)
    local player = target:ToPlayer()
    
    if player and player:HasCollectible(ItemId.DADS_BOOTS) then
        if (flag & DamageFlag.DAMAGE_SPIKES) > 0 or (flag & DamageFlag.DAMAGE_ACID) > 0 then
            return false
        end
        
        for i, squishy in pairs(Squishables) do
            if squishy.id == source.Type and (squishy.variant == source.Variant or squishy.variant == nil) and (squishy.subtype == source.SubType or squishy.subtype == nil) then
                if pExodus:PlayerIsMoving(player) then
                    return false
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.dadsBootsDamage, { EntityType.ENTITY_PLAYER })

function pExodus.dadsBootsCache(player, flag)
    if player:HasCollectible(ItemId.DADS_BOOTS) then
        if flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.1
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.dadsBootsCache, CacheFlag.CACHE_SPEED)