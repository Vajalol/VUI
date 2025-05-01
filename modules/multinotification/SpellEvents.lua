--[[
    VUI - MultiNotification SpellEvents
    Version: 0.2.0
    Author: VortexQ8
    
    Spell event detection and handling for the unified notification system
]]

local _, VUI = ...
local MultiNotification = VUI:GetModule("MultiNotification")

-- Reference to spell lists
local SpellCategories = {}
local RoleCategories = {}
local CustomSpells = {}

-- Initialize spell event handling
function MultiNotification:InitializeSpellEvents()
    -- Register combat log events
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "ProcessCombatLogEvent")
    
    -- Initialize spell categories (from SpellNotifications)
    SpellCategories = {
        ["interrupt"] = "Interrupts",
        ["dispel"] = "Dispels",
        ["important"] = "Important Abilities",
        ["defensive"] = "Defensive Cooldowns",
        ["offensive"] = "Offensive Cooldowns",
        ["utility"] = "Utility Abilities",
        ["cc"] = "Crowd Control",
        ["healing"] = "Healing Abilities"
    }
    
    -- Initialize role categories
    RoleCategories = {
        ["ALL"] = "All Roles",
        ["TANK"] = "Tank",
        ["HEALER"] = "Healer",
        ["DAMAGER"] = "Damage Dealer",
        ["PVP"] = "PvP"
    }
    
    -- Import SpellNotifications spell list if available
    local SpellNotifications = VUI:GetModule("SpellNotifications")
    if SpellNotifications then
        -- Import existing spell lists
        if SpellNotifications.SpellCategories then
            SpellCategories = SpellNotifications.SpellCategories
        end
        
        if SpellNotifications.RoleCategories then
            RoleCategories = SpellNotifications.RoleCategories
        end
        
        if SpellNotifications.CustomSpells then
            CustomSpells = SpellNotifications.CustomSpells
        end
        
        if SpellNotifications.db and SpellNotifications.db.profile and SpellNotifications.db.profile.importantSpells then
            self.db.profile.importantSpells = SpellNotifications.db.profile.importantSpells
        end
    end
    
    -- Initialize spell settings if not already set
    if not self.db.profile.spellSettings then
        self.db.profile.spellSettings = {
            enabled = true,
            notifyAllInterrupts = true,
            notifyAllDispels = true,
            showSourceInfo = true,
            displayTime = 3,
            importantSpells = {},
            useFramePooling = true
        }
    end
    
    -- Copy important spells if not set
    if not self.db.profile.spellSettings.importantSpells then
        self.db.profile.spellSettings.importantSpells = {}
    end
    
    -- Make categories accessible
    self.SpellCategories = SpellCategories
    self.RoleCategories = RoleCategories
    self.CustomSpells = CustomSpells
    
    VUI:Print("MultiNotification spell event detection initialized")
end

-- Process combat log events
function MultiNotification:ProcessCombatLogEvent()
    -- Check if spell notifications are enabled
    if not self.db.profile.enabled or not self.db.profile.spellSettings.enabled then
        return
    end
    
    -- Get combat log info
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
    
    local playerGUID = UnitGUID("player")
    local notificationType = nil
    
    -- Process different types of player-initiated events
    if sourceGUID == playerGUID then
        -- Check for successful interrupts
        if subevent == "SPELL_INTERRUPT" then
            notificationType = "interrupt"
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "interrupt")
            if isImportant or self.db.profile.spellSettings.notifyAllInterrupts then
                self:ShowSpellNotification(spellID, sourceGUID, notificationType)
            end
        
        -- Check for successful dispels/purges
        elseif subevent == "SPELL_DISPEL" or subevent == "SPELL_STOLEN" then
            notificationType = "dispel"
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "dispel")
            if isImportant or self.db.profile.spellSettings.notifyAllDispels then
                self:ShowSpellNotification(spellID, sourceGUID, notificationType)
            end
        
        -- Check for important spell casts
        elseif subevent == "SPELL_CAST_SUCCESS" then
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "important")
            if isImportant then
                notificationType = "important"
                self:ShowSpellNotification(spellID, sourceGUID, notificationType)
            end
        end
    end
    
    -- For events targeting the player
    if destGUID == playerGUID then
        -- Check for important incoming spell casts
        if subevent == "SPELL_CAST_SUCCESS" then
            local isImportant, spellData = self:IsImportantSpell(spellID, "important")
            if isImportant then
                notificationType = "important"
                self:ShowSpellNotification(spellID, sourceGUID, notificationType)
            end
        end
    end
end

-- Check if a spell is in the important spells list
function MultiNotification:IsImportantSpell(spellID, category)
    if not spellID or not self.db.profile.spellSettings.importantSpells then return false end
    
    -- Check if spell is in the important spells list
    for _, spellData in pairs(self.db.profile.spellSettings.importantSpells) do
        if spellData.id == spellID and (not category or spellData.category == category) then
            return true, spellData
        end
    end
    
    return false
end

-- Show a spell notification
function MultiNotification:ShowSpellNotification(spellID, sourceGUID, notificationType, text)
    -- Get notification type settings
    local notificationSettings = self.db.profile.spellSettings
    
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
    if self.db.profile.spellSettings.showSourceInfo and sourceGUID then
        local sourceName = self:GetSourceNameFromGUID(sourceGUID)
        if sourceName then
            text = text .. " |cFFAAAAAA(" .. sourceName .. ")|r"
        end
    end
    
    -- Use the notification system to show the notification
    return self:ShowNotification(
        notificationType,
        icon,
        text,
        notificationSettings.displayTime or nil
    )
end

-- Helper function to get a readable source name from GUID
function MultiNotification:GetSourceNameFromGUID(guid)
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

-- Test notification function for spells
function MultiNotification:TestSpellNotification(spellID, spellType)
    if not spellID then
        VUI:Print("|cFFFF0000No spell ID specified for testing.|r")
        return
    end

    local spellName, _, spellIcon = GetSpellInfo(spellID)
    if not spellName then
        VUI:Print("|cFFFF0000Invalid spell ID:|r " .. tostring(spellID))
        return
    end
    
    VUI:Print("|cFF00FF00Testing notification for spell:|r " .. spellName .. " (ID: " .. spellID .. ")")
    VUI:Print("|cFF00FF00Type:|r " .. (spellType or "important"))
    
    -- Use the player's GUID as the source for test notifications
    local playerGUID = UnitGUID("player")
    self:ShowSpellNotification(spellID, playerGUID, spellType or "important")
end

-- Register the initialization to be called after module is enabled
MultiNotification:RegisterCallback("OnEnabled", function()
    MultiNotification:InitializeSpellEvents()
end)