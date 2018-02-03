local ItemVariables = pExodus.ItemVariables
local Entities = pExodus.Entities
local ItemId = pExodus.ItemId
local game = pExodus.Game

pExodus.ItemId.COBALT_NECKLACE = Isaac.GetItemIdByName("Cobalt Necklace")

local Count = 0
local Counter = nil
local IsRoomClear = false
local HasCobaltNecklace = false

local function setScoreDisplay()
    if Counter then
        local sprite = Counter:GetSprite()
        
        if Count <= 101 then
            sprite:SetFrame("Frames", Count)
        else
            sprite:SetFrame("Frames", 102)
        end
        
        sprite:Stop()
    end
end

function pExodus.cobaltNecklaceUpdate()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        
        if player:HasCollectible(ItemId.COBALT_NECKLACE) then
            local room = game:GetRoom()
            
            if HasCobaltNecklace then
                Counter = Isaac.Spawn(Entities.SCORE_DISPLAY.id, Entities.SCORE_DISPLAY.variant, 0, player.Position + Vector(0, -69), Vector(0, 0), player)
                Count = 0
                HasCobaltNecklace = true
                setScoreDisplay()
            end
            
            if room:IsClear() then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
                
                if not IsRoomClear then
                    if room:GetRoomShape() == RoomShape.ROOMSHAPE_2x2 then
                        Count = Count + 2
                    else
                        Count = Count + 1
                    end
                    
                    setScoreDisplay()  
                    IsRoomClear = true
                end
            else
                IsRoomClear = false
            end
        elseif HasCobaltNecklace then
            HasCobaltNecklace = false
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.cobaltNecklaceUpdate)

function pExodus.cobaltNecklaceNewRoom()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        
        if player:HasCollectible(ItemId.COBALT_NECKLACE) and (not Counter or not Counter:Exists()) then
            Counter = Isaac.Spawn(Entities.SCORE_DISPLAY.id, Entities.SCORE_DISPLAY.variant, 0, player.Position + Vector(0, -69), pExodus.NullVector, player)
            setScoreDisplay()
        end 
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.cobaltNecklaceNewRoom)

function pExodus.cobaltNecklaceDamage(target, amount, flags, source, cdtimer)
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        
        if player:HasCollectible(ItemId.COBALT_NECKLACE) then
            Count = 0
            setScoreDisplay()
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.cobaltNecklaceDamage, { EntityType.ENTITY_PLAYER })

function pExodus.cobaltNecklaceCache(player, flag)
    if player:HasCollectible(ItemId.COBALT_NECKLACE) and flag == CacheFlag.CACHE_DAMAGE and Count >= 0 then
        player.Damage = player.Damage + (math.floor(((Count * 0.7)^0.7) * 100)) / 150 * player:GetCollectibleNum(ItemId.COBALT_NECKLACE)
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.cobaltNecklaceCache, CacheFlag.CACHE_DAMAGE)

function pExodus.cobaltNecklaceRender()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        
        if Counter then
            if player:HasCollectible(ItemId.COBALT_NECKLACE) then
                Counter.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                Counter.Position = player.Position + Vector(0, -69) + player.Velocity
            else
                Counter:Remove()
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_RENDER, pExodus.cobaltNecklaceRender)