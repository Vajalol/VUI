--[[
    VUI - Accessibility Enhancement System
    Author: VortexQ8
    
    This file implements accessibility features for VUI, providing options to make
    the addon more usable for players with various visual and input needs.
    
    Key features:
    1. High contrast mode for improved visibility
    2. UI scaling options for different display resolutions
    3. Colorblind-friendly theme variants
    4. Keyboard navigation enhancements
    5. Audio feedback options
    6. Profile management improvements
]]

local _, VUI = ...
local L = VUI.L

-- Create the Accessibility system
local Accessibility = {}
VUI.Accessibility = Accessibility

-- Default settings
local defaultSettings = {
    -- High Contrast Mode
    highContrastMode = false,
    contrastLevel = 2, -- Medium (1-3: Low, Medium, High)
    contrastBackground = true, -- Apply to backgrounds
    contrastBorders = true, -- Apply to borders
    contrastText = true, -- Apply to text
    contrastIcons = false, -- Apply to icons (can reduce icon readability)
    
    -- UI Scaling
    useCustomScale = false,
    globalScale = 1.0,
    moduleScales = {}, -- Individual module scales
    automaticScaling = false, -- Auto-adjust based on resolution
    
    -- Colorblind Mode
    colorblindMode = false, 
    colorblindType = "protanopia", -- Options: protanopia, deuteranopia, tritanopia
    colorblindIntensity = 0.6, -- 0.0 to 1.0
    useColorblindTexts = true, -- Add text labels to color-coded elements
    colorblindIndicators = true, -- Add symbols/patterns to distinguish colors
    
    -- Keyboard Navigation
    enhancedKeyboardNav = false,
    tabIndexing = true, -- Elements can be tabbed through
    hotkeyVisibility = true, -- Show hotkeys on buttons
    arrowKeysNavigation = true, -- Use arrow keys to navigate UI
    escapeClosesWindows = true, -- ESC key closes windows in reverse opening order
    
    -- Audio Feedback
    audioFeedback = false,
    buttonSounds = true, -- Play sounds on button interaction
    alertSounds = true, -- Play sounds for alerts/warnings
    narrativeTooltips = false, -- Announce tooltip content (requires narration addon)
    
    -- Profile Management
    accessibilityProfiles = {}, -- Store named accessibility profiles
    autoSwitchProfiles = false, -- Auto-switch based on character/spec
}

-- Initialize with default or saved settings
local settings = {}

-- Initialize module
function Accessibility:Initialize()
    -- Load saved settings or initialize with defaults
    if VUI.db and VUI.db.profile.accessibility then
        settings = VUI.db.profile.accessibility
    else
        settings = CopyTable(defaultSettings)
        if VUI.db and VUI.db.profile then
            VUI.db.profile.accessibility = settings
        end
    end
    
    -- Create the module frame
    self.frame = CreateFrame("Frame", "VUIAccessibilityFrame", UIParent)
    
    -- Register events
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    
    -- Set up event handler
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:OnPlayerEnteringWorld()
        elseif event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "VUI" then
                self:OnAddonLoaded()
            end
        elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
            self:OnSpecializationChanged(...)
        end
    end)
    
    -- Initialize high contrast mode
    self:ApplyHighContrastMode()
    
    -- Initialize UI scaling
    self:ApplyUIScaling()
    
    -- Initialize colorblind mode
    self:ApplyColorblindMode()
    
    -- Initialize keyboard navigation
    self:SetupKeyboardNavigation()
    
    -- Initialize audio feedback
    self:SetupAudioFeedback()
    
    -- Register with VUI Config
    self:RegisterConfig()
    
    -- Print initialization message if in debug mode
    if VUI.debug then
        VUI:Print("Accessibility system initialized")
    end
end

