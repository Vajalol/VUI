-- VUITGCD Settings.lua
-- Manages settings and profiles for the VUITGCD module

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace if not created yet
if not ns.settings then
    ns.settings = {
        profiles = {},
        activeProfile = nil,
        defaultProfile = "Default"
    }
end

-- Initialize default profile
function ns.settings:InitializeDefaultProfile()
    if not self.profiles["Default"] then
        self.profiles["Default"] = {
            name = "Default",
            enableInWorld = true,
            enableInDungeons = true,
            enableInRaids = true,
            enableInPvP = true,
            disableOutOfCombat = false,
            disableInCities = true,
            showGlow = true,
            glowEffect = "blizz",
            showTooltips = true,
            showSpellNames = false,
            
            -- Unit settings
            layoutSettings = {},
            
            -- Blocked spells
            innerBlocklist = {}
        }
        
        -- Initialize default layout settings for each unit type
        for _, unitType in ipairs(ns.constants.unitTypes) do
            self.profiles["Default"].layoutSettings[unitType] = {
                enable = (unitType == "player"), -- Only player enabled by default
                iconSize = ns.constants.defaultIconSize,
                maxIcons = 8,
                layout = "horizontal",
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = 0,
                showLabel = true,
                useClassColor = true
            }
        end
        
        -- Set default blocklist
        for spellId, blocked in pairs(ns.constants.defaultBlocklist) do
            self.profiles["Default"].innerBlocklist[spellId] = blocked
        end
    end
    
    -- Set Default as active profile if none exists
    if not self.activeProfile then
        self.activeProfile = self.profiles["Default"]
    end
end

-- Load settings from saved variables
function ns.settings:Load()
    local VUI = _G.VUI
    if not VUI then return end
    
    local loaded = false
    
    -- Initialize default profile first
    self:InitializeDefaultProfile()
    
    -- Load from VUI saved variables
    if VUI.db and VUI.db.modules and VUI.db.modules.VUITGCD then
        local savedSettings = VUI.db.modules.VUITGCD
        
        -- Load profiles
        if savedSettings.profiles then
            for name, profile in pairs(savedSettings.profiles) do
                self.profiles[name] = profile
            end
            loaded = true
        end
        
        -- Load active profile
        if savedSettings.activeProfileName and self.profiles[savedSettings.activeProfileName] then
            self.activeProfile = self.profiles[savedSettings.activeProfileName]
        else
            self.activeProfile = self.profiles["Default"]
        end
    end
    
    -- Ensure we have a valid active profile
    if not self.activeProfile then
        self.activeProfile = self.profiles["Default"]
    end
    
    return loaded
end

-- Save settings to saved variables
function ns.settings:Save()
    local VUI = _G.VUI
    if not VUI then return end
    
    -- Make sure VUI.db and modules exist
    if not VUI.db then VUI.db = {} end
    if not VUI.db.modules then VUI.db.modules = {} end
    
    -- Create or update VUITGCD settings
    VUI.db.modules.VUITGCD = {
        profiles = self.profiles,
        activeProfileName = self.activeProfile and self.activeProfile.name or "Default"
    }
end

-- Get a profile by name
function ns.settings:GetProfile(name)
    return self.profiles[name]
end

-- Create a new profile
function ns.settings:CreateProfile(name)
    if not name or name == "" or self.profiles[name] then
        return nil
    end
    
    -- Create new profile based on current active profile
    local newProfile = {}
    if self.activeProfile then
        -- Deep copy the active profile
        newProfile = ns.settings:DeepCopy(self.activeProfile)
        newProfile.name = name
    else
        -- Use default if no active profile
        newProfile = ns.settings:DeepCopy(self.profiles["Default"])
        newProfile.name = name
    end
    
    -- Store the new profile
    self.profiles[name] = newProfile
    
    -- Save changes
    self:Save()
    
    return newProfile
end

-- Delete a profile
function ns.settings:DeleteProfile(name)
    if not name or name == "" or name == "Default" or not self.profiles[name] then
        return false
    end
    
    -- Remove the profile
    self.profiles[name] = nil
    
    -- If it was the active profile, switch to Default
    if self.activeProfile and self.activeProfile.name == name then
        self.activeProfile = self.profiles["Default"]
    end
    
    -- Save changes
    self:Save()
    
    return true
end

-- Set active profile
function ns.settings:SetActiveProfile(name)
    if not name or not self.profiles[name] then
        return false
    end
    
    self.activeProfile = self.profiles[name]
    
    -- Save changes
    self:Save()
    
    -- Update all modules that depend on settings
    if ns.locationCheck and ns.locationCheck.settingsChanged then
        ns.locationCheck.settingsChanged()
    end
    
    return true
end

-- Reset a profile to defaults
function ns.settings:ResetProfile(name)
    if not name or not self.profiles[name] then
        return false
    end
    
    if name == "Default" then
        -- Reset default profile
        self.profiles["Default"] = nil
        self:InitializeDefaultProfile()
    else
        -- Base on Default
        self.profiles[name] = ns.settings:DeepCopy(self.profiles["Default"])
        self.profiles[name].name = name
    end
    
    -- Save changes
    self:Save()
    
    -- Update if it was the active profile
    if self.activeProfile and self.activeProfile.name == name then
        self.activeProfile = self.profiles[name]
        
        -- Update all modules that depend on settings
        if ns.locationCheck and ns.locationCheck.settingsChanged then
            ns.locationCheck.settingsChanged()
        end
    end
    
    return true
end

-- Deep copy a table
function ns.settings:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ns.settings:DeepCopy(orig_key)] = ns.settings:DeepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

-- Add spell to blocklist
function ns.settings:AddToBlocklist(spellId)
    if not spellId or not self.activeProfile then
        return false
    end
    
    self.activeProfile.innerBlocklist[spellId] = true
    
    -- Save changes
    self:Save()
    
    return true
end

-- Remove spell from blocklist
function ns.settings:RemoveFromBlocklist(spellId)
    if not spellId or not self.activeProfile then
        return false
    end
    
    self.activeProfile.innerBlocklist[spellId] = nil
    
    -- Save changes
    self:Save()
    
    return true
end

-- Check if spell is in blocklist
function ns.settings:IsSpellBlocked(spellId)
    if not spellId or not self.activeProfile then
        return false
    end
    
    return self.activeProfile.innerBlocklist[spellId] == true
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.Settings = ns.settings
end