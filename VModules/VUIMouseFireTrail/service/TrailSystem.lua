-- VUIMouseFireTrail TrailSystem.lua
-- Core system for managing and rendering cursor trails

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Local variables
local GetCursorPosition = GetCursorPosition
local CreateFrame = CreateFrame
local UIParent = UIParent
local min = math.min
local max = math.max
local random = math.random

-- Trail system variables
local trailFrames = {}
local trailPositions = {}
local isInitialized = false
local frameCounter = 0
local lastUpdate = 0
local mousePosX, mousePosY = 0, 0
local lastMousePosX, lastMousePosY = 0, 0

-- Initialize the trail system
function M:InitializeTrailSystem()
    if isInitialized then return end
    
    -- Create the parent frame for all trail elements
    self.parentFrame = CreateFrame("Frame", "VUIMouseFireTrailParentFrame", UIParent)
    self.parentFrame:SetFrameStrata("BACKGROUND")
    self.parentFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    self.parentFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    self.parentFrame:SetFrameLevel(1)
    
    -- Set up the update script
    self.parentFrame:SetScript("OnUpdate", function(self, elapsed)
        M:OnUpdate(elapsed)
    end)
    
    -- Create the trail frames
    self:CreateTrailFrames()
    
    -- Initialize positions array
    for i = 1, self.db.profile.trailCount do
        trailPositions[i] = {x = 0, y = 0, alpha = 0, size = 0}
    end
    
    -- Mark as initialized
    isInitialized = true
end

-- Create the trail frames
function M:CreateTrailFrames()
    -- Clean up any existing frames
    for i = 1, #trailFrames do
        if trailFrames[i] then
            trailFrames[i]:Hide()
            trailFrames[i]:SetParent(nil)
            trailFrames[i] = nil
        end
    end
    
    -- Clear the array
    wipe(trailFrames)
    
    -- Create new frames
    for i = 1, self.db.profile.trailCount do
        local frame = CreateFrame("Frame", "VUIMouseFireTrailFrame"..i, self.parentFrame)
        frame:SetFrameStrata("BACKGROUND")
        frame:SetFrameLevel(2)
        frame:SetSize(self.db.profile.trailSize, self.db.profile.trailSize)
        frame:SetAlpha(0)
        frame:Hide()
        
        -- Create the texture
        local texture = frame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints()
        texture:SetTexture(self:GetTrailTexture())
        
        -- Set the color based on the color mode
        self:ApplyTrailColor(texture)
        
        -- Store the texture reference
        frame.texture = texture
        
        -- Store the frame
        trailFrames[i] = frame
    end
end

-- Get the appropriate texture for the trail
function M:GetTrailTexture()
    local textureType = self.db.profile.trailTexture or "flame01"
    local texturePath = "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame01.tga"
    
    -- Use the TextureManager to get the texture
    if self.GetTexture then
        local category = "Basic"
        if self.db.profile.trailType == "TEXTURE" then
            category = self.db.profile.textureCategory or "Flame"
        end
        
        texturePath = self:GetTexture(category, 1)
    end
    
    return texturePath
end

-- Apply the trail color based on colorMode
function M:ApplyTrailColor(texture)
    if not texture then return end
    
    local colorMode = self.db.profile.colorMode or "FIRE"
    local r, g, b, a = 1, 0.7, 0.3, self.db.profile.trailAlpha or 0.7
    
    -- Apply colors based on the mode
    if colorMode == "FIRE" then
        r, g, b = 1, 0.7, 0.3
    elseif colorMode == "ARCANE" then
        r, g, b = 0.7, 0.3, 1
    elseif colorMode == "FROST" then
        r, g, b = 0.3, 0.7, 1
    elseif colorMode == "NATURE" then
        r, g, b = 0.3, 1, 0.3
    elseif colorMode == "THEME" then
        -- Get color from current VUI theme
        local themeColor = VUI.Media:GetThemeColor()
        r, g, b = themeColor.r, themeColor.g, themeColor.b
    elseif colorMode == "CUSTOM" then
        -- Use custom color
        r = self.db.profile.customColorR or 1
        g = self.db.profile.customColorG or 1
        b = self.db.profile.customColorB or 1
    elseif colorMode == "RAINBOW" then
        -- Rainbow will be handled dynamically in the update function
        -- Just use a default color here
        r, g, b = 1, 0, 0
    end
    
    -- Apply the color to the texture
    texture:SetVertexColor(r, g, b, a)
end

-- Update all trail colors (for theme changes)
function M:UpdateTheme()
    if not isInitialized then return end
    
    for i = 1, #trailFrames do
        if trailFrames[i] and trailFrames[i].texture then
            self:ApplyTrailColor(trailFrames[i].texture)
        end
    end
end

