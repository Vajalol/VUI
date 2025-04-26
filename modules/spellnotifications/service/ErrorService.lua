local _, VUI = ...
local SN = VUI.SpellNotifications

-- Updated error frame message handler
function SN:ErrorsFrameAddMessage(self, msg, ...)
    if SN:IsEmpty(msg) then
        msg = "unknown"
    end
    
    local lowermsg = string.lower(msg)
    local contains = SN.TableContains
    local standardErrorMessages = SN:StandardErrorMessages()

    if contains(standardErrorMessages, lowermsg) then
        return
    end

    return self.Original_AddMessage(self, msg, ...)
end

-- Hook into the error frame
function SN:HookErrorsFrame()
    -- Only hook if not already hooked
    local ef = getglobal("UIErrorsFrame")
    if not ef.Original_AddMessage then
        ef.Original_AddMessage = ef.AddMessage
        ef.AddMessage = function(self, msg, ...) 
            return SN:ErrorsFrameAddMessage(self, msg, ...) 
        end
    end
end

-- List of standard error messages to filter out
function SN:StandardErrorMessages()
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