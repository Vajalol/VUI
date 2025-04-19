-- Phoenix Flame Theme - Integration with Blizzard UI
local _, VUI = ...
local Skins = VUI:GetModule("skins")
local PhoenixFlame = VUI.themes and VUI.themes.PhoenixFlame

if not PhoenixFlame then
    PhoenixFlame = {}
    VUI.themes = VUI.themes or {}
    VUI.themes.PhoenixFlame = PhoenixFlame
end

-- UI Integration functions
PhoenixFlame.Integration = {}

-- Initialize integration hooks
function PhoenixFlame.Integration:Initialize()
    if not Skins then return end
    
    -- Hook into Skins module functions to apply our theme
    self:HookSkinFunctions()
    
    -- Register special UI enhancements for Phoenix Flame
    self:RegisterUIEnhancements()
end

-- Hook into core skin functions
function PhoenixFlame.Integration:HookSkinFunctions()
    -- Store original functions so we can call them
    self.originalApplyFrameBorder = Skins.ApplyFrameBorder
    self.originalApplyFrameSkin = Skins.ApplyFrameSkin
    self.originalStyleButton = Skins.StyleButton
    self.originalCreateBackdrop = Skins.CreateBackdrop
    
    -- Replace skin functions with our own versions
    Skins.ApplyFrameBorder = function(self, frame, options)
        -- Call original function first
        local result = PhoenixFlame.Integration.originalApplyFrameBorder(self, frame, options)
        
        -- Apply Phoenix Flame enhancements if this theme is active
        if Skins.activeTheme == "PhoenixFlame" and result and frame then
            PhoenixFlame.Integration:EnhanceFrameBorder(frame, options)
        end
        
        return result
    end
    
    Skins.ApplyFrameSkin = function(self, frame, options)
        -- Call original function first
        local result = PhoenixFlame.Integration.originalApplyFrameSkin(self, frame, options)
        
        -- Apply Phoenix Flame enhancements if this theme is active
        if Skins.activeTheme == "PhoenixFlame" and result and frame then
            PhoenixFlame.Integration:EnhanceFrameSkin(frame, options)
        end
        
        return result
    end
    
    Skins.StyleButton = function(self, button, options)
        -- Call original function first
        local result = PhoenixFlame.Integration.originalStyleButton(self, button, options)
        
        -- Apply Phoenix Flame button style if this theme is active
        if Skins.activeTheme == "PhoenixFlame" and result and button then
            PhoenixFlame.Integration:EnhanceButton(button, options)
        end
        
        return result
    end
    
    Skins.CreateBackdrop = function(self, frame, options)
        -- Call original function first
        local result = PhoenixFlame.Integration.originalCreateBackdrop(self, frame, options)
        
        -- Apply Phoenix Flame backdrop style if this theme is active
        if Skins.activeTheme == "PhoenixFlame" and result and frame then
            PhoenixFlame.Integration:EnhanceBackdrop(frame, options)
        end
        
        return result
    end
end

-- Register special UI enhancements specific to the Phoenix Flame theme
function PhoenixFlame.Integration:RegisterUIEnhancements()
    -- Register custom frame creation functions
    self:RegisterFrameEnhancements()
    
    -- Register custom animation functions
    self:RegisterAnimations()
    
    -- Register specialized UI skinning for specific Blizzard frames
    self:RegisterSpecialFrames()
end

-- Register frame enhancements
function PhoenixFlame.Integration:RegisterFrameEnhancements()
    -- Add Phoenix Flame-specific functions to the Skins module
    Skins.CreatePhoenixBorder = function(self, frame, options)
        if not frame then return end
        
        -- Mark that we've applied Phoenix styling
        frame.phoenixStyled = true
        
        -- Create a custom border with Phoenix Flame theme
        local border = frame:CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
        border:SetTexture(PhoenixFlame.media.textures.border)
        border:SetVertexColor(
            PhoenixFlame.colors.border.primary.r,
            PhoenixFlame.colors.border.primary.g,
            PhoenixFlame.colors.border.primary.b,
            PhoenixFlame.colors.border.primary.a
        )
        
        -- Store reference
        frame.phoenixBorder = border
        
        return border
    end
    
    Skins.CreatePhoenixGlow = function(self, frame, options)
        if not frame then return end
        
        -- Create a glow effect for the frame
        local glow = frame:CreateTexture(nil, "BACKGROUND")
        glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
        glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
        glow:SetTexture(PhoenixFlame.media.textures.glow)
        glow:SetVertexColor(
            PhoenixFlame.colors.border.highlight.r,
            PhoenixFlame.colors.border.highlight.g,
            PhoenixFlame.colors.border.highlight.b,
            0.4
        )
        glow:SetBlendMode("ADD")
        
        -- Store reference
        frame.phoenixGlow = glow
        
        return glow
    end
