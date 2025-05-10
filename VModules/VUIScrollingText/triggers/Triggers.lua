-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Triggers
-- Author: VortexQ8
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local ST = VUI.ScrollingText
if not ST then return end

-- Local variables
local registeredTriggers = {}
local masterEnable = true

-- Local references for increased performance
local pairs = pairs
local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------

-- Check if the event matches the trigger pattern
local function MatchesPattern(event, pattern)
    if not event or not pattern then return false end
    
    -- Exact match
    if event == pattern then return true end
    
    -- Wildcard match
    if string_find(pattern, "%*") then
        -- Convert pattern to Lua pattern by escaping special chars and converting * to .*
        local luaPattern = string_gsub(pattern, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
        luaPattern = string_gsub(luaPattern, "%%%*", ".*")
        
        return string_match(event, "^" .. luaPattern .. "$") ~= nil
    end
    
    return false
end

-- Check if a trigger should fire
local function ShouldTriggerFire(trigger, event, ...)
    -- Skip if trigger is disabled
    if not trigger.enabled then return false end
    
    -- Skip if no pattern to match
    if not trigger.pattern then return false end
    
    -- Check if the event matches the pattern
    if not MatchesPattern(event, trigger.pattern) then return false end
    
    -- If a condition function exists, test it
    if trigger.condition then
        local success, result = pcall(trigger.condition, event, ...)
        if not success or not result then return false end
    end
    
    return true
end

-- Fire a trigger
local function FireTrigger(trigger, event, ...)
    -- Check customizable options
    local message = trigger.message or ("Trigger: " .. event)
    local scrollArea = trigger.scrollArea or "Notification"
    
    -- Get colors
    local r, g, b = 1, 1, 1 -- Default white
    
    -- Use VUI theme color if enabled
    if trigger.useThemeColor then
        local themeColor = VUI:GetThemeColor()
        r, g, b = themeColor.r, themeColor.g, themeColor.b
    else
        r = trigger.colorR or r
        g = trigger.colorG or g
        b = trigger.colorB or b
    end
    
    -- Display the trigger message
    if ST.DisplayMessage then
        ST.DisplayMessage(message, scrollArea, r, g, b, nil, nil, trigger.fontSize, trigger.fontPath, nil, trigger.outlineIndex, trigger.soundFile)
    end
    
    -- Run custom function if it exists
    if trigger.onFire then
        pcall(trigger.onFire, trigger, event, ...)
    end
    
    return true
end

-------------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------------

-- Process an event
local function ProcessEvent(event, ...)
    -- Skip if triggers are globally disabled
    if not masterEnable then return false end
    
    local hadTrigger = false
    
    -- Check each registered trigger
    for name, trigger in pairs(registeredTriggers) do
        if ShouldTriggerFire(trigger, event, ...) then
            hadTrigger = FireTrigger(trigger, event, ...) or hadTrigger
        end
    end
    
    return hadTrigger
end

-- Register a trigger
local function RegisterTrigger(name, settings)
    if not name or not settings then return false end
    
    registeredTriggers[name] = settings
    return true
end

-- Unregister a trigger
local function UnregisterTrigger(name)
    if not name then return false end
    
    registeredTriggers[name] = nil
    return true
end

-- Get a trigger's settings
local function GetTriggerSettings(name)
    return registeredTriggers[name]
end

-- Get all registered triggers
local function GetAllTriggers()
    local names = {}
    for name in pairs(registeredTriggers) do
        table.insert(names, name)
    end
    return names
end

-- Enable/disable all triggers
local function SetMasterEnable(enabled)
    masterEnable = enabled
end

-- Apply VUI theme to triggers
local function ApplyTheme()
    -- Get the current theme color
    local themeColor = VUI:GetThemeColor()
    
    -- Update any triggers that use the theme color
    for _, trigger in pairs(registeredTriggers) do
        if trigger.useThemeColor then
            trigger.colorR = themeColor.r
            trigger.colorG = themeColor.g
            trigger.colorB = themeColor.b
        end
    end
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Module public interface
ST.Triggers = {
    ProcessEvent = ProcessEvent,
    RegisterTrigger = RegisterTrigger,
    UnregisterTrigger = UnregisterTrigger,
    GetTriggerSettings = GetTriggerSettings,
    GetAllTriggers = GetAllTriggers,
    SetMasterEnable = SetMasterEnable,
    ApplyTheme = ApplyTheme,
}

-- Register with theme system
if VUI.RegisterCallback then
    VUI:RegisterCallback("OnThemeChanged", function()
        ApplyTheme()
    end)
end

-- Register some default triggers
RegisterTrigger("LowHealth", {
    enabled = true,
    pattern = "UNIT_HEALTH_FREQUENT:player",
    condition = function(event)
        local currentHealth = UnitHealth("player")
        local maxHealth = UnitHealthMax("player")
        return currentHealth > 0 and maxHealth > 0 and (currentHealth / maxHealth) <= 0.25
    end,
    message = "LOW HEALTH!",
    scrollArea = "Notification",
    colorR = 1,
    colorG = 0,
    colorB = 0,
    fontSize = 24,
    outlineIndex = 2, -- Thick outline
    soundFile = "LowHealth",
    useThemeColor = false, -- Keep red for health warning
})

RegisterTrigger("LowMana", {
    enabled = true,
    pattern = "UNIT_POWER_FREQUENT:player",
    condition = function(event)
        local _, powerType = UnitPowerType("player")
        if powerType ~= "MANA" then return false end
        
        local currentMana = UnitPower("player")
        local maxMana = UnitPowerMax("player")
        return currentMana > 0 and maxMana > 0 and (currentMana / maxMana) <= 0.25
    end,
    message = "LOW MANA!",
    scrollArea = "Notification",
    colorR = 0,
    colorG = 0,
    colorB = 1,
    fontSize = 24,
    outlineIndex = 2, -- Thick outline
    soundFile = "LowMana",
    useThemeColor = false, -- Keep blue for mana warning
})