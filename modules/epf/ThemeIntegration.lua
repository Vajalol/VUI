--[[
    VUI - Enhanced Profile Frames (EPF) ThemeIntegration
    Version: 0.2.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.modules or not VUI.modules.epf then return end

-- Create local namespace
local EPF = VUI.modules.epf
EPF.ThemeIntegration = {}
local ThemeIntegration = EPF.ThemeIntegration

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
        VUI:Print("EPF ThemeIntegration initialized")
    end
end

-- Apply the current theme to EPF elements
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    if not EPF.enabled then return end
    
    -- Apply theme to player frame elements
    self:ApplyThemeToPlayerFrame()
    
    -- Apply theme to target frame elements
    self:ApplyThemeToTargetFrame()
    
    -- Apply theme to focus frame elements
    self:ApplyThemeToFocusFrame()
    
    -- Apply theme to party frames if enabled
    self:ApplyThemeToPartyFrames()
    
    -- Apply theme to boss frames if enabled
    self:ApplyThemeToBossFrames()
    
    -- Apply theme to arena frames if enabled
    self:ApplyThemeToArenaFrames()
end

-- Apply theme to player frame elements
function ThemeIntegration:ApplyThemeToPlayerFrame()
    if not PlayerFrame or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply to health bar background
    if PlayerFrameHealthBar and PlayerFrameHealthBar.background then
        PlayerFrameHealthBar.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            0.7
        )
    end
    
    -- Apply to power bar background
    if PlayerFrameManaBar and PlayerFrameManaBar.background then
        PlayerFrameManaBar.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            0.7
        )
    end
    
    -- Apply to frame border
    if EPF.frameBorder then
        EPF.frameBorder:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            1.0
        )
    end
    
    -- Apply theme colors to portrait frame if it exists
    if PlayerFramePortrait and EPF.portraitBorder then
        EPF.portraitBorder:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            1.0
        )
    end
    
    -- Apply theme to any enhancements on the player frame
    self:ApplyThemeToPlayerEnhancements()
end

-- Apply theme to target frame elements
function ThemeIntegration:ApplyThemeToTargetFrame()
    if not TargetFrame or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply to health bar background
    if TargetFrameHealthBar and TargetFrameHealthBar.background then
        TargetFrameHealthBar.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            0.7
        )
    end
    
    -- Apply to power bar background
    if TargetFrameManaBar and TargetFrameManaBar.background then
        TargetFrameManaBar.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            0.7
        )
    end
    
    -- Apply to frame border
    if EPF.targetFrameBorder then
        EPF.targetFrameBorder:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            1.0
        )
    end
    
    -- Apply theme to any target aura frames if present
    if EPF.settings.enhanceTargetAuras and EPF.enhancedAuraFrames then
        for _, frame in pairs(EPF.enhancedAuraFrames) do
            if frame.border then
                frame.border:SetVertexColor(
                    borderColor.r, 
                    borderColor.g, 
                    borderColor.b, 
                    1.0
                )
            end
            
            if frame.background then
                frame.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.5
                )
            end
        end
    end
end

-- Apply theme to focus frame elements
function ThemeIntegration:ApplyThemeToFocusFrame()
    if not FocusFrame or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply to health bar background
    if FocusFrameHealthBar and FocusFrameHealthBar.background then
        FocusFrameHealthBar.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            0.7
        )
    end
    
    -- Apply to power bar background
    if FocusFrameManaBar and FocusFrameManaBar.background then
        FocusFrameManaBar.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            0.7
        )
    end
    
    -- Apply to frame border
    if EPF.focusFrameBorder then
        EPF.focusFrameBorder:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            1.0
        )
    end
end

