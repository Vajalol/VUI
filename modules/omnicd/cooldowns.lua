-- VUI OmniCD Cooldown Management
local _, VUI = ...
local OmniCD = VUI.omnicd

-- Initialize cooldowns tracking
function OmniCD:InitializeCooldowns()
    -- Table to track cooldowns
    self.spellCooldowns = {}
    self.iconFrames = {}
    self.iconPool = {}
    
    -- Set up events
    self:SetupCooldownEvents()
    
    -- Set up update frame
    self:CreateCooldownUpdateFrame()
end

-- Set up events for cooldown tracking
function OmniCD:SetupCooldownEvents()
    if not self.cooldownEventFrame then
        self.cooldownEventFrame = CreateFrame("Frame")
    end
    
    self.cooldownEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self.cooldownEventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
    self.cooldownEventFrame:RegisterEvent("SPELL_UPDATE_USABLE")
    self.cooldownEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.cooldownEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    self.cooldownEventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "SPELL_UPDATE_COOLDOWN" then
            self:OnCooldownsUpdated()
        elseif event == "SPELL_UPDATE_CHARGES" then
            self:OnChargesUpdated()
        elseif event == "SPELL_UPDATE_USABLE" then
            self:OnSpellUsabilityUpdated()
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:OnPlayerEnteringWorld()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            self:OnUnitSpellcastSucceeded(...)
        end
    end)
end

-- Create update frame for cooldown animations
function OmniCD:CreateCooldownUpdateFrame()
    if not self.cooldownUpdateFrame then
        self.cooldownUpdateFrame = CreateFrame("Frame")
        self.cooldownUpdateFrame:Hide()
        
        self.cooldownUpdateFrame:SetScript("OnUpdate", function(_, elapsed)
            self:UpdateCooldownDisplay(elapsed)
        end)
    end
end

-- Handle cooldowns being updated
function OmniCD:OnCooldownsUpdated()
    -- Get all tracked spells for the player's class
    local trackedSpells = self:GetTrackedSpellsForClass()
    
    -- Update cooldown info for each tracked spell
    for _, spellData in ipairs(trackedSpells) do
        local spellID = spellData.spellID
        
        -- Check if we have a valid spell ID
        if spellID and spellID > 0 then
            -- Get current cooldown info
            local start, duration, enabled = GetSpellCooldown(spellID)
            
            -- Initialize entry if needed
            if not self.spellCooldowns[spellID] then
                self.spellCooldowns[spellID] = {
                    start = 0,
                    duration = 0,
                    enabled = false,
                    ready = true,
                    charges = 0,
                    maxCharges = 0,
                    group = spellData.group,
                    priority = spellData.priority
                }
            end
            
            -- Update cooldown info
            local cdInfo = self.spellCooldowns[spellID]
            local oldStart = cdInfo.start
            local oldDuration = cdInfo.duration
            
            cdInfo.start = start
            cdInfo.duration = duration
            cdInfo.enabled = enabled == 1
            
            -- Check if this is a new cooldown activation
            local isCooldownStarting = (oldStart == 0 and start > 0) or 
                                      (start > 0 and (start ~= oldStart or duration ~= oldDuration))
            
            -- Check if cooldown is ready
            local onCooldown = start > 0 and duration > 0 and enabled == 1
            cdInfo.ready = not onCooldown
            
            -- Update charges info if applicable
            local currentCharges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
            if currentCharges then
                cdInfo.charges = currentCharges
                cdInfo.maxCharges = maxCharges
                
                -- If we have max charges, consider it ready regardless of cooldown
                if currentCharges == maxCharges then
                    cdInfo.ready = true
                end
                
                -- Using charges means we're still partially ready
                cdInfo.partiallyReady = currentCharges > 0
            else
                cdInfo.charges = 0
                cdInfo.maxCharges = 0
                cdInfo.partiallyReady = false
            end
            
            -- Create display for this cooldown
            self:UpdateCooldownDisplay(0, spellID)
            
            -- If cooldown just started, play animation
            if isCooldownStarting and not cdInfo.ready then
                self:PlayCooldownActivationAnimation(spellID)
            elseif cdInfo.ready and oldStart > 0 and not cdInfo.readyEffectPlayed then
                -- Cooldown just finished, play ready effect
                self:PlayCooldownReadyAnimation(spellID)
                cdInfo.readyEffectPlayed = true
            end
        end
    end
    
    -- Start the update frame if we have active cooldowns
    self:EnsureUpdateFrame()
    
    -- Update all cooldown icons based on their groups
    self:UpdateCooldownIconsByGroups()
