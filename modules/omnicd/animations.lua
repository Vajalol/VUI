--[[
    VUI - OmniCD Animations Module
    Version: 0.0.1
    Author: VortexQ8
]]

local _, VUI = ...
local OmniCD = VUI.omnicd
local MediaPath = "Interface\\AddOns\\VUI\\media\\"

-- Create animation group for an element
local function CreateAnimationGroup(element, script)
    local group = element:CreateAnimationGroup()
    if script then
        group:SetScript("OnFinished", script)
    end
    return group
end

-- Create translation animation
local function CreateTranslation(group, offsetX, offsetY, duration, order, smoothType, delay)
    local anim = group:CreateAnimation("Translation")
    anim:SetOffset(offsetX, offsetY)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    if delay then anim:SetStartDelay(delay) end
    return anim
end

-- Create alpha animation
local function CreateAlpha(group, fromAlpha, toAlpha, duration, order, smoothType, delay)
    local anim = group:CreateAnimation("Alpha")
    anim:SetFromAlpha(fromAlpha)
    anim:SetToAlpha(toAlpha)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    if delay then anim:SetStartDelay(delay) end
    return anim
end

-- Create scale animation
local function CreateScale(group, fromScaleX, fromScaleY, toScaleX, toScaleY, duration, order, smoothType, delay)
    local anim = group:CreateAnimation("Scale")
    anim:SetFromScale(fromScaleX, fromScaleY)
    anim:SetToScale(toScaleX, toScaleY)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    if delay then anim:SetStartDelay(delay) end
    return anim
end

-- Create rotation animation
local function CreateRotation(group, degrees, duration, order, smoothType, delay)
    local anim = group:CreateAnimation("Rotation")
    anim:SetDegrees(degrees)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    if delay then anim:SetStartDelay(delay) end
    return anim
end

-- Initialize animations for the OmniCD module
function OmniCD:InitializeAnimations()
    if not self.iconFrames then return end
    
    -- Check settings
    self.db = self.db or {}
    if self.db.animations == nil then self.db.animations = true end
    if not self.db.animations then return end
    
    -- Add animations to each icon frame
    for i, frame in ipairs(self.iconFrames) do
        -- Initialize animations container
        frame.animations = {}
        
        -- Add show animation
        frame.animations.show = CreateAnimationGroup(frame)
        CreateScale(frame.animations.show, 0.1, 0.1, 1, 1, 0.2, 1, "OUT")
        CreateAlpha(frame.animations.show, 0, 1, 0.2, 1, "OUT")
        
        -- Add hide animation
        frame.animations.hide = CreateAnimationGroup(frame, function() frame:Hide() end)
        CreateScale(frame.animations.hide, 1, 1, 0.1, 0.1, 0.2, 1, "IN")
        CreateAlpha(frame.animations.hide, 1, 0, 0.2, 1, "IN")
        
        -- Add pulse animation
        frame.animations.pulse = CreateAnimationGroup(frame)
        CreateScale(frame.animations.pulse, 1, 1, 1.5, 1.5, 0.3, 1, "OUT")
        CreateScale(frame.animations.pulse, 1.5, 1.5, 1, 1, 0.3, 2, "IN")
        
        -- Add ready animation
        frame.animations.ready = CreateAnimationGroup(frame)
        CreateScale(frame.animations.ready, 1, 1, 1.3, 1.3, 0.2, 1, "OUT")
        CreateAlpha(frame.animations.ready, 1, 0.7, 0.2, 1, "IN")
        CreateScale(frame.animations.ready, 1.3, 1.3, 1, 1, 0.2, 2, "IN")
        CreateAlpha(frame.animations.ready, 0.7, 1, 0.2, 2, "OUT")
        
        -- Override the Show function
        frame.OldShow = frame.Show
        frame.Show = function(self)
            if self:IsShown() then return end
            
            -- Stop any running animations
            if self.animations.hide and self.animations.hide:IsPlaying() then
                self.animations.hide:Stop()
            end
            
            -- Set initial state
            self:SetAlpha(0)
            self:SetScale(0.1)
            
            -- Regular show call
            self:OldShow()
            
            -- Play show animation
            if self.animations.show then
                self.animations.show:Play()
            end
        end
        
        -- Override the Hide function
        frame.OldHide = frame.Hide
        frame.Hide = function(self)
            if not self:IsShown() then return end
            
            -- Stop any running animations
            if self.animations.show and self.animations.show:IsPlaying() then
                self.animations.show:Stop()
            end
            
            -- Play hide animation
            if self.db and self.db.animations and self.animations.hide then
                self.animations.hide:Play()
            else
                self:OldHide()
            end
        end
    end
    
    -- Create theme-specific animations
    self:ApplyThemeAnimations()
