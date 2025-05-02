local _, VUI = ...

-- Spell Tracker Integration Module
-- This module connects the SpellTracker to other VUI modules
VUI.SpellTrackerIntegration = VUI.SpellTrackerIntegration or {}
local Integration = VUI.SpellTrackerIntegration

-- Track integration state
Integration.initialized = false
Integration.registeredModules = {}
Integration.moduleCallbacks = {}

-- Module dependencies
local SpellTracker = VUI.SpellTracker
local SpellData = VUI.spellData

-- Initialize the integration module
function Integration:Initialize()
    if self.initialized then return end
    
    -- Check if the SpellTracker is available
    if not SpellTracker then
        print("|cffff0000VUI SpellTrackerIntegration:|r SpellTracker module not found. Integration disabled.")
        return
    end
    
    -- Perform integration of available modules
    self:IntegrateMultiNotification()
    self:IntegrateBuffOverlay()
    self:IntegrateTrufiGCD()
    self:IntegrateOmniCD()
    
    -- Mark as initialized
    self.initialized = true
    
    self:Log(3, "Spell Tracker Integration initialized")
end

-- Register a module for integration
function Integration:RegisterModule(moduleName, callbackTable)
    if not moduleName or not callbackTable then return false end
    
    self.registeredModules[moduleName] = true
    self.moduleCallbacks[moduleName] = callbackTable
    
    self:Log(3, "Registered module for integration: " .. moduleName)
    
    return true
end

-- Unregister a module
function Integration:UnregisterModule(moduleName)
    if not moduleName or not self.registeredModules[moduleName] then return false end
    
    self.registeredModules[moduleName] = nil
    self.moduleCallbacks[moduleName] = nil
    
    self:Log(3, "Unregistered module from integration: " .. moduleName)
    
    return true
end

-- Call a registered module function
function Integration:CallModuleFunction(moduleName, functionName, ...)
    if not self.moduleCallbacks[moduleName] or not self.moduleCallbacks[moduleName][functionName] then
        return nil
    end
    
    -- Call the function and return its result
    return self.moduleCallbacks[moduleName][functionName](...)
end

----------------------------------------------------------
-- Module-specific integrations
----------------------------------------------------------

