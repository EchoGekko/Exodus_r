local ItemId = pExodus.ItemId
local CostumeId = pExodus.CostumeId

pExodus.ItemId.MAKEUP_REMOVER = Isaac.GetItemIdByName("Makeup Remover")
pExodus.CostumeId.MAKEUP_REMOVER = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover.anm2")
pExodus.CostumeId.MAKEUP_REMOVER_BLACK = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_black.anm2")
pExodus.CostumeId.MAKEUP_REMOVER_BLUE = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_blue.anm2")
pExodus.CostumeId.MAKEUP_REMOVER_GRAY = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_grey.anm2")
pExodus.CostumeId.MAKEUP_REMOVER_WHITE = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_white.anm2")

function pExodus.makeupRemoverInit(entity)
	local player = Isaac.GetPlayer(0)
	local data = entity:GetData()
	
	if player:HasCollectible(ItemId.MAKEUP_REMOVER) and (entity:IsActiveEnemy(false)) and data.FaceScared == nil then
		data.FaceScared = true
		entity.HitPoints = entity.HitPoints * (0.9^player:GetCollectibleNum(ItemId.MAKEUP_REMOVER))
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NPC_INIT, pExodus.makeupRemoverInit)

function pExodus.makeupRemoverAdd()
	local player = Isaac.GetPlayer(0)
    local playerName = player:GetName()
    
    if playerName == "The Lost" then
        player:AddNullCostume(CostumeId.MAKEUP_REMOVER_WHITE)
    elseif playerName == "Azazel" or player:GetName() == "Lilith" then
        player:AddNullCostume(CostumeId.MAKEUP_REMOVER_BLACK)
    elseif playerName == "???" then
        player:AddNullCostume(CostumeId.MAKEUP_REMOVER_BLUE)
    elseif playerName == "Keeper" or playerName == "Apollyon" then
        player:AddNullCostume(CostumeId.MAKEUP_REMOVER_GRAY)
    else
        player:AddNullCostume(CostumeId.MAKEUP_REMOVER)
    end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.makeupRemoverAdd, ItemId.MAKEUP_REMOVER)

function pExodus.makeupRemoverRemove(noneLeft)
	local player = Isaac.GetPlayer(0)

    if noneLeft then
        player:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER)
        player:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_WHITE)
        player:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_BLACK)
        player:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_BLUE)
        player:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_GRAY)
    end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_REMOVE_COLLECTIBLE, pExodus.makeupRemoverRemove, ItemId.MAKEUP_REMOVER)