end

-- Initialize theme-specific animation elements for all cooldown frames
function OmniCD:ApplyThemeAnimations()
    -- Get current theme
    local theme = VUI.activeTheme or "PhoenixFlame"
    
    -- Apply theme-specific animations to each icon frame
    for _, frame in ipairs(self.iconFrames) do
        -- Remove any existing theme elements
        if frame.themeElements then
            for _, element in pairs(frame.themeElements) do
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
        
        -- Create new theme elements
        frame.themeElements = {}
        
        -- Apply theme-specific elements
        if theme == "PhoenixFlame" then
            self:ApplyPhoenixFlameTheme(frame)
        elseif theme == "ThunderStorm" then
            self:ApplyThunderStormTheme(frame)
        elseif theme == "ArcaneMystic" then
            self:ApplyArcaneMysticTheme(frame)
        elseif theme == "FelEnergy" then
            self:ApplyFelEnergyTheme(frame)
        end
    end
end

-- Apply Phoenix Flame theme
function OmniCD:ApplyPhoenixFlameTheme(frame)
    local themeDir = "phoenixflame"
    
    -- Glow effect during cooldown
    local glow = frame:CreateTexture(nil, "OVERLAY")
    glow:SetSize(frame:GetWidth() * 1.5, frame:GetHeight() * 1.5)
    glow:SetPoint("CENTER")
    glow:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\flame1.svg")
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(1, 0.6, 0.3, 0.5)
    glow:Hide()
    
    -- Flame animation group
    local flameGroup = CreateAnimationGroup(glow)
    flameGroup:SetLooping("REPEAT")
    
    -- Rotation animation
    CreateRotation(flameGroup, 90, 3)
    
    -- Pulse animation
    local flameAlphaIn = CreateAlpha(flameGroup, 0.3, 0.6, 1.5, 1, "IN_OUT")
    local flameAlphaOut = CreateAlpha(flameGroup, 0.6, 0.3, 1.5, 2, "IN_OUT")
    
    -- Ember effect on cooldown ready
    local emberEffect = function(frame)
        local embers = {}
        local emberCount = math.random(4, 8)
        
        for i = 1, emberCount do
            local ember = frame:CreateTexture(nil, "OVERLAY")
            ember:SetSize(math.random(3, 6), math.random(3, 6))
            ember:SetPoint("CENTER", frame, "CENTER", math.random(-frame:GetWidth()/2, frame:GetWidth()/2), 0)
            ember:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\ember.svg")
            ember:SetBlendMode("ADD")
            ember:SetVertexColor(1, math.random(4, 8)/10, 0.1, 1)
            
            local animGroup = CreateAnimationGroup(ember)
            
            -- Move upward and fade
            CreateTranslation(animGroup, math.random(-15, 15), math.random(20, 40), math.random(8, 15)/10)
            CreateAlpha(animGroup, 1, 0, math.random(6, 10)/10, nil, nil, math.random(2, 5)/10)
            
            animGroup:SetScript("OnFinished", function() 
                ember:Hide()
                ember = nil
            end)
            
            table.insert(embers, {texture = ember, animGroup = animGroup})
            animGroup:Play()
        end
        
        return embers
    end
    
    -- Store theme elements for later cleanup
    frame.themeElements.glow = { texture = glow, animGroup = flameGroup }
    
    -- Hook cooldown functions
    frame.cooldown.OldSetCooldown = frame.cooldown.SetCooldown
    frame.cooldown.SetCooldown = function(self, start, duration)
        self:OldSetCooldown(start, duration)
        
        -- Show glow during cooldown
        glow:Show()
        flameGroup:Play()
    end
    
    frame.cooldown.OldClear = frame.cooldown.Clear
    frame.cooldown.Clear = function(self)
        self:OldClear()
        
        -- Hide glow
        flameGroup:Stop()
        glow:Hide()
        
        -- Show ready animation
        if frame.animations.ready then
            frame.animations.ready:Play()
        end
        
        -- Show ember effect
        frame.themeElements.embers = emberEffect(frame)
    end
