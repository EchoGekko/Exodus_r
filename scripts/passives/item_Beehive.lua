local ColourIsBlack = false
local sfx = pExodus.SFX
local game = pExodus.Game

pExodus:AddItemCostume(pExodus.ItemId.BEEHIVE, pExodus.CostumeId.BEEHIVE)

function pExodus.beehiveUpdate()
    for pIndex = 1, pExodus.PlayerCount do
        local player = pExodus.Players[pIndex].ref
        
        if player:HasCollectible(pExodus.ItemId.BEEHIVE) then
            if player.FrameCount % (math.random(18, 20)) == 0 then
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, player.Position, pExodus.NullVector, player)
                creep:SetColor(Color(0, 0, 0, 1, math.random(200, 250), math.random(150, 200), math.random(0, 10)), -1, 1, false, false)
            end
            
            player.TearFallingAcceleration = -0.1
            
            if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER) then
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER, false)
            end
            
            if sfx:IsPlaying(SoundEffect.SOUND_TEARS_FIRE) then
                sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
                sfx:Play(SoundEffect.SOUND_INSECT_SWARM_LOOP, 1, 0, true, 0.8)
            end
            
            if sfx:IsPlaying(SoundEffect.SOUND_TEARIMPACTS) then
                sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)
                sfx:Play(SoundEffect.SOUND_INSECT_SWARM_LOOP, 1, 0, true, 0.8)
            end
            
            if player.FrameCount % 5 == 0 or game:GetRoom():GetFrameCount() == 1 then
                if ColourIsBlack then
                    player.TearColor = Color(0.1, 0.1, 0.1, 1, 0, 0, 0)
                    player.LaserColor = Color(0.1, 0.1, 0.1, 1, 0, 0, 0)
                    ColourIsBlack = false
                else
                    player.TearColor = Color(1, 1, 0, 1, 0, 0, 0)
                    player.LaserColor = Color(1, 1, 0, 1, 0, 0, 0)
                    ColourIsBlack = true
                end
            end
            
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                local sprite = entity:GetSprite()
                
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) and entity.Type == EntityType.ENTITY_KNIFE and pExodus.CompareEntities(entity.Parent, player) then
                    if entity.SpawnerType == EntityType.ENTITY_PLAYER then
                        entity.Visible = false
                        
                        local knife = player:FireKnife(nil, rng:RandomInt(360), true, 0)
                        knife.SpriteRotation = entity.SpriteRotation + entity.Position:Distance(player.Position) - 30
                        knife.Position = entity.Position + RandomVector()
                        knife:GetSprite().FlipY = true
                    end
                end
                
                if entity.Type == EntityType.ENTITY_LASER and entity.SpawnerType == EntityType.ENTITY_PLAYER and entity.Variant ~= 5 then
                    if ColourIsBlack then
                        entity.Color = Color(0, 0, 0, 1, 0, 0, 0)
                        entity.SplatColor = Color(0, 0, 0, 1, 0, 0, 0) 
                    else
                        entity.Color = Color(1, 1, 0, 1, 255, 255, 0)
                        entity.SplatColor = Color(1, 1, 0, 1, 255, 255, 0)
                    end
                end
                
                if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.ROCKET and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
                    if not string.find(sprite:GetFilename(), "gfx/effects/bee") then
                        sprite:ReplaceSpritesheet(0, "gfx/effects/effect_035_beemissile.png")
                        sprite:LoadGraphics()
                    end
                    
                    if entity:IsDead() then
                        pExodus:FireXHoney(15, entity)
                    end
                end
                
                if entity.Type == EntityType.ENTITY_BOMBDROP and entity.SpawnerType == EntityType.ENTITY_PLAYER and pExodus.CompareEntities(entity.Parent, player) and entity:ToBomb().IsFetus then
                    entity.Velocity = entity.Velocity + RandomVector()
                end
                
                if entity.Type == EntityType.ENTITY_TEAR then
                    if entity.SpawnerType == EntityType.ENTITY_PLAYER or entity.SpawnerType == EntityType.ENTITY_FAMILIAR then
                        if pExodus.CompareEntities(entity.Parent, player) or entity.SpawnerVariant == 120 or entity.SpawnerVariant == 80 then
                            entity.Color = player.TearColor
                            if entity.FrameCount > 20 then
                                entity.Velocity = entity.Velocity - RandomVector()
                            else
                                entity.Velocity = entity.Velocity - (RandomVector() / 2)
                            end
                            
                            if entity.FrameCount == 1 and player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
                                entity.CollisionDamage = entity.CollisionDamage * 2
                            end
                            
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and math.random(6) == 1 then
                                for u, effect in pairs(Isaac.GetRoomEntities()) do
                                    if effect.Type == EntityType.ENTITY_EFFECT and effect.Velocity ~= NullVector and effect.Variant == EffectVariant.TARGET then
                                        entity.Velocity = (effect.Position - entity.Position) / 30 + RandomVector() * 3
                                    end
                                end
                            end
                            
                            if entity.FrameCount == 1 then
                                entity.Velocity = entity.Velocity + RandomVector() * 3
                                entity.Color = player.TearColor
                            end
                        end
                    end
                end
            end
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_UPDATE, pExodus.beehiveUpdate)