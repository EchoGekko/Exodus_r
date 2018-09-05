local ItemId = pExodus.ItemId

pExodus.ItemId.POSSESSED_BOMBS = Isaac.GetItemIdByName("Possessed Bombs")
pExodus.CostumeId.POSSESSED_BOMBS = Isaac.GetCostumeIdByPath("gfx/characters/costume_Possessed Bombs.anm2")
pExodus:AddItemCostume(ItemId.POSSESSED_BOMBS, pExodus.CostumeId.POSSESSED_BOMBS)

function pExodus.possessedBombUpdate()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.POSSESSED_BOMBS) then
		for i, entity in pairs(pExodus.RoomEntities) do
			local bomb = entity:ToBomb()
			
			if bomb and not entity:IsDead() then
				local data = bomb:GetData()
				
				if not data.isPossessed and bomb.SpawnerType == 1 then
					bomb.Flags = bomb.Flags | (TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_FEAR)
					bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
					bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
					bomb:SetColor(Color(1, 1, 1, 0.7, 0, 0, 0), -1, 1, false, false)
					bomb:GetSprite():Load("gfx/effects/Possessed Bombs.anm2", true)
					
					data.isPossessed = true
				elseif data.isPossessed then
					bomb.Velocity = bomb.Velocity + Vector(Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) - Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex), Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) - Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex))
				end
			end
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.possessedBombUpdate)