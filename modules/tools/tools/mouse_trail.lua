local _, VUI = ...

-- Access the Tools module
local Tools = VUI.tools

-- Register the tool in the available tools list
Tools.availableTools.mouseTrail = {
    name = "Mouse Trail",
    description = "Creates a colorful visual trail behind your cursor",
    icon = "Interface\\Icons\\inv_pet_spectralpixel",
    shortcut = "ALT-T",
    order = 3,
    enabled = true
}

-- Constants
local PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
local UPDATE_RATE = 0.01 -- How often to update the trail (seconds)
local MAX_PARTICLES = 100 -- Maximum number of particles to display
local PARTICLE_LIFETIME = 0.8 -- How long a particle lives (seconds)
local PARTICLE_SIZE = 24 -- Size of particles
local MIN_DISTANCE = 6 -- Minimum distance to spawn a new particle
local STARTING_ALPHA = 0.8 -- Initial alpha of particles
local FADE_SPEED = 1.2 -- How quickly particles fade

-- Locals
local trailFrame
local particlePool = {}
local activeParticles = {}
local lastX, lastY = 0, 0
local updateElapsed = 0
local isTrailEnabled = false
local lastParticleTime = 0
local currentColorIndex = 1
local mouseTrailTexture = [[Interface\AddOns\VUI\media\effects\mousetrail]]

-- Color presets for the trail
local colorPresets = {
    rainbow = {
        name = "Rainbow",
        colors = {
            {r = 1.0, g = 0.0, b = 0.0}, -- Red
            {r = 1.0, g = 0.5, b = 0.0}, -- Orange
            {r = 1.0, g = 1.0, b = 0.0}, -- Yellow
            {r = 0.0, g = 1.0, b = 0.0}, -- Green
            {r = 0.0, g = 1.0, b = 1.0}, -- Cyan
            {r = 0.0, g = 0.0, b = 1.0}, -- Blue
            {r = 0.7, g = 0.0, b = 1.0}, -- Purple
        }
    },
    fire = {
        name = "Fire",
        colors = {
            {r = 1.0, g = 0.0, b = 0.0}, -- Red
            {r = 1.0, g = 0.3, b = 0.0}, -- Orange-Red
            {r = 1.0, g = 0.5, b = 0.0}, -- Orange
            {r = 1.0, g = 0.7, b = 0.0}, -- Yellow-Orange
            {r = 1.0, g = 0.9, b = 0.0}, -- Yellow
        }
    },
    frost = {
        name = "Frost",
        colors = {
            {r = 0.0, g = 0.5, b = 1.0}, -- Light Blue
            {r = 0.0, g = 0.7, b = 1.0}, -- Sky Blue
            {r = 0.5, g = 0.8, b = 1.0}, -- Pale Blue
            {r = 0.7, g = 0.9, b = 1.0}, -- White-Blue
            {r = 1.0, g = 1.0, b = 1.0}, -- White
        }
    },
    nature = {
        name = "Nature",
        colors = {
            {r = 0.0, g = 0.5, b = 0.0}, -- Dark Green
            {r = 0.0, g = 0.7, b = 0.0}, -- Medium Green
            {r = 0.0, g = 1.0, b = 0.0}, -- Bright Green
            {r = 0.5, g = 1.0, b = 0.0}, -- Yellow-Green
            {r = 0.7, g = 1.0, b = 0.0}, -- Lime
        }
    },
    arcane = {
        name = "Arcane",
        colors = {
            {r = 0.5, g = 0.0, b = 0.7}, -- Purple
            {r = 0.7, g = 0.0, b = 1.0}, -- Violet
            {r = 0.8, g = 0.2, b = 1.0}, -- Magenta-Purple
            {r = 1.0, g = 0.5, b = 1.0}, -- Pink
            {r = 1.0, g = 0.7, b = 1.0}, -- Light Pink
        }
    },
    fel = {
        name = "Fel",
        colors = {
            {r = 0.0, g = 0.5, b = 0.0}, -- Dark Green
            {r = 0.0, g = 0.8, b = 0.0}, -- Green
            {r = 0.5, g = 1.0, b = 0.0}, -- Bright Green
            {r = 0.0, g = 1.0, b = 0.5}, -- Green-Cyan
            {r = 0.0, g = 1.0, b = 0.0}, -- Pure Green
        }
    },
    void = {
        name = "Void",
        colors = {
            {r = 0.3, g = 0.0, b = 0.5}, -- Dark Purple
            {r = 0.5, g = 0.0, b = 0.7}, -- Purple
            {r = 0.7, g = 0.0, b = 1.0}, -- Violet
            {r = 0.2, g = 0.0, b = 0.3}, -- Deep Purple
            {r = 0.1, g = 0.0, b = 0.2}, -- Almost Black Purple
        }
    },
    bloodfang = {
        name = "Bloodfang",
        colors = {
            {r = 0.7, g = 0.0, b = 0.0}, -- Dark Red
            {r = 0.9, g = 0.0, b = 0.0}, -- Red
            {r = 1.0, g = 0.0, b = 0.0}, -- Bright Red
            {r = 0.5, g = 0.0, b = 0.0}, -- Deep Red
            {r = 0.3, g = 0.0, b = 0.0}, -- Maroon
        }
    }
}

