local Entities = pExodus.Entities
local ItemVariables = pExodus.ItemVariables
local ItemId = pExodus.ItemId
local game = pExodus.game

local Charge = 0
 
pExodus:AddItemCostume(ItemId.DRAGON_BREATH, pExodus.CostumeId.DRAGON_BREATH)

local function ShootFireball(player, position, vector)
    local fire = Isaac.Spawn(Entities.FIREBALL.id, Entities.FIREBALL.variant, 0, position, vector:Resized(10) * player.ShotSpeed + (player.Velocity / 2), player):ToTear()
    fire.Color = player.TearColor
    fire.CollisionDamage = player.Damage
    fire.TearFlags = fire.TearFlags | player.TearFlags
    fire.FallingAcceleration = -0.1
    fire.SpriteRotation = fire.Velocity:GetAngleDegrees() - 90
end

function pExodus.dragonBreathUpdate()  
    local room = game:GetRoom()
    
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i]
        
        if player:HasCollectible(ItemId.DRAGON_BREATH) then
            if room:GetFrameCount() == 1 then
                local bar = Isaac.Spawn(Entities.CHARGE_BAR.id, Entities.CHARGE_BAR.variant, 0, player.Position, pExodus.NullVector, player)
                bar:GetData().IsFireball = true
                bar.Visible = false
            end
            
            if player:GetFireDirection() > -1 then
                if Charge < 10 then
                    Charge = Charge + (1 / player.MaxFireDelay) * 8
                end
            else
                Charge = -1
            end
            
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_TEAR and entity.SpawnerType == EntityType.ENTITY_PLAYER and pExodus.CompareEntities(entity.Parent, player) and entity.Variant ~= Entities.FIREBALL.variant and entity.Variant ~= Entities.FIREBALL_2.variant and entity:ToTear().TearFlags & TearFlags.TEAR_LUDOVICO == 0 then
                    ShootFireball(player, player.Position, entity.Velocity)
                    entity:Remove()
                elseif entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= Entities.FIREBALL.variant and entity.Variant ~= Entities.BLIGHT_TEAR.variant then
                    local tear = entity:ToTear()
                    local sprite = tear:GetSprite()
                    
                    if tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then
                        if not player:HasCollectible(ItemId.TECH_360) then
                            tear:ChangeVariant(Entities.FIREBALL.variant)
                        end
                        entity.SpriteRotation = entity.Velocity:GetAngleDegrees() - 90
                        if tear.FrameCount == 0 then
                            tear.Visible = false
                        end
                    elseif entity.SpawnerType == EntityType.ENTITY_FAMILIAR and entity.SpawnerVariant == FamiliarVariant.INCUBUS then
                        ShootFireball(player, entity.Position, entity.Velocity)
                        entity:Remove()
                    end
                end
                
                if entity.Type == Entities.FIREBALL_2.id and entity.Variant == Entities.FIREBALL_2.variant then
                    entity.SpriteRotation = entity.FrameCount * 8
                    
                    if entity.FrameCount > player.TearHeight * -1 then
                        entity:Die()
                    end
                    
                    if entity:IsDead() then
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) and player.Position:DistanceSquared(entity.Position) < 70^2 and not player:HasFullHearts() then
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position, NullVector, entity)
                            player:AddHearts(2)
                        end
                        
                        if not player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
                            Isaac.Explode(entity.Position, nil, player.Damage * 7)
                        end
                    end
                end

                if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == 51 then
                    entity.Velocity = entity.Velocity / 1.25
                    if entity:GetData().Putout ~= nil and entity.FrameCount > 8 then
                        entity:Remove()
                    end
                end

                if entity.Type == Entities.FIREBALL.id and entity.Variant == Entities.FIREBALL.variant then
                    if pExodus.rng:RandomInt(3) == 0 then
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, Vector(entity.Position.X, entity.Position.Y - 12), RandomVector() * ((math.random() * 4) + 1), player)
                    end
                    
                    if entity:ToTear().TearFlags & TearFlags.TEAR_LUDOVICO == 0 then
                        local fire = Isaac.Spawn(1000, 51, 0, Vector(entity.Position.X, entity.Position.Y + entity:ToTear().Height), (entity.Velocity:Rotated(math.random(90, 270)) / 2), entity)
                        fire:GetData().Putout = true
                        fire:GetSprite():Play("FireStage03", true)
                    elseif game:GetFrameCount() % player.MaxFireDelay == 0 then
                        for i = 1, 16 do
                            fire = Isaac.Spawn(1000, 51, 0, Vector(entity.Position.X, entity.Position.Y + entity:ToTear().Height), Vector(25, 0):Rotated(math.random(0, 360)), entity)
                            fire:GetData().Putout = true
                            fire:GetSprite():Play("FireStage03", true)
                        end
                    end
                    
                    if pExodus.rng:RandomInt(4) == 0 and entity:ToTear().TearFlags & TearFlags.TEAR_LUDOVICO == 0 then
                        fire = Isaac.Spawn(1000, 51, 0, Vector(entity.Position.X, entity.Position.Y + entity:ToTear().Height), (entity.Velocity:Rotated(math.random(0, 360)) / 2), entity)
                        fire:GetData().Putout = true
                        fire:GetSprite():Play("FireStage03", true)
                    end
                    
                    entity.Velocity = entity.Velocity * 1.01
                    entity.SpriteRotation = entity.Velocity:GetAngleDegrees() - 90

                    if (entity:IsDead() or entity.FrameCount > 100) and entity:ToTear().TearFlags & TearFlags.TEAR_LUDOVICO == 0 then
                        entity:Die()

                        for i, entityburn in pairs(Isaac.GetRoomEntities()) do
                            if entityburn:IsActiveEnemy() and entityburn:IsVulnerableEnemy() then
                                if entityburn.Position:Distance(entity.Position) < 48 then
                                    entityburn:AddBurn(EntityRef(entity), 100, 1)
                                end
                            end
                        end

                        for i = 1, 16 do
                            fire = Isaac.Spawn(1000, 51, 0, Vector(entity.Position.X, entity.Position.Y + entity:ToTear().Height), (entity.Velocity:Rotated(math.random(0, 360)) * 1.25), entity)
                            fire:GetData().Putout = true
                            fire:GetSprite():Play("FireStage03", true)
                        end

                        local fire2 = Isaac.Spawn(Entities.FIREBALL_2.id, Entities.FIREBALL_2.variant, 0, entity.Position, entity.Velocity, entity):ToTear()
                        fire2.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
                        fire2.FallingAcceleration = -0.1
                        fire2.CollisionDamage = player.Damage * 2
                        fire2.Color = player.TearColor
                        fire2.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                        
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
                            for u = 1, math.random(3, 5) do
                                player:FireTechLaser(entity.Position, 0, RandomVector(), false, false)
                            end
                        end
                    end
                end
            end
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_UPDATE, pExodus.dragonBreathUpdate)  

function pExodus.dragonBreathCache(player, flag)
    if player:HasCollectible(ItemId.DRAGON_BREATH) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay * 3 - 2
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 2
		end
	end
end

pExodus:AddModCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.dragonBreathCache, CacheFlag.CACHE_FIREDELAY + CacheFlag.CACHE_DAMAGE)