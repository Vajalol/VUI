-- VUIPositionOfPower Module
-- Tracks buffs/effects related to positioning or stacking
-- Based on Position of Power WeakAura (https://wago.io/rdxO3TmdV)

local AddonName = ...
local VUI = _G["VUI"]
local MODNAME = "VUIPositionOfPower"

-- Set up global reference early to prevent nil errors
_G["VUIPositionOfPower"] = _G["VUIPositionOfPower"] or {}

-- Create minimal fallback if VUI doesn't exist
if not VUI then
    VUI = {}
    VUI.NewModule = function() return {} end
    _G["VUI"] = VUI
end

-- Try to create the module with error handling
local M

if VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
    -- Update the global reference with the actual module
    _G["VUIPositionOfPower"] = M
else
    -- Create minimal module object to prevent errors
    M = {
        NAME = MODNAME,
        TITLE = "VUI Position of Power",
        DESCRIPTION = "Tracks position-specific buffs and abilities",
        VERSION = "1.0",
        OnEnable = function() end,
        OnDisable = function() end
    }
    
    -- Register in VUI namespace
    VUI[MODNAME] = M
    
    -- Update the global reference with our placeholder
    _G["VUIPositionOfPower"] = M
    
    -- Try initialization again after delay
    C_Timer.After(0.5, function()
        if VUI and VUI.NewModule then
            local RealModule = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
            
            -- Transfer any properties from temporary module
            for k, v in pairs(M) do
                if k ~= "NAME" and k ~= "TITLE" and type(v) ~= "function" then
                    RealModule[k] = v
                end
            end
            
            -- Replace with real module
            VUI[MODNAME] = RealModule
            
            -- Update the global reference with the actual module
            _G["VUIPositionOfPower"] = RealModule
            
            -- Initialize the module
            if RealModule.OnInitialize then RealModule:OnInitialize() end
            if RealModule.OnEnable then RealModule:OnEnable() end
        end
    end)
end

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Position of Power"
M.DESCRIPTION = "Tracks position-specific buffs and abilities"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        scale = 1.0,
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = 0,
        alpha = 1.0,
        showGlow = true,
        showStackCount = true,
        growthDirection = "RIGHT", -- RIGHT, LEFT, UP, DOWN
        iconSize = 40,
        iconSpacing = 5,
        displayInCombatOnly = false,
        
        -- Visual settings
        borderColor = {r = 1, g = 1, b = 1, a = 1},
        useClassColor = true,
        backgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
        
        -- Text settings
        showDuration = true,
        durationFontSize = 14,
        durationFontColor = {r = 1, g = 1, b = 1, a = 1},
        showStackText = true,
        stackFontSize = 18,
        stackFontColor = {r = 1, g = 1, b = 1, a = 1},
    }
}

