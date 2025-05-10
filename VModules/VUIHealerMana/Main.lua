-- VUIHealerMana Module
-- Displays healer mana in group/raid
-- Based on Healer Mana WeakAura (https://wago.io/ebWkTh8By)

local AddonName, VUI = ...
local MODNAME = "VUIHealerMana"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Healer Mana"
M.DESCRIPTION = "Displays healer mana in group/raid"
M.VERSION = "1.0"

-- Class identification constants
local PRIEST = 5
local PALADIN = 2
local DRUID = 11
local MONK = 10
local SHAMAN = 7
local EVOKER = 13

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        scale = 1.0,
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = 0,
        width = 250,
        height = 20,
        spacing = 2,
        barTexture = "VUI Gradient",
        fontName = "Arial Narrow",
        fontSize = 12,
        showSelf = true,
        showParty = true,
        showRaid = true,
        
        -- Visual settings
        outlineMode = "OUTLINE",
        textPosition = "CENTER",
        growDirection = "DOWN",
        showIcon = true,
        showName = true,
        showPercent = true,
        showValue = false,
        
        -- Color settings
        useClassColors = true,
        backgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
        borderColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.8},
        customBarColor = {r = 0, g = 0.4, b = 0.8, a = 1},
        textColor = {r = 1, g = 1, b = 1, a = 1},
        
        -- Threshold settings
        useLowManaAlert = true,
        lowManaThreshold = 20,
        lowManaColor = {r = 1, g = 0, b = 0, a = 1},
        
        -- Filter settings
        showOutOfRange = true,
        showOffline = false,
        showDead = true,
        
        -- Auto-hide settings
        hideOutOfCombat = false,
        hideInRestArea = false,
        hideInDungeon = false,
        hideInBG = false,
    }
}

-- Healer specs by class ID
M.healerSpecs = {
    [PRIEST] = {
        [256] = true, -- Discipline
        [257] = true, -- Holy
    },
    [PALADIN] = {
        [65] = true, -- Holy
    },
    [DRUID] = {
        [105] = true, -- Restoration
    },
    [MONK] = {
        [270] = true, -- Mistweaver
    },
    [SHAMAN] = {
        [264] = true, -- Restoration
    },
    [EVOKER] = {
        [1468] = true, -- Preservation
    },
}

-- Initialize module
function M:OnInitialize()
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(MODNAME, self.defaults)
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    
    -- Initialize storage for healer data
    self.healers = {}
    self.healerFrames = {}
    
    -- Create main container
    self:CreateFrames()
    
    self:Debug("VUIHealerMana module initialized")
end

function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateGroup")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateGroup")
    self:RegisterEvent("UNIT_POWER_UPDATE", "UpdateUnitPower")
    self:RegisterEvent("UNIT_POWER_FREQUENT", "UpdateUnitPower")
    self:RegisterEvent("UNIT_DISPLAYPOWER", "UpdateUnitPower")
    self:RegisterEvent("UNIT_MAXPOWER", "UpdateUnitPower")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisibility") -- Entered combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility") -- Left combat
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateVisibility") -- Zone change
    self:RegisterEvent("PLAYER_DEAD", "UpdateGroup") -- Player death
    self:RegisterEvent("PLAYER_ALIVE", "UpdateGroup") -- Player alive
    self:RegisterEvent("UNIT_HEALTH", "UpdateUnitHealth") -- Health change
    
    -- Update timer for range checks
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateRange", 1.0)
    
    -- Initial group scan
    self:UpdateGroup()
    
    -- Initial visibility update
    self:UpdateVisibility()
    
    self:Debug("VUIHealerMana module enabled")
end