-- Integrate with MultiNotification module
function Integration:IntegrateMultiNotification()
    if not VUI.multinotification then
        self:Log(3, "MultiNotification module not available for integration")
        return
    end
    
    local MultiNotification = VUI.multinotification
    
    -- Register for spell events
    SpellTracker:RegisterCallback("INTERRUPT", "MultiNotification", function(eventData)
        if not MultiNotification or not eventData then return end
        
        -- Get spell info
        local spellInfo = SpellTracker:GetSpellInfo(eventData.spellID)
        if not spellInfo then return end
        
        -- Get target of interrupt
        local targetName = eventData.destName or "Unknown"
        local extraSpellInfo = eventData.extraSpellID and SpellTracker:GetSpellInfo(eventData.extraSpellID)
        local extraSpellName = extraSpellInfo and extraSpellInfo.name or eventData.extraSpellName or "Unknown Spell"
        
        -- Create notification data
        local notificationData = {
            type = "interrupt",
            source = eventData.sourceName,
            target = targetName,
            spellID = eventData.spellID,
            spellName = spellInfo.name,
            spellIcon = spellInfo.icon,
            extraSpellID = eventData.extraSpellID,
            extraSpellName = extraSpellName,
            timestamp = eventData.timestamp,
            importance = SpellData.GetSpellImportance(eventData.spellID) or 3
        }
        
        -- Call the module's AddNotification function if available
        if self.moduleCallbacks["MultiNotification"] and self.moduleCallbacks["MultiNotification"].AddNotification then
            self.moduleCallbacks["MultiNotification"].AddNotification(notificationData)
        else
            -- Fallback to direct function call
            if MultiNotification.AddNotification then
                MultiNotification:AddNotification(notificationData)
            end
        end
    end)
    
    -- Register for dispel events
    SpellTracker:RegisterCallback("DISPEL", "MultiNotification", function(eventData)
        if not MultiNotification or not eventData then return end
        
        -- Get spell info
        local spellInfo = SpellTracker:GetSpellInfo(eventData.spellID)
        if not spellInfo then return end
        
        -- Get target of dispel
        local targetName = eventData.destName or "Unknown"
        local extraSpellInfo = eventData.extraSpellID and SpellTracker:GetSpellInfo(eventData.extraSpellID)
        local extraSpellName = extraSpellInfo and extraSpellInfo.name or eventData.extraSpellName or "Unknown Spell"
        
        -- Create notification data
        local notificationData = {
            type = "dispel",
            source = eventData.sourceName,
            target = targetName,
            spellID = eventData.spellID,
            spellName = spellInfo.name,
            spellIcon = spellInfo.icon,
            extraSpellID = eventData.extraSpellID,
            extraSpellName = extraSpellName,
            auraType = eventData.auraType,
            timestamp = eventData.timestamp,
            importance = SpellData.GetSpellImportance(eventData.spellID) or 2
        }
        
        -- Call the module's AddNotification function if available
        if self.moduleCallbacks["MultiNotification"] and self.moduleCallbacks["MultiNotification"].AddNotification then
            self.moduleCallbacks["MultiNotification"].AddNotification(notificationData)
        else
            -- Fallback to direct function call
            if MultiNotification.AddNotification then
                MultiNotification:AddNotification(notificationData)
            end
        end
    end)
    
    -- Register for important spell events
    SpellTracker:RegisterCallback("SPELL", "MultiNotification", function(eventData)
        if not MultiNotification or not eventData or eventData.eventType ~= "SPELL_CAST_SUCCESS" then return end
        
        -- Check if this is an important spell
        local importance = SpellData.GetSpellImportance(eventData.spellID)
        if not importance or importance < 3 then return end -- Only handle Major and Critical importance
        
        -- Get spell info
        local spellInfo = SpellTracker:GetSpellInfo(eventData.spellID)
        if not spellInfo then return end
        
        -- Create notification data
        local notificationData = {
            type = "important",
            source = eventData.sourceName,
            target = eventData.destName,
            spellID = eventData.spellID,
            spellName = spellInfo.name,
            spellIcon = spellInfo.icon,
            timestamp = eventData.timestamp,
            importance = importance
        }
        
        -- Call the module's AddNotification function if available
        if self.moduleCallbacks["MultiNotification"] and self.moduleCallbacks["MultiNotification"].AddNotification then
            self.moduleCallbacks["MultiNotification"].AddNotification(notificationData)
        else
            -- Fallback to direct function call
            if MultiNotification.AddNotification then
                MultiNotification:AddNotification(notificationData)
            end
        end
    end)
    
    -- Register for death events
    SpellTracker:RegisterCallback("DEATH", "MultiNotification", function(eventData)
        if not MultiNotification or not eventData then return end
        
        -- Check for player deaths in arena/battleground/raid
        if eventData.destFlags and bit.band(eventData.destFlags, 0x00000400) > 0 then -- Is player
            local importance = 3 -- Default to Major importance for player deaths
            
            -- Create notification data
            local notificationData = {
                type = "death",
                target = eventData.destName,
                timestamp = eventData.timestamp,
                importance = importance
            }
            
            -- Call the module's AddNotification function if available
            if self.moduleCallbacks["MultiNotification"] and self.moduleCallbacks["MultiNotification"].AddNotification then
                self.moduleCallbacks["MultiNotification"].AddNotification(notificationData)
            else
                -- Fallback to direct function call
                if MultiNotification.AddNotification then
                    MultiNotification:AddNotification(notificationData)
                end
            end
        end
    end)
    
    -- Register our integration callbacks for MultiNotification
    self:RegisterModule("MultiNotification", {
        AddNotification = function(notificationData)
            if MultiNotification.AddNotification then
                return MultiNotification:AddNotification(notificationData)
            end
            return false
        end
    })
    
    self:Log(3, "MultiNotification integration complete")
end

