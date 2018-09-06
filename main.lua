------------------------
--<<<BASE VARIABLES>>>--
------------------------

-- Private mod table, used for base mod functionality that should not be publically visible
local Exodus = RegisterMod("Exodus", 1)

-- Public mod table, used for any functionality that has to be 'required'
pExodus = {}

-- Generic variables to be used by any code outside this main.lua to prevent calling game methods multiple times (Public)
pExodus.Game = Game()
pExodus.SFX = SFXManager()
pExodus.Music = MusicManager()
pExodus.ItemId = {}
pExodus.ItemPool = pExodus.Game:GetItemPool()
pExodus.NullVector = Vector(0, 0)
pExodus.Room = nil
pExodus.RoomEntities = nil

pExodus.PreventDMG = false
pExodus.LiftActive = false
pExodus.PreventPlayerCollision = false
pExodus.PreventNPCCollision = false

local rng = RNG()

----------------------
--<<<ENUMERATIONS>>>--
----------------------

-- Champion flag values, used for champion filtering on custom entities (Public)
pExodus.ChampionFlag = {
    NONE = 0,
    RED = 1,
    YELLOW = 1<<1,
    GREEN = 1<<2,
    ORANGE = 1<<3,
    DARK_BLUE = 1<<4,
    DARK_GREEN = 1<<5,
    SOLID_WHITE = 1<<6,
    GRAY = 1<<7,
    TRANSPARENT_WHITE = 1<<8,
    BLACK = 1<<9,
    PINK = 1<<10,
    PURPLE = 1<<11,
    DARK_RED = 1<<12,
    LIGHT_BLUE = 1<<13,
    CAMOUFLAGE = 1<<14,
    PULSING_GREEN = 1<<15,
    PULSING_GREY = 1<<16,
    LIGHT_WHITE = 1<<17,
    TINY = 1<<18,
    LARGE = 1<<19,
    PULSING_RED = 1<<20,
    PULSATING = 1<<21,
    CROWN = 1<<22,
    SKULL = 1<<23,
    ALL = 1<<24
}

----------------------------
--<<<ENTITY DECLARATION>>>--
----------------------------

-- Generic function used to easy get all used entity values by name (Private)
function pExodus.GetEntity(stringName)
    return { id = Isaac.GetEntityTypeByName(stringName), variant = Isaac.GetEntityVariantByName(stringName), subtype = Isaac.GetCardIdByName(stringName), name = stringName }
end