function M:OnDisable()
    -- Clear timers
    if self.updateTimer then
        self:CancelTimer(self.updateTimer)
        self.updateTimer = nil
    end
    
    -- Hide frames
    self.container:Hide()
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Clear data
    wipe(self.healers)
    self:ClearAllBars()
    
    self:Debug("VUIHealerMana module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    VUI:Debug(MODNAME, ...)
end

function M:Print(...)
    VUI:Print("|cFFFF6600VUI Healer Mana:|r", ...)
end

-- Create frames
function M:CreateFrames()
    -- Main container frame
    self.container = CreateFrame("Frame", "VUIHealerManaContainer", UIParent, "BackdropTemplate")
    self.container:SetSize(self.db.profile.width, 30) -- Initial height, will be adjusted
    self.container:SetPoint(
        self.db.profile.point,
        UIParent,
        self.db.profile.relativePoint,
        self.db.profile.xOffset,
        self.db.profile.yOffset
    )
    self.container:SetScale(self.db.profile.scale)
    self.container:SetFrameStrata("MEDIUM")
    self.container:SetClampedToScreen(true)
    
    -- Background
    self.container:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    
    local bg = self.db.profile.backgroundColor
    local border = self.db.profile.borderColor
    self.container:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
    self.container:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
    
    -- Make container draggable when unlocked
    self.container:SetMovable(true)
    self.container:EnableMouse(false)
    self.container:RegisterForDrag("LeftButton")
    self.container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.container:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        M.db.profile.point = point
        M.db.profile.relativePoint = relativePoint
        M.db.profile.xOffset = xOffset
        M.db.profile.yOffset = yOffset
    end)
    
    -- Title text
    self.container.title = self.container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.container.title:SetPoint("TOP", self.container, "TOP", 0, -2)
    self.container.title:SetText(L["Healer Mana"])
    self.container.title:Hide() -- Hidden by default, shown when unlocked
    
    -- Initial hide if not enabled
    if not self.db.profile.enabled then
        self.container:Hide()
    end
end

-- Create/update a healer bar for a unit
function M:CreateHealerBar(unit, index)
    local frame = self.healerFrames[unit]
    
    if not frame then
        -- Create new bar frame
        frame = CreateFrame("Frame", "VUIHealerManaBar_"..unit, self.container, "BackdropTemplate")
        frame:SetSize(self.db.profile.width, self.db.profile.height)
        
        -- Create background
        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
        frame.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
        frame.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        -- Create mana bar
        frame.bar = CreateFrame("StatusBar", nil, frame)
        frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        frame.bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        frame.bar:SetMinMaxValues(0, 100)
        frame.bar:SetValue(100)
        
        -- Set bar texture
        local texture = LSM:Fetch("statusbar", self.db.profile.barTexture) or "Interface\\Buttons\\WHITE8x8"
        frame.bar:SetStatusBarTexture(texture)
        
        -- Class icon
        frame.icon = frame:CreateTexture(nil, "OVERLAY")
        frame.icon:SetSize(self.db.profile.height - 2, self.db.profile.height - 2)
        frame.icon:SetPoint("LEFT", frame, "LEFT", 1, 0)
        
        -- Text elements
        frame.text = frame.bar:CreateFontString(nil, "OVERLAY")
        local font = LSM:Fetch("font", self.db.profile.fontName) or "Fonts\\FRIZQT__.TTF"
        frame.text:SetFont(font, self.db.profile.fontSize, self.db.profile.outlineMode)
        frame.text:SetTextColor(1, 1, 1, 1)
        
        -- Position text based on settings
        self:UpdateTextPosition(frame)
        
        -- Add to frames collection
        self.healerFrames[unit] = frame
    end
    
    -- Position the frame
    self:PositionHealerBar(frame, index)
    
    return frame
end

-- Position a healer bar
function M:PositionHealerBar(frame, index)
    local height = self.db.profile.height
    local spacing = self.db.profile.spacing
    local growthDir = self.db.profile.growDirection
    
    if growthDir == "DOWN" then
        frame:SetPoint("TOP", self.container, "TOP", 0, -((index - 1) * (height + spacing)) - spacing)
    elseif growthDir == "UP" then
        frame:SetPoint("BOTTOM", self.container, "BOTTOM", 0, ((index - 1) * (height + spacing)) + spacing)
    end
end

-- Update the text position on a bar
function M:UpdateTextPosition(frame)
    if not frame then return end
    
    local textPos = self.db.profile.textPosition
    local showIcon = self.db.profile.showIcon
    local iconOffset = (showIcon and self.db.profile.height or 0)
    
    frame.text:ClearAllPoints()
    
    if textPos == "LEFT" then
        frame.text:SetPoint("LEFT", frame.bar, "LEFT", iconOffset + 5, 0)
        frame.text:SetJustifyH("LEFT")
    elseif textPos == "RIGHT" then
        frame.text:SetPoint("RIGHT", frame.bar, "RIGHT", -5, 0)
        frame.text:SetJustifyH("RIGHT")
    else -- CENTER
        frame.text:SetPoint("CENTER", frame.bar, "CENTER", iconOffset/2, 0)
        frame.text:SetJustifyH("CENTER")
    end
