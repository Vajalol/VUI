-- VUITGCD LayoutSettings.lua
-- Manages layout settings for icon displays

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace if not created yet
if not ns.layoutSettings then ns.layoutSettings = {} end

-- Create a class-like structure for LayoutSettings
---@class LayoutSettings
ns.layoutSettings.__index = ns.layoutSettings

-- Constructor for LayoutSettings
---@param unitType string
---@return LayoutSettings
function ns.layoutSettings:New(unitType)
    local self = setmetatable({}, ns.layoutSettings)
    
    self.unitType = unitType
    self.enable = false
    self.layout = "horizontal"
    self.iconSize = ns.constants.defaultIconSize
    self.maxIcons = 8
    self.fadeTime = 3.0
    self.point = "CENTER"
    self.relativePoint = "CENTER"
    self.xOffset = 0
    self.yOffset = 0
    self.showLabel = true
    self.useClassColor = true
    
    return self
end

-- Load settings from profile
---@param profileSettings table
function ns.layoutSettings:Load(profileSettings)
    if not profileSettings then return end
    
    self.enable = profileSettings.enable or false
    self.layout = profileSettings.layout or "horizontal"
    self.iconSize = profileSettings.iconSize or ns.constants.defaultIconSize
    self.maxIcons = profileSettings.maxIcons or 8
    self.fadeTime = profileSettings.fadeTime or 3.0
    self.point = profileSettings.point or "CENTER"
    self.relativePoint = profileSettings.relativePoint or "CENTER"
    self.xOffset = profileSettings.xOffset or 0
    self.yOffset = profileSettings.yOffset or 0
    self.showLabel = profileSettings.showLabel or true
    self.useClassColor = profileSettings.useClassColor or true
end

-- Save settings to profile
---@return table
function ns.layoutSettings:Save()
    return {
        enable = self.enable,
        layout = self.layout,
        iconSize = self.iconSize,
        maxIcons = self.maxIcons,
        fadeTime = self.fadeTime,
        point = self.point,
        relativePoint = self.relativePoint,
        xOffset = self.xOffset,
        yOffset = self.yOffset,
        showLabel = self.showLabel,
        useClassColor = self.useClassColor
    }
end

-- Reset settings to defaults
---@param unitType string
function ns.layoutSettings:Reset(unitType)
    self.enable = (unitType == "player") -- Only player enabled by default
    self.layout = "horizontal"
    self.iconSize = ns.constants.defaultIconSize
    self.maxIcons = 8
    self.fadeTime = 3.0
    self.point = "CENTER"
    self.relativePoint = "CENTER"
    self.xOffset = 0
    self.yOffset = 0
    self.showLabel = true
    self.useClassColor = true
end

-- Set the layout direction
---@param direction string
function ns.layoutSettings:SetLayout(direction)
    if direction ~= "horizontal" and direction ~= "vertical" then
        return
    end
    
    self.layout = direction
end

-- Set icon size
---@param size number
function ns.layoutSettings:SetIconSize(size)
    if not size or size < 10 then
        return
    end
    
    self.iconSize = size
end

-- Set maximum icons
---@param max number
function ns.layoutSettings:SetMaxIcons(max)
    if not max or max < 1 then
        return
    end
    
    self.maxIcons = max
end

-- Set fade time
---@param time number
function ns.layoutSettings:SetFadeTime(time)
    if not time or time < 0.1 then
        return
    end
    
    self.fadeTime = time
end

-- Set position
---@param point string
---@param relativePoint string
---@param xOffset number
---@param yOffset number
function ns.layoutSettings:SetPosition(point, relativePoint, xOffset, yOffset)
    if not point or not relativePoint then
        return
    end
    
    self.point = point
    self.relativePoint = relativePoint
    self.xOffset = xOffset or 0
    self.yOffset = yOffset or 0
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.LayoutSettings = ns.layoutSettings
end