--[[
    VUI - OmniCD Priority System
    Version: 0.2.0
    Author: VortexQ8
    
    This file implements the priority system for the OmniCD module:
    - Organizes cooldowns into functional categories with assigned priorities
    - Provides visual distinctions for different cooldown types
    - Implements enhanced UI customization for priority levels
    - Integrates with the existing cooldown tracking system
]]

local _, VUI = ...
local OmniCD = VUI.omnicd

-- Create namespace for priority system
OmniCD.PrioritySystem = {}
local PS = OmniCD.PrioritySystem

-- Import frequently used globals
local format = string.format
local pairs, ipairs = pairs, ipairs
local tinsert, tremove, wipe = table.insert, table.remove, table.wipe
local min, max = math.min, math.max

-- Cooldown priority categories
PS.CATEGORIES = {
    DEFENSIVE = {
        id = "defensive",
        name = "Defensive",
        description = "Damage reduction and survival cooldowns",
        priority = 90,
        color = {0.2, 0.8, 0.2, 1.0},      -- Green
        borderSize = 1.25,
        iconScale = 1.15,
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {0.2, 0.8, 0.2, 0.7}
    },
    EXTERNAL = {
        id = "external",
        name = "External",
        description = "Cooldowns that benefit other players",
        priority = 85,
        color = {0.3, 0.7, 1.0, 1.0},      -- Light Blue
        borderSize = 1.25,
        iconScale = 1.15, 
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {0.3, 0.7, 1.0, 0.7}
    },
    INTERRUPT = {
        id = "interrupt",
        name = "Interrupt",
        description = "Spell interruption abilities",
        priority = 80,
        color = {1.0, 0.6, 0.0, 1.0},      -- Orange
        borderSize = 1.2,
        iconScale = 1.1,
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {1.0, 0.6, 0.0, 0.7}
    },
    CC = {
        id = "cc",
        name = "Crowd Control",
        description = "Stuns, incapacitates, and other crowd control",
        priority = 75,
        color = {0.8, 0.0, 0.8, 1.0},      -- Purple
        borderSize = 1.1,
        iconScale = 1.05,
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {0.8, 0.0, 0.8, 0.7}
    },
    OFFENSIVE = {
        id = "offensive",
        name = "Offensive",
        description = "Offensive damage cooldowns",
        priority = 70,
        color = {1.0, 0.3, 0.3, 1.0},      -- Red
        borderSize = 1.15,
        iconScale = 1.1,
        glowEnabled = true,
        glowType = "pixel",
        glowColor = {1.0, 0.3, 0.3, 0.7}
    },
    MOVEMENT = {
        id = "movement",
        name = "Movement",
        description = "Movement speed and repositioning abilities",
        priority = 65,
        color = {0.0, 0.6, 0.8, 1.0},      -- Teal
        borderSize = 1.0,
        iconScale = 1.0,
        glowEnabled = false
    },
    UTILITY = {
        id = "utility",
        name = "Utility",
        description = "General utility abilities",
        priority = 60,
        color = {0.6, 0.6, 0.6, 1.0},      -- Gray
        borderSize = 1.0,
        iconScale = 1.0,
        glowEnabled = false
    },
    STANDARD = {
        id = "standard",
        name = "Standard",
        description = "Regular abilities with cooldowns",
        priority = 50,
        color = {0.5, 0.5, 0.5, 0.8},      -- Light Gray
        borderSize = 1.0,
        iconScale = 0.95,
        glowEnabled = false
    }
}

-- Cooldown importance levels within categories
PS.IMPORTANCE = {
    CRITICAL = {
        id = "critical",
        name = "Critical",
        priorityMod = 10,
        iconScaleMod = 1.1,
        borderSizeMod = 1.1,
        glowIntensity = 1.2
    },
    MAJOR = {
        id = "major",
        name = "Major",
        priorityMod = 5,
        iconScaleMod = 1.05,
        borderSizeMod = 1.05,
        glowIntensity = 1.0
    },
    NORMAL = {
        id = "normal",
        name = "Normal",
        priorityMod = 0,
        iconScaleMod = 1.0,
        borderSizeMod = 1.0,
        glowIntensity = 0.8
    },
    MINOR = {
        id = "minor",
        name = "Minor",
        priorityMod = -5,
        iconScaleMod = 0.95,
        borderSizeMod = 0.95,
        glowIntensity = 0.6
    }
}

-- Spell category assignments
PS.spellCategories = {}
PS.spellImportance = {}

-- Initialize the priority system
function PS:Initialize()
    -- Set up database defaults
    self:InitializeDB()
    
    -- Load default spell categorizations
    self:LoadDefaultCategories()
    
    -- Apply theme-specific colors
    self:UpdateThemeColors()
    
    -- Register for theme changes
    VUI:RegisterCallback("ThemeChanged", function()
        self:UpdateThemeColors()
        OmniCD:UpdateCooldownDisplay()
    end)
    
    -- Hook into the OmniCD cooldown display
    self:HookCooldownDisplay()
    
    VUI:Print("OmniCD Priority System initialized")
end

