--[[
    VUI - MultiNotification SpellEvents
    Version: 1.0.0
    Author: VortexQ8
    
    Combat log event handler for the MultiNotification system.
    Detects and processes spell events for notifications.
]]

local _, VUI = ...
local MultiNotification = VUI:GetModule("MultiNotification")

-- Default spell categories
MultiNotification.SpellCategories = {
    ["interrupt"] = "Interrupt",
    ["dispel"] = "Dispel",
    ["important"] = "Important",
    ["defensive"] = "Defensive Cooldowns",
    ["offensive"] = "Offensive Cooldowns",
    ["utility"] = "Utility Abilities",
    ["cc"] = "Crowd Control",
    ["healing"] = "Healing Abilities"
}

-- Role categories for filtering
MultiNotification.RoleCategories = {
    ["ALL"] = "All Roles",
    ["TANK"] = "Tank",
    ["HEALER"] = "Healer",
    ["DAMAGER"] = "Damage Dealer",
    ["PVP"] = "PvP"
}

-- Initialize spell event tracking
function MultiNotification:InitializeSpellEvents()
    -- Create default database structure if it doesn't exist
    if not self.db.profile.spellSettings then
        self.db.profile.spellSettings = {
            importantSpells = {},
            enableSpellNotifications = true,
            showMyInterrupts = true,
            showOtherInterrupts = true,
            showMyDispels = true,
            showOtherDispels = true,
            showImportantSpells = true,
            soundEnabled = true,
            importantSoundFile = "important", -- This will reference a sound in our media system
            interruptSoundFile = "interrupt",
            dispelSoundFile = "dispel",
            priorityThreshold = 2, -- Medium priority or higher get notifications
        }
    end

    -- Define event filters
    self.eventFilterList = {
        ["SPELL_INTERRUPT"] = true,
        ["SPELL_DISPEL"] = true,
        ["SPELL_STOLEN"] = true,
        ["SPELL_CAST_SUCCESS"] = true,
        ["SPELL_AURA_APPLIED"] = true,
        ["SPELL_SUMMON"] = true,
    }
    
    -- Register combat log event handler
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEvent")
    
    -- Load built-in important spells if we haven't already
    self:LoadPredefinedSpells()
end

-- Loads predetermined important spells
function MultiNotification:LoadPredefinedSpells()
    if self.predefinedSpellsLoaded then return end
    
    -- Table of predetermined important spells organized by categories
    local predefinedSpells = {
        -- Interrupts (just a few examples)
        [1766] = { type = "interrupt", name = "Kick", class = "ROGUE", priority = 2 },
        [2139] = { type = "interrupt", name = "Counterspell", class = "MAGE", priority = 2 },
        [6552] = { type = "interrupt", name = "Pummel", class = "WARRIOR", priority = 2 },
        
        -- Dispels (examples)
        [4987] = { type = "dispel", name = "Cleanse", class = "PALADIN", priority = 2 },
        [88423] = { type = "dispel", name = "Nature's Cure", class = "DRUID", priority = 2 },
        [115450] = { type = "dispel", name = "Detox", class = "MONK", priority = 2 },
        
        -- Important defensive cooldowns (examples)
        [31884] = { type = "defensive", name = "Avenging Wrath", class = "PALADIN", priority = 3 },
        [47788] = { type = "defensive", name = "Guardian Spirit", class = "PRIEST", priority = 3 },
        [33206] = { type = "defensive", name = "Pain Suppression", class = "PRIEST", priority = 3 },
        
        -- Important offensive cooldowns (examples)
        [190319] = { type = "offensive", name = "Combustion", class = "MAGE", priority = 2 },
        [12472] = { type = "offensive", name = "Icy Veins", class = "MAGE", priority = 2 },
        [1719] = { type = "offensive", name = "Recklessness", class = "WARRIOR", priority = 2 },
        
        -- Crowd control abilities (examples)
        [605] = { type = "cc", name = "Mind Control", class = "PRIEST", priority = 2 },
        [118] = { type = "cc", name = "Polymorph", class = "MAGE", priority = 2 },
        [51514] = { type = "cc", name = "Hex", class = "SHAMAN", priority = 2 },
    }
    
    -- Merge predefined spells with user-defined ones
    for spellID, data in pairs(predefinedSpells) do
        if not self.db.profile.spellSettings.importantSpells[spellID] then
            -- Add name and icon information
            local name, _, icon = GetSpellInfo(spellID)
            if name then
                data.name = name
                data.icon = icon
                data.id = spellID
                data.roles = {"ALL"} -- Default to all roles
                self.db.profile.spellSettings.importantSpells[spellID] = data
            end
        end
    end
    
    self.predefinedSpellsLoaded = true
end

