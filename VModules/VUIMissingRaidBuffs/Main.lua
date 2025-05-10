-- VUIMissingRaidBuffs Module
-- Scans group/raid for missing standard buffs
-- Based on Missing Raid Buffs WeakAura (https://wago.io/BQce7Fj5J)

local AddonName, VUI = ...
local MODNAME = "VUIMissingRaidBuffs"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Missing Raid Buffs"
M.DESCRIPTION = "Shows missing raid buffs in group/raid"
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
        iconSize = 32,
        iconSpacing = 5,
        displayInCombatOnly = false,
        displayInGroupOnly = true,
        showWarning = true,
        warningSound = true,
        warningThreshold = 10, -- Seconds before pull to warn about missing buffs
        warningMessage = true, -- Show warning message in chat
        
        -- Visual settings
        growthDirection = "RIGHT", -- RIGHT, LEFT, UP, DOWN
        backgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
        borderColor = {r = 1, g = 1, b = 1, a = 1},
        showTooltip = true,
        
        -- Text settings
        showStatus = true,
        statusFontSize = 12,
        statusFontColor = {r = 1, g = 1, b = 1, a = 1},
        
        -- Buffs to track
        trackIntellect = true,
        trackStamina = true,
        trackAttackPower = true,
        trackHaste = true,
        trackSpellPower = true,
        trackKings = true, -- Stats
        trackMight = true, -- Stats
        trackHorn = true, -- Bloodlust/Heroism
    }
}

-- Raid buff data
M.raidBuffs = {
    intellect = {
        name = L["Intellect"],
        icon = 136222, -- Intellect icon
        spellIDs = {
            [1459] = true,    -- Arcane Intellect (Mage)
        },
        checkFunction = function() return GetSpellBuff("player", 1459) end,
        providedBy = {
            [8] = true, -- Mage
        },
        warning = L["Missing Intellect buff!"],
        track = "trackIntellect",
        priority = 90,
        stat = 1, -- Intellect
    },
    
    stamina = {
        name = L["Stamina"],
        icon = 135932, -- Stamina icon
        spellIDs = {
            [21562] = true,   -- Power Word: Fortitude (Priest)
        },
        checkFunction = function() return GetSpellBuff("player", 21562) end,
        providedBy = {
            [5] = true, -- Priest
        },
        warning = L["Missing Stamina buff!"],
        track = "trackStamina",
        priority = 95,
        stat = 3, -- Stamina
    },
    
    attackPower = {
        name = L["Attack Power"],
        icon = 132333, -- Attack power icon
        spellIDs = {
            [6673] = true,    -- Battle Shout (Warrior)
        },
        checkFunction = function() return GetSpellBuff("player", 6673) end,
        providedBy = {
            [1] = true, -- Warrior
        },
        warning = L["Missing Attack Power buff!"],
        track = "trackAttackPower",
        priority = 80,
        stat = 6, -- Attack Power
    },
    
    haste = {
        name = L["Haste"],
        icon = 135906, -- Haste icon
        spellIDs = {
            [49868] = true,   -- Mind Quickening (Priest)
            [113742] = true,  -- Swiftblade's Cunning (Rogue)
        },
        checkFunction = function() 
            return GetSpellBuff("player", 49868) or GetSpellBuff("player", 113742)
        end,
        providedBy = {
            [5] = true, -- Priest
            [4] = true, -- Rogue
        },
        warning = L["Missing Haste buff!"],
        track = "trackHaste",
        priority = 75,
    },
    
    kings = {
        name = L["Blessing of Kings"],
        icon = 135995, -- Blessing of Kings icon
        spellIDs = {
            [203538] = true,   -- Greater Blessing of Kings (Paladin)
        },
        checkFunction = function() return GetSpellBuff("player", 203538) end,
        providedBy = {
            [2] = true, -- Paladin
        },
        warning = L["Missing Kings buff!"],
        track = "trackKings",
        priority = 85,
    },
    
    might = {
        name = L["Blessing of Might"],
        icon = 135906, -- Blessing of Might icon
        spellIDs = {
            [203539] = true,   -- Greater Blessing of Might (Paladin)
        },
        checkFunction = function() return GetSpellBuff("player", 203539) end,
        providedBy = {
            [2] = true, -- Paladin
        },
        warning = L["Missing Might buff!"],
        track = "trackMight",
        priority = 83,
    },
    
    bloodlust = {
        name = L["Bloodlust/Heroism"],
        icon = 132313, -- Bloodlust icon
        spellIDs = {
            [2825] = true,    -- Bloodlust (Shaman)
            [32182] = true,   -- Heroism (Shaman)
            [80353] = true,   -- Time Warp (Mage)
            [264667] = true,  -- Primal Rage (Hunter pet)
        },
        debuffIDs = {
            [57724] = true,   -- Sated (Bloodlust debuff)
            [57723] = true,   -- Exhaustion (Heroism debuff)
            [80354] = true,   -- Temporal Displacement (Time Warp debuff)
            [264689] = true,  -- Fatigued (Primal Rage debuff)
        },
        checkFunction = function() 
            return GetSpellBuff("player", 2825) or 
                   GetSpellBuff("player", 32182) or 
                   GetSpellBuff("player", 80353) or 
                   GetSpellBuff("player", 264667) or
                   GetSpellDebuff("player", 57724) or
                   GetSpellDebuff("player", 57723) or
                   GetSpellDebuff("player", 80354) or
                   GetSpellDebuff("player", 264689)
        end,
        providedBy = {
            [7] = true, -- Shaman
            [8] = true, -- Mage
            [3] = true, -- Hunter (pet)
        },
        temporary = true, -- This is a temporary buff, not expected to be present at all times
        warning = L["Don't forget to use Bloodlust/Heroism!"],
        track = "trackHorn",
        priority = 100,
    },
}

