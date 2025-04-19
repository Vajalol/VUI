-- VUI Phoenix Flame Theme
local _, VUI = ...
local Skins = VUI:GetModule('skins')
local PhoenixFlame = {}

-- Theme registration with the skins module
Skins.themes = Skins.themes or {}
Skins.themes.phoenixflame = PhoenixFlame

-- Theme metadata
PhoenixFlame.name = "Phoenix Flame"
PhoenixFlame.description = "A fiery theme inspired by the phoenix, with warm colors and flame effects"
PhoenixFlame.author = "VortexQ8"
PhoenixFlame.version = "1.0"

-- Color scheme
PhoenixFlame.colors = {
    background = {r = 0.1, g = 0.04, b = 0.02, a = 0.9}, -- Dark red/brown
    border = {r = 0.9, g = 0.3, b = 0.05, a = 1.0}, -- Fiery orange
    highlight = {r = 1.0, g = 0.64, b = 0.1, a = 0.8}, -- Amber
    text = {r = 1.0, g = 0.96, b = 0.85, a = 1.0}, -- Cream
    shadow = {r = 0.0, g = 0.0, b = 0.0, a = 0.75}, -- Dark shadow
    glow = {r = 1.0, g = 0.5, b = 0.1, a = 0.6}, -- Orange glow
}

-- Theme textures
PhoenixFlame.textures = {
    -- Base textures
    background = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\background.tga",
    border = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga",
    shadow = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\shadow.tga",
    glow = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga",
    
    -- UI element textures
    dropdown = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\dropdown.tga",
    slider = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\slider.tga",
    tab = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\tab.tga",
    character = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\character.tga",
    spellbook = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\spellbook.tga",
    
    -- Special effects
    embers = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\embers.tga",
    ash = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\ash.tga",
    smoke = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\smoke.tga",
    
    -- State textures
    hover = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\hover.tga",
    pressed = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\pressed.tga",
    disabled = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\disabled.tga",
    
    -- Animation frames
    animationFrames = {
        "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame1.tga",
        "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame2.tga",
        "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame3.tga",
    }
}

-- Font configuration
PhoenixFlame.fonts = {
    normal = "InterBold",
    header = "GothamNarrow-Black",
    tooltip = "Expressway",
    chat = "MyriadWebBold"
}

-- Animation settings
PhoenixFlame.animations = {
    -- Border glow animation
    borderGlow = {
        duration = 1.5,
        minAlpha = 0.3,
        maxAlpha = 0.7,
        smoothing = "IN_OUT",
        enabled = true,
    },
    
    -- Flame animation
    flame = {
        duration = 0.8, -- Time for a complete animation cycle
        frameCount = 3, -- Number of animation frames
        frameDelay = 0.2, -- Delay between frames
        enabled = true,
    },
    
    -- Ember particles animation
    embers = {
        particleCount = 5, -- Number of ember particles
        minSize = 5, -- Minimum particle size
        maxSize = 12, -- Maximum particle size
        minDuration = 2.0, -- Minimum animation duration
        maxDuration = 4.0, -- Maximum animation duration
        fadeInTime = 0.5, -- Fade-in time
        fadeOutTime = 1.0, -- Fade-out time
        enabled = true,
    }
}

-- Apply the theme to a frame
function PhoenixFlame:ApplyToFrame(frame, options)
    options = options or {}
    
    -- Default options
    options.withBorder = options.withBorder ~= false
    options.withBackground = options.withBackground ~= false
    options.withShadow = options.withShadow ~= false
    options.withAnimation = options.withAnimation == true
    
    -- Create backdrop if it doesn't exist
    if not frame.backdrop then
        frame.backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.backdrop:SetAllPoints()
        frame.backdrop:SetFrameLevel(frame:GetFrameLevel())
    end
    
    -- Apply background
    if options.withBackground then
        frame.backdrop:SetBackdrop({
            bgFile = self.textures.background,
            insets = {left = 3, right = 3, top = 3, bottom = 3}
        })
        local bg = self.colors.background
        frame.backdrop:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
    end
    
    -- Apply border
    if options.withBorder then
        if not frame.backdrop.border then
            frame.backdrop.border = CreateFrame("Frame", nil, frame.backdrop, "BackdropTemplate")
            frame.backdrop.border:SetAllPoints()
            frame.backdrop.border:SetFrameLevel(frame.backdrop:GetFrameLevel() + 1)
        end
        
        frame.backdrop.border:SetBackdrop({
            edgeFile = self.textures.border,
            edgeSize = 3,
        })
        
        local border = self.colors.border
        frame.backdrop.border:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
    end
    
    -- Apply shadow
    if options.withShadow then
        if not frame.backdrop.shadow then
            frame.backdrop.shadow = CreateFrame("Frame", nil, frame.backdrop, "BackdropTemplate")
            frame.backdrop.shadow:SetFrameLevel(frame.backdrop:GetFrameLevel() - 1)
            frame.backdrop.shadow:SetAllPoints(frame)
            frame.backdrop.shadow:SetScale(1.05)
        end
        
        frame.backdrop.shadow:SetBackdrop({
            edgeFile = self.textures.shadow,
            edgeSize = 4,
        })
        
        local shadow = self.colors.shadow
        frame.backdrop.shadow:SetBackdropBorderColor(shadow.r, shadow.g, shadow.b, shadow.a)
    end
    
    -- Apply flame animations
    if options.withAnimation and self.animations.flame.enabled then
        if not frame.flameAnimation then
            -- Animation container
            frame.flameAnimation = CreateFrame("Frame", nil, frame)
            frame.flameAnimation:SetFrameLevel(frame:GetFrameLevel() + 2)
            frame.flameAnimation:SetAllPoints(frame)
            
            -- Animation textures
            frame.flameAnimation.textures = {}
            for i = 1, self.animations.flame.frameCount do
                local tex = frame.flameAnimation:CreateTexture(nil, "OVERLAY")
                tex:SetAllPoints()
                tex:SetTexture(self.textures.animationFrames[i])
                tex:SetBlendMode("ADD")
                tex:SetAlpha(0)
                frame.flameAnimation.textures[i] = tex
            end
            
            -- Animation group
            frame.flameAnimation.group = frame.flameAnimation:CreateAnimationGroup()
            frame.flameAnimation.group:SetLooping("REPEAT")
            
            -- Create animation sequence
            local frameDelay = self.animations.flame.frameDelay
            local frameDuration = self.animations.flame.duration / self.animations.flame.frameCount
            
            for i = 1, self.animations.flame.frameCount do
                -- Fade in
                local fadeIn = frame.flameAnimation.group:CreateAnimation("Alpha")
                fadeIn:SetTarget(frame.flameAnimation.textures[i])
                fadeIn:SetOrder(i * 2 - 1)
                fadeIn:SetFromAlpha(0)
                fadeIn:SetToAlpha(0.7)
                fadeIn:SetDuration(frameDuration / 2)
                
                -- Fade out
                local fadeOut = frame.flameAnimation.group:CreateAnimation("Alpha")
                fadeOut:SetTarget(frame.flameAnimation.textures[i])
                fadeOut:SetOrder(i * 2)
                fadeOut:SetFromAlpha(0.7)
                fadeOut:SetToAlpha(0)
                fadeOut:SetDuration(frameDuration / 2)
                fadeOut:SetStartDelay(frameDelay)
            end
            
            -- Start the animation
            frame.flameAnimation.group:Play()
        end
    end
    
    -- Return the modified frame
    return frame
