local ItemId = pExodus.ItemId
local Entities = pExodus.Entities
local ItemVariables = pExodus.ItemVariables
local game = pExodus.Game
local sfx = pExodus.SFX

pExodus.ItemId.HURDLE_HEELS = Isaac.GetItemIdByName("Hurdle Heels")

function pExodus.hurdleHeelsUpdate()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(ItemId.HURDLE_HEELS) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end
    
    if ItemVariables.HURDLE_HEELS.JumpState == 1 and ItemVariables.HURDLE_HEELS.FrameUsed + 8 < game:GetFrameCount() then
        ItemVariables.HURDLE_HEELS.JumpState = 2
        player.Visible = false
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_FAMILIAR then
                entity.Visible = false
            end
        end
        player:SetShootingCooldown(120)
        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ItemVariables.HURDLE_HEELS.Crosshair = Isaac.Spawn(1000, 30, 0, player.Position, Vector(0,0), player)
    end
    
    if ItemVariables.HURDLE_HEELS.JumpState == 2 then
        ItemVariables.HURDLE_HEELS.Crosshair.Position = player.Position
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsEnemy() then
                entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
            if entity.Type == EntityType.ENTITY_PROJECTILE then
                entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
        end
        if ItemVariables.HURDLE_HEELS.Crosshair.FrameCount > 50 then
            ItemVariables.HURDLE_HEELS.JumpState = 3
        end
    end

    if ItemVariables.HURDLE_HEELS.JumpState == 3 then
        ItemVariables.HURDLE_HEELS.Crosshair.Position = player.Position
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsEnemy() then
                entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
            if entity.Type == EntityType.ENTITY_PROJECTILE then
                entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
        end
        if ItemVariables.HURDLE_HEELS.Crosshair.FrameCount > 60 then
            player.Position = ItemVariables.HURDLE_HEELS.Crosshair.Position
            ItemVariables.HURDLE_HEELS.Crosshair:Remove()
            ItemVariables.HURDLE_HEELS.JumpState = 4
            ItemVariables.HURDLE_HEELS.FrameUsed = game:GetFrameCount()
            player.Visible = true
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            player:UseActiveItem(CollectibleType.COLLECTIBLE_WAIT_WHAT, false, false, false, false)
            player.Position = ItemVariables.HURDLE_HEELS.Crosshair.Position
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                if entity:IsEnemy() then
                    entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                end
                if entity.Type == EntityType.ENTITY_PROJECTILE then
                    entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                end
                if player.Position:Distance(entity.Position) < 64 and entity:IsVulnerableEnemy() then
                    entity:TakeDamage(player.Damage * 4, 0, EntityRef(player), 3)
                end
                if entity.Type == EntityType.ENTITY_FAMILIAR then
                    entity.Visible = true
                end
            end
        end
    end
    if ItemVariables.HURDLE_HEELS.JumpState == 4 and ItemVariables.HURDLE_HEELS.FrameUsed + 20 < game:GetFrameCount() then
        ItemVariables.HURDLE_HEELS.JumpState = 0
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.hurdleHeelsUpdate)

function pExodus.hurdleHeelsUse(active)
    local player = Isaac.GetPlayer(0)
    if active == ItemId.HURDLE_HEELS and ItemVariables.HURDLE_HEELS.JumpState == 0 then
        ItemVariables.HURDLE_HEELS.JumpState = 1
        ItemVariables.HURDLE_HEELS.FrameUsed = game:GetFrameCount()
        player.Velocity = Vector(0,0)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_HOW_TO_JUMP, true, false, false, false)
        sfx:Play(SoundEffect.SOUND_SUPER_JUMP, 1, 0, false, 1)
    end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.hurdleHeelsUse)

function pExodus.hurdleHeelsRender()
    local player = Isaac.GetPlayer(0)
    if ItemVariables.HURDLE_HEELS.JumpState == 2 then
        ItemVariables.HURDLE_HEELS.Icon:SetFrame("Idle", ItemVariables.HURDLE_HEELS.Crosshair.FrameCount)
        ItemVariables.HURDLE_HEELS.Icon:Render(game:GetRoom():WorldToScreenPosition(Vector(player.Position.X, player.Position.Y - ((ItemVariables.HURDLE_HEELS.Crosshair.FrameCount) * 32))), pExodus.NullVector, pExodus.NullVector)
    end
    if ItemVariables.HURDLE_HEELS.JumpState == 3 then
        ItemVariables.HURDLE_HEELS.Icon:SetFrame("Idle", (ItemVariables.HURDLE_HEELS.Crosshair.FrameCount - 60) * -1)
        ItemVariables.HURDLE_HEELS.Icon:Render(game:GetRoom():WorldToScreenPosition(Vector(player.Position.X, player.Position.Y - ((ItemVariables.HURDLE_HEELS.Crosshair.FrameCount - 60) * -32))), pExodus.NullVector, pExodus.NullVector)
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_RENDER, pExodus.hurdleHeelsRender)

function pExodus.hurdleHeelsDamage(target, amount, flags, source, cdtimer)
    if ItemVariables.HURDLE_HEELS.JumpState > 0 then
        pExodus.PreventDMG = true
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.hurdleHeelsDamage, EntityType.ENTITY_PLAYER)

function pExodus:hurdleHeelsCollision(player, entity)
    if ItemVariables.HURDLE_HEELS.JumpState > 0 then
        pExodus.PreventPlayerCollision = true
    end
end

pExodus:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, pExodus.hurdleHeelsCollision)

function pExodus.hurdleHeelsEnemyCollision(npc, entity)
    if ItemVariables.HURDLE_HEELS.JumpState > 0 and npc:IsEnemy() and entity.Type == EntityType.ENTITY_PLAYER then
        pExodus.PreventNPCCollision = true
    end
end

pExodus:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, pExodus.hurdleHeelsEnemyCollision)

function pExodus.hurdleHeelsCache(player, flag)
    if player:HasCollectible(ItemId.HURDLE_HEELS) and flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.1
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.hurdleHeelsCache)

function pExodus.hurdleHeelsNewRoom()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.HURDLE_HEELS) then
        ItemVariables.HURDLE_HEELS.JumpState = 0
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.hurdleHeelsNewRoom)