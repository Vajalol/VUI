local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Theme helpers module
VUI.ThemeHelpers = VUI.ThemeHelpers or {}

-- Store theme data for reuse (make it accessible to ThemeIntegration)
VUI.ThemeHelpers.themeColors = {
    ["thunderstorm"] = {
        backdrop = {r=0.04, g=0.04, b=0.1, a=0.9},
        border = {r=0.05, g=0.62, b=0.9, a=1},
        highlight = {r=0.1, g=0.7, b=1, a=0.3},
        header = "|cff1784d1" -- Electric blue
    },
    ["phoenixflame"] = {
        backdrop = {r=0.1, g=0.04, b=0.02, a=0.9},
        border = {r=0.9, g=0.3, b=0.05, a=1},
        highlight = {r=1, g=0.4, b=0.1, a=0.3},
        header = "|cffE64D0D" -- Fiery orange
    },
    ["arcanemystic"] = {
        backdrop = {r=0.1, g=0.04, b=0.18, a=0.9},
        border = {r=0.61, g=0.05, b=0.9, a=1},
        highlight = {r=0.7, g=0.1, b=1, a=0.3},
        header = "|cff9D0DE6" -- Violet
    },
    ["felenergy"] = {
        backdrop = {r=0.04, g=0.1, b=0.04, a=0.9},
        border = {r=0.1, g=1.0, b=0.1, a=1},
        highlight = {r=0.2, g=1, b=0.2, a=0.3},
        header = "|cff1AFF1A" -- Fel green
    },
    ["classcolor"] = {
        backdrop = {r=0.05, g=0.05, b=0.05, a=0.9},
        border = {r=0.7, g=0.7, b=0.7, a=1},
        highlight = {r=0.8, g=0.8, b=0.8, a=0.3},
        header = "|cffCCCCCC" -- Default gray until class is known
    }
}

-- Cache the current theme data
local currentThemeData = {}

-- Tables to track UI elements that need theme updates
local registeredPanels = {}
local registeredButtons = {}
local registeredCheckboxes = {}
local registeredSliders = {}
local registeredDropdowns = {}
local registeredTabSystems = {}

-- Local helper functions
local function tContains(table, item)
    for _, value in ipairs(table) do
        if value == item then
            return true
        end
    end
    return false
end

