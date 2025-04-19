-- Phoenix Flame Theme - Texture Definitions
local _, VUI = ...
local Skins = VUI:GetModule("skins")
local PhoenixFlame = VUI.themes and VUI.themes.PhoenixFlame

if not PhoenixFlame then
    PhoenixFlame = {}
    VUI.themes = VUI.themes or {}
    VUI.themes.PhoenixFlame = PhoenixFlame
end

-- Texture creation and management
PhoenixFlame.Textures = {}

-- Initialize textures
function PhoenixFlame.Textures:Initialize()
    -- Register default textures
    self:RegisterBackgroundTextures()
    self:RegisterBorderTextures()
    self:RegisterButtonTextures()
    self:RegisterStatusBarTextures()
    self:RegisterGlowTextures()
    
    -- Set texture paths in the theme
    self:UpdateTexturePaths()
end

-- Register background textures
function PhoenixFlame.Textures:RegisterBackgroundTextures()
    -- Register the main backgrounds:
    -- 1. Dark smoky red background
    local backgroundPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\background.tga"
    
    -- 2. Alternate slightly lighter background
    local backgroundLightPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\background-light.tga"
    
    -- 3. Dark ember background with subtle flame pattern
    local backgroundEmberPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\background-ember.tga"
    
    -- Register with the media system if available
    if VUI.media and VUI.media.RegisterTexture then
        VUI.media:RegisterTexture("PhoenixFlame-Background", backgroundPath)
        VUI.media:RegisterTexture("PhoenixFlame-Background-Light", backgroundLightPath)
        VUI.media:RegisterTexture("PhoenixFlame-Background-Ember", backgroundEmberPath)
    end
    
    -- Store for later use
    self.background = {
        default = backgroundPath,
        light = backgroundLightPath,
        ember = backgroundEmberPath
    }
end

-- Register border textures
function PhoenixFlame.Textures:RegisterBorderTextures()
    -- Register border textures:
    -- 1. Glowing ember border
    local borderPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga"
    
    -- 2. Alternative border with more pronounced flame effect
    local borderFlamePath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border-flame.tga"
    
    -- 3. Subtle border for less prominent elements
    local borderSubtlePath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border-subtle.tga"
    
    -- Register with the media system if available
    if VUI.media and VUI.media.RegisterTexture then
        VUI.media:RegisterTexture("PhoenixFlame-Border", borderPath)
        VUI.media:RegisterTexture("PhoenixFlame-Border-Flame", borderFlamePath)
        VUI.media:RegisterTexture("PhoenixFlame-Border-Subtle", borderSubtlePath)
    end
    
    -- Store for later use
    self.border = {
        default = borderPath,
        flame = borderFlamePath,
        subtle = borderSubtlePath
    }
end

-- Register button textures
function PhoenixFlame.Textures:RegisterButtonTextures()
    -- Register button textures:
    -- 1. Normal button state
    local buttonNormalPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\button.tga"
    
    -- 2. Hover button state
    local buttonHoverPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\button-hover.tga"
    
    -- 3. Pressed button state
    local buttonPressedPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\button-pressed.tga"
    
    -- 4. Disabled button state
    local buttonDisabledPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\button-disabled.tga"
    
    -- Register with the media system if available
    if VUI.media and VUI.media.RegisterTexture then
        VUI.media:RegisterTexture("PhoenixFlame-Button", buttonNormalPath)
        VUI.media:RegisterTexture("PhoenixFlame-Button-Hover", buttonHoverPath)
        VUI.media:RegisterTexture("PhoenixFlame-Button-Pressed", buttonPressedPath)
        VUI.media:RegisterTexture("PhoenixFlame-Button-Disabled", buttonDisabledPath)
    end
    
    -- Store for later use
    self.button = {
        normal = buttonNormalPath,
        hover = buttonHoverPath,
        pressed = buttonPressedPath,
        disabled = buttonDisabledPath
    }
end

-- Register status bar textures
function PhoenixFlame.Textures:RegisterStatusBarTextures()
    -- Register status bar textures:
    -- 1. Standard status bar
    local statusBarPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\statusbar.tga"
    
    -- 2. Status bar with flame pattern
    local statusBarFlamePath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\statusbar-flame.tga"
    
    -- 3. Status bar with ember glow effect
    local statusBarGlowPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\statusbar-glow.tga"
    
    -- Register with the media system if available
    if VUI.media and VUI.media.RegisterTexture then
        VUI.media:RegisterTexture("PhoenixFlame-StatusBar", statusBarPath)
        VUI.media:RegisterTexture("PhoenixFlame-StatusBar-Flame", statusBarFlamePath)
        VUI.media:RegisterTexture("PhoenixFlame-StatusBar-Glow", statusBarGlowPath)
    end
    
    -- Store for later use
    self.statusbar = {
        default = statusBarPath,
        flame = statusBarFlamePath,
        glow = statusBarGlowPath
    }
end

-- Register glow textures
function PhoenixFlame.Textures:RegisterGlowTextures()
    -- Register glow textures:
    -- 1. Standard glow effect
    local glowPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga"
    
    -- 2. Animated flame glow effect
    local glowFlamePath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow-flame.tga"
    
    -- 3. Ember particle effect
    local glowEmberPath = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow-ember.tga"
    
    -- Register with the media system if available
    if VUI.media and VUI.media.RegisterTexture then
        VUI.media:RegisterTexture("PhoenixFlame-Glow", glowPath)
        VUI.media:RegisterTexture("PhoenixFlame-Glow-Flame", glowFlamePath)
        VUI.media:RegisterTexture("PhoenixFlame-Glow-Ember", glowEmberPath)
    end
    
    -- Store for later use
    self.glow = {
        default = glowPath,
        flame = glowFlamePath,
        ember = glowEmberPath
    }
end

-- Update texture paths in the theme
function PhoenixFlame.Textures:UpdateTexturePaths()
    -- If we have access to the PhoenixFlame theme, update its media paths
    if PhoenixFlame and PhoenixFlame.media and PhoenixFlame.media.textures then
        -- Update the texture paths
        PhoenixFlame.media.textures.background = self.background.default
        PhoenixFlame.media.textures.border = self.border.default
        PhoenixFlame.media.textures.button = self.button.normal
        PhoenixFlame.media.textures.statusbar = self.statusbar.default
        PhoenixFlame.media.textures.glow = self.glow.default
    end
end

-- Utility functions for texture manipulation
function PhoenixFlame.Textures:GenerateFireGradient(width, height, startColor, endColor)
    -- In a real implementation, this would create a gradient texture
    -- from orange to red, simulating fire
    return "Interface\\Buttons\\WHITE8x8" -- Fallback to default texture for now
end

-- We'll call the initialize function when the theme is loaded
PhoenixFlame.Textures:Initialize()