end

-- Handle charges being updated
function OmniCD:OnChargesUpdated()
    -- Similar to OnCooldownsUpdated but focused on charges
    self:OnCooldownsUpdated() -- For simplicity, just reuse the same logic
end

-- Handle spell usability changes
function OmniCD:OnSpellUsabilityUpdated()
    -- Similar to OnCooldownsUpdated but focused on usability
    self:OnCooldownsUpdated() -- For simplicity, just reuse the same logic
end

-- Handle player entering world
function OmniCD:OnPlayerEnteringWorld()
    -- Initialize on entering world
    self:OnCooldownsUpdated()
end

-- Handle unit spellcast succeeded
function OmniCD:OnUnitSpellcastSucceeded(unit, _, spellID)
    -- Only track player spells
    if unit ~= "player" then return end
    
    -- Check if this spell is in our tracked list
    local trackedSpells = self:GetTrackedSpellsForClass()
    for _, spellData in ipairs(trackedSpells) do
        if spellData.spellID == spellID then
            -- Spell was cast, so update its cooldown info
            self:OnCooldownsUpdated()
            return
        end
    end
end

-- Update cooldown display
function OmniCD:UpdateCooldownDisplay(elapsed, specificSpellID)
    local currentTime = GetTime()
    local hasActiveCooldowns = false
    
    -- Get cooldowns to update
    local cooldownsToUpdate = {}
    if specificSpellID then
        if self.spellCooldowns[specificSpellID] then
            cooldownsToUpdate[specificSpellID] = self.spellCooldowns[specificSpellID]
        end
    else
        cooldownsToUpdate = self.spellCooldowns
    end
    
    -- Update each cooldown
    for spellID, cdInfo in pairs(cooldownsToUpdate) do
        -- Get icon frame
        local iconFrame = self:GetCooldownIconFrame(spellID)
        
        -- Update cooldown display
        if cdInfo.start > 0 and cdInfo.duration > 0 and cdInfo.enabled then
            -- Calculate remaining time
            local timeLeft = cdInfo.start + cdInfo.duration - currentTime
            
            -- Check if cooldown has finished
            if timeLeft <= 0 then
                -- Cooldown is finished
                cdInfo.ready = true
                
                -- Play ready effect if not already played
                if not cdInfo.readyEffectPlayed then
                    self:PlayCooldownReadyAnimation(spellID)
                    cdInfo.readyEffectPlayed = true
                end
                
                -- Update display to show ready state
                self:UpdateIconFrameReadyState(iconFrame, true)
            else
                -- Cooldown is still active
                hasActiveCooldowns = true
                cdInfo.ready = false
                cdInfo.readyEffectPlayed = false
                
                -- Update cooldown text
                if iconFrame.cooldownText then
                    iconFrame.cooldownText:SetText(self:FormatCooldownTime(timeLeft))
                end
                
                -- Update status bar if present
                if iconFrame.statusBar then
                    local progress = 1 - (timeLeft / cdInfo.duration)
                    iconFrame.statusBar:SetValue(progress * 100)
                end
                
                -- Show the icon as in cooldown state
                self:UpdateIconFrameReadyState(iconFrame, false)
            end
        else
            -- No active cooldown
            cdInfo.ready = true
            
            -- Update display to show ready state
            self:UpdateIconFrameReadyState(iconFrame, true)
        end
    end
    
    -- Continue or stop update frame as needed
    if not specificSpellID then
        if hasActiveCooldowns then
            self.cooldownUpdateFrame:Show()
        else
            self.cooldownUpdateFrame:Hide()
        end
    end
