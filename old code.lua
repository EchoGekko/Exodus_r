--<<<RITUAL CANDLE>>>--
function Exodus:ritualCandleUpdate()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.RITUAL_CANDLE) then
        ItemVariables.RITUAL_CANDLE.LitCandles = 0
        
        for i, entity in pairs(Isaac.GetRoomEntities()) do 
            local data = entity:GetData()
            local sprite = entity:GetSprite()
            
            if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.PENTAGRAM_BLACKPOWDER and data.IsFromRitual then
                entity:Remove()
            end
            
            local range = 107
            
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                range = 150
            end
            
            if ItemVariables.RITUAL_CANDLE.HasBonus and entity.Position:Distance(player.Position) <= range and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and game:GetFrameCount() % math.ceil(player.MaxFireDelay / 3) == 0 then
                entity:TakeDamage((player.Damage / 4) * (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS) + 1), 0, EntityRef(player), 0)
            end
            
            if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == Entities.CANDLE.variant then
                if data.IsLit then
                    ItemVariables.RITUAL_CANDLE.LitCandles = ItemVariables.RITUAL_CANDLE.LitCandles + 1
                    
                    if ItemVariables.RITUAL_CANDLE.HasBonus and data.LitTimer > 120 then
                        sprite:Play("Lit All", false)
                    else
                        sprite:Play("Lit", false)
                    end
                elseif not data.IsLit then
                    sprite:Play("Idle", false)
                end
            end
        end
        
        if ItemVariables.RITUAL_CANDLE.LitCandles == 5 then
            ItemVariables.RITUAL_CANDLE.Pentagram = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PENTAGRAM_BLACKPOWDER, 0, player.Position, NullVector, player)
            
            local sprite = ItemVariables.RITUAL_CANDLE.Pentagram:GetSprite()
            sprite:Load("gfx/effects/pentagram.anm2", true)
            sprite:Play("Idle", true)
            sprite:SetFrame("Idle", game:GetFrameCount() % 5)
            ItemVariables.RITUAL_CANDLE.Pentagram:ToEffect():FollowParent(player)
            ItemVariables.RITUAL_CANDLE.Pentagram.SpriteRotation = player.FrameCount*-2
            ItemVariables.RITUAL_CANDLE.Pentagram:GetData().IsFromRitual = true
            ItemVariables.RITUAL_CANDLE.HasBonus = true
            
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                ItemVariables.RITUAL_CANDLE.Pentagram.SpriteScale = Vector(1.45, 1.45)
            end
            
            if ItemVariables.RITUAL_CANDLE.SoundPlayed == false then
                sfx:Play(SoundEffect.SOUND_SATAN_GROW, 1, 0, false, 1)
                ItemVariables.RITUAL_CANDLE.SoundPlayed = true
            end
        else
            ItemVariables.RITUAL_CANDLE.HasBonus = false
            
            if ItemVariables.RITUAL_CANDLE.SoundPlayed then
                sfx:Play(SoundEffect.SOUND_SATAN_HURT, 1, 0, false, 1)
                ItemVariables.RITUAL_CANDLE.SoundPlayed = false
            end
        end    
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.ritualCandleUpdate)

function Exodus:randomiseCandleSprites()
    local player = Isaac.GetPlayer(0)
    local count = 1

    if player:HasCollectible(ItemId.RITUAL_CANDLE) then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == Entities.CANDLE.variant then
                local data = entity:GetData()
                
                if not data.RandomSpritesheet then
                    local sprite = entity:GetSprite()
                    
                    data.RandomSpritesheet = true
                    sprite:ReplaceSpritesheet(0, "gfx/familiar/candle" .. math.min(count, 5) .. ".png")
                    sprite:LoadGraphics()
                    count = count + 1
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.randomiseCandleSprites)

function Exodus:ritualCandleCache(player, flag)
    if player:HasCollectible(ItemId.RITUAL_CANDLE) and flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(Entities.CANDLE.variant, 5, rng)
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.ritualCandleCache)

function Exodus:ritualCandleInit(candle)
    candle.Parent = player
    candle.OrbitDistance = Vector(120, 120)
    candle.OrbitSpeed = 0.015
    candle.OrbitLayer = 6012
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.ritualCandleInit, Entities.CANDLE.variant)

function Exodus:ritualCandleFamiliarUpdate(candle)
    local data = candle:GetData()
    local sprite = candle:GetSprite()
    local player = Isaac.GetPlayer(0)

    if not player:HasCollectible(ItemId.RITUAL_CANDLE) then
        candle:Remove()
    end
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
        candle.OrbitDistance = Vector(150, 150)
    else
        candle.OrbitDistance = Vector(107, 107)
    end
    
    candle.OrbitSpeed = 0.015
    candle.OrbitLayer = 6012
    candle.Velocity = candle:GetOrbitPosition(player.Position + player.Velocity) - candle.Position
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do 
        if (entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_KNIFE or (entity.Type == EntityType.ENTITY_FIREPLACE and (entity.Variant == 0 or entity.Variant == 1))) then
            if entity.Position:DistanceSquared(candle.Position) < (entity.Size + candle.Size)^2 then
                if data.IsLit ~= true then
                    data.IsLit = true
                    sfx:Play(SoundEffect.SOUND_FIRE_RUSH, 1, 0, false, 1)
                end

                data.LitTimer = 600
            end
        end
    end
        
    if data.LitTimer ~= nil then
        if data.LitTimer <= 0 and data.IsLit then
            data.IsLit = false
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 1, 0, false, 1)
        end
            
        if data.IsLit and not game:GetRoom():IsClear() then
            data.LitTimer = data.LitTimer - 1
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Exodus.ritualCandleFamiliarUpdate, Entities.CANDLE.variant)

function Exodus:ritualCandleRender()
    if ItemVariables.RITUAL_CANDLE.HasBonus == false and ItemVariables.RITUAL_CANDLE.Pentagram ~= nil then
        ItemVariables.RITUAL_CANDLE.Pentagram:Remove()
        ItemVariables.RITUAL_CANDLE.Pentagram = nil
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.ritualCandleRender)

--<<<SCARED HEART>>>--
function Exodus:newScaredHeartLogic()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_HEART and entity.SubType == HeartSubType.HEART_SCARED then
            entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, Entities.SCARED_HEART.subtype, true)
        elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_HEART and entity.SubType == Entities.SCARED_HEART.subtype then
            local sprite = entity:GetSprite()
            local data = entity:GetData()
            
            if entity.FrameCount <= 1 then
                if not data.HasPlayedAppear then
                    sprite:Play("Appear", false)
                end
                
                data.FleeingFrames = 0
            end
            
            if entity.FrameCount >= 34 or data.HasPlayedAppear == true then
                if sprite:IsFinished("Appear") then
                    data.HasPlayedAppear = true
                end
                
                if player.Position:DistanceSquared(entity.Position) < 2500 and player.Position:DistanceSquared(entity.Position) > 625 then
                    data.FleeingFrames = 60
                    entity.Velocity = (player.Position - entity.Position):Resized(-250 / player.Position:Distance(entity.Position))
                end
                
                if data.FleeingFrames > 0 then
                    data.FleeingFrames = data.FleeingFrames - 1
                    sprite:Play("Flee", false)
                else
                    sprite:Play("Idle", false)
                end
                
                if player.Position:DistanceSquared(entity.Position) < (player.Size + entity.Size)^2 and player:GetMaxHearts() > player:GetHearts() and data.Collected ~= true then
                    player:AddHearts(2)
                    data.Collected = true
                    data.CollectedFrames = 0
                    local heart = entity:ToPickup()
                    heart:PlayPickupSound()
                end
                
                if data.CollectedFrames ~= nil then
                    if data.CollectedFrames <= 14 then
                        sprite:SetFrame("Collect", data.CollectedFrames)
                        data.CollectedFrames = data.CollectedFrames + 1
                        
                        if data.CollectedFrames > 4 then
                            entity.Visible = false
                        end
                    else
                        entity:Remove()
                    end
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.newScaredHeartLogic)

--<<<OCCULTIST>>>--
function pExodus:IsAOEFree()
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:GetData().IsOccultistAOE then
            return false
        end
    end
end

function Exodus:occultistEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    local room = Game():GetRoom()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if sprite:IsEventTriggered("Decelerate") then
        entity.Velocity = entity.Velocity * 0.8
    elseif sprite:IsEventTriggered("Flap") then
        sfx:Play(SoundEffect.SOUND_BIRD_FLAP, 1, 0, false, 0.7)
    elseif sprite:IsEventTriggered("Stop") then
        entity.Velocity = Vector(0, 0)
    elseif sprite:IsEventTriggered("Invisible") then
        sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 0.3)
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    elseif sprite:IsEventTriggered("Visible") then
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    elseif sprite:IsEventTriggered("Teleport") then
        sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 0.6)
        entity.Position = room:FindFreeTilePosition(room:GetRandomPosition(40), 5)
    elseif sprite:IsEventTriggered("Shoot") then
        for i = -1, 1 do
            Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, entity.Position, Vector.FromAngle(angle + i * 20):Resized(10), entity)
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
        end
    elseif sprite:IsEventTriggered("AOESpawn") then
        sfx:Play(SoundEffect.SOUND_HUSH_CHARGE, 1, 0, false, 1)
        
        for i = 1, math.random(15, 30) do
            local Marker = Isaac.Spawn(EntityType.ENTITY_EFFECT, Entities.OCCULTIST_TEAR_MARKER.variant, 0, room:FindFreeTilePosition(room:GetRandomPosition(40), 5), Vector(0,0), entity)
            Marker:GetSprite():Play("Idle", false)
        end
    elseif sprite:IsEventTriggered("AOEActivate") then
        sfx:Play(SoundEffect.SOUND_SATAN_BLAST, 1, 0, false, 1)
        
        for i, ent in pairs(Isaac.GetRoomEntities()) do
            if ent.Type == EntityType.ENTITY_EFFECT and ent.Variant == Entities.OCCULTIST_TEAR_MARKER.variant then
                local OccultistProjectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, ent.Position, Vector(0,0), entity):GetData()
                OccultistProjectile.IsOccultistAOE = true
                OccultistProjectile.AOEFrames = 0
                OccultistProjectile.OccultistParent = entity
                ent:Remove()
            end
        end
    end
    
    if entity.State == 0 then -- Spawn & Animate Appear
        if sprite:IsFinished("Appear") then
            entity.State = 2
        end
    elseif entity.State == 2 then -- Wander
        entity:AnimWalkFrame("Walk", "Walk", 0)
        
        if math.random(20) == 1 or entity.FrameCount == 40 then
            entity.Pathfinder:MoveRandomly()
        end
        
        entity.Velocity = entity.Velocity:Resized(2)
        
        if math.random(80) == 1 then
            entity.State = 3
        end
    elseif entity.State == 3 then -- Teleport
        sprite:Play("Teleport", false)
        
        if sprite:IsFinished("Teleport") then
            if Exodus:IsAOEFree() == false then
                entity.State = 2
            else
                entity.State = math.random(2, 5)
            end
        end
    elseif entity.State == 4 then -- Shoot
        sprite:Play("Projectiles")
        
        if sprite:IsFinished("Projectiles") then
            entity.State = 3
        end
    elseif entity.State == 5 then -- AOE Attack
        sprite:Play("AOE")
        
        if sprite:IsFinished("AOE") then
            entity.State = 3
        end
    end

    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        
        if data.IsOccultistAOE == true then
            if data.OccultistParent and not data.OccultistParent:IsDead() then
                if data.AOEFrames < 120 then
                    if entity.FrameCount >= 2 then
                        local NewAOETear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, entity.Position, Vector(0, 0), entity):GetData()
                        
                        NewAOETear.IsOccultistAOE = true
                        NewAOETear.AOEFrames = data.AOEFrames + 1
                        NewAOETear.OccultistParent = data.OccultistParent
                        entity:Remove()
                    end
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.occultistEntityUpdate, Entities.OCCULTIST.id)

--<<<IRON LUNG>>>--
function Exodus:ironLungGasLogic()
    local entities = Isaac.GetRoomEntities()
    
    for i, entity in pairs(entities) do
        if entity.Type == Entities.IRON_LUNG_GAS.id and entity.Variant == Entities.IRON_LUNG_GAS.variant then
            local sprite = entity:GetSprite()
            
            if sprite:IsFinished("Appear") then
                sprite:Play("Pyroclastic Flow", false)
            end
            
            if sprite:IsFinished("Pyroclastic Flow") then
                sprite:Play("Fade", false)
            end
            
            for v, tear in pairs(entities) do
                if tear:ToTear() then
                    if tear.Position:Distance(entity.Position) < entity.Size + tear.Size then
                        tear.Velocity = tear.Velocity * 0.8
                    end
                end
            end
            
            if sprite:IsFinished("Fade") then
                entity:Remove()
                entity.Visible = false
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.ironLungGasLogic)

function Exodus:ironLungEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    local room = Game():GetRoom()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if entity.FrameCount <=1 then
        sprite:Play("Appear", false)
        data.DirectionMultiplier = math.random(5)
    end
    
    if entity.State ~= 2 then
        data.State2Frames = 0
        data.IsCharging = false
    end
    
    if data.IsCharging == true then
        if entity:IsFrame(2, 0) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, Entities.IRON_LUNG_GAS.variant, 0, entity.Position, Vector(0, 0), entity)
        end
        
        entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    elseif entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
        entity:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end
    
    if entity.State == 0 then -- Move around
        if math.random(50) == 1 or entity:CollidesWithGrid() then
            data.DirectionMultiplier = math.random(5)
        end
        
        entity.Velocity = Vector.FromAngle(data.DirectionMultiplier * 90):Resized(7)
        
        if entity.Velocity.Y > 0 then
            entity:AnimWalkFrame("Hori", "Down", 0)
        elseif entity.Velocity.Y < 0 then
            entity:AnimWalkFrame("Hori", "Up", 0)
        end
        
        if angle % 90 < 10 and angle % 90 > -10 then
            entity.State = 2
        end
    elseif entity.State == 2 then -- Charge
        data.State2Frames = data.State2Frames + 1
        
        if data.State2Frames == 1 then
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL , 1, 0, false, 1)
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS  , 1, 0, false, 1)
            sfx:Play(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR , 1, 0, false, 2)
            data.IsCharging = false
            
            if angle > -45 and angle < 45 then -- Player is on the right
                sprite:Play("HoriPrep", false)
                sprite.FlipX = false
                data.Direction = Direction.RIGHT
            elseif angle > 45 and angle < 135 then -- Player is under
                sprite:Play("DownPrep", false)
                data.Direction = Direction.DOWN
            elseif angle < -45 and angle > -135 then -- Player is above
                sprite:Play("UpPrep", false)
                data.Direction = Direction.UP
            else -- Player is on the left
                sprite:Play("HoriPrep", false)
                sprite.FlipX = true
                data.Direction = Direction.LEFT
            end
        end
        
        if sprite:IsFinished("HoriPrep") and data.Direction == Direction.LEFT then
                data.IsCharging = true
                sprite:Play("HoriCharge", false)
                sprite.FlipX = true
            elseif sprite:IsFinished("HoriPrep") and data.Direction == Direction.RIGHT then
                data.IsCharging = true
                sprite:Play("HoriCharge", false)
                sprite.FlipX = false
            elseif sprite:IsFinished("DownPrep") then
                data.IsCharging = true
                sprite:Play("DownCharge", false)
            elseif sprite:IsFinished("UpPrep") then
                data.IsCharging = true
                sprite:Play("UpCharge", false)
            end
            
            if data.IsCharging == true and entity:CollidesWithGrid() then
                sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS , 2, 0, false, 0.8)
                sfx:Play(SoundEffect.SOUND_POT_BREAK , 2, 0, false, 0.8)
                data.IsCharging = false
                
                if data.Direction == Direction.LEFT then
                    sprite:Play("HoriSlam", false)
                    sprite.FlipX = true
                elseif data.Direction == Direction.RIGHT then
                    sprite:Play("HoriSlam", false)
                    sprite.FlipX = false
                elseif data.Direction == Direction.UP then
                    sprite:Play("UpSlam", false)
                elseif data.Direction == Direction.DOWN then
                    sprite:Play("DownSlam", false)
                end
            end
            
            if sprite:IsEventTriggered("Decelerate") then
                entity.Velocity = entity.Velocity * 0.8
            elseif sprite:IsEventTriggered("Stop") then
                entity.Velocity = Vector(0, 0)
            elseif sprite:IsEventTriggered("Charge") then
                if data.Direction == Direction.RIGHT then
                    entity.Velocity = Vector(25, 0)
                elseif data.Direction == Direction.LEFT then
                    entity.Velocity = Vector(-25, 0)
                elseif data.Direction == Direction.UP then
                    entity.Velocity = Vector(0, -25)
                elseif data.Direction == Direction.DOWN then
                    entity.Velocity = Vector(0, 25)
                end
            elseif sprite:IsEventTriggered("BackUp") then
                if data.Direction == Direction.LEFT then
                    entity.Velocity = Vector(10, 0)
                elseif data.Direction == Direction.RIGHT then
                    entity.Velocity = Vector(-10, 0)
                elseif data.Direction == Direction.DOWN then
                    entity.Velocity = Vector(0, -10)
                elseif data.Direction == Direction.UP then
                    entity.Velocity = Vector(0, 10)
                end
            elseif sprite:IsEventTriggered("Reverse") then
                if data.Direction == Direction.LEFT then
                    entity.Velocity = Vector(5, 0)
                elseif data.Direction == Direction.RIGHT then
                    entity.Velocity = Vector(-5, 0)
                elseif data.Direction == Direction.DOWN then
                    entity.Velocity = Vector(0, -5)
                elseif data.Direction == Direction.UP then
                    entity.Velocity = Vector(0, 5)
                end
            end
        if sprite:IsFinished("HoriSlam") or sprite:IsFinished("UpSlam") or sprite:IsFinished("DownSlam") then
            entity.State = 0
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.ironLungEntityUpdate, Entities.IRON_LUNG.id)

---<<FLYERBALL>>---
function Exodus:flyerballFires()
    local player = Isaac.GetPlayer(0)
    
    for i, fire in ipairs(EntityVariables.FLYERBALL.Fires) do
        if fire then
            local data = fire:GetData()
            
            if player.Position:DistanceSquared(fire.Position) < (fire.Size + player.Size)^2 then
                player:TakeDamage(1, DamageFlag.DAMAGE_FIRE, EntityRef(fire), 30)
            end
            
            if data.CountDown ~= nil then
                data.CountDown = data.CountDown - 1
                if data.CountDown <= 0 then
                    fire:Remove()
                    table.remove(EntityVariables.FLYERBALL.Fires, i)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.flyerballFires)

function Exodus:flyerballNewRoom()
    EntityVariables.FLYERBALL.Fires = {}
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.flyerballNewRoom)

function Exodus:flyerballTakeDamage(target, amount, flag, source, cdframes)
    local dmgSource = getEntityFromRef(source)
    
    if target.Variant == Entities.FLYERBALL.variant then
        local data = target:GetData()
        
        if flag == DamageFlag.DAMAGE_FIRE then
            return false
        end
        
        if dmgSource and dmgSource:ToTear() then
            target.Velocity = target.Velocity + dmgSource.Velocity
        end
        
        data.SpeedMultiplier = data.SpeedMultiplier - 0.75
        
        if target.HitPoints - amount <= 0.0 then
            local Fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, 51, 0, target.Position, Vector(0, 0), target)
            table.insert(EntityVariables.FLYERBALL.Fires, Fire)
            Fire:GetData().CountDown = 300
            Isaac.Explode(target.Position, target, 40)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.flyerballTakeDamage, Entities.FLYERBALL.id)

function Exodus:flyerballEntityUpdate(entity)
    if entity.Variant == Entities.FLYERBALL.variant then
        local player = Isaac.GetPlayer(0)
        local data = entity:GetData()
        local sprite = entity:GetSprite()
        local target = entity:GetPlayerTarget()
        
        local angle = (target.Position - entity.Position):GetAngleDegrees()
        
        if entity.FrameCount == 1 then
            sprite:Play("Appear", false)
            entity.State = 0
            data.SpeedMultiplier = 1.0
            data.PhaseChanged = false
            data.UpperBound = 2.5
            data.LowerBound = 1.0
            data.Appeared = false
        end
        
        data.SpeedMultiplier = math.min(math.max(data.LowerBound, data.SpeedMultiplier + 0.05), data.UpperBound)
        
        if sprite:IsFinished("Appear") and not data.Appeared then
            data.Appeared = true
            sprite:Play("Fly", true)
        end
        
        if data.Appeared then
            if not data.PhaseChanged then
                if entity.HitPoints < entity.MaxHitPoints / 2 then
                    data.PhaseChanged = true
                    data.UpperBound = 4.0
                    sfx:Play(SoundEffect.SOUND_FIRE_RUSH, 1, 0, false, 1)
                end
                
                entity.Velocity = entity.Velocity:Resized(data.SpeedMultiplier * 3.5)
            else
                sprite:SetFrame("Fury", entity.FrameCount % 6)
                
                entity.Velocity = entity.Velocity:Resized(data.SpeedMultiplier * 5.0)
            end
        end
        
        local entities = Isaac.GetRoomEntities()
        
        for i, ent in pairs(Isaac.GetRoomEntities()) do
            if ent.Type == EntityType.ENTITY_PROJECTILE and ent.SpawnerType == Entities.FLYERBALL.id and ent.SpawnerVariant == Entities.FLYERBALL.variant then
                ent:Remove()
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.flyerballEntityUpdate, Entities.FLYERBALL.id)

