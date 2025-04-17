-- VUI OmniCC Core Implementation
local _, VUI = ...
local OmniCC = VUI.omnicc

-- Cooldown settings
local ICON_SIZE_SMALL = 24
local ICON_SIZE_MEDIUM = 36
local DEFAULT_FONT_FACE = VUI:GetFont("expressway") or "FONTS\\FRIZQT__.TTF"

-- Module functionality
function OmniCC:SetupModule()
    -- Initialize internal tables
    self.activeCooldowns = {}
    self.effectsPool = {}
    
    -- Hook into all cooldown frames
    self:HookCooldowns()
    
    -- Create main update frame
    self:CreateUpdateFrame()
end

-- Create update frame to handle cooldown timers
function OmniCC:CreateUpdateFrame()
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
        self.updateFrame:Hide()
        
        self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
            self:UpdateCooldowns(elapsed)
        end)
    end
end

-- Hook into the cooldown system
function OmniCC:HookCooldowns()
    -- Hook for vanilla frames
    hooksecurefunc(getmetatable(CreateFrame("Cooldown", nil, nil, "CooldownFrameTemplate")).__index, "SetCooldown", function(cooldown, start, duration)
        if not cooldown or cooldown:IsForbidden() then return end
        self:ProcessCooldown(cooldown, start, duration)
    end)
    
    -- Hook for setting cooldown swap
    hooksecurefunc("CooldownFrame_Set", function(cooldown, start, duration, enable, forceShowDrawEdge)
        if not cooldown or cooldown:IsForbidden() then return end
        if enable and enable ~= 0 then
            self:ProcessCooldown(cooldown, start, duration)
        end
    end)
end

-- Process a cooldown when it's set
function OmniCC:ProcessCooldown(cooldown, start, duration)
    -- Skip invalid cooldowns
    if not cooldown or cooldown:IsForbidden() then return end
    
    -- Check if this cooldown should be processed
    if not self:ShouldProcessCooldown(cooldown, start, duration) then
        self:ClearCooldown(cooldown)
        return
    end
    
    -- Create or update the timer for this cooldown
    local timer = self:GetOrCreateTimer(cooldown)
    
    -- Update timer data
    timer.start = start
    timer.duration = duration
    timer.charges = nil -- Reset charges if there was a previous one
    
    -- Handle charges if this cooldown has them
    if cooldown.GetCurrentCharges then
        local charges, maxCharges, chargeStart, chargeDuration = cooldown:GetCurrentCharges()
        if charges and maxCharges and charges < maxCharges then
            timer.charges = {
                current = charges,
                max = maxCharges,
                start = chargeStart,
                duration = chargeDuration
            }
        end
    end
    
    -- Start tracking
    self:StartTracking()
end

-- Determine if a cooldown should be processed
function OmniCC:ShouldProcessCooldown(cooldown, start, duration)
    -- Skip processing if...
    
    -- No duration or already complete
    if not start or start <= 0 or not duration or duration <= 0 then
        return false
    end
    
    -- If remaining time is too short (< GCD)
    local remaining = start + duration - GetTime()
    if remaining <= 0 or remaining < self.db.minDuration then
        return false
    end
    
    -- Cooldown size is too small
    local width = cooldown:GetWidth()
    if width and width < self.db.minSize then
        return false
    end
    
    -- Check if it's on a blacklisted frame
    local parent = cooldown:GetParent()
    if parent and self:IsBlacklisted(parent:GetName() or "") then
        return false
    end
    
    -- Not showing on charges and cooldown has charges
    if not self.db.showCharges and cooldown.GetCurrentCharges and select(1, cooldown:GetCurrentCharges()) then
        return false
    end
    
    return true
end

