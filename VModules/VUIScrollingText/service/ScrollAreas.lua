local addonName, VUI = ...

-- ScrollAreas service for VUIScrollingText
-- This handles creating and managing the scroll areas where text will appear

-- Local references
local CreateFrame = CreateFrame
local UIParent = UIParent
local pairs = pairs

-- Scroll areas table
local scrollAreas = {}

-- Constants
local DEFAULT_SCROLL_DISTANCE = 100
local DEFAULT_SCROLL_DIRECTION = 1
local DEFAULT_X_OFFSET = 0
local DEFAULT_Y_OFFSET = 0

-- Create a new scroll area
function VUI.ScrollingText:CreateScrollArea(name, anchorPoint, xOffset, yOffset, scrollHeight, scrollWidth, iconSize, scrollDirection)
    -- Check if area already exists
    if scrollAreas[name] then return scrollAreas[name] end
    
    -- Set default values if not provided
    anchorPoint = anchorPoint or "CENTER"
    xOffset = xOffset or DEFAULT_X_OFFSET
    yOffset = yOffset or DEFAULT_Y_OFFSET
    scrollHeight = scrollHeight or 200
    scrollWidth = scrollWidth or 200
    iconSize = iconSize or 16
    scrollDirection = scrollDirection or DEFAULT_SCROLL_DIRECTION
    
    -- Create a frame for the scroll area
    local frame = CreateFrame("Frame", "VUIScrollingText_" .. name, UIParent)
    frame:SetPoint(anchorPoint, UIParent, anchorPoint, xOffset, yOffset)
    frame:SetHeight(scrollHeight)
    frame:SetWidth(scrollWidth)
    
    -- Make the frame movable if we want to allow user positioning
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:SetUserPlaced(true)
    
    -- Store scroll area settings
    frame.name = name
    frame.anchorPoint = anchorPoint
    frame.xOffset = xOffset
    frame.yOffset = yOffset
    frame.scrollHeight = scrollHeight
    frame.scrollWidth = scrollWidth
    frame.iconSize = iconSize
    frame.scrollDirection = scrollDirection
    
    -- Add to scroll areas table
    scrollAreas[name] = frame
    
    return frame
end

-- Delete a scroll area
function VUI.ScrollingText:DeleteScrollArea(name)
    -- Check if area exists
    if not scrollAreas[name] then return end
    
    -- Hide and release the frame
    scrollAreas[name]:Hide()
    scrollAreas[name] = nil
end

-- Get a scroll area by name
function VUI.ScrollingText:GetScrollArea(name)
    return scrollAreas[name]
end

-- Update a scroll area's settings
function VUI.ScrollingText:UpdateScrollArea(name, anchorPoint, xOffset, yOffset, scrollHeight, scrollWidth, iconSize, scrollDirection)
    -- Check if area exists
    local area = scrollAreas[name]
    if not area then return end
    
    -- Update settings if provided
    if anchorPoint then area.anchorPoint = anchorPoint end
    if xOffset then area.xOffset = xOffset end
    if yOffset then area.yOffset = yOffset end
    if scrollHeight then area.scrollHeight = scrollHeight end
    if scrollWidth then area.scrollWidth = scrollWidth end
    if iconSize then area.iconSize = iconSize end
    if scrollDirection then area.scrollDirection = scrollDirection end
    
    -- Update the frame
    area:ClearAllPoints()
    area:SetPoint(area.anchorPoint, UIParent, area.anchorPoint, area.xOffset, area.yOffset)
    area:SetHeight(area.scrollHeight)
    area:SetWidth(area.scrollWidth)
end

-- Create default scroll areas
function VUI.ScrollingText:CreateDefaultScrollAreas()
    -- Incoming damage (center, slightly offset to the left)
    self:CreateScrollArea("incoming", "CENTER", -150, 0, 200, 150, 16, 1)
    
    -- Outgoing damage (center, slightly offset to the right)
    self:CreateScrollArea("outgoing", "CENTER", 150, 0, 200, 150, 16, 1)
    
    -- Incoming healing (center, offset above character)
    self:CreateScrollArea("incomingHeal", "CENTER", -100, 75, 150, 100, 16, 1)
    
    -- Outgoing healing (center, offset above character)
    self:CreateScrollArea("outgoingHeal", "CENTER", 100, 75, 150, 100, 16, 1)
    
    -- Notifications (center, bottom of screen)
    self:CreateScrollArea("notification", "CENTER", 0, -150, 200, 300, 16, 1)
    
    -- Pet damage (offset below character)
    self:CreateScrollArea("outgoingPet", "CENTER", 125, -50, 150, 100, 14, 1)
    
    -- Power gains (mana, rage, energy)
    self:CreateScrollArea("power", "CENTER", 0, 125, 150, 200, 14, 1)
    
    -- Customizable area for testing
    self:CreateScrollArea("custom", "TOP", 0, -100, 200, 300, 16, 1)