--<<KEEPER>>--
function Exodus:keeperRender(t)
    local player = Isaac.GetPlayer(0)
    local level = game:GetLevel()
    local room = game:GetRoom()
    if player:GetName() == "Keeper" and (level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN) and (room:GetType() ~= RoomType.ROOM_BOSS or room:GetFrameCount() >= 1) then
        local hearts = player:GetMaxHearts()/2
        local sprite = Sprite()
        sprite:Load("gfx/ui/ui_hearts.anm2", true)
        if EntityVariables.KEEPER.ThirdHeart == 1 then
            sprite:Play("CoinEmpty")
            sprite:Update()
            sprite:Render(Vector((hearts*12)+12*1+36,12), Vector(0,0), Vector(0,0))
        elseif EntityVariables.KEEPER.ThirdHeart == 2 then
            sprite:Play("CoinHeartFull")
            sprite:Update()
            sprite:Render(Vector((hearts*12)+12*1+36,12), Vector(0,0), Vector(0,0))
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.keeperRender)

function Exodus:keeperUpdate(t)
    local player = Isaac.GetPlayer(0)
    local coins = player:GetNumCoins()
    local hearts = player:GetHearts()
    local maxhearts = player:GetMaxHearts()
    if player:GetName() == "Keeper" then
        if maxhearts == 4 and EntityVariables.KEEPER.ThirdHeart == 0 then
            player:AddMaxHearts(-2, false)
            EntityVariables.KEEPER.ThirdHeart = 2
        end
        if maxhearts == 0 and EntityVariables.KEEPER.ThirdHeart == 2 then
            EntityVariables.KEEPER.ThirdHeart = 0
            player:AddMaxHearts(2, false)
            player:AddHearts(4)
        end
        if coins > EntityVariables.KEEPER.CurrentCoins then
            if hearts == maxhearts and EntityVariables.KEEPER.ThirdHeart == 1 then
                player:AddCoins(-1)
                EntityVariables.KEEPER.ThirdHeart = 2
            end
        end
    end
    EntityVariables.KEEPER.CurrentCoins = coins
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.keeperUpdate)

function Exodus:keeperHit(t)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Keeper" then
        if EntityVariables.KEEPER.ThirdHeart == 2 then
            EntityVariables.KEEPER.ThirdHeart = 1
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, false, false, false)
            return false
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.keeperHit, EntityType.ENTITY_PLAYER)

--<<JAMES>>--
function Exodus:jamesNewFloor()
    local player = Isaac.GetPlayer(0)
    if player:GetPlayerType() == Characters.JAMES then
        if not EntityVariables.JAMES.HasGivenItems then
            player:AddCollectible(ItemId.THE_APOCRYPHON, 0, false)
            player:AddCollectible(ItemId.FULLERS_CLUB, 6, false)
            EntityVariables.JAMES.HasGivenItems = true
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS, false, false, false, false)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Exodus.jamesNewFloor)

function Exodus:jamesUpdate()
    local player = Isaac.GetPlayer(0)
    if player:GetPlayerType() == Characters.JAMES then
        if not EntityVariables.JAMES.HasGivenItems then
            player:AddCollectible(ItemId.THE_APOCRYPHON, 0, false)
            player:AddCollectible(ItemId.FULLERS_CLUB, 6, false)
            EntityVariables.JAMES.HasGivenItems = true
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.jamesUpdate)

function Exodus:jamesCache(player, flag)
    if player:GetPlayerType() == Characters.JAMES then
        if flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.1
        end
        if flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay + 2
        end
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage - 0.5
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.jamesCache)

function Exodus:jamesNewRoom()
    local player = Isaac.GetPlayer(0)
    local room = game:GetRoom()
    local level = game:GetLevel()
    if player:GetPlayerType() == Characters.JAMES then
        if room:GetType() == RoomType.ROOM_ANGEL and not ItemVariables.THE_APOCRYPHON.HasBeenToAngel then
            ItemVariables.THE_APOCRYPHON.HasBeenToAngel = true
        end
        if room:GetType() == RoomType.ROOM_DEVIL and ItemVariables.THE_APOCRYPHON.HasBeenToAngel and level:GetCurses() & 1 << 6 == 0 then
            level:AddCurse(LevelCurse.CURSE_OF_BLIND, false)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false, false, false, false)
            ItemVariables.THE_APOCRYPHON.ChangeBack = true
        end
        if room:GetType() ~= RoomType.ROOM_DEVIL and ItemVariables.THE_APOCRYPHON.ChangeBack then
            level:RemoveCurse(LevelCurse.CURSE_OF_BLIND)
            ItemVariables.THE_APOCRYPHON.ChangeBack = false
        end
        if room:GetType() ~= RoomType.ROOM_DEFAULT and room:IsFirstVisit() then
            local consumable = math.random(1,3)
            if consumable == 1 then
                player:AddCoins(1)
            elseif consumable == 2 then
                player:AddBombs(1)
            elseif consumable == 3 then
                player:AddKeys(1)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.jamesNewRoom)

--<<FULLER'S CLUB>>--
function Exodus:fullersClubUse()
    local player = Isaac.GetPlayer(0)
    local config = Isaac.GetItemConfig()
    ItemVariables.FULLERS_CLUB.CollectibleList = {}
    
    for i = 1, #config:GetCollectibles() do
        value = config:GetCollectible(i)
        
        if value and player:HasCollectible(value.ID) then
            table.insert(ItemVariables.FULLERS_CLUB.CollectibleList, value)
        end
    end

    if #ItemVariables.FULLERS_CLUB.CollectibleList == 0 then
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 1)
        return true
    end

    player:ClearCostumes()
    player:UseActiveItem(CollectibleType.COLLECTIBLE_BIBLE, false, false, false, false)

    for i = 0, #ItemVariables.FULLERS_CLUB.CollectibleList do
        if math.random(2) == 1 then
            ItemVariables.FULLERS_CLUB.ClubDamage = ItemVariables.FULLERS_CLUB.ClubDamage + 0.25
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        end
        if math.random(10) == 1 then
            ItemVariables.FULLERS_CLUB.ClubTearDelay = ItemVariables.FULLERS_CLUB.ClubTearDelay + 1
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        end
        if math.random(3) == 1 then
            ItemVariables.FULLERS_CLUB.ClubSpeed = ItemVariables.FULLERS_CLUB.ClubSpeed + 0.05
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        end
        if math.random(3) == 1 then
            ItemVariables.FULLERS_CLUB.ClubShotSpeed = ItemVariables.FULLERS_CLUB.ClubShotSpeed + 0.05
            player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        end
        if math.random(15) == 1 then
            ItemVariables.FULLERS_CLUB.ClubLuck = ItemVariables.FULLERS_CLUB.ClubLuck + 1
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        end
        if math.random(2) == 1 then
            ItemVariables.FULLERS_CLUB.ClubRange = ItemVariables.FULLERS_CLUB.ClubRange + 0.1
            player:AddCacheFlags(CacheFlag.CACHE_RANGE)
        end
    end

    player:EvaluateItems()
    return true
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.fullersClubUse, ItemId.FULLERS_CLUB)

function Exodus:fullersClubCache(player, flag)
    if flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + ItemVariables.FULLERS_CLUB.ClubSpeed
    end
    if flag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay - ItemVariables.FULLERS_CLUB.ClubTearDelay
    end
    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + ItemVariables.FULLERS_CLUB.ClubDamage
    end
    if flag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + ItemVariables.FULLERS_CLUB.ClubLuck
    end
    if flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + ItemVariables.FULLERS_CLUB.ClubShotSpeed
    end
    if flag == CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight - ItemVariables.FULLERS_CLUB.ClubRange
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.fullersClubCache)

function Exodus:fullersClubNewRoom()
    local player = Isaac.GetPlayer(0)
    local room = game:GetRoom()
    local level = game:GetLevel()

    if #ItemVariables.FULLERS_CLUB.CollectibleList > 0 then
        for i = 1, #ItemVariables.FULLERS_CLUB.CollectibleList do
            player:AddCostume(ItemVariables.FULLERS_CLUB.CollectibleList[i])
        end
    end

    ItemVariables.FULLERS_CLUB.CollectibleList = {}

    ItemVariables.FULLERS_CLUB.ClubDamage = 0
    ItemVariables.FULLERS_CLUB.ClubTearDelay = 0
    ItemVariables.FULLERS_CLUB.ClubSpeed = 0
    ItemVariables.FULLERS_CLUB.ClubShotSpeed = 0
    ItemVariables.FULLERS_CLUB.ClubLuck = 0
    ItemVariables.FULLERS_CLUB.ClubRange = 0
    player:EvaluateItems()
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.fullersClubNewRoom)

--<<BETTER LOOPS>>--
function loop()
    local player = Isaac.GetPlayer(0)
    EntityVariables.LOOPS.Loop = EntityVariables.LOOPS.Loop + 1
    local seeds = game:GetSeeds()
    local seed = seeds:GetNextSeed()
    seeds:SetStartSeed(seed)
    Isaac.ExecuteCommand("stage 1")
    player:AnimateAppear()
end

function Exodus:loopUpdate()
    local player = Isaac.GetPlayer(0)
    local room = game:GetRoom()
    local level = game:GetLevel()
    if room:GetType() == RoomType.ROOM_SUPERSECRET then
        if EntityVariables.LOOPS.Keyhole and player.Position:DistanceSquared(EntityVariables.LOOPS.Keyhole.Position) < 16^2 and player:GetNumKeys() > 0 and EntityVariables.LOOPS.KeyFrame == nil then
            player:AddKeys(-1)
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                if entity.Type == Entities.KEYHOLE.id and entity.Variant == Entities.KEYHOLE.variant then
                    if player:HasGoldenKey() then
                        EntityVariables.LOOPS.Keyhole:GetSprite():Play("Open With GOLD", true)
                    else
                        EntityVariables.LOOPS.Keyhole:GetSprite():Play("Open", true)
                    end
                end
            end
            EntityVariables.LOOPS.KeyFrame = game:GetFrameCount() + 27
        elseif EntityVariables.LOOPS.KeyFrame ~= nil then
            if EntityVariables.LOOPS.KeyFrame ~= 0 and EntityVariables.LOOPS.KeyFrame <= game:GetFrameCount() then
                for i, entity in pairs(Isaac.GetRoomEntities()) do
                    if entity.Type == Entities.KEYHOLE.id and entity.Variant == Entities.KEYHOLE.variant then
                        entity:Remove()
                        EntityVariables.LOOPS.IgnoreNegativeIndex = true
                        EntityVariables.LOOPS.SSIndex = level:GetCurrentRoomIndex()
                        Isaac.ExecuteCommand("goto s.curse.0")
                    end
                end
            end
        end
    elseif EntityVariables.LOOPS.KeyFrame ~= nil then
        if EntityVariables.LOOPS.KeyFrame ~= 0 and EntityVariables.LOOPS.KeyFrame <= game:GetFrameCount() then
            for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(i)
                if door ~= nil then
                    door:SetRoomTypes(RoomType.ROOM_SACRIFICE, RoomType.ROOM_SACRIFICE)
                end
            end
            keeper = Isaac.Spawn(Entities.CLOCK_KEEPER.id, Entities.CLOCK_KEEPER.variant, 0, Vector(320, 196), Vector(0, 0), nil)
            keeper:GetSprite():Play("Idle", true)
            EntityVariables.LOOPS.KeyFrame = 0
        end
    end
    if room:IsClear() and room:GetType() == RoomType.ROOM_BOSS and player:HasCollectible(ItemId.CLOCK_PIECE_1) and player:HasCollectible(ItemId.CLOCK_PIECE_2) and player:HasCollectible(ItemId.CLOCK_PIECE_3) and player:HasCollectible(ItemId.CLOCK_PIECE_4) then
        if Game():IsGreedMode() then
            if level:GetStage() == 7 and room:GetRoomShape() == 4 then
                loop()
            end
        else
            if level:GetStage() == 11 then
                loop()
            elseif level:GetStage() == 10 then
                if level:IsAltStage() then
                    if not Player:HasCollectible(CollectibleType.COLLECTIBLE_NEGATIVE) then
                        loop()
                    end
                else
                    if not Player:HasCollectible(CollectibleType.COLLECTIBLE_NEGATIVE) then
                        loop()
                    end
                end
            elseif level:GetStage() == 12 then
                if room:GetBossID() == 70 then
                    loop()
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.loopUpdate)

function Exodus:loopNewRoom()
    local player = Isaac.GetPlayer(0)
    local room = game:GetRoom()
    local level = game:GetLevel()
    local bigRooms = { [RoomShape.ROOMSHAPE_2x2] = true, [RoomShape.ROOMSHAPE_LBL] = true, [RoomShape.ROOMSHAPE_LBR] = true, [RoomShape.ROOMSHAPE_LTL] = true, [RoomShape.ROOMSHAPE_LTR] = true }
    
    if EntityVariables.LOOPS.Loop > 0 then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsActiveEnemy() and not EntityRef(entity).IsFriendly then
                entity.MaxHitPoints = entity.MaxHitPoints * (2^EntityVariables.LOOPS.Loop)
                entity.HitPoints = entity.MaxHitPoints
                if 1 == math.random(10) then
                    game:RerollEnemy(entity)
                end
                if EntityVariables.LOOPS.Loop >= math.random(10) and entity:GetData().IsDuplicate == nil then
                    for i = 1, math.random(1, EntityVariables.LOOPS.Loop) do
                        dup = Isaac.Spawn(entity.Type, entity.Variant, entity.SubType, Isaac.GetFreeNearPosition(entity.Position, 16), Vector(0,0), entity)
                        dup:GetData().IsDuplicate = true
                        dup.MaxHitPoints = entity.MaxHitPoints * (2^EntityVariables.LOOPS.Loop)
                        dup.HitPoints = dup.MaxHitPoints
                    end
                end
            end
        end
    end
    
    if room:GetType() == RoomType.ROOM_SUPERSECRET and room:IsFirstVisit() then
        local mainDoor
        local checkDist = math.huge
        
        for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
            local door = room:GetDoor(i)
            if door then
                local newDist = player.Position:DistanceSquared(door.Position)
                if newDist < checkDist then
                    checkDist = newDist
                    mainDoor = door 
                end
            end
        end
        
        local factor = 2
        
        if bigRooms[room:GetRoomShape()] then
            factor = 1
        end
        
        local oppositeDoorSlot = (mainDoor.Slot + 2 + (DoorSlot.NUM_DOOR_SLOTS / 2) * (2 - factor)) % (DoorSlot.NUM_DOOR_SLOTS / factor)
        local keyhole = Isaac.Spawn(Entities.KEYHOLE.id, Entities.KEYHOLE.variant, 0, room:GetDoorSlotPosition(oppositeDoorSlot), Vector(0, 0), nil)
        local sprite = keyhole:GetSprite()
        
        keyhole:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        
        sprite:Play("Idle", true)
        sprite.Rotation = (mainDoor.Direction + 1) * 90
        
        EntityVariables.LOOPS.KeyFrame = nil
        EntityVariables.LOOPS.Keyhole = keyhole
    elseif EntityVariables.LOOPS.KeyFrame == nil then
        EntityVariables.LOOPS.KeyFrame = 0
    end
    
    if room:GetType() == RoomType.ROOM_CURSE then
        if not EntityVariables.LOOPS.IgnoreNegativeIndex and level:GetCurrentRoomDesc().GridIndex < 0 then
            if EntityVariables.LOOPS.SSIndex and EntityVariables.LOOPS.SSIndex > 0 then
                level:ChangeRoom(EntityVariables.LOOPS.SSIndex)
            else
                level:ChangeRoom(level:GetStartingRoomIndex())
            end
        end
    end
    
    EntityVariables.LOOPS.IgnoreNegativeIndex = false
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.loopNewRoom)

function Exodus:loopKeeperBoom(keeper)
    local player = Isaac.GetPlayer(0)
    if keeper.Variant == Entities.CLOCK_KEEPER.variant then
        item = ItemId.CLOCK_PIECE_1
        if player:HasCollectible(ItemId.CLOCK_PIECE_1) then
            item = ItemId.CLOCK_PIECE_2
        end
        if player:HasCollectible(ItemId.CLOCK_PIECE_2) then
            item = ItemId.CLOCK_PIECE_3
        end
        if player:HasCollectible(ItemId.CLOCK_PIECE_3) then
            item = ItemId.CLOCK_PIECE_4
        end
        if player:HasCollectible(ItemId.CLOCK_PIECE_4) then
            item = itemPool:GetCollectible(ItemPoolType.POOL_CURSE, true, game:GetSeeds():GetStartSeed())
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, keeper.Position, Vector(0,0), keeper)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Exodus.loopKeeperBoom, Entities.CLOCK_KEEPER.id)

--<<<TRINKETS>>>--
function Exodus:trinketUpdate()
    local player = Isaac.GetPlayer(0)
    local playerData = player:GetData()
    
    ---<<BOMBS SOUL>>---
    if player:HasTrinket(ItemId.BOMBS_SOUL) then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            local data = entity:GetData()
            
            if entity:IsActiveEnemy(true) and entity:ToNPC() then
                if entity:IsDead() and data.BombSoulDied ~= true then
                    data.BombSoulDied = true
                    
                    if rng:RandomInt(4) == 1 then
                        if not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                            local bomb = Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_NORMAL, 0, entity.Position, Vector(0, 0), player)
                        else
                            local bomb = Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_MR_MEGA, 0, entity.Position, Vector(0, 0), player)
                        end
                    end
                end
            end
        end
    end
    
    ---<<BROKEN GLASSES>>---
    if player:HasTrinket(ItemId.BROKEN_GLASSES) or ItemVariables.BROKEN_GLASSES.Broke then
        ItemVariables.BROKEN_GLASSES.Broke = true
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsActiveEnemy() or entity.Type == EntityType.ENTITY_PICKUP then
                entity:GetSprite().Color = Color(0, 0, 0, 1, 0, 0, 0)
            elseif entity.Type == EntityType.ENTITY_TEAR and entity:GetData().FromBrokenGlasses == nil then
                if math.random(2) == 1 then
                    local tear = player:FireTear(Vector((entity.Position.X * 2) - player.Position.X, (entity.Position.Y * 2) - player.Position.Y), entity.Velocity, true, false, true)
                    tear:GetData().FromBrokenGlasses = true
                end
                entity:GetData().FromBrokenGlasses = true
            end
        end
    end
    
    ---<<PET ROCK>>---
    if player:HasTrinket(ItemId.PET_ROCK) then
        if playerData.HasHadPetRock ~= true then
            playerData.HasHadPetRock = true
        end
        
        if not player:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        end
        
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and not (Input.IsActionPressed(ButtonAction.ACTION_LEFT, player.ControllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_RIGHT, player.ControllerIndex)
        or Input.IsActionPressed(ButtonAction.ACTION_UP, player.ControllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_DOWN, player.ControllerIndex))then
            player.Velocity = Vector(0,0)
        end
    else
        if player:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) and playerData.HasHadPetRock then
            player:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
            playerData.HasHadPetRock = false
        end
    end
    
    ---<<BURLAP SACK>>---
    if player:HasTrinket(ItemId.BURLAP_SACK) then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            local data = entity:GetData()
            
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_GRAB_BAG and entity:IsDead() and data.IsSacked == nil then 
                data.IsSacked = true
                
                if player:HasCollectible(CollectibleType.COLLECTIBLE_SACK_HEAD) and rng:RandomInt(6) == 0 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, entity.Position, RandomVector() * 5, player)
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, entity.Position, RandomVector() * 5, player)
                end
            end
        end
    end
    
    ---<<GRID WORM>>---
    if player:HasTrinket(ItemId.GRID_WORM) then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            local rand = rng:RandomInt(4) + 1
            
            if entity.Type == EntityType.ENTITY_TEAR and entity.SpawnerType == EntityType.ENTITY_PLAYER then
                if entity:CollidesWithGrid() then
                    entity.Velocity = entity.Velocity * -1
                    entity.Position = entity.Position + entity.Velocity
                elseif entity.FrameCount % 10 == 1 and entity.FrameCount > 20 then
                    local signX = 10
                    local signY = 10
                    
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) then
                        if rand == 2 then
                            signX = -signX
                        elseif rand == 3 then
                            signY = -signY
                        elseif rand == 4 then
                            signX = -signX
                            signY = -signY
                        end
                    else
                        if rand == 1 then
                            signY = 0
                        elseif rand == 2 then
                            signX = -signX
                            signY = 0
                        elseif rand == 3 then
                            signX = 0
                        elseif rand == 4 then
                            signX = 0
                            signY = -signY
                        end
                    end
                    
                    entity.Velocity = Vector(player.ShotSpeed * signX, player.ShotSpeed * signY)
                elseif entity.FrameCount <= 1 then
                    local signX = 10
                    local signY = 10
                    if player:GetHeadDirection() == Direction.DOWN then
                        signX = 0
                    elseif player:GetHeadDirection() == Direction.LEFT then
                        signX = -signX
                        signY = 0
                    elseif player:GetHeadDirection() == Direction.RIGHT then
                        signY = 0
                    elseif player:GetHeadDirection() == Direction.UP then
                        signX = 0
                        signY = -signY
                    end
                    entity.Velocity = Vector(player.ShotSpeed * signX, player.ShotSpeed * signY)
                end
            end
        end
    end
    
    ---<<ROTTEN PENNY>>---
    if player:HasTrinket(ItemId.ROTTEN_PENNY) then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_QUARTER) and not ItemVariables.ROTTEN_PENNY.HasQuarter then
            ItemVariables.ROTTEN_PENNY.HasQuarter = true
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                player:AddBlueFlies(50, player.Position, nil)
            else
                player:AddBlueFlies(25, player.Position, nil)
            end
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_DOLLAR) and not ItemVariables.ROTTEN_PENNY.HasDollar then
            ItemVariables.ROTTEN_PENNY.HasDollar = true
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                player:AddBlueFlies(198, player.Position, nil)
            else
                player:AddBlueFlies(99, player.Position, nil)
            end
        end

        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COIN and entity:IsDead() and entity:GetData().HasSpawnedFly == nil then 
                entity:GetData().HasSpawnedFly = true
                local amount = 1
                
                if entity.SubType == CoinSubType.COIN_NICKEL then
                    amount = 5
                elseif entity.SubType == CoinSubType.COIN_DIME then
                    amount = 10
                elseif entity.SubType == CoinSubType.COIN_DOUBLEPACK then
                    amount = 2
                elseif entity.SubType == CoinSubType.COIN_LUCKYPENNY then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                        Isaac.Spawn(3, 43, 2, entity.Position, Vector(0,0), player)
                        Isaac.Spawn(3, 43, 2, entity.Position, Vector(0,0), player)
                        return
                    else
                        Isaac.Spawn(3, 43, 2, entity.Position, Vector(0,0), player)
                        return
                    end
                end
                
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                    amount = amount * 2
                end
                
                player:AddBlueFlies(amount, player.Position, nil)
            end
        end
    end
    
    ---<<FLYDER>>---
    if player:HasTrinket(ItemId.FLYDER) then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.BLUE_SPIDER and entity.FrameCount < 3 and entity:GetData().DontSwitch == nil then
                entity:Remove()
                local fly = player:AddBlueFlies(1, player.Position, player)
                fly:GetData().DontSwitch = true
            elseif entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.BLUE_FLY and entity.FrameCount < 3 and entity:GetData().DontSwitch == nil then
                entity:Remove()
                local spider = player:AddBlueSpider(entity.Position)
                spider:GetData().DontSwitch = true
            elseif entity.Type == EntityType.ENTITY_SPIDER and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and entity.FrameCount < 3 and entity:GetData().DontSwitch == nil then
                entity:Remove()
                local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0, 0, entity.Position, entity.Velocity, nil)
                fly:GetData().DontSwitch = true
            elseif entity.Type == EntityType.ENTITY_ATTACKFLY and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and entity.FrameCount < 3 and entity:GetData().DontSwitch == nil then
                entity:Remove()
                local spider = Isaac.Spawn(EntityType.ENTITY_SPIDER, 0, 0, entity.Position, entity.Velocity, nil)
                spider:GetData().DontSwitch = true
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Exodus.trinketUpdate)

