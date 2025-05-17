local AddonName, VUI = ...

-- Ensure VUI global exists to prevent nil errors
if not VUI then VUI = {} end

-- Ensure the Notifications namespace exists
VUI.Notifications = VUI.Notifications or {}

-- List of error messages to suppress
local suppressedErrors = {}

-- Helper function to safely add error constants to the suppression list
local function AddErrorToSuppress(errorConstant)
    if errorConstant then  -- Only add if the constant exists
        suppressedErrors[errorConstant] = true
    end
end

-- Add standard WoW error messages to suppress
-- Use pcall to prevent errors if any constants are nil
pcall(function()
    AddErrorToSuppress(ERR_ABILITY_COOLDOWN)
    AddErrorToSuppress(ERR_ATTACK_CHARMED)
    AddErrorToSuppress(ERR_ATTACK_CONFUSED)
    AddErrorToSuppress(ERR_ATTACK_DEAD)
    AddErrorToSuppress(ERR_ATTACK_FLEEING)
    AddErrorToSuppress(ERR_ATTACK_PACIFIED)
    AddErrorToSuppress(ERR_ATTACK_STUNNED)
    AddErrorToSuppress(ERR_AUTOFOLLOW_TOO_FAR)
    AddErrorToSuppress(ERR_BADATTACKFACING)
    AddErrorToSuppress(ERR_BADATTACKPOS)
    AddErrorToSuppress(ERR_CLIENT_LOCKED_OUT)
    AddErrorToSuppress(ERR_GENERIC_NO_TARGET)
    AddErrorToSuppress(ERR_INVALID_ATTACK_TARGET)
    AddErrorToSuppress(ERR_ITEM_COOLDOWN)
    AddErrorToSuppress(ERR_NOEMOTEWHILERUNNING)
    AddErrorToSuppress(ERR_NOT_ENOUGH_MONEY)
    AddErrorToSuppress(ERR_NOT_IN_RANGE)
    AddErrorToSuppress(ERR_OUT_OF_ENERGY)
    AddErrorToSuppress(ERR_OUT_OF_FOCUS)
    AddErrorToSuppress(ERR_OUT_OF_HEALTH)
    AddErrorToSuppress(ERR_OUT_OF_MANA)
    AddErrorToSuppress(ERR_OUT_OF_RAGE)
    AddErrorToSuppress(ERR_OUT_OF_RANGE)
    AddErrorToSuppress(ERR_OUT_OF_RUNES)
    AddErrorToSuppress(ERR_OUT_OF_RUNIC_POWER)
    AddErrorToSuppress(ERR_SPELL_COOLDOWN)
    AddErrorToSuppress(ERR_SPELL_OUT_OF_RANGE)
    AddErrorToSuppress(ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS)
    AddErrorToSuppress(SPELL_FAILED_NOT_BEHIND)
    AddErrorToSuppress(SPELL_FAILED_TOO_CLOSE)
    AddErrorToSuppress(SPELL_FAILED_CUSTOM_ERROR_162)
end)

-- Also add common error message texts directly
local commonErrorMessages = {
    "You can't do that right now.",
    "Ability is not ready yet.",
    "You can't do that while moving!",
    "Can't attack while stunned.",
    "Can't attack while pacified.",
    "You are too far away!",
    "Can't attack while charmed.",
    "Target is too far away.",
    "Can't attack while dead.",
    "You cannot attack that target.",
    "Can't attack while confused.",
    "Item is not ready yet.",
    "You don't have enough money.",
    "You have no target.",
    "You are facing the wrong way!",
    "Can't attack while fleeing."
}

-- Add text-based error messages to the table
for _, message in ipairs(commonErrorMessages) do
    suppressedErrors[message] = true
end

-- Hook the UI error frame
function VUI.Notifications.HookErrorsFrame()
    -- Flag to track if error suppression is enabled
    local suppressErrorsEnabled = false
    
    -- Get the module reference safely
    local module = nil
    
    -- Try to get the module through VUI's GetModule function if available
    if VUI and type(VUI.GetModule) == "function" then
        local success, result = pcall(function() return VUI:GetModule("VUINotifications") end)
        if success and result then
            module = result
            -- Only set the flag if we successfully got the module and it has the db property with suppressErrors enabled
            if module and module.db and module.db.profile then
                suppressErrorsEnabled = module.db.profile.suppressErrors
            end
        end
    end
    
    -- If module doesn't exist or doesn't have a proper db, try to look for global settings
    if not module or not module.db then
        -- Try to find settings in VUI's global db if it exists
        if VUI.db and VUI.db.namespaces and VUI.db.namespaces.VUINotifications then
            local dbProfile = VUI.db.namespaces.VUINotifications.profile
            if dbProfile then
                suppressErrorsEnabled = dbProfile.suppressErrors
            end
        end
    end
    
    -- Create a filter function
    local function OnUIErrorMessage(_, messageType, message)
        -- If suppression is disabled or message is not in the list, return false to show it
        if not suppressErrorsEnabled or not suppressedErrors[message] then
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
                    if suppressErrorsEnabled and suppressedErrors[message] then
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
    -- Flag to track if error suppression is enabled
    local suppressErrorsEnabled = false
    
    -- Get the module reference safely
    local module = nil
    
    -- Try to get the module through VUI's GetModule function if available
    if VUI and type(VUI.GetModule) == "function" then
        local success, result = pcall(function() return VUI:GetModule("VUINotifications") end)
        if success and result then
            module = result
            -- Only set the flag if we successfully got the module and it has the db property with suppressErrors enabled
            if module and module.db and module.db.profile then
                suppressErrorsEnabled = module.db.profile.suppressErrors
            end
        end
    end
    
    -- If module doesn't exist or doesn't have a proper db, try to look for global settings
    if not module or not module.db then
        -- Try to find settings in VUI's global db if it exists
        if VUI.db and VUI.db.namespaces and VUI.db.namespaces.VUINotifications then
            local dbProfile = VUI.db.namespaces.VUINotifications.profile
            if dbProfile then
                suppressErrorsEnabled = dbProfile.suppressErrors
            end
        end
    end
    
    return suppressErrorsEnabled and suppressedErrors[message]
end

-- Add an error to the suppression list
function VUI.Notifications.AddSuppressedError(errorMessage)
    suppressedErrors[errorMessage] = true
end

-- Remove an error from the suppression list
function VUI.Notifications.RemoveSuppressedError(errorMessage)
    suppressedErrors[errorMessage] = nil
end
