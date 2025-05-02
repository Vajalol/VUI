--[[
    VUI - Paperdoll ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.modules or not VUI.modules.paperdoll then return end

-- Create local namespace
local Paperdoll = VUI.modules.paperdoll
Paperdoll.ThemeIntegration = {}
local ThemeIntegration = Paperdoll.ThemeIntegration

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
    
    -- Log initialization
    if VUI.debug then
        VUI:Print("Paperdoll ThemeIntegration initialized")
    end
end

-- Apply the current theme to Paperdoll
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Update character frame appearance
    self:UpdateCharacterFrame()
    
    -- Update item level frame
    self:UpdateItemLevelFrame()
    
    -- Update durability display
    self:UpdateDurabilityFrame()
    
    -- Update stats display
    self:UpdateStatsDisplay()
end

-- Update the character frame with current theme
function ThemeIntegration:UpdateCharacterFrame()
    -- Apply theme to main frame
    local characterFrame = _G["CharacterFrame"]
    if not characterFrame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply background and border colors if frame is styled
    if Paperdoll.isCharacterFrameStyled then
        if characterFrame.backdrop then
            characterFrame.backdrop:SetColorTexture(
                backgroundColor.r, 
                backgroundColor.g, 
                backgroundColor.b, 
                backgroundColor.a or 0.8
            )
        end
        
        if characterFrame.border then
            characterFrame.border:SetColorTexture(
                borderColor.r, 
                borderColor.g, 
                borderColor.b, 
                borderColor.a or 1.0
            )
        end
        
        -- Style portrait frame if enabled
        if VUI.db.profile.modules.paperdoll.highQualityPortrait then
            local portrait = _G["CharacterModelFrame"]
            if portrait and portrait.portraitBorder then
                portrait.portraitBorder:SetVertexColor(
                    borderColor.r, 
                    borderColor.g, 
                    borderColor.b, 
                    1.0
                )
            end
        end
    end
    
    -- Check and update tabs with theme colors
    for i = 1, 5 do
        local tab = _G["CharacterFrameTab" .. i]
        if tab and tab.styled then
            local textColor = self:GetColor("text")
            local tabText = _G["CharacterFrameTab" .. i .. "Text"]
            if tabText then
                tabText:SetTextColor(textColor.r, textColor.g, textColor.b)
            end
        end
    end
end

-- Update item level frame with current theme
function ThemeIntegration:UpdateItemLevelFrame()
    if not Paperdoll.ilvlFrame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local highlightColor = self:GetColor("highlight")
    
    Paperdoll.ilvlFrame:SetBackdropColor(
        backgroundColor.r, 
        backgroundColor.g, 
        backgroundColor.b, 
        0.7
    )
    
    Paperdoll.ilvlFrame:SetBackdropBorderColor(
        borderColor.r, 
        borderColor.g, 
        borderColor.b, 
        1.0
    )
    
    if Paperdoll.ilvlFrame.text then
        Paperdoll.ilvlFrame.text:SetTextColor(
            highlightColor.r, 
            highlightColor.g, 
            highlightColor.b
        )
    end
end

-- Update durability frame with current theme
function ThemeIntegration:UpdateDurabilityFrame()
    if not Paperdoll.durabilityFrame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    Paperdoll.durabilityFrame:SetBackdropColor(
        backgroundColor.r, 
        backgroundColor.g, 
        backgroundColor.b, 
        0.7
    )
    
    Paperdoll.durabilityFrame:SetBackdropBorderColor(
        borderColor.r, 
        borderColor.g, 
        borderColor.b, 
        1.0
    )
    
    -- Update durability bars if they exist
    if Paperdoll.durabilityBars then
        for _, bar in pairs(Paperdoll.durabilityBars) do
            local color = self:GetDurabilityColor(bar.value or 1)
            bar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
end

-- Update stats display with current theme
function ThemeIntegration:UpdateStatsDisplay()
    if not _G["CharacterStatsPane"] then return end
    
    local textColor = self:GetColor("text")
    local highlightColor = self:GetColor("highlight")
    
    -- Apply text coloring to stat categories and values
    for statCategory in pairs(PAPERDOLL_STATCATEGORIES) do
        local categoryFrame = _G["CharacterStatsPaneCategory" .. statCategory]
        if categoryFrame and categoryFrame.Title then
            categoryFrame.Title:SetTextColor(highlightColor.r, highlightColor.g, highlightColor.b)
        end
        
        -- Color individual stat values if enabled
        if VUI.db.profile.modules.paperdoll.colorStatValues then
            for statIndex = 1, #PAPERDOLL_STATCATEGORIES[statCategory].stats do
                local statFrame = _G["CharacterStatsPaneCategory" .. statCategory .. "Stat" .. statIndex]
                if statFrame and statFrame.Value then
                    statFrame.Value:SetTextColor(textColor.r, textColor.g, textColor.b)
                end
            end
        end
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or themeColors.background or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or themeColors.border or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
        highlight = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
    }
    
    return colorMap[colorType] or colorMap.border
end

-- Get durability color based on percentage
function ThemeIntegration:GetDurabilityColor(durabilityPercentage)
    -- Theme-specific durability colors
    if durabilityPercentage <= 0.3 then
        return {r = 0.9, g = 0.1, b = 0.1} -- Red
    elseif durabilityPercentage <= 0.7 then
        return {r = 0.9, g = 0.9, b = 0.1} -- Yellow
    else
        local highlightColor = self:GetColor("highlight")
        return {r = 0.1, g = 0.8, b = 0.1} -- Green
    end
end

-- Convert a color table to a hex string
function ThemeIntegration:ColorToHex(color)
    if not color then return "ffffff" end
    
    return string.format("%02x%02x%02x", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255))
end