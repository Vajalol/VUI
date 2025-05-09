local Module = VUI:NewModule('Misc.UIScale')

function Module:OnEnable()
    -- Apply saved scale on login if the feature is enabled
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:UpdateFromSettings()
    end)

    -- Monitor for settings changes
    self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        -- After combat ends, check if we need to apply new settings
        if self.pendingUpdate then
            self:UpdateFromSettings()
            self.pendingUpdate = nil
        end
    end)
    
    -- Print a help message the first time the feature is enabled
    if VUI.db.profile.misc.uiscale.enabled and not VUI.db.profile.misc.uiscale.helpShown then
        C_Timer.After(5, function()
            VUI:Print("UI Scale feature enabled. You can adjust the scale in the VUI > Misc settings panel.")
            VUI:Print("If the UI becomes too small, use the '/vui-reset-scale' command to reset to default.")
            VUI.db.profile.misc.uiscale.helpShown = true
        end)
    end
    
    -- Register slash command for emergency reset
    _G["SLASH_VUIRESETSCALE1"] = "/vui-reset-scale"
    SlashCmdList["VUIRESETSCALE"] = function()
        self:ResetScale()
        VUI:Print("UI Scale has been reset to default (1.0)")
    end
end

-- Update scale based on current settings
function Module:UpdateFromSettings()
    local settings = VUI.db.profile.misc.uiscale
    
    if settings and settings.enabled then
        local savedScale = settings.scale or 1.0
        self:ApplyScale(savedScale)
    end
end

-- Apply the given scale to the UI
function Module:ApplyScale(scaleNumber)
    -- Don't make scale changes during combat
    if InCombatLockdown() then
        self.pendingUpdate = true
        VUI:Print("UI Scale will be updated after combat ends.")
        return tonumber(GetCVar("uiScale"))
    end

    local numberedScale = tonumber(scaleNumber)
    if (type(numberedScale) == "number") then
        -- Validate scale number (keep between 0.5 and 1.0 for usability)
        if (numberedScale < 0.5) then
            numberedScale = 0.5
        elseif (numberedScale > 1.0) then
            numberedScale = 1.0
        end
        
        -- Round to 2 decimal places for visual clarity
        numberedScale = math.floor(numberedScale * 100 + 0.5) / 100
        
        -- Apply the scale
        SetCVar("uiScale", numberedScale)
        UIParent:SetScale(numberedScale)
        
        -- Save to profile
        VUI.db.profile.misc.uiscale.scale = numberedScale
        
        -- Provide feedback when scale changes from settings panel
        if not VUI.db.profile.install then
            VUI:Print("UI Scale set to: " .. numberedScale)
        end
        
        -- Return the actual scale used (for UI updates)
        return numberedScale
    end
    return tonumber(GetCVar("uiScale"))
end

-- Calculate the recommended scale based on screen resolution
function Module:CalculateAutoScale()
    local screenWidth, screenHeight = GetPhysicalScreenSize()
    
    -- Calculate based on a comfortable fit for 1080p-optimized UI
    local recommendedScale = math.min(1.0, 768 / screenHeight)
    
    -- Round to 2 decimal places for better UI display
    recommendedScale = math.floor(recommendedScale * 100 + 0.5) / 100
    
    VUI:Print("Auto-calculated scale for your " .. screenWidth .. "x" .. screenHeight .. " resolution: " .. recommendedScale)
    
    return recommendedScale
end

-- Reset to default UI scale (1.0)
function Module:ResetScale()
    return self:ApplyScale(1.0)
end