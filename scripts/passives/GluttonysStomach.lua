local Entities = pExodus.Entities

local PartsMax = 8
local Parts = 0
local HPPos = Vector(36, 12)
local RenderBar = Sprite()
RenderBar:Load("gfx/effects/effect_gluttonystomach.anm2", true)
RenderBar.Scale = Vector(1.3, 1.3)

pExodus.ItemId.GLUTTONYS_STOMACH = Isaac.GetItemIdByName("Gluttony's Stomach")

function pExodus.reset()
    Parts = 0
end

pExodus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, pExodus.reset)

function pExodus.gluttonysStomachPickup(pickup, collider, low)
    local player = Isaac.GetPlayer(0)

	if pickup.Variant == PickupVariant.PICKUP_HEART and player:HasCollectible(pExodus.ItemId.GLUTTONYS_STOMACH) and player:HasFullHearts() and Parts < PartsMax then
		local parts
		local effect
		
		if pickup.SubType == HeartSubType.HEART_HALF then
			parts = 1
			effect = Entities.PART_UP.variant
		elseif pickup.SubType == HeartSubType.HEART_FULL then
			parts = 2
			effect = Entities.PART_UP_UP.variant
		elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
			parts = 4
			effect = Entities.PART_UP_UP_UP.variant
		else
			return nil
		end
		
		Parts = Parts + parts
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, pExodus.NullVector, pickup)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, player.Position, pExodus.NullVector, player)
		pickup:PlayPickupSound()
		pickup:Remove()
	end
	
	if Parts >= PartsMax and player:GetMaxHearts() < 24 then
		Parts = Parts - PartsMax
		player:AddMaxHearts(2, false)
	end
end

pExodus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, pExodus.gluttonysStomachPickup)

function pExodus.gluttonysStomachRender()
    local player = Isaac.GetPlayer(0)

	local playerType = player:GetPlayerType()
	local Hearts = math.max(1, player:GetMaxHearts() / 2)
	local level = pExodus.Level
	local room = pExodus.Room
	
	if player:HasCollectible(pExodus.ItemId.GLUTTONYS_STOMACH) and playerType ~= PlayerType.PLAYER_THELOST and playerType ~= PlayerType.PLAYER_KEEPER and (level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN) and (room:GetType() ~= RoomType.ROOM_BOSS or room:GetFrameCount() >= 1) then
		RenderBar.Scale = Vector(1.3, 1.3)
		RenderBar:SetFrame("Heart", math.min(PartsMax, Parts))
		
		local heartDiv = math.floor((Hearts - 1) / 6)
		RenderBar:Render(HPPos + Vector(12 * (((Hearts - 1) % 6) + 1), (12 - (heartDiv / 2)) * heartDiv), pExodus.NullVector, pExodus.NullVector)
	elseif Parts > 0 and not player:HasCollectible(pExodus.ItemId.GLUTTONYS_STOMACH) then
		Parts = 0
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_RENDER, pExodus.gluttonysStomachRender)