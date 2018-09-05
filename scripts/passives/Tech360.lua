local ItemId = pExodus.ItemId
local rng = RNG()
local Entities = pExodus.Entities

pExodus.ItemId.TECH_360 = Isaac.GetItemIdByName("Tech 360")
pExodus.CostumeId.TECH_360 = Isaac.GetCostumeIdByPath("gfx/characters/costume_TechY.anm2")
pExodus:AddItemCostume(pExodus.ItemId.TECH_360, pExodus.CostumeId.TECH_360)

local function GetTech360Size(player)
    local size = 1
    
    if player:HasCollectible(ItemId.BEEHIVE) then
        size = math.random(-3, 5)
    end
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
        size = size + 2
    end
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
        size = size / 2
    end
    
    return math.ceil(size * player.ShotSpeed)
end

function pExodus.tech360Update()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ItemId.TECH_360) then
		for i, entity in pairs(pExodus.RoomEntities) do 
			local data = entity:GetData()
			
			if entity.Type == EntityType.ENTITY_LASER and data.TechParent and data.Tech360 and data.LudoTear == nil then
				entity.Position = data.TechParent.Position
				entity.Velocity = data.TechParent.Velocity
			end
			
			if entity.Type == EntityType.ENTITY_TEAR and entity.Visible then
				if entity:ToTear().TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then
					entity.Visible = false
					
					local laser = player:FireTechXLaser(entity.Position, entity.Velocity, math.abs(player.TearHeight * 3))
					local laserData = laset:GetData()
					laser.TearFlags = laser.TearFlags | TearFlags.TEAR_CONTINUUM
					laser.Color = player.TearColor
					laserData.Tech360 = true
					laserData.LudoTear = entity
					entity.SpawnerType = EntityType.ENTITY_TEAR
				end
			elseif entity.Type == EntityType.ENTITY_LASER and data.Tech360 and data.LudoTear ~= nil then
				entity.Position = data.LudoTear.Position
				
				if entity.FrameCount % 50 == 0 then
					for u = 1, 6 do
						local laser = player:FireTechLaser(entity.Position, 3193, Vector.FromAngle(u * (60 + rng:RandomInt(11) - 5)), false, false)
						laser.TearFlags = laser.TearFlags | TearFlags.TEAR_SPECTRAL
						laser.Color = player.TearColor
						laser.DisableFollowParent = true
					end
				end
			end
			
			if entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= TearVariant.CHAOS_CARD and entity.Variant ~= Entities.LANTERN_TEAR.variant and entity.Variant ~= TearVariant.BOBS_HEAD and entity.SpawnerType == EntityType.ENTITY_PLAYER then
				entity:Remove()
				
				local laser = player:FireTechXLaser(player.Position, player.Velocity, 1)
				local laserData = laser:GetData()
				laser.TearFlags = laser.TearFlags | TearFlags.TEAR_CONTINUUM
				laser.Color = player.TearColor
				laserData.Tech360 = true
				laserData.TechParent = entity.Parent
				entity.SpawnerType = EntityType.ENTITY_TEAR
				
				if player:HasCollectible(ItemId.DRAGON_BREATH) then
					for i = 1, 16 do
						fire = Isaac.Spawn(1000, 51, 0, Vector(entity.Position.X, entity.Position.Y + entity:ToTear().Height), Vector(30, 0):Rotated(math.random(0, 360)), entity)
						fire:GetData().Putout = true
						fire:GetSprite():Play("FireStage03", true)
					end
				end
			elseif entity.SpawnerType == EntityType.ENTITY_FAMILIAR and entity.SpawnerVariant == FamiliarVariant.INCUBUS then
				entity:Remove()
				
				local laser = player:FireTechXLaser(player.Position, player.Velocity, 1)
				local laserData = laser:GetData()
				laser.TearFlags = laser.TearFlags | TearFlags.TEAR_CONTINUUM
				laser.Color = player.TearColor
				laserData.Tech360 = true
				laserData.TechParent = entity.Parent
				entity.SpawnerType = EntityType.ENTITY_TEAR
				
				if player:HasCollectible(ItemId.DRAGON_BREATH) then
					for i = 1, 16 do
						fire = Isaac.Spawn(1000, 51, 0, Vector(entity.Position.X, entity.Position.Y + entity:ToTear().Height), Vector(30, 0):Rotated(math.random(0, 360)), entity)
						fire:GetData().Putout = true
						fire:GetSprite():Play("FireStage03", true)
					end
				end
			end
			
			if entity.Type == EntityType.ENTITY_LASER and entity.SpawnerType == EntityType.ENTITY_PLAYER and entity.Variant == 2 and 
			(data.Tech360 or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) and data.IsFromRoboBaby == nil then
				entity.Color = player.TearColor
				entity = entity:ToLaser()
				
				if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) and entity.Radius > math.abs(player.TearHeight * 6)) or
				(entity.Radius > math.abs(player.TearHeight * 3) and player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) == false) then
					entity:Remove()
					
					for u = 1, 6 do
						local laser = player:FireTechLaser(entity.Position, 3193, Vector.FromAngle(u * (60 + rng:RandomInt(11) - 5)), false, false)
						laser.TearFlags = laser.TearFlags | TearFlags.TEAR_SPECTRAL
						laser.Color = player.TearColor
						laser.DisableFollowParent = true
					end
				elseif not(entity.Radius > math.abs(player.TearHeight * 3) and not player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) and entity.FrameCount < 80 then
						entity.Radius = 10
					else
						entity.Radius = entity.Radius + GetTech360Size(player)
					end
				end
			
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) and entity.FrameCount == 30 then
					entity:Remove()
					
					local laser = player:FireTechXLaser(entity.Position, RandomVector() * (entity.Radius / 20), entity.Radius)
					local laserData = laser:GetData()
					laser.TearFlags = laser.TearFlags | TearFlags.TEAR_CONTINUUM
					laser.Color = player.TearColor
					laserData.Tech360 = true
					laserData.TechParent = entity.Parent
					laserData.TechX = true
				end
			end
		end
	end
end

pExodus:AddCallback(ModCallbacks.MC_POST_UPDATE, pExodus.tech360Update)

function pExodus.tech360Cache(player, flag)
    if player:HasCollectible(ItemId.TECH_360) then
        if flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay * 3 - 2
        end
        if flag == CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight * 1.25
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.tech360Cache, CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE)