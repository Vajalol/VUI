local ThemePreview = VUI:NewModule('Config.Components.ThemePreview')

-- Local references
local Colors = VUI:GetModule('Data.Colors')
local VUIConfig = VUI.Libs.VUIConfig

local ICON_SIZE = 32
local PREVIEW_WIDTH = 180
local PREVIEW_HEIGHT = 100
local SPACING = 10

--[[
  This component creates theme preview items to display in the General settings tab
  Each preview shows the theme's color scheme and provides a visual representation
--]]
function ThemePreview:Create(parent, themeData, currentTheme, onThemeSelect)
    -- Create container frame
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(PREVIEW_WIDTH * 3 + SPACING * 2, PREVIEW_HEIGHT * 2 + SPACING)
    
    -- Track created previews for layout
    local previewFrames = {}
    local row = 1
    local col = 0
    
    -- Create preview for each theme
    for i, theme in ipairs(themeData) do
        col = col + 1
        if col > 3 then
            col = 1
            row = row + 1
        end
        
        local preview = self:CreateThemePreview(container, theme)
        preview:SetPoint("TOPLEFT", container, "TOPLEFT", 
            (col-1) * (PREVIEW_WIDTH + SPACING), 
            -(row-1) * (PREVIEW_HEIGHT + SPACING))
        
        -- Highlight current theme
        if theme.value == currentTheme then
            preview.selected = true
            preview.border:SetColorTexture(1, 1, 1, 0.8)
            -- Create check mark icon on selected theme
            local check = preview:CreateTexture(nil, "OVERLAY")
            check:SetSize(24, 24)
            check:SetPoint("TOPRIGHT", -5, -5)
            check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            preview.checkMark = check
        end
        
        -- Add click handling 
        preview:SetScript("OnMouseDown", function()
            -- Call selection callback
            if onThemeSelect and not preview.selected then
                onThemeSelect(theme.value)
            end
        end)
        
        -- Add hover effect
        preview:SetScript("OnEnter", function()
            if not preview.selected then
                preview.border:SetColorTexture(0.8, 0.8, 0.8, 0.4)
            end
            preview.highlight:Show()
        end)
        
        preview:SetScript("OnLeave", function()
            if not preview.selected then
                preview.border:SetColorTexture(0.4, 0.4, 0.4, 0.3)
            end
            preview.highlight:Hide()
        end)
        
        table.insert(previewFrames, preview)
    end
    
    -- Add instructions text
    local instructions = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    instructions:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, -20)
    instructions:SetText("|cffBBBBBBClick a theme to apply it. Changes take effect immediately.|r")
    
    return container
end

