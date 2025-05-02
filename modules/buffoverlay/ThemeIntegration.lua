--[[
    VUI - BuffOverlay ThemeIntegration
    Version: 0.3.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.modules.buffoverlay then return end

-- Create local namespace
local BuffOverlay = VUI.modules.buffoverlay
BuffOverlay.ThemeIntegration = {}
local ThemeIntegration = BuffOverlay.ThemeIntegration

-- Store theme colors
local themeColors = {}
local activeTheme = "thunderstorm"

-- Initialize theme integration
function ThemeIntegration:Initialize()
    -- Get current theme colors
    activeTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Register for theme changes
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            self:ApplyTheme(theme)
        end)
    end
    
    -- Apply the theme immediately
    self:ApplyTheme(activeTheme)
    
    -- Theme integration ready
end

-- Apply the current theme to BuffOverlay
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Apply theme to existing buff frames
    self:ApplyThemeToAllBuffFrames()
    
    -- Apply theme to container frame
    self:StyleContainerFrame()
    
    -- Apply theme to configuration panel
    self:StyleConfigPanel()
end

-- Apply theme to all existing buff frames
function ThemeIntegration:ApplyThemeToAllBuffFrames()
    if not BuffOverlay.buffFrames then return end
    
    for _, frame in pairs(BuffOverlay.buffFrames) do
        self:ApplyThemeToBuffFrame(frame)
    end
end

-- Apply theme to a specific buff frame
function ThemeIntegration:ApplyThemeToBuffFrame(frame)
    if not frame then return end
    
    -- Get theme assets from the existing theme system
    local themeData = BuffOverlay.ThemeAssets[activeTheme]
    if not themeData then
        -- Use thunderstorm as default if theme data is missing
        themeData = BuffOverlay.ThemeAssets.thunderstorm
    end
    
    -- Set theme-specific textures using the atlas system
    if frame.themeOverlay then
        -- Get the texture from atlas if possible
        local sparkTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\spark.tga"
        local atlasTextureInfo = VUI:GetTextureCached(sparkTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            frame.themeOverlay:SetTexture(atlasTextureInfo.path)
            frame.themeOverlay:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
            
            -- Applied optimized theme texture from atlas
        else
            -- Fallback to original texture if not in atlas
            frame.themeOverlay:SetTexture(themeData.effects.spark or "Interface\\AddOns\\VUI\\media\\textures\\shared\\glow.tga")
            frame.themeOverlay:SetTexCoord(0, 1, 0, 1) -- Reset texture coordinates
            
            -- Using standard texture
        end
    end
    
    -- Apply icon frame texture from the atlas if available
    if frame.iconFrame then
        local iconFrameTexture = "Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\icon-frame.tga"
        local atlasTextureInfo = VUI:GetTextureCached(iconFrameTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            frame.iconFrame:SetTexture(atlasTextureInfo.path)
            frame.iconFrame:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
            frame.iconFrame:SetVertexColor(colors.border.r, colors.border.g, colors.border.b)
        end
    end
    
    -- Apply theme colors
    local colors = themeData.colors
    if frame.themeOverlay then
        frame.themeOverlay:SetVertexColor(colors.glow.r, colors.glow.g, colors.glow.b)
    end
    
    if frame.glow then
        -- Apply glow from atlas
        local glowTexture = "Interface\\AddOns\\VUI\\media\\textures\\common\\glow.tga"
        local atlasTextureInfo = VUI:GetTextureCached(glowTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            frame.glow:SetTexture(atlasTextureInfo.path)
            frame.glow:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
        else
            -- Fallback to original texture
            frame.glow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\glow.tga")
            frame.glow:SetTexCoord(0, 1, 0, 1) -- Reset texture coordinates
        end
        
        frame.glow:SetVertexColor(colors.glow.r, colors.glow.g, colors.glow.b)
    end
    
    -- Apply border colors based on frame properties
    if frame.border then
        -- Use appropriate border color based on buff priority
        local borderColor = colors.border
        if frame.priority == "important" then
            borderColor = colors.important or {r = 0.9, g = 0.4, b = 0.0}
        elseif frame.priority == "critical" then
            borderColor = colors.critical or {r = 0.9, g = 0.0, b = 0.0}
        elseif frame.isPurge then
            borderColor = colors.purge or {r = 0.5, g = 0.0, b = 0.7}
        elseif frame.isOffensive then
            borderColor = colors.offensive or {r = 0.8, g = 0.2, b = 0.2}
        end
        
        frame.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
    end
    
    -- Create or update theme-specific animations
    BuffOverlay:CreateThemeAnimations(frame, activeTheme)
end

-- Style the main container frame
function ThemeIntegration:StyleContainerFrame()
    if not BuffOverlay.container then return end
    
    local container = BuffOverlay.container
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Style container background if it exists
    if container.background then
        -- Try to get background texture from atlas
        local bgTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\background.tga"
        local atlasTextureInfo = VUI:GetTextureCached(bgTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            container.background:SetTexture(atlasTextureInfo.path)
            container.background:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
            container.background:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a or 0.5)
        else
            -- Fallback to color texture
            container.background:SetColorTexture(
                backgroundColor.r, 
                backgroundColor.g, 
                backgroundColor.b, 
                backgroundColor.a or 0.5
            )
        end
    end
    
    -- Style container border if it exists
    if container.border then
        -- Try to get border texture from atlas
        local borderTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\border.tga"
        local atlasTextureInfo = VUI:GetTextureCached(borderTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            container.border:SetTexture(atlasTextureInfo.path)
            container.border:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
            container.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 0.8)
        else
            -- Fallback to color texture
            container.border:SetColorTexture(
                borderColor.r, 
                borderColor.g, 
                borderColor.b, 
                borderColor.a or 0.8
            )
        end
    end
end

-- Style the configuration panel
function ThemeIntegration:StyleConfigPanel()
    if not BuffOverlay.configPanel then return end
    
    local panel = BuffOverlay.configPanel
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local textColor = self:GetColor("text")
    
    -- Apply background using atlas if available
    if panel.bg then
        -- Try to get background texture from atlas
        local bgTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\background.tga"
        local atlasTextureInfo = VUI:GetTextureCached(bgTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            panel.bg:SetTexture(atlasTextureInfo.path)
            panel.bg:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
            panel.bg:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a or 0.7)
        else
            -- Fallback to color texture
            panel.bg:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                backgroundColor.a or 0.7
            )
        end
    end
    
    -- Apply border using atlas if available
    if panel.border then
        -- Try to get border texture from atlas
        local borderTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\border.tga"
        local atlasTextureInfo = VUI:GetTextureCached(borderTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            -- Apply texture from atlas
            panel.border:SetTexture(atlasTextureInfo.path)
            panel.border:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
            panel.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 0.8)
        else
            -- Fallback to color texture
            panel.border:SetColorTexture(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                borderColor.a or 0.8
            )
        end
    end
    
    -- Apply text colors to all text elements
    if panel.titleText and panel.titleText.SetTextColor then
        panel.titleText:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1.0)
    end
    
    -- Apply colors to all category headers
    if panel.categoryHeaders then
        for _, header in pairs(panel.categoryHeaders) do
            if header.text and header.text.SetTextColor then
                header.text:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1.0)
            end
            
            if header.line then
                header.line:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 0.5)
            end
        end
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
        highlight = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
    }
    
    return colorMap[colorType] or colorMap.border
end

-- Convert a color table to a hex string
function ThemeIntegration:ColorToHex(color)
    if not color then return "ffffff" end
    
    return string.format("%02x%02x%02x", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255))
end