local Entities = pExodus.Entities

local PartsMax = 8
local Parts = { 0, 0, 0, 0 }
local HPPos = { Vector(36, 12), Vector(332, 12), Vector(46, 247), Vector(324, 247) }
local RenderBar = Sprite()
RenderBar:Load("gfx/effects/Gluttony Stomach Bar.anm2", true)
RenderBar.Scale = Vector(1.3, 1.3)

function pExodus.gluttonysStomachPickup(pickup, collider, low)
    local player = collider:ToPlayer()
    local playerIndex = pExodus.GetPlayerByRef(player).index
    
    if player then
        if player:HasCollectible(pExodus.ItemId.GLUTTONYS_STOMACH) and player:HasFullHearts() and Parts[playerIndex] < PartsMax then
            local parts
            local effect
            
            if pickup.SubType == HeartSubType.HEART_HALF then
                parts = 1
                effect = Entities.PART_UP.variant
            elseif pickup.SubType == HeartSubType.HEART_FULL then
                parts = 2
                effect = Entities.PART_UP_UP.variant
            elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
                parts = 4
                effect = Entities.PART_UP_UP_UP.variant
            else
                return nil
            end
            
            Parts[playerIndex] = Parts[playerIndex] + parts
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, pExodus.NullVector, pickup)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, player.Position, pExodus.NullVector, player)
            pickup:PlayPickupSound()
            pickup:Remove()
        end
        
        if Parts[playerIndex] >= PartsMax and player:GetMaxHearts() < 24 then
            Parts[playerIndex] = Parts[playerIndex] - PartsMax
            player:AddMaxHearts(2, false)
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, pExodus.gluttonysStomachPickup, { PickupVariant.PICKUP_HEART })

function pExodus.gluttonysStomachRender()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        local playerIndex = pExodus.Players[i].index
        local playerType = player:GetPlayerType()
        local Hearts = math.max(1, player:GetMaxHearts() / 2)
        local level = pExodus.Level
        local room = pExodus.Room
        
        if player:HasCollectible(pExodus.ItemId.GLUTTONYS_STOMACH) and playerType ~= PlayerType.PLAYER_THELOST and playerType ~= PlayerType.PLAYER_KEEPER and (level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN) and (room:GetType() ~= RoomType.ROOM_BOSS or room:GetFrameCount() >= 1) then
            RenderBar.Scale = Vector(1.3, 1.3)
            RenderBar:SetFrame("Heart", math.min(PartsMax, Parts[playerIndex]))
             
            local renderMod = 3
            if i == 1 then
                renderMod = 6
            end
            
            local heartDiv = math.floor((Hearts - 1) / renderMod)
            RenderBar:Render(HPPos[i] + Vector(12 * (((Hearts - 1) % renderMod) + 1), (12 - (heartDiv / 2)) * heartDiv), pExodus.NullVector, pExodus.NullVector)
        elseif Parts[playerIndex] > 0 and not player:HasCollectible(pExodus.ItemId.GLUTTONYS_STOMACH) then
            Parts[playerIndex] = 0
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_RENDER, pExodus.gluttonysStomachRender)