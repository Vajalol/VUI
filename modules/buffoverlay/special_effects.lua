-- BuffOverlay Special Effects
-- This file implements advanced visual effects for important buffs/debuffs

local VUI, E = select(2, ...):unpack()
local BuffOverlay = E.Modules.BuffOverlay

-- Table to store special effect definitions
BuffOverlay.SpecialEffects = {
    -- Effect types
    EFFECTS = {
        PARTICLES = "particles",
        SPINNING_BORDER = "spinning_border",
        PULSE_GROW = "pulse_grow",
        COLOR_SHIFT = "color_shift",
        SPARKLE = "sparkle",
        LIGHTNING = "lightning",
        VORTEX = "vortex",
        SHADOW = "shadow",
        RUNE_CIRCLE = "rune_circle"
    },
    
    -- Default effect settings
    defaultSettings = {
        enabled = true,
        intensity = 0.7,
        speed = 1.0,
        useSound = true,
        colorCustomization = false,
        customColor = {r = 1, g = 1, b = 1},
        scale = 1.2,
        transparencyPulsing = true,
        applyForBuffCategories = {
            ["CRITICAL"] = true,
            ["IMPORTANT"] = true
        }
    }
}

-- Special Effects Spell Database
-- This table maps specific spell IDs to custom effects
BuffOverlay.SpecialEffectsSpells = {
    -- Death Knight
    [48707] = {effect = "SHADOW", name = "Anti-Magic Shell"},
    [48792] = {effect = "PULSE_GROW", name = "Icebound Fortitude"},
    [49039] = {effect = "SPINNING_BORDER", name = "Lichborne"},
    [55233] = {effect = "COLOR_SHIFT", name = "Vampiric Blood"},
    
    -- Demon Hunter
    [198589] = {effect = "PARTICLES", name = "Blur"},
    [187827] = {effect = "VORTEX", name = "Metamorphosis"},
    [196555] = {effect = "SPINNING_BORDER", name = "Netherwalk"},
    [212800] = {effect = "LIGHTNING", name = "Blur"},
    
    -- Druid
    [22812] = {effect = "PARTICLES", name = "Barkskin"},
    [61336] = {effect = "PULSE_GROW", name = "Survival Instincts"},
    [102558] = {effect = "VORTEX", name = "Incarnation: Guardian of Ursoc"},
    [102342] = {effect = "SPARKLE", name = "Ironbark"},
    [117679] = {effect = "RUNE_CIRCLE", name = "Incarnation"},
    
    -- Evoker
    [357170] = {effect = "PARTICLES", name = "Time Dilation"},
    [363916] = {effect = "LIGHTNING", name = "Obsidian Scales"},
    [370960] = {effect = "SPARKLE", name = "Emerald Communion"},
    [374348] = {effect = "VORTEX", name = "Renewing Blaze"},
    
    -- Hunter
    [186265] = {effect = "SPINNING_BORDER", name = "Aspect of the Turtle"},
    [264735] = {effect = "PULSE_GROW", name = "Survival of the Fittest"},
    [281195] = {effect = "PARTICLES", name = "Survival of the Fittest"},
    [212704] = {effect = "SHADOW", name = "The Beast Within"},
    
    -- Mage
    [45438] = {effect = "PARTICLES", name = "Ice Block"},
    [32612] = {effect = "SPINNING_BORDER", name = "Invisibility"},
    [110909] = {effect = "SPARKLE", name = "Alter Time"},
    [342246] = {effect = "VORTEX", name = "Alter Time"},
    
    -- Monk
    [125174] = {effect = "PARTICLES", name = "Touch of Karma"},
    [122783] = {effect = "PULSE_GROW", name = "Diffuse Magic"},
    [122278] = {effect = "SHADOW", name = "Dampen Harm"},
    [115203] = {effect = "SPINNING_BORDER", name = "Fortifying Brew"},
    
    -- Paladin
    [642] = {effect = "PARTICLES", name = "Divine Shield"},
    [1022] = {effect = "SPARKLE", name = "Blessing of Protection"},
    [204018] = {effect = "PULSE_GROW", name = "Blessing of Spellwarding"},
    [31884] = {effect = "LIGHTNING", name = "Avenging Wrath"},
    
    -- Priest
    [47585] = {effect = "SHADOW", name = "Dispersion"},
    [33206] = {effect = "SPARKLE", name = "Pain Suppression"},
    [47788] = {effect = "PARTICLES", name = "Guardian Spirit"},
    [64843] = {effect = "LIGHTNING", name = "Divine Hymn"},
    
    -- Rogue
    [1966] = {effect = "SPINNING_BORDER", name = "Feint"},
    [31224] = {effect = "SHADOW", name = "Cloak of Shadows"},
    [5277] = {effect = "PULSE_GROW", name = "Evasion"},
    [1784] = {effect = "PARTICLES", name = "Stealth"},
    
    -- Shaman
    [108271] = {effect = "LIGHTNING", name = "Astral Shift"},
    [210918] = {effect = "PARTICLES", name = "Ethereal Form"},
    [108281] = {effect = "SPARKLE", name = "Ancestral Guidance"},
    [198838] = {effect = "PULSE_GROW", name = "Earthen Wall Totem"},
    
    -- Warlock
    [104773] = {effect = "SHADOW", name = "Unending Resolve"},
    [212295] = {effect = "VORTEX", name = "Nether Ward"},
    [6789] = {effect = "PULSE_GROW", name = "Mortal Coil"},
    [108416] = {effect = "PARTICLES", name = "Dark Pact"},
    
    -- Warrior
    [871] = {effect = "SPINNING_BORDER", name = "Shield Wall"},
    [12975] = {effect = "PULSE_GROW", name = "Last Stand"},
    [118038] = {effect = "SHADOW", name = "Die by the Sword"},
    [97463] = {effect = "LIGHTNING", name = "Rallying Cry"},
    
    -- Raid/Dungeon Boss Mechanics (Critical)
    [409058] = {effect = "LIGHTNING", name = "Drenching Waters", isDebuff = true}, -- From Azureblade
    [370597] = {effect = "PARTICLES", name = "Sanguine Presence", isDebuff = true}, -- From Vault of the Incarnates
    [396792] = {effect = "VORTEX", name = "Primal Blizzard", isDebuff = true}, -- From Vault of the Incarnates
    [394719] = {effect = "SHADOW", name = "Imminent Extermination", isDebuff = true}, -- From Vault of the Incarnates
}

