--[[
    VUI - TrufiGCD Advanced Filtering
    Version: 1.0.0
    Author: VortexQ8
    
    This file implements advanced filtering options for the TrufiGCD module:
    - Spell category filtering
    - Class/spec specific filters
    - Priority-based filtering
    - Cooldown-based filtering
    - Customizable whitelist/blacklist
    - Global cooldown filtering
    - Pet spell filtering
    - PvP/PvE context filtering
    - Content-specific presets (raid, M+, arena, etc.)
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.modules.trufigcd then return end

-- Namespaces
local TrufiGCD = VUI.modules.trufigcd
TrufiGCD.AdvancedFiltering = {}

-- Import frequently used globals into locals for performance
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local UnitClass = UnitClass
local IsSpellKnown = IsSpellKnown
local UnitLevel = UnitLevel
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local bit_band = bit.band
local tinsert, tremove, wipe = table.insert, table.remove, table.wipe
local floor = math.floor
local format = string.format

-- Default settings for advanced filtering
local advancedFilteringDefaults = {
    enabled = true,
    enableClassFilters = true,
    enableSpecFilters = true,
    enableCooldownFilters = true,
    enableCategoryFilters = true,
    enableContextFilters = true,
    ignoreGCD = true,
    ignoreEmptyIcons = true,
    minCooldown = 0,
    maxCooldown = 0, -- 0 means no maximum
    ignorePetSpells = false,
    showOnlyOnCooldown = false,
    filterByDuration = false,
    minDuration = 0,
    maxDuration = 0, -- 0 means no maximum
    filterOutRaidCooldowns = false,
    filterOutDefensives = false,
    useWhitelist = false,
    useBlacklist = false,
    showOnlyWhenInCombat = false,
    showIconCounts = true,
    maxIcons = 10,
    whitelist = {},
    blacklist = {},
    contextPresets = {
        enablePresets = true,
        currentPreset = "auto", -- Options: auto, raid, mythicplus, arena, battleground, world
        autoDetectContext = true,
    },
    spellCategories = {
        damage = true,
        healing = true,
        cooldown = true,
        interrupt = true,
        utility = true,
        defensive = true,
        movement = true,
        covenant = true,
        racial = true,
        petAbility = false,
        items = false,
        consumables = false,
        trinkets = true,
        misc = false,
    },
    classFilters = {}, -- Will be populated with class and spec specific filters
    spellIconCustomization = {
        customizeByCategory = true,
        categoryColors = {
            damage = {r = 0.9, g = 0.1, b = 0.1, a = 1.0},
            healing = {r = 0.1, g = 0.9, b = 0.1, a = 1.0},
            cooldown = {r = 0.8, g = 0.8, b = 0.1, a = 1.0},
            interrupt = {r = 1.0, g = 0.6, b = 0.1, a = 1.0},
            utility = {r = 0.6, g = 0.6, b = 0.6, a = 1.0},
            defensive = {r = 0.1, g = 0.6, b = 0.9, a = 1.0},
            movement = {r = 0.1, g = 0.9, b = 0.6, a = 1.0},
            covenant = {r = 0.8, g = 0.4, b = 0.8, a = 1.0},
            racial = {r = 0.7, g = 0.4, b = 0.1, a = 1.0},
            petAbility = {r = 0.5, g = 0.5, b = 0.5, a = 1.0},
            items = {r = 0.3, g = 0.7, b = 0.3, a = 1.0},
            trinkets = {r = 0.6, g = 0.3, b = 0.6, a = 1.0},
            misc = {r = 0.5, g = 0.5, b = 0.5, a = 1.0},
        },
    },
}

-- Category-based spell definitions
local spellCategories = {
    -- These are examples of important spells by category
    -- This would be expanded to include many more spells in a complete implementation
    
    -- Interrupts
    interrupt = {
        [1766] = true,   -- Kick (Rogue)
        [2139] = true,   -- Counterspell (Mage)
        [6552] = true,   -- Pummel (Warrior)
        [19647] = true,  -- Spell Lock (Warlock)
        [47528] = true,  -- Mind Freeze (Death Knight)
        [57994] = true,  -- Wind Shear (Shaman)
        [91802] = true,  -- Shambling Rush (Death Knight)
        [96231] = true,  -- Rebuke (Paladin)
        [106839] = true, -- Skull Bash (Druid)
        [115781] = true, -- Optical Blast (Warlock)
        [116705] = true, -- Spear Hand Strike (Monk)
        [132409] = true, -- Spell Lock (Warlock)
        [147362] = true, -- Counter Shot (Hunter)
        [183752] = true, -- Disrupt (Demon Hunter)
        [187707] = true, -- Muzzle (Hunter)
        [351338] = true, -- Quell (Evoker)
    },
    
    -- Defensive cooldowns
    defensive = {
        -- Death Knight
        [48707] = true,  -- Anti-Magic Shell
        [51052] = true,  -- Anti-Magic Zone
        [48792] = true,  -- Icebound Fortitude
        
        -- Demon Hunter
        [198589] = true, -- Blur
        [196555] = true, -- Netherwalk
        [187827] = true, -- Metamorphosis (Vengeance)
        
        -- Druid
        [22812] = true,  -- Barkskin
        [61336] = true,  -- Survival Instincts
        [102342] = true, -- Ironbark
        
        -- Evoker
        [363916] = true, -- Obsidian Scales
        [374348] = true, -- Renewing Blaze
        
        -- Hunter
        [186265] = true, -- Aspect of the Turtle
        [264735] = true, -- Survival of the Fittest
        
        -- Mage
        [45438] = true,  -- Ice Block
        [235450] = true, -- Prismatic Barrier
        [235313] = true, -- Blazing Barrier
        
        -- Monk
        [122470] = true, -- Touch of Karma
        [115203] = true, -- Fortifying Brew
        [122278] = true, -- Dampen Harm
        
        -- Paladin
        [642] = true,    -- Divine Shield
        [86659] = true,  -- Guardian of Ancient Kings
        [31850] = true,  -- Ardent Defender
        
        -- Priest
        [47585] = true,  -- Dispersion
        [33206] = true,  -- Pain Suppression
        [19236] = true,  -- Desperate Prayer
        
        -- Rogue
        [31224] = true,  -- Cloak of Shadows
        [5277] = true,   -- Evasion
        [185311] = true, -- Crimson Vial
        
        -- Shaman
        [108271] = true, -- Astral Shift
        [198103] = true, -- Earth Elemental
        
        -- Warlock
        [104773] = true, -- Unending Resolve
        [108416] = true, -- Dark Pact
        
        -- Warrior
        [871] = true,    -- Shield Wall
        [12975] = true,  -- Last Stand
        [118038] = true, -- Die by the Sword
    },
    
    -- Major offensive cooldowns
    damage = {
        -- Death Knight
        [47568] = true,  -- Empower Rune Weapon
        [275699] = true, -- Apocalypse
        
        -- Demon Hunter
        [191427] = true, -- Metamorphosis (Havoc)
        
        -- Druid
        [194223] = true, -- Celestial Alignment
        [106951] = true, -- Berserk
        [102543] = true, -- Incarnation: King of the Jungle
        
        -- Evoker
        [375087] = true, -- Dragonrage
        
        -- Hunter
        [193530] = true, -- Aspect of the Wild
        [288613] = true, -- Trueshot
        [266779] = true, -- Coordinated Assault
        
        -- Mage
        [12472] = true,  -- Icy Veins
        [190319] = true, -- Combustion
        
        -- Monk
        [137639] = true, -- Storm, Earth, and Fire
        [152173] = true, -- Serenity
        
        -- Paladin
        [31884] = true,  -- Avenging Wrath
        [231895] = true, -- Crusade
        
        -- Priest
        [10060] = true,  -- Power Infusion
        [194249] = true, -- Voidform
        
        -- Rogue
        [13750] = true,  -- Adrenaline Rush
        [121471] = true, -- Shadow Blades
        
        -- Shaman
        [114051] = true, -- Ascendance
        [51533] = true,  -- Feral Spirit
        
        -- Warlock
        [1122] = true,   -- Summon Infernal
        [205180] = true, -- Summon Darkglare
        
        -- Warrior
        [107574] = true, -- Avatar
        [1719] = true,   -- Recklessness
    },
    
    -- Movement abilities
    movement = {
        [1850] = true,   -- Dash (Druid)
        [2983] = true,   -- Sprint (Rogue)
        [100] = true,    -- Charge (Warrior)
        [1953] = true,   -- Blink (Mage)
        [36554] = true,  -- Shadowstep (Rogue)
        [109132] = true, -- Roll (Monk)
        [111400] = true, -- Burning Rush (Warlock)
        [190784] = true, -- Divine Steed (Paladin)
        [358267] = true, -- Hover (Evoker)
    },
    
    -- Healing abilities
    healing = {
        [740] = true,    -- Tranquility (Druid)
        [64843] = true,  -- Divine Hymn (Priest)
        [115310] = true, -- Revival (Monk)
        [108280] = true, -- Healing Tide Totem (Shaman)
        [31821] = true,  -- Aura Mastery (Paladin)
        [15286] = true,  -- Vampiric Embrace (Priest)
        [633] = true,    -- Lay on Hands (Paladin)
        [198838] = true, -- Earthen Wall Totem (Shaman)
        [203538] = true, -- Greater Blessing of Kings (Paladin)
        [33891] = true,  -- Tree of Life (Druid)
    },
    
    -- Utility spells
    utility = {
        [20484] = true,  -- Rebirth (Druid)
        [2825] = true,   -- Bloodlust (Shaman)
        [32182] = true,  -- Heroism (Shaman)
        [64901] = true,  -- Symbol of Hope (Priest)
        [29166] = true,  -- Innervate (Druid)
        [6940] = true,   -- Blessing of Sacrifice (Paladin)
        [102342] = true, -- Ironbark (Druid)
        [47788] = true,  -- Guardian Spirit (Priest)
        [33206] = true,  -- Pain Suppression (Priest)
    },
    
    -- Racial abilities
    racial = {
        [20594] = true,  -- Stoneform (Dwarf)
        [59752] = true,  -- Every Man for Himself (Human)
        [33697] = true,  -- Blood Fury (Orc)
        [26297] = true,  -- Berserking (Troll)
        [20572] = true,  -- Blood Fury (Orc)
        [7744] = true,   -- Will of the Forsaken (Undead)
        [28880] = true,  -- Gift of the Naaru (Draenei)
        [59545] = true,  -- Gift of the Naaru (Draenei)
        [59543] = true,  -- Gift of the Naaru (Draenei)
        [59544] = true,  -- Gift of the Naaru (Draenei)
        [121093] = true, -- Gift of the Naaru (Draenei)
        [20589] = true,  -- Escape Artist (Gnome)
        [69041] = true,  -- Rocket Barrage (Goblin)
        [69070] = true,  -- Rocket Jump (Goblin)
        [68992] = true,  -- Darkflight (Worgen)
    },
}

-- GCD spells that should be filtered out if ignoreGCD is enabled
local globalCooldownSpells = {
    -- This would be a large list of common GCD spells
    -- The implementation would filter these out when ignoreGCD is true
    -- Examples:
    [585] = true,    -- Smite (Priest)
    [100] = true,    -- Fireball (Mage)
    [8936] = true,   -- Regrowth (Druid)
    -- ... etc.
}

-- Store known pet abilities for filtering
local petAbilities = {
    -- Hunter pet abilities
    [17253] = true,   -- Bite
    [16827] = true,   -- Claw
    [386663] = true,  -- Desecrating Shot
    [393863] = true,  -- Dominion Over the Dead
    -- ... etc.
}

-- Initialize the module
function TrufiGCD:InitializeAdvancedFiltering()
    -- Register defaults if not already registered
    VUI.db.profile.modules.trufigcd.advancedFiltering = VUI.db.profile.modules.trufigcd.advancedFiltering or advancedFilteringDefaults
    
    -- Update any missing fields (for version compatibility)
    for k, v in pairs(advancedFilteringDefaults) do
        if VUI.db.profile.modules.trufigcd.advancedFiltering[k] == nil then
            VUI.db.profile.modules.trufigcd.advancedFiltering[k] = v
        end
        
        -- If it's a table, update any missing nested fields
        if type(v) == "table" and type(VUI.db.profile.modules.trufigcd.advancedFiltering[k]) == "table" then
            for nestedKey, nestedValue in pairs(v) do
                if VUI.db.profile.modules.trufigcd.advancedFiltering[k][nestedKey] == nil then
                    VUI.db.profile.modules.trufigcd.advancedFiltering[k][nestedKey] = nestedValue
                end
                
                -- If the nested value is also a table, update its fields too
                if type(nestedValue) == "table" and type(VUI.db.profile.modules.trufigcd.advancedFiltering[k][nestedKey]) == "table" then
                    for deepKey, deepValue in pairs(nestedValue) do
                        if VUI.db.profile.modules.trufigcd.advancedFiltering[k][nestedKey][deepKey] == nil then
                            VUI.db.profile.modules.trufigcd.advancedFiltering[k][nestedKey][deepKey] = deepValue
                        end
                    end
                end
            end
        end
    end
    
    -- Initialize player class and spec data
    self:InitializeClassData()
    
    -- Register options for the configuration UI
    self:RegisterAdvancedFilteringOptions()
    
    -- Register for spec change events
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnSpecChanged")
    
    -- Add context detection events
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnContextChanged")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnContextChanged")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnContextChanged")
    
    -- Advanced filtering system initialized
end

-- Initialize class-specific data
function TrufiGCD:InitializeClassData()
    local _, playerClass = UnitClass("player")
    self.playerClass = playerClass
    self.playerSpec = self:GetCurrentSpecialization()
    
    -- Set up class-specific filters if they don't exist yet
    if not VUI.db.profile.modules.trufigcd.advancedFiltering.classFilters[playerClass] then
        VUI.db.profile.modules.trufigcd.advancedFiltering.classFilters[playerClass] = {
            enabled = true,
            specs = {}
        }
        
        -- Initialize spec data
        for i = 1, GetNumSpecializations() do
            local id, name = GetSpecializationInfo(i)
            if id and name then
                VUI.db.profile.modules.trufigcd.advancedFiltering.classFilters[playerClass].specs[id] = {
                    enabled = true,
                    name = name,
                    spellWhitelist = {},
                    spellBlacklist = {}
                }
            end
        end
    end
end

-- Get the current specialization
function TrufiGCD:GetCurrentSpecialization()
    local specIndex = GetSpecialization()
    if specIndex then
        local specID = GetSpecializationInfo(specIndex)
        return specID
    end
    return nil
end

-- Event handler for spec changes
function TrufiGCD:OnSpecChanged()
    self.playerSpec = self:GetCurrentSpecialization()
    
    -- Update filtering for the new spec
    if VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.autoDetectContext then
        self:ApplyFilterPreset(VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset)
    end
end

-- Event handler for context changes (zone, group composition)
function TrufiGCD:OnContextChanged()
    -- Skip if auto-detection is disabled
    if not VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.autoDetectContext then
        return
    end
    
    -- Detect current context
    local currentContext = self:DetectCurrentContext()
    
    -- Update if context has changed
    if currentContext ~= VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset then
        VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset = currentContext
        self:ApplyFilterPreset(currentContext)
    end
end

-- Detect the current gameplay context
function TrufiGCD:DetectCurrentContext()
    -- Check if in arena
    local inArena = IsActiveBattlefieldArena()
    if inArena then
        return "arena"
    end
    
    -- Check if in battleground
    local inBattleground = UnitInBattleground("player")
    if inBattleground then
        return "battleground"
    end
    
    -- Check if in raid instance
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "raid" then
        return "raid"
    end
    
    -- Check if in mythic+ dungeon
    if instanceType == "party" and (difficultyID == 8 or difficultyID == 23) then
        return "mythicplus"
    end
    
    -- Default to world content
    return "world"
end

-- Apply a filter preset based on context
function TrufiGCD:ApplyFilterPreset(presetName)
    local settings = VUI.db.profile.modules.trufigcd.advancedFiltering
    
    -- Skip if presets are disabled
    if not settings.contextPresets.enablePresets then
        return
    end
    
    -- Apply preset settings based on context
    if presetName == "raid" then
        -- Show raid-relevant abilities
        settings.spellCategories.damage = true
        settings.spellCategories.healing = true
        settings.spellCategories.cooldown = true
        settings.spellCategories.utility = true
        settings.spellCategories.defensive = true
        settings.spellCategories.interrupt = false -- Less relevant in most raids
        settings.spellCategories.movement = false
        settings.spellCategories.trinkets = true
        settings.maxIcons = 10
        settings.ignoreGCD = true
        settings.showOnlyWhenInCombat = true
        
    elseif presetName == "mythicplus" then
        -- Show M+ relevant abilities
        settings.spellCategories.damage = true
        settings.spellCategories.healing = true
        settings.spellCategories.cooldown = true
        settings.spellCategories.interrupt = true -- Very important in M+
        settings.spellCategories.utility = true
        settings.spellCategories.defensive = true
        settings.spellCategories.movement = true
        settings.spellCategories.trinkets = true
        settings.maxIcons = 12
        settings.ignoreGCD = true
        settings.showOnlyWhenInCombat = false
        
    elseif presetName == "arena" then
        -- Show arena-relevant abilities
        settings.spellCategories.damage = true
        settings.spellCategories.healing = true
        settings.spellCategories.cooldown = true
        settings.spellCategories.interrupt = true
        settings.spellCategories.utility = true
        settings.spellCategories.defensive = true
        settings.spellCategories.movement = true
        settings.spellCategories.racial = true
        settings.spellCategories.trinkets = true
        settings.maxIcons = 15
        settings.ignoreGCD = false -- Show everything in arena
        settings.showOnlyWhenInCombat = false
        
    elseif presetName == "battleground" then
        -- Show battleground-relevant abilities
        settings.spellCategories.damage = true
        settings.spellCategories.healing = true
        settings.spellCategories.cooldown = true
        settings.spellCategories.interrupt = false
        settings.spellCategories.utility = true
        settings.spellCategories.defensive = true
        settings.spellCategories.movement = true
        settings.spellCategories.racial = true
        settings.spellCategories.trinkets = true
        settings.maxIcons = 10
        settings.ignoreGCD = true
        settings.showOnlyWhenInCombat = false
        
    else -- "world" or any other default
        -- Show default abilities for world content
        settings.spellCategories.damage = true
        settings.spellCategories.healing = false
        settings.spellCategories.cooldown = true
        settings.spellCategories.interrupt = false
        settings.spellCategories.utility = false
        settings.spellCategories.defensive = true
        settings.spellCategories.movement = false
        settings.spellCategories.racial = false
        settings.spellCategories.trinkets = true
        settings.maxIcons = 8
        settings.ignoreGCD = true
        settings.showOnlyWhenInCombat = false
    end
    
    -- Update UI to reflect changes
    self:UpdateFrames()
    
    -- Preset applied: layout optimized for current content type
end

-- Check if a spell passes the advanced filters
function TrufiGCD:FilterSpell(spellID)
    local settings = VUI.db.profile.modules.trufigcd.advancedFiltering
    
    -- Skip filtering if disabled
    if not settings.enabled then return true end
    
    -- Check if player is in combat if that filter is enabled
    if settings.showOnlyWhenInCombat and not UnitAffectingCombat("player") then
        return false
    end
    
    -- Filter by whitelist if enabled
    if settings.useWhitelist then
        return settings.whitelist[spellID] or false
    end
    
    -- Filter by blacklist if enabled
    if settings.useBlacklist and settings.blacklist[spellID] then
        return false
    end
    
    -- Get spell category
    local category = self:GetSpellCategory(spellID)
    
    -- Filter based on spell category
    if settings.enableCategoryFilters and category and not settings.spellCategories[category] then
        return false
    end
    
    -- Filter pet abilities if enabled
    if settings.ignorePetSpells and petAbilities[spellID] then
        return false
    end
    
    -- Filter GCD spells if enabled
    if settings.ignoreGCD and globalCooldownSpells[spellID] then
        return false
    end
    
    -- Filter based on class and spec if enabled
    if settings.enableClassFilters then
        -- Class filter
        if self.playerClass and settings.classFilters[self.playerClass] and not settings.classFilters[self.playerClass].enabled then
            return false
        end
        
        -- Spec filter
        if settings.enableSpecFilters and self.playerSpec and 
           settings.classFilters[self.playerClass] and 
           settings.classFilters[self.playerClass].specs[self.playerSpec] and
           not settings.classFilters[self.playerClass].specs[self.playerSpec].enabled then
            return false
        end
        
        -- Spec-specific blacklist
        if settings.enableSpecFilters and self.playerSpec and 
           settings.classFilters[self.playerClass] and 
           settings.classFilters[self.playerClass].specs[self.playerSpec] and
           settings.classFilters[self.playerClass].specs[self.playerSpec].spellBlacklist[spellID] then
            return false
        end
        
        -- Spec-specific whitelist (if not in whitelist and we're using spec whitelist)
        if settings.enableSpecFilters and self.playerSpec and 
           settings.classFilters[self.playerClass] and 
           settings.classFilters[self.playerClass].specs[self.playerSpec] and
           next(settings.classFilters[self.playerClass].specs[self.playerSpec].spellWhitelist) ~= nil and
           not settings.classFilters[self.playerClass].specs[self.playerSpec].spellWhitelist[spellID] then
            return false
        end
    end
    
    -- Pass all filters
    return true
end

-- Get the category of a spell
function TrufiGCD:GetSpellCategory(spellID)
    for category, spells in pairs(spellCategories) do
        if spells[spellID] then
            return category
        end
    end
    return "misc" -- Default category
end

-- Register configuration options for advanced filtering
function TrufiGCD:RegisterAdvancedFilteringOptions()
    -- Add to the module's options table when it's generated
    local originalGetOptions = self.GetOptions
    
    self.GetOptions = function(self)
        local options = originalGetOptions and originalGetOptions(self) or {}
        
        -- Ensure we have args table
        options.args = options.args or {}
        
        -- Add advanced filtering section
        options.args.advancedFilteringHeader = {
            type = "header",
            name = "Advanced Filtering",
            order = 100
        }
        
        options.args.advancedFilteringEnabled = {
            type = "toggle",
            name = "Enable Advanced Filtering",
            desc = "Toggle advanced spell filtering options",
            get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.enabled end,
            set = function(_, value)
                VUI.db.profile.modules.trufigcd.advancedFiltering.enabled = value
                self:UpdateFrames()
            end,
            width = "full",
            order = 101
        }
        
        -- Category filters group
        options.args.categoryFiltersGroup = {
            type = "group",
            name = "Spell Categories",
            inline = true,
            order = 102,
            disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled end,
            args = {
                enableCategoryFilters = {
                    type = "toggle",
                    name = "Filter By Category",
                    desc = "Enable filtering spells by their category",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 1
                },
                
                -- Add toggle for each spell category
                damageCategoryToggle = {
                    type = "toggle",
                    name = "Damage Abilities",
                    desc = "Show damage-dealing abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.damage end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.damage = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 2
                },
                
                healingCategoryToggle = {
                    type = "toggle",
                    name = "Healing Abilities",
                    desc = "Show healing abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.healing end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.healing = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 3
                },
                
                cooldownCategoryToggle = {
                    type = "toggle",
                    name = "Major Cooldowns",
                    desc = "Show major cooldown abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.cooldown end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.cooldown = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 4
                },
                
                interruptCategoryToggle = {
                    type = "toggle",
                    name = "Interrupt Abilities",
                    desc = "Show interrupt abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.interrupt end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.interrupt = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 5
                },
                
                defensiveCategoryToggle = {
                    type = "toggle",
                    name = "Defensive Abilities",
                    desc = "Show defensive and survival abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.defensive end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.defensive = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 6
                },
                
                utilityCategoryToggle = {
                    type = "toggle",
                    name = "Utility Abilities",
                    desc = "Show utility abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.utility end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.utility = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 7
                },
                
                movementCategoryToggle = {
                    type = "toggle",
                    name = "Movement Abilities",
                    desc = "Show movement enhancing abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.movement end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.movement = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 8
                },
                
                racialCategoryToggle = {
                    type = "toggle",
                    name = "Racial Abilities",
                    desc = "Show racial abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.racial end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.racial = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 9
                },
                
                trinketsCategoryToggle = {
                    type = "toggle",
                    name = "Trinket Abilities",
                    desc = "Show trinket abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.trinkets end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.trinkets = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 10
                },
                
                petAbilityCategoryToggle = {
                    type = "toggle",
                    name = "Pet Abilities",
                    desc = "Show pet abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.petAbility end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.spellCategories.petAbility = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableCategoryFilters end,
                    width = "half",
                    order = 11
                },
            }
        }
        
        -- General filter options
        options.args.generalFiltersGroup = {
            type = "group",
            name = "General Filters",
            inline = true,
            order = 103,
            disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled end,
            args = {
                ignoreGCD = {
                    type = "toggle",
                    name = "Ignore Global Cooldown",
                    desc = "Filter out abilities that are on the global cooldown",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.ignoreGCD end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.ignoreGCD = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 1
                },
                
                ignorePetSpells = {
                    type = "toggle",
                    name = "Ignore Pet Spells",
                    desc = "Filter out pet abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.ignorePetSpells end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.ignorePetSpells = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 2
                },
                
                showOnlyWhenInCombat = {
                    type = "toggle",
                    name = "Show Only In Combat",
                    desc = "Only show spell icons when in combat",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.showOnlyWhenInCombat end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.showOnlyWhenInCombat = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 3
                },
                
                maxIcons = {
                    type = "range",
                    name = "Maximum Icons",
                    desc = "Maximum number of spell icons to show at once",
                    min = 1,
                    max = 30,
                    step = 1,
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.maxIcons end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.maxIcons = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 4
                },
            }
        }
        
        -- Context preset options
        options.args.contextPresetsGroup = {
            type = "group",
            name = "Context Presets",
            inline = true,
            order = 104,
            disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled end,
            args = {
                enablePresets = {
                    type = "toggle",
                    name = "Enable Context Presets",
                    desc = "Automatically switch filters based on your current game content",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.enablePresets end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.enablePresets = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 1
                },
                
                autoDetectContext = {
                    type = "toggle",
                    name = "Auto-Detect Content",
                    desc = "Automatically detect what type of content you're doing",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.autoDetectContext end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.autoDetectContext = value
                        -- If enabling, immediately detect content
                        if value then
                            local currentContext = self:DetectCurrentContext()
                            VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset = currentContext
                            self:ApplyFilterPreset(currentContext)
                        end
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.enablePresets end,
                    width = "full",
                    order = 2
                },
                
                currentPreset = {
                    type = "select",
                    name = "Current Preset",
                    desc = "Select which content preset to use",
                    values = {
                        auto = "Auto-Detect",
                        raid = "Raid",
                        mythicplus = "Mythic+",
                        arena = "Arena",
                        battleground = "Battleground",
                        world = "World Content"
                    },
                    get = function() 
                        return VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset 
                    end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset = value
                        if value ~= "auto" then
                            self:ApplyFilterPreset(value)
                        else
                            local currentContext = self:DetectCurrentContext()
                            self:ApplyFilterPreset(currentContext)
                        end
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.enablePresets end,
                    width = "full",
                    order = 3
                },
            }
        }
        
        -- List management header
        options.args.listManagementHeader = {
            type = "header",
            name = "Spell Lists",
            order = 110
        }
        
        -- Whitelist/Blacklist options
        options.args.spellListsGroup = {
            type = "group",
            name = "Whitelist & Blacklist",
            inline = true,
            order = 111,
            disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled end,
            args = {
                useWhitelist = {
                    type = "toggle",
                    name = "Use Whitelist",
                    desc = "Only show spells that are in your whitelist",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.useWhitelist end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.useWhitelist = value
                        -- If enabling whitelist, disable blacklist
                        if value then
                            VUI.db.profile.modules.trufigcd.advancedFiltering.useBlacklist = false
                        end
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 1
                },
                
                useBlacklist = {
                    type = "toggle",
                    name = "Use Blacklist",
                    desc = "Hide spells that are in your blacklist",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.useBlacklist end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.useBlacklist = value
                        -- If enabling blacklist, disable whitelist
                        if value then
                            VUI.db.profile.modules.trufigcd.advancedFiltering.useWhitelist = false
                        end
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 2
                },
                
                -- This would be expanded with a proper whitelist/blacklist management UI
                -- in a complete implementation
                whitelistHelp = {
                    type = "description",
                    name = "Use /trufigcd whitelist add <spellID> to add spells to whitelist\nUse /trufigcd whitelist remove <spellID> to remove spells from whitelist",
                    order = 3,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.useWhitelist end,
                },
                
                blacklistHelp = {
                    type = "description",
                    name = "Use /trufigcd blacklist add <spellID> to add spells to blacklist\nUse /trufigcd blacklist remove <spellID> to remove spells from blacklist",
                    order = 4,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.useBlacklist end,
                },
            }
        }
        
        -- Class filters header
        options.args.classFiltersHeader = {
            type = "header",
            name = "Class & Spec Filters",
            order = 120
        }
        
        -- Class/Spec filter options
        options.args.classSpecFiltersGroup = {
            type = "group",
            name = "Class & Specialization Filters",
            inline = true,
            order = 121,
            disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled end,
            args = {
                enableClassFilters = {
                    type = "toggle",
                    name = "Enable Class Filters",
                    desc = "Enable class-specific filtering",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.enableClassFilters end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.enableClassFilters = value
                        self:UpdateFrames()
                    end,
                    width = "full",
                    order = 1
                },
                
                enableSpecFilters = {
                    type = "toggle",
                    name = "Enable Spec Filters",
                    desc = "Enable specialization-specific filtering",
                    get = function() return VUI.db.profile.modules.trufigcd.advancedFiltering.enableSpecFilters end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.advancedFiltering.enableSpecFilters = value
                        self:UpdateFrames()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.advancedFiltering.enabled or not VUI.db.profile.modules.trufigcd.advancedFiltering.enableClassFilters end,
                    width = "full",
                    order = 2
                },
                
                -- This would be expanded with a proper class/spec filter UI
                -- in a complete implementation
                classSpecHelp = {
                    type = "description",
                    name = "Additional class and spec filtering options would be available here in the full implementation.",
                    order = 3,
                },
            }
        }
        
        return options
    end
end

-- Override the shouldDisplaySpell function to incorporate advanced filtering
local originalShouldDisplaySpell
if TrufiGCD.ShouldDisplaySpell then
    originalShouldDisplaySpell = TrufiGCD.ShouldDisplaySpell
    
    TrufiGCD.ShouldDisplaySpell = function(self, spellID)
        -- Call the original function
        local shouldDisplay = originalShouldDisplaySpell(self, spellID)
        
        -- Apply advanced filtering if original check passed
        if shouldDisplay and spellID then
            return self:FilterSpell(spellID)
        end
        
        return shouldDisplay
    end
end

-- Add slash command handlers for whitelist/blacklist management
local function HandleWhitelistCommand(...)
    local args = {...}
    local action = args[1]
    local spellID = tonumber(args[2])
    
    if not action or (action ~= "add" and action ~= "remove" and action ~= "list" and action ~= "clear") then
        VUI:Print("Usage: /trufigcd whitelist add|remove|list|clear [spellID]")
        return
    end
    
    if action == "list" then
        VUI:Print("TrufiGCD Whitelist:")
        local count = 0
        for id in pairs(VUI.db.profile.modules.trufigcd.advancedFiltering.whitelist) do
            local name = GetSpellInfo(id) or "Unknown Spell"
            VUI:Print(string.format("  %d - %s", id, name))
            count = count + 1
        end
        if count == 0 then
            VUI:Print("  No spells in whitelist")
        end
        return
    end
    
    if action == "clear" then
        wipe(VUI.db.profile.modules.trufigcd.advancedFiltering.whitelist)
        VUI:Print("TrufiGCD whitelist cleared")
        TrufiGCD:UpdateFrames()
        return
    end
    
    if not spellID then
        VUI:Print("Please provide a valid spell ID")
        return
    end
    
    local name = GetSpellInfo(spellID)
    if not name then
        VUI:Print("Invalid spell ID: " .. spellID)
        return
    end
    
    if action == "add" then
        VUI.db.profile.modules.trufigcd.advancedFiltering.whitelist[spellID] = true
        VUI:Print(string.format("Added %s (%d) to TrufiGCD whitelist", name, spellID))
    elseif action == "remove" then
        VUI.db.profile.modules.trufigcd.advancedFiltering.whitelist[spellID] = nil
        VUI:Print(string.format("Removed %s (%d) from TrufiGCD whitelist", name, spellID))
    end
    
    TrufiGCD:UpdateFrames()
end

local function HandleBlacklistCommand(...)
    local args = {...}
    local action = args[1]
    local spellID = tonumber(args[2])
    
    if not action or (action ~= "add" and action ~= "remove" and action ~= "list" and action ~= "clear") then
        VUI:Print("Usage: /trufigcd blacklist add|remove|list|clear [spellID]")
        return
    end
    
    if action == "list" then
        VUI:Print("TrufiGCD Blacklist:")
        local count = 0
        for id in pairs(VUI.db.profile.modules.trufigcd.advancedFiltering.blacklist) do
            local name = GetSpellInfo(id) or "Unknown Spell"
            VUI:Print(string.format("  %d - %s", id, name))
            count = count + 1
        end
        if count == 0 then
            VUI:Print("  No spells in blacklist")
        end
        return
    end
    
    if action == "clear" then
        wipe(VUI.db.profile.modules.trufigcd.advancedFiltering.blacklist)
        VUI:Print("TrufiGCD blacklist cleared")
        TrufiGCD:UpdateFrames()
        return
    end
    
    if not spellID then
        VUI:Print("Please provide a valid spell ID")
        return
    end
    
    local name = GetSpellInfo(spellID)
    if not name then
        VUI:Print("Invalid spell ID: " .. spellID)
        return
    end
    
    if action == "add" then
        VUI.db.profile.modules.trufigcd.advancedFiltering.blacklist[spellID] = true
        VUI:Print(string.format("Added %s (%d) to TrufiGCD blacklist", name, spellID))
    elseif action == "remove" then
        VUI.db.profile.modules.trufigcd.advancedFiltering.blacklist[spellID] = nil
        VUI:Print(string.format("Removed %s (%d) from TrufiGCD blacklist", name, spellID))
    end
    
    TrufiGCD:UpdateFrames()
end

-- Register slash commands
local originalInitialize = TrufiGCD.Initialize
if originalInitialize then
    TrufiGCD.Initialize = function(self)
        -- Call original function
        originalInitialize(self)
        
        -- Initialize advanced filtering
        self:InitializeAdvancedFiltering()
        
        -- Register slash commands for whitelist/blacklist management
        if not SlashCmdList["TRUFIGCD"] then
            SLASH_TRUFIGCD1 = "/trufigcd"
            SlashCmdList["TRUFIGCD"] = function(msg)
                local args = {}
                for arg in string.gmatch(msg, "%S+") do
                    table.insert(args, arg)
                end
                
                local command = args[1]
                if not command then
                    VUI:Print("TrufiGCD commands:")
                    VUI:Print("  /trufigcd whitelist add|remove|list|clear [spellID]")
                    VUI:Print("  /trufigcd blacklist add|remove|list|clear [spellID]")
                    VUI:Print("  /trufigcd preset raid|mythicplus|arena|battleground|world")
                    VUI:Print("  /trufigcd config - Open configuration panel")
                    return
                end
                
                table.remove(args, 1) -- Remove the command
                
                if command == "whitelist" then
                    HandleWhitelistCommand(unpack(args))
                elseif command == "blacklist" then
                    HandleBlacklistCommand(unpack(args))
                elseif command == "preset" then
                    local preset = args[1]
                    if preset and (preset == "raid" or preset == "mythicplus" or preset == "arena" or preset == "battleground" or preset == "world") then
                        VUI.db.profile.modules.trufigcd.advancedFiltering.contextPresets.currentPreset = preset
                        self:ApplyFilterPreset(preset)
                        VUI:Print("Applied TrufiGCD preset: " .. preset)
                    else
                        VUI:Print("Usage: /trufigcd preset raid|mythicplus|arena|battleground|world")
                    end
                elseif command == "config" then
                    VUI:OpenConfigPanel("trufigcd")
                else
                    VUI:Print("Unknown TrufiGCD command: " .. command)
                end
            end
        end
    end
end