-- The Type, Variant and SubType of every entity added by the mod (Public)
pExodus.Entities = {
    ---<<EFFECTS>>---
    HONEY_SPLAT = pExodus.GetEntity("Honey Splat"),
    HONEY_POOF = pExodus.GetEntity("Honey Poof"),
    SCORE_DISPLAY = pExodus.GetEntity("Score Display"),
    CHARGE_BAR = pExodus.GetEntity("Charge Bar"),
    PENTAGRAM = pExodus.GetEntity("Pentagram"),
    SUMMONING_MARK = pExodus.GetEntity("Summoning Mark"),
    LANTERN_GIBS = pExodus.GetEntity("Lantern Gibs"),
    LANTERN_FIRE = pExodus.GetEntity("Lantern Fire"),
    PORTAL_DOOR = pExodus.GetEntity("Portal Door"),
    BASEBALL_HIT = pExodus.GetEntity("Baseball Hit"),
    IRON_LUNG_GAS = pExodus.GetEntity("Iron Lung Gas"),
    OCCULTIST_TEAR_MARKER = pExodus.GetEntity("Occultist Tear Marker"),
    PART_UP = pExodus.GetEntity("Part Up"),
    PART_UP_UP = pExodus.GetEntity("Part Up Up"),
    PART_UP_UP_UP = pExodus.GetEntity("Part Up Up Up"),
    PIT_GIBS = pExodus.GetEntity("Pit Gibs"),
    BLIGHT_SPLASH = pExodus.GetEntity("Blight Splash"),
    BLIGHT_STATUS_EFFECT = pExodus.GetEntity("Blight Status Effect"),
    HURDLE_JUMP = pExodus.GetEntity("Hurdle Jump"),
    
    ---<<FAMILIARS>>---
    HUNGRY_HIPPO = pExodus.GetEntity("Hungry Hippo"),
    CANDLE = pExodus.GetEntity("Candle"),
    LIL_RUNE = pExodus.GetEntity("Lil Rune"),
    SUN = pExodus.GetEntity("Sundial Sun"),
    SHADOW = pExodus.GetEntity("Sundial Shadow"),
    ROBOBABY_360 = pExodus.GetEntity("Robobaby 3.6.0"),
    
    ---<<ENEMIES>>---
    POISON_MASTERMIND = pExodus.GetEntity("Poison Mastermind"),
    POISON_HEMISPHERE = pExodus.GetEntity("Poison Hemisphere"),
    DANK_DIP = pExodus.GetEntity("Dank Dip"),
    DROWNED_SHROOMMAN = pExodus.GetEntity("Drowned Mushroom"),
    SCARY_SHROOMMAN = pExodus.GetEntity("Scary Shroomman"),
    BLOCKAGE = pExodus.GetEntity("Blockage"),
    CLOSTER = pExodus.GetEntity("Closter"),
    FLYERBALL = pExodus.GetEntity("Flyerball"),
    IRON_LUNG = pExodus.GetEntity("Iron Lung"),
    OCCULTIST = pExodus.GetEntity("Occultist"),
    HALFBLIND = pExodus.GetEntity("Halfblind"),
    HEADCASE = pExodus.GetEntity("Headcase"),
    HOLLOWHEAD = pExodus.GetEntity("Hollowhead"),
    WOMBSHROOM = pExodus.GetEntity("Wombshroom"),
    CARRION_PRINCE = pExodus.GetEntity("Carrion Prince"),
    LITHOPEDION = pExodus.GetEntity("Lithopedion"),
    DEATHS_EYE = pExodus.GetEntity("Death's Eye"),
    FLESH_DEATHS_EYE = pExodus.GetEntity("Flesh Death's Eye"),
    LOVELY_FLY = pExodus.GetEntity("Lovely Fly"),
    SOULFUL_FLY = pExodus.GetEntity("Soulful Fly"),
    HATEFUL_FLY = pExodus.GetEntity("Hateful Fly"),
    HATEFUL_FLY_GHOST = pExodus.GetEntity("Hateful Fly Ghost"),
    HOTHEAD = pExodus.GetEntity("Hothead"),
    WINGLEADER = pExodus.GetEntity("Wingleader"),
    BROOD = pExodus.GetEntity("Brood"),
    PATRIARCH = pExodus.GetEntity("Patriarch"),
    
    ---<<OTHERS>>---
    BIRDBATH = pExodus.GetEntity("Birdbath"),
    LANTERN_TEAR = pExodus.GetEntity("Lantern Tear"),
    BASEBALL = pExodus.GetEntity("Baseball"),
    SCARED_HEART = pExodus.GetEntity("Exodus Scared Heart"),
    WELCOME_MAT = pExodus.GetEntity("Welcome Mat"),
    KEYHOLE = pExodus.GetEntity("Keyhole"),
    CLOCK_KEEPER = pExodus.GetEntity("Clock Keeper"),
    FIREBALL = pExodus.GetEntity("Fireball"),
    FIREBALL_2 = pExodus.GetEntity("Fireball 2"),
    BLIGHT_TEAR = pExodus.GetEntity("Blight Tear")
}

-- Error checking for entities to alert the developer to a mistyped name
for i, entity in pairs(pExodus.Entities) do
    if entity.id == -1 then
        error("Could not find a type for entity " .. entity.name, 1)
    elseif entity.variant == -1 then
        error("Could not find a variant for entity " .. entity.name, 1)
    end
end

-------------------------------
--<<<CHARACTER DECLARATION>>>--
-------------------------------

-- The Type of every character added by the mod (Public)
pExodus.Characters = {
    JAMES = Isaac.GetPlayerTypeByName("James")
}

-----------------------------
--<<<COSTUME DECLARATION>>>--
-----------------------------

-- The Costume IDs of every costume used by the mod (Public)
pExodus.CostumeId = {
    UNHOLY_MANTLE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Unholy Mantle.anm2"),
}

-------------------------------------
--<<<MUSIC AND SOUND DECLARATION>>>--
-------------------------------------

-- The Music IDs of every music file used by the mod (Public)
pExodus.MusicId = {
    LOCUS = Isaac.GetMusicIdByName("Locus"),
    TYRANNICIDE = Isaac.GetMusicIdByName("Tyrannicide")
}

-- The Sound IDs of every sound file used by the mod (Public)
pExodus.SoundId = {
    SOUND_SUPER_JUMP = Isaac.GetSoundIdByName("Super Jump")
}

------------------------------
--<<<VARIABLE DECLARATION>>>--
------------------------------

-- Organised tables to hold variables that have to be reset when a new run is started (Public)
pExodus.ItemVariables = {}
pExodus.EntityVariables = {}

-- Table and module used to encode and decode data that must be saved to a file when a run is quit and continued (Private)
local GameState = {}
local json = require("json")