end

-- Function to get the appropriate scroll area for a text based on settings
function VUI.ScrollingText:GetScrollAreaForText(textType)
    -- Get configuration settings for scroll area placement
    local area
    
    if textType == "incomingDamage" then
        area = self:GetConfigValue("incomingDamageArea", "center")
    elseif textType == "outgoingDamage" then
        area = self:GetConfigValue("outgoingDamageArea", "right")
    elseif textType == "incomingHeal" then
        area = self:GetConfigValue("incomingHealingArea", "center")
    elseif textType == "outgoingHeal" then
        area = self:GetConfigValue("outgoingHealingArea", "right")
    elseif textType == "notification" then
        return "notification" -- Always use notification area for notifications
    elseif textType == "pet" then
        return "outgoingPet" -- Always use pet area for pet damage
    elseif textType == "power" then
        return "power" -- Always use power area for power gains
    else
        return "custom" -- Default to custom area for unknown types
    end
    
    -- Map the configured area to an actual scroll area
    if area == "center" then
        if textType == "incomingDamage" or textType == "incomingHeal" then
            return "incoming"
        else
            return "outgoing"
        end
    elseif area == "left" then
        return "incoming"
    elseif area == "right" then
        return "outgoing"
    elseif area == "up" then
        if textType == "incomingDamage" or textType == "incomingHeal" then
            return "incomingHeal"
        else
            return "outgoingHeal"
        end
    elseif area == "down" then
        return "notification"
    else
        return "custom" -- Fallback to custom area
    end
end

-- Initialize the scroll areas
function VUI.ScrollingText:InitializeScrollAreas()
    -- Create the default scroll areas
    self:CreateDefaultScrollAreas()
    
    -- Make scroll areas movable with a modifier key (shift)
    self:MakeScrollAreasMovable()
    
    -- Load any saved positions
    self:LoadScrollAreaPositions()
end

-- Make scroll areas movable when holding shift
function VUI.ScrollingText:MakeScrollAreasMovable()
    for name, frame in pairs(scrollAreas) do
        frame:SetScript("OnMouseDown", function(self, button)
            if IsShiftKeyDown() and button == "LeftButton" then
                self:StartMoving()
            end
        end)
        
        frame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                self:StopMovingOrSizing()
                -- Save the new position
                VUI.ScrollingText:SaveScrollAreaPosition(name)
            end
        end)
    end
end

-- Save a scroll area's position
function VUI.ScrollingText:SaveScrollAreaPosition(name)
    local frame = scrollAreas[name]
    if not frame then return end
    
    -- Get the current position
    local point, _, relativePoint, xOffset, yOffset = frame:GetPoint()
    
    -- Save to the config
    if not VUI_SavedVariables.VUIScrollingText.scrollAreaPositions then
        VUI_SavedVariables.VUIScrollingText.scrollAreaPositions = {}
    end
    
    VUI_SavedVariables.VUIScrollingText.scrollAreaPositions[name] = {
        point = point,
        relativePoint = relativePoint,
        xOffset = xOffset,
        yOffset = yOffset
    }
end

-- Load saved scroll area positions
function VUI.ScrollingText:LoadScrollAreaPositions()
    if not VUI_SavedVariables.VUIScrollingText or not VUI_SavedVariables.VUIScrollingText.scrollAreaPositions then
        return
    end
    
    for name, position in pairs(VUI_SavedVariables.VUIScrollingText.scrollAreaPositions) do
        local frame = scrollAreas[name]
        if frame then
            frame:ClearAllPoints()
            frame:SetPoint(position.point, UIParent, position.relativePoint, position.xOffset, position.yOffset)
        end
    end
end

-- Reset all scroll areas to their default positions
function VUI.ScrollingText:ResetScrollAreaPositions()
    if not VUI_SavedVariables.VUIScrollingText then return end
    
    -- Clear saved positions
    VUI_SavedVariables.VUIScrollingText.scrollAreaPositions = {}
    
    -- Recreate all scroll areas
    for name, _ in pairs(scrollAreas) do
        scrollAreas[name]:Hide()
        scrollAreas[name] = nil
    end
    
    -- Create default areas
    self:CreateDefaultScrollAreas()
end