-- VUIConsumables Module
-- Tracks player consumables (flasks, food, potions, runes)
-- Based on Luxthos Consumables WeakAura

local AddonName, _ = ...
local MODNAME = "VUIConsumables"

-- Use global reference instead of local addon variable to fix load order issues
local VUI = _G["VUI"]

-- Check if VUI exists before proceeding
if not VUI then 
    -- Don't print a warning message as the module will be properly registered later when VUI is ready
    return 
end

-- Set up global reference early to prevent nil errors
_G["VUIConsumables"] = _G["VUIConsumables"] or {}

-- Try to create the module with error handling
local M
if VUI then
    -- Check for TryCreateModule first (preferred method)
    if VUI.TryCreateModule then
        M = VUI:TryCreateModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
        -- Update the global reference with the actual module
        _G["VUIConsumables"] = M
    -- Fall back to NewModule if available
    elseif VUI.NewModule then
        M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
        -- Update the global reference with the actual module
        _G["VUIConsumables"] = M
    else
        -- Last resort - create a basic object with minimum required functionality
        -- Don't print warning since we've already added a silent list in Core/Init.lua
        M = {
            NAME = MODNAME,
            RegisterEvent = function() end,
            UnregisterAllEvents = function() end,
            ScheduleRepeatingTimer = function() return 0 end,
            CancelTimer = function() end,
            RegisterChatCommand = function() end,
            Debug = function(self, ...) 
                -- Silent debug to prevent duplicate console messages
            end,
            Print = function(self, ...) print("|cFF33BBFFVUI Consumables:|r", ...) end,
            GetOptions = function() return {} end
        }
        VUI[MODNAME] = M
        -- Update the global reference with our placeholder
        _G["VUIConsumables"] = M
    end
end

if not M then
    print("VUIConsumables: Fatal error initializing module")
    return
end

-- Localization
-- Use global reference pattern for localization tables
local L = VUI.L or (LibStub and LibStub("AceLocale-3.0") and LibStub("AceLocale-3.0"):GetLocale("VUI", true)) or {}

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Consumables"
M.DESCRIPTION = "Tracks player consumables such as flasks, food, potions, and runes"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        showFlasks = true,
        showFood = true,
        showPotions = true,
        showRunes = true,
        scale = 1.0,
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = 0,
        alpha = 1.0,
        activeOnly = true,
        flashWarning = true,
        warningThreshold = 60,    -- 60 seconds warning before expiration
        iconSize = 36,
        iconSpacing = 5,
        -- Visual settings
        borderColor = {r = 1, g = 1, b = 1, a = 1},
        useClassColor = true,
        backgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
        -- Text settings
        showDuration = true,
        durationFontSize = 12,
        durationFontColor = {r = 1, g = 1, b = 1, a = 1},
        showLabel = true,
        labelFontSize = 10,
        labelFontColor = {r = 1, g = 1, b = 1, a = 1},
    }
}

-- Consumable Types
M.FLASK = "FLASK"
M.FOOD = "FOOD"
M.POTION = "POTION"
M.RUNE = "RUNE"