-- Function run every time a new game is started to define and reset all necessary variables (Private)
function Exodus.newGame(fromSave)
    if not fromSave then
        pExodus.ItemVariables = {
            ---<<PASSIVES>>---
            UNHOLY_MANTLE = { HasUnholyMantle = false, HasEffect = true },
            TECH_360 = { HasTech360 = false },
            RITUAL_CANDLE = { LitCandles = 0, HasBonus = false, Pentagram = nil, SoundPlayed = false },
            WELCOME_MAT = { HasWelcomeMat = false, Position = NullVector, Direction = 0, CloseToMat = false, Placed = true, AppearFrame = nil },
            LIL_RUNE = { HasLilRune = false, State = "Purple", RuneType = 0 },
            POSSESSED_BOMBS = { HasPossessedBombs = false },
            MOLDY_BREAD = { GotFlies = false },
            CLAUSTROPHOBIA = { Triggered = false },
            ROTTEN_PENNY = { HasQuarter = false, HasDollar = false },
            HOLY_WATER = { Splashed = false },
            FOOLS_GOLD = { HasFoolsGold = false },
            THE_APOCRYPHON = { HasBeenToAngel = false, ChangeBack = false },
            BROKEN_GLASSES = { Broke = false },
            
            ---<<ACTIVES>>---
            MUTANT_CLOVER = { Used = 0 },
            TRAGIC_MUSHROOM = { Uses = 0 },
            FORBIDDEN_FRUIT = { UseCount = 0 },
            BASEBALL_MITT = { Used = false, Lifted = true, BallsCaught = 0, UseDelay = 0 },
            PSEUDOBULBAR_AFFECT = { Icon = Sprite() },
            OMINOUS_LANTERN = { Fired = true, Lifted = false, Hid = false, LastEnemyHit = nil, FrameModifier = 300 },
            HURDLE_HEELS = { JumpState = 0, FrameUsed = 0, Icon = Sprite() },
            FULLERS_CLUB = { CollectibleList = {}, ClubDamage = 0, ClubTearDelay = 0, ClubSpeed = 0, ClubLuck = 0, ClubShotSpeed = 0, ClubRange = 0 },
            WRATH_OF_THE_LAMB = { Uses = {}, 
                Stats = {
                    Damage = 0,
                    Speed = 0,
                    Range = 0,
                    FireDelay = 0
                },
                Bosses = {
                    -- Stages 1 and 2
                    { EntityType.ENTITY_THE_HAUNT, EntityType.ENTITY_DINGLE, EntityType.ENTITY_MONSTRO, EntityType.ENTITY_LITTLE_HORN, EntityType.ENTITY_GURDY_JR, EntityType.ENTITY_FISTULA_BIG, EntityType.ENTITY_DUKE, EntityType.ENTITY_GEMINI, EntityType.ENTITY_RAG_MAN, EntityType.ENTITY_PIN, EntityType.ENTITY_WIDOW, EntityType.ENTITY_FAMINE, EntityType.ENTITY_GREED },
                    -- Stages 3 and 4
                    { EntityType.ENTITY_CHUB, EntityType.ENTITY_POLYCEPHALUS, EntityType.ENTITY_RAG_MEGA, EntityType.ENTITY_DARK_ONE, EntityType.ENTITY_MEGA_FATTY, EntityType.ENTITY_BIG_HORN, EntityType.ENTITY_MEGA_MAW, EntityType.ENTITY_PESTILENCE, EntityType.ENTITY_PEEP, EntityType.ENTITY_GURDY },
                    -- Stages 5 and 6
                    { EntityType.ENTITY_MONSTRO2, EntityType.ENTITY_ADVERSARY, EntityType.ENTITY_GATE, EntityType.ENTITY_LOKI, EntityType.ENTITY_MONSTRO2, EntityType.ENTITY_ADVERSARY, EntityType.ENTITY_BROWNIE, EntityType.ENTITY_WAR, EntityType.ENTITY_URIEL },
                    -- Stages 7 and 8
                    { EntityType.ENTITY_MR_FRED, EntityType.ENTITY_BLASTOCYST_BIG, EntityType.ENTITY_CAGE, EntityType.ENTITY_MASK_OF_INFAMY, EntityType.ENTITY_GABRIEL, EntityType.ENTITY_MAMA_GURDY },
                    -- Stage 9
                    { EntityType.ENTITY_FORSAKEN, EntityType.ENTITY_STAIN },
                    -- Stage 10
                    { EntityType.ENTITY_DEATH, EntityType.ENTITY_DADDYLONGLEGS, EntityType.ENTITY_SISTERS_VIS },
                    -- Others
                    { EntityType.ENTITY_MOMS_HEART, EntityType.ENTITY_SATAN, EntityType.ENTITY_ISAAC }
                }
            },
            
            ---<<MISCELLANEOUS>>--
            CHARGE_BAR = { Bar = Sprite(), Scale = Vector(1, 1) },
            SUBROOM_CHARGE = {
                OMINOUS_LANTERN = { id = pExodus.ItemId.OMINOUS_LANTERN, frames = 0, Charge = 0 }
            }
        }
        
        -- Pre-start variable handling that could not be done in the table declaration
        pExodus.ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Load("gfx/effects/Pseudobulbar Icon.anm2", true)
        pExodus.ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Play("Idle", true)

        pExodus.ItemVariables.HURDLE_HEELS.Icon:Load("gfx/effects/effect_hurdleheel.anm2", true)
        pExodus.ItemVariables.HURDLE_HEELS.Icon:Play("Idle", true)
        
        pExodus.ItemVariables.CHARGE_BAR.Bar:Load("gfx/ui/ui_chargebar2.anm2", true)
        
        pExodus.ItemVariables.SUBROOM_CHARGE.OMINOUS_LANTERN.frames = pExodus.ItemVariables.OMINOUS_LANTERN.FrameModifier
        
        pExodus.EntityVariables = {
            ---<<ENEMIES>>---
            FLYERBALL = { Fires = {} },
            HEADCASE = { DoLobbed = false },
            
            ---<<CHARACTERS>>---
            KEEPER = { ThirdHeart = 2, CurrentCoins = 0 },
            JAMES = { HasGivenItems = false },
            
            ---<<BETTER LOOPS>>---
            LOOPS = { Loop = 0, KeyFrame = 0, Keyhole = nil, IgnoreNegativeIndex = false, SSIndex = 0 }
        }
        
        -- Ensures the player's stats are properly reset along with the variables
        local player = Isaac.GetPlayer(0)
        if player then
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
    
	-- Ensures the RNG stays seeded to the run's seed
	rng:SetSeed(pExodus.Game:GetSeeds():GetStartSeed(), 0)
    math.randomseed(pExodus.Game:GetSeeds():GetStartSeed())
