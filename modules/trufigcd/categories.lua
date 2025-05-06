--[[
    VUI - TrufiGCD Spell Categorization
    Version: 1.0.0
    Author: VortexQ8
    
    This system classifies spells into functional categories with visual distinctions:
    - Organizes spells by role and importance
    - Provides visual cues based on spell type
    - Supports filtering and customization by category
    - Integrates with the existing icon customization system
]]

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.modules.trufigcd then return end

-- Create namespace
local TrufiGCD = VUI.modules.trufigcd
TrufiGCD.Categories = {}
local Categories = TrufiGCD.Categories

-- Import frequently used globals
local GetSpellInfo = GetSpellInfo
local select = select
local pairs, ipairs = pairs, ipairs
local tinsert = table.insert
local format = string.format

-- Spell category definitions (similar to BuffOverlay categories)
Categories.TYPES = {
    OFFENSIVE = {
        id = "offensive",
        name = "Offensive",
        priority = 10,
        description = "Damage-dealing abilities and offensive cooldowns",
        borderColor = {1.0, 0.3, 0.3, 1.0},      -- Red
        iconSize = 1.1,                          -- 10% larger than normal
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {1.0, 0.3, 0.3, 0.7}         -- Red glow
    },
    DEFENSIVE = {
        id = "defensive",
        name = "Defensive",
        priority = 20,
        description = "Damage reduction and survival abilities",
        borderColor = {0.2, 0.8, 0.2, 1.0},      -- Green
        iconSize = 1.15,                         -- 15% larger than normal
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {0.2, 0.8, 0.2, 0.7}         -- Green glow
    },
    HEALING = {
        id = "healing",
        name = "Healing",
        priority = 15,
        description = "Healing abilities and HoTs",
        borderColor = {0.0, 1.0, 0.0, 1.0},      -- Bright green
        iconSize = 1.1,                          -- 10% larger than normal
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {0.0, 1.0, 0.0, 0.7}         -- Bright green glow
    },
    UTILITY = {
        id = "utility",
        name = "Utility",
        priority = 30,
        description = "Movement, crowd control, and utility abilities",
        borderColor = {0.4, 0.4, 1.0, 1.0},      -- Blue
        iconSize = 1.0,                          -- Standard size
        glowEnabled = false
    },
    INTERRUPTS = {
        id = "interrupts",
        name = "Interrupts",
        priority = 25,
        description = "Spell interruption abilities",
        borderColor = {1.0, 0.6, 0.0, 1.0},      -- Orange
        iconSize = 1.2,                          -- 20% larger than normal
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {1.0, 0.6, 0.0, 0.7}         -- Orange glow
    },
    DISPELS = {
        id = "dispels",
        name = "Dispels",
        priority = 28,
        description = "Dispel and purge abilities",
        borderColor = {0.8, 0.0, 0.8, 1.0},      -- Purple
        iconSize = 1.05,                         -- 5% larger than normal
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {0.8, 0.0, 0.8, 0.7}         -- Purple glow
    },
    COOLDOWNS = {
        id = "cooldowns",
        name = "Major Cooldowns",
        priority = 5,
        description = "Major class and role cooldowns",
        borderColor = {1.0, 0.9, 0.0, 1.0},      -- Yellow/gold
        iconSize = 1.25,                         -- 25% larger than normal
        glowEnabled = true,
        glowType = "button",
        glowColor = {1.0, 0.9, 0.0, 0.9}         -- Bright yellow glow
    },
    STANDARD = {
        id = "standard",
        name = "Standard",
        priority = 50,
        description = "Regular rotational abilities",
        borderColor = {0.7, 0.7, 0.7, 0.8},      -- Gray
        iconSize = 1.0,                          -- Standard size
        glowEnabled = false
    }
}

-- Importance levels within categories
Categories.IMPORTANCE = {
    HIGH = {
        id = "high",
        priority = 10,
        iconSizeModifier = 1.1,
        glowIntensity = 1.2
    },
    MEDIUM = {
        id = "medium",
        priority = 20,
        iconSizeModifier = 1.0,
        glowIntensity = 1.0
    },
    LOW = {
        id = "low",
        priority = 30,
        iconSizeModifier = 0.9,
        glowIntensity = 0.8
    }
}

-- Table for storing spell categorization
Categories.spellCategories = {}
Categories.importanceMap = {}

