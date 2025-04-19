local addonName, VUI = ...
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

-- Arcane Mystic Theme Configuration
local ArcaneMystic = Module:NewTheme('ArcaneMystic', {
    name = L['Arcane Mystic'],
    desc = L['An elegant, magical theme with arcane runes and violet accents.'],
    author = 'VortexQ8',
    version = '1.0',
    mediaPath = 'Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\',
})

-- Color Palette
ArcaneMystic.Colors = {
    Background = { r = 0.102, g = 0.039, b = 0.184, a = 0.9 },    -- #1A0A2F
    BackgroundLight = { r = 0.137, g = 0.059, b = 0.216, a = 0.9 },  -- #231037
    BackgroundDark = { r = 0.078, g = 0.027, b = 0.149, a = 0.95 },  -- #140726
    Border = { r = 0.616, g = 0.051, b = 0.902, a = 1.0 },        -- #9D0DE6
    Highlight = { r = 0.365, g = 0.102, b = 1.0, a = 1.0 },       -- #5D1AFF
    Accent = { r = 0.510, g = 0.251, b = 0.753, a = 1.0 },        -- #8240C0
    ArcaneGlow = { r = 0.102, g = 0.729, b = 1.0, a = 0.8 },      -- #1ABAFF
    Text = { r = 0.902, g = 0.827, b = 1.0, a = 1.0 },            -- #E6D4FF
    TextDisabled = { r = 0.447, g = 0.4, b = 0.5, a = 1.0 },      -- #726680
    Health = { r = 0.616, g = 0.051, b = 0.902, a = 1.0 },        -- #9D0DE6
    Mana = { r = 0.2, g = 0.4, b = 0.8, a = 1.0 },                -- #3366CC
    Rage = { r = 0.7, g = 0.2, b = 0.2, a = 1.0 },                -- #B33333
    Energy = { r = 0.902, g = 0.902, b = 0.2, a = 1.0 },          -- #E6E633
    Focus = { r = 0.902, g = 0.616, b = 0.2, a = 1.0 },           -- #E69D33
}

-- Gradients
ArcaneMystic.Gradients = {
    Background = {
        TopLeft = { r = 0.102, g = 0.039, b = 0.184, a = 0.9 },   -- #1A0A2F
        TopRight = { r = 0.157, g = 0.078, b = 0.216, a = 0.9 },  -- #281437
        BottomLeft = { r = 0.118, g = 0.047, b = 0.196, a = 0.9 },-- #1E0C32
        BottomRight = { r = 0.094, g = 0.031, b = 0.169, a = 0.9 },-- #18082B
    },
    Button = {
        TopLeft = { r = 0.137, g = 0.059, b = 0.216, a = 0.9 },   -- #231037
        TopRight = { r = 0.176, g = 0.098, b = 0.255, a = 0.9 },  -- #2D1941
        BottomLeft = { r = 0.137, g = 0.059, b = 0.216, a = 0.9 },-- #231037
        BottomRight = { r = 0.125, g = 0.055, b = 0.196, a = 0.9 },-- #200E32
    },
    ButtonHover = {
        TopLeft = { r = 0.157, g = 0.078, b = 0.235, a = 0.9 },   -- #28143C
        TopRight = { r = 0.196, g = 0.118, b = 0.275, a = 0.9 },  -- #321E46
        BottomLeft = { r = 0.157, g = 0.078, b = 0.235, a = 0.9 },-- #28143C
        BottomRight = { r = 0.145, g = 0.067, b = 0.216, a = 0.9 },-- #251137
    },
    ButtonPressed = {
        TopLeft = { r = 0.118, g = 0.047, b = 0.196, a = 0.9 },   -- #1E0C32
        TopRight = { r = 0.157, g = 0.078, b = 0.235, a = 0.9 },  -- #28143C
        BottomLeft = { r = 0.118, g = 0.047, b = 0.196, a = 0.9 },-- #1E0C32
        BottomRight = { r = 0.106, g = 0.039, b = 0.176, a = 0.9 },-- #1B0A2D
    },
}

