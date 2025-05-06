--[[
    VUI - Actionbars Module
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create a module using the ModuleAPI
local moduleName = "actionbars"
local module = VUI.ModuleAPI:CreateModule(moduleName)

-- Export module to global VUI namespace
VUI.actionbars = module

-- Default settings
local defaults = {
    enabled = true,
    enhancedButtonStyle = true,
    showHotkeys = true,
    showMacroText = false,
    enhancedVisibility = true,
    enhancedLayout = true,
    buttonSize = 36,
    spacing = 4,
    mainBarRows = 1,
    mainBarColumns = 12,
    fadeOutOfCombat = true,
    fadeAlpha = 0.7,
    showGridAlways = false,
    responsiveScaling = true
}

function module:OnInitialize()
    -- Initialize settings with defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings(moduleName, defaults)
    
    -- Set enabled state based on settings
    self:SetEnabledState(self.settings.enabled)
    
    -- Register for events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ACTIONBAR_SHOWGRID")
    self:RegisterEvent("ACTIONBAR_HIDEGRID")
    self:RegisterEvent("UPDATE_BINDINGS")
    
    -- Initialize ThemeIntegration module
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
end

function module:OnEnable()
    -- Initialize the action bars
    self:SetupActionBars()
    
    -- Apply theme
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme()
    end
    
    -- Update visuals
    self:UpdateActionBarVisuals()
end

function module:OnDisable()
    -- Restore default appearances
    self:RestoreDefaultActionBars()
end

function module:PLAYER_ENTERING_WORLD()
    -- Refresh action bars when player enters world
    self:UpdateActionBarLayout()
    self:UpdateActionBarVisuals()
end

function module:ACTIONBAR_SHOWGRID()
    -- Handle action bar grid showing
    self:UpdateGridVisibility(true)
end

function module:ACTIONBAR_HIDEGRID()
    -- Handle action bar grid hiding
    self:UpdateGridVisibility(false)
end

function module:UPDATE_BINDINGS()
    -- Update hotkey texts
    self:UpdateHotkeyText()
end

-- Theme handling is delegated to ThemeIntegration
function module:ApplyTheme(theme)
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme(theme)
    end
end

-- Setup action bars (placeholder - actual implementation in core.lua)
function module:SetupActionBars()
    -- This function will be implemented in core.lua
end

-- Update action bar layout (placeholder - actual implementation in core.lua)
function module:UpdateActionBarLayout()
    -- This function will be implemented in core.lua
end

-- Update action bar visuals (placeholder - actual implementation in core.lua)
function module:UpdateActionBarVisuals()
    -- This function will be implemented in core.lua
end

-- Restore default action bars (placeholder - actual implementation in core.lua)
function module:RestoreDefaultActionBars()
    -- This function will be implemented in core.lua
end

-- Update grid visibility (placeholder - actual implementation in core.lua)
function module:UpdateGridVisibility(showGrid)
    -- This function will be implemented in core.lua
end

-- Update hotkey text (placeholder - actual implementation in core.lua)
function module:UpdateHotkeyText()
    -- This function will be implemented in core.lua
end