-- Initialize defaults for module
function Categories:Initialize()
    -- Register spell categories with the configuration system
    self:RegisterConfig()
    
    -- Load default spell categories for all classes
    self:LoadDefaultCategories()
    
    -- Hook into the AddSpell function to apply categorization
    self:HookAddSpell()
    
    -- Register theme hook for colored borders
    VUI:RegisterCallback("ThemeChanged", function()
        self:UpdateThemeColors()
    end)
    
    -- Apply current theme colors
    self:UpdateThemeColors()
    
    VUI:Print("TrufiGCD spell categorization system initialized")
end

-- Add a spell to a category
function Categories:AddSpell(spellID, categoryType, importance)
    if not spellID then return end
    
    -- Default to standard if no category is provided
    categoryType = categoryType or "STANDARD"
    importance = importance or "MEDIUM"
    
    -- Store the categorization
    self.spellCategories[spellID] = categoryType
    self.importanceMap[spellID] = importance
end

-- Get the category for a spell
function Categories:GetSpellCategory(spellID)
    if not spellID then return self.TYPES.STANDARD end
    
    local categoryID = self.spellCategories[spellID]
    if not categoryID then
        return self.TYPES.STANDARD
    end
    
    return self.TYPES[categoryID] or self.TYPES.STANDARD
end

-- Get the importance for a spell
function Categories:GetSpellImportance(spellID)
    if not spellID then return self.IMPORTANCE.MEDIUM end
    
    local importanceID = self.importanceMap[spellID]
    if not importanceID then
        return self.IMPORTANCE.MEDIUM
    end
    
    return self.IMPORTANCE[importanceID] or self.IMPORTANCE.MEDIUM
end

-- Apply categorization to a spell frame
function Categories:ApplyToFrame(frame, spellID)
    if not frame or not spellID then return end
    
    local category = self:GetSpellCategory(spellID)
    local importance = self:GetSpellImportance(spellID)
    
    -- Apply size modifier based on category and importance
    local baseSize = TrufiGCD.db.iconSize or 32
    local categorySize = category.iconSize or 1.0
    local importanceSize = importance.iconSizeModifier or 1.0
    local newSize = baseSize * categorySize * importanceSize
    
    frame:SetSize(newSize, newSize)
    
    -- Apply border color
    if frame.border and category.borderColor then
        frame.border:SetVertexColor(
            category.borderColor[1],
            category.borderColor[2],
            category.borderColor[3],
            category.borderColor[4] or 1.0
        )
    end
    
    -- Apply glow effect if enabled for this category
    if category.glowEnabled and TrufiGCD.IconCustomization then
        local glowColor = category.glowColor
        local glowIntensity = importance.glowIntensity or 1.0
        
        -- Use the IconCustomization system to apply glow
        if TrufiGCD.IconCustomization.ApplyGlow then
            TrufiGCD.IconCustomization.ApplyGlow(
                frame,
                category.glowType or "pixel",
                {
                    glowColor[1],
                    glowColor[2],
                    glowColor[3],
                    (glowColor[4] or 1.0) * glowIntensity
                }
            )
        end
    end
end

-- Hook into the AddSpell function to apply categorization
function Categories:HookAddSpell()
    -- Store original function
    local originalAddSpell = TrufiGCD.AddSpell
    
    -- Replace with new function that applies categorization
    TrufiGCD.AddSpell = function(self, spellID, texture, name)
        -- Call original function first
        originalAddSpell(self, spellID, texture, name)
        
        -- Apply categorization to visible frames
        for i, frame in ipairs(self.frames) do
            if frame:IsShown() and frame.spellID then
                Categories:ApplyToFrame(frame, frame.spellID)
            end
        end
    end
end

-- Update theme colors
function Categories:UpdateThemeColors()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Adjust colors based on theme
    if theme == "phoenixflame" then
        -- Warm color variants for Phoenix Flame theme
        self.TYPES.OFFENSIVE.borderColor = {1.0, 0.4, 0.1, 1.0} -- More orange-red
        self.TYPES.COOLDOWNS.borderColor = {1.0, 0.7, 0.0, 1.0} -- More golden
    elseif theme == "thunderstorm" then
        -- Cool color variants for Thunder Storm theme
        self.TYPES.OFFENSIVE.borderColor = {0.9, 0.2, 0.2, 1.0} -- Deeper red
        self.TYPES.UTILITY.borderColor = {0.2, 0.5, 1.0, 1.0}  -- Brighter blue
    elseif theme == "arcanemystic" then
        -- Mystical color variants for Arcane Mystic theme
        self.TYPES.DISPELS.borderColor = {0.9, 0.2, 1.0, 1.0}  -- Brighter purple
        self.TYPES.COOLDOWNS.borderColor = {0.8, 0.5, 1.0, 1.0} -- Arcane purple-gold
    elseif theme == "felenergy" then
        -- Fel color variants for Fel Energy theme
        self.TYPES.HEALING.borderColor = {0.1, 0.9, 0.1, 1.0}  -- More fel green
        self.TYPES.OFFENSIVE.borderColor = {0.8, 1.0, 0.2, 1.0} -- Fel yellow-green
    end
    
    -- Update glow colors to match border colors
    for category, data in pairs(self.TYPES) do
        if data.glowEnabled and data.borderColor then
            data.glowColor = {
                data.borderColor[1],
                data.borderColor[2],
                data.borderColor[3],
                0.7 -- Lower alpha for glow
            }
        end
    end