-- Update rainbow color for a frame
function M:UpdateRainbowColor(frameIndex)
    if not trailFrames[frameIndex] or not trailFrames[frameIndex].texture then return end
    
    -- Only apply rainbow if colorMode is set to RAINBOW
    if self.db.profile.colorMode ~= "RAINBOW" then return end
    
    -- Calculate hue based on frame index and time
    local hue = (frameIndex / self.db.profile.trailCount) + (GetTime() * 0.2) % 1
    
    -- Convert HSV to RGB (simplified, assuming S and V are 1)
    local r, g, b = 0, 0, 0
    local hi = math.floor(hue * 6) % 6
    local f = hue * 6 - hi
    local p = 0
    local q = 1 - f
    local t = f
    
    if hi == 0 then r, g, b = 1, t, p
    elseif hi == 1 then r, g, b = q, 1, p
    elseif hi == 2 then r, g, b = p, 1, t
    elseif hi == 3 then r, g, b = p, q, 1
    elseif hi == 4 then r, g, b = t, p, 1
    elseif hi == 5 then r, g, b = 1, p, q
    end
    
    -- Apply the color to the texture
    trailFrames[frameIndex].texture:SetVertexColor(r, g, b, self.db.profile.trailAlpha or 0.7)
end

-- Update function called every frame
function M:OnUpdate(elapsed)
    -- Check if the module is enabled
    if not self.db.profile.enabled then
        -- Hide all frames
        for i = 1, #trailFrames do
            if trailFrames[i] then
                trailFrames[i]:Hide()
            end
        end
        return
    end
    
    -- Update frame counter for throttling
    frameCounter = frameCounter + 1
    lastUpdate = lastUpdate + elapsed
    
    -- Only update at the specified frequency
    local updateFrequency = 1 / (self.db.profile.trailSmoothing or 60)
    if lastUpdate < updateFrequency then
        return
    end
    
    -- Reset the update timer
    lastUpdate = 0
    
    -- Get the current cursor position
    local currentX, currentY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    currentX, currentY = currentX / scale, currentY / scale
    
    -- Store the last known position
    lastMousePosX, lastMousePosY = mousePosX, mousePosY
    mousePosX, mousePosY = currentX, currentY
    
    -- Calculate movement based on distance between last positions
    local distX = mousePosX - lastMousePosX
    local distY = mousePosY - lastMousePosY
    local distance = math.sqrt(distX * distX + distY * distY)
    
    -- Skip if there's no significant movement
    if distance < 1 then return end
    
    -- Check display conditions
    if not self:ShouldDisplayTrail() then
        -- Hide all frames when conditions aren't met
        for i = 1, #trailFrames do
            if trailFrames[i] then
                trailFrames[i]:Hide()
            end
        end
        return
    end
    
    -- Shift positions down
    for i = self.db.profile.trailCount, 2, -1 do
        trailPositions[i].x = trailPositions[i-1].x
        trailPositions[i].y = trailPositions[i-1].y
        trailPositions[i].alpha = trailPositions[i-1].alpha * self.db.profile.trailDecay
        trailPositions[i].size = trailPositions[i-1].size
    end
    
    -- Set the new head position
    trailPositions[1].x = mousePosX
    trailPositions[1].y = mousePosY
    trailPositions[1].alpha = self.db.profile.trailAlpha
    
    -- Add some random size variation if enabled
    local variation = 0
    if self.db.profile.trailVariation > 0 then
        variation = random() * self.db.profile.trailVariation * 2 - self.db.profile.trailVariation
    end
    trailPositions[1].size = self.db.profile.trailSize * (1 + variation)
    
    -- Update trail appearance based on type
    if self.db.profile.trailType == "PARTICLE" then
        self:UpdateParticleTrail()
    elseif self.db.profile.trailType == "TEXTURE" then
        self:UpdateTextureTrail()
    elseif self.db.profile.trailType == "SHAPE" then
        self:UpdateShapeTrail()
    elseif self.db.profile.trailType == "GLOW" then
        self:UpdateGlowTrail()
    else
        -- Default to particle
        self:UpdateParticleTrail()
    end
    
    -- Connect trail segments with lines if enabled
    if self.db.profile.connectSegments then
        self:ConnectTrailSegments()
    end
end

-- Check if trail should be displayed based on conditions
function M:ShouldDisplayTrail()
    -- Check combat state
    if not self.db.profile.showInCombat and UnitAffectingCombat("player") then
        return false
    end
    
    -- Check instance type
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        if instanceType == "party" or instanceType == "raid" then
            if not self.db.profile.showInInstances then
                return false
            end
        end
    else
        -- Open world
        if not self.db.profile.showInWorld then
            return false
        end
    end
    
    -- Check rest area
    if not self.db.profile.showInRestArea and IsResting() then
        return false
    end
    
    -- Check mouse button condition
    if self.db.profile.requireMouseButton then
        local anyButtonDown = false
        for i = 1, 5 do
            if IsMouseButtonDown(i) then
                anyButtonDown = true
                break
            end
        end
        if not anyButtonDown then
            return false
        end
    end
    
    -- Check modifier key condition
    if self.db.profile.requireModifierKey then
        if not (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()) then
            return false
        end
    end
    
    return true