-- Create a preview frame for a specific theme
function ThemePreview:CreateThemePreview(parent, theme)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(PREVIEW_WIDTH, PREVIEW_HEIGHT)
    frame:EnableMouse(true)
    
    -- Add border
    local border = frame:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints(frame)
    border:SetColorTexture(0.4, 0.4, 0.4, 0.3)
    frame.border = border
    
    -- Add highlight for hover
    local highlight = frame:CreateTexture(nil, "BORDER")
    highlight:SetAllPoints(frame)
    highlight:SetColorTexture(1, 1, 1, 0.1)
    highlight:Hide()
    frame.highlight = highlight
    
    -- Add background with theme color
    local bg = frame:CreateTexture(nil, "BORDER")
    bg:SetPoint("TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", -1, 1)
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
    
    -- Add theme name
    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOP", 0, -10)
    name:SetText(theme.text)
    frame.name = name
    
    -- Style based on theme type
    if theme.value == "VUI" then
        self:StyleVUITheme(frame, name)
    elseif theme.value == "PhoenixFlame" then
        self:StylePhoenixFlame(frame, name)
    elseif theme.value == "FelEnergy" then
        self:StyleFelEnergy(frame, name)
    elseif theme.value == "ArcaneMystic" then
        self:StyleArcaneMystic(frame, name)
    elseif theme.value == "Class" then
        self:StyleClassTheme(frame, name)
    elseif theme.value == "Dark" then
        self:StyleDarkTheme(frame, name)
    elseif theme.value == "Blizzard" then
        self:StyleBlizzardTheme(frame, name)
    elseif theme.value == "Custom" then
        self:StyleCustomTheme(frame, name)
    end
    
    -- Add icon for themed preview items
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("CENTER", frame, "CENTER", 0, 10)
    
    -- Set icon based on theme
    if theme.value == "VUI" then
        icon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm.tga")
    elseif theme.value == "PhoenixFlame" then
        icon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_phoenixflame.svg")
    elseif theme.value == "FelEnergy" then
        icon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_felenergy.svg")
    elseif theme.value == "ArcaneMystic" then
        icon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_arcanemystic.svg")
    else
        icon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex.svg")
    end
    
    frame.icon = icon
    
    -- Add example button
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(100, 22)
    button:SetPoint("BOTTOM", 0, 10)
    button:SetText("Example Button")
    
    -- Style button based on theme
    if theme.value == "VUI" then
        button.Left:SetVertexColor(0.05, 0.61, 0.9)
        button.Right:SetVertexColor(0.05, 0.61, 0.9)
        button.Middle:SetVertexColor(0.05, 0.61, 0.9)
        button:SetNormalFontObject("GameFontHighlight")
    elseif theme.value == "PhoenixFlame" then
        button.Left:SetVertexColor(0.90, 0.30, 0.05)
        button.Right:SetVertexColor(0.90, 0.30, 0.05)
        button.Middle:SetVertexColor(0.90, 0.30, 0.05)
        button:SetNormalFontObject("GameFontHighlight")
    elseif theme.value == "FelEnergy" then
        button.Left:SetVertexColor(0.10, 0.80, 0.10)
        button.Right:SetVertexColor(0.10, 0.80, 0.10)
        button.Middle:SetVertexColor(0.10, 0.80, 0.10)
        button:SetNormalFontObject("GameFontHighlight")
    elseif theme.value == "ArcaneMystic" then
        button.Left:SetVertexColor(0.62, 0.05, 0.90)
        button.Right:SetVertexColor(0.62, 0.05, 0.90)
        button.Middle:SetVertexColor(0.62, 0.05, 0.90)
        button:SetNormalFontObject("GameFontHighlight")
    end
    
    return frame
end

-- Style methods for each theme
function ThemePreview:StyleVUITheme(frame, nameText)
    -- VUI blue gradients
    nameText:SetTextColor(0.05, 0.61, 0.9) -- VUI blue
    
    -- Create gradient overlay
    local gradient = frame:CreateTexture(nil, "ARTWORK")
    gradient:SetPoint("TOPLEFT", 2, -2)
    gradient:SetPoint("BOTTOMRIGHT", -2, 2)
    gradient:SetColorTexture(0.05, 0.61, 0.9, 0.1)
    
    -- Create pulse animation
    local ag = gradient:CreateAnimationGroup()
    ag:SetLooping("REPEAT")
    
    local alpha1 = ag:CreateAnimation("Alpha")
    alpha1:SetFromAlpha(0.1)
    alpha1:SetToAlpha(0.2)
    alpha1:SetDuration(1.5)
    alpha1:SetOrder(1)
    
    local alpha2 = ag:CreateAnimation("Alpha")
    alpha2:SetFromAlpha(0.2)
    alpha2:SetToAlpha(0.1)
    alpha2:SetDuration(1.5)
    alpha2:SetOrder(2)
    
    ag:Play()
end

function ThemePreview:StylePhoenixFlame(frame, nameText)
    nameText:SetTextColor(0.90, 0.30, 0.05) -- Phoenix Flame
    
    -- Create gradient overlay
    local gradient = frame:CreateTexture(nil, "ARTWORK")
    gradient:SetPoint("TOPLEFT", 2, -2)
    gradient:SetPoint("BOTTOMRIGHT", -2, 2)
    gradient:SetColorTexture(0.90, 0.30, 0.05, 0.1)
    
    -- Create pulse animation
    local ag = gradient:CreateAnimationGroup()
    ag:SetLooping("REPEAT")
    
    local alpha1 = ag:CreateAnimation("Alpha")
    alpha1:SetFromAlpha(0.1)
    alpha1:SetToAlpha(0.2)
    alpha1:SetDuration(1.5)
    alpha1:SetOrder(1)
    
    local alpha2 = ag:CreateAnimation("Alpha")
    alpha2:SetFromAlpha(0.2)
    alpha2:SetToAlpha(0.1)
    alpha2:SetDuration(1.5)
    alpha2:SetOrder(2)
    
    ag:Play()
