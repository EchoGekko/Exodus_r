local ItemId = pExodus.ItemId
local playerVars = {}

pExodus.ItemId.FORBIDDEN_FRUIT = Isaac.GetItemIdByName("The Forbidden Fruit")

function pExodus.forbiddenFruitResetTable()
    playerVars = {
        { UseCount = 0 },
        { UseCount = 0 },
        { UseCount = 0 },
        { UseCount = 0 }
    }
end

pExodus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, pExodus.forbiddenFruitResetTable)

function pExodus:forbiddenFruitCache(player, flag)
    for pIndex = 1, pExodus.PlayerCount do
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + (math.floor((math.pow(playerVars[pIndex].UseCount, 0.7)) * 100)) / 101
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.forbiddenFruitCache, CacheFlag.CACHE_DAMAGE)

function pExodus.forbiddenFruitUse()
	local player = pExodus:UsedPlayer().ref
	local pIndex = pExodus:UsedPlayer().index
	
	if player:GetName() ~= "The Lost" and player:GetName() ~= "Keeper" then
		pExodus.SFX:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
		playerVars[pIndex].UseCount = playerVars[pIndex].UseCount + 1
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
	
	return true
end

pExodus:AddCallback(ModCallbacks.MC_USE_ITEM, pExodus.forbiddenFruitUse, ItemId.FORBIDDEN_FRUIT)