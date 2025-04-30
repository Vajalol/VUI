-------------------------------------------------------------------------------
-- Title: VUI BuffOverlay Themes
-- Author: VortexQ8
-- Theme integration for BuffOverlay module
-------------------------------------------------------------------------------

local _, VUI = ...
local BuffOverlay = VUI.modules.buffoverlay

if not BuffOverlay then return end

-- Theme-specific textures and animations for buff frames
BuffOverlay.ThemeAssets = {
    -- Phoenix Flame theme
    phoenixflame = {
        -- Border textures
        borders = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\border_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\border_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\border_critical.tga",
            beneficial = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\border_beneficial.tga",
            minor = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\border_minor.tga",
        },
        
        -- Glow textures
        glows = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\glow_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\glow_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\buffoverlay\\glow_critical.tga",
        },
        
        -- Effect textures
        effects = {
            flame = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame1.tga",
            ember = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame2.tga",
            spark = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame3.tga",
        },
        
        -- Default colors
        colors = {
            border = {r = 0.8, g = 0.4, b = 0.0},
            glow = {r = 1.0, g = 0.5, b = 0.0},
            icon = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            background = {r = 0.2, g = 0.1, b = 0.0, a = 0.8},
            timer = {r = 1.0, g = 0.8, b = 0.0},
        },
        
        -- Animation settings
        animations = {
            pulse = {
                duration = 1.5,
                minAlpha = 0.3,
                maxAlpha = 0.7,
            },
            hover = {
                duration = 0.3,
                scale = 1.1,
                glowAlpha = 0.8,
            },
            gain = {
                duration = 0.4,
                startScale = 0.8,
                peakScale = 1.15,
                endScale = 1.0,
                glowDuration = 0.6,
            },
            fade = {
                duration = 0.3,
                startScale = 1.0,
                endScale = 0.8,
            },
        },
    },
    
    -- Thunder Storm theme
    thunderstorm = {
        -- Border textures
        borders = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\border_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\border_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\border_critical.tga",
            beneficial = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\border_beneficial.tga",
            minor = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\border_minor.tga",
        },
        
        -- Glow textures
        glows = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\glow_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\glow_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\buffoverlay\\glow_critical.tga",
        },
        
        -- Effect textures
        effects = {
            lightning = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\animation\\lightning1.tga",
            charge = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\animation\\lightning2.tga",
            spark = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\animation\\lightning3.tga",
        },
        
        -- Default colors
        colors = {
            border = {r = 0.3, g = 0.5, b = 0.9},
            glow = {r = 0.4, g = 0.6, b = 1.0},
            icon = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            background = {r = 0.0, g = 0.1, b = 0.2, a = 0.8},
            timer = {r = 0.7, g = 0.9, b = 1.0},
        },
        
        -- Animation settings
        animations = {
            pulse = {
                duration = 1.2,
                minAlpha = 0.2,
                maxAlpha = 0.6,
            },
            hover = {
                duration = 0.2,
                scale = 1.08,
                glowAlpha = 0.7,
            },
            gain = {
                duration = 0.3,
                startScale = 0.9,
                peakScale = 1.1,
                endScale = 1.0,
                glowDuration = 0.5,
            },
            fade = {
                duration = 0.25,
                startScale = 1.0,
                endScale = 0.9,
            },
        },
    },
    
    -- Arcane Mystic theme
    arcanemystic = {
        -- Border textures
        borders = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\border_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\border_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\border_critical.tga",
            beneficial = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\border_beneficial.tga",
            minor = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\border_minor.tga",
        },
        
        -- Glow textures
        glows = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\glow_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\glow_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\buffoverlay\\glow_critical.tga",
        },
        
        -- Effect textures
        effects = {
            arcane = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\animation\\arcane1.tga",
            energy = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\animation\\arcane2.tga",
            sparkle = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\animation\\arcane3.tga",
        },
        
        -- Default colors
        colors = {
            border = {r = 0.6, g = 0.3, b = 0.8},
            glow = {r = 0.7, g = 0.3, b = 1.0},
            icon = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            background = {r = 0.1, g = 0.05, b = 0.2, a = 0.8},
            timer = {r = 0.8, g = 0.6, b = 1.0},
        },
        
        -- Animation settings
        animations = {
            pulse = {
                duration = 1.8,
                minAlpha = 0.2,
                maxAlpha = 0.6,
            },
            hover = {
                duration = 0.25,
                scale = 1.05,
                glowAlpha = 0.65,
            },
            gain = {
                duration = 0.5,
                startScale = 0.85,
                peakScale = 1.12,
                endScale = 1.0,
                glowDuration = 0.7,
            },
            fade = {
                duration = 0.35,
                startScale = 1.0,
                endScale = 0.85,
            },
        },
    },
    
    -- Fel Energy theme
    felenergy = {
        -- Border textures
        borders = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\border_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\border_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\border_critical.tga",
            beneficial = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\border_beneficial.tga",
            minor = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\border_minor.tga",
        },
        
        -- Glow textures
        glows = {
            standard = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\glow_standard.tga",
            important = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\glow_important.tga",
            critical = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\buffoverlay\\glow_critical.tga",
        },
        
        -- Effect textures
        effects = {
            fel = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\animation\\fel1.tga",
            energy = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\animation\\fel2.tga",
            spark = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\animation\\fel3.tga",
        },
        
        -- Default colors
        colors = {
            border = {r = 0.0, g = 0.8, b = 0.0},
            glow = {r = 0.1, g = 0.9, b = 0.1},
            icon = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            background = {r = 0.05, g = 0.15, b = 0.05, a = 0.8},
            timer = {r = 0.6, g = 1.0, b = 0.6},
        },
        
        -- Animation settings
        animations = {
            pulse = {
                duration = 1.4,
                minAlpha = 0.3,
                maxAlpha = 0.8,
            },
            hover = {
                duration = 0.2,
                scale = 1.1,
                glowAlpha = 0.9,
            },
            gain = {
                duration = 0.3,
                startScale = 0.8,
                peakScale = 1.2,
                endScale = 1.0,
                glowDuration = 0.6,
            },
            fade = {
                duration = 0.3,
                startScale = 1.0,
                endScale = 0.8,
            },
        },
    },
}