-- Animation settings
ArcaneMystic.Animations = {
    -- Arcane pulse animation settings
    ArcanePulse = {
        Duration = 4.0,
        PulseIntensity = 0.6,
        FadeOutDuration = 2.0,
    },
    
    -- Button hover animation
    ButtonHover = {
        Duration = 0.3,
        GlowIntensity = 0.7,
    },
    
    -- Bar animations
    BarAnimation = {
        Duration = 0.4,
        SmoothingAmount = 0.8,
        RuneEnabled = true,
        RuneSize = { width = 16, height = 16 },
    },
}

-- Font configuration
ArcaneMystic.Fonts = {
    Normal = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 12,
        style = "",
        color = ArcaneMystic.Colors.Text,
    },
    Title = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis-bold.ttf",
        size = 14,
        style = "",
        color = ArcaneMystic.Colors.Text,
    },
    Small = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 10,
        style = "",
        color = ArcaneMystic.Colors.Text,
    },
    Tooltip = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 11,
        style = "",
        color = ArcaneMystic.Colors.Text,
    },
}

-- Textures
ArcaneMystic.Textures = {
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
    Arcane = "arcane.tga",
    Rune = "rune.tga",
    Vortex = "vortex.tga",
    Starfield = "starfield.tga",
    
    -- Animation Textures
    ArcaneAnim = {
        "animation/arcane1.tga",
        "animation/arcane2.tga",
        "animation/arcane3.tga",
        "animation/arcane4.tga",
    },
    
    -- State Textures
    Hover = "hover.tga",
    Pressed = "pressed.tga",
    Disabled = "disabled.tga",
}

-- Frame styling function
function ArcaneMystic:StyleFrame(frame, options)
    options = options or {}
    
    -- Default styling
    if not frame.ArcaneMysticStyled then
        -- Apply background
        if not frame.ArcaneMysticBackground then
            frame.ArcaneMysticBackground = frame:CreateTexture(nil, "BACKGROUND")
            frame.ArcaneMysticBackground:SetAllPoints(frame)
            frame.ArcaneMysticBackground:SetTexture(self.mediaPath .. self.Textures.Background)
            frame.ArcaneMysticBackground:SetVertexColor(
                self.Colors.Background.r,
                self.Colors.Background.g,
                self.Colors.Background.b,
                self.Colors.Background.a
            )
        end
        
        -- Apply border
        if not frame.ArcaneMysticBorder then
            frame.ArcaneMysticBorder = frame:CreateTexture(nil, "BORDER")
            frame.ArcaneMysticBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
            frame.ArcaneMysticBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
            frame.ArcaneMysticBorder:SetTexture(self.mediaPath .. self.Textures.Border)
            frame.ArcaneMysticBorder:SetVertexColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                self.Colors.Border.a
            )
        end
        
        -- Add custom arcane effect
        if not frame.ArcaneMysticArcane and not options.noArcane then
            frame.ArcaneMysticArcane = frame:CreateTexture(nil, "OVERLAY")
            frame.ArcaneMysticArcane:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            frame.ArcaneMysticArcane:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            frame.ArcaneMysticArcane:SetTexture(self.mediaPath .. self.Textures.Arcane)
            frame.ArcaneMysticArcane:SetVertexColor(
                self.Colors.ArcaneGlow.r,
                self.Colors.ArcaneGlow.g,
                self.Colors.ArcaneGlow.b,
                0
            )
            frame.ArcaneMysticArcane:SetBlendMode("ADD")
            
            -- Create animation group for arcane pulse
            frame.ArcaneMysticArcaneAnimation = frame.ArcaneMysticArcane:CreateAnimationGroup()
            
            -- Create pulse animation
            local pulse = frame.ArcaneMysticArcaneAnimation:CreateAnimation("Alpha")
            pulse:SetFromAlpha(0)
            pulse:SetToAlpha(self.Animations.ArcanePulse.PulseIntensity)
            pulse:SetDuration(self.Animations.ArcanePulse.Duration / 2)
            
            -- Create fade animation
            local fade = frame.ArcaneMysticArcaneAnimation:CreateAnimation("Alpha")
            fade:SetFromAlpha(self.Animations.ArcanePulse.PulseIntensity)
            fade:SetToAlpha(0)
            fade:SetDuration(self.Animations.ArcanePulse.FadeOutDuration)
            fade:SetStartDelay(self.Animations.ArcanePulse.Duration / 2)
            
            -- Setup random pulse function
            frame.ArcaneMysticLastPulse = 0
            frame:HookScript("OnUpdate", function(self, elapsed)
                self.ArcaneMysticLastPulse = self.ArcaneMysticLastPulse + elapsed
                if self.ArcaneMysticLastPulse > math.random(10, 20) then
                    self.ArcaneMysticArcaneAnimation:Play()
                    self.ArcaneMysticLastPulse = 0
                end
            end)
        end
        
        frame.ArcaneMysticStyled = true
    end
    
    -- Apply style options
    if options.title and not frame.ArcaneMysticTitleApplied then
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
        
        frame.ArcaneMysticTitleApplied = true
    end
    
    -- Apply button styles if this is a button
    if frame:GetObjectType() == "Button" and not frame.ArcaneMysticButtonStyled then
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
        
        frame.ArcaneMysticButtonStyled = true
    end