end

-- Apply Thunder Storm theme
function OmniCD:ApplyThunderStormTheme(frame)
    local themeDir = "thunderstorm"
    
    -- Lightning effect during cooldown
    local lightning = frame:CreateTexture(nil, "OVERLAY")
    lightning:SetSize(frame:GetWidth() * 1.5, frame:GetHeight() * 1.5)
    lightning:SetPoint("CENTER")
    lightning:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\lightning.svg")
    lightning:SetBlendMode("ADD")
    lightning:SetVertexColor(0.3, 0.6, 1.0, 0)
    lightning:Hide()
    
    -- Lightning flash animation
    local lightningGroup = CreateAnimationGroup(lightning)
    lightningGroup:SetLooping("REPEAT")
    
    -- Alpha animation for lightning flash
    CreateAlpha(lightningGroup, 0, 0.7, 0.2, 1, "IN")
    CreateAlpha(lightningGroup, 0.7, 0, 0.3, 2, "OUT")
    
    -- Random reposition every flash
    local repositionTimer = 0
    local function UpdateLightningPosition(elapsed)
        repositionTimer = repositionTimer + elapsed
        if repositionTimer >= 0.5 then
            repositionTimer = 0
            lightning:ClearAllPoints()
            lightning:SetPoint("CENTER", frame, "CENTER", math.random(-5, 5), math.random(-5, 5))
        end
    end
    
    frame:HookScript("OnUpdate", function(self, elapsed)
        if lightning:IsShown() then
            UpdateLightningPosition(elapsed)
        end
    end)
    
    -- Surge effect on cooldown ready
    local surgeEffect = function(frame)
        local surge = frame:CreateTexture(nil, "OVERLAY")
        surge:SetAllPoints(frame)
        surge:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\surge.svg")
        surge:SetBlendMode("ADD")
        surge:SetVertexColor(0.4, 0.7, 1.0, 0.8)
        
        local animGroup = CreateAnimationGroup(surge)
        
        -- Pulse and fade
        CreateScale(animGroup, 1, 1, 2, 2, 0.4)
        CreateAlpha(animGroup, 0.8, 0, 0.4)
        
        animGroup:SetScript("OnFinished", function() 
            surge:Hide()
            surge = nil
        end)
        
        animGroup:Play()
        return {texture = surge, animGroup = animGroup}
    end
    
    -- Store theme elements for later cleanup
    frame.themeElements.lightning = { texture = lightning, animGroup = lightningGroup }
    
    -- Hook cooldown functions
    frame.cooldown.OldSetCooldown = frame.cooldown.SetCooldown
    frame.cooldown.SetCooldown = function(self, start, duration)
        self:OldSetCooldown(start, duration)
        
        -- Show lightning during cooldown
        lightning:Show()
        lightningGroup:Play()
    end
    
    frame.cooldown.OldClear = frame.cooldown.Clear
    frame.cooldown.Clear = function(self)
        self:OldClear()
        
        -- Hide lightning
        lightningGroup:Stop()
        lightning:Hide()
        
        -- Show ready animation
        if frame.animations.ready then
            frame.animations.ready:Play()
        end
        
        -- Show surge effect
        frame.themeElements.surge = surgeEffect(frame)
    end
end