-- Helper function to check for buff by spell ID
function GetSpellBuff(unit, spellID)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, id = UnitBuff(unit, i)
        if not name then break end
        if id == spellID then return true end
        i = i + 1
    end
    return false
end

-- Helper function to check for debuff by spell ID
function GetSpellDebuff(unit, spellID)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, id = UnitDebuff(unit, i)
        if not name then break end
        if id == spellID then return true end
        i = i + 1
    end
    return false
end

-- Initialize module
function M:OnInitialize()
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(MODNAME, self.defaults)
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    
    -- Missing buffs tracking
    self.missingBuffs = {}
    
    -- Create frames
    self:CreateFrames()
    
    self:Debug("VUIMissingRaidBuffs module initialized")
end

function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateGroupStatus")
    self:RegisterEvent("UNIT_AURA", "CheckBuffs")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisibility") -- Entered combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility") -- Left combat
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateDisplay", 1.0)
    
    -- Check if we're in a group
    self:UpdateGroupStatus()
    
    -- Initial buff check
    self:CheckBuffs()
    
    -- Initial display update
    self:UpdateDisplay()
    
    self:Debug("VUIMissingRaidBuffs module enabled")
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
    
    self:Debug("VUIMissingRaidBuffs module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    VUI:Debug(MODNAME, ...)
end

function M:Print(...)
    VUI:Print("|cFFFF6600VUI Missing Raid Buffs:|r", ...)
end

-- Create container frame
function M:CreateFrames()
    -- Main frame
    self.containerFrame = CreateFrame("Frame", "VUIMissingRaidBuffsFrame", UIParent)
    self.containerFrame:SetSize(300, 50)
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
    
    -- Icon frames container
    self.iconFrames = {}
    
    -- Set visibility based on enabled state
    if self.db.profile.enabled then
        self:UpdateVisibility()
    else
        self.containerFrame:Hide()
    end
end

-- Create or update an icon frame for a buff
function M:GetIconFrame(buffKey, index)
    if not self.iconFrames[buffKey] then
        local frame = CreateFrame("Frame", "VUIMissingRaidBuffsIcon_"..buffKey, self.containerFrame, "BackdropTemplate")
        local iconSize = self.db.profile.iconSize
        frame:SetSize(iconSize, iconSize)
        
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
        
        -- Status text
        frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.status:SetPoint("BOTTOM", 0, 2)
        frame.status:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.statusFontSize, "OUTLINE")
        
        local statusColor = self.db.profile.statusFontColor
        frame.status:SetTextColor(statusColor.r, statusColor.g, statusColor.b, statusColor.a)
        
        -- Tooltip
        if self.db.profile.showTooltip then
            frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local buff = M.raidBuffs[buffKey]
                GameTooltip:SetText(buff.name)
                
                -- Show list of classes that can provide this buff
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["Provided By:"])
                
                local addedClass = false
                for classID, _ in pairs(buff.providedBy) do
                    local className = LOCALIZED_CLASS_NAMES_MALE[classID]
                    if className then
                        local classColor = RAID_CLASS_COLORS[classID]
                        if classColor then
                            GameTooltip:AddLine(className, classColor.r, classColor.g, classColor.b)
                        else
                            GameTooltip:AddLine(className)
                        end
                        addedClass = true
                    end
                end
                
                if not addedClass then
                    GameTooltip:AddLine(L["Unknown"], 1, 0, 0)
                end
                
                GameTooltip:Show()
            end)
            
            frame:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        
        -- Store the frame
        self.iconFrames[buffKey] = frame
    end
    
    -- Position the frame based on index and growth direction
    local frame = self.iconFrames[buffKey]
    local iconSize = self.db.profile.iconSize
    local spacing = self.db.profile.iconSpacing
    
    -- Position based on growth direction
    if self.db.profile.growthDirection == "RIGHT" then
        frame:SetPoint("LEFT", self.containerFrame, "LEFT", (index - 1) * (iconSize + spacing), 0)
    elseif self.db.profile.growthDirection == "LEFT" then
        frame:SetPoint("RIGHT", self.containerFrame, "RIGHT", -((index - 1) * (iconSize + spacing)), 0)
    elseif self.db.profile.growthDirection == "UP" then
        frame:SetPoint("BOTTOM", self.containerFrame, "BOTTOM", 0, (index - 1) * (iconSize + spacing))
    else -- DOWN
        frame:SetPoint("TOP", self.containerFrame, "TOP", 0, -((index - 1) * (iconSize + spacing)))
    end
    
    return frame
