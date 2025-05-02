--[[
    VUI - MultiNotification Enhanced Spell Detection
    Author: VortexQ8
    
    Advanced spell detection with performance optimizations:
    - Smart filtering of combat events
    - Improved handling of spell prediction
    - Better prioritization of important spells
    - Integration with core optimization systems
]]

local _, VUI = ...
local MultiNotification = VUI:GetModule("MultiNotification")

-- Helper tables
local SpellPriorities = {}     -- Stores spell priorities for quick lookup
local ClassColors = {}         -- Cached class colors for performance
local PlayerCache = {}         -- Cache player lookup info
local EventHistory = {}        -- Tracks event history for smart filtering
local RecentTargets = {}       -- Recent spell targets for merging similar events
local SpecSpellMapping = {}    -- Specialization to important spells mapping

-- Performance metrics - disabled in production release
local Metrics = {
    eventsProcessed = 0,       -- Total events processed
    eventsFiltered = 0,        -- Events filtered out
    notificationsShown = 0,    -- Notifications displayed
    duplicatesMerged = 0,      -- Similar events merged
    lastReset = GetTime(),     -- Last metrics reset
    enabled = false            -- Metrics collection disabled in production
}

-- Configuration
local Config = {
    smartFiltering = true,     -- Enables intelligent event filtering
    combatOptimization = true, -- Extra optimizations during combat
    eventMerging = true,       -- Merges similar events 
    predictiveLoading = true,  -- Preloads likely spells based on group composition
    debugMode = false          -- Debug mode disabled in production release
}

-- Initialize enhanced spell detection
function MultiNotification:InitializeEnhancedSpellDetection()
    -- Register integration with core spell detection optimization
    self:RegisterCoreOptimizationIntegration()
    
    -- Set up event preprocessing
    self:SetupEventPreprocessing()
    
    -- Initialize player class cache
    self:InitializePlayerCache()
    
    -- Register for spec change events for predictive loading
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnSpecializationChanged")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateGroupCache")
    
    -- Set up spec to important spell mapping
    self:InitializeSpecSpellMapping()
    
    -- Metrics reporting disabled in production release
    
    -- Flag as initialized
    self.enhancedSpellDetectionInitialized = true
    
    -- Initialization message disabled in production release
end

-- Register integration with core spell detection optimization
function MultiNotification:RegisterCoreOptimizationIntegration()
    -- Check if core optimization is available and initialize if needed
    if VUI.SpellDetectionOptimization and not VUI.SpellDetectionOptimization.initialized then
        VUI.SpellDetectionOptimization:Initialize()
    end
    
    -- Register for notifications from core optimization
    if VUI.SpellDetectionOptimization then
        VUI:RegisterCallback("SPELL_DETECTION_OPTIMIZED", function(event, module, data)
            if module == "MultiNotification" then
                -- Update our settings from core optimization
                Config.smartFiltering = data.smartFiltering or Config.smartFiltering
                Config.combatOptimization = data.combatOptimization or Config.combatOptimization
                Config.eventMerging = data.eventMerging or Config.eventMerging
                Config.predictiveLoading = data.predictiveLoading or Config.predictiveLoading
                Config.debugMode = data.debugMode or Config.debugMode
            end
        end)
    end
end

-- Set up enhanced event preprocessing
function MultiNotification:SetupEventPreprocessing()
    -- Store original method for later reference
    if not self.originalOnCombatLogEvent then
        self.originalOnCombatLogEvent = self.OnCombatLogEvent
    end
    
    -- Replace with optimized version if core optimization isn't handling it
    if not VUI.SpellDetectionOptimization or not VUI.SpellDetectionOptimization.initialized then
        self.OnCombatLogEvent = function(...)
            return self:EnhancedCombatLogEvent(...)
        end
    end
end

