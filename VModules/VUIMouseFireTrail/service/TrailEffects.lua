-- VUIMouseFireTrail TrailEffects.lua
-- Specialized visual effects for cursor trails

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Local variables
local CreateFrame = CreateFrame
local UIParent = UIParent
local sin = math.sin
local cos = math.cos
local pi = math.pi

-- Table to store active effects
M.ActiveEffects = {}

-- Create a glow effect around the cursor
function M:CreateGlowEffect(x, y, size, r, g, b, a)
    -- Default values
    size = size or 40
    r = r or 1
    g = g or 0.7
    b = b or 0.3
    a = a or 0.7
    
    -- Create the frame for the glow
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    frame:SetSize(size, size)
    
    -- Create the texture
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\glow.tga")
    texture:SetBlendMode("ADD")
    texture:SetVertexColor(r, g, b, a)
    
    -- Store the texture reference
    frame.texture = texture
    
    -- Add animation
    local ag = frame:CreateAnimationGroup()
    
    -- Fade out animation
    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(a)
    fade:SetToAlpha(0)
    fade:SetDuration(0.5)
    fade:SetSmoothing("OUT")
    
    -- Size animation
    local expand = ag:CreateAnimation("Scale")
    expand:SetFromScale(1, 1)
    expand:SetToScale(2, 2)
    expand:SetDuration(0.5)
    expand:SetSmoothing("OUT")
    
    -- Set script for cleanup
    ag:SetScript("OnFinished", function()
        frame:Hide()
        frame:SetParent(nil)
        -- Remove from active effects
        for i = 1, #M.ActiveEffects do
            if M.ActiveEffects[i] == frame then
                table.remove(M.ActiveEffects, i)
                break
            end
        end
    end)
    
    -- Store the animation group
    frame.animation = ag
    
    -- Start the animation
    ag:Play()
    
    -- Add to active effects
    table.insert(M.ActiveEffects, frame)
    
    return frame
end

-- Create a particle burst effect
function M:CreateParticleBurst(x, y, count, size, speed, r, g, b, a)
    -- Default values
    count = count or 8
    size = size or 15
    speed = speed or 100
    r = r or 1
    g = g or 0.7
    b = b or 0.3
    a = a or 0.7
    
    -- Create particles
    for i = 1, count do
        -- Create the frame for the particle
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetFrameStrata("BACKGROUND")
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        frame:SetSize(size, size)
        
        -- Create the texture
        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints()
        texture:SetTexture("Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame01.tga")
        texture:SetVertexColor(r, g, b, a)
        
        -- Store the texture reference
        frame.texture = texture
        
        -- Calculate random direction
        local angle = (i - 1) * (2 * pi / count) + math.random() * (pi / 4)
        local vx = cos(angle) * speed
        local vy = sin(angle) * speed
        frame.vx = vx
        frame.vy = vy
        
        -- Add animation
        local ag = frame:CreateAnimationGroup()
        
        -- Fade out animation
        local fade = ag:CreateAnimation("Alpha")
        fade:SetFromAlpha(a)
        fade:SetToAlpha(0)
        fade:SetDuration(0.7)
        fade:SetSmoothing("OUT")
        
        -- Size animation (smaller)
        local shrink = ag:CreateAnimation("Scale")
        shrink:SetFromScale(1, 1)
        shrink:SetToScale(0.3, 0.3)
        shrink:SetDuration(0.7)
        shrink:SetSmoothing("OUT")
        
        -- Set script for cleanup
        ag:SetScript("OnFinished", function()
            frame:Hide()
            frame:SetParent(nil)
            -- Remove from active effects
            for i = 1, #M.ActiveEffects do
                if M.ActiveEffects[i] == frame then
                    table.remove(M.ActiveEffects, i)
                    break
                end
            end
        end)
        
        -- Store the animation group
        frame.animation = ag
        
        -- Set update script for movement
        frame:SetScript("OnUpdate", function(self, elapsed)
            -- Calculate new position
            local cx, cy = self:GetCenter()
            local scale = UIParent:GetEffectiveScale()
            local newX = cx + (self.vx * elapsed)
            local newY = cy + (self.vy * elapsed)
            
            -- Update position
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", newX, newY)
            
            -- Apply gravity effect
            self.vy = self.vy - (200 * elapsed) -- Gravity
        end)
        
        -- Start the animation
        ag:Play()
        
        -- Add to active effects
        table.insert(M.ActiveEffects, frame)
    end
end