-- Apply High Contrast Mode settings
function Accessibility:ApplyHighContrastMode()
    if not settings.highContrastMode then
        self:DisableHighContrastMode()
        return
    end
    
    -- Save current theme for restoration if needed
    if not VUI.savedRegularTheme then
        VUI.savedRegularTheme = VUI.db.profile.theme
    end
    
    -- Get the current theme or default to "thunderstorm"
    local currentTheme = VUI.db.profile.theme or "thunderstorm"
    local themeData = VUI.Theme and VUI.Theme.GetThemeData and VUI.Theme:GetThemeData(currentTheme) or nil
    
    -- Adjust colors based on chosen contrast level
    local contrastMultiplier = 1.0
    if settings.contrastLevel == 1 then -- Low
        contrastMultiplier = 1.2
    elseif settings.contrastLevel == 2 then -- Medium
        contrastMultiplier = 1.5
    elseif settings.contrastLevel == 3 then -- High
        contrastMultiplier = 2.0
    end
    
    -- Apply high contrast to current theme
    if themeData then
        local highContrastTheme = CopyTable(themeData)
        
        -- Process theme colors for high contrast
        if settings.contrastBackground then
            -- Make dark colors darker and light colors lighter
            for key, color in pairs(highContrastTheme.colors.background or {}) do
                if type(color) == "table" and color.r and color.g and color.b then
                    local luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
                    if luminance < 0.5 then
                        -- Darken dark colors
                        color.r = max(0, color.r - 0.1 * contrastMultiplier)
                        color.g = max(0, color.g - 0.1 * contrastMultiplier)
                        color.b = max(0, color.b - 0.1 * contrastMultiplier)
                    else
                        -- Lighten light colors
                        color.r = min(1, color.r + 0.1 * contrastMultiplier)
                        color.g = min(1, color.g + 0.1 * contrastMultiplier)
                        color.b = min(1, color.b + 0.1 * contrastMultiplier)
                    end
                end
            end
        end
        
        if settings.contrastBorders then
            -- Increase contrast of borders
            for key, color in pairs(highContrastTheme.colors.border or {}) do
                if type(color) == "table" and color.r and color.g and color.b then
                    -- Borders often need to stand out more, so boost their intensity
                    local luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
                    if luminance < 0.5 then
                        -- For dark borders, make them a bit lighter to stand out against dark backgrounds
                        color.r = min(1, color.r + 0.15 * contrastMultiplier)
                        color.g = min(1, color.g + 0.15 * contrastMultiplier)
                        color.b = min(1, color.b + 0.15 * contrastMultiplier)
                    else
                        -- For light borders, make them more intense
                        color.r = min(1, color.r + 0.1 * contrastMultiplier)
                        color.g = min(1, color.g + 0.1 * contrastMultiplier)
                        color.b = min(1, color.b + 0.1 * contrastMultiplier)
                    end
                end
            end
        end
        
        -- Store the high contrast version
        VUI.highContrastTheme = highContrastTheme
        
        -- Apply the high contrast theme immediately if theme system is loaded
        if VUI.Theme and VUI.Theme.ApplyTheme then
            VUI.Theme:ApplyTheme("highcontrast", true) -- true for silent application
        end
    end
    
    -- Apply high contrast to fonts if enabled
    if settings.contrastText and VUI.FontSystem then
        -- Increase font boldness and contrast
        VUI.FontSystem:SetHighContrastMode(true, contrastMultiplier)
    end
    
    -- Apply high contrast to icons if enabled
    if settings.contrastIcons then
        self:ApplyHighContrastIcons(contrastMultiplier)
    end
    
    -- Notify modules about high contrast mode
    VUI:CallModuleFunction("OnHighContrastModeChanged", settings.highContrastMode, settings.contrastLevel)
end

-- Disable High Contrast Mode
function Accessibility:DisableHighContrastMode()
    -- Restore original theme if saved
    if VUI.savedRegularTheme and VUI.Theme and VUI.Theme.ApplyTheme then
        VUI.Theme:ApplyTheme(VUI.savedRegularTheme, true) -- true for silent application
        VUI.savedRegularTheme = nil
        VUI.highContrastTheme = nil
    end
    
    -- Reset font settings
    if VUI.FontSystem then
        VUI.FontSystem:SetHighContrastMode(false)
    end
    
    -- Reset icon contrast
    self:ApplyHighContrastIcons(0) -- 0 means disable
    
    -- Notify modules about high contrast mode disabled
    VUI:CallModuleFunction("OnHighContrastModeChanged", false, 0)
end

-- Apply high contrast to icons
function Accessibility:ApplyHighContrastIcons(contrastMultiplier)
    -- If there's a TextureManager or similar, we would call it here
    if VUI.TextureManager then
        VUI.TextureManager:SetHighContrastMode(contrastMultiplier > 0, contrastMultiplier)
    end
    
    -- For the texture atlas system
    if VUI.Atlas then
        VUI.Atlas:SetHighContrastMode(contrastMultiplier > 0, contrastMultiplier)
    end
    
    -- We might need to process icons in each module
    if contrastMultiplier > 0 then
        -- Apply high contrast to icons
        VUI:CallModuleFunction("ApplyHighContrastIcons", contrastMultiplier)
    else
        -- Remove high contrast from icons
        VUI:CallModuleFunction("ResetIconContrast")
    end
end

-- Apply UI Scaling settings
function Accessibility:ApplyUIScaling()
    if not settings.useCustomScale then
        self:ResetUIScaling()
        return
    end
    
    -- Apply global scaling if needed
    if settings.globalScale ~= 1.0 then
        -- Store the original scale for restoration
        if not VUI.originalUIScale then
            VUI.originalUIScale = UIParent:GetScale()
        end
        
        -- Apply new scale
        UIParent:SetScale(settings.globalScale)
    end
    
    -- Apply individual module scaling
    for moduleName, scale in pairs(settings.moduleScales) do
        local module = VUI:GetModule(moduleName)
        if module and module.frame then
            if not module.originalScale then
                module.originalScale = module.frame:GetScale()
            end
            module.frame:SetScale(scale)
        end
    end
    
    -- If automatic scaling is enabled, calculate based on resolution
    if settings.automaticScaling then
        self:CalculateAutomaticScaling()
    end
    
    -- Notify modules about UI scaling
    VUI:CallModuleFunction("OnUIScalingChanged", settings.useCustomScale, settings.globalScale)
end

-- Reset UI Scaling to defaults
function Accessibility:ResetUIScaling()
    -- Restore original UI scale if saved
    if VUI.originalUIScale then
        UIParent:SetScale(VUI.originalUIScale)
        VUI.originalUIScale = nil
    end
    
    -- Restore original module scales
    for moduleName, _ in pairs(settings.moduleScales) do
        local module = VUI:GetModule(moduleName)
        if module and module.frame and module.originalScale then
            module.frame:SetScale(module.originalScale)
            module.originalScale = nil
        end
    end
    
    -- Notify modules about UI scaling reset
    VUI:CallModuleFunction("OnUIScalingChanged", false, 1.0)
