-- VUI UI Framework
-- This file provides a toolkit for creating consistent UI elements across the addon
local _, VUI = ...

-- Create UI namespace
VUI.UI = {}

-- Store created frames for batch operations
VUI.UI.frames = {}

-- Media paths
local MEDIA_PATH = "Interface\\AddOns\\VUI\\media\\textures\\"
local THEME_PATH = "Interface\\AddOns\\VUI\\media\\textures\\themes\\"
local COMMON_PATH = "Interface\\AddOns\\VUI\\media\\textures\\common\\"

-- Element Templates
local BACKDROP_TEMPLATE = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Default Colors
local COLORS = {
    backdrop = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
    border = {r = 0.4, g = 0.4, b = 0.4, a = 1},
    highlight = {r = 0.3, g = 0.3, b = 0.3, a = 0.5},
    text = {r = 1, g = 1, b = 1, a = 1},
    header = {r = 1, g = 0.9, b = 0.8, a = 1},
    accent = {r = 0.75, g = 0.61, b = 0, a = 1}
}

-- Get appropriate theme colors
function VUI.UI:GetThemeColors()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    if theme == "thunderstorm" then
        return {
            backdrop = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            border = {r = 0.4, g = 0.4, b = 0.4, a = 1},
            highlight = {r = 0.3, g = 0.3, b = 0.3, a = 0.5},
            text = {r = 1, g = 1, b = 1, a = 1}
        }
    elseif theme == "phoenixflame" then
        return {
            backdrop = {r = 0.1, g = 0.04, b = 0.02, a = 0.8},
            border = {r = 0.9, g = 0.3, b = 0.05, a = 1},
            highlight = {r = 1.0, g = 0.64, b = 0.1, a = 0.5},
            text = {r = 1.0, g = 0.9, b = 0.8, a = 1}
        }
    elseif theme == "arcanemystic" then
        return {
            backdrop = {r = 0.1, g = 0.04, b = 0.18, a = 0.8},
            border = {r = 0.62, g = 0.05, b = 0.9, a = 1},
            highlight = {r = 0.7, g = 0.3, b = 0.9, a = 0.5},
            text = {r = 0.9, g = 0.8, b = 1.0, a = 1}
        }
    elseif theme == "felenergy" then
        return {
            backdrop = {r = 0.04, g = 0.1, b = 0.04, a = 0.8},
            border = {r = 0.1, g = 1.0, b = 0.1, a = 1},
            highlight = {r = 0.3, g = 0.9, b = 0.3, a = 0.5},
            text = {r = 0.8, g = 1.0, b = 0.8, a = 1}
        }
    else
        return COLORS
    end
end

-- Get theme texture path
function VUI.UI:GetThemeTexturePath(textureName)
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    return THEME_PATH .. theme .. "\\" .. textureName
end

-- Get common texture path (theme-agnostic)
function VUI.UI:GetCommonTexturePath(textureName)
    return COMMON_PATH .. textureName
end

-- Get class color
function VUI.UI:GetClassColor(class)
    if not class then
        class = select(2, UnitClass("player"))
    end
    
    if RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        return RAID_CLASS_COLORS[class]
    else
        return {r = 1, g = 1, b = 1}
    end
end

-- Create a basic frame with standardized appearance
function VUI.UI:CreateFrame(name, parent, template)
    parent = parent or UIParent
    template = template or "BackdropTemplate"
    
    local frame = CreateFrame("Frame", name, parent, template)
    
    -- Apply standard backdrop
    frame:SetBackdrop(BACKDROP_TEMPLATE)
    
    -- Get colors based on theme
    local colors = self:GetThemeColors()
    
    -- Apply backdrop colors
    frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
    
    -- Apply border color (check for class colored borders)
    if VUI.db.profile.appearance.classColoredBorders then
        local classColor = self:GetClassColor()
        frame:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, colors.border.a)
    else
        frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    end
    
    -- Add frame to our tracking table
    table.insert(self.frames, frame)
    
    -- Add method to update appearance based on settings
    frame.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        
        -- Update backdrop
        self:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        
        -- Update border
        if appearance.classColoredBorders then
            local classColor = VUI.UI:GetClassColor()
            self:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, colors.border.a)
        else
            self:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        end
        
        -- Update text elements if they exist
        if self.text then
            local font = VUI:GetFont(appearance.font)
            local fontSize = appearance.fontSize
            self.text:SetFont(font, fontSize, "")
            self.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
        
        if self.title then
            local font = VUI:GetFont(appearance.font)
            local fontSize = appearance.fontSize + 2
            self.title:SetFont(font, fontSize, "OUTLINE")
            self.title:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
        end
    end
    
    -- Return the frame
    return frame