-- Create a spiral effect
function M:CreateSpiralEffect(x, y, radius, duration, r, g, b, a)
    -- Default values
    radius = radius or 40
    duration = duration or 1.5
    r = r or 1
    g = g or 0.7
    b = b or 0.3
    a = a or 0.7
    
    -- Number of points in the spiral
    local count = 15
    
    -- Create the spiral points
    for i = 1, count do
        -- Create the frame for the point
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetFrameStrata("BACKGROUND")
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        frame:SetSize(10, 10)
        
        -- Create the texture
        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints()
        texture:SetTexture("Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame01.tga")
        texture:SetVertexColor(r, g, b, a)
        
        -- Store the texture reference
        frame.texture = texture
        
        -- Calculate spiral position (initial)
        local progress = i / count
        local angle = progress * 4 * pi
        local rad = progress * radius
        local px = x + cos(angle) * rad
        local py = y + sin(angle) * rad
        
        -- Set the position and data
        frame.angle = angle
        frame.radius = rad
        frame.progress = progress
        frame.centerX = x
        frame.centerY = y
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", px, py)
        
        -- Add animation
        local ag = frame:CreateAnimationGroup()
        
        -- Fade out animation
        local fade = ag:CreateAnimation("Alpha")
        fade:SetFromAlpha(a)
        fade:SetToAlpha(0)
        fade:SetDuration(duration)
        fade:SetSmoothing("OUT")
        
        -- Set script for cleanup
        ag:SetScript("OnFinished", function()
            frame:Hide()
            frame:SetParent(nil)
            -- Remove from active effects
            for i = 1, #M.ActiveEffects do
                if M.ActiveEffects[i] == frame then
                    table.remove(M.ActiveEffects, i)
                    break
                end
            end
        end)
        
        -- Store the animation group
        frame.animation = ag
        
        -- Set update script for spiral movement
        frame:SetScript("OnUpdate", function(self, elapsed)
            -- Update progress
            self.progress = self.progress - elapsed / duration
            if self.progress < 0 then
                self.progress = 0
            end
            
            -- Calculate new spiral position
            local angle = self.progress * 4 * pi
            local rad = self.progress * radius
            local px = self.centerX + cos(angle) * rad
            local py = self.centerY + sin(angle) * rad
            
            -- Update position
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", px, py)
        end)
        
        -- Start the animation
        ag:Play()
        
        -- Add to active effects
        table.insert(M.ActiveEffects, frame)
    end
end

-- Create a fire trail behind cursor moves
function M:CreateFireTrailEffect(x1, y1, x2, y2, segments, width, r, g, b, a)
    -- Default values
    segments = segments or 5
    width = width or 20
    r = r or 1
    g = g or 0.5
    b = b or 0.2
    a = a or 0.7
    
    -- Calculate spacing between segments
    local dx = (x2 - x1) / segments
    local dy = (y2 - y1) / segments
    
    -- Create segments
    for i = 1, segments do
        -- Calculate position
        local px = x1 + dx * (i - 1)
        local py = y1 + dy * (i - 1)
        
        -- Create the frame for the flame
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetFrameStrata("BACKGROUND")
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", px, py)
        frame:SetSize(width, width)
        
        -- Create the texture
        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints()
        texture:SetTexture("Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame0" .. (1 + (i % 3)) .. ".tga")
        texture:SetVertexColor(r, g, b, a * (1 - (i / segments) * 0.7))
        
        -- Store the texture reference
        frame.texture = texture
        
        -- Add animation
        local ag = frame:CreateAnimationGroup()
        
        -- Fade out animation
        local fade = ag:CreateAnimation("Alpha")
        fade:SetFromAlpha(a * (1 - (i / segments) * 0.7))
        fade:SetToAlpha(0)
        fade:SetDuration(0.5 + i * 0.1)
        fade:SetSmoothing("OUT")
        
        -- Size animation (grow slightly)
        local grow = ag:CreateAnimation("Scale")
        grow:SetFromScale(1, 1)
        grow:SetToScale(1.3, 1.3)
        grow:SetDuration(0.5 + i * 0.1)
        grow:SetSmoothing("OUT")
        
        -- Set script for cleanup
        ag:SetScript("OnFinished", function()
            frame:Hide()
            frame:SetParent(nil)
            -- Remove from active effects
            for i = 1, #M.ActiveEffects do
                if M.ActiveEffects[i] == frame then
                    table.remove(M.ActiveEffects, i)
                    break
                end
            end
        end)
        
        -- Store the animation group
        frame.animation = ag
        
        -- Start the animation
        ag:Play()
        
        -- Add to active effects
        table.insert(M.ActiveEffects, frame)
    end
end

-- Clean up all active effects
function M:CleanupEffects()
    for i = #M.ActiveEffects, 1, -1 do
        local frame = M.ActiveEffects[i]
        if frame then
            if frame.animation then
                frame.animation:Stop()
            end
            frame:Hide()
            frame:SetParent(nil)
        end
        table.remove(M.ActiveEffects, i)
    end
end