-- Create theme-specific animations for a buff frame
function BuffOverlay:CreateThemeAnimations(frame, theme)
    -- Clear existing animations
    if frame.animations then
        for _, anim in pairs(frame.animations) do
            if anim and anim:IsPlaying() then
                anim:Stop()
            end
        end
    end
    
    frame.animations = {}
    
    -- Get theme settings
    local themeData = self.ThemeAssets[theme] or self.ThemeAssets.thunderstorm
    local animations = themeData.animations
    
    -- Create pulse animation
    local pulseAnim = frame:CreateAnimationGroup()
    pulseAnim:SetLooping("REPEAT")
    
    local pulseIn = pulseAnim:CreateAnimation("Alpha")
    pulseIn:SetTarget(frame.themeOverlay)
    pulseIn:SetFromAlpha(animations.pulse.minAlpha)
    pulseIn:SetToAlpha(animations.pulse.maxAlpha)
    pulseIn:SetDuration(animations.pulse.duration / 2)
    pulseIn:SetOrder(1)
    pulseIn:SetSmoothing("IN")
    
    local pulseOut = pulseAnim:CreateAnimation("Alpha")
    pulseOut:SetTarget(frame.themeOverlay)
    pulseOut:SetFromAlpha(animations.pulse.maxAlpha)
    pulseOut:SetToAlpha(animations.pulse.minAlpha)
    pulseOut:SetDuration(animations.pulse.duration / 2)
    pulseOut:SetOrder(2)
    pulseOut:SetSmoothing("OUT")
    
    frame.animations.pulseAnimation = pulseAnim
    
    -- Create hover animation
    local hoverAnim = frame:CreateAnimationGroup()
    hoverAnim:SetLooping("NONE")
    
    local hoverGlowIn = hoverAnim:CreateAnimation("Alpha")
    hoverGlowIn:SetTarget(frame.glow)
    hoverGlowIn:SetFromAlpha(0)
    hoverGlowIn:SetToAlpha(animations.hover.glowAlpha)
    hoverGlowIn:SetDuration(animations.hover.duration)
    hoverGlowIn:SetOrder(1)
    
    local hoverScale = hoverAnim:CreateAnimation("Scale")
    hoverScale:SetFromScale(1.0, 1.0)
    hoverScale:SetToScale(animations.hover.scale, animations.hover.scale)
    hoverScale:SetDuration(animations.hover.duration)
    hoverScale:SetOrder(1)
    
    -- Make sure animation resets properly
    hoverAnim:SetScript("OnFinished", function()
        if not frame:IsMouseOver() then
            frame.glow:SetAlpha(0)
            frame:SetScale(1.0)
        end
    end)
    
    frame.animations.hoverAnimation = hoverAnim
    
    -- Create gain animation
    local gainAnim = frame:CreateAnimationGroup()
    gainAnim:SetLooping("NONE")
    
    local fadeIn = gainAnim:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(animations.gain.duration / 2)
    fadeIn:SetOrder(1)
    
    local scaleUp = gainAnim:CreateAnimation("Scale")
    scaleUp:SetFromScale(animations.gain.startScale, animations.gain.startScale)
    scaleUp:SetToScale(animations.gain.peakScale, animations.gain.peakScale)
    scaleUp:SetDuration(animations.gain.duration / 2)
    scaleUp:SetOrder(1)
    
    local scaleDown = gainAnim:CreateAnimation("Scale")
    scaleDown:SetFromScale(animations.gain.peakScale, animations.gain.peakScale)
    scaleDown:SetToScale(animations.gain.endScale, animations.gain.endScale)
    scaleDown:SetDuration(animations.gain.duration / 2)
    scaleDown:SetOrder(2)
    
    local glowIn = gainAnim:CreateAnimation("Alpha")
    glowIn:SetTarget(frame.glow)
    glowIn:SetFromAlpha(0)
    glowIn:SetToAlpha(animations.hover.glowAlpha)
    glowIn:SetDuration(animations.gain.glowDuration / 2)
    glowIn:SetOrder(1)
    
    local glowOut = gainAnim:CreateAnimation("Alpha")
    glowOut:SetTarget(frame.glow)
    glowOut:SetFromAlpha(animations.hover.glowAlpha)
    glowOut:SetToAlpha(0)
    glowOut:SetDuration(animations.gain.glowDuration / 2)
    glowOut:SetOrder(3)
    
    -- Make sure animation resets properly
    gainAnim:SetScript("OnFinished", function()
        frame.glow:SetAlpha(0)
        frame:SetScale(1.0)
    end)
    
    frame.animations.gainAnimation = gainAnim
    
    -- Create fade animation
    local fadeAnim = frame:CreateAnimationGroup()
    fadeAnim:SetLooping("NONE")
    
    local fadeOut = fadeAnim:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(animations.fade.duration)
    fadeOut:SetOrder(1)
    
    local scaleFade = fadeAnim:CreateAnimation("Scale")
    scaleFade:SetFromScale(animations.fade.startScale, animations.fade.startScale)
    scaleFade:SetToScale(animations.fade.endScale, animations.fade.endScale)
    scaleFade:SetDuration(animations.fade.duration)
    scaleFade:SetOrder(1)
    
    -- Make sure animation hides frame when finished
    fadeAnim:SetScript("OnFinished", function()
        frame:Hide()
    end)
    
    frame.animations.fadeAnimation = fadeAnim
    
    -- Create category-specific animations based on the current theme
    self:CreateCategoryAnimations(frame, theme)
