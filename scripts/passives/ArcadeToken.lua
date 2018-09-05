local ItemId = pExodus.ItemId

pExodus.ItemId.ARCADE_TOKEN = Isaac.GetItemIdByName("Arcade Token")

function pExodus.arcadeTokenUpdate()
	local player = Isaac.GetPlayer(0)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Isaac.GetFreeNearPosition(player.Position, 50), pExodus.NullVector, nil)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.arcadeTokenUpdate, ItemId.ARCADE_TOKEN)

function pExodus.arcadeTokenCoinCollect(pickup, collider, low)
	player = Isaac.GetPlayer(0)

	if player:HasCollectible(pExodus.ItemId.ARCADE_TOKEN) then
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

pExodus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, pExodus.arcadeTokenCoinCollect, { PickupVariant.PICKUP_COIN })