local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Nameplates = VUI.nameplates
local Plater = Nameplates.plater

-- VUI Plater Health Bar Component
Plater.Health = {}
local Health = Plater.Health

-- Initialize the health bar component
function Health:Initialize()
    -- Set up hooks for health bar customization
    self:SetupHooks()
end

-- Setup hooks for health bar handling
function Health:SetupHooks()
    -- Hook health update
    hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Update health bar
        self:UpdateHealthBar(frame)
    end)
    
    -- Hook max health update
    hooksecurefunc("CompactUnitFrame_UpdateMaxHealth", function(frame)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Update health bar max value
        self:UpdateHealthBarMax(frame)
    end)
    
    -- Hook health color update
    hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Update health bar color
        self:UpdateHealthBarColor(frame)
    end)
end

-- Update health bar value
function Health:UpdateHealthBar(frame)
    local unit = frame.namePlateUnitToken
    if not unit then return end
    
    -- Get current health value
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    
    -- Apply to health bar
    if frame.healthBar then
        -- Standard health update
        frame.healthBar:SetValue(health)
        
        -- Update health text if enabled
        if Nameplates.settings.showHealthText then
            -- Create health text if it doesn't exist
            if not frame.VUIHealthText then
                frame.VUIHealthText = frame.healthBar:CreateFontString(nil, "OVERLAY")
                frame.VUIHealthText:SetFont(Nameplates.settings.healthTextFont or "VUI PT Sans Narrow", 
                                          Nameplates.settings.healthTextSize or 10, 
                                          Nameplates.settings.healthTextOutline or "OUTLINE")
                frame.VUIHealthText:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
            end
            
            -- Set health text based on format setting
            local format = Nameplates.settings.healthFormat or "percent"
            local text = ""
            
            if format == "percent" then
                if maxHealth > 0 then
                    text = math.floor((health / maxHealth) * 100) .. "%"
                else
                    text = "0%"
                end
            elseif format == "value" then
                text = Nameplates.utils:FormatNumber(health)
            elseif format == "both" then
                if maxHealth > 0 then
                    text = Nameplates.utils:FormatNumber(health) .. " - " .. math.floor((health / maxHealth) * 100) .. "%"
                else
                    text = Nameplates.utils:FormatNumber(health) .. " - 0%"
                end
            end
            
            frame.VUIHealthText:SetText(text)
            frame.VUIHealthText:Show()
        elseif frame.VUIHealthText then
            frame.VUIHealthText:Hide()
        end
        
        -- Handle execute range
        self:UpdateExecuteIndicator(frame)
        
        -- Handle custom effects
        self:ApplyCustomHealthEffects(frame, health, maxHealth)
    end
end

-- Update health bar max value
function Health:UpdateHealthBarMax(frame)
    local unit = frame.namePlateUnitToken
    if not unit then return end
    
    -- Set max value on health bar
    local maxHealth = UnitHealthMax(unit)
    if frame.healthBar and maxHealth > 0 then
        frame.healthBar:SetMinMaxValues(0, maxHealth)
    end
end

-- Update health bar color
function Health:UpdateHealthBarColor(frame)
    local unit = frame.namePlateUnitToken
    if not unit or not frame.healthBar then return end
    
    -- Check if threat coloring should override class/reaction color
    local useThreatColor = Nameplates.settings.showThreatIndicator and 
                          Nameplates.settings.threatWarningMode == "color" and
                          UnitReaction(unit, "player") <= 4 -- Only for enemies
    
    if useThreatColor then
        local isTanking, status, threatPct = UnitDetailedThreatSituation("player", unit)
        
        -- Skip color override if no threat data
        if not status then
            useThreatColor = false
        end
    end
    
    -- Apply appropriate color
    if not useThreatColor then
        -- Use class/reaction color
        local color = Nameplates.utils:GetHealthColor(unit, frame)
        if color then
            frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
    -- Note: Threat color is handled in hooks.lua UpdateThreat function
end

