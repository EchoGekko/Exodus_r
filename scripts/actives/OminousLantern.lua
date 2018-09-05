local ItemId = pExodus.ItemId
local ItemVariables = pExodus.ItemVariables
local Entities = pExodus.Entities
local sfx = pExodus.SFX
local game = pExodus.Game

pExodus.ItemId.OMINOUS_LANTERN = Isaac.GetItemIdByName("Ominous Lantern")

function pExodus.ominousLanternNewRoom()
    ItemVariables.OMINOUS_LANTERN.Fired = true
    ItemVariables.OMINOUS_LANTERN.Lifted = true
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.ominousLanternNewRoom)

function pExodus.ominousLanternUpdate()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.OMINOUS_LANTERN) then
        if ItemVariables.OMINOUS_LANTERN.Fired == false then
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                player:FullCharge()
            end
            
            if ItemVariables.OMINOUS_LANTERN.Lifted == false then
                player:AnimateCollectible(ItemId.OMINOUS_LANTERN, "LiftItem", "PlayerPickupSparkle")
                ItemVariables.OMINOUS_LANTERN.Lifted = true
            end
        end
        
        if ItemVariables.OMINOUS_LANTERN.Hid then
            ItemVariables.OMINOUS_LANTERN.Hid = false
            player:FullCharge()
        end
        
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_TEAR and entity.Variant == Entities.LANTERN_TEAR.variant then
                if entity:IsDead() then
                    sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1, 0, false, 1.5)
                    pExodus:SpawnGib(entity.Position, entity, true)
                    
                    for z = 1, 3 do
                        pExodus:SpawnGib(entity.Position, entity, false)
                    end
                    
                    local purpleFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, Entities.LANTERN_FIRE.variant, 0, entity.Position, pExodus.NullVector, player)
                    purpleFire:GetData().ExistingFrames = 0
                end
            elseif entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == Entities.LANTERN_FIRE.variant then
                local data = entity:GetData()
                local sprite = entity:GetSprite()
                
                data.ExistingFrames = data.ExistingFrames + 1
                
                if data.ExistingFrames >= 300 then
                    sprite:Play("Dying", false)
                    
                    if sprite:IsFinished("Dying") then
                        entity:Remove()
                    end
                end
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.ominousLanternUpdate)

function pExodus.ominousLanternDamage(target, amount, flags, source, cdtimer)
    if source.Type == EntityType.ENTITY_TEAR and source.Variant == Entities.LANTERN_TEAR.variant then
        ItemVariables.OMINOUS_LANTERN.LastEnemyHit = target
    end
    
    if target.Type == EntityType.ENTITY_PLAYER then
        ItemVariables.OMINOUS_LANTERN.Fired = true
        ItemVariables.OMINOUS_LANTERN.Lifted = true  
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.ominousLanternDamage)