-- Initialize the main frame
local function CreateMouseTrailFrame()
    -- Main container frame
    local frame = CreateFrame("Frame", "VUIMouseTrailFrame", UIParent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetAllPoints()
    frame:Hide()
    
    -- Initialize particle pool
    for i = 1, MAX_PARTICLES do
        local particle = frame:CreateTexture(nil, "BACKGROUND")
        particle:SetTexture(mouseTrailTexture)
        particle:SetBlendMode("ADD")
        particle:SetSize(PARTICLE_SIZE, PARTICLE_SIZE)
        particle:Hide()
        
        table.insert(particlePool, particle)
    end
    
    return frame
end

-- Get a particle from the pool
local function GetParticle()
    -- Reuse the oldest particle if we've reached the maximum
    if #activeParticles >= MAX_PARTICLES then
        local oldestParticle = table.remove(activeParticles, 1)
        table.insert(activeParticles, oldestParticle)
        return oldestParticle
    end
    
    -- Get a new particle from the pool
    if #particlePool > 0 then
        local particle = table.remove(particlePool, 1)
        table.insert(activeParticles, particle)
        return particle
    end
    
    -- This should never happen (we create enough particles initially)
    return nil
end

-- Get next color from the current preset
local function GetNextColor()
    local selectedPreset = VUI.db.profile.modules.tools.toolSettings.mouseTrail.colorPreset or "rainbow"
    local preset = colorPresets[selectedPreset]
    if not preset then
        preset = colorPresets["rainbow"]
    end
    
    local color = preset.colors[currentColorIndex]
    currentColorIndex = currentColorIndex + 1
    if currentColorIndex > #preset.colors then
        currentColorIndex = 1
    end
    
    return color
end

-- Update existing particles (fade out, etc.)
local function UpdateParticles(elapsed)
    local i = 1
    while i <= #activeParticles do
        local particle = activeParticles[i]
        
        -- Update lifetime
        particle.lifetime = particle.lifetime - elapsed
        
        -- Remove expired particles
        if particle.lifetime <= 0 then
            particle:Hide()
            table.insert(particlePool, particle)
            table.remove(activeParticles, i)
        else
            -- Update alpha based on remaining lifetime
            local alpha = (particle.lifetime / PARTICLE_LIFETIME) * STARTING_ALPHA
            particle:SetAlpha(alpha)
            
            -- Update size based on remaining lifetime (optional)
            local sizeFactor = 1 - ((PARTICLE_LIFETIME - particle.lifetime) / PARTICLE_LIFETIME) * 0.7
            particle:SetSize(PARTICLE_SIZE * sizeFactor, PARTICLE_SIZE * sizeFactor)
            
            i = i + 1
        end
    end
end

-- Create a new particle at the cursor position
local function CreateParticleAtCursor()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    x = x / scale
    y = y / scale
    
    -- Check if cursor has moved enough to spawn a new particle
    local distance = ((x - lastX)^2 + (y - lastY)^2)^0.5
    if distance < MIN_DISTANCE then
        return
    end
    
    -- Get a particle
    local particle = GetParticle()
    if not particle then return end
    
    -- Position the particle
    particle:ClearAllPoints()
    particle:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    
    -- Set particle properties
    local color = GetNextColor()
    particle:SetVertexColor(color.r, color.g, color.b)
    particle:SetAlpha(STARTING_ALPHA)
    particle.lifetime = PARTICLE_LIFETIME
    
    -- Show the particle
    particle:Show()
    
    -- Remember last position
    lastX, lastY = x, y
    lastParticleTime = GetTime()
end

-- Main update function
local function OnUpdate(self, elapsed)
    if not isTrailEnabled then return end
    
    updateElapsed = updateElapsed + elapsed
    
    -- Update existing particles
    UpdateParticles(elapsed)
    
    -- Create new particles at regular intervals
    if updateElapsed >= UPDATE_RATE then
        updateElapsed = 0
        CreateParticleAtCursor()
    end
end

-- Event handler
local function OnEvent(self, event, ...)
    if event == PLAYER_ENTERING_WORLD then
        -- Initialize cursor position
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        lastX = x / scale
        lastY = y / scale
    end
end

-- Tool initialization
function Tools:mouseTrailInitialize()
    -- Create the main frame if it doesn't exist
    if not trailFrame then
        trailFrame = CreateMouseTrailFrame()
    end
    
    -- Setup defaults
    self:mouseTrailSetupDefaults()
    
    -- Set texture based on settings
    mouseTrailTexture = VUI.db.profile.modules.tools.toolSettings.mouseTrail.texture or mouseTrailTexture
    
    -- Update particle textures if needed
    for _, particle in ipairs(particlePool) do
        particle:SetTexture(mouseTrailTexture)
    end
    for _, particle in ipairs(activeParticles) do
        particle:SetTexture(mouseTrailTexture)
    end
    
    -- Reset color index
    currentColorIndex = 1
    
    -- Set enabled state based on settings
    isTrailEnabled = VUI.db.profile.modules.tools.toolSettings.mouseTrail.enabled
    
    if isTrailEnabled then
        -- Create event frame if it doesn't exist
        if not self.mouseTrailEventFrame then
            self.mouseTrailEventFrame = CreateFrame("Frame")
            self.mouseTrailEventFrame:SetScript("OnEvent", OnEvent)
        end
        
        -- Register events
        self.mouseTrailEventFrame:RegisterEvent(PLAYER_ENTERING_WORLD)
        
        -- Set up OnUpdate script
        trailFrame:SetScript("OnUpdate", OnUpdate)
        
        -- Show frame
        trailFrame:Show()
    else
        -- Unregister events if the tool is disabled
        if self.mouseTrailEventFrame then
            self.mouseTrailEventFrame:UnregisterAllEvents()
        end
        
        -- Remove OnUpdate script
        trailFrame:SetScript("OnUpdate", nil)
        
        -- Hide frame and clear particles
        trailFrame:Hide()
        for _, particle in ipairs(activeParticles) do
            particle:Hide()
            table.insert(particlePool, particle)
        end
        wipe(activeParticles)
    end
end

-- Tool disable
function Tools:mouseTrailDisable()
    -- Unregister events
    if self.mouseTrailEventFrame then
        self.mouseTrailEventFrame:UnregisterAllEvents()
    end
    
    -- Remove OnUpdate script
    if trailFrame then
        trailFrame:SetScript("OnUpdate", nil)
        
        -- Hide frame and clear particles
        trailFrame:Hide()
        for _, particle in ipairs(activeParticles) do
            particle:Hide()
            table.insert(particlePool, particle)
        end
        wipe(activeParticles)
    end
    
    isTrailEnabled = false
end

-- Setup defaults
function Tools:mouseTrailSetupDefaults()
    -- Ensure the tool has default settings in the VUI database
    if not VUI.defaults.profile.modules.tools.toolSettings.mouseTrail then
        VUI.defaults.profile.modules.tools.toolSettings.mouseTrail = {
            enabled = true,
            colorPreset = "rainbow",
            texture = mouseTrailTexture,
            particleSize = PARTICLE_SIZE,
            particleLifetime = PARTICLE_LIFETIME,
            particleCount = MAX_PARTICLES
        }
    end
    
    -- Initialize settings if they don't exist
    if not VUI.db.profile.modules.tools.toolSettings.mouseTrail then
        VUI.db.profile.modules.tools.toolSettings.mouseTrail = VUI.defaults.profile.modules.tools.toolSettings.mouseTrail
    end
end

-- Tool specific config
function Tools:mouseTrailConfig()
    -- Create options for each color preset
    local colorPresetOptions = {}
    for presetId, preset in pairs(colorPresets) do
        colorPresetOptions[presetId] = preset.name
    end
    
    return {
        enable = {
            type = "toggle",
            name = "Enable Mouse Trail",
            desc = "Toggle the mouse trail effect on/off",
            order = 10,
            width = "full",
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mouseTrail.enabled 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mouseTrail.enabled = val
                isTrailEnabled = val
                
                if val then
                    -- Enable the trail
                    if trailFrame then
                        trailFrame:SetScript("OnUpdate", OnUpdate)
                        trailFrame:Show()
                        
                        -- Initialize cursor position
                        local x, y = GetCursorPosition()
                        local scale = UIParent:GetEffectiveScale()
                        lastX = x / scale
                        lastY = y / scale
                    end
                else
                    -- Disable the trail
                    if trailFrame then
                        trailFrame:SetScript("OnUpdate", nil)
                        trailFrame:Hide()
                        
                        -- Clear particles
                        for _, particle in ipairs(activeParticles) do
                            particle:Hide()
                            table.insert(particlePool, particle)
                        end
                        wipe(activeParticles)
                    end
                end
            end
        },
        colorPreset = {
            type = "select",
            name = "Color Theme",
            desc = "Select the color theme for the mouse trail",
            order = 20,
            width = "full",
            values = colorPresetOptions,
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mouseTrail.colorPreset 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mouseTrail.colorPreset = val
                currentColorIndex = 1 -- Reset color index
            end
        },
        particleSize = {
            type = "range",
            name = "Particle Size",
            desc = "Set the size of the trail particles",
            order = 30,
            width = "full",
            min = 8,
            max = 40,
            step = 1,
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mouseTrail.particleSize 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mouseTrail.particleSize = val
                PARTICLE_SIZE = val
            end
        },
        particleLifetime = {
            type = "range",
            name = "Particle Lifetime",
            desc = "How long each particle stays visible (in seconds)",
            order = 40,
            width = "full",
            min = 0.2,
            max = 2.0,
            step = 0.1,
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mouseTrail.particleLifetime 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mouseTrail.particleLifetime = val
                PARTICLE_LIFETIME = val
            end
        },
        particleCount = {
            type = "range",
            name = "Maximum Particles",
            desc = "Maximum number of particles to display at once",
            order = 50,
            width = "full",
            min = 20,
            max = 200,
            step = 10,
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mouseTrail.particleCount 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mouseTrail.particleCount = val
                
                -- Update MAX_PARTICLES
                MAX_PARTICLES = val
                
                -- Recreate particle pool if needed
                if trailFrame then
                    -- Clear existing particles
                    for _, particle in ipairs(activeParticles) do
                        particle:Hide()
                        table.insert(particlePool, particle)
                    end
                    wipe(activeParticles)
                    
                    -- Create new particles if needed
                    local currentTotalParticles = #particlePool
                    if currentTotalParticles < MAX_PARTICLES then
                        for i = currentTotalParticles + 1, MAX_PARTICLES do
                            local particle = trailFrame:CreateTexture(nil, "BACKGROUND")
                            particle:SetTexture(mouseTrailTexture)
                            particle:SetBlendMode("ADD")
                            particle:SetSize(PARTICLE_SIZE, PARTICLE_SIZE)
                            particle:Hide()
                            
                            table.insert(particlePool, particle)
                        end
                    end
                end
            end
        }
    }
end