end

-- Helper function to create Phoenix Flame style buttons
function PhoenixFlame:CreateButton(parent, name, text, width, height)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, height or 22)
    button:SetText(text or "Button")
    
    -- Apply the Phoenix Flame theme to the button
    self:ApplyToFrame(button, {withShadow = true})
    
    -- Set text color
    local textColor = self.colors.text
    button:SetNormalFontObject("GameFontNormal")
    button.Text:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    
    -- Button textures for states
    button:SetNormalTexture(self.textures.background)
    button:SetHighlightTexture(self.textures.hover)
    button:SetPushedTexture(self.textures.pressed)
    button:SetDisabledTexture(self.textures.disabled)
    
    -- State colors
    local normalTex = button:GetNormalTexture()
    local bg = self.colors.background
    normalTex:SetVertexColor(bg.r, bg.g, bg.b, bg.a)
    
    local highlightTex = button:GetHighlightTexture()
    local highlight = self.colors.highlight
    highlightTex:SetVertexColor(highlight.r, highlight.g, highlight.b, highlight.a)
    highlightTex:SetBlendMode("ADD")
    
    local pushedTex = button:GetPushedTexture()
    pushedTex:SetVertexColor(bg.r * 0.7, bg.g * 0.7, bg.b * 0.7, bg.a)
    
    local disabledTex = button:GetDisabledTexture()
    disabledTex:SetVertexColor(bg.r * 0.5, bg.g * 0.5, bg.b * 0.5, bg.a)
    
    return button
end

-- Helper function to create themed checkboxes
function PhoenixFlame:CreateCheckbox(parent, name, text, initialValue)
    local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    
    -- Apply Phoenix Flame theme
    self:ApplyToFrame(checkbox, {withBorder = false, withBackground = false})
    
    -- Set the checkbox text
    _G[checkbox:GetName() .. "Text"]:SetText(text)
    local textColor = self.colors.text
    _G[checkbox:GetName() .. "Text"]:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    
    -- Set initial state
    checkbox:SetChecked(initialValue or false)
    
    -- Hook state changes to update appearance
    checkbox:HookScript("OnClick", function(self)
        -- Additional theme effects can be added here
    end)
    
    return checkbox
end

-- Helper function to create themed sliders
function PhoenixFlame:CreateSlider(parent, name, text, min, max, step, initialValue)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetWidth(150)
    slider:SetMinMaxValues(min or 0, max or 100)
    slider:SetValue(initialValue or min or 0)
    slider:SetValueStep(step or 1)
    
    -- Apply theme to slider
    self:ApplyToFrame(slider, {withBackground = false})
    
    -- Set labels
    _G[slider:GetName() .. "Text"]:SetText(text)
    _G[slider:GetName() .. "Low"]:SetText(min or 0)
    _G[slider:GetName() .. "High"]:SetText(max or 100)
    
    -- Set text colors
    local textColor = self.colors.text
    _G[slider:GetName() .. "Text"]:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    _G[slider:GetName() .. "Low"]:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    _G[slider:GetName() .. "High"]:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    
    -- Set slider texture
    slider:SetThumbTexture(self.textures.slider)
    local thumbTex = slider:GetThumbTexture()
    local highlight = self.colors.highlight
    thumbTex:SetVertexColor(highlight.r, highlight.g, highlight.b, highlight.a)
    
    return slider
end

-- Register theme as a skin option
Skins:RegisterTheme("phoenixflame", PhoenixFlame.name, PhoenixFlame.description)

-- Return the theme
return PhoenixFlame