end

-- Initial variable definition
Exodus.newGame(false)

--------------------------------
--<<<BASE MOD FUNCTIONALITY>>>-- (Effectively a simple Exodus API)
--------------------------------

-- Allows developers to easily tie a costume to an item by calling pExodus:AddItemCostume(ItemID, CostumeID) (Private)
local ItemCostumes = {}

function pExodus:AddItemCostume(item, costume)
	table.insert(ItemCostumes, { HasCostume = { false, false, false, false }, ItemId = item, CostumeId = costume })
end

-- Allows developers to set a familiar variant to be checked on a familiar cache update
local FamiliarCaches = {}
local BoxOfFriendsUses = {}

function pExodus:SetupFamiliar(variant, itemId)
    table.insert(FamiliarCaches, { Variant = variant, ItemId = itemId })
end

local function HandleExcessFamiliars(familiar, itemId)
    local player = familiar.Player
    local ePlayer = pExodus.GetExodusPlayerByRef(player)
    local count = 1
    local expectedCount = player:GetCollectibleNum(itemId)
    
    if expectedCount > 0 and BoxOfFriendsUses[ePlayer.index] then
        expectedCount = expectedCount + BoxOfFriendsUses[ePlayer.index]
    end
    
    for i, ent in pairs(pExodus.RoomEntities) do
        local fam = ent:ToFamiliar()
        
        if fam and fam.Player.Index == player.Index and fam.Variant == familiar.Variant then
            if count < expectedCount then
                count = count + 1
            elseif count >= expectedCount then
                ent:Remove()
            end
        end
    end
    
    if count > expectedCount then
        familiar:Remove()
    end
end

-- Allows developer to setup an entity and limit its potential champion variants
local EntitiesToFilter = {}

function pExodus:SetupEntity(eTable, flags)
    table.insert(EntitiesToFilter, { EntityTable = eTable, ChampionFlags = flags })
end

-- Defining custom Exodus callbacks to make it easier to achieve certain functionalities (Public)
pExodus.ExodusCallbacks = {
	MC_ADD_COLLECTIBLE = 0,
	MC_REMOVE_COLLECTIBLE = 1
}

-- Private reference to the custom callbacks (Private)
local ExodusCallbacks = pExodus.ExodusCallbacks

-- Stores all functions and parameters to use with the custom callbacks (Private)
local CustomCalls = {
	[ExodusCallbacks.MC_ADD_COLLECTIBLE] = {},
	[ExodusCallbacks.MC_REMOVE_COLLECTIBLE] = {}
}

