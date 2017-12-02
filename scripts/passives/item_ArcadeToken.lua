local ItemVariables = pExodus.ItemVariables
local ItemId = pExodus.ItemId

function pExodus.arcadeTokenUpdate(player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Isaac.GetFreeNearPosition(player.Position, 50), Vector(0, 0), nil)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.arcadeTokenUpdate, ItemId.ARCADE_TOKEN)

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

pExodus:AddModCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, pExodus.arcadeTokenCoinCollect, { PickupVariant.PICKUP_COIN })