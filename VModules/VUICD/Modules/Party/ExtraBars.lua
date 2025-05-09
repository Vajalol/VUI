local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local EB = {}
P.ExtraBars = EB

-- Local variables
local extraBars = {}
local extraBarConfigs = {}
local activeExtraBars = {}

-- Initialize extra bars
function EB:Initialize()
    -- Get settings
    self.db = VUICD:GetPartySettings().extraBars or {}
    
    -- Create default configuration if none exists
    if not self.db.bars then
        self.db.bars = {
            {
                name = "Interrupts",
                enabled = false,
                growthDirection = "RIGHT",
                scale = 1.0,
                spacing = 2,
                position = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOffset = 0,
                    yOffset = -100,
                    anchorFrame = "UIParent"
                },
                filters = {
                    interrupt = true,
                    defensive = false,
                    offensive = false,
                    utility = false,
                    covenant = false,
                }
            },
            {
                name = "Raid CDs",
                enabled = false,
                growthDirection = "RIGHT",
                scale = 1.0,
                spacing = 2,
                position = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOffset = 0,
                    yOffset = -130,
                    anchorFrame = "UIParent"
                },
                filters = {
                    interrupt = false,
                    defensive = true,
                    offensive = false,
                    utility = false,
                    covenant = false,
                }
            }
        }
    end
    
    -- Load bar configurations
    for i, barConfig in ipairs(self.db.bars) do
        extraBarConfigs[i] = barConfig
        
        -- Create the bar if enabled
        if barConfig.enabled then
            self:CreateExtraBar(i, barConfig)
        end
    end
end

-- Create an extra bar
function EB:CreateExtraBar(barIndex, config)
    if not config or activeExtraBars[barIndex] then return end
    
    -- Create container frame
    local frame = CreateFrame("Frame", "VUICD_ExtraBar" .. barIndex, UIParent)
    frame.barIndex = barIndex
    frame.config = config
    
    -- Set initial size
    frame:SetSize(200, 40)
    
    -- Set position
    self:ApplyExtraBarPosition(frame)
    
    -- Make movable
    if P.Position then
        P.Position:MakeMovable(frame)
    end
    
    -- Create icons container
    frame.iconsContainer = CreateFrame("Frame", nil, frame)
    frame.iconsContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.iconsContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    
    -- Store in active bars
    activeExtraBars[barIndex] = frame
    
    -- Populate with spell icons
    self:UpdateExtraBar(barIndex)
    
    -- Show frame
    frame:Show()
    
    return frame
end

-- Apply position to extra bar
function EB:ApplyExtraBarPosition(frame)
    if not frame or not frame.config or not frame.config.position then return end
    
    local pos = frame.config.position
    frame:ClearAllPoints()
    
    -- Handle different anchor frames
    local anchorFrame = _G[pos.anchorFrame] or UIParent
    
    frame:SetPoint(pos.point, anchorFrame, pos.relativePoint, pos.xOffset, pos.yOffset)
end

-- Save position for extra bar
function EB:SaveExtraBarPosition(frame)
    if not frame or not frame.config or not frame.config.position then return end
    
    local pos = frame.config.position
    local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
    
    pos.point = point
    pos.relativePoint = relativePoint
    pos.xOffset = xOffset
    pos.yOffset = yOffset
    
    -- Store anchor frame name
    if relativeTo then
        pos.anchorFrame = relativeTo:GetName() or "UIParent"
    else
        pos.anchorFrame = "UIParent"
    end
end

