-- VUI Utils
-- This file contains utility functions for the UI framework
local _, VUI = ...

-- Create utilities namespace
VUI.Utils = {}

-- Creates a shallow copy of a table
function VUI.Utils:CopyTable(src)
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = v
    end
    return copy
end

-- Creates a deep copy of a table
function VUI.Utils:DeepCopyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopyTable(orig_key)] = self:DeepCopyTable(orig_value)
        end
        setmetatable(copy, self:DeepCopyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Merges two tables, with values from t2 overriding t1
function VUI.Utils:MergeTables(t1, t2)
    local result = self:CopyTable(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Returns a formatted string with the specified color
function VUI.Utils:ColorText(text, r, g, b)
    if type(r) == "table" then
        g = r.g
        b = r.b
        r = r.r
    end
    return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, text)
end

-- Returns a class-colored text
function VUI.Utils:ClassColorText(text, class)
    if not class then
        class = select(2, UnitClass("player"))
    end
    
    local color = RAID_CLASS_COLORS[class]
    if color then
        return self:ColorText(text, color.r, color.g, color.b)
    else
        return text
    end
end

-- Returns text colored according to a quality level (0-5)
function VUI.Utils:QualityColorText(text, quality)
    local colors = {
        [0] = {r = 0.6, g = 0.6, b = 0.6},    -- Poor (Gray)
        [1] = {r = 1.0, g = 1.0, b = 1.0},    -- Common (White)
        [2] = {r = 0.2, g = 0.8, b = 0.2},    -- Uncommon (Green)
        [3] = {r = 0.0, g = 0.4, b = 0.8},    -- Rare (Blue)
        [4] = {r = 0.7, g = 0.3, b = 0.7},    -- Epic (Purple)
        [5] = {r = 1.0, g = 0.5, b = 0.0}     -- Legendary (Orange)
    }
    
    local color = colors[quality] or colors[1]
    return self:ColorText(text, color.r, color.g, color.b)
end

-- Truncates text to a specific length, adding ellipsis if needed
function VUI.Utils:TruncateText(text, length)
    if not text then return "" end
    if #text <= length then return text end
    
    return string.sub(text, 1, length-3) .. "..."
end

-- Format a number with commas as thousands separators
function VUI.Utils:FormatNumber(number)
    local formatted = tostring(number)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return formatted
end

-- Format large numbers more readably (1.5k, 1.2M, etc)
function VUI.Utils:FormatLargeNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fk", number / 1000)
    else
        return tostring(number)
    end
end

-- Format time (seconds) into a readable string
function VUI.Utils:FormatTime(seconds)
    if not seconds or seconds <= 0 then
        return "0:00"
    end
    
    if seconds < 60 then
        return string.format("%d", seconds)
    elseif seconds < 3600 then
        local mins = math.floor(seconds / 60)
        local secs = seconds % 60
        return string.format("%d:%02d", mins, secs)
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = seconds % 60
        return string.format("%d:%02d:%02d", hours, mins, secs)
    end
end

-- Format time (seconds) into a compact format based on duration
function VUI.Utils:FormatTimeCompact(seconds)
    if not seconds or seconds <= 0 then
        return "0s"
    end
    
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        local mins = math.floor(seconds / 60)
        return string.format("%dm", mins)
    elseif seconds < 86400 then
        local hours = math.floor(seconds / 3600)
        return string.format("%dh", hours)
    else
        local days = math.floor(seconds / 86400)
        return string.format("%dd", days)
    end
end

-- Get the border style file path based on the current theme
function VUI.Utils:GetBorderStyle()
    local style = VUI.db.profile.appearance.border or "thin"
    
    if style == "blizzard" then
        return "Interface\\DialogFrame\\UI-DialogBox-Border"
    elseif style == "thin" then
        return "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga"
    elseif style == "custom" then
        -- Custom border would be set elsewhere
        return VUI.db.profile.appearance.customBorder or "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga"
    else
        return ""  -- For "none" style
    end
end

-- Get the backdrop file path based on the current theme
function VUI.Utils:GetBackdropStyle()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    if theme == "thunderstorm" then
        return "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\background.tga"
    elseif theme == "phoenixflame" then
        return "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\background.tga"
    elseif theme == "arcanemystic" then
        return "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\background.tga"
    elseif theme == "felenergy" then
        return "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\background.tga"
    else
        return "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\background.tga"
    end
end

-- Get the statusbar texture path based on current settings
function VUI.Utils:GetStatusBarTexture()
    local style = VUI.db.profile.appearance.statusbarTexture or "smooth"
    
    if style == "flat" then
        return "Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-flat.blp"
    elseif style == "gloss" then
        return "Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-gloss.tga"
    else -- smooth
        return "Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-smooth.blp"
    end
end

-- RGB to Hex color conversion
function VUI.Utils:RGBToHex(r, g, b)
    if type(r) == "table" then
        g = r.g
        b = r.b
        r = r.r
    end
    return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

-- Hex to RGB color conversion
function VUI.Utils:HexToRGB(hex)
    hex = hex:gsub("#", "")
    return {
        r = tonumber("0x" .. hex:sub(1, 2)) / 255,
        g = tonumber("0x" .. hex:sub(3, 4)) / 255,
        b = tonumber("0x" .. hex:sub(5, 6)) / 255
    }
end

-- Lighten a color by a percentage amount
function VUI.Utils:LightenColor(color, percent)
    percent = percent or 0.2
    
    if type(color) ~= "table" then return end
    
    local r = color.r + (1 - color.r) * percent
    local g = color.g + (1 - color.g) * percent
    local b = color.b + (1 - color.b) * percent
    
    return {r = math.min(r, 1), g = math.min(g, 1), b = math.min(b, 1)}
end

-- Darken a color by a percentage amount
function VUI.Utils:DarkenColor(color, percent)
    percent = percent or 0.2
    
    if type(color) ~= "table" then return end
    
    local r = color.r * (1 - percent)
    local g = color.g * (1 - percent)
    local b = color.b * (1 - percent)
    
    return {r = math.max(r, 0), g = math.max(g, 0), b = math.max(b, 0)}
end

-- Get table size (# of elements)
function VUI.Utils:TableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- Print a table's contents for debugging (recursive)
function VUI.Utils:PrintTable(tbl, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            VUI:Print(indentStr .. k .. " = {")
            self:PrintTable(v, indent + 1)
            VUI:Print(indentStr .. "}")
        else
            VUI:Print(indentStr .. k .. " = " .. tostring(v))
        end
    end
end

-- Generate a unique ID
function VUI.Utils:GenerateUniqueID()
    return string.format("%x%x", GetTime() * 1000, math.random(1000000, 9999999))
end

-- Throttle function execution
function VUI.Utils:Throttle(func, delay)
    delay = delay or 0.1
    local lastUpdate = 0
    
    return function(...)
        local now = GetTime()
        if now - lastUpdate > delay then
            lastUpdate = now
            return func(...)
        end
    end
end

-- Debounce function execution
function VUI.Utils:Debounce(func, delay)
    delay = delay or 0.1
    local timer
    
    return function(...)
        local args = {...}
        
        if timer then
            timer:Cancel()
        end
        
        timer = C_Timer.NewTimer(delay, function()
            func(unpack(args))
        end)
    end
end

-- Check if a position is in bounds of a frame
function VUI.Utils:IsPositionInFrame(x, y, frame)
    local left, bottom, width, height = frame:GetRect()
    if not left then return false end
    
    local right = left + width
    local top = bottom + height
    
    return x >= left and x <= right and y >= bottom and y <= top
end

-- Set frame level based on strata
function VUI.Utils:SetAppropriateFrameLevel(frame, baseLevel)
    baseLevel = baseLevel or 1
    
    local strataLevels = {
        BACKGROUND = 1,
        LOW = 2,
        MEDIUM = 3,
        HIGH = 4,
        DIALOG = 5,
        FULLSCREEN = 6,
        FULLSCREEN_DIALOG = 7,
        TOOLTIP = 8
    }
    
    local strata = frame:GetFrameStrata()
    local strataBaseLevel = strataLevels[strata] or 1
    
    frame:SetFrameLevel(baseLevel + strataBaseLevel * 100)
end

-- Apply a pulsing animation to a frame
function VUI.Utils:ApplyPulseAnimation(frame, duration, minScale, maxScale)
    duration = duration or 1
    minScale = minScale or 0.9
    maxScale = maxScale or 1.1
    
    if frame.pulseAnimation then
        frame.pulseAnimation:Stop()
    else
        frame.pulseAnimation = frame:CreateAnimationGroup()
        frame.pulseAnimation:SetLooping("REPEAT")
        
        local grow = frame.pulseAnimation:CreateAnimation("Scale")
        grow:SetOrder(1)
        grow:SetDuration(duration / 2)
        grow:SetFromScale(minScale, minScale)
        grow:SetToScale(maxScale, maxScale)
        
        local shrink = frame.pulseAnimation:CreateAnimation("Scale")
        shrink:SetOrder(2)
        shrink:SetDuration(duration / 2)
        shrink:SetFromScale(maxScale, maxScale)
        shrink:SetToScale(minScale, minScale)
    end
    
    frame.pulseAnimation:Play()
    
    return frame.pulseAnimation
end

-- Apply a fade in animation to a frame
function VUI.Utils:ApplyFadeInAnimation(frame, duration)
    duration = duration or 0.3
    
    frame:SetAlpha(0)
    
    if frame.fadeInAnimation then
        frame.fadeInAnimation:Stop()
    else
        frame.fadeInAnimation = frame:CreateAnimationGroup()
        
        local fade = frame.fadeInAnimation:CreateAnimation("Alpha")
        fade:SetFromAlpha(0)
        fade:SetToAlpha(1)
        fade:SetDuration(duration)
    end
    
    frame.fadeInAnimation:Play()
    
    return frame.fadeInAnimation
end

-- Apply a fade out animation to a frame
function VUI.Utils:ApplyFadeOutAnimation(frame, duration, hideOnFinish)
    duration = duration or 0.3
    
    if frame.fadeOutAnimation then
        frame.fadeOutAnimation:Stop()
    else
        frame.fadeOutAnimation = frame:CreateAnimationGroup()
        
        local fade = frame.fadeOutAnimation:CreateAnimation("Alpha")
        fade:SetFromAlpha(1)
        fade:SetToAlpha(0)
        fade:SetDuration(duration)
        
        if hideOnFinish then
            frame.fadeOutAnimation:SetScript("OnFinished", function()
                frame:Hide()
            end)
        end
    end
    
    frame.fadeOutAnimation:Play()
    
    return frame.fadeOutAnimation
end

-- Safely load textures, with a fallback texture on failure
function VUI.Utils:SafeLoadTexture(textureInfo, fallback)
    fallback = fallback or "Interface\\Icons\\INV_Misc_QuestionMark"
    
    if not textureInfo then
        return fallback
    end
    
    if type(textureInfo) == "string" then
        return textureInfo
    elseif type(textureInfo) == "number" then
        -- It's likely a spellID
        local icon = select(3, GetSpellInfo(textureInfo))
        return icon or fallback
    end
    
    return fallback
end

-- Safely extract color values from a color specification
function VUI.Utils:SafeGetColor(colorInfo, defaultColor)
    defaultColor = defaultColor or {r = 1, g = 1, b = 1, a = 1}
    
    if not colorInfo then
        return defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a
    end
    
    if type(colorInfo) == "table" then
        return colorInfo.r or defaultColor.r, 
               colorInfo.g or defaultColor.g, 
               colorInfo.b or defaultColor.b, 
               colorInfo.a or defaultColor.a
    end
    
    return defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a
end

-- Create a shortcut mapping to all utility functions
setmetatable(VUI.Utils, {__index = function(t, k)
    VUI:Print("Warning: Undefined utility function: " .. tostring(k))
    return function() end
end})

-- Add some common aliases
VUI.utils = VUI.Utils