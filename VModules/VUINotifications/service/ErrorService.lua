local AddonName, VUI = ...

-- Define module reference
local M = VUI:GetModule("VUINotifications")

-- Ensure the Notifications namespace exists
VUI.Notifications = VUI.Notifications or {}

-- List of error messages to suppress
local suppressedErrors = {
    [ERR_ABILITY_COOLDOWN] = true,
    [ERR_ATTACK_CHARMED] = true,
    [ERR_ATTACK_CONFUSED] = true,
    [ERR_ATTACK_DEAD] = true,
    [ERR_ATTACK_FLEEING] = true,
    [ERR_ATTACK_PACIFIED] = true,
    [ERR_ATTACK_STUNNED] = true,
    [ERR_AUTOFOLLOW_TOO_FAR] = true,
    [ERR_BADATTACKFACING] = true,
    [ERR_BADATTACKPOS] = true,
    [ERR_CLIENT_LOCKED_OUT] = true,
    [ERR_GENERIC_NO_TARGET] = true,
    [ERR_INVALID_ATTACK_TARGET] = true,
    [ERR_ITEM_COOLDOWN] = true,
    [ERR_NOEMOTEWHILERUNNING] = true,
    [ERR_NOT_ENOUGH_MONEY] = true,
    [ERR_NOT_IN_RANGE] = true,
    [ERR_OUT_OF_ENERGY] = true,
    [ERR_OUT_OF_FOCUS] = true,
    [ERR_OUT_OF_HEALTH] = true,
    [ERR_OUT_OF_MANA] = true,
    [ERR_OUT_OF_RAGE] = true,
    [ERR_OUT_OF_RANGE] = true,
    [ERR_OUT_OF_RUNES] = true,
    [ERR_OUT_OF_RUNIC_POWER] = true,
    [ERR_SPELL_COOLDOWN] = true,
    [ERR_SPELL_OUT_OF_RANGE] = true,
    [ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS] = true,
    [SPELL_FAILED_NOT_BEHIND] = true,
    [SPELL_FAILED_TOO_CLOSE] = true,
    [SPELL_FAILED_CUSTOM_ERROR_162] = true
}

-- Hook the UI error frame
function VUI.Notifications.HookErrorsFrame()
    local module = VUI:GetModule("VUINotifications")
    if not module or not module.db then return end
    
    -- Create a filter function
    local function OnUIErrorMessage(_, messageType, message)
        -- If suppression is disabled or message is not in the list, return false to show it
        if not module.db.profile.suppressErrors or not suppressedErrors[message] then
            return false
        end
        
        -- Return true to suppress the message
        return true
    end
    
    -- Hook using UIErrorsFrame's SetEventHook if Dragonflight or newer
    if UIErrorsFrame.SetEventHook then
        pcall(function() UIErrorsFrame:SetEventHook(OnUIErrorMessage) end)
    else
        -- Fallback for older versions
        pcall(function() 
            local oldOnEvent = UIErrorsFrame:GetScript("OnEvent")
            UIErrorsFrame:SetScript("OnEvent", function(frame, event, ...)
                if event == "UI_ERROR_MESSAGE" then
                    local messageType, message = ...
                    if module.db.profile.suppressErrors and suppressedErrors[message] then
                        return
                    end
                end
                return oldOnEvent(frame, event, ...)
            end)
        end)
    end
end

-- Check if a custom error message should be suppressed
function VUI.Notifications.ShouldSuppressError(message)
    local module = VUI:GetModule("VUINotifications")
    if not module or not module.db then return false end
    
    return module.db.profile.suppressErrors and suppressedErrors[message]
end

-- Add an error to the suppression list
function VUI.Notifications.AddSuppressedError(errorMessage)
    suppressedErrors[errorMessage] = true
end

-- Remove an error from the suppression list
function VUI.Notifications.RemoveSuppressedError(errorMessage)
    suppressedErrors[errorMessage] = nil
end