end

-- Update trail in particle mode
function M:UpdateParticleTrail()
    for i = 1, self.db.profile.trailCount do
        local frame = trailFrames[i]
        if not frame then return end
        
        -- Skip frames with no position yet
        if trailPositions[i].x == 0 and trailPositions[i].y == 0 then
            frame:Hide()
        else
            -- Position and size the frame
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", trailPositions[i].x, trailPositions[i].y)
            
            -- Scale down with distance from head
            local scale = 1 - ((i - 1) / self.db.profile.trailCount) * 0.5
            local size = trailPositions[i].size * scale
            frame:SetSize(size, size)
            
            -- Update alpha
            frame:SetAlpha(trailPositions[i].alpha)
            
            -- Hide if alpha is too low
            if trailPositions[i].alpha < 0.02 then
                frame:Hide()
            else
                frame:Show()
            end
            
            -- Update rainbow color if needed
            if self.db.profile.colorMode == "RAINBOW" then
                self:UpdateRainbowColor(i)
            end
        end
    end
end

-- Update trail in texture mode
function M:UpdateTextureTrail()
    -- Similar to particle mode but with different textures
    self:UpdateParticleTrail()
end

-- Update trail in shape mode
function M:UpdateShapeTrail()
    -- If we have the shape generator, use it
    if self.ApplyShapeToTrail then
        local shapeType = self.db.profile.trailShape or "V_SHAPE"
        local angle = 0
        local width = self.db.profile.trailSize * 2
        local length = self.db.profile.trailSize * 3
        
        -- Apply the shape to the trail
        self:ApplyShapeToTrail(shapeType, trailFrames, mousePosX, mousePosY, angle, width, length)
        
        -- Update opacity and show frames
        for i = 1, self.db.profile.trailCount do
            if trailFrames[i] then
                -- Calculate alpha based on position in trail
                local alpha = max(0, 1 - ((i - 1) / self.db.profile.trailCount)) * self.db.profile.trailAlpha
                trailFrames[i]:SetAlpha(alpha)
                
                -- Update rainbow color if needed
                if self.db.profile.colorMode == "RAINBOW" then
                    self:UpdateRainbowColor(i)
                end
                
                -- Show/hide based on alpha
                if alpha < 0.02 then
                    trailFrames[i]:Hide()
                else
                    trailFrames[i]:Show()
                end
            end
        end
    else
        -- Fall back to particle mode if shape generator is missing
        self:UpdateParticleTrail()
    end
end

-- Update trail in glow mode
function M:UpdateGlowTrail()
    -- Create a glow effect that follows the cursor
    local frame = trailFrames[1]
    if not frame then return end
    
    -- Position at current cursor position
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", mousePosX, mousePosY)
    
    -- Set size based on settings
    local size = self.db.profile.trailSize * 2
    frame:SetSize(size, size)
    
    -- Set alpha
    frame:SetAlpha(self.db.profile.trailAlpha)
    
    -- Show this frame
    frame:Show()
    
    -- Hide all other frames
    for i = 2, self.db.profile.trailCount do
        if trailFrames[i] then
            trailFrames[i]:Hide()
        end
    end
    
    -- Add glow effect if enabled
    if self.db.profile.enableGlow and frame.texture then
        -- Create glow if it doesn't exist
        if not frame.glow then
            frame.glow = frame:CreateTexture(nil, "BACKGROUND")
            frame.glow:SetAllPoints()
            frame.glow:SetTexture(frame.texture:GetTexture())
            frame.glow:SetBlendMode("ADD")
        end
        
        -- Apply glow color
        local r, g, b = frame.texture:GetVertexColor()
        frame.glow:SetVertexColor(r, g, b, 0.7)
        
        -- Animate glow if pulsing is enabled
        if self.db.profile.pulsingGlow then
            -- Simple pulsing animation
            local factor = (math.sin(GetTime() * 3) + 1) / 2 -- 0 to 1
            local pulsedSize = size * (1 + factor * 0.3)
            frame.glow:SetSize(pulsedSize, pulsedSize)
        else
            -- Static glow
            frame.glow:SetAllPoints()
        end
    elseif frame.glow then
        -- Hide glow if disabled
        frame.glow:Hide()
    end
end

-- Connect trail segments with lines
function M:ConnectTrailSegments()
    -- This would need a LineTexture implementation
    -- For now, we'll just leave it as a placeholder
end

-- Initialize the module
function M:Initialize()
    -- Create the DB
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults
    })
    
    -- Initialize the trail system
    self:InitializeTrailSystem()
    
    -- Register any needed events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Register slash command
    self:RegisterChatCommand("vuitrail", "SlashCommand")
end

-- Handle events
function M:PLAYER_ENTERING_WORLD()
    -- Validate textures when entering world
    if self.ValidateTextures then
        self:ValidateTextures()
    end
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        print("|cffff9900VUIMouseFireTrail:|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        VUI.Config:OpenToCategory(self.TITLE)
    end
end