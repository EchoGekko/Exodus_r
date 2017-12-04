------------------------
--<<<BASE VARIABLES>>>--
------------------------

-- Private mod table, used for base mod functionality that should not be publically visible
local Exodus = RegisterMod("Exodus", 1)

-- Public mod table, used for any functionality that has to be 'required'
pExodus = {}

-- Generic variables to be used by any code outside this main.lua to prevent calling game methods multiple times (Public)
pExodus.Game = Game()
pExodus.RNG = RNG()
pExodus.SFX = SFXManager()
pExodus.Music = MusicManager()
pExodus.ItemPool = pExodus.Game:GetItemPool()
pExodus.NullVector = Vector(0, 0)
pExodus.Players = {}
pExodus.PlayerCount = 0

----------------------
--<<<ENUMERATIONS>>>--
----------------------

-- Champion flag values, used for champion filtering on custom entities (Public)
pExodus.ChampionFlag = {
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
    SKULL = 1<<23
}

-- The Item IDs of every item added by the mod (Public)
pExodus.ItemId = {
    ---<<PASSIVES>>---
    BEEHIVE = Isaac.GetItemIdByName("Beehive"),
    SAD_TEARS = Isaac.GetItemIdByName("Sad Tears"),
    BUSTED_PIPE = Isaac.GetItemIdByName("Busted Pipe"),
    UNHOLY_MANTLE = Isaac.GetItemIdByName("Unholy Mantle"),
    TECH_360 = Isaac.GetItemIdByName("Tech 360"),
    PAPER_CUT = Isaac.GetItemIdByName("Paper Cut"),
    FORGET_ME_LATER = Isaac.GetItemIdByName("Forget Me Later"),
    DRAGON_BREATH = Isaac.GetItemIdByName("Dragon Breath"),
    COBALT_NECKLACE = Isaac.GetItemIdByName("Cobalt Necklace"),
    PIG_BLOOD = Isaac.GetItemIdByName("Pig Blood"),
    DADS_BOOTS = Isaac.GetItemIdByName("Dad's Boots"),
    MYSTERIOUS_MUSTACHE = Isaac.GetItemIdByName("Mysterious Mustache"),
    CURSED_METRONOME = Isaac.GetItemIdByName("Cursed Metronome"),
    BIG_SCISSORS = Isaac.GetItemIdByName("Big Scissors"),
    WELCOME_MAT = Isaac.GetItemIdByName("Welcome Mat"),
    GLUTTONYS_STOMACH = Isaac.GetItemIdByName("Gluttony's Stomach"),
    POSSESSED_BOMBS = Isaac.GetItemIdByName("Possessed Bombs"),
    BUTTROT = Isaac.GetItemIdByName("Buttrot"),
    SLING = Isaac.GetItemIdByName("Sling"),
    YIN = Isaac.GetItemIdByName("Yin"),
    YANG = Isaac.GetItemIdByName("Yang"),
    DEJA_VU = Isaac.GetItemIdByName("Deja Vu"),
    FOOLS_GOLD = Isaac.GetItemIdByName("Fool's Gold"),
    MAKEUP_REMOVER = Isaac.GetItemIdByName("Makeup Remover"),
    ARCADE_TOKEN = Isaac.GetItemIdByName("Arcade Token"),
    HAND_OF_GREED = Isaac.GetItemIdByName("Hand of Greed"),
    CLOCK_PIECE_1 = Isaac.GetItemIdByName("Clock Piece 1"),
    CLOCK_PIECE_2 = Isaac.GetItemIdByName("Clock Piece 2"),
    CLOCK_PIECE_3 = Isaac.GetItemIdByName("Clock Piece 3"),
    CLOCK_PIECE_4 = Isaac.GetItemIdByName("Clock Piece 4"),
    THE_APOCRYPHON = Isaac.GetItemIdByName("The Apocryphon"),
    
    ---<<ACTIVES>>---
    FORBIDDEN_FRUIT = Isaac.GetItemIdByName("The Forbidden Fruit"),
    WRATH_OF_THE_LAMB = Isaac.GetItemIdByName("Wrath of the Lamb"),
    BIRDBATH = Isaac.GetItemIdByName("Birdbath"),
    OMINOUS_LANTERN = Isaac.GetItemIdByName("Ominous Lantern"),
    BASEBALL_MITT = Isaac.GetItemIdByName("Baseball Mitt"),
    PSEUDOBULBAR_AFFECT = Isaac.GetItemIdByName("The Pseudobulbar Affect"),
    MUTANT_CLOVER = Isaac.GetItemIdByName("Mutant Clover"),
    TRAGIC_MUSHROOM = Isaac.GetItemIdByName("Tragic Mushroom"),
    ANAMNESIS = Isaac.GetItemIdByName("Anamnesis"),
    HURDLE_HEELS = Isaac.GetItemIdByName("Hurdle Heels"),
    FULLERS_CLUB = Isaac.GetItemIdByName("Fuller's Club"),
    
    ---<<FAMILIARS>>---
    HUNGRY_HIPPO = Isaac.GetItemIdByName("Hungry Hippo"),
    RITUAL_CANDLE = Isaac.GetItemIdByName("Ritual Candle"),
    ASTRO_BABY = Isaac.GetItemIdByName("Astro Baby"),
    LIL_RUNE = Isaac.GetItemIdByName("Lil Rune"),
    SUNDIAL = Isaac.GetItemIdByName("Sundial"),
    ROBOBABY_360 = Isaac.GetItemIdByName("Robo-Baby 3.6.0"),
    
    ---<<TRINKETS>>---
    GRID_WORM = Isaac.GetTrinketIdByName("Grid Worm"),
    BURLAP_SACK = Isaac.GetTrinketIdByName("Burlap Sack"),
    PET_ROCK = Isaac.GetTrinketIdByName("Pet Rock"),
    ROTTEN_PENNY = Isaac.GetTrinketIdByName("Rotten Penny"),
    BLUE_MOON = Isaac.GetTrinketIdByName("Blue Moon"),
    BROKEN_GLASSES = Isaac.GetTrinketIdByName("Broken Glasses"),
    BOMBS_SOUL = Isaac.GetTrinketIdByName("Bomb's Soul"),
    CLAUSTROPHOBIA = Isaac.GetTrinketIdByName("Claustrophobia"),
    FLYDER = Isaac.GetTrinketIdByName("Flyder")
}

