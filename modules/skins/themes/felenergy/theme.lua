local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

-- Fel Energy Theme Configuration
local FelEnergy = Module:NewTheme('FelEnergy', {
    name = L['Fel Energy'],
    desc = L['A demonic, corrupting theme with fel energy and toxic green accents.'],
    author = 'VortexQ8',
    version = '1.0.0',
    mediaPath = 'Interface\\AddOns\\VUI\\media\\textures\\felenergy\\',
})

-- Color Palette
FelEnergy.Colors = {
    Background = { r = 0.039, g = 0.102, b = 0.039, a = 0.9 },    -- #0A1A0A
    BackgroundLight = { r = 0.059, g = 0.137, b = 0.059, a = 0.9 },  -- #0F230F
    BackgroundDark = { r = 0.027, g = 0.075, b = 0.027, a = 0.95 },  -- #071307
    Border = { r = 0.102, g = 1.0, b = 0.102, a = 1.0 },          -- #1AFF1A
    Highlight = { r = 0.667, g = 1.0, b = 0.0, a = 1.0 },         -- #AAFF00
    Accent = { r = 0.055, g = 0.184, b = 0.055, a = 1.0 },        -- #0E2F0E
    Corruption = { r = 0.667, g = 0.0, b = 1.0, a = 0.8 },        -- #AA00FF
    Text = { r = 0.827, g = 1.0, b = 0.827, a = 1.0 },            -- #D4FFD4
    TextDisabled = { r = 0.4, g = 0.5, b = 0.4, a = 1.0 },        -- #668066
    Health = { r = 0.102, g = 1.0, b = 0.102, a = 1.0 },          -- #1AFF1A
    Mana = { r = 0.2, g = 0.4, b = 0.8, a = 1.0 },                -- #3366CC
    Rage = { r = 0.7, g = 0.2, b = 0.2, a = 1.0 },                -- #B33333
    Energy = { r = 0.902, g = 0.902, b = 0.2, a = 1.0 },          -- #E6E633
    Focus = { r = 0.902, g = 0.616, b = 0.2, a = 1.0 },           -- #E69D33
}

-- Gradients
FelEnergy.Gradients = {
    Background = {
        TopLeft = { r = 0.039, g = 0.102, b = 0.039, a = 0.9 },   -- #0A1A0A
        TopRight = { r = 0.055, g = 0.157, b = 0.055, a = 0.9 },  -- #0E280E
        BottomLeft = { r = 0.047, g = 0.118, b = 0.047, a = 0.9 },-- #0C1E0C
        BottomRight = { r = 0.031, g = 0.094, b = 0.031, a = 0.9 },-- #081808
    },
    Button = {
        TopLeft = { r = 0.059, g = 0.137, b = 0.059, a = 0.9 },   -- #0F230F
        TopRight = { r = 0.078, g = 0.176, b = 0.078, a = 0.9 },  -- #142D14
        BottomLeft = { r = 0.059, g = 0.137, b = 0.059, a = 0.9 },-- #0F230F
        BottomRight = { r = 0.047, g = 0.125, b = 0.047, a = 0.9 },-- #0C200C
    },
    ButtonHover = {
        TopLeft = { r = 0.078, g = 0.157, b = 0.078, a = 0.9 },   -- #142814
        TopRight = { r = 0.098, g = 0.196, b = 0.098, a = 0.9 },  -- #193219
        BottomLeft = { r = 0.078, g = 0.157, b = 0.078, a = 0.9 },-- #142814
        BottomRight = { r = 0.067, g = 0.145, b = 0.067, a = 0.9 },-- #112511
    },
    ButtonPressed = {
        TopLeft = { r = 0.047, g = 0.118, b = 0.047, a = 0.9 },   -- #0C1E0C
        TopRight = { r = 0.067, g = 0.157, b = 0.067, a = 0.9 },  -- #112811
        BottomLeft = { r = 0.047, g = 0.118, b = 0.047, a = 0.9 },-- #0C1E0C
        BottomRight = { r = 0.039, g = 0.106, b = 0.039, a = 0.9 },-- #0A1B0A
    },
}