-- Handles the setting up of custom callbacks to streamline development (Public)
function pExodus:AddCustomCallback(callback, func, params)
	if callback == ExodusCallbacks.MC_ADD_COLLECTIBLE then
		if params and type(params) == "number" then
            table.insert(CustomCalls[callback], { ItemCount = 0, ItemId = params, FunctionRef = func })
		else
			error("Expected an item ID argument to MC_ADD_COLLECTIBLE callback.", 2)
		end
	elseif callback == ExodusCallbacks.MC_REMOVE_COLLECTIBLE then
		if params and type(params) == "number" then
            table.insert(CustomCalls[callback], { ItemCount = 0, ItemId = params, FunctionRef = func })
		else
			error("Expected an item ID argument to MC_REMOVE_COLLECTIBLE callback.", 2)
		end
	end
end

-- Stores all function and parameters to use with the existing callbacks (Private)
local ExodusCalls = {}

function pExodus:AddCallback(callback, func, ...)
    local functionTable = { FunctionRef = func, Parameters = ... }
    
    if ExodusCalls[callback] == nil then
        ExodusCalls[callback] = { functionTable }
    else
        table.insert(ExodusCalls[callback], functionTable)
    end
end

function Exodus:GenericFunction(callback, ...)
    local callbackParams = ...
    
    for i, functionTable in ipairs(ExodusCalls[callback]) do
        functionTable.FunctionRef(table.unpack(callbackParams))
    end
end

for i, callback in pairs(ModCallbacks) do
    ExodusCalls[callback] = {}
    Exodus:AddCallback(callback, function(exodus, ...) Exodus:GenericFunction(callback, {...}) end)
end

function Exodus:PostUpdate()
    
    pExodus.RoomEntities = Isaac.GetRoomEntities()

	local player = Isaac.GetPlayer(0)
	
	for u, functionTable in ipairs(CustomCalls[ExodusCallbacks.MC_ADD_COLLECTIBLE]) do
		local itemCount = player:GetCollectibleNum(functionTable.ItemId)
		
		if functionTable.ItemCount < itemCount then
			for i = functionTable.ItemCount, itemCount - 1 do
				functionTable.FunctionRef(1)
			end
		end
		
		functionTable.ItemCount = itemCount
	end
	
	for u, functionTable in ipairs(CustomCalls[ExodusCallbacks.MC_REMOVE_COLLECTIBLE]) do
		local itemCount = player:GetCollectibleNum(functionTable.ItemId)
		local noneLeft = false
		
		if functionTable.ItemCount > itemCount then
			for z = functionTable.ItemCount - 1, itemCount, -1 do
				if z == 0 then
					noneLeft = true
				end
				
				functionTable.FunctionRef(1, noneLeft)
			end
		end
		
		functionTable.ItemCount = itemCount
	end
	
	for u, costumeTable in ipairs(ItemCostumes) do
		if player:HasCollectible(costumeTable.ItemId) then
			if not costumeTable.HasCostume then
				player:AddNullCostume(costumeTable.CostumeId)
				costumeTable.HasCostume = true
			end
		elseif costumeTable.HasCostume then
			player:TryRemoveNullCostume(costumeTable.CostumeId)
			costumeTable.HasCostume = false
		end
	end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.PostUpdate)

function Exodus:EntityTakeDMG(target, amount, flag, source, cdtimer)
	local player = Isaac.GetPlayer(0)
	
    if target.Type == EntityType.ENTITY_PLAYER and pExodus.PreventDMG then
		pExodus.PreventDMG = false
		return false
	end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.EntityTakeDMG)

function Exodus:PlayerCollision(player, entity)
	local player = Isaac.GetPlayer(0)
	
    if pExodus.PreventPlayerCollision then
		pExodus.PreventPlayerCollision = false
		return false
	end
end

Exodus:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, Exodus.PlayerCollision)

function Exodus:NPCCollision(npc, entity)
	local player = Isaac.GetPlayer(0)
	
    if entity.Type == EntityType.ENTITY_PLAYER and pExodus.PreventNPCCollision then
		pExodus.PreventNPCCollision = false
		return false
	end
end

Exodus:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Exodus.NPCCollision)

function Exodus:PostNewRoom()
    local room = pExodus.Game:GetRoom()
    pExodus.Room = room
    pExodus.RoomEntities = Isaac.GetRoomEntities()
    
    BoxOfFriendsUses = {}
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.PostNewRoom)

function Exodus:PostNewLevel()
    local level = pExodus.Game:GetLevel()
    pExodus.Level = level
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Exodus.PostNewLevel)

function Exodus:EvaluateCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_FAMILIARS then
        for i, familiar in ipairs(FamiliarCaches) do
            if player:HasCollectible(familiar.ItemId) then
                player:CheckFamiliar(familiar.Variant, player:GetCollectibleNum(familiar.ItemId) + (BoxOfFriendsUses or 0), rng)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.EvaluateCache)