end

-- Resize the container based on number of healers
function M:ResizeContainer()
    local count = #self.healers
    local height = self.db.profile.height
    local spacing = self.db.profile.spacing
    local totalHeight = (count * height) + ((count + 1) * spacing)
    
    self.container:SetHeight(totalHeight)
end

-- Clear all bars
function M:ClearAllBars()
    for unit, frame in pairs(self.healerFrames) do
        frame:Hide()
    end
end

-- Update all healer bars
function M:UpdateBars()
    -- Hide all frames first
    self:ClearAllBars()
    
    -- Sort healers by name
    table.sort(self.healers, function(a, b) 
        return (a.name or "") < (b.name or "")
    end)
    
    -- Create/update bars for each healer
    for i, healer in ipairs(self.healers) do
        local frame = self:CreateHealerBar(healer.unit, i)
        
        -- Update icon
        if self.db.profile.showIcon then
            local coords = CLASS_ICON_TCOORDS[healer.class]
            frame.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            if coords then
                frame.icon:SetTexCoord(unpack(coords))
            else
                frame.icon:SetTexCoord(0, 1, 0, 1)
            end
            frame.icon:Show()
        else
            frame.icon:Hide()
        end
        
        -- Update bar color
        if self.db.profile.useClassColors and healer.class then
            local color = RAID_CLASS_COLORS[healer.class]
            if color then
                frame.bar:SetStatusBarColor(color.r, color.g, color.b, 1)
            else
                local c = self.db.profile.customBarColor
                frame.bar:SetStatusBarColor(c.r, c.g, c.b, c.a)
            end
        else
            local c = self.db.profile.customBarColor
            frame.bar:SetStatusBarColor(c.r, c.g, c.b, c.a)
        end
        
        -- Update mana percentage
        local percent = healer.manaPercent or 100
        frame.bar:SetValue(percent)
        
        -- Check for low mana alert
        if self.db.profile.useLowManaAlert and percent <= self.db.profile.lowManaThreshold then
            local c = self.db.profile.lowManaColor
            frame.bar:SetStatusBarColor(c.r, c.g, c.b, c.a)
        end
        
        -- Update text
        local text = ""
        
        if self.db.profile.showName then
            text = healer.name or ""
        end
        
        if self.db.profile.showPercent then
            if text ~= "" then text = text .. " - " end
            text = text .. math.floor(percent) .. "%"
        end
        
        if self.db.profile.showValue and healer.mana and healer.maxMana then
            if text ~= "" then text = text .. " " end
            text = text .. "(" .. AbbreviateLargeNumbers(healer.mana) .. "/" .. AbbreviateLargeNumbers(healer.maxMana) .. ")"
        end
        
        -- Add status indicators
        if healer.isOffline then
            text = text .. " |cFFFF0000" .. L["Offline"] .. "|r"
        elseif healer.isDead then
            text = text .. " |cFFFF0000" .. L["Dead"] .. "|r"
        elseif not healer.inRange then
            text = text .. " |cFFFF9900" .. L["Out of Range"] .. "|r"
        end
        
        frame.text:SetText(text)
        
        -- Show the frame
        frame:Show()
    end
    
    -- Resize container
    self:ResizeContainer()
end

-- Update group members
function M:UpdateGroup()
    -- Clear healers
    wipe(self.healers)
    
    -- Check for player
    local playerIsHealer = self:IsHealer("player")
    if playerIsHealer and self.db.profile.showSelf then
        self:AddUnit("player")
    end
    
    -- Check if we're in a group
    if IsInGroup() then
        local prefix, count
        if IsInRaid() then
            if not self.db.profile.showRaid then return self:UpdateBars() end
            prefix, count = "raid", 40
        else
            if not self.db.profile.showParty then return self:UpdateBars() end
            prefix, count = "party", 4
        end
        
        -- Scan group members
        for i = 1, count do
            local unit = prefix .. i
            if UnitExists(unit) and self:IsHealer(unit) then
                self:AddUnit(unit)
            end
        end
    end
    
    -- Update bars
    self:UpdateBars()
    
    -- Update visibility
    self:UpdateVisibility()
end

