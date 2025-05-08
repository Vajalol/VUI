local addonName, VUI = ...

-- Animation service for VUIScrollingText
-- This handles creating, configuring, and managing text animations

-- Local references
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetTime = GetTime
local table_insert = table.insert
local table_remove = table.remove
local math_floor = math.floor
local math_ceil = math.ceil
local math_abs = math.abs
local math_sin = math.sin
local math_cos = math.cos
local math_pow = math.pow

-- Animation frames table
local animationFrames = {}
local unusedAnimationFrames = {}
local animationFontStrings = {}
local unusedFontStrings = {}

-- Configuration
local defaultScrollTime = 2.0
local defaultFadeTime = 0.3

-- Animation styles
VUI.ScrollingText.AnimationStyles = {
    ["normal"] = {
        ['x'] = function(percent) return 0 end,
        ['y'] = function(percent) return percent end,
        ['scale'] = function(percent) return 1 end,
        ['alpha'] = function(percent)
            if percent < 0.1 then
                return percent * 10
            elseif percent > 0.9 then
                return (1 - percent) * 10
            else
                return 1
            end
        end
    },
    ["parabola"] = {
        ['x'] = function(percent) return (percent - 0.5) * 2 end,
        ['y'] = function(percent) return percent * (2 - percent) end,
        ['scale'] = function(percent) return 1 end,
        ['alpha'] = function(percent)
            if percent < 0.1 then
                return percent * 10
            elseif percent > 0.9 then
                return (1 - percent) * 10
            else
                return 1
            end
        end
    },
    ["straight"] = {
        ['x'] = function(percent) return 0 end,
        ['y'] = function(percent) return percent end,
        ['scale'] = function(percent) return 1 end,
        ['alpha'] = function(percent) return 1 end
    },
    ["static"] = {
        ['x'] = function(percent) return 0 end,
        ['y'] = function(percent) return 0 end,
        ['scale'] = function(percent) return 1 end,
        ['alpha'] = function(percent)
            if percent < 0.2 then
                return percent * 5
            elseif percent > 0.8 then
                return (1 - percent) * 5
            else
                return 1
            end
        end
    },
    ["pow"] = {
        ['x'] = function(percent) return 0 end,
        ['y'] = function(percent) return percent end,
        ['scale'] = function(percent)
            if percent < 0.2 then
                return 1 + (1 - percent / 0.2) * 2
            else
                return 1
            end
        end,
        ['alpha'] = function(percent)
            if percent < 0.1 then
                return percent * 10
            elseif percent > 0.9 then
                return (1 - percent) * 10
            else
                return 1
            end
        end
    }
}

-- Function to create a new animation frame
function VUI.ScrollingText:CreateAnimationFrame()
    -- Check for reusable frames first
    if #unusedAnimationFrames > 0 then
        local frame = table_remove(unusedAnimationFrames)
        frame:Show()
        return frame
    end
    
    -- Create a new frame if none available
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameStrata("HIGH")
    frame:SetHeight(32)
    frame:SetWidth(32)
    
    -- Store animation data in the frame
    frame.startTime = 0
    frame.duration = 0
    frame.scrollTime = 0
    frame.fadeTime = 0
    frame.offsetX = 0
    frame.offsetY = 0
    frame.anchorPoint = "CENTER"
    frame.direction = 1
    frame.scrollDistance = 100
    frame.fontString = nil
    frame.animationStyle = "normal"
    
    -- Create OnUpdate handler
    frame:SetScript("OnUpdate", function(self, elapsed)
        VUI.ScrollingText:AnimationFrameOnUpdate(self, elapsed)
    end)
    
    return frame
end

-- Function to get a font string for animation
function VUI.ScrollingText:GetFontString()
    -- Check for reusable font strings first
    if #unusedFontStrings > 0 then
        local fontString = table_remove(unusedFontStrings)
        fontString:Show()
        return fontString
    end
    
    -- Create a new font string if none available
    local fontString = UIParent:CreateFontString(nil, "OVERLAY")
    fontString:SetDrawLayer("OVERLAY", 7) -- High layer to appear above most UI elements
    
    return fontString
end

