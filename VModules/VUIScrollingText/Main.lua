-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Main
-- Author: VortexQ8
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local VUIScrollingText = VUI:GetModule("VUIScrollingText")
local ST = VUI.ScrollingText
if not ST then return end

-- Local variables
local frames = {}
local activeFrames = {}
local eventFrame
local eventHandler = {}
local framePool = {}
local numFrames = 0
local throttleCount = 0
local lastThrottleTime = 0

-- Local references for increased performance
local pairs = pairs
local ipairs = ipairs
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local math_cos = math.cos
local math_sin = math.sin
local math_pi = math.pi
local string_sub = string.sub
local GetTime = GetTime
local UIParent = UIParent

-- Constants
local ANIMATION_VERTICAL_FACTOR = 1.5
local ANIMATION_HORIZONTAL_FACTOR = 1
local THROTTLE_TIME_THRESHOLD = 0.2
local THROTTLE_MESSAGE_THRESHOLD = 10
local FRAME_WIDTH = 600
local FRAME_HEIGHT = 700
local DEFAULT_SCROLL_HEIGHT = 360
local DEFAULT_SCROLL_WIDTH = 40
local DEFAULT_ANIMATION_DURATION = 3
local DEFAULT_NOTIFICATION_DURATION = 2

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------

-- Create a new frame for displaying text
local function CreateDisplayFrame()
    numFrames = numFrames + 1
    local frame = CreateFrame("Frame", "VUIScrollingTextFrame" .. numFrames, UIParent, "BackdropTemplate")
    frame:SetHeight(60)
    frame:SetWidth(300)
    frame:SetFrameStrata("BACKGROUND")
    frame.fontString = frame:CreateFontString(nil, "OVERLAY")
    frame.fontString:SetPoint("CENTER")
    frame.fontString:SetWidth(300)
    frame.showTime = 0
    frame.alpha = 1
    frame.animationProgress = 0
    frame.direction = ST.SCROLL_UP
    frame.scrollHeight = DEFAULT_SCROLL_HEIGHT
    frame.scrollWidth = DEFAULT_SCROLL_WIDTH
    frame.scrollArea = nil
    frame:Hide()
    return frame
end

-- Get a frame from the pool or create a new one
local function AcquireDisplayFrame()
    local frame = table.remove(framePool)
    if not frame then
        frame = CreateDisplayFrame()
    end
    frame:Show()
    return frame
end

-- Return a frame to the pool
local function ReleaseDisplayFrame(frame)
    frame:Hide()
    frame.fontString:SetText("")
    frame.animationFunction = nil
    table.insert(framePool, frame)
    return true
end

-- Animation system functions
local function AnimationStraight(frame, elapsed)
    -- Calculate the new position based on direction
    local progress = frame.animationProgress
    local duration = frame.duration or DEFAULT_ANIMATION_DURATION
    local height = frame.scrollHeight
    local width = frame.scrollWidth
    local direction = frame.direction
    
    -- Update animation progress
    frame.animationProgress = progress + (elapsed / duration)
    
    if frame.animationProgress > 1 then
        return false -- Animation complete
    end
    
    if direction == ST.SCROLL_UP then
        local y = height * (1 - progress)
        frame:SetPoint("CENTER", frame.originX, frame.originY + y)
    elseif direction == ST.SCROLL_DOWN then
        local y = height * (1 - progress)
        frame:SetPoint("CENTER", frame.originX, frame.originY - y)
    elseif direction == ST.SCROLL_LEFT then
        local x = width * (1 - progress)
        frame:SetPoint("CENTER", frame.originX - x, frame.originY)
    elseif direction == ST.SCROLL_RIGHT then
        local x = width * (1 - progress)
        frame:SetPoint("CENTER", frame.originX + x, frame.originY)
    end
    
    -- Apply fading effect near end of animation
    if progress > 0.7 then
        local alpha = (1 - progress) / 0.3
        frame:SetAlpha(alpha)
    end
    
    return true -- Continue animation