----------------------------
--<<<ENTITY DECLARATION>>>--
----------------------------

-- Generic function used to easy get all used entity values by name (Private)
local function getEntity(stringName, intSubtype)
    if intSubtype == nil then 
        intSubtype = 0 
    end
    
    return { id = Isaac.GetEntityTypeByName(stringName), variant = Isaac.GetEntityVariantByName(stringName), subtype = Isaac.GetCardIdByName(stringName), name = stringName }
end

-- The Type, Variant and SubType of every entity added by the mod (Public)
pExodus.Entities = {
    ---<<EFFECTS>>---
    HONEY_SPLAT = getEntity("Honey Splat"),
    HONEY_POOF = getEntity("Honey Poof"),
    SCORE_DISPLAY = getEntity("Score Display"),
    CHARGE_BAR = getEntity("Charge Bar"),
    PENTAGRAM = getEntity("Pentagram"),
    SUMMONING_MARK = getEntity("Summoning Mark"),
    LANTERN_GIBS = getEntity("Lantern Gibs"),
    LANTERN_FIRE = getEntity("Lantern Fire"),
    PORTAL_DOOR = getEntity("Portal Door"),
    BASEBALL_HIT = getEntity("Baseball Hit"),
    IRON_LUNG_GAS = getEntity("Iron Lung Gas"),
    OCCULTIST_TEAR_MARKER = getEntity("Occultist Tear Marker"),
    PART_UP = getEntity("Part Up"),
    PART_UP_UP = getEntity("Part Up Up"),
    PART_UP_UP_UP = getEntity("Part Up Up Up"),
    PIT_GIBS = getEntity("Pit Gibs"),
    BLIGHT_SPLASH = getEntity("Blight Splash"),
    BLIGHT_STATUS_EFFECT = getEntity("Blight Status Effect"),
    HURDLE_JUMP = getEntity("Hurdle Jump"),
    
    ---<<FAMILIARS>>---
    HUNGRY_HIPPO = getEntity("Hungry Hippo"),
    CANDLE = getEntity("Candle"),
    ASTRO_BABY = getEntity("Astro Baby"),
    LIL_RUNE = getEntity("Lil Rune"),
    SUN = getEntity("Sundial Sun"),
    SHADOW = getEntity("Sundial Shadow"),
    ROBOBABY_360 = getEntity("Robobaby 3.6.0"),
    
    ---<<ENEMIES>>---
    POISON_MASTERMIND = getEntity("Poison Mastermind"),
    POISON_HEMISPHERE = getEntity("Poison Hemisphere"),
    DANK_DIP = getEntity("Dank Dip"),
    DROWNED_SHROOMMAN = getEntity("Drowned Mushroom"),
    SCARY_SHROOMMAN = getEntity("Scary Shroomman"),
    BLOCKAGE = getEntity("Blockage"),
    CLOSTER = getEntity("Closter"),
    FLYERBALL = getEntity("Flyerball"),
    IRON_LUNG = getEntity("Iron Lung"),
    OCCULTIST = getEntity("Occultist"),
    HALFBLIND = getEntity("Halfblind"),
    HEADCASE = getEntity("Headcase"),
    HOLLOWHEAD = getEntity("Hollowhead"),
    WOMBSHROOM = getEntity("Wombshroom"),
    CARRION_PRINCE = getEntity("Carrion Prince"),
    LITHOPEDION = getEntity("Lithopedion"),
    DEATHS_EYE = getEntity("Death's Eye"),
    FLESH_DEATHS_EYE = getEntity("Flesh Death's Eye"),
    LOVELY_FLY = getEntity("Lovely Fly"),
    SOULFUL_FLY = getEntity("Soulful Fly"),
    HATEFUL_FLY = getEntity("Hateful Fly"),
    HATEFUL_FLY_GHOST = getEntity("Hateful Fly Ghost"),
    HOTHEAD = getEntity("Hothead"),
    WINGLEADER = getEntity("Wingleader"),
    BROOD = getEntity("Brood"),
    PATRIARCH = getEntity("Patriarch"),
    
    ---<<OTHERS>>---
    BIRDBATH = getEntity("Birdbath"),
    LANTERN_TEAR = getEntity("Lantern Tear"),
    BASEBALL = getEntity("Baseball"),
    SCARED_HEART = getEntity("Exodus Scared Heart"),
    WELCOME_MAT = getEntity("Welcome Mat"),
    KEYHOLE = getEntity("Keyhole"),
    CLOCK_KEEPER = getEntity("Clock Keeper"),
    FIREBALL = getEntity("Fireball"),
    FIREBALL_2 = getEntity("Fireball 2"),
    BLIGHT_TEAR = getEntity("Blight Tear")
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
    BEEHIVE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Beehive.anm2"),
    SAD_TEARS = Isaac.GetCostumeIdByPath("gfx/characters/costume_Sad Tears.anm2"),
    BUSTED_PIPE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Busted Pipe.anm2"),
    UNHOLY_MANTLE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Unholy Mantle.anm2"),
    TECH_360 = Isaac.GetCostumeIdByPath("gfx/characters/costume_TechY.anm2"),
    PAPER_CUT = Isaac.GetCostumeIdByPath("gfx/characters/costume_Paper Cut.anm2"),
    DRAGON_BREATH = Isaac.GetCostumeIdByPath("gfx/characters/costume_Dragon Breath.anm2"),
    PIG_BLOOD = Isaac.GetCostumeIdByPath("gfx/characters/costume_Pig Blood.anm2"),
    DADS_BOOTS = Isaac.GetCostumeIdByPath("gfx/characters/costume_Dad's Boots.anm2"),
    CURSED_METRONOME = Isaac.GetCostumeIdByPath("gfx/characters/costume_Cursed Metronome.anm2"),
    MYSTERIOUS_MUSTACHE = Isaac.GetCostumeIdByPath("gfx/characters/costume_Mysterious Mustache.anm2"),
    POSSESSED_BOMBS = Isaac.GetCostumeIdByPath("gfx/characters/costume_Possessed Bombs.anm2"),
    BUTTROT = Isaac.GetCostumeIdByPath("gfx/characters/costume_Buttrot.anm2"),
    KEEPER_HAND_OF_GREED = Isaac.GetCostumeIdByPath("gfx/characters/costume_Keeper Hand of Greed.anm2"),
    HAND_OF_GREED = Isaac.GetCostumeIdByPath("gfx/characters/costume_Hand of Greed.anm2"),
    MAKEUP_REMOVER = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover.anm2"),
    MAKEUP_REMOVER_BLACK = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_black.anm2"),
    MAKEUP_REMOVER_BLUE = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_blue.anm2"),
    MAKEUP_REMOVER_GRAY = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_grey.anm2"),
    MAKEUP_REMOVER_WHITE = Isaac.GetCostumeIdByPath("gfx/characters/costume_MakeupRemover_white.anm2")
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
            SAD_TEARS = { HasSadTears = false },
            UNHOLY_MANTLE = { HasUnholyMantle = false, HasEffect = true },
            TECH_360 = { HasTech360 = false },
            RITUAL_CANDLE = { LitCandles = 0, HasBonus = false, Pentagram = nil, SoundPlayed = false },
            PIG_BLOOD = { HasPigBlood = false },
            WELCOME_MAT = { HasWelcomeMat = false, Position = NullVector, Direction = 0, CloseToMat = false, Placed = true, AppearFrame = nil },
            ASTRO_BABY = { UsedBox = 0 },
            ROBOBABY_360 = { UsedBox = 0 },
            LIL_RUNE = { HasLilRune = false, UsedBox = 0, State = "Purple", RuneType = 0 },
            POSSESSED_BOMBS = { HasPossessedBombs = false },
            MOLDY_BREAD = { GotFlies = false },
            CLAUSTROPHOBIA = { Triggered = false },
            ROTTEN_PENNY = { HasQuarter = false, HasDollar = false },
            SLING = { Icon = Sprite() },
            HOLY_WATER = { Splashed = false },
            FOOLS_GOLD = { HasFoolsGold = false },
            THE_APOCRYPHON = { HasBeenToAngel = false, ChangeBack = false, ApocDamage = 0, ApocTearDelay = 0, ApocSpeed = 0, ApocLuck = 0, ApocShotSpeed = 0, ApocRange = 0 },
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
            ANAMNESIS = { IsHolding = false, Charge = 0 },
            
            ---<<MISCELLANEOUS>>--
            CHARGE_BAR = { Bar = Sprite(), Scale = Vector(1, 1) },
            SUBROOM_CHARGE = {
                OMINOUS_LANTERN = { id = pExodus.ItemId.OMINOUS_LANTERN, frames = 0, Charge = 0 }
            }
        }
        
        -- Pre-start variable handling that could not be done in the table declaration
        pExodus.ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Load("gfx/effects/Pseudobulbar Icon.anm2", true)
        pExodus.ItemVariables.PSEUDOBULBAR_AFFECT.Icon:Play("Idle", true)
        
        pExodus.ItemVariables.SLING.Icon:Load("gfx/effects/Sling_marker_effect.anm2", true)
        pExodus.ItemVariables.SLING.Icon:Play("Idle", true)

        pExodus.ItemVariables.HURDLE_HEELS.Icon:Load("gfx/effects/Jump.anm2", true)
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
	pExodus.RNG:SetSeed(pExodus.Game:GetSeeds():GetStartSeed(), 0)
    math.randomseed(pExodus.Game:GetSeeds():GetStartSeed())