-- OnUpdate handler for animation frames
function VUI.ScrollingText:AnimationFrameOnUpdate(frame, elapsed)
    local currentTime = GetTime()
    local elapsedTime = currentTime - frame.startTime
    
    -- Check if animation is complete
    if elapsedTime >= frame.duration then
        self:ReleaseAnimationFrame(frame)
        return
    end
    
    -- Calculate animation percent
    local percent = elapsedTime / frame.scrollTime
    if percent > 1 then percent = 1 end
    
    -- Get animation style functions
    local animStyle = self.AnimationStyles[frame.animationStyle] or self.AnimationStyles["normal"]
    
    -- Calculate positions based on animation style
    local xOffset = frame.offsetX + animStyle['x'](percent) * frame.scrollDistance * frame.direction
    local yOffset = frame.offsetY + animStyle['y'](percent) * frame.scrollDistance
    local scale = animStyle['scale'](percent)
    local alpha = animStyle['alpha'](percent)
    
    -- Apply animation
    frame:SetPoint(frame.anchorPoint, UIParent, frame.anchorPoint, xOffset, yOffset)
    
    if frame.fontString then
        frame.fontString:SetScale(scale)
        frame.fontString:SetAlpha(alpha)
    end
end

-- Function to release animation frame back to the pool
function VUI.ScrollingText:ReleaseAnimationFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    
    if frame.fontString then
        frame.fontString:Hide()
        frame.fontString:ClearAllPoints()
        table_insert(unusedFontStrings, frame.fontString)
        frame.fontString = nil
    end
    
    table_insert(unusedAnimationFrames, frame)
end

-- Function to display scrolling text
function VUI.ScrollingText:DisplayScrollingText(text, scrollArea, color, fontSize, fontPath, outline, animStyle)
    -- Skip if module is disabled
    if not self:GetConfigValue("enabled", true) then return end
    
    -- Get defaults if not specified
    fontPath = fontPath or "Fonts\\FRIZQT__.TTF"
    fontSize = fontSize or 18
    color = color or {r = 1, g = 1, b = 1}
    outline = outline or "OUTLINE"
    animStyle = animStyle or "normal"
    
    -- Get configuration for the scroll area
    local anchorPoint = "CENTER"
    local xOffset = 0
    local yOffset = 0
    local direction = 1
    local scrollDistance = 100
    
    if scrollArea == "incoming" then
        anchorPoint = "LEFT"
        xOffset = 100
        direction = 1
    elseif scrollArea == "outgoing" then
        anchorPoint = "RIGHT"
        xOffset = -100
        direction = -1
    elseif scrollArea == "warning" then
        anchorPoint = "CENTER"
        yOffset = 100
    elseif scrollArea == "notification" then
        anchorPoint = "CENTER"
        yOffset = -100
    end
    
    -- Create animation frame
    local frame = self:CreateAnimationFrame()
    local fontString = self:GetFontString()
    
    -- Configure font
    fontString:SetFont(fontPath, fontSize, outline)
    fontString:SetText(text)
    fontString:SetTextColor(color.r, color.g, color.b)
    
    -- Set up frame
    frame.fontString = fontString
    fontString:SetParent(frame)
    fontString:ClearAllPoints()
    fontString:SetPoint("CENTER", frame, "CENTER", 0, 0)
    
    -- Configure animation
    frame.startTime = GetTime()
    frame.scrollTime = defaultScrollTime * (self:GetConfigValue("animationSpeed", 1) or 1)
    frame.fadeTime = defaultFadeTime
    frame.duration = frame.scrollTime + frame.fadeTime
    frame.offsetX = xOffset
    frame.offsetY = yOffset
    frame.anchorPoint = anchorPoint
    frame.direction = direction
    frame.scrollDistance = scrollDistance
    frame.animationStyle = animStyle
    
    -- Initial positioning
    frame:SetPoint(anchorPoint, UIParent, anchorPoint, xOffset, yOffset)
    
    -- Add to active animations
    table_insert(animationFrames, frame)
    
    return frame
end

-- Animation initialization function
function VUI.ScrollingText:InitializeAnimations()
    -- Pre-create some animation frames for better performance
    for i = 1, 20 do
        table_insert(unusedAnimationFrames, self:CreateAnimationFrame())
    end
    
    -- Pre-create some font strings for better performance
    for i = 1, 20 do
        table_insert(unusedFontStrings, self:GetFontString())
    end
    
    -- Hide all pre-created frames and strings
    for _, frame in ipairs(unusedAnimationFrames) do
        frame:Hide()
    end
    
    for _, fontString in ipairs(unusedFontStrings) do
        fontString:Hide()
    end
end