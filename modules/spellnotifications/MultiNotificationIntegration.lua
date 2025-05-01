-- VUI SpellNotifications MultiNotification Integration
-- Links the SpellNotifications module with the MultiNotification system
local _, VUI = ...

-- Get module references
local SpellNotifications = VUI:GetModule("SpellNotifications")

-- Helper function to check if the MultiNotification module is available
local function IsMultiNotificationAvailable()
    return VUI:GetModule("MultiNotification") ~= nil
end

-- Store the original ShowNotification function
local originalShowNotification = SpellNotifications.ShowNotification

-- Override the ShowNotification function to use MultiNotification when available
function SpellNotifications:ShowNotification(spellID, notificationType, text)
    -- If MultiNotification is not available or is disabled, fall back to original notification system
    if not IsMultiNotificationAvailable() or not VUI.MultiNotification.db.profile.enabled then
        return originalShowNotification(self, spellID, notificationType, text)
    end
    
    -- Get notification type settings
    local notificationSettings = self.db.profile
    
    -- Map notificationType to MultiNotification category
    local category = notificationType or "spell_notification"
    
    -- Get spell icon
    local icon = spellID
    if type(spellID) == "number" then
        icon = GetSpellTexture(spellID) or spellID
    end
    
    -- Get spell name if text is not provided
    if not text and type(spellID) == "number" then
        local spellName = GetSpellInfo(spellID)
        text = spellName or tostring(spellID)
    end
    
    -- Use the MultiNotification system to show the notification
    local notification = VUI.MultiNotification:AddNotification(
        category,
        icon,
        text,
        notificationSettings.displayTime or nil
    )
    
    -- Return the created notification for further customization if needed
    return notification
end

-- Initialize integration
function SpellNotifications:InitializeMultiNotificationIntegration()
    if not IsMultiNotificationAvailable() then
        self:Print("MultiNotification module not available, using original notification system")
        return
    end
    
    self:Print("SpellNotifications integrated with MultiNotification system")
end

-- Register the integration to be initialized after modules
VUI:RegisterCallback("ModulesInitialized", function()
    if SpellNotifications and SpellNotifications.InitializeMultiNotificationIntegration then
        SpellNotifications:InitializeMultiNotificationIntegration()
    end
end)