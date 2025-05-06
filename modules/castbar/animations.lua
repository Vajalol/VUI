--[[
    VUI - Castbar Animations
    Version: 0.0.1
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Castbar = VUI.Castbar
local MediaPath = "Interface\\AddOns\\VUI\\media\\"

-- Animation utilities
local function CreateAlphaAnimation(frame, fromAlpha, toAlpha, duration, startDelay, smoothing)
    local animGroup = frame:CreateAnimationGroup()
    local anim = animGroup:CreateAnimation("Alpha")
    anim:SetFromAlpha(fromAlpha)
    anim:SetToAlpha(toAlpha)
    anim:SetDuration(duration)
    anim:SetSmoothing(smoothing or "OUT")
    
    if startDelay and startDelay > 0 then
        anim:SetStartDelay(startDelay)
    end
    
    return animGroup
end

local function CreateScaleAnimation(frame, fromScaleX, fromScaleY, toScaleX, toScaleY, duration, startDelay, smoothing)
    local animGroup = frame:CreateAnimationGroup()
    local anim = animGroup:CreateAnimation("Scale")
    anim:SetFromScale(fromScaleX, fromScaleY)
    anim:SetToScale(toScaleX, toScaleY)
    anim:SetDuration(duration)
    anim:SetSmoothing(smoothing or "OUT")
    
    if startDelay and startDelay > 0 then
        anim:SetStartDelay(startDelay)
    end
    
    return animGroup
end

local function CreateTranslationAnimation(frame, offsetX, offsetY, duration, startDelay, smoothing)
    local animGroup = frame:CreateAnimationGroup()
    local anim = animGroup:CreateAnimation("Translation")
    anim:SetOffset(offsetX, offsetY)
    anim:SetDuration(duration)
    anim:SetSmoothing(smoothing or "OUT")
    
    if startDelay and startDelay > 0 then
        anim:SetStartDelay(startDelay)
    end
    
    return animGroup
end

-- Initialize animations for a castbar
function Castbar:InitializeCastbarAnimations(castbar)
    if not castbar then return end
    
    -- Base animations (theme-agnostic)
    local animations = self.settings.animations
    
    -- Cast start animation
    if animations.castStart then
        -- Flash animation for bar
        castbar.startFlashAnim = CreateAlphaAnimation(castbar.bar, 0.5, 1.0, 0.3, 0, "IN_OUT")
        
        -- Scale animation for icon (if it exists)
        if castbar.icon and animations.iconPulse then
            castbar.iconStartAnim = CreateScaleAnimation(castbar.icon, 1.3, 1.3, 1.0, 1.0, 0.3, 0, "OUT")
        end
        
        -- Text scale animation
        if animations.textPulse then
            castbar.textStartAnim = CreateScaleAnimation(castbar.text, 1.2, 1.2, 1.0, 1.0, 0.3, 0, "OUT")
        end
    end
    
    -- Cast success animation
    if animations.castComplete then
        -- Flash animation for bar
        castbar.successFlashAnim = CreateAlphaAnimation(castbar.bar, 1.0, 0.7, 0.5, 0, "IN_OUT")
        
        -- Scale animation for completion text
        if castbar.completionText and animations.textPulse then
            castbar.completionTextAnim = CreateScaleAnimation(castbar.completionText, 1.5, 1.5, 1.0, 1.0, 0.3, 0, "OUT")
        end
    end
    
    -- Cast fail animation
    if animations.castFail then
        -- Shake animation for the entire castbar
        castbar.failShakeAnim = CreateFrame("Frame", nil, castbar)
        castbar.failShakeAnim:SetAllPoints()
        
        local shakeAnimGroup = castbar.failShakeAnim:CreateAnimationGroup()
        local shake1 = shakeAnimGroup:CreateAnimation("Translation")
        shake1:SetOffset(5, 0)
        shake1:SetDuration(0.1)
        shake1:SetOrder(1)
        
        local shake2 = shakeAnimGroup:CreateAnimation("Translation")
        shake2:SetOffset(-10, 0)
        shake2:SetDuration(0.1)
        shake2:SetOrder(2)
        
        local shake3 = shakeAnimGroup:CreateAnimation("Translation")
        shake3:SetOffset(10, 0)
        shake3:SetDuration(0.1)
        shake3:SetOrder(3)
        
        local shake4 = shakeAnimGroup:CreateAnimation("Translation")
        shake4:SetOffset(-5, 0)
        shake4:SetDuration(0.1)
        shake4:SetOrder(4)
        
        castbar.failShakeAnimGroup = shakeAnimGroup
    end
    
    -- Bar pulse animation for important casts
    if animations.barPulse then
        castbar.barPulseTexture = castbar.bar:CreateTexture(nil, "OVERLAY")
        castbar.barPulseTexture:SetAllPoints()
        castbar.barPulseTexture:SetTexture(MediaPath.."textures\\statusbar")
        castbar.barPulseTexture:SetBlendMode("ADD")
        castbar.barPulseTexture:SetAlpha(0)
        
        castbar.barPulseAnim = CreateAlphaAnimation(castbar.barPulseTexture, 0.5, 0, 1.0, 0, "IN_OUT")
        castbar.barPulseAnim:SetLooping("REPEAT")
    end
    
    -- Register animation hooks
    castbar.animationHooks = {
        Start = function(castbar)
            if castbar.startFlashAnim then
                castbar.startFlashAnim:Play()
            end
            
            if castbar.iconStartAnim then
                castbar.iconStartAnim:Play()
            end
            
            if castbar.textStartAnim then
                castbar.textStartAnim:Play()
            end
            
            -- Important spell detection (interrupt, CC, etc)
            -- This would need a database of spell IDs to detect important spells
            local isImportantSpell = false -- Placeholder for spell importance detection
            
            if isImportantSpell and castbar.barPulseAnim then
                castbar.barPulseTexture:SetVertexColor(1, 0.5, 0)
                castbar.barPulseAnim:Play()
            end
        end,
        
        ChannelStart = function(castbar)
            -- Similar to Start, but could have channel-specific animations
            if castbar.startFlashAnim then
                castbar.startFlashAnim:Play()
            end
            
            if castbar.iconStartAnim then
                castbar.iconStartAnim:Play()
            end
            
            if castbar.textStartAnim then
                castbar.textStartAnim:Play()
            end
        end,
        
        Finish = function(castbar)
            -- Clean finish for normal casts
            if castbar.barPulseAnim then
                castbar.barPulseAnim:Stop()
            end
        end,
        
        ChannelFinish = function(castbar)
            -- Clean finish for channeled spells
            if castbar.barPulseAnim then
                castbar.barPulseAnim:Stop()
            end
        end,
        
        Success = function(castbar)
            if castbar.successFlashAnim then
                castbar.successFlashAnim:Play()
            end
            
            if castbar.completionTextAnim then
                castbar.completionTextAnim:Play()
            end
        end,
        
        Fail = function(castbar)
            if castbar.failShakeAnimGroup then
                castbar.failShakeAnimGroup:Play()
            end
            
            if castbar.barPulseAnim then
                castbar.barPulseAnim:Stop()
            end
        end,
        
        Update = function(castbar, elapsed)
            -- This is called every frame while the cast is active
            -- Can be used for continuous animations
        end
    }
end

-- Initialize animations for all castbars
function Castbar:InitializeAnimations()
    for unit, castbar in pairs(self.frames) do
        self:InitializeCastbarAnimations(castbar)
    end
end

-- Apply theme-specific animations
function Castbar:ApplyThemeAnimations(castbar, themeName)
    -- Clean up any existing theme elements
    if castbar.themeElements then
        for _, element in pairs(castbar.themeElements) do
            if element.texture then
                element.texture:Hide()
                element.texture = nil
            end
            
            if element.animGroup then
                element.animGroup:Stop()
                element.animGroup = nil
            end
        end
    end
    
    castbar.themeElements = {}
    
    -- Apply theme-specific elements based on the active theme
    if themeName == "PhoenixFlame" then
        -- Phoenix Flame Theme
        self:ApplyPhoenixFlameTheme(castbar)
    elseif themeName == "ThunderStorm" then
        -- Thunder Storm Theme
        self:ApplyThunderStormTheme(castbar)
    elseif themeName == "ArcaneMystic" then
        -- Arcane Mystic Theme
        self:ApplyArcaneMysticTheme(castbar)
    elseif themeName == "FelEnergy" then
        -- Fel Energy Theme
        self:ApplyFelEnergyTheme(castbar)
    end
end

-- Apply Phoenix Flame theme animations
function Castbar:ApplyPhoenixFlameTheme(castbar)
    local themeDir = "phoenixflame"
    
    -- Edge flame effects
    local leftFlame = castbar:CreateTexture(nil, "OVERLAY")
    leftFlame:SetSize(castbar:GetHeight() * 2, castbar:GetHeight() * 2)
    leftFlame:SetPoint("RIGHT", castbar, "LEFT", 0, 0)
    leftFlame:SetTexture(MediaPath.."textures\\"..themeDir.."\\animation\\flame1.tga")
    leftFlame:SetBlendMode("ADD")
    leftFlame:SetVertexColor(1, 0.6, 0.3, 0.8)
    
    local rightFlame = castbar:CreateTexture(nil, "OVERLAY")
    rightFlame:SetSize(castbar:GetHeight() * 2, castbar:GetHeight() * 2)
    rightFlame:SetPoint("LEFT", castbar, "RIGHT", 0, 0)
    rightFlame:SetTexture(MediaPath.."textures\\"..themeDir.."\\animation\\flame1.tga")
    rightFlame:SetBlendMode("ADD")
    rightFlame:SetVertexColor(1, 0.6, 0.3, 0.8)
    
    -- Flame animation function
    local flameFrames = {}
    for i = 1, 4 do
        flameFrames[i] = MediaPath.."textures\\"..themeDir.."\\animation\\flame"..i..".tga"
    end
    
    local flameTimer = 0
    local flameFrame = 1
    local flameDuration = 0.1 -- Time per frame
    
    -- Store theme elements for later cleanup
    castbar.themeElements.leftFlame = { texture = leftFlame }
    castbar.themeElements.rightFlame = { texture = rightFlame }
    
    -- Ember particle effect for successful casts
    local emberParticle = function(castbar)
        local embers = {}
        local emberCount = math.random(5, 10)
        
        for i = 1, emberCount do
            local ember = castbar:CreateTexture(nil, "OVERLAY")
            ember:SetSize(math.random(3, 8), math.random(3, 8))
            ember:SetPoint("CENTER", castbar, "CENTER", math.random(-castbar:GetWidth()/2, castbar:GetWidth()/2), 0)
            ember:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\ember.svg")
            ember:SetBlendMode("ADD")
            ember:SetVertexColor(1, math.random(4, 8)/10, 0.1, 1)
            
            local animGroup = ember:CreateAnimationGroup()
            
            -- Move upward and fade
            local move = animGroup:CreateAnimation("Translation")
            move:SetOffset(math.random(-20, 20), math.random(30, 60))
            move:SetDuration(math.random(10, 20)/10)
            
            local fade = animGroup:CreateAnimation("Alpha")
            fade:SetFromAlpha(1)
            fade:SetToAlpha(0)
            fade:SetDuration(math.random(8, 15)/10)
            fade:SetStartDelay(math.random(5, 10)/10)
            
            animGroup:SetScript("OnFinished", function() 
                ember:Hide()
                ember = nil
            end)
            
            table.insert(embers, {texture = ember, animGroup = animGroup})
            animGroup:Play()
        end
        
        return embers
    end
    
    -- Augment existing animation hooks with theme-specific effects
    local originalHooks = castbar.animationHooks
    castbar.animationHooks = {
        Start = function(castbar)
            -- Call original start animation
            if originalHooks.Start then
                originalHooks.Start(castbar)
            end
            
            -- Show flame textures
            leftFlame:Show()
            rightFlame:Show()
        end,
        
        Success = function(castbar)
            -- Call original success animation
            if originalHooks.Success then
                originalHooks.Success(castbar)
            end
            
            -- Create ember particle effect
            castbar.themeElements.embers = emberParticle(castbar)
        end,
        
        Update = function(castbar, elapsed)
            -- Call original update animation
            if originalHooks.Update then
                originalHooks.Update(castbar, elapsed)
            end
            
            -- Animate flame textures
            flameTimer = flameTimer + elapsed
            if flameTimer >= flameDuration then
                flameTimer = flameTimer - flameDuration
                flameFrame = flameFrame + 1
                if flameFrame > #flameFrames then
                    flameFrame = 1
                end
                
                leftFlame:SetTexture(flameFrames[flameFrame])
                rightFlame:SetTexture(flameFrames[flameFrame])
            end
        end,
        
        -- Preserve other hooks
        ChannelStart = originalHooks.ChannelStart,
        Finish = originalHooks.Finish,
        ChannelFinish = originalHooks.ChannelFinish,
        Fail = originalHooks.Fail
    }
end

-- Apply Thunder Storm theme animations
function Castbar:ApplyThunderStormTheme(castbar)
    local themeDir = "thunderstorm"
    
    -- Lightning edge effects
    local leftLightning = castbar:CreateTexture(nil, "OVERLAY")
    leftLightning:SetSize(castbar:GetHeight() * 2, castbar:GetHeight() * 2)
    leftLightning:SetPoint("RIGHT", castbar, "LEFT", 0, 0)
    leftLightning:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\lightning.svg")
    leftLightning:SetBlendMode("ADD")
    leftLightning:SetVertexColor(0.3, 0.6, 1.0, 0)
    
    local rightLightning = castbar:CreateTexture(nil, "OVERLAY")
    rightLightning:SetSize(castbar:GetHeight() * 2, castbar:GetHeight() * 2)
    rightLightning:SetPoint("LEFT", castbar, "RIGHT", 0, 0)
    rightLightning:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\lightning.svg")
    rightLightning:SetBlendMode("ADD")
    rightLightning:SetVertexColor(0.3, 0.6, 1.0, 0)
    
    -- Lightning flash animations
    local leftLightningFlash = CreateAlphaAnimation(leftLightning, 0.8, 0, 0.5, 0, "IN")
    leftLightningFlash:SetLooping("REPEAT")
    
    local rightLightningFlash = CreateAlphaAnimation(rightLightning, 0.8, 0, 0.5, 0.25, "IN")
    rightLightningFlash:SetLooping("REPEAT")
    
    -- Store theme elements for later cleanup
    castbar.themeElements.leftLightning = { texture = leftLightning, animGroup = leftLightningFlash }
    castbar.themeElements.rightLightning = { texture = rightLightning, animGroup = rightLightningFlash }
    
    -- Lightning surge for successful casts
    local lightningSurge = function(castbar)
        local flash = castbar:CreateTexture(nil, "OVERLAY")
        flash:SetAllPoints(castbar)
        flash:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\surge.svg")
        flash:SetBlendMode("ADD")
        flash:SetVertexColor(0.4, 0.7, 1.0, 0)
        
        local animGroup = flash:CreateAnimationGroup()
        
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.8)
        fadeIn:SetDuration(0.2)
        fadeIn:SetOrder(1)
        
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.8)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.3)
        fadeOut:SetOrder(2)
        
        animGroup:SetScript("OnFinished", function() 
            flash:Hide()
            flash = nil
        end)
        
        return {texture = flash, animGroup = animGroup}
    end
    
    -- Augment existing animation hooks with theme-specific effects
    local originalHooks = castbar.animationHooks
    castbar.animationHooks = {
        Start = function(castbar)
            -- Call original start animation
            if originalHooks.Start then
                originalHooks.Start(castbar)
            end
            
            -- Start lightning flash animations
            leftLightningFlash:Play()
            rightLightningFlash:Play()
        end,
        
        Success = function(castbar)
            -- Call original success animation
            if originalHooks.Success then
                originalHooks.Success(castbar)
            end
            
            -- Create lightning surge effect
            local surge = lightningSurge(castbar)
            castbar.themeElements.surge = surge
            surge.animGroup:Play()
        end,
        
        Finish = function(castbar)
            -- Call original finish animation
            if originalHooks.Finish then
                originalHooks.Finish(castbar)
            end
            
            -- Stop lightning animations
            leftLightningFlash:Stop()
            rightLightningFlash:Stop()
        end,
        
        -- Preserve other hooks
        ChannelStart = originalHooks.ChannelStart,
        ChannelFinish = originalHooks.ChannelFinish,
        Fail = originalHooks.Fail,
        Update = originalHooks.Update
    }
