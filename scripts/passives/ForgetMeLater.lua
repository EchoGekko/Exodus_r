pExodus.ItemId.FORGET_ME_LATER = Isaac.GetItemIdByName("Forget Me Later")

local NumberFloors = {}

function pExodus.forgetMeLaterAdd(player)
    NumberFloors[player.index] = pExodus.Level:GetAbsoluteStage() + math.random(2)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.forgetMeLaterAdd, pExodus.ItemId.FORGET_ME_LATER)

function pExodus.forgetMeLaterUpdate()
    local levelStage = pExodus.Level:GetAbsoluteStage()
    
    for i = 1, pExodus.PlayerCount do
        local player = pExodus.Players[i]
        
        if player.ref:HasCollectible(pExodus.ItemId.FORGET_ME_LATER) then
            if player.ref:GetSprite():IsPlaying("Trapdoor") and levelStage >= NumberFloors[player.index] then
                NumberFloors[player.index] = nil
                pExodus.Game:StartStageTransition(true, 0)
                player.ref:RemoveCollectible(pExodus.ItemId.FORGET_ME_LATER)
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.forgetMeLaterUpdate)