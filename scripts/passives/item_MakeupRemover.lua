local ItemId = pExodus.ItemId
local CostumeId = pExodus.CostumeId

function pExodus.makeupRemoverInit(entity)
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i].ref
        local data = entity:GetData()
        
        if player:HasCollectible(ItemId.MAKEUP_REMOVER) and (entity:IsActiveEnemy(false)) and data.FaceScared == nil then
            data.FaceScared = true
            entity.HitPoints = entity.HitPoints * (0.9^player:GetCollectibleNum(ItemId.MAKEUP_REMOVER))
        end
    end
end

pExodus:AddModCallback(ModCallbacks.MC_POST_NPC_INIT, pExodus.makeupRemoverInit)

function pExodus.makeupRemoverAdd(exodusPlayer)
    local player = exodusPlayer.ref
    local playerName = player:GetName()
    
    if pplayerName == "The Lost" then
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

function pExodus.makeupRemoverRemove(exodusPlayer, noneLeft)
    if noneLeft then
        exodusPlayer.ref:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER)
        exodusPlayer.ref:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_WHITE)
        exodusPlayer.ref:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_BLACK)
        exodusPlayer.ref:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_BLUE)
        exodusPlayer.ref:TryRemoveNullCostume(CostumeId.MAKEUP_REMOVER_GRAY)
    end
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_REMOVE_COLLECTIBLE, pExodus.makeupRemoverRemove, ItemId.MAKEUP_REMOVER)