local function tinsert(table, value)
    table[#table + 1] = value
end

-- Initialize the theme data based on current profile
function VUI.ThemeHelpers:UpdateCurrentTheme()
    local theme = "thunderstorm"
    
    -- Get theme name from profile if available
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        theme = VUI.db.profile.appearance.theme or "thunderstorm"
    end
    
    -- Update current theme data
    currentThemeData = self.themeColors[theme] or self.themeColors["thunderstorm"]
end

-- Get current theme data
function VUI.ThemeHelpers:GetThemeData()
    if not next(currentThemeData) then
        self:UpdateCurrentTheme()
    end
    return currentThemeData
end

-- Apply a themed backdrop to a frame
function VUI.ThemeHelpers:ApplyBackdrop(frame, isDarkened)
    if not frame then return end
    
    -- Get current theme data
    local themeData = self:GetThemeData()
    
    -- Create a backdrop for the frame
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Apply theme colors, optionally darkened
    local bgColor = {
        r = themeData.backdrop.r * (isDarkened and 0.7 or 1),
        g = themeData.backdrop.g * (isDarkened and 0.7 or 1),
        b = themeData.backdrop.b * (isDarkened and 0.7 or 1),
        a = themeData.backdrop.a + (isDarkened and 0.1 or 0)
    }
    
    frame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    frame:SetBackdropBorderColor(
        themeData.border.r,
        themeData.border.g,
        themeData.border.b,
        themeData.border.a
    )
    
    return frame
end

-- Create a themed panel
function VUI.ThemeHelpers:CreatePanel(name, parent, width, height)
    local frame = CreateFrame("Frame", name, parent or UIParent)
    frame:SetSize(width or 400, height or 300)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Apply themed backdrop
    self:ApplyBackdrop(frame)
    
    -- Add a header
    local themeData = self:GetThemeData()
    
    -- Add a themed header
    local headerTexture = frame:CreateTexture(nil, "ARTWORK")
    headerTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    headerTexture:SetWidth(300)
    headerTexture:SetHeight(64)
    headerTexture:SetPoint("TOP", 0, 12)
    
    -- Add title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOP", headerTexture, "TOP", 0, -14)
    frame.title:SetText(themeData.header .. (name or "VUI Panel") .. "|r")
    
    -- Add a close button
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", -5, -5)
    
    -- Add a method to update the theme
    frame.UpdateTheme = function(self)
        VUI.ThemeHelpers:UpdatePanelTheme(self)
    end
    
    -- Register the panel for theme updates
    self:RegisterPanelForThemeUpdates(frame)
    
    return frame
end

-- Create a themed button
function VUI.ThemeHelpers:CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 100, height or 30)
    
    -- Button background
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    
    -- Get theme data
    local themeData = self:GetThemeData()
    
    -- Apply theme colors
    local bgColor = {
        r = themeData.backdrop.r * 1.2,
        g = themeData.backdrop.g * 1.2,
        b = themeData.backdrop.b * 1.2,
        a = 0.8
    }
    button:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    button:SetBackdropBorderColor(
        themeData.border.r,
        themeData.border.g,
        themeData.border.b,
        0.8
    )
    
    -- Button text
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER")
    button.text:SetText(text)
    button.text:SetTextColor(0.9, 0.9, 0.9)
    
    -- Highlight texture
    button.highlighttexture = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlighttexture:SetAllPoints()
    button.highlighttexture:SetColorTexture(
        themeData.highlight.r,
        themeData.highlight.g,
        themeData.highlight.b,
        themeData.highlight.a
    )
    button:SetHighlightTexture(button.highlighttexture)
    
    -- Add method to update theme
    button.UpdateTheme = function(self)
        VUI.ThemeHelpers:UpdateButtonTheme(self)
    end
    
    -- Register for theme updates
    self:RegisterButtonForThemeUpdates(button)
    
    return button
end

-- Create a themed checkbox
function VUI.ThemeHelpers:CreateCheckbox(parent, text, initialValue)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    
    -- Add label text
    checkbox.label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.label:SetText(text)
    checkbox.label:SetTextColor(0.9, 0.9, 0.9)
    
    -- Set initial value
    if initialValue ~= nil then
        checkbox:SetChecked(initialValue)
    end
    
    -- Theme the checkbox
    local themeData = self:GetThemeData()
    checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    local checkedTexture = checkbox:GetCheckedTexture()
    checkedTexture:SetVertexColor(
        themeData.border.r,
        themeData.border.g,
        themeData.border.b,
        1
    )
    
    -- Add method to update theme
    checkbox.UpdateTheme = function(self)
        VUI.ThemeHelpers:UpdateCheckboxTheme(self)
    end
    
    -- Register for theme updates
    self:RegisterCheckboxForThemeUpdates(checkbox)
    
    return checkbox
end

-- Create a themed slider
function VUI.ThemeHelpers:CreateSlider(parent, text, min, max, step, initialValue)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetSize(180, 16)
    slider:SetMinMaxValues(min or 0, max or 1)
    slider:SetValueStep(step or 0.01)
    slider:SetObeyStepOnDrag(true)
    
    -- Set text
    slider.Text:SetText(text)
    slider.Low:SetText(min or 0)
    slider.High:SetText(max or 1)
    
    -- Set initial value
    if initialValue then
        slider:SetValue(initialValue)
    end
    
    -- Theme the slider
    local themeData = self:GetThemeData()
    slider.Thumb:SetVertexColor(
        themeData.border.r,
        themeData.border.g,
        themeData.border.b,
        1
    )
    
    -- Add value display
    slider.value = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slider.value:SetPoint("TOP", slider, "BOTTOM", 0, 0)
    slider:SetScript("OnValueChanged", function(self, value)
        self.value:SetText(string.format("%.2f", value))
    end)
    slider:GetScript("OnValueChanged")(slider, slider:GetValue())
    
    -- Add method to update theme
    slider.UpdateTheme = function(self)
        VUI.ThemeHelpers:UpdateSliderTheme(self)
    end
    
    -- Register for theme updates
    self:RegisterSliderForThemeUpdates(slider)
    
    return slider