-- Enhanced combat log event handler
function MultiNotification:EnhancedCombatLogEvent()
    -- Extract the combat log parameters
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()
    
    -- Track metrics
    Metrics.eventsProcessed = Metrics.eventsProcessed + 1
    
    -- Skip if not in our event filter list
    if not self.eventFilterList[event] then 
        Metrics.eventsFiltered = Metrics.eventsFiltered + 1
        return 
    end
    
    -- Skip if spell notifications are disabled
    if not self.db.profile.spellSettings.enableSpellNotifications then return end
    
    -- Smart filtering based on event type and situation
    if Config.smartFiltering and self:ShouldFilterEvent(event, sourceGUID, spellID, timestamp) then
        Metrics.eventsFiltered = Metrics.eventsFiltered + 1
        return
    end
    
    -- Determine source player type (is it me, friendly player, hostile player, etc.)
    local isPlayer = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    local isMe = sourceGUID == UnitGUID("player")
    local isFriendly = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
    
    -- Process by event type
    if event == "SPELL_INTERRUPT" then
        self:ProcessInterruptWithEnhancements(isMe, isFriendly, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName)
    elseif event == "SPELL_DISPEL" or event == "SPELL_STOLEN" then
        self:ProcessDispelWithEnhancements(event, isMe, isFriendly, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName)
    elseif self.db.profile.spellSettings.showImportantSpells and
           (event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" or event == "SPELL_SUMMON") and
           isPlayer then
        self:ProcessImportantSpellWithEnhancements(sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, spellID, spellName)
    end
    
    -- Record event history for smart filtering
    self:RecordEventHistory(event, sourceGUID, spellID, timestamp)
end

-- Smart event filtering based on various factors
function MultiNotification:ShouldFilterEvent(event, sourceGUID, spellID, timestamp)
    -- Don't filter interrupts and dispels, they're always important
    if event == "SPELL_INTERRUPT" or event == "SPELL_DISPEL" or event == "SPELL_STOLEN" then
        return false
    end
    
    -- Check event history to see if we've seen this recently (throttle repetitive events)
    local eventKey = sourceGUID .. "_" .. spellID
    local lastTime = EventHistory[eventKey]
    
    if lastTime and (timestamp - lastTime) < 2.0 then
        -- Same event from same source within 2 seconds, filter it
        return true
    end
    
    -- Additional filtering in combat if enabled
    if Config.combatOptimization and InCombatLockdown() then
        -- Check spell priority for this spell
        local priority = SpellPriorities[spellID]
        
        -- If it's a low priority spell (or unknown) during combat, we may filter it
        -- based on combat intensity (more filtering during intense combat)
        if not priority or priority < 2 then
            -- Simple heuristic: if we're getting more than 10 events per second, filter low priority
            local eventRate = Metrics.eventsProcessed / (GetTime() - Metrics.lastReset)
            if eventRate > 10 then
                return true
            end
        end
    end
    
    return false
end

-- Record event history for smart filtering
function MultiNotification:RecordEventHistory(event, sourceGUID, spellID, timestamp)
    local eventKey = sourceGUID .. "_" .. spellID
    EventHistory[eventKey] = timestamp
    
    -- Clean up old history entries (older than 5 seconds)
    if #EventHistory > 100 then -- Arbitrary cleanup threshold
        for key, time in pairs(EventHistory) do
            if timestamp - time > 5.0 then
                EventHistory[key] = nil
            end
        end
    end
end

-- Process interrupts with enhancements
function MultiNotification:ProcessInterruptWithEnhancements(isMe, isFriendly, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName)
    if (isMe and self.db.profile.spellSettings.showMyInterrupts) or 
       (not isMe and isFriendly and self.db.profile.spellSettings.showOtherInterrupts) then
        
        -- Check for similar recent notifications to merge
        if Config.eventMerging and self:ShouldMergeInterruptEvent(sourceGUID, destGUID) then
            Metrics.duplicatesMerged = Metrics.duplicatesMerged + 1
            return
        end
        
        -- Format player name with optimized coloring
        local playerName = self:GetCachedPlayerName(sourceName, sourceFlags, sourceRaidFlags)
        
        -- Create the notification text
        local text = playerName .. " interrupted " .. destName .. "'s " .. extraSpellName
        
        -- Display the notification
        local success = self:ShowSpellNotification(
            spellName,          -- Title
            text,               -- Message 
            spellID,            -- Spell ID for icon
            "interrupt",        -- Category
            self.db.profile.spellSettings.interruptSoundFile -- Sound
        )
        
        if success then
            Metrics.notificationsShown = Metrics.notificationsShown + 1
            
            -- Record for merging similar events
            if Config.eventMerging then
                RecentTargets[destGUID] = {
                    type = "interrupt",
                    sourceGUID = sourceGUID,
                    timestamp = GetTime()
                }
            end
        end
    end
end

-- Process dispels and spell steals with enhancements
function MultiNotification:ProcessDispelWithEnhancements(event, isMe, isFriendly, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName)
    if (isMe and self.db.profile.spellSettings.showMyDispels) or 
       (not isMe and isFriendly and self.db.profile.spellSettings.showOtherDispels) then
        
        -- Check for similar recent notifications to merge
        if Config.eventMerging and self:ShouldMergeDispelEvent(sourceGUID, destGUID, event) then
            Metrics.duplicatesMerged = Metrics.duplicatesMerged + 1
            return
        end
        
        -- Format player name with optimized coloring
        local playerName = self:GetCachedPlayerName(sourceName, sourceFlags, sourceRaidFlags)
        
        -- Create the notification text
        local action = event == "SPELL_DISPEL" and "dispelled" or "stole"
        local text = playerName .. " " .. action .. " " .. destName .. "'s " .. extraSpellName
        
        -- Display the notification
        local success = self:ShowSpellNotification(
            spellName,          -- Title
            text,               -- Message
            spellID,            -- Spell ID for icon
            "dispel",           -- Category
            self.db.profile.spellSettings.dispelSoundFile -- Sound
        )
        
        if success then
            Metrics.notificationsShown = Metrics.notificationsShown + 1
            
            -- Record for merging similar events
            if Config.eventMerging then
                RecentTargets[destGUID] = {
                    type = event == "SPELL_DISPEL" and "dispel" or "steal",
                    sourceGUID = sourceGUID,
                    timestamp = GetTime()
                }
            end
        end
    end
end

-- Process important spells with enhancements
function MultiNotification:ProcessImportantSpellWithEnhancements(sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, spellID, spellName)
    -- Check if this is an important spell we want to track
    local spellData = self.db.profile.spellSettings.importantSpells[spellID]
    if not spellData then return end
    
    -- Check priority threshold
    if spellData.priority < self.db.profile.spellSettings.priorityThreshold then
        return
    end
    
    -- Cache spell priority for future filtering
    SpellPriorities[spellID] = spellData.priority
    
    -- Check for similar recent notifications to merge
    if Config.eventMerging and self:ShouldMergeImportantSpellEvent(sourceGUID, spellID) then
        Metrics.duplicatesMerged = Metrics.duplicatesMerged + 1
        return
    end
    
    -- Format player name with optimized coloring
    local playerName = self:GetCachedPlayerName(sourceName, sourceFlags, sourceRaidFlags)
    
    -- Create notification text
    local text
    if destName and destName ~= sourceName and destGUID ~= sourceGUID then
        text = playerName .. " used " .. spellName .. " on " .. destName
    else
        text = playerName .. " used " .. spellName
    end
    
    -- Display the notification
    local success = self:ShowSpellNotification(
        spellName,          -- Title
        text,               -- Message
        spellID,            -- Spell ID for icon
        spellData.type,     -- Category
        self.db.profile.spellSettings.importantSoundFile -- Sound
    )
    
    if success then
        Metrics.notificationsShown = Metrics.notificationsShown + 1
        
        -- Record for merging similar events
        if Config.eventMerging then
            local key = sourceGUID .. "_" .. spellID
            RecentTargets[key] = {
                type = "spell",
                sourceGUID = sourceGUID,
                spellID = spellID,
                timestamp = GetTime()
            }
        end
    end
end

-- Check if we should merge similar interrupt events
function MultiNotification:ShouldMergeInterruptEvent(sourceGUID, destGUID)
    local recentInfo = RecentTargets[destGUID]
    if recentInfo and recentInfo.type == "interrupt" and recentInfo.sourceGUID == sourceGUID then
        -- If same source interrupted same target within 1 second, merge the events
        if GetTime() - recentInfo.timestamp < 1.0 then
            return true
        end
    end
    return false
end

-- Check if we should merge similar dispel events
function MultiNotification:ShouldMergeDispelEvent(sourceGUID, destGUID, eventType)
    local eventCategory = eventType == "SPELL_DISPEL" and "dispel" or "steal"
    local recentInfo = RecentTargets[destGUID]
    
    if recentInfo and recentInfo.type == eventCategory and recentInfo.sourceGUID == sourceGUID then
        -- If same source dispelled/stole from same target within 1 second, merge the events
        if GetTime() - recentInfo.timestamp < 1.0 then
            return true
        end
    end
    return false
end

-- Check if we should merge similar important spell events
function MultiNotification:ShouldMergeImportantSpellEvent(sourceGUID, spellID)
    local key = sourceGUID .. "_" .. spellID
    local recentInfo = RecentTargets[key]
    
    if recentInfo and recentInfo.type == "spell" and 
       recentInfo.sourceGUID == sourceGUID and 
       recentInfo.spellID == spellID then
        -- If same source cast same spell within 2 seconds, merge the events
        if GetTime() - recentInfo.timestamp < 2.0 then
            return true
        end
    end
    return false
end

-- Cache player name with class coloring for better performance
function MultiNotification:GetCachedPlayerName(name, flags, raidFlags)
    if not name then return "Unknown" end
    
    -- Check if we have this name cached
    if PlayerCache[name] then
        return PlayerCache[name]
    end
    
    -- Not cached, format and cache it
    local formattedName = self:FormatPlayerName(name, flags, raidFlags)
    PlayerCache[name] = formattedName
    
    return formattedName
end

-- Initialize player cache with current group
function MultiNotification:InitializePlayerCache()
    -- Cache player class first
    local _, className = UnitClass("player")
    if className and RAID_CLASS_COLORS[className] then
        local color = RAID_CLASS_COLORS[className]
        local playerName = UnitName("player")
        PlayerCache[playerName] = string.format("|cff%02x%02x%02x%s|r", 
            color.r * 255, 
            color.g * 255, 
            color.b * 255, 
            playerName)
    end
    
    -- Cache group members
    self:UpdateGroupCache()
    
    -- Periodically clean cache to prevent memory bloat
    C_Timer.After(300, function() self:CleanPlayerCache() end)
end

-- Update group member cache when roster changes
function MultiNotification:UpdateGroupCache()
    -- Cache classes of group members
    local numMembers = GetNumGroupMembers()
    local unit = IsInRaid() and "raid" or "party"
    
    for i = 1, numMembers do
        local unitID = unit..i
        if UnitExists(unitID) then
            local name = UnitName(unitID)
            local _, className = UnitClass(unitID)
            
            if name and className and RAID_CLASS_COLORS[className] then
                local color = RAID_CLASS_COLORS[className]
                PlayerCache[name] = string.format("|cff%02x%02x%02x%s|r", 
                    color.r * 255, 
                    color.g * 255, 
                    color.b * 255, 
                    name)
            end
        end
    end
    
    -- If predictive loading is enabled, update based on group composition
    if Config.predictiveLoading then
        self:PreloadSpellsForGroup()
    end
end

-- Clean player cache periodically
function MultiNotification:CleanPlayerCache()
    -- Keep no more than 100 entries in cache
    local count = 0
    for _ in pairs(PlayerCache) do
        count = count + 1
    end
    
    if count > 100 then
        -- Limited reset - just create a new table with the player still in it
        local playerName = UnitName("player")
        local playerEntry = PlayerCache[playerName]
        
        PlayerCache = {}
        
        if playerName and playerEntry then
            PlayerCache[playerName] = playerEntry
        end
    end
    
    -- Schedule next cleanup
    C_Timer.After(300, function() self:CleanPlayerCache() end)
end

-- Handle specialization changes for predictive loading
function MultiNotification:OnSpecializationChanged(unit)
    if not Config.predictiveLoading then return end
    
    -- If it's the player or someone in their group, update spell predictions
    if unit == "player" then
        self:UpdateSpellPredictionsForPlayer()
    else
        -- Update group cache
        self:UpdateGroupCache()
    end
end

-- Update spell predictions based on player spec
function MultiNotification:UpdateSpellPredictionsForPlayer()
    local specID = GetSpecialization()
    if not specID then return end
    
    local _, specName, _, _, _, primaryStat = GetSpecializationInfo(specID)
    if not specName then return end
    
    -- Preload important spells for this spec
    self:PreloadSpellsForSpec(specName)
    
    if VUI.debug then
        VUI:Print(string.format("Updated spell predictions for %s spec", specName))
    end
end

-- Preload important spells for the current group composition
function MultiNotification:PreloadSpellsForGroup()
    local spellsToPreload = {}
    local classCount = {}
    
    -- Count classes in group
    local numMembers = GetNumGroupMembers()
    local unit = IsInRaid() and "raid" or "party"
    
    -- Include player
    local _, playerClass = UnitClass("player")
    if playerClass then
        classCount[playerClass] = (classCount[playerClass] or 0) + 1
    end
    
    for i = 1, numMembers do
        local unitID = unit..i
        if UnitExists(unitID) then
            local _, className = UnitClass(unitID)
            if className then
                classCount[className] = (classCount[className] or 0) + 1
            end
        end
    end
    
    -- For each class present, preload its key spells
    for class, count in pairs(classCount) do
        -- Add class-specific important spells to preload list
        local classSpells = self:GetImportantSpellsForClass(class)
        for _, spellID in ipairs(classSpells) do
            spellsToPreload[spellID] = true
        end
    end
    
    -- Preload these spells into cache
    if VUI.SpellDetectionOptimization then
        for spellID in pairs(spellsToPreload) do
            VUI.SpellDetectionOptimization:GetSpellInfo(spellID)
        end
    end
    
    if VUI.debug then
        local count = 0
        for _ in pairs(spellsToPreload) do count = count + 1 end
        VUI:Print(string.format("Preloaded %d spells based on group composition", count))
    end
end

-- Initialize spell to spec mapping
function MultiNotification:InitializeSpecSpellMapping()
    -- Just a small sampling of important spells by class/spec
    SpecSpellMapping = {
        -- Druid
        ["Balance"] = {194223, 191034, 78675, 102560, 102359},
        ["Feral"] = {106785, 5217, 1079, 285381, 106830},
        ["Guardian"] = {22842, 61336, 102558, 102793, 200851},
        ["Restoration"] = {33763, 88423, 102342, 102351, 203651},
        
        -- Hunter
        ["Beast Mastery"] = {19574, 193530, 201430, 120679, 186254},
        ["Marksmanship"] = {257044, 288613, 212431, 53209, 186387},
        ["Survival"] = {259491, 187708, 259495, 269751, 186289},
        
        -- Mage
        ["Arcane"] = {12042, 55342, 110959, 153626, 205025},
        ["Fire"] = {190319, 157981, 31661, 108853, 153561},
        ["Frost"] = {12472, 84714, 112965, 153595, 205021},
        
        -- Paladin
        ["Holy"] = {31884, 31821, 53563, 200652, 114158},
        ["Protection"] = {31850, 204150, 86659, 204035, 216331},
        ["Retribution"] = {231895, 343721, 255937, 343527, 383329},
        
        -- Priest
        ["Discipline"] = {47536, 194509, 33206, 129250, 81209},
        ["Holy"] = {47788, 64843, 64901, 34861, 88625},
        ["Shadow"] = {228260, 219521, 205065, 263346, 205385},
        
        -- Rogue
        ["Assassination"] = {79140, 1329, 57934, 121411, 185565},
        ["Outlaw"] = {13750, 13877, 51690, 195457, 196937},
        ["Subtlety"] = {121471, 185313, 185422, 269513, 277925},
        
        -- Shaman
        ["Elemental"] = {191634, 117014, 192249, 210714, 192222},
        ["Enhancement"] = {51533, 187880, 196884, 197214, 114051},
        ["Restoration"] = {98008, 108280, 73920, 73685, 207778},
        
        -- Warlock
        ["Affliction"] = {205180, 278350, 86121, 264119, 198590},
        ["Demonology"] = {265187, 267171, 267211, 264119, 265273},
        ["Destruction"] = {196447, 152108, 29722, 116858, 80240},
        
        -- Warrior
        ["Arms"] = {262161, 227847, 845, 97462, 167105},
        ["Fury"] = {184364, 118000, 184367, 280772, 335096},
        ["Protection"] = {1160, 871, 12975, 97462, 107574},
        
        -- Death Knight
        ["Blood"] = {49028, 55233, 43265, 49998, 77575},
        ["Frost"] = {196770, 49184, 51271, 207167, 57330},
        ["Unholy"] = {275699, 42650, 63560, 115989, 49206},
        
        -- Demon Hunter
        ["Havoc"] = {162264, 198589, 212459, 258925, 258860},
        ["Vengeance"] = {204021, 189110, 207684, 207682, 203720},
        
        -- Monk
        ["Brewmaster"] = {115072, 115203, 115308, 119582, 122281},
        ["Mistweaver"] = {115310, 116680, 115151, 115450, 116844},
        ["Windwalker"] = {137639, 122470, 261682, 122783, 152175}
    }
end

-- Preload important spells for a specific spec
function MultiNotification:PreloadSpellsForSpec(specName)
    if not SpecSpellMapping[specName] then return end
    
    for _, spellID in ipairs(SpecSpellMapping[specName]) do
        if VUI.SpellDetectionOptimization then
            VUI.SpellDetectionOptimization:GetSpellInfo(spellID)
        end
    end
end

-- Get important spells for a class
function MultiNotification:GetImportantSpellsForClass(className)
    local spells = {}
    
    -- Common interrupts and utility by class
    if className == "WARRIOR" then
        table.insert(spells, 6552)   -- Pummel
        table.insert(spells, 97462)  -- Rallying Cry
        table.insert(spells, 1719)   -- Recklessness
        table.insert(spells, 12975)  -- Last Stand
        table.insert(spells, 871)    -- Shield Wall
    elseif className == "PALADIN" then
        table.insert(spells, 96231)  -- Rebuke
        table.insert(spells, 31884)  -- Avenging Wrath
        table.insert(spells, 31821)  -- Aura Mastery
        table.insert(spells, 4987)   -- Cleanse
        table.insert(spells, 1022)   -- Blessing of Protection
    elseif className == "HUNTER" then
        table.insert(spells, 147362) -- Counter Shot
        table.insert(spells, 19574)  -- Bestial Wrath
        table.insert(spells, 264735) -- Survival of the Fittest
        table.insert(spells, 186265) -- Aspect of the Turtle
        table.insert(spells, 186257) -- Aspect of the Cheetah
    elseif className == "ROGUE" then
        table.insert(spells, 1766)   -- Kick
        table.insert(spells, 31224)  -- Cloak of Shadows
        table.insert(spells, 5277)   -- Evasion
        table.insert(spells, 2094)   -- Blind
        table.insert(spells, 1856)   -- Vanish
    elseif className == "PRIEST" then
        table.insert(spells, 15487)  -- Silence
        table.insert(spells, 47788)  -- Guardian Spirit
        table.insert(spells, 33206)  -- Pain Suppression
        table.insert(spells, 62618)  -- Power Word: Barrier
        table.insert(spells, 64843)  -- Divine Hymn
    elseif className == "SHAMAN" then
        table.insert(spells, 57994)  -- Wind Shear
        table.insert(spells, 98008)  -- Spirit Link Totem
        table.insert(spells, 108280) -- Healing Tide Totem
        table.insert(spells, 51886)  -- Cleanse Spirit
        table.insert(spells, 16191)  -- Mana Tide Totem
    elseif className == "MAGE" then
        table.insert(spells, 2139)   -- Counterspell
        table.insert(spells, 190319) -- Combustion
        table.insert(spells, 12472)  -- Icy Veins
        table.insert(spells, 80353)  -- Time Warp
        table.insert(spells, 45438)  -- Ice Block
    elseif className == "WARLOCK" then
        table.insert(spells, 19647)  -- Spell Lock (pet)
        table.insert(spells, 104773) -- Unending Resolve
        table.insert(spells, 265187) -- Summon Demonic Tyrant
        table.insert(spells, 1122)   -- Summon Infernal
        table.insert(spells, 30283)  -- Shadowfury
    elseif className == "MONK" then
        table.insert(spells, 116705) -- Spear Hand Strike
        table.insert(spells, 115310) -- Revival
        table.insert(spells, 115203) -- Fortifying Brew
        table.insert(spells, 115450) -- Detox
        table.insert(spells, 115176) -- Zen Meditation
    elseif className == "DRUID" then
        table.insert(spells, 106839) -- Skull Bash
        table.insert(spells, 740)    -- Tranquility
        table.insert(spells, 22812)  -- Barkskin
        table.insert(spells, 88423)  -- Nature's Cure
        table.insert(spells, 77764)  -- Stampeding Roar
    elseif className == "DEATHKNIGHT" then
        table.insert(spells, 47528)  -- Mind Freeze
        table.insert(spells, 49028)  -- Dancing Rune Weapon
        table.insert(spells, 55233)  -- Vampiric Blood
        table.insert(spells, 48792)  -- Icebound Fortitude
        table.insert(spells, 51052)  -- Anti-Magic Zone
    elseif className == "DEMONHUNTER" then
        table.insert(spells, 183752) -- Disrupt
        table.insert(spells, 187827) -- Metamorphosis (Vengeance)
        table.insert(spells, 191427) -- Metamorphosis (Havoc)
        table.insert(spells, 196718) -- Darkness
        table.insert(spells, 202137) -- Sigil of Silence
    end
    
    return spells
end

-- Report performance metrics
function MultiNotification:ReportSpellMetrics()
    if not Config.debugMode then
        -- Schedule next report and exit
        C_Timer.After(60, function() self:ReportSpellMetrics() end)
        return
    end
    
    local now = GetTime()
    local duration = now - Metrics.lastReset
    
    -- Calculate rates
    local eventRate = Metrics.eventsProcessed / duration
    local filterRate = Metrics.eventsFiltered / Metrics.eventsProcessed * 100
    local notificationRate = Metrics.notificationsShown / duration
    
    -- Performance reporting disabled in production release
    
    -- Reset for next window
    Metrics.eventsProcessed = 0
    Metrics.eventsFiltered = 0
    Metrics.notificationsShown = 0
    Metrics.duplicatesMerged = 0
    Metrics.lastReset = now
    
    -- Clean up caches
    local eventHistorySize = 0
    for _ in pairs(EventHistory) do eventHistorySize = eventHistorySize + 1 end
    
    local recentTargetsSize = 0
    for _ in pairs(RecentTargets) do recentTargetsSize = recentTargetsSize + 1 end
    
    if eventHistorySize > 200 then EventHistory = {} end
    if recentTargetsSize > 100 then RecentTargets = {} end
    
    -- Schedule next report
    C_Timer.After(60, function() self:ReportSpellMetrics() end)
end

-- Create options for this enhancement
function MultiNotification:GetEnhancedSpellDetectionOptions()
    return {
        enhancedHeader = {
            order = 1,
            type = "header",
            name = "Enhanced Spell Detection",
        },
        smartFiltering = {
            order = 2,
            type = "toggle",
            name = "Smart Filtering",
            desc = "Filter redundant or low-priority spell notifications in combat",
            get = function() return Config.smartFiltering end,
            set = function(_, value) Config.smartFiltering = value end,
            width = "full",
        },
        eventMerging = {
            order = 3,
            type = "toggle",
            name = "Event Merging",
            desc = "Combine similar events into a single notification",
            get = function() return Config.eventMerging end,
            set = function(_, value) Config.eventMerging = value end,
            width = "full",
        },
        combatOptimization = {
            order = 4,
            type = "toggle",
            name = "Combat Optimization",
            desc = "Apply more aggressive performance optimizations during combat",
            get = function() return Config.combatOptimization end,
            set = function(_, value) Config.combatOptimization = value end,
            width = "full",
        },
        predictiveLoading = {
            order = 5,
            type = "toggle",
            name = "Predictive Loading",
            desc = "Predict and preload spell data based on group composition",
            get = function() return Config.predictiveLoading end,
            set = function(_, value) 
                Config.predictiveLoading = value 
                if value then
                    self:UpdateGroupCache()
                end
            end,
            width = "full",
        },
        debugMode = {
            order = 6,
            type = "toggle",
            name = "Debug Mode",
            desc = "Show performance metrics and debug information",
            get = function() return Config.debugMode end,
            set = function(_, value) Config.debugMode = value end,
            width = "full",
        },
        resetCaches = {
            order = 7,
            type = "execute",
            name = "Reset Caches",
            desc = "Clear all spell and player caches",
            func = function()
                PlayerCache = {}
                EventHistory = {}
                RecentTargets = {}
                self:InitializePlayerCache()
                VUI:Print("Enhanced spell detection caches have been reset")
            end,
            width = "full",
        },
    }
end

-- Register this file with the module
VUI:RegisterModuleScript("MultiNotification", "EnhancedSpellDetection")