-- Position buffs data - these represent positioning or stacking mechanics for various classes/specs
M.positionBuffs = {
    -- HUNTER
    [260649] = { -- Careful Aim (Marksmanship Hunter)
        name = L["Careful Aim"],
        icon = 132212,
        class = "HUNTER",
        spec = 2, -- Marksmanship
        description = L["Target has 70% or more health, increasing Critical Strike chance of Aimed Shot and Rapid Fire"],
        priority = 90,
    },
    [194594] = { -- Lock and Load (Marksmanship Hunter)
        name = L["Lock and Load"],
        icon = 236179,
        class = "HUNTER",
        spec = 2, -- Marksmanship
        description = L["Your auto-attacks have a chance to make your next Aimed Shot cost no Focus and be instant"],
        priority = 85,
    },
    [193534] = { -- Steady Focus (Marksmanship Hunter)
        name = L["Steady Focus"],
        icon = 132213,
        class = "HUNTER",
        spec = 2, -- Marksmanship
        description = L["Using Steady Shot twice in a row increases your haste by 7%"],
        priority = 80,
    },
    
    -- MAGE
    [116014] = { -- Rune of Power (Mage)
        name = L["Rune of Power"],
        icon = 609815,
        class = "MAGE",
        spec = 0, -- All specs
        description = L["Increases spell damage while standing in the rune"],
        priority = 95,
    },
    [190446] = { -- Brain Freeze (Frost Mage)
        name = L["Brain Freeze"],
        icon = 236206,
        class = "MAGE",
        spec = 3, -- Frost
        description = L["Your next Flurry will hit as though the target were frozen"],
        priority = 90,
    },
    [12536] = { -- Clearcasting (Arcane Mage)
        name = L["Clearcasting"],
        icon = 135733,
        class = "MAGE",
        spec = 1, -- Arcane
        description = L["Your next Arcane spell's damage is increased and mana cost reduced"],
        priority = 90,
    },
    [48108] = { -- Hot Streak (Fire Mage)
        name = L["Hot Streak"],
        icon = 236217,
        class = "MAGE",
        spec = 2, -- Fire
        description = L["Your next Pyroblast or Flamestrike will be instant cast and deal increased damage"],
        priority = 95,
    },
    
    -- MONK
    [308059] = { -- Chi Energy (Windwalker Monk)
        name = L["Chi Energy"],
        icon = 258823,
        class = "MONK",
        spec = 3, -- Windwalker
        description = L["Hit combo increases, increasing damage done"],
        stacking = true,
        maxStacks = 6,
        priority = 95,
    },
    [196741] = { -- Hit Combo (Windwalker Monk)
        name = L["Hit Combo"],
        icon = 1381794,
        class = "MONK",
        spec = 3, -- Windwalker
        description = L["Each successive attack that triggers combo strikes increases damage done"],
        stacking = true,
        maxStacks = 6,
        priority = 95,
    },
    
    -- ROGUE
    [193359] = { -- True Bearing (Outlaw Rogue)
        name = L["True Bearing"],
        icon = 132331,
        class = "ROGUE",
        spec = 2, -- Outlaw
        description = L["Finishing moves reduce the remaining cooldown of many Rogue abilities"],
        priority = 85,
        roll = true,
    },
    [199603] = { -- Jolly Roger (Outlaw Rogue)
        name = L["Jolly Roger"],
        icon = 132364,
        class = "ROGUE",
        spec = 2, -- Outlaw
        description = L["Finishing moves have a chance to generate extra combo points"],
        priority = 80,
        roll = true,
    },
    [193358] = { -- Grand Melee (Outlaw Rogue)
        name = L["Grand Melee"],
        icon = 132330,
        class = "ROGUE",
        spec = 2, -- Outlaw
        description = L["Grants increased energy regeneration and attack speed"],
        priority = 82,
        roll = true,
    },
    [193357] = { -- Shark Infested Waters (Outlaw Rogue)
        name = L["Shark Infested Waters"],
        icon = 132329,
        class = "ROGUE",
        spec = 2, -- Outlaw
        description = L["Increases critical strike chance"],
        priority = 80,
        roll = true,
    },
    [193356] = { -- Broadside (Outlaw Rogue)
        name = L["Broadside"],
        icon = 132328,
        class = "ROGUE",
        spec = 2, -- Outlaw
        description = L["Pistol Shot and Between the Eyes grant additional combo points"],
        priority = 81,
        roll = true,
    },
    [199600] = { -- Buried Treasure (Outlaw Rogue)
        name = L["Buried Treasure"],
        icon = 132332,
        class = "ROGUE",
        spec = 2, -- Outlaw
        description = L["Reduces energy cost of abilities"],
        priority = 79,
        roll = true,
    },
    [385616] = { -- Flagellation Stacks (Subtlety Rogue)
        name = L["Flagellation"],
        icon = 3565454,
        class = "ROGUE",
        spec = 3, -- Subtlety
        description = L["Combo points spent during Flagellation increase your haste"],
        stacking = true,
        maxStacks = 15,
        priority = 90,
    },

    -- DRUID
    [279709] = { -- Starfallen (Balance Druid)
        name = L["Starfallen"],
        icon = 236168,
        class = "DRUID",
        spec = 1, -- Balance
        description = L["Starsurge increases the damage of your Moonfire and Sunfire"],
        stacking = true,
        maxStacks = 3,
        priority = 85,
    },
    [164547] = { -- Lunar Empowerment (Balance Druid)
        name = L["Lunar Empowerment"],
        icon = 132132,
        class = "DRUID",
        spec = 1, -- Balance
        description = L["Lunar Strike does increased damage"],
        stacking = true,
        maxStacks = 3,
        priority = 90,
    },
    [164545] = { -- Solar Empowerment (Balance Druid)
        name = L["Solar Empowerment"],
        icon = 132129,
        class = "DRUID",
        spec = 1, -- Balance
        description = L["Solar Wrath does increased damage"],
        stacking = true,
        maxStacks = 3,
        priority = 90,
    },
    
    -- SHAMAN
    [344179] = { -- Maelstrom Weapon (Enhancement Shaman)
        name = L["Maelstrom Weapon"],
        icon = 136063,
        class = "SHAMAN",
        spec = 2, -- Enhancement
        description = L["Your Lightning Bolt and Chain Lightning casts are instant and deal more damage"],
        stacking = true,
        maxStacks = 10,
        priority = 90,
    },
    [187878] = { -- Crash Lightning (Enhancement Shaman)
        name = L["Crash Lightning"],
        icon = 136026,
        class = "SHAMAN",
        spec = 2, -- Enhancement
        description = L["Your auto-attacks hit all nearby targets"],
        priority = 85,
    },
    
    -- DEATH KNIGHT
    [194310] = { -- Festering Wound (Unholy Death Knight)
        name = L["Festering Wound"],
        icon = 132278,
        class = "DEATHKNIGHT",
        spec = 3, -- Unholy
        description = L["Target is afflicted with wounds that burst when struck by Scourge Strike"],
        stacking = true,
        maxStacks = 8,
        priority = 90,
        targetBuff = true,
    },
    
    -- Add more positioning buffs for other classes here
}