-- Check if a unit is a healer
function M:IsHealer(unit)
    if not UnitExists(unit) then return false end
    
    -- Get class and spec
    local _, class = UnitClass(unit)
    if not class then return false end
    
    -- Check if the class can be a healer
    if not self.healerSpecs[class] then return false end
    
    -- For player, we can get current spec
    if unit == "player" then
        local specIndex = GetSpecialization()
        if not specIndex then return false end
        
        local specID = GetSpecializationInfo(specIndex)
        return self.healerSpecs[class][specID] or false
    end
    
    -- For other players, we need to make assumptions
    -- Check if the unit uses mana
    local powerType = UnitPowerType(unit)
    if powerType ~= Enum.PowerType.Mana then return false end
    
    -- Check for healing spells in action bars (only works for player)
    -- For others, we'll just assume any mana user of a healing class is a healer
    return true
end

-- Add a unit to the healers list
function M:AddUnit(unit)
    -- Get unit info
    local name, realm = UnitName(unit)
    if realm and realm ~= "" then
        name = name .. "-" .. realm
    end
    
    local _, class = UnitClass(unit)
    local mana = UnitPower(unit, Enum.PowerType.Mana)
    local maxMana = UnitPowerMax(unit, Enum.PowerType.Mana)
    local manaPercent = maxMana > 0 and (mana / maxMana * 100) or 100
    
    -- Check status
    local isDead = UnitIsDeadOrGhost(unit)
    local isOffline = not UnitIsConnected(unit)
    local inRange = UnitInRange(unit)
    
    -- Filter based on settings
    if isDead and not self.db.profile.showDead then return end
    if isOffline and not self.db.profile.showOffline then return end
    if not inRange and not self.db.profile.showOutOfRange then return end
    
    -- Add to healers list
    table.insert(self.healers, {
        unit = unit,
        name = name,
        class = class,
        mana = mana,
        maxMana = maxMana,
        manaPercent = manaPercent,
        isDead = isDead,
        isOffline = isOffline,
        inRange = inRange
    })
end

-- Update unit power changes
function M:UpdateUnitPower(event, unit)
    -- Check if this is a unit we're tracking
    for i, healer in ipairs(self.healers) do
        if healer.unit == unit then
            -- Update mana values
            healer.mana = UnitPower(unit, Enum.PowerType.Mana)
            healer.maxMana = UnitPowerMax(unit, Enum.PowerType.Mana)
            healer.manaPercent = healer.maxMana > 0 and (healer.mana / healer.maxMana * 100) or 100
            
            -- Update the display
            self:UpdateBars()
            return
        end
    end
end

-- Update unit health changes (for dead/alive status)
function M:UpdateUnitHealth(event, unit)
    -- Check if this is a unit we're tracking
    for i, healer in ipairs(self.healers) do
        if healer.unit == unit then
            -- Update status
            healer.isDead = UnitIsDeadOrGhost(unit)
            
            -- If the unit died and we don't show dead healers, rescan the group
            if healer.isDead and not self.db.profile.showDead then
                self:UpdateGroup()
                return
            end
            
            -- Update the display
            self:UpdateBars()
            return
        end
    end
end

-- Update range status
function M:UpdateRange()
    local updated = false
    
    -- Check all healers
    for i, healer in ipairs(self.healers) do
        local inRange = UnitInRange(healer.unit)
        if healer.inRange ~= inRange then
            healer.inRange = inRange
            updated = true
        end
    end
    
    -- Update if changes detected
    if updated then
        self:UpdateBars()
    end
end

-- Update display visibility
function M:UpdateVisibility()
    if not self.db.profile.enabled then
        self.container:Hide()
        return
    end
    
    -- Check for empty healers list
    if #self.healers == 0 then
        self.container:Hide()
        return
    end
    
    local shouldShow = true
    
    -- Check combat status
    if self.db.profile.hideOutOfCombat and not UnitAffectingCombat("player") then
        shouldShow = false
    end
    
    -- Check zone type
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        -- Check dungeon settings
        if instanceType == "party" and self.db.profile.hideInDungeon then
            shouldShow = false
        end
        
        -- Check battleground settings
        if instanceType == "pvp" or instanceType == "arena" and self.db.profile.hideInBG then
            shouldShow = false
        end
    elseif IsResting() and self.db.profile.hideInRestArea then
        -- Check rest area settings
        shouldShow = false
    end
    
    -- Update visibility
    if shouldShow then
        self.container:Show()
    else
        self.container:Hide()
    end
end

