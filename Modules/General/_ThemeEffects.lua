local Module = VUI:NewModule('General.ThemeEffects')

function Module:OnEnable()
    -- Register for settings changes
    VUI:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- Small delay to ensure UI is fully loaded
        C_Timer.After(1, function()
            if VUI.db.profile.general.theme == 'VUI' then
                self:ApplyVUIThemePulseEffects()
            end
        end)
    end)
    
    -- Re-apply when UI is reloaded or changed
    VUI:RegisterEvent("UI_SCALE_CHANGED", function()
        if VUI.db.profile.general.theme == 'VUI' then
            self:ApplyVUIThemePulseEffects()
        end
    end)
    
    -- Add callback system for theme changes if not present already
    if not VUI.callbacks then
        VUI.callbacks = {}
    end
    
    if not VUI.RegisterCallback then
        function VUI:RegisterCallback(event, func)
            if not self.callbacks[event] then
                self.callbacks[event] = {}
            end
            table.insert(self.callbacks[event], func)
        end
    end
    
    if not VUI.SendCallback then
        function VUI:SendCallback(event, ...)
            if self.callbacks and self.callbacks[event] then
                for _, func in ipairs(self.callbacks[event]) do
                    func(...)
                end
            end
        end
    end
    
    -- Register for theme changes
    VUI:RegisterCallback("Theme_Changed", function(theme)
        if theme == 'VUI' then
            self:ApplyVUIThemePulseEffects()
        end
    end)
    
    -- Initial check in case we're already using the VUI theme
    if VUI.db.profile.general.theme == 'VUI' then
        self:ApplyVUIThemePulseEffects()
    end
end

function Module:ApplyVUIThemePulseEffects()
    -- Apply pulse effects to key UI elements
    
    -- Options for the pulse animation
    local pulseOptions = {
        pulseAmount = 0.05,      -- Subtle pulse - increase for stronger effect
        repeat_count = 0,        -- Infinite repeating (0 means repeat forever)
    }
    
    -- Apply to key elements that should pulse
    local pulseTargets = {
        -- Main game menu button (if found)
        GameMenuFrame and GameMenuFrame.Header,
        
        -- Player stats frame elements (if it exists)
        PlayerStatsFrame and PlayerStatsFrame.headerText,
        
        -- Game menu button - this is the button at the top of Game Menu
        GameMenuButtonOptions and GameMenuButtonOptions.LeftDisabled,
        
        -- Try to find the VUI menu button
        VUIMenuButton and VUIMenuButton.Text,
        
        -- Minimap elements if they exist
        MinimapBackdrop and MinimapBackdrop.VUIBorder,
        MinimapCluster and MinimapCluster.BorderTop,
        
        -- Chat frame elements
        GeneralDockManager and GeneralDockManager.TextBackground,
        
        -- Look for any VUI branded elements
        _G["VUITitle"], -- Global elements with VUI in the name
        
        -- Standard UI elements that should be themed
        PlayerFrame and PlayerFrame.PlayerFrameContent and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain and 
            PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture,
        TargetFrame and TargetFrame.TargetFrameContent and TargetFrame.TargetFrameContent.TargetFrameContentMain and 
            TargetFrame.TargetFrameContent.TargetFrameContentMain.StatusTexture,
        
        -- Class-specific resources where we want the VUI blue pulse
        ClassNameplateBarFrame,
        
        -- Action bars elements
        ActionButton1 and ActionButton1.HotKey,
        MainMenuBar and MainMenuBar.EndCaps and MainMenuBar.EndCaps.LeftEndCap,
        
        -- Castbar elements
        CastingBarFrame and CastingBarFrame.BorderShield,
        CastingBarFrame and CastingBarFrame.Text,
        
        -- Important elements players interact with
        QuestFrameDetailPanel and QuestFrameDetailPanel.MaterialTopLeft,
        MainMenuBarBackpackButton,
        CharacterMicroButton,
        
        -- Try to find specific tooltip elements
        GameTooltip and GameTooltip.NineSlice
    }
    
    for _, frame in pairs(pulseTargets) do
        if frame then
            -- Stop any existing animations first
            VUI.Animations:StopAnimations(frame)
            
            -- Apply pulse animation with blue glow
            VUI.Animations:Pulse(frame, 2.0, nil, pulseOptions)
            
            -- Add additional glow effect if it's a text element
            if frame.SetTextColor then
                frame:SetTextColor(0.05, 0.61, 0.9) -- VUI blue
            end
        end
    end
    
    -- Also try to find any frames with "VUI" in their name
    for name, frame in pairs(_G) do
        if type(name) == "string" and name:find("VUI") and type(frame) == "table" and frame.IsObjectType and frame:IsObjectType("Frame") then
            -- Don't animate hidden frames
            if frame:IsVisible() then
                VUI.Animations:StopAnimations(frame)
                VUI.Animations:Pulse(frame, 2.5, nil, pulseOptions)
            end
        end
    end
    
    -- Add blue glow to specific frames
    self:AddBlueGlow(GameMenuFrame)
    self:AddBlueGlow(PlayerStatsFrame)
end

-- Add a blue glow effect matching theme colors
function Module:AddBlueGlow(frame)
    if not frame then return end
    
    -- Skip if frame doesn't exist or is hidden
    if not frame:IsVisible() then return end
    
    -- Create or retrieve the glow texture
    if not frame.vui_glow then
        frame.vui_glow = frame:CreateTexture(nil, "OVERLAY")
        frame.vui_glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -8, 8)
        frame.vui_glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 8, -8)
        frame.vui_glow:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\UI-Achievement-Guild-Glow")
        frame.vui_glow:SetBlendMode("ADD")
        frame.vui_glow:SetVertexColor(0.05, 0.61, 0.9) -- #0D9DE6 base color
        frame.vui_glow:SetAlpha(0)
    end
    
    -- Stop any existing animations
    if frame.vui_glow.anim_group then
        frame.vui_glow.anim_group:Stop()
    end
    
    -- Create a new animation group
    frame.vui_glow.anim_group = frame.vui_glow:CreateAnimationGroup()
    frame.vui_glow.anim_group:SetLooping("REPEAT")
    
    -- Create fade in animation
    local fadeIn = frame.vui_glow.anim_group:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(0.3)
    fadeIn:SetDuration(1.5)
    fadeIn:SetOrder(1)
    fadeIn:SetSmoothing("IN_OUT")
    
    -- Create fade out animation
    local fadeOut = frame.vui_glow.anim_group:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.3)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(1.5)
    fadeOut:SetOrder(2)
    fadeOut:SetSmoothing("IN_OUT")
    
    -- Start the animation
    frame.vui_glow.anim_group:Play()
end