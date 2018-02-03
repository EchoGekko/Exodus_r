local Entities = pExodus.Entities
local sfx = pExodus.SFX

Entities.BLOCKAGE = pExodus.GetEntity("Blockage")
pExodus:SetupEntity(Entities.BLOCKAGE, pExodus.ChampionFlag.NONE)

function pExodus.blockageEntityUpdate(entity, data)
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    local room = pExodus.Room
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    local player = pExodus.Players[1].ref
    local dist = math.huge
    
    for i = 1, pExodus.PlayerCount do
        local ePlayer = pExodus.Players[i].ref
        local checkDist = ePlayer.Position:DistanceSquared(entity.Position)
        
        if checkDist < dist then
            dist = checkDist
            player = ePlayer
        end
    end
    
    if entity.State ~= 2 then
        data.State2Frames = 0
    end
    
    if entity.State ~= 3 then
        data.State3Frames = 0
    end
    
    if entity.State ~= 4 then
        data.State4Frames = 0
    end
    
    if entity.State == 0 then -- Appearing and Burrowing - Initialization
        if sprite:IsFinished("Appear") then
            sprite:Play("Burrow", false)
            sfx:Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 1, 0, false, 1)
        end
        
        if sprite:IsFinished("Burrow") then
            entity.Visible = false
            entity.State = 2
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    elseif entity.State == 2 then -- Burrowed
        data.State2Frames = data.State2Frames + 1
        
        if data.State2Frames == 1 then
            data.State2SpikeTime = math.random(20, 100)
        end
        
        if data.State2Frames == data.State2SpikeTime then
            entity.State = 3
            entity.Visible = true
        end
    elseif entity.State == 3 then -- Attacking
        data.State3Frames = data.State3Frames + 1
        sprite:Play("Spike", false)
        
        if sprite:IsEventTriggered("Spike") then
            sfx:Play(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 1)
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        elseif sprite:IsEventTriggered("Retreat") then
            sfx:Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 1, 0, false, 1)
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        elseif sprite:IsEventTriggered("Spike Pop") and data.State3Frames < 170 then
            entity.Position = player.Position
        elseif sprite:IsEventTriggered("Spike Pop Initial") and data.State3Frames < 40 then
            entity.Position = player.Position
        end
        
        if data.State3Frames == 179 then
            entity.State = 4
            entity.Position = room:FindFreeTilePosition(room:GetRandomPosition(40), 5)
        end
    elseif entity.State == 4 then -- Watching
        data.State4Frames = data.State4Frames + 1
        
        if data.State4Frames == 1 then
            data.State4BurrowTime = math.random(40, 200)
            sprite:Play("Emerge", false)
            sfx:Play(SoundEffect.SOUND_MAGGOT_BURST_OUT, 1, 0, false, 1)
        end
        
        if data.State4Frames == 13 then
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end
        
        if sprite:IsFinished("Emerge") then
            sprite:Play("Watching", false)
        end
        
        if data.State4Frames == data.State4BurrowTime then
            sprite:Play("Burrow", false)
            sfx:Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 1, 0, false, 1)    
        end
        
        if data.State4Frames > 30 and data.State4Frames < data.State4BurrowTime then
            if entity.Position.X < player.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        end
        
        if sprite:IsFinished("Burrow") and data.State4Frames >= data.State4BurrowTime then
            entity.Visible = false
            entity.State = 2
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, pExodus.blockageEntityUpdate, { Entities.BLOCKAGE.id, Entities.BLOCKAGE.variant })