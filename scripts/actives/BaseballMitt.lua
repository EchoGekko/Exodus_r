local ItemId = pExodus.ItemId
local ItemVariables = pExodus.ItemVariables
local Entities = pExodus.Entities
local rng = RNG()

pExodus.ItemId.ANAMNESIS = Isaac.GetItemIdByName("Baseball Mitt")

function pExodus.baseballMittUpdate()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_TEAR and entity.Variant == Entities.BASEBALL.variant and entity:IsDead() then
            local hit = Isaac.Spawn(Entities.BASEBALL_HIT.id, Entities.BASEBALL_HIT.variant, 0, entity.Position, pExodus.NullVector, nil)
            hit:ToEffect():SetTimeout(20)
            hit.SpriteRotation = rng:RandomInt(360)
        end
    end
    
    if ItemVariables.BASEBALL_MITT.Used and player:HasCollectible(ItemId.BASEBALL_MITT) then
        player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        
        if not ItemVariables.BASEBALL_MITT.Lifted then
            player:AnimateCollectible(ItemId.BASEBALL_MITT, "LiftItem", "PlayerPickupSparkle")
            ItemVariables.BASEBALL_MITT.Lifted = true
        end
        
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_PROJECTILE then
                local playerPos = player.Position
                local bulletPos = entity.Position
                local distance = (playerPos):Distance(bulletPos)
                
                if distance > player.Size + entity.Size and distance <= 120 then
                    local nudgeVector = (playerPos - bulletPos) / (distance)
                    entity.Velocity = (entity.Velocity + nudgeVector):Resized(entity.Velocity:Length())
                elseif distance <= player.Size + entity.Size then
                    entity:Remove()
                    ItemVariables.BASEBALL_MITT.BallsCaught = ItemVariables.BASEBALL_MITT.BallsCaught + 1
                end
            end
        end
        
        if pExodus.Game:GetFrameCount() >= ItemVariables.BASEBALL_MITT.UseDelay + 120 or Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
            player:AnimateCollectible(ItemId.BASEBALL_MITT, "HideItem", "PlayerPickupSparkle")
            ItemVariables.BASEBALL_MITT.Used = false
            
            if ItemVariables.BASEBALL_MITT.BallsCaught > 0 then
                repeat
                    local tear = player:FireTear(player.Position, Vector(10, 0):Rotated(rng:RandomInt(360)), false, true, false)
                    tear:ChangeVariant(Entities.BASEBALL.variant)
                    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_BOUNCE 
                    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_CONFUSION
                    tear.CollisionDamage = player.Damage * 3
                            
                    ItemVariables.BASEBALL_MITT.BallsCaught = ItemVariables.BASEBALL_MITT.BallsCaught  - 1
                until ItemVariables.BASEBALL_MITT.BallsCaught == 0
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.baseballMittUpdate)

function pExodus.baseballMittDamage(target, amount, flags, source, cdtimer)
    if ItemVariables.BASEBALL_MITT.Used then
        pExodus.PreventDMG = true
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.baseballMittDamage, EntityType.ENTITY_PLAYER)

function pExodus.baseballMittUse()
    ItemVariables.BASEBALL_MITT.Used = true
    ItemVariables.BASEBALL_MITT.Lifted = false
    ItemVariables.BASEBALL_MITT.BallsCaught = 0
    ItemVariables.BASEBALL_MITT.UseDelay = pExodus.Game:GetFrameCount()
    pExodus.LiftActive = true
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.baseballMittUse, ItemId.BASEBALL_MITT)