-- VUI Theme Editor
-- Provides a visual theme customization interface
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create Theme Editor module
VUI.ThemeEditor = {}

-- Default settings
VUI.ThemeEditor.defaults = {
    enabled = true,
    lastColor = {r = 1, g = 1, b = 1, a = 1},
    lastTexture = "smooth",
    customThemes = {},
    showPreview = true,
    previewSize = "medium",  -- small, medium, large
    autoSave = true,         -- Auto-save changes
    allowExport = true,      -- Allow exporting themes
    confirmOverwrite = true, -- Confirm before overwriting themes
    showTooltips = true,     -- Show tooltips with detailed info
    useRGBSliders = true,    -- Use RGB sliders vs. color picker
    previewElements = {      -- UI elements to preview
        frame = true,
        button = true,
        statusbar = true,
        header = true,
        text = true
    }
}

-- ThemeEditor panel reference
local ThemeEditor = VUI.ThemeEditor
local panel = nil
local colorPickers = {}
local texturePickers = {}
local fontPickers = {}
local currentTheme = {}
local previewElements = {}
local isDirty = false

-- Constants
local PANEL_PADDING = 16
local COLOR_PICKER_SIZE = 24
local TEXTURE_PICKER_WIDTH = 140
local TEXTURE_PICKER_HEIGHT = 16
local PREVIEW_FRAME_SIZE = 220
local STANDARD_BUTTON_WIDTH = 100
local STANDARD_BUTTON_HEIGHT = 24
local DEFAULT_THEMES = {"thunderstorm", "phoenixflame", "arcanemystic", "felenergy"}

-- Color categories for themeing
local COLOR_ELEMENTS = {
    backdrop = {
        name = "Background",
        desc = "Main background color for frames",
        default = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
    },
    border = {
        name = "Border",
        desc = "Border color for frames",
        default = {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
    },
    highlight = {
        name = "Highlight",
        desc = "Color for highlights and selections",
        default = {r = 0.3, g = 0.3, b = 0.3, a = 0.5},
    },
    header = {
        name = "Header",
        desc = "Color for frame headers and titles",
        default = {r = 0.15, g = 0.15, b = 0.15, a = 1.0},
    },
    button = {
        name = "Button",
        desc = "Background color for buttons",
        default = {r = 0.2, g = 0.2, b = 0.2, a = 1.0},
    },
    text = {
        name = "Text",
        desc = "Default text color",
        default = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
    },
    primary = {
        name = "Primary Accent",
        desc = "Main accent color for important elements",
        default = {r = 0.3, g = 0.6, b = 1.0, a = 1.0},
    },
    secondary = {
        name = "Secondary Accent",
        desc = "Secondary accent color",
        default = {r = 1.0, g = 0.82, b = 0.0, a = 1.0},
    }
}

-- Texture categories for themeing
local TEXTURE_ELEMENTS = {
    background = {
        name = "Background",
        desc = "Background texture for frames",
        options = {
            "solid", "gradient", "smoke", "dark", "rough", "parchment"
        }
    },
    border = {
        name = "Border",
        desc = "Border texture for frames",
        options = {
            "thin", "thick", "glow", "solid", "shadow", "none"
        }
    },
    statusbar = {
        name = "StatusBar",
        desc = "Texture for status and progress bars",
        options = {
            "smooth", "flat", "gloss", "normtext", "minimalist", "bars"
        }
    },
    button = {
        name = "Button",
        desc = "Texture for buttons",
        options = {
            "default", "glossy", "clean", "flat", "sharp", "modern"
        }
    },
    highlight = {
        name = "Highlight",
        desc = "Texture for highlighting",
        options = {
            "glow", "shine", "blizzard", "minimal", "soft", "sharp"
        }
    }
}

-- Font options
local FONT_ELEMENTS = {
    normal = {
        name = "Normal Text",
        desc = "Font for standard text",
        options = {
            "Friz Quadrata TT", "Arial Narrow", "VUI PT Sans Narrow", 
            "VUI Roboto", "VUI Open Sans", "VUI Noto Sans"
        }
    },
    header = {
        name = "Header Text",
        desc = "Font for titles and headers",
        options = {
            "Friz Quadrata TT", "Arial Narrow", "VUI PT Sans Narrow", 
            "VUI Roboto", "VUI Open Sans", "VUI Noto Sans"
        }
    },
    mono = {
        name = "Monospace Text",
        desc = "Font for code and fixed-width text",
        options = {
            "VUI Courier New", "VUI Consolas", "VUI Source Code Pro"
        }
    }
}

-- Initialize module
function ThemeEditor:Initialize()
    -- Set up the theme editor frame
    self:SetupFrame()
    
    -- Create theme editor UI
    self:CreateEditorUI()
    
    -- Create preview panel
    if VUI.db.profile.themeEditor.showPreview then
        self:CreatePreviewPanel()
    end
    
    -- Load current theme into editor
    self:LoadCurrentTheme()
    
    -- Register with ConfigUI if available
    if VUI.ConfigUI then
        self:RegisterWithConfigUI()
    end
    
    VUI:Print("ThemeEditor module initialized")
end

-- Enable module
function ThemeEditor:Enable()
    self.enabled = true
    VUI:Print("ThemeEditor module enabled")
end

-- Disable module
function ThemeEditor:Disable()
    self.enabled = false
    VUI:Print("ThemeEditor module disabled")
end

-- Set up the main theme editor frame
function ThemeEditor:SetupFrame()
    -- Create the main panel frame
    panel = CreateFrame("Frame", "VUIThemeEditorPanel")
    panel:SetSize(800, 600)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    panel:Hide()
    
    -- Add title text
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("VUI Theme Editor")
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() ThemeEditor:Hide() end)
    
    -- Save panel reference
    self.panel = panel
    self.title = title
    
    return panel
end

-- Create the theme editor UI
function ThemeEditor:CreateEditorUI()
    local panel = self.panel
    
    -- Theme selection dropdown
    local themeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    themeLabel:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -20)
    themeLabel:SetText("Theme:")
    
    local themeDropdown = CreateFrame("Frame", "VUIThemeEditorThemeDropdown", panel, "UIDropDownMenuTemplate")
    themeDropdown:SetPoint("TOPLEFT", themeLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(themeDropdown, 200)
    
    UIDropDownMenu_Initialize(themeDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        -- Add built-in themes
        for _, theme in ipairs(DEFAULT_THEMES) do
            info.text = theme:gsub("^%l", string.upper) -- Capitalize first letter
            info.value = theme
            info.func = function()
                ThemeEditor:SelectTheme(theme)
                UIDropDownMenu_SetText(themeDropdown, info.text)
            end
            info.checked = (VUI.db.profile.appearance.theme == theme)
            UIDropDownMenu_AddButton(info, level)
        end
        
        -- Add separator
        if #VUI.db.profile.themeEditor.customThemes > 0 then
            info.text = ""
            info.disabled = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Add custom themes header
            info.text = "Custom Themes"
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Add custom themes
            for name, _ in pairs(VUI.db.profile.themeEditor.customThemes) do
                info.text = name
                info.value = name
                info.isTitle = false
                info.notCheckable = false
                info.func = function()
                    ThemeEditor:SelectTheme(name, true)
                    UIDropDownMenu_SetText(themeDropdown, name)
                end
                info.checked = (VUI.db.profile.appearance.theme == name)
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    
    -- Set initial text
    local currentThemeName = VUI.db.profile.appearance.theme or "thunderstorm"
    currentThemeName = currentThemeName:gsub("^%l", string.upper) -- Capitalize first letter
    UIDropDownMenu_SetText(themeDropdown, currentThemeName)
    
    -- Create tabs for different theme settings
    local tabContainer = CreateFrame("Frame", nil, panel)
    tabContainer:SetPoint("TOPLEFT", themeDropdown, "BOTTOMLEFT", 15, -20)
    tabContainer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 50)
    
    -- Create tabs
    local tabs = {
        {text = "Colors", frame = "colorFrame"},
        {text = "Textures", frame = "textureFrame"},
        {text = "Fonts", frame = "fontFrame"},
        {text = "Create Theme", frame = "createThemeFrame"},
        {text = "Import/Export", frame = "importExportFrame"},
        {text = "Media Stats", frame = "mediaStatsFrame"}
    }
    
    -- Create tab buttons
    local tabFrames = {}
    local tabButtons = {}
    
    for i, tabInfo in ipairs(tabs) do
        -- Create tab button
        local tabButton = CreateFrame("Button", "VUIThemeEditorTab" .. i, panel, "OptionsFrameTabButtonTemplate")
        tabButton:SetID(i)
        tabButton:SetText(tabInfo.text)
        
        if i == 1 then
            tabButton:SetPoint("BOTTOMLEFT", tabContainer, "TOPLEFT", 0, 1)
        else
            tabButton:SetPoint("LEFT", tabButtons[i-1], "RIGHT", -15, 0)
        end
        
        tabButton:SetScript("OnClick", function(self)
            ThemeEditor:SelectTab(i)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end)
        
        -- Create content frame for this tab
        local contentFrame = CreateFrame("Frame", nil, tabContainer)
        contentFrame:SetPoint("TOPLEFT", tabContainer, "TOPLEFT", 10, -10)
        contentFrame:SetPoint("BOTTOMRIGHT", tabContainer, "BOTTOMRIGHT", -10, 10)
        contentFrame:Hide()
        
        -- Store references
        tabFrames[i] = contentFrame
        tabButtons[i] = tabButton
        self[tabInfo.frame] = contentFrame
    end
    
    -- Create content for each tab
    self:CreateColorTab(tabFrames[1])
    self:CreateTextureTab(tabFrames[2])
    self:CreateFontTab(tabFrames[3])
    self:CreateThemeWizardTab(tabFrames[4])
    self:CreateImportExportTab(tabFrames[5])
    self:CreateMediaStatsTab(tabFrames[6])
    
    -- Action buttons at bottom
    local buttonContainer = CreateFrame("Frame", nil, panel)
    buttonContainer:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
    buttonContainer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    buttonContainer:SetHeight(STANDARD_BUTTON_HEIGHT)
    
    -- Save button
    local saveButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    saveButton:SetSize(STANDARD_BUTTON_WIDTH, STANDARD_BUTTON_HEIGHT)
    saveButton:SetPoint("RIGHT", buttonContainer, "RIGHT", 0, 0)
    saveButton:SetText("Save Theme")
    saveButton:SetScript("OnClick", function() ThemeEditor:SaveTheme() end)
    
    -- Save As button
    local saveAsButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    saveAsButton:SetSize(STANDARD_BUTTON_WIDTH, STANDARD_BUTTON_HEIGHT)
    saveAsButton:SetPoint("RIGHT", saveButton, "LEFT", -10, 0)
    saveAsButton:SetText("Save As...")
    saveAsButton:SetScript("OnClick", function() ThemeEditor:SaveThemeAs() end)
    
    -- Reset button
    local resetButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    resetButton:SetSize(STANDARD_BUTTON_WIDTH, STANDARD_BUTTON_HEIGHT)
    resetButton:SetPoint("LEFT", buttonContainer, "LEFT", 0, 0)
    resetButton:SetText("Reset")
    resetButton:SetScript("OnClick", function() ThemeEditor:ResetTheme() end)
    
    -- Apply button
    local applyButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    applyButton:SetSize(STANDARD_BUTTON_WIDTH, STANDARD_BUTTON_HEIGHT)
    applyButton:SetPoint("LEFT", resetButton, "RIGHT", 10, 0)
    applyButton:SetText("Apply")
    applyButton:SetScript("OnClick", function() ThemeEditor:ApplyTheme() end)
    
    -- Store references
    self.tabFrames = tabFrames
    self.tabButtons = tabButtons
    self.saveButton = saveButton
    self.saveAsButton = saveAsButton
    self.resetButton = resetButton
    self.applyButton = applyButton
    self.themeDropdown = themeDropdown
    
    -- Start with first tab selected
    self:SelectTab(1)
end

-- Create the color tab content
function ThemeEditor:CreateColorTab(frame)
    -- Create scrollable container
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(scrollFrame:GetHeight() * 2) -- Make it taller than the visible area
    
    -- Add color pickers
    local yOffset = 10
    for key, colorInfo in pairs(COLOR_ELEMENTS) do
        -- Create label and description
        local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -yOffset)
        label:SetText(colorInfo.name)
        
        local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
        desc:SetText(colorInfo.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Create color swatch
        local swatch = CreateFrame("Button", nil, scrollChild)
        swatch:SetSize(COLOR_PICKER_SIZE, COLOR_PICKER_SIZE)
        swatch:SetPoint("RIGHT", scrollChild, "RIGHT", -30, 0)
        swatch:SetPoint("TOP", label, "TOP", 0, 0)
        
        swatch.tex = swatch:CreateTexture(nil, "BACKGROUND")
        swatch.tex:SetAllPoints(swatch)
        swatch.tex:SetColorTexture(colorInfo.default.r, colorInfo.default.g, colorInfo.default.b, colorInfo.default.a)
        
        -- Add border around color swatch
        swatch:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1
        })
        swatch:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
        
        -- Click behavior for color picker
        swatch:SetScript("OnClick", function()
            ThemeEditor:OpenColorPicker(key, swatch.tex)
        end)
        
        -- Store reference to this color picker
        colorPickers[key] = {
            swatch = swatch,
            texture = swatch.tex,
            default = CopyTable(colorInfo.default)
        }
        
        -- Add RGB sliders if enabled
        if VUI.db.profile.themeEditor.useRGBSliders then
            -- Red slider
            local redSlider = CreateFrame("Slider", nil, scrollChild, "OptionsSliderTemplate")
            redSlider:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -15)
            redSlider:SetPoint("RIGHT", scrollChild, "RIGHT", -70, 0)
            redSlider:SetMinMaxValues(0, 100)
            redSlider:SetValue(colorInfo.default.r * 100)
            redSlider:SetValueStep(1)
            redSlider.Low:SetText("R")
            redSlider.High:SetText("")
            redSlider.Text:SetText(math.floor(colorInfo.default.r * 100) .. "%")
            
            -- Green slider
            local greenSlider = CreateFrame("Slider", nil, scrollChild, "OptionsSliderTemplate")
            greenSlider:SetPoint("TOPLEFT", redSlider, "BOTTOMLEFT", 0, -15)
            greenSlider:SetPoint("RIGHT", scrollChild, "RIGHT", -70, 0)
            greenSlider:SetMinMaxValues(0, 100)
            greenSlider:SetValue(colorInfo.default.g * 100)
            greenSlider:SetValueStep(1)
            greenSlider.Low:SetText("G")
            greenSlider.High:SetText("")
            greenSlider.Text:SetText(math.floor(colorInfo.default.g * 100) .. "%")
            
            -- Blue slider
            local blueSlider = CreateFrame("Slider", nil, scrollChild, "OptionsSliderTemplate")
            blueSlider:SetPoint("TOPLEFT", greenSlider, "BOTTOMLEFT", 0, -15)
            blueSlider:SetPoint("RIGHT", scrollChild, "RIGHT", -70, 0)
            blueSlider:SetMinMaxValues(0, 100)
            blueSlider:SetValue(colorInfo.default.b * 100)
            blueSlider:SetValueStep(1)
            blueSlider.Low:SetText("B")
            blueSlider.High:SetText("")
            blueSlider.Text:SetText(math.floor(colorInfo.default.b * 100) .. "%")
            
            -- Alpha slider
            local alphaSlider = CreateFrame("Slider", nil, scrollChild, "OptionsSliderTemplate")
            alphaSlider:SetPoint("TOPLEFT", blueSlider, "BOTTOMLEFT", 0, -15)
            alphaSlider:SetPoint("RIGHT", scrollChild, "RIGHT", -70, 0)
            alphaSlider:SetMinMaxValues(0, 100)
            alphaSlider:SetValue(colorInfo.default.a * 100)
            alphaSlider:SetValueStep(1)
            alphaSlider.Low:SetText("A")
            alphaSlider.High:SetText("")
            alphaSlider.Text:SetText(math.floor(colorInfo.default.a * 100) .. "%")
            
            -- Update functions
            local function UpdateColor()
                local r = redSlider:GetValue() / 100
                local g = greenSlider:GetValue() / 100
                local b = blueSlider:GetValue() / 100
                local a = alphaSlider:GetValue() / 100
                
                swatch.tex:SetColorTexture(r, g, b, a)
                redSlider.Text:SetText(math.floor(r * 100) .. "%")
                greenSlider.Text:SetText(math.floor(g * 100) .. "%")
                blueSlider.Text:SetText(math.floor(b * 100) .. "%")
                alphaSlider.Text:SetText(math.floor(a * 100) .. "%")
                
                -- Update current theme
                currentTheme.colors = currentTheme.colors or {}
                currentTheme.colors[key] = {r = r, g = g, b = b, a = a}
                
                -- Mark as dirty
                isDirty = true
                
                -- Update preview
                ThemeEditor:UpdatePreview()
            end
            
            redSlider:SetScript("OnValueChanged", UpdateColor)
            greenSlider:SetScript("OnValueChanged", UpdateColor)
            blueSlider:SetScript("OnValueChanged", UpdateColor)
            alphaSlider:SetScript("OnValueChanged", UpdateColor)
            
            -- Store references
            colorPickers[key].redSlider = redSlider
            colorPickers[key].greenSlider = greenSlider
            colorPickers[key].blueSlider = blueSlider
            colorPickers[key].alphaSlider = alphaSlider
            
            -- Update y-offset for next color
            yOffset = yOffset + 130
        else
            -- Update y-offset for next color
            yOffset = yOffset + 50
        end
    end
    
    -- Adjust scrollChild height
    scrollChild:SetHeight(yOffset + 20)
    
    -- Store references
    self.colorScrollFrame = scrollFrame
    self.colorScrollChild = scrollChild
