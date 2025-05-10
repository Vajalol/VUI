-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L
local C = VUIGfinder.C

-- Create Settings namespace
VUIGfinder.Settings = {}
local Settings = VUIGfinder.Settings

-- Default settings
Settings.defaults = {
    profile = {
        enabled = true,
        debug = false,
        
        -- Dungeon filters
        dungeon = {
            enabled = true,
            minimumDifficulty = C.NORMAL,
            maximumDifficulty = C.MYTHICPLUS,
            minMythicPlusLevel = 2,
            maxMythicPlusLevel = 30,
            tankRoleEnabled = true,
            healerRoleEnabled = true,
            dpsRoleEnabled = true,
            onlyShowTimedRuns = false,
            excludeBoostGroups = true,
            requireVoiceChat = false,
        },
        
        -- Raid filters
        raid = {
            enabled = true,
            minimumDifficulty = C.NORMAL,
            maximumDifficulty = C.MYTHIC,
            tankRoleEnabled = true, 
            healerRoleEnabled = true,
            dpsRoleEnabled = true,
            onlyShowProgression = false,
            excludeBoostGroups = true,
            requireVoiceChat = false,
        },
        
        -- Arena filters
        arena = {
            enabled = true,
            minRating = 0,
            maxRating = 3000,
            tankRoleEnabled = true,
            healerRoleEnabled = true,
            dpsRoleEnabled = true,
            excludeBoostGroups = true,
            requireVoiceChat = false,
        },
        
        -- Rated BG filters
        rbg = {
            enabled = true,
            minRating = 0,
            maxRating = 3000,
            tankRoleEnabled = true,
            healerRoleEnabled = true, 
            dpsRoleEnabled = true,
            excludeBoostGroups = true,
            requireVoiceChat = false,
        },
        
        -- Advanced filtering
        advanced = {
            enabled = false,
            expression = "",
        },
        
        -- Custom sorting
        sorting = {
            enabled = false,
            expression = "",
        },
        
        -- UI settings
        ui = {
            minimized = false,
            dialogScale = 1.0,
            tooltipEnhancement = true,
            oneClickSignUp = true,
            persistSignUpNote = true,
            signUpOnEnter = true,
            usePGFButton = true,
        },
        
        -- Saved notes
        signUpNotes = {
            default = "",
            dungeon = "",
            raid = "",
            arena = "",
            rbg = "",
        },
    },
}

-- Initialize settings
function Settings:Initialize()
    -- Migrate legacy settings if needed
    self:MigrateSettings()
    
    -- Set up defaults
    self:SetDefaults()
    
    -- Register callbacks for settings changes
    self:RegisterCallbacks()
end

-- Migrate settings from previous versions
function Settings:MigrateSettings()
    -- Check for legacy saved variables format
    local savedVars = VUI_SavedVariables.VUIGfinder
    
    if not savedVars then
        return
    end
    
    -- Simple migration - just ensure profile exists
    if not savedVars.profile then
        savedVars.profile = {}
    end
    
    -- More complex migrations can be added here
end

-- Set default settings
function Settings:SetDefaults()
    local db = Module.db
    
    -- Ensure we have a profile
    db.profile = db.profile or {}
    
    -- Merge defaults into existing settings
    for category, defaults in pairs(self.defaults.profile) do
        db.profile[category] = db.profile[category] or {}
        
        if type(defaults) == "table" then
            for key, value in pairs(defaults) do
                if db.profile[category][key] == nil then
                    db.profile[category][key] = value
                end
            end
        else
            if db.profile[category] == nil then
                db.profile[category] = defaults
            end
        end
    end
end

-- Register callbacks for settings changes
function Settings:RegisterCallbacks()
    -- Add callbacks if needed
end

-- Get a setting value
function Settings:Get(category, key)
    local db = Module.db
    
    if not db.profile then
        return nil
    end
    
    if not category then
        return db.profile
    end
    
    if not db.profile[category] then
        return nil
    end
    
    if not key then
        return db.profile[category]
    end
    
    return db.profile[category][key]
end

-- Set a setting value
function Settings:Set(category, key, value)
    local db = Module.db
    
    if not db.profile then
        db.profile = {}
    end
    
    if not db.profile[category] then
        db.profile[category] = {}
    end
    
    db.profile[category][key] = value
    
    -- Trigger callbacks
    self:TriggerCallbacks(category, key, value)
end

-- Save settings
function Settings:Save()
    -- Ensure settings are saved in SavedVariables
    VUI_SavedVariables.VUIGfinder = Module.db
end

-- Reset settings to defaults
function Settings:Reset(category)
    local db = Module.db
    
    if not category then
        -- Reset all settings
        db.profile = self.defaults.profile
    else
        -- Reset just one category
        db.profile[category] = self.defaults.profile[category]
    end
    
    -- Trigger callbacks
    self:TriggerCallbacks(category)
end

-- Callback system
Settings.callbacks = {}

-- Register a callback for settings changes
function Settings:RegisterCallback(callback)
    table.insert(self.callbacks, callback)
end

-- Trigger callbacks for settings changes
function Settings:TriggerCallbacks(category, key, value)
    for _, callback in ipairs(self.callbacks) do
        callback(category, key, value)
    end
end

-- Create options panel for VUI config interface
function Settings:CreateOptionsPanel()
    -- Implementation will be in separate UI file
end