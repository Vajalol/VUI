local Module = VUI:NewModule("ActionBars.Pulse")

function Module:OnEnable()
    -- Skip if disabled in config
    if not VUI.db.profile.actionbar.pulseEffects or not VUI.db.profile.actionbar.pulseEffects.enabled then
        return
    end

    -- Store all types of action buttons we need to apply the effect to
    local allActionButtons = {}
    
    -- Configuration for the pulse animation
    local pulseOptions = {
        pulseAmount = VUI.db.profile.actionbar.pulseEffects.intensity or 0.05,
        repeat_count = 0, -- Infinite repeating
    }
    
    -- Get current theme color
    local r, g, b
    local theme = VUI.db.profile.general.theme
    if theme == 'VUI' then
        r, g, b = 0.05, 0.61, 0.9 -- VUI blue
    elseif theme == 'PhoenixFlame' then
        r, g, b = 0.90, 0.30, 0.05 -- Phoenix Flame orange/red
    elseif theme == 'FelEnergy' then
        r, g, b = 0.10, 0.90, 0.10 -- Fel Energy green
    elseif theme == 'ArcaneMystic' then
        r, g, b = 0.60, 0.20, 0.80 -- Arcane Mystic purple
    else
        -- Default to VUI blue if theme is unknown
        r, g, b = 0.05, 0.61, 0.9
    end
    
    -- Collect standard action buttons
    for i = 1, 12 do
        table.insert(allActionButtons, _G["ActionButton" .. i])
    end
    
    -- Collect multi-bar buttons
    local multiBarNames = {
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "MultiBar5Button",
        "MultiBar6Button", 
        "MultiBar7Button"
    }
    
    for _, barName in pairs(multiBarNames) do
        for i = 1, 12 do
            local button = _G[barName .. i]
            if button then
                table.insert(allActionButtons, button)
            end
        end
    end
    
    -- Collect pet action buttons
    for i = 1, 10 do
        local button = _G["PetActionButton" .. i]
        if button then
            table.insert(allActionButtons, button)
        end
    end
    
    -- Collect stance buttons
    for i = 1, 10 do
        local button = _G["StanceButton" .. i]
        if button then
            table.insert(allActionButtons, button)
        end
    end
    
    -- Check for addon-specific buttons
    
    -- Dominos Support
    if C_AddOns.IsAddOnLoaded("Dominos") then
        for i = 1, 140 do
            local button = _G["DominosActionButton" .. i]
            if button then
                table.insert(allActionButtons, button)
            end
        end
        
        for i = 1, 10 do
            local petButton = _G["DominosPetActionButton" .. i]
            if petButton then
                table.insert(allActionButtons, petButton)
            end
            
            local stanceButton = _G["DominosStanceButton" .. i]
            if stanceButton then
                table.insert(allActionButtons, stanceButton)
            end
        end
    end
    
    -- Bartender4 Support
    if C_AddOns.IsAddOnLoaded("Bartender4") then
        for i = 1, 180 do
            local button = _G["BT4Button" .. i]
            if button then
                table.insert(allActionButtons, button)
            end
        end
        
        for i = 1, 10 do
            local petButton = _G["BT4PetButton" .. i]
            if petButton then
                table.insert(allActionButtons, petButton)
            end
            
            local stanceButton = _G["BT4StanceButton" .. i]
            if stanceButton then
                table.insert(allActionButtons, stanceButton)
            end
        end
    end
    
    -- Apply pulse effect to all collected buttons
    for _, button in pairs(allActionButtons) do
        if button and button:IsVisible() then
            -- Stop any existing animations
            VUI.Animations:StopAnimations(button)
            
            -- Apply the pulse animation with theme color
            VUI.Animations:Pulse(button, 2.0, nil, pulseOptions)
            
            -- Add a glow effect to the button
            self:AddActionButtonGlow(button, r, g, b)
        end
    end
    
    -- Listen for theme changes to update pulse colors
    VUI:RegisterCallback("Theme_Changed", function(newTheme)
        local nr, ng, nb
        if newTheme == 'VUI' then
            nr, ng, nb = 0.05, 0.61, 0.9 -- VUI blue
        elseif newTheme == 'PhoenixFlame' then
            nr, ng, nb = 0.90, 0.30, 0.05 -- Phoenix Flame orange/red
        elseif newTheme == 'FelEnergy' then
            nr, ng, nb = 0.10, 0.90, 0.10 -- Fel Energy green
        elseif newTheme == 'ArcaneMystic' then
            nr, ng, nb = 0.60, 0.20, 0.80 -- Arcane Mystic purple
        else
            -- Default to VUI blue if theme is unknown
            nr, ng, nb = 0.05, 0.61, 0.9
        end
        
        -- Update all button glows
        for _, button in pairs(allActionButtons) do
            if button and button:IsVisible() and button.vui_glow then
                button.vui_glow:SetVertexColor(nr, ng, nb)
            end
        end
    end)