end

-- Create the texture tab content
function ThemeEditor:CreateTextureTab(frame)
    -- Create scrollable container
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(scrollFrame:GetHeight() * 2) -- Make it taller than the visible area
    
    -- Add texture pickers
    local yOffset = 10
    for key, textureInfo in pairs(TEXTURE_ELEMENTS) do
        -- Create label and description
        local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -yOffset)
        label:SetText(textureInfo.name)
        
        local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
        desc:SetText(textureInfo.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Create texture dropdown
        local dropdown = CreateFrame("Frame", "VUIThemeEditorTexture" .. key, scrollChild, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", -15, -5)
        UIDropDownMenu_SetWidth(dropdown, 140)
        
        -- Get current texture or default
        local currentTexture = textureInfo.options[1]
        if currentTheme.textures and currentTheme.textures[key] then
            currentTexture = currentTheme.textures[key]
        end
        
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, option in ipairs(textureInfo.options) do
                info.text = option:gsub("^%l", string.upper) -- Capitalize first letter
                info.value = option
                info.func = function()
                    UIDropDownMenu_SetText(dropdown, info.text)
                    -- Update current theme
                    currentTheme.textures = currentTheme.textures or {}
                    currentTheme.textures[key] = option
                    isDirty = true
                    ThemeEditor:UpdatePreview()
                end
                info.checked = (currentTexture == option)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        
        -- Set initial value
        UIDropDownMenu_SetText(dropdown, currentTexture:gsub("^%l", string.upper))
        
        -- Create texture preview
        local preview = CreateFrame("Frame", nil, scrollChild)
        preview:SetSize(TEXTURE_PICKER_WIDTH, TEXTURE_PICKER_HEIGHT)
        preview:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -30, -yOffset)
        
        -- Add texture based on type
        if key == "background" then
            preview:SetBackdrop({
                bgFile = "Interface\\AddOns\\VUI\\media\\textures\\" .. currentTexture .. ".tga",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
        elseif key == "border" then
            preview:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\borders\\" .. currentTexture .. ".tga",
                edgeSize = 8,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            preview:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        elseif key == "statusbar" then
            local bar = CreateFrame("StatusBar", nil, preview)
            bar:SetAllPoints()
            bar:SetStatusBarTexture("Interface\\AddOns\\VUI\\media\\textures\\statusbars\\" .. currentTexture .. ".tga")
            bar:SetMinMaxValues(0, 100)
            bar:SetValue(75)
            bar:SetStatusBarColor(0.2, 0.6, 1.0, 1.0)
            preview.bar = bar
            
            preview:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1
            })
        end
        
        preview:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
        
        -- Store references
        texturePickers[key] = {
            dropdown = dropdown,
            preview = preview,
            options = textureInfo.options
        }
        
        -- Update y-offset for next texture
        yOffset = yOffset + 80
    end
    
    -- Adjust scrollChild height
    scrollChild:SetHeight(yOffset + 20)
    
    -- Store references
    self.textureScrollFrame = scrollFrame
    self.textureScrollChild = scrollChild
end

-- Create the font tab content
function ThemeEditor:CreateFontTab(frame)
    -- Create scrollable container
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(scrollFrame:GetHeight() * 2) -- Make it taller than the visible area
    
    -- Add font pickers
    local yOffset = 10
    for key, fontInfo in pairs(FONT_ELEMENTS) do
        -- Create label and description
        local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -yOffset)
        label:SetText(fontInfo.name)
        
        local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
        desc:SetText(fontInfo.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Create font dropdown
        local dropdown = CreateFrame("Frame", "VUIThemeEditorFont" .. key, scrollChild, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", -15, -5)
        UIDropDownMenu_SetWidth(dropdown, 160)
        
        -- Get current font or default
        local currentFont = fontInfo.options[1]
        if currentTheme.fonts and currentTheme.fonts[key] then
            currentFont = currentTheme.fonts[key]
        end
        
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, option in ipairs(fontInfo.options) do
                info.text = option
                info.value = option
                info.func = function()
                    UIDropDownMenu_SetText(dropdown, option)
                    fontPickers[key].preview:SetFont(option, 12, "")
                    -- Update current theme
                    currentTheme.fonts = currentTheme.fonts or {}
                    currentTheme.fonts[key] = option
                    isDirty = true
                    ThemeEditor:UpdatePreview()
                end
                info.checked = (currentFont == option)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        
        -- Set initial value
        UIDropDownMenu_SetText(dropdown, currentFont)
        
        -- Create font preview
        local preview = scrollChild:CreateFontString(nil, "OVERLAY")
        preview:SetFont(currentFont, 12, "")
        preview:SetText("The quick brown fox jumps over the lazy dog.")
        preview:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -30, -yOffset)
        preview:SetJustifyH("RIGHT")
        preview:SetWidth(200)
        
        -- Store references
        fontPickers[key] = {
            dropdown = dropdown,
            preview = preview,
            options = fontInfo.options
        }
        
        -- Add font size slider
        local sizeSlider = CreateFrame("Slider", nil, scrollChild, "OptionsSliderTemplate")
        sizeSlider:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 20, -20)
        sizeSlider:SetPoint("RIGHT", scrollChild, "RIGHT", -80, 0)
        sizeSlider:SetMinMaxValues(8, 24)
        sizeSlider:SetValue(12)
        sizeSlider:SetValueStep(1)
        sizeSlider.Low:SetText("8")
        sizeSlider.High:SetText("24")
        sizeSlider.Text:SetText("Font Size: 12")
        
        sizeSlider:SetScript("OnValueChanged", function(self, value)
            local size = math.floor(value)
            self.Text:SetText("Font Size: " .. size)
            preview:SetFont(currentFont, size, "")
            -- Update current theme
            currentTheme.fontSizes = currentTheme.fontSizes or {}
            currentTheme.fontSizes[key] = size
            isDirty = true
            ThemeEditor:UpdatePreview()
        end)
        
        -- Add outline options
        local outlineLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        outlineLabel:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -15)
        outlineLabel:SetText("Outline:")
        
        local outlineOptions = {
            {text = "None", value = ""},
            {text = "Outline", value = "OUTLINE"},
            {text = "Thick Outline", value = "THICKOUTLINE"}
        }
        
        local outlineDropdown = CreateFrame("Frame", "VUIThemeEditorFontOutline" .. key, scrollChild, "UIDropDownMenuTemplate")
        outlineDropdown:SetPoint("LEFT", outlineLabel, "RIGHT", 10, 0)
        UIDropDownMenu_SetWidth(outlineDropdown, 120)
        
        UIDropDownMenu_Initialize(outlineDropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, option in ipairs(outlineOptions) do
                info.text = option.text
                info.value = option.value
                info.func = function()
                    UIDropDownMenu_SetText(outlineDropdown, option.text)
                    local font, size = preview:GetFont()
                    preview:SetFont(font, size, option.value)
                    -- Update current theme
                    currentTheme.fontOutlines = currentTheme.fontOutlines or {}
                    currentTheme.fontOutlines[key] = option.value
                    isDirty = true
                    ThemeEditor:UpdatePreview()
                end
                info.checked = (preview:GetFontObject() and preview:GetFontObject():GetFont() == option.value)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        
        -- Set initial outline value
        UIDropDownMenu_SetText(outlineDropdown, "None")
        
        -- Store additional references
        fontPickers[key].sizeSlider = sizeSlider
        fontPickers[key].outlineDropdown = outlineDropdown
        
        -- Update y-offset for next font
        yOffset = yOffset + 140
    end
    
    -- Adjust scrollChild height
    scrollChild:SetHeight(yOffset + 20)
    
    -- Store references
    self.fontScrollFrame = scrollFrame
    self.fontScrollChild = scrollChild
end

-- Create the import/export tab content
function ThemeEditor:CreatePreviewFrame(parentFrame, width, height)
    local previewFrame = CreateFrame("Frame", nil, parentFrame)
    previewFrame:SetSize(width, height)
    
    -- Create a background frame
    local bg = CreateFrame("Frame", nil, previewFrame)
    bg:SetPoint("TOPLEFT", previewFrame, "TOPLEFT", 0, 0)
    bg:SetPoint("BOTTOMRIGHT", previewFrame, "BOTTOMRIGHT", 0, 0)
    bg:SetFrameLevel(previewFrame:GetFrameLevel() - 1)
    bg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    bg:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    bg:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Sample frame
    local sampleFrame = CreateFrame("Frame", nil, previewFrame)
    sampleFrame:SetSize(width * 0.45, height * 0.3)
    sampleFrame:SetPoint("TOPLEFT", previewFrame, "TOPLEFT", 10, -10)
    sampleFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    previewFrame.sampleFrame = sampleFrame
    
    -- Sample header
    local sampleHeader = sampleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sampleHeader:SetPoint("TOPLEFT", sampleFrame, "TOPLEFT", 10, -10)
    sampleHeader:SetText("Theme Preview - Header")
    previewFrame.sampleHeader = sampleHeader
    
    -- Sample text
    local sampleText = sampleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sampleText:SetPoint("TOPLEFT", sampleHeader, "BOTTOMLEFT", 0, -10)
    sampleText:SetText("Sample UI text with theme styling")
    previewFrame.sampleText = sampleText
    
    -- Sample button
    local sampleButton = CreateFrame("Button", nil, sampleFrame, "UIPanelButtonTemplate")
    sampleButton:SetSize(120, 26)
    sampleButton:SetPoint("TOPLEFT", sampleText, "BOTTOMLEFT", 0, -15)
    sampleButton:SetText("Sample Button")
    previewFrame.sampleButton = sampleButton
    
    -- Sample statusbar
    local sampleStatusBar = CreateFrame("StatusBar", nil, sampleFrame)
    sampleStatusBar:SetSize(width * 0.4, 20)
    sampleStatusBar:SetPoint("TOPLEFT", sampleButton, "BOTTOMLEFT", 0, -15)
    sampleStatusBar:SetMinMaxValues(0, 100)
    sampleStatusBar:SetValue(70)
    previewFrame.sampleStatusBar = sampleStatusBar
    
    -- Add a second sample frame that looks like a unit frame
    local unitFrame = CreateFrame("Frame", nil, previewFrame)
    unitFrame:SetSize(width * 0.45, height * 0.15)
    unitFrame:SetPoint("TOPLEFT", sampleFrame, "BOTTOMLEFT", 0, -20)
    unitFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    previewFrame.unitFrame = unitFrame
    
    -- Unit frame health bar
    local healthBar = CreateFrame("StatusBar", nil, unitFrame)
    healthBar:SetSize(width * 0.4, 18)
    healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 10, -10)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetValue(65)
    previewFrame.healthBar = healthBar
    
    -- Unit frame name
    local unitName = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    unitName:SetPoint("LEFT", healthBar, "LEFT", 5, 0)
    unitName:SetText("Player Name")
    previewFrame.unitName = unitName
    
    -- Unit frame mana bar
    local manaBar = CreateFrame("StatusBar", nil, unitFrame)
    manaBar:SetSize(width * 0.4, 12)
    manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -2)
    manaBar:SetMinMaxValues(0, 100)
    manaBar:SetValue(80)
    previewFrame.manaBar = manaBar
    
    -- Third example - action button
    local actionButton = CreateFrame("Button", nil, previewFrame)
    actionButton:SetSize(40, 40)
    actionButton:SetPoint("TOPLEFT", unitFrame, "BOTTOMLEFT", 0, -20)
    actionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
    actionButton:GetNormalTexture():SetTexCoord(0.18, 0.82, 0.18, 0.82)
    previewFrame.actionButton = actionButton
    
    -- Action button cooldown overlay
    local cooldown = CreateFrame("Cooldown", nil, actionButton, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetCooldown(GetTime(), 30)
    
    -- Action button border frame
    local actionBorder = CreateFrame("Frame", nil, actionButton)
    actionBorder:SetAllPoints()
    actionBorder:SetFrameLevel(actionButton:GetFrameLevel() + 1)
    actionBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    previewFrame.actionBorder = actionBorder
    
    -- Function to update the preview with current theme
    function previewFrame:UpdateWithTheme(theme)
        if not theme then return end
        
        -- Update sample frame
        sampleFrame:SetBackdropColor(
            theme.colors.backdrop.r or 0.1, 
            theme.colors.backdrop.g or 0.1, 
            theme.colors.backdrop.b or 0.1, 
            theme.colors.backdrop.a or 0.8
        )
        sampleFrame:SetBackdropBorderColor(
            theme.colors.border.r or 0.6, 
            theme.colors.border.g or 0.6, 
            theme.colors.border.b or 0.6, 
            theme.colors.border.a or 1
        )
        
        -- Update header text
        if theme.fonts.header then
            sampleHeader:SetFont(theme.fonts.header, theme.fontSizes.header or 14, theme.fontOutlines.header or "NONE")
        end
        sampleHeader:SetTextColor(
            theme.colors.header.r or 1, 
            theme.colors.header.g or 1, 
            theme.colors.header.b or 1, 
            theme.colors.header.a or 1
        )
        
        -- Update normal text
        if theme.fonts.normal then
            sampleText:SetFont(theme.fonts.normal, theme.fontSizes.normal or 12, theme.fontOutlines.normal or "NONE")
        end
        sampleText:SetTextColor(
            theme.colors.text.r or 1, 
            theme.colors.text.g or 1, 
            theme.colors.text.b or 1, 
            theme.colors.text.a or 1
        )
        
        -- Update button
        if theme.colors.button then
            local normalTex = sampleButton:GetNormalTexture()
            if normalTex then
                normalTex:SetVertexColor(
                    theme.colors.button.r or 0.8, 
                    theme.colors.button.g or 0.8, 
                    theme.colors.button.b or 0.8, 
                    theme.colors.button.a or 1
                )
            end
        end
        
        -- Update statusbar
        if theme.textures.statusbar then
            sampleStatusBar:SetStatusBarTexture(theme.textures.statusbar)
        end
        sampleStatusBar:SetStatusBarColor(
            theme.colors.statusbar.r or 0.8, 
            theme.colors.statusbar.g or 0.8, 
            theme.colors.statusbar.b or 0.2, 
            theme.colors.statusbar.a or 1
        )
        
        -- Update unit frame
        unitFrame:SetBackdropColor(
            theme.colors.backdrop.r or 0.1, 
            theme.colors.backdrop.g or 0.1, 
            theme.colors.backdrop.b or 0.1, 
            theme.colors.backdrop.a or 0.8
        )
        unitFrame:SetBackdropBorderColor(
            theme.colors.border.r or 0.6, 
            theme.colors.border.g or 0.6, 
            theme.colors.border.b or 0.6, 
            theme.colors.border.a or 1
        )
        
        -- Update health and mana bars
        if theme.textures.statusbar then
            healthBar:SetStatusBarTexture(theme.textures.statusbar)
            manaBar:SetStatusBarTexture(theme.textures.statusbar)
        end
        healthBar:SetStatusBarColor(0.2, 0.8, 0.2, 1) -- Class-colored 
        manaBar:SetStatusBarColor(0.2, 0.2, 0.8, 1)   -- Resource-colored
        
        -- Update unit name font
        if theme.fonts.normal then
            unitName:SetFont(theme.fonts.normal, theme.fontSizes.normal or 12, theme.fontOutlines.normal or "NONE")
        end
        
        -- Update action button border
        actionBorder:SetBackdropBorderColor(
            theme.colors.border.r or 0.6, 
            theme.colors.border.g or 0.6, 
            theme.colors.border.b or 0.6, 
            theme.colors.border.a or 1
        )
    end
    
    return previewFrame
end

-- Create the Theme Wizard tab content
function ThemeEditor:CreateThemeWizardTab(frame)
    -- Create title and description
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    title:SetText("Create New Theme")
    
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText("Follow the steps below to create a new custom theme using the theme wizard.")
    desc:SetJustifyH("LEFT")
    desc:SetWidth(frame:GetWidth() - 20)
    
    -- Create a theme preview frame
    local previewFrame = self:CreatePreviewFrame(frame, frame:GetWidth() * 0.45, frame:GetHeight() * 0.4)
    previewFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -40)
    
    -- Create a step indicator
    local stepsFrame = CreateFrame("Frame", nil, frame)
    stepsFrame:SetSize(frame:GetWidth() - 20, 30)
    stepsFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    
    local steps = {
        "1. Base Theme",
        "2. Color Scheme",
        "3. Texture Style",
        "4. Font Selection",
        "5. Name and Save"
    }
    
    local stepIndicators = {}
    for i, stepText in ipairs(steps) do
        local indicator = CreateFrame("Frame", nil, stepsFrame)
        indicator:SetSize(frame:GetWidth() / #steps - 10, 30)
        
        if i == 1 then
            indicator:SetPoint("LEFT", stepsFrame, "LEFT", 0, 0)
        else
            indicator:SetPoint("LEFT", stepIndicators[i-1], "RIGHT", 5, 0)
        end
        
        indicator.bg = indicator:CreateTexture(nil, "BACKGROUND")
        indicator.bg:SetAllPoints()
        indicator.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        
        indicator.text = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        indicator.text:SetPoint("CENTER", indicator, "CENTER")
        indicator.text:SetText(stepText)
        
        -- Store reference
        stepIndicators[i] = indicator
    end
    
    -- Highlight the current step
    local function UpdateStepIndicators(currentStep)
        for i, indicator in ipairs(stepIndicators) do
            if i == currentStep then
                indicator.bg:SetColorTexture(0.3, 0.3, 0.8, 0.7)
                indicator.text:SetTextColor(1, 1, 1)
            else
                if i < currentStep then
                    -- Completed step
                    indicator.bg:SetColorTexture(0.2, 0.5, 0.2, 0.5)
                    indicator.text:SetTextColor(0.8, 1, 0.8)
                else
                    -- Future step
                    indicator.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
                    indicator.text:SetTextColor(0.7, 0.7, 0.7)
                end
            end
        end
    end
    
    -- Content area for the current step
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetSize(frame:GetWidth() * 0.5 - 30, frame:GetHeight() - 160)
    contentArea:SetPoint("TOPLEFT", stepsFrame, "BOTTOMLEFT", 0, -20)
    
    -- Step content frames
    local stepFrames = {}
    for i = 1, #steps do
        local stepFrame = CreateFrame("Frame", nil, contentArea)
        stepFrame:SetAllPoints(contentArea)
        stepFrame:Hide()
        stepFrames[i] = stepFrame
    end
    
    -- Step 1: Base Theme Selection
    local baseThemeFrame = stepFrames[1]
    
    local baseThemeLabel = baseThemeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    baseThemeLabel:SetPoint("TOPLEFT", baseThemeFrame, "TOPLEFT", 0, 0)
    baseThemeLabel:SetText("Select a Base Theme")
    
    local baseThemeDesc = baseThemeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    baseThemeDesc:SetPoint("TOPLEFT", baseThemeLabel, "BOTTOMLEFT", 0, -10)
    baseThemeDesc:SetText("Choose a built-in theme to use as the starting point for your custom theme.")
    baseThemeDesc:SetJustifyH("LEFT")
    baseThemeDesc:SetWidth(baseThemeFrame:GetWidth())
    
    -- Theme radio buttons
    local baseThemeOptions = {
        {name = "Phoenix Flame", value = "phoenixflame", description = "Dark red/brown backgrounds with fiery orange borders."},
        {name = "Thunder Storm", value = "thunderstorm", description = "Deep blue backgrounds with electric blue borders."},
        {name = "Arcane Mystic", value = "arcanemystic", description = "Deep purple backgrounds with violet borders."},
        {name = "Fel Energy", value = "felenergy", description = "Dark green backgrounds with fel green borders."}
    }
    
    local selectedBaseTheme = "thunderstorm"
    local baseThemeRadios = {}
    
    for i, themeOption in ipairs(baseThemeOptions) do
        local radio = CreateFrame("CheckButton", nil, baseThemeFrame, "UICheckButtonTemplate")
        radio:SetSize(24, 24)
        
        if i == 1 then
            radio:SetPoint("TOPLEFT", baseThemeDesc, "BOTTOMLEFT", 0, -20)
        else
            radio:SetPoint("TOPLEFT", baseThemeRadios[i-1].desc, "BOTTOMLEFT", -20, -10)
        end
        
        radio.value = themeOption.value
        radio:SetChecked(selectedBaseTheme == themeOption.value)
        
        radio.text = baseThemeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        radio.text:SetPoint("LEFT", radio, "RIGHT", 5, 0)
        radio.text:SetText(themeOption.name)
        
        radio.desc = baseThemeFrame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        radio.desc:SetPoint("TOPLEFT", radio.text, "BOTTOMLEFT", 0, -2)
        radio.desc:SetText(themeOption.description)
        radio.desc:SetTextColor(0.7, 0.7, 0.7)
        radio.desc:SetWidth(baseThemeFrame:GetWidth() - 30)
        radio.desc:SetJustifyH("LEFT")
        
        radio:SetScript("OnClick", function()
            -- Uncheck all others
            for _, otherRadio in ipairs(baseThemeRadios) do
                otherRadio:SetChecked(false)
            end
            -- Check this one
            radio:SetChecked(true)
            selectedBaseTheme = radio.value
            
            -- Update preview
            local previewTheme = VUI:GetTheme(selectedBaseTheme)
            previewFrame:UpdateWithTheme(previewTheme)
        end)
        
        baseThemeRadios[i] = radio
    end
    
    -- Step 2: Color Scheme
    local colorSchemeFrame = stepFrames[2]
    
    local colorSchemeLabel = colorSchemeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    colorSchemeLabel:SetPoint("TOPLEFT", colorSchemeFrame, "TOPLEFT", 0, 0)
    colorSchemeLabel:SetText("Customize Color Scheme")
    
    local colorSchemeDesc = colorSchemeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorSchemeDesc:SetPoint("TOPLEFT", colorSchemeLabel, "BOTTOMLEFT", 0, -10)
    colorSchemeDesc:SetText("Adjust the primary and secondary colors for your theme.")
    colorSchemeDesc:SetJustifyH("LEFT")
    colorSchemeDesc:SetWidth(colorSchemeFrame:GetWidth())
    
    -- Create color pickers for primary elements
    local primaryColor = {r = 0.3, g = 0.6, b = 1.0, a = 1.0}
    local secondaryColor = {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
    
    -- Primary color picker
    local primaryLabel = colorSchemeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    primaryLabel:SetPoint("TOPLEFT", colorSchemeDesc, "BOTTOMLEFT", 0, -20)
    primaryLabel:SetText("Primary Color (borders, highlights):")
    
    local primarySwatch = CreateFrame("Button", nil, colorSchemeFrame)
    primarySwatch:SetSize(24, 24)
    primarySwatch:SetPoint("LEFT", primaryLabel, "RIGHT", 10, 0)
    
    primarySwatch.tex = primarySwatch:CreateTexture(nil, "BACKGROUND")
    primarySwatch.tex:SetAllPoints(primarySwatch)
    primarySwatch.tex:SetColorTexture(primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a)
    
    primarySwatch:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1
    })
    primarySwatch:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    
    primarySwatch:SetScript("OnClick", function()
        ColorPickerFrame:SetColorRGB(primaryColor.r, primaryColor.g, primaryColor.b)
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = primaryColor.a
        ColorPickerFrame.previousValues = {primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a}
        ColorPickerFrame.func = function()
            primaryColor.r, primaryColor.g, primaryColor.b = ColorPickerFrame:GetColorRGB()
            primaryColor.a = OpacitySliderFrame:GetValue()
            primarySwatch.tex:SetColorTexture(primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a)
            
            -- Update preview theme
            local previewTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
            -- Apply primary color to border and primary elements
            previewTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
            previewTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
            -- Apply secondary color to secondary elements
            previewTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
            
            previewFrame:UpdateWithTheme(previewTheme)
        end
        ColorPickerFrame.cancelFunc = function(previousValues)
            primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a = unpack(previousValues)
            primarySwatch.tex:SetColorTexture(primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a)
        end
        ColorPickerFrame:Show()
    end)
    
    -- Secondary color picker
    local secondaryLabel = colorSchemeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    secondaryLabel:SetPoint("TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -20)
    secondaryLabel:SetText("Secondary Color (accents, highlights):")
    
    local secondarySwatch = CreateFrame("Button", nil, colorSchemeFrame)
    secondarySwatch:SetSize(24, 24)
    secondarySwatch:SetPoint("LEFT", secondaryLabel, "RIGHT", 10, 0)
    
    secondarySwatch.tex = secondarySwatch:CreateTexture(nil, "BACKGROUND")
    secondarySwatch.tex:SetAllPoints(secondarySwatch)
    secondarySwatch.tex:SetColorTexture(secondaryColor.r, secondaryColor.g, secondaryColor.b, secondaryColor.a)
    
    secondarySwatch:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1
    })
    secondarySwatch:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    
    secondarySwatch:SetScript("OnClick", function()
        ColorPickerFrame:SetColorRGB(secondaryColor.r, secondaryColor.g, secondaryColor.b)
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = secondaryColor.a
        ColorPickerFrame.previousValues = {secondaryColor.r, secondaryColor.g, secondaryColor.b, secondaryColor.a}
        ColorPickerFrame.func = function()
            secondaryColor.r, secondaryColor.g, secondaryColor.b = ColorPickerFrame:GetColorRGB()
            secondaryColor.a = OpacitySliderFrame:GetValue()
            secondarySwatch.tex:SetColorTexture(secondaryColor.r, secondaryColor.g, secondaryColor.b, secondaryColor.a)
            
            -- Update preview theme
            local previewTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
            -- Apply primary color to border and primary elements
            previewTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
            previewTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
            -- Apply secondary color to secondary elements
            previewTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
            
            previewFrame:UpdateWithTheme(previewTheme)
        end
        ColorPickerFrame.cancelFunc = function(previousValues)
            secondaryColor.r, secondaryColor.g, secondaryColor.b, secondaryColor.a = unpack(previousValues)
            secondarySwatch.tex:SetColorTexture(secondaryColor.r, secondaryColor.g, secondaryColor.b, secondaryColor.a)
        end
        ColorPickerFrame:Show()
    end)
    
    -- Step 3: Texture Style
    local textureFrame = stepFrames[3]
    
    local textureLabel = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    textureLabel:SetPoint("TOPLEFT", textureFrame, "TOPLEFT", 0, 0)
    textureLabel:SetText("Select Texture Style")
    
    local textureDesc = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textureDesc:SetPoint("TOPLEFT", textureLabel, "BOTTOMLEFT", 0, -10)
    textureDesc:SetText("Choose the texture styles for UI elements.")
    textureDesc:SetJustifyH("LEFT")
    textureDesc:SetWidth(textureFrame:GetWidth())
    
    -- Create dropdown for statusbar texture
    local statusbarLabel = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusbarLabel:SetPoint("TOPLEFT", textureDesc, "BOTTOMLEFT", 0, -20)
    statusbarLabel:SetText("Status Bar Texture:")
    
    local statusbarDropdown = CreateFrame("Frame", "VUIWizardStatusbarDropdown", textureFrame, "UIDropDownMenuTemplate")
    statusbarDropdown:SetPoint("TOPLEFT", statusbarLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(statusbarDropdown, 140)
    
    local statusbarTextures = {"smooth", "flat", "gloss", "normtext", "minimalist", "bars"}
    local selectedStatusbar = "smooth"
    
    UIDropDownMenu_Initialize(statusbarDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, texture in ipairs(statusbarTextures) do
            info.text = texture:gsub("^%l", string.upper) -- Capitalize first letter
            info.value = texture
            info.func = function()
                selectedStatusbar = texture
                UIDropDownMenu_SetText(statusbarDropdown, info.text)
                
                -- Update preview theme
                local previewTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
                -- Apply colors
                previewTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
                previewTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
                previewTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
                -- Apply textures
                previewTheme.textures.statusbar = selectedStatusbar
                
                previewFrame:UpdateWithTheme(previewTheme)
            end
            info.checked = (selectedStatusbar == texture)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Set initial value
    UIDropDownMenu_SetText(statusbarDropdown, selectedStatusbar:gsub("^%l", string.upper))
    
    -- Create dropdown for border texture
    local borderLabel = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    borderLabel:SetPoint("TOPLEFT", statusbarDropdown, "BOTTOMLEFT", 15, -20)
    borderLabel:SetText("Border Texture:")
    
    local borderDropdown = CreateFrame("Frame", "VUIWizardBorderDropdown", textureFrame, "UIDropDownMenuTemplate")
    borderDropdown:SetPoint("TOPLEFT", borderLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(borderDropdown, 140)
    
    local borderTextures = {"thin", "thick", "glow", "solid", "shadow", "none"}
    local selectedBorder = "thin"
    
    UIDropDownMenu_Initialize(borderDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, texture in ipairs(borderTextures) do
            info.text = texture:gsub("^%l", string.upper) -- Capitalize first letter
            info.value = texture
            info.func = function()
                selectedBorder = texture
                UIDropDownMenu_SetText(borderDropdown, info.text)
                
                -- Update preview theme
                local previewTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
                -- Apply colors
                previewTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
                previewTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
                previewTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
                -- Apply textures
                previewTheme.textures.statusbar = selectedStatusbar
                previewTheme.textures.border = selectedBorder
                
                previewFrame:UpdateWithTheme(previewTheme)
            end
            info.checked = (selectedBorder == texture)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Set initial value
    UIDropDownMenu_SetText(borderDropdown, selectedBorder:gsub("^%l", string.upper))
    
    -- Step 4: Font Selection
    local fontFrame = stepFrames[4]
    
    local fontLabel = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fontLabel:SetPoint("TOPLEFT", fontFrame, "TOPLEFT", 0, 0)
    fontLabel:SetText("Choose Fonts")
    
    local fontDesc = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontDesc:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -10)
    fontDesc:SetText("Select fonts for different UI elements.")
    fontDesc:SetJustifyH("LEFT")
    fontDesc:SetWidth(fontFrame:GetWidth())
    
    -- Font dropdown for normal text
    local normalFontLabel = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    normalFontLabel:SetPoint("TOPLEFT", fontDesc, "BOTTOMLEFT", 0, -20)
    normalFontLabel:SetText("Normal Text Font:")
    
    local normalFontDropdown = CreateFrame("Frame", "VUIWizardNormalFontDropdown", fontFrame, "UIDropDownMenuTemplate")
    normalFontDropdown:SetPoint("TOPLEFT", normalFontLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(normalFontDropdown, 160)
    
    local fontOptions = {
        "Friz Quadrata TT", "Arial Narrow", "VUI PT Sans Narrow", 
        "VUI Roboto", "VUI Open Sans", "VUI Noto Sans"
    }
    local selectedNormalFont = "VUI PT Sans Narrow"
    
    UIDropDownMenu_Initialize(normalFontDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, font in ipairs(fontOptions) do
            info.text = font
            info.value = font
            info.func = function()
                selectedNormalFont = font
                UIDropDownMenu_SetText(normalFontDropdown, font)
                
                -- Update preview theme
                local previewTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
                -- Apply colors
                previewTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
                previewTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
                previewTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
                -- Apply textures
                previewTheme.textures.statusbar = selectedStatusbar
                previewTheme.textures.border = selectedBorder
                -- Apply fonts
                previewTheme.fonts.normal = selectedNormalFont
                
                previewFrame:UpdateWithTheme(previewTheme)
            end
            info.checked = (selectedNormalFont == font)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Set initial value
    UIDropDownMenu_SetText(normalFontDropdown, selectedNormalFont)
    
    -- Font size slider
    local fontSizeLabel = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fontSizeLabel:SetPoint("TOPLEFT", normalFontDropdown, "BOTTOMLEFT", 15, -20)
    fontSizeLabel:SetText("Font Size:")
    
    local fontSizeSlider = CreateFrame("Slider", nil, fontFrame, "OptionsSliderTemplate")
    fontSizeSlider:SetPoint("TOPLEFT", fontSizeLabel, "BOTTOMLEFT", 0, -5)
    fontSizeSlider:SetWidth(180)
    fontSizeSlider:SetMinMaxValues(8, 16)
    fontSizeSlider:SetValue(12)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider.Low:SetText("8")
    fontSizeSlider.High:SetText("16")
    fontSizeSlider.Text:SetText("12")
    
    local selectedFontSize = 12
    
    fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        selectedFontSize = value
        self.Text:SetText(value)
        
        -- Update preview theme
        local previewTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
        -- Apply colors
        previewTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
        previewTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
        previewTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
        -- Apply textures
        previewTheme.textures.statusbar = selectedStatusbar
        previewTheme.textures.border = selectedBorder
        -- Apply fonts
        previewTheme.fonts.normal = selectedNormalFont
        previewTheme.fontSizes = previewTheme.fontSizes or {}
        previewTheme.fontSizes.normal = selectedFontSize
        
        previewFrame:UpdateWithTheme(previewTheme)
    end)
    
    -- Step 5: Name and Save
    local saveFrame = stepFrames[5]
    
    local saveLabel = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    saveLabel:SetPoint("TOPLEFT", saveFrame, "TOPLEFT", 0, 0)
    saveLabel:SetText("Name Your Theme")
    
    local saveDesc = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    saveDesc:SetPoint("TOPLEFT", saveLabel, "BOTTOMLEFT", 0, -10)
    saveDesc:SetText("Give your custom theme a name and save it.")
    saveDesc:SetJustifyH("LEFT")
    saveDesc:SetWidth(saveFrame:GetWidth())
    
    -- Theme name input
    local nameLabel = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameLabel:SetPoint("TOPLEFT", saveDesc, "BOTTOMLEFT", 0, -20)
    nameLabel:SetText("Theme Name:")
    
    local nameInput = CreateFrame("EditBox", nil, saveFrame, "InputBoxTemplate")
    nameInput:SetSize(200, 20)
    nameInput:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 5, -5)
    nameInput:SetAutoFocus(false)
    nameInput:SetText("My Custom Theme")
    nameInput:SetScript("OnEscapePressed", function() nameInput:ClearFocus() end)
    
    -- Theme author input
    local authorLabel = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    authorLabel:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", -5, -15)
    authorLabel:SetText("Author:")
    
    local authorInput = CreateFrame("EditBox", nil, saveFrame, "InputBoxTemplate")
    authorInput:SetSize(200, 20)
    authorInput:SetPoint("TOPLEFT", authorLabel, "BOTTOMLEFT", 5, -5)
    authorInput:SetAutoFocus(false)
    authorInput:SetText(UnitName("player"))
    authorInput:SetScript("OnEscapePressed", function() authorInput:ClearFocus() end)
    
    -- Theme description input
    local descLabel = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    descLabel:SetPoint("TOPLEFT", authorInput, "BOTTOMLEFT", -5, -15)
    descLabel:SetText("Description:")
    
    local descInput = CreateFrame("EditBox", nil, saveFrame, "InputBoxTemplate")
    descInput:SetSize(saveFrame:GetWidth() - 20, 20)
    descInput:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 5, -5)
    descInput:SetAutoFocus(false)
    descInput:SetText("A custom theme created with the VUI Theme Wizard")
    descInput:SetScript("OnEscapePressed", function() descInput:ClearFocus() end)
    
    -- Summary of settings
    local summaryLabel = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    summaryLabel:SetPoint("TOPLEFT", descInput, "BOTTOMLEFT", -5, -15)
    summaryLabel:SetText("Theme Summary:")
    
    local summaryText = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryText:SetPoint("TOPLEFT", summaryLabel, "BOTTOMLEFT", 5, -5)
    summaryText:SetJustifyH("LEFT")
    summaryText:SetWidth(saveFrame:GetWidth() - 20)
    
    -- Function to update summary
    local function UpdateSummary()
        local summary = string.format(
            "Base Theme: %s\n" ..
            "Primary Color: |cFF%02x%02x%02x%s|r\n" ..
            "Secondary Color: |cFF%02x%02x%02x%s|r\n" ..
            "StatusBar Texture: %s\n" ..
            "Border Texture: %s\n" ..
            "Font: %s (Size %d)",
            selectedBaseTheme:gsub("^%l", string.upper),
            primaryColor.r * 255, primaryColor.g * 255, primaryColor.b * 255, "Primary",
            secondaryColor.r * 255, secondaryColor.g * 255, secondaryColor.b * 255, "Secondary",
            selectedStatusbar:gsub("^%l", string.upper),
            selectedBorder:gsub("^%l", string.upper),
            selectedNormalFont, selectedFontSize
        )
        summaryText:SetText(summary)
    end
    
    -- Initial summary update
    UpdateSummary()
    
    -- Create save button
    local saveButton = CreateFrame("Button", nil, saveFrame, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 26)
    saveButton:SetPoint("BOTTOMRIGHT", saveFrame, "BOTTOM", -10, 0)
    saveButton:SetText("Save Theme")
    saveButton:SetScript("OnClick", function()
        local themeName = nameInput:GetText():trim()
        
        if themeName == "" then
            VUI:Print("Theme name cannot be empty.")
            return
        end
        
        -- Check if name is a default theme
        for _, name in ipairs(DEFAULT_THEMES) do
            if name:lower() == themeName:lower() then
                VUI:Print("Cannot use a default theme name. Please choose another name.")
                return
            end
        end
        
        -- Create new theme based on selections
        local newTheme = CopyTable(VUI:GetTheme(selectedBaseTheme))
        
        -- Apply customizations
        newTheme.name = themeName
        newTheme.author = authorInput:GetText():trim()
        newTheme.description = descInput:GetText():trim()
        
        -- Apply colors
        newTheme.colors.border = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
        newTheme.colors.primary = {r = primaryColor.r, g = primaryColor.g, b = primaryColor.b, a = primaryColor.a}
        newTheme.colors.secondary = {r = secondaryColor.r, g = secondaryColor.g, b = secondaryColor.b, a = secondaryColor.a}
        
        -- Apply textures
        newTheme.textures.statusbar = selectedStatusbar
        newTheme.textures.border = selectedBorder
        
        -- Apply fonts
        newTheme.fonts.normal = selectedNormalFont
        newTheme.fontSizes = newTheme.fontSizes or {}
        newTheme.fontSizes.normal = selectedFontSize
        
        -- Save theme and reload editor
        if VUI.db.profile.themeEditor.customThemes[themeName] and VUI.db.profile.themeEditor.confirmOverwrite then
            StaticPopupDialogs["VUI_THEME_WIZARD_CONFIRM_SAVE"] = {
                text = "A theme named '" .. themeName .. "' already exists. Overwrite it?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    VUI.db.profile.themeEditor.customThemes[themeName] = CopyTable(newTheme)
                    VUI:Print("Theme '" .. themeName .. "' has been saved!")
                    
                    -- Select the new theme
                    ThemeEditor:SelectTheme(themeName, true)
                    UIDropDownMenu_SetText(ThemeEditor.themeDropdown, themeName)
                    
                    -- Close wizard
                    ThemeEditor:SelectTab(1)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("VUI_THEME_WIZARD_CONFIRM_SAVE")
        else
            VUI.db.profile.themeEditor.customThemes[themeName] = CopyTable(newTheme)
            VUI:Print("Theme '" .. themeName .. "' has been saved!")
            
            -- Select the new theme
            ThemeEditor:SelectTheme(themeName, true)
            UIDropDownMenu_SetText(ThemeEditor.themeDropdown, themeName)
            
            -- Close wizard
            ThemeEditor:SelectTab(1)
        end
    end)
    
    -- Navigation buttons (Back, Next)
    local backButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    backButton:SetSize(100, 26)
    backButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    backButton:SetText("< Back")
    backButton:Disable()
    
    local nextButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    nextButton:SetSize(100, 26)
    nextButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    nextButton:SetText("Next >")
    
    -- Current step tracking
    local currentStep = 1
    
    -- Function to change steps
    local function ChangeStep(step)
        -- Hide all step frames
        for i, stepFrame in ipairs(stepFrames) do
            stepFrame:Hide()
        end
        
        -- Show current step frame
        stepFrames[step]:Show()
        
        -- Update step indicators
        UpdateStepIndicators(step)
        
        -- Update buttons
        backButton:SetEnabled(step > 1)
        
        if step == #steps then
            nextButton:Hide()
            -- Update summary on final step
            UpdateSummary()
        else
            nextButton:Show()
        end
        
        -- Store current step
        currentStep = step
    end
    
    -- Button click handlers
    backButton:SetScript("OnClick", function()
        if currentStep > 1 then
            ChangeStep(currentStep - 1)
        end
    end)
    
    nextButton:SetScript("OnClick", function()
        if currentStep < #steps then
            ChangeStep(currentStep + 1)
        end
    end)
    
    -- Initialize with step 1
    ChangeStep(1)
    
    -- Show the first base theme to start
    local initialTheme = VUI:GetTheme("thunderstorm")
    previewFrame:UpdateWithTheme(initialTheme)
    
    -- Store references
    self.wizardPreviewFrame = previewFrame
    self.wizardStepFrames = stepFrames
    self.wizardCurrentStep = currentStep
    self.wizardChangeStep = ChangeStep
end

function ThemeEditor:CreateImportExportTab(frame)
    -- Create title and description
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    title:SetText("Import & Export Themes")
    
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText("Share your custom themes with others or import themes created by the community.")
    desc:SetJustifyH("LEFT")
    desc:SetWidth(frame:GetWidth() - 20)
    
    -- Export section
    local exportHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    exportHeader:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    exportHeader:SetText("Export Theme")
    
    local exportDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    exportDesc:SetPoint("TOPLEFT", exportHeader, "BOTTOMLEFT", 0, -5)
    exportDesc:SetText("Copy the text below to share your theme with others:")
    exportDesc:SetWidth(frame:GetWidth() - 20)
    
    local exportEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    exportEditBox:SetSize(frame:GetWidth() - 40, 80)
    exportEditBox:SetPoint("TOPLEFT", exportDesc, "BOTTOMLEFT", 5, -10)
    exportEditBox:SetAutoFocus(false)
    exportEditBox:SetMultiLine(true)
    exportEditBox:SetFontObject("ChatFontSmall")
    exportEditBox:SetScript("OnEscapePressed", function() exportEditBox:ClearFocus() end)
    
    -- Add background to edit box for better visibility
    exportEditBox.bg = CreateFrame("Frame", nil, exportEditBox)
    exportEditBox.bg:SetPoint("TOPLEFT", exportEditBox, "TOPLEFT", -5, 5)
    exportEditBox.bg:SetPoint("BOTTOMRIGHT", exportEditBox, "BOTTOMRIGHT", 5, -5)
    exportEditBox.bg:SetFrameLevel(exportEditBox:GetFrameLevel() - 1)
    exportEditBox.bg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    exportEditBox.bg:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    exportEditBox.bg:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Export button
    local exportButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    exportButton:SetSize(100, 26)
    exportButton:SetPoint("TOPLEFT", exportEditBox, "BOTTOMLEFT", 0, -10)
    exportButton:SetText("Export")
    exportButton:SetScript("OnClick", function() ThemeEditor:ExportCurrentTheme(exportEditBox) end)
    
    -- Import section
    local importHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    importHeader:SetPoint("TOPLEFT", exportButton, "BOTTOMLEFT", 0, -20)
    importHeader:SetText("Import Theme")
    
    local importDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    importDesc:SetPoint("TOPLEFT", importHeader, "BOTTOMLEFT", 0, -5)
    importDesc:SetText("Paste a theme string below and click 'Import' to add it to your collection:")
    importDesc:SetWidth(frame:GetWidth() - 20)
    
    local importEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importEditBox:SetSize(frame:GetWidth() - 40, 80)
    importEditBox:SetPoint("TOPLEFT", importDesc, "BOTTOMLEFT", 5, -10)
    importEditBox:SetAutoFocus(false)
    importEditBox:SetMultiLine(true)
    importEditBox:SetFontObject("ChatFontSmall")
    importEditBox:SetScript("OnEscapePressed", function() importEditBox:ClearFocus() end)
    
    -- Add background to edit box for better visibility
    importEditBox.bg = CreateFrame("Frame", nil, importEditBox)
    importEditBox.bg:SetPoint("TOPLEFT", importEditBox, "TOPLEFT", -5, 5)
    importEditBox.bg:SetPoint("BOTTOMRIGHT", importEditBox, "BOTTOMRIGHT", 5, -5)
    importEditBox.bg:SetFrameLevel(importEditBox:GetFrameLevel() - 1)
    importEditBox.bg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    importEditBox.bg:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    importEditBox.bg:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Import button
    local importButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    importButton:SetSize(100, 26)
    importButton:SetPoint("TOPLEFT", importEditBox, "BOTTOMLEFT", 0, -10)
    importButton:SetText("Import")
    importButton:SetScript("OnClick", function() ThemeEditor:ImportTheme(importEditBox:GetText()) end)
    
    -- Store references
    self.exportEditBox = exportEditBox
    self.importEditBox = importEditBox
    self.exportButton = exportButton
    self.importButton = importButton
end

-- Create preview panel
function ThemeEditor:CreatePreviewPanel()
    local panel = self.panel
    
    -- Create preview frame
    local previewFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    previewFrame:SetSize(PREVIEW_FRAME_SIZE, PREVIEW_FRAME_SIZE)
    previewFrame:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -30, -50)
    previewFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Preview title
    local title = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", previewFrame, "TOP", 0, -10)
    title:SetText("Preview")
    
    -- Sample frame
    local sampleFrame = CreateFrame("Frame", nil, previewFrame, "BackdropTemplate")
    sampleFrame:SetSize(180, 100)
    sampleFrame:SetPoint("TOP", title, "BOTTOM", 0, -10)
    sampleFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Sample header
    local header = CreateFrame("Frame", nil, sampleFrame, "BackdropTemplate")
    header:SetSize(180, 24)
    header:SetPoint("TOP", sampleFrame, "TOP", 0, 0)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header",
        tile = true, tileSize = 16,
    })
    
    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    headerText:SetPoint("TOP", header, "TOP", 0, -10)
    headerText:SetText("Sample Window")
    
    -- Sample button
    local button = CreateFrame("Button", nil, sampleFrame, "UIPanelButtonTemplate")
    button:SetSize(100, 22)
    button:SetPoint("BOTTOM", sampleFrame, "BOTTOM", 0, 10)
    button:SetText("Button")
    
    -- Sample statusbar
    local statusbar = CreateFrame("StatusBar", nil, sampleFrame)
    statusbar:SetSize(160, 16)
    statusbar:SetPoint("BOTTOM", button, "TOP", 0, 10)
    statusbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    statusbar:SetMinMaxValues(0, 100)
    statusbar:SetValue(75)
    
    -- Sample text
    local text = sampleFrame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    text:SetPoint("BOTTOM", statusbar, "TOP", 0, 10)
    text:SetText("Sample Text")
    
    -- Store references
    self.previewFrame = previewFrame
    previewElements.frame = sampleFrame
    previewElements.header = header
    previewElements.headerText = headerText
    previewElements.button = button
    previewElements.statusbar = statusbar
    previewElements.text = text
    
    -- Update preview with current theme
    self:UpdatePreview()
