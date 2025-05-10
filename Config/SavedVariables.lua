-- VUI SavedVariables Manager
-- Ensures all modules' settings are properly stored in a unified database structure

local AddonName, VUI = ...

local SavedVariables = VUI:NewModule("SavedVariables")

-- List of all VUI modules that might have settings
local moduleList = {
    -- Core Modules 
    "General", "Unitframes", "Nameplates", "Actionbar", "Castbars", 
    "Tooltip", "Buffs", "Map", "Chat", "Misc",
    
    -- Phase 1: Core Addon Modules 
    "VUIBuffs", "VUIAnyFrame", "VUIKeystones", "VUICC", "VUICD",
    "VUIIDs", "VUIGfinder", "VUITGCD", "VUIAuctionator", "VUINotifications",
    
    -- Phase 2: WeakAura Modules
    "VUIScrollingText", "VUIepf", "VUIConsumables", "VUIPositionOfPower",
    "VUIMissingRaidBuffs", "VUIMouseFireTrail", "VUIHealerMana",
    
    -- Phase 3: New Features
    "VUIPlater", "VUISkin"
}

function SavedVariables:OnInitialize()
    -- This module initializes after all others to verify saved variables
    self:RegisterEvent("PLAYER_LOGIN", "VerifySavedVariables")
end

function SavedVariables:VerifySavedVariables()
    VUI:Print("Verifying module settings database structure...")
    
    local missingModules = {}
    local count = 0
    
    -- Check that each module has settings registered properly
    for _, moduleName in ipairs(moduleList) do
        if VUI.db.namespaces[moduleName] then
            count = count + 1
        else
            table.insert(missingModules, moduleName)
        end
    end
    
    -- Report results
    VUI:Print(string.format("Found %d/%d modules with proper settings", count, #moduleList))
    
    -- Alert about any missing module settings
    if #missingModules > 0 then
        VUI:Print("The following modules might not be saving settings properly:")
        for _, name in ipairs(missingModules) do
            VUI:Print("- " .. name)
        end
    end
end

-- Function to reset all settings for all modules
function SavedVariables:ResetAllSettings()
    for _, moduleName in ipairs(moduleList) do
        if VUI.db.namespaces[moduleName] then
            VUI.db.namespaces[moduleName]:ResetProfile()
        end
    end
    
    -- Also reset global settings
    VUI.db:ResetProfile()
    
    VUI:Print("All settings have been reset to defaults.")
    
    -- Suggest reload
    StaticPopup_Show("VUI_RELOAD_UI")
end

-- Create a reload UI dialog
StaticPopupDialogs["VUI_RELOAD_UI"] = {
    text = "VUI settings have changed. Reload UI to apply changes?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Add a "Reset All Settings" button to the main VUI configuration panel
function SavedVariables:AddResetAllButton(configPanel)
    if not configPanel then return end
    
    local resetAll = CreateFrame("Button", nil, configPanel, "UIPanelButtonTemplate")
    resetAll:SetSize(150, 25)
    resetAll:SetPoint("BOTTOMRIGHT", configPanel, "BOTTOMRIGHT", -10, 10)
    resetAll:SetText("Reset All Settings")
    resetAll:SetScript("OnClick", function()
        StaticPopup_Show("VUI_RESET_ALL_CONFIRM")
    end)
end

-- Create a confirmation dialog for resetting all settings
StaticPopupDialogs["VUI_RESET_ALL_CONFIRM"] = {
    text = "Are you sure you want to reset ALL VUI settings to default? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        SavedVariables:ResetAllSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}