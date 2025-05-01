-- VUI SpellNotifications MultiNotification Integration
-- Links the SpellNotifications module with the MultiNotification system
local _, VUI = ...

-- Get module references
local SpellNotifications = VUI:GetModule("SpellNotifications")

-- Helper function to check if the MultiNotification module is available
local function IsMultiNotificationAvailable()
    return VUI:GetModule("MultiNotification") ~= nil
end

-- Define the sole notification function that uses MultiNotification exclusively
function SpellNotifications:ShowNotification(spellID, sourceGUID, notificationType, text)
    -- Check for MultiNotification module
    if not IsMultiNotificationAvailable() then
        VUI:Print("|cFFFF0000Error:|r MultiNotification module is required but not available.")
        return nil
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
    
    -- Add source unit information if available and enabled
    if self.db.profile.showSourceInfo and sourceGUID then
        local sourceName = self:GetSourceNameFromGUID(sourceGUID)
        if sourceName then
            text = text .. " |cFFAAAAAA(" .. sourceName .. ")|r"
        end
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

-- Helper function to get a readable source name from GUID
function SpellNotifications:GetSourceNameFromGUID(guid)
    if not guid then return nil end
    
    local name
    -- Try to get name from GUID using different methods
    if UnitExists("target") and UnitGUID("target") == guid then
        name = UnitName("target")
    elseif UnitExists("focus") and UnitGUID("focus") == guid then
        name = UnitName("focus")
    else
        -- Check group members
        for i = 1, GetNumGroupMembers() do
            local unit = IsInRaid() and "raid"..i or "party"..i
            if UnitExists(unit) and UnitGUID(unit) == guid then
                name = UnitName(unit)
                break
            end
        end
    end
    
    return name
end

-- Initialize integration
function SpellNotifications:InitializeMultiNotificationIntegration()
    if not IsMultiNotificationAvailable() then
        self:Print("|cFFFF0000Error:|r MultiNotification module is required but not available.")
        return
    end
    
    -- Ensure we have a dependency on MultiNotification
    VUI:AddModuleDependency("SpellNotifications", "MultiNotification")
    
    self:Print("SpellNotifications fully integrated with MultiNotification system")
end

-- Register the integration to be initialized after modules
VUI:RegisterCallback("ModulesInitialized", function()
    if SpellNotifications and SpellNotifications.InitializeMultiNotificationIntegration then
        SpellNotifications:InitializeMultiNotificationIntegration()
    end
end)