function Exodus:trinketCache(player, flag)
    ---<<GRID WORM>>---
    if player:HasTrinket(ItemId.GRID_WORM) and flag == CacheFlag.CACHE_RANGE then
        player.TearFallingSpeed = 10
    end

    --<<CLAUSTROPHOBIA>>--
    if player:HasTrinket(ItemId.CLAUSTROPHOBIA) and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
        if flag == CacheFlag.CACHE_SPEED then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.MoveSpeed = player.MoveSpeed + 0.5
            end
        end
        if flag == CacheFlag.CACHE_FIREDELAY then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.MaxFireDelay = player.MaxFireDelay - 4
            end
        end
        if flag == CacheFlag.CACHE_DAMAGE then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.Damage = player.Damage + 4
            end
        end
        if flag == CacheFlag.CACHE_LUCK then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.Luck = player.Luck + 2
            end
        end
        if flag == CacheFlag.CACHE_SHOTSPEED then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.ShotSpeed = player.ShotSpeed + 0.3
            end
        end
        if flag == CacheFlag.CACHE_RANGE then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.TearHeight = player.TearHeight - 3
            end
        end
    elseif player:HasTrinket(ItemId.CLAUSTROPHOBIA) then
        if flag == CacheFlag.CACHE_SPEED then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.MoveSpeed = player.MoveSpeed + 0.4
            end
        end
        if flag == CacheFlag.CACHE_FIREDELAY then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.MaxFireDelay = player.MaxFireDelay - 3
            end
        end
        if flag == CacheFlag.CACHE_DAMAGE then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.Damage = player.Damage + 3
            end
        end
        if flag == CacheFlag.CACHE_LUCK then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.Luck = player.Luck + 1
            end
        end
        if flag == CacheFlag.CACHE_SHOTSPEED then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.ShotSpeed = player.ShotSpeed + 0.2
            end
        end
        if flag == CacheFlag.CACHE_RANGE then
            if ItemVariables.CLAUSTROPHOBIA.Triggered then
                player.TearHeight = player.TearHeight - 2.5
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.trinketCache)

function Exodus:trinketNewRoom()
    local player = Isaac.GetPlayer(0)
    local room = game:GetRoom()

    if room:GetRoomShape() == RoomShape.ROOMSHAPE_IH or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIH or room:GetRoomShape() == RoomShape.ROOMSHAPE_IV or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIV then
        ItemVariables.CLAUSTROPHOBIA.Triggered = true
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:AddCacheFlags(CacheFlag.CACHE_RANGE)
        player:EvaluateItems()
    else
        ItemVariables.CLAUSTROPHOBIA.Triggered = false
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:AddCacheFlags(CacheFlag.CACHE_RANGE)
        player:EvaluateItems()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.trinketNewRoom)

function Exodus:trinketNewFloor()
    if ItemVariables.BROKEN_GLASSES.Broke then
        ItemVariables.BROKEN_GLASSES.Broke = false
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Exodus.trinketNewFloor)

--<<<SUB ROOM CHARGE ITEMS>>>--
function Exodus:subRoomChargeItemsUpdate()
    local room = game:GetRoom()
    local player = Isaac.GetPlayer(0)
    
    if game:GetFrameCount() == 1 then
        for i, item in pairs(ItemVariables.SUBROOM_CHARGE) do
            item.Charge = 0
        end
    end
    
    if player:GetActiveCharge() == 0 then
        for i, item in pairs(ItemVariables.SUBROOM_CHARGE) do
            if item ~= nil and player:GetActiveItem() == item.id then
                item.Charge = item.Charge + 1
                
                if item.Charge >= item.frames then
                    item.Charge = 0
                    player:FullCharge()
                end
            end
        end
    end
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
        ItemVariables.SUBROOM_CHARGE.OMINOUS_LANTERN.frames = 100
    else
        ItemVariables.SUBROOM_CHARGE.OMINOUS_LANTERN.frames = 300
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.subRoomChargeItemsUpdate)

--<<<OMINOUS LANTERN>>>--
function Exodus:GetRandomEnemyInTheRoom(entity) 
    local index = 1
    local possible = {}
  
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy(false) and entity:CanShutDoors() and entity.Position:DistanceSquared(entity.Position) < 250^2 then
            possible[index] = entity
            index = index + 1
        end
    end
  
    return possible[math.random(1, index)]
end

function Exodus:SpawnCandleTear(npc, isNormal)
    local target = Exodus:GetRandomEnemyInTheRoom(npc)

    if target ~= nil then
        local angle = (target.Position - npc.Position):GetAngleDegrees()
        local candleTear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, npc.Position, Vector.FromAngle(1 * angle):Resized(5), player):ToTear()
        
        candleTear.TearFlags = candleTear.TearFlags | TearFlags.TEAR_HOMING
        Exodus:PlayTearSprite(candleTear, "Psychic Tear.anm2")
        candleTear:GetData().AddedFireBonus = true
    end
end

function Exodus:SpawnGib(position, spawner, big)
    local YOffset = math.random(5, 20)
    local LanternGibs = Isaac.Spawn(EntityType.ENTITY_EFFECT, Entities.LANTERN_GIBS.variant, 0, position, Vector(math.random(-20, 20), -1 * YOffset), spawner)
    local sprite = LanternGibs:GetSprite()
    
    LanternGibs:GetData().Offset = YOffset
    LanternGibs.SpriteRotation = math.random(360)
    
    if LanternGibs.FrameCount == 0 then
        if not big then
            sprite:Play("Gib0" .. tostring(math.random(2, 4)),false)
            sprite:Stop()
        elseif big then
            sprite:Play("Gib01",false)
            sprite:Stop()
        end
    end
end

function Exodus:FireLantern(pos, vel, anim)
    local player = Isaac.GetPlayer(0)
    
    if (ItemVariables.OMINOUS_LANTERN.Fired == false or player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) and player:HasCollectible(ItemId.OMINOUS_LANTERN) then 
        ItemVariables.OMINOUS_LANTERN.LastEnemyHit = nil
        player:DischargeActiveItem()
        ItemVariables.OMINOUS_LANTERN.Fired = true
        ItemVariables.OMINOUS_LANTERN.Lifted = true
        
        local lantern = Isaac.Spawn(EntityType.ENTITY_TEAR, Entities.LANTERN_TEAR.variant, 0, pos, vel + player.Velocity, player):ToTear()
        lantern.FallingSpeed = -10
        lantern.FallingAcceleration = 1
        
        if anim then
            player:AnimateCollectible(ItemId.OMINOUS_LANTERN, "HideItem", "PlayerPickupSparkle")
        end
    end
end

function Exodus:ominousLanternNewRoom()
    ItemVariables.OMINOUS_LANTERN.Fired = true
    ItemVariables.OMINOUS_LANTERN.Lifted = true
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.ominousLanternNewRoom)

function Exodus:ominousLanternUpdate()
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
                    Exodus:SpawnGib(entity.Position, entity, true)
                    
                    for z = 1, 3 do
                        Exodus:SpawnGib(entity.Position, entity, false)
                    end
                    
                    local purpleFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, Entities.LANTERN_FIRE.variant, 0, entity.Position, NullVector, player)
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

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.ominousLanternUpdate)

function Exodus:ominousLanternDamage(target, amount, flags, source, cdtimer)
    if source.Type == EntityType.ENTITY_TEAR and source.Variant == Entities.LANTERN_TEAR.variant then
        ItemVariables.OMINOUS_LANTERN.LastEnemyHit = target
    end
    
    if target.Type == EntityType.ENTITY_PLAYER then
        ItemVariables.OMINOUS_LANTERN.Fired = true
        ItemVariables.OMINOUS_LANTERN.Lifted = true  
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.ominousLanternDamage)

function Exodus:ominousLanternRender()
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
                npc.Velocity = NullVector
            end
            
            if game:GetFrameCount() % math.random(30, 80) == 0 then
                Exodus:SpawnCandleTear(npc)
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
                        Exodus:PlayTearSprite(entity, "Psychic Tear.anm2")
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
                        Exodus:SpawnCandleTear(entity)
                    end
                end
            end
        end
    end
    
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and ItemVariables.OMINOUS_LANTERN.Lifted then
        if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
            Exodus:FireLantern(player.Position, Vector(-15 ,0), true)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
            Exodus:FireLantern(player.Position, Vector(15, 0), true)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
            Exodus:FireLantern(player.Position, Vector(0, -15), true)
        elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
            Exodus:FireLantern(player.Position, Vector(0, 15), true)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.ominousLanternRender)

function Exodus:ominousLanternUse()
    local player = Isaac.GetPlayer(0)
    
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
        Exodus:FireLantern(player.Position, Vector.FromAngle(rng:RandomInt(360)):Resized(rng:RandomInt(10) + 3), false)
        Exodus:FireLantern(player.Position, Vector.FromAngle(rng:RandomInt(360)):Resized(rng:RandomInt(10) + 3), false)
        return true
    end
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.ominousLanternUse, ItemId.OMINOUS_LANTERN)

--<<<BASEBALL MITT>>>--
function Exodus:baseballMittUpdate()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_TEAR and entity.Variant == Entities.BASEBALL.variant and entity:IsDead() then
            local hit = Isaac.Spawn(Entities.BASEBALL_HIT.id, Entities.BASEBALL_HIT.variant, 0, entity.Position, NullVector, nil)
            hit:ToEffect():SetTimeout(20)
            hit.SpriteRotation = rng:RandomInt(360)
        end
    end
    
    if ItemVariables.BASEBALL_MITT.Used and player:HasCollectible(ItemId.BASEBALL_MITT) then
        player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        
        if ItemVariables.BASEBALL_MITT.Lifted == false then
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
        
        if game:GetFrameCount() >= ItemVariables.BASEBALL_MITT.UseDelay + 120 or Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) or
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

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.baseballMittUpdate)

function Exodus:baseballMittDamage(target, amount, flags, source, cdtimer)
    if ItemVariables.BASEBALL_MITT.Used then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.baseballMittDamage, EntityType.ENTITY_PLAYER)

function Exodus:baseballMittUse()
    ItemVariables.BASEBALL_MITT.Used = true
    ItemVariables.BASEBALL_MITT.Lifted = false
    ItemVariables.BASEBALL_MITT.BallsCaught = 0
    ItemVariables.BASEBALL_MITT.UseDelay = game:GetFrameCount()
    return true
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.baseballMittUse, ItemId.BASEBALL_MITT)

--<<<HURDLE HEELS>>>--
function Exodus:hurdleHeelsUpdate()
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

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.hurdleHeelsUpdate)

function Exodus:hurdleHeelsUse()
    local player = Isaac.GetPlayer(0)
    if ItemVariables.HURDLE_HEELS.JumpState == 0 then
        ItemVariables.HURDLE_HEELS.JumpState = 1
        ItemVariables.HURDLE_HEELS.FrameUsed = game:GetFrameCount()
        player.Velocity = Vector(0,0)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_HOW_TO_JUMP, true, false, false, false)
        sfx:Play(SoundEffect.SOUND_SUPER_JUMP, 1, 0, false, 1)
    end
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.hurdleHeelsUse, ItemId.HURDLE_HEELS)

function Exodus:hurdleHeelsRender()
    local player = Isaac.GetPlayer(0)
    if ItemVariables.HURDLE_HEELS.JumpState == 2 then
        ItemVariables.HURDLE_HEELS.Icon:SetFrame("Idle", ItemVariables.HURDLE_HEELS.Crosshair.FrameCount)
        ItemVariables.HURDLE_HEELS.Icon:Render(game:GetRoom():WorldToScreenPosition(Vector(player.Position.X, player.Position.Y - ((ItemVariables.HURDLE_HEELS.Crosshair.FrameCount) * 32))), NullVector, NullVector)
    end
    if ItemVariables.HURDLE_HEELS.JumpState == 3 then
        ItemVariables.HURDLE_HEELS.Icon:SetFrame("Idle", (ItemVariables.HURDLE_HEELS.Crosshair.FrameCount - 60) * -1)
        ItemVariables.HURDLE_HEELS.Icon:Render(game:GetRoom():WorldToScreenPosition(Vector(player.Position.X, player.Position.Y - ((ItemVariables.HURDLE_HEELS.Crosshair.FrameCount - 60) * -32))), NullVector, NullVector)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.hurdleHeelsRender)

function Exodus:hurdleHeelsDamage(target, amount, flags, source, cdtimer)
    if ItemVariables.HURDLE_HEELS.JumpState > 0 then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.hurdleHeelsDamage, EntityType.ENTITY_PLAYER)

function Exodus:hurdleHeelsCollision(player, entity)
    if ItemVariables.HURDLE_HEELS.JumpState > 0 then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, Exodus.hurdleHeelsCollision)

function Exodus:hurdleHeelsEnemyCollision(npc, entity)
    if ItemVariables.HURDLE_HEELS.JumpState > 0 and npc:IsEnemy() and entity.Type == EntityType.ENTITY_PLAYER then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Exodus.hurdleHeelsEnemyCollision)

function Exodus:hurdleHeelsCache(player, flag)
    if player:HasCollectible(ItemId.HURDLE_HEELS) and flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.1
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.hurdleHeelsCache)

function Exodus:hurdleHeelsNewRoom()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.HURDLE_HEELS) then
        ItemVariables.HURDLE_HEELS.JumpState = 0
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.hurdleHeelsNewRoom)

--<<<THE FORBIDDEN FRUIT>>>--
function Exodus:forbiddenFruitCache(player, flag)
    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (math.floor((ItemVariables.FORBIDDEN_FRUIT.UseCount^0.7) * 100)) / 101
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.forbiddenFruitCache)

function Exodus:forbiddenFruitUse()
    local player = Isaac.GetPlayer(0)
    
    if player:GetName() ~= "The Lost" and player:GetName() ~= "Keeper" then
        sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
        ItemVariables.FORBIDDEN_FRUIT.UseCount = ItemVariables.FORBIDDEN_FRUIT.UseCount + 1
        player:AddHearts(24)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()

        if player:GetSoulHearts() > 4 or player:GetMaxHearts() > 2 then
            if player:GetMaxHearts() == 0 then
                player:AddSoulHearts(-4)
                if math.random(2) == 1 then
                    Isaac.Spawn(5, 10, 7, player.Position, Vector(0, 0), player)
                end
            else
                player:AddMaxHearts(-2)
            end
        else
            player:Die()
            player:AddMaxHearts(-2)
            player:AddSoulHearts(-4)
        end
    end
    
    return true
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.forbiddenFruitUse, ItemId.FORBIDDEN_FRUIT)

--<<<YIN AND YANG>>>--
function Exodus:yinyangUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.YIN) or player:HasCollectible(ItemId.YANG) then
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.yinyangUpdate)

function Exodus:yinyangCache(player, flag)
    local heartmap = player:GetBlackHearts()
    local blackhearts = 0
    while heartmap > 0 do
        heartmap = heartmap - 2^(math.floor(math.log(heartmap) / math.log(2)))
        blackhearts = blackhearts + 1
    end
    local soulhearts = player:GetSoulHearts() - (blackhearts * 2)
    if flag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(ItemId.YIN) then
        if player:HasCollectible(ItemId.YANG) then
            player.MaxFireDelay = player.MaxFireDelay - blackhearts
        else
            player.MaxFireDelay = player.MaxFireDelay - blackhearts + math.ceil(soulhearts / 2)
        end
    end
    if flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(ItemId.YANG) then
        if player:HasCollectible(ItemId.YIN) then
            player.Damage = player.Damage + (soulhearts / 2)
        else
            player.Damage = player.Damage + (soulhearts / 2) - blackhearts
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.yinyangCache)

--<<<WELCOME MAT>>>--
function Exodus:welcomeMatUpdate()
    local player = Isaac.GetPlayer(0)
    local room = game:GetRoom()

    if player:HasCollectible(ItemId.WELCOME_MAT) then
        if ItemVariables.WELCOME_MAT.Position ~= nil then
            if (player.Position:DistanceSquared(ItemVariables.WELCOME_MAT.Position) <= 100^2) then
                ItemVariables.WELCOME_MAT.CloseToMat = true
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            else
                ItemVariables.WELCOME_MAT.CloseToMat = false
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        end
    end
    
    if player:HasCollectible(ItemId.WELCOME_MAT) then
        if not ItemVariables.WELCOME_MAT.Placed then
            ItemVariables.WELCOME_MAT.Placed = true
            ItemVariables.WELCOME_MAT.AppearFrame = 0
            local mat = Isaac.Spawn(Entities.WELCOME_MAT.id, 0, 0, player.Position, Vector(0, 0), player)
            local sprite = mat:GetSprite()
            sprite:Play("Appear", false)
            mat.Visible = false
            
            ItemVariables.WELCOME_MAT.Position = mat.Position
            mat:Remove()
        elseif ItemVariables.WELCOME_MAT.AppearFrame ~= nil then
            local mat = Isaac.Spawn(Entities.WELCOME_MAT.id, 0, 0, ItemVariables.WELCOME_MAT.Position, Vector(0, 0), player)
            local sprite = mat:GetSprite()
            ItemVariables.WELCOME_MAT.AppearFrame = ItemVariables.WELCOME_MAT.AppearFrame + 1
            sprite:SetFrame("Appear", ItemVariables.WELCOME_MAT.AppearFrame)

            for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(i)
                
                if (door ~= nil) then
                    if (player.Position:DistanceSquared(door.Position) <= 100^2) then
                        ItemVariables.WELCOME_MAT.Direction = door.Direction
                    end
                end
            end
            
            if ItemVariables.WELCOME_MAT.Direction == Direction.LEFT then
                sprite.Rotation = sprite.Rotation + 90
            elseif ItemVariables.WELCOME_MAT.Direction == Direction.UP then
                sprite.Rotation = sprite.Rotation + 180
            elseif ItemVariables.WELCOME_MAT.Direction == Direction.RIGHT then
                sprite.Rotation = sprite.Rotation + 270
            end
            if ItemVariables.WELCOME_MAT.AppearFrame <= 3 then
                mat:Remove()
            elseif ItemVariables.WELCOME_MAT.AppearFrame == 11 then
                mat:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
                ItemVariables.WELCOME_MAT.AppearFrame = nil
            else
                mat:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Exodus.welcomeMatUpdate)

function Exodus:welcomeMatNewRoom()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.WELCOME_MAT) then
        ItemVariables.WELCOME_MAT.Placed = false
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.welcomeMatNewRoom)

function Exodus:welcomeMatNewLevel()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.WELCOME_MAT) then
        ItemVariables.WELCOME_MAT.Placed = true
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Exodus.welcomeMatNewLevel)

function Exodus:welcomeMatCache(player, flag)
    if ItemVariables.WELCOME_MAT.Position ~= nil then
        if flag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(ItemId.WELCOME_MAT) and ItemVariables.WELCOME_MAT.CloseToMat then
            player.MaxFireDelay = player.MaxFireDelay - 3
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.welcomeMatCache)

