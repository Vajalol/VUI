-- VUICC: Timer implementation
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local Timer = Module.Timer

-- Local references for performance
local GetTime = GetTime
local floor = math.floor
local min = math.min
local max = math.max
local next = next
local pairs = pairs
local tonumber = tonumber

-- Format constants
local DAY = 86400
local HOUR = 3600
local MINUTE = 60
local SECOND_FORMAT_LONG = '%.1f'
local SECOND_FORMAT_SHORT = '%.0f'

-- Timer state tracking
local timers = {}
local active = {}

-- Formula: scale = baseScale * min(1, size / minSize)^scaleFactor
local function getTimerScale(width, height, scale, minSize)
    local size = min(width, height)
    
    if size < minSize then
        return scale * (size / minSize)
    end
    
    return scale
end

-- Create a new timer for a cooldown
function Timer:Get(cooldown)
    if timers[cooldown] then
        return timers[cooldown]
    end
    
    local timer = Module.Display:New(cooldown)
    
    if timer then
        timer:SetScript('OnUpdate', self.OnUpdate)
        timer.cooldown = cooldown
        cooldown._occ_timer = timer
        
        timers[cooldown] = timer
    end
    
    return timer
end

-- Main update function for timer
function Timer:OnUpdate(elapsed)
    -- This is a method of the timer frame, not the Timer module
    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end
    
    local cooldown = self.cooldown
    if not cooldown or cooldown:IsForbidden() then
        self:Hide()
        return
    end
    
    local remain = cooldown:GetTimeLeft()
    if remain <= 0 then
        -- Handle finish effect if this is a long cooldown
        local minEffectDuration = Module.db.minEffectDuration
        
        if minEffectDuration and self.duration and self.duration >= minEffectDuration then
            if not self.waitingForEffect then
                Module.FX:Run(self.effect, self.cooldown, self.effectParams)
                self.waitingForEffect = true
                self.nextUpdate = FINISH_EFFECT_BUFFER
                return
            end
        end
        
        -- Hide when finished
        self:Hide()
        return
    end
    
    -- Update appearance based on time remaining
    local settings = cooldown:GetSettings()
    local oldRemainingShown = self.duration
    local newRemainingShown = remain
    
    -- Update displayed time
    local text, r, g, b, a, scale
    
    -- Days
    if remain >= DAY then
        local days = floor(remain / DAY)
        text = days .. 'd'
        
        local style = settings.styles.days
        r, g, b, a = style.r, style.g, style.b, style.a
        scale = style.scale
        
        self.nextUpdate = remain % DAY
    -- Hours
    elseif remain >= HOUR then
        local hours = floor(remain / HOUR)
        text = hours .. 'h'
        
        local style = settings.styles.hours
        r, g, b, a = style.r, style.g, style.b, style.a
        scale = style.scale
        
        self.nextUpdate = remain % HOUR
    -- Minutes
    elseif remain >= MINUTE then
        local minutes = floor(remain / MINUTE)
        text = minutes .. 'm'
        
        local style = settings.styles.minutes
        r, g, b, a = style.r, style.g, style.b, style.a
        scale = style.scale
        
        self.nextUpdate = remain % MINUTE
    -- Seconds
    else
        -- Add tenths of seconds if enabled and time is under the threshold
        local tenthsThreshold = Module.db.tenthsDuration or 0
        if remain < tenthsThreshold then
            text = SECOND_FORMAT_LONG:format(remain)
        else
            text = SECOND_FORMAT_SHORT:format(remain)
        end
        
        -- Determine if this is "soon" or just regular seconds
        if remain < settings.minDuration then
            local style = settings.styles.soon
            r, g, b, a = style.r, style.g, style.b, style.a
            scale = style.scale
        else
            local style = settings.styles.seconds
            r, g, b, a = style.r, style.g, style.b, style.a
            scale = style.scale
        end
        
        -- Update more frequently for smoother countdown
        self.nextUpdate = remain % 1
        if self.nextUpdate < 0.1 then
            self.nextUpdate = 0.1
        end
    end
    
    -- Apply settings to the timer
    if self.text:GetText() ~= text then
        self.text:SetText(text)
    end
    
    -- Only update appearance if something changed
    if self.duration ~= newRemainingShown then
        local width, height = cooldown:GetSize()
        
        -- Scale timer text based on cooldown size
        local fontSize = settings.fontSize * getTimerScale(width, height, scale, settings.minSize)
        
        -- Apply text styling
        self.text:SetFont(settings.fontFace, fontSize, settings.fontOutline)
        self.text:SetTextColor(r, g, b, a)
        
        -- Reposition the text
        self.text:ClearAllPoints()
        self.text:SetPoint(settings.anchor, settings.xOff, settings.yOff)
        
        -- Save effect for finish
        self.effect = settings.effect
        self.effectParams = settings.effectSettings
        self.duration = newRemainingShown
    end
end

-- Show/hide functions
function Timer:Show()
    active[self] = true
    self.waitingForEffect = nil
    self.nextUpdate = 0
    self:SetScript('OnUpdate', Timer.OnUpdate)
    
    -- Update once immediately
    Timer.OnUpdate(self, 0)
    self:Show()
end

function Timer:Hide()
    active[self] = nil
    self.waitingForEffect = nil
    self:SetScript('OnUpdate', nil)
    self:Hide()
end

-- Update active timers
function Timer:ForActive(method, ...)
    for timer in pairs(active) do
        local func = timer[method]
        if type(func) == 'function' then
            func(timer, ...)
        end
    end
end

-- Cleanup when module is disabled
function Timer:Cleanup()
    for i, timer in pairs(timers) do
        timer:Hide()
        timer:ClearAllPoints()
        timer:SetParent(nil)
        timer.cooldown = nil
        timers[i] = nil
    end
    
    active = {}
end

-- Update module with Timer methods
Module.Timer = Timer