-- Create or get a timer for a cooldown
function OmniCC:GetOrCreateTimer(cooldown)
    if not self.activeCooldowns[cooldown] then
        local timer = {}
        timer.cooldown = cooldown
        
        -- Create text display
        timer.text = cooldown:CreateFontString(nil, "OVERLAY")
        timer.text:SetPoint("CENTER", 0, 0)
        
        -- Format the text
        self:FormatTimerText(timer)
        
        -- Store in active cooldowns
        self.activeCooldowns[cooldown] = timer
    end
    
    return self.activeCooldowns[cooldown]
end

-- Format the timer text display
function OmniCC:FormatTimerText(timer)
    if not timer or not timer.text then return end
    
    -- Get the cooldown size
    local size = timer.cooldown:GetWidth() or 36
    
    -- Determine text size based on cooldown size
    local textSize = math.max(self.db.minFontSize, size * self.db.fontScale)
    if self.db.uniformTextSize then
        textSize = self.db.fontSize
    end
    
    -- Set the font
    timer.text:SetFont(DEFAULT_FONT_FACE, textSize, self.db.fontOutline)
    
    -- Apply customizations
    timer.text:SetTextColor(self.db.textColor.r, self.db.textColor.g, self.db.textColor.b, self.db.textColor.a)
    
    -- Apply position
    local xOffset, yOffset = 0, 0
    if self.db.textAnchor == "TOP" then
        yOffset = 1
    elseif self.db.textAnchor == "BOTTOM" then
        yOffset = -1
    end
    
    timer.text:ClearAllPoints()
    timer.text:SetPoint(self.db.textAnchor, timer.cooldown, self.db.textAnchor, xOffset, yOffset)
end

-- Update all active cooldowns
function OmniCC:UpdateCooldowns(elapsed)
    local hasActiveCooldowns = false
    
    -- Current time
    local now = GetTime()
    
    -- Update all active cooldowns
    for cooldown, timer in pairs(self.activeCooldowns) do
        if cooldown:IsVisible() then
            -- Calculate remaining time
            local remaining = timer.start + timer.duration - now
            
            if remaining > 0 then
                -- Cooldown is still active
                hasActiveCooldowns = true
                
                -- Update text display
                self:UpdateTimerText(timer, remaining)
                
                -- Check if we need to trigger any effects
                if not timer.triggeredEffect and remaining <= self.db.effectThreshold then
                    self:ShowFinishEffect(timer.cooldown)
                    timer.triggeredEffect = true
                end
            else
                -- Cooldown is complete - clear it
                self:ClearCooldown(cooldown)
            end
        else
            -- Cooldown not visible - clear it
            self:ClearCooldown(cooldown)
        end
    end
    
    -- If there are no active cooldowns, stop tracking
    if not hasActiveCooldowns then
        self:StopTracking()
    end
end

-- Update the text on a timer
function OmniCC:UpdateTimerText(timer, remaining)
    if not timer or not timer.text then return end
    
    -- Format the time text based on remaining time
    local text, r, g, b, a = self:FormatTime(remaining)
    
    -- Update the text
    timer.text:SetText(text)
    
    -- Apply color
    if r and g and b then
        timer.text:SetTextColor(r, g, b, a or 1)
    end
end

-- Format time string based on remaining time
function OmniCC:FormatTime(remaining)
    -- Apply color based on time
    local r, g, b, a = 1, 1, 1, 1
    
    -- Format text based on time remaining
    local text
    if remaining >= 86400 then
        -- Days
        text = ("%dd"):format(math.floor(remaining / 86400))
        r, g, b = 0.7, 0.7, 0.7 -- Grey for days
    elseif remaining >= 3600 then
        -- Hours
        text = ("%dh"):format(math.floor(remaining / 3600))
        r, g, b = 0.7, 0.7, 0.7 -- Grey for hours
    elseif remaining >= 60 then
        -- Minutes
        text = ("%dm"):format(math.floor(remaining / 60))
        r, g, b = 1, 1, 1 -- White for minutes
    elseif remaining >= 10 then
        -- Seconds (no decimal)
        text = ("%ds"):format(math.floor(remaining))
        r, g, b = 1, 1, 0 -- Yellow for seconds
    elseif remaining >= 3 then
        -- Seconds (round to tenths)
        text = ("%.1f"):format(remaining)
        r, g, b = 1, 0.5, 0 -- Orange for seconds < 10
    else
        -- Seconds (round to tenths)
        text = ("%.1f"):format(remaining)
        r, g, b = 1, 0, 0 -- Red for seconds < 3
    end
    
    -- Apply customization
    if self.db.useColorGradient then
        r, g, b = self:GetProgressColor(remaining / 60)
    end
    
    return text, r, g, b, a