-- Update an extra bar with spells
function EB:UpdateExtraBar(barIndex)
    local frame = activeExtraBars[barIndex]
    if not frame or not frame.config then return end
    
    local config = frame.config
    
    -- Clear existing icons
    self:ClearExtraBarIcons(frame)
    
    -- Get spells that match the filters
    local filteredSpells = self:GetFilteredSpells(config.filters)
    
    -- Create icons for spells
    local iconSize = 30 * config.scale
    local spacing = config.spacing or 2
    
    -- Determine layout direction
    local isHorizontal = config.growthDirection == "RIGHT" or config.growthDirection == "LEFT"
    local isReversed = config.growthDirection == "LEFT" or config.growthDirection == "UP"
    
    -- Create icons
    local icons = {}
    for i, spellData in ipairs(filteredSpells) do
        local icon = self:CreateSpellIcon(frame.iconsContainer, spellData, iconSize)
        if icon then
            table.insert(icons, icon)
        end
    end
    
    -- Position icons
    local totalWidth = isHorizontal and (#icons * (iconSize + spacing) - spacing) or iconSize
    local totalHeight = isHorizontal and iconSize or (#icons * (iconSize + spacing) - spacing)
    
    frame.iconsContainer:SetSize(totalWidth, totalHeight)
    
    -- Position icons based on growth direction
    for i, icon in ipairs(icons) do
        local xPos, yPos = 0, 0
        
        if isHorizontal then
            xPos = isReversed and totalWidth - (i * (iconSize + spacing)) or (i - 1) * (iconSize + spacing)
        else
            yPos = isReversed and (i - 1) * (iconSize + spacing) or -(i - 1) * (iconSize + spacing)
        end
        
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", frame.iconsContainer, "TOPLEFT", xPos, yPos)
    end
    
    -- Update frame size
    frame:SetSize(totalWidth, totalHeight)
end

-- Clear icons from an extra bar
function EB:ClearExtraBarIcons(frame)
    if not frame or not frame.iconsContainer then return end
    
    for i = frame.iconsContainer:GetNumChildren(), 1, -1 do
        local child = select(i, frame.iconsContainer:GetChildren())
        if child.isSpellIcon then
            child:Hide()
            child:SetParent(nil)
        end
    end
end

-- Create a spell icon for an extra bar
function EB:CreateSpellIcon(parent, spellData, size)
    if not parent or not spellData then return nil end
    
    local icon = CreateFrame("Frame", nil, parent, "VUICD_CooldownIconTemplate")
    icon:SetSize(size, size)
    icon.isSpellIcon = true
    
    -- Set icon texture
    if icon.icon then
        icon.icon:SetTexture(spellData.icon)
    end
    
    -- Set spell data
    icon.spellID = spellData.id
    icon.spellName = spellData.name
    icon.unit = spellData.unit
    icon.class = spellData.class
    
    -- Apply cooldown
    if icon.cooldown and P.CD then
        local onCD, start, duration = P.CD:IsOnCooldown(spellData.guid, spellData.id)
        if onCD then
            CooldownFrame_Set(icon.cooldown, start, duration, true)
            
            -- Set count text
            if icon.count then
                local remaining = (start + duration) - GetTime()
                if remaining > 0 then
                    icon.count:SetText(math.floor(remaining))
                else
                    icon.count:SetText("")
                end
            end
        else
            CooldownFrame_Clear(icon.cooldown)
            if icon.count then
                icon.count:SetText("")
            end
        end
    end
    
    -- Add class color border
    if not icon.border then
        icon.border = icon:CreateTexture(nil, "BACKGROUND")
        icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        icon.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
        icon.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    end
    
    -- Set border color based on class
    if icon.border and spellData.class then
        local classColor = RAID_CLASS_COLORS[spellData.class]
        if classColor then
            icon.border:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
        end
    end
    
    -- Show the icon
    icon:Show()
    
    return icon
end

-- Get spells filtered by the given filters
function EB:GetFilteredSpells(filters)
    if not filters or not P.CD then return {} end
    
    local result = {}
    
    -- Get all group members
    local groupMembers = P.GroupInfo and P.GroupInfo:GetGroupMembers() or {}
    
    for guid, memberInfo in pairs(groupMembers) do
        local spells = P.CD:GetActiveSpells(guid)
        
        for spellID, spellInfo in pairs(spells) do
            local include = false
            
            -- Check if spell matches any of the filters
            for spellType, enabled in pairs(filters) do
                if enabled and spellInfo[spellType] then
                    include = true
                    break
                end
            end
            
            if include then
                table.insert(result, {
                    id = spellID,
                    name = spellInfo.name,
                    icon = spellInfo.icon,
                    class = memberInfo.class,
                    unit = memberInfo.unit,
                    guid = guid
                })
            end
        end
    end
    
    return result
end

-- Update all extra bars
function EB:UpdateAll()
    for barIndex in pairs(activeExtraBars) do
        self:UpdateExtraBar(barIndex)
    end
end

-- Enable or disable an extra bar
function EB:SetBarEnabled(barIndex, enabled)
    if not extraBarConfigs[barIndex] then return end
    
    -- Update configuration
    extraBarConfigs[barIndex].enabled = enabled
    
    -- Create or destroy the bar
    if enabled then
        if not activeExtraBars[barIndex] then
            self:CreateExtraBar(barIndex, extraBarConfigs[barIndex])
        end
    else
        if activeExtraBars[barIndex] then
            activeExtraBars[barIndex]:Hide()
            activeExtraBars[barIndex] = nil
        end
    end
end