-- Spell Data: These spell IDs represent the different consumable buffs
M.consumableData = {
    -- Flask spells
    flasks = {
        -- Season 2 (War Within)
        -- Various Flasks
        [382144] = {name = "Phial of the Eye in the Storm", type = M.FLASK, duration = 60 * 60},  -- +70 primary stat
        [392883] = {name = "Phial of Static Empowerment", type = M.FLASK, duration = 60 * 60},    -- +70 secondary stat
        [373257] = {name = "Phial of Glacial Fury", type = M.FLASK, duration = 60 * 60},          -- +70 secondary stat
        [371354] = {name = "Phial of Tepid Versatility", type = M.FLASK, duration = 60 * 60},     -- +70 versatility
        [371386] = {name = "Phial of Icy Preservation", type = M.FLASK, duration = 60 * 60},      -- Damage reduction
        
        -- Cauldrons (Raid-wide flasks)
        [373257] = {name = "Cauldron of the War Within", type = M.FLASK, duration = 60 * 60},     -- Raid cauldron

        -- Previous Expansion Flasks - for backward compatibility
        [307185] = {name = "Spectral Flask of Power", type = M.FLASK, duration = 60 * 60},
        [307187] = {name = "Spectral Flask of Stamina", type = M.FLASK, duration = 60 * 60},
    },

    -- Food buffs
    food = {
        -- Season 2 Foods
        [382149] = {name = "Feast", type = M.FOOD, duration = 60 * 60}, -- Hearty Feast
        [382147] = {name = "Ferocity Food", type = M.FOOD, duration = 60 * 60},  -- Crit
        [382145] = {name = "Haste Food", type = M.FOOD, duration = 60 * 60},     -- Haste
        [382148] = {name = "Mastery Food", type = M.FOOD, duration = 60 * 60},   -- Mastery
        [382146] = {name = "Versatility Food", type = M.FOOD, duration = 60 * 60}, -- Versatility
        
        -- Generic Well Fed buff - fallback for unknown food
        [327706] = {name = "Well Fed", type = M.FOOD, duration = 60 * 60},
    },

    -- Combat potions
    potions = {
        -- Season 2 Combat Potions
        [371024] = {name = "Elemental Potion of Power", type = M.POTION, duration = 60 * 30}, -- Primary stat
        [371028] = {name = "Elemental Potion of Ultimate Power", type = M.POTION, duration = 60 * 30}, -- More primary stat
        [371033] = {name = "Aerated Mana Potion", type = M.POTION, duration = 10}, -- Mana restoration over time
        [371039] = {name = "Elemental Healing Potion", type = M.POTION, duration = 10}, -- Healing over time
        [371152] = {name = "Potion of the Hushed Zephyr", type = M.POTION, duration = 60 * 10}, -- Speed increase
    },

    -- Augment runes
    runes = {
        -- Season 2 Runes
        [367405] = {name = "Draconic Augment Rune", type = M.RUNE, duration = 60 * 60 * 2}, -- 2 hour
        [393438] = {name = "Obsidian Augment Rune", type = M.RUNE, duration = 60 * 60 * 2}, -- 2 hour
    },
}

-- Initialize module
function M:OnInitialize()
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIConsumables"] or VUI.db.namespaces["vuiconsumables"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIConsumables"] = namespace
            VUI.db.namespaces["vuiconsumables"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIConsumables", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuiconsumables"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Register settings with VUI Config
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, self:GetOptions(), self.TITLE)
    end
    
    -- Frame setup - create the main container frame
    self:CreateFrames()
    
    self:Debug("VUIConsumables module initialized")
end

function M:OnEnable()
    -- Create the icon frames
    self:CreateIconFrames()
    
    -- Register events with proper error handling
    local safeRegisterEvent = function(eventName, methodName)
        if not self or not self.RegisterEvent then return false end
        
        -- If methodName is a string, make sure the method exists
        if type(methodName) == "string" then
            if not self[methodName] then
                -- Create an empty handler to prevent errors
                self[methodName] = function() end
            end
        end
        
        -- Use pcall to safely register the event
        local success = pcall(function()
            if type(methodName) == "string" then
                self:RegisterEvent(eventName, methodName)
            else
                self:RegisterEvent(eventName)
            end
        end)
        
        return success
    end
    
    -- Register required events
    safeRegisterEvent("PLAYER_ENTERING_WORLD", "UpdateConsumables")
    safeRegisterEvent("UNIT_AURA", "UpdateConsumables")
    
    -- Start update timer with error handling
    if self.ScheduleRepeatingTimer and type(self.ScheduleRepeatingTimer) == "function" then
        pcall(function()
            self.updateTimer = self:ScheduleRepeatingTimer("UpdateConsumables", 0.5)
        end)
    end
    
    self:Debug("VUIConsumables module enabled")
end

