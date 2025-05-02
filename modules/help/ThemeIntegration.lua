--[[
    VUI - Help System Theme Integration
    Version: 0.3.0
    Author: VortexQ8
]]

local addonName, VUI = ...

-- Early return if module doesn't exist
if not VUI.modules or not VUI.modules.help then return end

-- Create theme integration for Help module
VUI.modules.help.ThemeIntegration = {}
local ThemeIntegration = VUI.modules.help.ThemeIntegration
local Help = VUI.modules.help

-- Initialize theme integration
function ThemeIntegration:Initialize()
    -- Register for theme change callback
    VUI:RegisterCallback("ThemeChanged", function()
        self:ApplyTheme()
    end)
    
    -- Apply initial theme
    self:ApplyTheme()
end

-- Apply current theme to Help UI elements
function ThemeIntegration:ApplyTheme()
    local theme = VUI.db.profile.theme or "thunderstorm"
    local colors = VUI.media.themes[theme] or {}
    
    -- Apply theme to welcome frame if it exists
    if Help.welcomeFrame then
        Help.welcomeFrame:SetBackdrop({
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
            tile = false,
            tileSize = 0,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        if colors.background then
            Help.welcomeFrame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
        else
            Help.welcomeFrame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
        end
        
        if colors.border then
            Help.welcomeFrame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
        else
            Help.welcomeFrame:SetBackdropBorderColor(0, 0.6, 1, 1)
        end
        
        -- Find and update the close button
        local closeButton = Help.welcomeFrame:GetChildren()
        for i=1, select("#", closeButton) do
            local child = select(i, closeButton)
            if child:GetObjectType() == "Button" and child:GetText() == "Get Started" then
                -- Apply theme to button
                if VUI.ApplyThemeToButton then
                    VUI.ApplyThemeToButton(child, theme)
                end
            end
        end
    end
    
    -- Apply theme to help buttons (if we've created any)
    if Help.helpButtons then
        for frame, button in pairs(Help.helpButtons) do
            if button and button:GetObjectType() == "Button" then
                local icon = button:GetRegions()
                if icon and icon:GetObjectType() == "Texture" then
                    icon:SetVertexColor(colors.highlight.r, colors.highlight.g, colors.highlight.b)
                end
            end
        end
    end
    
    -- When creating feature-specific help UIs that need theming
    -- add theme application for those UI elements here
end

-- Create a themed help frame (for more complex help displays)
function ThemeIntegration:CreateHelpFrame(title, content, width, height)
    local theme = VUI.db.profile.theme or "thunderstorm"
    local colors = VUI.media.themes[theme] or {}
    
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(width or 400, height or 300)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetFrameStrata("DIALOG")
    
    -- Apply theme
    frame:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    if colors.background then
        frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
    else
        frame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
    end
    
    if colors.border then
        frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    else
        frame:SetBackdropBorderColor(0, 0.6, 1, 1)
    end
    
    -- Title
    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOP", frame, "TOP", 0, -15)
    titleText:SetText(title)
    
    -- Set title color based on theme
    if colors.highlight then
        titleText:SetTextColor(colors.highlight.r, colors.highlight.g, colors.highlight.b)
    end
    
    -- Content
    local contentText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
    contentText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 50)
    contentText:SetJustifyH("LEFT")
    contentText:SetJustifyV("TOP")
    contentText:SetText(content)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 25)
    closeButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Apply theme to button
    if VUI.ApplyThemeToButton then
        VUI.ApplyThemeToButton(closeButton, theme)
    end
    
    return frame
end

-- Track help buttons we create
Help.helpButtons = Help.helpButtons or {}

-- Enhanced version of AddHelpButton that uses themed buttons
function ThemeIntegration:AddHelpButton(frame, helpTopic)
    if not frame or not helpTopic then return end
    
    local theme = VUI.db.profile.theme or "thunderstorm"
    local colors = VUI.media.themes[theme] or {}
    
    local helpButton = CreateFrame("Button", nil, frame)
    helpButton:SetSize(16, 16)
    helpButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    local icon = helpButton:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\help-icon.tga")
    
    -- Apply theme color to icon
    if colors.highlight then
        icon:SetVertexColor(colors.highlight.r, colors.highlight.g, colors.highlight.b)
    end
    
    helpButton:SetScript("OnClick", function()
        if Help.helpContent.modules[helpTopic] then
            Help:ShowModuleHelp(helpTopic)
        elseif Help.helpContent.features[helpTopic] then
            Help:ShowFeatureHelp(helpTopic)
        else
            Help:ShowGeneralHelp()
        end
    end)
    
    helpButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click for help", nil, nil, nil, nil, true)
        GameTooltip:Show()
        
        -- Apply hover effect
        icon:SetVertexColor(1, 1, 1)
    end)
    
    helpButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        
        -- Restore theme color
        if colors.highlight then
            icon:SetVertexColor(colors.highlight.r, colors.highlight.g, colors.highlight.b)
        end
    end)
    
    -- Store the button for theme updates
    Help.helpButtons[frame] = helpButton
    
    return helpButton
end

-- Replace the original AddHelpButton with our themed version
Help.AddHelpButton = function(self, frame, helpTopic)
    return ThemeIntegration:AddHelpButton(frame, helpTopic)
end