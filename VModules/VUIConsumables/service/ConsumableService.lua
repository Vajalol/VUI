-- VUIConsumables: Consumable Service
-- Provides utility functions for tracking and analyzing consumable effects

local AddonName, VUI = ...

-- Create a namespace for services that will be populated later
VUI.ConsumableService = VUI.ConsumableService or {}

-- Helper to safely get module reference when needed
local function GetModule()
    -- Check if VUI exists and has the GetModule method
    if VUI and type(VUI.GetModule) == "function" then
        local success, module = pcall(function() return VUI:GetModule("VUIConsumables") end)
        if success and module then
            return module
        end
    end
    
    -- Check for global reference as fallback
    if _G["VUIConsumables"] then
        return _G["VUIConsumables"]
    end
    
    -- Last resort: check if module exists directly in VUI
    if VUI and VUI.VUIConsumables then
        return VUI.VUIConsumables
    end
    
    return nil
end

-- Determine which consumables are currently missing
-- Returns a table of missing consumable types
function VUI.ConsumableService:GetMissingConsumables()
    local M = GetModule()
    if not M or not M.iconFrames then return {} end
    
    local missing = {}
    
    -- Check if each tracked consumable type is active
    for _, frame in pairs(M.iconFrames or {}) do
        if not frame.active then
            table.insert(missing, frame.type)
        end
    end
    
    return missing
end

-- Get a formatted string listing missing consumables
function VUI.ConsumableService:GetMissingConsumablesText()
    local missing = self:GetMissingConsumables()
    if #missing == 0 then
        return nil
    end
    
    local text = "Missing: "
    for i, consumableType in ipairs(missing) do
        text = text .. consumableType
        if i < #missing then
            text = text .. ", "
        end
    end
    
    return text
end

-- Check if a specific consumable type is active
function VUI.ConsumableService:IsConsumableActive(consumableType)
    local M = GetModule()
    if not M or not M.iconFrames or not M.iconFrames[consumableType] then
        return false
    end
    
    return M.iconFrames[consumableType].active
end

-- Get time remaining for a specific consumable type
-- Returns remaining time in seconds, or 0 if not active
function VUI.ConsumableService:GetConsumableTimeRemaining(consumableType)
    if not self:IsConsumableActive(consumableType) then
        return 0
    end
    
    local M = GetModule()
    if not M or not M.iconFrames then return 0 end
    
    local currentTime = GetTime()
    local frame = M.iconFrames[consumableType]
    
    return math.max(0, frame.expirationTime - currentTime)
end

-- Get consumable status information for all types
-- Returns a table with details for each consumable type
function VUI.ConsumableService:GetConsumableStatus()
    local M = GetModule()
    if not M then return {} end
    
    local status = {}
    local consumableTypes = {}
    
    -- Try to get consumable type constants
    if M.FLASK and M.FOOD and M.POTION and M.RUNE then
        consumableTypes = {M.FLASK, M.FOOD, M.POTION, M.RUNE}
    else
        -- Fallback to string literals if constants aren't available
        consumableTypes = {"FLASK", "FOOD", "POTION", "RUNE"}
    end
    
    for _, consumableType in ipairs(consumableTypes) do
        if M.iconFrames and M.iconFrames[consumableType] then
            local frame = M.iconFrames[consumableType]
            status[consumableType] = {
                active = frame.active,
                name = frame.name,
                timeRemaining = self:GetConsumableTimeRemaining(consumableType),
                icon = frame.icon:GetTexture()
            }
        else
            status[consumableType] = {
                active = false,
                name = nil,
                timeRemaining = 0,
                icon = nil
            }
        end
    end
    
    return status
end

-- Get warning status for consumables
-- Returns true if any consumable is about to expire
function VUI.ConsumableService:HasWarnings()
    local M = GetModule()
    if not M or not M.db or not M.db.profile then
        return false
    end
    
    local warningThreshold = M.db.profile.warningThreshold or 60
    local consumableTypes = {}
    
    -- Try to get consumable type constants
    if M.FLASK and M.FOOD and M.POTION and M.RUNE then
        consumableTypes = {M.FLASK, M.FOOD, M.POTION, M.RUNE}
    else
        -- Fallback to string literals if constants aren't available
        consumableTypes = {"FLASK", "FOOD", "POTION", "RUNE"}
    end
    
    for _, consumableType in ipairs(consumableTypes) do
        local timeRemaining = self:GetConsumableTimeRemaining(consumableType)
        if timeRemaining > 0 and timeRemaining < warningThreshold then
            return true
        end
    end
    
    return false
end

-- Format time nicely for display
function VUI.ConsumableService:FormatTime(seconds)
    if seconds <= 0 then
        return "0s"
    elseif seconds > 3600 then
        return string.format("%.1fh", seconds/3600)
    elseif seconds > 60 then
        return string.format("%.1fm", seconds/60)
    else
        return string.format("%.0fs", seconds)
    end
end

-- Connect to module when it's available
if VUI and VUI.RegisterLoadHandler then
    VUI:RegisterLoadHandler(function()
        local M = GetModule()
        if M then
            -- Link our service to the module for backward compatibility
            M.Service = VUI.ConsumableService
        end
    end)
end