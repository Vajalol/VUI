local addonName, VUI = ...

-- Profiles service for VUIScrollingText
-- This handles loading, saving, and managing user profiles/settings

-- Local references
local pairs = pairs
local type = type
local CopyTable = VUI.ScrollingText.CopyTable

-- Default profile settings
local DEFAULT_PROFILE = {
    -- General settings
    enabled = true,
    
    -- Font settings
    fontFamily = "Friz",
    fontSize = 16,
    fontOutline = "OUTLINE",
    
    -- Animation settings
    animationStyle = "normal",
    animationSpeed = 2,
    
    -- Scroll areas
    incomingDamageArea = "center",
    outgoingDamageArea = "right",
    incomingHealingArea = "center",
    outgoingHealingArea = "right",
    
    -- Color settings
    useSchoolColors = true,
    damageColor = {r = 1, g = 0, b = 0},
    healingColor = {r = 0, g = 1, b = 0},
    missColor = {r = 0.5, g = 0.5, b = 0.5},
    
    -- Critical hit settings
    showCritsLarger = true,
    critPrefix = "",
    critSuffix = "!",
    
    -- Throttling settings
    enableThrottling = true,
    throttlingAmount = 2,
    
    -- Display filters
    showDamageAmount = true,
    showHealingAmount = true,
    showOverhealing = true,
    showMisses = true,
    showPowerGains = true,
    showExperience = true,
    showReputation = true,
    showHonor = true,
    showSkillGains = true,
    showLoot = true,
    showMoney = true,
    abbreviateNumbers = true,
    mergeSwings = true,
    
    -- Triggers and custom events
    customTriggers = {},
    customEvents = {},
    
    -- Cooldown settings
    cooldownThreshold = 3,
    showCooldowns = true,
}

-- Reference to the core module
local VUIScrollingTextModule = LibStub("AceAddon-3.0"):GetAddon("VUI"):GetModule("VUIScrollingText")

-- Initialize saved variables
function VUI.ScrollingText:InitializeProfile()
    -- Get reference to the module's database
    self.moduleDB = VUIScrollingTextModule.db.profile
    
    -- Ensure all default settings exist in the saved profile
    self:UpdateProfile()
end

-- Update the profile with any missing default values
function VUI.ScrollingText:UpdateProfile()
    local profile = self.moduleDB
    
    -- Check all default settings and add any missing ones
    for key, value in pairs(DEFAULT_PROFILE) do
        if profile[key] == nil then
            profile[key] = CopyTable(value)
        elseif type(value) == "table" and type(profile[key]) == "table" then
            -- For table values, check for missing keys in the subtable
            for subKey, subValue in pairs(value) do
                if profile[key][subKey] == nil then
                    profile[key][subKey] = subValue
                end
            end
        end
    end
end

-- Reset profile to defaults
function VUI.ScrollingText:ResetProfile()
    -- Reset the profile to defaults
    for key in pairs(self.moduleDB) do
        self.moduleDB[key] = nil
    end
    
    -- Copy the defaults back in
    for key, value in pairs(DEFAULT_PROFILE) do
        self.moduleDB[key] = CopyTable(value)
    end
end

-- Get a configuration value with fallback to default
function VUI.ScrollingText:GetConfigValue(key, defaultValue)
    -- Check if the key exists in the module's database
    if self.moduleDB and self.moduleDB[key] ~= nil then
        return self.moduleDB[key]
    end
    
    -- If the key exists in the default profile, return that
    if DEFAULT_PROFILE[key] ~= nil then
        return DEFAULT_PROFILE[key]
    end
    
    -- Otherwise return the provided default value
    return defaultValue
end

-- Set a configuration value
function VUI.ScrollingText:SetConfigValue(key, value)
    -- Initialize the module DB if not already done
    if not self.moduleDB then
        self:InitializeProfile()
    end
    
    -- Set the value in the module's database
    self.moduleDB[key] = value
end

-- Create a trigger for displaying text when a specific event occurs
function VUI.ScrollingText:CreateTrigger(triggerType, pattern, text, colorR, colorG, colorB, fontSize, soundFile, scrollArea, animationStyle)
    -- Initialize the module DB if not already done
    if not self.moduleDB then
        self:InitializeProfile()
    end
    
    -- Ensure the customTriggers table exists
    if not self.moduleDB.customTriggers then
        self.moduleDB.customTriggers = {}
    end
    
    local trigger = {
        triggerType = triggerType,
        pattern = pattern,
        text = text,
        color = {r = colorR or 1, g = colorG or 1, b = colorB or 1},
        fontSize = fontSize,
        soundFile = soundFile,
        scrollArea = scrollArea,
        animationStyle = animationStyle,
    }
    
    table.insert(self.moduleDB.customTriggers, trigger)
    return #self.moduleDB.customTriggers
end

-- Delete a trigger
function VUI.ScrollingText:DeleteTrigger(index)
    -- Check if the customTriggers table exists
    if not self.moduleDB or not self.moduleDB.customTriggers then return end
    table.remove(self.moduleDB.customTriggers, index)
end

-- Get all triggers
function VUI.ScrollingText:GetTriggers()
    -- Return the customTriggers table or an empty table if it doesn't exist
    return (self.moduleDB and self.moduleDB.customTriggers) or {}
end

-- Check if a message matches any triggers
function VUI.ScrollingText:CheckTriggers(message, eventType)
    local triggers = self:GetTriggers()
    
    for _, trigger in ipairs(triggers) do
        if trigger.triggerType == eventType or trigger.triggerType == "ANY" then
            if string.find(message, trigger.pattern) then
                return trigger
            end
        end
    end
    
    return nil
end

-- Execute a trigger action
function VUI.ScrollingText:ExecuteTrigger(trigger, message)
    -- Skip if module is disabled
    if not self:GetConfigValue("enabled", true) then return end
    
    -- Process the trigger text (substitute variables if needed)
    local text = trigger.text
    
    -- Display the text
    self:DisplayScrollingText(
        text,
        trigger.scrollArea or "notification",
        trigger.color,
        trigger.fontSize,
        nil,
        nil,
        trigger.animationStyle
    )
    
    -- Play sound if specified
    if trigger.soundFile then
        PlaySoundFile(trigger.soundFile, "Master")
    end
end