-- Integrate with BuffOverlay module
function Integration:IntegrateBuffOverlay()
    if not VUI.buffoverlay then
        self:Log(3, "BuffOverlay module not available for integration")
        return
    end
    
    local BuffOverlay = VUI.buffoverlay
    
    -- Register for aura events
    SpellTracker:RegisterCallback("SPELL", "BuffOverlay", function(eventData)
        if not BuffOverlay or not eventData then return end
        
        -- Only handle aura events
        if not (eventData.eventType == "SPELL_AURA_APPLIED" or 
                eventData.eventType == "SPELL_AURA_APPLIED_DOSE" or
                eventData.eventType == "SPELL_AURA_REFRESH" or
                eventData.eventType == "SPELL_AURA_REMOVED" or
                eventData.eventType == "SPELL_AURA_REMOVED_DOSE") then
            return
        end
        
        -- Get cached spell info
        local spellInfo = SpellTracker:GetSpellInfo(eventData.spellID)
        if not spellInfo then return end
        
        -- Determine if this is a buff or debuff
        local isBuff = bit.band(eventData.sourceFlags or 0, 0x00000001) > 0 -- Friendly
        local isBossDebuff = bit.band(eventData.sourceFlags or 0, 0x00000008) > 0 -- Boss
        
        -- Determine category and importance for the aura
        local category = SpellData.GetSpellCategory(eventData.spellID)
        local importance = SpellData.GetSpellImportance(eventData.spellID)
        
        -- For buff tracking, we'll do this outside the normal COMBAT_LOG processing
        -- BuffOverlay has its own event handling for UNIT_AURA events
        
        -- Here we're just providing category and importance information to BuffOverlay
        -- if it has the necessary hooks
        
        if (self.moduleCallbacks["BuffOverlay"] and self.moduleCallbacks["BuffOverlay"].UpdateSpellData) then
            -- Update the spell data in BuffOverlay
            self.moduleCallbacks["BuffOverlay"].UpdateSpellData(eventData.spellID, {
                category = category,
                importance = importance,
                isBossDebuff = isBossDebuff
            })
        end
    end)
    
    -- Register with BuffOverlay to provide spell categorization
    if BuffOverlay.RegisterCategoryProvider then
        BuffOverlay:RegisterCategoryProvider("SpellTracker", function(spellID)
            return SpellData.GetSpellCategory(spellID), SpellData.GetSpellImportance(spellID)
        end)
    end
    
    -- Register our integration callbacks for BuffOverlay
    self:RegisterModule("BuffOverlay", {
        UpdateSpellData = function(spellID, data)
            if BuffOverlay.UpdateSpellData then
                return BuffOverlay:UpdateSpellData(spellID, data)
            end
            return false
        end,
        GetFrameFromPool = function(frameType, parent, template)
            -- Use SpellTracker's frame pool
            if SpellTracker.GetFrameFromPool then
                return SpellTracker:GetFrameFromPool(frameType, parent, template)
            end
            -- Fallback to creating a frame directly
            return CreateFrame(frameType, nil, parent, template)
        end,
        ReleaseFrame = function(frame)
            -- Use SpellTracker's frame pool
            if SpellTracker.ReleaseFrame then
                return SpellTracker:ReleaseFrame(frame)
            end
            -- Fallback to hiding the frame
            if frame then
                frame:Hide()
            end
        end
    })
    
    self:Log(3, "BuffOverlay integration complete")
end

-- Integrate with TrufiGCD module
function Integration:IntegrateTrufiGCD()
    if not VUI.trufigcd then
        self:Log(3, "TrufiGCD module not available for integration")
        return
    end
    
    local TrufiGCD = VUI.trufigcd
    
    -- Register for spell cast events
    SpellTracker:RegisterCallback("SPELL", "TrufiGCD", function(eventData)
        if not TrufiGCD or not eventData then return end
        
        -- Only handle successful spell casts
        if eventData.eventType ~= "SPELL_CAST_SUCCESS" then return end
        
        -- Only track player spells
        if eventData.sourceGUID ~= UnitGUID("player") then return end
        
        -- Get cached spell info
        local spellInfo = SpellTracker:GetSpellInfo(eventData.spellID)
        if not spellInfo then return end
        
        -- Determine category and importance for the spell
        local category = SpellData.GetSpellCategory(eventData.spellID)
        local importance = SpellData.GetSpellImportance(eventData.spellID)
        
        -- Send the spell data to TrufiGCD if it has the necessary hooks
        if self.moduleCallbacks["TrufiGCD"] and self.moduleCallbacks["TrufiGCD"].AddSpellToQueue then
            -- Add the spell to TrufiGCD's queue with our categorization
            self.moduleCallbacks["TrufiGCD"].AddSpellToQueue(eventData.spellID, spellInfo.name, spellInfo.icon, {
                category = category,
                importance = importance,
                timestamp = eventData.timestamp
            })
        end
    end)
    
    -- Register with TrufiGCD to provide spell categorization
    if TrufiGCD.RegisterCategoryProvider then
        TrufiGCD:RegisterCategoryProvider("SpellTracker", function(spellID)
            return SpellData.GetSpellCategory(spellID), SpellData.GetSpellImportance(spellID)
        end)
    end
    
    -- Register our integration callbacks for TrufiGCD
    self:RegisterModule("TrufiGCD", {
        AddSpellToQueue = function(spellID, spellName, spellIcon, data)
            if TrufiGCD.AddSpellToQueue then
                return TrufiGCD:AddSpellToQueue(spellID, spellName, spellIcon, data)
            end
            return false
        end,
        GetFrameFromPool = function(frameType, parent, template)
            -- Use SpellTracker's frame pool
            if SpellTracker.GetFrameFromPool then
                return SpellTracker:GetFrameFromPool(frameType, parent, template)
            end
            -- Fallback to creating a frame directly
            return CreateFrame(frameType, nil, parent, template)
        end,
        ReleaseFrame = function(frame)
            -- Use SpellTracker's frame pool
            if SpellTracker.ReleaseFrame then
                return SpellTracker:ReleaseFrame(frame)
            end
            -- Fallback to hiding the frame
            if frame then
                frame:Hide()
            end
        end
    })
    
    self:Log(3, "TrufiGCD integration complete")