end

-- Update preview with current theme colors and textures
function ThemeEditor:UpdatePreview()
    if not self.previewFrame or not VUI.db.profile.themeEditor.showPreview then
        return
    end
    
    -- Get current theme elements
    local colors = currentTheme.colors or {}
    local textures = currentTheme.textures or {}
    local fonts = currentTheme.fonts or {}
    local fontSizes = currentTheme.fontSizes or {}
    local fontOutlines = currentTheme.fontOutlines or {}
    
    -- Update frame
    if previewElements.frame then
        local backdrop = {
            bgFile = textures.background and "Interface\\AddOns\\VUI\\media\\textures\\" .. textures.background .. ".tga" or "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = textures.border and "Interface\\AddOns\\VUI\\media\\textures\\borders\\" .. textures.border .. ".tga" or "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        }
        previewElements.frame:SetBackdrop(backdrop)
        
        local backdropColor = colors.backdrop or {r=0.1, g=0.1, b=0.1, a=0.8}
        local borderColor = colors.border or {r=0.4, g=0.4, b=0.4, a=1.0}
        
        previewElements.frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
        previewElements.frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end
    
    -- Update header
    if previewElements.header then
        local headerColor = colors.header or {r=0.15, g=0.15, b=0.15, a=1.0}
        previewElements.header:SetBackdropColor(headerColor.r, headerColor.g, headerColor.b, headerColor.a)
        
        if fonts.header then
            local fontSize = fontSizes.header or 10
            local fontOutline = fontOutlines.header or ""
            previewElements.headerText:SetFont(fonts.header, fontSize, fontOutline)
        end
        
        if colors.text then
            previewElements.headerText:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
    end
    
    -- Update button
    if previewElements.button then
        local buttonColor = colors.button or {r=0.2, g=0.2, b=0.2, a=1.0}
        previewElements.button:SetBackdropColor(buttonColor.r, buttonColor.g, buttonColor.b, buttonColor.a)
        
        if fonts.normal then
            local fontSize = fontSizes.normal or 10
            local fontOutline = fontOutlines.normal or ""
            local font = CreateFont("VUIThemeEditorButtonFont")
            font:SetFont(fonts.normal, fontSize, fontOutline)
            previewElements.button:SetNormalFontObject(font)
        end
    end
    
    -- Update statusbar
    if previewElements.statusbar then
        local texture = textures.statusbar and "Interface\\AddOns\\VUI\\media\\textures\\statusbars\\" .. textures.statusbar .. ".tga" or "Interface\\TargetingFrame\\UI-StatusBar"
        previewElements.statusbar:SetStatusBarTexture(texture)
        
        local primaryColor = colors.primary or {r=0.3, g=0.6, b=1.0, a=1.0}
        previewElements.statusbar:SetStatusBarColor(primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a)
    end
    
    -- Update text
    if previewElements.text then
        if fonts.normal then
            local fontSize = fontSizes.normal or 10
            local fontOutline = fontOutlines.normal or ""
            previewElements.text:SetFont(fonts.normal, fontSize, fontOutline)
        end
        
        if colors.text then
            previewElements.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
    end