-- Additional spells to be tracked as important
local additionalImportantSpells = {
    -- Death Knight 
    [48265] = "Death's Advance",
    [81256] = "Dancing Rune Weapon",
    [63560] = "Dark Transformation",
    [49028] = "Dancing Rune Weapon",
    
    -- Demon Hunter
    [258920] = "Immolation Aura",
    [178740] = "Immolation Aura",
    [191427] = "Metamorphosis",
    [207810] = "Nether Bond",
    
    -- Druid
    [33891] = "Incarnation: Tree of Life",
    [106951] = "Berserk",
    [194223] = "Celestial Alignment",
    [102560] = "Incarnation: Chosen of Elune",
    
    -- Evoker
    [375087] = "Dragonrage",
    [359816] = "Dreamflight",
    [373835] = "Stasis (Dream)",
    [358267] = "Hover",
    
    -- Hunter
    [288613] = "Trueshot",
    [193530] = "Aspect of the Wild",
    [359844] = "Call of the Wild",
    [186289] = "Aspect of the Eagle",
    
    -- Mage
    [190319] = "Combustion",
    [12472] = "Icy Veins",
    [365362] = "Arcane Surge",
    [110960] = "Greater Invisibility",
    
    -- Monk
    [137639] = "Storm, Earth, and Fire",
    [152173] = "Serenity",
    [325197] = "Invoke Xuen, the White Tiger",
    [322118] = "Invoke Yu'lon, the Jade Serpent",
    
    -- Paladin
    [327510] = "Shield of the Righteous",
    [231895] = "Crusade",
    [105809] = "Holy Avenger",
    [200025] = "Beacon of Virtue",
    
    -- Priest
    [194249] = "Voidform",
    [10060] = "Power Infusion",
    [197268] = "Ray of Hope",
    [265202] = "Holy Word: Salvation",
    
    -- Rogue
    [13750] = "Adrenaline Rush",
    [121471] = "Shadow Blades",
    [185422] = "Shadow Dance",
    [212283] = "Symbols of Death",
    
    -- Shaman
    [114050] = "Ascendance",
    [192249] = "Storm Elemental",
    [198067] = "Fire Elemental",
    [51533] = "Feral Spirit",
    
    -- Warlock
    [205180] = "Summon Darkglare",
    [265187] = "Summon Demonic Tyrant",
    [111898] = "Grimoire: Felguard",
    [267171] = "Demonic Strength",
    
    -- Warrior
    [107574] = "Avatar",
    [262228] = "Deadly Calm",
    [1719] = "Recklessness",
    [46924] = "Bladestorm",
    
    -- Trinkets and other important effects
    [345231] = "Adaptive Synapses", -- Cosmic trinket
    [345539] = "Adaptive Plasma Discharge", -- Cosmic trinket
    [311444] = "Unbound Changeling", -- Shadowlands trinket
    [382426] = "Spiteful Stormbolt", -- Dragonflight trinket
    [381475] = "Screech of Mortality", -- Dragonflight trinket
    [396384] = "Frenzied Devastation", -- Dragonflight trinket
}

