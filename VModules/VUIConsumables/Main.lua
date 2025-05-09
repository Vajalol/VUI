-- VUIConsumables Module
-- Tracks player consumables (flasks, food, potions, runes)
-- Based on Luxthos Consumables WeakAura

local AddonName, VUI = ...
local MODNAME = "VUIConsumables"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

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
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(MODNAME, self.defaults)
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    
    -- Frame setup - create the main container frame
    self:CreateFrames()
    
    self:Debug("VUIConsumables module initialized")
end

function M:OnEnable()
    -- Create the icon frames
    self:CreateIconFrames()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA", "UpdateConsumables")
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateConsumables", 0.5)
    
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
    VUI:Debug(MODNAME, ...)
end

function M:Print(...)
    VUI:Print("|cFF33BBFFVUI Consumables:|r", ...)
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

-- Create individual icon frames for each consumable type
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
            
            -- Set default state using our media texture
            frame.type = data.type
            frame.active = false
            
            -- Use appropriate icon based on type
            if data.type == M.FLASK then
                frame.icon:SetTexture(VUI.Media.textures.consumables.flask)
            elseif data.type == M.FOOD then
                frame.icon:SetTexture(VUI.Media.textures.consumables.food)
            elseif data.type == M.POTION then
                frame.icon:SetTexture(VUI.Media.textures.consumables.potion)
            elseif data.type == M.RUNE then
                frame.icon:SetTexture(VUI.Media.textures.consumables.rune)
            else
                frame.icon:SetTexture(VUI.Media.textures.consumables.question)
            end
            
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
    
    -- Scan all player auras
    local i = 1
    local name, icon, count, debuffType, duration, expirationTime, unitCaster, 
          isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
          isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3 = UnitAura("player", i, "HELPFUL")
    
    while name do
        self:ProcessAura(spellId, name, icon, duration, expirationTime)
        
        i = i + 1
        name, icon, count, debuffType, duration, expirationTime, unitCaster, 
        isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
        isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3 = UnitAura("player", i, "HELPFUL")
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
                
                -- Use appropriate icon for the type
                if type == M.FLASK then
                    frame.icon:SetTexture(VUI.Media.textures.consumables.flask)
                elseif type == M.FOOD then
                    frame.icon:SetTexture(VUI.Media.textures.consumables.food)
                elseif type == M.POTION then
                    frame.icon:SetTexture(VUI.Media.textures.consumables.potion)
                elseif type == M.RUNE then
                    frame.icon:SetTexture(VUI.Media.textures.consumables.rune)
                else
                    frame.icon:SetTexture(VUI.Media.textures.consumables.question)
                end
                
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

-- Register the module
VUI:RegisterModule(MODNAME, M)