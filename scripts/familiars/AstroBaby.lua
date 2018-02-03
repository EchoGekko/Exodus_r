local ItemId = pExodus.ItemId
local Entities = pExodus.Entities
local playerUsedBox = { 0, 0, 0, 0 }

pExodus.ItemId.ASTRO_BABY = Isaac.GetItemIdByName("Astro Baby")
pExodus.Entities.ASTRO_BABY = pExodus.GetEntity("Astro Baby")

pExodus:SetupFamiliar(Entities.ASTRO_BABY.variant, ItemId.ASTRO_BABY)

function pExodus.astroBabyInit(astro)
    astro:AddToFollowers()
    astro:GetData().FireDelay = 10
    astro:GetSprite():Play("IdleDown")
end

pExodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, pExodus.astroBabyInit, Entities.ASTRO_BABY.variant)

function pExodus.astroBabyFamiliarUpdate(astro)
    local player = astro.Player
    local sprite = astro:GetSprite()
    local data = astro:GetData()
    
    astro:FollowParent()
    
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        
        if entity.Type == EntityType.ENTITY_TEAR and data.IsFromAstroBaby == true then
            if not entity:IsDead() then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    entity:GetSprite():Play("BFFS", false)
                end

                entity.Velocity = entity.Velocity:Rotated(data.RotateAmount)

                if data.RotateAmount < 10 then
                    data.RotateAmount = data.RotateAmount / 1.01
                else
                    data.RotateAmount = data.RotateAmount / 1.1
                end
            else
                for i = 1, 4 do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.NAIL_PARTICLE, 0, entity.Position, RandomVector() * ((math.random() * 4) + 1), player)
                end
            end
        end
    end
    
    if data.FireDelay == 0 then
        if player:GetFireDirection() > -1 then
            data.FireDelay = 10
            local dir = Vector(0,0)
            
            if player:GetHeadDirection() == Direction.DOWN then
                dir = Vector(0, 10) + (astro.Velocity / 3)
                sprite:Play("ShootDown", true)
            elseif player:GetHeadDirection() == Direction.LEFT then
                dir = Vector(-10, 0) + (astro.Velocity / 3)
                sprite:Play("ShootSide2", true)
            elseif player:GetHeadDirection() == Direction.RIGHT then
                dir = Vector(10, 0) + (astro.Velocity / 3)
                sprite:Play("ShootSide", true)
            elseif player:GetHeadDirection() == Direction.UP then
                dir = Vector(0, -10) + (astro.Velocity / 3)
                sprite:Play("ShootUp", true)
            end

            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 619575, 0, astro.Position, dir, astro):ToTear()
            local tearData = tear:GetData()
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                tear.CollisionDamage = 7
            else
                tear.CollisionDamage = 3.5
            end
            tearData.IsFromAstroBaby = true
            tearData.Parent = astro
            tearData.RotateAmount = 30
            tear.FallingAcceleration = -0.1
            tear.FallingSpeed = 0
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
end

pExodus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, pExodus.astroBabyFamiliarUpdate, Entities.ASTRO_BABY.variant)