end

-- Register animations
function PhoenixFlame.Integration:RegisterAnimations()
    -- Add Phoenix Flame animation functions
    Skins.CreatePhoenixPulse = function(self, frame, options)
        if not frame then return end
        
        -- Setup animation group for pulsing effect
        local ag = frame:CreateAnimationGroup()
        ag:SetLooping("REPEAT")
        
        -- Alpha animation for pulsing effect
        local alpha1 = ag:CreateAnimation("Alpha")
        alpha1:SetFromAlpha(1.0)
        alpha1:SetToAlpha(0.7)
        alpha1:SetDuration(0.8)
        alpha1:SetOrder(1)
        
        local alpha2 = ag:CreateAnimation("Alpha")
        alpha2:SetFromAlpha(0.7)
        alpha2:SetToAlpha(1.0)
        alpha2:SetDuration(0.8)
        alpha2:SetOrder(2)
        
        -- Store reference
        frame.phoenixPulse = ag
        
        -- Start the animation
        ag:Play()
        
        return ag
    end
    
    Skins.CreatePhoenixFlareEffect = function(self, frame, options)
        if not frame then return end
        
        -- Create a flare effect element
        local flare = frame:CreateTexture(nil, "OVERLAY")
        flare:SetPoint("CENTER", frame, "CENTER", 0, 0)
        flare:SetSize(frame:GetWidth() * 1.5, frame:GetHeight() * 1.5)
        flare:SetTexture(PhoenixFlame.media.textures.glow)
        flare:SetVertexColor(1, 0.5, 0.1, 0)
        flare:SetBlendMode("ADD")
        
        -- Setup animation for the flare
        local ag = flare:CreateAnimationGroup()
        ag:SetLooping("REPEAT")
        
        -- Scale animation
        local scale1 = ag:CreateAnimation("Scale")
        scale1:SetScale(1.5, 1.5)
        scale1:SetDuration(0.5)
        scale1:SetOrder(1)
        
        -- Alpha animation to fade in and out
        local alpha1 = ag:CreateAnimation("Alpha")
        alpha1:SetFromAlpha(0)
        alpha1:SetToAlpha(0.5)
        alpha1:SetDuration(0.5)
        alpha1:SetOrder(1)
        
        local alpha2 = ag:CreateAnimation("Alpha")
        alpha2:SetFromAlpha(0.5)
        alpha2:SetToAlpha(0)
        alpha2:SetDuration(0.5)
        alpha2:SetOrder(2)
        
        -- Make the animation infrequent
        local wait = ag:CreateAnimation("Translation")
        wait:SetOffset(0, 0)
        wait:SetDuration(math.random(5, 15))
        wait:SetOrder(3)
        
        -- Store references
        frame.phoenixFlare = flare
        frame.phoenixFlareAnimation = ag
        
        -- Start the animation
        ag:Play()
        
        return flare
    end
end

-- Register special frames that get unique Phoenix Flame skinning
function PhoenixFlame.Integration:RegisterSpecialFrames()
    -- Register specialized skinning for important UI elements
    
    -- Character Frame - apply phoenix-themed background
    local CharacterFrameSkin = function()
        if not CharacterFrame or not Skins.activeTheme == "PhoenixFlame" then return end
        
        -- Apply phoenix backdrop to character frame
        if CharacterFrame.portrait then
            -- Add a fiery effect around the portrait
            if not CharacterFrame.portrait.phoenixGlow then
                Skins:CreatePhoenixGlow(CharacterFrame.portrait)
                Skins:CreatePhoenixPulse(CharacterFrame.portrait.phoenixGlow)
            end
        end
        
        -- Add title with phoenix theme
        if CharacterFrame.TitleText and not CharacterFrame.TitleText.phoenixStyled then
            CharacterFrame.TitleText:SetTextColor(
                PhoenixFlame.colors.text.header.r,
                PhoenixFlame.colors.text.header.g,
                PhoenixFlame.colors.text.header.b
            )
            CharacterFrame.TitleText.phoenixStyled = true
        end
    end
    
    -- Spellbook - apply phoenix-themed elements
    local SpellBookFrameSkin = function()
        if not SpellBookFrame or not Skins.activeTheme == "PhoenixFlame" then return end
        
        -- Apply phoenix effects to spell tabs
        for i = 1, MAX_SKILLLINE_TABS do
            local tab = _G["SpellBookSkillLineTab"..i]
            if tab and not tab.phoenixStyled then
                -- Add a subtle glow to the spell school tabs
                if not tab.phoenixGlow then
                    Skins:CreatePhoenixGlow(tab)
                end
                tab.phoenixStyled = true
            end
        end
    end
    
    -- Add these special frame handlers to the Skins module
    Skins.phoenixFrameHandlers = Skins.phoenixFrameHandlers or {}
    Skins.phoenixFrameHandlers.CharacterFrame = CharacterFrameSkin
    Skins.phoenixFrameHandlers.SpellBookFrame = SpellBookFrameSkin
    
    -- Hook the ShowUIPanel function to catch when these frames are shown
    local originalShowUIPanel = ShowUIPanel
    ShowUIPanel = function(frame, ...)
        -- Call original function
        local result = originalShowUIPanel(frame, ...)
        
        -- Apply our custom skinning if this is a registered frame
        if frame and frame:GetName() and Skins.phoenixFrameHandlers[frame:GetName()] then
            Skins.phoenixFrameHandlers[frame:GetName()]()
        end
        
        return result
    end
