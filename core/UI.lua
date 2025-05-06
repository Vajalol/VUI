-- VUI UI Framework
-- This file provides a toolkit for creating consistent UI elements across the addon
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

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
    local colors = {}
    
    if theme == "thunderstorm" then
        colors = {
            backdrop = {r = 0.04, g = 0.04, b = 0.1, a = 0.8}, -- Deep blue
            border = {r = 0.05, g = 0.62, b = 0.9, a = 1}, -- Electric blue
            highlight = {r = 0.1, g = 0.4, b = 0.6, a = 0.5},
            text = {r = 1, g = 1, b = 1, a = 1},
            header = {r = 0.2, g = 0.7, b = 1.0, a = 1},
            accent = {r = 0.0, g = 0.5, b = 0.9, a = 1}
        }
    elseif theme == "phoenixflame" then
        colors = {
            backdrop = {r = 0.1, g = 0.04, b = 0.02, a = 0.8}, -- Dark red/brown
            border = {r = 0.9, g = 0.3, b = 0.05, a = 1}, -- Fiery orange
            highlight = {r = 1.0, g = 0.64, b = 0.1, a = 0.5},
            text = {r = 1.0, g = 0.9, b = 0.8, a = 1},
            header = {r = 1.0, g = 0.7, b = 0.2, a = 1},
            accent = {r = 0.9, g = 0.4, b = 0.0, a = 1}
        }
    elseif theme == "arcanemystic" then
        colors = {
            backdrop = {r = 0.1, g = 0.04, b = 0.18, a = 0.8}, -- Deep purple
            border = {r = 0.62, g = 0.05, b = 0.9, a = 1}, -- Bright violet
            highlight = {r = 0.7, g = 0.3, b = 0.9, a = 0.5},
            text = {r = 0.9, g = 0.8, b = 1.0, a = 1},
            header = {r = 0.8, g = 0.5, b = 1.0, a = 1},
            accent = {r = 0.6, g = 0.2, b = 0.9, a = 1}
        }
    elseif theme == "felenergy" then
        colors = {
            backdrop = {r = 0.04, g = 0.1, b = 0.04, a = 0.8}, -- Dark green
            border = {r = 0.1, g = 1.0, b = 0.1, a = 1}, -- Fel green
            highlight = {r = 0.3, g = 0.9, b = 0.3, a = 0.5},
            text = {r = 0.8, g = 1.0, b = 0.8, a = 1},
            header = {r = 0.5, g = 1.0, b = 0.5, a = 1},
            accent = {r = 0.2, g = 0.8, b = 0.2, a = 1}
        }
    elseif theme == "classcolor" then
        -- Get the player's class color
        local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
        
        -- Create a darker variant for backdrops
        local darkR = classColor.r * 0.2
        local darkG = classColor.g * 0.2
        local darkB = classColor.b * 0.2
        
        -- Create a lighter variant for highlights
        local lightR = min(classColor.r + 0.2, 1.0)
        local lightG = min(classColor.g + 0.2, 1.0)
        local lightB = min(classColor.b + 0.2, 1.0)
        
        colors = {
            backdrop = {r = darkR, g = darkG, b = darkB, a = 0.8},
            border = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1},
            highlight = {r = lightR, g = lightG, b = lightB, a = 0.5},
            text = {r = 1, g = 1, b = 1, a = 1},
            header = {r = lightR, g = lightG, b = lightB, a = 1},
            accent = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
        }
    else
        -- Default colors
        colors = {
            backdrop = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            border = {r = 0.4, g = 0.4, b = 0.4, a = 1},
            highlight = {r = 0.3, g = 0.3, b = 0.3, a = 0.5},
            text = {r = 1, g = 1, b = 1, a = 1},
            header = {r = 1, g = 0.9, b = 0.8, a = 1},
            accent = {r = 0.75, g = 0.61, b = 0, a = 1}
        }
    end
    
    -- Override with class color if option is enabled but not using the class theme
    if VUI.db.profile.appearance.classColoredBorders and theme ~= "classcolor" then
        local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
        colors.border = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
    end
    
    return colors
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