-- Animation settings
FelEnergy.Animations = {
    -- Fel corruption animation settings
    FelCorruption = {
        Duration = 3.0,
        PulseIntensity = 0.7,
        FadeOutDuration = 1.5,
    },
    
    -- Button hover animation
    ButtonHover = {
        Duration = 0.2,
        GlowIntensity = 0.8,
    },
    
    -- Bar animations
    BarAnimation = {
        Duration = 0.3,
        SmoothingAmount = 0.6,
        CorruptionEnabled = true,
        CorruptionSize = { width = 14, height = 24 },
    },
}

-- Font configuration
FelEnergy.Fonts = {
    Normal = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 12,
        style = "",
        color = FelEnergy.Colors.Text,
    },
    Title = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis-bold.ttf",
        size = 14,
        style = "",
        color = FelEnergy.Colors.Text,
    },
    Small = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 10,
        style = "",
        color = FelEnergy.Colors.Text,
    },
    Tooltip = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 11,
        style = "",
        color = FelEnergy.Colors.Text,
    },
}

-- Textures
FelEnergy.Textures = {
    -- Base Textures
    Background = "background.tga",
    BackgroundLight = "background-light.tga",
    BackgroundDark = "background-dark.tga",
    Border = "border.tga",
    Glow = "glow.tga",
    
    -- UI Element Textures
    Button = "button.tga",
    ActionButton = "actionbutton.tga",
    ItemButton = "itembutton.tga",
    StatusBar = "statusbar.tga",
    Tooltip = "tooltip.tga",
    UnitFrame = "unitframe.tga",
    CastBar = "castbar.tga",
    AuraIcon = "auraicon.tga",
    ChatFrame = "chatframe.tga",
    
    -- Special Effect Textures
    Fel = "fel.tga",
    Corruption = "corruption.tga",
    Smoke = "smoke.tga",
    Crystal = "crystal.tga",
    
    -- Animation Textures
    FelAnim = {
        "animation/fel1.tga",
        "animation/fel2.tga",
        "animation/fel3.tga",
        "animation/fel4.tga",
    },
    
    -- State Textures
    Hover = "hover.tga",
    Pressed = "pressed.tga",
    Disabled = "disabled.tga",
}