end

-- Update visibility based on group status and combat
function M:UpdateVisibility()
    local shouldShow = true
    
    -- Check if we should only show in group
    if self.db.profile.displayInGroupOnly and not IsInGroup() then
        shouldShow = false
    end
    
    -- Check if we should only show in combat
    if self.db.profile.displayInCombatOnly and not UnitAffectingCombat("player") then
        shouldShow = false
    end
    
    -- Update visibility
    if shouldShow and self.db.profile.enabled then
        self.containerFrame:Show()
    else
        self.containerFrame:Hide()
    end
end

-- Check group status
function M:UpdateGroupStatus()
    self.inGroup = IsInGroup()
    self.inRaid = IsInRaid()
    
    -- Update visibility based on group status
    self:UpdateVisibility()
    
    -- Check buffs if we're in a group
    if self.inGroup then
        self:CheckBuffs()
    end
end

-- Check for missing buffs
function M:CheckBuffs(event, unit)
    -- Skip units other than player or party/raid members
    if unit and unit ~= "player" and not unit:match("^party%d$") and not unit:match("^raid%d+$") then
        return
    end
    
    -- Clear missing buffs
    wipe(self.missingBuffs)
    
    -- Only check buffs if we're in a group and alive
    if (self.inGroup or not self.db.profile.displayInGroupOnly) and not UnitIsDeadOrGhost("player") then
        -- Check each raid buff
        for buffKey, buffData in pairs(self.raidBuffs) do
            if self.db.profile[buffData.track] then
                -- Skip temporary buffs (like Bloodlust) for normal checks
                if not buffData.temporary or event == "ENCOUNTER_START" then
                    local hasThisBuff = false
                    
                    -- Use the specific check function if provided
                    if buffData.checkFunction then
                        hasThisBuff = buffData.checkFunction()
                    else
                        -- Check for any of the spell IDs
                        for spellID, _ in pairs(buffData.spellIDs) do
                            if GetSpellBuff("player", spellID) then
                                hasThisBuff = true
                                break
                            end
                        end
                    end
                    
                    -- Check if we have a suitable equivalent
                    if not hasThisBuff and buffData.stat then
                        -- TODO: Add checks for equivalent buffs by stat type
                    end
                    
                    -- If the buff is missing, add it to the list
                    if not hasThisBuff then
                        self.missingBuffs[buffKey] = buffData
                    end
                end
            end
        end
    end
    
    -- Update the display
    self:UpdateDisplay()
