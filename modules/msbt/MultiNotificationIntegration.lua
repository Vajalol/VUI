-- VUI MSBT MultiNotification Integration
-- Links the MSBT module with the MultiNotification system
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Get module references
local MSBT = VUI:GetModule("MSBT")

-- Helper function to check if the MultiNotification module is available
local function IsMultiNotificationAvailable()
    return VUI:GetModule("MultiNotification") ~= nil
end

-- Define mapping for notification types
local notificationTypeMap = {
    ["NOTIFICATION_BUFF"] = "buff",
    ["NOTIFICATION_BUFF_STACK"] = "buff",
    ["NOTIFICATION_DEBUFF"] = "debuff",
    ["NOTIFICATION_DEBUFF_STACK"] = "debuff",
    ["NOTIFICATION_ITEM_BUFF"] = "buff",
    ["NOTIFICATION_HONOR_GAIN"] = "system",
    ["NOTIFICATION_REP_GAIN"] = "system",
    ["NOTIFICATION_REP_LOSS"] = "system",
    ["NOTIFICATION_SKILL_GAIN"] = "system",
    ["NOTIFICATION_EXPERIENCE_GAIN"] = "system",
    ["NOTIFICATION_PC_KILLING_BLOW"] = "important",
    ["NOTIFICATION_EXTRA_ATTACK"] = "important",
    ["NOTIFICATION_ENEMY_BUFF"] = "important",
    ["NOTIFICATION_COOLDOWN"] = "important",
    ["NOTIFICATION_LOOT_MONEY"] = "system",
    ["NOTIFICATION_MONEY"] = "system",
    -- Add more mappings as needed
}

-- Store the original DisplayMessage function
local originalDisplayMessage = nil

-- Function to hook into MSBT's notification system
local function HookMSBTNotifications()
    if not MSBT or not MSBT.DisplayMessage then
        return false
    end
    
    -- Save the original function if we haven't already
    if not originalDisplayMessage then
        originalDisplayMessage = MSBT.DisplayMessage
    end
    
    -- Replace DisplayMessage with our own version that forwards to MultiNotification when appropriate
    MSBT.DisplayMessage = function(self, eventType, message, icon, sourceGUID, sourceName, skillName, amount, ...)
        -- Always call the original function to maintain core MSBT functionality
        originalDisplayMessage(self, eventType, message, icon, sourceGUID, sourceName, skillName, amount, ...)
        
        -- If MultiNotification is not available or disabled, don't proceed with integration
        if not IsMultiNotificationAvailable() or not VUI.MultiNotification.db.profile.enabled then
            return
        end
        
        -- Check if this notification type should be forwarded to MultiNotification
        if not notificationTypeMap[eventType] then
            return
        end
        
        -- Handle special cases based on event type
        local notificationType = notificationTypeMap[eventType]
        local notificationIcon = icon
        local notificationText = message
        
        -- If it's a spell or ability, try to get the spell icon
        if skillName and not notificationIcon then
            -- Try to find the spell ID
            local spellID = MSBT:GetSpellIDFromName(skillName)
            if spellID then
                notificationIcon = GetSpellTexture(spellID)
            end
        end
        
        -- Fall back to a reasonable default icon if none is available
        if not notificationIcon then
            if notificationType == "buff" then
                notificationIcon = 135898 -- Default buff icon (Magic)
            elseif notificationType == "debuff" then
                notificationIcon = 136119 -- Default debuff icon (Magic debuff)
            elseif notificationType == "system" then
                notificationIcon = 136235 -- Default WoW icon
            else
                notificationIcon = 134400 -- Default question mark icon
            end
        end
        
        -- Format the notification text
        if not notificationText or notificationText == "" then
            if skillName then
                notificationText = skillName
                if amount then
                    notificationText = notificationText .. " " .. amount
                end
            elseif sourceName then
                notificationText = sourceName
            end
        end
        
        -- Send to MultiNotification
        VUI.MultiNotification:AddNotification(
            notificationType,
            notificationIcon,
            notificationText
        )
    end
    
    return true
end

-- Utility function to extract spell ID from spell name (if available)
function MSBT:GetSpellIDFromName(spellName)
    if not spellName then return nil end
    
    -- Check if this is already a spell ID
    if type(spellName) == "number" then
        return spellName
    end
    
    -- Try to find the spell ID using GetSpellInfo
    local searchName = spellName:lower()
    for i = 1, 50000 do -- Reasonable range for spell IDs
        local name = GetSpellInfo(i)
        if name and name:lower() == searchName then
            return i
        end
    end
    
    return nil
end

-- Initialize integration
function MSBT:InitializeMultiNotificationIntegration()
    if not IsMultiNotificationAvailable() then
        -- MultiNotification module not available, using original notification system
        return
    end
    
    if HookMSBTNotifications() then
        -- MSBT successfully integrated with MultiNotification system
    else
        -- Failed to integrate MSBT with MultiNotification system
    end
end

-- Register the integration to be initialized after modules
VUI:RegisterCallback("ModulesInitialized", function()
    if MSBT and MSBT.InitializeMultiNotificationIntegration then
        MSBT:InitializeMultiNotificationIntegration()
    end
end)