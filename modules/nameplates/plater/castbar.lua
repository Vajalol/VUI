local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Nameplates = VUI.nameplates
local Plater = Nameplates.plater

-- VUI Plater Cast Bar Component
Plater.CastBar = {}
local CastBar = Plater.CastBar

-- Initialize the cast bar component
function CastBar:Initialize()
    -- Skip if cast bars are disabled
    if not Nameplates.settings.showCastbars then
        return
    end
    
    -- Set up hooks for cast bar customization
    self:SetupHooks()
end

-- Setup hooks for cast bar handling
function CastBar:SetupHooks()
    -- Hook cast bar creation/setup
    hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Initialize cast bar
        self:SetupCastBar(frame)
    end)
    
    -- Hook cast start
    hooksecurefunc("CompactUnitFrame_StartCastingFlash", function(frame)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Apply cast start effects
        self:OnCastStart(frame)
    end)
    
    -- Hook cast update
    hooksecurefunc("CompactUnitFrame_SetCastingInfo", function(frame, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Update cast bar
        self:UpdateCastBar(frame, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible)
    end)
    
    -- Hook channel update
    hooksecurefunc("CompactUnitFrame_SetChannelingInfo", function(frame, name, text, texture, startTime, endTime, isTradeSkill)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Update channel bar (uses same function as cast bar)
        self:UpdateCastBar(frame, name, text, texture, startTime, endTime, isTradeSkill, nil, nil, true)
    end)
    
    -- Hook cast stop
    hooksecurefunc("CompactUnitFrame_FinishCastingFlash", function(frame)
        -- Skip if not a nameplate or if our styling is not active
        if not frame.namePlateUnitToken or not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
            return
        end
        
        -- Apply cast stop effects
        self:OnCastStop(frame)
    end)
end

-- Setup cast bar for a unit frame
function CastBar:SetupCastBar(frame)
    -- Don't do anything if cast bars are disabled
    if not Nameplates.settings.showCastbars then
        if frame.castBar then
            frame.castBar:Hide()
        end
        return
    end
    
    -- Create cast bar if it doesn't exist
    if not frame.castBar then
        return -- Let Blizzard create it
    end
    
    -- Configure cast bar
    frame.castBar:ClearAllPoints()
    frame.castBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2)
    frame.castBar:SetPoint("TOPRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, -2)
    frame.castBar:SetHeight(Nameplates.settings.castBarHeight or 10)
    
    -- Set texture
    local texture = Nameplates.settings.castBarTexture or "VUI_Smooth"
    frame.castBar:SetStatusBarTexture(texture)
    
    -- Apply border
    Nameplates.hooks:ApplyBorder(frame.castBar, Nameplates.settings.healthBarBorderType)
    
    -- Configure icon
    if frame.castBar.Icon then
        -- Size and position the icon
        local iconSize = Nameplates.settings.castBarIconSize or 16
        frame.castBar.Icon:SetSize(iconSize, iconSize)
        frame.castBar.Icon:ClearAllPoints()
        frame.castBar.Icon:SetPoint("RIGHT", frame.castBar, "LEFT", -2, 0)
        
        -- Apply border to icon
        Nameplates.hooks:ApplyBorder(frame.castBar.Icon, Nameplates.settings.healthBarBorderType)
    end
    
    -- Configure cast text
    if frame.castBar.Text then
        -- Set font and position
        frame.castBar.Text:SetFont(Nameplates.settings.castBarTextFont or "VUI PT Sans Narrow", 
                                  Nameplates.settings.castBarTextSize or 8, 
                                  Nameplates.settings.castBarTextOutline or "OUTLINE")
        frame.castBar.Text:ClearAllPoints()
        frame.castBar.Text:SetPoint("CENTER", frame.castBar, "CENTER", 0, 0)
    end
    
    -- Create cast target text if needed
    if Nameplates.settings.showCastTarget and not frame.castBar.VUITargetText then
        frame.castBar.VUITargetText = frame.castBar:CreateFontString(nil, "OVERLAY")
        frame.castBar.VUITargetText:SetFont(Nameplates.settings.castBarTextFont or "VUI PT Sans Narrow", 
                                         Nameplates.settings.castBarTextSize or 8, 
                                         Nameplates.settings.castBarTextOutline or "OUTLINE")
        
        -- Position based on settings
        if Nameplates.settings.castTargetPosition == "below" then
            frame.castBar.VUITargetText:SetPoint("TOP", frame.castBar, "BOTTOM", 0, -1)
        else
            frame.castBar.VUITargetText:SetPoint("LEFT", frame.castBar.Text, "RIGHT", 2, 0)
        end
    end
    
    -- Create cast shield if needed
    if not frame.castBar.VUIShield and Nameplates.hooks then
        frame.castBar.VUIShield = frame.castBar:CreateTexture(nil, "OVERLAY")
        frame.castBar.VUIShield:SetSize(20, 20)
        frame.castBar.VUIShield:SetPoint("LEFT", frame.castBar.Icon, "LEFT", -2, 0)
        frame.castBar.VUIShield:SetTexture("Interface\\AddOns\\VUI\\media\\shield.tga")
        frame.castBar.VUIShield:Hide()
    end
    
    -- Create cast flash if needed
    if not frame.castBar.VUIFlash then
        frame.castBar.VUIFlash = frame.castBar:CreateTexture(nil, "OVERLAY")
        frame.castBar.VUIFlash:SetAllPoints(frame.castBar)
        frame.castBar.VUIFlash:SetTexture(frame.castBar:GetStatusBarTexture():GetTexture())
        frame.castBar.VUIFlash:SetBlendMode("ADD")
        frame.castBar.VUIFlash:SetVertexColor(1, 1, 1, 0)
        
        -- Create animation
        frame.castBar.VUIFlashAnim = frame.castBar.VUIFlash:CreateAnimationGroup()
        local fadeIn = frame.castBar.VUIFlashAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.5)
        fadeIn:SetDuration(0.15)
        fadeIn:SetOrder(1)
        
        local fadeOut = frame.castBar.VUIFlashAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.5)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.25)
        fadeOut:SetOrder(2)
        
        frame.castBar.VUIFlashAnim:SetScript("OnFinished", function()
            frame.castBar.VUIFlash:Hide()
        end)
    end
    
    -- Create interrupt flash if needed
    if not frame.castBar.VUIInterruptFlash then
        frame.castBar.VUIInterruptFlash = frame.castBar:CreateTexture(nil, "OVERLAY")
        frame.castBar.VUIInterruptFlash:SetAllPoints(frame.castBar)
        frame.castBar.VUIInterruptFlash:SetTexture(frame.castBar:GetStatusBarTexture():GetTexture())
        frame.castBar.VUIInterruptFlash:SetBlendMode("ADD")
        frame.castBar.VUIInterruptFlash:SetVertexColor(1, 0, 0, 0)
        
        -- Create animation
        frame.castBar.VUIInterruptAnim = frame.castBar.VUIInterruptFlash:CreateAnimationGroup()
        local fadeIn = frame.castBar.VUIInterruptAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.8)
        fadeIn:SetDuration(0.1)
        fadeIn:SetOrder(1)
        
        local fadeOut = frame.castBar.VUIInterruptAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.8)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.3)
        fadeOut:SetOrder(2)
        
        frame.castBar.VUIInterruptAnim:SetScript("OnFinished", function()
            frame.castBar.VUIInterruptFlash:Hide()
        end)
    end
    
    -- Show the cast bar by default
    frame.castBar:Show()