end

-- Create a themed dropdown
function VUI.ThemeHelpers:CreateDropdown(parent, text, width, items)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetSize(width or 150, 30)
    
    -- Add label
    dropdown.label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdown.label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 5)
    dropdown.label:SetText(text)
    
    -- Store items
    dropdown.items = items or {}
    dropdown.selectedValue = nil
    
    -- Initialize dropdown
    UIDropDownMenu_SetWidth(dropdown, width or 150)
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for value, text in pairs(dropdown.items) do
            info.text = text
            info.value = value
            info.func = function()
                UIDropDownMenu_SetText(dropdown, text)
                dropdown.selectedValue = value
                if dropdown.OnValueChanged then
                    dropdown:OnValueChanged(value)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Theme the dropdown
    local themeData = self:GetThemeData()
    local leftBorder = _G[dropdown:GetName() .. "Left"]
    local rightBorder = _G[dropdown:GetName() .. "Right"]
    local middleBorder = _G[dropdown:GetName() .. "Middle"]
    local buttonIcon = _G[dropdown:GetName() .. "Button"]
    
    if leftBorder and rightBorder and middleBorder then
        leftBorder:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.8
        )
        rightBorder:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.8
        )
        middleBorder:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.8
        )
    end
    
    -- Add method to update theme
    dropdown.UpdateTheme = function(self)
        VUI.ThemeHelpers:UpdateDropdownTheme(self)
    end
    
    -- Register for theme updates
    self:RegisterDropdownForThemeUpdates(dropdown)
    
    return dropdown
end