end

-- Calculate automatic scaling based on resolution
function Accessibility:CalculateAutomaticScaling()
    -- Get screen resolution
    local screenWidth, screenHeight = GetPhysicalScreenSize()
    
    -- Base calculation on resolution thresholds
    local scale = 1.0
    
    if screenWidth >= 3840 then -- 4K and higher
        scale = 1.5
    elseif screenWidth >= 2560 then -- 1440p and higher
        scale = 1.25
    elseif screenWidth >= 1920 then -- 1080p and higher
        scale = 1.0
    elseif screenWidth >= 1366 then -- 768p and higher
        scale = 0.9
    else -- Lower resolutions
        scale = 0.8
    end
    
    -- Apply calculated scale
    settings.globalScale = scale
    
    -- Apply new scale
    if not VUI.originalUIScale then
        VUI.originalUIScale = UIParent:GetScale()
    end
    
    UIParent:SetScale(scale)
    
    -- Notify modules about automatic scaling
    VUI:CallModuleFunction("OnUIScalingChanged", true, scale)
end

-- Apply Colorblind Mode settings
function Accessibility:ApplyColorblindMode()
    if not settings.colorblindMode then
        self:DisableColorblindMode()
        return
    end
    
    -- Create or update colorblind theme based on selected type
    self:CreateColorblindTheme(settings.colorblindType, settings.colorblindIntensity)
    
    -- Apply colorblind-friendly textures if possible
    if VUI.TextureManager then
        VUI.TextureManager:SetColorblindMode(true, settings.colorblindType)
    end
    
    -- Apply text labels to color-based UI elements if enabled
    if settings.useColorblindTexts then
        self:ApplyColorblindTextLabels(true)
    end
    
    -- Apply colorblind indicators (patterns, symbols) if enabled
    if settings.colorblindIndicators then
        self:ApplyColorblindIndicators(true)
    end
    
    -- Notify modules about colorblind mode
    VUI:CallModuleFunction("OnColorblindModeChanged", true, settings.colorblindType, settings.colorblindIntensity)
end

-- Disable Colorblind Mode
function Accessibility:DisableColorblindMode()
    -- Restore original theme
    if VUI.savedRegularTheme and VUI.Theme and VUI.Theme.ApplyTheme then
        VUI.Theme:ApplyTheme(VUI.savedRegularTheme, true)
        VUI.savedRegularTheme = nil
    end
    
    -- Remove colorblind-friendly textures
    if VUI.TextureManager then
        VUI.TextureManager:SetColorblindMode(false)
    end
    
    -- Remove text labels from color-based UI elements
    self:ApplyColorblindTextLabels(false)
    
    -- Remove colorblind indicators
    self:ApplyColorblindIndicators(false)
    
    -- Notify modules about colorblind mode disabled
    VUI:CallModuleFunction("OnColorblindModeChanged", false)
end

-- Create colorblind theme based on type and intensity
function Accessibility:CreateColorblindTheme(colorblindType, intensity)
    -- Save current theme for restoration if needed
    if not VUI.savedRegularTheme then
        VUI.savedRegularTheme = VUI.db.profile.theme
    end
    
    -- Get the current theme or default to "thunderstorm"
    local currentTheme = VUI.db.profile.theme or "thunderstorm"
    local themeData = VUI.Theme and VUI.Theme.GetThemeData and VUI.Theme:GetThemeData(currentTheme) or nil
    
    -- Process colors for the selected colorblind type
    if themeData then
        local colorblindTheme = CopyTable(themeData)
        colorblindTheme.name = "colorblind_" .. colorblindType
        
        -- Process theme colors for colorblind mode
        for category, colors in pairs(colorblindTheme.colors) do
            for key, color in pairs(colors) do
                if type(color) == "table" and color.r and color.g and color.b then
                    -- Apply colorblind transformation
                    local newColor = self:TransformColorForColorblindness(color, colorblindType, intensity)
                    color.r, color.g, color.b = newColor.r, newColor.g, newColor.b
                end
            end
        end
        
        -- Store the colorblind version
        VUI.colorblindTheme = colorblindTheme
        
        -- Apply the colorblind theme immediately if theme system is loaded
        if VUI.Theme and VUI.Theme.ApplyTheme then
            VUI.Theme:ApplyTheme("colorblind_" .. colorblindType, true)
        end
    end
end

-- Transform a color for various types of colorblindness
function Accessibility:TransformColorForColorblindness(color, colorblindType, intensity)
    local r, g, b = color.r, color.g, color.b
    local newR, newG, newB = r, g, b
    
    -- Basic simulation of colorblindness
    if colorblindType == "protanopia" then
        -- Red-blind: reduce red component, enhance blue and green
        newR = r * (1 - intensity) + (0.567 * g + 0.433 * b) * intensity
        newG = g * (1 - intensity) + (0.558 * g + 0.442 * b) * intensity
        newB = b * (1 - intensity) + (0.242 * g + 0.758 * b) * intensity
    elseif colorblindType == "deuteranopia" then
        -- Green-blind: reduce green component, enhance red and blue
        newR = r * (1 - intensity) + (0.625 * r + 0.375 * b) * intensity
        newG = g * (1 - intensity) + (0.7 * r + 0.3 * b) * intensity
        newB = b * (1 - intensity) + (0.3 * r + 0.7 * b) * intensity
    elseif colorblindType == "tritanopia" then
        -- Blue-blind: reduce blue component, enhance red and green
        newR = r * (1 - intensity) + (0.95 * r + 0.05 * g) * intensity
        newG = g * (1 - intensity) + (0.433 * r + 0.567 * g) * intensity
        newB = b * (1 - intensity) + (0.475 * r + 0.525 * g) * intensity
    end
    
    -- Ensure values are within valid range
    newR = max(0, min(1, newR))
    newG = max(0, min(1, newG))
    newB = max(0, min(1, newB))
    
    -- Return transformed color
    return {r = newR, g = newG, b = newB}
