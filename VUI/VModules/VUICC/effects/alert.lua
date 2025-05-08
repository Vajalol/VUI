-- VUICC: Alert effect
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")

-- Play alert sound
local function playAlertSound(options)
    options = options or {}
    
    -- Handle volume option
    local volume = options.volume or 1
    
    -- Play the sound
    if options.sound then
        PlaySoundFile(options.sound, "SFX")
    else
        -- Default to a standard finish sound
        PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "SFX")
    end
end

-- Register the alert effect (plays a sound)
Module.FX:Register('alert', function(cooldown, options)
    playAlertSound(options)
end)