end

-- Initial variable definition
Exodus.newGame(false)

--------------------------------
--<<<BASE MOD FUNCTIONALITY>>>-- (Effectively a simple Exodus API)
--------------------------------

-- Stores all player entities in the pExodus.Players table with a reference and an index to the table
local function GetPlayers()
    pExodus.Players = {}
    pExodus.PlayerCount = pExodus.Game:GetNumPlayers()
    
    for i = 1, pExodus.PlayerCount do
        pExodus.Players[i] = { ref = Isaac.GetPlayer(i - 1), index = i }
    end
end

-- Returns a player table from pExodus.Players that matches the passed in player reference
function pExodus.GetPlayerByRef(ref)
    for i, player in ipairs(pExodus.Players) do
        if player.ref.Index == ref.Index and player.ref.InitSeed == ref.InitSeed then
            return player
        end
    end
end

-- Allows developers to easily tie a costume to an item by calling pExodus:AddItemCostume(ItemID, CostumeID) (Private)
local ItemCostumes = {}

function pExodus:AddItemCostume(item, costume)
	table.insert(ItemCostumes, { HasCostume = { false, false, false, false }, ItemId = item, CostumeId = costume })
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
	[ExodusCallbacks.MC_ADD_COLLECTIBLE] = { {}, {}, {}, {} },
	[ExodusCallbacks.MC_REMOVE_COLLECTIBLE] = { {}, {}, {}, {} }
}