end

-- Create a basic button with standardized appearance
function VUI.UI:CreateButton(name, parent, text)
    parent = parent or UIParent
    
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetText(text or name)
    
    -- Apply theme styling
    local colors = self:GetThemeColors()
    
    -- Add highlight effect
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    
    -- Set font based on appearance settings
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local region = button:GetRegions()
    if region and region:GetObjectType() == "FontString" then
        region:SetFont(fontName, VUI.db.profile.appearance.fontSize, "")
        region:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    end
    
    -- Add to tracking
    table.insert(self.frames, button)
    
    -- Add update method
    button.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        
        -- Update text
        local region = self:GetRegions()
        if region and region:GetObjectType() == "FontString" then
            local font = VUI:GetFont(appearance.font)
            local fontSize = appearance.fontSize
            region:SetFont(font, fontSize, "")
            region:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
    end
    
    return button
end

-- Create a check button with standardized appearance
function VUI.UI:CreateCheckButton(name, parent, text)
    parent = parent or UIParent
    
    local checkButton = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    
    -- Set the accompanying text
    local textObj = _G[name .. "Text"]
    if textObj then
        textObj:SetText(text or name)
        
        -- Apply font settings
        local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
        local fontSize = VUI.db.profile.appearance.fontSize
        textObj:SetFont(fontName, fontSize, "")
        
        -- Apply color
        local colors = self:GetThemeColors()
        textObj:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    end
    
    -- Add to tracking
    table.insert(self.frames, checkButton)
    
    -- Add update method
    checkButton.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        
        -- Update text
        local textObj = _G[self:GetName() .. "Text"]
        if textObj then
            local font = VUI:GetFont(appearance.font)
            local fontSize = appearance.fontSize
            textObj:SetFont(font, fontSize, "")
            textObj:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
    end
    
    return checkButton
end

-- Create a slider with standardized appearance
function VUI.UI:CreateSlider(parent, name, label, minValue, maxValue, step)
    parent = parent or UIParent
    minValue = minValue or 0
    maxValue = maxValue or 100
    step = step or 1
    
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    -- Set labels
    _G[name .. "Text"]:SetText(label or name)
    _G[name .. "Low"]:SetText(minValue)
    _G[name .. "High"]:SetText(maxValue)
    
    -- Apply font settings
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = self:GetThemeColors()
    
    for _, region in ipairs({_G[name .. "Text"], _G[name .. "Low"], _G[name .. "High"]}) do
        region:SetFont(fontName, fontSize, "")
        region:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    end
    
    -- Add to tracking
    table.insert(self.frames, slider)
    
    -- Add update method
    slider.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        local font = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        -- Update text elements
        for _, region in ipairs({_G[self:GetName() .. "Text"], 
                               _G[self:GetName() .. "Low"], 
                               _G[self:GetName() .. "High"]}) do
            region:SetFont(font, fontSize, "")
            region:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
    end
    
    return slider
end

-- Create an edit box with standardized appearance
function VUI.UI:CreateEditBox(name, parent, width, height)
    parent = parent or UIParent
    width = width or 150
    height = height or 25
    
    local editBox = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    editBox:SetSize(width, height)
    editBox:SetAutoFocus(false)
    
    -- Apply theme styling
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = self:GetThemeColors()
    
    editBox:SetFont(fontName, fontSize, "")
    editBox:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    
    -- Add to tracking
    table.insert(self.frames, editBox)
    
    -- Add update method
    editBox.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        local font = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        self:SetFont(font, fontSize, "")
        self:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    end
    
    return editBox
end

-- Create a dropdown menu with standardized appearance
function VUI.UI:CreateDropdown(name, parent, width)
    parent = parent or UIParent
    width = width or 150
    
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, width)
    
    -- Apply theme styling
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    
    -- Add to tracking
    table.insert(self.frames, dropdown)
    
    -- Add update method
    dropdown.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        -- Dropdown menus are more complex to style directly
        -- Most of their appearance is controlled by the game UI
    end
    
    return dropdown
end

