local ItemId = pExodus.ItemId
local UseCount = 0

pExodus.ItemId.FORBIDDEN_FRUIT = Isaac.GetItemIdByName("The Forbidden Fruit")

function pExodus.forbiddenFruitResetTable()
    UseCount = 0
end

pExodus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, pExodus.forbiddenFruitResetTable)

function pExodus.forbiddenFruitCache(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + (math.floor((UseCount^0.7) * 100)) / 101
	end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.forbiddenFruitCache)

function pExodus.forbiddenFruitUse(active)
	local player = Isaac.GetPlayer(0)
	
	if active == ItemId.FORBIDDEN_FRUIT then
		if player:GetName() ~= "The Lost" and player:GetName() ~= "Keeper" then
			pExodus.SFX:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
			UseCount = UseCount + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
			player:AddHearts(24)
			
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
		
		pExodus.LiftActive = true
	end
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.forbiddenFruitUse, ItemId.FORBIDDEN_FRUIT)