end

-- Get color based on progress (0-1)
function OmniCC:GetProgressColor(progress)
    -- Clamp progress between 0 and 1
    progress = math.max(0, math.min(1, progress))
    
    -- Define color ranges
    -- Red (1,0,0) -> Yellow (1,1,0) -> Green (0,1,0)
    local r, g, b
    
    if progress <= 0.5 then
        -- Red to Yellow
        r = 1
        g = progress * 2
        b = 0
    else
        -- Yellow to Green
        r = (1 - progress) * 2
        g = 1
        b = 0
    end
    
    return r, g, b
end

-- Clear a cooldown
function OmniCC:ClearCooldown(cooldown)
    if self.activeCooldowns[cooldown] then
        -- Hide text
        if self.activeCooldowns[cooldown].text then
            self.activeCooldowns[cooldown].text:SetText("")
        end
        
        -- Remove from active cooldowns
        self.activeCooldowns[cooldown] = nil
    end
end

-- Show finish effect on a cooldown
function OmniCC:ShowFinishEffect(cooldown)
    if not cooldown or not self.db.enableEffects then return end
    
    local effect = self:GetEffectFromPool()
    if not effect then return end
    
    -- Configure the effect
    effect:SetParent(cooldown)
    effect:ClearAllPoints()
    effect:SetAllPoints(cooldown)
    
    -- Set up animation based on effect type
    if self.db.effectType == "PULSE" then
        self:SetupPulseAnimation(effect)
    elseif self.db.effectType == "SHINE" then
        self:SetupShineAnimation(effect)
    elseif self.db.effectType == "FLARE" then
        self:SetupFlareAnimation(effect)
    else
        -- DEFAULT to PULSE
        self:SetupPulseAnimation(effect)
    end
    
    -- Show and play the effect
    effect:Show()
    effect.animation:Play()
end

-- Get an effect frame from the pool
function OmniCC:GetEffectFromPool()
    -- Look for an unused effect
    for i, effect in ipairs(self.effectsPool) do
        if not effect.animation:IsPlaying() then
            return effect
        end
    end
    
    -- Create a new effect
    local effect = CreateFrame("Frame")
    effect:SetSize(30, 30)
    effect:Hide()
    
    -- Create texture
    effect.texture = effect:CreateTexture(nil, "OVERLAY")
    effect.texture:SetAllPoints()
    
    -- Store in pool
    table.insert(self.effectsPool, effect)
    
    return effect
end

-- Set up pulse animation
function OmniCC:SetupPulseAnimation(effect)
    if not effect.animation then
        effect.animation = effect:CreateAnimationGroup()
        
        -- Scale animation
        local scale = effect.animation:CreateAnimation("Scale")
        scale:SetScale(1.5, 1.5)
        scale:SetDuration(0.3)
        scale:SetOrder(1)
        
        -- Alpha animation
        local alpha = effect.animation:CreateAnimation("Alpha")
        alpha:SetFromAlpha(1)
        alpha:SetToAlpha(0)
        alpha:SetDuration(0.3)
        alpha:SetOrder(1)
    end
    
    -- Set appropriate texture
    effect.texture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    effect.texture:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    effect.texture:SetBlendMode("ADD")
    
    -- Set handlers
    effect.animation:SetScript("OnFinished", function()
        effect:Hide()
    end)
end