--<<<WRATH OF THE LAMB>>>--
function Exodus:wotlUse()
    local player = Isaac.GetPlayer(0)
    local level = game:GetLevel()
    local stat = rng:RandomInt(4)
    
    if stat == 0 then
        ItemVariables.WRATH_OF_THE_LAMB.Stats.Damage = ItemVariables.WRATH_OF_THE_LAMB.Stats.Damage + 1
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    elseif stat == 1 then
        ItemVariables.WRATH_OF_THE_LAMB.Stats.Speed = ItemVariables.WRATH_OF_THE_LAMB.Stats.Speed + 1
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    elseif stat == 2 then
        ItemVariables.WRATH_OF_THE_LAMB.Stats.Range = ItemVariables.WRATH_OF_THE_LAMB.Stats.Range + 1
        player:AddCacheFlags(CacheFlag.CACHE_RANGE)
    elseif stat == 3 then
        ItemVariables.WRATH_OF_THE_LAMB.Stats.FireDelay = ItemVariables.WRATH_OF_THE_LAMB.Stats.FireDelay + 1
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    else
        error("Invalid stat rolled - Value: " .. tostring(stat))
    end
    
    music:PitchSlide(0.5)
    player:EvaluateItems()
    
    local mark = Isaac.Spawn(Entities.SUMMONING_MARK.id, Entities.SUMMONING_MARK.variant, 0, player.Position, Vector(0, 0), player)
    mark:GetSprite():SetFrame("Idle", 0)
    mark:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
    table.insert(ItemVariables.WRATH_OF_THE_LAMB.Uses, { Room = level:GetCurrentRoomIndex(), Mark = mark, BossSpawned = false, Countdown = 65 })
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.wotlUse, ItemId.WRATH_OF_THE_LAMB)

function Exodus:wotlCache(player, cacheFlag)
    local damageBonus = 0.5 * ItemVariables.WRATH_OF_THE_LAMB.Stats.Damage
    local speedBonus = 0.1 * ItemVariables.WRATH_OF_THE_LAMB.Stats.Speed
    local rangeBonus = 2 * ItemVariables.WRATH_OF_THE_LAMB.Stats.Range
    local fireDelayBonus = ItemVariables.WRATH_OF_THE_LAMB.Stats.FireDelay
    
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage - damageBonus
    elseif cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = math.max(0.6, player.MoveSpeed - speedBonus)
    elseif cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight + rangeBonus
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay + fireDelayBonus
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.wotlCache)

function Exodus:wotlUpdate()
    local player = Isaac.GetPlayer(0)
    local level = game:GetLevel()
    local room = game:GetRoom()
    
    for i, tbl in pairs(ItemVariables.WRATH_OF_THE_LAMB.Uses) do
        if tbl then
            if tbl.Countdown >= 0 then
                tbl.Countdown = tbl.Countdown - 1
            elseif not tbl.BossSpawned then
                tbl.BossSpawned = true
                
                local stage = level:GetAbsoluteStage()
                local pool
                
                if stage == 11 then
                    if level:GetStageType() == StageType.STAGETYPE_WOTL then
                        Isaac.ExecuteCommand("stage 11")
                    else
                        player:UseCard(Card.CARD_EMPEROR)
                    end
                elseif stage <= 8 then
                    if stage % 2 == 1 then
                        pool = ItemVariables.WRATH_OF_THE_LAMB.Bosses[(stage + 1) / 2]
                    else
                        pool = ItemVariables.WRATH_OF_THE_LAMB.Bosses[stage / 2]
                    end
                elseif stage <= 10 then
                    pool = ItemVariables.WRATH_OF_THE_LAMB.Bosses[stage - 4]
                else
                    pool = ItemVariables.WRATH_OF_THE_LAMB.Bosses[#ItemVariables.WRATH_OF_THE_LAMB.Bosses]
                end
                
                tbl.Boss = Isaac.Spawn(pool[rng:RandomInt(#pool) + 1], 0, 0, tbl.Mark.Position, Vector(0, 0), nil)
                
                if music:GetCurrentMusicID() ~= MusicId.LOCUS then
                    music:Crossfade(MusicId.LOCUS)
                end
                
                music:PitchSlide(1)
                
                room:SetClear(false)
            elseif not tbl.Boss:IsDead() then
                for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                    local door = room:GetDoor(i)
                    
                    if door ~= nil then
                        local tarType = door.TargetRoomType
                        local curType = door.CurrentRoomType
                        
                        if (tarType ~= RoomType.ROOM_SECRET and tarType ~= RoomType.ROOM_SUPERSECRET and curType ~= RoomType.ROOM_SECRET and curType ~= RoomType.ROOM_SUPERSECRET and not door:IsLocked()) or door:IsOpen() then
                            door:Bar()
                        end
                    end
                end
            elseif room:IsClear() then
                music:Play(Music.MUSIC_BOSS_OVER, 0.1)
                
                local payout = rng:RandomInt(100)
                
                if payout < 70 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                elseif payout < 75 then
                    for i = 1, 2 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                    end
                elseif payout < 80 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                elseif payout < 85 then
                    for i = 1, 2 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                    end
                elseif payout < 90 then
                    for i = 1, 3 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                    end
                elseif payout < 95 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(tbl.Mark.Position, 20), Vector(0, 0), player)
                end
                
                table.remove(ItemVariables.WRATH_OF_THE_LAMB.Uses, i)
                
                i = i - 1
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.wotlUpdate)

function Exodus:wotlPEffectUpdate()
    for i, tbl in pairs(ItemVariables.WRATH_OF_THE_LAMB.Uses) do
        if tbl.Countdown >= 0 then
            local mark = Isaac.Spawn(Entities.SUMMONING_MARK.id, Entities.SUMMONING_MARK.variant, 0, tbl.Mark.Position, Vector(0, 0), nil)
            mark:GetSprite():SetFrame("Idle", 21 - (tbl.Countdown % 22))
            mark:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Exodus.wotlPEffectUpdate)

function Exodus:wotlNewRoom()
    ItemVariables.WRATH_OF_THE_LAMB.Uses = {}
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.wotlNewRoom)
  
--<<<TRAGIC MUSHROOM>>>--
function Exodus:tragicMushroomCache(player, flag)
    for i = 1, ItemVariables.TRAGIC_MUSHROOM.Uses do
        local ratio = 1 / (1<<(i - 1))
        
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = (player.Damage + (0.8 * ratio)) * (ratio + 1)
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight - (7.25 * ratio)
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + (0.6 * ratio)
        end
    end
end
    
Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.tragicMushroomCache)

function Exodus:tragicMushroomUse()
    local player = Isaac.GetPlayer(0)

    if player:GetPlayerType() == PlayerType.PLAYER_XXX then
        local maxhp = player:GetSoulHearts() - 2
        player:AddSoulHearts(-maxhp)
    else
        local maxhp = player:GetMaxHearts() - 2
        player:AddSoulHearts(-player:GetSoulHearts())
        player:AddMaxHearts(-maxhp)
        player:AddHearts(2)
    end
    
    ItemVariables.TRAGIC_MUSHROOM.Uses = ItemVariables.TRAGIC_MUSHROOM.Uses + 1
    sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE + CacheFlag.CACHE_RANGE + CacheFlag.CACHE_SPEED)
    player:EvaluateItems()
    player:RemoveCollectible(ItemId.TRAGIC_MUSHROOM)
    
    return true
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.tragicMushroomUse, ItemId.TRAGIC_MUSHROOM)

--<<<HUNGRY HIPPO>>>--
function Exodus:hungryHippoCache(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(ItemId.HUNGRY_HIPPO) then
        player:CheckFamiliar(Entities.HUNGRY_HIPPO.variant, player:GetCollectibleNum(ItemId.HUNGRY_HIPPO), rng)
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.hungryHippoCache)

function Exodus:hungryHippoInit(hippo)
    local player = Isaac.GetPlayer(0)
    
    hippo.OrbitLayer = 98
    hippo.Position = hippo:GetOrbitPosition(player.Position + player.Velocity)
    hippo.Visible = false
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.hungryHippoInit, Entities.HUNGRY_HIPPO.variant)

function Exodus:hungryHippoUpdate(hippo)
    local player = Isaac.GetPlayer(0)
    local data = hippo:GetData()
    local sprite = hippo:GetSprite()
    
    if hippo.FrameCount >= 1 then
        hippo.Visible = true
    else
        hippo.Visible = false
    end
    
    if hippo.FrameCount == 1 then
        hippo.SpawnerVariant = 0
        hippo.SpawnerType = 0
    end
    
    hippo.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    hippo.OrbitDistance = Vector(35 + (hippo.State * 15), 35 + (hippo.State * 15))
    
    if player:HasTrinket(TrinketType.TRINKET_CHILD_LEASH) then
        hippo.OrbitDistance = hippo.OrbitDistance / 2
    end
    
    hippo.OrbitSpeed = 0.03
    hippo.FireCooldown = 32
    
    if not Exodus:PlayerIsMoving() then
        hippo.Position = hippo:GetOrbitPosition(player.Position + player.Velocity)
    end
    
    hippo.Velocity = hippo:GetOrbitPosition(player.Position + player.Velocity) - hippo.Position
    hippo.GridCollisionClass = 0
    hippo.CollisionDamage = hippo.State * (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS) + 1)
    
    local closestEnemyDistance = 999999999
    local closestEnemy = nil
    
    if data.HasFired ~= 0 and data.HasFired ~= nil then
        data.HasFired = data.HasFired - 1
    end
    
    if data.HasSucc then
        sprite:Play("Succ "..tostring(math.floor(hippo.SpawnerVariant / 15) + 1), false)
    else
        sprite:Play(tostring(math.floor(hippo.SpawnerVariant / 15) + 1), false)
    end
    
    if hippo.State > 4 then 
        hippo.State = 4 
    elseif hippo.State == 0 then 
        hippo.State = 1 
    end
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local checkDist = entity.Position:DistanceSquared(hippo.Position)
        
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            if checkDist < closestEnemyDistance then
                closestEnemyDistance = checkDist
                closestEnemy = entity
            end
        end
        
        if hippo.State == 4 and entity.Type == EntityType.ENTITY_BOMBDROP and entity.SpawnerType ~= EntityType.ENTITY_PLAYER then
            if checkDist < 24^2 then
                entity:Remove()
                Isaac.Explode(hippo.Position, player, 60)
            end
            
            entity.Velocity = entity.Velocity + (hippo.Position - entity.Position) / 25
        end
        
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            if checkDist < 24^2 then
                entity:Die()
                
                if hippo.State ~= 4 then
                    hippo.SpawnerVariant = hippo.SpawnerVariant + 1
                    hippo.State = math.floor(hippo.SpawnerVariant / 15) + 1
                end
                
                if hippo.State == 1 then
                    hippo.SpawnerType = 0
                else
                    hippo.SpawnerType = hippo.SpawnerType + 1
                end
            end
            
            if checkDist < 75^2 and hippo.State >= 3 then
                entity.Velocity = entity.Velocity + (hippo.Position - entity.Position) / 25
            end
        end
    end
    
    if hippo.SpawnerType >= hippo.FireCooldown then
        hippo.SpawnerType = hippo.FireCooldown - 1
    end
    
    local canShoot = false
    local shootDir
    
    if closestEnemy and hippo.FrameCount % (hippo.FireCooldown - hippo.SpawnerType) == 0 and hippo.SpawnerType ~= 0 and hippo.State ~= 1 then
        data.HasSucc = true
        canShoot = true
        hippo.SpawnerType = hippo.SpawnerType - 1
        data.HasFired = 4
        shootDir = (closestEnemy.Position - hippo.Position):Normalized()
    else
        if data.HasFired == 0 or data.HasFired == nil then
            data.HasSucc = false
        end
    end
    
    if canShoot then
        local tear = hippo:FireProjectile(shootDir)
        tear:ChangeVariant(1)
        tear.Scale = 1 * (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS) / 4 + 1)
        tear.CollisionDamage = 2 * (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS) + 1)
        tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SPECTRAL
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Exodus.hungryHippoUpdate, Entities.HUNGRY_HIPPO.variant)

--<<<SUNDIAL>>>--
function Exodus:sundialCache(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(ItemId.SUNDIAL) then
        player:CheckFamiliar(Entities.SUN.variant, player:GetCollectibleNum(ItemId.SUNDIAL), rng)
        player:CheckFamiliar(Entities.SHADOW.variant, player:GetCollectibleNum(ItemId.SUNDIAL), rng)
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.sundialCache)

function Exodus:sunInit(sun)
    local player = Isaac.GetPlayer(0)
    
    sun.OrbitLayer = 98
    sun.Position = sun:GetOrbitPosition(player.Position + player.Velocity)
    sun.Visible = false
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.sunInit, Entities.SUN.variant)

function Exodus:shadowInit(shadow)
    local player = Isaac.GetPlayer(0)
    
    shadow.OrbitLayer = 98
    shadow.Position = shadow:GetOrbitPosition(player.Position + player.Velocity)
    shadow.Visible = false
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.shadowInit, Entities.SHADOW.variant)

function Exodus:sunUpdate(sun)
    local player = Isaac.GetPlayer(0)
    
    if sun.FrameCount >= 1 then
        sun.Visible = true
    else
        sun.Visible = false
    end

    if not player:HasCollectible(ItemId.SUNDIAL) then
        sun:Remove()
    end
    
    if math.random(12) == 1 then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, Vector(sun.Position.X, sun.Position.Y - 8), RandomVector() * ((math.random() * 4) + 1), player)
    end

    if sun.FrameCount == 1 then
        sun.SpawnerVariant = 0
        sun.SpawnerType = 0
    end

    sun.OrbitDistance = Vector(64, 64)
    
    if player:HasTrinket(TrinketType.TRINKET_CHILD_LEASH) then
        sun.OrbitDistance = sun.OrbitDistance / 2
    end
    
    sun.OrbitSpeed = 0.02

    if not Exodus:PlayerIsMoving() then
        sun.Position = sun:GetOrbitPosition(player.Position + player.Velocity)
    end
    
    sun.Velocity = sun:GetOrbitPosition(player.Position + player.Velocity) - sun.Position
    sun.GridCollisionClass = 0

    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            if sun.Position:Distance(entity.Position) < 24 and entity:IsFlying() then
                entity:AddBurn(EntityRef(sun), 100, 1)
                entity:TakeDamage(2, 0, EntityRef(sun), 3)
                if math.random(4) == 1 then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, Vector(sun.Position.X, sun.Position.Y - 8), RandomVector() * ((math.random() * 4) + 1), player)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Exodus.sunUpdate, Entities.SUN.variant)

function Exodus:shadowUpdate(shadow)
    local player = Isaac.GetPlayer(0)
    local sprite = shadow:GetSprite()
    
    if shadow.FrameCount >= 1 then
        shadow.Visible = true
    else
        shadow.Visible = false
    end

    if not player:HasCollectible(ItemId.SUNDIAL) then
        shadow:Remove()
    end

    if shadow.FrameCount == 1 then
        shadow.SpawnerVariant = 0
        shadow.SpawnerType = 0
    end

    shadow.OrbitDistance = Vector(64, 64)
    
    if player:HasTrinket(TrinketType.TRINKET_CHILD_LEASH) then
        shadow.OrbitDistance = shadow.OrbitDistance / 2
    end
    
    shadow.OrbitSpeed = 0.02

    if not Exodus:PlayerIsMoving() then
        shadow.Position = shadow:GetOrbitPosition(player.Position + player.Velocity)
    end
    
    shadow.Velocity = shadow:GetOrbitPosition(player.Position + player.Velocity) - shadow.Position
    shadow.GridCollisionClass = 0

    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            if shadow.Position:Distance(entity.Position) < 24 and not entity:IsFlying() then
                entity:AddFear(EntityRef(shadow), 100)
                entity:TakeDamage(2, 0, EntityRef(shadow), 3)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Exodus.shadowUpdate, Entities.SHADOW.variant)

--<<<ROBO-BABY 3.6.0>>>--
function Exodus:roboBabyCache(player, flag)
    if player:HasCollectible(ItemId.ROBOBABY_360) and flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(Entities.ROBOBABY_360.variant, player:GetCollectibleNum(ItemId.ROBOBABY_360) + ItemVariables.ROBOBABY_360.UsedBox, rng)
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.roboBabyCache)

function Exodus:roboBabyInit(robo)
    local player = Isaac.GetPlayer(0)
    robo:GetData().FireDelay = 30
  
    local sprite = robo:GetSprite()
    sprite:Play("IdleDown")
    robo.OrbitLayer = 120
    robo.Position = robo:GetOrbitPosition(player.Position + player.Velocity)
    robo.Visible = false
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.roboBabyInit, Entities.ROBOBABY_360.variant)

function Exodus:roboBabyFamiliarUpdate(robo)
    local player = Isaac.GetPlayer(0)
    local sprite = robo:GetSprite()
    local data = robo:GetData()
    
    if not player:HasCollectible(ItemId.ROBOBABY_360) then
        robo:Remove()
    end

    if robo.FrameCount >= 1 then
        robo.Visible = true
    else
        robo.Visible = false
    end

    if robo.FrameCount == 1 then
        robo.SpawnerVariant = 0
        robo.SpawnerType = 0
    end

    robo.OrbitDistance = Vector(64, 64)
    
    if player:HasTrinket(TrinketType.TRINKET_CHILD_LEASH) then
        robo.OrbitDistance = robo.OrbitDistance / 2
    end
    
    robo.OrbitSpeed = 0.03

    if not Exodus:PlayerIsMoving() then
        robo.Position = robo:GetOrbitPosition(player.Position + player.Velocity)
    end
    
    robo.Velocity = robo:GetOrbitPosition(player.Position + player.Velocity) - robo.Position
    robo.GridCollisionClass = 0

    if data.FireDelay == 0 then
        if player:GetFireDirection() > -1 then
            data.FireDelay = 30

            if player:GetHeadDirection() == Direction.DOWN then
                sprite:Play("ShootDown", true)
            elseif player:GetHeadDirection() == Direction.LEFT then
                sprite:Play("ShootSide2", true)
            elseif player:GetHeadDirection() == Direction.RIGHT then
                sprite:Play("ShootSide", true)
            elseif player:GetHeadDirection() == Direction.UP then
                sprite:Play("ShootUp", true)
            end

            local laser = player:FireTechXLaser(robo.Position, robo.Velocity, 1)
            laser:Update()
            laser.TearFlags = TearFlags.TEAR_CONTINUUM
            laser:Update()
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                laser.CollisionDamage = 4
            else
                laser.CollisionDamage = 2
            end
            laser:GetData().IsFromRoboBaby = true
            laser.Color = Color(1, 0, 0, 1, 100, 0, 0)
        else
            sprite:Play("IdleDown", true)
        end
    else
        data.FireDelay = data.FireDelay - 1

        if player:GetFireDirection() > -1 then
            if data.FireDelay < 7 then
                if player:GetHeadDirection() == Direction.UP then
                    sprite:Play("IdleUp", true)
                elseif player:GetHeadDirection() == Direction.LEFT then
                    sprite:Play("IdleSide2", true)
                elseif player:GetHeadDirection() == Direction.RIGHT then
                    sprite:Play("IdleSide", true)
                else
                    sprite:Play("IdleDown", true)
                end
            end
        else
            sprite:Play("IdleDown", true)
        end
    end

    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_LASER and entity:GetData().IsFromRoboBaby ~= nil then
            entity.Position = robo.Position
            entity.Velocity = robo.Velocity
            entity:ToLaser().Radius = entity:ToLaser().Radius + 3
            if entity:ToLaser().Radius > 64 then
                entity:Remove()
                
                for u = 1, 4 do
                    local laser = player:FireTechLaser(entity.Position, 3193, Vector.FromAngle(u * (90 + rng:RandomInt(11) - 5)), false, false)
                    laser:Update()
                    laser.TearFlags = TearFlags.TEAR_SPECTRAL
                    laser:Update()
                    laser.DisableFollowParent = true
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                        laser.CollisionDamage = 4
                    else
                        laser.CollisionDamage = 2
                    end
                    laser.Color = Color(1, 0, 0, 1, 100, 0, 0)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Exodus.roboBabyFamiliarUpdate, Entities.ROBOBABY_360.variant)

function Exodus:roboBabyNewRoom()
    local player = Isaac.GetPlayer(0)
    ItemVariables.ROBOBABY_360.UsedBox = 0
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    player:EvaluateItems()
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.roboBabyNewRoom)

--<<<LIL RUNE>>>--
function Exodus:lilRuneCache(player, flag)
    if player:HasCollectible(ItemId.LIL_RUNE) and flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(Entities.LIL_RUNE.variant, player:GetCollectibleNum(ItemId.LIL_RUNE) + ItemVariables.LIL_RUNE.UsedBox, rng)
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.lilRuneCache)

function Exodus:lilRuneInit(rune)
    local player = Isaac.GetPlayer(0)
    rune.IsFollower = true

    local sprite = rune:GetSprite()
    local data = rune:GetData()
    sprite:Play("PurpleDown")
    data.FireDelay = 20
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.lilRuneInit, Entities.LIL_RUNE.variant)

