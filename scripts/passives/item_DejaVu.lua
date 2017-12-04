local InvalidFlags = TearFlags.TEAR_SPLIT
local ValidFamiliars = {
	[FamiliarVariant.INCUBUS] = true,
	[FamiliarVariant.FATES_REWARD] = true
}

function pExodus.dejaVuUpdate()
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        
        if player:HasCollectible(pExodus.ItemId.DEJA_VU) then
            for i, entity in pairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_TEAR and ((entity.SpawnerType == EntityType.ENTITY_PLAYER and pExodus.CompareEntities(entity.Parent, player)) or (entity.SpawnerType == EntityType.ENTITY_FAMILIAR and ValidFamiliars[entity.SpawnerVariant])) then
                    local entData = entity:GetData()
                    local entTear = entity:ToTear()
                    
                    if entity:IsDead() then
                        if (entTear.TearFlags & InvalidFlags) == 0 and entity.Variant ~= pExodus.Entities.FIREBALL_2.variant then
                            if entData.ReturnChance == nil then
                                entData.ReturnChance = 50 + player.Luck
                            end
                            
                            if pExodus.RNG:RandomInt(101) < entData.ReturnChance then
                                local tearPosition = entData.OriginalData.Position
                                
                                if not tearPosition then
                                    tearPosition = player.Position
                                end
                                
                                local tear = player:FireTear(tearPosition, entData.OriginalData.Velocity, true, true, true)
                                local tearData = tear:GetData()
                                tearData.ReturnChance = entData.ReturnChance / 2
                                tearData.OriginalData = entData.OriginalData
                                tear.Scale = entData.OriginalData.Scale * 1.25
                                tear.TearFlags = entData.OriginalData.Flags
                                tear.Height = entData.OriginalData.Height
                                tear.FallingSpeed = entData.OriginalData.FallingSpeed
                                tear.FallingAcceleration = entData.OriginalData.FallingAcceleration
                                tear:SetColor(Color(1, 1, 1, 1, 255, 255, 255), 5, 5, true, false)
                            else
                                entData.ReturnChance = 0
                            end
                        end
                    elseif not entData.OriginalData and entity.FrameCount <= 1 then
                        entData.OriginalData = { Position = entity.Position, Velocity = entity.Velocity, Flags = entTear.TearFlags, Scale = entTear.Scale, Height = entTear.Height, FallingSpeed = entTear.FallingSpeed, FallingAcceleration = entTear.FallingAcceleration }
                    elseif entData.OriginalData and entTear.Scale > entData.OriginalData.Scale then
                        entTear.Scale = math.max(entData.OriginalData.Scale, entTear.Scale * 0.9)
                    end
                end
            end
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_UPDATE, pExodus.dejaVuUpdate)