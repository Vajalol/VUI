-- VUI Skins Module - Core Functionality
local _, VUI = ...
local Skins = VUI.skins

-- Constants for skinning
local BACKDROP_TEMPLATE = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

-- Tables to manage skin functions
Skins.blizzardSkinFuncs = {}
Skins.addonSkinFuncs = {}

-- Tables for tracking skinned objects
Skins.pendingSkins = {}
Skins.skinnedFrames = {}
Skins.registeredSkins = {}
Skins.activeSkins = {}

-- Tables for hooked objects
Skins.hooked = {}

-- Forbidden frames (frames that should never be skinned)
Skins.forbiddenFrames = {
    ["CalendarCreateEventIcon"] = true,
    ["FriendsFrameIcon"] = true,
    ["MacroFramePortrait"] = true,
    ["QuestFrameDetailPanelBg"] = true,
    ["StaticPopup1AlertIcon"] = true,
    ["StaticPopup2AlertIcon"] = true,
    ["StaticPopup3AlertIcon"] = true,
    ["PVPReadyDialogBackground"] = true,
    ["LFGDungeonReadyDialogBackground"] = true,
}

-- Register a skin module
function Skins:RegisterSkin(name, category)
    local category = category or "Blizzard"
    local skin = {
        name = name,
        category = category,
        enabled = false,
        OnEnable = function() end,
        OnDisable = function() end,
        OnInitialize = function() end
    }
    
    self.registeredSkins[name] = skin
    
    -- Return the skin object for method chaining
    return skin
end

-- Initialize all registered skins
function Skins:InitializeSkins()
    VUI:Print("Initializing skins...")
    
    for name, skin in pairs(self.registeredSkins) do
        if type(skin.OnInitialize) == "function" then
            skin:OnInitialize()
        end
        
        -- Check if this skin should be enabled by default
        local category = skin.category:lower()
        local skinName = name:lower()
        
        if self.settings.skins[category] and self.settings.skins[category][skinName] then
            self:EnableSkin(name)
        end
    end
end

-- Enable a specific skin
function Skins:EnableSkin(name)
    local skin = self.registeredSkins[name]
    if not skin or skin.enabled then return end
    
    VUI:Print("Enabling skin: " .. name)
    
    -- Run the OnEnable function
    if type(skin.OnEnable) == "function" then
        skin:OnEnable()
    end
    
    skin.enabled = true
    self.activeSkins[name] = skin
end

-- Disable a specific skin
function Skins:DisableSkin(name)
    local skin = self.registeredSkins[name]
    if not skin or not skin.enabled then return end
    
    VUI:Print("Disabling skin: " .. name)
    
    -- Run the OnDisable function
    if type(skin.OnDisable) == "function" then
        skin:OnDisable()
    end
    
    skin.enabled = false
    self.activeSkins[name] = nil
end

-- Get a list of registered skins by category
function Skins:GetSkinsByCategory(category)
    local result = {}
    
    for name, skin in pairs(self.registeredSkins) do
        if skin.category == category then
            table.insert(result, skin)
        end
    end
    
    return result
end

-- Return pixel-perfect values
function Skins:GetPerfectPixelSize()
    local scale = UIParent:GetEffectiveScale()
    local screenWidth = GetScreenWidth() * scale
    local screenHeight = GetScreenHeight() * scale
    
    -- Get pixel size
    local pixelSize = 1.0
    if self.settings.advancedUI.usePixelPerfect then
        pixelSize = (768 / screenHeight)
    end
    
    return pixelSize
end

-- Get border size, adjusted for pixel-perfect if enabled
function Skins:GetBorderSize()
    local size = self.settings.style.borderSize
    if self.settings.advancedUI.usePixelPerfect then
        size = size * self:GetPerfectPixelSize()
    end
    return size
end

-- Get a color from our theme with optional alpha adjustment
function Skins:GetBackdropColor(alphaAdjust)
    local color = self.settings.style.backdropColor
    local alpha = color.a
    
    if alphaAdjust then
        alpha = alphaAdjust
    end
    
    return color.r, color.g, color.b, alpha
end

-- Get border color from our theme with optional alpha adjustment
function Skins:GetBorderColor(alphaAdjust)
    local color = self.settings.style.borderColor
    local alpha = color.a
    
    if alphaAdjust then
        alpha = alphaAdjust
    end
    
    return color.r, color.g, color.b, alpha
end

