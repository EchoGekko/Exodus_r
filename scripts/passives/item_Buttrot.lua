local game = pExodus.game
local Entities = pExodus.Entities

local function getSize(scale, flags)
    if flags & TearFlags.TEAR_LUDOVICO ~= 0 then
        return 6
    elseif scale < 0.675 then
        return 1
    elseif scale < 0.925 then
        return 2
    elseif scale < 1.175 then
        return 3
    elseif scale < 1.675 then
        return 4
    elseif scale < 2.175 then
        return 5
    else
        return 6
    end
end

pExodus:AddItemCostume(pExodus.ItemId.BUTTROT, pExodus.CostumeId.BUTTROT)

function pExodus.buttrotUpdate()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i]
        
        if player:HasCollectible(pExodus.ItemId.BUTTROT) then
            local entities = Isaac.GetRoomEntities()
            
            for i = 1, #entities do
                local entData = entities[i]:GetData()
                
                if entities[i].Type == EntityType.ENTITY_TEAR and entities[i].Variant == pExodus.Entities.BLIGHT_TEAR.variant then
                    if entities[i]:IsDead() then
                        local splash = Isaac.Spawn(pExodus.Entities.BLIGHT_STATUS_EFFECT.id, pExodus.Entities.BLIGHT_STATUS_EFFECT.variant, 0, entities[i].Position + Vector(0, entities[i]:ToTear().Height), Vector(0,0), nil):ToEffect()
                        splash:SetTimeout(30)                
                    elseif not player:HasCollectible(pExodus.ItemId.TECH_360) then
                        entities[i].Visible = true
                    end
                end
                
                if entities[i].Type == pExodus.Entities.BLIGHT_STATUS_EFFECT.id and entities[i].Variant == pExodus.Entities.BLIGHT_STATUS_EFFECT.variant then
                    entities[i].Position = entData.parent.Position + Vector(0, entData.parent.Size)
                    if entData.parent:IsDead() or entData.parent:GetData().BlightedFrame == nil then
                        entities[i]:Remove()
                    end
                end
                
                if entData.BlightedFrame ~= nil then
                    if entData.BlightedFrame + 200 < game:GetFrameCount() then
                        entData.BlightedFrame = nil
                    end
                end
                
                if entities[i].Type == EntityType.ENTITY_LASER and entities[i].SpawnerType == EntityType.ENTITY_PLAYER and entities[i].Variant ~= 5 then
                    player.TearColor = Color(0.5, 0.1, 0.8, 1, 125, 55, 225)
                    player.LaserColor = Color(0.5, 0.1, 0.8, 1, 125, 55, 225)
                    entities[i].Color = Color(0.5, 0.1, 0.8, 1, 125, 55, 225)
                    entities[i].SplatColor = Color(0.5, 0.1, 0.8, 1, 125, 55, 225) 
                end
                
                if entities[i].Type == EntityType.ENTITY_TEAR and entities[i].Variant ~= pExodus.Entities.BLIGHT_TEAR.variant then
                    local tear = entities[i]:ToTear()
                    local flags = tear.TearFlags
                    local sprite = tear:GetSprite()
                    
                    if flags & TearFlags.TEAR_LUDOVICO ~= 0 then
                        if not player:HasCollectible(pExodus.ItemId.TECH_360) then
                            tear:ChangeVariant(pExodus.Entities.BLIGHT_TEAR.variant)
                        end
                        
                        sprite:Play("Shroom6")
                        
                        if tear.FrameCount == 0 then
                            tear.Visible = false
                        end
                    end
                end
                
                if entities[i].Type == EntityType.ENTITY_BOMBDROP and entities[i].SpawnerType == 1 and entData.IsButtrotBomb == nil then
                    local buttchance = 4 - player.Luck
                    
                    if buttchance < 1 then
                        buttchance = 1
                    end
                    
                    if pExodus.rng:RandomInt(buttchance) == 0 then
                        entities[i]:GetSprite():Load("gfx/blight_bomb.anm2", true)
                        entData.IsButtrotBomb = true
                    else
                        entData.IsButtrotBomb = false
                    end
                elseif entities[i].Type == EntityType.ENTITY_BOMBDROP and entities[i].SpawnerType == 1 and entData.IsButtrotBomb and entities[i]:IsDead() then
                    for i, target in pairs(Isaac.GetRoomEntities()) do
                        if target:IsVulnerableEnemy() and not EntityRef(target).IsFriendly and target.Position:DistanceSquared(entities[i].Position) < 12^2 then
                            local targetData = target:GetData()
                            
                            if targetData.BlightedFrame == nil then
                                target:SetColor(Color(0.75, 0.17, 0.46, 1, 0, 0, 0), 200, 1, false, false)  
                                
                                local arrow = Isaac.Spawn(1000, 538978237, 0, target.Position + Vector(0, target.Size), Vector(0,0), nil)
                                arrow:GetData().parent = target
                                targetData.BlightedFrame = game:GetFrameCount()
                            end
                        end
                    end
                end
                
                if entities[i]:IsActiveEnemy() and entData.BlightedFrame ~= nil then
                    for v, target in pairs(Isaac.GetRoomEntities()) do
                        if target:IsActiveEnemy() and not EntityRef(target).IsFriendly and target.Position:DistanceSquared(entities[i].Position) < (entities[i].Size * 2)^2 and target.Position:DistanceSquared(entities[i].Position) > 1 then
                            game:ButterBeanFart(entities[i].Position, 64, entities[i], true)
                            entities[i]:TakeDamage(player.Damage / 2, 0, EntityRef(target), 3)
                        end
                    end
                end
            end
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_UPDATE, pExodus.buttrotUpdate)

function pExodus.buttrotTear(tear)
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i]
        
        if player:HasCollectible(pExodus.ItemId.BUTTROT) then
            local buttchance = 12 - player.Luck
            
            if buttchance < 1 then
                buttchance = 1
            end
            
            if pExodus.rng:RandomInt(buttchance) == 0 then
                tear:ChangeVariant(Entities.BLIGHT_TEAR.variant)
                local sprite = tear:GetSprite()
                local size = getSize(tear.Scale, tear.TearFlags)
                sprite:Play("Shroom" .. size)
            end
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_FIRE_TEAR, pExodus.buttrotTear)