end

-- Create category-specific animations for different buff types
function BuffOverlay:CreateCategoryAnimations(frame, theme)
    -- Get theme settings
    local themeData = self.ThemeAssets[theme] or self.ThemeAssets.thunderstorm
    
    -- Create theme-specific animations for critical auras
    local criticalAnim = frame:CreateAnimationGroup()
    criticalAnim:SetLooping("REPEAT")
    
    -- Specific animation pattern based on theme
    if theme == "phoenixflame" then
        -- Phoenix Flame uses pulsing glow and scale
        local criticalPulseIn = criticalAnim:CreateAnimation("Alpha")
        criticalPulseIn:SetTarget(frame.glow)
        criticalPulseIn:SetFromAlpha(0.3)
        criticalPulseIn:SetToAlpha(0.8)
        criticalPulseIn:SetDuration(0.8)
        criticalPulseIn:SetOrder(1)
        criticalPulseIn:SetSmoothing("IN")
        
        local criticalPulseOut = criticalAnim:CreateAnimation("Alpha")
        criticalPulseOut:SetTarget(frame.glow)
        criticalPulseOut:SetFromAlpha(0.8)
        criticalPulseOut:SetToAlpha(0.3)
        criticalPulseOut:SetDuration(0.8)
        criticalPulseOut:SetOrder(2)
        criticalPulseOut:SetSmoothing("OUT")
        
        local criticalScaleIn = criticalAnim:CreateAnimation("Scale")
        criticalScaleIn:SetFromScale(0.95, 0.95)
        criticalScaleIn:SetToScale(1.05, 1.05)
        criticalScaleIn:SetDuration(0.8)
        criticalScaleIn:SetOrder(1)
        criticalScaleIn:SetSmoothing("IN")
        
        local criticalScaleOut = criticalAnim:CreateAnimation("Scale")
        criticalScaleOut:SetFromScale(1.05, 1.05)
        criticalScaleOut:SetToScale(0.95, 0.95)
        criticalScaleOut:SetDuration(0.8)
        criticalScaleOut:SetOrder(2)
        criticalScaleOut:SetSmoothing("OUT")
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm uses electric flash effects
        local flashIn = criticalAnim:CreateAnimation("Alpha")
        flashIn:SetTarget(frame.themeOverlay)
        flashIn:SetFromAlpha(0.1)
        flashIn:SetToAlpha(0.7)
        flashIn:SetDuration(0.1)
        flashIn:SetOrder(1)
        
        local flashOut = criticalAnim:CreateAnimation("Alpha")
        flashOut:SetTarget(frame.themeOverlay)
        flashOut:SetFromAlpha(0.7)
        flashOut:SetToAlpha(0.1)
        flashOut:SetDuration(0.3)
        flashOut:SetOrder(2)
        
        local glowIn = criticalAnim:CreateAnimation("Alpha")
        glowIn:SetTarget(frame.glow)
        glowIn:SetFromAlpha(0.2)
        glowIn:SetToAlpha(0.6)
        glowIn:SetDuration(0.7)
        glowIn:SetOrder(3)
        
        local glowOut = criticalAnim:CreateAnimation("Alpha")
        glowOut:SetTarget(frame.glow)
        glowOut:SetFromAlpha(0.6)
        glowOut:SetToAlpha(0.2)
        glowOut:SetDuration(0.9)
        glowOut:SetOrder(4)
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic uses rotating and pulsing effect
        local rotateIn = criticalAnim:CreateAnimation("Rotation")
        rotateIn:SetDegrees(30)
        rotateIn:SetDuration(1.5)
        rotateIn:SetOrder(1)
        
        local rotateOut = criticalAnim:CreateAnimation("Rotation")
        rotateOut:SetDegrees(-30)
        rotateOut:SetDuration(1.5)
        rotateOut:SetOrder(2)
        
        local arcaneIn = criticalAnim:CreateAnimation("Alpha")
        arcaneIn:SetTarget(frame.themeOverlay)
        arcaneIn:SetFromAlpha(0.2)
        arcaneIn:SetToAlpha(0.6)
        arcaneIn:SetDuration(0.75)
        arcaneIn:SetOrder(1)
        
        local arcaneOut = criticalAnim:CreateAnimation("Alpha")
        arcaneOut:SetTarget(frame.themeOverlay)
        arcaneOut:SetFromAlpha(0.6)
        arcaneOut:SetToAlpha(0.2)
        arcaneOut:SetDuration(0.75)
        arcaneOut:SetOrder(3)
        
    elseif theme == "felenergy" then
        -- Fel Energy uses pulsing fel glow and scale
        local felPulseIn = criticalAnim:CreateAnimation("Alpha")
        felPulseIn:SetTarget(frame.themeOverlay)
        felPulseIn:SetFromAlpha(0.2)
        felPulseIn:SetToAlpha(0.8)
        felPulseIn:SetDuration(0.6)
        felPulseIn:SetOrder(1)
        
        local felPulseOut = criticalAnim:CreateAnimation("Alpha")
        felPulseOut:SetTarget(frame.themeOverlay)
        felPulseOut:SetFromAlpha(0.8)
        felPulseOut:SetToAlpha(0.2)
        felPulseOut:SetDuration(0.8)
        felPulseOut:SetOrder(2)
        
        local felScaleIn = criticalAnim:CreateAnimation("Scale")
        felScaleIn:SetFromScale(0.98, 0.98)
        felScaleIn:SetToScale(1.05, 1.05)
        felScaleIn:SetDuration(0.7)
        felScaleIn:SetOrder(1)
        
        local felScaleOut = criticalAnim:CreateAnimation("Scale")
        felScaleOut:SetFromScale(1.05, 1.05)
        felScaleOut:SetToScale(0.98, 0.98)
        felScaleOut:SetDuration(0.7)
        felScaleOut:SetOrder(3)
    end
    
    frame.animations.criticalAnimation = criticalAnim
    
    -- Create animation for important buffs
    local importantAnim = frame:CreateAnimationGroup()
    importantAnim:SetLooping("REPEAT")
    
    -- Different animation style based on theme
    if theme == "phoenixflame" or theme == "felenergy" then
        -- Slower pulsing for important buffs
        local pulseIn = importantAnim:CreateAnimation("Alpha")
        pulseIn:SetTarget(frame.themeOverlay)
        pulseIn:SetFromAlpha(0.1)
        pulseIn:SetToAlpha(0.4)
        pulseIn:SetDuration(1.2)
        pulseIn:SetOrder(1)
        pulseIn:SetSmoothing("IN")
        
        local pulseOut = importantAnim:CreateAnimation("Alpha")
        pulseOut:SetTarget(frame.themeOverlay)
        pulseOut:SetFromAlpha(0.4)
        pulseOut:SetToAlpha(0.1)
        pulseOut:SetDuration(1.2)
        pulseOut:SetOrder(2)
        pulseOut:SetSmoothing("OUT")
    else
        -- Gentle glow for important buffs for other themes
        local glowIn = importantAnim:CreateAnimation("Alpha")
        glowIn:SetTarget(frame.glow)
        glowIn:SetFromAlpha(0.1)
        glowIn:SetToAlpha(0.3)
        glowIn:SetDuration(1.5)
        glowIn:SetOrder(1)
        
        local glowOut = importantAnim:CreateAnimation("Alpha")
        glowOut:SetTarget(frame.glow)
        glowOut:SetFromAlpha(0.3)
        glowOut:SetToAlpha(0.1)
        glowOut:SetDuration(1.5)
        glowOut:SetOrder(2)
    end
    
    frame.animations.importantAnimation = importantAnim