function pExodus.ominousLanternRender()
    local player = Isaac.GetPlayer(0)
    
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        local data = ent:GetData()
        
        if ent.Type == EntityType.ENTITY_EFFECT and ent.Variant == Entities.LANTERN_GIBS.variant then
            if data.Offset ~= nil then
                if ent.Velocity.Y < data.Offset and data.Resting ~= true then
                    ent.Velocity = ent.Velocity + Vector(0, 1)
                end
            end
            
            if ent.Velocity.X < 0 then
                ent.Velocity = ent.Velocity + Vector(1, 0)
            end
            
            if ent.Velocity.X > 0 then
                ent.Velocity = ent.Velocity + Vector(-1, 0)
            end
            
            if ent.Velocity.Y >= data.Offset then
                ent.Velocity = Vector(ent.Velocity.X, 0)    
                data.Resting = true
            end    
        elseif ent.Type == EntityType.ENTITY_EFFECT and ent.Variant == Entities.LANTERN_FIRE.variant then
            local npc = ent
            
            if npc.FrameCount <= 1 then
                data.ExistingFrames = 0
                npc:GetSprite():Play("Idle", false)
                data.SFXcd = 0
                
                if ItemVariables.OMINOUS_LANTERN.LastEnemyHit ~= nil then
                    data.IsLatchedToEnemy = ItemVariables.OMINOUS_LANTERN.LastEnemyHit
                end
            end
            
            if data.SFXcd ~= nil then
                if data.SFXcd >= 1 then
                    data.SFXcd = data.SFXcd - 1
                end
            end
            
            if data.IsLatchedToEnemy ~= nil then
                npc.Position = data.IsLatchedToEnemy.Position
                
                if data.IsLatchedToEnemy:IsDead() then
                    data.IsLatchedToEnemy = nil
                end
            else
                npc.Velocity = pExodus.NullVector
            end
            
            if game:GetFrameCount() % math.random(30, 80) == 0 then
                pExodus:SpawnCandleTear(npc)
            end
            
            for u, entity in pairs(Isaac.GetRoomEntities()) do
                local edata = entity:GetData()
                
                if entity:IsVulnerableEnemy() then
                    if entity.Position:DistanceSquared(npc.Position) < (entity.Size + npc.Size)^2 then
                        entity:AddFear(EntityRef(player), 30)
                        entity:TakeDamage(2, DamageFlag.DAMAGE_FIRE, EntityRef(npc), 90)
                        if data.IsLatchedToEnemy == nil and data.SFXcd == 0 then
                            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.7, 0, false, 1)
                            data.SFXcd = 30
                        end
                    end
                elseif entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= Entities.LANTERN_TEAR.variant then
                    if entity.Position:DistanceSquared(npc.Position) < (entity.Size + npc.Size)^2 and edata.AddedFireBonus ~= true and edata.IsCandleTear ~= true then
                        local tear = entity:ToTear()
                        edata.AddedFireBonus = true
                        tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
                        tear.Scale = tear.Scale * 1.5
                        entity.CollisionDamage = entity.CollisionDamage * 1.5
                        pExodus:PlayTearSprite(entity, "Psychic Tear.anm2")
                        entity.Velocity = entity.Velocity * 0.8
                    elseif entity.Position:DistanceSquared(npc.Position) < (entity.Size + npc.Size)^2 and edata.AddedFireBonus ~= true and edata.IsCandleTear then
                        local tear = entity:ToTear()
                        edata.AddedFireBonus = true
                        tear.TearFlags = tear.TearFlags + TearFlags.TEAR_HOMING
                        entity.Color = Color(1, 1, 1, 1, 80, 0, 80)
                    end
                elseif entity.Type == EntityType.ENTITY_PROJECTILE then
                    if entity.Position:DistanceSquared(npc.Position) < (entity.Size + npc.Size)^2 then    
                        entity:Die()
                        data.ExistingFrames = data.ExistingFrames + 50
                    end
                elseif entity.Type == EntityType.ENTITY_BOMBDROP then
                    local Bomb = entity:ToBomb()
                    local BombData = entity:GetData()
                    
                    if Bomb.IsFetus and BombData.MadeHoming ~= true then
                        if entity.Position:DistanceSquared(npc.Position) < (entity.Size + npc.Size)^2 then
                            Bomb.Flags = Bomb.Flags + TearFlags.TEAR_HOMING
                            entity.Color = Color(1, 1, 1, 1, 80, 0, 80)
                            BombData.MadeHoming = true
                        end
                    end
                elseif entity.Type == EntityType.ENTITY_KNIFE and entity:ToKnife():IsFlying() then
                    if entity.Position:DistanceSquared(npc.Position) < (entity.Size + npc.Size)^2 then
                        pExodus:SpawnCandleTear(entity)
                    end
                end
            end
        end
    end
    
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and ItemVariables.OMINOUS_LANTERN.Lifted then
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
            pExodus:FireLantern(player.Position, Vector(-15 ,0), true)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
            pExodus:FireLantern(player.Position, Vector(15, 0), true)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
            pExodus:FireLantern(player.Position, Vector(0, -15), true)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
            pExodus:FireLantern(player.Position, Vector(0, 15), true)
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_RENDER, pExodus.ominousLanternRender)

function pExodus.ominousLanternUse(active)
    local player = Isaac.GetPlayer(0)
    
	if active == ItemId.OMINOUS_LANTERN then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
			if ItemVariables.OMINOUS_LANTERN.Fired == false then
				ItemVariables.OMINOUS_LANTERN.Fired = true
				ItemVariables.OMINOUS_LANTERN.Lifted = true
				ItemVariables.OMINOUS_LANTERN.Hid = true
				player:AnimateCollectible(ItemId.OMINOUS_LANTERN, "HideItem", "PlayerPickupSparkle")
			else
				ItemVariables.OMINOUS_LANTERN.Fired = false
				ItemVariables.OMINOUS_LANTERN.Lifted = false
			end
		else
			pExodus:FireLantern(player.Position, Vector.FromAngle(rng:RandomInt(360)):Resized(rng:RandomInt(10) + 3), false)
			pExodus:FireLantern(player.Position, Vector.FromAngle(rng:RandomInt(360)):Resized(rng:RandomInt(10) + 3), false)
			pExodus.LiftActive = true
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.ominousLanternUse)