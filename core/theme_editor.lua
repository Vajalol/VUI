-- VUI Theme Editor
-- Provides a visual theme customization interface
local _, VUI = ...

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
        {text = "Import/Export", frame = "importExportFrame"}
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
    self:CreateImportExportTab(tabFrames[4])
    
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