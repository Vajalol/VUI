-- VUIPositionOfPower Module
-- Tracks buffs/effects related to positioning or stacking
-- Based on Position of Power WeakAura (https://wago.io/rdxO3TmdV)

local AddonName, VUI = ...
local MODNAME = "VUIPositionOfPower"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

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
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(self.NAME, self:GetOptions(), self.TITLE)
    
    -- Store active auras
    self.activeBuffs = {}
    
    -- Create frames
    self:CreateFrames()
    
    self:Debug(self.NAME .. " module initialized")
end

function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "TalentUpdate")
    self:RegisterEvent("UNIT_AURA", "UpdateAuras")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTargetAuras")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisibility") -- Entered combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility") -- Left combat
    
    -- Initialize player class and spec
    self:GetPlayerInfo()
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateDisplay", 0.1)
    
    -- Initial update
    self:UpdateDisplay()
    
    self:Debug(self.NAME .. " module enabled")
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
function M:CreateFrames()
    -- Main frame
    self.containerFrame = CreateFrame("Frame", "VUIPositionOfPowerFrame", UIParent)
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
        self.containerFrame:Show()
    else
        self.containerFrame:Hide()
    end
end

-- Create or recycle an icon frame
function M:GetIconFrame(id, index)
    if not self.iconFrames[id] then
        local frame = CreateFrame("Frame", "VUIPositionOfPowerIcon_"..id, self.containerFrame, "BackdropTemplate")
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
        
        -- Duration text
        frame.duration = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.duration:SetPoint("BOTTOM", 0, 2)
        frame.duration:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.durationFontSize, "OUTLINE")
        
        local durationColor = self.db.profile.durationFontColor
        frame.duration:SetTextColor(durationColor.r, durationColor.g, durationColor.b, durationColor.a)
        
        -- Stack count text
        frame.stackCount = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.stackCount:SetPoint("CENTER", 0, 0)
        frame.stackCount:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.stackFontSize, "OUTLINE")
        
        local stackColor = self.db.profile.stackFontColor
        frame.stackCount:SetTextColor(stackColor.r, stackColor.g, stackColor.b, stackColor.a)
        
        -- Glow effect (created but initially hidden)
        frame.glow = frame:CreateTexture(nil, "OVERLAY")
        frame.glow:SetPoint("CENTER")
        frame.glow:SetSize(iconSize * 1.5, iconSize * 1.5)
        frame.glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
        frame.glow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
        frame.glow:SetBlendMode("ADD")
        frame.glow:SetAlpha(0)
        
        -- Store the frame
        self.iconFrames[id] = frame
    end
    
    -- Position the frame based on index and growth direction
    local frame = self.iconFrames[id]
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
    
    -- Reset appearance
    frame:Hide()
    
    return frame
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
    
    -- Determine if we should process player or target buffs
    local i = 1
    local buffName, icon, count, debuffType, duration, expirationTime, unitCaster, 
           isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HELPFUL")
    
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
        isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HELPFUL")
    end
    
    -- Also scan for debuffs on target
    if isTarget then
        i = 1
        local debuffName, icon, count, debuffType, duration, expirationTime, unitCaster, 
               isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HARMFUL|PLAYER")
        
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
            isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HARMFUL|PLAYER")
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
            
            -- Color based on time left
            if timeLeft < 3 then
                frame.duration:SetTextColor(1, 0, 0, 1) -- Red for < 3 seconds
            elseif timeLeft < 10 then
                frame.duration:SetTextColor(1, 0.5, 0, 1) -- Orange for < 10 seconds
            else
                local durationColor = self.db.profile.durationFontColor
                frame.duration:SetTextColor(durationColor.r, durationColor.g, durationColor.b, durationColor.a)
            end
        else
            frame.duration:SetText("")
        end
        
        -- Stack count
        if buffInfo.stacking and buffInfo.count > 1 and self.db.profile.showStackText then
            frame.stackCount:SetText(buffInfo.count)
            
            -- Color based on stack count
            if buffInfo.maxStacks and buffInfo.count == buffInfo.maxStacks then
                frame.stackCount:SetTextColor(0, 1, 0, 1) -- Green for max stacks
            else
                local stackColor = self.db.profile.stackFontColor
                frame.stackCount:SetTextColor(stackColor.r, stackColor.g, stackColor.b, stackColor.a)
            end
        else
            frame.stackCount:SetText("")
        end
        
        -- Glow effect for important buffs or high stacks
        if self.db.profile.showGlow then
            local shouldGlow = false
            
            if buffInfo.priority >= 95 then
                shouldGlow = true
            elseif buffInfo.stacking and buffInfo.maxStacks and buffInfo.count == buffInfo.maxStacks then
                shouldGlow = true
            end
            
            if shouldGlow then
                frame.glow:SetAlpha(0.7)
            else
                frame.glow:SetAlpha(0)
            end
        else
            frame.glow:SetAlpha(0)
        end
        
        -- Border color based on class if enabled
        if self.db.profile.useClassColor then
            local classColor = RAID_CLASS_COLORS[self.playerClass]
            frame:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 1)
        else
            local borderColor = self.db.profile.borderColor
            frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        end
        
        -- Show the frame
        frame:Show()
        
        -- Increment index for next buff
        currentIndex = currentIndex + 1
    end
    
    -- Update container size based on growth direction
    local iconSize = self.db.profile.iconSize
    local spacing = self.db.profile.iconSpacing
    local count = #relevantBuffs
    
    if self.db.profile.growthDirection == "RIGHT" or self.db.profile.growthDirection == "LEFT" then
        self.containerFrame:SetSize(count * iconSize + (count - 1) * spacing, iconSize)
    else -- UP or DOWN
        self.containerFrame:SetSize(iconSize, count * iconSize + (count - 1) * spacing)
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
VUI:RegisterModule(MODNAME, M)