-- Handles the setting up of custom callbacks to streamline development (Public)
function pExodus:AddCustomCallback(callback, func, params)
	if callback == ExodusCallbacks.MC_ADD_COLLECTIBLE then
		if params and type(params) == "number" then
            for i = 1, 4 do
                table.insert(CustomCalls[callback][i], { ItemCount = 0, ItemId = params, FunctionRef = func })
            end
		else
			error("Expected an item ID argument to MC_ADD_COLLECTIBLE callback.", 2)
		end
	elseif callback == ExodusCallbacks.MC_REMOVE_COLLECTIBLE then
		if params and type(params) == "number" then
            for i = 1, 4 do
                table.insert(CustomCalls[callback][i], { ItemCount = 0, ItemId = params, FunctionRef = func })
            end
		else
			error("Expected an item ID argument to MC_REMOVE_COLLECTIBLE callback.", 2)
		end
	end
end

-- Stores all function and parameters to use with the existing callbacks (Private)
local ExodusCalls = {
	[ModCallbacks.MC_POST_GAME_STARTED] = {},
    [ModCallbacks.MC_POST_UPDATE] = {},
    [ModCallbacks.MC_POST_RENDER] = {},
    [ModCallbacks.MC_POST_NEW_ROOM] = {},
    [ModCallbacks.MC_POST_NEW_LEVEL] = {},
    [ModCallbacks.MC_ENTITY_TAKE_DMG] = {},
    [ModCallbacks.MC_EVALUATE_CACHE] = {},
    [ModCallbacks.MC_POST_FIRE_TEAR] = {},
    [ModCallbacks.MC_NPC_UPDATE] = {},
    [ModCallbacks.MC_POST_NPC_INIT] = {},
	[ModCallbacks.MC_POST_TEAR_INIT] = {},
	[ModCallbacks.MC_PRE_PICKUP_COLLISION] = {},
    [ModCallbacks.MC_USE_CARD] = {}
}

