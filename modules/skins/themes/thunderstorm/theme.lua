local addonName, VUI = ...
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

-- Thunder Storm Theme Configuration
local ThunderStorm = Module:NewTheme('ThunderStorm', {
    name = L['Thunder Storm'],
    desc = L['An electric, stormy theme with lightning effects and deep blue colors.'],
    author = 'VortexQ8',
    version = '1.0.0',
    mediaPath = 'Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\',
})

-- Color Palette
ThunderStorm.Colors = {
    Background = { r = 0.039, g = 0.039, b = 0.102, a = 0.9 },    -- #0A0A1A
    BackgroundLight = { r = 0.059, g = 0.059, b = 0.137, a = 0.9 },  -- #0F0F23
    BackgroundDark = { r = 0.024, g = 0.024, b = 0.075, a = 0.95 },  -- #070713
    Border = { r = 0.051, g = 0.616, b = 0.902, a = 1.0 },        -- #0D9DE6
    Highlight = { r = 0.157, g = 0.706, b = 0.961, a = 1.0 },     -- #28B4F5
    Lightning = { r = 1.0, g = 1.0, b = 1.0, a = 0.8 },           -- #FFFFFF
    StormyGray = { r = 0.251, g = 0.251, b = 0.314, a = 1.0 },    -- #404050
    Text = { r = 0.827, g = 0.914, b = 1.0, a = 1.0 },            -- #D4E9FF
    TextDisabled = { r = 0.4, g = 0.447, b = 0.5, a = 1.0 },      -- #667280
    Health = { r = 0.051, g = 0.616, b = 0.902, a = 1.0 },        -- #0D9DE6
    Mana = { r = 0.2, g = 0.4, b = 0.8, a = 1.0 },                -- #3366CC
    Rage = { r = 0.7, g = 0.2, b = 0.2, a = 1.0 },                -- #B33333
    Energy = { r = 0.902, g = 0.902, b = 0.2, a = 1.0 },          -- #E6E633
    Focus = { r = 0.902, g = 0.616, b = 0.2, a = 1.0 },           -- #E69D33
}

-- Gradients
ThunderStorm.Gradients = {
    Background = {
        TopLeft = { r = 0.039, g = 0.039, b = 0.102, a = 0.9 },   -- #0A0A1A
        TopRight = { r = 0.059, g = 0.078, b = 0.157, a = 0.9 },  -- #0F1428
        BottomLeft = { r = 0.047, g = 0.047, b = 0.118, a = 0.9 },-- #0C0C1E
        BottomRight = { r = 0.024, g = 0.031, b = 0.094, a = 0.9 },-- #070818
    },
    Button = {
        TopLeft = { r = 0.059, g = 0.059, b = 0.137, a = 0.9 },   -- #0F0F23
        TopRight = { r = 0.078, g = 0.098, b = 0.176, a = 0.9 },  -- #141A2D
        BottomLeft = { r = 0.059, g = 0.059, b = 0.137, a = 0.9 },-- #0F0F23
        BottomRight = { r = 0.047, g = 0.055, b = 0.125, a = 0.9 },-- #0C0E20
    },
    ButtonHover = {
        TopLeft = { r = 0.067, g = 0.078, b = 0.157, a = 0.9 },   -- #111428
        TopRight = { r = 0.086, g = 0.118, b = 0.196, a = 0.9 },  -- #161E32
        BottomLeft = { r = 0.067, g = 0.078, b = 0.157, a = 0.9 },-- #111428
        BottomRight = { r = 0.055, g = 0.067, b = 0.145, a = 0.9 },-- #0E1125
    },
    ButtonPressed = {
        TopLeft = { r = 0.039, g = 0.047, b = 0.118, a = 0.9 },   -- #0A0C1E
        TopRight = { r = 0.059, g = 0.078, b = 0.157, a = 0.9 },  -- #0F1428
        BottomLeft = { r = 0.039, g = 0.047, b = 0.118, a = 0.9 },-- #0A0C1E
        BottomRight = { r = 0.031, g = 0.039, b = 0.106, a = 0.9 },-- #080A1B
    },
}

-- Animation settings
ThunderStorm.Animations = {
    -- Lightning flash animation settings
    LightningFlash = {
        Duration = 0.5,
        FlashIntensity = 0.8,
        FadeOutDuration = 0.3,
    },
    
    -- Button hover animation
    ButtonHover = {
        Duration = 0.2,
        GlowIntensity = 0.6,
    },
    
    -- Bar animations
    BarAnimation = {
        Duration = 0.3,
        SmoothingAmount = 0.7,
        SparkEnabled = true,
        SparkSize = { width = 12, height = 25 },
    },
}

-- Font configuration
ThunderStorm.Fonts = {
    Normal = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 12,
        style = "",
        color = ThunderStorm.Colors.Text,
    },
    Title = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis-bold.ttf",
        size = 14,
        style = "",
        color = ThunderStorm.Colors.Text,
    },
    Small = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 10,
        style = "",
        color = ThunderStorm.Colors.Text,
    },
    Tooltip = {
        font = "Interface\\AddOns\\VUI\\media\\fonts\\metropolis.ttf",
        size = 11,
        style = "",
        color = ThunderStorm.Colors.Text,
    },
}

-- Textures
ThunderStorm.Textures = {
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
    Lightning = "lightning.tga",
    Spark = "spark.tga",
    Cloud = "cloud.tga",
    Rain = "rain.tga",
    
    -- Animation Textures
    LightningAnim = {
        "animation/lightning1.tga",
        "animation/lightning2.tga",
        "animation/lightning3.tga",
        "animation/lightning4.tga",
    },
    
    -- State Textures
    Hover = "hover.tga",
    Pressed = "pressed.tga",
    Disabled = "disabled.tga",
}