-- Update execute indicator
function Health:UpdateExecuteIndicator(frame)
    local unit = frame.namePlateUnitToken
    if not unit then return end
    
    -- Check if execute indicator is enabled
    if not Nameplates.settings.showExecuteIndicator then
        if frame.VUIExecuteIndicator then
            frame.VUIExecuteIndicator:Hide()
        end
        return
    end
    
    -- Create execute indicator if it doesn't exist
    if not frame.VUIExecuteIndicator then
        frame.VUIExecuteIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.VUIExecuteIndicator:SetAllPoints(frame.healthBar)
        frame.VUIExecuteIndicator:SetTexture("Interface\\AddOns\\VUI\\media\\execute.tga")
        frame.VUIExecuteIndicator:SetBlendMode("ADD")
        frame.VUIExecuteIndicator:SetVertexColor(1, 0, 0, 0.3)
    end
    
    -- Show indicator if unit is in execute range
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local executeThreshold = Nameplates.settings.executeThreshold or 20
    
    if maxHealth > 0 and (health / maxHealth) * 100 <= executeThreshold then
        frame.VUIExecuteIndicator:Show()
    else
        frame.VUIExecuteIndicator:Hide()
    end
end

-- Apply custom health effects (animations, etc.)
function Health:ApplyCustomHealthEffects(frame, health, maxHealth)
    -- Setup health change animation
    if not frame.healthBar.lastHealth then
        frame.healthBar.lastHealth = health
        return
    end
    
    -- Check for significant health change
    local healthDiff = health - frame.healthBar.lastHealth
    if healthDiff < -maxHealth * 0.05 then
        -- Lost at least 5% health, do damage flash
        self:AnimateHealthDamage(frame, healthDiff)
    elseif healthDiff > maxHealth * 0.05 then
        -- Gained at least 5% health, do healing flash
        self:AnimateHealthHealing(frame, healthDiff)
    end
    
    -- Update last health
    frame.healthBar.lastHealth = health
end

-- Animate health damage effect
function Health:AnimateHealthDamage(frame, healthDiff)
    -- Create damage flash if it doesn't exist
    if not frame.healthBar.damageFlash then
        frame.healthBar.damageFlash = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.healthBar.damageFlash:SetAllPoints(frame.healthBar)
        frame.healthBar.damageFlash:SetTexture(frame.healthBar:GetStatusBarTexture():GetTexture())
        frame.healthBar.damageFlash:SetBlendMode("ADD")
        frame.healthBar.damageFlash:SetVertexColor(1, 0, 0, 0)
        
        -- Create animation group
        frame.healthBar.damageAnim = frame.healthBar.damageFlash:CreateAnimationGroup()
        
        -- Alpha animation
        local fadeIn = frame.healthBar.damageAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.6)
        fadeIn:SetDuration(0.15)
        fadeIn:SetOrder(1)
        
        local fadeOut = frame.healthBar.damageAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.6)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.25)
        fadeOut:SetOrder(2)
        
        -- Set up animation finished handler
        frame.healthBar.damageAnim:SetScript("OnFinished", function()
            frame.healthBar.damageFlash:Hide()
        end)
    end
    
    -- Show damage flash
    frame.healthBar.damageFlash:Show()
    
    -- Start animation
    frame.healthBar.damageAnim:Play()
end

-- Animate health healing effect
function Health:AnimateHealthHealing(frame, healthDiff)
    -- Create healing flash if it doesn't exist
    if not frame.healthBar.healingFlash then
        frame.healthBar.healingFlash = frame.healthBar:CreateTexture(nil, "OVERLAY")
        frame.healthBar.healingFlash:SetAllPoints(frame.healthBar)
        frame.healthBar.healingFlash:SetTexture(frame.healthBar:GetStatusBarTexture():GetTexture())
        frame.healthBar.healingFlash:SetBlendMode("ADD")
        frame.healthBar.healingFlash:SetVertexColor(0, 1, 0, 0)
        
        -- Create animation group
        frame.healthBar.healingAnim = frame.healthBar.healingFlash:CreateAnimationGroup()
        
        -- Alpha animation
        local fadeIn = frame.healthBar.healingAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.6)
        fadeIn:SetDuration(0.15)
        fadeIn:SetOrder(1)
        
        local fadeOut = frame.healthBar.healingAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.6)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.25)
        fadeOut:SetOrder(2)
        
        -- Set up animation finished handler
        frame.healthBar.healingAnim:SetScript("OnFinished", function()
            frame.healthBar.healingFlash:Hide()
        end)
    end
    
    -- Show healing flash
    frame.healthBar.healingFlash:Show()
    
    -- Start animation
    frame.healthBar.healingAnim:Play()
end