-- Initialize module
function M:OnInitialize()
    -- Get database
    self.db = VUI.db
    
    -- Register module configuration
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, self:GetOptions(), self.TITLE)
    end
    
    -- Store active auras
    self.activeBuffs = {}
    
    -- Create frames
    self:CreateFrames()
    
    self:Debug(self.NAME .. " module initialized")
end

function M:OnEnable()
    -- Create a safe event registration handler
    local function SafeRegisterEvent(eventName, methodName)
        -- Check if we have the AceEvent-3.0 RegisterEvent method
        if not self.RegisterEvent or type(self.RegisterEvent) ~= "function" then
            -- Create fallback event frame if needed
            if not self.eventFrame then
                -- Safe CreateFrame wrapper with extensive error handling
                local function SafeCreateFrame(frameType, name, parent, template)
                    -- Check if CreateFrame exists
                    if not CreateFrame then
                        self:Debug("Error: CreateFrame global function is not available")
                        
                        -- Create a minimal frame substitute that won't error
                        local frame = {}
                        frame.events = {}
                        frame.handlers = {}
                        
                        -- Implement minimal frame methods to prevent errors
                        frame.RegisterEvent = function(self, event) 
                            if not self.events then self.events = {} end
                            table.insert(self.events, event) 
                        end
                        
                        frame.UnregisterEvent = function(self, event)
                            if not self.events then return end
                            for i, registeredEvent in ipairs(self.events) do
                                if registeredEvent == event then
                                    table.remove(self.events, i)
                                    break
                                end
                            end
                        end
                        
                        frame.UnregisterAllEvents = function(self)
                            self.events = {}
                        end
                        
                        frame.SetScript = function(self, scriptType, handler)
                            if not self.handlers then self.handlers = {} end
                            self.handlers[scriptType] = handler
                        end
                        
                        frame.GetScript = function(self, scriptType)
                            if not self.handlers then return nil end
                            return self.handlers[scriptType]
                        end
                        
                        -- Return our minimal frame substitute
                        return frame
                    end
                    
                    -- If CreateFrame exists, try to call it with pcall for safety
                    local success, frame = pcall(function()
                        return CreateFrame(frameType, name, parent, template)
                    end)
                    
                    if success and frame then
                        return frame
                    else
                        self:Debug("Error creating frame: " .. (frame or "unknown error"))
                        
                        -- Return minimal frame substitute on error
                        local fallbackFrame = {}
                        fallbackFrame.RegisterEvent = function() end
                        fallbackFrame.UnregisterEvent = function() end
                        fallbackFrame.UnregisterAllEvents = function() end
                        fallbackFrame.SetScript = function() end
                        fallbackFrame.GetScript = function() return nil end
                        
                        return fallbackFrame
                    end
                end
                
                self.eventFrame = SafeCreateFrame("Frame")
                self.eventFrame.module = self
            end
            
            -- Register the event on the fallback frame
            self.eventFrame:RegisterEvent(eventName)
            
            -- Set up script handler if not already done
            if not self.eventFrame:GetScript("OnEvent") then
                self.eventFrame:SetScript("OnEvent", function(_, event, ...)
                    local handler = self[methodName]
                    if handler and type(handler) == "function" then
                        handler(self, ...)
                    end
                end)
            end
            
            return true
        end
        
        -- Make sure the handler method exists
        if not self[methodName] or type(self[methodName]) ~= "function" then
            -- Create empty handler method to prevent errors
            self[methodName] = function() end
        end
        
        -- Use pcall to safely register the event
        local success = pcall(function()
            self:RegisterEvent(eventName, methodName)
        end)
        
        return success
    end
    
    -- Register required events
    SafeRegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    SafeRegisterEvent("PLAYER_TALENT_UPDATE", "TalentUpdate")
    SafeRegisterEvent("UNIT_AURA", "UpdateAuras")
    SafeRegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTargetAuras")
    SafeRegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisibility") -- Entered combat
    SafeRegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility") -- Left combat
    
    -- Create the tracking frame
    self:CreateFrame()
    
    -- Initialize for the player's current class/spec
    self:TalentUpdate()
    
    -- Update position of frame after creation
    self:UpdateFramePosition()
    
    -- Initial visibility update
    self:UpdateVisibility()
    
    -- Debug message
    self:Debug("VUIPositionOfPower module enabled")