-- Get text color (slightly lighter than backdrop)
function Skins:GetTextColor(alphaAdjust)
    local color = self.settings.style.backdropColor
    local r = math.min(color.r + 0.3, 1.0)
    local g = math.min(color.g + 0.3, 1.0)
    local b = math.min(color.b + 0.3, 1.0)
    local alpha = color.a
    
    if alphaAdjust then
        alpha = alphaAdjust
    end
    
    return r, g, b, alpha
end

-- Get shadow size, adjusted for pixel-perfect if enabled
function Skins:GetShadowSize()
    local size = self.settings.style.shadowSize
    if self.settings.advancedUI.usePixelPerfect then
        size = size * self:GetPerfectPixelSize()
    end
    return size
end

-- Create skin for a frame
function Skins:SkinFrame(frame, options)
    -- Skip if disabled or already skinned
    if not self.enabled or not frame or frame.VUISkinned then return end
    
    -- Process options
    options = options or {}
    local noBorder = options.noBorder
    local noShadow = options.noShadow
    local forceSquare = options.forceSquare
    
    -- Mark as skinned
    frame.VUISkinned = true
    
    -- Save original backdrop for restoring later if needed
    if frame.GetBackdrop then
        frame.VUIOriginalBackdrop = frame:GetBackdrop()
    end
    
    -- Set up new backdrop
    local backdrop = CopyTable(BACKDROP_TEMPLATE)
    backdrop.edgeSize = self:GetBorderSize()
    
    if frame.SetBackdrop then
        frame:SetBackdrop(backdrop)
        
        -- Apply colors
        local backdropColor = self.settings.style.backdropColor
        local borderColor = self.settings.style.borderColor
        
        frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
        
        if not noBorder then
            frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        else
            frame:SetBackdropBorderColor(0, 0, 0, 0)
        end
    end
    
    -- Add shadow if enabled and not specifically disabled for this frame
    if self.settings.style.shadowSize > 0 and not noShadow then
        self:AddShadow(frame)
    end
    
    -- Force square corners if requested
    if forceSquare then
        self:MakeFrameSquare(frame)
    end
    
    -- Add to our list of skinned frames
    if not self.skinnedFrames[frame] then
        self.skinnedFrames[frame] = true
    end
    
    return frame
end

-- Create skin for a button
function Skins:SkinButton(button, options)
    -- Skip if disabled or already skinned
    if not self.enabled or not button or button.VUISkinned then return end
    
    -- Process options
    options = options or {}
    local noHighlight = options.noHighlight
    
    -- Mark as skinned
    button.VUISkinned = true
    
    -- Save original textures
    if not button.VUIOriginalNormalTexture and button:GetNormalTexture() then
        button.VUIOriginalNormalTexture = button:GetNormalTexture():GetTexture()
    end
    
    if not button.VUIOriginalPushedTexture and button:GetPushedTexture() then
        button.VUIOriginalPushedTexture = button:GetPushedTexture():GetTexture()
    end
    
    if not button.VUIOriginalDisabledTexture and button:GetDisabledTexture() then
        button.VUIOriginalDisabledTexture = button:GetDisabledTexture():GetTexture()
    end
    
    if not button.VUIOriginalHighlightTexture and button:GetHighlightTexture() then
        button.VUIOriginalHighlightTexture = button:GetHighlightTexture():GetTexture()
    end
    
    -- Create backdrop
    if not button.backdrop then
        local backdrop = CreateFrame("Frame", nil, button)
        backdrop:SetAllPoints()
        backdrop:SetFrameLevel(button:GetFrameLevel())
        
        local bdrop = CopyTable(BACKDROP_TEMPLATE)
        bdrop.edgeSize = self:GetBorderSize()
        
        backdrop:SetBackdrop(bdrop)
        
        -- Apply colors
        local backdropColor = self.settings.style.buttons.backdropColor
        local borderColor = self.settings.style.buttons.borderColor
        
        backdrop:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
        backdrop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        
        button.backdrop = backdrop
    end
    
    -- Apply button style
    if self.settings.style.buttonStyle == "gradient" then
        self:ApplyGradientStyle(button)
    elseif self.settings.style.buttonStyle == "flat" then
        self:ApplyFlatStyle(button)
    elseif self.settings.style.buttonStyle == "shadow" then
        self:ApplyShadowStyle(button)
    end
    
    -- Add highlight effect if not disabled
    if not noHighlight and self.settings.style.colorInteractive then
        if not self.hooked[button] then
            button:HookScript("OnEnter", function(b)
                if b.backdrop and not b:IsEnabled() then return end
                
                local hoverColor = self.settings.style.buttons.hoverColor
                if b.backdrop then
                    b.backdrop:SetBackdropColor(
                        hoverColor.r + 0.1,
                        hoverColor.g + 0.1,
                        hoverColor.b + 0.1,
                        hoverColor.a
                    )
                    
                    if self.settings.style.colorBorderInteractive then
                        b.backdrop:SetBackdropBorderColor(
                            hoverColor.r + 0.3,
                            hoverColor.g + 0.3,
                            hoverColor.b + 0.3,
                            1.0
                        )
                    end
                end
            end)
            
            button:HookScript("OnLeave", function(b)
                if b.backdrop and not b:IsEnabled() then return end
                
                local backdropColor = self.settings.style.buttons.backdropColor
                local borderColor = self.settings.style.buttons.borderColor
                
                if b.backdrop then
                    b.backdrop:SetBackdropColor(
                        backdropColor.r,
                        backdropColor.g,
                        backdropColor.b,
                        backdropColor.a
                    )
                    
                    b.backdrop:SetBackdropBorderColor(
                        borderColor.r,
                        borderColor.g,
                        borderColor.b,
                        borderColor.a
                    )
                end
            end)
            
            self.hooked[button] = true
        end
    end
    
    -- Apply font styling to button text
    if self.settings.advancedUI.customFonts and button:GetFontString() then
        self:SkinFontString(button:GetFontString())
    end
    
    -- Add to our list of skinned frames
    if not self.skinnedFrames[button] then
        self.skinnedFrames[button] = true
    end
    
    return button
