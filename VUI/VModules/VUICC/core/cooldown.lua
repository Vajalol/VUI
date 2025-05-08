-- VUICC: Cooldown tracking
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local Cooldown = Module.Cooldown

-- Constants
local MIN_START_OFFSET = -86400 -- How far in the future a cooldown can be before we show text for it
local GCD_SPELL_ID = 61304 -- The global cooldown spell id
local FINISH_EFFECT_BUFFER = -0.15 -- How much of a buffer we give finish effects (in seconds)

-- Tracking all cooldowns
local cooldowns = {}

-- Utility methods
local IsGCD, GetGCDTimeRemaining

-- Implementation of GCD tests for different API versions
if type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function" then
    IsGCD = function (start, duration, modRate)
        if not (start > 0 and duration > 0 and modRate > 0) then
            return false
        end

        local gcd = C_Spell.GetSpellCooldown(GCD_SPELL_ID)

        return gcd
            and gcd.isEnabled
            and start == gcd.startTime
            and duration == gcd.duration
            and modRate == gcd.modRate
    end

    GetGCDTimeRemaining = function()
        local gcd = C_Spell.GetSpellCooldown(GCD_SPELL_ID)
        if not (gcd and gcd.isEnabled) then
            return 0
        end

        local start, duration, modRate = gcd.startTime, gcd.duration, gcd.modRate
        if not (start > 0 and duration > 0 and modRate > 0) then
            return 0
        end

        local remain = (start + duration) - GetTime()
        if remain > 0 then
            return remain / modRate
        end

        return 0
    end
else
    IsGCD = function (start, duration, modRate)
        if not (start > 0 and duration > 0 and modRate > 0) then
            return false
        end

        local gcdStart, gcdDuration, gcdEnabled, gcdModRate = GetSpellCooldown(GCD_SPELL_ID)

        return gcdEnabled
            and start == gcdStart
            and duration == gcdDuration
            and modRate == gcdModRate
    end

    GetGCDTimeRemaining = function()
        local start, duration, enabled, modRate = GetSpellCooldown(GCD_SPELL_ID)
        if (not enabled and start > 0 and duration > 0 and modRate > 0) then
            return 0
        end

        local remain = (start + duration) - GetTime()
        if remain > 0 then
            return remain
        end

        return 0
    end
end

-- Retrieve the name of the given region or its ancestors
local function getFirstName(frame)
    while frame do
        local name = frame:GetName()

        if name then
            return name
        end

        frame = frame:GetParent()
    end
end

-- Cooldown methods
function Cooldown:OnSetCooldown(start, duration, modRate)
    if self:IsForbidden() then
        return 
    end
    
    local now = GetTime()
    
    start = start or 0
    duration = duration or 0
    modRate = modRate or 1
    
    -- Handle exceptional situations first (ignored cooldowns, not numbers, etc)
    if not Addon.db.global.enabled or not Module.db.enabled then
        self._occ_start = nil
        self._occ_duration = nil
        self._occ_modRate = nil
        self._occ_gcd = nil
        self:HideTimer()
        return
    end
    
    if (not (start > 0 and duration > 0 and modRate > 0)) then
        self._occ_start = nil
        self._occ_duration = nil
        self._occ_modRate = nil
        self._occ_gcd = nil
        self:HideTimer()
        return
    end
    
    -- Record values for later comparisons
    self._occ_start = start
    self._occ_duration = duration
    self._occ_modRate = modRate
    
    -- Detect GCD
    if IsGCD(start, duration, modRate) then
        self._occ_gcd = true
        self:HideTimer()
        return
    else
        self._occ_gcd = nil
    end
    
    -- Start the timer if needed
    if start > now + MIN_START_OFFSET then
        local minDuration = Module.db.minimumDuration
        if minDuration and (not minDuration or duration / modRate >= minDuration) and self:CanShowText() then
            self:ShowTimer()
        else
            self:HideTimer()
        end
    else
        self:HideTimer()
    end
end

function Cooldown:OnSetCooldownDuration(duration, modRate)
    if self:IsForbidden() then
        return
    end
    
    if self._occ_start then
        self:OnSetCooldown(self._occ_start, duration, modRate)
    end
end

function Cooldown:ShowTimer()
    local timer = Module.Timer:Get(self)
    if timer then
        cooldowns[self] = true
        timer:Show()
    end
end

function Cooldown:HideTimer()
    local timer = self._occ_timer
    if timer then
        cooldowns[self] = nil
        timer:Hide()
    end
end

function Cooldown:OnClear()
    if self:IsForbidden() then
        return
    end
    
    self._occ_gcd = nil
    self:HideTimer()
end

function Cooldown:SetDisplayAsPercentage(self)
    if self:IsForbidden() then
        return
    end
    
    self._occ_showText = false
    self:HideTimer()
end

function Cooldown:CanShowText()
    if self.noCooldownCount or self._occ_gcd then
        return false
    end

    local duration = self._occ_duration or 0
    if duration <= 0 then
        return false
    end

    local modRate = self._occ_modRate or 1
    if modRate <= 0 then
        return false
    end

    local start = self._occ_start or 0
    if start <= 0 then
        return false
    end

    if self.GetHideCountdownNumbers and not self:GetHideCountdownNumbers() then
        return false
    end

    local elapsed = GetTime() - start
    if elapsed < -0.5 then
        return false
    end

    -- Hide text if it's going to take up more than 1/3rd of the icon
    if self:GetWidth() < 1 or self:GetHeight() < 1 then
        return false
    end

    return not self._occ_showText
end

function Cooldown:GetTimer()
    return self._occ_timer
end

function Cooldown:GetTimeLeft()
    local start, duration, modRate = self._occ_start, self._occ_duration, self._occ_modRate
    if not (start and duration and modRate) then
        return 0
    end
    
    return (start + duration) - GetTime()
end

function Cooldown:GetSettings()
    if self._occ_settings_force then
        return self._occ_settings_force
    end

    local name = getFirstName(self)

    if name then
        local rule = Module:GetMatchingRule(name)
        if rule then
            return Module:GetTheme(rule.theme)
        end
    end

    return Module:GetDefaultTheme()
end

function Cooldown:OnSetHideCountdownNumbers(hide)
    local disable = not (hide or self.noCooldownCount or self:IsForbidden())
                    and Module.db.disableBlizzardCooldownText

    if disable then
        self:SetHideCountdownNumbers(true)
        Cooldown.Refresh(self)
    end
end

-- Setup cooldown hooks
function Cooldown:SetupHooks()
    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index
    hooksecurefunc(cooldown_mt, 'SetCooldown', Cooldown.OnSetCooldown)
    hooksecurefunc(cooldown_mt, 'SetCooldownDuration', Cooldown.OnSetCooldownDuration)
    hooksecurefunc(cooldown_mt, 'Clear', Cooldown.OnClear)
    hooksecurefunc(cooldown_mt, 'SetHideCountdownNumbers', Cooldown.OnSetHideCountdownNumbers)
    hooksecurefunc('CooldownFrame_SetDisplayAsPercentage', Cooldown.SetDisplayAsPercentage)
end

-- Apply method to all cooldowns
function Cooldown:ForAll(method, ...)
    local func = self[method]
    if type(func) ~= 'function' then
        error(('Cooldown method %q not found'):format(method), 2)
    end

    for cooldown in pairs(cooldowns) do
        func(cooldown, ...)
    end
end

-- Update module with our Cooldown methods
Module.Cooldown = Cooldown