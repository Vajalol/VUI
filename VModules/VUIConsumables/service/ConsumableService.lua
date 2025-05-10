-- VUIConsumables: Consumable Service
-- Provides utility functions for tracking and analyzing consumable effects

local AddonName, VUI = ...
local M = VUI.VUIConsumables
if not M then return end -- Safety check

-- Create the service namespace
M.Service = {}

-- Determine which consumables are currently missing
-- Returns a table of missing consumable types
function M.Service:GetMissingConsumables()
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
function M.Service:GetMissingConsumablesText()
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
function M.Service:IsConsumableActive(consumableType)
    if not M.iconFrames or not M.iconFrames[consumableType] then
        return false
    end
    
    return M.iconFrames[consumableType].active
end

-- Get time remaining for a specific consumable type
-- Returns remaining time in seconds, or 0 if not active
function M.Service:GetConsumableTimeRemaining(consumableType)
    if not self:IsConsumableActive(consumableType) then
        return 0
    end
    
    local currentTime = GetTime()
    local frame = M.iconFrames[consumableType]
    
    return math.max(0, frame.expirationTime - currentTime)
end

-- Get consumable status information for all types
-- Returns a table with details for each consumable type
function M.Service:GetConsumableStatus()
    local status = {}
    
    for _, consumableType in ipairs({M.FLASK, M.FOOD, M.POTION, M.RUNE}) do
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
function M.Service:HasWarnings()
    local warningThreshold = M.db.profile.warningThreshold
    
    for _, consumableType in ipairs({M.FLASK, M.FOOD, M.POTION, M.RUNE}) do
        local timeRemaining = self:GetConsumableTimeRemaining(consumableType)
        if timeRemaining > 0 and timeRemaining < warningThreshold then
            return true
        end
    end
    
    return false
end

-- Format time nicely for display
function M.Service:FormatTime(seconds)
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