end

-- Apply the current theme to a buff frame
function BuffOverlay:ApplyThemeToBuffFrame(frame)
    if not frame then return end
    
    -- Get current theme
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeData = self.ThemeAssets[theme]
    
    if not themeData then
        -- Use thunderstorm as default if theme data is missing
        theme = "thunderstorm"
        themeData = self.ThemeAssets.thunderstorm
    end
    
    -- Set theme-specific textures
    frame.themeOverlay:SetTexture(themeData.effects.spark or "Interface\\AddOns\\VUI\\media\\textures\\shared\\glow.tga")
    
    -- Apply theme colors
    local colors = themeData.colors
    frame.themeOverlay:SetVertexColor(colors.glow.r, colors.glow.g, colors.glow.b)
    frame.glow:SetVertexColor(colors.glow.r, colors.glow.g, colors.glow.b)
    
    -- Create theme-specific animations
    self:CreateThemeAnimations(frame, theme)
end

-- Start the appropriate animation for a buff category
function BuffOverlay:StartCategoryAnimation(frame, category)
    if not frame or not frame.animations then return end
    
    -- Stop all currently playing animations
    for name, anim in pairs(frame.animations) do
        if anim:IsPlaying() then
            anim:Stop()
        end
    end
    
    -- Apply different animations based on category
    if category == "CRITICAL" and frame.animations.criticalAnimation then
        frame.glow:SetAlpha(0.3) -- Set initial alpha for the animation
        frame.animations.criticalAnimation:Play()
        
    elseif category == "IMPORTANT" and frame.animations.importantAnimation then
        frame.glow:SetAlpha(0.1) -- Set initial alpha for the animation
        frame.animations.importantAnimation:Play()
        
    elseif frame.animations.pulseAnimation then
        -- Gentle pulse for other categories
        frame.themeOverlay:SetAlpha(0.1) -- Set initial alpha for the animation
        frame.animations.pulseAnimation:Play()
    end
end

-- Get theme-specific border texture for a category
function BuffOverlay:GetThemeBorderTexture(category)
    if not category then return nil end
    
    -- Get current theme
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeData = self.ThemeAssets[theme]
    
    if not themeData then
        -- Use thunderstorm as default if theme data is missing
        themeData = self.ThemeAssets.thunderstorm
    end
    
    -- Get category-specific border or fallback to standard
    local borderTexture = themeData.borders[category:lower()]
    
    if not borderTexture then
        -- Fallback to standard border
        borderTexture = themeData.borders.standard
    end
    
    -- Final fallback to default WoW border if texture still missing
    if not borderTexture then
        borderTexture = "Interface\\Buttons\\UI-Debuff-Overlays"
    end
    
    return borderTexture
end