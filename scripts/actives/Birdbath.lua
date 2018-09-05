local ItemId = pExodus.ItemId
local Entities = pExodus.Entities

pExodus.ItemId.BIRDBATH = Isaac.GetItemIdByName("Birdbath")

function pExodus.birdbathUse(active)
    local player = Isaac.GetPlayer(0)
    
	if active == ItemId.BIRDBATH then
		local bath = Isaac.Spawn(Entities.BIRDBATH.id, Entities.BIRDBATH.variant, 0, Isaac.GetFreeNearPosition(player.Position, 7), pExodus.NullVector, player)
		bath:GetSprite():Play("Appear", true)

		pExodus.LiftActive = true
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.birdbathUse, ItemId.BIRDBATH)

function pExodus.birdbathEntityUpdate()
	for i, bath in pairs(pExodus.RoomEntities) do
		if bath.Type == Entities.BIRDBATH.id and bath.Variant == Entities.BIRDBATH.variant then
			local data = bath:GetData()
			
			bath.Velocity = pExodus.NullVector
			bath.Friction = bath.Friction / 100
			
			if not bath:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
				bath:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			end

			if bath:GetSprite():IsFinished("Appear") then
				bath:GetSprite():Play("Idle", true)
			end

			local suckable = false

			for e, entity in pairs(pExodus.RoomEntities) do
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
				if (entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_KNIFE) and not entity:GetData().DontSplash then
					if entity.Position:DistanceSquared(bath.Position) < (entity.Size + bath.Size)^2 then
						local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, bath.Position + Vector(math.random(-8, 8), math.random(-16, -12)), Vector(0,0), player)
						splash:GetSprite().Color = Color(1, 1, 1, 1, 0, math.random(150, 255), math.random(200, 255))
						splash:GetSprite().Rotation = math.random(-30, 30)
						entity:GetData().DontSplash = true
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
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.birdbathEntityUpdate)