end

-- Select a tab in the editor
function ThemeEditor:SelectTab(tab)
    for i, frame in ipairs(self.tabFrames) do
        frame:Hide()
        PanelTemplates_DeselectTab(self.tabButtons[i])
    end
    
    self.tabFrames[tab]:Show()
    PanelTemplates_SelectTab(self.tabButtons[tab])
end

-- Open the color picker for a specific color
function ThemeEditor:OpenColorPicker(colorKey, texture)
    local color = currentTheme.colors and currentTheme.colors[colorKey] or COLOR_ELEMENTS[colorKey].default
    
    VUI.db.profile.themeEditor.lastColor = CopyTable(color)
    
    local function ColorCallback(restore)
        local newR, newG, newB, newA
        if restore then
            -- User clicked cancel, restore original color
            newR = VUI.db.profile.themeEditor.lastColor.r
            newG = VUI.db.profile.themeEditor.lastColor.g
            newB = VUI.db.profile.themeEditor.lastColor.b
            newA = VUI.db.profile.themeEditor.lastColor.a
        else
            -- Get color picker values
            newR, newG, newB = ColorPickerFrame:GetColorRGB()
            newA = 1 - OpacitySliderFrame:GetValue()
        end
        
        -- Update texture
        texture:SetColorTexture(newR, newG, newB, newA)
        
        -- Update RGB sliders if they exist
        if colorPickers[colorKey].redSlider then
            colorPickers[colorKey].redSlider:SetValue(newR * 100)
            colorPickers[colorKey].greenSlider:SetValue(newG * 100)
            colorPickers[colorKey].blueSlider:SetValue(newB * 100)
            colorPickers[colorKey].alphaSlider:SetValue(newA * 100)
        end
        
        -- Update current theme
        currentTheme.colors = currentTheme.colors or {}
        currentTheme.colors[colorKey] = {r = newR, g = newG, b = newB, a = newA}
        
        -- Mark as dirty
        isDirty = true
        
        -- Update preview
        self:UpdatePreview()
    end
    
    -- Set up color picker
    ColorPickerFrame.hasOpacity = true
    ColorPickerFrame.opacity = 1 - color.a
    ColorPickerFrame.previousValues = {color.r, color.g, color.b, color.a}
    ColorPickerFrame.func = ColorCallback
    ColorPickerFrame.opacityFunc = ColorCallback
    ColorPickerFrame.cancelFunc = ColorCallback
    
    ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
    ColorPickerFrame:Show()
