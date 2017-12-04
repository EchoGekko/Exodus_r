local ItemId = pExodus.ItemId
local rng = pExodus.RNG

pExodus:AddItemCostume(ItemId.MYSTERIOUS_MUSTACHE, pExodus.CostumeId.MYSTERIOUS_MUSTACHE)

local ItemCount = {}
local CoinCount = {}

function pExodus.mysteriousMustacheUpdate()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        local pIndex = pExodus.Players[i].index
        
        local currentSoulHearts = player:GetSoulHearts()
        local currentItems = player:GetCollectibleCount()
        local currentCoins = player:GetNumCoins()
        local roomType = pExodus.Room:GetType()
        
        if player:HasCollectible(ItemId.MYSTERIOUS_MUSTACHE) then
            if currentItems > ItemCount[pIndex] and roomType == RoomType.ROOM_SHOP and rng:RandomInt(2) == 1 then
                player:AddHearts(1)
                
                if currentSoulHearts ~= player:GetSoulHearts() then
                    currentSoulHearts = player:GetSoulHearts()
                    player:AddHearts(-1 * currentSoulHearts)
                    player:AddHearts(1)
                    player:AddSoulHearts(currentSoulHearts)
                end
            end
            
            if currentCoins < CoinCount[pIndex] and roomType == RoomType.ROOM_SHOP and rng:RandomInt(100) == 1 then
                player:AddCoins(CoinCount[pIndex] - currentCoins)
            end
        end
        
        ItemCount[pIndex] = currentItems
        CoinCount[pIndex] = currentCoins
    end
end
  
pExodus:AddModCallback(ModCallbacks.MC_POST_UPDATE, pExodus.mysteriousMustacheUpdate)