end

-- Apply gradient style to button
function Skins:ApplyGradientStyle(button)
    -- Set textures
    button:SetNormalTexture("")
    button:SetPushedTexture("")
    button:SetDisabledTexture("")
    button:SetHighlightTexture("")
    
    -- Add gradient overlay
    if not button.gradientTexture then
        local gradient = button:CreateTexture(nil, "OVERLAY")
        gradient:SetPoint("TOPLEFT", 1, -1)
        gradient:SetPoint("BOTTOMRIGHT", -1, 1)
        gradient:SetTexture("Interface\\Buttons\\WHITE8x8")
        gradient:SetGradientAlpha("VERTICAL", 1, 1, 1, 0.1, 1, 1, 1, 0.3)
        gradient:SetBlendMode("ADD")
        
        button.gradientTexture = gradient
    end
end

-- Apply flat style to button
function Skins:ApplyFlatStyle(button)
    -- Set textures
    button:SetNormalTexture("")
    button:SetPushedTexture("")
    button:SetDisabledTexture("")
    button:SetHighlightTexture("")
    
    -- Make sure no gradient is added
    if button.gradientTexture then
        button.gradientTexture:Hide()
    end
end

-- Apply shadow style to button
function Skins:ApplyShadowStyle(button)
    -- Set textures
    button:SetNormalTexture("")
    button:SetPushedTexture("")
    button:SetDisabledTexture("")
    button:SetHighlightTexture("")
    
    -- Make sure no gradient is added
    if button.gradientTexture then
        button.gradientTexture:Hide()
    end
    
    -- Add shadow
    self:AddShadow(button)
end

-- Add shadow to frame
function Skins:AddShadow(frame)
    if not frame or frame.VUIShadow then return end
    
    local shadowSize = self:GetShadowSize()
    if shadowSize <= 0 then return end
    
    -- Create shadow frame
    local shadow = CreateFrame("Frame", nil, frame)
    shadow:SetFrameLevel(1)
    shadow:SetFrameStrata(frame:GetFrameStrata())
    shadow:SetPoint("TOPLEFT", -shadowSize, shadowSize)
    shadow:SetPoint("BOTTOMRIGHT", shadowSize, -shadowSize)
    shadow:SetBackdrop({
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\shadow",
        edgeSize = shadowSize,
    })
    shadow:SetBackdropBorderColor(0, 0, 0, self.settings.style.shadowOverlayAlpha)
    
    frame.VUIShadow = shadow
end

-- Make frame square (remove rounded corners)
function Skins:MakeFrameSquare(frame)
    if frame.SetCornerSize then
        frame:SetCornerSize(0)
    end
end