end

-- Style status bar function
function ArcaneMystic:StyleStatusBar(bar, options)
    options = options or {}
    
    if not bar.ArcaneMysticBarStyled then
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
        
        -- Create rune icon if enabled in animation settings
        if self.Animations.BarAnimation.RuneEnabled and not bar.ArcaneMysticRune then
            bar.ArcaneMysticRune = bar:CreateTexture(nil, "OVERLAY")
            bar.ArcaneMysticRune:SetTexture(self.mediaPath .. self.Textures.Rune)
            bar.ArcaneMysticRune:SetSize(
                self.Animations.BarAnimation.RuneSize.width,
                self.Animations.BarAnimation.RuneSize.height
            )
            bar.ArcaneMysticRune:SetBlendMode("ADD")
            bar.ArcaneMysticRune:SetVertexColor(
                self.Colors.ArcaneGlow.r,
                self.Colors.ArcaneGlow.g,
                self.Colors.ArcaneGlow.b,
                self.Colors.ArcaneGlow.a
            )
            
            -- Update rune position
            bar:HookScript("OnValueChanged", function(self)
                local min, max = self:GetMinMaxValues()
                local val = self:GetValue()
                local width = self:GetWidth()
                local x = (val - min) / (max - min) * width
                
                if x > 0 and x < width then
                    self.ArcaneMysticRune:Show()
                    self.ArcaneMysticRune:SetPoint("CENTER", self, "LEFT", x, 0)
                else
                    self.ArcaneMysticRune:Hide()
                end
            end)
            
            -- Create spinning animation
            local runeAnim = bar.ArcaneMysticRune:CreateAnimationGroup()
            runeAnim:SetLooping("REPEAT")
            
            local rotation = runeAnim:CreateAnimation("Rotation")
            rotation:SetDegrees(360)
            rotation:SetDuration(5)
            
            runeAnim:Play()
        end
        
        -- Add border if requested
        if options.border and not bar.ArcaneMysticBorder then
            bar.ArcaneMysticBorder = CreateFrame("Frame", nil, bar)
            bar.ArcaneMysticBorder:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
            bar.ArcaneMysticBorder:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
            bar.ArcaneMysticBorder:SetBackdrop({
                edgeFile = self.mediaPath .. self.Textures.Border,
                edgeSize = 2,
            })
            bar.ArcaneMysticBorder:SetBackdropBorderColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                self.Colors.Border.a
            )
        end
        
        bar.ArcaneMysticBarStyled = true
    end
end

-- Register theme with the skin system
Module:RegisterTheme(ArcaneMystic)