-- Create a themed tab system
function VUI.ThemeHelpers:CreateTabSystem(parent, width, height, tabs)
    local tabFrame = CreateFrame("Frame", nil, parent)
    tabFrame:SetSize(width or parent:GetWidth() - 40, height or parent:GetHeight() - 60)
    tabFrame:SetPoint("TOP", 0, -30)
    
    -- Apply themed backdrop
    self:ApplyBackdrop(tabFrame)
    
    -- Create tabs
    tabFrame.tabs = {}
    tabFrame.tabButtons = {}
    tabFrame.numTabs = #tabs
    
    for i, tabInfo in ipairs(tabs) do
        -- Create tab button
        local tabButton = CreateFrame("Button", nil, tabFrame)
        tabButton:SetSize(100, 30)
        tabButton:SetPoint("TOPLEFT", (i-1) * 105, 20)
        
        -- Apply themed backdrop
        tabButton:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        
        -- Get theme data
        local themeData = self:GetThemeData()
        
        -- Apply theme colors (darker initially)
        local bgColor = {
            r = themeData.backdrop.r * 0.8,
            g = themeData.backdrop.g * 0.8,
            b = themeData.backdrop.b * 0.8,
            a = 0.8
        }
        tabButton:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        tabButton:SetBackdropBorderColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.6
        )
        
        -- Tab text
        tabButton.text = tabButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tabButton.text:SetPoint("CENTER")
        tabButton.text:SetText(tabInfo.name)
        tabButton.text:SetTextColor(0.9, 0.9, 0.9)
        
        -- Highlight texture
        tabButton.highlighttexture = tabButton:CreateTexture(nil, "HIGHLIGHT")
        tabButton.highlighttexture:SetAllPoints()
        tabButton.highlighttexture:SetColorTexture(
            themeData.highlight.r,
            themeData.highlight.g,
            themeData.highlight.b,
            themeData.highlight.a
        )
        tabButton:SetHighlightTexture(tabButton.highlighttexture)
        
        -- Create tab content frame
        local tabContent = CreateFrame("Frame", nil, tabFrame)
        tabContent:SetSize(tabFrame:GetWidth() - 20, tabFrame:GetHeight() - 50)
        tabContent:SetPoint("TOP", 0, -30)
        tabContent:Hide()
        
        -- Store tab info
        tabButton.tabIndex = i
        tabButton.tabContent = tabContent
        
        -- Tab click handler
        tabButton:SetScript("OnClick", function()
            tabFrame:SelectTab(i)
        end)
        
        -- Store in tab system
        tabFrame.tabs[i] = tabContent
        tabFrame.tabButtons[i] = tabButton
        
        -- Call the setup function if provided
        if tabInfo.setup and type(tabInfo.setup) == "function" then
            tabInfo.setup(tabContent)
        end
    end
    
    -- Add select tab method
    function tabFrame:SelectTab(index)
        -- Hide all tabs
        for i = 1, self.numTabs do
            self.tabs[i]:Hide()
            
            -- Reset appearance
            local button = self.tabButtons[i]
            local themeData = VUI.ThemeHelpers:GetThemeData()
            
            -- Normal state for non-selected tabs
            if i ~= index then
                local normalColor = {
                    r = themeData.backdrop.r * 0.8,
                    g = themeData.backdrop.g * 0.8,
                    b = themeData.backdrop.b * 0.8,
                    a = 0.8
                }
                button:SetBackdropColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
                button:SetBackdropBorderColor(
                    themeData.border.r,
                    themeData.border.g,
                    themeData.border.b,
                    0.6
                )
            else
                -- Selected state
                local selectedColor = {
                    r = themeData.backdrop.r * 1.2,
                    g = themeData.backdrop.g * 1.2,
                    b = themeData.backdrop.b * 1.2,
                    a = 0.9
                }
                button:SetBackdropColor(selectedColor.r, selectedColor.g, selectedColor.b, selectedColor.a)
                button:SetBackdropBorderColor(
                    themeData.border.r,
                    themeData.border.g,
                    themeData.border.b,
                    1
                )
            end
        end
        
        -- Show selected tab
        if self.tabs[index] then
            self.tabs[index]:Show()
        end
    end
    
    -- Add method to update theme
    tabFrame.UpdateTheme = function(self)
        VUI.ThemeHelpers:UpdateTabSystemTheme(self)
    end
    
    -- Register for theme updates
    self:RegisterTabSystemForThemeUpdates(tabFrame)
    
    -- Select first tab by default
    tabFrame:SelectTab(1)
    
    return tabFrame
end

-- Tables to track UI elements for theme updates
local registeredPanels = {}
local registeredButtons = {}
local registeredCheckboxes = {}
local registeredSliders = {}
local registeredDropdowns = {}
local registeredTabSystems = {}

-- Register UI elements for theme updates
function VUI.ThemeHelpers:RegisterPanelForThemeUpdates(panel)
    if not tContains(registeredPanels, panel) then
        tinsert(registeredPanels, panel)
    end
end

function VUI.ThemeHelpers:RegisterButtonForThemeUpdates(button)
    if not tContains(registeredButtons, button) then
        tinsert(registeredButtons, button)
    end
end

function VUI.ThemeHelpers:RegisterCheckboxForThemeUpdates(checkbox)
    if not tContains(registeredCheckboxes, checkbox) then
        tinsert(registeredCheckboxes, checkbox)
    end
end

function VUI.ThemeHelpers:RegisterSliderForThemeUpdates(slider)
    if not tContains(registeredSliders, slider) then
        tinsert(registeredSliders, slider)
    end
end

function VUI.ThemeHelpers:RegisterDropdownForThemeUpdates(dropdown)
    if not tContains(registeredDropdowns, dropdown) then
        tinsert(registeredDropdowns, dropdown)
    end
end