end

-- Function to add a glow effect to action buttons
function Module:AddActionButtonGlow(button, r, g, b)
    if not button then return end
    
    -- Skip if button doesn't exist or is hidden
    if not button:IsVisible() then return end
    
    -- Create or retrieve the glow texture
    if not button.vui_glow then
        button.vui_glow = button:CreateTexture(nil, "OVERLAY")
        button.vui_glow:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
        button.vui_glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
        button.vui_glow:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\UI-ActionButton-Border")
        button.vui_glow:SetBlendMode("ADD")
        button.vui_glow:SetVertexColor(r, g, b)
        button.vui_glow:SetAlpha(0)
    else
        button.vui_glow:SetVertexColor(r, g, b)
    end
    
    -- Stop any existing animations
    if button.vui_glow.anim_group then
        button.vui_glow.anim_group:Stop()
    end
    
    -- Create a new animation group
    button.vui_glow.anim_group = button.vui_glow:CreateAnimationGroup()
    button.vui_glow.anim_group:SetLooping("REPEAT")
    
    -- Create fade in animation
    local fadeIn = button.vui_glow.anim_group:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(0.4)
    fadeIn:SetDuration(1.0)
    fadeIn:SetOrder(1)
    fadeIn:SetSmoothing("IN_OUT")
    
    -- Create fade out animation
    local fadeOut = button.vui_glow.anim_group:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.4)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(1.0)
    fadeOut:SetOrder(2)
    fadeOut:SetSmoothing("IN_OUT")
    
    -- Start the animation
    button.vui_glow.anim_group:Play()
end

function Module:OnDisable()
    -- Clean up all glows when the module is disabled
    local allActionButtons = {}
    
    -- Get all standard action buttons
    for i = 1, 12 do
        table.insert(allActionButtons, _G["ActionButton" .. i])
    end
    
    -- Collect multi-bar buttons
    local multiBarNames = {
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "MultiBar5Button",
        "MultiBar6Button", 
        "MultiBar7Button"
    }
    
    for _, barName in pairs(multiBarNames) do
        for i = 1, 12 do
            local button = _G[barName .. i]
            if button then
                table.insert(allActionButtons, button)
            end
        end
    end
    
    -- Add pet and stance buttons
    for i = 1, 10 do
        local petButton = _G["PetActionButton" .. i]
        if petButton then
            table.insert(allActionButtons, petButton)
        end
        
        local stanceButton = _G["StanceButton" .. i]
        if stanceButton then
            table.insert(allActionButtons, stanceButton)
        end
    end
    
    -- Check for addon-specific buttons
    -- Dominos Support
    if C_AddOns.IsAddOnLoaded("Dominos") then
        for i = 1, 140 do
            local button = _G["DominosActionButton" .. i]
            if button then
                table.insert(allActionButtons, button)
            end
        end
        
        for i = 1, 10 do
            local petButton = _G["DominosPetActionButton" .. i]
            if petButton then
                table.insert(allActionButtons, petButton)
            end
            
            local stanceButton = _G["DominosStanceButton" .. i]
            if stanceButton then
                table.insert(allActionButtons, stanceButton)
            end
        end
    end
    
    -- Bartender4 Support
    if C_AddOns.IsAddOnLoaded("Bartender4") then
        for i = 1, 180 do
            local button = _G["BT4Button" .. i]
            if button then
                table.insert(allActionButtons, button)
            end
        end
        
        for i = 1, 10 do
            local petButton = _G["BT4PetButton" .. i]
            if petButton then
                table.insert(allActionButtons, petButton)
            end
            
            local stanceButton = _G["BT4StanceButton" .. i]
            if stanceButton then
                table.insert(allActionButtons, stanceButton)
            end
        end
    end
    
    -- Remove glow from all buttons
    for _, button in pairs(allActionButtons) do
        if button and button.vui_glow then
            if button.vui_glow.anim_group then
                button.vui_glow.anim_group:Stop()
            end
            button.vui_glow:SetAlpha(0)
            VUI.Animations:StopAnimations(button)
        end
    end
end