function M:OnDisable()
    -- Hide frames
    if self.containerFrame then
        self.containerFrame:Hide()
    end
    
    -- Cancel timers
    if self.updateTimer then
        self:CancelTimer(self.updateTimer)
        self.updateTimer = nil
    end
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    self:Debug("VUIConsumables module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    if VUI and type(VUI.Debug) == "function" then
        VUI:Debug(self.NAME, ...)
    else
        print("[" .. self.NAME .. "]", ...)
    end
end

function M:Print(...)
    if VUI and type(VUI.Print) == "function" then
        VUI:Print("|cFF33BBFFVUI Consumables:|r", ...)
    else
        print("|cFF33BBFFVUI Consumables:|r", ...)
    end
end

-- Create container frame
function M:CreateFrames()
    -- Main frame
    self.containerFrame = CreateFrame("Frame", "VUIConsumablesFrame", UIParent)
    self.containerFrame:SetSize(200, 50)
    self.containerFrame:SetPoint(
        self.db.profile.point,
        UIParent,
        self.db.profile.relativePoint,
        self.db.profile.xOffset,
        self.db.profile.yOffset
    )
    self.containerFrame:SetScale(self.db.profile.scale)
    self.containerFrame:SetAlpha(self.db.profile.alpha)
    
    -- Make the frame draggable when unlocked
    self.containerFrame:SetMovable(true)
    self.containerFrame:EnableMouse(false)
    self.containerFrame:RegisterForDrag("LeftButton")
    self.containerFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.containerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        M.db.profile.point = point
        M.db.profile.relativePoint = relativePoint
        M.db.profile.xOffset = xOffset
        M.db.profile.yOffset = yOffset
    end)
    
    -- Set visibility based on enabled state
    if self.db.profile.enabled then
        self.containerFrame:Show()
    else
        self.containerFrame:Hide()
    end
end

-- Create icon frames for each consumable type
function M:CreateIconFrames()
    if not self.containerFrame then return end
    
    self.iconFrames = {}
    local iconTypes = {
        {type = M.FLASK, enabled = "showFlasks"},
        {type = M.FOOD, enabled = "showFood"},
        {type = M.POTION, enabled = "showPotions"},
        {type = M.RUNE, enabled = "showRunes"}
    }
    
    local iconSize = self.db.profile.iconSize
    local spacing = self.db.profile.iconSpacing
    local xPos = 0
    
    -- Define fallback textures if VUI.Media is not available
    local defaultTextures = {
        [M.FLASK] = "Interface\\Icons\\INV_Alchemy_EndlessFlask_06",
        [M.FOOD] = "Interface\\Icons\\INV_Misc_Food_15",
        [M.POTION] = "Interface\\Icons\\INV_Alchemy_Potion_06",
        [M.RUNE] = "Interface\\Icons\\INV_Misc_Rune_04",
        ["default"] = "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    
    -- Check if VUI.Media exists and has the textures with safe navigation
    local hasMedia = (VUI and VUI.Media and VUI.Media.textures and VUI.Media.textures.consumables)
    
    -- Safe function to get texture path
    local function GetTexturePath(consumableType)
        if hasMedia and VUI.Media.textures.consumables[consumableType] then
            return VUI.Media.textures.consumables[consumableType]
        else
            return defaultTextures[consumableType] or defaultTextures["default"]
        end
    end
    
    for i, data in ipairs(iconTypes) do
        if self.db.profile[data.enabled] then
            local frame = CreateFrame("Frame", "VUIConsumablesIcon_"..data.type, self.containerFrame, "BackdropTemplate")
            frame:SetSize(iconSize, iconSize)
            frame:SetPoint("LEFT", xPos, 0)
            
            -- Icon
            frame.icon = frame:CreateTexture(nil, "ARTWORK")
            frame.icon:SetAllPoints()
            frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Remove default icon border
            
            -- Border
            frame:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = {left = 1, right = 1, top = 1, bottom = 1}
            })
            
            local borderColor = self.db.profile.borderColor
            frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            
            -- Background
            frame.bg = frame:CreateTexture(nil, "BACKGROUND")
            frame.bg:SetAllPoints()
            
            local bgColor = self.db.profile.backgroundColor
            frame.bg:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
            
            -- Duration text
            frame.duration = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.duration:SetPoint("BOTTOM", 0, 2)
            frame.duration:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.durationFontSize, "OUTLINE")
            
            local durationColor = self.db.profile.durationFontColor
            frame.duration:SetTextColor(durationColor.r, durationColor.g, durationColor.b, durationColor.a)
            
            -- Label text
            frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.label:SetPoint("TOP", 0, -2)
            frame.label:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.labelFontSize, "OUTLINE")
            
            local labelColor = self.db.profile.labelFontColor
            frame.label:SetTextColor(labelColor.r, labelColor.g, labelColor.b, labelColor.a)
            
            -- Set default state using our media texture or fallback
            frame.type = data.type
            frame.active = false
            
            -- Check if VUI.Media exists and get appropriate texture with fallback
            local iconTexture
            
            if hasMedia then
                if data.type == M.FLASK then
                    iconTexture = VUI.Media.textures.consumables.flask or defaultTextures[M.FLASK]
                elseif data.type == M.FOOD then
                    iconTexture = VUI.Media.textures.consumables.food or defaultTextures[M.FOOD]
                elseif data.type == M.POTION then
                    iconTexture = VUI.Media.textures.consumables.potion or defaultTextures[M.POTION]
                elseif data.type == M.RUNE then
                    iconTexture = VUI.Media.textures.consumables.rune or defaultTextures[M.RUNE]
                else
                    iconTexture = VUI.Media.textures.consumables.question or defaultTextures["default"]
                end
            else
                iconTexture = defaultTextures[data.type] or defaultTextures["default"]
            end
            
            frame.icon:SetTexture(iconTexture)
            frame.duration:SetText("")
            frame.label:SetText(data.type)
            
            -- Store the frame
            self.iconFrames[data.type] = frame
            
            -- Update position for next icon
            xPos = xPos + iconSize + spacing
        end
    end
    
    -- Update container size
    self.containerFrame:SetSize(xPos - spacing, iconSize)