-- Toggle frame movability
function M:ToggleMovable(enable)
    if not self.container then return end
    
    self.container:EnableMouse(enable)
    if enable then
        -- Show title when unlocked
        self.container.title:Show()
        
        -- Update backdrop for visibility
        self.container:SetBackdropColor(0, 0, 0, 0.8)
        self.container:SetBackdropBorderColor(1, 1, 1, 1)
        
        self:Print(L["Frame unlocked for moving. Drag to reposition, then lock when finished."])
    else
        -- Hide title when locked
        self.container.title:Hide()
        
        -- Restore normal backdrop
        local bg = self.db.profile.backgroundColor
        local border = self.db.profile.borderColor
        self.container:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
        self.container:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
        
        self:Print(L["Frame locked."])
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
                        get = function() return self.container and self.container:IsMouseEnabled() end,
                        set = function(info, value) self:ToggleMovable(value) end,
                    },
                    scale = {
                        name = L["Scale"],
                        desc = L["Overall scale of the display"],
                        type = "range",
                        order = 3,
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return self.db.profile.scale end,
                        set = function(info, value)
                            self.db.profile.scale = value
                            if self.container then
                                self.container:SetScale(value)
                            end
                        end,
                    },
                    showHeader = {
                        name = L["Display Settings"],
                        type = "header",
                        order = 4,
                    },
                    showSelf = {
                        name = L["Show Self"],
                        desc = L["Show your own mana if you're a healer"],
                        type = "toggle",
                        order = 5,
                        get = function() return self.db.profile.showSelf end,
                        set = function(info, value)
                            self.db.profile.showSelf = value
                            self:UpdateGroup()
                        end,
                    },
                    showParty = {
                        name = L["Show Party"],
                        desc = L["Show mana for healers in your party"],
                        type = "toggle",
                        order = 6,
                        get = function() return self.db.profile.showParty end,
                        set = function(info, value)
                            self.db.profile.showParty = value
                            self:UpdateGroup()
                        end,
                    },
                    showRaid = {
                        name = L["Show Raid"],
                        desc = L["Show mana for healers in your raid"],
                        type = "toggle",
                        order = 7,
                        get = function() return self.db.profile.showRaid end,
                        set = function(info, value)
                            self.db.profile.showRaid = value
                            self:UpdateGroup()
                        end,
                    },
                    growDirection = {
                        name = L["Growth Direction"],
                        desc = L["Direction in which new bars appear"],
                        type = "select",
                        order = 8,
                        values = {
                            ["DOWN"] = L["Down"],
                            ["UP"] = L["Up"],
                        },
                        get = function() return self.db.profile.growDirection end,
                        set = function(info, value)
                            self.db.profile.growDirection = value
                            self:UpdateBars()
                        end,
                    },
                },
            },
            appearance = {
                name = L["Appearance"],
                type = "group",
                order = 2,
                args = {
                    barSize = {
                        name = L["Bar Size"],
                        type = "group",
                        order = 1,
                        inline = true,
                        args = {
                            width = {
                                name = L["Width"],
                                desc = L["Width of the mana bars"],
                                type = "range",
                                order = 1,
                                min = 50,
                                max = 400,
                                step = 5,
                                get = function() return self.db.profile.width end,
                                set = function(info, value)
                                    self.db.profile.width = value
                                    if self.container then
                                        self.container:SetWidth(value)
                                        self:UpdateBars() -- Recreate all bars with new width
                                    end
                                end,
                            },
                            height = {
                                name = L["Height"],
                                desc = L["Height of each mana bar"],
                                type = "range",
                                order = 2,
                                min = 10,
                                max = 40,
                                step = 1,
                                get = function() return self.db.profile.height end,
                                set = function(info, value)
                                    self.db.profile.height = value
                                    self:UpdateBars() -- Recreate all bars with new height
                                end,
                            },
                            spacing = {
                                name = L["Spacing"],
                                desc = L["Space between bars"],
                                type = "range",
                                order = 3,
                                min = 0,
                                max = 10,
                                step = 1,
                                get = function() return self.db.profile.spacing end,
                                set = function(info, value)
                                    self.db.profile.spacing = value
                                    self:UpdateBars()
                                end,
                            },
                        },
                    },
                    barTexture = {
                        name = L["Bar Texture"],
                        desc = L["Texture used for the mana bars"],
                        type = "select",
                        order = 2,
                        dialogControl = "LSM30_Statusbar",
                        values = LSM:HashTable("statusbar"),
                        get = function() return self.db.profile.barTexture end,
                        set = function(info, value)
                            self.db.profile.barTexture = value
                            self:UpdateBars()
                        end,
                    },
                    colors = {
                        name = L["Colors"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            useClassColors = {
                                name = L["Use Class Colors"],
                                desc = L["Color bars by healer class"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.useClassColors end,
                                set = function(info, value)
                                    self.db.profile.useClassColors = value
                                    self:UpdateBars()
                                end,
                            },
                            customBarColor = {
                                name = L["Bar Color"],
                                desc = L["Color for mana bars when not using class colors"],
                                type = "color",
                                order = 2,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.customBarColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.customBarColor = {r=r, g=g, b=b, a=a}
                                    self:UpdateBars()
                                end,
                                disabled = function() return self.db.profile.useClassColors end,
                            },
                            backgroundColor = {
                                name = L["Background Color"],
                                desc = L["Color for the container background"],
                                type = "color",
                                order = 3,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.backgroundColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.backgroundColor = {r=r, g=g, b=b, a=a}
                                    if self.container then
                                        self.container:SetBackdropColor(r, g, b, a)
                                    end
                                end,
                            },
                            borderColor = {
                                name = L["Border Color"],
                                desc = L["Color for the container border"],
                                type = "color",
                                order = 4,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.borderColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.borderColor = {r=r, g=g, b=b, a=a}
                                    if self.container then
                                        self.container:SetBackdropBorderColor(r, g, b, a)
                                    end
                                end,
                            },
                            textColor = {
                                name = L["Text Color"],
                                desc = L["Color for bar text"],
                                type = "color",
                                order = 5,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.textColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.textColor = {r=r, g=g, b=b, a=a}
                                    self:UpdateBars()
                                end,
                            },
                        },
                    },
                    text = {
                        name = L["Text"],
                        type = "group",
                        order = 4,
                        inline = true,
                        args = {
                            fontName = {
                                name = L["Font"],
                                desc = L["Font used for bar text"],
                                type = "select",
                                order = 1,
                                dialogControl = "LSM30_Font",
                                values = LSM:HashTable("font"),
                                get = function() return self.db.profile.fontName end,
                                set = function(info, value)
                                    self.db.profile.fontName = value
                                    self:UpdateBars()
                                end,
                            },
                            fontSize = {
                                name = L["Font Size"],
                                desc = L["Size of the bar text"],
                                type = "range",
                                order = 2,
                                min = 8,
                                max = 20,
                                step = 1,
                                get = function() return self.db.profile.fontSize end,
                                set = function(info, value)
                                    self.db.profile.fontSize = value
                                    self:UpdateBars()
                                end,
                            },
                            outlineMode = {
                                name = L["Font Outline"],
                                desc = L["Outline style for the bar text"],
                                type = "select",
                                order = 3,
                                values = {
                                    [""] = L["None"],
                                    ["OUTLINE"] = L["Outline"],
                                    ["THICKOUTLINE"] = L["Thick Outline"],
                                },
                                get = function() return self.db.profile.outlineMode end,
                                set = function(info, value)
                                    self.db.profile.outlineMode = value
                                    self:UpdateBars()
                                end,
                            },
                            textPosition = {
                                name = L["Text Position"],
                                desc = L["Position of the text on the bar"],
                                type = "select",
                                order = 4,
                                values = {
                                    ["LEFT"] = L["Left"],
                                    ["CENTER"] = L["Center"],
                                    ["RIGHT"] = L["Right"],
                                },
                                get = function() return self.db.profile.textPosition end,
                                set = function(info, value)
                                    self.db.profile.textPosition = value
                                    self:UpdateBars()
                                end,
                            },
                        },
                    },
                    displayElements = {
                        name = L["Display Elements"],
                        type = "group",
                        order = 5,
                        inline = true,
                        args = {
                            showIcon = {
                                name = L["Show Class Icon"],
                                desc = L["Show class icon next to each bar"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.showIcon end,
                                set = function(info, value)
                                    self.db.profile.showIcon = value
                                    self:UpdateBars()
                                end,
                            },
                            showName = {
                                name = L["Show Name"],
                                desc = L["Show healer name on the bar"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.showName end,
                                set = function(info, value)
                                    self.db.profile.showName = value
                                    self:UpdateBars()
                                end,
                            },
                            showPercent = {
                                name = L["Show Percentage"],
                                desc = L["Show mana percentage on the bar"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.showPercent end,
                                set = function(info, value)
                                    self.db.profile.showPercent = value
                                    self:UpdateBars()
                                end,
                            },
                            showValue = {
                                name = L["Show Value"],
                                desc = L["Show current/max mana values"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.showValue end,
                                set = function(info, value)
                                    self.db.profile.showValue = value
                                    self:UpdateBars()
                                end,
                            },
                        },
                    },
                },
            },
            threshold = {
                name = L["Low Mana Alert"],
                type = "group",
                order = 3,
                args = {
                    useLowManaAlert = {
                        name = L["Enable Low Mana Alert"],
                        desc = L["Highlight healers with low mana"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.useLowManaAlert end,
                        set = function(info, value)
                            self.db.profile.useLowManaAlert = value
                            self:UpdateBars()
                        end,
                    },
                    lowManaThreshold = {
                        name = L["Low Mana Threshold"],
                        desc = L["Percentage at which mana is considered low"],
                        type = "range",
                        order = 2,
                        min = 5,
                        max = 50,
                        step = 5,
                        get = function() return self.db.profile.lowManaThreshold end,
                        set = function(info, value)
                            self.db.profile.lowManaThreshold = value
                            self:UpdateBars()
                        end,
                        disabled = function() return not self.db.profile.useLowManaAlert end,
                    },
                    lowManaColor = {
                        name = L["Low Mana Color"],
                        desc = L["Color used for low mana highlights"],
                        type = "color",
                        order = 3,
                        hasAlpha = true,
                        get = function()
                            local c = self.db.profile.lowManaColor
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(info, r, g, b, a)
                            self.db.profile.lowManaColor = {r=r, g=g, b=b, a=a}
                            self:UpdateBars()
                        end,
                        disabled = function() return not self.db.profile.useLowManaAlert end,
                    },
                },
            },
            filters = {
                name = L["Filters"],
                type = "group",
                order = 4,
                args = {
                    showOutOfRange = {
                        name = L["Show Out of Range"],
                        desc = L["Show healers that are out of range"],
                        type = "toggle",
                        order = 1,
                        get = function() return self.db.profile.showOutOfRange end,
                        set = function(info, value)
                            self.db.profile.showOutOfRange = value
                            self:UpdateGroup()
                        end,
                    },
                    showOffline = {
                        name = L["Show Offline"],
                        desc = L["Show healers that are offline"],
                        type = "toggle",
                        order = 2,
                        get = function() return self.db.profile.showOffline end,
                        set = function(info, value)
                            self.db.profile.showOffline = value
                            self:UpdateGroup()
                        end,
                    },
                    showDead = {
                        name = L["Show Dead"],
                        desc = L["Show healers that are dead"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.showDead end,
                        set = function(info, value)
                            self.db.profile.showDead = value
                            self:UpdateGroup()
                        end,
                    },
                },
            },
            autoHide = {
                name = L["Auto-Hide"],
                type = "group",
                order = 5,
                args = {
                    hideOutOfCombat = {
                        name = L["Hide Out of Combat"],
                        desc = L["Hide when not in combat"],
                        type = "toggle",
                        order = 1,
                        get = function() return self.db.profile.hideOutOfCombat end,
                        set = function(info, value)
                            self.db.profile.hideOutOfCombat = value
                            self:UpdateVisibility()
                        end,
                    },
                    hideInRestArea = {
                        name = L["Hide In Rest Areas"],
                        desc = L["Hide in cities and inns"],
                        type = "toggle",
                        order = 2,
                        get = function() return self.db.profile.hideInRestArea end,
                        set = function(info, value)
                            self.db.profile.hideInRestArea = value
                            self:UpdateVisibility()
                        end,
                    },
                    hideInDungeon = {
                        name = L["Hide In Dungeons"],
                        desc = L["Hide in 5-man dungeons"],
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.hideInDungeon end,
                        set = function(info, value)
                            self.db.profile.hideInDungeon = value
                            self:UpdateVisibility()
                        end,
                    },
                    hideInBG = {
                        name = L["Hide In Battlegrounds"],
                        desc = L["Hide in PvP instances"],
                        type = "toggle",
                        order = 4,
                        get = function() return self.db.profile.hideInBG end,
                        set = function(info, value)
                            self.db.profile.hideInBG = value
                            self:UpdateVisibility()
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