end

-- Register with config system
function Categories:RegisterConfig()
    -- Add to existing TrufiGCD config
    local originalGetConfig = TrufiGCD.GetConfig
    
    TrufiGCD.GetConfig = function(self)
        local config = originalGetConfig(self)
        
        -- Add categories section
        config.args.categories = {
            type = "group",
            name = "Spell Categories",
            desc = "Configure spell categories and visual styling",
            order = 10,
            args = {
                enableCategories = {
                    type = "toggle",
                    name = "Enable Spell Categories",
                    desc = "Enable or disable spell categorization system",
                    get = function() return VUI.db.profile.modules.trufigcd.enableCategories end,
                    set = function(_, value) 
                        VUI.db.profile.modules.trufigcd.enableCategories = value
                        TrufiGCD:UpdateFrames()
                    end,
                    width = "full",
                    order = 1
                },
                spacer1 = {
                    type = "description",
                    name = " ",
                    order = 2
                },
                categoryInfo = {
                    type = "description",
                    name = "Spell categories add visual distinctions to different types of abilities in your cast history. Each category has unique visual styling.",
                    order = 3,
                    fontSize = "medium",
                },
                spacer2 = {
                    type = "description",
                    name = " ",
                    order = 4
                }
            }
        }
        
        -- Add each category to config
        local order = 5
        for id, data in pairs(self.TYPES) do
            config.args.categories.args[string.lower(id)] = {
                type = "toggle",
                name = data.name,
                desc = data.description,
                get = function() 
                    return VUI.db.profile.modules.trufigcd.categories[string.lower(id)] 
                end,
                set = function(_, value) 
                    VUI.db.profile.modules.trufigcd.categories[string.lower(id)] = value
                    TrufiGCD:UpdateFrames()
                end,
                width = "full",
                order = order
            }
            order = order + 1
        end
        
        return config
    end
end

-- Load default spell categories for all classes
function Categories:LoadDefaultCategories()
    -- Death Knight
    self:AddClassSpells("DEATHKNIGHT")
    
    -- Demon Hunter
    self:AddClassSpells("DEMONHUNTER")
    
    -- Druid
    self:AddClassSpells("DRUID")
    
    -- Hunter
    self:AddClassSpells("HUNTER")
    
    -- Mage
    self:AddClassSpells("MAGE")
    
    -- Monk
    self:AddClassSpells("MONK")
    
    -- Paladin
    self:AddClassSpells("PALADIN")
    
    -- Priest
    self:AddClassSpells("PRIEST")
    
    -- Rogue
    self:AddClassSpells("ROGUE")
    
    -- Shaman
    self:AddClassSpells("SHAMAN")
    
    -- Warlock
    self:AddClassSpells("WARLOCK")
    
    -- Warrior
    self:AddClassSpells("WARRIOR")
    
    -- Evoker
    self:AddClassSpells("EVOKER")
    
    -- Add generally important spells
    self:AddGeneralSpells()
end

