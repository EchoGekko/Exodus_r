pExodus.ItemId.FOOLS_GOLD = Isaac.GetItemIdByName("Fool's Gold")

function pExodus.foolsGoldAdd(player)
    player.ref:AddGoldenHearts(1)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL, Isaac.GetFreeNearPosition(player.ref.Position, 50), pExodus.NullVector, nil)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.foolsGoldAdd, pExodus.ItemId.FOOLS_GOLD)