-- Skin a font string
function Skins:SkinFontString(fontString)
    if not fontString or not self.settings.advancedUI.customFonts then return end
    
    local font = self:GetFont()
    local fontSize = self.settings.advancedUI.fontSize
    local fontFlags = self.settings.advancedUI.fontFlags
    
    fontString:SetFont(font, fontSize, fontFlags)
    
    return fontString
end

-- Get the font to use
function Skins:GetFont()
    local fontPath = "Fonts\\FRIZQT__.TTF" -- Default WoW font
    local fontName = self.settings.advancedUI.fontName or "Friz Quadrata TT"
    
    if VUI.media and VUI.media.fonts and VUI.media.fonts[fontName] then
        fontPath = VUI.media.fonts[fontName]
    end
    
    return fontPath
end

-- Skin a scroll bar
function Skins:SkinScrollBar(scrollBar)
    if not scrollBar or scrollBar.VUISkinned then return end
    
    scrollBar.VUISkinned = true
    
    -- Skin the scrollbar background
    if scrollBar.Background then
        scrollBar.Background:SetTexture("")
    end
    
    -- Skin the track
    if scrollBar.Track then
        self:SkinFrame(scrollBar.Track, {noBorder = true})
    end
    
    -- Skin the thumb
    if scrollBar.Thumb then
        self:SkinFrame(scrollBar.Thumb)
        
        -- Add highlight effect
        if self.settings.style.colorInteractive then
            if not self.hooked[scrollBar.Thumb] then
                scrollBar.Thumb:HookScript("OnEnter", function(thumb)
                    local hoverColor = self.settings.style.buttons.hoverColor
                    thumb:SetBackdropColor(
                        hoverColor.r + 0.1,
                        hoverColor.g + 0.1,
                        hoverColor.b + 0.1,
                        hoverColor.a
                    )
                end)
                
                scrollBar.Thumb:HookScript("OnLeave", function(thumb)
                    local backdropColor = self.settings.style.backdropColor
                    thumb:SetBackdropColor(
                        backdropColor.r,
                        backdropColor.g,
                        backdropColor.b,
                        backdropColor.a
                    )
                end)
                
                self.hooked[scrollBar.Thumb] = true
            end
        end
    end
    
    -- Skin up/down buttons
    if scrollBar.ScrollUpButton then
        self:SkinButton(scrollBar.ScrollUpButton)
    end
    
    if scrollBar.ScrollDownButton then
        self:SkinButton(scrollBar.ScrollDownButton)
    end
    
    return scrollBar
end

-- Skin a check button
function Skins:SkinCheckButton(checkButton)
    if not checkButton or checkButton.VUISkinned then return end
    
    checkButton.VUISkinned = true
    
    -- Save original textures
    checkButton.VUIOriginalNormalTexture = checkButton:GetNormalTexture():GetTexture()
    
    -- Apply backdrop
    self:SkinFrame(checkButton)
    
    -- Set up the check texture
    local check = checkButton:CreateTexture(nil, "OVERLAY")
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetPoint("CENTER")
    check:SetSize(14, 14)
    check:Hide()
    
    checkButton.VUICheckTexture = check
    
    -- Hook to update the check visibility
    if not self.hooked[checkButton] then
        checkButton:HookScript("OnClick", function(self)
            if self:GetChecked() then
                self.VUICheckTexture:Show()
            else
                self.VUICheckTexture:Hide()
            end
        end)
        
        self.hooked[checkButton] = true
    end
    
    -- Set initial state
    if checkButton:GetChecked() then
        checkButton.VUICheckTexture:Show()
    else
        checkButton.VUICheckTexture:Hide()
    end
    
    return checkButton
end

-- Skin a dropdown menu
function Skins:SkinDropDownMenu(dropdown)
    if not dropdown or dropdown.VUISkinned then return end
    
    dropdown.VUISkinned = true
    
    -- Skin the menu backdrop
    local backdrop = _G[dropdown:GetName().."MenuBackdrop"]
    if backdrop then
        self:SkinFrame(backdrop)
    end
    
    -- Skin the button
    local button = _G[dropdown:GetName().."Button"]
    if button then
        self:SkinButton(button)
    end
    
    -- Skin the dropdown text
    local text = _G[dropdown:GetName().."Text"]
    if text and self.settings.advancedUI.customFonts then
        self:SkinFontString(text)
    end
    
    return dropdown
end