-- Create a tab button for use in tab panels
function VUI.UI:CreateTabButton(name, parent, text, index)
    parent = parent or UIParent
    
    local tabButton = CreateFrame("Button", name, parent)
    tabButton:SetSize(100, 24)
    
    -- Calculate position based on index
    if index then
        tabButton:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", (index-1) * 100, 0)
    end
    
    -- Create background texture
    tabButton.bg = tabButton:CreateTexture(nil, "BACKGROUND")
    tabButton.bg:SetAllPoints()
    
    -- Create highlight texture
    tabButton.highlight = tabButton:CreateTexture(nil, "HIGHLIGHT")
    tabButton.highlight:SetAllPoints()
    
    -- Create text label
    tabButton.text = tabButton:CreateFontString(nil, "OVERLAY")
    tabButton.text:SetPoint("CENTER")
    tabButton.text:SetText(text or name)
    
    -- Apply theme styling
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = self:GetThemeColors()
    
    tabButton.text:SetFont(fontName, fontSize, "")
    tabButton.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    
    tabButton.bg:SetColorTexture(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
    tabButton.highlight:SetColorTexture(colors.highlight.r, colors.highlight.g, colors.highlight.b, colors.highlight.a)
    
    -- Not selected by default
    tabButton.selected = false
    
    -- Add selection method
    tabButton.Select = function(self, select)
        self.selected = select
        
        local colors = VUI.UI:GetThemeColors()
        
        if select then
            self.bg:SetColorTexture(colors.highlight.r, colors.highlight.g, colors.highlight.b, colors.highlight.a + 0.2)
            self.text:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
        else
            self.bg:SetColorTexture(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
            self.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
    end
    
    -- Add to tracking
    table.insert(self.frames, tabButton)
    
    -- Add update method
    tabButton.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        local font = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        -- Update text
        self.text:SetFont(font, fontSize, "")
        
        -- Update colors based on selection state
        if self.selected then
            self.bg:SetColorTexture(colors.highlight.r, colors.highlight.g, colors.highlight.b, colors.highlight.a + 0.2)
            self.text:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
        else
            self.bg:SetColorTexture(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
            self.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        end
        
        self.highlight:SetColorTexture(colors.highlight.r, colors.highlight.g, colors.highlight.b, colors.highlight.a)
    end
    
    return tabButton
end

-- Create a tab panel (container with multiple selectable tabs)
function VUI.UI:CreateTabFrame(name, parent, numTabs, tabNames)
    parent = parent or UIParent
    numTabs = numTabs or 1
    tabNames = tabNames or {"Tab 1"}
    
    -- Create main frame
    local tabFrame = self:CreateFrame(name, parent)
    
    -- Add tab collection and content frames
    tabFrame.tabs = {}
    tabFrame.contents = {}
    
    -- Create tabs
    for i = 1, numTabs do
        local tabName = name .. "Tab" .. i
        local tab = self:CreateTabButton(tabName, tabFrame, tabNames[i], i)
        
        -- Create content frame for this tab
        local contentName = name .. "Content" .. i
        local content = self:CreateFrame(contentName, tabFrame)
        content:SetAllPoints(tabFrame)
        content:Hide()
        
        -- Store references
        tabFrame.tabs[i] = tab
        tabFrame.contents[i] = content
        
        -- Set up tab click behavior
        tab:SetScript("OnClick", function()
            tabFrame:SelectTab(i)
        end)
    end
    
    -- Add method to select a tab
    tabFrame.SelectTab = function(self, index)
        -- Hide all content frames and deselect all tabs
        for i = 1, #self.tabs do
            self.contents[i]:Hide()
            self.tabs[i]:Select(false)
        end
        
        -- Show the selected content and select the tab
        if self.contents[index] then
            self.contents[index]:Show()
        end
        
        if self.tabs[index] then
            self.tabs[index]:Select(true)
        end
        
        -- Store the current selection
        self.selectedTab = index
    end
    
    -- Select first tab by default
    tabFrame:SelectTab(1)
    
    -- Add to tracking
    table.insert(self.frames, tabFrame)
    
    return tabFrame
end

-- Create a scrollable frame with standardized appearance
function VUI.UI:CreateScrollFrame(name, parent, width, height)
    parent = parent or UIParent
    width = width or 300
    height = height or 400
    
    -- Create the outer frame
    local frame = self:CreateFrame(name, parent)
    frame:SetSize(width, height)
    
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", name .. "ScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
    
    -- Create the scrollbar backdrop
    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
    scrollBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    
    -- Create the content frame
    local content = CreateFrame("Frame", name .. "Content", scrollFrame)
    content:SetSize(width - 44, height - 16)
    scrollFrame:SetScrollChild(content)
    
    -- Apply theme styling to the scrollbar
    local colors = self:GetThemeColors()
    
    -- Store references
    frame.scrollFrame = scrollFrame
    frame.content = content
    
    -- Add to tracking
    table.insert(self.frames, frame)
    
    return frame, content
end

-- Create a status bar with standardized appearance
function VUI.UI:CreateStatusBar(name, parent, width, height)
    parent = parent or UIParent
    width = width or 200
    height = height or 20
    
    local statusBar = CreateFrame("StatusBar", name, parent)
    statusBar:SetSize(width, height)
    
    -- Create textures
    statusBar:SetStatusBarTexture(MEDIA_PATH .. "statusbar-smooth.blp")
    
    -- Create background
    statusBar.bg = statusBar:CreateTexture(nil, "BACKGROUND")
    statusBar.bg:SetAllPoints()
    statusBar.bg:SetTexture(MEDIA_PATH .. "statusbar-smooth.blp")
    
    -- Create text
    statusBar.text = statusBar:CreateFontString(nil, "OVERLAY")
    statusBar.text:SetPoint("CENTER")
    
    -- Apply theme styling
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = self:GetThemeColors()
    
    statusBar.text:SetFont(fontName, fontSize, "OUTLINE")
    statusBar.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    
    statusBar:SetStatusBarColor(0.4, 0.4, 0.8)
    statusBar.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    
    -- Create a border
    statusBar.border = CreateFrame("Frame", nil, statusBar, "BackdropTemplate")
    statusBar.border:SetAllPoints()
    statusBar.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    
    if VUI.db.profile.appearance.classColoredBorders then
        local classColor = self:GetClassColor()
        statusBar.border:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 1)
    else
        statusBar.border:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    end
    
    -- Add to tracking
    table.insert(self.frames, statusBar)
    
    -- Add update method
    statusBar.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        local font = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        -- Update text
        self.text:SetFont(font, fontSize, "OUTLINE")
        self.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        
        -- Update border
        if appearance.classColoredBorders then
            local classColor = VUI.UI:GetClassColor()
            self.border:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 1)
        else
            self.border:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        end
    end
    
    return statusBar
end

-- Create an icon button with standardized appearance
function VUI.UI:CreateIconButton(name, parent, texture, size)
    parent = parent or UIParent
    size = size or 32
    
    local button = CreateFrame("Button", name, parent)
    button:SetSize(size, size)
    
    -- Create texture
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    
    if texture then
        button.icon:SetTexture(texture)
    end
    
    -- Apply texcoords to remove default icon border
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Create highlight
    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints()
    button.highlight:SetTexture(MEDIA_PATH .. "highlight.tga")
    button.highlight:SetBlendMode("ADD")
    
    -- Create border
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetPoint("TOPLEFT", -1, 1)
    button.border:SetPoint("BOTTOMRIGHT", 1, -1)
    button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    
    -- Apply theme styling
    local colors = self:GetThemeColors()
    
    if VUI.db.profile.appearance.classColoredBorders then
        local classColor = self:GetClassColor()
        button.border:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
    else
        button.border:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    end
    
    -- Add cooldown frame
    button.cooldown = CreateFrame("Cooldown", name .. "Cooldown", button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    button.cooldown:SetDrawEdge(false)
    button.cooldown:SetHideCountdownNumbers(true)
    
    -- Add count text
    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetPoint("BOTTOMRIGHT", 2, -2)
    button.count:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), VUI.db.profile.appearance.fontSize, "OUTLINE")
    button.count:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    
    -- Add to tracking
    table.insert(self.frames, button)
    
    -- Add update method
    button.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        local font = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        -- Update count text
        self.count:SetFont(font, fontSize, "OUTLINE")
        self.count:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        
        -- Update border
        if appearance.classColoredBorders then
            local classColor = VUI.UI:GetClassColor()
            self.border:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
        else
            self.border:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        end
    end
    
    return button
end

-- Create a tooltip with standardized appearance
function VUI.UI:CreateTooltip(name, parent)
    local tooltip = CreateFrame("GameTooltip", name, parent, "GameTooltipTemplate")
    
    -- Apply theme styling
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = self:GetThemeColors()
    
    -- Style the tooltip header and text
    _G[name .. "TextLeft1"]:SetFont(fontName, fontSize + 1, "OUTLINE")
    _G[name .. "TextLeft1"]:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
    
    -- Add update method
    tooltip.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        
        local colors = VUI.UI:GetThemeColors()
        local font = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        -- Update header
        _G[self:GetName() .. "TextLeft1"]:SetFont(font, fontSize + 1, "OUTLINE")
        _G[self:GetName() .. "TextLeft1"]:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
    end
    
    return tooltip
end

-- Function to update all UI elements with the current appearance settings
function VUI.UI:UpdateAppearance()
    -- Update all tracked frames
    for _, frame in ipairs(self.frames) do
        if frame.UpdateAppearance then
            frame:UpdateAppearance(VUI.db.profile.appearance)
        end
    end
end

-- Update all UI elements when settings change
function VUI:ApplyUISettings()
    VUI.UI:UpdateAppearance()
end