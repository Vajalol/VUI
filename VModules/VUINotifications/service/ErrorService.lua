local addonName, VUI = ...

-- Custom message handler for UIErrorsFrame to filter unwanted messages
function VUI.Notifications.ErrorsFrame_AddMessage(self, msg, ...)
    -- Check if error filtering is enabled in config
    if VUI_SavedVariables and VUI_SavedVariables.VUINotifications and
       VUI_SavedVariables.VUINotifications.suppressErrors == false then
        return self:Original_AddMessage(msg, ...)
    end
    
    if (VUI.Notifications.isEmpty(msg)) then
        msg = "unknown"
    end
    
    local lowermsg = string.lower(msg)
    local contains = VUI.Notifications.tableContains
    local standardErrorMessages = VUI.Notifications.standardErrorMessages()

    if (contains(standardErrorMessages, lowermsg)) then
        return
    end

    return self:Original_AddMessage(msg, ...)
end

-- Hook into the UIErrorsFrame to add our custom message handler
function VUI.Notifications.HookErrorsFrame()
    local ef = getglobal("UIErrorsFrame")
    ef.Original_AddMessage = ef.AddMessage
    ef.AddMessage = VUI.Notifications.ErrorsFrame_AddMessage
end

-- Helper function to check if a table contains a specific value
function VUI.Notifications.tableContains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
        
-- Helper function to check if a string is empty
function VUI.Notifications.isEmpty(msg)
  return msg == nil or msg == ''
end

-- List of standard error messages that will be suppressed
function VUI.Notifications.standardErrorMessages()
    return {
        "not enough", "not ready", "nothing to attack", "can't attack",
        "can't do", "unable to move", "must equip", "target is dead",
        "invalid target", "line of sight", "you are dead", "no target",
        "another action", "you are stunned", "wrong way", "out of range",
        "front of you", "you cannot attack", "too far away", "must be in",
        "too close", "requires combo", "in combat", "not in control",
        "must have", "nothing to dispel", "in an arena", "while pacified", "ready",
        "interrupted"
    }
end