end

-- Format a cooldown time for display
function OmniCD:FormatCooldownTime(timeLeft)
    if timeLeft <= 0 then
        return ""
    elseif timeLeft < 1 then
        return string.format("%.1f", timeLeft)
    elseif timeLeft < 10 then
        return string.format("%.0f", timeLeft)
    elseif timeLeft < 60 then
        return string.format("%d", timeLeft)
    elseif timeLeft < 3600 then
        return string.format("%d:%02d", timeLeft / 60, timeLeft % 60)
    else
        return string.format("%d:%02d:%02d", timeLeft / 3600, (timeLeft % 3600) / 60, timeLeft % 60)
    end
end

-- Ensure the update frame is running if needed
function OmniCD:EnsureUpdateFrame()
    local hasActiveCooldowns = false
    
    -- Check if any cooldowns are active
    for _, cdInfo in pairs(self.spellCooldowns) do
        if cdInfo.start > 0 and cdInfo.duration > 0 and cdInfo.enabled and not cdInfo.ready then
            hasActiveCooldowns = true
            break
        end
    end
    
    -- Show or hide update frame
    if hasActiveCooldowns then
        self.cooldownUpdateFrame:Show()
    else
        self.cooldownUpdateFrame:Hide()
    end
end

-- Get an icon frame for a spell
function OmniCD:GetCooldownIconFrame(spellID)
    -- Return existing frame if we have one
    if self.iconFrames[spellID] then
        return self.iconFrames[spellID]
    end
    
    -- Get a frame from the pool or create a new one
    local frame = table.remove(self.iconPool) or self:CreateCooldownIconFrame()
    
    -- Set up the frame for this spell
    local spellName, _, spellIcon = GetSpellInfo(spellID)
    
    -- Set spell info
    frame.spellID = spellID
    frame.spellName.text = spellName
    frame.icon:SetTexture(spellIcon)
    
    -- Store in tracked frames
    self.iconFrames[spellID] = frame
    
    -- Apply theme and group styling
    self:ApplyThemeToIconFrame(frame)
    
    -- Show the frame
    frame:Show()
    
    return frame
end

-- Create a new cooldown icon frame
function OmniCD:CreateCooldownIconFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(36, 36)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the borders
    
    -- Border texture
    frame.border = frame:CreateTexture(nil, "OVERLAY")
    frame.border:SetAllPoints()
    frame.border:SetTexture(self:GetThemeTexture("icon_border"))
    
    -- Cooldown model
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetDrawBling(false)
    frame.cooldown:SetDrawSwipe(true)
    frame.cooldown:SetSwipeColor(0, 0, 0, 0.8)
    
    -- Cooldown text
    frame.cooldownText = frame:CreateFontString(nil, "OVERLAY")
    frame.cooldownText:SetPoint("CENTER", frame, "CENTER", 0, 0)
    self:ApplyThemeFont(frame.cooldownText, "cooldown", 14)
    
    -- Spell name text
    frame.spellName = frame:CreateFontString(nil, "OVERLAY")
    frame.spellName:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    self:ApplyThemeFont(frame.spellName, "regular", 9)
    
    -- Status bar (optional, only shown for some groups)
    frame.statusBar = CreateFrame("StatusBar", nil, frame)
    frame.statusBar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    frame.statusBar:SetSize(100, 6)
    frame.statusBar:SetStatusBarTexture(self:GetThemeTexture("bar"))
    frame.statusBar:SetMinMaxValues(0, 100)
    frame.statusBar:SetValue(0)
    
    -- Status bar background
    frame.statusBar.bg = frame.statusBar:CreateTexture(nil, "BACKGROUND")
    frame.statusBar.bg:SetAllPoints()
    frame.statusBar.bg:SetTexture(self:GetThemeTexture("background"))
    
    -- Glow effect (shown when ready)
    frame.glow = frame:CreateTexture(nil, "OVERLAY")
    frame.glow:SetPoint("CENTER")
    frame.glow:SetSize(frame:GetWidth() * 1.5, frame:GetHeight() * 1.5)
    frame.glow:SetTexture(self:GetThemeTexture("glow"))
    frame.glow:SetBlendMode("ADD")
    frame.glow:Hide()
    
    -- Initialize state
    frame.ready = true
    
    return frame