end

-- Handle cast start
function CastBar:OnCastStart(frame)
    -- Play start animation
    if frame.castBar and frame.castBar.VUIFlash and frame.castBar.VUIFlashAnim then
        frame.castBar.VUIFlash:Show()
        frame.castBar.VUIFlashAnim:Play()
    end
end

-- Update cast bar during casting
function CastBar:UpdateCastBar(frame, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, isChanneling)
    local unit = frame.namePlateUnitToken
    if not unit or not frame.castBar then return end
    
    -- Store not interruptible state
    frame.castBar.VUINotInterruptible = notInterruptible
    
    -- Set colors based on interruptible status
    if notInterruptible then
        local color = Nameplates.settings.nonInterruptibleColor
        frame.castBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1.0)
        
        -- Show shield icon if it exists
        if frame.castBar.VUIShield then
            frame.castBar.VUIShield:Show()
        end
    else
        local color = Nameplates.settings.castBarColor
        frame.castBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1.0)
        
        -- Hide shield icon
        if frame.castBar.VUIShield then
            frame.castBar.VUIShield:Hide()
        end
    end
    
    -- Apply theme colors if enabled
    if Nameplates.settings.useThemeColors then
        Nameplates.utils:ApplyThemeColors(frame.castBar, "castBar")
    end
    
    -- Update cast target text if enabled
    if Nameplates.settings.showCastTarget and frame.castBar.VUITargetText then
        local targetName = nil
        
        -- Try to get cast target
        if isChanneling then
            -- For channels, try to get target from spell target text
            targetName = UnitChannelInfo(unit)
            if targetName and targetName:find(">") then
                targetName = targetName:match(">%s*(.+)")
            else
                targetName = nil
            end
        else
            -- For regular casts
            targetName = UnitCastingInfo(unit)
            if targetName and targetName:find(">") then
                targetName = targetName:match(">%s*(.+)")
            else
                targetName = nil
            end
        end
        
        -- If we found a target, display it
        if targetName then
            -- Try to color by class if it's a player
            local targetIsPlayer = UnitExists(targetName) and UnitIsPlayer(targetName)
            if targetIsPlayer and Nameplates.settings.showClassColors then
                local _, targetClass = UnitClass(targetName)
                if targetClass and RAID_CLASS_COLORS[targetClass] then
                    local color = RAID_CLASS_COLORS[targetClass]
                    targetName = "|cff" .. string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) .. targetName .. "|r"
                end
            end
            
            frame.castBar.VUITargetText:SetText(">> " .. targetName)
            frame.castBar.VUITargetText:Show()
        else
            frame.castBar.VUITargetText:Hide()
        end
    end
end

-- Handle cast stop
function CastBar:OnCastStop(frame)
    local castBar = frame.castBar
    if not castBar then return end
    
    -- Check if the cast was interrupted
    if castBar.VUINotInterruptible == false and -- Was interruptible
       not castBar.finished and -- Didn't complete
       castBar.value < castBar.maxValue then -- Didn't reach the end
        
        -- Cast was interrupted, show interrupt flash
        if castBar.VUIInterruptFlash and castBar.VUIInterruptAnim then
            castBar.VUIInterruptFlash:Show()
            castBar.VUIInterruptAnim:Play()
        end
    end
end