-- Initialize the special effects module
function BuffOverlay:InitializeSpecialEffects()
    -- Register default settings
    if not VUI.db.profile.modules.buffoverlay.specialEffects then
        VUI.db.profile.modules.buffoverlay.specialEffects = self.SpecialEffects.defaultSettings
    end
    
    -- Add additional important spells to tracked spells list
    for spellID, spellName in pairs(additionalImportantSpells) do
        -- Only add if not already present
        if not self.CategorySpells[spellID] then
            self.CategorySpells[spellID] = "IMPORTANT"
            
            -- Add to tracked spells for display
            if not VUI.db.profile.modules.buffoverlay.spells[spellID] then
                VUI.db.profile.modules.buffoverlay.spells[spellID] = true
            end
        end
    end
    
    -- Register hooks for aura display
    self:SecureHook("ApplyThemeToBuffFrame", "CheckAndApplySpecialEffects")
    
    -- Log initialization
    if VUI.debug then
        local specialEffectsCount = 0
        for _ in pairs(self.SpecialEffectsSpells) do
            specialEffectsCount = specialEffectsCount + 1
        end
        
        local additionalSpellsCount = 0
        for _ in pairs(additionalImportantSpells) do
            additionalSpellsCount = additionalSpellsCount + 1
        end
        
        VUI:Debug(string.format("BuffOverlay Special Effects initialized with %d effect definitions and %d additional important spells", 
            specialEffectsCount, additionalSpellsCount))
    end
end

-- Check if an aura should have special effects and apply them
function BuffOverlay:CheckAndApplySpecialEffects(frame)
    -- Skip if frame doesn't have a spell ID or special effects are disabled
    if not frame.spellID or not VUI.db.profile.modules.buffoverlay.specialEffects.enabled then
        return
    end
    
    local spellID = frame.spellID
    local settings = VUI.db.profile.modules.buffoverlay.specialEffects
    local category = frame.category
    
    -- Check if we should apply effects based on category
    local applyCategoryEffect = category and settings.applyForBuffCategories[category]
    
    -- Check if we have a specific effect for this spell
    local specificEffect = self.SpecialEffectsSpells[spellID]
    
    if specificEffect or applyCategoryEffect then
        -- If we have a specific effect, use it; otherwise use a default based on category
        local effectType = specificEffect and specificEffect.effect or self:GetDefaultEffectForCategory(category)
        
        -- Apply the effect
        self:ApplySpecialEffect(frame, effectType, settings)
    end
end

-- Get default effect type based on aura category
function BuffOverlay:GetDefaultEffectForCategory(category)
    local effects = self.SpecialEffects.EFFECTS
    
    if category == "CRITICAL" then
        return effects.PARTICLES
    elseif category == "IMPORTANT" then
        return effects.PULSE_GROW
    else
        return effects.SPINNING_BORDER
    end
end

