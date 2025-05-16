local AddonName, VUI = ...

-- Define module reference
local M = VUI:GetModule("VUINotifications")

-- Ensure the Notifications namespace exists
VUI.Notifications = VUI.Notifications or {}

-- Create a print function that can work with VUI's notification system
function VUI.Notifications.print(text, color, size)
    local sizes = VUI.Notifications.Sizes and VUI.Notifications.Sizes() or {SMALL = "small", LARGE = "large"}
    local R, G, B

    if color == nil then
        R, G, B = 1, 1, 1 -- white default
    else
        R, G, B = color["R"], color["G"], color["B"]
    end

    -- Get the module reference
    local module = VUI:GetModule("VUINotifications")
    
    -- If we have access to the module's ShowNotification function, use it
    if module and module.ShowNotification then
        local notificationType = "miss" -- default type
        
        -- Determine the notification type based on color
        if color then
            if color["R"] == 0 and color["G"] == 1 and color["B"] == 0 then
                notificationType = "interrupt"
            elseif color["R"] == 1 and color["G"] == 1 and color["B"] == 0 then
                notificationType = "dispel"
            elseif color["R"] == 1 and color["G"] == 0 and color["B"] == 0 then
                notificationType = "pet"
            elseif color["R"] == 0 and color["G"] == 0.5 and color["B"] == 1 then
                notificationType = "reflect"
            end
        end
        
        module:ShowNotification(text, notificationType)
        return
    end

    -- Fallback to default behavior if module is not available
    if size == sizes.LARGE or size == sizes.BIG then
        ZoneTextString:SetText(text);
        PVPInfoTextString:SetText("");
        ZoneTextFrame.startTime = GetTime()
        ZoneTextFrame.fadeInTime = 0
        ZoneTextFrame.holdTime = 1
        ZoneTextFrame.fadeOutTime = 2
        ZoneTextString:SetTextColor(R, G, B);
        ZoneTextFrame:Show()
    else -- size == sizes.SMALL
        UIErrorsFrame:AddMessage(text, R, G, B);
    end
end

-- Play sound function that works with VUI's sound system
function VUI.Notifications.playSound(sound)
    -- Try to use VUI's module first if available
    local module = VUI:GetModule("VUINotifications")
    if module and module.PlaySound then
        pcall(function() module:PlaySound(sound) end)
        return
    end
    
    -- Otherwise, use direct sound file path with correct VUI path
    local soundPath = "Interface\\AddOns\\VUI\\VModules\\VUINotifications\\sounds\\" .. sound .. ".mp3"
    
    -- Use pcall to handle errors
    if not pcall(function() PlaySoundFile(soundPath, "Master") end) then
        -- Fallback: try original sound path
        pcall(function() PlaySoundFile("Interface\\AddOns\\VUI\\VUIorginalcopy\\SpellNotifications\\sounds\\" .. sound .. ".mp3", "Master") end)
    end
end

-- Add initialization function
function VUI.Notifications.Initialize()
    -- Ensure the module exists
    local module = VUI:GetModule("VUINotifications")
    if not module then return end
    
    -- Link up the addon table to the module for backwards compatibility
    if _G["SpellNotifications"] then
        _G["SpellNotifications"].print = VUI.Notifications.print
        _G["SpellNotifications"].playSound = VUI.Notifications.playSound
    end
end