end

-- Apply Arcane Mystic theme animations
function Castbar:ApplyArcaneMysticTheme(castbar)
    local themeDir = "arcanemystic"
    
    -- Arcane rune effect
    local arcaneRune = castbar:CreateTexture(nil, "OVERLAY")
    arcaneRune:SetSize(castbar:GetHeight() * 3, castbar:GetHeight() * 3)
    arcaneRune:SetPoint("CENTER", castbar, "CENTER", 0, 0)
    arcaneRune:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\rune.svg")
    arcaneRune:SetBlendMode("ADD")
    arcaneRune:SetVertexColor(0.7, 0.3, 1.0, 0.3)
    arcaneRune:SetAlpha(0.3)
    
    -- Arcane rune rotation animation
    local arcaneRotate = arcaneRune:CreateAnimationGroup()
    local rotate = arcaneRotate:CreateAnimation("Rotation")
    rotate:SetDegrees(360)
    rotate:SetDuration(8)
    arcaneRotate:SetLooping("REPEAT")
    
    -- Store theme elements for later cleanup
    castbar.themeElements.arcaneRune = { texture = arcaneRune, animGroup = arcaneRotate }
    
    -- Arcane burst for successful casts
    local arcaneBurst = function(castbar)
        local burst = castbar:CreateTexture(nil, "OVERLAY")
        burst:SetAllPoints(castbar)
        burst:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\burst.svg")
        burst:SetBlendMode("ADD")
        burst:SetVertexColor(0.8, 0.4, 1.0, 0.8)
        
        local animGroup = burst:CreateAnimationGroup()
        
        local scale = animGroup:CreateAnimation("Scale")
        scale:SetFromScale(0.5, 0.5)
        scale:SetToScale(2, 2)
        scale:SetDuration(0.5)
        scale:SetOrder(1)
        
        local fade = animGroup:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.8)
        fade:SetToAlpha(0)
        fade:SetDuration(0.5)
        fade:SetOrder(1)
        
        animGroup:SetScript("OnFinished", function() 
            burst:Hide()
            burst = nil
        end)
        
        return {texture = burst, animGroup = animGroup}
    end
    
    -- Augment existing animation hooks with theme-specific effects
    local originalHooks = castbar.animationHooks
    castbar.animationHooks = {
        Start = function(castbar)
            -- Call original start animation
            if originalHooks.Start then
                originalHooks.Start(castbar)
            end
            
            -- Start arcane rune animation
            arcaneRotate:Play()
        end,
        
        Success = function(castbar)
            -- Call original success animation
            if originalHooks.Success then
                originalHooks.Success(castbar)
            end
            
            -- Create arcane burst effect
            local burst = arcaneBurst(castbar)
            castbar.themeElements.burst = burst
            burst.animGroup:Play()
        end,
        
        Finish = function(castbar)
            -- Call original finish animation
            if originalHooks.Finish then
                originalHooks.Finish(castbar)
            end
            
            -- Stop arcane animations
            arcaneRotate:Stop()
        end,
        
        -- Preserve other hooks
        ChannelStart = originalHooks.ChannelStart,
        ChannelFinish = originalHooks.ChannelFinish,
        Fail = originalHooks.Fail,
        Update = originalHooks.Update
    }
