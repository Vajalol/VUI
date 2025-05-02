--[[
    VUI - DetailsSkin Texture Atlas
    Version: 0.2.0
    Author: VortexQ8
    
    This module implements the texture atlas system for the Details damage meter skin,
    significantly reducing memory usage and improving loading times.
]]

local _, VUI = ...
local DS = VUI.detailsskin or {}
VUI.detailsskin = DS

-- Local reference to the VUI Atlas system
local Atlas = VUI.Atlas

-- Local references for better performance
local pairs = pairs
local format = string.format
local gsub = string.gsub

-- Cache for atlas-based textures
DS.TextureCache = {}

-- Atlas registration information
DS.Atlas = {
    -- Track if the atlas is registered
    registered = false,
    
    -- Performance statistics
    stats = {
        textureLoads = 0,
        atlasHits = 0,
        cacheMisses = 0,
        memoryEstimatedSaved = 0
    },
    
    -- Atlas entries for each theme
    entries = {
        -- Structure will be populated in RegisterAtlas function
        -- phoenixflame = {},
        -- thunderstorm = {},
        -- arcanemystic = {},
        -- felenergy = {}
    }
}

-- Register the Details atlas with the core atlas system
function DS.Atlas:RegisterAtlas()
    if self.registered or not Atlas then return end
    
    -- Register each theme's textures
    self:RegisterThemeTextures("phoenixflame")
    self:RegisterThemeTextures("thunderstorm")
    self:RegisterThemeTextures("arcanemystic")
    self:RegisterThemeTextures("felenergy")
    
    -- Mark as registered
    self.registered = true
    
    VUI:Debug("DetailsSkin: Texture atlas registered")
end

-- Register textures for a specific theme
function DS.Atlas:RegisterThemeTextures(theme)
    if not Atlas then return end
    
    -- Initialize the theme entry if it doesn't exist
    self.entries[theme] = self.entries[theme] or {}
    
    -- Register bar texture
    local barTexture = DS.ThemeBarTextures[theme]
    if barTexture then
        -- Convert file path to atlas key
        local atlasKey = gsub(barTexture, "Interface\\AddOns\\VUI\\media\\textures\\themes\\.-\\(.+)%.tga", "%1")
        
        -- Register with the atlas system
        Atlas:RegisterTexture(
            "details." .. theme .. "." .. atlasKey,
            barTexture,
            {
                width = 256,
                height = 32,
                coords = {0, 1, 0, 1} -- Full texture coordinates
            }
        )
        
        -- Store the atlas key for later reference
        self.entries[theme].barTexture = "details." .. theme .. "." .. atlasKey
    end
    
    -- Register title bar texture
    local headerStyle = DS.ThemeHeaderStyles[theme]
    if headerStyle and headerStyle.texture then
        -- Convert file path to atlas key
        local atlasKey = gsub(headerStyle.texture, "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\(.+)%.svg", "%1")
        
        -- Register with the atlas system
        Atlas:RegisterTexture(
            "details." .. theme .. ".titlebar",
            headerStyle.texture,
            {
                width = 256,
                height = 32, 
                coords = {0, 1, 0, 1} -- Full texture coordinates
            }
        )
        
        -- Store the atlas key for later reference
        self.entries[theme].titleTexture = "details." .. theme .. ".titlebar"
    end
    
    -- Register button textures
    if DS.ThemeButtonTextures and DS.ThemeButtonTextures[theme] then
        for buttonType, texturePath in pairs(DS.ThemeButtonTextures[theme]) do
            -- Convert file path to atlas key
            local atlasKey = gsub(texturePath, "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\(.+)%.svg", "%1")
            
            -- Register with the atlas system
            Atlas:RegisterTexture(
                "details." .. theme .. ".button." .. buttonType,
                texturePath,
                {
                    width = 32,
                    height = 32,
                    coords = {0, 1, 0, 1} -- Full texture coordinates
                }
            )
            
            -- Store the atlas key for later reference
            self.entries[theme]["button_" .. buttonType] = "details." .. theme .. ".button." .. buttonType
        end
    end
    
    -- Register animation textures
    if DS.ThemeAnimations and DS.ThemeAnimations[theme] then
        local animations = DS.ThemeAnimations[theme]
        
        for animType, texturePath in pairs(animations) do
            if type(texturePath) == "string" then
                -- Convert file path to atlas key
                local atlasKey = gsub(texturePath, "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\(.+)%..+", "%1")
                
                -- Register with the atlas system
                Atlas:RegisterTexture(
                    "details." .. theme .. ".anim." .. animType,
                    texturePath,
                    {
                        width = 256,
                        height = 64,
                        coords = {0, 1, 0, 1} -- Full texture coordinates
                    }
                )
                
                -- Store the atlas key for later reference
                self.entries[theme]["anim_" .. animType] = "details." .. theme .. ".anim." .. animType
            end
        end
    end
    
    -- Register background texture if it exists
    local backgroundTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga"
    Atlas:RegisterTexture(
        "details." .. theme .. ".background",
        backgroundTexture,
        {
            width = 256,
            height = 256,
            coords = {0, 1, 0, 1} -- Full texture coordinates
        }
    )
    
    -- Store the atlas key for later reference
    self.entries[theme].background = "details." .. theme .. ".background"
    
    -- Register border texture
    local borderTexture = "Interface\\AddOns\\VUI\\media\\textures\\border.tga"
    Atlas:RegisterTexture(
        "details.border",
        borderTexture,
        {
            width = 32,
            height = 32,
            coords = {0, 1, 0, 1} -- Full texture coordinates
        }
    )
    
    -- Store the atlas key for later reference
    self.entries[theme].border = "details.border"