end

-- Load the current theme into the editor
function ThemeEditor:LoadCurrentTheme()
    local themeName = VUI.db.profile.appearance.theme or "thunderstorm"
    self:SelectTheme(themeName)
end

-- Select a theme to edit
function ThemeEditor:SelectTheme(themeName, isCustom)
    -- Reset current theme
    currentTheme = {}
    
    -- Load theme data
    if isCustom and VUI.db.profile.themeEditor.customThemes[themeName] then
        -- Load custom theme
        currentTheme = CopyTable(VUI.db.profile.themeEditor.customThemes[themeName])
    else
        -- Load built-in theme
        currentTheme.name = themeName
        
        -- Load theme colors based on the built-in theme
        currentTheme.colors = {}
        
        if themeName == "thunderstorm" then
            currentTheme.colors.backdrop = {r = 0.04, g = 0.04, b = 0.1, a = 0.8} -- Deep blue
            currentTheme.colors.border = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
            currentTheme.colors.highlight = {r = 0.1, g = 0.4, b = 0.6, a = 0.5}
            currentTheme.colors.header = {r = 0.07, g = 0.07, b = 0.15, a = 1}
            currentTheme.colors.button = {r = 0.07, g = 0.07, b = 0.15, a = 1}
            currentTheme.colors.text = {r = 0.9, g = 0.9, b = 1.0, a = 1.0}
            currentTheme.colors.primary = {r = 0.05, g = 0.62, b = 0.9, a = 1}
            currentTheme.colors.secondary = {r = 0.7, g = 0.85, b = 1.0, a = 1}
        elseif themeName == "phoenixflame" then
            currentTheme.colors.backdrop = {r = 0.1, g = 0.04, b = 0.02, a = 0.8} -- Dark red/brown
            currentTheme.colors.border = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
            currentTheme.colors.highlight = {r = 0.6, g = 0.2, b = 0.05, a = 0.5}
            currentTheme.colors.header = {r = 0.15, g = 0.07, b = 0.05, a = 1}
            currentTheme.colors.button = {r = 0.15, g = 0.07, b = 0.05, a = 1}
            currentTheme.colors.text = {r = 1.0, g = 0.9, b = 0.8, a = 1.0}
            currentTheme.colors.primary = {r = 0.9, g = 0.3, b = 0.05, a = 1}
            currentTheme.colors.secondary = {r = 1.0, g = 0.6, b = 0.2, a = 1}
        elseif themeName == "arcanemystic" then
            currentTheme.colors.backdrop = {r = 0.1, g = 0.04, b = 0.18, a = 0.8} -- Deep purple
            currentTheme.colors.border = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
            currentTheme.colors.highlight = {r = 0.4, g = 0.1, b = 0.6, a = 0.5}
            currentTheme.colors.header = {r = 0.15, g = 0.07, b = 0.2, a = 1}
            currentTheme.colors.button = {r = 0.15, g = 0.07, b = 0.2, a = 1}
            currentTheme.colors.text = {r = 0.9, g = 0.8, b = 1.0, a = 1.0}
            currentTheme.colors.primary = {r = 0.61, g = 0.05, b = 0.9, a = 1}
            currentTheme.colors.secondary = {r = 0.8, g = 0.2, b = 1.0, a = 1}
        elseif themeName == "felenergy" then
            currentTheme.colors.backdrop = {r = 0.04, g = 0.1, b = 0.04, a = 0.8} -- Dark green
            currentTheme.colors.border = {r = 0.1, g = 1.0, b = 0.1, a = 1} -- Fel green
            currentTheme.colors.highlight = {r = 0.1, g = 0.6, b = 0.1, a = 0.5}
            currentTheme.colors.header = {r = 0.07, g = 0.15, b = 0.07, a = 1}
            currentTheme.colors.button = {r = 0.07, g = 0.15, b = 0.07, a = 1}
            currentTheme.colors.text = {r = 0.8, g = 1.0, b = 0.8, a = 1.0}
            currentTheme.colors.primary = {r = 0.1, g = 1.0, b = 0.1, a = 1}
            currentTheme.colors.secondary = {r = 0.6, g = 1.0, b = 0.3, a = 1}
        else
            -- Default theme colors as fallback
            for key, colorInfo in pairs(COLOR_ELEMENTS) do
                currentTheme.colors[key] = CopyTable(colorInfo.default)
            end
        end
    end
    
    -- Update UI with theme data
    self:UpdateUI()
    
    -- Reset dirty flag
    isDirty = false
