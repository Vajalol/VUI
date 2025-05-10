-- VUIMouseFireTrail ParticleService
-- Provides centralized particle system management
-- Based on Frogski's mouse fire trail WeakAura (https://wago.io/RzZVq4F1a)

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")
local ParticleService = {}
M.ParticleService = ParticleService

-- Local references for performance
local math_random = math.random
local math_max = math.max
local GetCursorPosition = GetCursorPosition
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsMouseButtonDown = IsMouseButtonDown
local UIParent = UIParent

-- Constants for sprite textures
local TEXTURES = {
    FIRE = "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\fire.tga",
    ARCANE = "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\arcane.tga",
    FROST = "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\frost.tga",
    NATURE = "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\nature.tga",
}

-- Initialize the particle service
function ParticleService:Initialize(parent)
    self.parent = parent
    self.particles = {}
    self.textures = {}
    self.texturePool = {}
    self.lastUpdate = 0
    
    -- Create main container frame
    self.frame = CreateFrame("Frame", "VUIMouseFireTrailFrame", UIParent)
    self.frame:SetFrameStrata("BACKGROUND")
    self.frame:SetSize(1, 1)
    self.frame:SetPoint("CENTER")
    self.frame:Hide()
    
    -- Initialize particles
    self:InitParticles()
    
    M:Debug("ParticleService initialized")
    return self.frame
end

-- Initialize particles based on current settings
function ParticleService:InitParticles()
    -- Clear any existing particles
    for i = 1, #self.particles do
        if self.textures[i] then
            self.textures[i]:Hide()
            table.insert(self.texturePool, self.textures[i])
        end
    end
    
    wipe(self.particles)
    wipe(self.textures)
    
    local settings = M.db.profile
    
    -- Create new particles based on settings
    for i = 1, settings.particleCount do
        self.particles[i] = {
            x = 0,
            y = 0,
            alpha = 0,
            size = 0,
            active = false
        }
        
        -- Get texture from pool or create new
        local texture
        if #self.texturePool > 0 then
            texture = table.remove(self.texturePool)
            texture:ClearAllPoints()
        else
            texture = self.frame:CreateTexture(nil, "BACKGROUND")
            texture:SetBlendMode("ADD")
        end
        
        -- Set up texture
        texture:SetSize(1, 1)  -- Will be sized later during update
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", 0, 0)
        texture:Hide()
        
        -- Set texture based on color mode
        self:SetParticleTexture(texture)
        
        self.textures[i] = texture
    end
end

-- Set particle texture based on color mode
function ParticleService:SetParticleTexture(texture)
    local settings = M.db.profile
    local colorMode = settings.colorMode
    
    -- Set appropriate texture
    if colorMode == "FIRE" then
        texture:SetTexture(TEXTURES.FIRE)
    elseif colorMode == "ARCANE" then
        texture:SetTexture(TEXTURES.ARCANE)
    elseif colorMode == "FROST" then
        texture:SetTexture(TEXTURES.FROST)
    elseif colorMode == "NATURE" then
        texture:SetTexture(TEXTURES.NATURE)
    else
        texture:SetTexture(TEXTURES.FIRE) -- Default
    end
    
    -- Apply custom color if needed
    if colorMode == "CUSTOM" then
        local c = settings.customColor
        texture:SetVertexColor(c.r, c.g, c.b)
    elseif colorMode == "RAINBOW" then
        -- Set random color for rainbow mode
        texture:SetVertexColor(math_random(), math_random(), math_random())
    else
        -- Reset vertex color for standard textures
        texture:SetVertexColor(1, 1, 1)
    end
end

