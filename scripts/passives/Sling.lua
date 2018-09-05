local game = pExodus.Game
local ItemId = pExodus.ItemId

pExodus.ItemId.SLING = Isaac.GetItemIdByName("Sling")

local ValidEnemies = { EntityType.ENTITY_FATTY, EntityType.ENTITY_SWARMER, EntityType.ENTITY_CRAZY_LONG_LEGS, EntityType.ENTITY_DADDYLONGLEGS }
local InvalidEnemies = { EntityType.ENTITY_ATTACKFLY, EntityType.ENTITY_HUSH_FLY, EntityType.ENTITY_POOTER, EntityType.ENTITY_FLY, EntityType.ENTITY_RING_OF_FLIES, EntityType.ENTITY_DART_FLY,EntityType.ENTITY_SWARM, EntityType.ENTITY_MOTER, EntityType.ENTITY_FLY_L2, EntityType.ENTITY_ETERNALFLY }

local SlingIcon = Sprite()
SlingIcon:Load("gfx/effects/Sling_marker_effect.anm2", true)
SlingIcon:Play("Idle", true)

local function IsValidEnemy(enemy)
    if not enemy then
        return false
    end
    
    if enemy.Size > 13 or enemy:IsBoss() then
        for i, id in ipairs(InvalidEnemies) do
            if enemy.Type == id then
                return false
            end
        end
        
        return true
    else
        for i, id in ipairs(ValidEnemies) do
            if enemy.Type == id then
                return true
            end
        end
    end
    
    return false
end

function pExodus.slingRender()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.SLING) and not game:IsPaused() then
		SlingIcon.Color = Color(1, 1, 1, 0.5, 0, 0, 0)
		SlingIcon:Update()
		SlingIcon:LoadGraphics()
		
		for i, entity in pairs(pExodus.RoomEntities) do
			if entity:IsVulnerableEnemy() and IsValidEnemy(entity) then
				SlingIcon:Render(pExodus.Room:WorldToScreenPosition(entity.Position - Vector(0, (entity.SpriteScale.Y * entity.Size * 1.5) + 20)), pExodus.NullVector, pExodus.NullVector)
			end
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_RENDER, pExodus.slingRender)

function pExodus.slingTearCollision(tear, target)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.SLING) and pExodus.CompareEntities(player, tear.Parent) and target:IsVulnerableEnemy() and IsValidEnemy(target) then
		tear.CollisionDamage = player.Damage + (target.Size / 13)
	end
end

pExodus:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, pExodus.slingTearCollision)