end

function ThemePreview:StyleFelEnergy(frame, nameText)
    nameText:SetTextColor(0.10, 0.80, 0.10) -- Fel Energy
    
    -- Create gradient overlay
    local gradient = frame:CreateTexture(nil, "ARTWORK")
    gradient:SetPoint("TOPLEFT", 2, -2)
    gradient:SetPoint("BOTTOMRIGHT", -2, 2)
    gradient:SetColorTexture(0.10, 0.80, 0.10, 0.1)
    
    -- Create pulse animation
    local ag = gradient:CreateAnimationGroup()
    ag:SetLooping("REPEAT")
    
    local alpha1 = ag:CreateAnimation("Alpha")
    alpha1:SetFromAlpha(0.1)
    alpha1:SetToAlpha(0.2)
    alpha1:SetDuration(1.5)
    alpha1:SetOrder(1)
    
    local alpha2 = ag:CreateAnimation("Alpha")
    alpha2:SetFromAlpha(0.2)
    alpha2:SetToAlpha(0.1)
    alpha2:SetDuration(1.5)
    alpha2:SetOrder(2)
    
    ag:Play()
end

function ThemePreview:StyleArcaneMystic(frame, nameText)
    nameText:SetTextColor(0.62, 0.05, 0.90) -- Arcane Mystic
    
    -- Create gradient overlay
    local gradient = frame:CreateTexture(nil, "ARTWORK")
    gradient:SetPoint("TOPLEFT", 2, -2)
    gradient:SetPoint("BOTTOMRIGHT", -2, 2)
    gradient:SetColorTexture(0.62, 0.05, 0.90, 0.1)
    
    -- Create pulse animation
    local ag = gradient:CreateAnimationGroup()
    ag:SetLooping("REPEAT")
    
    local alpha1 = ag:CreateAnimation("Alpha")
    alpha1:SetFromAlpha(0.1)
    alpha1:SetToAlpha(0.2)
    alpha1:SetDuration(1.5)
    alpha1:SetOrder(1)
    
    local alpha2 = ag:CreateAnimation("Alpha")
    alpha2:SetFromAlpha(0.2)
    alpha2:SetToAlpha(0.1)
    alpha2:SetDuration(1.5)
    alpha2:SetOrder(2)
    
    ag:Play()
end

function ThemePreview:StyleClassTheme(frame, nameText)
    -- Get player class color
    local _, class = UnitClass("player")
    local r, g, b = GetClassColor(class)
    
    nameText:SetTextColor(r, g, b)
    
    -- Create simple color accent
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetSize(PREVIEW_WIDTH - 4, 3)
    accent:SetPoint("TOP", frame, "TOP", 0, -30)
    accent:SetColorTexture(r, g, b, 0.7)
end

function ThemePreview:StyleDarkTheme(frame, nameText)
    nameText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Create dark top accent
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetSize(PREVIEW_WIDTH - 4, 3)
    accent:SetPoint("TOP", frame, "TOP", 0, -30)
    accent:SetColorTexture(0.3, 0.3, 0.3, 0.7)
end

function ThemePreview:StyleBlizzardTheme(frame, nameText)
    nameText:SetTextColor(1, 0.8, 0)
    
    -- Create blizzard gold accent
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetSize(PREVIEW_WIDTH - 4, 3)
    accent:SetPoint("TOP", frame, "TOP", 0, -30)
    accent:SetColorTexture(1, 0.8, 0, 0.7)
end

function ThemePreview:StyleCustomTheme(frame, nameText)
    nameText:SetTextColor(1, 1, 1)
    
    -- Get the custom color from VUI settings
    local customColor = VUI.db.profile.general.color
    local r, g, b
    
    if customColor then
        r, g, b = customColor.r, customColor.g, customColor.b
    else
        r, g, b = 0.5, 0.5, 0.5
    end
    
    -- Create custom color accent
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetSize(PREVIEW_WIDTH - 4, 3)
    accent:SetPoint("TOP", frame, "TOP", 0, -30)
    accent:SetColorTexture(r, g, b, 0.7)
end