-- Frame styling function
function FelEnergy:StyleFrame(frame, options)
    options = options or {}
    
    -- Default styling
    if not frame.FelEnergyStyled then
        -- Apply background
        if not frame.FelEnergyBackground then
            frame.FelEnergyBackground = frame:CreateTexture(nil, "BACKGROUND")
            frame.FelEnergyBackground:SetAllPoints(frame)
            frame.FelEnergyBackground:SetTexture(self.mediaPath .. self.Textures.Background)
            frame.FelEnergyBackground:SetVertexColor(
                self.Colors.Background.r,
                self.Colors.Background.g,
                self.Colors.Background.b,
                self.Colors.Background.a
            )
        end
        
        -- Apply border
        if not frame.FelEnergyBorder then
            frame.FelEnergyBorder = frame:CreateTexture(nil, "BORDER")
            frame.FelEnergyBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
            frame.FelEnergyBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
            frame.FelEnergyBorder:SetTexture(self.mediaPath .. self.Textures.Border)
            frame.FelEnergyBorder:SetVertexColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                self.Colors.Border.a
            )
        end
        
        -- Add custom fel corruption effect
        if not frame.FelEnergyCorruption and not options.noCorruption then
            frame.FelEnergyCorruption = frame:CreateTexture(nil, "OVERLAY")
            frame.FelEnergyCorruption:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            frame.FelEnergyCorruption:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            frame.FelEnergyCorruption:SetTexture(self.mediaPath .. self.Textures.Corruption)
            frame.FelEnergyCorruption:SetVertexColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                0
            )
            frame.FelEnergyCorruption:SetBlendMode("ADD")
            
            -- Create animation group for fel corruption pulse
            frame.FelEnergyCorruptionAnimation = frame.FelEnergyCorruption:CreateAnimationGroup()
            
            -- Create pulse animation
            local pulse = frame.FelEnergyCorruptionAnimation:CreateAnimation("Alpha")
            pulse:SetFromAlpha(0)
            pulse:SetToAlpha(self.Animations.FelCorruption.PulseIntensity)
            pulse:SetDuration(self.Animations.FelCorruption.Duration / 2)
            
            -- Create fade animation
            local fade = frame.FelEnergyCorruptionAnimation:CreateAnimation("Alpha")
            fade:SetFromAlpha(self.Animations.FelCorruption.PulseIntensity)
            fade:SetToAlpha(0)
            fade:SetDuration(self.Animations.FelCorruption.FadeOutDuration)
            fade:SetStartDelay(self.Animations.FelCorruption.Duration / 2)
            
            -- Setup random pulse function
            frame.FelEnergyLastPulse = 0
            frame:HookScript("OnUpdate", function(self, elapsed)
                self.FelEnergyLastPulse = self.FelEnergyLastPulse + elapsed
                if self.FelEnergyLastPulse > math.random(7, 14) then
                    self.FelEnergyCorruptionAnimation:Play()
                    self.FelEnergyLastPulse = 0
                end
            end)
        end
        
        frame.FelEnergyStyled = true
    end
    
    -- Apply style options
    if options.title and not frame.FelEnergyTitleApplied then
        -- Create title bar
        local titleBar = CreateFrame("Frame", nil, frame)
        titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        titleBar:SetHeight(30)
        
        -- Title bar background
        local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
        titleBg:SetAllPoints(titleBar)
        titleBg:SetTexture(self.mediaPath .. self.Textures.BackgroundDark)
        titleBg:SetVertexColor(
            self.Colors.BackgroundDark.r,
            self.Colors.BackgroundDark.g,
            self.Colors.BackgroundDark.b,
            self.Colors.BackgroundDark.a
        )
        
        -- Title text
        local titleText = titleBar:CreateFontString(nil, "OVERLAY")
        titleText:SetFont(self.Fonts.Title.font, self.Fonts.Title.size, self.Fonts.Title.style)
        titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
        titleText:SetTextColor(
            self.Fonts.Title.color.r,
            self.Fonts.Title.color.g,
            self.Fonts.Title.color.b,
            self.Fonts.Title.color.a
        )
        titleText:SetText(options.title)
        
        frame.FelEnergyTitleApplied = true
    end
    
    -- Apply button styles if this is a button
    if frame:GetObjectType() == "Button" and not frame.FelEnergyButtonStyled then
        -- Normal state
        if frame:GetNormalTexture() then
            frame:GetNormalTexture():SetTexture(self.mediaPath .. self.Textures.Button)
            frame:GetNormalTexture():SetVertexColor(
                self.Gradients.Button.TopLeft.r,
                self.Gradients.Button.TopLeft.g,
                self.Gradients.Button.TopLeft.b,
                self.Gradients.Button.TopLeft.a
            )
        end
        
        -- Highlight state
        if frame:GetHighlightTexture() then
            frame:GetHighlightTexture():SetTexture(self.mediaPath .. self.Textures.Hover)
            frame:GetHighlightTexture():SetVertexColor(
                self.Gradients.ButtonHover.TopLeft.r,
                self.Gradients.ButtonHover.TopLeft.g,
                self.Gradients.ButtonHover.TopLeft.b,
                self.Gradients.ButtonHover.TopLeft.a
            )
        end
        
        -- Pushed state
        if frame:GetPushedTexture() then
            frame:GetPushedTexture():SetTexture(self.mediaPath .. self.Textures.Pressed)
            frame:GetPushedTexture():SetVertexColor(
                self.Gradients.ButtonPressed.TopLeft.r,
                self.Gradients.ButtonPressed.TopLeft.g,
                self.Gradients.ButtonPressed.TopLeft.b,
                self.Gradients.ButtonPressed.TopLeft.a
            )
        end
        
        -- Add fel glow on hover
        frame:HookScript("OnEnter", function(self)
            if not self.FelEnergyGlow then
                self.FelEnergyGlow = self:CreateTexture(nil, "OVERLAY")
                self.FelEnergyGlow:SetPoint("TOPLEFT", self, "TOPLEFT", -5, 5)
                self.FelEnergyGlow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 5, -5)
                self.FelEnergyGlow:SetTexture(FelEnergy.mediaPath .. FelEnergy.Textures.Glow)
                self.FelEnergyGlow:SetVertexColor(
                    FelEnergy.Colors.Border.r,
                    FelEnergy.Colors.Border.g,
                    FelEnergy.Colors.Border.b,
                    0.5
                )
                self.FelEnergyGlow:SetBlendMode("ADD")
            end
            
            self.FelEnergyGlow:Show()
        end)
        
        frame:HookScript("OnLeave", function(self)
            if self.FelEnergyGlow then
                self.FelEnergyGlow:Hide()
            end
        end)
        
        frame.FelEnergyButtonStyled = true
    end