--[[ (Public)
   Handles the setting up of existing callbacks to streamline development and increase mod efficiency 
   Some callbacks will only take zero to one arguments passed to the callback as a single value (Example: 5)
   Some callbacks will take multiple arguments that must always be passed in as a table regardless of how many arguments are being used (Example: { 5, 2, 3 })
]]
function pExodus:AddModCallback(callback, func, params)
    table.insert(ExodusCalls[callback], { FunctionRef = func, Parameters = params })
end

-- Runs all functions attached using an MC_POST_GAME_STARTED callback (Private)
function Exodus:PostGameStarted(fromSave)
    GetPlayers()
	Exodus.newGame(fromSave)

	for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_GAME_STARTED]) do
		if not functionTable.Parameters or functionTable.Parameters[1] == fromSave then
			functionTable.FunctionRef(fromSave)
		end
	end
end

Exodus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Exodus.PostGameStarted)

--[[ (Private)
   Runs all functions attached using an MC_POST_UPDATE callback
   Runs all functions attached using an MC_ADD_COLLECTIBLE callback
   Runs all functions attached using an MC_REMOVE_COLLECTIBLE callback
   Handles adding and removing of costumes tied to items using pExodus:AddItemCostume()
]]
function Exodus:PostUpdate()
    GetPlayers()
    
	for pIndex = 1, pExodus.PlayerCount do
        local exodusPlayer = pExodus.Players[pIndex]
        local player = exodusPlayer.ref
        
        for u, functionTable in ipairs(CustomCalls[ExodusCallbacks.MC_ADD_COLLECTIBLE][pIndex]) do
            local itemCount = player:GetCollectibleNum(functionTable.ItemId)
            
            if functionTable.ItemCount < itemCount then
                for i = functionTable.ItemCount, itemCount - 1 do
                    functionTable.FunctionRef(exodusPlayer)
                end
            end
            
            functionTable.ItemCount = itemCount
        end
        
        for u, functionTable in ipairs(CustomCalls[ExodusCallbacks.MC_REMOVE_COLLECTIBLE][pIndex]) do
            local itemCount = player:GetCollectibleNum(functionTable.ItemId)
            local noneLeft = false
            
            if functionTable.ItemCount > itemCount then
                for z = functionTable.ItemCount - 1, itemCount, -1 do
                    if z == 0 then
                        noneLeft = true
                    end
                    
                    functionTable.FunctionRef(exodusPlayer, noneLeft)
                end
            end
            
            functionTable.ItemCount = itemCount
        end
        
        for u, costumeTable in ipairs(ItemCostumes) do
            if player:HasCollectible(costumeTable.ItemId) then
                if not costumeTable.HasCostume[pIndex] then
                    player:AddNullCostume(costumeTable.CostumeId)
                    costumeTable.HasCostume[pIndex] = true
                end
            elseif costumeTable.HasCostume[pIndex] then
                player:TryRemoveNullCostume(costumeTable.CostumeId)
                costumeTable.HasCostume[pIndex] = false
            end
        end
    end
    
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_UPDATE]) do
        functionTable.FunctionRef()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.PostUpdate)