end

-- Enhancement functions called from the hooked skin functions

-- Enhance frame borders with Phoenix Flame style
function PhoenixFlame.Integration:EnhanceFrameBorder(frame, options)
    if not frame or frame.phoenixBorderEnhanced then return end
    
    -- Apply the Phoenix border style
    -- In a live implementation, this would apply a fiery border texture
    
    -- Mark as enhanced
    frame.phoenixBorderEnhanced = true
end

-- Enhance frame skin with Phoenix Flame style
function PhoenixFlame.Integration:EnhanceFrameSkin(frame, options)
    if not frame or frame.phoenixSkinEnhanced then return end
    
    -- Apply the main Phoenix skin enhancements
    
    -- For headers and title bars, add special treatment
    if options and options.isHeader then
        if frame.text or frame.Text then
            local textFrame = frame.text or frame.Text
            textFrame:SetTextColor(
                PhoenixFlame.colors.text.header.r,
                PhoenixFlame.colors.text.header.g,
                PhoenixFlame.colors.text.header.b
            )
        end
    end
    
    -- For important frames, add a glow effect
    if options and options.isImportant then
        Skins:CreatePhoenixGlow(frame)
    end
    
    -- Mark as enhanced
    frame.phoenixSkinEnhanced = true
end

-- Enhance buttons with Phoenix Flame style
function PhoenixFlame.Integration:EnhanceButton(button, options)
    if not button or button.phoenixButtonEnhanced then return end
    
    -- Apply button enhancements
    
    -- Set normal texture
    if button:GetNormalTexture() then
        button:GetNormalTexture():SetVertexColor(
            PhoenixFlame.colors.button.normal.r,
            PhoenixFlame.colors.button.normal.g,
            PhoenixFlame.colors.button.normal.b
        )
    end
    
    -- Set hover and pushed textures
    if button:GetHighlightTexture() then
        button:GetHighlightTexture():SetVertexColor(
            PhoenixFlame.colors.button.hover.r,
            PhoenixFlame.colors.button.hover.g,
            PhoenixFlame.colors.button.hover.b
        )
    end
    
    if button:GetPushedTexture() then
        button:GetPushedTexture():SetVertexColor(
            PhoenixFlame.colors.button.pressed.r,
            PhoenixFlame.colors.button.pressed.g,
            PhoenixFlame.colors.button.pressed.b
        )
    end
    
    -- For action buttons, apply special effects
    if button.HotKey or button.Count then
        -- This is likely an action button
        -- Add subtle flare effect to prominent buttons
        if options and options.isProminent then
            Skins:CreatePhoenixFlareEffect(button)
        end
    end
    
    -- Mark as enhanced
    button.phoenixButtonEnhanced = true
end

-- Enhance backdrops with Phoenix Flame style
function PhoenixFlame.Integration:EnhanceBackdrop(frame, options)
    if not frame or frame.phoenixBackdropEnhanced then return end
    
    -- Apply backdrop color variations based on frame type
    if options then
        if options.isHeader then
            -- Header backdrop
            frame:SetBackdropColor(
                PhoenixFlame.colors.backdrop.secondary.r,
                PhoenixFlame.colors.backdrop.secondary.g,
                PhoenixFlame.colors.backdrop.secondary.b,
                PhoenixFlame.colors.backdrop.secondary.a
            )
        elseif options.isHighlight then
            -- Highlighted elements
            frame:SetBackdropColor(
                PhoenixFlame.colors.backdrop.highlight.r,
                PhoenixFlame.colors.backdrop.highlight.g,
                PhoenixFlame.colors.backdrop.highlight.b,
                PhoenixFlame.colors.backdrop.highlight.a
            )
        end
    end
    
    -- Mark as enhanced
    frame.phoenixBackdropEnhanced = true
end

-- Initialize when the file is loaded
PhoenixFlame.Integration:Initialize()