-- Update all particles based on frame delta
function ParticleService:Update(elapsed)
    local settings = M.db.profile
    
    -- Check conditions first
    if not self:ShouldUpdate() then return end
    
    -- Get mouse position
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    cursorX = cursorX / uiScale
    cursorY = cursorY / uiScale
    
    -- Update particles
    local particleSize = settings.particleSize
    local decay = settings.particleDecay
    local variation = settings.particleVariation
    local speed = settings.particleSpeed
    
    -- Find oldest particle to replace
    local oldestIdx = 1
    local oldestAlpha = 1
    
    for i = 1, #self.particles do
        local p = self.particles[i]
        
        if p.active then
            -- Update existing particle
            p.alpha = p.alpha * decay
            p.size = p.size * (1 + ((1 - decay) * 0.5))
            
            -- Track oldest for replacement
            if p.alpha < oldestAlpha then
                oldestAlpha = p.alpha
                oldestIdx = i
            end
            
            -- Deactivate if too faded
            if p.alpha < 0.01 then
                p.active = false
                self.textures[i]:Hide()
            else
                -- Update texture
                local texture = self.textures[i]
                texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
                texture:SetSize(p.size, p.size)
                texture:SetAlpha(p.alpha)
                
                -- Apply rainbow color if needed
                if settings.colorMode == "RAINBOW" then
                    -- Slightly shift color for animated effect
                    local r, g, b = texture:GetVertexColor()
                    r = (r + 0.01) % 1
                    g = (g + 0.02) % 1
                    b = (b + 0.03) % 1
                    texture:SetVertexColor(r, g, b)
                end
                
                texture:Show()
            end
        end
    end
    
    -- Calculate trail length and spawn rate
    local trailLength = settings.particleTrailLength
    local threshold = math_max(0.05, 1 - (trailLength * 0.9))
    
    -- Check if we should spawn a new particle
    if math_random() > threshold then
        local idx = oldestIdx
        local p = self.particles[idx]
        
        -- Calculate random offsets for visual effect
        local randX = (math_random() - 0.5) * 5 * speed
        local randY = (math_random() - 0.5) * 5 * speed
        
        -- Create new particle
        p.x = cursorX + randX
        p.y = cursorY + randY
        p.alpha = settings.particleAlpha
        
        -- Random size variation
        local baseSize = particleSize * (1 + ((math_random() - 0.5) * variation))
        p.size = baseSize
        p.active = true
        
        -- Update texture
        local texture = self.textures[idx]
        
        -- Set rainbow color if needed
        if settings.colorMode == "RAINBOW" then
            texture:SetVertexColor(math_random(), math_random(), math_random())
        end
        
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
        texture:SetSize(p.size, p.size)
        texture:SetAlpha(p.alpha)
        texture:Show()
    end
end

-- Check if particle system should be updated
function ParticleService:ShouldUpdate()
    local settings = M.db.profile
    
    -- Check key modifiers if required
    if settings.keyModifierRequired then
        local modifier = settings.keyModifier
        if modifier == "SHIFT" and not IsShiftKeyDown() then return false end
        if modifier == "CTRL" and not IsControlKeyDown() then return false end
        if modifier == "ALT" and not IsAltKeyDown() then return false end
    end
    
    -- Check mouse button if required
    if settings.mouseButtonRequired then
        local button = settings.mouseButton
        if button == "LEFT" and not IsMouseButtonDown("LeftButton") then return false end
        if button == "RIGHT" and not IsMouseButtonDown("RightButton") then return false end
        if button == "MIDDLE" and not IsMouseButtonDown("MiddleButton") then return false end
    end
    
    return true
end

-- Update all particle textures after settings changed
function ParticleService:UpdateTextures()
    for i = 1, #self.textures do
        if self.textures[i] then
            self:SetParticleTexture(self.textures[i])
        end
    end
end

-- Reset the particle system
function ParticleService:Reset()
    -- Hide all particles
    for i = 1, #self.particles do
        if self.textures[i] then
            self.textures[i]:Hide()
        end
        self.particles[i].active = false
    end
    
    -- Reinitialize with current settings
    self:InitParticles()
end

-- Return the service object
return ParticleService