function Exodus:lilRuneFamiliarUpdate(rune)
    local player = Isaac.GetPlayer(0)
    local sprite = rune:GetSprite()
    local data = rune:GetData()

    if not player:HasCollectible(ItemId.LIL_RUNE) then
        rune:Remove()
    end

    rune:FollowParent()

    if ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        if ItemVariables.LIL_RUNE.RuneType == 1 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("AlgizTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 2 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("HaglazTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 3 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("JeraTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 4 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("PerthroTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 5 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("EhwazTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 6 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("AnsuzTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 7 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("DagazTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 8 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("BerkanoTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 9 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("BlackTransform", false)
        elseif ItemVariables.LIL_RUNE.RuneType == 10 and ItemVariables.LIL_RUNE.PlayAnim then
            sprite:Play("BlankTransform", false)
        end
        ItemVariables.LIL_RUNE.PlayAnim = false
    end
    
    if sprite:IsFinished("AlgizTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("HaglazTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("JeraTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("PerthroTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("EhwazTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("AnsuzTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("DagazTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("BerkanoTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("BlackTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    elseif sprite:IsFinished("BlankTransform") and ItemVariables.LIL_RUNE.PlayAnim ~= nil then
        ItemVariables.LIL_RUNE.PlayAnim = nil
        sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
    end

    local isblankrune = false

    if ItemVariables.LIL_RUNE.RuneType == 10 then
        isblankrune = true
        ItemVariables.LIL_RUNE.RuneType = rng:RandomInt(9)
    end

    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()

        if entity.Type == EntityType.ENTITY_TEAR then
            if data.IsFromLilRune == true then
                if entity:IsDead() then
                    for i = 1, 4 do
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.NAIL_PARTICLE, 0, entity.Position, RandomVector() * ((math.random() * 4) + 1), player)
                    end
                elseif ItemVariables.LIL_RUNE.RuneType == 1 then
                    for i, shot in pairs(Isaac.GetRoomEntities()) do
                        if shot.Type == EntityType.ENTITY_PROJECTILE then
                            if shot.Position:Distance(entity.Position) < 12 then
                                shot:Kill()
                                entity:Kill()
                            end
                        end
                    end
                end
            elseif ItemVariables.RuneType == 5 then
                for i, fam in pairs(Isaac.GetRoomEntities()) do
                    if fam.Type == EntityType.ENTITY_FAMILIAR and fam.Variant == Entities.LIL_RUNE.variant then
                        if shot.Position:Distance(entity.Position) < 24 then
                            entity:ToTear().TearFlags = entity:ToTear().TearFlags + TearFlags.TEAR_CONTINUUM + TearFlags.TEAR_PIERCING
                            entity:ToTear().TearFallingSpeed = entity:ToTear().TearFallingSpeed - 5
                        end
                    end
                end
            end
        end
        if ItemVariables.LIL_RUNE.RuneType == 1 and entity.Type == EntityType.ENTITY_PROJECTILE then
            if entity.Position:Distance(rune.Position) < 16 then
                entity:Kill()
            end
        end
        if ItemVariables.LIL_RUNE.RuneType == 3 then
            if entity:IsEnemy() and entity:IsDead() and data.RuneSplitted == nil and entity:ToNPC().ParentNPC == nil and entity.Type ~= EntityType.ENTITY_SWARM and rng:RandomInt(8) == 1 then
                data.RuneSplitted = true
                if entity:ToNPC().ChildNPC ~= nil then
                    entity:ToNPC().ChildNPC:Kill()
                end
                local dup = Isaac.Spawn(entity.Type, entity.Variant, entity.SubType, Isaac.GetFreeNearPosition(entity.Position, 1), Vector(0,0), nil)
                dup:ToNPC().Scale = dup:ToNPC().Scale / 1.3
                dup.MaxHitPoints = dup.MaxHitPoints / 2
                dup.HitPoints = dup.MaxHitPoints
                local dup = Isaac.Spawn(entity.Type, entity.Variant, entity.SubType, Isaac.GetFreeNearPosition(entity.Position, 1), Vector(0,0), nil)
                dup:ToNPC().Scale = dup:ToNPC().Scale / 1.3
                dup.MaxHitPoints = dup.MaxHitPoints / 2
                dup.HitPoints = dup.MaxHitPoints
            elseif entity:IsEnemy() and entity:IsDead() and data.RuneSplitted == nil then
                data.RuneSplitted = true
            end
        end
    end

    if data.FireDelay == 0 and ItemVariables.LIL_RUNE.PlayAnim == nil then
        if player:GetFireDirection() > -1 then
            data.FireDelay = 20
            local dir = Vector(0,0)
            
            if player:GetHeadDirection() == Direction.DOWN then
                sprite:Play(ItemVariables.LIL_RUNE.State .. "DownShoot", true)
                dir = Vector(0, 10) + (rune.Velocity / 3)
            elseif player:GetHeadDirection() == Direction.LEFT then
                sprite:Play(ItemVariables.LIL_RUNE.State .. "LeftShoot", true)
                dir = Vector(-10, 0) + (rune.Velocity / 3)
            elseif player:GetHeadDirection() == Direction.RIGHT then
                sprite:Play(ItemVariables.LIL_RUNE.State .. "RightShoot", true)
                dir = Vector(10, 0) + (rune.Velocity / 3)
            elseif player:GetHeadDirection() == Direction.UP then
                sprite:Play(ItemVariables.LIL_RUNE.State .. "UpShoot", true)
                dir = Vector(0, -10) + (rune.Velocity / 3)
            end
            
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 619576, 0, rune.Position, dir, rune):ToTear()
            local tearData = tear:GetData()
            local tearSprite = tear:GetSprite()
            if isblankrune then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    tear.CollisionDamage = 7
                    tearSprite:Play("BFFS Blank", true)
                else
                    tear.CollisionDamage = 3.5
                    tearSprite:Play("Blank", true)
                end
            else
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    tear.CollisionDamage = 7
                    tearSprite:Play("BFFS Purple", true)
                else
                    tear.CollisionDamage = 3.5
                    tearSprite:Play("Purple", true)
                end
            end
            if ItemVariables.LIL_RUNE.RuneType == 2 and rng:RandomInt(6) == 1 then
                tear.TearFlags = tear.TearFlags + TearFlags.TEAR_EXPLOSIVE
            elseif ItemVariables.LIL_RUNE.RuneType == 3 then
                tear.TearFlags = tear.TearFlags + TearFlags.TEAR_SPLIT
            elseif ItemVariables.LIL_RUNE.RuneType == 5 then
                tear.TearFlags = tear.TearFlags + TearFlags.TEAR_CONTINUUM + TearFlags.TEAR_SPECTRAL + TearFlags.TEAR_PIERCING
                tear.Height = tear.Height + 5
            elseif ItemVariables.LIL_RUNE.RuneType == 6 then
                local tear2 = Isaac.Spawn(EntityType.ENTITY_TEAR, 619576, 0, rune.Position, dir, rune):ToTear()
                local tearData2 = tear2:GetData()
                local tearSprite2 = tear2:GetSprite()
                if isblankrune then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                        tear2.CollisionDamage = 7
                        tearSprite2:Play("BFFS Blank", true)
                    else
                        tear2.CollisionDamage = 3.5
                        tearSprite2:Play("Blank", true)
                    end
                else
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                        tear2.CollisionDamage = 7
                        tearSprite2:Play("BFFS Purple", true)
                    else
                        tear2.CollisionDamage = 3.5
                        tearSprite2:Play("Purple", true)
                    end
                end

                if player:GetHeadDirection() == Direction.DOWN then
                    tear.Position = tear.Position + Vector(-8, 0)
                    tear2.Position = tear2.Position + Vector(8, 0)
                elseif player:GetHeadDirection() == Direction.LEFT then
                    tear.Position = tear.Position + Vector(0, -8)
                    tear2.Position = tear2.Position + Vector(0, 8)
                elseif player:GetHeadDirection() == Direction.RIGHT then
                    tear.Position = tear.Position + Vector(0, 8)
                    tear2.Position = tear2.Position + Vector(0, -8)
                else
                    tear.Position = tear.Position + Vector(8, 0)
                    tear2.Position = tear2.Position + Vector(-8, 0)
                end
                tearData2.IsFromLilRune = true
            elseif ItemVariables.LIL_RUNE.RuneType == 8 and rng:RandomInt(2) == 1 then
                tear.TearFlags = tear.TearFlags + TearFlags.TEAR_EGG
            elseif ItemVariables.LIL_RUNE.RuneType == 9 then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    tear.CollisionDamage = 7
                    tearSprite:Play("BFFS Black", true)
                else
                    tear.CollisionDamage = 3.5
                    tearSprite:Play("Black", true)
                end
                if rng:RandomInt(10) == 1 then
                    tear.TearFlags = tear.TearFlags + TearFlags.TEAR_HORN
                end
            end
            tearData.IsFromLilRune = true
        else
            sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
        end
    elseif ItemVariables.LIL_RUNE.PlayAnim == nil then
        data.FireDelay = data.FireDelay - 1
        if player:GetFireDirection() > -1 then
            if data.FireDelay < 15 then
                if player:GetHeadDirection() == Direction.DOWN then
                    sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
                elseif player:GetHeadDirection() == Direction.LEFT then
                    sprite:Play(ItemVariables.LIL_RUNE.State .. "Left", true)
                elseif player:GetHeadDirection() == Direction.RIGHT then
                    sprite:Play(ItemVariables.LIL_RUNE.State .. "Right", true)
                elseif player:GetHeadDirection() == Direction.UP then
                    sprite:Play(ItemVariables.LIL_RUNE.State .. "Up", true)
                end
            end
        else
            sprite:Play(ItemVariables.LIL_RUNE.State .. "Down", true)
        end
    end

    if isblankrune then
        ItemVariables.LIL_RUNE.RuneType = 10
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Exodus.lilRuneFamiliarUpdate, Entities.LIL_RUNE.variant)

function Exodus:lilRuneNewRoom()
    local player = Isaac.GetPlayer(0)
    ItemVariables.LIL_RUNE.UsedBox = 0
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    player:EvaluateItems()
    if ItemVariables.LIL_RUNE.RuneType == 7 then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsEnemy() then
                if entity:ToNPC():IsChampion() then
                    entity:Remove()
                    Isaac.Spawn(entity.Type, entity.Variant, entity.SubType, entity.Position, Vector(0,0), entity)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.lilRuneNewRoom)

function Exodus:lilRuneUse(rune)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.LIL_RUNE) then
        if rune == Card.RUNE_ALGIZ then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 1
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_HAGALAZ then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 2
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_JERA then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 3
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_PERTHRO then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 4
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_EHWAZ then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 5
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_ANSUZ then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 6
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_DAGAZ then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 7
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_BERKANO then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 8
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_BLACK then
            ItemVariables.LIL_RUNE.State = "Black"
            ItemVariables.LIL_RUNE.RuneType = 9
            ItemVariables.LIL_RUNE.PlayAnim = true
        elseif rune == Card.RUNE_BLANK then
            ItemVariables.LIL_RUNE.State = "Purple"
            ItemVariables.LIL_RUNE.RuneType = 10
            ItemVariables.LIL_RUNE.PlayAnim = true
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_USE_CARD, Exodus.lilRuneUse)

function Exodus:lilRuneUpdate()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.LIL_RUNE) then
        if not ItemVariables.LIL_RUNE.HasLilRune then
            Isaac.Spawn(5, 300, math.random(32, 41), Isaac.GetFreeNearPosition(player.Position, 50), Vector(0, 0), nil)
            ItemVariables.LIL_RUNE.HasLilRune = true
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.lilRuneUpdate)

--<<<SLING + BUTTROT + LIL RUNE PRE_TEAR_COLLISION>>>--
function Exodus:buttrotShatter(tear, target)
    local player = Isaac.GetPlayer(0)
    local isblankrune = false
    if ItemVariables.LIL_RUNE.RuneType == 10 then
        isblankrune = true
        ItemVariables.LIL_RUNE.RuneType = rng:RandomInt(9)
    end
    if tear:GetData().IsFromLilRune and ItemVariables.LIL_RUNE.RuneType == 2 and target:IsVulnerableEnemy() and not EntityRef(target).IsFriendly then
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() and not EntityRef(entity).IsFriendly and entity ~= target then
                entity:TakeDamage(tear.CollisionDamage / 2, 0, EntityRef(tear), 3)
            end
        end
    end
    if tear:GetData().IsFromLilRune and ItemVariables.LIL_RUNE.RuneType == 4 and target:IsVulnerableEnemy() and not EntityRef(target).IsFriendly then
        if 1 == math.random(10) then
            game:RerollEnemy(target)
        end
    end
    if tear:GetData().IsFromLilRune and ItemVariables.LIL_RUNE.RuneType == 7 and target:IsActiveEnemy() then
        Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, tear.Position, Vector(0,0), tear)
    end
    if isblankrune then
        ItemVariables.LIL_RUNE.RuneType = 10
    end
end

Exodus:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, Exodus.buttrotShatter)



--<<<THE LADDER>>>--
function Exodus:ladderUpdate()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LADDER) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.ladderUpdate)

function Exodus:ladderCache(player, flag)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LADDER) and flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.1
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.ladderCache)

--<<<FIRE MIND>>>--
function Exodus:fireMindUpdate()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:EvaluateItems()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.fireMindUpdate)

function Exodus:fireMindCache(player, flag)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) and flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 0.5
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) and flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + 0.35
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.fireMindCache)

--<<<LUCKY FOOT + LUCK TOE>>>--
function Exodus:luckUpdate()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:EvaluateItems()
    end
    if player:HasTrinket(TrinketType.TRINKET_LUCKY_TOE) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:EvaluateItems()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.luckUpdate)

function Exodus:luckCache(player, flag)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) and flag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + 2
    end
    if player:HasTrinket(TrinketType.TRINKET_LUCKY_TOE) and flag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + 1
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.luckCache)

--<<<MOLDY BREAD>>>--
function Exodus:breadUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOLDY_BREAD) and not ItemVariables.MOLDY_BREAD.GotFlies then
        player:AddBlueFlies(20, player.Position, player)
        ItemVariables.MOLDY_BREAD.GotFlies = true
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.breadUpdate)

--<<<HOLY WATER>>>--
function Exodus:holyWaterDamage(target, amount, flags, source, cdtimer)
    local player = Isaac.GetPlayer(0)
    local chance = game:GetRoom():GetDevilRoomChance()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_WATER) and not ItemVariables.HOLY_WATER.Splashed then
        ItemVariables.HOLY_WATER.Splashed = true
        if player:GetSoulHearts() > 0 then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, false, false, false)
            player:AddSoulHearts(-1)
            return false
        else
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, false, false, false)
            player:AddHearts(-1)
            return false
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.holyWaterDamage, EntityType.ENTITY_PLAYER)

function Exodus:holyWaterRoom()
    ItemVariables.HOLY_WATER.Splashed = false
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.holyWaterRoom)

--<<<MUTANT CLOVER>>>--
function Exodus:mutantCloverNewRoom()
    local player = Isaac.GetPlayer(0)
    
    ItemVariables.MUTANT_CLOVER.Used = 0
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
    player:EvaluateItems()
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.mutantCloverNewRoom)

function Exodus:mutantCloverCache(player, flag)
    if player:HasCollectible(ItemId.MUTANT_CLOVER) and ItemVariables.MUTANT_CLOVER.Used > 0 then
        if flag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + (10 * ItemVariables.MUTANT_CLOVER.Used)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.mutantCloverCache)

function Exodus:mutantCloverUse()
    local player = Isaac.GetPlayer(0)
    ItemVariables.MUTANT_CLOVER.Used = ItemVariables.MUTANT_CLOVER.Used + 1
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
    player:EvaluateItems()
    
    return true
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.mutantCloverUse, ItemId.MUTANT_CLOVER)

--<<<UNHOLY MANTLE>>>--
function Exodus:unholyMantleCostume()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.UNHOLY_MANTLE) then
        if not ItemVariables.UNHOLY_MANTLE.HasUnholyMantle then
            player:AddNullCostume(CostumeId.UNHOLY_MANTLE)
            ItemVariables.UNHOLY_MANTLE.HasUnholyMantle = true
        end
    elseif ItemVariables.UNHOLY_MANTLE.HasUnholyMantle then
        ItemVariables.UNHOLY_MANTLE.HasUnholyMantle = false
        player:TryRemoveNullCostume(CostumeId.UNHOLY_MANTLE)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.unholyMantleCostume)

function Exodus:unholyMantleDamage(target, amount, flags, source, cdtimer)
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.UNHOLY_MANTLE) then
        if ItemVariables.UNHOLY_MANTLE.HasEffect then
            player:TryRemoveNullCostume(CostumeId.UNHOLY_MANTLE)
            
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                if entity:IsVulnerableEnemy() then
                    entity:TakeDamage(math.ceil(100 * (game:GetLevel():GetAbsoluteStage()^0.7)), 0, EntityRef(player), 3)
                end
            end
            
            ItemVariables.UNHOLY_MANTLE.HasEffect = false
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.unholyMantleDamage, EntityType.ENTITY_PLAYER)

function Exodus:unholyMantleNewFloor()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.UNHOLY_MANTLE) then
        if ItemVariables.UNHOLY_MANTLE.HasEffect then
            player:AddBlackHearts(4)
            player:AddNullCostume(CostumeId.UNHOLY_MANTLE)
        else
            ItemVariables.UNHOLY_MANTLE.HasEffect = true
            player:AddNullCostume(CostumeId.UNHOLY_MANTLE)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Exodus.unholyMantleNewFloor)

--<<<THE PSEUDOBULBAR EFFECT>>>--
function Exodus:FireTurretBullet(pos, vel, spawner)
    local player = Isaac.GetPlayer(0)
    local TurretBullet = player:FireTear(pos, vel, false, true, false)
    
    if spawner:IsBoss() then
        TurretBullet.CollisionDamage = TurretBullet.CollisionDamage * 1.5
        TurretBullet.Scale = TurretBullet.Scale * 1.5
    end
    
    local sprite = TurretBullet:GetSprite()
    sprite.Color = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B, sprite.Color.A, 100, 0, 0)
    
    pExodus:PlayTearSprite(TurretBullet, "Blood Tear.anm2")
end

function Exodus:pseudobulbarTurretUpdate()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        local level = game:GetLevel()
        local room = game:GetRoom()
        
        if data.IsPseudobulbarTurret then
            if player.FireDelay == player.MaxFireDelay then
                if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
                    Exodus:FireTurretBullet(entity.Position + Vector(-1 * entity.Size, 0) , Vector(-15, 0) * player.ShotSpeed + entity.Velocity, entity)
                elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
                    Exodus:FireTurretBullet(entity.Position + Vector(entity.Size, 0), Vector(15, 0) * player.ShotSpeed + entity.Velocity, entity)
                elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
                    Exodus:FireTurretBullet(entity.Position + Vector(0, -1 * entity.Size), Vector(0, -15) * player.ShotSpeed + entity.Velocity, entity)
                elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
                    Exodus:FireTurretBullet(entity.Position + Vector(0, entity.Size), Vector(0, 15) * player.ShotSpeed + entity.Velocity, entity)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.pseudobulbarTurretUpdate)

function Exodus:pseudobulbarAffectRender()
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(ItemId.PSEUDOBULBAR_AFFECT) then
        ItemVariables.PSEUDOBULBAR_AFFECT.Icon.Color = Color(1, 1, 1, 0.5, 0, 0, 0)
        ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Update()
        ItemVariables.PSEUDOBULBAR_AFFECT.Icon:LoadGraphics()
        
        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:GetData().IsPseudobulbarTurret then
                ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Render(game:GetRoom():WorldToScreenPosition(entity.Position + Vector(0, entity.Size)), NullVector, NullVector)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.pseudobulbarAffectRender)

function Exodus:pseudobulbarAffectUse()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() then
            entity:GetData().IsPseudobulbarTurret = true
        end
    end
    
    return true
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.pseudobulbarAffectUse, ItemId.PSEUDOBULBAR_AFFECT)

--<<<BIRDBATH>>>--
function Exodus:birdbathUse()
    local player = Isaac.GetPlayer(0)
    
    local bath = Isaac.Spawn(Entities.BIRDBATH.id, Entities.BIRDBATH.variant, 0, Isaac.GetFreeNearPosition(player.Position, 7), NullVector, player)
    bath:GetSprite():Play("Appear", true)
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.birdbathUse, ItemId.BIRDBATH)

function Exodus:birdbathEntityUpdate(bath)
    if bath.Variant == Entities.BIRDBATH.variant then
        local data = bath:GetData()
        
        bath.Velocity = NullVector
        bath.Friction = bath.Friction / 100
        
        if not bath:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            bath:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end

        if bath:GetSprite():IsFinished("Appear") then
            bath:GetSprite():Play("Idle", true)
        end

        local suckable = false

        for i, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() and entity:IsFlying() then
                suckable = true
                if entity.Velocity:Length() < 3 then
                    entity.Velocity = (bath.Position - entity.Position):Resized(3)
                else
                    entity.Velocity = (bath.Position - entity.Position):Resized(entity.Velocity:Length())
                end
                
                if entity.Position:DistanceSquared(bath.Position) < (entity.Size + bath.Size)^2 then
                    entity:AddPoison(EntityRef(bath), 30, entity.MaxHitPoints)
                end
            end
            if (entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_KNIFE) and entity:GetData().DontSplash == nil then
                if entity.Position:DistanceSquared(bath.Position) < (entity.Size + bath.Size)^2 then
                    local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, bath.Position + Vector(math.random(-8, 8), math.random(-16, -12)), Vector(0,0), player)
                    splash:GetSprite().Color = Color(1, 1, 1, 1, 0, math.random(150, 255), math.random(200, 255))
                    splash:GetSprite().Rotation = math.random(-30, 30)
                    entity:GetData().DontSplash = true
                    for v = 1, 8 do
                        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, bath.Position + Vector(0,-32), Vector(5,5):Rotated(math.random(360)), player)
                        tear:ToTear().Height = -21
                        tear:ToTear().FallingSpeed = 2
                        tear:ToTear().Flags = tear:ToTear().Flags + TearFlags.TEAR_POISON
                        tear:GetData().DontSplash = true
                        tear:GetSprite():Load("gfx/effects/Birdbath Tears.anm2", true)
                    end
                end
            end
        end

        if not suckable and bath:GetSprite():IsPlaying("Idle") and bath.FrameCount > 180 then
            bath:GetSprite():Play("Disappear", true)
        end

        if bath:GetSprite():IsFinished("Disappear") then
            bath:Remove()
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.birdbathEntityUpdate, Entities.BIRDBATH.id)