end

local function AnimationParabola(frame, elapsed)
    -- Calculate parabolic path
    local progress = frame.animationProgress
    local duration = frame.duration or DEFAULT_ANIMATION_DURATION
    local height = frame.scrollHeight
    local width = frame.scrollWidth
    local direction = frame.direction
    
    -- Update animation progress
    frame.animationProgress = progress + (elapsed / duration)
    
    if frame.animationProgress > 1 then
        return false -- Animation complete
    end
    
    -- Calculate parabolic function (y = -4x^2 + 4x) to get a nice arc
    local verticalProgress = -4 * (progress - 0.5) * (progress - 0.5) + 1
    
    if direction == ST.SCROLL_UP or direction == ST.SCROLL_DOWN then
        local y = height * verticalProgress * (direction == ST.SCROLL_UP and 1 or -1)
        local x = width * (progress - 0.5)
        frame:SetPoint("CENTER", frame.originX + x, frame.originY + y)
    else
        local x = width * (progress - 0.5) * (direction == ST.SCROLL_RIGHT and 1 or -1)
        local y = height * verticalProgress
        frame:SetPoint("CENTER", frame.originX + x, frame.originY + y)
    end
    
    -- Apply fading effect near end of animation
    if progress > 0.7 then
        local alpha = (1 - progress) / 0.3
        frame:SetAlpha(alpha)
    end
    
    return true -- Continue animation
end

local function AnimationScroll(frame, elapsed)
    -- Scrolling animation
    local progress = frame.animationProgress
    local duration = frame.duration or DEFAULT_ANIMATION_DURATION
    local height = frame.scrollHeight
    local width = frame.scrollWidth
    local direction = frame.direction
    
    -- Update animation progress
    frame.animationProgress = progress + (elapsed / duration)
    
    if frame.animationProgress > 1 then
        return false -- Animation complete
    end
    
    if direction == ST.SCROLL_UP then
        local y = height * progress
        frame:SetPoint("CENTER", frame.originX, frame.originY + y)
    elseif direction == ST.SCROLL_DOWN then
        local y = height * progress
        frame:SetPoint("CENTER", frame.originX, frame.originY - y)
    elseif direction == ST.SCROLL_LEFT then
        local x = width * progress
        frame:SetPoint("CENTER", frame.originX - x, frame.originY)
    elseif direction == ST.SCROLL_RIGHT then
        local x = width * progress
        frame:SetPoint("CENTER", frame.originX + x, frame.originY)
    end
    
    -- Apply fading effect near end of animation
    if progress > 0.7 then
        local alpha = (1 - progress) / 0.3
        frame:SetAlpha(alpha)
    end
    
    return true -- Continue animation
end

local function AnimationStatic(frame, elapsed)
    -- Static display (no movement, just fade in/out)
    local progress = frame.animationProgress
    local duration = frame.duration or DEFAULT_NOTIFICATION_DURATION
    
    -- Update animation progress
    frame.animationProgress = progress + (elapsed / duration)
    
    if frame.animationProgress > 1 then
        return false -- Animation complete
    end
    
    -- Set position at origin
    frame:SetPoint("CENTER", frame.originX, frame.originY)
    
    -- Fade in for first 0.2, hold until 0.8, fade out for final 0.2
    local alpha = 1
    if progress < 0.2 then
        alpha = progress / 0.2
    elseif progress > 0.8 then
        alpha = (1 - progress) / 0.2
    end
    frame:SetAlpha(alpha)
    
    return true -- Continue animation
end

-- Animation system update function
local function UpdateAnimations(self, elapsed)
    -- Update throttle check
    local currentTime = GetTime()
    if currentTime - lastThrottleTime > THROTTLE_TIME_THRESHOLD then
        throttleCount = 0
        lastThrottleTime = currentTime
    end
    
    for i = #activeFrames, 1, -1 do
        local frame = activeFrames[i]
        
        -- Call the animation function
        if frame.animationFunction then
            local stillActive = frame.animationFunction(frame, elapsed)
            if not stillActive then
                -- Animation is complete, return frame to pool
                table.remove(activeFrames, i)
                ReleaseDisplayFrame(frame)
            end
        else
            -- No animation function, return to pool
            table.remove(activeFrames, i)
            ReleaseDisplayFrame(frame)
        end
    end
