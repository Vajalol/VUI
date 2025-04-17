-- VUI Example Module - Core Functionality
-- This file demonstrates how to use the VUI UI frameworks
local _, VUI = ...
local Example = VUI.example

-- Create the main UI
function Example:CreateUI()
    -- Skip if frame already exists
    if self.frame then 
        return self.frame 
    end
    
    -- Create main frame using VUI UI framework
    self.frame = self:CreateFrame("VUIExampleFrame", UIParent)
    self.frame:SetSize(300, 200)
    
    -- Set position from saved settings
    local pos = self.settings.position
    self.frame:SetPoint(pos[1], UIParent, pos[1], pos[2], pos[3])
    
    -- Set scale
    self.frame:SetScale(self.settings.scale)
    
    -- Make frame movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        
        -- Save new position
        local point, _, _, xOfs, yOfs = frame:GetPoint()
        self.settings.position = {point, xOfs, yOfs}
    end)
    
    -- Create title bar
    self.titleBar = self:CreateFrame("VUIExampleTitleBar", self.frame)
    self.titleBar:SetPoint("TOPLEFT", 0, 0)
    self.titleBar:SetPoint("TOPRIGHT", 0, 0)
    self.titleBar:SetHeight(24)
    
    -- Set title appearance
    self.titleBar:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    
    -- Add title text
    self.titleText = self.titleBar:CreateFontString(nil, "OVERLAY")
    self.titleText:SetPoint("CENTER", self.titleBar, "CENTER")
    self.titleText:SetText("VUI Example Module")
    
    -- Apply font from media system
    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize + 2
    self.titleText:SetFont(fontPath, fontSize, "OUTLINE")
    
    -- Add close button using our UI framework
    self.closeButton = self:CreateButton("VUIExampleCloseButton", self.titleBar, "X")
    self.closeButton:SetSize(20, 20)
    self.closeButton:SetPoint("TOPRIGHT", -2, -2)
    self.closeButton:SetScript("OnClick", function() self:Hide() end)
    
    -- Create content area
    self.content = self:CreateFrame("VUIExampleContent", self.frame)
    self.content:SetPoint("TOPLEFT", self.titleBar, "BOTTOMLEFT", 0, 0)
    self.content:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
    
    -- Add demonstration widgets
    self:CreateWidgets()
    
    -- Check if title should be visible
    if not self.settings.showTitle then
        self.titleBar:Hide()
        self.content:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    end
    
    -- Hide by default if module is disabled
    if not self.enabled then
        self.frame:Hide()
    end
    
    -- Apply current theme
    self:ApplyTheme()
    
    return self.frame
end

-- Create widgets for the example module
function Example:CreateWidgets()
    -- Add some example widgets using both UI and Widgets frameworks
    
    -- Create label using basic UI
    self.label = self.content:CreateFontString(nil, "OVERLAY")
    self.label:SetPoint("TOPLEFT", 15, -15)
    self.label:SetWidth(270)
    self.label:SetJustifyH("LEFT")
    self.label:SetText("This example module demonstrates how to use the VUI frameworks")
    
    -- Apply font
    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    self.label:SetFont(fontPath, fontSize, "")
    
    -- Create a button
    self.button = self:CreateButton("VUIExampleButton", self.content, "Click Me")
    self.button:SetSize(100, 30)
    self.button:SetPoint("TOPLEFT", self.label, "BOTTOMLEFT", 0, -20)
    self.button:SetScript("OnClick", function() 
        VUI:Print("Example button clicked")
        -- Play a sound using the media system
        VUI:PlaySound("button")
    end)
    
    -- Create a checkbox
    self.checkbox = self:CreateCheckButton("VUIExampleCheckbox", self.content, "Example Option")
    self.checkbox:SetPoint("TOPLEFT", self.button, "BOTTOMLEFT", -4, -10)
    
    -- Create progress bar using the Widgets framework
    self.progressBar = self:CreateProgressBar("VUIExampleProgressBar", self.content, 200, 20, "Progress:")
    self.progressBar:SetPoint("TOPLEFT", self.checkbox, "BOTTOMLEFT", 4, -20)
    self.progressBar:SetValue(50, 100)
    self.progressBar:SetColor(0.2, 0.8, 0.2)
    
    -- Add a slider
    self.slider = self:CreateSlider(self.content, "VUIExampleSlider", "Example Slider", 0, 100, 1)
    self.slider:SetWidth(200)
    self.slider:SetPoint("TOPLEFT", self.progressBar, "BOTTOMLEFT", 0, -20)
    self.slider:SetValue(50)
    self.slider:SetScript("OnValueChanged", function(_, value)
        self.progressBar:SetValue(value, 100)
    end)
end

-- Show the module UI
function Example:Show()
    if not self.frame then
        self:CreateUI()
    end
    
    self.frame:Show()
end

-- Hide the module UI
function Example:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

-- Toggle module UI visibility
function Example:Toggle()
    if not self.frame then
        self:CreateUI()
        self.frame:Show()
        return
    end
    
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

-- Reset position
function Example:ResetPosition()
    if not self.frame then return end
    
    self.settings.position = {"CENTER", 0, 0}
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    VUI:Print("Example module position reset")
end

-- Apply current theme
function Example:ApplyTheme()
    if not self.frame then return end
    
    -- Get theme colors
    local theme = VUI.db.profile.appearance.theme or "dark"
    local themeData = VUI.media.themes[theme]
    
    if not themeData then return end
    
    -- Apply colors
    self.frame:SetBackdropColor(
        themeData.colors.backdrop.r,
        themeData.colors.backdrop.g,
        themeData.colors.backdrop.b,
        themeData.colors.backdrop.a
    )
    
    self.frame:SetBackdropBorderColor(
        themeData.colors.border.r,
        themeData.colors.border.g,
        themeData.colors.border.b,
        themeData.colors.border.a
    )
    
    self.content:SetBackdropColor(
        themeData.colors.backdrop.r,
        themeData.colors.backdrop.g,
        themeData.colors.backdrop.b,
        themeData.colors.backdrop.a
    )
    
    -- Apply text colors
    if self.label then
        self.label:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
    end
    
    if self.titleText then
        self.titleText:SetTextColor(
            themeData.colors.header.r,
            themeData.colors.header.g,
            themeData.colors.header.b,
            themeData.colors.header.a
        )
    end
end

-- Update UI when settings change
function Example:UpdateUI()
    if not self.frame then return end
    
    -- Apply scale
    self.frame:SetScale(self.settings.scale)
    
    -- Toggle title bar visibility
    if self.settings.showTitle then
        self.titleBar:Show()
        self.content:SetPoint("TOPLEFT", self.titleBar, "BOTTOMLEFT", 0, 0)
    else
        self.titleBar:Hide()
        self.content:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    end
    
    -- Apply current theme
    self:ApplyTheme()
end