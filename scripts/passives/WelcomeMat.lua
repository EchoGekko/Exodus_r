local ItemId = pExodus.ItemId
local ItemVariables = pExodus.ItemVariables
local Entities = pExodus.Entities

pExodus.ItemId.WELCOME_MAT = Isaac.GetItemIdByName("Welcome Mat")

function pExodus.welcomeMatUpdate()
    local player = Isaac.GetPlayer(0)
    local room = pExodus.Game:GetRoom()

    if player:HasCollectible(ItemId.WELCOME_MAT) then
        if ItemVariables.WELCOME_MAT.Position ~= nil then
            if (player.Position:DistanceSquared(ItemVariables.WELCOME_MAT.Position) <= 100^2) then
                ItemVariables.WELCOME_MAT.CloseToMat = true
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            else
                ItemVariables.WELCOME_MAT.CloseToMat = false
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        end
    end
    
    if player:HasCollectible(ItemId.WELCOME_MAT) then
        if not ItemVariables.WELCOME_MAT.Placed then
            ItemVariables.WELCOME_MAT.Placed = true
            ItemVariables.WELCOME_MAT.AppearFrame = 0
            local mat = Isaac.Spawn(Entities.WELCOME_MAT.id, 0, 0, player.Position, Vector(0, 0), player)
            local sprite = mat:GetSprite()
            sprite:Play("Appear", false)
            mat.Visible = false
            
            ItemVariables.WELCOME_MAT.Position = mat.Position
            mat:Remove()
        elseif ItemVariables.WELCOME_MAT.AppearFrame ~= nil then
            local mat = Isaac.Spawn(Entities.WELCOME_MAT.id, 0, 0, ItemVariables.WELCOME_MAT.Position, Vector(0, 0), player)
            local sprite = mat:GetSprite()
            ItemVariables.WELCOME_MAT.AppearFrame = ItemVariables.WELCOME_MAT.AppearFrame + 1
            sprite:SetFrame("Appear", ItemVariables.WELCOME_MAT.AppearFrame)

            for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(i)
                
                if (door ~= nil) then
                    if (player.Position:DistanceSquared(door.Position) <= 100^2) then
                        ItemVariables.WELCOME_MAT.Direction = door.Direction
                    end
                end
            end
            
            if ItemVariables.WELCOME_MAT.Direction == Direction.LEFT then
                sprite.Rotation = sprite.Rotation + 90
            elseif ItemVariables.WELCOME_MAT.Direction == Direction.UP then
                sprite.Rotation = sprite.Rotation + 180
            elseif ItemVariables.WELCOME_MAT.Direction == Direction.RIGHT then
                sprite.Rotation = sprite.Rotation + 270
            end
            if ItemVariables.WELCOME_MAT.AppearFrame <= 3 then
                mat:Remove()
            elseif ItemVariables.WELCOME_MAT.AppearFrame == 11 then
                mat:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
                ItemVariables.WELCOME_MAT.AppearFrame = nil
            else
                mat:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
            end
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, pExodus.welcomeMatUpdate)

function pExodus.welcomeMatNewRoom()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.WELCOME_MAT) then
        ItemVariables.WELCOME_MAT.Placed = false
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, pExodus.welcomeMatNewRoom)

function pExodus.welcomeMatNewLevel()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ItemId.WELCOME_MAT) then
        ItemVariables.WELCOME_MAT.Placed = true
    end
end

pExodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, pExodus.welcomeMatNewLevel)

function pExodus.welcomeMatCache(player, flag)
    if ItemVariables.WELCOME_MAT.Position ~= nil then
        if flag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(ItemId.WELCOME_MAT) and ItemVariables.WELCOME_MAT.CloseToMat then
            player.MaxFireDelay = player.MaxFireDelay - 3
        end
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.welcomeMatCache)