--<<<DROWNED CHARGER>>>--
function Exodus:drownedChargerUpdate(entity)        
    if entity.Variant == 1 then 
        if entity.FrameCount == 1 then
            entity.HitPoints = 13
            entity.MaxHitPoints = 14
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.drownedChargerUpdate, EntityType.ENTITY_CHARGER)

--<<<DANK DIP>>>--
function Exodus:makeDankDip(entity)
    local stage = game:GetLevel():GetAbsoluteStage()
    
    if (entity.Type == EntityType.ENTITY_SPIDER and entity.SpawnerType == EntityType.ENTITY_GLOBIN and entity.SpawnerVariant == 2) or 
        (entity.Type == Entities.DANK_DIP.id and rng:RandomInt(10) ~= 0 and entity.Variant ~= 2 and entity.Variant ~= Entities.DANK_DIP.variant and
        (stage == 5 or stage == 6) and entity.FrameCount == 1) then
        entity:ToNPC():Morph(Entities.DANK_DIP.id, Entities.DANK_DIP.variant, 0, -1)
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.makeDankDip)

function Exodus:dankDipUpdate(entity)
    local player = Isaac.GetPlayer(0)
    
    if entity.Variant == Entities.DANK_DIP.variant and rng:RandomInt(8) == 0 then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, entity.Position, NullVector, entity)
    end
    
    for i, creep in pairs(Isaac.GetRoomEntities()) do
        if creep.Type == EntityType.ENTITY_EFFECT and creep.Variant == EffectVariant.CREEP_BLACK and creep.SpawnerType == entity.Type and creep.SpawnerVariant == entity.Variant then
            if creep.FrameCount > 1 then
                creep.Visible = true
            end
            
            if player.Position:DistanceSquared(creep.Position) < 13^2 and not creep:IsDead() then
                player:AddSlowing(EntityRef(entity), 10, 0.5, Color(1, 1, 1, 1, 0, 0, 0))
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.dankDipUpdate, Entities.DANK_DIP.id)

function Exodus:dankDipEntityUpdate(dip)
    if dip.Variant == Isaac.GetEntityVariantByName("Dank Dip") then
        local player = Isaac.GetPlayer(0)
        local sprite = dip:GetSprite()
        
        if sprite:IsPlaying("Move") then
            dip.Velocity = dip.Velocity:Rotated(5):Resized(6) + (player.Position - dip.Position):Normalized()
        end
        
        if dip:IsDead() then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, dip.Position, NullVector, dip):ToEffect().Scale = 1.3
        end
        
        if dip.FrameCount == 1 then
            local rand = rng:RandomInt(3) + 1
            sprite:ReplaceSpritesheet(0, "gfx/monsters/Dank Dip " .. rand .. ".png")
            sprite:LoadGraphics()
        end
        
        if rng:RandomInt(10) == 0 then
          local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, dip.Position, NullVector, dip):ToEffect()
          creep.Scale = 0.7
          creep.Visible = false
          creep:SetTimeout(20)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.dankDipEntityUpdate, Entities.DANK_DIP.id)

--<<<PATRIARCH>>>--
function Exodus:patriarchUpdate(entity)
    local player = Isaac.GetPlayer(0)
    
    if entity.Variant == Entities.PATRIARCH.variant and entity.State == 8 and entity:GetData().HolyLightDirection == nil then
        entity:GetData().ShotFrom = entity.Position
        entity:GetData().HolyLightDirection = (player.Position - entity.Position):GetAngleDegrees() - 48
        entity:GetData().BeamNumber = -5
    end
    
    if entity:GetData().HolyLightDirection ~= nil and entity:GetData().BeamNumber >= 1 and entity:GetData().BeamNumber == math.floor(entity:GetData().BeamNumber) then
        local lightpos = entity:GetData().ShotFrom + Vector(48 * entity:GetData().BeamNumber, 48 * entity:GetData().BeamNumber):Rotated(entity:GetData().HolyLightDirection)
        entity:GetData().BeamNumber = entity:GetData().BeamNumber + 0.25
        Isaac.Spawn(1000, 19, 0, lightpos, Vector(0,0), nil)
        if entity:GetData().BeamNumber >= 8 then
            entity:GetData().HolyLightDirection = nil
            entity.State = 4
        end
    elseif entity:GetData().HolyLightDirection ~= nil then
        if entity:GetData().BeamNumber - 0.25 == math.floor(entity:GetData().BeamNumber) then
            entity:GetData().HolyLightDirection = (player.Position - entity.Position):GetAngleDegrees() - 48
        end
        entity:GetData().BeamNumber = entity:GetData().BeamNumber + 0.25
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.patriarchUpdate, Entities.PATRIARCH.id)

--<<<WINGLEADER>>>--
function Exodus:wingleaderUpdate(fly)
    local player = Isaac.GetPlayer(0)
    local data = fly:GetData()
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == Entities.WINGLEADER.id then
            if fly.Position:DistanceSquared(entity.Position) <= 16384 then
                if not data.lockedToParent then
                    data.lockedToParent = true
                    data.orbitAngle = math.floor((fly.Position - entity.Position):GetAngleDegrees())
                    fly.Velocity = Vector(0, 0)
                else
                    data.orbitAngle = data.orbitAngle + 5
                    if data.orbitAngle >= 360 then
                        data.orbitAngle = data.orbitAngle % 360
                    elseif data.orbitAngle < 0 then
                        data.orbitAngle = 360 - (data.orbitAngle % 360)
                    end
                    fly.Velocity = Vector(0, 0)
                    fly.Position = entity.Position + Vector(entity:GetData().orbitDistance, 0):Rotated(data.orbitAngle)
                end
            else
                fly.Velocity = fly.Velocity:Rotated(5):Resized(6) + (entity.Position - fly.Position):Normalized()
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.wingleaderUpdate, EntityType.ENTITY_ATTACKFLY)

function Exodus:wingleaderEntityUpdate(wingleader)
    local player = Isaac.GetPlayer(0)
    local sprite = wingleader:GetSprite()
    local data = wingleader:GetData()

    wingleader.Velocity = (player.Position - wingleader.Position):Resized(data.wingSpeed)
    if wingleader.FrameCount > 47 and data.Done == nil then
        sprite:Play("Idle", false)
        data.Done = true
    end
    if wingleader.Position.X < player.Position.X then
        sprite.FlipX = true
    else
        sprite.FlipX = false
    end
    if data.orbitDistance == 32 then
        if rng:RandomInt(120) == 1 then
            data.orbitDistance = 34
            data.orbitDirection = 1
            data.wingSpeed = 0
            sprite:Play("Puff", false)
        else
            sprite:Play("Idle", false)
        end
    else
        if data.orbitDirection == 1 then
            data.orbitDistance = data.orbitDistance + 2
            data.wingSpeed = data.wingSpeed + 0.02
            if data.orbitDistance > 128 then
                data.orbitDirection = 0
            elseif data.orbitDistance > 62 then
                sprite:Play("Idle", false)
            end
        else
            data.orbitDistance = data.orbitDistance - 1
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.wingleaderEntityUpdate, Entities.WINGLEADER.id)

function Exodus:wingleaderInit(wingleader)
    wingleader.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    wingleader.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    wingleader:GetData().orbitDistance = 32
    wingleader:GetData().orbitDirection = 0
    wingleader:GetData().wingSpeed = 1
end

Exodus:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Exodus.wingleaderInit, Entities.WINGLEADER.id)

--<<<BOTH SHROOMMEN>>>--
function Exodus:shroommanUpdate()
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PROJECTILE and entity.SpawnerType == Entities.DROWNED_SHROOMMAN.id and (entity.SpawnerVariant == Entities.DROWNED_SHROOMMAN.variant or entity.SpawnerVariant == Entities.SCARY_SHROOMMAN.variant) then
            entity:Remove()
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.shroommanUpdate)

function Exodus:shroommanEntityUpdate(shroom)
    local sprite = shroom:GetSprite()
    local data = shroom:GetData()
    local player = Isaac.GetPlayer(0)
    
    if not shroom:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
        shroom:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end
    
    if shroom.Variant == Entities.DROWNED_SHROOMMAN.variant then
        if shroom:IsDead() then
            Isaac.Spawn(EntityType.ENTITY_CHARGER, 1, 0, shroom.Position, NullVector, shroom)
        end
        
        if sprite:IsPlaying("Reveal") then
            if data.HasFarted ~= true then
                for i = 1, 3 do
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, shroom.Position + Vector(30, 0):Rotated(i * math.random(110,120)), NullVector, shroom):ToEffect()
                    creep.Scale = 2
                    creep:Update()
                    creep.Color = Color(0.4, 0.4, 1, 1, 100, 255, 255)
                end
                
                data.HasFarted = true
            end
        else
            data.HasFarted = false
        end
    elseif shroom.Variant == Entities.SCARY_SHROOMMAN.variant then
        if sprite:IsPlaying("Reveal") and not player:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            player.Velocity = ((player.Position - shroom.Position) / (player.Position:Distance(shroom.Position) * 2)) * 5 + player.Velocity
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.shroommanEntityUpdate, Entities.DROWNED_SHROOMMAN.id)

--<<<BOTH POISON ENEMIES>>>--
function Exodus:poisonEnemiesUpdate()
    local player = Isaac.GetPlayer(0)
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        
        if entity.Type == EntityType.ENTITY_MEMBRAIN and entity.FrameCount == 1 and rng:RandomInt(13) == 0 and entity.Variant ~= Entities.POISON_HEMISPHERE.variant then
            entity:Remove()
            
            Isaac.Spawn(EntityType.ENTITY_MEMBRAIN, Entities.POISON_MASTERMIND.variant, 0, entity.Position, NullVector, nil)
        end
        
        if entity.SpawnerVariant == Entities.POISON_HEMISPHERE.variant and entity.Type == EntityType.ENTITY_PROJECTILE then
            entity:Remove()
            
            if rng:RandomInt(100) <= 25 then
                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, entity.Position, entity.Velocity + (RandomVector() * 2), entity):ToTear()
                local sprite = tear:GetSprite()
                
                sprite:ReplaceSpritesheet(0, "gfx/Ipecac.png")
                sprite:LoadGraphics()
                
                tear.Height = -40
                tear.FallingAcceleration = 0.5
                tear.FallingSpeed = 0
                tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                tear:GetData().IsIpecac = true
                tear.SpawnerType = Entities.POISON_MASTERMIND.id
            end
        end
        
        if entity.Type == EntityType.ENTITY_TEAR and entity:IsDead() and data.IsIpecac and entity.SpawnerType == Entities.POISON_MASTERMIND.id then
            local boom = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, entity.Position, NullVector, entity)
            boom:SetColor(Color(0, 1, 0, 1, 0, 0, 0), -1, 1, false, false)
            
            if player.Position:DistanceSquared(entity.Position) < 70^2 then
                player:TakeDamage(2, 0, EntityRef(entity), 5)
            end
        end
        
        if entity.SpawnerType == Entities.POISON_MASTERMIND.id then
            if (entity.SpawnerVariant == Entities.POISON_HEMISPHERE.variant or entity.SpawnerVariant == Entities.POISON_MASTERMIND.variant) and entity.Type == EntityType.ENTITY_GUTS then
                entity:Remove()
            end
            
            if entity.SpawnerVariant == Entities.POISON_MASTERMIND.variant and entity.Type == EntityType.ENTITY_PROJECTILE then
                entity:Remove()
                
                if rng:RandomInt(100) <= 50 then
                  local tear = Isaac.Spawn(2, 0, 0, entity.Position, entity.Velocity + (RandomVector() * 2), entity):ToTear()
                  local sprite = tear:GetSprite()
                  
                  sprite:ReplaceSpritesheet(0,"gfx/Ipecac.png")
                  sprite:LoadGraphics()
                  
                  tear.Height = -40
                  tear.FallingAcceleration = 0.5
                  tear.FallingSpeed = 0
                  tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                  tear:GetData().IsIpecac = true
                  tear.SpawnerType = Entities.POISON_MASTERMIND.id
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.poisonEnemiesUpdate)

function Exodus:poisonEntityUpdate(entity)
    local sprite = entity:GetSprite()
    
    if entity.Variant == Entities.POISON_HEMISPHERE.variant then
        entity.SplatColor = Color(0, 0.9, 0, 1, 0, 0, 0)
        
        if entity:IsDead() then
            Isaac.Spawn(EntityType.ENTITY_POISON_MIND, 0, 0, entity.Position, NullVector, entity)
        end
        
        if entity:HasEntityFlags(EntityFlag.FLAG_POISON) and entity.HitPoints < entity.MaxHitPoints then
            entity.HitPoints = entity.HitPoints + 1
        end
        
        if rng:RandomInt(10) == 0 then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, entity.Position, NullVector, entity):ToEffect()
            creep:SetTimeout(100)
        end
    end
    
    if entity.Variant == Entities.POISON_MASTERMIND.variant then
        entity.SplatColor = Color(0, 0.9, 0, 1, 0, 0, 0)
        entity.Velocity = entity.Velocity * 0.9
        
        if entity:IsDead() then
            Isaac.Spawn(EntityType.ENTITY_POISON_MIND, 0, 0, entity.Position, NullVector, entity)
            Isaac.Spawn(EntityType.ENTITY_POISON_MIND, 0, 0, entity.Position, NullVector, entity)
        end 
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.poisonEntityUpdate, Entities.POISON_MASTERMIND.id)

--<<<BROOD>>>--
local broodbehaviors = {}

function broodbehaviors.init(npc, data)
    local sprite = npc:GetSprite()
    if sprite:IsFinished("Appear") then
        data.state = "preidle"
    end
end

function broodbehaviors.preidle(npc, data)
    local sprite = npc:GetSprite()
    data.counter = 0
    data.state = "idle"
    sprite:Play("Idle", true)
end

function broodbehaviors.idle(npc, data)
    data.counter = data.counter + 1
    npc.Velocity = npc.Velocity * 0.8
    if data.counter > 30 and math.random() > 1.5-data.counter/60 then
        data.state = "prewalk"
    end
end

function broodbehaviors.prewalk(npc, data)
    local sprite = npc:GetSprite()
    data.state = "walk"
    local ang = math.random()*math.pi*2
    data.dir = Vector(math.sin(ang), math.cos(ang))
    data.duration = math.random()*40+10
    data.counter = 0
    sprite:Play("Walk")
end

function broodbehaviors.walk(npc, data)
    data.counter = data.counter + 1

    npc.Velocity = npc.Velocity * 0.6 + data.dir * 2

    if data.counter > data.duration then
        data.counter = 0
        data.state = "preidle"
    end
end

function broodUpdate(_, npc)
    if not npc:Exists() or npc:IsDead() then return end

    local data = npc:GetData()
    local f = broodbehaviors[data.state]
    if not f then
        Isaac.DebugString("Missing brood behavior: "..data.state)
        return
    end

    if npc:HasMortalDamage() then
        local pos = npc.Position
        for i = 1, math.random(5)+7 do
            EntityNPC.ThrowSpider(pos, npc, pos+RandomVector()*100*(math.random()*0.7+0.3), false, 0)
        end
        return
    end

    f(npc, data)
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, broodUpdate, Entities.BROOD.id)

function broodInit(_, npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()

    data.state = "init"

    sprite:Play("Appear", true)
end

Exodus:AddCallback(ModCallbacks.MC_POST_NPC_INIT, broodInit, Entities.BROOD.id)

--<<<CLOSTER>>>--
function Exodus:closterEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if entity.FrameCount <= 1 then
        sprite:Play("Appear", false)
        entity.State = 0
        entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end
    
    if sprite:IsFinished("Appear") then
        entity.Pathfinder:MoveRandomly(false)
        sprite:Play("Idle", false)
    end
    
    if sprite:IsFinished("Idle") then
        entity.Pathfinder:Reset()
        entity.Velocity = Vector(0,0)
        sprite:Play("Attack", false)
    end
    
    if sprite:IsEventTriggered("Stomp") then
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS ,1,0,false,0.7)
        
        if math.random(2) == 1 then
            for i = 1, 6 do 
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, entity.Position + Vector(math.random(-20, 20), math.random(-20, 20)), Vector(0, 0), entity):ToEffect()
                creep.Scale = creep.Scale * 1.2
            end
            
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, entity.Position , Vector(0, 0), entity):ToEffect()
            creep.Scale = creep.Scale * 1.2
        else
            Isaac.Spawn(Entities.DANK_DIP.id, Entities.DANK_DIP.variant, 0, entity.Position + Vector(math.random(-2, 2), math.random(-2, 2)), Vector(0, 0), entity)
        end
        
        sprite:Play("Idle", false) 
        entity.Pathfinder:MoveRandomly(false)
    end
    
    entity.Velocity = entity.Velocity:Resized(math.random(1, 2))
    
    if entity:IsDead() then
        for i = 1, 2 do
            Isaac.Spawn(EntityType.ENTITY_CLOTTY, 1, 0, entity.Position + Vector(math.random(-2, 2), math.random(-2, 2)), Vector(0, 0), entity)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.closterEntityUpdate, Entities.CLOSTER.id)

--<<<HALFBLIND>>>--
function Exodus:halfblindTakeDamage(target, amount, flag, source, cdframes)
    local data = target:GetData()
    
    if source.Type == EntityType.ENTITY_TEAR then -- Is tear
        if data.FacingDirection == Direction.RIGHT then -- Block shots from the right
            if source.Position.X > target.Position.X then
                return false
            end
        elseif data.FacingDirection == Direction.LEFT then -- Block shots from the left
            if source.Position.X < target.Position.X then
                return false
            end
        elseif data.FacingDirection == Direction.UP then -- Block shots from up
            if source.Position.Y < target.Position.Y then
                return false
            end
        elseif data.FacingDirection == Direction.DOWN then -- Block shots from down
            if source.Position.Y > target.Position.Y then
                return false
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.halfblindTakeDamage, Entities.HALFBLIND.id)

function Exodus:halfblindEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    local room = Game():GetRoom()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if ent.Type == EntityType.ENTITY_TEAR then
            ent:GetData().LastVelocity = entity.Velocity
        end
    end
    
    if sprite:IsEventTriggered("Decelerate") then -- Decelerate
        entity.Velocity = entity.Velocity * 0.8
    elseif sprite:IsEventTriggered("Stop") then -- Stop Velocity
        entity.Velocity = Vector(0,0)
    elseif sprite:IsEventTriggered("Brimstone Up") then -- Shoot up
        EntityLaser.ShootAngle(1, entity.Position, -90, 30, Vector(0, -30), entity)
    elseif sprite:IsEventTriggered("Brimstone Down") then -- Shoot down
        EntityLaser.ShootAngle(1, entity.Position, 90, 30, Vector(0, -30), entity)
    elseif sprite:IsEventTriggered("Brimstone Hori") then -- Shoot horizontal
        if sprite.FlipX == false then
            EntityLaser.ShootAngle(1, entity.Position, 180, 30, Vector(0, -30), entity)
        else
            EntityLaser.ShootAngle(1, entity.Position, 0, 30, Vector(0, -30), entity)
        end
    end -- Brimstone other event
    
    if entity.FrameCount <=1 then
        sprite:Play("Appear", false)
        data.DirectionMultiplier = math.random(5)
        data.AttackCooldown = 0
    end
    
    if entity.State == 0 then -- Move around
        if data.AttackCooldown > 0 then
            data.AttackCooldown = data.AttackCooldown - 1
        end
        
        if math.random(50) == 1 or entity:CollidesWithGrid() then
            data.DirectionMultiplier = math.random(5)
        end
        
        entity.Velocity = Vector.FromAngle(data.DirectionMultiplier * 90):Resized(7)
        
        if entity.Velocity.Y > 0 then
            entity:AnimWalkFrame("Hori", "Down", 0)
        elseif entity.Velocity.Y < 0 then
            entity:AnimWalkFrame("Hori", "Up", 0)
        end
        
        if data.AttackCooldown == 0 then
            if sprite:IsPlaying("Hori") and sprite.FlipX == false then -- Facing Right
                if target.Position.X < entity.Position.X and target.Position.Y - 10 < entity.Position.Y and target.Position.Y + 10 > entity.Position.Y then
                    entity.State = 2
                end
                
                data.FacingDirection = Direction.RIGHT
            elseif sprite:IsPlaying("Hori") and sprite.FlipX == true then -- Facing Left
                if target.Position.X > entity.Position.X and target.Position.Y - 10 < entity.Position.Y and target.Position.Y + 10 > entity.Position.Y then
                    entity.State = 3
                end
                
                data.FacingDirection = Direction.LEFT
            elseif sprite:IsPlaying("Down") then
                if target.Position.Y < entity.Position.Y and target.Position.X - 10 < entity.Position.X and target.Position.X + 10 > entity.Position.X then -- Facing Down
                    entity.State = 4
                end
                
                data.FacingDirection = Direction.DOWN
            elseif sprite:IsPlaying("Up") then
                if target.Position.Y > entity.Position.Y and target.Position.X - 10 < entity.Position.X and target.Position.X + 10 > entity.Position.X then -- Facing Up
                    entity.State = 5
                end
                
                data.FacingDirection = Direction.UP
            end
        end
    elseif entity.State == 2 then -- Right Facing Attack
        sprite:Play("ShootHori", false)
        
        if sprite:IsFinished("ShootHori") then
            entity.State = 0
        end
        
        data.AttackCooldown = 60
    elseif entity.State == 3 then -- Left Facing Attack
        sprite:Play("ShootHori", false)
        sprite.FlipX = true
        
        if sprite:IsFinished("ShootHori") then
            entity.State = 0
        end
        
        data.AttackCooldown = 60
    elseif entity.State == 4 then -- Upwards Attack
        sprite:Play("ShootDown", false)
        
        if sprite:IsFinished("ShootDown") then
            entity.State = 0
        end
        
        data.AttackCooldown = 60
    elseif entity.State == 5 then -- Downwards Attack
        sprite:Play("ShootUp", false)
        
        if sprite:IsFinished("ShootUp") then
            entity.State = 0
        end
        
        data.AttackCooldown = 60
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.halfblindEntityUpdate, Entities.HALFBLIND.id)

