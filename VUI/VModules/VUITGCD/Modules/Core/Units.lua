-- VUITGCD Units.lua
-- Manages tracking and display of unit ability history

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Create a class-like structure for Unit
---@class Unit
ns.Unit = {}
ns.Unit.__index = ns.Unit

---@param unitId string
---@param settings table
---@return Unit
function ns.Unit:New(unitId, settings)
    local self = setmetatable({}, ns.Unit)
    
    self.unitId = unitId
    self.settings = settings or {}
    self.name = UnitName(unitId) or unitId
    self.class = select(2, UnitClass(unitId)) or "WARRIOR"
    self.iconQueue = nil
    self.container = nil
    self.enabled = true
    self.trackedSpells = {}
    self.lastSpellTime = 0
    self.lastSpellId = 0
    
    -- Create frame structure
    self:CreateFrames()
    
    return self
end

-- Create frame structure for this unit
function ns.Unit:CreateFrames()
    -- Parent frame
    self.container = CreateFrame("Frame", nil, UIParent)
    self.container:SetSize(300, 40)
    self.container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.container:SetFrameStrata("MEDIUM")
    self.container:SetMovable(true)
    self.container:EnableMouse(true)
    self.container:RegisterForDrag("LeftButton")
    self.container:SetScript("OnDragStart", self.container.StartMoving)
    self.container:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        -- Save position to settings
        if ns.settings and ns.settings.activeProfile and 
           ns.settings.activeProfile.layoutSettings and 
           ns.settings.activeProfile.layoutSettings[self.unitId] then
            local point, _, relativePoint, xOfs, yOfs = f:GetPoint()
            if point and relativePoint then
                ns.settings.activeProfile.layoutSettings[self.unitId].point = point
                ns.settings.activeProfile.layoutSettings[self.unitId].relativePoint = relativePoint
                ns.settings.activeProfile.layoutSettings[self.unitId].xOffset = xOfs
                ns.settings.activeProfile.layoutSettings[self.unitId].yOffset = yOfs
            end
        end
    end)
    
    -- Unit label
    self.unitLabel = self.container:CreateFontString(nil, "OVERLAY")
    self.unitLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    self.unitLabel:SetPoint("BOTTOMLEFT", self.container, "TOPLEFT", 0, 0)
    self.unitLabel:SetTextColor(1, 1, 1, 1)
    self.unitLabel:SetText(self.name)
    
    -- Create icon queue
    -- Use settings if available
    local iconSize = (self.settings and self.settings.iconSize) or ns.constants.defaultIconSize
    local maxIcons = (self.settings and self.settings.maxIcons) or 8
    local direction = (self.settings and self.settings.layout) or "horizontal"
    
    self.iconQueue = ns.IconQueue:New(self.container, maxIcons, iconSize, direction)
    self.iconQueue.frame:SetPoint("TOPLEFT", self.container, "TOPLEFT", 0, 0)
    
    -- Size container based on icon queue
    self.container:SetSize(self.iconQueue.frame:GetWidth(), self.iconQueue.frame:GetHeight())
    
    -- Apply settings
    self:ApplySettings()
end