-- Apply a special effect to a buff frame
function BuffOverlay:ApplySpecialEffect(frame, effectType, settings)
    local effects = self.SpecialEffects.EFFECTS
    local intensity = settings.intensity
    local speed = settings.speed
    local scale = settings.scale
    
    -- Clean up any existing special effects
    self:ClearSpecialEffects(frame)
    
    -- Create the special effect container if it doesn't exist
    if not frame.specialEffects then
        frame.specialEffects = {}
    end
    
    -- Apply the requested effect
    if effectType == effects.PARTICLES then
        self:ApplyParticleEffect(frame, intensity, speed)
    elseif effectType == effects.SPINNING_BORDER then
        self:ApplySpinningBorderEffect(frame, intensity, speed)
    elseif effectType == effects.PULSE_GROW then
        self:ApplyPulseGrowEffect(frame, intensity, speed)
    elseif effectType == effects.COLOR_SHIFT then
        self:ApplyColorShiftEffect(frame, intensity, speed)
    elseif effectType == effects.SPARKLE then
        self:ApplySparkleEffect(frame, intensity, speed)
    elseif effectType == effects.LIGHTNING then
        self:ApplyLightningEffect(frame, intensity, speed)
    elseif effectType == effects.VORTEX then
        self:ApplyVortexEffect(frame, intensity, speed)
    elseif effectType == effects.SHADOW then
        self:ApplyShadowEffect(frame, intensity, speed)
    elseif effectType == effects.RUNE_CIRCLE then
        self:ApplyRuneCircleEffect(frame, intensity, speed)
    end
    
    -- Apply scale if different from 1.0
    if scale ~= 1.0 then
        frame:SetScale(scale)
    end
    
    -- Apply transparency pulsing if enabled
    if settings.transparencyPulsing then
        self:ApplyTransparencyPulsing(frame, intensity, speed)
    end
    
    -- Play sound if enabled and this is a new buff
    if settings.useSound and not frame.specialEffectSoundPlayed and not InCombatLockdown() then
        self:PlaySpecialEffectSound(frame)
        frame.specialEffectSoundPlayed = true
    end
end

-- Clear all special effects from a frame
function BuffOverlay:ClearSpecialEffects(frame)
    if not frame.specialEffects then
        return
    end
    
    -- Stop any animations
    for _, animGroup in pairs(frame.specialEffects) do
        if animGroup.IsPlaying and animGroup:IsPlaying() then
            animGroup:Stop()
        end
    end
    
    -- Hide any textures
    for _, texture in pairs(frame.specialEffects) do
        if texture.Hide then
            texture:Hide()
        end
    end
    
    -- Reset scale
    frame:SetScale(1.0)
    
    -- Clear the special effects table
    wipe(frame.specialEffects)
end

-- Particle effect implementation (sparkly particles emanating from the buff icon)
function BuffOverlay:ApplyParticleEffect(frame, intensity, speed)
    -- Create particle container
    local particleContainer = CreateFrame("Frame", nil, frame)
    particleContainer:SetAllPoints()
    frame.specialEffects.particleContainer = particleContainer
    
    -- Create particles
    local numParticles = math.floor(8 * intensity)
    frame.specialEffects.particles = {}
    
    for i = 1, numParticles do
        local particle = particleContainer:CreateTexture(nil, "OVERLAY")
        particle:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
        particle:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
        particle:SetSize(frame:GetWidth() * 0.3, frame:GetHeight() * 0.3)
        particle:SetPoint("CENTER")
        particle:SetAlpha(0)
        particle:SetBlendMode("ADD")
        
        -- Create animation group for this particle
        local animGroup = particle:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        -- Movement animation (random direction)
        local angle = math.random() * 2 * math.pi
        local distance = frame:GetWidth() * 0.7
        local moveX = math.cos(angle) * distance
        local moveY = math.sin(angle) * distance
        
        local move = animGroup:CreateAnimation("Translation")
        move:SetOffset(moveX, moveY)
        move:SetDuration(1.5 / speed)
        move:SetOrder(1)
        
        -- Fade in/out
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.7 * intensity)
        fadeIn:SetDuration(0.5 / speed)
        fadeIn:SetOrder(1)
        
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.7 * intensity)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(1.0 / speed)
        fadeOut:SetOrder(2)
        
        -- Add to particles table
        table.insert(frame.specialEffects.particles, {
            texture = particle,
            animGroup = animGroup
        })
        
        -- Start with random delay
        C_Timer.After(math.random() * 1.5, function()
            animGroup:Play()
        end)
    end
