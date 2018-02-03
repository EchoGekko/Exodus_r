local ItemVariables = pExodus.ItemVariables
local ItemId = pExodus.ItemId
local rng = pExodus.RNG

pExodus.ItemId.CURSED_METRONOME = Isaac.GetItemIdByName("Cursed Metronome")
pExodus.CostumeId.CURSED_METRONOME = Isaac.GetCostumeIdByPath("gfx/characters/costume_Cursed Metronome.anm2")
pExodus:AddItemCostume(ItemId.CURSED_METRONOME, pExodus.CostumeId.CURSED_METRONOME)

function pExodus.cursedMetronomeAdd(player)
    local hp = player.ref:GetHearts() - 2
	player.ref:AddHearts(hp * -1)
	hp = hp + 2
    
	for i = 1, rng:RandomInt(hp / 2) do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL,  Isaac.GetFreeNearPosition(player.ref.Position, 20), pExodus.NullVector, player.ref)
	end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.cursedMetronomeAdd, ItemId.CURSED_METRONOME)

function pExodus.cursedMetronomeDamage(target, amount, flags, source, cdtimer)
    local player = target:ToPlayer()
    
    if player and player:HasCollectible(ItemId.CURSED_METRONOME) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_METRONOME, false, false, false, false)
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.cursedMetronomeDamage, { EntityType.ENTITY_PLAYER })

function pExodus.cursedMetronomeCache(player, flag)
    if player:HasCollectible(ItemId.CURSED_METRONOME) then
        if flag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck - 2
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.cursedMetronomeCache, CacheFlag.CACHE_LUCK)