end

-- Update consumables display
function M:UpdateConsumables(event, unit)
    if not unit or unit == "player" then
        self:ScanPlayerConsumables()
    end
end

-- Scan player auras for consumables
function M:ScanPlayerConsumables()
    if not self.iconFrames then return end
    
    -- Reset all icons to inactive
    for _, frame in pairs(self.iconFrames) do
        frame.active = false
    end
    
    -- Safe wrapper for UnitAura to prevent nil errors
    local function SafeUnitAura(unit, index, filter)
        if not UnitAura or type(UnitAura) ~= "function" then
            return nil
        end
        
        -- Use pcall to safely call UnitAura
        local success, name, icon, count, debuffType, duration, expirationTime, unitCaster, 
              isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
              isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3 = pcall(UnitAura, unit, index, filter)
        
        if success and name then
            return name, icon, count, debuffType, duration, expirationTime, unitCaster, 
                   isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
                   isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3
        else
            return nil
        end
    end
    
    -- Scan all player auras
    local i = 1
    local name, icon, count, debuffType, duration, expirationTime, unitCaster, 
          isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
          isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3 = SafeUnitAura("player", i, "HELPFUL")
    
    while name do
        self:ProcessAura(spellId, name, icon, duration, expirationTime)
        
        i = i + 1
        name, icon, count, debuffType, duration, expirationTime, unitCaster, 
        isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
        isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3 = SafeUnitAura("player", i, "HELPFUL")
    end
    
    -- Update icon displays
    self:UpdateIconFrames()
end

-- Process a single aura to check if it's a tracked consumable
function M:ProcessAura(spellId, name, icon, duration, expirationTime)
    -- Check through all consumable types
    for _, consumableType in pairs({"flasks", "food", "potions", "runes"}) do
        local consumables = self.consumableData[consumableType]
        
        if consumables[spellId] then
            local data = consumables[spellId]
            local frameType = data.type
            
            if self.iconFrames[frameType] then
                local frame = self.iconFrames[frameType]
                
                -- If we already have an active buff of this type, only update if this one has a longer duration
                if not frame.active or (expirationTime > frame.expirationTime) then
                    frame.active = true
                    frame.icon:SetTexture(icon)
                    frame.name = name
                    frame.duration = duration
                    frame.expirationTime = expirationTime
                    
                    -- Show the appropriate label
                    if self.db.profile.showLabel then
                        frame.label:SetText(data.name:sub(1, 6))
                    else
                        frame.label:SetText("")
                    end
                end
                
                return true
            end
        end
    end
    
    return false
end