end

-- Update an icon frame to show ready or cooldown state
function OmniCD:UpdateIconFrameReadyState(frame, isReady)
    if not frame then return end
    
    frame.ready = isReady
    
    -- Update visuals based on ready state
    if isReady then
        -- Ready state
        frame.cooldownText:SetText("")
        frame.cooldown:Hide()
        
        -- Show status bar at full if applicable
        if frame.statusBar:IsShown() then
            frame.statusBar:SetValue(100)
        end
        
        -- Apply ready color to border
        self:ApplyThemeColors(frame.border, "ready")
        
        -- Show glow effect if enabled in theme
        if self:GetThemeEffectSetting("readyPulse") then
            frame.glow:Show()
            self:ApplyThemeColors(frame.glow, "highlight")
        end
    else
        -- Cooldown state
        frame.cooldown:Show()
        
        -- Hide glow
        frame.glow:Hide()
        
        -- Apply cooldown color to border
        self:ApplyThemeColors(frame.border, "border")
    end
end

-- Play cooldown activation animation
function OmniCD:PlayCooldownActivationAnimation(spellID)
    local frame = self.iconFrames[spellID]
    if not frame then return end
    
    -- Simple flash animation
    if not frame.activationAnimGroup then
        frame.activationAnimGroup = frame:CreateAnimationGroup()
        
        local flash = frame.activationAnimGroup:CreateAnimation("Alpha")
        flash:SetFromAlpha(1.0)
        flash:SetToAlpha(0.3)
        flash:SetDuration(0.15)
        flash:SetOrder(1)
        
        local flash2 = frame.activationAnimGroup:CreateAnimation("Alpha")
        flash2:SetFromAlpha(0.3)
        flash2:SetToAlpha(1.0)
        flash2:SetDuration(0.15)
        flash2:SetOrder(2)
    end
    
    frame.activationAnimGroup:Play()
end

-- Play cooldown ready animation
function OmniCD:PlayCooldownReadyAnimation(spellID)
    local frame = self.iconFrames[spellID]
    if not frame then return end
    
    -- Pulse animation
    if not frame.readyAnimGroup then
        frame.readyAnimGroup = frame:CreateAnimationGroup()
        
        local scale1 = frame.readyAnimGroup:CreateAnimation("Scale")
        scale1:SetScaleFrom(1, 1)
        scale1:SetScaleTo(1.3, 1.3)
        scale1:SetDuration(0.2)
        scale1:SetOrder(1)
        
        local scale2 = frame.readyAnimGroup:CreateAnimation("Scale")
        scale2:SetScaleFrom(1.3, 1.3)
        scale2:SetScaleTo(1.0, 1.0)
        scale2:SetDuration(0.2)
        scale2:SetOrder(2)
    end
    
    frame.readyAnimGroup:Play()
    
    -- Play sound if enabled
    if self.db.playReadySound then
        PlaySoundFile(self:GetThemeSound("cooldownReady"), "Master")
    end
end

-- Release an icon frame back to the pool
function OmniCD:ReleaseIconFrame(spellID)
    local frame = self.iconFrames[spellID]
    if not frame then return end
    
    -- Hide the frame
    frame:Hide()
    
    -- Reset frame data
    frame.spellID = nil
    frame.cooldownText:SetText("")
    frame.spellName:SetText("")
    frame.icon:SetTexture(nil)
    frame.glow:Hide()
    
    -- Return to pool
    table.insert(self.iconPool, frame)
    self.iconFrames[spellID] = nil
end