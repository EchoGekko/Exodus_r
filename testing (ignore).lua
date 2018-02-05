local Exodus = RegisterMod("Exodus", 1)
local ExodusCalls = {}
local pExodus = { PlayerCount = 3, Players = { 1, 2, 3 }}

function pExodus:AddCallback(callback, func, params, multiplayer)
    local functionTable = { FunctionRef = func, Parameters = params, Multiplayer = multiplayer or false }
    
    if ExodusCalls[callback] == nil then
        ExodusCalls[callback] = { functionTable }
    else
        table.insert(ExodusCalls[callback], functionTable)
    end
end

function Exodus:GenericFunction(callback, callbackParams)
    for i, functionTable in ipairs(ExodusCalls[callback]) do
        local valid = true
        
        for u, param in pairs(functionTable.Parameters) do
            if param ~= callbackParams[u] then
                valid = false
                break
            end
        end
        
        if valid then
            if functionTable.Multiplayer then
                for i = 1, pExodus.PlayerCount do
                    functionTable.FunctionRef(pExodus.Players[i], callbackParams)
                end
            else
                functionTable.FunctionRef(callbackParams)
            end
        end
    end
end

for i, callback in ipairs({
            ModCallbacks.MC_EVALUATE_CACHE,
            ModCallbacks.MC_ENTITY_TAKE_DMG
        } do
    Exodus:AddCallback(callback, function(...) Exodus:GenericFunction(callback, {...}) end)
end

function pExodus.testFunction(params)
    for i, param in pairs(params) do
        print(tostring(param))
    end
end

pExodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pExodus.testFunction, { nil, CacheFlag.CACHE_DAMAGE })

function pExodus.testFunction2(player, params)
    print(tostring(player))
    for i, param in pairs(params) do
        print(tostring(param))
    end
end

pExodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, pExodus.testFunction2, { EntityType.ENTITY_PLAYER }, true)