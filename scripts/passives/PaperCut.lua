local ItemId = pExodus.ItemId

pExodus.ItemId.PAPER_CUT = Isaac.GetItemIdByName("Paper Cut")
pExodus.CostumeId.PAPER_CUT = Isaac.GetCostumeIdByPath("gfx/characters/costume_Paper Cut.anm2")
pExodus:AddItemCostume(ItemId.PAPER_CUT, pExodus.CostumeId.PAPER_CUT)

function pExodus.paperCutAdd()
	local player = Isaac.GetPlayer(0)

    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, Isaac.GetFreeNearPosition(player.Position, 50), pExodus.NullVector, nil)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.paperCutAdd, ItemId.PAPER_CUT)

function pExodus.paperCutCardUse()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.PAPER_CUT) then
		for i, entity in pairs(pExodus.RoomEntities) do
			if entity:IsVulnerableEnemy() then
				local damage = 10 * (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TAROT_CLOTH) + 1)
				
				entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				entity:TakeDamage(damage, 0, EntityRef(player), 0)
			end
			
			if entity.Type == EntityType.ENTITY_STONEY then
				entity:Kill()
			end
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_CARD, pExodus.paperCutCardUse)