-- Add class-specific spell categorizations
function Categories:AddClassSpells(class)
    if class == "DEATHKNIGHT" then
        -- Death Knight offensive cooldowns
        self:AddSpell(49028, "COOLDOWNS", "HIGH")      -- Dancing Rune Weapon
        self:AddSpell(47568, "COOLDOWNS", "HIGH")      -- Empower Rune Weapon
        self:AddSpell(275699, "COOLDOWNS", "HIGH")     -- Apocalypse
        self:AddSpell(42650, "COOLDOWNS", "HIGH")      -- Army of the Dead
        self:AddSpell(49206, "COOLDOWNS", "HIGH")      -- Summon Gargoyle
        self:AddSpell(48707, "DEFENSIVE", "HIGH")      -- Anti-Magic Shell
        self:AddSpell(48792, "DEFENSIVE", "HIGH")      -- Icebound Fortitude
        self:AddSpell(55233, "DEFENSIVE", "HIGH")      -- Vampiric Blood
        self:AddSpell(48743, "DEFENSIVE", "HIGH")      -- Death Pact
        self:AddSpell(51052, "COOLDOWNS", "HIGH")      -- Anti-Magic Zone
        self:AddSpell(108199, "UTILITY", "MEDIUM")     -- Gorefiend's Grasp
        self:AddSpell(47528, "INTERRUPTS", "MEDIUM")   -- Mind Freeze
        
        -- Regular abilities
        self:AddSpell(49998, "OFFENSIVE", "MEDIUM")    -- Death Strike
        self:AddSpell(47541, "OFFENSIVE", "LOW")       -- Death Coil
        self:AddSpell(85948, "OFFENSIVE", "LOW")       -- Festering Strike
        self:AddSpell(77575, "OFFENSIVE", "LOW")       -- Outbreak
        self:AddSpell(55090, "OFFENSIVE", "LOW")       -- Scourge Strike
    elseif class == "DEMONHUNTER" then
        -- Demon Hunter offensive cooldowns
        self:AddSpell(191427, "COOLDOWNS", "HIGH")     -- Metamorphosis (Havoc)
        self:AddSpell(187827, "COOLDOWNS", "HIGH")     -- Metamorphosis (Vengeance)
        self:AddSpell(162264, "COOLDOWNS", "HIGH")     -- Metamorphosis (General)
        self:AddSpell(198589, "OFFENSIVE", "HIGH")     -- Blur
        self:AddSpell(196718, "DEFENSIVE", "HIGH")     -- Darkness
        self:AddSpell(212084, "DEFENSIVE", "HIGH")     -- Fel Devastation
        self:AddSpell(206803, "DEFENSIVE", "HIGH")     -- Rain from Above
        self:AddSpell(204021, "DEFENSIVE", "HIGH")     -- Fiery Brand
        self:AddSpell(202137, "UTILITY", "MEDIUM")     -- Sigil of Silence
        self:AddSpell(202138, "UTILITY", "MEDIUM")     -- Sigil of Chains
        self:AddSpell(207684, "UTILITY", "MEDIUM")     -- Sigil of Misery
        self:AddSpell(183752, "UTILITY", "MEDIUM")     -- Disrupt (Interrupt)
        self:AddSpell(196718, "DEFENSIVE", "HIGH")     -- Darkness
        
        -- Regular abilities
        self:AddSpell(162243, "OFFENSIVE", "LOW")      -- Demon's Bite
        self:AddSpell(201427, "OFFENSIVE", "MEDIUM")   -- Annihilation
        self:AddSpell(210152, "OFFENSIVE", "MEDIUM")   -- Death Sweep
        self:AddSpell(203782, "OFFENSIVE", "LOW")      -- Shear
        self:AddSpell(228478, "OFFENSIVE", "LOW")      -- Soul Cleave
    elseif class == "DRUID" then
        -- Druid offensive cooldowns
        self:AddSpell(194223, "COOLDOWNS", "HIGH")     -- Celestial Alignment
        self:AddSpell(102560, "COOLDOWNS", "HIGH")     -- Incarnation: Chosen of Elune
        self:AddSpell(106951, "COOLDOWNS", "HIGH")     -- Berserk
        self:AddSpell(102543, "COOLDOWNS", "HIGH")     -- Incarnation: King of the Jungle
        self:AddSpell(33891, "COOLDOWNS", "HIGH")      -- Incarnation: Tree of Life
        self:AddSpell(102558, "COOLDOWNS", "HIGH")     -- Incarnation: Guardian of Ursoc
        self:AddSpell(61336, "DEFENSIVE", "HIGH")      -- Survival Instincts
        self:AddSpell(22812, "DEFENSIVE", "HIGH")      -- Barkskin
        self:AddSpell(29166, "COOLDOWNS", "HIGH")      -- Innervate
        self:AddSpell(740, "HEALING", "HIGH")          -- Tranquility
        self:AddSpell(77764, "UTILITY", "MEDIUM")      -- Stampeding Roar
        
        -- Healing spells
        self:AddSpell(18562, "HEALING", "MEDIUM")      -- Swiftmend
        self:AddSpell(33763, "HEALING", "LOW")         -- Lifebloom
        self:AddSpell(8936, "HEALING", "LOW")          -- Regrowth
        self:AddSpell(774, "HEALING", "LOW")           -- Rejuvenation
        self:AddSpell(48438, "HEALING", "MEDIUM")      -- Wild Growth
        
        -- Utility
        self:AddSpell(2908, "UTILITY", "MEDIUM")       -- Soothe
        self:AddSpell(20484, "UTILITY", "MEDIUM")      -- Rebirth
        self:AddSpell(2782, "DISPELS", "MEDIUM")       -- Remove Corruption
    elseif class == "HUNTER" then
        -- Hunter offensive cooldowns
        self:AddSpell(193530, "COOLDOWNS", "HIGH")     -- Aspect of the Wild
        self:AddSpell(19574, "COOLDOWNS", "HIGH")      -- Bestial Wrath
        self:AddSpell(288613, "COOLDOWNS", "HIGH")     -- Trueshot
        self:AddSpell(266779, "COOLDOWNS", "HIGH")     -- Coordinated Assault
        self:AddSpell(186257, "DEFENSIVE", "HIGH")     -- Aspect of the Cheetah
        self:AddSpell(186265, "DEFENSIVE", "HIGH")     -- Aspect of the Turtle
        self:AddSpell(109304, "DEFENSIVE", "HIGH")     -- Exhilaration
        self:AddSpell(187650, "DEFENSIVE", "HIGH")     -- Freezing Trap
        self:AddSpell(186387, "UTILITY", "MEDIUM")     -- Bursting Shot
        self:AddSpell(147362, "INTERRUPTS", "MEDIUM")  -- Counter Shot
        
        -- Regular abilities
        self:AddSpell(217200, "OFFENSIVE", "LOW")      -- Barbed Shot
        self:AddSpell(34026, "OFFENSIVE", "LOW")       -- Kill Command
        self:AddSpell(193455, "OFFENSIVE", "LOW")      -- Cobra Shot
        self:AddSpell(56641, "OFFENSIVE", "LOW")       -- Steady Shot
        self:AddSpell(185358, "OFFENSIVE", "LOW")      -- Arcane Shot
        self:AddSpell(259489, "OFFENSIVE", "LOW")      -- Kill Shot
    elseif class == "MAGE" then
        -- Mage offensive cooldowns
        self:AddSpell(12472, "COOLDOWNS", "HIGH")      -- Icy Veins
        self:AddSpell(190319, "COOLDOWNS", "HIGH")     -- Combustion
        self:AddSpell(12042, "COOLDOWNS", "HIGH")      -- Arcane Power
        self:AddSpell(45438, "DEFENSIVE", "HIGH")      -- Ice Block
        self:AddSpell(55342, "DEFENSIVE", "HIGH")      -- Mirror Image
        self:AddSpell(113724, "UTILITY", "HIGH")       -- Ring of Frost
        self:AddSpell(2139, "INTERRUPTS", "MEDIUM")    -- Counterspell
        self:AddSpell(80353, "UTILITY", "MEDIUM")      -- Time Warp
        
        -- Regular abilities
        self:AddSpell(30451, "OFFENSIVE", "LOW")       -- Arcane Blast
        self:AddSpell(5143, "OFFENSIVE", "LOW")        -- Arcane Missiles
        self:AddSpell(1449, "OFFENSIVE", "LOW")        -- Arcane Explosion
        self:AddSpell(116, "OFFENSIVE", "LOW")         -- Frostbolt
        self:AddSpell(11366, "OFFENSIVE", "MEDIUM")    -- Pyroblast
        self:AddSpell(108853, "OFFENSIVE", "LOW")      -- Fire Blast
        self:AddSpell(2948, "OFFENSIVE", "LOW")        -- Scorch
    elseif class == "MONK" then
        -- Monk offensive cooldowns
        self:AddSpell(137639, "COOLDOWNS", "HIGH")     -- Storm, Earth, and Fire
        self:AddSpell(152173, "COOLDOWNS", "HIGH")     -- Serenity
        self:AddSpell(115203, "DEFENSIVE", "HIGH")     -- Fortifying Brew
        self:AddSpell(122278, "DEFENSIVE", "HIGH")     -- Dampen Harm
        self:AddSpell(122783, "DEFENSIVE", "HIGH")     -- Diffuse Magic
        self:AddSpell(243435, "DEFENSIVE", "HIGH")     -- Fortifying Brew (Brewmaster)
        self:AddSpell(115310, "COOLDOWNS", "HIGH")     -- Revival
        self:AddSpell(116680, "COOLDOWNS", "HIGH")     -- Thunder Focus Tea
        self:AddSpell(322118, "UTILITY", "MEDIUM")     -- Invoke Yu'lon
        self:AddSpell(115078, "UTILITY", "MEDIUM")     -- Paralysis
        self:AddSpell(119381, "UTILITY", "MEDIUM")     -- Leg Sweep
        self:AddSpell(116844, "UTILITY", "MEDIUM")     -- Ring of Peace
        self:AddSpell(116670, "UTILITY", "MEDIUM")     -- Vivify
        
        -- Healing spells
        self:AddSpell(115151, "HEALING", "MEDIUM")     -- Renewing Mist
        self:AddSpell(116670, "HEALING", "LOW")        -- Vivify
        self:AddSpell(124682, "HEALING", "LOW")        -- Enveloping Mist
        self:AddSpell(115175, "HEALING", "LOW")        -- Soothing Mist
    elseif class == "PALADIN" then
        -- Paladin offensive cooldowns
        self:AddSpell(31884, "COOLDOWNS", "HIGH")      -- Avenging Wrath
        self:AddSpell(216331, "COOLDOWNS", "HIGH")     -- Avenging Crusader
        self:AddSpell(105809, "COOLDOWNS", "HIGH")     -- Holy Avenger
        self:AddSpell(31821, "COOLDOWNS", "HIGH")      -- Aura Mastery
        self:AddSpell(86659, "DEFENSIVE", "HIGH")      -- Guardian of Ancient Kings
        self:AddSpell(642, "DEFENSIVE", "HIGH")        -- Divine Shield
        self:AddSpell(633, "HEALING", "HIGH")          -- Lay on Hands
        self:AddSpell(1022, "DEFENSIVE", "HIGH")       -- Blessing of Protection
        self:AddSpell(204018, "DEFENSIVE", "HIGH")     -- Blessing of Spellwarding
        self:AddSpell(1044, "UTILITY", "MEDIUM")       -- Blessing of Freedom
        self:AddSpell(96231, "UTILITY", "MEDIUM")      -- Rebuke (Interrupt)
        
        -- Healing spells
        self:AddSpell(19750, "HEALING", "LOW")         -- Flash of Light
        self:AddSpell(82326, "HEALING", "LOW")         -- Holy Light
        self:AddSpell(85222, "HEALING", "MEDIUM")      -- Light of Dawn
        self:AddSpell(53600, "HEALING", "MEDIUM")      -- Shield of the Righteous
        
        -- Utility
        self:AddSpell(4987, "DISPELS", "MEDIUM")       -- Cleanse
    elseif class == "PRIEST" then
        -- Priest offensive cooldowns
        self:AddSpell(10060, "COOLDOWNS", "HIGH")      -- Power Infusion
        self:AddSpell(194249, "COOLDOWNS", "HIGH")     -- Voidform
        self:AddSpell(64843, "COOLDOWNS", "HIGH")      -- Divine Hymn
        self:AddSpell(64901, "COOLDOWNS", "HIGH")      -- Symbol of Hope
        self:AddSpell(47536, "COOLDOWNS", "HIGH")      -- Rapture
        self:AddSpell(33206, "DEFENSIVE", "HIGH")      -- Pain Suppression
        self:AddSpell(47788, "DEFENSIVE", "HIGH")      -- Guardian Spirit
        self:AddSpell(62618, "DEFENSIVE", "HIGH")      -- Power Word: Barrier
        self:AddSpell(19236, "DEFENSIVE", "HIGH")      -- Desperate Prayer
        self:AddSpell(15286, "DEFENSIVE", "HIGH")      -- Vampiric Embrace
        
        -- Healing spells
        self:AddSpell(2061, "HEALING", "LOW")          -- Flash Heal
        self:AddSpell(2060, "HEALING", "LOW")          -- Heal
        self:AddSpell(139, "HEALING", "LOW")           -- Renew
        self:AddSpell(33076, "HEALING", "MEDIUM")      -- Prayer of Mending
        self:AddSpell(34861, "HEALING", "MEDIUM")      -- Holy Word: Sanctify
        self:AddSpell(2050, "HEALING", "MEDIUM")       -- Holy Word: Serenity
        
        -- Utility
        self:AddSpell(527, "DISPELS", "MEDIUM")        -- Purify
        self:AddSpell(32375, "DISPELS", "MEDIUM")      -- Mass Dispel
    elseif class == "ROGUE" then
        -- Rogue offensive cooldowns
        self:AddSpell(13750, "COOLDOWNS", "HIGH")      -- Adrenaline Rush
        self:AddSpell(51690, "COOLDOWNS", "HIGH")      -- Killing Spree
        self:AddSpell(185313, "COOLDOWNS", "HIGH")     -- Shadow Dance
        self:AddSpell(121471, "COOLDOWNS", "HIGH")     -- Shadow Blades
        self:AddSpell(5277, "DEFENSIVE", "HIGH")       -- Evasion
        self:AddSpell(31224, "DEFENSIVE", "HIGH")      -- Cloak of Shadows
        self:AddSpell(1856, "DEFENSIVE", "HIGH")       -- Vanish
        self:AddSpell(1966, "DEFENSIVE", "HIGH")       -- Feint
        self:AddSpell(2094, "UTILITY", "MEDIUM")       -- Blind
        self:AddSpell(1766, "INTERRUPTS", "MEDIUM")    -- Kick
        
        -- Regular abilities
        self:AddSpell(193315, "OFFENSIVE", "LOW")      -- Sinister Strike
        self:AddSpell(185763, "OFFENSIVE", "LOW")      -- Pistol Shot
        self:AddSpell(8676, "OFFENSIVE", "MEDIUM")     -- Ambush
        self:AddSpell(2098, "OFFENSIVE", "MEDIUM")     -- Eviscerate
    elseif class == "SHAMAN" then
        -- Shaman offensive cooldowns
        self:AddSpell(198067, "COOLDOWNS", "HIGH")     -- Fire Elemental
        self:AddSpell(51533, "COOLDOWNS", "HIGH")      -- Feral Spirit
        self:AddSpell(114050, "COOLDOWNS", "HIGH")     -- Ascendance (Elemental)
        self:AddSpell(114051, "COOLDOWNS", "HIGH")     -- Ascendance (Enhancement)
        self:AddSpell(114052, "COOLDOWNS", "HIGH")     -- Ascendance (Restoration)
        self:AddSpell(108271, "DEFENSIVE", "HIGH")     -- Astral Shift
        self:AddSpell(108281, "DEFENSIVE", "HIGH")     -- Ancestral Guidance
        self:AddSpell(98008, "COOLDOWNS", "HIGH")      -- Spirit Link Totem
        self:AddSpell(198103, "UTILITY", "MEDIUM")     -- Earth Elemental
        self:AddSpell(57994, "INTERRUPTS", "MEDIUM")   -- Wind Shear
        self:AddSpell(2825, "UTILITY", "MEDIUM")       -- Bloodlust
        
        -- Healing spells
        self:AddSpell(8004, "HEALING", "LOW")          -- Healing Surge
        self:AddSpell(77472, "HEALING", "MEDIUM")      -- Healing Wave
        self:AddSpell(61295, "HEALING", "LOW")         -- Riptide
        self:AddSpell(73920, "HEALING", "MEDIUM")      -- Healing Rain
        
        -- Utility
        self:AddSpell(370, "DISPELS", "MEDIUM")        -- Purge
    elseif class == "WARLOCK" then
        -- Warlock offensive cooldowns
        self:AddSpell(1122, "COOLDOWNS", "HIGH")       -- Summon Infernal
        self:AddSpell(205180, "COOLDOWNS", "HIGH")     -- Summon Darkglare
        self:AddSpell(265187, "COOLDOWNS", "HIGH")     -- Summon Demonic Tyrant
        self:AddSpell(113858, "COOLDOWNS", "HIGH")     -- Dark Soul: Instability
        self:AddSpell(113860, "COOLDOWNS", "HIGH")     -- Dark Soul: Misery
        self:AddSpell(104773, "DEFENSIVE", "HIGH")     -- Unending Resolve
        self:AddSpell(108416, "DEFENSIVE", "HIGH")     -- Dark Pact
        
        -- Regular abilities
        self:AddSpell(172, "OFFENSIVE", "LOW")         -- Corruption
        self:AddSpell(980, "OFFENSIVE", "LOW")         -- Agony
        self:AddSpell(146739, "OFFENSIVE", "LOW")      -- Corruption (Proc)
        self:AddSpell(27243, "OFFENSIVE", "LOW")       -- Seed of Corruption
        self:AddSpell(198590, "OFFENSIVE", "LOW")      -- Drain Soul
        self:AddSpell(232449, "OFFENSIVE", "LOW")      -- Unstable Affliction
    elseif class == "WARRIOR" then
        -- Warrior offensive cooldowns
        self:AddSpell(1719, "COOLDOWNS", "HIGH")       -- Recklessness
        self:AddSpell(107574, "COOLDOWNS", "HIGH")     -- Avatar
        self:AddSpell(227847, "COOLDOWNS", "HIGH")     -- Bladestorm
        self:AddSpell(118038, "DEFENSIVE", "HIGH")     -- Die by the Sword
        self:AddSpell(97462, "DEFENSIVE", "HIGH")      -- Rallying Cry
        self:AddSpell(871, "DEFENSIVE", "HIGH")        -- Shield Wall
        self:AddSpell(12975, "DEFENSIVE", "HIGH")      -- Last Stand
        self:AddSpell(6552, "INTERRUPTS", "MEDIUM")    -- Pummel
        
        -- Regular abilities
        self:AddSpell(85288, "OFFENSIVE", "LOW")       -- Raging Blow
        self:AddSpell(23881, "OFFENSIVE", "LOW")       -- Bloodthirst
        self:AddSpell(5308, "OFFENSIVE", "MEDIUM")     -- Execute
        self:AddSpell(163201, "OFFENSIVE", "LOW")      -- Execute (Proc)
        self:AddSpell(12294, "OFFENSIVE", "MEDIUM")    -- Mortal Strike
        self:AddSpell(20243, "OFFENSIVE", "LOW")       -- Devastate
    elseif class == "EVOKER" then
        -- Evoker offensive cooldowns
        self:AddSpell(375087, "COOLDOWNS", "HIGH")     -- Dragonrage
        self:AddSpell(359816, "COOLDOWNS", "HIGH")     -- Dreambreaker
        self:AddSpell(357210, "DEFENSIVE", "HIGH")     -- Deep Breath
        self:AddSpell(363916, "DEFENSIVE", "HIGH")     -- Obsidian Scales
        self:AddSpell(370553, "UTILITY", "HIGH")       -- Tip the Scales
        self:AddSpell(370665, "INTERRUPTS", "MEDIUM")  -- Rescue
        
        -- Healing spells
        self:AddSpell(366155, "HEALING", "MEDIUM")     -- Reversion
        self:AddSpell(355936, "HEALING", "LOW")        -- Dream Breath
        self:AddSpell(364343, "HEALING", "LOW")        -- Echo
        self:AddSpell(355913, "HEALING", "MEDIUM")     -- Emerald Blossom
        
        -- Regular abilities
        self:AddSpell(357209, "OFFENSIVE", "LOW")      -- Fire Breath
        self:AddSpell(361469, "OFFENSIVE", "LOW")      -- Living Flame
        self:AddSpell(356995, "OFFENSIVE", "LOW")      -- Disintegrate
    end
