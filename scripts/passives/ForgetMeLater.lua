pExodus.ItemId.FORGET_ME_LATER = Isaac.GetItemIdByName("Forget Me Later")

local NumberFloors = 0

function pExodus.forgetMeLaterAdd()
    NumberFloors = pExodus.Level:GetAbsoluteStage() + math.random(2)
end

pExodus:AddCustomCallback(pExodus.ExodusCallbacks.MC_ADD_COLLECTIBLE, pExodus.forgetMeLaterAdd, pExodus.ItemId.FORGET_ME_LATER)

function pExodus.forgetMeLaterUpdate()
    local levelStage = pExodus.Level:GetAbsoluteStage()

	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(pExodus.ItemId.FORGET_ME_LATER) then
		if player:GetSprite():IsPlaying("Trapdoor") and levelStage >= NumberFloors then
			NumberFloors = nil
			pExodus.Game:StartStageTransition(true, 0)
			player:RemoveCollectible(pExodus.ItemId.FORGET_ME_LATER)
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.forgetMeLaterUpdate)