function Exodus:PostNpcInit(npc)
    for i, entity in ipairs(EntitiesToFilter) do
        local eTable = entity.EntityTable
        
        if npc.Type == eTable.id and npc.Variant == eTable.variant then
            if ((1<<npc:GetChampionColorIdx()) & entity.ChampionFlags) > 0 then
                npc:Morph(npc.id, npc.variant, npc.subtype, -1)
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Exodus.PostNpcInit)

function Exodus:UseItem(collectibleType, itemRng)
    if collectibleType == CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS then
		local player = Isaac.GetPlayer(0)
		
		if Input.GetActionValue(ButtonAction.ACTION_ITEM, player.ControllerIndex) > 0.0 and not player:NeedsCharge() then
			if not BoxOfFriendsUses then
				BoxOfFriendsUses = 1
			else
				BoxOfFriendsUses = BoxOfFriendsUses + 1
			end
		end
    end
	if pExodus.LiftActive then
		pExodus.LiftActive = false
		return true
	end
end

Exodus:AddCallback(ModCallbacks.MC_USE_ITEM, Exodus.UseItem)

function Exodus:FamiliarInit(familiar)
    if familiar.Variant == FamiliarVariant.DEMON_BABY then
        HandleExcessFamiliars(familiar, CollectibleType.COLLECTIBLE_DEMON_BABY)
    end
    
    for i, fam in ipairs(FamiliarCaches) do
        if familiar.Variant == fam.Variant then
            HandleExcessFamiliars(familiar, fam.ItemId)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Exodus.FamiliarInit)

-------------------
--<<<REQUIRING>>>--
-------------------

-- Requires all necessary passive item Lua files
for index, item in ipairs({
    "ArcadeToken", -- DONE
    "Beehive", -- DONE
    "BigScissors", -- DONE
    "BustedPipe", -- DONE
    "Buttrot", -- DONE
    "CobaltNecklace", -- DONE
    "CursedMetronome", -- DONE
	"DadsBoots", -- DONE
    "DejaVu", -- DONE
    "DragonBreath", -- DONE
    "FoolsGold", -- DONE
    "ForgetMeLater", -- DONE
    "GluttonysStomach", -- DONE
    "HandOfGreed", -- DONE
    "MakeupRemover", -- DONE
    "MysteriousMustache", -- DONE
    "PaperCut", -- DONE
    "PigBlood", -- DONE
    "PossessedBombs", -- DONE
    "SadTears", -- DONE
    "Sling", -- DONE
    "Tech360", -- DONE
    --"TheApocryphon", -- HOLD
    --"UnholyMantle", -- HOLD
    "WelcomeMat", -- DONE
    "Yang", -- DONE
    "Yin" -- DONE
}) do
    require("scripts/passives/" .. item)
end

-- Requires all necessary active item Lua files
for index, item in ipairs({
    "Anamnesis", -- DONE
    "BaseballMitt", -- DONE
    "Birdbath", -- DONE
    "ForbiddenFruit", -- DONE
    --"FullersClub", -- HOLD
    "HurdleHeels", -- DONE
    "MutantClover", -- DONE
    "OminousLantern", -- DONE
    "PseudobulbarAffect", -- DONE
    "TragicMushroom", -- DONE
    --"WrathOfTheLamb"
}) do
    require("scripts/actives/" .. item)
end

--[[
-- Requires all necessary trinket Lua files
for index, trinket in ipairs({
    "BlueMoon", -- OLD
    "BombsSoul",
    "BrokenGlasses",
    "BurlapSack",
    "Claustrophobia",
    "Flyder",
    "GridWorm",
    "PetRock",
    "RottenPenny"
}) do
    require("scripts/trinkets/" .. trinket)
end

-- Requires all necessary familiar Lua files
for index, familiar in ipairs({
    "AstroBaby", -- OLD
    "HungryHippo",
    "LilRune",
    "RitualCandle",
    "Robobaby360",
    "Sundial"
}) do
    require("scripts/familiars/" .. familiar)
end

-- Requires all necessary enemy Lua files
for index, enemy in ipairs({
    "Blockage", -- OLD
    "Brood",
    "CarrionPrince",
    "Closter",
    "DankDip",
    "DeathsEye",
    "DrownedShroomman",
    "FleshDeathsEye",
    "Flyerball",
    "Halfblind",
    "Headcase",
    "HeartFlies",
    "Hollowhead",
    "Hothead",
    "IronLung",
    "Lithopedion",
    "Occultist",
    "Patriarch",
    "PoisonHemisphere",
    "PoisonMastermind",
    "ScaryShroomman",
    "Wingleader",
    "Wombshroom"
}) do
    require("scripts/enemies/" .. enemy)
end
]]

