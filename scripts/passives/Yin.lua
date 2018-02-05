local ItemId = pExodus.ItemId
local CostumeId = pExodus.CostumeId

pExodus.ItemId.YIN = Isaac.GetItemIdByName("Yin")
pExodus.CostumeId.YIN = Isaac.GetCostumeIdByPath("gfx/characters/costume_Yin.anm2")
pExodus:AddItemCostume(ItemId.YIN, pExodus.CostumeId.YIN)

function pExodus.yinCache(player, flag)
	local heartmap = player:GetBlackHearts()
	local blackhearts = 0
	while heartmap > 0 do
		heartmap = heartmap - 2^(math.floor(math.log(heartmap) / math.log(2)))
		blackhearts = blackhearts + 1
	end
	local soulhearts = player:GetSoulHearts() - (blackhearts * 2)
	if flag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(ItemId.YIN) then
		if player:HasCollectible(ItemId.YANG) then
			player.MaxFireDelay = player.MaxFireDelay - blackhearts
		else
			player.MaxFireDelay = player.MaxFireDelay - blackhearts + math.ceil(soulhearts / 2)
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.yinCache)