local ItemId = pExodus.ItemId
local rng = pExodus.RNG

pExodus.ItemId.THE_APOCRYPHON = Isaac.GetItemIdByName("The Apocryphon")

local PlayerStats = {}
local Caches = {
    CacheFlag.CACHE_DAMAGE,
    CacheFlag.CACHE_FIREDELAY,
    CacheFlag.CACHE_SPEED,
    CacheFlag.CACHE_SHOTSPEED,
    CacheFlag.CACHE_LUCK,
    CacheFlag.CACHE_RANGE
}

function pExodus.theApocryphonNewLevel()
   for i = 1, 4 do
        PlayerStats[i] = {}
        
        for u, cache in ipairs(Caches) do
            PlayerStats[i][cache] = 0
        end
    end
    
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, pExodus.theApocryphonNewLevel)

function pExodus.theApocryphonNewRoom()
    local room = pExodus.Room
    local level = pExodus.Level
    
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        local playerIndex = pExodus.Players[i].index
        
        if player:HasCollectible(ItemId.THE_APOCRYPHON) and PlayerStats[playerIndex] then
            if room:GetType() ~= RoomType.ROOM_DEFAULT and room:IsFirstVisit() then
                for z = 1, player:GetCollectibleNum(ItemId.THE_APOCRYPHON) do
                    for u = 1, rng:RandomInt(2) + 1 do
                        local stat = Caches[rng:RandomInt(#Caches) + 1]
                        
                        if PlayerStats[playerIndex][stat] then
                            PlayerStats[playerIndex][stat] = PlayerStats[playerIndex][stat] + 1
                        else
                            PlayerStats[playerIndex][stat] = 1
                        end
                        
                        player:AddCacheFlags(stat)
                        player:EvaluateItems()
                    end
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.theApocryphonNewRoom)

function pExodus.theApocryphonCache(player, flag)
    local pIndex = pExodus.GetExodusPlayerByRef(player).index
    
    if player:HasCollectible(ItemId.THE_APOCRYPHON) and PlayerStats[pIndex] then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + (PlayerStats[pIndex][flag] * 0.5)
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - PlayerStats[pIndex][flag]
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + (PlayerStats[pIndex][flag] * 0.1)
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + (PlayerStats[pIndex][flag] * 0.1)
        elseif flag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + PlayerStats[pIndex][flag]
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight - (PlayerStats[pIndex][flag] * 0.25)
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.theApocryphonCache)