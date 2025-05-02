-- BuffOverlay Categories
-- This file defines the buff/debuff categorization system

local VUI, E = select(2, ...):unpack()
local BuffOverlay = E.Modules.BuffOverlay

-- Define the buff/debuff categories
BuffOverlay.Categories = {
    ["CRITICAL"] = {
        color = {r = 1.0, g = 0.1, b = 0.1},  -- Red
        priority = 100,
        glow = true,
        pulse = true,
        sound = "critical"
    },
    ["IMPORTANT"] = {
        color = {r = 1.0, g = 0.5, b = 0.0},  -- Orange
        priority = 80,
        glow = true,
        pulse = false,
        sound = "important"
    },
    ["BENEFICIAL"] = {
        color = {r = 0.0, g = 0.8, b = 0.1},  -- Green
        priority = 60,
        glow = false,
        pulse = false,
        sound = "buff"
    },
    ["STANDARD"] = {
        color = {r = 0.6, g = 0.6, b = 0.6},  -- Gray
        priority = 40,
        glow = false,
        pulse = false,
        sound = nil
    },
    ["MINOR"] = {
        color = {r = 0.4, g = 0.4, b = 0.4},  -- Light Gray
        priority = 20,
        glow = false,
        pulse = false,
        sound = nil
    }
}

-- Database of special auras with their assigned categories
BuffOverlay.CategorySpells = {
    -- CRITICAL category - Major defensive cooldowns and boss mechanics
    [47788] = "CRITICAL",  -- Guardian Spirit
    [33206] = "CRITICAL",  -- Pain Suppression
    [116849] = "CRITICAL", -- Life Cocoon
    [6940] = "CRITICAL",   -- Blessing of Sacrifice
    [1022] = "CRITICAL",   -- Blessing of Protection
    [102342] = "CRITICAL", -- Ironbark
    [374227] = "CRITICAL", -- Zephyr (Evoker)
    [31224] = "CRITICAL",  -- Cloak of Shadows
    [118038] = "CRITICAL", -- Die by the Sword
    [404977] = "CRITICAL", -- Shield of Earth (Earthen Pillar)
    [384631] = "CRITICAL", -- Wildseed Awakening (Dormancy)

    -- IMPORTANT category - Major buffs and debuffs that significantly affect gameplay
    [10060] = "IMPORTANT",  -- Power Infusion
    [64843] = "IMPORTANT",  -- Divine Hymn
    [390667] = "IMPORTANT", -- Blessing of Spring
    [64901] = "IMPORTANT",  -- Symbol of Hope
    [108281] = "IMPORTANT", -- Ancestral Guidance
    [51490] = "IMPORTANT",  -- Thunderstorm
    [51514] = "IMPORTANT",  -- Hex
    [15286] = "IMPORTANT",  -- Vampiric Embrace

    -- BENEFICIAL category - Useful buffs that enhance performance
    [21562] = "BENEFICIAL",  -- Power Word: Fortitude
    [1459] = "BENEFICIAL",   -- Arcane Intellect
    [6673] = "BENEFICIAL",   -- Battle Shout
    [203538] = "BENEFICIAL", -- Greater Blessing of Kings
    [203539] = "BENEFICIAL", -- Greater Blessing of Wisdom
    [116956] = "BENEFICIAL", -- Grace of Air
    [125151] = "BENEFICIAL", -- Feather Fall
    [381752] = "BENEFICIAL", -- Augmentation Evoker - Ebon Might

    -- STANDARD category - Default category for normal buffs
    -- No need to explicitly list; this is the default

    -- MINOR category - Minor buffs like food, flasks, etc.
    [87959] = "MINOR",   -- Drink
    [308433] = "MINOR",  -- Temporal Distortion 
    [345801] = "MINOR",  -- Soulfang
    [342938] = "MINOR",  -- Unstable Rift Energy
    [356567] = "MINOR",  -- Shadewalker
    [176151] = "MINOR",  -- Breath of the Winds
    [226510] = "MINOR",  -- Sanguine Ichor
}