end

-- Spinning border effect implementation
function BuffOverlay:ApplySpinningBorderEffect(frame, intensity, speed)
    -- Create a border texture that spins around the buff
    local spinBorder = frame:CreateTexture(nil, "OVERLAY")
    spinBorder:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\special\\spinborder")
    spinBorder:SetAllPoints()
    spinBorder:SetBlendMode("ADD")
    spinBorder:SetAlpha(0.7 * intensity)
    frame.specialEffects.spinBorder = spinBorder
    
    -- Create animation group
    local animGroup = spinBorder:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Rotation animation
    local spin = animGroup:CreateAnimation("Rotation")
    spin:SetDegrees(360)
    spin:SetDuration(4 / speed)
    spin:SetOrder(1)
    
    -- Start animation
    animGroup:Play()
    
    -- Store animation group for later reference
    frame.specialEffects.spinBorderAnim = animGroup
end

-- Pulse grow effect implementation
function BuffOverlay:ApplyPulseGrowEffect(frame, intensity, speed)
    -- Create animation group
    local animGroup = frame:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Scale animation
    local grow = animGroup:CreateAnimation("Scale")
    grow:SetScale(1.1 + (0.1 * intensity), 1.1 + (0.1 * intensity))
    grow:SetDuration(0.8 / speed)
    grow:SetOrder(1)
    grow:SetSmoothing("IN_OUT")
    
    local shrink = animGroup:CreateAnimation("Scale")
    shrink:SetScale(1/(1.1 + (0.1 * intensity)), 1/(1.1 + (0.1 * intensity)))
    shrink:SetDuration(0.8 / speed)
    shrink:SetOrder(2)
    shrink:SetSmoothing("IN_OUT")
    
    -- Start animation
    animGroup:Play()
    
    -- Store animation group for later reference
    frame.specialEffects.pulseGrowAnim = animGroup
end

-- Color shift effect implementation
function BuffOverlay:ApplyColorShiftEffect(frame, intensity, speed)
    -- Create animation group
    local animGroup = frame:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Set color animation targets
    local icon = frame.icon
    
    -- Create the color shift animation
    local function CreateColorAnimation(r1, g1, b1, r2, g2, b2, duration, order)
        local colorAnim = animGroup:CreateAnimation()
        colorAnim:SetDuration(duration / speed)
        colorAnim:SetOrder(order)
        
        colorAnim:SetScript("OnUpdate", function(self)
            local progress = self:GetProgress()
            local r = r1 + (r2 - r1) * progress
            local g = g1 + (g2 - g1) * progress
            local b = b1 + (b2 - b1) * progress
            
            icon:SetVertexColor(r, g, b)
        end)
        
        return colorAnim
    end
    
    -- Define color animation sequence
    local intensity = math.min(intensity, 1.0) -- Cap intensity at 1.0
    
    -- Original color to shift color 1
    CreateColorAnimation(1, 1, 1, 1, 0.5, 0.5, 1.0, 1)
    
    -- Shift color 1 to shift color 2
    CreateColorAnimation(1, 0.5, 0.5, 0.5, 1, 0.5, 1.0, 2)
    
    -- Shift color 2 to shift color 3
    CreateColorAnimation(0.5, 1, 0.5, 0.5, 0.5, 1, 1.0, 3)
    
    -- Shift color 3 back to original
    CreateColorAnimation(0.5, 0.5, 1, 1, 1, 1, 1.0, 4)
    
    -- Start animation
    animGroup:Play()
    
    -- Store animation group for later reference
    frame.specialEffects.colorShiftAnim = animGroup
end