-- Apply Arcane Mystic theme
function OmniCD:ApplyArcaneMysticTheme(frame)
    local themeDir = "arcanemystic"
    
    -- Arcane rune effect during cooldown
    local rune = frame:CreateTexture(nil, "OVERLAY")
    rune:SetSize(frame:GetWidth() * 2, frame:GetHeight() * 2)
    rune:SetPoint("CENTER")
    rune:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\rune.svg")
    rune:SetBlendMode("ADD")
    rune:SetVertexColor(0.7, 0.3, 1.0, 0.3)
    rune:Hide()
    
    -- Rune rotation animation
    local runeGroup = CreateAnimationGroup(rune)
    runeGroup:SetLooping("REPEAT")
    
    -- Rotation animation
    CreateRotation(runeGroup, 360, 8)
    
    -- Arcane burst effect on cooldown ready
    local burstEffect = function(frame)
        local burst = frame:CreateTexture(nil, "OVERLAY")
        burst:SetAllPoints(frame)
        burst:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\burst.svg")
        burst:SetBlendMode("ADD")
        burst:SetVertexColor(0.8, 0.4, 1.0, 0.8)
        
        local animGroup = CreateAnimationGroup(burst)
        
        -- Scale and fade
        CreateScale(animGroup, 0.5, 0.5, 2, 2, 0.5)
        CreateAlpha(animGroup, 0.8, 0, 0.5)
        
        animGroup:SetScript("OnFinished", function() 
            burst:Hide()
            burst = nil
        end)
        
        animGroup:Play()
        return {texture = burst, animGroup = animGroup}
    end
    
    -- Store theme elements for later cleanup
    frame.themeElements.rune = { texture = rune, animGroup = runeGroup }
    
    -- Hook cooldown functions
    frame.cooldown.OldSetCooldown = frame.cooldown.SetCooldown
    frame.cooldown.SetCooldown = function(self, start, duration)
        self:OldSetCooldown(start, duration)
        
        -- Show rune during cooldown
        rune:Show()
        runeGroup:Play()
    end
    
    frame.cooldown.OldClear = frame.cooldown.Clear
    frame.cooldown.Clear = function(self)
        self:OldClear()
        
        -- Hide rune
        runeGroup:Stop()
        rune:Hide()
        
        -- Show ready animation
        if frame.animations.ready then
            frame.animations.ready:Play()
        end
        
        -- Show burst effect
        frame.themeElements.burst = burstEffect(frame)
    end
end

-- Apply Fel Energy theme
function OmniCD:ApplyFelEnergyTheme(frame)
    local themeDir = "felenergy"
    
    -- Fel glow effect during cooldown
    local glow = frame:CreateTexture(nil, "OVERLAY")
    glow:SetAllPoints(frame)
    glow:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\glow.svg")
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(0.3, 1.0, 0.3, 0.5)
    glow:Hide()
    
    -- Pulsing glow animation
    local glowGroup = CreateAnimationGroup(glow)
    glowGroup:SetLooping("REPEAT")
    
    -- Alpha animation
    CreateAlpha(glowGroup, 0.3, 0.7, 1.0, 1, "IN_OUT")
    CreateAlpha(glowGroup, 0.7, 0.3, 1.0, 2, "IN_OUT")
    
    -- Fel explosion effect on cooldown ready
    local explosionEffect = function(frame)
        local explosion = frame:CreateTexture(nil, "OVERLAY")
        explosion:SetAllPoints(frame)
        explosion:SetTexture(MediaPath.."textures\\"..themeDir.."\\omnicd\\explosion.svg")
        explosion:SetBlendMode("ADD")
        explosion:SetVertexColor(0.4, 1.0, 0.4, 0.8)
        
        local animGroup = CreateAnimationGroup(explosion)
        
        -- Scale and fade
        CreateScale(animGroup, 0.8, 0.8, 1.5, 1.5, 0.5)
        CreateAlpha(animGroup, 0.8, 0, 0.5)
        
        animGroup:SetScript("OnFinished", function() 
            explosion:Hide()
            explosion = nil
        end)
        
        animGroup:Play()
        return {texture = explosion, animGroup = animGroup}
    end
    
    -- Store theme elements for later cleanup
    frame.themeElements.glow = { texture = glow, animGroup = glowGroup }
    
    -- Hook cooldown functions
    frame.cooldown.OldSetCooldown = frame.cooldown.SetCooldown
    frame.cooldown.SetCooldown = function(self, start, duration)
        self:OldSetCooldown(start, duration)
        
        -- Show glow during cooldown
        glow:Show()
        glowGroup:Play()
    end
    
    frame.cooldown.OldClear = frame.cooldown.Clear
    frame.cooldown.Clear = function(self)
        self:OldClear()
        
        -- Hide glow
        glowGroup:Stop()
        glow:Hide()
        
        -- Show ready animation
        if frame.animations.ready then
            frame.animations.ready:Play()
        end
        
        -- Show explosion effect
        frame.themeElements.explosion = explosionEffect(frame)
    end
end

-- Function to call on theme change
function OmniCD:UpdateThemeAnimations()
    self:ApplyThemeAnimations()
end

-- Called when VUI's theme is changed
VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
    OmniCD:UpdateThemeAnimations()
end)