end

-- Update the display of missing buffs
function M:UpdateDisplay()
    if not self.containerFrame then return end
    
    -- Hide all icons first
    for _, frame in pairs(self.iconFrames) do
        frame:Hide()
    end
    
    -- Sort missing buffs by priority
    local sortedBuffs = {}
    for buffKey, buffData in pairs(self.missingBuffs) do
        table.insert(sortedBuffs, {key = buffKey, data = buffData})
    end
    
    table.sort(sortedBuffs, function(a, b) 
        return (a.data.priority or 0) > (b.data.priority or 0)
    end)
    
    -- Display missing buffs
    local currentIndex = 1
    for _, buffInfo in ipairs(sortedBuffs) do
        local buffKey = buffInfo.key
        local buffData = buffInfo.data
        
        local frame = self:GetIconFrame(buffKey, currentIndex)
        
        -- Set icon
        frame.icon:SetTexture(buffData.icon)
        
        -- Status text
        if self.db.profile.showStatus then
            frame.status:SetText(L["Missing"])
            frame.status:SetTextColor(1, 0, 0, 1) -- Red for missing
        else
            frame.status:SetText("")
        end
        
        -- Show the frame
        frame:Show()
        
        -- Increment index for next buff
        currentIndex = currentIndex + 1
    end
    
    -- Update container size based on growth direction
    local iconSize = self.db.profile.iconSize
    local spacing = self.db.profile.iconSpacing
    local count = #sortedBuffs
    
    if count > 0 then
        if self.db.profile.growthDirection == "RIGHT" or self.db.profile.growthDirection == "LEFT" then
            self.containerFrame:SetSize(count * iconSize + (count - 1) * spacing, iconSize)
        else -- UP or DOWN
            self.containerFrame:SetSize(iconSize, count * iconSize + (count - 1) * spacing)
        end
        
        -- Show the container
        self:UpdateVisibility()
    else
        -- No missing buffs, hide the container
        self.containerFrame:Hide()
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
        icon = "Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm.tga",
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
                    displayInGroupOnly = {
                        name = L["Display In Group Only"],
                        desc = L["Only show missing buffs while in a group/raid"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.displayInGroupOnly end,
                        set = function(info, value)
                            self.db.profile.displayInGroupOnly = value
                            self:UpdateVisibility()
                        end,
                    },
                    displayInCombatOnly = {
                        name = L["Display In Combat Only"],
                        desc = L["Only show missing buffs while in combat"],
                        type = "toggle",
                        order = 4,
                        get = function() return self.db.profile.displayInCombatOnly end,
                        set = function(info, value)
                            self.db.profile.displayInCombatOnly = value
                            self:UpdateVisibility()
                        end,
                    },
                    appearance = {
                        name = L["Appearance"],
                        type = "group",
                        order = 5,
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
                                min = 16,
                                max = 64,
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
                            showTooltip = {
                                name = L["Show Tooltips"],
                                desc = L["Show tooltips with buff information"],
                                type = "toggle",
                                order = 6,
                                get = function() return self.db.profile.showTooltip end,
                                set = function(info, value)
                                    self.db.profile.showTooltip = value
                                    -- Recreate frames for tooltip change
                                    self.iconFrames = {}
                                    self:UpdateDisplay()
                                end,
                            },
                            showStatus = {
                                name = L["Show Status Text"],
                                desc = L["Show 'Missing' text below icons"],
                                type = "toggle",
                                order = 7,
                                get = function() return self.db.profile.showStatus end,
                                set = function(info, value)
                                    self.db.profile.showStatus = value
                                    self:UpdateDisplay()
                                end,
                            },
                        },
                    },
                    warnings = {
                        name = L["Warnings"],
                        type = "group",
                        order = 6,
                        inline = true,
                        args = {
                            showWarning = {
                                name = L["Show Warnings"],
                                desc = L["Show warnings for missing buffs before encounters"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.showWarning end,
                                set = function(info, value)
                                    self.db.profile.showWarning = value
                                end,
                            },
                            warningSound = {
                                name = L["Play Warning Sound"],
                                desc = L["Play sound when warning about missing buffs"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.warningSound end,
                                set = function(info, value)
                                    self.db.profile.warningSound = value
                                end,
                            },
                            warningMessage = {
                                name = L["Show Warning Message"],
                                desc = L["Display a chat message about missing buffs"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.warningMessage end,
                                set = function(info, value)
                                    self.db.profile.warningMessage = value
                                end,
                            },
                        },
                    },
                },
            },
            buffs = {
                name = L["Buff Tracking"],
                type = "group",
                order = 2,
                args = {
                    trackIntellect = {
                        name = L["Track Intellect"],
                        desc = L["Check for missing Intellect buff"],
                        type = "toggle",
                        order = 1,
                        get = function() return self.db.profile.trackIntellect end,
                        set = function(info, value)
                            self.db.profile.trackIntellect = value
                            self:CheckBuffs()
                        end,
                    },
                    trackStamina = {
                        name = L["Track Stamina"],
                        desc = L["Check for missing Stamina buff"],
                        type = "toggle",
                        order = 2,
                        get = function() return self.db.profile.trackStamina end,
                        set = function(info, value)
                            self.db.profile.trackStamina = value
                            self:CheckBuffs()
                        end,
                    },
                    trackAttackPower = {
                        name = L["Track Attack Power"],
                        desc = L["Check for missing Attack Power buff"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.trackAttackPower end,
                        set = function(info, value)
                            self.db.profile.trackAttackPower = value
                            self:CheckBuffs()
                        end,
                    },
                    trackHaste = {
                        name = L["Track Haste"],
                        desc = L["Check for missing Haste buff"],
                        type = "toggle",
                        order = 4,
                        get = function() return self.db.profile.trackHaste end,
                        set = function(info, value)
                            self.db.profile.trackHaste = value
                            self:CheckBuffs()
                        end,
                    },
                    trackKings = {
                        name = L["Track Kings"],
                        desc = L["Check for missing Kings buff"],
                        type = "toggle",
                        order = 5,
                        get = function() return self.db.profile.trackKings end,
                        set = function(info, value)
                            self.db.profile.trackKings = value
                            self:CheckBuffs()
                        end,
                    },
                    trackMight = {
                        name = L["Track Might"],
                        desc = L["Check for missing Might buff"],
                        type = "toggle",
                        order = 6,
                        get = function() return self.db.profile.trackMight end,
                        set = function(info, value)
                            self.db.profile.trackMight = value
                            self:CheckBuffs()
                        end,
                    },
                    trackHorn = {
                        name = L["Track Bloodlust/Heroism"],
                        desc = L["Check for Bloodlust/Heroism at encounter start"],
                        type = "toggle",
                        order = 7,
                        get = function() return self.db.profile.trackHorn end,
                        set = function(info, value)
                            self.db.profile.trackHorn = value
                            self:CheckBuffs()
                        end,
                    },
                },
            },
        },
    }
    
    return options
end

-- Register the module
VUI:RegisterModule(MODNAME, M)