-- Initialize database
function PS:InitializeDB()
    if not OmniCD.db.prioritySystem then
        OmniCD.db.prioritySystem = {
            enabled = true,
            categories = {
                defensive = true,
                external = true, 
                interrupt = true,
                cc = true,
                offensive = true,
                movement = true,
                utility = true,
                standard = true
            },
            visualEnhancements = true,
            showGlows = true,
            scalePriorities = true,
            customPriorities = {}
        }
    end
    
    self.db = OmniCD.db.prioritySystem
end

-- Update theme colors
function PS:UpdateThemeColors()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Adjust colors based on theme
    if theme == "phoenixflame" then
        -- Warm color variants for Phoenix Flame theme
        self.CATEGORIES.OFFENSIVE.color = {1.0, 0.4, 0.1, 1.0} -- More orange-red
        self.CATEGORIES.OFFENSIVE.glowColor = {1.0, 0.4, 0.1, 0.7} -- More orange-red
        self.CATEGORIES.DEFENSIVE.color = {0.4, 0.9, 0.1, 1.0} -- More yellow-green
        self.CATEGORIES.DEFENSIVE.glowColor = {0.4, 0.9, 0.1, 0.7} -- More yellow-green
    elseif theme == "thunderstorm" then
        -- Cool color variants for Thunder Storm theme
        self.CATEGORIES.OFFENSIVE.color = {0.9, 0.2, 0.2, 1.0} -- Deeper red
        self.CATEGORIES.OFFENSIVE.glowColor = {0.9, 0.2, 0.2, 0.7} -- Deeper red
        self.CATEGORIES.MOVEMENT.color = {0.1, 0.6, 0.9, 1.0} -- Brighter blue
        self.CATEGORIES.MOVEMENT.glowColor = {0.1, 0.6, 0.9, 0.7} -- Brighter blue
    elseif theme == "arcanemystic" then
        -- Mystical color variants for Arcane Mystic theme
        self.CATEGORIES.CC.color = {0.9, 0.2, 1.0, 1.0} -- Brighter purple
        self.CATEGORIES.CC.glowColor = {0.9, 0.2, 1.0, 0.7} -- Brighter purple
        self.CATEGORIES.EXTERNAL.color = {0.5, 0.3, 0.9, 1.0} -- Arcane purple-blue
        self.CATEGORIES.EXTERNAL.glowColor = {0.5, 0.3, 0.9, 0.7} -- Arcane purple-blue
    elseif theme == "felenergy" then
        -- Fel color variants for Fel Energy theme
        self.CATEGORIES.DEFENSIVE.color = {0.1, 0.9, 0.1, 1.0} -- More fel green
        self.CATEGORIES.DEFENSIVE.glowColor = {0.1, 0.9, 0.1, 0.7} -- More fel green
        self.CATEGORIES.OFFENSIVE.color = {0.8, 1.0, 0.2, 1.0} -- Fel yellow-green
        self.CATEGORIES.OFFENSIVE.glowColor = {0.8, 1.0, 0.2, 0.7} -- Fel yellow-green
    end
end

-- Apply priority styling to cooldown icon
function PS:ApplyToCooldownIcon(frame, spellID, cooldownInfo)
    if not frame or not spellID or not self.db.enabled then return end
    
    -- Get category and importance
    local categoryID = self.spellCategories[spellID]
    local importanceID = self.spellImportance[spellID]
    
    -- Use default if not categorized
    if not categoryID then categoryID = "standard" end
    if not importanceID then importanceID = "normal" end
    
    -- Get category and importance data
    local category = self.CATEGORIES[categoryID:upper()]
    local importance = self.IMPORTANCE[importanceID:upper()]
    
    if not category or not importance then return end
    
    -- Apply border color
    if frame.border and category.color then
        frame.border:SetVertexColor(
            category.color[1],
            category.color[2],
            category.color[3],
            category.color[4] or 1.0
        )
    end
    
    -- Apply icon scaling if enabled
    if self.db.scalePriorities then
        local baseSize = OmniCD.db.iconSize or 30
        local categoryScale = category.iconScale or 1.0
        local importanceScale = importance.iconScaleMod or 1.0
        local newSize = baseSize * categoryScale * importanceScale
        
        frame:SetSize(newSize, newSize)
    end
    
    -- Apply glow effect if enabled
    if self.db.showGlows and category.glowEnabled and frame.highlight then
        local glowColor = category.glowColor
        local glowIntensity = importance.glowIntensity or 1.0
        
        frame.highlight:SetVertexColor(
            glowColor[1],
            glowColor[2],
            glowColor[3],
            (glowColor[4] or 0.7) * glowIntensity
        )
        
        -- Show highlight for important cooldowns
        if cooldownInfo.priority >= 70 then
            frame.highlight:SetAlpha(0.3 * glowIntensity)
        else
            frame.highlight:SetAlpha(0)
        end
    end
    
    -- Apply border size
    if self.db.visualEnhancements and frame.iconFrame then
        local borderSize = category.borderSize or 1.0
        local borderSizeMod = importance.borderSizeMod or 1.0
        local scaling = borderSize * borderSizeMod
        
        frame.iconFrame:SetScale(scaling)
    end
    
    -- Apply ready pulse effect for high priority cooldowns
    if cooldownInfo.priority >= 85 and frame.readyPulse then
        -- Enable pulse animation for high-priority cooldowns when they're ready
        local timeLeft = cooldownInfo.endTime - GetTime()
        if timeLeft <= 0 then
            -- Implement pulse animation for ready high-priority cooldowns
            if not frame.pulseAnimation then
                frame.pulseAnimation = frame:CreateAnimationGroup()
                frame.pulseAnimation:SetLooping("REPEAT")
                
                local pulse = frame.pulseAnimation:CreateAnimation("Alpha")
                pulse:SetFromAlpha(0)
                pulse:SetToAlpha(0.7)
                pulse:SetDuration(0.5)
                pulse:SetSmoothing("IN_OUT")
                
                local pulseOut = frame.pulseAnimation:CreateAnimation("Alpha")
                pulseOut:SetFromAlpha(0.7)
                pulseOut:SetToAlpha(0)
                pulseOut:SetDuration(0.5)
                pulseOut:SetSmoothing("IN_OUT")
                pulseOut:SetOrder(2)
            end
            
            if not frame.pulseAnimation:IsPlaying() then
                frame.readyPulse:Show()
                frame.pulseAnimation:Play()
            end
        else
            -- Stop pulse when cooldown isn't ready
            if frame.pulseAnimation and frame.pulseAnimation:IsPlaying() then
                frame.pulseAnimation:Stop()
                frame.readyPulse:Hide()
            end
        end
    end