--<<<HEADCASE>>>--
function Exodus:lobbedShotCollision()
    local player = Isaac.GetPlayer(0)
    
    if EntityVariables.HEADCASE.DoLobbed then
        for i, entity in pairs(Isaac.GetRoomEntities()) do 
            if entity.Type == EntityType.ENTITY_TEAR and entity:GetData().IsExodusLobbed == true then
                if entity.Position:DistanceSquared(player.Position) < 18^2 and entity:ToTear().Height < 5 then
                    entity:Die()
                    player:TakeDamage(1, 0, EntityRef(entity), 0)
                end
                if entity:ToTear().Height < 1 then
                    EntityVariables.HEADCASE.DoLobbed = false
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.lobbedShotCollision)

function Exodus:headcaseEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    local room = Game():GetRoom()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if entity.FrameCount <= 1 then
        sprite:Play("Appear", false)
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
    
    if sprite:IsEventTriggered("Vulnerable") then
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    elseif sprite:IsEventTriggered("Invulnerable") then
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    elseif sprite:IsEventTriggered("Decel") then
        entity.Velocity = entity.Velocity * 0.8
    elseif sprite:IsEventTriggered("Stop") then
        entity.Velocity = Vector(0,0)
    elseif sprite:IsEventTriggered("Stomp") then
        if entity.Position:Distance(player.Position) < 20 then
            player:TakeDamage(2, 0, EntityRef(entity), 30)
        end
        
        for i = 1, math.random(4) do
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, entity.Position + Vector(math.random(-5, 5), math.random(-5, 5)), Vector(0, 0), entity)
        end
        
        EntityVariables.HEADCASE.DoLobbed = true
        
        for i = 0, 7 do
            local boom = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, entity.Position, Vector.FromAngle(i * 45):Resized(10), entity)
            boom:ToTear().FallingSpeed = -10
            boom:ToTear().FallingAcceleration = 1
            boom:GetData().IsExodusLobbed = true
            boom.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end
        
        sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND , 4, 0, false, 1)
    end
    
    if entity.State == 0 then
        if entity.FrameCount > 1 then
            sprite:Play("Idle", false)
        end
        
        entity.Velocity = (target.Position - entity.Position):Resized(30)
        
        if entity.Position:DistanceSquared(target.Position) < 20^2 then
            entity.State = 2
            sfx:Play(SoundEffect.SOUND_BOSS_GURGLE_ROAR , 2, 0, false, 0.8)
        end
    elseif entity.State == 2 then
        sprite:Play("Stomp", false)
        
        if sprite:IsFinished("Stomp") then
            entity.State = 0
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.headcaseEntityUpdate, Entities.HEADCASE.id)

--<<<HOLLOWHEAD>>>--
function Exodus:hollowheadEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if data.TelegraphLaser ~= nil then
        if data.StopFollowing ~= true then
            data.TelegraphLaser.Angle = angle
        end
    end
    
    if data.TelegraphLaser1 ~= nil then
        if data.StopFollowing ~= true then
            data.TelegraphLaser1.Angle = angle + 180
        end
    end
    
    if sprite:IsEventTriggered("Decelerate") then
        entity.Velocity = entity.Velocity * 0.8
    elseif sprite:IsEventTriggered("Telegraph") then
        local telegraph = EntityLaser.ShootAngle(2, entity.Position, angle, 34, Vector(0, -40), entity)
        telegraph.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        telegraph.Color = Color(telegraph.Color.R, telegraph.Color.G, telegraph.Color.B, 0.7, 0, 0, 100)
        telegraph:SetMaxDistance(80)
        
        local telegraph1 = EntityLaser.ShootAngle(2, entity.Position, angle + 180, 34, Vector(0, -40), entity)
        telegraph1.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        telegraph1.Color = Color(telegraph1.Color.R, telegraph1.Color.G, telegraph1.Color.B, 0.7, 0, 0, 100)
        telegraph1:SetMaxDistance(80)
        data.TelegraphLaser = telegraph
        data.TelegraphLaser1 = telegraph1
    elseif sprite:IsEventTriggered("Stop Follow") then
        data.StopFollowing = true
    elseif sprite:IsEventTriggered("Shoot") then
        sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND , 2, 0, false, 0.8)
        
        local real_laser = EntityLaser.ShootAngle(9, entity.Position, data.TelegraphLaser:ToLaser().AngleDegrees, 13, Vector(0, -45), entity)
        local real_laser1 = EntityLaser.ShootAngle(9, entity.Position, data.TelegraphLaser:ToLaser().AngleDegrees + 180, 13, Vector(0, -45), entity)
        real_laser.Color = Color(real_laser.Color.R, real_laser.Color.G, real_laser.Color.B, 1, 0, 0, 70)
        real_laser1.Color = Color(real_laser1.Color.R, real_laser1.Color.G, real_laser1.Color.B, 1, 0, 0, 70)
    end
    
    if entity.State == 0 then -- Follow (Inbetween attacks)
        entity:AnimWalkFrame("Fly", "Fly", 0)
        data.StopFollowing = false
        
        if entity.Position:Distance(target.Position) > 100 then
            entity.Velocity = (target.Position - entity.Position):Resized(5)
        else
            entity.Velocity = (target.Position - entity.Position):Resized(2)
        end
        
        if math.random(100) == 1 then
            entity.State = 2
        end
    elseif entity.State == 2 then -- Attack
        if entity.Position.X < target.Position.X then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        
        sprite:Play("Telegraph and Shoot", false)
        
        if sprite:IsFinished("Telegraph and Shoot") then
            entity.State = 3
        end
    elseif entity.State == 3 then
        sprite:Play("Telegraph and Shoot", false)
        
        if sprite:IsFinished("Telegraph and Shoot") then
            entity.State = 0
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.hollowheadEntityUpdate, Entities.HOLLOWHEAD.id)

--<<<WOMBSHROOM>>>--
function Exodus:wombshroomEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if entity.FrameCount <= 1 then
        data.State0Frames = 0
        data.State2Frames = 0
        data.StartShroomPosition = entity.Position
    end
    
    entity.Velocity = Vector(0,0)
    entity.Position = data.StartShroomPosition
    
    if sprite:IsEventTriggered("Shoot") then
        Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, entity.Position, Vector.FromAngle(data.ShotAngle * 45 + 90):Resized(10), entity)
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
        data.ShotAngle = data.ShotAngle + 1
    elseif sprite:IsEventTriggered("Splash") then
        for i = 0, 8 do
            Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, entity.Position, Vector.FromAngle(i * 45 + 90):Resized(10), entity)
        end
        
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 2, 0, false, 0.8)
    end
    if entity.State == 0 then -- Hiding
        data.ShotAngle = 0
        sprite:Play("Blocking", false)
        data.State0Frames = data.State0Frames + 1
        
        if data.State0Frames == 10 then
            entity.State = 2
            data.State0Frames = 0
        end
    elseif entity.State == 2 then -- Attacking
        data.State2Frames = data.State2Frames + 1
        
        if data.State2Frames == 1 then
            sprite:Play("Reveal", false)
        end
        
        if sprite:IsFinished("Reveal") then
            sprite:Play("Hide", false)
        end
        
        if sprite:IsFinished("Hide") then
            entity.State = 0
            data.State2Frames = 0
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.wombshroomEntityUpdate, Entities.WOMBSHROOM.id)

--<<<CARRION PRINCE>>>--
function Exodus:carrionPrinceEntityUpdate(entity)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    local room = game:GetRoom()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()

    if entity.FrameCount <= 1 then
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        data.DirectionMultiplier = math.random(5)
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        entity:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
        entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.BombTimer = -1
        data.ChargeCooldown = 0
    end
    
    if entity.State >= 7 then
        entity.Velocity = Vector(0, 0)
        
        if data.BombTimer > 0 then
            data.BombTimer = data.BombTimer - 1
        end
        
        if data.BombTimer == 0 then
            Isaac.Explode(entity.Position, player, 60)
            entity:GetData().Butt:TakeDamage(60, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
            data.BombTimer = -1
            entity.State = 2
        end
    end
    
    if entity.State >= 3 then
        for i, ent in pairs(Isaac.GetRoomEntities()) do
            if ent:ToBomb() then
                if ent.Position:DistanceSquared(entity.Position) < (entity.Size + ent.Size)^2 then
                    entity.State = entity.State + 4
                    data.BombTimer = 15
                    ent:Remove()
                end
            end
        end
    end
    
    if entity.State == 0 then -- Spawn Stuff
        if entity:GetData().MainNPC == nil then
            local Body1 = Isaac.Spawn(Entities.CARRION_PRINCE.id, 0, 0, entity.Position, Vector(0,0), entity)
            Body1.Parent = entity
            Body1:GetData().IsBody = true
            Body1:GetData().MainNPC = entity
            
            local Body2 = Isaac.Spawn(Entities.CARRION_PRINCE.id, 0, 0, entity.Position, Vector(0,0), entity)
            Body2.Parent = Body1
            Body2:GetData().IsBody = true
            Body2:GetData().MainNPC = entity
            
            local Body3 = Isaac.Spawn(Entities.CARRION_PRINCE.id, 0, 0, entity.Position, Vector(0,0), entity)
            Body3.Parent = Body2
            Body3:GetData().IsBody = true
            Body3:GetData().MainNPC = entity
            
            local Butt = Isaac.Spawn(Entities.CARRION_PRINCE.id, 0, 0, entity.Position, Vector(0,0), entity)
            Butt.Parent = Body3
            Butt:GetData().IsButt = true
            Butt:GetData().MainNPC = entity
            entity:GetData().IsHead = true
            entity:GetData().Butt = Butt
            entity.State = 2
        else
            entity.State = 2
        end
    elseif entity.State == 2 then -- Move Around
        if entity:GetData().IsHead ~= true then
            if entity.Position:DistanceSquared(entity.Parent.Position) > 30^2 then
                entity.Position = entity.Parent.Position + (entity.Position - entity.Parent.Position):Resized(30)
            end
        else
            if entity.Velocity.Y > 0 then
                entity:AnimWalkFrame("WalkHeadHori", "WalkHeadDown", 0)
            elseif entity.Velocity.Y < 0 then
                entity:AnimWalkFrame("WalkHeadHori", "WalkHeadUp", 0)
            end
            
            if math.random(50) == 1 or entity:CollidesWithGrid() then
                data.DirectionMultiplier = math.random(5)
            end
            
            entity.Velocity = Vector.FromAngle(data.DirectionMultiplier * 90):Resized(7)
            
            local dirAngle = (target.Position - entity.Position):GetAngleDegrees()
            
            if entity:GetData().ChargeCooldown > 0 then
                entity:GetData().ChargeCooldown = entity:GetData().ChargeCooldown - 1
            end
            
            if dirAngle > 170 and dirAngle < 190 and room:CheckLine(entity.Position, target.Position, 0, 10, false, false) and entity:GetData().ChargeCooldown == 0 then -- Facing Left
                entity.State = 3
                sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_2, 1, 0, false, 1)
                entity:GetData().ChargeCooldown = 300
            elseif dirAngle > -10 and dirAngle < 10 and room:CheckLine(entity.Position, target.Position, 0, 10, false, false) and entity:GetData().ChargeCooldown == 0 then -- Facing Right
                entity.State = 4
                sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_1, 1, 0, false, 1)
                entity:GetData().ChargeCooldown = 300
            elseif dirAngle < -80 and dirAngle > -100 and room:CheckLine(entity.Position, target.Position, 0, 10, false, false) and entity:GetData().ChargeCooldown == 0 then -- Facing Up
                entity.State = 5
                sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0, 1, 0, false, 1)
                entity:GetData().ChargeCooldown = 300
            elseif dirAngle > 80 and dirAngle < 100 and room:CheckLine(entity.Position, target.Position, 0, 10, false, false) and entity:GetData().ChargeCooldown == 0 then -- Facing Down
                entity.State = 6
                sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0, 1, 0, false, 1)
                entity:GetData().ChargeCooldown = 300
            end
        end
        
        if data.IsBody then
            if math.abs(data.MainNPC.Velocity.Y) > math.abs(data.MainNPC.Velocity.X) then
                sprite:Play("WalkBodyVert", false)
            else    
                sprite:Play("WalkBodyHori", false)
                
                if data.MainNPC.Velocity.X > 0 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
            end
        elseif data.IsButt then
            if math.abs(data.MainNPC.Velocity.Y) > math.abs(data.MainNPC.Velocity.X) then
                if data.MainNPC.Velocity.Y > 0 then
                    sprite:Play("WalkButtDown", false)
                else
                    sprite:Play("WalkButtUp", false)
                end
            else    
                if data.MainNPC.Velocity.X > 0 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
                
                sprite:Play("WalkButtHori", false)
            end
        end
    elseif entity.State == 3 then -- Left
        sprite:Play("AngryHeadHori", false)
        sprite.FlipX = true
        entity.Velocity = Vector.FromAngle(180):Resized(10)
        
        if entity:CollidesWithGrid() then
            entity.State = 2
        end
    elseif entity.State == 4 then -- Right
        sprite:Play("AngryHeadHori", false)
        sprite.FlipX = false
        entity.Velocity = Vector.FromAngle(0):Resized(10)
        
        if entity:CollidesWithGrid() then
            entity.State = 2
        end
    elseif entity.State == 5 then -- Up
        sprite:Play("AngryHeadUp", false)
        entity.Velocity = Vector.FromAngle(-90):Resized(10)
        
        if entity:CollidesWithGrid() then
            entity.State = 2
        end
    elseif entity.State == 6 then -- Down
        sprite:Play("AngryHeadDown", false)
        entity.Velocity = Vector.FromAngle(90):Resized(10)
        
        if entity:CollidesWithGrid() then
            entity.State = 2
        end
    elseif entity.State == 7 then -- Left Eat Bomb
        sprite:Play("SadHeadHori", false)
        sprite.FlipX = true
    elseif entity.State == 8 then -- Right Eat Bomb
        sprite:Play("SadHeadHori", false)
        sprite.FlipX = false
    elseif entity.State == 9 then -- Up Eat Bomb
        sprite:Play("SadHeadUp", false)
    elseif entity.State == 10 then -- Down Eat Bomb
        sprite:Play("SadHeadDown", false)
    end
    
    if entity:IsDead() then
        if entity.Parent ~= nil then
            entity.Parent:Die()
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.carrionPrinceEntityUpdate, Entities.CARRION_PRINCE.id)

function Exodus:carrionPrinceTakeDamage(target, amount, flag, source, cd)
    if target:GetData().IsButt ~= true then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.carrionPrinceTakeDamage, Entities.CARRION_PRINCE.id)

--<<<LITHOPEDION>>>--
function Exodus:lithopedionEntityUpdate(entity)
    local player = Isaac.GetPlayer(0)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local target = entity:GetPlayerTarget()
    
    local angle = (target.Position - entity.Position):GetAngleDegrees()
    
    if entity.FrameCount <= 1 then
        sprite:Play("Appear", false)
        entity.State = 0
        entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    end
    
    if sprite:IsFinished("Appear") then
        entity.Pathfinder:MoveRandomly(false)
        sprite:Play("Idle", false)
    end
    
    if sprite:IsFinished("Idle") then
        entity.Pathfinder:Reset()
        entity.Velocity = Vector(0, 0)
        sprite:Play("Attack", false)
    end
    
    if sprite:IsEventTriggered("Stomp") then
        sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS , 2, 0, false, 0.8)
        
        if math.random(2) == 1 then
            local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, entity.Position, Vector(0,0), entity)
            shockwave:ToEffect():SetRadii(20, 100)
        else
            local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE_RANDOM , 0, entity.Position, Vector(0,0), entity)
            shockwave:ToEffect():SetTimeout(200)
        end
        
        sprite:Play("Idle", false) 
        entity.Pathfinder:MoveRandomly(false)
    end
    
    entity.Velocity = entity.Velocity:Resized(math.random(1, 2))
    
    if entity:IsDead() then
        for i = 1, 2 do
            Isaac.Spawn(Entities.BLOCKAGE.id, 0, 0, entity.Position + Vector(math.random(-2, 2), math.random(-2, 2)), Vector(0, 0), entity)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.lithopedionEntityUpdate, Entities.LITHOPEDION.id)

function Exodus:lithopedionTakeDamage(target, amount, flag, source, cd)
    if source.Type == 0 and source.Variant == 0 and flag == 4 then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.lithopedionTakeDamage, Entities.LITHOPEDION.id)

--<<<FLESH DEATH'S EYE>>>--
function Exodus:fleshDeathsEyeEntityUpdate(entity)
    if entity.Variant == Entities.FLESH_DEATHS_EYE.variant then
        local player = Isaac.GetPlayer(0)
        local data = entity:GetData()
        local sprite = entity:GetSprite()
        local target = entity:GetPlayerTarget()
        
        local angle = (target.Position - entity.Position):GetAngleDegrees()
        
        if sprite:IsEventTriggered("Shoot") then
            sfx:Play(SoundEffect.SOUND_GURG_BARF , 1, 0, false, 1)
            Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, entity.Position, Vector.FromAngle(angle + 10):Resized(10), entity)
            Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, entity.Position, Vector.FromAngle(angle - 10):Resized(10), entity)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.fleshDeathsEyeEntityUpdate, Entities.FLESH_DEATHS_EYE.id)

function Exodus:fleshDeathsEyeDeath()
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == Entities.FLESH_DEATHS_EYE.id and entity.Variant == Entities.FLESH_DEATHS_EYE.variant and entity:HasMortalDamage() then
            for v = 0, 7 do
                Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, entity.Position, Vector.FromAngle(v * 45):Resized(10), entity)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.fleshDeathsEyeDeath)

--<<<DEATH'S EYE>>>--
function Exodus:deathsEyeEntityUpdate(entity)
    if entity.Variant == Entities.DEATHS_EYE.variant then
        local player = Isaac.GetPlayer(0)
        local data = entity:GetData()
        local sprite = entity:GetSprite()
        local target = entity:GetPlayerTarget()
        
        local angle = (target.Position - entity.Position):GetAngleDegrees()
        
        if sprite:IsEventTriggered("Shoot") then
            sfx:Play(SoundEffect.SOUND_FIRE_RUSH , 1, 0, false, 1)
            Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, entity.Position, Vector.FromAngle(angle):Resized(10), entity)
        end
        
        entity.Velocity = entity.Velocity:Resized(5)
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.deathsEyeEntityUpdate, Entities.DEATHS_EYE.id)

function Exodus:deathsEyeTakeDamage(target, amount, flag, source, cdframes)
    if target.Variant == Entities.DEATHS_EYE.variant then
        return false
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.deathsEyeTakeDamage, Entities.DEATHS_EYE.id)

--<<<LOVELY FLIES>>>--
local FLIES = {
    [Entities.LOVELY_FLY.variant] = { 
        turnFactor = 1, --This value influences how fast the fly will turn towards the player when it can't find a mate
        velocityFactor = 1, --This value influences how fast the fly will move towards the player when it can't find a mate
        parentOffset = Vector(50, 0), --How far away the fly will orbit from the enemy, a normal room is 500x260 units
        orbitDamage = 0, --This value tells the game how much collision damage the fly should deal to the player when it's orbiting or finding a mate
        noMateDamage = 0, --This value tells the game how much collision damage the fly should deal to the player when it can't find a mate
        maxHealing = 15, --How much the Lovely Fly heals base damage tear deals 3.5 damage
        healDelay = 60, --How long between heals, in ticks, 30 ticks per second,
        healPercentage = 20, --The percentage of it's max health an enemy will gain when the Lovely Fly heals it
        healColour = Color(1, 1, 1, 1, 50, 50, 50), --The base colour that enemies will be set to when this fly heals them
    },
    
    [Entities.SOULFUL_FLY.variant] = { 
        turnFactor = 1, --This value influences how fast the fly will turn towards the player when it can't find a mate
        velocityFactor = 1, --This value influences how fast the fly will move towards the player when it can't find a mate
        parentOffset = Vector(50, 0), --How far away the fly will orbit from the enemy, a normal room is 500x260 units
        orbitDamage = 0, --This value tells the game how much collision damage the fly should deal to the player when it's orbiting or finding a mate
        noMateDamage = 0, --This value tells the game how much collision damage the fly should deal to the player when it can't find a mate
        baseColour = Color(1, 1, 1, 1, 50, 50, 50), --The base colour that enemies will be set to while this fly is on them
        invincibilityColour = Color(1, 1, 1, 1, 125, 150, 200) --The colour that enemies will flash when this fly prevents damage
    },
    
    [Entities.HATEFUL_FLY.variant] = { 
        turnFactor = 1, --This value influences how fast the fly will turn towards the player when it can't find a mate
        velocityFactor = 8, --This value influences how fast the fly will move towards the player when it can't find a mate
        parentOffset = Vector(50, 0), --How far away the fly will orbit from the enemy, a normal room is 500x260 units,
        orbitDamage = 0, --This value tells the game how much collision damage the fly should deal to the player when it's orbiting or finding a mate
        noMateDamage = 1, --This value tells the game how much collision damage the fly should deal to the player when it can't find a mate
        rotationAmount = 5, --This value influences by how many degrees the fly will rotate at a time to be pointed towards the player
        baseColour = Color(0.6, 0.6, 0.6, 1, 0, 0, 0), --The base colour that enemies will be set to while this fly is on them
    },
    
    [Entities.HATEFUL_FLY_GHOST.variant] = { 
        turnFactor = 0.5, --This value influences how fast the fly will turn towards the player when it can't find a mate
        velocityFactor = 6, --This value influences how fast the fly will move towards the player when it can't find a mate
        baseColour = Color(0.6, 0.5, 0.5, 1, 0, 0, 0), --The base colour that enemies will be set to while this fly is on them
    }
}