end

-- Apply text labels to color-coded UI elements
function Accessibility:ApplyColorblindTextLabels(enabled)
    -- Call modules to add/remove text labels
    VUI:CallModuleFunction("ApplyColorblindTextLabels", enabled)
end

-- Apply colorblind indicators (patterns, symbols)
function Accessibility:ApplyColorblindIndicators(enabled)
    -- Call modules to add/remove indicator patterns
    VUI:CallModuleFunction("ApplyColorblindIndicators", enabled)
end

-- Setup keyboard navigation enhancements
function Accessibility:SetupKeyboardNavigation()
    if not settings.enhancedKeyboardNav then
        self:DisableKeyboardNavigation()
        return
    end
    
    -- Setup tab indexing
    if settings.tabIndexing then
        self:SetupTabIndexing()
    end
    
    -- Show hotkeys on buttons
    if settings.hotkeyVisibility then
        self:EnhanceHotkeyVisibility()
    end
    
    -- Setup arrow key navigation
    if settings.arrowKeysNavigation then
        self:SetupArrowKeyNavigation()
    end
    
    -- Setup ESC key to close windows
    if settings.escapeClosesWindows then
        self:SetupEscapeKeyClosing()
    end
    
    -- Notify modules about keyboard navigation
    VUI:CallModuleFunction("OnKeyboardNavigationChanged", true)
end

-- Disable keyboard navigation enhancements
function Accessibility:DisableKeyboardNavigation()
    -- Reset tab indexing
    self:ResetTabIndexing()
    
    -- Reset hotkey visibility
    self:ResetHotkeyVisibility()
    
    -- Reset arrow key navigation
    self:ResetArrowKeyNavigation()
    
    -- Reset ESC key window closing
    self:ResetEscapeKeyClosing()
    
    -- Notify modules about keyboard navigation disabled
    VUI:CallModuleFunction("OnKeyboardNavigationChanged", false)
end

-- Setup tab indexing for UI elements
function Accessibility:SetupTabIndexing()
    -- TBA: Setup tab indexing for VUI UI elements
    -- Requires coordination with all modules
    
    -- For now, we notify modules to implement their own tab indexing
    VUI:CallModuleFunction("SetupTabIndexing")
end

-- Reset tab indexing to defaults
function Accessibility:ResetTabIndexing()
    -- TBA: Reset tab indexing for VUI UI elements
    
    -- For now, we notify modules to reset their tab indexing
    VUI:CallModuleFunction("ResetTabIndexing")
end

-- Enhance hotkey visibility on buttons
function Accessibility:EnhanceHotkeyVisibility()
    -- TBA: Enhance hotkey visibility on buttons
    -- For now, we notify modules to enhance their hotkey visibility
    VUI:CallModuleFunction("EnhanceHotkeyVisibility")
end

-- Reset hotkey visibility to defaults
function Accessibility:ResetHotkeyVisibility()
    -- TBA: Reset hotkey visibility on buttons
    -- For now, we notify modules to reset their hotkey visibility
    VUI:CallModuleFunction("ResetHotkeyVisibility")
end

-- Setup arrow key navigation
function Accessibility:SetupArrowKeyNavigation()
    -- TBA: Setup arrow key navigation
    -- For now, we notify modules to implement their own arrow key navigation
    VUI:CallModuleFunction("SetupArrowKeyNavigation")
end

-- Reset arrow key navigation to defaults
function Accessibility:ResetArrowKeyNavigation()
    -- TBA: Reset arrow key navigation
    -- For now, we notify modules to reset their arrow key navigation
    VUI:CallModuleFunction("ResetArrowKeyNavigation")
end

-- Setup ESC key to close windows
function Accessibility:SetupEscapeKeyClosing()
    -- TBA: Setup ESC key to close windows
    -- For now, we notify modules to implement their own ESC key handling
    VUI:CallModuleFunction("SetupEscapeKeyClosing")
end

-- Reset ESC key window closing to defaults
function Accessibility:ResetEscapeKeyClosing()
    -- TBA: Reset ESC key window closing
    -- For now, we notify modules to reset their ESC key handling
    VUI:CallModuleFunction("ResetEscapeKeyClosing")
end

-- Setup audio feedback
function Accessibility:SetupAudioFeedback()
    if not settings.audioFeedback then
        self:DisableAudioFeedback()
        return
    end
    
    -- Setup button sounds
    if settings.buttonSounds then
        self:EnableButtonSounds()
    end
    
    -- Setup alert sounds
    if settings.alertSounds then
        self:EnableAlertSounds()
    end
    
    -- Setup narrative tooltips
    if settings.narrativeTooltips then
        self:EnableNarrativeTooltips()
    end
    
    -- Notify modules about audio feedback
    VUI:CallModuleFunction("OnAudioFeedbackChanged", true)
