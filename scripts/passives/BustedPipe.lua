local rng = RNG()

pExodus.ItemId.BUSTED_PIPE = Isaac.GetItemIdByName("Busted Pipe")
pExodus.CostumeId.BUSTED_PIPE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Busted Pipe.anm2")
pExodus:AddItemCostume(pExodus.ItemId.BUSTED_PIPE, pExodus.CostumeId.BUSTED_PIPE)

function pExodus:bustedPipeUpdate()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(pExodus.ItemId.BUSTED_PIPE) then        
		for i, entity in pairs(pExodus.RoomEntities) do
			if entity.Parent and pExodus.CompareEntities(entity.Parent, player) then
				local data = entity:GetData()
				
				if entity.Type == EntityType.ENTITY_LASER and entity.FrameCount == 1 and pExodus:HasPlayerChance(player, 7) and not entity:ToLaser().IsCircleLaser then
					for i = 1, 10 do
						local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, entity.Position + (Vector.FromAngle(entity:ToLaser().Direction) * i * 40), NullVector, player):ToEffect()
						creep:SetTimeout(20)
						creep.Color = player.TearColor
						creep.CollisionDamage = player.Damage
						creep:SetColor(Color(0.4, 0.4, 1, 1, 150, 190, 255), -1, 1, false, false)
					end
				elseif (entity.Type == EntityType.ENTITY_TEAR or (entity.Type == EntityType.ENTITY_LASER and entity:ToLaser().IsCircleLaser)) and entity.SpawnerType == EntityType.ENTITY_PLAYER then
					if pExodus:HasPlayerChance(player, 7) and entity.FrameCount == 1 then
						data.IsLeakyTear = true
						entity:SetColor(Color(0.4, 0.4, 1, 1, 130, 180, 255), -1, 1, false, false)
					end
					
					if data.IsLeakyTear then
						if entity.FrameCount == 1 then
							entity.Velocity = entity.Velocity * 1.6
						end
						
						if rng:RandomInt(3) == 0 and entity.Position:DistanceSquared(player.Position) > 30^2 then
							for i = 1, player:GetCollectibleNum(pExodus.ItemId.BUSTED_PIPE) do
								local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, entity.Position + (RandomVector() * (i - 1) * 30), pExodus.NullVector, entity):ToEffect()
								creep:SetTimeout(20)
								creep.Color = player.TearColor
								creep.CollisionDamage = player.Damage * 2
								creep:SetColor(Color(0.4, 0.4, 1, 1, 130, 180, 255), -1, 1, false, false)
							end
						end
					end
				end
			end
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.bustedPipeUpdate)