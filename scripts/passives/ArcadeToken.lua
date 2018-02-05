local ItemId = pExodus.ItemId

pExodus.ItemId.ARCADE_TOKEN = Isaac.GetItemIdByName("Arcade Token")

function pExodus.arcadeTokenAdd(player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Isaac.GetFreeNearPosition(player.ref.Position, 50), pExodus.NullVector, nil)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.arcadeTokenAdd, ItemId.ARCADE_TOKEN)

function pExodus.arcadeTokenCoinCollect(pickup, collider, low)
	local player = collider:ToPlayer()
    
	if player then
		local coinCount = player:GetNumCoins()
		local pickupValue = pickup:GetCoinValue()
		
		if coinCount + pickupValue >= 100 then
			player:AddCoins(pickupValue - 100)
			player:AddCollectible(CollectibleType.COLLECTIBLE_ONE_UP, 0, false)
			pickup:PlayPickupSound()
			pickup:Remove()
			return false
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, pExodus.arcadeTokenCoinCollect, false, PickupVariant.PICKUP_COIN)