-- Update all icon frames based on current state
function M:UpdateIconFrames()
    local currentTime = GetTime()
    
    -- Define fallback textures if VUI.Media is not available
    local defaultTextures = {
        [M.FLASK] = "Interface\\Icons\\INV_Alchemy_EndlessFlask_06",
        [M.FOOD] = "Interface\\Icons\\INV_Misc_Food_15",
        [M.POTION] = "Interface\\Icons\\INV_Alchemy_Potion_06",
        [M.RUNE] = "Interface\\Icons\\INV_Misc_Rune_04",
        ["default"] = "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    
    -- Check if VUI.Media exists and has the textures with safe navigation
    local hasMedia = (VUI and VUI.Media and VUI.Media.textures and VUI.Media.textures.consumables)
    
    for type, frame in pairs(self.iconFrames) do
        if frame.active then
            local timeLeft = frame.expirationTime - currentTime
            
            -- Determine if close to expiring
            local isExpiring = timeLeft < self.db.profile.warningThreshold
            
            -- Update appearance based on state
            if isExpiring and self.db.profile.flashWarning then
                local alpha = 0.5 + math.abs(math.sin(currentTime * 3)) * 0.5
                frame:SetAlpha(alpha)
                
                -- Set border to red for warning
                frame:SetBackdropBorderColor(1, 0, 0, 1)
            else
                frame:SetAlpha(1)
                
                -- Reset border color
                local borderColor = self.db.profile.borderColor
                frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            end
            
            -- Update duration text
            if self.db.profile.showDuration then
                if timeLeft > 3600 then
                    frame.duration:SetText(string.format("%.1fh", timeLeft/3600))
                elseif timeLeft > 60 then
                    frame.duration:SetText(string.format("%.1fm", timeLeft/60))
                else
                    frame.duration:SetText(string.format("%.0fs", timeLeft))
                end
                
                -- Color duration text based on time left
                if timeLeft < 30 then
                    frame.duration:SetTextColor(1, 0, 0, 1) -- Red for < 30 seconds
                elseif timeLeft < 300 then
                    frame.duration:SetTextColor(1, 0.5, 0, 1) -- Orange for < 5 minutes
                else
                    local durationColor = self.db.profile.durationFontColor
                    frame.duration:SetTextColor(durationColor.r, durationColor.g, durationColor.b, durationColor.a)
                end
            else
                frame.duration:SetText("")
            end
            
            -- Show if active or if we're showing all icons
            frame:Show()
        else
            -- Handle inactive state
            if self.db.profile.activeOnly then
                frame:Hide()
            else
                frame:Show()
                frame:SetAlpha(0.3) -- Dim inactive icons
                
                -- Get appropriate icon texture with fallback
                local iconTexture
                
                if hasMedia then
                    -- Use VUI media textures if available
                    if type == M.FLASK then
                        iconTexture = VUI.Media.textures.consumables.flask or defaultTextures[M.FLASK]
                    elseif type == M.FOOD then
                        iconTexture = VUI.Media.textures.consumables.food or defaultTextures[M.FOOD]
                    elseif type == M.POTION then
                        iconTexture = VUI.Media.textures.consumables.potion or defaultTextures[M.POTION]
                    elseif type == M.RUNE then
                        iconTexture = VUI.Media.textures.consumables.rune or defaultTextures[M.RUNE]
                    else
                        iconTexture = VUI.Media.textures.consumables.question or defaultTextures["default"]
                    end
                else
                    -- Use default textures
                    iconTexture = defaultTextures[type] or defaultTextures["default"]
                end
                
                frame.icon:SetTexture(iconTexture)
                frame.duration:SetText("")
                
                -- Reset label text to just show the type
                frame.label:SetText(type)
                
                -- Gray border for inactive
                frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.7)
            end
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
                    appearance = {
                        name = L["Appearance"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            scale = {
                                name = L["Scale"],
                                desc = L["Adjust the size of the consumables display"],
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
                                desc = L["Adjust the transparency of the consumables display"],
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
                            activeOnly = {
                                name = L["Show Active Only"],
                                desc = L["Only show icons for active consumables"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.activeOnly end,
                                set = function(info, value)
                                    self.db.profile.activeOnly = value
                                    self:UpdateIconFrames()
                                end,
                            },
                        },
                    },
                    display = {
                        name = L["Display"],
                        type = "group",
                        order = 4,
                        inline = true,
                        args = {
                            showFlasks = {
                                name = L["Show Flasks"],
                                desc = L["Show flask tracking icon"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.showFlasks end,
                                set = function(info, value)
                                    self.db.profile.showFlasks = value
                                    -- Recreate frames if this changes
                                    self:CreateIconFrames()
                                end,
                            },
                            showFood = {
                                name = L["Show Food"],
                                desc = L["Show food buff tracking icon"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.showFood end,
                                set = function(info, value)
                                    self.db.profile.showFood = value
                                    -- Recreate frames if this changes
                                    self:CreateIconFrames()
                                end,
                            },
                            showPotions = {
                                name = L["Show Potions"],
                                desc = L["Show potion tracking icon"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.showPotions end,
                                set = function(info, value)
                                    self.db.profile.showPotions = value
                                    -- Recreate frames if this changes
                                    self:CreateIconFrames()
                                end,
                            },
                            showRunes = {
                                name = L["Show Runes"],
                                desc = L["Show augment rune tracking icon"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.showRunes end,
                                set = function(info, value)
                                    self.db.profile.showRunes = value
                                    -- Recreate frames if this changes
                                    self:CreateIconFrames()
                                end,
                            },
                        },
                    },
                    warnings = {
                        name = L["Warnings"],
                        type = "group",
                        order = 5,
                        inline = true,
                        args = {
                            flashWarning = {
                                name = L["Flash Warning"],
                                desc = L["Flash icons when consumables are about to expire"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.flashWarning end,
                                set = function(info, value)
                                    self.db.profile.flashWarning = value
                                end,
                            },
                            warningThreshold = {
                                name = L["Warning Threshold"],
                                desc = L["Seconds before expiration to begin warning"],
                                type = "range",
                                order = 2,
                                min = 10,
                                max = 300,
                                step = 5,
                                get = function() return self.db.profile.warningThreshold end,
                                set = function(info, value)
                                    self.db.profile.warningThreshold = value
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

-- Register the module with VUI if the method exists
if VUI and VUI.RegisterModule then
    VUI:RegisterModule(MODNAME, M)
else 
    -- Fallback if RegisterModule is not available
    -- Store a reference in VUI's namespace so it can be accessed
    if VUI then
        VUI[MODNAME] = M
        -- No need to print a message - this is expected behavior during initialization
    end
end

-- Add a new function after this code:

-- Add slash command functionality
if M and type(M.RegisterChatCommand) == "function" then
    -- Safely try to register chat command
    pcall(function()
        M:RegisterChatCommand("vuiconsumables", function(input)
            if input and input:trim() == "toggle" then
                M.db.profile.enabled = not M.db.profile.enabled
                if M.db.profile.enabled then
                    if M.OnEnable then M:OnEnable() end
                else
                    if M.OnDisable then M:OnDisable() end
                end
                M:Print(M.db.profile.enabled and "Enabled" or "Disabled")
            else
                -- Open config if available
                if VUI and VUI.Config and VUI.Config.OpenToCategory then
                    pcall(function() VUI.Config:OpenToCategory(M.TITLE) end)
                else
                    M:Print("Type /vuiconsumables toggle to toggle the module")
                end
            end
        end)
        
        -- Add shorter alias command
        M:RegisterChatCommand("vuicons", function(input)
            if input and input:trim() == "toggle" then
                M.db.profile.enabled = not M.db.profile.enabled
                if M.db.profile.enabled then
                    if M.OnEnable then M:OnEnable() end
                else
                    if M.OnDisable then M:OnDisable() end
                end
                M:Print(M.db.profile.enabled and "Enabled" or "Disabled")
            else
                -- Open config if available
                if VUI and VUI.Config and VUI.Config.OpenToCategory then
                    pcall(function() VUI.Config:OpenToCategory(M.TITLE) end)
                else
                    M:Print("Type /vuicons toggle to toggle the module")
                end
            end
        end)
    end)
else
    -- Fallback slash command registration if AceConsole is not available
    _G.SLASH_VUICONSUMABLES1 = "/vuiconsumables"
    _G.SLASH_VUICONSUMABLES2 = "/vuicons"
    SlashCmdList["VUICONSUMABLES"] = function(input)
        if input and input:trim() == "toggle" then
            M.db.profile.enabled = not M.db.profile.enabled
            if M.db.profile.enabled then
                if M.OnEnable then M:OnEnable() end
            else
                if M.OnDisable then M:OnDisable() end
            end
            M:Print(M.db.profile.enabled and "Enabled" or "Disabled")
        else
            -- Open config if available
            if VUI and VUI.Config and VUI.Config.OpenToCategory then
                pcall(function() VUI.Config:OpenToCategory(M.TITLE) end)
            else
                M:Print("Type /vuiconsumables toggle to toggle the module")
            end
        end
    end
end