end

function M:OnDisable()
    -- Hide frames
    if self.containerFrame then
        self.containerFrame:Hide()
    end
    
    -- Cancel timers with safety check
    if self.updateTimer then
        if self.CancelTimer and type(self.CancelTimer) == "function" then
            pcall(function() self:CancelTimer(self.updateTimer) end)
        end
        self.updateTimer = nil
    end
    
    -- Unregister events with safety check
    if self.UnregisterAllEvents and type(self.UnregisterAllEvents) == "function" then
        pcall(function() self:UnregisterAllEvents() end)
    end
    
    -- Clean up the event frame if we created one
    if self.eventFrame then
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame = nil
    end
    
    self:Debug(self.NAME .. " module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end

function M:Print(...)
    VUI:Print("|cFF33BBFFVUI Position of Power:|r", ...)
end

-- Get player class and spec info
function M:GetPlayerInfo()
    self.playerClass = select(2, UnitClass("player"))
    self.playerSpec = GetSpecialization()
    
    self:Debug("Player class:", self.playerClass, "Spec:", self.playerSpec)
end

-- Handle talent changes
function M:TalentUpdate()
    self.playerSpec = GetSpecialization()
    self:UpdateDisplay()
end

-- Create container frame
function M:CreateFrame()
    -- Safe CreateFrame wrapper
    local function SafeCreateFrame(frameType, name, parent, template)
        -- Check if CreateFrame exists
        if not CreateFrame then
            self:Debug("Error: CreateFrame global function is not available")
            return nil
        end
        
        -- Use pcall to safely call CreateFrame
        local success, frame = pcall(function()
            return CreateFrame(frameType, name, parent, template)
        end)
        
        if not success or not frame then
            self:Debug("Error creating frame: " .. (frame or "unknown error"))
            return nil
        end
        
        return frame
    end
    
    -- Create the container frame
    self.containerFrame = SafeCreateFrame("Frame", "VUIPositionOfPowerContainer", UIParent)
    
    if not self.containerFrame then
        self:Debug("Failed to create container frame")
        return
    end
    
    -- Set initial position
    self.containerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.containerFrame:SetSize(64, 64)
    self.containerFrame:SetMovable(true)
    self.containerFrame:EnableMouse(true)
    self.containerFrame:RegisterForDrag("LeftButton")
    self.containerFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.containerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        M.db.profile.positionOfPower.position = {
            point = point,
            relativePoint = relativePoint,
            x = xOfs,
            y = yOfs
        }
    end)
    
    -- Create icon containers
    self.iconFrames = {}
end