-- Apply settings from profile
function ns:ApplySettings()
    if not ns.settings or not ns.settings.activeProfile or 
       not ns.settings.activeProfile.layoutSettings or 
       not ns.settings.activeProfile.layoutSettings[self.unitId] then
        return
    end
    
    local unitSettings = ns.settings.activeProfile.layoutSettings[self.unitId]
    
    -- Set position if available
    if unitSettings.point and unitSettings.relativePoint then
        self.container:ClearAllPoints()
        self.container:SetPoint(
            unitSettings.point,
            UIParent,
            unitSettings.relativePoint,
            unitSettings.xOffset or 0,
            unitSettings.yOffset or 0
        )
    end
    
    -- Set enabled state
    self.enabled = unitSettings.enable or false
    if not self.enabled then
        self.container:Hide()
    else
        self.container:Show()
    end
    
    -- Set icon queue properties
    if self.iconQueue then
        if unitSettings.iconSize then
            self.iconQueue:SetIconSize(unitSettings.iconSize)
        end
        
        if unitSettings.maxIcons then
            self.iconQueue:SetMaxIcons(unitSettings.maxIcons)
        end
        
        if unitSettings.layout then
            self.iconQueue:SetDirection(unitSettings.layout)
        end
    end
    
    -- Update label based on settings
    if unitSettings.showLabel then
        self.unitLabel:Show()
    else
        self.unitLabel:Hide()
    end
    
    -- Override class color
    if unitSettings.useClassColor and self.class then
        local classColor = RAID_CLASS_COLORS[self.class]
        if classColor then
            self.unitLabel:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
        end
    else
        self.unitLabel:SetTextColor(1, 1, 1, 1)
    end
    
    -- Update container size
    if self.iconQueue and self.iconQueue.frame then
        self.container:SetSize(self.iconQueue.frame:GetWidth(), self.iconQueue.frame:GetHeight())
    end
end

-- Track a spell cast by this unit
---@param spellId number
---@param timestamp number
---@param targetGUID string|nil
---@param targetName string|nil
function ns.Unit:TrackSpell(spellId, timestamp, targetGUID, targetName)
    if not self.enabled or not spellId or spellId == 0 then
        return
    end
    
    -- Skip if we're not tracking spells that are too close together
    if (timestamp - self.lastSpellTime) < 0.1 and spellId == self.lastSpellId then
        return
    end
    
    -- Add to icon queue
    if self.iconQueue then
        self.iconQueue:AddIcon(spellId)
    end
    
    -- Store spell in tracked spells
    table.insert(self.trackedSpells, {
        id = spellId,
        time = timestamp,
        targetGUID = targetGUID,
        targetName = targetName
    })
    
    -- Keep only recent spells
    while #self.trackedSpells > 50 do
        table.remove(self.trackedSpells, 1)
    end
    
    -- Update last spell info
    self.lastSpellTime = timestamp
    self.lastSpellId = spellId
end

-- Clear all tracked spells
function ns.Unit:Clear()
    self.trackedSpells = {}
    self.lastSpellTime = 0
    self.lastSpellId = 0
    
    if self.iconQueue then
        self.iconQueue:Clear()
    end
end

-- Update the unit (call from OnUpdate)
---@param elapsed number
function ns.Unit:Update(elapsed)
    if not self.enabled then
        return
    end
    
    if self.iconQueue then
        self.iconQueue:Update(elapsed)
    end
end

-- Copy spell history from another unit
---@param otherUnit Unit
function ns.Unit:Copy(otherUnit)
    if not otherUnit then
        return
    end
    
    -- Copy tracked spells
    self.trackedSpells = {}
    for _, spell in ipairs(otherUnit.trackedSpells) do
        table.insert(self.trackedSpells, {
            id = spell.id,
            time = spell.time,
            targetGUID = spell.targetGUID,
            targetName = spell.targetName
        })
    end
    
    -- Copy last spell info
    self.lastSpellTime = otherUnit.lastSpellTime
    self.lastSpellId = otherUnit.lastSpellId
    
    -- Sync up icon queue
    if self.iconQueue and otherUnit.iconQueue then
        -- Clear current icons
        self.iconQueue:Clear()
        
        -- Recreate icons from other unit's tracked spells
        -- Starting from most recent
        for i = #self.trackedSpells, 1, -1 do
            if i > self.iconQueue.maxIcons then
                break
            end
            
            local spell = self.trackedSpells[i]
            if spell and spell.id then
                self.iconQueue:AddIcon(spell.id)
            end
        end
    end
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.Unit = ns.Unit
end

-- Initialize unit objects
function ns.InitializeUnits()
    ns.units = {}
    
    -- Create units for all tracked unit types
    for _, unitType in ipairs(ns.constants.unitTypes) do
        ns.units[unitType] = ns.Unit:New(unitType)
    end
end