end

-- Apply Fel Energy theme animations
function Castbar:ApplyFelEnergyTheme(castbar)
    local themeDir = "felenergy"
    
    -- Fel glow effect
    local felGlow = castbar:CreateTexture(nil, "OVERLAY")
    felGlow:SetAllPoints(castbar)
    felGlow:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\glow.svg")
    felGlow:SetBlendMode("ADD")
    felGlow:SetVertexColor(0.3, 1.0, 0.3, 0.5)
    
    -- Pulsing glow animation
    local glowPulse = CreateAlphaAnimation(felGlow, 0.3, 0.7, 1.0, 0, "IN_OUT")
    glowPulse:SetLooping("REPEAT")
    
    -- Store theme elements for later cleanup
    castbar.themeElements.felGlow = { texture = felGlow, animGroup = glowPulse }
    
    -- Fel explosion for successful casts
    local felExplosion = function(castbar)
        local explosion = castbar:CreateTexture(nil, "OVERLAY")
        explosion:SetAllPoints(castbar)
        explosion:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\explosion.svg")
        explosion:SetBlendMode("ADD")
        explosion:SetVertexColor(0.4, 1.0, 0.4, 0.8)
        
        local animGroup = explosion:CreateAnimationGroup()
        
        local scale = animGroup:CreateAnimation("Scale")
        scale:SetFromScale(0.8, 0.8)
        scale:SetToScale(1.5, 1.5)
        scale:SetDuration(0.5)
        scale:SetOrder(1)
        
        local fade = animGroup:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.8)
        fade:SetToAlpha(0)
        fade:SetDuration(0.5)
        fade:SetOrder(1)
        
        animGroup:SetScript("OnFinished", function() 
            explosion:Hide()
            explosion = nil
        end)
        
        return {texture = explosion, animGroup = animGroup}
    end
    
    -- Skull icon overlay for important spells (interrupt, etc)
    local felSkull = castbar:CreateTexture(nil, "OVERLAY")
    felSkull:SetSize(castbar:GetHeight() * 2, castbar:GetHeight() * 2)
    felSkull:SetPoint("CENTER", castbar, "CENTER", 0, 0)
    felSkull:SetTexture(MediaPath.."textures\\"..themeDir.."\\castbar\\skull.svg")
    felSkull:SetBlendMode("ADD")
    felSkull:SetVertexColor(0.5, 1.0, 0.5, 0)
    
    castbar.themeElements.felSkull = { texture = felSkull }
    
    -- Augment existing animation hooks with theme-specific effects
    local originalHooks = castbar.animationHooks
    castbar.animationHooks = {
        Start = function(castbar)
            -- Call original start animation
            if originalHooks.Start then
                originalHooks.Start(castbar)
            end
            
            -- Start fel glow animation
            glowPulse:Play()
            
            -- Check if this is an important spell (for example, interrupt)
            local isInterrupt = false -- This would need actual spell detection
            if isInterrupt then
                -- Show skull warning for interrupts
                local skullAnim = CreateAlphaAnimation(felSkull, 0, 0.8, 0.3, 0, "IN")
                skullAnim:Play()
                castbar.themeElements.skullAnim = { animGroup = skullAnim }
            end
        end,
        
        Success = function(castbar)
            -- Call original success animation
            if originalHooks.Success then
                originalHooks.Success(castbar)
            end
            
            -- Create fel explosion effect
            local explosion = felExplosion(castbar)
            castbar.themeElements.explosion = explosion
            explosion.animGroup:Play()
        end,
        
        Finish = function(castbar)
            -- Call original finish animation
            if originalHooks.Finish then
                originalHooks.Finish(castbar)
            end
            
            -- Stop fel animations
            glowPulse:Stop()
            
            -- Hide skull if it was shown
            felSkull:SetAlpha(0)
        end,
        
        -- Preserve other hooks
        ChannelStart = originalHooks.ChannelStart,
        ChannelFinish = originalHooks.ChannelFinish,
        Fail = originalHooks.Fail,
        Update = originalHooks.Update
    }
end

-- Initialize all theme animations for a given theme
function Castbar:ApplyThemeIntegration(themeName)
    -- Use the current theme if none specified
    themeName = themeName or VUI.activeTheme or "PhoenixFlame"
    
    -- Apply the theme animations to all castbars
    for unit, castbar in pairs(self.frames) do
        self:ApplyThemeAnimations(castbar, themeName)
    end
end