local _, VUI = ...
VUI.SpellNotifications = VUI.SpellNotifications or {}
local SN = VUI.SpellNotifications
local L = VUI.L

-- Initialize the module
function SN:Initialize()
    -- Initialize settings with defaults
    self:InitializeSettings()
    
    -- Initialize event handling
    self:InitializeEvents()
    
    -- Register with VUI's module system
    VUI:RegisterModule("SpellNotifications", self)
end

-- TableContains helper function
function SN.TableContains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- IsEmpty helper function
function SN:IsEmpty(msg)
    return msg == nil or msg == ''
end

-- Print functions will be provided by NotifyService
function SN:Print(text, color, size)
    -- This will be implemented in NotifyService.lua
    if self.NotifyPrint then
        self:NotifyPrint(text, color, size)
    else
        -- Fallback implementation if NotifyService isn't loaded yet
        local settings = self:GetSettings()
        local textSize = settings.textSize
        local R, G, B

        if color == nil then
            R, G, B = 1, 1, 1 -- white default
        else
            R, G, B = color["R"], color["G"], color["B"]
        end

        if textSize == "LARGE" or textSize == "BIG" then
            ZoneTextString:SetText(text)
            PVPInfoTextString:SetText("")
            ZoneTextFrame.startTime = GetTime()
            ZoneTextFrame.fadeInTime = 0
            ZoneTextFrame.holdTime = 1
            ZoneTextFrame.fadeOutTime = 2
            ZoneTextString:SetTextColor(R, G, B)
            ZoneTextFrame:Show()
        else -- size == "SMALL"
            UIErrorsFrame:AddMessage(text, R, G, B)
        end
    end
end

-- Function to play notification sounds
function SN:PlaySound(sound)
    -- This will be implemented in NotifyService.lua
    if self.NotifyPlaySound then
        self:NotifyPlaySound(sound)
    else
        -- Fallback implementation if NotifyService isn't loaded yet
        local settings = self:GetSettings()
        if not settings.enableSounds then return end
        
        PlaySoundFile("Interface\\Addons\\VUI\\modules\\spellnotifications\\sounds\\" .. sound .. ".mp3", settings.soundChannel)
    end
end

-- Copy the OnEvent function from the original addon (we'll implement this later)
function SN:OnEvent(event, ...)
    -- Event handling logic will be implemented here
end

-- Hook into error frame
function SN:ErrorsFrame_AddMessage(self, msg, ...)
    if VUI.SpellNotifications:IsEmpty(msg) then
        msg = "unknown"
    end
    
    local lowermsg = string.lower(msg)
    local contains = VUI.SpellNotifications.TableContains
    local standardErrorMessages = VUI.SpellNotifications:StandardErrorMessages()

    if contains(standardErrorMessages, lowermsg) then
        return
    end

    return self.Original_AddMessage(self, msg, ...)
end

function SN:HookErrorsFrame()
    local ef = getglobal("UIErrorsFrame")
    ef.Original_AddMessage = ef.AddMessage
    ef.AddMessage = self.ErrorsFrame_AddMessage
end

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

-- Initialize the module when VUI loads
VUI:RegisterModule("SpellNotifications", SN)