-- Set a texture to a frame using atlas if available
function VUI.UI:SetTexture(frame, texturePath, useAtlas)
    if not frame or not texturePath then return end
    
    -- Default to using atlas if parameter not specified
    if useAtlas == nil then useAtlas = true end
    
    if useAtlas then
        -- Try to get texture from atlas system
        local textureInfo = VUI:GetTextureCached(texturePath)
        
        -- If texture is from atlas, apply it with coordinates
        if textureInfo and textureInfo.isAtlas then
            frame:SetTexture(textureInfo.path)
            frame:SetTexCoord(
                textureInfo.coords.left,
                textureInfo.coords.right,
                textureInfo.coords.top,
                textureInfo.coords.bottom
            )
            return
        end
    end
    
    -- Fall back to regular texture if not in atlas or atlas disabled
    frame:SetTexture(texturePath)
    frame:SetTexCoord(0, 1, 0, 1) -- Reset texture coordinates to default
end

-- Set a background texture to a frame using atlas if available
function VUI.UI:SetBackgroundTexture(frame, texturePath, useAtlas, tile)
    if not frame or not texturePath then return end
    
    -- Default to using atlas if parameter not specified
    if useAtlas == nil then useAtlas = true end
    
    if useAtlas then
        -- Try to get texture from atlas system
        local textureInfo = VUI:GetTextureCached(texturePath)
        
        -- If texture is from atlas, apply it with coordinates
        if textureInfo and textureInfo.isAtlas then
            frame:SetBackdrop({
                bgFile = textureInfo.path,
                tile = tile or false,
                tileSize = 64
            })
            
            -- We need a custom solution for setting TexCoords on backdrop
            -- Create or reuse the overlay texture for this
            if not frame._atlasOverlay then
                frame._atlasOverlay = frame:CreateTexture(nil, "BACKGROUND")
                frame._atlasOverlay:SetAllPoints(frame)
                frame._atlasOverlay:SetDrawLayer("BACKGROUND", 1)
            end
            
            frame._atlasOverlay:Show()
            frame._atlasOverlay:SetTexture(textureInfo.path)
            frame._atlasOverlay:SetTexCoord(
                textureInfo.coords.left,
                textureInfo.coords.right,
                textureInfo.coords.top,
                textureInfo.coords.bottom
            )
            return
        end
    end
    
    -- Fall back to regular texture if not in atlas or atlas disabled
    if frame._atlasOverlay then
        frame._atlasOverlay:Hide()
    end
    
    frame:SetBackdrop({
        bgFile = texturePath,
        tile = tile or false,
        tileSize = 64
    })
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
function VUI.UI:CreateButton(name, parent, text, icon)
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
        
        -- Adjust text position if icon is provided
        if icon then
            region:ClearAllPoints()
            region:SetPoint("RIGHT", button, "RIGHT", -5, 0)
        end
    end
    
    -- Add icon if provided
    if icon then
        button.icon = button:CreateTexture(name.."Icon", "ARTWORK")
        button.icon:SetSize(16, 16)
        button.icon:SetPoint("LEFT", button, "LEFT", 5, 0)
        button.icon:SetTexture(icon)
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
function VUI.UI:CreateCheckButton(name, parent, text, icon)
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
        
        -- Add spacing for icon if provided
        if icon then
            textObj:SetPoint("LEFT", checkButton, "RIGHT", 24, 0)
        end
    end
    
    -- Add icon if provided
    if icon then
        checkButton.icon = checkButton:CreateTexture(name.."Icon", "ARTWORK")
        checkButton.icon:SetSize(16, 16)
        checkButton.icon:SetPoint("LEFT", checkButton, "RIGHT", 4, 0)
        checkButton.icon:SetTexture(icon)
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

--------------------------------------------------
-- Animation Framework
--------------------------------------------------

-- Create animation namespace
VUI.UI.Animation = {}

-- Animation defaults
VUI.UI.Animation.defaults = {
    duration = 0.3,            -- Default animation duration in seconds
    smoothing = "OUT",         -- Default smoothing method (IN, OUT, INOUT)
    fadeInDuration = 0.2,      -- Default fade in duration
    fadeOutDuration = 0.15,    -- Default fade out duration
    slideDuration = 0.3,       -- Default slide duration
    scaleDuration = 0.25,      -- Default scale duration
    enabled = true,            -- Whether animations are enabled globally
    thresholdFPS = 30,         -- FPS threshold below which animations are disabled
}