end

-- Integrate with OmniCD module
function Integration:IntegrateOmniCD()
    if not VUI.omnicd then
        self:Log(3, "OmniCD module not available for integration")
        return
    end
    
    local OmniCD = VUI.omnicd
    
    -- Register for cooldown events (spell cast success)
    SpellTracker:RegisterCallback("SPELL", "OmniCD", function(eventData)
        if not OmniCD or not eventData then return end
        
        -- Only handle successful spell casts
        if eventData.eventType ~= "SPELL_CAST_SUCCESS" then return end
        
        -- Get cached spell info
        local spellInfo = SpellTracker:GetSpellInfo(eventData.spellID)
        if not spellInfo then return end
        
        -- Determine if this is a tracked cooldown
        local category = SpellData.GetSpellCategory(eventData.spellID)
        local importance = SpellData.GetSpellImportance(eventData.spellID)
        
        -- Only track specific categories that are relevant for cooldown tracking
        if category == SpellData.CATEGORIES.OFFENSIVE_CD or
           category == SpellData.CATEGORIES.DEFENSIVE_CD or
           category == SpellData.CATEGORIES.EXTERNAL_CD or
           category == SpellData.CATEGORIES.INTERRUPT or
           category == SpellData.CATEGORIES.DISPEL or
           category == SpellData.CATEGORIES.CC then
            
            -- Send the cooldown usage to OmniCD if it has the necessary hooks
            if self.moduleCallbacks["OmniCD"] and self.moduleCallbacks["OmniCD"].ProcessCooldownUsage then
                -- Process the cooldown usage with our categorization
                self.moduleCallbacks["OmniCD"].ProcessCooldownUsage(
                    eventData.sourceGUID,
                    eventData.sourceName,
                    eventData.spellID,
                    category,
                    importance
                )
            end
        end
    end)
    
    -- Register with OmniCD to provide spell categorization
    if OmniCD.RegisterCategoryProvider then
        OmniCD:RegisterCategoryProvider("SpellTracker", function(spellID)
            return SpellData.GetSpellCategory(spellID), SpellData.GetSpellImportance(spellID)
        end)
    end
    
    -- Register our integration callbacks for OmniCD
    self:RegisterModule("OmniCD", {
        ProcessCooldownUsage = function(sourceGUID, sourceName, spellID, category, importance)
            if OmniCD.ProcessCooldownUsage then
                return OmniCD:ProcessCooldownUsage(sourceGUID, sourceName, spellID, category, importance)
            end
            return false
        end,
        GetFrameFromPool = function(frameType, parent, template)
            -- Use SpellTracker's frame pool
            if SpellTracker.GetFrameFromPool then
                return SpellTracker:GetFrameFromPool(frameType, parent, template)
            end
            -- Fallback to creating a frame directly
            return CreateFrame(frameType, nil, parent, template)
        end,
        ReleaseFrame = function(frame)
            -- Use SpellTracker's frame pool
            if SpellTracker.ReleaseFrame then
                return SpellTracker:ReleaseFrame(frame)
            end
            -- Fallback to hiding the frame
            if frame then
                frame:Hide()
            end
        end
    })
    
    self:Log(3, "OmniCD integration complete")
end

----------------------------------------------------------
-- Utility functions
----------------------------------------------------------

-- Log a message
function Integration:Log(level, message)
    if not SpellTracker then
        print("|cff1784d1VUI SpellTrackerIntegration|r: " .. message)
        return
    end
    
    SpellTracker:Log(level, "Integration: " .. message)
end

-- Initialize when the addon is loaded
if VUI.initialized then
    Integration:Initialize()
else
    VUI:RegisterCallback("OnInitialized", function()
        -- Defer initialization to ensure modules are loaded
        C_Timer.After(0.5, function()
            Integration:Initialize()
        end)
    end)
end