-- Sparkle effect implementation
function BuffOverlay:ApplySparkleEffect(frame, intensity, speed)
    -- Create sparkle textures
    local numSparkles = math.floor(4 * intensity)
    frame.specialEffects.sparkles = {}
    
    for i = 1, numSparkles do
        local sparkle = frame:CreateTexture(nil, "OVERLAY")
        sparkle:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
        sparkle:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
        sparkle:SetSize(frame:GetWidth() * 0.4, frame:GetHeight() * 0.4)
        
        -- Position randomly within the frame
        local xOffset = (math.random() * 0.8 - 0.4) * frame:GetWidth()
        local yOffset = (math.random() * 0.8 - 0.4) * frame:GetHeight()
        sparkle:SetPoint("CENTER", frame, "CENTER", xOffset, yOffset)
        
        sparkle:SetBlendMode("ADD")
        sparkle:SetAlpha(0)
        
        -- Create animation group
        local animGroup = sparkle:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        -- Fade in
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.8 * intensity)
        fadeIn:SetDuration(0.3 / speed)
        fadeIn:SetOrder(1)
        
        -- Hold
        local hold = animGroup:CreateAnimation("Alpha")
        hold:SetFromAlpha(0.8 * intensity)
        hold:SetToAlpha(0.8 * intensity)
        hold:SetDuration(0.2 / speed)
        hold:SetOrder(2)
        
        -- Fade out
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.8 * intensity)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.3 / speed)
        fadeOut:SetOrder(3)
        
        -- Wait
        local wait = animGroup:CreateAnimation("Alpha")
        wait:SetFromAlpha(0)
        wait:SetToAlpha(0)
        wait:SetDuration((1.5 + math.random() * 2) / speed)
        wait:SetOrder(4)
        
        -- Add to sparkles table
        table.insert(frame.specialEffects.sparkles, {
            texture = sparkle,
            animGroup = animGroup
        })
        
        -- Start with random delay
        C_Timer.After(math.random() * 2, function()
            animGroup:Play()
        end)
    end
end

-- Lightning effect implementation
function BuffOverlay:ApplyLightningEffect(frame, intensity, speed)
    -- Create lightning textures
    local numBolts = math.floor(3 * intensity)
    frame.specialEffects.lightningBolts = {}
    
    for i = 1, numBolts do
        local bolt = frame:CreateTexture(nil, "OVERLAY")
        bolt:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\special\\lightning")
        bolt:SetSize(frame:GetWidth() * 1.5, frame:GetHeight() * 0.3)
        bolt:SetBlendMode("ADD")
        bolt:SetAlpha(0)
        
        -- Randomly position and rotate
        local angle = math.random() * 360
        bolt:SetPoint("CENTER")
        bolt:SetRotation(math.rad(angle))
        
        -- Create animation group
        local animGroup = bolt:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        -- Flash in and out
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.8 * intensity)
        fadeIn:SetDuration(0.1 / speed)
        fadeIn:SetOrder(1)
        
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.8 * intensity)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.1 / speed)
        fadeOut:SetOrder(2)
        
        -- Wait
        local wait = animGroup:CreateAnimation("Alpha")
        wait:SetFromAlpha(0)
        wait:SetToAlpha(0)
        wait:SetDuration((2 + math.random() * 2) / speed)
        wait:SetOrder(3)
        
        -- Add to lightning table
        table.insert(frame.specialEffects.lightningBolts, {
            texture = bolt,
            animGroup = animGroup
        })
        
        -- Start with random delay
        C_Timer.After(math.random() * 1.5, function()
            animGroup:Play()
        end)
    end
end

-- Vortex effect implementation
function BuffOverlay:ApplyVortexEffect(frame, intensity, speed)
    -- Create vortex texture
    local vortex = frame:CreateTexture(nil, "OVERLAY")
    vortex:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\special\\vortex")
    vortex:SetAllPoints()
    vortex:SetBlendMode("ADD")
    vortex:SetAlpha(0.7 * intensity)
    frame.specialEffects.vortex = vortex
    
    -- Create animation group
    local animGroup = vortex:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Rotation animation
    local spin = animGroup:CreateAnimation("Rotation")
    spin:SetDegrees(-360) -- Spin counter-clockwise
    spin:SetDuration(6 / speed)
    spin:SetOrder(1)
    
    -- Start animation
    animGroup:Play()
    
    -- Store animation group for later reference
    frame.specialEffects.vortexAnim = animGroup
end