-- Create all necessary frames
function M:CreateFrames()
    -- Create the main container frame
    self:CreateFrame()
    
    -- Safety check - if container frame creation failed, don't proceed
    if not self.containerFrame then
        self:Debug("Cannot create child frames - container frame is nil")
        return
    end
    
    -- Create initial icon frames (we'll reuse these)
    for i = 1, 5 do
        self:GetIconFrame(0, i)
    end
    
    -- Update frame position from saved settings
    self:UpdateFramePosition()
end

-- Get or create an icon frame
function M:GetIconFrame(buffId, index)
    -- Create if it doesn't exist
    if not self.iconFrames[index] then
        local frame = CreateFrame("Frame", "VUIPositionOfPowerIcon"..index, self.containerFrame)
        frame:SetSize(36, 36)
        
        -- Set position based on index
        if index == 1 then
            frame:SetPoint("CENTER", self.containerFrame, "CENTER", 0, 0)
        elseif index == 2 then
            frame:SetPoint("BOTTOM", self.iconFrames[1], "TOP", 0, 2)
        elseif index == 3 then
            frame:SetPoint("RIGHT", self.iconFrames[1], "LEFT", -2, 0)
        elseif index == 4 then
            frame:SetPoint("LEFT", self.iconFrames[1], "RIGHT", 2, 0)
        elseif index == 5 then
            frame:SetPoint("TOP", self.iconFrames[1], "BOTTOM", 0, -2)
        else
            -- Additional icons get placed in a row below
            frame:SetPoint("TOPLEFT", self.iconFrames[1], "BOTTOMLEFT", (index-6) * 38, -40)
        end
        
        -- Create background
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.5)
        
        -- Create icon texture
        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim icon borders
        
        -- Create border
        local border = frame:CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        border:SetColorTexture(1, 1, 1, 0.3)
        
        -- Create count text
        local count = frame:CreateFontString(nil, "OVERLAY")
        count:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
        count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
        count:SetText("")
        
        -- Create duration text
        local duration = frame:CreateFontString(nil, "OVERLAY")
        duration:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        duration:SetPoint("TOP", frame, "BOTTOM", 0, -2)
        duration:SetText("")
        
        -- Store references
        frame.icon = icon
        frame.border = border
        frame.count = count
        frame.duration = duration
        frame.buffId = buffId
        
        -- Store the frame
        self.iconFrames[index] = frame
    end
    
    -- Update buff ID
    self.iconFrames[index].buffId = buffId
    
    return self.iconFrames[index]
end

-- Update frame position based on saved settings
function M:UpdateFramePosition()
    if not self.containerFrame then return end
    
    -- Set position based on saved settings
    self.containerFrame:ClearAllPoints()
    
    -- Check if we have saved position settings
    if self.db.profile.positionOfPower and self.db.profile.positionOfPower.position then
        local pos = self.db.profile.positionOfPower.position
        local point = pos.point or "CENTER"
        local relativePoint = pos.relativePoint or "CENTER"
        local xOffset = pos.x or 0
        local yOffset = pos.y or 0
        
        -- Set the point with saved values
        self.containerFrame:SetPoint(
            point,
            UIParent,
            relativePoint,
            xOffset,
            yOffset
        )
    else
        -- Use default values if no saved settings
        self.containerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    -- Set scale and alpha
    self.containerFrame:SetScale(self.db.profile.scale or 1.0)
    self.containerFrame:SetAlpha(self.db.profile.alpha or 1.0)
end

-- Update auras when UNIT_AURA event fires
function M:UpdateAuras(event, unit)
    if unit == "player" or unit == "target" then
        self:ScanAuras(unit)
    end
end

-- Update target auras when target changes
function M:UpdateTargetAuras()
    self:ScanAuras("target")
end