-- Skin a tab button
function Skins:SkinTab(tab)
    if not tab or tab.VUISkinned then return end
    
    tab.VUISkinned = true
    
    -- Skin the tab like a button
    self:SkinButton(tab)
    
    -- Modify the selected texture
    if tab.GetHighlightTexture and tab:GetHighlightTexture() then
        tab:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
        tab:GetHighlightTexture():SetBlendMode("ADD")
    end
    
    return tab
end

-- Skin a slider
function Skins:SkinSlider(slider)
    if not slider or slider.VUISkinned then return end
    
    slider.VUISkinned = true
    
    -- Skin the slider backdrop
    self:SkinFrame(slider, {noBorder = true})
    
    -- Skin the thumb texture
    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
        thumb:SetSize(16, 16)
    end
    
    return slider
end

-- Skin an edit box
function Skins:SkinEditBox(editBox)
    if not editBox or editBox.VUISkinned then return end
    
    editBox.VUISkinned = true
    
    -- Skin the edit box
    self:SkinFrame(editBox)
    
    -- Skin the text
    if self.settings.advancedUI.customFonts then
        self:SkinFontString(editBox:GetFontString())
    end
    
    return editBox
end

-- Register a Blizzard UI skinning function
function Skins:RegisterBlizzardSkin(name, func)
    if type(func) ~= "function" then return end
    
    self.blizzardSkinFuncs[name] = func
end

-- Register an addon skinning function
function Skins:RegisterAddonSkin(name, func)
    if type(func) ~= "function" then return end
    
    self.addonSkinFuncs[name] = func
end

-- Get a list of all registered Blizzard skins
function Skins:GetRegisteredBlizzardSkins()
    local skins = {}
    
    for name, _ in pairs(self.blizzardSkinFuncs) do
        table.insert(skins, name)
    end
    
    return skins
end

-- Get a list of all registered addon skins
function Skins:GetRegisteredAddonSkins()
    local skins = {}
    
    for name, _ in pairs(self.addonSkinFuncs) do
        table.insert(skins, name)
    end
    
    return skins
end

-- Register a skin module
function Skins:RegisterSkin(name)
    local skinModule = {}
    skinModule.name = name
    
    -- Register this skin with our system
    self:RegisterBlizzardSkin(name, function()
        if skinModule.OnEnable then
            skinModule:OnEnable()
        end
    end)
    
    return skinModule
end

-- Register an addon skin module
function Skins:RegisterAddonSkin(name)
    local skinModule = {}
    skinModule.name = name
    
    -- Register this skin with our system
    self:RegisterAddonSkin(name, function()
        if skinModule.OnEnable then
            skinModule:OnEnable()
        end
    end)
    
    return skinModule
end

-- Load all Blizzard UI skins
function Skins:LoadBlizzardSkins()
    for name, func in pairs(self.blizzardSkinFuncs) do
        if self.settings.skins.blizzard.enabled and func then
            func()
        end
    end
end

-- Load all addon skins
function Skins:LoadAddonSkins()
    for name, func in pairs(self.addonSkinFuncs) do
        if self.settings.skins.addons.enabled and func then
            func()
        end
    end
end

-- Initialize the skins module
function Skins:Initialize()
    -- Initialize tables
    self.skinnedFrames = {}
    self.blizzardSkinFuncs = {}
    self.addonSkinFuncs = {}
    self.hooked = {}
    
    -- Load default settings if needed
    if not self.settings then
        self.settings = {
            enabled = true,
            skins = {
                blizzard = {
                    enabled = true,
                    actionbar = true,
                    bags = true,
                    unitframes = true,
                    portraitStyles = true,
                    portraitStyle = "DEFAULT" -- Options: DEFAULT, FLAT, TRANSPARENT
                },
                addons = {
                    enabled = true,
                    bartender = true,
                    classicui = true
                }
            },
            style = {
                backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
                borderColor = {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
                borderSize = 1,
                shadowSize = 3,
                colorInteractive = true,
                statusbarTexture = "Interface\\AddOns\\VUI\\media\\textures\\statusbar-smooth.blp",
                buttons = {
                    normalColor = {r = 0.3, g = 0.3, b = 0.3, a = 1.0},
                    hoverColor = {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
                    pressedColor = {r = 0.2, g = 0.2, b = 0.2, a = 1.0}
                }
            },
            advancedUI = {
                usePixelPerfect = true,
                customFonts = true
            }
        }
    end
    
    -- Delay loading skins until player enters world
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            Skins:LoadBlizzardSkins()
            Skins:LoadAddonSkins()
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    end)
    
    self.enabled = true
end