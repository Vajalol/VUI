local addonName, VUI = ...

-- Print notification to screen with specified color and size
function VUI.Notifications.print(text, color, size)
    local sizes = VUI.Notifications.Sizes()
    local R, G, B

    if color == nil then
        R, G, B = 1, 1, 1 -- white default
    else
        R, G, B = color["R"], color["G"], color["B"]
    end

    -- Check if notification is enabled in config
    if VUI_SavedVariables and VUI_SavedVariables.VUINotifications and
       VUI_SavedVariables.VUINotifications.enabled == false then
        return
    end

    if
        size == sizes.LARGE or
        size == sizes.BIG
    then
        -- Large notifications appear in the center of the screen
        ZoneTextString:SetText(text)
        PVPInfoTextString:SetText("")
        ZoneTextFrame.startTime = GetTime()
        ZoneTextFrame.fadeInTime = 0
        ZoneTextFrame.holdTime = 1
        ZoneTextFrame.fadeOutTime = 2
        ZoneTextString:SetTextColor(R, G, B)
        ZoneTextFrame:Show()
    else -- size == sizes.SMALL
        -- Small notifications appear in the error frame
        UIErrorsFrame:AddMessage(text, R, G, B)
    end
end

-- Play sound from the module's sound directory
function VUI.Notifications.playSound(sound)
    -- Check if sound is enabled in config
    if VUI_SavedVariables and VUI_SavedVariables.VUINotifications and
       VUI_SavedVariables.VUINotifications.soundsEnabled == false then
        return
    end
    
    PlaySoundFile("Interface\\AddOns\\VUI\\VModules\\VUINotifications\\sounds\\" .. sound .. ".mp3", "Master")
end