-- Shadow effect implementation
function BuffOverlay:ApplyShadowEffect(frame, intensity, speed)
    -- Create shadow texture
    local shadow = frame:CreateTexture(nil, "BACKGROUND")
    shadow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\special\\shadow")
    shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -8, 8)
    shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 8, -8)
    shadow:SetBlendMode("BLEND")
    shadow:SetAlpha(0.6 * intensity)
    frame.specialEffects.shadow = shadow
    
    -- Create animation group
    local animGroup = shadow:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Pulse animation
    local fadeOut = animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.6 * intensity)
    fadeOut:SetToAlpha(0.3 * intensity)
    fadeOut:SetDuration(1.2 / speed)
    fadeOut:SetOrder(1)
    fadeOut:SetSmoothing("IN_OUT")
    
    local fadeIn = animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.3 * intensity)
    fadeIn:SetToAlpha(0.6 * intensity)
    fadeIn:SetDuration(1.2 / speed)
    fadeIn:SetOrder(2)
    fadeIn:SetSmoothing("IN_OUT")
    
    -- Start animation
    animGroup:Play()
    
    -- Store animation group for later reference
    frame.specialEffects.shadowAnim = animGroup
end

-- Rune circle effect implementation
function BuffOverlay:ApplyRuneCircleEffect(frame, intensity, speed)
    -- Create outer circle rune
    local outerRune = frame:CreateTexture(nil, "BACKGROUND")
    outerRune:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\special\\runecircle")
    outerRune:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, 12)
    outerRune:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 12, -12)
    outerRune:SetBlendMode("ADD")
    outerRune:SetAlpha(0.6 * intensity)
    frame.specialEffects.outerRune = outerRune
    
    -- Create inner circle rune
    local innerRune = frame:CreateTexture(nil, "OVERLAY")
    innerRune:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\special\\rune")
    innerRune:SetAllPoints()
    innerRune:SetBlendMode("ADD")
    innerRune:SetAlpha(0.7 * intensity)
    frame.specialEffects.innerRune = innerRune
    
    -- Create animation groups
    local outerAnimGroup = outerRune:CreateAnimationGroup()
    outerAnimGroup:SetLooping("REPEAT")
    
    local innerAnimGroup = innerRune:CreateAnimationGroup()
    innerAnimGroup:SetLooping("REPEAT")
    
    -- Outer circle rotation (slow)
    local outerSpin = outerAnimGroup:CreateAnimation("Rotation")
    outerSpin:SetDegrees(360)
    outerSpin:SetDuration(12 / speed)
    outerSpin:SetOrder(1)
    
    -- Inner rune rotation (faster, opposite direction)
    local innerSpin = innerAnimGroup:CreateAnimation("Rotation")
    innerSpin:SetDegrees(-360)
    innerSpin:SetDuration(6 / speed)
    innerSpin:SetOrder(1)
    
    -- Start animations
    outerAnimGroup:Play()
    innerAnimGroup:Play()
    
    -- Store animation groups for later reference
    frame.specialEffects.outerRuneAnim = outerAnimGroup
    frame.specialEffects.innerRuneAnim = innerAnimGroup
end

-- Apply transparency pulsing effect
function BuffOverlay:ApplyTransparencyPulsing(frame, intensity, speed)
    -- Create animation group if it doesn't exist
    if not frame.specialEffects.transparencyAnim then
        local animGroup = frame:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        -- Fade out slightly
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.7)
        fadeOut:SetDuration(1.0 / speed)
        fadeOut:SetOrder(1)
        fadeOut:SetSmoothing("IN_OUT")
        
        -- Fade back in
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.7)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(1.0 / speed)
        fadeIn:SetOrder(2)
        fadeIn:SetSmoothing("IN_OUT")
        
        frame.specialEffects.transparencyAnim = animGroup
    end
    
    -- Start animation
    frame.specialEffects.transparencyAnim:Play()
end

-- Play sound effect for special buff
function BuffOverlay:PlaySpecialEffectSound(frame)
    if InCombatLockdown() then return end -- Don't play sounds in combat
    
    -- Determine sound file based on category or specific spell
    local soundFile
    local category = frame.category
    
    if category == "CRITICAL" then
        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\criticaleffect.ogg"
    elseif category == "IMPORTANT" then
        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\importanteffect.ogg"
    else
        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\specialeffect.ogg"
    end
    
    -- Play the sound if we have a file
    if soundFile and PlaySoundFile then
        PlaySoundFile(soundFile, "SFX")
    end
end