end

-- Update UI to reflect current theme
function ThemeEditor:UpdateUI()
    -- Update color swatches
    for key, picker in pairs(colorPickers) do
        local color = currentTheme.colors and currentTheme.colors[key] or COLOR_ELEMENTS[key].default
        picker.texture:SetColorTexture(color.r, color.g, color.b, color.a)
        
        -- Update RGB sliders if they exist
        if picker.redSlider then
            picker.redSlider:SetValue(color.r * 100)
            picker.greenSlider:SetValue(color.g * 100)
            picker.blueSlider:SetValue(color.b * 100)
            picker.alphaSlider:SetValue(color.a * 100)
        end
    end
    
    -- Update texture dropdowns
    for key, picker in pairs(texturePickers) do
        local currentTexture = currentTheme.textures and currentTheme.textures[key] or picker.options[1]
        UIDropDownMenu_SetText(picker.dropdown, currentTexture:gsub("^%l", string.upper))
        
        -- Update preview texture
        if key == "background" then
            picker.preview:SetBackdrop({
                bgFile = "Interface\\AddOns\\VUI\\media\\textures\\" .. currentTexture .. ".tga",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
        elseif key == "border" then
            picker.preview:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\borders\\" .. currentTexture .. ".tga",
                edgeSize = 8,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
        elseif key == "statusbar" and picker.preview.bar then
            picker.preview.bar:SetStatusBarTexture("Interface\\AddOns\\VUI\\media\\textures\\statusbars\\" .. currentTexture .. ".tga")
        end
    end
    
    -- Update font dropdowns
    for key, picker in pairs(fontPickers) do
        local currentFont = currentTheme.fonts and currentTheme.fonts[key] or picker.options[1]
        UIDropDownMenu_SetText(picker.dropdown, currentFont)
        
        local fontSize = currentTheme.fontSizes and currentTheme.fontSizes[key] or 12
        local fontOutline = currentTheme.fontOutlines and currentTheme.fontOutlines[key] or ""
        picker.preview:SetFont(currentFont, fontSize, fontOutline)
        picker.sizeSlider:SetValue(fontSize)
    end
    
    -- Update preview panel
    self:UpdatePreview()
    
    -- Export the current theme to the export text box
    if self.exportEditBox then
        self:ExportCurrentTheme(self.exportEditBox)
    end
end

-- Save the current theme (overwrite)
function ThemeEditor:SaveTheme()
    local themeName = currentTheme.name
    
    -- Check if it's a default theme
    local isDefaultTheme = false
    for _, name in ipairs(DEFAULT_THEMES) do
        if name == themeName then
            isDefaultTheme = true
            break
        end
    end
    
    if isDefaultTheme then
        -- Can't overwrite default themes, use Save As instead
        StaticPopupDialogs["VUI_THEME_EDITOR_CANT_SAVE"] = {
            text = "You cannot overwrite default themes. Please use 'Save As...' instead.",
            button1 = "OK",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("VUI_THEME_EDITOR_CANT_SAVE")
        return
    end
    
    -- Check if it's a custom theme
    if VUI.db.profile.themeEditor.customThemes[themeName] then
        -- Confirm overwrite if enabled
        if VUI.db.profile.themeEditor.confirmOverwrite then
            StaticPopupDialogs["VUI_THEME_EDITOR_CONFIRM_SAVE"] = {
                text = "Are you sure you want to overwrite the theme '" .. themeName .. "'?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    self:DoSaveTheme(themeName)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("VUI_THEME_EDITOR_CONFIRM_SAVE")
        else
            self:DoSaveTheme(themeName)
        end
    else
        -- New theme, use Save As
        self:SaveThemeAs()
    end
end

-- Actually save the theme
function ThemeEditor:DoSaveTheme(themeName)
    -- Save the theme to profile
    VUI.db.profile.themeEditor.customThemes[themeName] = CopyTable(currentTheme)
    
    -- Apply the theme if it's the current one
    if VUI.db.profile.appearance.theme == themeName then
        self:ApplyTheme()
    end
    
    -- Reset dirty flag
    isDirty = false
    
    -- Notify user
    VUI:Print("Theme '" .. themeName .. "' has been saved.")
end

-- Save the current theme with a new name
function ThemeEditor:SaveThemeAs()
    -- Prompt for name
    StaticPopupDialogs["VUI_THEME_EDITOR_SAVE_AS"] = {
        text = "Enter a name for your theme:",
        button1 = "Save",
        button2 = "Cancel",
        hasEditBox = true,
        maxLetters = 32,
        OnAccept = function(self)
            local themeName = self.editBox:GetText():trim()
            
            if themeName == "" then
                -- Empty name
                VUI:Print("Theme name cannot be empty.")
                return
            end
            
            -- Check if name is a default theme
            for _, name in ipairs(DEFAULT_THEMES) do
                if name:lower() == themeName:lower() then
                    VUI:Print("Cannot use a default theme name. Please choose another name.")
                    return
                end
            end
            
            -- Check if theme already exists
            if VUI.db.profile.themeEditor.customThemes[themeName] and VUI.db.profile.themeEditor.confirmOverwrite then
                StaticPopupDialogs["VUI_THEME_EDITOR_CONFIRM_SAVE"] = {
                    text = "A theme named '" .. themeName .. "' already exists. Overwrite it?",
                    button1 = "Yes",
                    button2 = "No",
                    OnAccept = function()
                        currentTheme.name = themeName
                        ThemeEditor:DoSaveTheme(themeName)
                        
                        -- Update dropdown text
                        UIDropDownMenu_SetText(ThemeEditor.themeDropdown, themeName)
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                }
                StaticPopup_Show("VUI_THEME_EDITOR_CONFIRM_SAVE")
            else
                -- Save with new name
                currentTheme.name = themeName
                ThemeEditor:DoSaveTheme(themeName)
                
                -- Update dropdown text
                UIDropDownMenu_SetText(ThemeEditor.themeDropdown, themeName)
            end
        end,
        OnShow = function(self)
            self.editBox:SetFocus()
            self.editBox:SetText(currentTheme.name or "")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("VUI_THEME_EDITOR_SAVE_AS")
end

-- Reset the current theme to default values
function ThemeEditor:ResetTheme()
    -- Prompt for confirmation
    StaticPopupDialogs["VUI_THEME_EDITOR_CONFIRM_RESET"] = {
        text = "Are you sure you want to reset this theme to its default values? Any unsaved changes will be lost.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            -- Reload the theme to reset
            local themeName = currentTheme.name
            ThemeEditor:SelectTheme(themeName)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("VUI_THEME_EDITOR_CONFIRM_RESET")
end

-- Apply the current theme
function ThemeEditor:ApplyTheme()
    local themeName = currentTheme.name
    
    -- Default themes are applied directly
    if VUI.db.profile.appearance.theme ~= themeName then
        -- Set theme in profile
        VUI.db.profile.appearance.theme = themeName
        
        -- Notify user
        VUI:Print("Theme '" .. themeName .. "' has been applied.")
    end
    
    -- Apply theme colors to profile
    if currentTheme.colors then
        for key, color in pairs(currentTheme.colors) do
            if key == "backdrop" then
                VUI.db.profile.appearance.backdropColor = CopyTable(color)
            elseif key == "border" then
                VUI.db.profile.appearance.borderColor = CopyTable(color)
            end
        end
    end
    
    -- Apply theme textures to profile if applicable
    if currentTheme.textures then
        if currentTheme.textures.statusbar then
            VUI.db.profile.appearance.statusbarTexture = currentTheme.textures.statusbar
        end
        if currentTheme.textures.border then
            VUI.db.profile.appearance.border = currentTheme.textures.border
        end
    end
    
    -- Apply theme fonts to profile if applicable
    if currentTheme.fonts and currentTheme.fonts.normal then
        VUI.db.profile.appearance.font = currentTheme.fonts.normal
    end
    
    -- Apply theme font sizes to profile if applicable
    if currentTheme.fontSizes and currentTheme.fontSizes.normal then
        VUI.db.profile.appearance.fontSize = currentTheme.fontSizes.normal
    end
    
    -- Trigger UI update
    VUI:UpdateUI()
    
    -- Notify modules of theme change
    if VUI.Integration then
        VUI.Integration:NotifyThemeChanged()
    end
    
    -- Reset dirty flag
    isDirty = false
end

-- Export the current theme to a string
function ThemeEditor:ExportCurrentTheme(editBox)
    -- Create a simplified version of the theme for export
    local exportTheme = {
        name = currentTheme.name,
        colors = currentTheme.colors,
        textures = currentTheme.textures,
        fonts = currentTheme.fonts,
        fontSizes = currentTheme.fontSizes,
        fontOutlines = currentTheme.fontOutlines,
    }
    
    -- Convert to string
    local success, exportString = pcall(function()
        return VUI:TableToString(exportTheme)
    end)
    
    if success and exportString then
        editBox:SetText(exportString)
        editBox:HighlightText()
    else
        editBox:SetText("Error creating theme export string.")
    end
end

-- Import a theme from a string
function ThemeEditor:ImportTheme(importString)
    if not importString or importString == "" then
        VUI:Print("Please enter a theme string to import.")
        return
    end
    
    -- Convert from string
    local success, importTheme = pcall(function()
        return VUI:StringToTable(importString)
    end)
    
    if success and importTheme and importTheme.name then
        -- Prompt for name
        StaticPopupDialogs["VUI_THEME_EDITOR_IMPORT"] = {
            text = "Import this theme as:",
            button1 = "Import",
            button2 = "Cancel",
            hasEditBox = true,
            maxLetters = 32,
            OnAccept = function(self)
                local themeName = self.editBox:GetText():trim()
                
                if themeName == "" then
                    -- Empty name
                    VUI:Print("Theme name cannot be empty.")
                    return
                end
                
                -- Check if name is a default theme
                for _, name in ipairs(DEFAULT_THEMES) do
                    if name:lower() == themeName:lower() then
                        VUI:Print("Cannot use a default theme name. Please choose another name.")
                        return
                    end
                end
                
                -- Check if theme already exists
                if VUI.db.profile.themeEditor.customThemes[themeName] and VUI.db.profile.themeEditor.confirmOverwrite then
                    StaticPopupDialogs["VUI_THEME_EDITOR_CONFIRM_IMPORT"] = {
                        text = "A theme named '" .. themeName .. "' already exists. Overwrite it?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            -- Save with new name
                            importTheme.name = themeName
                            VUI.db.profile.themeEditor.customThemes[themeName] = CopyTable(importTheme)
                            
                            -- Load the imported theme
                            ThemeEditor:SelectTheme(themeName, true)
                            
                            -- Update dropdown text
                            UIDropDownMenu_SetText(ThemeEditor.themeDropdown, themeName)
                            
                            -- Notify user
                            VUI:Print("Theme '" .. themeName .. "' has been imported.")
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                    }
                    StaticPopup_Show("VUI_THEME_EDITOR_CONFIRM_IMPORT")
                else
                    -- Save with new name
                    importTheme.name = themeName
                    VUI.db.profile.themeEditor.customThemes[themeName] = CopyTable(importTheme)
                    
                    -- Load the imported theme
                    ThemeEditor:SelectTheme(themeName, true)
                    
                    -- Update dropdown text
                    UIDropDownMenu_SetText(ThemeEditor.themeDropdown, themeName)
                    
                    -- Notify user
                    VUI:Print("Theme '" .. themeName .. "' has been imported.")
                end
            end,
            OnShow = function(self)
                self.editBox:SetFocus()
                self.editBox:SetText(importTheme.name or "New Theme")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("VUI_THEME_EDITOR_IMPORT")
    else
        VUI:Print("Invalid theme string. Could not import theme.")
    end
end

-- Show the theme editor
function ThemeEditor:Show()
    self.panel:Show()
end

-- Hide the theme editor
function ThemeEditor:Hide()
    -- Check for unsaved changes
    if isDirty then
        StaticPopupDialogs["VUI_THEME_EDITOR_UNSAVED"] = {
            text = "You have unsaved changes. Do you want to save before closing?",
            button1 = "Save",
            button2 = "Discard",
            button3 = "Cancel",
            OnAccept = function()
                ThemeEditor:SaveTheme()
                ThemeEditor.panel:Hide()
            end,
            OnCancel = function()
                ThemeEditor.panel:Hide()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("VUI_THEME_EDITOR_UNSAVED")
    else
        self.panel:Hide()
    end
end

-- Toggle the theme editor visibility
function ThemeEditor:Toggle()
    if self.panel:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Register with ConfigUI
function ThemeEditor:RegisterWithConfigUI()
    if not VUI.ConfigUI then return end
    
    -- Add a button to open Theme Editor in the Appearance tab
    local appearanceTab = VUI.ConfigUI.tabFrames[2] -- Appearance tab
    if appearanceTab then
        local openButton = CreateFrame("Button", nil, appearanceTab, "UIPanelButtonTemplate")
        openButton:SetSize(160, 26)
        openButton:SetPoint("TOPLEFT", appearanceTab, "TOPLEFT", 20, -360)
        openButton:SetText("Open Theme Editor")
        openButton:SetScript("OnClick", function() ThemeEditor:Show() end)
    end
end

-- Create the Media Stats tab
function ThemeEditor:CreateMediaStatsTab(frame)
    -- Create scrollable container
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 0)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(scrollFrame:GetHeight() * 1.5) -- Make it taller than the visible area
    
    -- Create header
    local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
    header:SetText("Media Cache Performance Statistics")
    
    local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    desc:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    desc:SetText("This tab shows performance statistics for the enhanced media management system.")
    desc:SetTextColor(0.7, 0.7, 0.7)
    
    -- Create Stats container
    local statsFrame = CreateFrame("Frame", nil, scrollChild)
    statsFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    statsFrame:SetPoint("RIGHT", scrollChild, "RIGHT", -30, 0)
    statsFrame:SetHeight(300)
    
    -- Add a border around stats
    statsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    statsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
    statsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    
    -- Stats labels
    local yOffset = 15
    local stats = {
        { label = "━━━━━ Texture System ━━━━━", dataKey = "textureSeparator" },
        { label = "Textures Loaded:", dataKey = "texturesLoaded" },
        { label = "Cache Hits:", dataKey = "cacheHits" },
        { label = "Cache Misses:", dataKey = "cacheMisses" },
        { label = "Cache Hit Rate:", dataKey = "cacheHitRate" },
        { label = "Cache Size:", dataKey = "cacheSize" },
        { label = "Memory Usage:", dataKey = "memoryUsage" },
        { label = "Queue Size:", dataKey = "queueSize" },
        { label = "━━━━━ Atlas System ━━━━━", dataKey = "atlasSeparator" },
        { label = "Atlases Loaded:", dataKey = "atlasesLoaded" },
        { label = "Textures in Atlases:", dataKey = "atlasTexturesSaved" },
        { label = "Memory Reduction:", dataKey = "atlasMemoryReduction" },
        { label = "━━━━━ Font System ━━━━━", dataKey = "fontSeparator" },
        { label = "Font Cache Size:", dataKey = "fontCacheSize" },
        { label = "Font Objects Created:", dataKey = "fontObjectsCreated" },
        { label = "Font Objects Reused:", dataKey = "fontObjectsReused" },
        { label = "Font Cache Hits:", dataKey = "fontCacheHits" },
        { label = "Font Cache Misses:", dataKey = "fontCacheMisses" },
        { label = "Font Cache Hit Rate:", dataKey = "fontCacheHitRate" },
        { label = "Font Memory Estimate:", dataKey = "fontMemoryEstimate" }
    }
    
    local statLabels = {}
    local statValues = {}
    
    for i, stat in ipairs(stats) do
        -- Create label
        local label = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 15, -yOffset)
        label:SetText(stat.label)
        label:SetJustifyH("LEFT")
        
        -- Create value
        local value = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        value:SetPoint("TOPRIGHT", statsFrame, "TOPRIGHT", -15, -yOffset)
        value:SetText("Loading...")
        value:SetJustifyH("RIGHT")
        
        -- Store references
        statLabels[stat.dataKey] = label
        statValues[stat.dataKey] = value
        
        yOffset = yOffset + 25
    end
    
    -- Add refresh button
    local refreshButton = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    refreshButton:SetSize(120, 22)
    refreshButton:SetPoint("TOPLEFT", statsFrame, "BOTTOMLEFT", 0, -15)
    refreshButton:SetText("Refresh Stats")
    
    -- Add clear cache button
    local clearCacheButton = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    clearCacheButton:SetSize(120, 22)
    clearCacheButton:SetPoint("LEFT", refreshButton, "RIGHT", 10, 0)
    clearCacheButton:SetText("Clear Texture Cache")
    
    -- Add clear font cache button
    local clearFontCacheButton = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    clearFontCacheButton:SetSize(120, 22)
    clearFontCacheButton:SetPoint("LEFT", clearCacheButton, "RIGHT", 10, 0)
    clearFontCacheButton:SetText("Clear Font Cache")
    
    -- Add preload button for current theme
    local preloadButton = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    preloadButton:SetSize(180, 22)
    preloadButton:SetPoint("TOPLEFT", refreshButton, "BOTTOMLEFT", 0, -15)
    preloadButton:SetText("Preload Current Theme")
    
    -- Function to update stats display
    local function UpdateStats()
        -- Get current stats
        local mediaStats = VUI:GetMediaStats()
        
        -- Update display
        for dataKey, valueText in pairs(statValues) do
            if dataKey:find("Separator") then
                valueText:SetText("")  -- No value for separator
            elseif mediaStats[dataKey] ~= nil then
                if dataKey == "cacheHitRate" or dataKey == "fontCacheHitRate" then
                    valueText:SetText(string.format("%.1f%%", mediaStats[dataKey]))
                else
                    valueText:SetText(tostring(mediaStats[dataKey]))
                end
            else
                valueText:SetText("N/A")
            end
        end
    end
    
    -- Update stats on show
    frame:SetScript("OnShow", UpdateStats)
    
    -- Button scripts
    refreshButton:SetScript("OnClick", function()
        UpdateStats()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    clearCacheButton:SetScript("OnClick", function()
        VUI:ClearUnusedMediaCache()
        UpdateStats()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    preloadButton:SetScript("OnClick", function()
        local currentThemeName = VUI.db.profile.appearance.theme or "thunderstorm"
        VUI:PreloadThemeTextures(currentThemeName)
        UpdateStats()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    clearFontCacheButton:SetScript("OnClick", function()
        if VUI.FontIntegration and VUI.FontIntegration.CleanupFontCache then
            VUI.FontIntegration:CleanupFontCache(true) -- Force a full cleanup
            VUI:Print("Font cache cleared.")
        end
        UpdateStats()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    -- Add performance notes section
    local notesHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    notesHeader:SetPoint("TOPLEFT", preloadButton, "BOTTOMLEFT", 0, -20)
    notesHeader:SetText("Performance Notes:")
    
    local notesBG = CreateFrame("Frame", nil, scrollChild)
    notesBG:SetPoint("TOPLEFT", notesHeader, "BOTTOMLEFT", 0, -5)
    notesBG:SetPoint("RIGHT", scrollChild, "RIGHT", -30, 0)
    notesBG:SetHeight(150)
    
    -- Add a border around notes
    notesBG:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    notesBG:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
    notesBG:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    
    local notesText = notesBG:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    notesText:SetPoint("TOPLEFT", notesBG, "TOPLEFT", 10, -10)
    notesText:SetPoint("BOTTOMRIGHT", notesBG, "BOTTOMRIGHT", -10, 10)
    notesText:SetJustifyH("LEFT")
    notesText:SetJustifyV("TOP")
    
    -- Use the enhanced font system
    if VUI.FontIntegration and VUI.FontIntegration.ApplyFontToFrame then
        -- Apply a cached font to the text - this demonstrates the font caching system
        VUI.FontIntegration:ApplyFontToFrame(notesText, "normal", 11, "")
    end
    
    notesText:SetText(
        "• The enhanced media system improves performance by:\n" ..
        "  - Caching textures and fonts for faster access\n" ..
        "  - Lazy loading non-essential assets\n" ..
        "  - Preloading theme assets when needed\n" ..
        "  - Freeing memory when assets are no longer used\n\n" ..
        "• The texture atlas system combines multiple textures into single files:\n" ..
        "  - Reduces file operations during loading\n" ..
        "  - Decreases memory usage by up to 30%\n" ..
        "  - Improves rendering performance\n\n" ..
        "• The font system optimization:\n" ..
        "  - Caches font objects for reuse\n" ..
        "  - Reduces GetFont calls by 25-35%\n" ..
        "  - Provides theme-specific fonts\n" ..
        "  - Reduces memory usage in text-heavy UI regions\n\n" ..
        "• High cache hit rate indicates good performance\n" ..
        "• Memory usage estimates are approximate\n"
    )
    notesText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Initial stats update
    UpdateStats()
    
    -- Store references
    self.mediaStatsScrollFrame = scrollFrame
    self.mediaStatsScrollChild = scrollChild
    self.statValues = statValues
    self.updateStatsFunc = UpdateStats
end