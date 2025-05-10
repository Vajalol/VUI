-- VUIMouseFireTrail Module
-- Creates a fire trail effect following the mouse cursor
-- Based on Frogski's mouse fire trail WeakAura (https://wago.io/RzZVq4F1a)

local AddonName, VUI = ...
local MODNAME = "VUIMouseFireTrail"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Mouse Fire Trail"
M.DESCRIPTION = "Creates a fire effect that follows your mouse cursor"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        particleCount = 25,         -- Number of particles in the trail
        particleSize = 25,          -- Size of each particle
        particleAlpha = 0.7,        -- Transparency of particles
        particleDecay = 0.92,       -- How quickly particles fade (0.8-0.98)
        particleVariation = 0.2,    -- Random size variation (0-1)
        particleTrailLength = 0.4,  -- Length of the trail (0.1-1)
        particleSpeed = 1.5,        -- How fast the particles move (0.5-3)
        colorMode = "FIRE",         -- FIRE, ARCANE, FROST, NATURE, RAINBOW
        customColor = {r = 1, g = 0.5, b = 0},   -- Custom color
        enableInCombat = true,      -- Enable during combat
        enableInInstance = true,    -- Enable in dungeons/raids
        enableInRest = true,        -- Enable in rest areas
        enableInWorld = true,       -- Enable in the open world
        hideWithUI = true,          -- Hide when UI is hidden
        mouseButtonRequired = false, -- Require holding mouse button
        mouseButton = "RIGHT",      -- Which mouse button (LEFT, RIGHT, MIDDLE)
        keyModifierRequired = false, -- Require holding key modifier
        keyModifier = "SHIFT",      -- Which key modifier (SHIFT, CTRL, ALT)
    }
}

-- Particle effect textures
M.FireTextureID = 135818     -- Fireball spell texture
M.ArcaneTextureID = 135734   -- Arcane Missiles spell texture
M.FrostTextureID = 135840    -- Frostbolt spell texture
M.NatureTextureID = 136006   -- Regrowth spell texture

-- Initialize module
function M:OnInitialize()
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(MODNAME, self.defaults)
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    
    -- Initialize particle system
    self:CreateParticleSystem()
    
    self:Debug("VUIMouseFireTrail module initialized")
end

function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisibility")  -- Entered combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility")   -- Left combat
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateVisibility")
    
    -- Register hidden event handler
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("CINEMATIC_START")
    frame:RegisterEvent("CINEMATIC_STOP")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "CINEMATIC_START" then
            -- Hide during cinematics
            M.particleFrame:Hide()
        elseif event == "CINEMATIC_STOP" or event == "PLAYER_ENTERING_WORLD" then
            -- Check if we should show after cinematic
            M:UpdateVisibility()
        end
    end)
    
    -- Hook mouse handlers
    WorldFrame:HookScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
    
    -- Check if UI is hidden
    hooksecurefunc("ShowUIPanel", function() self:UpdateVisibility() end)
    hooksecurefunc("HideUIPanel", function() self:UpdateVisibility() end)
    
    -- Initial visibility check
    self:UpdateVisibility()
    
    self:Debug("VUIMouseFireTrail module enabled")
end