-- Custom category assignments for different themes
local themeCategories = {
    ["thunderstorm"] = {
        ["CRITICAL"] = {r = 1.0, g = 0.2, b = 0.2},   -- Red
        ["IMPORTANT"] = {r = 0.0, g = 0.6, b = 1.0},  -- Electric Blue
        ["BENEFICIAL"] = {r = 0.0, g = 1.0, b = 0.6}, -- Turquoise
        ["STANDARD"] = {r = 0.5, g = 0.5, b = 0.7},   -- Light Blue-Gray
        ["MINOR"] = {r = 0.4, g = 0.4, b = 0.6}       -- Dark Blue-Gray
    },
    ["phoenixflame"] = {
        ["CRITICAL"] = {r = 1.0, g = 0.0, b = 0.0},   -- Bright Red
        ["IMPORTANT"] = {r = 1.0, g = 0.5, b = 0.0},  -- Fiery Orange
        ["BENEFICIAL"] = {r = 1.0, g = 0.8, b = 0.0}, -- Golden Yellow
        ["STANDARD"] = {r = 0.7, g = 0.5, b = 0.3},   -- Amber
        ["MINOR"] = {r = 0.5, g = 0.3, b = 0.2}       -- Brown
    },
    ["arcanemystic"] = {
        ["CRITICAL"] = {r = 1.0, g = 0.3, b = 1.0},   -- Bright Pink
        ["IMPORTANT"] = {r = 0.7, g = 0.0, b = 1.0},  -- Purple
        ["BENEFICIAL"] = {r = 0.5, g = 0.0, b = 0.8}, -- Dark Purple
        ["STANDARD"] = {r = 0.6, g = 0.5, b = 0.8},   -- Lavender
        ["MINOR"] = {r = 0.4, g = 0.3, b = 0.6}       -- Dark Lavender
    },
    ["felenergy"] = {
        ["CRITICAL"] = {r = 0.0, g = 1.0, b = 0.0},   -- Bright Green
        ["IMPORTANT"] = {r = 0.4, g = 0.8, b = 0.0},  -- Lime Green
        ["BENEFICIAL"] = {r = 0.0, g = 0.6, b = 0.0}, -- Dark Green
        ["STANDARD"] = {r = 0.3, g = 0.5, b = 0.3},   -- Muted Green
        ["MINOR"] = {r = 0.2, g = 0.3, b = 0.2}       -- Dark Green
    }
}

-- Function to determine the category of an aura based on its type and properties
function BuffOverlay:DetermineCategoryForAura(spellID, auraType, isCastByPlayer, isDuration, isBoss)
    -- First, check if there's an explicit category for this spell ID
    if self.CategorySpells[spellID] then
        return self.CategorySpells[spellID]
    end
    
    -- Check for boss auras - usually critical
    if isBoss then
        return "CRITICAL"
    end
    
    -- If it's a player-cast helpful aura
    if isCastByPlayer and auraType == "HELPFUL" then
        -- Important class cooldowns are usually short duration
        if isDuration and isDuration < 30 then
            return "IMPORTANT"
        else
            return "BENEFICIAL"
        end
    end
    
    -- If it's a player-cast harmful aura
    if isCastByPlayer and auraType == "HARMFUL" then
        -- Important debuffs tend to be shorter duration
        if isDuration and isDuration < 15 then
            return "IMPORTANT"
        else
            return "STANDARD"
        end
    end
    
    -- Check for harmful affects applied to player
    if auraType == "HARMFUL" then
        -- Default harmful auras are important if short-duration
        if isDuration and isDuration < 10 then
            return "IMPORTANT"
        else
            return "STANDARD"
        end
    end
    
    -- Default to standard for all other cases
    return "STANDARD"
end