-- Scan auras for position buffs
function M:ScanAuras(unit)
    if not unit or not UnitExists(unit) then return end
    
    -- Check if we should scan this unit
    local isPlayer = (unit == "player")
    local isTarget = (unit == "target")
    
    if isTarget and not UnitCanAttack("player", "target") then
        -- Target is friendly, don't scan for debuffs
        return
    end
    
    -- Safe UnitAura wrapper function to handle nil value errors
    local function SafeUnitAura(unit, index, filter)
        -- Check if UnitAura exists
        if not UnitAura then
            return nil
        end
        
        -- Use pcall to safely call UnitAura
        local success, name, icon, count, debuffType, duration, expirationTime, 
               unitCaster, isStealable, nameplateShowPersonal, spellId = pcall(UnitAura, unit, index, filter)
        
        if success and name then
            return name, icon, count, debuffType, duration, expirationTime, 
                   unitCaster, isStealable, nameplateShowPersonal, spellId
        else
            return nil
        end
    end
    
    -- Determine if we should process player or target buffs
    local i = 1
    local buffName, icon, count, debuffType, duration, expirationTime, unitCaster, 
           isStealable, nameplateShowPersonal, spellId = SafeUnitAura(unit, i, "HELPFUL")
    
    while buffName do
        local buffData = self.positionBuffs[spellId]
        
        if buffData then
            -- Check if this is a target buff that should be tracked
            local shouldTrack = (isPlayer and not buffData.targetBuff) or (isTarget and buffData.targetBuff)
            
            if shouldTrack then
                -- Store the buff information
                local buffInfo = {
                    id = spellId,
                    name = buffName,
                    icon = icon,
                    count = count or 0,
                    duration = duration or 0,
                    expirationTime = expirationTime or 0,
                    stacking = buffData.stacking,
                    maxStacks = buffData.maxStacks,
                    priority = buffData.priority or 0,
                    class = buffData.class,
                    spec = buffData.spec,
                    roll = buffData.roll, -- For Outlaw Rogue Roll the Bones buffs
                }
                
                -- Store in active buffs
                self.activeBuffs[spellId] = buffInfo
            end
        end
        
        i = i + 1
        buffName, icon, count, debuffType, duration, expirationTime, unitCaster, 
        isStealable, nameplateShowPersonal, spellId = SafeUnitAura(unit, i, "HELPFUL")
    end
    
    -- Also scan for debuffs on target
    if isTarget then
        i = 1
        local debuffName, icon, count, debuffType, duration, expirationTime, unitCaster, 
               isStealable, nameplateShowPersonal, spellId = SafeUnitAura(unit, i, "HARMFUL|PLAYER")
        
        while debuffName do
            local buffData = self.positionBuffs[spellId]
            
            if buffData and buffData.targetBuff then
                -- Store the debuff information
                local buffInfo = {
                    id = spellId,
                    name = debuffName,
                    icon = icon,
                    count = count or 0,
                    duration = duration or 0,
                    expirationTime = expirationTime or 0,
                    stacking = buffData.stacking,
                    maxStacks = buffData.maxStacks,
                    priority = buffData.priority or 0,
                    class = buffData.class,
                    spec = buffData.spec,
                    targetBuff = true,
                }
                
                -- Store in active buffs
                self.activeBuffs[spellId] = buffInfo
            end
            
            i = i + 1
            debuffName, icon, count, debuffType, duration, expirationTime, unitCaster, 
            isStealable, nameplateShowPersonal, spellId = SafeUnitAura(unit, i, "HARMFUL|PLAYER")
        end
    end
    
    -- Trigger display update
    self:UpdateDisplay()
end

-- Update visibility based on combat state
function M:UpdateVisibility()
    if self.db.profile.displayInCombatOnly then
        if UnitAffectingCombat("player") then
            self.containerFrame:Show()
        else
            self.containerFrame:Hide()
        end
    else
        self.containerFrame:Show()
    end
end