end

-- Add general spells that are not class-specific
function Categories:AddGeneralSpells()
    -- Trinkets and racial abilities
    self:AddSpell(26297, "UTILITY", "MEDIUM")    -- Berserking (Troll)
    self:AddSpell(20594, "UTILITY", "MEDIUM")    -- Stoneform (Dwarf)
    self:AddSpell(59752, "UTILITY", "MEDIUM")    -- Every Man for Himself (Human)
    
    -- Covenants
    self:AddSpell(324631, "COOLDOWNS", "HIGH")   -- Fleshcraft (Necrolord)
    self:AddSpell(323547, "OFFENSIVE", "HIGH")   -- Ravenous Frenzy (Venthyr)
    self:AddSpell(323639, "OFFENSIVE", "HIGH")   -- The Hunt (Night Fae)
    self:AddSpell(328923, "HEALING", "HIGH")     -- Fallen Order (Kyrian)
    
    -- Consumables
    self:AddSpell(188030, "UTILITY", "LOW")      -- Feast
    self:AddSpell(307162, "UTILITY", "LOW")      -- Potion
    self:AddSpell(307185, "UTILITY", "LOW")      -- Shadowcore Oil
    
    -- Generic items (like trinkets)
    -- These are more examples and would need specific spell IDs
    -- self:AddSpell(123456, "OFFENSIVE", "HIGH")  -- Damage Trinket
    -- self:AddSpell(234567, "DEFENSIVE", "HIGH")  -- Tank Trinket
    -- self:AddSpell(345678, "HEALING", "HIGH")    -- Healing Trinket
end