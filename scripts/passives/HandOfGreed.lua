local ItemId = pExodus.ItemId
local CostumeId = pExodus.CostumeId

pExodus.ItemId.HAND_OF_GREED = Isaac.GetItemIdByName("Hand of Greed")
pExodus.CostumeId.KEEPER_HAND_OF_GREED = Isaac.GetCostumeIdByPath("gfx/characters/costume_Keeper Hand of Greed.anm2")
pExodus.CostumeId.HAND_OF_GREED = Isaac.GetCostumeIdByPath("gfx/characters/costume_Hand of Greed.anm2")

local shopItems = {}
local redHearts = nil
local soulHearts = nil
local activeItems = nil

function pExodus.greedHandAdd()
    local coinCount = 3
    local player = Isaac.GetPlayer(0)
    
    if player:GetName() == "Keeper" then
        player:AddNullCostume(CostumeId.KEEPER_HAND_OF_GREED)
        coinCount = 6
    else
        player:AddNullCostume(CostumeId.HAND_OF_GREED)
    end
    
    for i = 1, coinCount do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Isaac.GetFreeNearPosition(player.Position, 50), pExodus.NullVector, nil)
    end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.greedHandAdd, ItemId.HAND_OF_GREED)

function pExodus.greedHandRemove(noneLeft)
    local player = Isaac.GetPlayer(0)
	
    if noneLeft then
        player:TryRemoveNullCostume(CostumeId.KEEPER_HAND_OF_GREED)
        player:TryRemoveNullCostume(CostumeId.HAND_OF_GREED)
    end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_REMOVE_COLLECTIBLE, pExodus.greedHandRemove, ItemId.HAND_OF_GREED)

function pExodus.greedHandUpdate()
    local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.HAND_OF_GREED) then
		if pExodus.Room:GetType() == RoomType.ROOM_DEVIL then
			for i, entity in pairs(pExodus.RoomEntities) do
				local pickup = entity:ToPickup()
				
				if pickup and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Price ~= nil then
					local basePrice = 15
					
					if pickup.Price == PickupPrice.PRICE_TWO_HEARTS then
						basePrice = 30
					end
					
					pickup.Price = math.max(0, basePrice - (math.ceil(basePrice / 2) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STEAM_SALE)))
				end
			end
		end
		
		redHearts = player:GetMaxHearts()
		soulHearts = player:GetSoulHearts()
		activeItems = player:GetActiveItem()
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.greedHandUpdate)

function pExodus.greedHandNewLevel()
    local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.HAND_OF_GREED) then
		local coinCount = 3
		
		if player:GetName() == "Keeper" then
			coinCount = 6
		end
		
		for i = 1, coinCount do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Isaac.GetFreeNearPosition(player.Position, 50), pExodus.NullVector, nil)
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, pExodus.greedHandNewLevel)

function pExodus.ShopInfo()
    local player = Isaac.GetPlayer(0)
	
	for i, entity in ipairs(pExodus.RoomEntities) do
		local pickup = entity:ToPickup()
		
		if pickup then
			if pickup:IsShopItem() then
				if shopItems[pickup.InitSeed] == nil then
					local itemConfig = nil
					
					if pickup.Variant == PickupVariant.PICKUP_TRINKET then
						itemConfig = Isaac.GetItemConfig():GetTrinket(pickup.SubType)
					elseif pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
						itemConfig = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
					end
					
					if itemConfig ~= nil then
						shopItems[pickup.InitSeed] = {
							pickup = pickup,
							variant = pickup.Variant,
							subType = pickup.SubType,
							value = pickup:GetCoinValue(),
							price = pickup.Price,
							devilPrice = itemConfig.DevilPrice,
							name = itemConfig.Name
						}
					end
				end
			end
		end
	end
	
	for initSeed, info in pairs(shopItems) do
		if (info.pickup:IsDead() or not info.pickup:IsShopItem() or (info.pickup.Touched and info.subType ~= info.pickup.SubType)) and pExodus.Room:GetType() == RoomType.ROOM_DEVIL then
			if info.price >= 15 then
				local price = math.max(0, info.price - (math.ceil(info.price / 2) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STEAM_SALE)))
				local hearts = math.ceil(info.price / 15) * 2
				
				player:AddMaxHearts(hearts, false)
				player:AddHearts(hearts)
				
				if player:GetNumCoins() >= price then
					player:AddCoins(-price)
				else
					player:Die()
				end
			end
			
			shopItems[initSeed] = nil
		elseif not info.pickup.Touched and info.subType ~= info.pickup.SubType then
			shopItems[initSeed] = nil
			-- Rerolled --
		elseif not info.pickup:Exists() then
			shopItems[initSeed] = nil
			-- Doesn't Exist --
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.ShopInfo)

function pExodus.greedHandNewRoom()
    shopItems = {} 
    return nil 
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.greedHandNewRoom)