-- Update display with current buffs
function M:UpdateDisplay()
    if not self.containerFrame then return end
    
    -- Check visibility based on combat state
    self:UpdateVisibility()
    
    -- Hide all icons first
    for _, frame in pairs(self.iconFrames) do
        frame:Hide()
    end
    
    -- Filter buffs for current class and spec
    local relevantBuffs = {}
    local currentTime = GetTime()
    
    for id, buffInfo in pairs(self.activeBuffs) do
        -- Check if buff is still active (hasn't expired)
        local timeLeft = buffInfo.expirationTime - currentTime
        if timeLeft <= 0 then
            self.activeBuffs[id] = nil
        elseif buffInfo.class == self.playerClass and 
               (buffInfo.spec == 0 or buffInfo.spec == self.playerSpec) then
            -- Buff is for current class and spec
            table.insert(relevantBuffs, buffInfo)
        end
    end
    
    -- Sort buffs by priority
    table.sort(relevantBuffs, function(a, b) 
        -- Handle Roll the Bones buffs specially - group them together
        if a.roll and b.roll then
            return a.priority > b.priority
        elseif a.roll then
            return true
        elseif b.roll then
            return false
        else
            return a.priority > b.priority
        end
    end)
    
    -- Display buffs
    local currentIndex = 1
    for _, buffInfo in ipairs(relevantBuffs) do
        local frame = self:GetIconFrame(buffInfo.id, currentIndex)
        
        -- Set icon
        frame.icon:SetTexture(buffInfo.icon)
        
        -- Duration text
        if self.db.profile.showDuration and buffInfo.duration > 0 then
            local timeLeft = buffInfo.expirationTime - currentTime
            
            if timeLeft > 60 then
                frame.duration:SetText(string.format("%.1fm", timeLeft/60))
            else
                frame.duration:SetText(string.format("%.1fs", timeLeft))
            end
            
            -- Colorize based on time remaining
            local durationPercent = timeLeft / buffInfo.duration
            local r, g, b = 1, 1, 1
            
            if durationPercent < 0.3 then
                -- Red when about to expire
                r, g, b = 1, 0.3, 0.3
            elseif durationPercent < 0.5 then
                -- Yellow when halfway through
                r, g, b = 1, 1, 0.3
            else
                -- Default color
                local durationColor = self.db.profile.durationFontColor or {r=1, g=1, b=1, a=1}
                r, g, b = durationColor.r, durationColor.g, durationColor.b
            end
            
            frame.duration:SetTextColor(r, g, b)
        else
            frame.duration:SetText("")
        end
        
        -- Stack count
        if buffInfo.stacking and buffInfo.count > 1 and self.db.profile.showStackText then
            frame.count:SetText(buffInfo.count)
            
            -- Color based on stack count
            if buffInfo.maxStacks and buffInfo.count == buffInfo.maxStacks then
                frame.count:SetTextColor(0, 1, 0, 1) -- Green for max stacks
            else
                local stackColor = self.db.profile.stackFontColor or {r=1, g=1, b=1, a=1}
                frame.count:SetTextColor(stackColor.r, stackColor.g, stackColor.b, stackColor.a)
            end
        else
            frame.count:SetText("")
        end
        
        -- Set border highlight based on importance
        local shouldGlow = (buffInfo.priority >= 90)  -- High priority buffs have visual highlight
        
        if shouldGlow then
            frame.border:SetAlpha(0.7)
        else
            frame.border:SetAlpha(0)
        end
        
        -- Show the frame
        frame:Show()
        
        -- Increment index
        currentIndex = currentIndex + 1
    end
    
    -- Update container frame size if needed
    local totalBuffs = #relevantBuffs
    if totalBuffs > 0 then
        -- Show frame
        self.containerFrame:Show()
    else
        -- Hide frame when no buffs to show
        if not self.db.profile.alwaysShow then
            self.containerFrame:Hide()
        end
    end
end

-- Lock/unlock the frame for moving
function M:ToggleMovable(enable)
    if self.containerFrame then
        self.containerFrame:EnableMouse(enable)
        
        if enable then
            self.containerFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = {left = 1, right = 1, top = 1, bottom = 1}
            })
            self.containerFrame:SetBackdropColor(0, 0, 0, 0.3)
            self.containerFrame:SetBackdropBorderColor(1, 1, 1, 0.7)
            
            self:Print("Frame unlocked for moving. Drag to reposition, then lock when finished.")
        else
            self.containerFrame:SetBackdrop(nil)
            
            self:Print("Frame locked.")
        end
    end
end