-------------------------------
--<<<GENERIC MOD FUNCTIONS>>>-- (Most of these don't even get used)
-------------------------------

--<<<ENTITY REGISTRATION>>>--
function Exodus:RemoveFromRegister(entity)
    for i = 1, #GameState.Register do
        if GameState.Register[i].Room == game:GetLevel():GetCurrentRoomIndex() 
        and GameState.Register[i].Position.X == entity.Position.X 
        and GameState.Register[i].Position.Y == entity.Position.Y
        and GameState.Register[i].Entity.Type == entity.Type
        and GameState.Register[i].Entity.Variant == entity.Variant
        then
            table.remove(GameState.Register, i)
            break
        end
    end
end

function Exodus:SpawnRegister()
	local currentRoomIndex = game:GetLevel():GetCurrentRoomIndex()

    for i=1, #GameState.Register do
        if GameState.Register[i].Room == currentRoomIndex then
            local entity = Isaac.Spawn(GameState.Register[i].Type, GameState.Register[i].Variant, 0, GameState.Register[i].Position, NullVector, nil)
        end
    end
end

function Exodus:AddToRegister(entity)
    table.insert(GameState.Register, {
            Room = game:GetLevel():GetCurrentRoomIndex(),
            Position = entity.Position,
            Entity = {Type = entity.Type, Variant = entity.Variant}
        })
end

--<<<SAVING MOD DATA>>>--
function Exodus:OnStart()
    GameState = json.decode(Exodus:LoadData())
    if GameState.Register == nil then GameState.Register = {} end
end

Exodus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Exodus.OnStart)

function Exodus:OnExit()
    Exodus:SaveData(json.encode(GameState))
end

Exodus:AddCallback(ModCallbacks.MC_POST_GAME_END, Exodus.OnExit)
Exodus:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Exodus.OnExit)

function Exodus:OnNewGame(fromSave)
    local player = Isaac.GetPlayer(0)
    
    if not fromSave then
        GameState.Register = {}
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Exodus.OnNewGame)

--<<<OTHER FUNCTIONS>>>--
function pExodus.CompareEntities(ent1, ent2)
    if ent1 and ent2 then
        if ent1.Type == ent2.Type and ent1.Variant == ent2.Variant and ent1.SubType == ent2.SubType and ent1.Index == ent2.Index and ent1.InitSeed == ent2.InitSeed then
            return true
        end
    end
    
    return false
end

function pExodus:PlayerIsMoving(player)
    for i = 0, 3 do
        if Input.IsActionPressed(i, player.ControllerIndex) then
            return true
        end
    end
    
    return false
end

function pExodus:PlayTearSprite(tear, anm2)
    local sprite = tear:GetSprite()
    
    if anm2 then
        sprite:Load("gfx/" .. anm2, true)
    end
    
    if tear.CollisionDamage <= 0.5 then
        sprite:Play("RegularTear1", true)
    elseif tear.CollisionDamage <= 1 then
        sprite:Play("RegularTear2", true)
    elseif tear.CollisionDamage <= 1.5 then
        sprite:Play("RegularTear3", true)
    elseif tear.CollisionDamage <= 2 then
        sprite:Play("RegularTear4", true)
    elseif tear.CollisionDamage <= 3 then
        sprite:Play("RegularTear5", true)
    elseif tear.CollisionDamage <= 4.5 then
        sprite:Play("RegularTear6", true)
    elseif tear.CollisionDamage <= 6 then
        sprite:Play("RegularTear7", true)
    elseif tear.CollisionDamage <= 7.5 then
        sprite:Play("RegularTear8", true)
    elseif tear.CollisionDamage <= 9 then
        sprite:Play("RegularTear9", true)
    elseif tear.CollisionDamage <= 10.5 then
        sprite:Play("RegularTear10", true)
    elseif tear.CollisionDamage <= 15 then
        sprite:Play("RegularTear11", true)
    elseif tear.CollisionDamage < 20 then
        sprite:Play("RegularTear12", true)
    elseif tear.CollisionDamage >= 20 then
        sprite:Play("RegularTear13", true)
    end
end

function pExodus:GetEntityFromRef(entityRef)
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if ent.Index == entityRef.Entity.Index and ent.InitSeed == entityRef.Entity.InitSeed then
            return ent
        end
    end
end

function pExodus:HasPlayerChance(player, luckcap)
    if math.random(luckcap - math.min(player.Luck, luckcap) + 1) == 1 then
        return true
    else
        return false
    end
end