-- Initialize animation system
function VUI.UI.Animation:Initialize()
    -- Create animation registry
    self.registry = {}
    
    -- Create a frame for capturing FPS
    self.fpsFrame = CreateFrame("Frame")
    self.fpsFrame.elapsed = 0
    self.fpsFrame.frameCount = 0
    self.fpsFrame.fps = 60
    
    -- Update FPS tracker 
    self.fpsFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        self.frameCount = self.frameCount + 1
        
        if self.elapsed >= 1 then
            VUI.UI.Animation.currentFPS = self.frameCount / self.elapsed
            self.elapsed = 0
            self.frameCount = 0
        end
    end)
    
    -- Set defaults based on settings
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        local settings = VUI.db.profile.appearance
        self.enabled = settings.enableAnimations or self.defaults.enabled
    else
        self.enabled = self.defaults.enabled
    end
end

-- Check if animations should be used (based on settings and FPS)
function VUI.UI.Animation:ShouldAnimate()
    if not self.enabled then
        return false
    end
    
    -- Check FPS - disable animations when FPS is low
    if self.currentFPS and self.currentFPS < self.defaults.thresholdFPS then
        return false
    end
    
    return true
end

-- Create a fade in animation
function VUI.UI.Animation:FadeIn(frame, duration, target, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        frame:SetAlpha(target or 1)
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Stop any existing animations
    if frame.fadeAnim and frame.fadeAnim:IsPlaying() then
        frame.fadeAnim:Stop()
    end
    
    -- Create animation group if needed
    if not frame.fadeAnimGroup then
        frame.fadeAnimGroup = frame:CreateAnimationGroup()
        frame.fadeAnim = frame.fadeAnimGroup:CreateAnimation("Alpha")
    end
    
    -- Set up animation
    frame.fadeAnim:SetFromAlpha(frame:GetAlpha())
    frame.fadeAnim:SetToAlpha(target or 1)
    frame.fadeAnim:SetDuration(duration or self.defaults.fadeInDuration)
    frame.fadeAnim:SetSmoothing(self.defaults.smoothing)
    
    -- Set callback
    if onFinished then
        frame.fadeAnimGroup:SetScript("OnFinished", function() 
            onFinished(frame)
        end)
    else
        frame.fadeAnimGroup:SetScript("OnFinished", nil)
    end
    
    -- Start animation
    frame.fadeAnimGroup:Play()
end

-- Create a fade out animation
function VUI.UI.Animation:FadeOut(frame, duration, target, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        frame:SetAlpha(target or 0)
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Stop any existing animations
    if frame.fadeAnim and frame.fadeAnim:IsPlaying() then
        frame.fadeAnim:Stop()
    end
    
    -- Create animation group if needed
    if not frame.fadeAnimGroup then
        frame.fadeAnimGroup = frame:CreateAnimationGroup()
        frame.fadeAnim = frame.fadeAnimGroup:CreateAnimation("Alpha")
    end
    
    -- Set up animation
    frame.fadeAnim:SetFromAlpha(frame:GetAlpha())
    frame.fadeAnim:SetToAlpha(target or 0)
    frame.fadeAnim:SetDuration(duration or self.defaults.fadeOutDuration)
    frame.fadeAnim:SetSmoothing(self.defaults.smoothing)
    
    -- Set callback
    if onFinished then
        frame.fadeAnimGroup:SetScript("OnFinished", function() 
            onFinished(frame)
        end)
    else
        frame.fadeAnimGroup:SetScript("OnFinished", nil)
    end
    
    -- Start animation
    frame.fadeAnimGroup:Play()
end

-- Create a slide animation
function VUI.UI.Animation:Slide(frame, direction, distance, duration, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        -- Update position immediately
        local x, y = 0, 0
        if direction == "LEFT" then
            x = -distance
        elseif direction == "RIGHT" then
            x = distance
        elseif direction == "UP" then
            y = distance
        elseif direction == "DOWN" then
            y = -distance
        end
        
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        frame:ClearAllPoints()
        frame:SetPoint(point, relativeTo, relativePoint, xOfs + x, yOfs + y)
        
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Stop any existing animations
    if frame.slideAnim and frame.slideAnim:IsPlaying() then
        frame.slideAnim:Stop()
    end
    
    -- Create animation group if needed
    if not frame.slideAnimGroup then
        frame.slideAnimGroup = frame:CreateAnimationGroup()
        frame.slideAnim = frame.slideAnimGroup:CreateAnimation("Translation")
    end
    
    -- Set up animation
    local x, y = 0, 0
    if direction == "LEFT" then
        x = -distance
    elseif direction == "RIGHT" then
        x = distance
    elseif direction == "UP" then
        y = distance
    elseif direction == "DOWN" then
        y = -distance
    end
    
    frame.slideAnim:SetOffset(x, y)
    frame.slideAnim:SetDuration(duration or self.defaults.slideDuration)
    frame.slideAnim:SetSmoothing(self.defaults.smoothing)
    
    -- Set callback
    if onFinished then
        frame.slideAnimGroup:SetScript("OnFinished", function() 
            onFinished(frame)
        end)
    else
        frame.slideAnimGroup:SetScript("OnFinished", nil)
    end
    
    -- Start animation
    frame.slideAnimGroup:Play()
end

-- Create a scale animation
function VUI.UI.Animation:Scale(frame, fromScale, toScale, duration, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        frame:SetScale(toScale or 1)
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Stop any existing animations
    if frame.scaleAnim and frame.scaleAnim:IsPlaying() then
        frame.scaleAnim:Stop()
    end
    
    -- Create animation group if needed
    if not frame.scaleAnimGroup then
        frame.scaleAnimGroup = frame:CreateAnimationGroup()
        frame.scaleAnim = frame.scaleAnimGroup:CreateAnimation("Scale")
    end
    
    -- Set up animation
    frame.scaleAnim:SetFromScale(fromScale or frame:GetScale(), fromScale or frame:GetScale())
    frame.scaleAnim:SetToScale(toScale or 1, toScale or 1)
    frame.scaleAnim:SetDuration(duration or self.defaults.scaleDuration)
    frame.scaleAnim:SetSmoothing(self.defaults.smoothing)
    
    -- Set callback
    if onFinished then
        frame.scaleAnimGroup:SetScript("OnFinished", function() 
            onFinished(frame)
        end)
    else
        frame.scaleAnimGroup:SetScript("OnFinished", nil)
    end
    
    -- Start animation
    frame.scaleAnimGroup:Play()
end

-- Flash a frame to draw attention to it
function VUI.UI.Animation:Flash(frame, count, duration, minAlpha, maxAlpha, onFinished)
    if not frame then return end
    
    count = count or 3
    duration = duration or 0.2
    minAlpha = minAlpha or 0.3
    maxAlpha = maxAlpha or 1.0
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Stop any existing animations
    if frame.flashAnimGroup and frame.flashAnimGroup:IsPlaying() then
        frame.flashAnimGroup:Stop()
    end
    
    -- Create animation group if needed
    if not frame.flashAnimGroup then
        frame.flashAnimGroup = frame:CreateAnimationGroup()
    else
        frame.flashAnimGroup:SetLooping("NONE")
        frame.flashAnimGroup:SetToFinalAlpha(true)
        frame.flashAnimGroup:Stop()
        
        -- Clear all existing animations
        for i = frame.flashAnimGroup:GetNumAnimations(), 1, -1 do
            local anim = select(i, frame.flashAnimGroup:GetAnimations())
            anim:SetScript("OnFinished", nil)
            anim:SetScript("OnUpdate", nil)
            anim:SetScript("OnPlay", nil)
            frame.flashAnimGroup:GetAnimations():Delete()
        end
    end
    
    -- Create flash animations
    local originalAlpha = frame:GetAlpha()
    local totalDuration = 0
    
    for i = 1, count * 2 do
        local anim = frame.flashAnimGroup:CreateAnimation("Alpha")
        anim:SetFromAlpha(i % 2 == 1 and originalAlpha or maxAlpha)
        anim:SetToAlpha(i % 2 == 1 and maxAlpha or minAlpha)
        anim:SetDuration(duration)
        anim:SetOrder(i)
        totalDuration = totalDuration + duration
    end
    
    -- Add final animation to restore original alpha
    local finalAnim = frame.flashAnimGroup:CreateAnimation("Alpha")
    finalAnim:SetFromAlpha(minAlpha)
    finalAnim:SetToAlpha(originalAlpha)
    finalAnim:SetDuration(duration)
    finalAnim:SetOrder(count * 2 + 1)
    
    -- Set callback
    if onFinished then
        frame.flashAnimGroup:SetScript("OnFinished", function() 
            onFinished(frame)
        end)
    else
        frame.flashAnimGroup:SetScript("OnFinished", nil)
    end
    
    -- Start animation
    frame.flashAnimGroup:Play()
end

-- Create a glow effect animation
function VUI.UI.Animation:Glow(frame, color, duration, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Create a glow overlay if it doesn't exist
    if not frame.glowOverlay then
        frame.glowOverlay = CreateFrame("Frame", nil, frame)
        frame.glowOverlay:SetFrameStrata("HIGH")
        frame.glowOverlay:SetAllPoints(frame)
        frame.glowOverlay:SetAlpha(0)
        
        -- Create a texture for the glow
        frame.glowOverlay.texture = frame.glowOverlay:CreateTexture(nil, "OVERLAY")
        frame.glowOverlay.texture:SetAllPoints()
        frame.glowOverlay.texture:SetTexture(VUI:GetTexture("textures", "glow"))
        frame.glowOverlay.texture:SetBlendMode("ADD")
    end
    
    -- Set the texture color
    if color then
        frame.glowOverlay.texture:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, color.a or 0.7)
    else
        -- Use theme color if no color specified
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        local themeColor = VUI.UI:GetThemeColors().border
        frame.glowOverlay.texture:SetVertexColor(themeColor.r, themeColor.g, themeColor.b, 0.7)
    end
    
    -- Perform the animation
    frame.glowOverlay:Show()
    
    -- Fade in
    self:FadeIn(frame.glowOverlay, 0.2, 0.7, function()
        -- Hold for a moment
        C_Timer.After(duration or 0.5, function()
            -- Fade out
            self:FadeOut(frame.glowOverlay, 0.3, 0, function()
                if onFinished then onFinished(frame) end
            end)
        end)
    end)
end

-- Create a shine effect animation (moving highlight)
function VUI.UI.Animation:Shine(frame, angle, width, duration, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        if onFinished then onFinished(frame) end
        return
    end
    
    -- Create a shine overlay if it doesn't exist
    if not frame.shineOverlay then
        frame.shineOverlay = CreateFrame("Frame", nil, frame)
        frame.shineOverlay:SetFrameStrata("HIGH")
        frame.shineOverlay:SetAllPoints(frame)
        
        -- Create a texture for the shine
        frame.shineOverlay.texture = frame.shineOverlay:CreateTexture(nil, "OVERLAY")
        frame.shineOverlay.texture:SetTexture("Interface\\Buttons\\WHITE8x8")
        frame.shineOverlay.texture:SetBlendMode("ADD")
        frame.shineOverlay.texture:SetVertexColor(1, 1, 1, 0.5)
    end
    
    -- Set up the shine
    local frameWidth, frameHeight = frame:GetSize()
    local shineWidth = width or frameWidth * 0.3
    local shineHeight = frameHeight * 2
    
    -- Position and size the shine texture
    frame.shineOverlay.texture:SetSize(shineWidth, shineHeight)
    
    -- Determine start and end positions based on angle
    local angle = angle or 45
    local radian = math.rad(angle)
    local startX, startY, endX, endY
    
    -- Calculate diagonal distance across frame
    local diagonal = math.sqrt(frameWidth^2 + frameHeight^2)
    
    -- Calculate start position (offscreen)
    startX = -diagonal * math.cos(radian)
    startY = -diagonal * math.sin(radian)
    
    -- Calculate end position (offscreen on other side)
    endX = diagonal * math.cos(radian)
    endY = diagonal * math.sin(radian)
    
    -- Position the shine at start
    frame.shineOverlay.texture:ClearAllPoints()
    frame.shineOverlay.texture:SetPoint("CENTER", frame, "CENTER", startX, startY)
    frame.shineOverlay:Show()
    
    -- Create animation group if needed
    if not frame.shineAnimGroup then
        frame.shineAnimGroup = frame.shineOverlay:CreateAnimationGroup()
        frame.shineMoveAnim = frame.shineAnimGroup:CreateAnimation("Translation")
    end
    
    -- Set up animation
    frame.shineMoveAnim:SetOffset(endX - startX, endY - startY)
    frame.shineMoveAnim:SetDuration(duration or 0.5)
    frame.shineMoveAnim:SetSmoothing("IN_OUT")
    
    -- Set callback
    frame.shineAnimGroup:SetScript("OnFinished", function() 
        frame.shineOverlay:Hide()
        if onFinished then onFinished(frame) end
    end)
    
    -- Start animation
    frame.shineAnimGroup:Play()
end

-- Create a bounce effect
function VUI.UI.Animation:Bounce(frame, height, count, onFinished)
    if not frame then return end
    
    -- Skip animation if disabled
    if not self:ShouldAnimate() then
        if onFinished then onFinished(frame) end
        return
    end
    
    height = height or 10
    count = count or 3
    
    -- Stop any existing animations
    if frame.bounceAnimGroup and frame.bounceAnimGroup:IsPlaying() then
        frame.bounceAnimGroup:Stop()
    end
    
    -- Create animation group if needed
    if not frame.bounceAnimGroup then
        frame.bounceAnimGroup = frame:CreateAnimationGroup()
    else
        frame.bounceAnimGroup:SetLooping("NONE")
        frame.bounceAnimGroup:Stop()
        
        -- Clear all existing animations
        for i = frame.bounceAnimGroup:GetNumAnimations(), 1, -1 do
            local anim = select(i, frame.bounceAnimGroup:GetAnimations())
            anim:SetScript("OnFinished", nil)
            anim:SetScript("OnUpdate", nil)
            anim:SetScript("OnPlay", nil)
            frame.bounceAnimGroup:GetAnimations():Delete()
        end
    end
    
    -- Create bounce animations
    local totalDuration = 0
    local bounceUpDuration = 0.2
    local bounceDownDuration = 0.15
    
    for i = 1, count do
        local upAnim = frame.bounceAnimGroup:CreateAnimation("Translation")
        upAnim:SetOffset(0, height * (count - i + 1) / count)
        upAnim:SetDuration(bounceUpDuration * (count - i + 1) / count)
        upAnim:SetSmoothing("OUT")
        upAnim:SetOrder(i * 2 - 1)
        
        local downAnim = frame.bounceAnimGroup:CreateAnimation("Translation")
        downAnim:SetOffset(0, -height * (count - i + 1) / count)
        downAnim:SetDuration(bounceDownDuration * (count - i + 1) / count)
        downAnim:SetSmoothing("IN")
        downAnim:SetOrder(i * 2)
        
        totalDuration = totalDuration + bounceUpDuration + bounceDownDuration
    end
    
    -- Set callback
    if onFinished then
        frame.bounceAnimGroup:SetScript("OnFinished", function() 
            onFinished(frame)
        end)
    else
        frame.bounceAnimGroup:SetScript("OnFinished", nil)
    end
    
    -- Start animation
    frame.bounceAnimGroup:Play()
end

-- Apply theme transition effect when theme changes
function VUI.UI.Animation:ThemeTransition(onFinished)
    if not self:ShouldAnimate() then
        if onFinished then onFinished() end
        return
    end
    
    -- Create full-screen overlay if it doesn't exist
    if not self.themeTransitionFrame then
        self.themeTransitionFrame = CreateFrame("Frame", nil, UIParent)
        self.themeTransitionFrame:SetFrameStrata("FULLSCREEN")
        self.themeTransitionFrame:SetAllPoints(UIParent)
        self.themeTransitionFrame:SetAlpha(0)
        self.themeTransitionFrame:Hide()
        
        -- Create a texture for the overlay
        self.themeTransitionFrame.texture = self.themeTransitionFrame:CreateTexture(nil, "BACKGROUND")
        self.themeTransitionFrame.texture:SetAllPoints()
        self.themeTransitionFrame.texture:SetColorTexture(0, 0, 0, 1)
    end
    
    -- Show the overlay
    self.themeTransitionFrame:Show()
    
    -- Fade in
    self:FadeIn(self.themeTransitionFrame, 0.2, 0.8, function()
        -- Call the theme change handler
        if onFinished then
            onFinished()
        end
        
        -- Fade out
        C_Timer.After(0.1, function()
            self:FadeOut(self.themeTransitionFrame, 0.5, 0, function()
                self.themeTransitionFrame:Hide()
            end)
        end)
    end)
end

-- Initialize the animation system
VUI.UI.Animation:Initialize()