end

-------------------------------------------------------------------------------
-- Scroll Areas Management
-------------------------------------------------------------------------------

-- Create a new scroll area
function ST.CreateScrollArea(name, settings)
    if not name or not settings then return false end
    
    -- Create scroll area if it doesn't exist
    if not ST.scrollAreas[name] then
        ST.scrollAreas[name] = {}
    end
    
    -- Apply settings
    local scrollArea = ST.scrollAreas[name]
    scrollArea.name = name
    scrollArea.animationStyle = settings.animationStyle or "Normal"
    scrollArea.direction = settings.direction or ST.SCROLL_UP
    scrollArea.behavior = settings.behavior or ST.BEHAVIOR_SCROLL
    scrollArea.textAlign = settings.textAlign or ST.ALIGN_CENTER
    scrollArea.scrollHeight = settings.scrollHeight or DEFAULT_SCROLL_HEIGHT
    scrollArea.scrollWidth = settings.scrollWidth or DEFAULT_SCROLL_WIDTH
    scrollArea.positionX = settings.positionX or 0
    scrollArea.positionY = settings.positionY or 0
    scrollArea.enabled = settings.enabled ~= false -- Default to enabled
    scrollArea.animationDuration = settings.animationDuration or DEFAULT_ANIMATION_DURATION
    
    -- VUI theme integration
    scrollArea.useThemeColor = settings.useThemeColor or false
    scrollArea.animationStyleSettings = settings
    
    return true
end

-- Delete a scroll area
function ST.DeleteScrollArea(name)
    if not name or not ST.scrollAreas[name] then return false end
    
    ST.scrollAreas[name] = nil
    return true
end

-- Get scroll area settings
function ST.GetScrollAreaSettings(name)
    return ST.scrollAreas[name]
end

-- Update a scroll area's settings
function ST.UpdateScrollArea(name, settings)
    if not name or not settings or not ST.scrollAreas[name] then return false end
    
    local scrollArea = ST.scrollAreas[name]
    for k, v in pairs(settings) do
        scrollArea[k] = v
    end
    
    return true
end

-- Enable or disable a scroll area
function ST.SetScrollAreaEnabled(name, enabled)
    if not name or not ST.scrollAreas[name] then return false end
    
    ST.scrollAreas[name].enabled = enabled
    return true
end

-- Get a list of all scroll areas
function ST.GetScrollAreas()
    local areas = {}
    for name in pairs(ST.scrollAreas) do
        table.insert(areas, name)
    end
    table.sort(areas)
    return areas
end

-------------------------------------------------------------------------------
-- Display Functions
-------------------------------------------------------------------------------

-- Helper function to get animation function based on behavior
local function GetAnimationFunction(behavior)
    if behavior == ST.BEHAVIOR_STRAIGHT then
        return AnimationStraight
    elseif behavior == ST.BEHAVIOR_PARABOLA then
        return AnimationParabola
    elseif behavior == ST.BEHAVIOR_STATIC then
        return AnimationStatic
    else
        return AnimationScroll -- Default
    end
end