end

-- Get bar texture from atlas
function DS.Atlas:GetBarTexture(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Ensure atlas is registered
    if not self.registered then
        self:RegisterAtlas()
    end
    
    -- Check if theme exists in our entries
    if not self.entries[theme] then
        theme = "thunderstorm" -- Fallback to default theme
    end
    
    -- Get the atlas texture
    local atlasKey = self.entries[theme].barTexture
    if atlasKey then
        if Atlas:TextureExists(atlasKey) then
            self.stats.atlasHits = self.stats.atlasHits + 1
            self.stats.memoryEstimatedSaved = self.stats.memoryEstimatedSaved + 20 -- Estimation for each texture reuse
            return Atlas:GetTexture(atlasKey)
        else
            self.stats.cacheMisses = self.stats.cacheMisses + 1
        end
    end
    
    -- Fallback to classic texture path
    self.stats.textureLoads = self.stats.textureLoads + 1
    return DS.ThemeBarTextures[theme] or DS.ThemeBarTextures.thunderstorm
end

-- Get title bar texture from atlas
function DS.Atlas:GetTitleTexture(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Ensure atlas is registered
    if not self.registered then
        self:RegisterAtlas()
    end
    
    -- Check if theme exists in our entries
    if not self.entries[theme] then
        theme = "thunderstorm" -- Fallback to default theme
    end
    
    -- Get the atlas texture
    local atlasKey = self.entries[theme].titleTexture
    if atlasKey then
        if Atlas:TextureExists(atlasKey) then
            self.stats.atlasHits = self.stats.atlasHits + 1
            self.stats.memoryEstimatedSaved = self.stats.memoryEstimatedSaved + 20
            return Atlas:GetTexture(atlasKey)
        else
            self.stats.cacheMisses = self.stats.cacheMisses + 1
        end
    end
    
    -- Fallback to classic texture path
    self.stats.textureLoads = self.stats.textureLoads + 1
    local headerStyle = DS.ThemeHeaderStyles[theme] or DS.ThemeHeaderStyles.thunderstorm
    return headerStyle.texture
end

-- Get button texture from atlas
function DS.Atlas:GetButtonTexture(theme, buttonType)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Ensure atlas is registered
    if not self.registered then
        self:RegisterAtlas()
    end
    
    -- Check if theme exists in our entries
    if not self.entries[theme] then
        theme = "thunderstorm" -- Fallback to default theme
    end
    
    -- Get the atlas texture
    local atlasKey = self.entries[theme]["button_" .. buttonType]
    if atlasKey then
        if Atlas:TextureExists(atlasKey) then
            self.stats.atlasHits = self.stats.atlasHits + 1
            self.stats.memoryEstimatedSaved = self.stats.memoryEstimatedSaved + 20
            return Atlas:GetTexture(atlasKey)
        else
            self.stats.cacheMisses = self.stats.cacheMisses + 1
        end
    end
    
    -- Fallback to classic texture path
    self.stats.textureLoads = self.stats.textureLoads + 1
    return DS.ThemeButtonTextures and DS.ThemeButtonTextures[theme] and 
           DS.ThemeButtonTextures[theme][buttonType]
end

-- Get animation texture from atlas
function DS.Atlas:GetAnimTexture(theme, animType)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Ensure atlas is registered
    if not self.registered then
        self:RegisterAtlas()
    end
    
    -- Check if theme exists in our entries
    if not self.entries[theme] then
        theme = "thunderstorm" -- Fallback to default theme
    end
    
    -- Get the atlas texture
    local atlasKey = self.entries[theme]["anim_" .. animType]
    if atlasKey then
        if Atlas:TextureExists(atlasKey) then
            self.stats.atlasHits = self.stats.atlasHits + 1
            self.stats.memoryEstimatedSaved = self.stats.memoryEstimatedSaved + 20
            return Atlas:GetTexture(atlasKey)
        else
            self.stats.cacheMisses = self.stats.cacheMisses + 1
        end
    end
    
    -- Fallback to classic texture path
    self.stats.textureLoads = self.stats.textureLoads + 1
    return DS.ThemeAnimations and DS.ThemeAnimations[theme] and 
           DS.ThemeAnimations[theme][animType]
end

-- Get background texture from atlas
function DS.Atlas:GetBackgroundTexture(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Ensure atlas is registered
    if not self.registered then
        self:RegisterAtlas()
    end
    
    -- Check if theme exists in our entries
    if not self.entries[theme] then
        theme = "thunderstorm" -- Fallback to default theme
    end
    
    -- Get the atlas texture
    local atlasKey = self.entries[theme].background
    if atlasKey then
        if Atlas:TextureExists(atlasKey) then
            self.stats.atlasHits = self.stats.atlasHits + 1
            self.stats.memoryEstimatedSaved = self.stats.memoryEstimatedSaved + 20
            return Atlas:GetTexture(atlasKey)
        else
            self.stats.cacheMisses = self.stats.cacheMisses + 1
        end
    end
    
    -- Fallback to classic texture path
    self.stats.textureLoads = self.stats.textureLoads + 1
    return "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga"
end

-- Get border texture from atlas
function DS.Atlas:GetBorderTexture()
    -- Ensure atlas is registered
    if not self.registered then
        self:RegisterAtlas()
    end
    
    -- Get the atlas texture
    local atlasKey = "details.border"
    if Atlas:TextureExists(atlasKey) then
        self.stats.atlasHits = self.stats.atlasHits + 1
        self.stats.memoryEstimatedSaved = self.stats.memoryEstimatedSaved + 20
        return Atlas:GetTexture(atlasKey)
    else
        self.stats.cacheMisses = self.stats.cacheMisses + 1
    end
    
    -- Fallback to classic texture path
    self.stats.textureLoads = self.stats.textureLoads + 1
    return "Interface\\AddOns\\VUI\\media\\textures\\border.tga"
end

-- Reset statistics
function DS.Atlas:ResetStats()
    self.stats = {
        textureLoads = 0,
        atlasHits = 0,
        cacheMisses = 0,
        memoryEstimatedSaved = 0
    }
end

-- Get current statistics
function DS.Atlas:GetStats()
    return self.stats
end

-- Register with the resource cleanup system for memory management
if VUI.ResourceCleanup then
    VUI.ResourceCleanup:RegisterModule("DetailsSkinAtlas", function(deepCleanup)
        -- Clear our texture cache during cleanup
        wipe(DS.TextureCache)
        
        return true
    end)
end

-- Initialize the atlas when VUI is ready
if VUI.isInitialized and Atlas then
    DS.Atlas:RegisterAtlas()
else
    VUI:RegisterCallback("OnInitialized", function()
        if Atlas then
            DS.Atlas:RegisterAtlas()
        end
    end)
end