-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create Settings namespace
VUIGfinder.Settings = {}
local Settings = VUIGfinder.Settings

-- Default settings
Settings.defaults = {
    profile = {
        -- General settings
        enabled = true,
        dialogScale = 1.0,
        debugMode = false,
        
        -- Feature settings
        enhancedTooltips = true,
        oneClickSignUp = true,
        rememberSignUpNotes = true,
        signUpOnEnter = true,
        showFilterButton = true,
        
        -- Advanced filter settings
        enableAdvancedMode = false,
        defaultFilterExpression = "",
        enableCustomSorting = false,
        defaultSortingExpression = "",
        
        -- Last used filters (saved for convenience)
        lastRaidFilters = {},
        lastDungeonFilters = {},
        lastPvPFilters = {},
        
        -- UI settings
        lastDialogPosition = {},
        
        -- Saved notes
        signUpNotes = "",
    }
}

-- Initialize settings
function Settings:Initialize()
    -- Register default settings
    VUIGfinder.db = VUI.db:RegisterNamespace("VUIGfinder", self.defaults)
    
    -- Apply initial settings
    self:ApplySettings()
    
    -- Set labels for UI
    if VUIGfinderSettingsPanelGeneralSettingsEnable then
        VUIGfinderSettingsPanelGeneralSettingsEnable.Text:SetText(L["Enable"])
    end
    
    if VUIGfinderSettingsPanelFeatureSettingsEnhancedTooltips then
        VUIGfinderSettingsPanelFeatureSettingsEnhancedTooltips.Text:SetText(L["Enhanced Tooltips"])
    end
    
    if VUIGfinderSettingsPanelFeatureSettingsOneClickSignUp then
        VUIGfinderSettingsPanelFeatureSettingsOneClickSignUp.Text:SetText(L["One-Click Sign Up"])
    end
    
    if VUIGfinderSettingsPanelFeatureSettingsRememberSignUpNotes then
        VUIGfinderSettingsPanelFeatureSettingsRememberSignUpNotes.Text:SetText(L["Remember Sign Up Notes"])
    end
    
    if VUIGfinderSettingsPanelFeatureSettingsSignUpOnEnter then
        VUIGfinderSettingsPanelFeatureSettingsSignUpOnEnter.Text:SetText(L["Sign Up on Enter"])
    end
    
    if VUIGfinderSettingsPanelFeatureSettingsShowFilterButton then
        VUIGfinderSettingsPanelFeatureSettingsShowFilterButton.Text:SetText(L["Show Filter Button"])
    end
end

-- Apply settings to UI components
function Settings:ApplySettings()
    -- Apply dialog scale
    local scale = VUIGfinder.db.profile.dialogScale
    if VUIGfinderDialog then
        VUIGfinderDialog:SetScale(scale)
    end
    
    -- Set logger level based on debug mode
    if VUIGfinder.Logger then
        if VUIGfinder.db.profile.debugMode then
            VUIGfinder.Logger:SetLogLevel(VUIGfinder.Logger.LOG_LEVEL_DEBUG)
        else
            VUIGfinder.Logger:SetLogLevel(VUIGfinder.Logger.LOG_LEVEL_ERROR)
        end
    end
    
    -- Apply other settings as needed
    -- (each module should check settings when initializing)
end

-- Toggle addon enabled state
function Settings:ToggleEnabled(enabled)
    VUIGfinder.db.profile.enabled = enabled
    self:ApplySettings()
    
    if VUIGfinder.OnEnabledStateChanged then
        VUIGfinder.OnEnabledStateChanged(enabled)
    end
end

-- Set dialog scale
function Settings:SetDialogScale(scale)
    VUIGfinder.db.profile.dialogScale = scale
    self:ApplySettings()
end

-- Toggle enhanced tooltips
function Settings:ToggleEnhancedTooltips(enabled)
    VUIGfinder.db.profile.enhancedTooltips = enabled
end

-- Toggle one-click sign up
function Settings:ToggleOneClickSignUp(enabled)
    VUIGfinder.db.profile.oneClickSignUp = enabled
end

-- Toggle remember sign up notes
function Settings:ToggleRememberSignUpNotes(enabled)
    VUIGfinder.db.profile.rememberSignUpNotes = enabled
end

-- Toggle sign up on enter
function Settings:ToggleSignUpOnEnter(enabled)
    VUIGfinder.db.profile.signUpOnEnter = enabled
end

-- Toggle show filter button
function Settings:ToggleShowFilterButton(enabled)
    VUIGfinder.db.profile.showFilterButton = enabled
    
    -- Update filter button visibility
    if VUIGfinder.UpdateFilterButtonVisibility then
        VUIGfinder.UpdateFilterButtonVisibility()
    end
end

-- Set advanced mode enabled
function Settings:SetAdvancedModeEnabled(enabled)
    VUIGfinder.db.profile.enableAdvancedMode = enabled
end

-- Set filter expression
function Settings:SetFilterExpression(expression)
    VUIGfinder.db.profile.defaultFilterExpression = expression
end

-- Set custom sorting enabled
function Settings:SetCustomSortingEnabled(enabled)
    VUIGfinder.db.profile.enableCustomSorting = enabled
end

-- Set sorting expression
function Settings:SetSortingExpression(expression)
    VUIGfinder.db.profile.defaultSortingExpression = expression
end