-- Apply theme to party frames if enabled
function ThemeIntegration:ApplyThemeToPartyFrames()
    if not EPF.settings.enhancePartyFrames or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each party frame
    for i = 1, 4 do
        local frame = _G["PartyMemberFrame" .. i]
        if frame then
            -- Apply to health bar background
            local healthBar = _G["PartyMemberFrame" .. i .. "HealthBar"]
            if healthBar and healthBar.background then
                healthBar.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
            
            -- Apply to power bar background
            local powerBar = _G["PartyMemberFrame" .. i .. "ManaBar"]
            if powerBar and powerBar.background then
                powerBar.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
            
            -- Apply to frame border if it exists
            if EPF.partyFrameBorders and EPF.partyFrameBorders[i] then
                EPF.partyFrameBorders[i]:SetVertexColor(
                    borderColor.r, 
                    borderColor.g, 
                    borderColor.b, 
                    1.0
                )
            end
        end
    end
end

-- Apply theme to boss frames if enabled
function ThemeIntegration:ApplyThemeToBossFrames()
    if not EPF.settings.enhanceBossFrames or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each boss frame
    for i = 1, MAX_BOSS_FRAMES do
        local frame = _G["Boss" .. i .. "TargetFrame"]
        if frame then
            -- Apply to health bar background
            local healthBar = _G["Boss" .. i .. "TargetFrameHealthBar"]
            if healthBar and healthBar.background then
                healthBar.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
            
            -- Apply to power bar background
            local powerBar = _G["Boss" .. i .. "TargetFrameManaBar"]
            if powerBar and powerBar.background then
                powerBar.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
            
            -- Apply to frame border if it exists
            if EPF.bossFrameBorders and EPF.bossFrameBorders[i] then
                EPF.bossFrameBorders[i]:SetVertexColor(
                    borderColor.r, 
                    borderColor.g, 
                    borderColor.b, 
                    1.0
                )
            end
        end
    end
end

-- Apply theme to arena frames if enabled
function ThemeIntegration:ApplyThemeToArenaFrames()
    if not EPF.settings.enhanceArenaFrames or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each arena frame
    for i = 1, 5 do
        local frame = _G["ArenaEnemyFrame" .. i]
        if frame then
            -- Apply to health bar background
            local healthBar = _G["ArenaEnemyFrame" .. i .. "HealthBar"]
            if healthBar and healthBar.background then
                healthBar.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
            
            -- Apply to power bar background
            local powerBar = _G["ArenaEnemyFrame" .. i .. "ManaBar"]
            if powerBar and powerBar.background then
                powerBar.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
            
            -- Apply to frame border if it exists
            if EPF.arenaFrameBorders and EPF.arenaFrameBorders[i] then
                EPF.arenaFrameBorders[i]:SetVertexColor(
                    borderColor.r, 
                    borderColor.g, 
                    borderColor.b, 
                    1.0
                )
            end
        end
    end
end

-- Apply theme to player frame enhancements
function ThemeIntegration:ApplyThemeToPlayerEnhancements()
    if not EPF.settings.enhancePlayerFrame or not EPF.settings.useThemeColors then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local accentColor = self:GetColor("accent")
    
    -- Apply theme to enhanced player health/power text
    if EPF.playerHealthText then
        EPF.playerHealthText:SetTextColor(
            accentColor.r, 
            accentColor.g, 
            accentColor.b, 
            1.0
        )
    end
    
    if EPF.playerPowerText then
        EPF.playerPowerText:SetTextColor(
            accentColor.r, 
            accentColor.g, 
            accentColor.b, 
            1.0
        )
    end
    
    -- Apply theme to any other enhanced elements on the player frame
    if EPF.playerEnhancements then
        for _, element in pairs(EPF.playerEnhancements) do
            if element.border then
                element.border:SetVertexColor(
                    borderColor.r, 
                    borderColor.g, 
                    borderColor.b, 
                    1.0
                )
            end
            
            if element.background then
                element.background:SetColorTexture(
                    backgroundColor.r, 
                    backgroundColor.g, 
                    backgroundColor.b, 
                    0.7
                )
            end
        end
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or themeColors.backdrop or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or themeColors.border or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
        accent = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
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