-- Main function to display a message
function ST.DisplayMessage(message, scrollArea, colorR, colorG, colorB, fontSize, fontName, outline, duration, soundFile)
    -- Check throttling
    throttleCount = throttleCount + 1
    if throttleCount > THROTTLE_MESSAGE_THRESHOLD then
        return false
    end
    
    -- Get scroll area settings
    local areaSettings = ST.scrollAreas[scrollArea or "Notification"]
    if not areaSettings or not areaSettings.enabled then
        return false
    end
    
    -- Create a new display frame
    local frame = AcquireDisplayFrame()
    table.insert(activeFrames, frame)
    
    -- Set font properties
    local font = fontName or ST.masterFont
    local size = fontSize or ST.normalFontSize
    local outlineType = outline or ST.normalOutlineIndex
    
    if ST.Media and ST.Media.GetFontPath then
        font = ST.Media.GetFontPath(font)
    end
    
    if ST.Media and ST.Media.GetOutlineByIndex then
        outlineType = ST.Media.GetOutlineByIndex(outlineType)
    end
    
    frame.fontString:SetFont(font, size, outlineType)
    
    -- Set text and properties
    frame.fontString:SetText(message)
    
    -- VUI theme color integration
    if areaSettings.useThemeColor and VUI and VUI.GetThemeColor then
        local themeColor = VUI:GetThemeColor()
        colorR, colorG, colorB = themeColor.r, themeColor.g, themeColor.b
    end
    
    frame.fontString:SetTextColor(colorR or 1, colorG or 1, colorB or 1)
    
    -- Set text alignment
    frame.fontString:SetJustifyH(areaSettings.textAlign or ST.ALIGN_CENTER)
    
    -- Set up animation properties
    frame.direction = areaSettings.direction or ST.SCROLL_UP
    frame.scrollHeight = areaSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT
    frame.scrollWidth = areaSettings.scrollWidth or DEFAULT_SCROLL_WIDTH
    frame.behavior = areaSettings.behavior or ST.BEHAVIOR_SCROLL
    frame.duration = duration or areaSettings.animationDuration or DEFAULT_ANIMATION_DURATION
    frame.animationProgress = 0
    frame.scrollArea = scrollArea
    
    -- Position the frame at the scroll area's position
    frame.originX = areaSettings.positionX or 0
    frame.originY = areaSettings.positionY or 0
    frame:SetPoint("CENTER", UIParent, "CENTER", frame.originX, frame.originY)
    
    -- Assign animation function
    frame.animationFunction = GetAnimationFunction(frame.behavior)
    
    -- Play sound if enabled
    if soundFile and ST.soundsEnabled and ST.Media and ST.Media.PlaySound then
        ST.Media.PlaySound(soundFile)
    end
    
    return true
end

-------------------------------------------------------------------------------
-- Event System
-------------------------------------------------------------------------------

-- Register an event handler
function ST.RegisterEventHandler(event, handler)
    if not event or not handler then return false end
    
    if not eventHandler[event] then
        eventHandler[event] = {}
    end
    
    table.insert(eventHandler[event], handler)
    
    -- Register with the event frame if needed
    if eventFrame and not eventFrame:IsEventRegistered(event) then
        eventFrame:RegisterEvent(event)
    end
    
    return true
end

-- Unregister an event handler
function ST.UnregisterEventHandler(event, handler)
    if not event or not handler or not eventHandler[event] then return false end
    
    for i, func in ipairs(eventHandler[event]) do
        if func == handler then
            table.remove(eventHandler[event], i)
            break
        end
    end
    
    -- Unregister event if no handlers remain
    if #eventHandler[event] == 0 then
        eventHandler[event] = nil
        if eventFrame and eventFrame:IsEventRegistered(event) then
            eventFrame:UnregisterEvent(event)
        end
    end
    
    return true
end