-- Set up shine animation
function OmniCC:SetupShineAnimation(effect)
    if not effect.animation then
        effect.animation = effect:CreateAnimationGroup()
        
        -- Rotation animation
        local rotation = effect.animation:CreateAnimation("Rotation")
        rotation:SetDegrees(90)
        rotation:SetDuration(0.4)
        rotation:SetOrder(1)
        
        -- Alpha animation
        local alpha = effect.animation:CreateAnimation("Alpha")
        alpha:SetFromAlpha(0)
        alpha:SetToAlpha(1)
        alpha:SetDuration(0.2)
        alpha:SetOrder(1)
        
        local alpha2 = effect.animation:CreateAnimation("Alpha")
        alpha2:SetFromAlpha(1)
        alpha2:SetToAlpha(0)
        alpha2:SetDuration(0.2)
        alpha2:SetOrder(2)
    end
    
    -- Set appropriate texture
    effect.texture:SetTexture("Interface\\Cooldown\\star4")
    effect.texture:SetBlendMode("ADD")
    
    -- Set handlers
    effect.animation:SetScript("OnFinished", function()
        effect:Hide()
    end)
end

-- Set up flare animation
function OmniCC:SetupFlareAnimation(effect)
    if not effect.animation then
        effect.animation = effect:CreateAnimationGroup()
        
        -- Scale animation
        local scale = effect.animation:CreateAnimation("Scale")
        scale:SetScale(2, 2)
        scale:SetDuration(0.3)
        scale:SetOrder(1)
        
        -- Alpha animation
        local alpha = effect.animation:CreateAnimation("Alpha")
        alpha:SetFromAlpha(1)
        alpha:SetToAlpha(0)
        alpha:SetDuration(0.3)
        alpha:SetOrder(1)
    end
    
    -- Set appropriate texture
    effect.texture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\omnicc\\flare")
    effect.texture:SetBlendMode("ADD")
    
    -- Set handlers
    effect.animation:SetScript("OnFinished", function()
        effect:Hide()
    end)
end

-- Check if a frame name is blacklisted
function OmniCC:IsBlacklisted(name)
    if not name or name == "" then return false end
    
    for _, blacklistedName in ipairs(self.db.blacklist) do
        if name:match(blacklistedName) then
            return true
        end
    end
    
    return false
end

-- Start tracking cooldowns
function OmniCC:StartTracking()
    if not self.updateFrame:IsShown() and next(self.activeCooldowns) then
        self.updateFrame:Show()
    end
end

-- Stop tracking cooldowns
function OmniCC:StopTracking()
    self.updateFrame:Hide()
end

-- Initialize the module
function OmniCC:Initialize()
    -- Create database
    if not VUI.db.profile.modules.omnicc then
        VUI.db.profile.modules.omnicc = {
            enabled = true,
            minDuration = 2.5,            -- Minimum cooldown duration to show
            minSize = 24,                -- Minimum cooldown size to show
            fontScale = 0.6,            -- Font size relative to cooldown size
            minFontSize = 8,            -- Minimum font size
            fontSize = 14,              -- Font size when uniform text size is enabled
            uniformTextSize = false,    -- Use uniform text size
            fontOutline = "OUTLINE",    -- Font outline style
            textAnchor = "CENTER",      -- Text anchor point
            textColor = {r=1, g=1, b=1, a=1}, -- Text color
            useColorGradient = true,    -- Use color gradient based on time
            blacklist = {},             -- Blacklisted frame names
            enableEffects = true,       -- Enable finish effects
            effectType = "PULSE",       -- Effect type (PULSE, SHINE, FLARE)
            effectThreshold = 3,        -- Time threshold to show finish effect
            showCharges = true          -- Show cooldown when charges are available
        }
    end
    
    self.db = VUI.db.profile.modules.omnicc
    
    -- Initialize the module
    if self.db.enabled then
        self:SetupModule()
        VUI:Print("OmniCC module initialized")
    end
end