-- Runs all functions attached using an MC_POST_RENDER callback (Private)
function Exodus:PostRender()
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_RENDER]) do
        functionTable.FunctionRef()
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_RENDER, Exodus.PostRender)

--[[ (Private)
   Runs all functions attached using an MC_ENTITY_TAKE_DMG callback
   Allows the passing of a Type, Variant and SubType as arguments to the callback (in that order) to streamline development and prevent unnecessary function calls
]]
function Exodus:EntityTakeDamage(entity, dmgAmount, dmgFlags, dmgSource, invulnFrames)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_ENTITY_TAKE_DMG]) do
		local returnVal;
        
		if not functionTable.Parameters then
			returnVal = functionTable.FunctionRef(entity, dmgAmount, dmgFlags, dmgSource, invulnFrames)
		elseif entity.Type == functionTable.Parameters[1] then
            if not functionTable.Parameters[2] or functionTable.Parameters[2] == npc.Variant then
                if not functionTable.Parameters[3] or functionTable.Parameters[3] == npc.SubType then
                    returnVal = functionTable.FunctionRef(entity, dmgAmount, dmgFlags, dmgSource, invulnFrames)
                end
            end
        end
        
		if returnVal ~= nil then
			return returnVal
		end
    end
end

Exodus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Exodus.EntityTakeDamage)