-- Event frame handler
local function OnEvent(self, event, ...)
    if not eventHandler[event] then return end
    
    for _, handler in ipairs(eventHandler[event]) do
        handler(event, ...)
    end
    
    -- Forward to triggers system if available
    if ST.Triggers and ST.Triggers.ProcessEvent then
        ST.Triggers.ProcessEvent(event, ...)
    end
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Initialize the addon
function VUIScrollingText:OnInitialize()
    -- Create the event frame
    eventFrame = CreateFrame("Frame")
    eventFrame:SetScript("OnEvent", OnEvent)
    eventFrame:SetScript("OnUpdate", UpdateAnimations)
    
    -- Create default scroll areas
    ST.CreateScrollArea("Notification", {
        animationStyle = "VUIThemed",
        direction = ST.SCROLL_UP,
        behavior = ST.BEHAVIOR_SCROLL,
        textAlign = ST.ALIGN_CENTER,
        scrollHeight = 240,
        scrollWidth = 60,
        positionX = 0,
        positionY = 0,
        enabled = true,
        animationDuration = 2.5,
        useThemeColor = true
    })
    
    ST.CreateScrollArea("Incoming", {
        animationStyle = "Angled",
        direction = ST.SCROLL_UP,
        behavior = ST.BEHAVIOR_SCROLL,
        textAlign = ST.ALIGN_RIGHT,
        scrollHeight = 320,
        scrollWidth = 80,
        positionX = -200,
        positionY = -100,
        enabled = true,
        animationDuration = 3,
        useThemeColor = false
    })
    
    ST.CreateScrollArea("Outgoing", {
        animationStyle = "Angled",
        direction = ST.SCROLL_UP,
        behavior = ST.BEHAVIOR_SCROLL,
        textAlign = ST.ALIGN_LEFT,
        scrollHeight = 320,
        scrollWidth = 80,
        positionX = 200,
        positionY = -100,
        enabled = true,
        animationDuration = 3,
        useThemeColor = false
    })
    
    -- Initialize sub-modules
    if ST.Loot then ST.Loot.EnableLoot() end
    if ST.Cooldowns then ST.Cooldowns.EnableCooldowns() end
    
    -- Register options
    self:RegisterOptions()
    
    -- Set initialized flag
    ST.isInitialized = true
end

-- Interface for the main addon
-- Display a message (for external modules to use)
function VUIScrollingText:DisplayMessage(...)
    return ST.DisplayMessage(...)
end

-- Apply theme changes
function VUIScrollingText:ApplyTheme()
    if not ST.isInitialized then return end
    
    -- Apply theme to options panel
    if self.options and self.options.ApplyTheme then
        self.options:ApplyTheme()
    end
    
    -- Apply theme to submodules
    if ST.AnimationStyles and ST.AnimationStyles.ApplyTheme then
        ST.AnimationStyles.ApplyTheme()
    end
    
    if ST.Cooldowns and ST.Cooldowns.ApplyTheme then
        ST.Cooldowns.ApplyTheme()
    end
    
    if ST.Loot and ST.Loot.ApplyTheme then
        ST.Loot.ApplyTheme()
    end
    
    if ST.Triggers and ST.Triggers.ApplyTheme then
        ST.Triggers.ApplyTheme()
    end
    
    -- Update any active animations
    if ST.scrollAreas then
        for _, area in pairs(ST.scrollAreas) do
            if area.useThemeColor then
                -- The next animation will use the new theme color
                area.lastThemeUpdate = GetTime()
            end
        end
    end
end

-- Helper method to display themed messages
function VUIScrollingText:DisplayThemedMessage(message, scrollArea, fontSize, fontName, outline, duration, soundFile)
    if not ST.isInitialized or not VUI then return false end
    
    -- Get VUI theme color
    local themeColor = VUI:GetThemeColor()
    if not themeColor then
        themeColor = {r = 0, g = 0.44, b = 0.87} -- Default VUI blue
    end
    
    -- Display the message with theme color
    return ST.DisplayMessage(message, scrollArea, themeColor.r, themeColor.g, themeColor.b, 
                            fontSize, fontName, outline, duration, soundFile)
end

-- Show options panel
function VUIScrollingText:ShowOptions()
    -- Create options frame if not already created
    if not self.optionsFrame then
        self:RegisterOptions()
    end
    
    -- Show the options frame
    if self.optionsFrame then
        self.optionsFrame:Show()
    end
end

-- Method for the Advanced Configuration button in VUI config
function VUIScrollingText:OpenConfigPanel()
    self:ShowOptions()
end