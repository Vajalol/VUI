-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Cooldowns
-- Author: VortexQ8
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local ST = VUI.ScrollingText
if not ST then return end

-- Local references for increased performance
local string_find = string.find
local string_match = string.match
local pairs = pairs
local next = next
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime

-- Whether or not the cooldowns module is enabled
local isEnabled = false

-- Table to hold the cooldown entries
local cooldownEntries = {}

-- Table to hold spells still on cooldown
local spellsOnCooldown = {}

-- Last fire time for each spell
local lastFireTimes = {}

-- Fire threshold in seconds
local FIRE_THRESHOLD = 0.1

-- Update frequency
local UPDATE_FREQUENCY = 0.1

-- Next update time
local nextUpdate = 0

-- Event frame
local eventFrame

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------

-- Validate the cooldown settings
local function ValidateCooldownSettings(name, settings)
    -- Ensure required fields exist
    if not name or not settings then return false end
    if not settings.enabled or not settings.spellName then return false end
    
    return true
end

-- Process a cooldown
local function ProcessCooldown(spellName, duration, startTime, cooldownType)
    -- Skip if the cooldown isn't interesting
    if duration <= 1.5 then return end
    
    -- Get current time
    local currentTime = GetTime()
    
    -- Process each cooldown entry
    for _, entry in pairs(cooldownEntries) do
        if entry.enabled and entry.spellName == spellName then
            -- Skip if the entry was fired too recently to avoid spam
            if lastFireTimes[spellName] and (currentTime - lastFireTimes[spellName] < FIRE_THRESHOLD) then
                return
            end
            
            -- Determine if the cooldown is ready or just started
            local isReady = duration == 0 or (currentTime - startTime) >= duration
            
            -- Update the last fire time
            lastFireTimes[spellName] = currentTime
            
            -- Track the cooldown state
            if isReady then
                -- Cooldown is ready
                if spellsOnCooldown[spellName] then
                    spellsOnCooldown[spellName] = nil
                    -- Trigger a ready message (pass to the main ScrollingText output)
                    if ST.DisplayMessage then
                        local message = "+" .. spellName
                        local colorR, colorG, colorB
                        
                        -- Use VUI theme color if set
                        if entry.useThemeColor then
                            local themeColor = VUI:GetThemeColor()
                            colorR, colorG, colorB = themeColor.r, themeColor.g, themeColor.b
                        else
                            colorR, colorG, colorB = entry.colorR or 0, entry.colorG or 1, entry.colorB or 0
                        end
                        
                        ST.DisplayMessage(message, entry.scrollArea or "Notification", colorR, colorG, colorB, nil, nil, entry.fontSize or nil, entry.fontPath or nil, nil, entry.outlineIndex or nil, entry.soundFile or "Cooldown")
                    end
                end
            else
                -- Cooldown just started
                if not spellsOnCooldown[spellName] then
                    spellsOnCooldown[spellName] = true
                    -- Trigger a started message (pass to the main ScrollingText output)
                    if ST.DisplayMessage then
                        local message = "-" .. spellName
                        local colorR, colorG, colorB
                        
                        -- Use VUI theme color if set
                        if entry.useThemeColor then
                            local themeColor = VUI:GetThemeColor()
                            colorR, colorG, colorB = themeColor.r, themeColor.g, themeColor.b
                        else
                            colorR, colorG, colorB = entry.colorR or 1, entry.colorG or 0, entry.colorB or 0
                        end
                        
                        ST.DisplayMessage(message, entry.scrollArea or "Notification", colorR, colorG, colorB, nil, nil, entry.fontSize or nil, entry.fontPath or nil, nil, entry.outlineIndex or nil)
                    end
                end
            end
            
            return
        end
    end
end

-- On update function for checking cooldowns
local function OnUpdate(self, elapsed)
    -- Return immediately if disabled
    if not isEnabled then return end
    
    -- Only update at the specified frequency
    local currentTime = GetTime()
    if currentTime < nextUpdate then return end
    nextUpdate = currentTime + UPDATE_FREQUENCY
    
    -- Check cooldowns for each entry
    for _, entry in pairs(cooldownEntries) do
        if entry.enabled then
            local start, duration = GetSpellCooldown(entry.spellId or entry.spellName)
            if start and duration then
                ProcessCooldown(entry.spellName, duration, start, "SPELL")
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------------

-- Enable cooldown tracking
local function EnableCooldowns()
    -- Create the event frame if it doesn't exist
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnUpdate", OnUpdate)
    end
    
    isEnabled = true
end

-- Disable cooldown tracking
local function DisableCooldowns()
    isEnabled = false
    
    -- Clear the event frame
    if eventFrame then
        eventFrame:SetScript("OnUpdate", nil)
    end
end

-- Register a cooldown
local function RegisterCooldown(name, settings)
    -- Validate the settings
    if not ValidateCooldownSettings(name, settings) then return false end
    
    -- Add the cooldown entry
    cooldownEntries[name] = settings
    
    return true
end

-- Unregister a cooldown
local function UnregisterCooldown(name)
    cooldownEntries[name] = nil
end

-- Get the list of registered cooldowns
local function GetRegisteredCooldowns()
    local names = {}
    for name in pairs(cooldownEntries) do
        table.insert(names, name)
    end
    return names
end

-- Apply VUI theme to cooldowns
local function ApplyTheme()
    if not isEnabled then return end
    
    -- Get the current theme color
    local themeColor = VUI:GetThemeColor()
    
    -- Update any cooldown entries that use the theme color
    for _, entry in pairs(cooldownEntries) do
        if entry.useThemeColor then
            entry.colorR = themeColor.r
            entry.colorG = themeColor.g
            entry.colorB = themeColor.b
        end
    end
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Module public interface
ST.Cooldowns = {
    EnableCooldowns = EnableCooldowns,
    DisableCooldowns = DisableCooldowns,
    RegisterCooldown = RegisterCooldown,
    UnregisterCooldown = UnregisterCooldown,
    GetRegisteredCooldowns = GetRegisteredCooldowns,
    ApplyTheme = ApplyTheme,
}

-- Register with theme system
if VUI.RegisterCallback then
    VUI:RegisterCallback("OnThemeChanged", function()
        ApplyTheme()
    end)
end