end

-- Hook into the cooldown display to apply priority styling
function PS:HookCooldownDisplay()
    -- Store the original function
    local originalUpdateCooldownDisplay = OmniCD.UpdateCooldownDisplay
    
    -- Replace with our enhanced version
    OmniCD.UpdateCooldownDisplay = function(self)
        -- Call the original function first
        originalUpdateCooldownDisplay(self)
        
        -- Get active frames and apply priority styling
        for i = 1, #self.iconFrames do
            local frame = self.iconFrames[i]
            if frame:IsShown() and frame.spellID and frame.cooldownInfo then
                PS:ApplyToCooldownIcon(frame, frame.spellID, frame.cooldownInfo)
            end
        end
    end
    
    -- Hook into icon frame creation to store spell ID
    local originalCreateIconFrame = OmniCD.CreateIconFrame
    OmniCD.CreateIconFrame = function(self, index)
        local frame = originalCreateIconFrame(self, index)
        
        -- Add spellID field for tracking
        frame.spellID = nil
        frame.cooldownInfo = nil
        
        return frame
    end
    
    -- Hook into the function that updates the frames with cooldown info
    local originalUpdateCooldownFrames = OmniCD.UpdateCooldownFrames
    if originalUpdateCooldownFrames then
        OmniCD.UpdateCooldownFrames = function(self, cooldownList)
            originalUpdateCooldownFrames(self, cooldownList)
            
            -- Apply priority styling to frames
            for i = 1, #self.iconFrames do
                local frame = self.iconFrames[i]
                if frame:IsShown() and frame.spellID and frame.cooldownInfo then
                    PS:ApplyToCooldownIcon(frame, frame.spellID, frame.cooldownInfo)
                end
            end
        end
    end
    
    -- Add spell ID tracking to the cooldown display update function if needed
    if OmniCD.UpdateCooldownDisplay then
        local originalUpdateDisplay = OmniCD.UpdateCooldownDisplay
        OmniCD.UpdateCooldownDisplay = function(self)
            -- Call original function
            originalUpdateDisplay(self)
            
            -- Get cooldowns into a list
            local cooldownList = {}
            for _, unitCooldowns in pairs(self.activeCooldowns or {}) do
                for _, cd in ipairs(unitCooldowns) do
                    table.insert(cooldownList, cd)
                end
            end
            
            -- Sort by priority
            table.sort(cooldownList, function(a, b)
                return a.priority > b.priority
            end)
            
            -- Store spell IDs and cooldown info in frames
            for i = 1, min(#cooldownList, #self.iconFrames) do
                local frame = self.iconFrames[i]
                local cd = cooldownList[i]
                
                if frame and cd then
                    frame.spellID = cd.spellID
                    frame.cooldownInfo = cd
                    PS:ApplyToCooldownIcon(frame, cd.spellID, cd)
                end
            end
        end
    end
end

-- Calculate priority for a spell
function PS:CalculatePriority(spellID)
    -- Get the base category priority
    local categoryID = self.spellCategories[spellID] or "standard"
    local importanceID = self.spellImportance[spellID] or "normal"
    
    local category = self.CATEGORIES[categoryID:upper()]
    local importance = self.IMPORTANCE[importanceID:upper()]
    
    if not category or not importance then
        return 50 -- Default priority
    end
    
    -- Calculate priority based on category and importance
    local basePriority = category.priority or 50
    local priorityMod = importance.priorityMod or 0
    
    -- Check for user-defined custom priorities
    local customPriority = self.db.customPriorities[spellID]
    if customPriority then
        return customPriority
    end
    
    return basePriority + priorityMod
end

-- Update the global SPELL_PRIORITY table with our calculated priorities
function PS:UpdateSpellPriorities()
    -- Create local reference to the global priority table
    local SPELL_PRIORITY = _G.SPELL_PRIORITY or {}
    
    -- Update all categorized spells
    for spellID, _ in pairs(self.spellCategories) do
        SPELL_PRIORITY[spellID] = self:CalculatePriority(spellID)
    end
    
    -- Assign to global variable
    _G.SPELL_PRIORITY = SPELL_PRIORITY
    
    -- Update cooldown display
    OmniCD:UpdateCooldownDisplay()
end

-- Add a spell to a category
function PS:AddSpell(spellID, categoryID, importanceID)
    if not spellID then return end
    
    -- Default to standard category
    categoryID = categoryID or "STANDARD"
    importanceID = importanceID or "NORMAL"
    
    -- Store uppercase category
    self.spellCategories[spellID] = categoryID:lower()
    self.spellImportance[spellID] = importanceID:lower()
    
    -- Update calculated priority
    if _G.SPELL_PRIORITY then
        _G.SPELL_PRIORITY[spellID] = self:CalculatePriority(spellID)
    end
end

-- Load default spell categorizations
function PS:LoadDefaultCategories()
    -- Death Knight
    self:AddDeathKnightSpells()
    
    -- Demon Hunter
    self:AddDemonHunterSpells()
    
    -- Druid
    self:AddDruidSpells()
    
    -- Hunter
    self:AddHunterSpells()
    
    -- Mage
    self:AddMageSpells()
    
    -- Monk
    self:AddMonkSpells()
    
    -- Paladin
    self:AddPaladinSpells()
    
    -- Priest
    self:AddPriestSpells()
    
    -- Rogue
    self:AddRogueSpells()
    
    -- Shaman
    self:AddShamanSpells()
    
    -- Warlock
    self:AddWarlockSpells()
    
    -- Warrior
    self:AddWarriorSpells()
    
    -- Evoker
    self:AddEvokerSpells()
    
    -- Update priorities after loading defaults
    self:UpdateSpellPriorities()
end

-- Death Knight spells
function PS:AddDeathKnightSpells()
    -- Defensive
    self:AddSpell(48707, "DEFENSIVE", "MAJOR")       -- Anti-Magic Shell
    self:AddSpell(48792, "DEFENSIVE", "CRITICAL")    -- Icebound Fortitude
    self:AddSpell(55233, "DEFENSIVE", "MAJOR")       -- Vampiric Blood
    self:AddSpell(48743, "DEFENSIVE", "MAJOR")       -- Death Pact
    
    -- External
    self:AddSpell(51052, "EXTERNAL", "CRITICAL")     -- Anti-Magic Zone
    
    -- Utility
    self:AddSpell(49576, "UTILITY", "NORMAL")        -- Death Grip
    self:AddSpell(108199, "UTILITY", "MAJOR")        -- Gorefiend's Grasp
    
    -- Interrupt
    self:AddSpell(47528, "INTERRUPT", "NORMAL")      -- Mind Freeze
    
    -- Offensive
    self:AddSpell(49028, "OFFENSIVE", "MAJOR")       -- Dancing Rune Weapon
    self:AddSpell(47568, "OFFENSIVE", "MAJOR")       -- Empower Rune Weapon
    self:AddSpell(275699, "OFFENSIVE", "MAJOR")      -- Apocalypse
    self:AddSpell(42650, "OFFENSIVE", "CRITICAL")    -- Army of the Dead
    self:AddSpell(49206, "OFFENSIVE", "MAJOR")       -- Summon Gargoyle
    
    -- Movement
    self:AddSpell(48265, "MOVEMENT", "NORMAL")       -- Death's Advance
    self:AddSpell(212552, "MOVEMENT", "NORMAL")      -- Wraith Walk
end

-- Demon Hunter spells
function PS:AddDemonHunterSpells()
    -- Defensive
    self:AddSpell(198589, "DEFENSIVE", "MAJOR")      -- Blur
    self:AddSpell(196718, "DEFENSIVE", "CRITICAL")   -- Darkness
    self:AddSpell(196555, "DEFENSIVE", "MAJOR")      -- Netherwalk
    self:AddSpell(204021, "DEFENSIVE", "MAJOR")      -- Fiery Brand
    
    -- Interrupt
    self:AddSpell(183752, "INTERRUPT", "NORMAL")     -- Disrupt
    
    -- CC
    self:AddSpell(179057, "CC", "MAJOR")             -- Chaos Nova
    self:AddSpell(211881, "CC", "NORMAL")            -- Fel Eruption
    self:AddSpell(205630, "CC", "MAJOR")             -- Illidan's Grasp
    
    -- Utility
    self:AddSpell(202137, "UTILITY", "MAJOR")        -- Sigil of Silence
    self:AddSpell(202138, "UTILITY", "MAJOR")        -- Sigil of Chains
    self:AddSpell(207684, "UTILITY", "MAJOR")        -- Sigil of Misery
    
    -- Offensive
    self:AddSpell(191427, "OFFENSIVE", "CRITICAL")   -- Metamorphosis (Havoc)
    self:AddSpell(187827, "OFFENSIVE", "CRITICAL")   -- Metamorphosis (Vengeance)
    self:AddSpell(198013, "OFFENSIVE", "MAJOR")      -- Eye Beam
    
    -- Movement
    self:AddSpell(195072, "MOVEMENT", "NORMAL")      -- Fel Rush
    self:AddSpell(198793, "MOVEMENT", "NORMAL")      -- Vengeful Retreat
    self:AddSpell(189110, "MOVEMENT", "NORMAL")      -- Infernal Strike
end

-- Druid spells
function PS:AddDruidSpells()
    -- Defensive
    self:AddSpell(61336, "DEFENSIVE", "CRITICAL")    -- Survival Instincts
    self:AddSpell(22812, "DEFENSIVE", "MAJOR")       -- Barkskin
    self:AddSpell(102342, "DEFENSIVE", "MAJOR")      -- Ironbark
    
    -- External
    self:AddSpell(29166, "EXTERNAL", "MAJOR")        -- Innervate
    
    -- Offensive
    self:AddSpell(194223, "OFFENSIVE", "MAJOR")      -- Celestial Alignment
    self:AddSpell(102560, "OFFENSIVE", "MAJOR")      -- Incarnation: Chosen of Elune
    self:AddSpell(106951, "OFFENSIVE", "MAJOR")      -- Berserk
    self:AddSpell(102543, "OFFENSIVE", "MAJOR")      -- Incarnation: King of the Jungle
    self:AddSpell(33891, "OFFENSIVE", "MAJOR")       -- Incarnation: Tree of Life
    self:AddSpell(102558, "OFFENSIVE", "MAJOR")      -- Incarnation: Guardian of Ursoc
    
    -- Healing
    self:AddSpell(740, "EXTERNAL", "CRITICAL")       -- Tranquility
    self:AddSpell(204066, "EXTERNAL", "MAJOR")       -- Lunar Beam
    
    -- CC
    self:AddSpell(99, "CC", "NORMAL")                -- Incapacitating Roar
    self:AddSpell(2637, "CC", "NORMAL")              -- Hibernate
    self:AddSpell(78675, "CC", "NORMAL")             -- Solar Beam
    
    -- Utility
    self:AddSpell(20484, "UTILITY", "NORMAL")        -- Rebirth
    self:AddSpell(2908, "UTILITY", "NORMAL")         -- Soothe
    self:AddSpell(2782, "UTILITY", "NORMAL")         -- Remove Corruption
    
    -- Movement
    self:AddSpell(77764, "MOVEMENT", "MAJOR")        -- Stampeding Roar
    self:AddSpell(1850, "MOVEMENT", "NORMAL")        -- Dash
    self:AddSpell(252216, "MOVEMENT", "NORMAL")      -- Tiger Dash
end

-- Hunter spells
function PS:AddHunterSpells()
    -- Defensive
    self:AddSpell(186265, "DEFENSIVE", "CRITICAL")   -- Aspect of the Turtle
    self:AddSpell(109304, "DEFENSIVE", "MAJOR")      -- Exhilaration
    self:AddSpell(199483, "DEFENSIVE", "MAJOR")      -- Camouflage
    
    -- Utility
    self:AddSpell(34477, "UTILITY", "NORMAL")        -- Misdirection
    self:AddSpell(53271, "UTILITY", "NORMAL")        -- Master's Call
    self:AddSpell(19801, "UTILITY", "NORMAL")        -- Tranquilizing Shot
    
    -- Interrupt
    self:AddSpell(147362, "INTERRUPT", "NORMAL")     -- Counter Shot
    self:AddSpell(187707, "INTERRUPT", "NORMAL")     -- Muzzle
    
    -- CC
    self:AddSpell(187650, "CC", "MAJOR")             -- Freezing Trap
    self:AddSpell(186387, "CC", "NORMAL")            -- Bursting Shot
    self:AddSpell(19577, "CC", "NORMAL")             -- Intimidation
    
    -- Offensive
    self:AddSpell(193530, "OFFENSIVE", "MAJOR")      -- Aspect of the Wild
    self:AddSpell(19574, "OFFENSIVE", "MAJOR")       -- Bestial Wrath
    self:AddSpell(288613, "OFFENSIVE", "MAJOR")      -- Trueshot
    self:AddSpell(266779, "OFFENSIVE", "MAJOR")      -- Coordinated Assault
    
    -- Movement
    self:AddSpell(186257, "MOVEMENT", "NORMAL")      -- Aspect of the Cheetah
    self:AddSpell(186289, "MOVEMENT", "NORMAL")      -- Aspect of the Eagle
    self:AddSpell(5384, "MOVEMENT", "NORMAL")        -- Feign Death
end

-- Mage spells
function PS:AddMageSpells()
    -- Defensive
    self:AddSpell(45438, "DEFENSIVE", "CRITICAL")    -- Ice Block
    self:AddSpell(113724, "DEFENSIVE", "MAJOR")      -- Ring of Frost
    self:AddSpell(11426, "DEFENSIVE", "MAJOR")       -- Ice Barrier
    
    -- Utility
    self:AddSpell(80353, "EXTERNAL", "CRITICAL")     -- Time Warp
    self:AddSpell(110959, "UTILITY", "NORMAL")       -- Greater Invisibility
    self:AddSpell(66, "UTILITY", "NORMAL")           -- Invisibility
    self:AddSpell(55342, "UTILITY", "NORMAL")        -- Mirror Image
    
    -- Interrupt
    self:AddSpell(2139, "INTERRUPT", "NORMAL")       -- Counterspell
    
    -- CC
    self:AddSpell(118, "CC", "NORMAL")               -- Polymorph
    self:AddSpell(122, "CC", "NORMAL")               -- Frost Nova
    self:AddSpell(157997, "CC", "NORMAL")            -- Ice Nova
    
    -- Offensive
    self:AddSpell(12472, "OFFENSIVE", "MAJOR")       -- Icy Veins
    self:AddSpell(190319, "OFFENSIVE", "MAJOR")      -- Combustion
    self:AddSpell(12042, "OFFENSIVE", "MAJOR")       -- Arcane Power
    
    -- Movement
    self:AddSpell(1953, "MOVEMENT", "NORMAL")        -- Blink
    self:AddSpell(212653, "MOVEMENT", "NORMAL")      -- Shimmer
end

-- Monk spells
function PS:AddMonkSpells()
    -- Defensive
    self:AddSpell(115203, "DEFENSIVE", "CRITICAL")   -- Fortifying Brew
    self:AddSpell(243435, "DEFENSIVE", "CRITICAL")   -- Fortifying Brew (Brewmaster)
    self:AddSpell(122278, "DEFENSIVE", "MAJOR")      -- Dampen Harm
    self:AddSpell(122783, "DEFENSIVE", "MAJOR")      -- Diffuse Magic
    
    -- External
    self:AddSpell(116841, "EXTERNAL", "CRITICAL")    -- Tiger's Lust
    self:AddSpell(115310, "EXTERNAL", "CRITICAL")    -- Revival
    self:AddSpell(116849, "EXTERNAL", "MAJOR")       -- Life Cocoon
    
    -- Interrupt
    self:AddSpell(116705, "INTERRUPT", "NORMAL")     -- Spear Hand Strike
    
    -- CC
    self:AddSpell(119381, "CC", "MAJOR")             -- Leg Sweep
    self:AddSpell(115078, "CC", "NORMAL")            -- Paralysis
    self:AddSpell(116844, "CC", "MAJOR")             -- Ring of Peace
    
    -- Offensive
    self:AddSpell(137639, "OFFENSIVE", "MAJOR")      -- Storm, Earth, and Fire
    self:AddSpell(152173, "OFFENSIVE", "MAJOR")      -- Serenity
    self:AddSpell(115080, "OFFENSIVE", "MAJOR")      -- Touch of Death
    self:AddSpell(107574, "EXTERNAL", "MAJOR")       -- Skull Banner
    
    -- Healing
    self:AddSpell(115310, "EXTERNAL", "CRITICAL")    -- Revival
    self:AddSpell(116680, "EXTERNAL", "MAJOR")       -- Thunder Focus Tea
    
    -- Utility
    self:AddSpell(322118, "UTILITY", "MAJOR")        -- Invoke Yu'lon
    
    -- Movement
    self:AddSpell(109132, "MOVEMENT", "NORMAL")      -- Roll
    self:AddSpell(115008, "MOVEMENT", "NORMAL")      -- Chi Torpedo
end

-- Paladin spells
function PS:AddPaladinSpells()
    -- Defensive
    self:AddSpell(642, "DEFENSIVE", "CRITICAL")      -- Divine Shield
    self:AddSpell(86659, "DEFENSIVE", "CRITICAL")    -- Guardian of Ancient Kings
    self:AddSpell(31850, "DEFENSIVE", "MAJOR")       -- Ardent Defender
    self:AddSpell(498, "DEFENSIVE", "MAJOR")         -- Divine Protection
    
    -- External
    self:AddSpell(1022, "EXTERNAL", "CRITICAL")      -- Blessing of Protection
    self:AddSpell(204018, "EXTERNAL", "CRITICAL")    -- Blessing of Spellwarding
    self:AddSpell(633, "EXTERNAL", "CRITICAL")       -- Lay on Hands
    
    -- Interrupt
    self:AddSpell(96231, "INTERRUPT", "NORMAL")      -- Rebuke
    
    -- CC
    self:AddSpell(10326, "CC", "NORMAL")             -- Turn Evil
    self:AddSpell(853, "CC", "NORMAL")               -- Hammer of Justice
    self:AddSpell(105421, "CC", "MAJOR")             -- Blinding Light
    
    -- Offensive
    self:AddSpell(31884, "OFFENSIVE", "CRITICAL")    -- Avenging Wrath
    self:AddSpell(216331, "OFFENSIVE", "MAJOR")      -- Avenging Crusader
    self:AddSpell(105809, "OFFENSIVE", "MAJOR")      -- Holy Avenger
    
    -- Healing
    self:AddSpell(31821, "EXTERNAL", "CRITICAL")     -- Aura Mastery
    
    -- Utility
    self:AddSpell(1044, "UTILITY", "MAJOR")          -- Blessing of Freedom
    self:AddSpell(4987, "UTILITY", "NORMAL")         -- Cleanse
    
    -- Movement
    self:AddSpell(190784, "MOVEMENT", "NORMAL")      -- Divine Steed
end

-- Priest spells
function PS:AddPriestSpells()
    -- Defensive
    self:AddSpell(19236, "DEFENSIVE", "MAJOR")       -- Desperate Prayer
    self:AddSpell(47585, "DEFENSIVE", "CRITICAL")    -- Dispersion
    self:AddSpell(47788, "EXTERNAL", "CRITICAL")     -- Guardian Spirit
    
    -- External
    self:AddSpell(33206, "EXTERNAL", "CRITICAL")     -- Pain Suppression
    self:AddSpell(62618, "EXTERNAL", "CRITICAL")     -- Power Word: Barrier
    self:AddSpell(10060, "EXTERNAL", "MAJOR")        -- Power Infusion
    
    -- Utility
    self:AddSpell(527, "UTILITY", "NORMAL")          -- Purify
    self:AddSpell(32375, "UTILITY", "MAJOR")         -- Mass Dispel
    
    -- CC
    self:AddSpell(8122, "CC", "NORMAL")              -- Psychic Scream
    self:AddSpell(605, "CC", "NORMAL")               -- Mind Control
    self:AddSpell(64044, "CC", "NORMAL")             -- Psychic Horror
    
    -- Offensive
    self:AddSpell(194249, "OFFENSIVE", "MAJOR")      -- Voidform
    self:AddSpell(10060, "OFFENSIVE", "MAJOR")       -- Power Infusion
    
    -- Healing
    self:AddSpell(64843, "EXTERNAL", "CRITICAL")     -- Divine Hymn
    self:AddSpell(64901, "EXTERNAL", "MAJOR")        -- Symbol of Hope
    self:AddSpell(47536, "EXTERNAL", "MAJOR")        -- Rapture
    
    -- Defensive (additional)
    self:AddSpell(15286, "DEFENSIVE", "MAJOR")       -- Vampiric Embrace
    
    -- Movement
    self:AddSpell(121536, "MOVEMENT", "NORMAL")      -- Angelic Feather
    self:AddSpell(73325, "MOVEMENT", "NORMAL")       -- Leap of Faith
end

-- Rogue spells
function PS:AddRogueSpells()
    -- Defensive
    self:AddSpell(5277, "DEFENSIVE", "CRITICAL")     -- Evasion
    self:AddSpell(31224, "DEFENSIVE", "CRITICAL")    -- Cloak of Shadows
    self:AddSpell(1966, "DEFENSIVE", "MAJOR")        -- Feint
    
    -- Utility
    self:AddSpell(57934, "UTILITY", "NORMAL")        -- Tricks of the Trade
    self:AddSpell(1856, "MOVEMENT", "MAJOR")         -- Vanish
    
    -- Interrupt
    self:AddSpell(1766, "INTERRUPT", "NORMAL")       -- Kick
    
    -- CC
    self:AddSpell(2094, "CC", "MAJOR")               -- Blind
    self:AddSpell(6770, "CC", "NORMAL")              -- Sap
    self:AddSpell(408, "CC", "NORMAL")               -- Kidney Shot
    
    -- Offensive
    self:AddSpell(13750, "OFFENSIVE", "MAJOR")       -- Adrenaline Rush
    self:AddSpell(51690, "OFFENSIVE", "MAJOR")       -- Killing Spree
    self:AddSpell(185313, "OFFENSIVE", "MAJOR")      -- Shadow Dance
    self:AddSpell(121471, "OFFENSIVE", "MAJOR")      -- Shadow Blades
    
    -- Movement
    self:AddSpell(36554, "MOVEMENT", "NORMAL")       -- Shadowstep
    self:AddSpell(2983, "MOVEMENT", "NORMAL")        -- Sprint
    self:AddSpell(195457, "MOVEMENT", "NORMAL")      -- Grappling Hook
end

-- Shaman spells
function PS:AddShamanSpells()
    -- Defensive
    self:AddSpell(108271, "DEFENSIVE", "MAJOR")      -- Astral Shift
    self:AddSpell(30884, "DEFENSIVE", "MAJOR")       -- Nature's Guardian
    
    -- External
    self:AddSpell(98008, "EXTERNAL", "CRITICAL")     -- Spirit Link Totem
    self:AddSpell(108281, "EXTERNAL", "MAJOR")       -- Ancestral Guidance
    
    -- Utility
    self:AddSpell(370, "UTILITY", "NORMAL")          -- Purge
    
    -- Interrupt
    self:AddSpell(57994, "INTERRUPT", "NORMAL")      -- Wind Shear
    
    -- CC
    self:AddSpell(51514, "CC", "NORMAL")             -- Hex
    self:AddSpell(192058, "CC", "NORMAL")            -- Capacitor Totem
    
    -- Offensive
    self:AddSpell(198067, "OFFENSIVE", "MAJOR")      -- Fire Elemental
    self:AddSpell(51533, "OFFENSIVE", "MAJOR")       -- Feral Spirit
    self:AddSpell(114050, "OFFENSIVE", "MAJOR")      -- Ascendance (Elemental)
    self:AddSpell(114051, "OFFENSIVE", "MAJOR")      -- Ascendance (Enhancement)
    self:AddSpell(114052, "OFFENSIVE", "MAJOR")      -- Ascendance (Restoration)
    
    -- Healing
    self:AddSpell(108280, "EXTERNAL", "CRITICAL")    -- Healing Tide Totem
    
    -- Movement
    self:AddSpell(58875, "MOVEMENT", "NORMAL")       -- Spirit Walk
    self:AddSpell(2825, "EXTERNAL", "CRITICAL")      -- Bloodlust
    self:AddSpell(32182, "EXTERNAL", "CRITICAL")     -- Heroism
end

-- Warlock spells
function PS:AddWarlockSpells()
    -- Defensive
    self:AddSpell(104773, "DEFENSIVE", "CRITICAL")   -- Unending Resolve
    self:AddSpell(108416, "DEFENSIVE", "MAJOR")      -- Dark Pact
    
    -- Utility
    self:AddSpell(5782, "CC", "NORMAL")              -- Fear
    self:AddSpell(710, "CC", "NORMAL")               -- Banish
    self:AddSpell(6789, "CC", "NORMAL")              -- Mortal Coil
    
    -- CC
    self:AddSpell(6789, "CC", "NORMAL")              -- Mortal Coil
    self:AddSpell(30283, "CC", "NORMAL")             -- Shadowfury
    self:AddSpell(5484, "CC", "NORMAL")              -- Howl of Terror
    
    -- Offensive
    self:AddSpell(1122, "OFFENSIVE", "CRITICAL")     -- Summon Infernal
    self:AddSpell(205180, "OFFENSIVE", "MAJOR")      -- Summon Darkglare
    self:AddSpell(265187, "OFFENSIVE", "MAJOR")      -- Summon Demonic Tyrant
    self:AddSpell(113858, "OFFENSIVE", "MAJOR")      -- Dark Soul: Instability
    self:AddSpell(113860, "OFFENSIVE", "MAJOR")      -- Dark Soul: Misery
    
    -- Movement
    self:AddSpell(48020, "MOVEMENT", "NORMAL")       -- Demonic Circle: Teleport
    self:AddSpell(111771, "MOVEMENT", "NORMAL")      -- Demonic Gateway
end

-- Warrior spells
function PS:AddWarriorSpells()
    -- Defensive
    self:AddSpell(871, "DEFENSIVE", "CRITICAL")      -- Shield Wall
    self:AddSpell(12975, "DEFENSIVE", "CRITICAL")    -- Last Stand
    self:AddSpell(118038, "DEFENSIVE", "MAJOR")      -- Die by the Sword
    
    -- External
    self:AddSpell(97462, "EXTERNAL", "CRITICAL")     -- Rallying Cry
    
    -- Interrupt
    self:AddSpell(6552, "INTERRUPT", "NORMAL")       -- Pummel
    
    -- CC
    self:AddSpell(5246, "CC", "NORMAL")              -- Intimidating Shout
    self:AddSpell(132169, "CC", "NORMAL")            -- Storm Bolt
    self:AddSpell(107570, "CC", "NORMAL")            -- Storm Bolt
    
    -- Offensive
    self:AddSpell(1719, "OFFENSIVE", "MAJOR")        -- Recklessness
    self:AddSpell(107574, "OFFENSIVE", "MAJOR")      -- Avatar
    self:AddSpell(227847, "OFFENSIVE", "MAJOR")      -- Bladestorm
    
    -- Movement
    self:AddSpell(6544, "MOVEMENT", "NORMAL")        -- Heroic Leap
    self:AddSpell(100, "MOVEMENT", "NORMAL")         -- Charge
    self:AddSpell(198304, "MOVEMENT", "NORMAL")      -- Intercept
end

-- Evoker spells
function PS:AddEvokerSpells()
    -- Defensive
    self:AddSpell(363916, "DEFENSIVE", "CRITICAL")   -- Obsidian Scales
    self:AddSpell(370960, "DEFENSIVE", "MAJOR")      -- Stasis
    
    -- Utility
    self:AddSpell(374348, "UTILITY", "MAJOR")        -- Rescue
    
    -- Offensive
    self:AddSpell(375087, "OFFENSIVE", "MAJOR")      -- Dragonrage
    self:AddSpell(359816, "OFFENSIVE", "MAJOR")      -- Dreamflight
    
    -- External
    self:AddSpell(370537, "EXTERNAL", "MAJOR")       -- Stasis
    
    -- Movement
    self:AddSpell(358267, "MOVEMENT", "NORMAL")      -- Hover
    self:AddSpell(370553, "UTILITY", "MAJOR")        -- Tip the Scales
end