function Exodus:lovelyFlyLogic(fly)
    local data = fly:GetData()
    local sprite = fly:GetSprite()
    local player = Isaac.GetPlayer(0)
    local flyStats = FLIES[fly.Variant]
    local noMate = "Alone"
    
    --[[
    This code covers the function of every fly except the Hateful Fly Ghost such as finding a parent enemy, lack of enemies, etc.
    ]]
    if fly.Variant ~= Entities.HATEFUL_FLY_GHOST.variant then
        if fly.FrameCount <= 1 then
            fly.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            fly.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            
            data.parentOffset = flyStats.parentOffset
            data.orbitAngle = 0
            data.lockedToParent = false
            data.parentEnemy = nil
            
            sprite:Play("Looking for a mate", true)
        end
        
        if not data.parentEnemy or data.parentEnemy == noMate then
            local nearEnemy
            local checkDist = math.huge
            
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                if entity:IsActiveEnemy(false) and entity.Index ~= fly.Index and entity.InitSeed ~= fly.InitSeed then
                    local newDist = fly.Position:DistanceSquared(entity.Position)
                    local entityData = entity:GetData()
                    
                    if newDist < checkDist then
                        local ignore = false
                        
                        if fly.Variant == Entities.LOVELY_FLY.variant and entity.Type == fly.Type and not ignore then
                            ignore = true
                        end
                        
                        if (fly.Variant == Entities.LOVELY_FLY.variant or Entities.SOULFUL_FLY.variant) and not ignore then
                            if entityData.childFlies and #entityData.childFlies >= 3 then
                                ignore = true
                            end
                        end
                        
                        if not ignore then
                            local recursion = true
                            local checkData = entityData
                            
                            while recursion do
                                if checkData.parentEnemy and checkData.parentEnemy ~= noMate then
                                    if checkData.parentEnemy.Index == fly.Index and checkData.parentEnemy.InitSeed == fly.InitSeed then
                                        recursion = false
                                        ignore = true
                                    else
                                        checkData = checkData.parentEnemy:GetData()
                                    end
                                else
                                    recursion = false
                                end
                            end
                        end
                        
                        if entityData.parentEnemy and entityData.parentEnemy.Index == fly.Index and entityData.parentEnemy.InitSeed == fly.InitSeed and not ignore then
                            ignore = true
                        end
                        
                        if fly.Variant == Entities.HATEFUL_FLY.variant and not ignore then
                            if entityData.hasHatefulFly then
                                ignore = true
                            end
                        end
                        
                        if not ignore then
                            nearEnemy = entity
                            checkDist = newDist
                        end
                    end
                end
            end
            
            if nearEnemy then
                if not sprite:IsPlaying("Looking for a mate") then
                    sprite:Play("Looking for a mate", true)
                end
                
                local entityData = nearEnemy:GetData()
                data.parentEnemy = nearEnemy
                
                if fly.Variant ~= Entities.HATEFUL_FLY.variant then
                    if entityData.childFlies then
                        table.insert(entityData.childFlies, fly)
                    else
                        entityData.childFlies = { fly }
                    end
                else
                    entityData.hasHatefulFly = true
                end
            else
                data.parentEnemy = noMate
            end
        else
            if data.parentEnemy:IsDead() or not data.parentEnemy:Exists() then
                data.parentEnemy = nil
                data.lockedToParent = false
            else
                if not data.lockedToParent then
                    fly.Velocity = (fly.Velocity + ((data.parentEnemy.Position - fly.Position):Normalized())):Normalized() * 5
                    
                    if fly.Position:DistanceSquared(data.parentEnemy.Position) <= 5625 then
                        data.lockedToParent = true
                        data.orbitAngle = math.floor((fly.Position - data.parentEnemy.Position):GetAngleDegrees())
                        fly.Velocity = Vector(0, 0)
                        
                        sprite:Play("Found a mate")
                    end
                 else
                    if fly.Position:DistanceSquared(data.parentEnemy.Position) > 6400 then
                        data.lockedToParent = false
                    else
                        local parentData = data.parentEnemy:GetData()
                        
                        if fly.Variant ~= Entities.HATEFUL_FLY.variant then
                            local index = 1
                            
                            for u, childEnt in ipairs(parentData.childFlies) do
                                if childEnt.Index == fly.Index and childEnt.InitSeed == fly.InitSeed then
                                    index = u
                                end
                            end
                            
                            if index == 1 then
                                data.orbitAngle = data.orbitAngle + 3
                            else
                                local targetAngle = (parentData.childFlies[index - 1]:GetData().orbitAngle + (360 / #parentData.childFlies)) % 360
                            
                                if math.abs(data.orbitAngle - targetAngle) > 6 or math.abs(data.orbitAngle - targetAngle) > 354 then
                                    data.orbitAngle = data.orbitAngle + 6
                                else
                                    data.orbitAngle = targetAngle
                                end
                            end
                            
                            if data.orbitAngle >= 360 then
                                data.orbitAngle = data.orbitAngle % 360
                            elseif data.orbitAngle < 0 then
                                data.orbitAngle = 360 - (data.orbitAngle % 360)
                            end
                            
                            fly.Velocity = Vector(0, 0)
                            fly.Position = data.parentEnemy.Position + data.parentOffset:Rotated(data.orbitAngle)
                        end
                    end
                end
            end
        end
        
        if data.parentEnemy == noMate then
            if not sprite:IsPlaying("I have no mate") then
                sprite:Play("I have no mate", true)
            end
            
            local turnFactor = flyStats.turnFactor
            local velFactor = math.min(flyStats.velocityFactor * player.MoveSpeed, flyStats.velocityFactor)
            
            fly.CollisionDamage = flyStats.noMateDamage
            fly.Velocity = (fly.Velocity + ((player.Position - fly.Position):Normalized() * turnFactor)):Normalized() * velFactor
        else
            fly.CollisionDamage = flyStats.orbitDamage
        end
    end
    
    --[[
    This code covers the special abilities for the Lovely Fly
    ]]
    if fly.Variant == Entities.LOVELY_FLY.variant then
        if fly.FrameCount <= 1 then
            data.healTimer = flyStats.healDelay
        end
        
        if data.parentEnemy and data.parentEnemy ~= noMate then
            if not data.parentEnemy:IsDead() and data.parentEnemy:Exists() then
                if data.lockedToParent then
                    if data.parentEnemy.HitPoints < data.parentEnemy.MaxHitPoints then
                        if data.healTimer > 0 then
                            data.healTimer = data.healTimer - 1
                        else
                            data.parentEnemy.HitPoints = data.parentEnemy.HitPoints + math.min(flyStats.maxHealing, math.ceil(data.parentEnemy.MaxHitPoints / (100 / flyStats.healPercentage)))
                            data.parentEnemy:SetColor(Color(1, 0.5, 0.5, 1, 50, 0, 0), 10, 1, true, false)
                            data.healTimer = flyStats.healDelay
                            
                            fly:SetColor(flyStats.healColour, 10, 1, true, false)
                        end
                    end
                end
            end
        end
        
    --[[
    This code covers the special abilites for the Soulful Fly
    ]]
    elseif fly.Variant == Entities.SOULFUL_FLY.variant then
        if data.parentEnemy and data.parentEnemy ~= noMate then
            if not data.parentEnemy:IsDead() and data.parentEnemy:Exists() then
                if data.lockedToParent then
                    local parentData = data.parentEnemy:GetData()
                    
                    if not parentData.invulnFrames then
                        data.parentEnemy:SetColor(flyStats.baseColour, 2, 1, true, false)
                    elseif parentData.invulnFrames > 0 then
                        parentData.invulnFrames = parentData.invulnFrames - 1
                    else
                        parentData.invulnFrames = false
                    end
                end
            end
        end
    
    --[[
    This code covers the special abilites for the Hateful Fly
    ]]
    elseif fly.Variant == Entities.HATEFUL_FLY.variant then
        if sprite:IsFinished("Wait what?") then
            local ghost = Isaac.Spawn(Entities.HATEFUL_FLY_GHOST.id, Entities.HATEFUL_FLY_GHOST.variant, 0, fly.Position, fly.Velocity, fly)
            
            ghost:GetData().tetherEnemy = data.parentEnemy
            fly:Kill()
        else
            if data.parentEnemy and data.parentEnemy ~= noMate then
                if not data.parentEnemy:IsDead() and data.parentEnemy:Exists() then
                    if data.lockedToParent then
                        local parentData = data.parentEnemy:GetData()
                            
                        local moveAngle = math.ceil(flyStats.rotationAmount * player.MoveSpeed)
                        local targetAngle = math.ceil((fly.Position - player.Position):GetAngleDegrees()) + 180
                        local angleDif = math.abs(data.orbitAngle - targetAngle)
                        
                        if (angleDif > moveAngle and angleDif < 360 - moveAngle) and player.Position:DistanceSquared(fly.Position) > 400 then
                            local sign = 1
                            
                            if angleDif > 180 then
                                if data.orbitAngle < targetAngle then
                                    sign = -1
                                end
                            else
                                if data.orbitAngle > targetAngle then
                                    sign = -1
                                end
                            end
                            
                            data.orbitAngle = math.ceil(data.orbitAngle + (moveAngle * sign))
                        end
                        
                        if data.orbitAngle >= 360 then
                            data.orbitAngle = data.orbitAngle % 360
                        elseif data.orbitAngle < 0 then
                            data.orbitAngle = 360 + (data.orbitAngle % 360)
                        end
                        
                        --data.parentEnemy:SetColor(flyStats.baseColour, 2, 1, false, false)
                        
                        fly.Velocity = Vector(0, 0)
                        fly.Position = data.parentEnemy.Position + data.parentOffset:Rotated(data.orbitAngle)
                    end
                end
            end
        end
        
    --[[
    This code covers the special abilities for the Hateful Fly Ghost
    ]]
    elseif fly.Variant == Entities.HATEFUL_FLY_GHOST.variant then
        if data.tetherEnemy and (data.tetherEnemy:IsDead() or not data.tetherEnemy:Exists()) then
            fly:Kill()
        else
            if fly.FrameCount <= 1 then
                fly.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                fly.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                
                sprite:Play("RIP", true)
            end
            
            data.tetherEnemy:SetColor(flyStats.baseColour, 2, 1, false, false)
            
            fly.Velocity = (fly.Velocity + ((player.Position - fly.Position):Normalized() * flyStats.turnFactor)):Normalized() * math.min(flyStats.velocityFactor * player.MoveSpeed, flyStats.velocityFactor)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.lovelyFlyLogic, Entities.LOVELY_FLY.id)

function Exodus:moveFlyChildren(entity)
    local data = entity:GetData()
    
    if data.childFlies then
        for i, fly in ipairs(data.childFlies) do
            if fly:IsDead() or not fly:Exists() or fly:GetData().parentEnemy == "Alone" then
                table.remove(data.childFlies, i)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.moveFlyChildren)

function Exodus:soulfulFlyInvincibility(entity, dmgAmount, dmgFlags, dmgSource, invulnFrames)
    local data = entity:GetData()
    
    if data.childFlies then
        for i, fly in ipairs(data.childFlies) do
            if fly.Variant == Entities.SOULFUL_FLY.variant and fly:GetData().lockedToParent then
                local flyStats = FLIES[fly.Variant]
                
                data.invulnFrames = 6
                entity:SetColor(flyStats.invincibilityColour, 10, 1, true, false)
                return false
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.soulfulFlyInvincibility)

function Exodus:hatefulFlyGhost(entity, dmgAmount, dmgFlags, dmgSource, invulnFrames)
    local data = entity:GetData()
    dmgSource = getEntityFromRef(dmgSource)
    
    if entity.Variant == Entities.HATEFUL_FLY.variant then
        local dmgSourceTear = dmgSource:ToTear()
        
        if dmgSourceTear and dmgSourceTear.TearFlags & TearFlags.TEAR_PIERCING == TearFlags.TEAR_PIERCING then
            dmgSource:Kill()
        end
        
        if entity.HitPoints - dmgAmount <= 0 and data.lockedToParent then
            data.parentEnemy:GetData().hasHatefulFly = false
            entity:GetSprite():Play("Wait what?", true)
            return false
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.hatefulFlyGhost, Entities.HATEFUL_FLY.id)

function Exodus:hatefulFlyLaserStop(entity)
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()

    if entity.Parent:ToPlayer() then
        local laser = entity:ToLaser()
        local data = laser:GetData()
        
        if data.flyStopped then 
            if laser.Radius <= 10 then
                laser:Remove()
            elseif laser.Velocity:LengthSquared() < 0.5 then
                laser.Velocity = data.flyStopped
                data.flyStopped = false
            end
            
        end
        
        for u, fly in pairs(entities) do
            if fly.Type == Entities.HATEFUL_FLY.id and fly.Variant == Entities.HATEFUL_FLY.variant then
                if not laser:IsCircleLaser() then
                    local angle = (fly.Position - laser.Position):GetAngleDegrees()
                    
                    if math.abs(math.abs(angle) - math.abs(laser.Angle)) < 20 then
                        local room = Game():GetLevel():GetCurrentRoom()
                        local centreY = room:GetCenterPos().Y
                        local centreX = room:GetCenterPos().X
                            
                        local x1 = laser.Position.X - centreX
                        local y1 = laser.Position.Y - centreY
                        local x2 = fly.Position.X - centreX
                        local y2 = fly.Position.Y - centreY
                        local a = math.tan((360 - laser.Angle) / 180 * math.pi)
                        local b = -1
                        local c = y1 - (a * x1)
                        
                        local perpendicularDist = math.abs((a * x2) + (b * y2) + c) / math.sqrt(a^2 + b^2)
                        local stopDist = 10
                        
                        if laser.Variant == 1 or laser.Variant == 9 then
                            stopDist = 30
                        end
                        
                        if perpendicularDist <= 30 then
                            laser:SetMaxDistance((laser.Position - fly.Position):Length() - stopDist)
                        end
                    end
                else
                    if laser.FrameCount > 120 then
                        laser:Remove()
                    elseif fly.Position:DistanceSquared(laser.Position) < (laser.Radius^2 + 10) then
                        data.flyStopped = laser.Velocity
                        laser.Velocity = Vector(0, 0)
                        laser.Radius = laser.Radius * 0.9
                    end
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.hatefulFlyLaserStop, EntityType.ENTITY_LASER)

--<<<HOTHEAD>>>--
function Exodus:hotheadEntityUpdate(hothead)
    local path = hothead.Pathfinder
    local sprite = hothead:GetSprite()
    local data = hothead:GetData()
    local target = hothead:GetPlayerTarget()
    local angleVec = target.Position - hothead.Position
    
    local room = game:GetRoom()
    
    if hothead.Variant == Entities.HOTHEAD.variant then
        if hothead.FrameCount <= 1 then
            sprite:ReplaceSpritesheet(0, "gfx/monsters/Hothead" .. math.random(1, 3) .. ".png")
            sprite:LoadGraphics()
            hothead.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            hothead:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.soundTimer = math.random(40, 100)
        end
        
        if not data.wakingUp then
            if path:HasPathToPos(target.Position, false) then
                data.wakingUp = true
                
                for i, entity in pairs(Isaac.GetRoomEntities()) do
                    if entity.Type == Entities.HOTHEAD.id and entity.Variant == Entities.HOTHEAD.variant then
                        entity:GetData().wakingUp = true
                    end
                end
            else
                sprite:Play("Sleeping", true)
            end
        else
            if not data.awake then
                if sprite:IsFinished("Awaken") then
                    data.awake = true
                    
                elseif not sprite:IsPlaying("Awaken") then
                    sprite:Play("Awaken", true)
                    sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_3, 1, 0, false, 0.7)
                end
            else
                if path:HasPathToPos(target.Position, false) and not sprite:IsPlaying("Jump") then
                    local directPath = true
                    
                    for i = 20, hothead.Position:Distance(target.Position), 20 do
                        local newPos = hothead.Position + Vector(i, 0):Rotated(angleVec:GetAngleDegrees())
                        local gridEnt = room:GetGridEntityFromPos(newPos)
                        
                        if gridEnt and (gridEnt:ToRock() or gridEnt:ToPit() or gridEnt:ToPoop() or gridEnt:ToTNT() or gridEnt:ToSpikes()) then
                            directPath = false
                            break
                        end
                    end
                    
                    if directPath then
                        local velLimit = 7
                        
                        if target:ToPlayer() then
                            velLimit = velLimit * math.min(math.max(target:ToPlayer().MoveSpeed, 0.7), 1.4)
                        end
                        
                        hothead.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                        hothead:AddVelocity(angleVec:Resized(math.min(150 / angleVec:Length(), 2)))
                        hothead.Velocity = hothead.Velocity:Resized(math.min(hothead.Velocity:Length(), velLimit))
                    else
                        path:FindGridPath(target.Position, 1.5, 0, true)
                    end
                    
                    local velAngle = hothead.Velocity:GetAngleDegrees()
                    
                    if (velAngle > -135 and velAngle < -45) or velAngle < 135 and velAngle > 45 then
                        if not sprite:IsPlaying("WalkVerti") then
                            sprite:Play("WalkVerti", true)
                        end
                    else
                        if velAngle < -90 or velAngle > 90 then
                            sprite.FlipX = true
                        else
                            sprite.FlipX = false
                        end
                    
                        if not sprite:IsPlaying("WalkHori") then
                            sprite:Play("WalkHori", true)
                        end
                    end
                    
                    for i, entity in pairs(Isaac.GetRoomEntities()) do
                        if entity.Type == Entities.HOTHEAD.id and entity.Variant == Entities.HOTHEAD.variant then
                            if entity.Position:DistanceSquared(hothead.Position) < 25^2 then
                                local vel = (entity.Position - hothead.Position):Resized(hothead.Velocity:Length() / 1.5)
                                entity:AddVelocity(vel)
                                hothead:AddVelocity(vel * -1)
                            end
                        end
                    end
                    
                    if data.soundTimer <= 0 then
                        sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0, 0.8, 0, false, 0.6)
                        data.soundTimer = math.random(40, 100)
                    else
                        data.soundTimer = data.soundTimer - 1
                    end
                else
                    if not sprite:IsPlaying("Jump") then
                        sprite:Play("Jump", true)
                    elseif sprite:IsEventTriggered("Jump") then
                        local jumpPos = Isaac.GetFreeNearPosition(hothead.Position, 20)
                        
                        for i = 50, hothead.Position:Distance(target.Position), 10 do
                            local newPos = hothead.Position + Vector(i, 0):Rotated(angleVec:GetAngleDegrees())
                            local gridEnt = room:GetGridEntityFromPos(newPos)
                                
                            if not gridEnt or (gridEnt and not(gridEnt:ToRock() or gridEnt:ToPit() or gridEnt:ToPoop() or gridEnt:ToTNT() or gridEnt:ToSpikes())) then
                                jumpPos = Isaac.GetFreeNearPosition(newPos, 20)
                                break
                            end
                        end
                        
                        hothead.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                        hothead.Velocity = angleVec:Resized(hothead.Position:Distance(jumpPos) / 11)
                    elseif sprite:GetFrame() == 15 then
                        sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 0, false, 0.5)
                    elseif sprite:GetFrame() > 15 then
                        hothead.Velocity = Vector(0, 0)
                    end
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.hotheadEntityUpdate, Entities.HOTHEAD.id)

function Exodus:hotheadTakeDamage(entity, dmgAmount, dmgFlags, dmgSource, invulnFrames)
    if entity.Variant == Entities.HOTHEAD.variant and entity.HitPoints - dmgAmount <= 0 then
        for i = 1, math.random(5, 8) do
            local gibs = Isaac.Spawn(Entities.PIT_GIBS.id, Entities.PIT_GIBS.variant, 0, entity.Position + Vector(0, -15), Vector(math.random(-20, 20), math.random(-20, 20)), entity):ToEffect()
            local sprite = gibs:GetSprite()
            
            gibs.SpriteRotation = math.random(360)
            
            local gib = rng:RandomInt(4)
            
            if gib == 0 then
                sprite:Play("BloodGib0" .. rng:RandomInt(3) + 1, true)
            elseif gib == 1 then
                sprite:Play("Bone0" .. rng:RandomInt(2) + 1, true)
            elseif gib == 2 then
                sprite:Play("Eye", true)
            elseif gib == 3 then
                sprite:Play("Guts0" .. rng:RandomInt(2) + 1, true)
            end
            
            sprite:Stop()
        end
        
        entity.HitPoints = 0
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.hotheadTakeDamage, Entities.HOTHEAD.id)

function Exodus:hotheadUpdate()
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == Entities.PIT_GIBS.id and entity.Variant == Entities.PIT_GIBS.variant then
            entity.Velocity = entity.Velocity / 1.3
            
            if entity.Velocity:LengthSquared() < 4 then
                entity.Velocity = Vector(0, 0)
                entity:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.hotheadUpdate)