end

-- Disable audio feedback
function Accessibility:DisableAudioFeedback()
    -- Reset button sounds
    self:DisableButtonSounds()
    
    -- Reset alert sounds
    self:DisableAlertSounds()
    
    -- Reset narrative tooltips
    self:DisableNarrativeTooltips()
    
    -- Notify modules about audio feedback disabled
    VUI:CallModuleFunction("OnAudioFeedbackChanged", false)
end

-- Enable sounds on button interactions
function Accessibility:EnableButtonSounds()
    -- TBA: Enable sounds on button interactions
    -- For now, we notify modules to enable their button sounds
    VUI:CallModuleFunction("EnableButtonSounds")
end

-- Disable sounds on button interactions
function Accessibility:DisableButtonSounds()
    -- TBA: Disable sounds on button interactions
    -- For now, we notify modules to disable their button sounds
    VUI:CallModuleFunction("DisableButtonSounds")
end

-- Enable alert sounds
function Accessibility:EnableAlertSounds()
    -- TBA: Enable alert sounds
    -- For now, we notify modules to enable their alert sounds
    VUI:CallModuleFunction("EnableAlertSounds")
end

-- Disable alert sounds
function Accessibility:DisableAlertSounds()
    -- TBA: Disable alert sounds
    -- For now, we notify modules to disable their alert sounds
    VUI:CallModuleFunction("DisableAlertSounds")
end

-- Enable narrative tooltips
function Accessibility:EnableNarrativeTooltips()
    -- TBA: Enable narrative tooltips
    -- For now, we notify modules to enable their narrative tooltips
    VUI:CallModuleFunction("EnableNarrativeTooltips")
end

-- Disable narrative tooltips
function Accessibility:DisableNarrativeTooltips()
    -- TBA: Disable narrative tooltips
    -- For now, we notify modules to disable their narrative tooltips
    VUI:CallModuleFunction("DisableNarrativeTooltips")
end

-- Load a named accessibility profile
function Accessibility:LoadProfile(profileName)
    if not profileName or not settings.accessibilityProfiles[profileName] then
        return false
    end
    
    -- Load the selected profile
    local profile = settings.accessibilityProfiles[profileName]
    
    -- Apply settings from the profile
    for key, value in pairs(profile) do
        if key ~= "name" and key ~= "description" then
            settings[key] = value
        end
    end
    
    -- Save settings to database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.accessibility = settings
    end
    
    -- Apply all settings
    self:ApplyAllSettings()
    
    -- Notify modules about profile change
    VUI:CallModuleFunction("OnAccessibilityProfileChanged", profileName)
    
    return true
end

-- Save current settings as a named profile
function Accessibility:SaveProfile(profileName, description)
    if not profileName then
        return false
    end
    
    -- Create profile from current settings
    local profile = CopyTable(settings)
    
    -- Add metadata
    profile.name = profileName
    profile.description = description or ""
    
    -- Remove the accessibilityProfiles table to avoid recursion
    profile.accessibilityProfiles = nil
    
    -- Store the profile
    settings.accessibilityProfiles[profileName] = profile
    
    -- Save to database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.accessibility = settings
    end
    
    return true
end

-- Delete a named profile
function Accessibility:DeleteProfile(profileName)
    if not profileName or not settings.accessibilityProfiles[profileName] then
        return false
    end
    
    -- Remove the profile
    settings.accessibilityProfiles[profileName] = nil
    
    -- Save to database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.accessibility = settings
    end
    
    return true
end

-- Apply all settings (useful when loading profiles)
function Accessibility:ApplyAllSettings()
    -- Apply each feature based on current settings
    self:ApplyHighContrastMode()
    self:ApplyUIScaling()
    self:ApplyColorblindMode()
    self:SetupKeyboardNavigation()
    self:SetupAudioFeedback()
    
    -- Notify modules about comprehensive settings change
    VUI:CallModuleFunction("OnAccessibilitySettingsChanged", settings)
end

-- Event Handlers

-- Handle player entering world
function Accessibility:OnPlayerEnteringWorld()
    -- Apply automatic profile switching if enabled
    if settings.autoSwitchProfiles then
        self:AutoSwitchProfile()
    end
    
    -- Apply all settings
    self:ApplyAllSettings()
end

-- Handle addon loaded
function Accessibility:OnAddonLoaded()
    -- Initialize all settings
    self:ApplyAllSettings()
end

-- Handle specialization changed
function Accessibility:OnSpecializationChanged(unit)
    if unit ~= "player" then return end
    
    -- Apply automatic profile switching if enabled
    if settings.autoSwitchProfiles then
        self:AutoSwitchProfile()
    end
end

-- Automatically switch profile based on character/spec
function Accessibility:AutoSwitchProfile()
    local _, className = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID = specIndex and GetSpecializationInfo(specIndex)
    local characterKey = UnitName("player") .. "-" .. (GetRealmName() or "")
    
    -- Look for a profile match
    for profileName, profile in pairs(settings.accessibilityProfiles) do
        if profile.autoSwitchData then
            local data = profile.autoSwitchData
            
            -- Check for match
            if (data.character and data.character == characterKey) or
               (data.class and data.class == className) or
               (data.spec and data.spec == specID) then
                -- Load this profile
                self:LoadProfile(profileName)
                break
            end
        end
    end