-- Create configuration UI for special effects
function BuffOverlay:CreateSpecialEffectsConfig(container)
    -- Settings reference
    local settings = VUI.db.profile.modules.buffoverlay.specialEffects
    
    -- Header
    local header = AceGUI:Create("Heading")
    header:SetText("Special Effects for Important Buffs")
    header:SetFullWidth(true)
    container:AddChild(header)
    
    -- Description
    local desc = AceGUI:Create("Label")
    desc:SetText("Configure advanced visual effects for important buffs and debuffs. These enhanced visuals help you easily spot critical gameplay buffs.")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    -- Enable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Special Effects")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(settings.enabled)
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.enabled = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(enableCheckbox)
    
    -- Intensity slider
    local intensitySlider = AceGUI:Create("Slider")
    intensitySlider:SetLabel("Effect Intensity")
    intensitySlider:SetWidth(300)
    intensitySlider:SetSliderValues(0.1, 1.0, 0.05)
    intensitySlider:SetValue(settings.intensity)
    intensitySlider:SetDisabled(not settings.enabled)
    intensitySlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.intensity = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(intensitySlider)
    
    -- Speed slider
    local speedSlider = AceGUI:Create("Slider")
    speedSlider:SetLabel("Effect Speed")
    speedSlider:SetWidth(300)
    speedSlider:SetSliderValues(0.5, 2.0, 0.05)
    speedSlider:SetValue(settings.speed)
    speedSlider:SetDisabled(not settings.enabled)
    speedSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.speed = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(speedSlider)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Icon Scale")
    scaleSlider:SetWidth(300)
    scaleSlider:SetSliderValues(1.0, 1.5, 0.05)
    scaleSlider:SetValue(settings.scale)
    scaleSlider:SetDisabled(not settings.enabled)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.scale = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(scaleSlider)
    
    -- Sound toggle
    local soundCheckbox = AceGUI:Create("CheckBox")
    soundCheckbox:SetLabel("Play Sound Effects")
    soundCheckbox:SetWidth(200)
    soundCheckbox:SetValue(settings.useSound)
    soundCheckbox:SetDisabled(not settings.enabled)
    soundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.useSound = value
    end)
    container:AddChild(soundCheckbox)
    
    -- Transparency pulsing toggle
    local pulsingCheckbox = AceGUI:Create("CheckBox")
    pulsingCheckbox:SetLabel("Enable Transparency Pulsing")
    pulsingCheckbox:SetWidth(250)
    pulsingCheckbox:SetValue(settings.transparencyPulsing)
    pulsingCheckbox:SetDisabled(not settings.enabled)
    pulsingCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.transparencyPulsing = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(pulsingCheckbox)
    
    -- Category selection header
    local catHeader = AceGUI:Create("Heading")
    catHeader:SetText("Apply Effects to Categories")
    catHeader:SetFullWidth(true)
    container:AddChild(catHeader)
    
    -- Category checkboxes
    local criticalCheckbox = AceGUI:Create("CheckBox")
    criticalCheckbox:SetLabel("Critical Auras")
    criticalCheckbox:SetWidth(150)
    criticalCheckbox:SetValue(settings.applyForBuffCategories["CRITICAL"])
    criticalCheckbox:SetDisabled(not settings.enabled)
    criticalCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.applyForBuffCategories["CRITICAL"] = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(criticalCheckbox)
    
    local importantCheckbox = AceGUI:Create("CheckBox")
    importantCheckbox:SetLabel("Important Auras")
    importantCheckbox:SetWidth(150)
    importantCheckbox:SetValue(settings.applyForBuffCategories["IMPORTANT"])
    importantCheckbox:SetDisabled(not settings.enabled)
    importantCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.applyForBuffCategories["IMPORTANT"] = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(importantCheckbox)
    
    local beneficialCheckbox = AceGUI:Create("CheckBox")
    beneficialCheckbox:SetLabel("Beneficial Auras")
    beneficialCheckbox:SetWidth(150)
    beneficialCheckbox:SetValue(settings.applyForBuffCategories["BENEFICIAL"] or false)
    beneficialCheckbox:SetDisabled(not settings.enabled)
    beneficialCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.applyForBuffCategories["BENEFICIAL"] = value
        -- Update all auras
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end)
    container:AddChild(beneficialCheckbox)
end