-- Main combat log event handler
function MultiNotification:OnCombatLogEvent()
    -- Extract the combat log parameters
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()
    
    -- Skip if not in our event filter list
    if not self.eventFilterList[event] then return end
    
    -- Skip if spell notifications are disabled
    if not self.db.profile.spellSettings.enableSpellNotifications then return end
    
    -- Determine source player type (is it me, friendly player, hostile player, etc.)
    local isPlayer = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    local isMe = sourceGUID == UnitGUID("player")
    local isFriendly = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
    
    -- Handle interrupts
    if event == "SPELL_INTERRUPT" then
        if (isMe and self.db.profile.spellSettings.showMyInterrupts) or 
           (not isMe and isFriendly and self.db.profile.spellSettings.showOtherInterrupts) then
            -- Format player name (colorize based on class for players)
            local playerName = self:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
            
            -- Create the notification text
            local text = playerName .. " interrupted " .. destName .. "'s " .. extraSpellName
            
            -- Display the notification
            self:ShowSpellNotification(
                spellName,          -- Title
                text,               -- Message 
                spellID,            -- Spell ID for icon
                "interrupt",        -- Category
                self.db.profile.spellSettings.interruptSoundFile -- Sound
            )
        end
        return
    end
    
    -- Handle dispels and spell steals
    if event == "SPELL_DISPEL" or event == "SPELL_STOLEN" then
        if (isMe and self.db.profile.spellSettings.showMyDispels) or 
           (not isMe and isFriendly and self.db.profile.spellSettings.showOtherDispels) then
            -- Format player name
            local playerName = self:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
            
            -- Create the notification text
            local action = event == "SPELL_DISPEL" and "dispelled" or "stole"
            local text = playerName .. " " .. action .. " " .. destName .. "'s " .. extraSpellName
            
            -- Display the notification
            self:ShowSpellNotification(
                spellName,          -- Title
                text,               -- Message
                spellID,            -- Spell ID for icon
                "dispel",           -- Category
                self.db.profile.spellSettings.dispelSoundFile -- Sound
            )
        end
        return
    end
    
    -- Check for important spells
    if self.db.profile.spellSettings.showImportantSpells and 
       (event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" or event == "SPELL_SUMMON") and
       isPlayer then
        
        -- Check if this is an important spell we want to track
        local spellData = self.db.profile.spellSettings.importantSpells[spellID]
        if spellData then
            -- Check priority threshold
            if spellData.priority < self.db.profile.spellSettings.priorityThreshold then
                return
            end
            
            -- Format player name
            local playerName = self:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
            
            -- Create notification text
            local text
            if destName and destName ~= sourceName and destGUID ~= sourceGUID then
                text = playerName .. " used " .. spellName .. " on " .. destName
            else
                text = playerName .. " used " .. spellName
            end
            
            -- Display the notification
            self:ShowSpellNotification(
                spellName,          -- Title
                text,               -- Message
                spellID,            -- Spell ID for icon
                spellData.type,     -- Category
                self.db.profile.spellSettings.importantSoundFile -- Sound
            )
        end
    end
end

-- Helper function to format player names with class colors
function MultiNotification:FormatPlayerName(name, flags, raidFlags)
    if not name then return "Unknown" end
    
    -- Check if this is a player
    local isPlayer = bit.band(flags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    
    if isPlayer then
        -- Try to get class color
        local _, className, classID
        
        -- Check if it's the player or someone in their group
        if name == UnitName("player") then
            _, className = UnitClass("player")
        else
            -- Try to find the player in the group
            for i = 1, GetNumGroupMembers() do
                local unit = IsInRaid() and "raid"..i or "party"..i
                if UnitExists(unit) and UnitName(unit) == name then
                    _, className = UnitClass(unit)
                    break
                end
            end
        end
        
        -- Apply class color if available
        if className and RAID_CLASS_COLORS[className] then
            local color = RAID_CLASS_COLORS[className]
            return string.format("|cff%02x%02x%02x%s|r", 
                color.r * 255, 
                color.g * 255, 
                color.b * 255, 
                name)
        end
    end
    
    -- If we couldn't apply class color, return the name as is
    return name
end

-- Function to show a test notification for a specific spell
function MultiNotification:TestSpellNotification(spellID, spellType)
    if not spellID then return end
    
    local name, _, icon = GetSpellInfo(spellID)
    if not name then
        VUI:Print("|cFFFF0000Invalid spell ID.|r")
        return
    end
    
    local text = "This is a test notification for " .. name
    local soundFile
    
    -- Determine sound file based on spell type
    if spellType == "interrupt" then
        soundFile = self.db.profile.spellSettings.interruptSoundFile
    elseif spellType == "dispel" then
        soundFile = self.db.profile.spellSettings.dispelSoundFile
    else
        soundFile = self.db.profile.spellSettings.importantSoundFile
    end
    
    -- Show the test notification
    self:ShowSpellNotification(
        name .. " (Test)",   -- Title
        text,                -- Message
        spellID,             -- Spell ID for icon
        spellType or "important", -- Category
        soundFile,           -- Sound
        8                    -- Duration (longer for testing)
    )
    
    VUI:Print("|cFF00FF00Test notification sent for|r " .. name)
end

-- Helper function to filter spells based on criteria
function MultiNotification:FilterSpells(options)
    local spells = self:GetAllImportantSpells()
    local filteredSpells = {}
    
    -- Default options
    options = options or {}
    options.type = options.type or "all"
    options.role = options.role or "ALL"
    options.customOnly = options.customOnly or false
    
    for id, data in pairs(spells) do
        local includeSpell = true
        
        -- Filter by type
        if options.type ~= "all" and data.type ~= options.type then
            includeSpell = false
        end
        
        -- Filter by role
        if options.role ~= "ALL" and data.roles then
            local hasRole = false
            for _, role in ipairs(data.roles) do
                if role == "ALL" or role == options.role then
                    hasRole = true
                    break
                end
            end
            if not hasRole then includeSpell = false end
        end
        
        -- Filter by class
        if options.class and data.class and data.class ~= options.class then
            includeSpell = false
        end
        
        -- Filter by custom flag
        if options.customOnly and not data.custom then
            includeSpell = false
        end
        
        if includeSpell then
            filteredSpells[id] = data
        end
    end
    
    return filteredSpells
end

-- Register this file to be loaded with the module
VUI:RegisterModuleScript("MultiNotification", "SpellEvents")