end

-- Config panel integration
function Accessibility:RegisterConfig()
    -- Register with VUI Config system
    if VUI.Config then
        VUI.Config:RegisterModule("Accessibility", self:GetConfigOptions())
    end
end

-- Get config options for the settings panel
function Accessibility:GetConfigOptions()
    local options = {
        name = "Accessibility",
        type = "group",
        args = {
            highContrastSection = {
                order = 1,
                type = "group",
                name = "High Contrast Mode",
                inline = true,
                args = {
                    highContrastMode = {
                        order = 1,
                        type = "toggle",
                        name = "Enable High Contrast Mode",
                        desc = "Increases the contrast of UI elements for better visibility",
                        get = function() return settings.highContrastMode end,
                        set = function(_, value) 
                            settings.highContrastMode = value
                            VUI.db.profile.accessibility.highContrastMode = value
                            self:ApplyHighContrastMode()
                        end,
                        width = "full",
                    },
                    contrastLevel = {
                        order = 2,
                        type = "range",
                        name = "Contrast Level",
                        desc = "Adjust the level of contrast enhancement",
                        min = 1,
                        max = 3,
                        step = 1,
                        get = function() return settings.contrastLevel end,
                        set = function(_, value) 
                            settings.contrastLevel = value
                            VUI.db.profile.accessibility.contrastLevel = value
                            self:ApplyHighContrastMode()
                        end,
                        width = "full",
                        disabled = function() return not settings.highContrastMode end,
                    },
                    contrastBackground = {
                        order = 3,
                        type = "toggle",
                        name = "Enhance Background Contrast",
                        desc = "Apply contrast enhancement to background elements",
                        get = function() return settings.contrastBackground end,
                        set = function(_, value) 
                            settings.contrastBackground = value
                            VUI.db.profile.accessibility.contrastBackground = value
                            self:ApplyHighContrastMode()
                        end,
                        width = "normal",
                        disabled = function() return not settings.highContrastMode end,
                    },
                    contrastBorders = {
                        order = 4,
                        type = "toggle",
                        name = "Enhance Border Contrast",
                        desc = "Apply contrast enhancement to borders and edges",
                        get = function() return settings.contrastBorders end,
                        set = function(_, value) 
                            settings.contrastBorders = value
                            VUI.db.profile.accessibility.contrastBorders = value
                            self:ApplyHighContrastMode()
                        end,
                        width = "normal",
                        disabled = function() return not settings.highContrastMode end,
                    },
                    contrastText = {
                        order = 5,
                        type = "toggle",
                        name = "Enhance Text Contrast",
                        desc = "Apply contrast enhancement to text elements",
                        get = function() return settings.contrastText end,
                        set = function(_, value) 
                            settings.contrastText = value
                            VUI.db.profile.accessibility.contrastText = value
                            self:ApplyHighContrastMode()
                        end,
                        width = "normal",
                        disabled = function() return not settings.highContrastMode end,
                    },
                    contrastIcons = {
                        order = 6,
                        type = "toggle",
                        name = "Enhance Icon Contrast",
                        desc = "Apply contrast enhancement to icons (may reduce icon readability)",
                        get = function() return settings.contrastIcons end,
                        set = function(_, value) 
                            settings.contrastIcons = value
                            VUI.db.profile.accessibility.contrastIcons = value
                            self:ApplyHighContrastMode()
                        end,
                        width = "normal",
                        disabled = function() return not settings.highContrastMode end,
                    },
                },
            },
            
            uiScalingSection = {
                order = 2,
                type = "group",
                name = "UI Scaling",
                inline = true,
                args = {
                    useCustomScale = {
                        order = 1,
                        type = "toggle",
                        name = "Enable Custom UI Scaling",
                        desc = "Use custom scaling for UI elements",
                        get = function() return settings.useCustomScale end,
                        set = function(_, value) 
                            settings.useCustomScale = value
                            VUI.db.profile.accessibility.useCustomScale = value
                            self:ApplyUIScaling()
                        end,
                        width = "full",
                    },
                    globalScale = {
                        order = 2,
                        type = "range",
                        name = "Global UI Scale",
                        desc = "Adjust the overall scale of the UI",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.globalScale end,
                        set = function(_, value) 
                            settings.globalScale = value
                            VUI.db.profile.accessibility.globalScale = value
                            self:ApplyUIScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.useCustomScale end,
                    },
                    automaticScaling = {
                        order = 3,
                        type = "toggle",
                        name = "Automatic Resolution Scaling",
                        desc = "Automatically adjust UI scale based on screen resolution",
                        get = function() return settings.automaticScaling end,
                        set = function(_, value) 
                            settings.automaticScaling = value
                            VUI.db.profile.accessibility.automaticScaling = value
                            if value then
                                self:CalculateAutomaticScaling()
                            end
                            self:ApplyUIScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.useCustomScale end,
                    },
                    -- Module-specific scaling would be added dynamically
                },
            },
            
            colorblindSection = {
                order = 3,
                type = "group",
                name = "Colorblind Mode",
                inline = true,
                args = {
                    colorblindMode = {
                        order = 1,
                        type = "toggle",
                        name = "Enable Colorblind Mode",
                        desc = "Apply colorblind-friendly adjustments to the UI",
                        get = function() return settings.colorblindMode end,
                        set = function(_, value) 
                            settings.colorblindMode = value
                            VUI.db.profile.accessibility.colorblindMode = value
                            self:ApplyColorblindMode()
                        end,
                        width = "full",
                    },
                    colorblindType = {
                        order = 2,
                        type = "select",
                        name = "Colorblind Type",
                        desc = "Select the type of colorblindness to optimize for",
                        values = {
                            ["protanopia"] = "Protanopia (Red-Blind)",
                            ["deuteranopia"] = "Deuteranopia (Green-Blind)",
                            ["tritanopia"] = "Tritanopia (Blue-Blind)"
                        },
                        get = function() return settings.colorblindType end,
                        set = function(_, value) 
                            settings.colorblindType = value
                            VUI.db.profile.accessibility.colorblindType = value
                            self:ApplyColorblindMode()
                        end,
                        width = "full",
                        disabled = function() return not settings.colorblindMode end,
                    },
                    colorblindIntensity = {
                        order = 3,
                        type = "range",
                        name = "Colorblind Intensity",
                        desc = "Adjust the intensity of the colorblind adjustments",
                        min = 0.0,
                        max = 1.0,
                        step = 0.1,
                        get = function() return settings.colorblindIntensity end,
                        set = function(_, value) 
                            settings.colorblindIntensity = value
                            VUI.db.profile.accessibility.colorblindIntensity = value
                            self:ApplyColorblindMode()
                        end,
                        width = "full",
                        disabled = function() return not settings.colorblindMode end,
                    },
                    useColorblindTexts = {
                        order = 4,
                        type = "toggle",
                        name = "Add Text Labels",
                        desc = "Add text labels to color-coded elements",
                        get = function() return settings.useColorblindTexts end,
                        set = function(_, value) 
                            settings.useColorblindTexts = value
                            VUI.db.profile.accessibility.useColorblindTexts = value
                            self:ApplyColorblindTextLabels(value)
                        end,
                        width = "full",
                        disabled = function() return not settings.colorblindMode end,
                    },
                    colorblindIndicators = {
                        order = 5,
                        type = "toggle",
                        name = "Add Patterns/Symbols",
                        desc = "Add patterns or symbols to distinguish colors",
                        get = function() return settings.colorblindIndicators end,
                        set = function(_, value) 
                            settings.colorblindIndicators = value
                            VUI.db.profile.accessibility.colorblindIndicators = value
                            self:ApplyColorblindIndicators(value)
                        end,
                        width = "full",
                        disabled = function() return not settings.colorblindMode end,
                    },
                },
            },
            
            keyboardNavSection = {
                order = 4,
                type = "group",
                name = "Keyboard Navigation",
                inline = true,
                args = {
                    enhancedKeyboardNav = {
                        order = 1,
                        type = "toggle",
                        name = "Enhanced Keyboard Navigation",
                        desc = "Improve keyboard navigation throughout the UI",
                        get = function() return settings.enhancedKeyboardNav end,
                        set = function(_, value) 
                            settings.enhancedKeyboardNav = value
                            VUI.db.profile.accessibility.enhancedKeyboardNav = value
                            self:SetupKeyboardNavigation()
                        end,
                        width = "full",
                    },
                    tabIndexing = {
                        order = 2,
                        type = "toggle",
                        name = "Tab Indexing",
                        desc = "Allow tabbing through UI elements",
                        get = function() return settings.tabIndexing end,
                        set = function(_, value) 
                            settings.tabIndexing = value
                            VUI.db.profile.accessibility.tabIndexing = value
                            self:SetupTabIndexing()
                        end,
                        width = "normal",
                        disabled = function() return not settings.enhancedKeyboardNav end,
                    },
                    hotkeyVisibility = {
                        order = 3,
                        type = "toggle",
                        name = "Show Hotkeys",
                        desc = "Show hotkeys on buttons and elements",
                        get = function() return settings.hotkeyVisibility end,
                        set = function(_, value) 
                            settings.hotkeyVisibility = value
                            VUI.db.profile.accessibility.hotkeyVisibility = value
                            self:EnhanceHotkeyVisibility()
                        end,
                        width = "normal",
                        disabled = function() return not settings.enhancedKeyboardNav end,
                    },
                    arrowKeysNavigation = {
                        order = 4,
                        type = "toggle",
                        name = "Arrow Key Navigation",
                        desc = "Use arrow keys to navigate between UI elements",
                        get = function() return settings.arrowKeysNavigation end,
                        set = function(_, value) 
                            settings.arrowKeysNavigation = value
                            VUI.db.profile.accessibility.arrowKeysNavigation = value
                            self:SetupArrowKeyNavigation()
                        end,
                        width = "normal",
                        disabled = function() return not settings.enhancedKeyboardNav end,
                    },
                    escapeClosesWindows = {
                        order = 5,
                        type = "toggle",
                        name = "ESC Key Window Closing",
                        desc = "Use ESC key to close windows in reverse opening order",
                        get = function() return settings.escapeClosesWindows end,
                        set = function(_, value) 
                            settings.escapeClosesWindows = value
                            VUI.db.profile.accessibility.escapeClosesWindows = value
                            self:SetupEscapeKeyClosing()
                        end,
                        width = "normal",
                        disabled = function() return not settings.enhancedKeyboardNav end,
                    },
                },
            },
            
            audioFeedbackSection = {
                order = 5,
                type = "group",
                name = "Audio Feedback",
                inline = true,
                args = {
                    audioFeedback = {
                        order = 1,
                        type = "toggle",
                        name = "Enable Audio Feedback",
                        desc = "Add audio cues and feedback to UI interactions",
                        get = function() return settings.audioFeedback end,
                        set = function(_, value) 
                            settings.audioFeedback = value
                            VUI.db.profile.accessibility.audioFeedback = value
                            self:SetupAudioFeedback()
                        end,
                        width = "full",
                    },
                    buttonSounds = {
                        order = 2,
                        type = "toggle",
                        name = "Button Sounds",
                        desc = "Play sounds when interacting with buttons",
                        get = function() return settings.buttonSounds end,
                        set = function(_, value) 
                            settings.buttonSounds = value
                            VUI.db.profile.accessibility.buttonSounds = value
                            if value then
                                self:EnableButtonSounds()
                            else
                                self:DisableButtonSounds()
                            end
                        end,
                        width = "normal",
                        disabled = function() return not settings.audioFeedback end,
                    },
                    alertSounds = {
                        order = 3,
                        type = "toggle",
                        name = "Alert Sounds",
                        desc = "Play sounds for alerts and warnings",
                        get = function() return settings.alertSounds end,
                        set = function(_, value) 
                            settings.alertSounds = value
                            VUI.db.profile.accessibility.alertSounds = value
                            if value then
                                self:EnableAlertSounds()
                            else
                                self:DisableAlertSounds()
                            end
                        end,
                        width = "normal",
                        disabled = function() return not settings.audioFeedback end,
                    },
                    narrativeTooltips = {
                        order = 4,
                        type = "toggle",
                        name = "Narrative Tooltips",
                        desc = "Announce tooltip content (requires narration addon)",
                        get = function() return settings.narrativeTooltips end,
                        set = function(_, value) 
                            settings.narrativeTooltips = value
                            VUI.db.profile.accessibility.narrativeTooltips = value
                            if value then
                                self:EnableNarrativeTooltips()
                            else
                                self:DisableNarrativeTooltips()
                            end
                        end,
                        width = "normal",
                        disabled = function() return not settings.audioFeedback end,
                    },
                },
            },
            
            profileSection = {
                order = 6,
                type = "group",
                name = "Accessibility Profiles",
                inline = true,
                args = {
                    profileSelector = {
                        order = 1,
                        type = "select",
                        name = "Load Profile",
                        desc = "Load a saved accessibility profile",
                        values = function()
                            local profiles = {}
                            for name, _ in pairs(settings.accessibilityProfiles) do
                                profiles[name] = name
                            end
                            return profiles
                        end,
                        get = function() return "" end, -- No default selection
                        set = function(_, value) 
                            if value ~= "" then
                                self:LoadProfile(value)
                            end
                        end,
                        width = "full",
                    },
                    profileName = {
                        order = 2,
                        type = "input",
                        name = "New Profile Name",
                        desc = "Enter a name for a new profile",
                        get = function() return "" end,
                        set = function(_, value) 
                            profileNameTemp = value
                        end,
                        width = "full",
                    },
                    profileDescription = {
                        order = 3,
                        type = "input",
                        name = "Profile Description",
                        desc = "Enter a description for the new profile",
                        get = function() return "" end,
                        set = function(_, value) 
                            profileDescTemp = value
                        end,
                        width = "full",
                    },
                    saveProfile = {
                        order = 4,
                        type = "execute",
                        name = "Save Current Settings as Profile",
                        desc = "Save all current accessibility settings as a named profile",
                        func = function()
                            if profileNameTemp and profileNameTemp ~= "" then
                                self:SaveProfile(profileNameTemp, profileDescTemp)
                                profileNameTemp = ""
                                profileDescTemp = ""
                            end
                        end,
                        width = "normal",
                    },
                    deleteProfile = {
                        order = 5,
                        type = "execute",
                        name = "Delete Selected Profile",
                        desc = "Delete the selected accessibility profile",
                        func = function()
                            if profileNameTemp and profileNameTemp ~= "" then
                                self:DeleteProfile(profileNameTemp)
                                profileNameTemp = ""
                            end
                        end,
                        width = "normal",
                    },
                    autoSwitchProfiles = {
                        order = 6,
                        type = "toggle",
                        name = "Auto-Switch Profiles",
                        desc = "Automatically switch profiles based on character/spec",
                        get = function() return settings.autoSwitchProfiles end,
                        set = function(_, value) 
                            settings.autoSwitchProfiles = value
                            VUI.db.profile.accessibility.autoSwitchProfiles = value
                            if value then
                                self:AutoSwitchProfile()
                            end
                        end,
                        width = "full",
                    },
                },
            },
        }
    }
    
    return options
end

-- Module export for VUI
VUI.Accessibility = Accessibility

-- Initialize on VUI ready
if VUI.isInitialized then
    Accessibility:Initialize()
else
    -- Instead of using RegisterScript, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize module after VUI is initialized
        if Accessibility.Initialize then
            Accessibility:Initialize()
        end
    end
end