--[[ (Private)
   Runs all functions attached using an MC_POST_NEW_ROOM callback
   Passes the current room into the attached function to streamline development and prevent unnecessary function calls
]]
function Exodus:PostNewRoom()
    GetPlayers()
    
    local room = pExodus.Game:GetRoom()
    pExodus.Room = room
    
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_NEW_ROOM]) do
        functionTable.FunctionRef(room)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.PostNewRoom)

--[[ (Private)
   Runs all functions attached using an MC_POST_NEW_LEVEL callback
   Passes the current level into the attached function to streamline development and prevent unnecessary function calls
]]
function Exodus:PostNewLevel()
    GetPlayers()
    
    local level = pExodus.Game:GetLevel()
    pExodus.Level = level
    
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_NEW_LEVEL]) do
        functionTable.FunctionRef(level)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exodus.PostNewLevel)

--[[ (Private)
   Runs all functions attached using an MC_EVALUATE_CACHE callback
   Allows the passing of a bitmask of cache flags to the callback to prevent unnecessary function calls
]]
function Exodus:EvaluateCache(player, cacheFlag)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_EVALUATE_CACHE]) do
        if functionTable.Parameters == nil or functionTable.Parameters & cacheFlag == cacheFlag then
            functionTable.FunctionRef(player, cacheFlag)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Exodus.EvaluateCache)

-- Runs all functions attached using an MC_POST_FIRE_TEAR callback (Private)
function Exodus:PostFireTear(tear)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_FIRE_TEAR]) do
        functionTable.FunctionRef(tear)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Exodus.PostFireTear)

-- Runs all functions attached using an MC_POST_TEAR_INIT callback (Private)
function Exodus:PostTearInit(tear)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_TEAR_INIT]) do
        functionTable.FunctionRef(tear)
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, Exodus.PostTearInit)

--[[ (Private)
   Runs all functions attached using an MC_NPC_UPDATE callback
   Allows the passing of a Type, Variant and SubType to the callback (in that order) to streamline development and prevent unnecessary function calls
]]
function Exodus:NpcUpdate(npc)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_NPC_UPDATE]) do
		if not functionTable.Parameters then
			functionTable.FunctionRef(npc)
        elseif functionTable.Parameters[1] == npc.Type then
            if not functionTable.Parameters[2] or functionTable.Parameters[2] == npc.Variant then
                if not functionTable.Parameters[3] or functionTable.Parameters[3] == npc.SubType then
                    functionTable.FunctionRef(npc)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_NPC_UPDATE, Exodus.NpcUpdate)

--[[ (Private)
   Runs all functions attached using an MC_POST_NPC_INIT callback
   Allows the passing of a Type, Variant and SubType to the callback (in that order) to streamline development and prevent unnecessary function calls
]]
function Exodus:PostNpcInit(npc)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_POST_NPC_INIT]) do
		if not functionTable.Parameters then
			functionTable.FunctionRef(npc)
        elseif functionTable.Parameters[1] == npc.Type then
            if not functionTable.Parameters[2] or functionTable.Parameters[2] == npc.Variant then
                if not functionTable.Parameters[3] or functionTable.Parameters[3] == npc.SubType then
                    functionTable.FunctionRef(npc)
                end
            end
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Exodus.PostNpcInit)