function VUI.ThemeHelpers:RegisterTabSystemForThemeUpdates(tabSystem)
    if not tContains(registeredTabSystems, tabSystem) then
        tinsert(registeredTabSystems, tabSystem)
    end
end

-- Update theme for UI elements
function VUI.ThemeHelpers:UpdatePanelTheme(panel)
    local themeData = self:GetThemeData()
    
    panel:SetBackdropColor(themeData.backdrop.r, themeData.backdrop.g, themeData.backdrop.b, themeData.backdrop.a)
    panel:SetBackdropBorderColor(themeData.border.r, themeData.border.g, themeData.border.b, themeData.border.a)
    
    if panel.title then
        panel.title:SetText(themeData.header .. panel.title:GetText():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") .. "|r")
    end
end

function VUI.ThemeHelpers:UpdateButtonTheme(button)
    local themeData = self:GetThemeData()
    
    local bgColor = {
        r = themeData.backdrop.r * 1.2,
        g = themeData.backdrop.g * 1.2,
        b = themeData.backdrop.b * 1.2,
        a = 0.8
    }
    button:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    button:SetBackdropBorderColor(themeData.border.r, themeData.border.g, themeData.border.b, 0.8)
    
    if button.highlighttexture then
        button.highlighttexture:SetColorTexture(
            themeData.highlight.r,
            themeData.highlight.g,
            themeData.highlight.b,
            themeData.highlight.a
        )
        button:SetHighlightTexture(button.highlighttexture)
    end
end

function VUI.ThemeHelpers:UpdateCheckboxTheme(checkbox)
    local themeData = self:GetThemeData()
    
    local checkedTexture = checkbox:GetCheckedTexture()
    if checkedTexture then
        checkedTexture:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            1
        )
    end
end

function VUI.ThemeHelpers:UpdateSliderTheme(slider)
    local themeData = self:GetThemeData()
    
    slider.Thumb:SetVertexColor(
        themeData.border.r,
        themeData.border.g,
        themeData.border.b,
        1
    )
end

function VUI.ThemeHelpers:UpdateDropdownTheme(dropdown)
    local themeData = self:GetThemeData()
    
    local leftBorder = _G[dropdown:GetName() .. "Left"]
    local rightBorder = _G[dropdown:GetName() .. "Right"]
    local middleBorder = _G[dropdown:GetName() .. "Middle"]
    
    if leftBorder and rightBorder and middleBorder then
        leftBorder:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.8
        )
        rightBorder:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.8
        )
        middleBorder:SetVertexColor(
            themeData.border.r,
            themeData.border.g,
            themeData.border.b,
            0.8
        )
    end
end

function VUI.ThemeHelpers:UpdateTabSystemTheme(tabSystem)
    local themeData = self:GetThemeData()
    
    -- Update the tab frame
    tabSystem:SetBackdropColor(themeData.backdrop.r, themeData.backdrop.g, themeData.backdrop.b, themeData.backdrop.a)
    tabSystem:SetBackdropBorderColor(themeData.border.r, themeData.border.g, themeData.border.b, themeData.border.a)
    
    -- Find the active tab
    local activeTabIndex = 1
    for i = 1, tabSystem.numTabs do
        if tabSystem.tabs[i]:IsShown() then
            activeTabIndex = i
            break
        end
    end
    
    -- Update all tab buttons
    for i = 1, tabSystem.numTabs do
        local button = tabSystem.tabButtons[i]
        
        if i == activeTabIndex then
            -- Selected state
            local selectedColor = {
                r = themeData.backdrop.r * 1.2,
                g = themeData.backdrop.g * 1.2,
                b = themeData.backdrop.b * 1.2,
                a = 0.9
            }
            button:SetBackdropColor(selectedColor.r, selectedColor.g, selectedColor.b, selectedColor.a)
            button:SetBackdropBorderColor(
                themeData.border.r,
                themeData.border.g,
                themeData.border.b,
                1
            )
        else
            -- Normal state
            local normalColor = {
                r = themeData.backdrop.r * 0.8,
                g = themeData.backdrop.g * 0.8,
                b = themeData.backdrop.b * 0.8,
                a = 0.8
            }
            button:SetBackdropColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
            button:SetBackdropBorderColor(
                themeData.border.r,
                themeData.border.g,
                themeData.border.b,
                0.6
            )
        end
        
        -- Update highlight texture
        if button.highlighttexture then
            button.highlighttexture:SetColorTexture(
                themeData.highlight.r,
                themeData.highlight.g,
                themeData.highlight.b,
                themeData.highlight.a
            )
            button:SetHighlightTexture(button.highlighttexture)
        end
    end