function Exodus:FakeChargeBarRender()
    local player = Isaac.GetPlayer(0)
    
    for i, item in pairs(pExodus.ItemVariables.SUBROOM_CHARGE) do
        if player:GetActiveItem() == item.id then
            if player:GetActiveItem() > 0 then
                pExodusItemVariables.CHARGE_BAR.Bar:SetFrame("BarEmpty",0)
                pExodus.ItemVariables.CHARGE_BAR.Bar.Scale = Vector(1, 1)
                pExodus.ItemVariables.CHARGE_BAR.Bar:Render(Vector(36, 17), pExodus.NullVector, pExodus.NullVector)
            end
            
            pExodus.ItemVariables.CHARGE_BAR.Bar:SetFrame("BarFull",0)
            pExodus.ItemVariables.CHARGE_BAR.Scale.Y = item.Charge / item.frames
            pExodus.ItemVariables.CHARGE_BAR.Bar.Scale = pExodus.ItemVariables.CHARGE_BAR.Scale
            
            local ChargePos = Vector(36, 17)
            ChargePos.Y = ChargePos.Y + 10 * (1 - pExodus.ItemVariables.CHARGE_BAR.Scale.Y)
            pExodus.ItemVariables.CHARGE_BAR.Bar:Render(ChargePos, pExodus.NullVector, pExodus.NullVector)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.FakeChargeBarRender)

function pExodus:GetRandomEnemyInTheRoom(entity) 
    local index = 1
    local possible = {}
  
    for i, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy(false) and entity:CanShutDoors() and entity.Position:DistanceSquared(entity.Position) < 250^2 then
            possible[index] = entity
            index = index + 1
        end
    end
  
    return possible[math.random(1, index)]
end

function pExodus:SpawnCandleTear(npc, isNormal)
    local target = pExodus:GetRandomEnemyInTheRoom(npc)

    if target ~= nil then
        local angle = (target.Position - npc.Position):GetAngleDegrees()
        local candleTear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, npc.Position, Vector.FromAngle(1 * angle):Resized(5), player):ToTear()
        
        candleTear.TearFlags = candleTear.TearFlags | TearFlags.TEAR_HOMING
        pExodus:PlayTearSprite(candleTear, "effect_psychictear.anm2")
        candleTear:GetData().AddedFireBonus = true
    end
end

function pExodus:SpawnGib(position, spawner, big)
    local YOffset = math.random(5, 20)
    local LanternGibs = Isaac.Spawn(EntityType.ENTITY_EFFECT, pExodus.Entities.LANTERN_GIBS.variant, 0, position, Vector(math.random(-20, 20), -1 * YOffset), spawner)
    local sprite = LanternGibs:GetSprite()
    
    LanternGibs:GetData().Offset = YOffset
    LanternGibs.SpriteRotation = math.random(360)
    
    if LanternGibs.FrameCount == 0 then
        if not big then
            sprite:Play("Gib0" .. tostring(math.random(2, 4)),false)
            sprite:Stop()
        elseif big then
            sprite:Play("Gib01",false)
            sprite:Stop()
        end
    end
end

function pExodus:FireLantern(pos, vel, anim)
    local player = Isaac.GetPlayer(0)
    
    if (pExodus.ItemVariables.OMINOUS_LANTERN.Fired == false or player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) and player:HasCollectible(pExodus.ItemId.OMINOUS_LANTERN) then 
        pExodus.ItemVariables.OMINOUS_LANTERN.LastEnemyHit = nil
        player:DischargeActiveItem()
        pExodus.ItemVariables.OMINOUS_LANTERN.Fired = true
        pExodus.ItemVariables.OMINOUS_LANTERN.Lifted = true
        
        local lantern = Isaac.Spawn(EntityType.ENTITY_TEAR, pExodus.Entities.LANTERN_TEAR.variant, 0, pos, vel + player.Velocity, player):ToTear()
        lantern.FallingSpeed = -10
        lantern.FallingAcceleration = 1
        
        if anim then
            player:AnimateCollectible(pExodus.ItemId.OMINOUS_LANTERN, "HideItem", "PlayerPickupSparkle")
        end
    end
end

function pExodus:FireTurretBullet(pos, vel, spawner)
    local player = Isaac.GetPlayer(0)
    local TurretBullet = player:FireTear(pos, vel, false, true, false)
    
    if spawner:IsBoss() then
        TurretBullet.CollisionDamage = TurretBullet.CollisionDamage * 1.5
        TurretBullet.Scale = TurretBullet.Scale * 1.5
    end
    
    local sprite = TurretBullet:GetSprite()
    sprite.Color = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B, sprite.Color.A, 100, 0, 0)
    
    pExodus:PlayTearSprite(TurretBullet, "Blood Tear.anm2")
end