end

-- Style status bar function
function FelEnergy:StyleStatusBar(bar, options)
    options = options or {}
    
    if not bar.FelEnergyBarStyled then
        -- Set texture
        bar:SetStatusBarTexture(self.mediaPath .. self.Textures.StatusBar)
        
        -- Set color based on options or default to border color
        local r, g, b = self.Colors.Border.r, self.Colors.Border.g, self.Colors.Border.b
        if options.barType then
            if options.barType == "health" and self.Colors.Health then
                r, g, b = self.Colors.Health.r, self.Colors.Health.g, self.Colors.Health.b
            elseif options.barType == "mana" and self.Colors.Mana then
                r, g, b = self.Colors.Mana.r, self.Colors.Mana.g, self.Colors.Mana.b
            elseif options.barType == "rage" and self.Colors.Rage then
                r, g, b = self.Colors.Rage.r, self.Colors.Rage.g, self.Colors.Rage.b
            elseif options.barType == "energy" and self.Colors.Energy then
                r, g, b = self.Colors.Energy.r, self.Colors.Energy.g, self.Colors.Energy.b
            elseif options.barType == "focus" and self.Colors.Focus then
                r, g, b = self.Colors.Focus.r, self.Colors.Focus.g, self.Colors.Focus.b
            end
        elseif options.color then
            r, g, b = options.color.r, options.color.g, options.color.b
        end
        
        bar:SetStatusBarColor(r, g, b)
        
        -- Create corruption effect if enabled in animation settings
        if self.Animations.BarAnimation.CorruptionEnabled and not bar.FelEnergyCorruption then
            bar.FelEnergyCorruption = bar:CreateTexture(nil, "OVERLAY")
            bar.FelEnergyCorruption:SetTexture(self.mediaPath .. self.Textures.Corruption)
            bar.FelEnergyCorruption:SetSize(
                self.Animations.BarAnimation.CorruptionSize.width,
                self.Animations.BarAnimation.CorruptionSize.height
            )
            bar.FelEnergyCorruption:SetBlendMode("ADD")
            bar.FelEnergyCorruption:SetVertexColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                0.7
            )
            
            -- Update corruption position
            bar:HookScript("OnValueChanged", function(self)
                local min, max = self:GetMinMaxValues()
                local val = self:GetValue()
                local width = self:GetWidth()
                local x = (val - min) / (max - min) * width
                
                if x > 0 and x < width then
                    self.FelEnergyCorruption:Show()
                    self.FelEnergyCorruption:SetPoint("CENTER", self, "LEFT", x, 0)
                else
                    self.FelEnergyCorruption:Hide()
                end
            end)
            
            -- Add subtle animation
            local corruptionAnim = bar.FelEnergyCorruption:CreateAnimationGroup()
            corruptionAnim:SetLooping("REPEAT")
            
            local scale = corruptionAnim:CreateAnimation("Scale")
            scale:SetScaleFrom(0.95, 0.95)
            scale:SetScaleTo(1.05, 1.05)
            scale:SetDuration(0.7)
            scale:SetOrder(1)
            
            local scale2 = corruptionAnim:CreateAnimation("Scale")
            scale2:SetScaleFrom(1.05, 1.05)
            scale2:SetScaleTo(0.95, 0.95)
            scale2:SetDuration(0.7)
            scale2:SetOrder(2)
            
            corruptionAnim:Play()
        end
        
        -- Add border if requested
        if options.border and not bar.FelEnergyBorder then
            bar.FelEnergyBorder = CreateFrame("Frame", nil, bar)
            bar.FelEnergyBorder:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
            bar.FelEnergyBorder:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
            bar.FelEnergyBorder:SetBackdrop({
                edgeFile = self.mediaPath .. self.Textures.Border,
                edgeSize = 2,
            })
            bar.FelEnergyBorder:SetBackdropBorderColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                self.Colors.Border.a
            )
        end
        
        bar.FelEnergyBarStyled = true
    end
end

-- Register theme with the skin system
Module:RegisterTheme(FelEnergy)