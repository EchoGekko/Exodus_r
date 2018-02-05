local ItemId = pExodus.ItemId
local CostumeId = pExodus.CostumeId

pExodus.ItemId.YANG = Isaac.GetItemIdByName("Yang")
pExodus.CostumeId.YANG = Isaac.GetCostumeIdByPath("gfx/characters/costume_Yang.anm2")
pExodus:AddItemCostume(ItemId.YANG, pExodus.CostumeId.YANG)

function pExodus.yangCache(player, flag)
	local heartmap = player:GetBlackHearts()
	local blackhearts = 0
	while heartmap > 0 do
		heartmap = heartmap - 2^(math.floor(math.log(heartmap) / math.log(2)))
		blackhearts = blackhearts + 1
	end
	local soulhearts = player:GetSoulHearts() - (blackhearts * 2)
	if flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(ItemId.YANG) then
		if player:HasCollectible(ItemId.YIN) then
			player.Damage = player.Damage + (soulhearts / 2)
		else
			player.Damage = player.Damage + (soulhearts / 2) - blackhearts
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.yangCache)