-- Frame styling function
function ThunderStorm:StyleFrame(frame, options)
    options = options or {}
    
    -- Default styling
    if not frame.ThunderStormStyled then
        -- Apply background
        if not frame.ThunderStormBackground then
            frame.ThunderStormBackground = frame:CreateTexture(nil, "BACKGROUND")
            frame.ThunderStormBackground:SetAllPoints(frame)
            frame.ThunderStormBackground:SetTexture(self.mediaPath .. self.Textures.Background)
            frame.ThunderStormBackground:SetVertexColor(
                self.Colors.Background.r,
                self.Colors.Background.g,
                self.Colors.Background.b,
                self.Colors.Background.a
            )
        end
        
        -- Apply border
        if not frame.ThunderStormBorder then
            frame.ThunderStormBorder = frame:CreateTexture(nil, "BORDER")
            frame.ThunderStormBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
            frame.ThunderStormBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
            frame.ThunderStormBorder:SetTexture(self.mediaPath .. self.Textures.Border)
            frame.ThunderStormBorder:SetVertexColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                self.Colors.Border.a
            )
        end
        
        -- Add custom lightning effect
        if not frame.ThunderStormLightning and not options.noLightning then
            frame.ThunderStormLightning = frame:CreateTexture(nil, "OVERLAY")
            frame.ThunderStormLightning:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            frame.ThunderStormLightning:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            frame.ThunderStormLightning:SetTexture(self.mediaPath .. self.Textures.Lightning)
            frame.ThunderStormLightning:SetVertexColor(
                self.Colors.Lightning.r,
                self.Colors.Lightning.g,
                self.Colors.Lightning.b,
                0
            )
            
            -- Create animation group for lightning flash
            frame.ThunderStormLightningAnimation = frame.ThunderStormLightning:CreateAnimationGroup()
            
            -- Create flash animation
            local flash = frame.ThunderStormLightningAnimation:CreateAnimation("Alpha")
            flash:SetFromAlpha(0)
            flash:SetToAlpha(self.Animations.LightningFlash.FlashIntensity)
            flash:SetDuration(self.Animations.LightningFlash.Duration / 2)
            
            -- Create fade animation
            local fade = frame.ThunderStormLightningAnimation:CreateAnimation("Alpha")
            fade:SetFromAlpha(self.Animations.LightningFlash.FlashIntensity)
            fade:SetToAlpha(0)
            fade:SetDuration(self.Animations.LightningFlash.FadeOutDuration)
            fade:SetStartDelay(self.Animations.LightningFlash.Duration / 2)
            
            -- Setup random flash function
            frame.ThunderStormLastFlash = 0
            frame:HookScript("OnUpdate", function(self, elapsed)
                self.ThunderStormLastFlash = self.ThunderStormLastFlash + elapsed
                if self.ThunderStormLastFlash > math.random(8, 15) then
                    self.ThunderStormLightningAnimation:Play()
                    self.ThunderStormLastFlash = 0
                end
            end)
        end
        
        frame.ThunderStormStyled = true
    end
    
    -- Apply style options
    if options.title and not frame.ThunderStormTitleApplied then
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
        
        frame.ThunderStormTitleApplied = true
    end
    
    -- Apply button styles if this is a button
    if frame:GetObjectType() == "Button" and not frame.ThunderStormButtonStyled then
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
        
        frame.ThunderStormButtonStyled = true
    end
end

-- Style status bar function
function ThunderStorm:StyleStatusBar(bar, options)
    options = options or {}
    
    if not bar.ThunderStormBarStyled then
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
        
        -- Create spark if enabled in animation settings
        if self.Animations.BarAnimation.SparkEnabled and not bar.ThunderStormSpark then
            bar.ThunderStormSpark = bar:CreateTexture(nil, "OVERLAY")
            bar.ThunderStormSpark:SetTexture(self.mediaPath .. self.Textures.Spark)
            bar.ThunderStormSpark:SetSize(
                self.Animations.BarAnimation.SparkSize.width,
                self.Animations.BarAnimation.SparkSize.height
            )
            bar.ThunderStormSpark:SetBlendMode("ADD")
            bar.ThunderStormSpark:SetVertexColor(
                self.Colors.Lightning.r,
                self.Colors.Lightning.g,
                self.Colors.Lightning.b,
                self.Colors.Lightning.a
            )
            
            -- Update spark position
            bar:HookScript("OnValueChanged", function(self)
                local min, max = self:GetMinMaxValues()
                local val = self:GetValue()
                local width = self:GetWidth()
                local x = (val - min) / (max - min) * width
                
                if x > 0 and x < width then
                    self.ThunderStormSpark:Show()
                    self.ThunderStormSpark:SetPoint("CENTER", self, "LEFT", x, 0)
                else
                    self.ThunderStormSpark:Hide()
                end
            end)
        end
        
        -- Add border if requested
        if options.border and not bar.ThunderStormBorder then
            bar.ThunderStormBorder = CreateFrame("Frame", nil, bar)
            bar.ThunderStormBorder:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
            bar.ThunderStormBorder:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
            bar.ThunderStormBorder:SetBackdrop({
                edgeFile = self.mediaPath .. self.Textures.Border,
                edgeSize = 2,
            })
            bar.ThunderStormBorder:SetBackdropBorderColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                self.Colors.Border.a
            )
        end
        
        bar.ThunderStormBarStyled = true
    end
end

-- Register theme with the skin system
Module:RegisterTheme(ThunderStorm)