-- Get options for configuration panel
function M:GetOptions()
    local options = {
        name = self.TITLE,
        type = "group",
        args = {
            general = {
                name = L["General Settings"],
                type = "group",
                order = 1,
                inline = true,
                args = {
                    enabled = {
                        name = L["Enable"],
                        desc = L["Enable/disable this module"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.enabled end,
                        set = function(info, value) 
                            self.db.profile.enabled = value
                            if value then self:OnEnable() else self:OnDisable() end
                        end,
                    },
                    movable = {
                        name = L["Unlock Frame"],
                        desc = L["Unlock the frame to allow repositioning"],
                        type = "toggle",
                        order = 2,
                        get = function() return self.containerFrame and self.containerFrame:IsMouseEnabled() end,
                        set = function(info, value) self:ToggleMovable(value) end,
                    },
                    displayInCombatOnly = {
                        name = L["Display In Combat Only"],
                        desc = L["Only show position buffs while in combat"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.displayInCombatOnly end,
                        set = function(info, value)
                            self.db.profile.displayInCombatOnly = value
                            self:UpdateVisibility()
                        end,
                    },
                    appearance = {
                        name = L["Appearance"],
                        type = "group",
                        order = 4,
                        inline = true,
                        args = {
                            scale = {
                                name = L["Scale"],
                                desc = L["Adjust the size of the display"],
                                type = "range",
                                order = 1,
                                min = 0.5,
                                max = 2.0,
                                step = 0.05,
                                get = function() return self.db.profile.scale end,
                                set = function(info, value)
                                    self.db.profile.scale = value
                                    if self.containerFrame then
                                        self.containerFrame:SetScale(value)
                                    end
                                end,
                            },
                            alpha = {
                                name = L["Alpha"],
                                desc = L["Adjust the transparency of the display"],
                                type = "range",
                                order = 2,
                                min = 0.1,
                                max = 1.0,
                                step = 0.05,
                                get = function() return self.db.profile.alpha end,
                                set = function(info, value)
                                    self.db.profile.alpha = value
                                    if self.containerFrame then
                                        self.containerFrame:SetAlpha(value)
                                    end
                                end,
                            },
                            iconSize = {
                                name = L["Icon Size"],
                                desc = L["Size of the buff icons"],
                                type = "range",
                                order = 3,
                                min = 20,
                                max = 80,
                                step = 1,
                                get = function() return self.db.profile.iconSize end,
                                set = function(info, value)
                                    self.db.profile.iconSize = value
                                    -- Recreate frames for new size
                                    self.iconFrames = {}
                                    self:UpdateDisplay()
                                end,
                            },
                            iconSpacing = {
                                name = L["Icon Spacing"],
                                desc = L["Space between buff icons"],
                                type = "range",
                                order = 4,
                                min = 0,
                                max = 20,
                                step = 1,
                                get = function() return self.db.profile.iconSpacing end,
                                set = function(info, value)
                                    self.db.profile.iconSpacing = value
                                    self:UpdateDisplay()
                                end,
                            },
                            growthDirection = {
                                name = L["Growth Direction"],
                                desc = L["Direction in which new icons appear"],
                                type = "select",
                                order = 5,
                                values = {
                                    RIGHT = L["Right"],
                                    LEFT = L["Left"],
                                    UP = L["Up"],
                                    DOWN = L["Down"],
                                },
                                get = function() return self.db.profile.growthDirection end,
                                set = function(info, value)
                                    self.db.profile.growthDirection = value
                                    -- Recreate frames for new direction
                                    self.iconFrames = {}
                                    self:UpdateDisplay()
                                end,
                            },
                        },
                    },
                    display = {
                        name = L["Display Options"],
                        type = "group",
                        order = 5,
                        inline = true,
                        args = {
                            showGlow = {
                                name = L["Show Glow Effect"],
                                desc = L["Show a glow effect around important buffs"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.showGlow end,
                                set = function(info, value)
                                    self.db.profile.showGlow = value
                                    self:UpdateDisplay()
                                end,
                            },
                            showDuration = {
                                name = L["Show Duration"],
                                desc = L["Show the time remaining on buffs"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.showDuration end,
                                set = function(info, value)
                                    self.db.profile.showDuration = value
                                    self:UpdateDisplay()
                                end,
                            },
                            showStackText = {
                                name = L["Show Stack Count"],
                                desc = L["Show the number of stacks for stacking buffs"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.showStackText end,
                                set = function(info, value)
                                    self.db.profile.showStackText = value
                                    self:UpdateDisplay()
                                end,
                            },
                            useClassColor = {
                                name = L["Use Class Color Border"],
                                desc = L["Color the icon borders based on your class"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.useClassColor end,
                                set = function(info, value)
                                    self.db.profile.useClassColor = value
                                    self:UpdateDisplay()
                                end,
                            },
                        },
                    },
                },
            },
        },
    }
    
    return options
end

-- Register the module
if VUI.RegisterModule then
    VUI:RegisterModule(MODNAME, M)
end

-- Handle PLAYER_ENTERING_WORLD event
function M:OnPlayerEnteringWorld()
    -- Update player info
    self:GetPlayerInfo()
    
    -- Scan player auras
    self:ScanAuras("player")
    
    -- Update visibility
    self:UpdateVisibility()
    
    -- Initial display update
    self:UpdateDisplay()
end

-- Create initial frames and containers
function M:CreateFrames()
    -- This is a placeholder method called during OnInitialize
    -- The actual frame creation is done in CreateFrame when the module is enabled
    self:Debug("Initializing frames")
    
    -- Initialize active buffs container
    self.activeBuffs = {}
    
    -- Initialize icon frames container
    self.iconFrames = {}
end

function M:SetPoint(i, region, relPoint, offsetX, offsetY)
    if not self.containerFrame or not self.containerFrame:IsShown() then
        return
    end
    
    -- Make sure region is valid
    if not region then
        self:Debug("Error: Attempted to set point with nil region")
        return
    end
    
    -- Safety checks for parameters
    local point = i
    if type(point) ~= "string" then
        point = "CENTER"
    end
    relPoint = relPoint or "CENTER"
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    
    -- Set the point with validated parameters
    self.containerFrame:ClearAllPoints()
    self.containerFrame:SetPoint(point, region, relPoint, offsetX, offsetY)
end