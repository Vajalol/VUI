-- VUI Core functions

-- Initialize database
function VUI:InitializeDB()
    -- Create main database using AceDB-3.0
    self.db = LibStub("AceDB-3.0"):New("VUIDB", self.defaults, true)
    
    -- Set up profile handling
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    -- Initialize module databases
    self:InitializeModuleDBs()
end

-- Initialize databases for each module
function VUI:InitializeModuleDBs()
    -- Each module has its own database with profile support
    self.BuffOverlay.db = LibStub("AceDB-3.0"):New("BuffOverlayDB", self.BuffOverlay.defaults, true)
    self.TrufiGCD.db = LibStub("AceDB-3.0"):New("TrufiGCDDB", self.TrufiGCD.defaults, true)
    self.MoveAny.db = LibStub("AceDB-3.0"):New("MoveAnyDB", self.MoveAny.defaults, true)
    self.Auctionator.db = LibStub("AceDB-3.0"):New("AuctionatorDB", self.Auctionator.defaults, true)
    self.AngryKeystones.db = LibStub("AceDB-3.0"):New("AngryKeystonesDB", self.AngryKeystones.defaults, true)
    self.OmniCC.db = LibStub("AceDB-3.0"):New("OmniCCDB", self.OmniCC.defaults, true)
    self.OmniCD.db = LibStub("AceDB-3.0"):New("OmniCDDB", self.OmniCD.defaults, true)
    
    -- Register callbacks for profile changes
    for _, moduleName in ipairs(self.modules) do
        if self[moduleName] and self[moduleName].db then
            self[moduleName].db.RegisterCallback(self[moduleName], "OnProfileChanged", "RefreshConfig")
            self[moduleName].db.RegisterCallback(self[moduleName], "OnProfileCopied", "RefreshConfig")
            self[moduleName].db.RegisterCallback(self[moduleName], "OnProfileReset", "RefreshConfig")
        end
    end
end

-- Refresh config when profile changes
function VUI:RefreshConfig()
    -- Update core settings
    self:ApplySettings()
    
    -- Refresh module configs
    for _, moduleName in ipairs(self.modules) do
        if self.enabledModules[moduleName] and self[moduleName] and self[moduleName].RefreshConfig then
            self[moduleName]:RefreshConfig()
        end
    end
    
    -- Rebuild config panels
    self:CreateConfigPanel(true)
end

-- Apply settings from the database
function VUI:ApplySettings()
    -- Apply core settings
    local settings = self.db.profile
    
    -- Update module enabled states
    for _, moduleName in ipairs(self.modules) do
        self.enabledModules[moduleName] = settings.modules[moduleName]
    end
    
    -- Apply any global theme settings
    self:ApplyTheme(settings.theme)
end

-- Apply theme settings
function VUI:ApplyTheme(theme)
    -- Apply global theming like colors, fonts, etc.
    self.activeTheme = theme
    
    -- Update UI elements with theme settings
    if self.UI then
        -- Update fonts
        self.UI:UpdateFonts(theme.font, theme.fontSize)
        
        -- Update colors
        self.UI:UpdateColors(theme.primaryColor, theme.accentColor)
        
        -- Update textures
        self.UI:UpdateTextures(theme.barTexture)
    end
end

-- Open the config panel
function VUI:OpenConfigPanel()
    if not self.configFrame then
        self:CreateConfigPanel()
    end
    
    self.configFrame:Show()
end

-- Create UI element helper functions
VUI.UI = {}

-- Create standard button
function VUI.UI:CreateButton(parent, name, text, width, height)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, height or 25)
    button:SetText(text)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(text)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    return button
end

-- Create checkbox
function VUI.UI:CreateCheckbox(parent, name, text)
    local checkbox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox.Text:SetText(text)
    return checkbox
end

-- Create slider
function VUI.UI:CreateSlider(parent, name, text, min, max, step)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText(min)
    slider.High:SetText(max)
    slider.Text:SetText(text)
    return slider
end

-- Create dropdown
function VUI.UI:CreateDropdown(parent, name, text, width)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    label:SetText(text)
    UIDropDownMenu_SetWidth(dropdown, width or 100)
    return dropdown, label
end

-- Update fonts for UI elements
function VUI.UI:UpdateFonts(fontFamily, fontSize)
    -- Apply font changes to all UI elements
    -- This would typically iterate through registered UI elements
end

-- Update colors for UI elements
function VUI.UI:UpdateColors(primaryColor, accentColor)
    -- Apply color changes to all UI elements
    -- This would typically iterate through registered UI elements
end

-- Update textures for UI elements
function VUI.UI:UpdateTextures(barTexture)
    -- Apply texture changes to all UI elements
    -- This would typically iterate through registered UI elements
end