end

-- Forward declaration for the UpdateAllThemes function which is defined later
-- This ensures the function is available when called before its full definition
-- Full implementation is below

-- Helper function for individual element updates
local function updateElement(element)
    if element and element.UpdateTheme then
        element:UpdateTheme()
    end
end

-- Update all registered UI elements with current theme
function VUI.ThemeHelpers:UpdateAllThemes()
    -- Update current theme data first
    self:UpdateCurrentTheme()
    
    -- Update all registered panels
    for _, panel in ipairs(registeredPanels) do
        if panel and panel.UpdateTheme then
            panel:UpdateTheme()
        elseif panel then
            self:UpdatePanelTheme(panel)
        end
    end
    
    -- Update all registered buttons
    for _, button in ipairs(registeredButtons) do
        if button and button.UpdateTheme then
            button:UpdateTheme()
        elseif button then
            self:UpdateButtonTheme(button)
        end
    end
    
    -- Update all registered checkboxes
    for _, checkbox in ipairs(registeredCheckboxes) do
        if checkbox and checkbox.UpdateTheme then
            checkbox:UpdateTheme()
        elseif checkbox then
            self:UpdateCheckboxTheme(checkbox)
        end
    end
    
    -- Update all registered sliders
    for _, slider in ipairs(registeredSliders) do
        if slider and slider.UpdateTheme then
            slider:UpdateTheme()
        elseif slider then
            self:UpdateSliderTheme(slider)
        end
    end
    
    -- Update all registered dropdowns
    for _, dropdown in ipairs(registeredDropdowns) do
        if dropdown and dropdown.UpdateTheme then
            dropdown:UpdateTheme()
        elseif dropdown then
            self:UpdateDropdownTheme(dropdown)
        end
    end
    
    -- Update all registered tab systems
    for _, tabSystem in ipairs(registeredTabSystems) do
        if tabSystem and tabSystem.UpdateTheme then
            tabSystem:UpdateTheme()
        elseif tabSystem then
            self:UpdateTabSystemTheme(tabSystem)
        end
    end
    
    -- Notify other systems that themes have been updated
    VUI:TriggerCallback("THEME_UPDATED", self:GetThemeData())
    
    -- Log update
    VUI:Debug("Updated all UI elements with theme: " .. (VUI.db and VUI.db.profile and VUI.db.profile.appearance and VUI.db.profile.appearance.theme or "unknown"))
end

-- Create a function to handle theme registration that will be called later
local function RegisterThemeCallbacks()
    -- Make sure ThemeIntegration exists and has RegisterThemeChangeCallback method
    if VUI.ThemeIntegration and VUI.ThemeIntegration.RegisterThemeChangeCallback then
        VUI.ThemeIntegration:RegisterThemeChangeCallback(function(newTheme)
            VUI.ThemeHelpers:UpdateAllThemes()
        end)
    end
end

-- Initialize themes on load if possible, otherwise wait for OnInitialize
if VUI.isInitialized then
    VUI.ThemeHelpers:UpdateCurrentTheme()
    RegisterThemeCallbacks()
else
    -- Hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize themes and register callbacks after VUI is initialized
        if VUI.ThemeHelpers then
            VUI.ThemeHelpers:UpdateCurrentTheme()
            RegisterThemeCallbacks()
        end
    end
end