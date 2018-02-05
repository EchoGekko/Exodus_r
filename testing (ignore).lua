local Exodus = RegisterMod("Exodus", 1)
local ExodusCalls = {}
local pExodus = { PlayerCount = 1, Players = { 1, 2, 3 }}

function pExodus:AddCallback(callback, func, params, multiplayer)
    local functionTable = { FunctionRef = func, Parameters = params or {}, Multiplayer = multiplayer or false }
    
    if ExodusCalls[callback] == nil then
        ExodusCalls[callback] = { functionTable }
    else
        table.insert(ExodusCalls[callback], functionTable)
    end
end

local function CheckParameters(callback, callbackParams, functionParams)
    if callback == ModCallbacks.MC_EVALUATE_CACHE then
        if callbackParams[2] == functionParams[1] then
            return true
        end
    elseif callback == ModCallbacks.MC_ENTITY_TAKE_DMG then
        if (callbackParams[1].Type == functionParams[1] or  functionParams[1]) and (callbackParams[1].Variant == functionParams[2] or not functionParams[2])
        and (callbackParams[1].SubType == functionParams[3] or not functionParams[3]) then
            return true
        end
    end
    
    return false
end

function Exodus:GenericFunction(callback, ...)
    local callbackParams = ...
    
    for i, functionTable in ipairs(ExodusCalls[callback]) do
        if CheckParameters(callback, callbackParams, functionTable.Parameters) then
            if functionTable.Multiplayer then
                for i = 1, pExodus.PlayerCount do
                    local params = {}
                    table.move(callbackParams, 1, #callbackParams, 1, params)
                    table.insert(params, pExodus.Players[i])
                    functionTable.FunctionRef(table.unpack(params))
                end
            else
                functionTable.FunctionRef(table.unpack(callbackParams))
            end
        end
    end
end

for i, callback in ipairs({
            ModCallbacks.MC_EVALUATE_CACHE,
            ModCallbacks.MC_ENTITY_TAKE_DMG
        }) do
    ExodusCalls[callback] = {}
    Exodus:AddCallback(callback, function(exodus, ...) Exodus:GenericFunction(callback, {...}) end)
end

function pExodus.damage(entity, amount, flags, source, frames, player)
    Isaac.ConsoleOutput("Player took damage")
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.damage, { EntityType.ENTITY_PLAYER }, true)