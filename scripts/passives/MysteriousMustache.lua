local ItemId = pExodus.ItemId
local rng = RNG()

pExodus.ItemId.MYSTERIOUS_MUSTACHE = Isaac.GetItemIdByName("Mysterious Mustache")
pExodus.CostumeId.MYSTERIOUS_MUSTACHE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Mysterious Mustache.anm2")
pExodus:AddItemCostume(ItemId.MYSTERIOUS_MUSTACHE, pExodus.CostumeId.MYSTERIOUS_MUSTACHE)

local ItemCount = nil
local CoinCount = nil

function pExodus.mysteriousMustacheUpdate()
	local player = Isaac.GetPlayer(0)
	
	local currentSoulHearts = player:GetSoulHearts()
	local currentItems = player:GetCollectibleCount()
	local currentCoins = player:GetNumCoins()
	local roomType = pExodus.Room:GetType()
	
	if player:HasCollectible(ItemId.MYSTERIOUS_MUSTACHE) then
		if currentItems > ItemCount and roomType == RoomType.ROOM_SHOP and rng:RandomInt(2) == 0 then
			player:AddHearts(1)
			
			if currentSoulHearts ~= player:GetSoulHearts() then
				currentSoulHearts = player:GetSoulHearts()
				player:AddHearts(-1 * currentSoulHearts)
				player:AddHearts(1)
				player:AddSoulHearts(currentSoulHearts)
			end
		end
		
		if currentCoins < CoinCount and roomType == RoomType.ROOM_SHOP and rng:RandomInt(100) == 0 then
			player:AddCoins(CoinCount - currentCoins)
		end
	end
	
	ItemCount = currentItems
	CoinCount = currentCoins
end
  
pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.mysteriousMustacheUpdate)