--[[ (Private)
   Runs all functions attached using an MC_PRE_PICKUP_COLLISION callback
   Allows the passing of a Variant and SubType to the callback (in that order) to streamline development and prevent unnecessary function calls
]]
function Exodus:PrePickupCollision(pickup, collider, low)
	for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_PRE_PICKUP_COLLISION]) do
		local returnVal;

		if not functionTable.Parameters then
			returnVal = functionTable.FunctionRef(pickup, collider, low)
        elseif functionTable.Parameters[1] == pickup.Variant then
			if not functionTable.Parameters[2] or functionTable.Parameters[2] == pickup.SubType then
				returnVal = functionTable.FunctionRef(pickup, collider, low)
			end
		end

		if returnVal ~= nil then
			return returnVal
		end
    end
end

Exodus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Exodus.PrePickupCollision)

--[[ (Private)
   Runs all functions attaches using an MC_USE_CARD callback
   Allows the passing of a Card ID to the callback to prevent unnecessary function calls
]]
function Exodus:UseCard(card)
    for i, functionTable in ipairs(ExodusCalls[ModCallbacks.MC_USE_CARD]) do
        if not functionTable.Parameters or functionTable.Parameters == card then
            functionTable.FunctionRef(card)
        end
    end
end

Exodus:AddCallback(ModCallbacks.MC_USE_CARD, Exodus.UseCard)

-------------------
--<<<REQUIRING>>>--
-------------------

-- All passive item Lua files that must be required
local PassivesToRequire = {
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
    "FoolsGold",
    "ForgetMeLater",
    "GluttonysStomach",
    "HandOfGreed",
    "MakeupRemover",
    "MysteriousMustache",
    "PaperCut",
    "PigBlood",
    "PossessedBombs",
    "SadTears",
    "Sling",
    "Tech360",
    "TheApocryphon",
    "UnholyMantle",
    "WelcomeMat",
    "Yang",
    "Yin"
}

-- Requires all necessary passive item Lua files
for index, item in ipairs(PassivesToRequire) do
    require("scripts/passives/item_" .. item)
end

-------------------------------
--<<<GENERIC MOD FUNCTIONS>>>-- (Most of these don't even get used)
-------------------------------

--<<<ENTITY REGISTRATION>>>--
function Exodus:RemoveFromRegister(entity)
    for i=1, #GameState.Register do
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

--[[
function Exodus:TestData()
    local entities = Isaac.GetRoomEntities()
    for i=1, #entities do    
        if entities[i]:IsVulnerableEnemy() and entities[i]:GetData().AddedToRegister ~= true then
            Exodus:AddToRegister(entities[i])
            entities[i]:GetData().AddedToRegister = true
        end
    end
    if GameState.Register[1] ~= nil then
        Isaac.DebugString("The Entity Register: " .. tostring(GameState.Register[1].Entity.Type))
    end
    if GameState.Register[2] ~= nil then
        Isaac.DebugString("The Entity Register: " .. tostring(GameState.Register[2].Entity.Type))
    end
end

Exodus:AddCallback(ModCallbacks.MC_POST_UPDATE, Exodus.TestData)
--]]

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

--[[ UNUSED AT THE MOMENT
function Exodus:FireXHoney(margin, v)
    local dir = rng:RandomInt(360)
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) then
        margin = 360
    end
      
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
        margin = 0
        
        for i = 1, 4 do
            EntityLaser.ShootAngle(7, v.Position, dir + (i * 90), 10, NullVector, v)
        end
    end
    
    for i = 1, 4 do
        Exodus:FireHoney(Vector.FromAngle(dir + math.random(((i - 1) * 90) - margin,((i - 1) * 90) + margin)) * 10, v)
    end
end

function Exodus:FireHoney(dir, v)
    local player = Isaac.GetPlayer(0)
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
        dir = dir / 100
    end
  
    local honey = Isaac.Spawn(EntityType.ENTITY_EFFECT, Entities.HONEY_SPLAT.variant, 0, v.Position, dir, v)
    honey.SpriteRotation = honey.Velocity:GetAngleDegrees()
    honey.GridCollisionClass = GridCollisionClass.COLLISION_WALL
end
]]