-- Apply theme coloring to categories
function BuffOverlay:ApplyThemeToCategories(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Check if we have specific colors for this theme
    if themeCategories[theme] then
        -- Apply the theme colors to each category
        for categoryName, categoryInfo in pairs(self.Categories) do
            if themeCategories[theme][categoryName] then
                local themeColor = themeCategories[theme][categoryName]
                categoryInfo.color.r = themeColor.r
                categoryInfo.color.g = themeColor.g
                categoryInfo.color.b = themeColor.b
            end
        end
    end
end

-- Apply category-specific visual enhancement to a buff frame
function BuffOverlay:ApplyCategoryVisuals(frame, category)
    if not category or not self.Categories[category] then
        -- Default if no category specified
        category = "STANDARD"
    end
    
    local categoryInfo = self.Categories[category]
    
    -- Apply border color based on category
    if frame.border then
        frame.border:SetVertexColor(
            categoryInfo.color.r,
            categoryInfo.color.g,
            categoryInfo.color.b,
            1.0
        )
    end
    
    -- Apply glow effect if enabled for this category
    if frame.glow then
        if categoryInfo.glow then
            frame.glow:SetVertexColor(
                categoryInfo.color.r,
                categoryInfo.color.g,
                categoryInfo.color.b,
                0.7
            )
            
            -- Create or update glow animation
            if not frame.animations.glowAnimation then
                local animGroup = frame:CreateAnimationGroup()
                local fadeIn = animGroup:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(0.0)
                fadeIn:SetToAlpha(0.7)
                fadeIn:SetDuration(0.5)
                fadeIn:SetOrder(1)
                
                local fadeOut = animGroup:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(0.7)
                fadeOut:SetToAlpha(0.0)
                fadeOut:SetDuration(0.5)
                fadeOut:SetOrder(2)
                
                animGroup:SetLooping("REPEAT")
                frame.animations.glowAnimation = animGroup
                
                -- Set the target of the animation
                fadeIn:SetTarget(frame.glow)
                fadeOut:SetTarget(frame.glow)
            end
            
            -- Start the animation
            if categoryInfo.pulse then
                frame.animations.glowAnimation:Play()
            else
                if frame.animations.glowAnimation:IsPlaying() then
                    frame.animations.glowAnimation:Stop()
                end
                frame.glow:SetAlpha(0.5)
            end
        else
            -- No glow for this category
            if frame.animations.glowAnimation and frame.animations.glowAnimation:IsPlaying() then
                frame.animations.glowAnimation:Stop()
            end
            frame.glow:SetAlpha(0)
        end
    end
    
    -- Play sound if enabled for this category
    if categoryInfo.sound and VUI.db.profile.modules.buffoverlay.enableCategorySounds then
        -- Only play once per session per buff
        if not frame.soundPlayed and frame.spellID then
            local soundKey = "buff_" .. frame.spellID
            if not BuffOverlay.playedSounds then
                BuffOverlay.playedSounds = {}
            end
            
            if not BuffOverlay.playedSounds[soundKey] then
                -- Play the sound
                local soundFile
                if categoryInfo.sound == "critical" then
                    soundFile = VUI.Media:Fetch("sound", "critical_buff")
                elseif categoryInfo.sound == "important" then
                    soundFile = VUI.Media:Fetch("sound", "important_buff") 
                elseif categoryInfo.sound == "buff" then
                    soundFile = VUI.Media:Fetch("sound", "buff_gained")
                end
                
                if soundFile then
                    PlaySoundFile(soundFile, "Master")
                    BuffOverlay.playedSounds[soundKey] = true
                    frame.soundPlayed = true
                end
            end
        end
    end
end

-- Register for callbacks
function BuffOverlay:InitializeCategories()
    -- Apply theme on initialization and when theme changes
    self:ApplyThemeToCategories()
    
    -- Register callback for theme changes
    VUI.RegisterCallback(self, "ThemeChanged", function(_, theme)
        self:ApplyThemeToCategories(theme)
        
        -- Update current auras to reflect theme changes
        self:UpdateAuras("player")
        self:UpdateAuras("target")
        self:UpdateAuras("focus")
    end)
end