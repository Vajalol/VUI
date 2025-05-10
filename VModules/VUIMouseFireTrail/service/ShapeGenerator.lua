-- VUIMouseFireTrail ShapeGenerator.lua
-- Generates various shapes for trail effects

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Local variables
local PI = math.pi
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

-- Rotate a point around the origin
local function RotatePoint(x, y, angle)
    local newX = x * cos(angle) - y * sin(angle)
    local newY = x * sin(angle) + y * cos(angle)
    return newX, newY
end

-- Generate points for a V shape
function M:GenerateVShape(numPoints, angle, width, length)
    local points = {}
    
    -- Calculate half width
    local halfWidth = width / 2
    
    -- Calculate points for left leg of V
    for i = 1, math.floor(numPoints / 2) do
        local progress = (i - 1) / (numPoints / 2 - 1)
        local x = -halfWidth + progress * halfWidth
        local y = -length * progress
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    -- Calculate points for right leg of V
    for i = 1, math.ceil(numPoints / 2) do
        local progress = (i - 1) / (numPoints / 2 - 1)
        local x = 0 + progress * halfWidth
        local y = -length * (1 - progress)
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    return points
end

-- Generate points for an arrow shape
function M:GenerateArrowShape(numPoints, angle, width, length)
    local points = {}
    
    -- Calculate half width
    local halfWidth = width / 2
    
    -- Calculate points for left leg of arrow
    for i = 1, math.floor(numPoints / 3) do
        local progress = (i - 1) / (numPoints / 3 - 1)
        local x = -halfWidth + progress * halfWidth
        local y = -length / 3 * progress
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    -- Calculate points for right leg of arrow
    for i = 1, math.floor(numPoints / 3) do
        local progress = (i - 1) / (numPoints / 3 - 1)
        local x = 0 + progress * halfWidth
        local y = -length / 3 * (1 - progress)
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    -- Calculate points for arrow shaft
    for i = 1, math.ceil(numPoints / 3) do
        local progress = (i - 1) / (numPoints / 3 - 1)
        local x = 0
        local y = -length / 3 - progress * (length * 2 / 3)
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    return points
end

-- Generate points for a U shape
function M:GenerateUShape(numPoints, angle, width, length)
    local points = {}
    
    -- Calculate half width
    local halfWidth = width / 2
    
    -- Calculate points for left leg of U
    for i = 1, math.floor(numPoints / 3) do
        local progress = (i - 1) / (numPoints / 3 - 1)
        local x = -halfWidth
        local y = -length * progress
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    -- Calculate points for bottom of U
    for i = 1, math.floor(numPoints / 3) do
        local progress = (i - 1) / (numPoints / 3 - 1)
        local x = -halfWidth + progress * width
        local y = -length
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    -- Calculate points for right leg of U
    for i = 1, math.ceil(numPoints / 3) do
        local progress = 1 - (i - 1) / (numPoints / 3 - 1)
        local x = halfWidth
        local y = -length * progress
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    return points
end

-- Generate points for an ellipse
function M:GenerateEllipseShape(numPoints, angle, width, height)
    local points = {}
    
    -- Calculate half width and height
    local halfWidth = width / 2
    local halfHeight = height / 2
    
    -- Calculate points around the ellipse
    for i = 1, numPoints do
        local progress = (i - 1) / numPoints
        local theta = progress * 2 * PI
        
        -- Ellipse parametric equation
        local x = halfWidth * cos(theta)
        local y = halfHeight * sin(theta)
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    return points
end

-- Generate points for a spiral
function M:GenerateSpiralShape(numPoints, angle, maxRadius, revolutions)
    local points = {}
    
    -- Calculate points along spiral
    for i = 1, numPoints do
        local progress = (i - 1) / (numPoints - 1)
        local theta = progress * revolutions * 2 * PI
        
        -- Spiral parametric equation (Archimedean spiral)
        local radius = progress * maxRadius
        local x = radius * cos(theta)
        local y = radius * sin(theta)
        
        -- Rotate the point
        local rx, ry = RotatePoint(x, y, angle)
        table.insert(points, {x = rx, y = ry})
    end
    
    return points
end

-- Generate points for a custom trail shape
function M:GenerateShapePoints(shape, numPoints, angle, width, length)
    if shape == "V_SHAPE" then
        return self:GenerateVShape(numPoints, angle, width, length)
    elseif shape == "ARROW" then
        return self:GenerateArrowShape(numPoints, angle, width, length)
    elseif shape == "U_SHAPE" then
        return self:GenerateUShape(numPoints, angle, width, length)
    elseif shape == "ELLIPSE" then
        return self:GenerateEllipseShape(numPoints, angle, width, length)
    elseif shape == "SPIRAL" then
        return self:GenerateSpiralShape(numPoints, angle, width, 2) -- 2 revolutions
    else
        -- Default to V shape
        return self:GenerateVShape(numPoints, angle, width, length)
    end
end

-- Apply a shape to trail segments
function M:ApplyShapeToTrail(shape, frames, x, y, angle, width, length)
    -- Default values
    angle = angle or 0
    width = width or 50
    length = length or 100
    
    -- Get shape points
    local points = self:GenerateShapePoints(shape, #frames, angle, width, length)
    
    -- Apply points to frames
    for i = 1, #frames do
        if frames[i] and points[i] then
            frames[i]:ClearAllPoints()
            frames[i]:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + points[i].x, y + points[i].y)
        end
    end
end