function M:OnDisable()
    -- Hide particles
    if self.particleFrame then
        self.particleFrame:Hide()
    end
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    self:Debug("VUIMouseFireTrail module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    VUI:Debug(MODNAME, ...)
end

function M:Print(...)
    VUI:Print("|cFFFF6600VUI Mouse Fire Trail:|r", ...)
end

-- Create particle system
function M:CreateParticleSystem()
    -- Create main frame
    local frame = CreateFrame("Frame", "VUIMouseFireTrailFrame", UIParent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetSize(1, 1)
    frame:SetPoint("CENTER")
    frame:Hide()
    
    -- Create particle pool
    self.particles = {}
    self.textures = {}
    self.texturePool = {}
    
    -- Store reference to frame
    self.particleFrame = frame
    
    -- Initialize particles
    self:InitParticles()
end

-- Initialize particles
function M:InitParticles()
    -- Clear any existing particles
    for i = 1, #self.particles do
        if self.textures[i] then
            self.textures[i]:Hide()
            table.insert(self.texturePool, self.textures[i])
        end
    end
    
    wipe(self.particles)
    wipe(self.textures)
    
    -- Create new particles based on settings
    for i = 1, self.db.profile.particleCount do
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
            texture = self.particleFrame:CreateTexture(nil, "BACKGROUND")
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
function M:SetParticleTexture(texture)
    local textureID
    
    -- Choose texture based on color mode
    if self.db.profile.colorMode == "FIRE" then
        textureID = self.FireTextureID
    elseif self.db.profile.colorMode == "ARCANE" then
        textureID = self.ArcaneTextureID
    elseif self.db.profile.colorMode == "FROST" then
        textureID = self.FrostTextureID
    elseif self.db.profile.colorMode == "NATURE" then
        textureID = self.NatureTextureID
    elseif self.db.profile.colorMode == "CUSTOM" then
        textureID = self.FireTextureID  -- Use fire texture with custom color
    else
        textureID = self.FireTextureID  -- Default to fire
    end
    
    texture:SetTexture(textureID)
    
    -- Apply custom color if needed
    if self.db.profile.colorMode == "CUSTOM" then
        local c = self.db.profile.customColor
        texture:SetVertexColor(c.r, c.g, c.b)
    elseif self.db.profile.colorMode == "RAINBOW" then
        -- Set random color for rainbow mode
        texture:SetVertexColor(math.random(), math.random(), math.random())
    else
        -- Reset vertex color for standard textures
        texture:SetVertexColor(1, 1, 1)
    end
end

-- Update particle system
function M:OnUpdate(elapsed)
    -- Check if the module is enabled
    if not self.db.profile.enabled then return end
    
    -- Check if particle frame exists
    if not self.particleFrame then return end
    
    -- Check if the frame is hidden
    if not self.particleFrame:IsShown() then return end
    
    -- Check key modifiers if required
    if self.db.profile.keyModifierRequired then
        local modifier = self.db.profile.keyModifier
        if modifier == "SHIFT" and not IsShiftKeyDown() then return end
        if modifier == "CTRL" and not IsControlKeyDown() then return end
        if modifier == "ALT" and not IsAltKeyDown() then return end
    end
    
    -- Check mouse button if required
    if self.db.profile.mouseButtonRequired then
        local button = self.db.profile.mouseButton
        if button == "LEFT" and not IsMouseButtonDown("LeftButton") then return end
        if button == "RIGHT" and not IsMouseButtonDown("RightButton") then return end
        if button == "MIDDLE" and not IsMouseButtonDown("MiddleButton") then return end
    end
    
    -- Get mouse position
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    cursorX = cursorX / uiScale
    cursorY = cursorY / uiScale
    
    -- Update particles
    local particleSize = self.db.profile.particleSize
    local decay = self.db.profile.particleDecay
    local variation = self.db.profile.particleVariation
    local speed = self.db.profile.particleSpeed
    
    -- Find oldest particle
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
                if self.db.profile.colorMode == "RAINBOW" then
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
    local trailLength = self.db.profile.particleTrailLength
    local threshold = math.max(0.05, 1 - (trailLength * 0.9))
    
    -- Check if we should spawn a new particle
    if math.random() > threshold then
        local idx = oldestIdx
        local p = self.particles[idx]
        
        -- Calculate random offsets for visual effect
        local randX = (math.random() - 0.5) * 5 * speed
        local randY = (math.random() - 0.5) * 5 * speed
        
        -- Create new particle
        p.x = cursorX + randX
        p.y = cursorY + randY
        p.alpha = self.db.profile.particleAlpha
        
        -- Random size variation
        local baseSize = particleSize * (1 + ((math.random() - 0.5) * variation))
        p.size = baseSize
        p.active = true
        
        -- Update texture
        local texture = self.textures[idx]
        
        -- Set rainbow color if needed
        if self.db.profile.colorMode == "RAINBOW" then
            texture:SetVertexColor(math.random(), math.random(), math.random())
        end
        
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
        texture:SetSize(p.size, p.size)
        texture:SetAlpha(p.alpha)
        texture:Show()
    end
end

-- Update visibility based on conditions
function M:UpdateVisibility()
    -- Don't proceed if not enabled
    if not self.db.profile.enabled or not self.particleFrame then return end
    
    local shouldShow = true
    
    -- Check combat status
    if UnitAffectingCombat("player") and not self.db.profile.enableInCombat then
        shouldShow = false
    end
    
    -- Check zone type
    local inInstance, instanceType = IsInInstance()
    if inInstance and (instanceType == "party" or instanceType == "raid") and not self.db.profile.enableInInstance then
        shouldShow = false
    end
    
    -- Check for rested state
    if IsResting() and not self.db.profile.enableInRest then
        shouldShow = false
    end
    
    -- Check for open world
    if not inInstance and not IsResting() and not self.db.profile.enableInWorld then
        shouldShow = false
    end
    
    -- Check if UI is hidden
    if self.db.profile.hideWithUI and not UIParent:IsShown() then
        shouldShow = false
    end
    
    -- Set visibility with smooth animations if available
    if shouldShow then
        if not self.particleFrame:IsShown() and VUI.Animations then
            -- Use fade in animation
            VUI.Animations:FadeIn(self.particleFrame, 0.3, nil, {
                fromAlpha = 0,
                toAlpha = 1,
                smoothing = "OUT"
            })
        elseif not self.particleFrame:IsShown() then
            -- Fallback if animations module not available
            self.particleFrame:Show()
        end
    else
        if self.particleFrame:IsShown() and VUI.Animations then
            -- Use fade out animation
            VUI.Animations:FadeOut(self.particleFrame, 0.3, nil, {
                fromAlpha = 1,
                toAlpha = 0,
                smoothing = "IN"
            })
        elseif self.particleFrame:IsShown() then
            -- Fallback if animations module not available
            self.particleFrame:Hide()
        end
    end
end

-- Get color name from mode
function M:GetColorName(mode)
    if mode == "FIRE" then
        return L["Fire"]
    elseif mode == "ARCANE" then
        return L["Arcane"]
    elseif mode == "FROST" then
        return L["Frost"]
    elseif mode == "NATURE" then
        return L["Nature"]
    elseif mode == "RAINBOW" then
        return L["Rainbow"]
    elseif mode == "CUSTOM" then
        return L["Custom Color"]
    end
    return L["Unknown"]
end

-- Get options for configuration panel
function M:GetOptions()
    local options = {
        name = self.TITLE,
        type = "group",
        args = {
            general = {
                name = L["General Settings"],
                type = "group",
                order = 1,
                inline = true,
                args = {
                    enabled = {
                        name = L["Enable"],
                        desc = L["Enable/disable this module"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.enabled end,
                        set = function(info, value) 
                            self.db.profile.enabled = value
                            if value then self:OnEnable() else self:OnDisable() end
                        end,
                    },
                    enableHeader = {
                        name = L["Enable In Zones"],
                        type = "header",
                        order = 2,
                    },
                    enableInCombat = {
                        name = L["Show During Combat"],
                        desc = L["Show the fire trail during combat"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.enableInCombat end,
                        set = function(info, value)
                            self.db.profile.enableInCombat = value
                            self:UpdateVisibility()
                        end,
                    },
                    enableInInstance = {
                        name = L["Show In Instances"],
                        desc = L["Show the fire trail in dungeons and raids"],
                        type = "toggle",
                        order = 4,
                        get = function() return self.db.profile.enableInInstance end,
                        set = function(info, value)
                            self.db.profile.enableInInstance = value
                            self:UpdateVisibility()
                        end,
                    },
                    enableInRest = {
                        name = L["Show In Rest Areas"],
                        desc = L["Show the fire trail in cities and inns"],
                        type = "toggle",
                        order = 5,
                        get = function() return self.db.profile.enableInRest end,
                        set = function(info, value)
                            self.db.profile.enableInRest = value
                            self:UpdateVisibility()
                        end,
                    },
                    enableInWorld = {
                        name = L["Show In Open World"],
                        desc = L["Show the fire trail in the open world"],
                        type = "toggle",
                        order = 6,
                        get = function() return self.db.profile.enableInWorld end,
                        set = function(info, value)
                            self.db.profile.enableInWorld = value
                            self:UpdateVisibility()
                        end,
                    },
                    hideWithUI = {
                        name = L["Hide With UI"],
                        desc = L["Hide the fire trail when the UI is hidden"],
                        type = "toggle",
                        order = 7,
                        get = function() return self.db.profile.hideWithUI end,
                        set = function(info, value)
                            self.db.profile.hideWithUI = value
                            self:UpdateVisibility()
                        end,
                    },
                },
            },
            appearance = {
                name = L["Appearance"],
                type = "group",
                order = 2,
                args = {
                    colorMode = {
                        name = L["Particle Style"],
                        desc = L["Choose the visual style of the trail particles"],
                        type = "select",
                        order = 1,
                        values = {
                            ["FIRE"] = L["Fire"],
                            ["ARCANE"] = L["Arcane"],
                            ["FROST"] = L["Frost"],
                            ["NATURE"] = L["Nature"],
                            ["RAINBOW"] = L["Rainbow"],
                            ["CUSTOM"] = L["Custom Color"],
                        },
                        get = function() return self.db.profile.colorMode end,
                        set = function(info, value)
                            self.db.profile.colorMode = value
                            -- Reinitialize particles with new texture
                            self:InitParticles()
                        end,
                    },
                    customColor = {
                        name = L["Custom Color"],
                        desc = L["Set a custom color for the particles"],
                        type = "color",
                        order = 2,
                        get = function()
                            local c = self.db.profile.customColor
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            self.db.profile.customColor = {r = r, g = g, b = b}
                            -- Update particles with new color
                            self:InitParticles()
                        end,
                        disabled = function() return self.db.profile.colorMode ~= "CUSTOM" end,
                    },
                    particleSettings = {
                        name = L["Particle Settings"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            particleCount = {
                                name = L["Particle Count"],
                                desc = L["Number of particles in the trail"],
                                type = "range",
                                order = 1,
                                min = 5,
                                max = 100,
                                step = 1,
                                get = function() return self.db.profile.particleCount end,
                                set = function(info, value)
                                    self.db.profile.particleCount = value
                                    -- Reinitialize particles with new count
                                    self:InitParticles()
                                end,
                            },
                            particleSize = {
                                name = L["Particle Size"],
                                desc = L["Size of each particle"],
                                type = "range",
                                order = 2,
                                min = 10,
                                max = 100,
                                step = 1,
                                get = function() return self.db.profile.particleSize end,
                                set = function(info, value)
                                    self.db.profile.particleSize = value
                                end,
                            },
                            particleAlpha = {
                                name = L["Particle Alpha"],
                                desc = L["Transparency of particles"],
                                type = "range",
                                order = 3,
                                min = 0.1,
                                max = 1,
                                step = 0.05,
                                get = function() return self.db.profile.particleAlpha end,
                                set = function(info, value)
                                    self.db.profile.particleAlpha = value
                                end,
                            },
                            particleDecay = {
                                name = L["Particle Fade Speed"],
                                desc = L["How quickly particles fade away"],
                                type = "range",
                                order = 4,
                                min = 0.8,
                                max = 0.98,
                                step = 0.01,
                                get = function() return self.db.profile.particleDecay end,
                                set = function(info, value)
                                    self.db.profile.particleDecay = value
                                end,
                            },
                            particleVariation = {
                                name = L["Size Variation"],
                                desc = L["Random size variation of particles"],
                                type = "range",
                                order = 5,
                                min = 0,
                                max = 1,
                                step = 0.05,
                                get = function() return self.db.profile.particleVariation end,
                                set = function(info, value)
                                    self.db.profile.particleVariation = value
                                end,
                            },
                            particleTrailLength = {
                                name = L["Trail Length"],
                                desc = L["Length of the particle trail"],
                                type = "range",
                                order = 6,
                                min = 0.1,
                                max = 1,
                                step = 0.05,
                                get = function() return self.db.profile.particleTrailLength end,
                                set = function(info, value)
                                    self.db.profile.particleTrailLength = value
                                end,
                            },
                            particleSpeed = {
                                name = L["Particle Speed"],
                                desc = L["How fast the particles move"],
                                type = "range",
                                order = 7,
                                min = 0.5,
                                max = 3,
                                step = 0.1,
                                get = function() return self.db.profile.particleSpeed end,
                                set = function(info, value)
                                    self.db.profile.particleSpeed = value
                                end,
                            },
                        },
                    },
                },
            },
            activation = {
                name = L["Activation"],
                type = "group",
                order = 3,
                args = {
                    mouseButtonRequired = {
                        name = L["Require Mouse Button"],
                        desc = L["Only show trail when holding a mouse button"],
                        type = "toggle",
                        order = 1,
                        get = function() return self.db.profile.mouseButtonRequired end,
                        set = function(info, value)
                            self.db.profile.mouseButtonRequired = value
                        end,
                    },
                    mouseButton = {
                        name = L["Mouse Button"],
                        desc = L["Which mouse button to hold"],
                        type = "select",
                        order = 2,
                        values = {
                            ["LEFT"] = L["Left Button"],
                            ["RIGHT"] = L["Right Button"],
                            ["MIDDLE"] = L["Middle Button"],
                        },
                        get = function() return self.db.profile.mouseButton end,
                        set = function(info, value)
                            self.db.profile.mouseButton = value
                        end,
                        disabled = function() return not self.db.profile.mouseButtonRequired end,
                    },
                    keyModifierRequired = {
                        name = L["Require Key Modifier"],
                        desc = L["Only show trail when holding a modifier key"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.keyModifierRequired end,
                        set = function(info, value)
                            self.db.profile.keyModifierRequired = value
                        end,
                    },
                    keyModifier = {
                        name = L["Key Modifier"],
                        desc = L["Which key to hold"],
                        type = "select",
                        order = 4,
                        values = {
                            ["SHIFT"] = L["Shift"],
                            ["CTRL"] = L["Control"],
                            ["ALT"] = L["Alt"],
                        },
                        get = function() return self.db.profile.keyModifier end,
                        set = function(info, value)
                            self.db.profile.keyModifier = value
                        end,
                        disabled = function() return not self.db.profile.keyModifierRequired end,
                    },
                },
            },
        },
    }
    
    return options
end

-- Register the module
VUI:RegisterModule(MODNAME, M)