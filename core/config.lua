-- VUI Config Panel

-- Create main config panel
function VUI:CreateConfigPanel(rebuild)
    -- Clean up existing panel if rebuilding
    if self.configFrame and rebuild then
        self.configFrame:Hide()
        self.configFrame = nil
    end
    
    -- Don't recreate if it already exists
    if self.configFrame then
        return
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "VUIConfigFrame", UIParent)
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 20, -20)
    frame.title:SetText("|cff1784d1VUI|r Configuration")
    
    -- Close button
    frame.closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    -- Create tabs
    self:CreateConfigTabs(frame)
    
    -- Create content frames
    self:CreateGeneralOptions(frame)
    self:CreateModuleOptions(frame)
    self:CreateProfileOptions(frame)
    
    -- Show general options by default
    self:ShowConfigSection(frame, "General")
    
    -- Store the frame
    self.configFrame = frame
end

-- Create config tabs
function VUI:CreateConfigTabs(frame)
    frame.tabs = {}
    
    -- Tab container
    frame.tabContainer = CreateFrame("Frame", nil, frame)
    frame.tabContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
    frame.tabContainer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 20)
    frame.tabContainer:SetWidth(150)
    
    -- Tab background
    frame.tabContainerBg = frame.tabContainer:CreateTexture(nil, "BACKGROUND")
    frame.tabContainerBg:SetAllPoints()
    frame.tabContainerBg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    
    -- Create tab buttons
    local tabs = {
        {text = "General", icon = "Interface\\Icons\\INV_Misc_Note_01"},
        {text = "Modules", icon = "Interface\\Icons\\INV_Misc_EngGizmos_30"},
        {text = "Profiles", icon = "Interface\\Icons\\INV_Misc_Book_16"}
    }
    
    local prevTab
    for i, tabInfo in ipairs(tabs) do
        local tab = CreateFrame("Button", nil, frame.tabContainer)
        tab:SetSize(130, 30)
        
        if prevTab then
            tab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -5)
        else
            tab:SetPoint("TOPLEFT", frame.tabContainer, "TOPLEFT", 10, -10)
        end
        
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.text:SetPoint("LEFT", 30, 0)
        tab.text:SetText(tabInfo.text)
        
        tab.icon = tab:CreateTexture(nil, "ARTWORK")
        tab.icon:SetSize(16, 16)
        tab.icon:SetPoint("LEFT", 8, 0)
        tab.icon:SetTexture(tabInfo.icon)
        
        tab.highlight = tab:CreateTexture(nil, "HIGHLIGHT")
        tab.highlight:SetAllPoints()
        tab.highlight:SetColorTexture(1, 1, 1, 0.2)
        
        tab.selected = tab:CreateTexture(nil, "BACKGROUND")
        tab.selected:SetAllPoints()
        tab.selected:SetColorTexture(0.2, 0.4, 0.8, 0.3)
        tab.selected:Hide()
        
        tab:SetScript("OnClick", function()
            self:ShowConfigSection(frame, tabInfo.text)
        end)
        
        frame.tabs[tabInfo.text] = tab
        prevTab = tab
    end
    
    -- Content container
    frame.contentContainer = CreateFrame("Frame", nil, frame)
    frame.contentContainer:SetPoint("TOPLEFT", frame.tabContainer, "TOPRIGHT", 10, 0)
    frame.contentContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
    
    -- Content background
    frame.contentBg = frame.contentContainer:CreateTexture(nil, "BACKGROUND")
    frame.contentBg:SetAllPoints()
    frame.contentBg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    
    -- Content sections
    frame.sections = {}
end

-- Show config section by name
function VUI:ShowConfigSection(frame, sectionName)
    -- Highlight the selected tab and hide others
    for name, tab in pairs(frame.tabs) do
        if name == sectionName then
            tab.selected:Show()
        else
            tab.selected:Hide()
        end
    end
    
    -- Show the selected section and hide others
    for name, section in pairs(frame.sections) do
        if name == sectionName then
            section:Show()
        else
            section:Hide()
        end
    end
end

-- Create general options panel
function VUI:CreateGeneralOptions(frame)
    local section = CreateFrame("Frame", nil, frame.contentContainer)
    section:SetAllPoints()
    
    -- Title
    section.title = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    section.title:SetPoint("TOPLEFT", 20, -20)
    section.title:SetText("General Settings")
    
    -- Version info
    section.version = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.version:SetPoint("TOPLEFT", section.title, "BOTTOMLEFT", 0, -10)
    section.version:SetText("Version: " .. self.version .. " by " .. self.author)
    
    -- Theme settings
    section.themeTitle = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    section.themeTitle:SetPoint("TOPLEFT", section.version, "BOTTOMLEFT", 0, -20)
    section.themeTitle:SetText("Theme Settings")
    
    -- Primary color
    section.primaryColorText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.primaryColorText:SetPoint("TOPLEFT", section.themeTitle, "BOTTOMLEFT", 0, -15)
    section.primaryColorText:SetText("Primary Color:")
    
    section.primaryColorPicker = CreateFrame("Button", nil, section)
    section.primaryColorPicker:SetSize(20, 20)
    section.primaryColorPicker:SetPoint("LEFT", section.primaryColorText, "RIGHT", 10, 0)
    
    local r, g, b = unpack(self.db.profile.theme.primaryColor)
    section.primaryColorPicker.tex = section.primaryColorPicker:CreateTexture(nil, "OVERLAY")
    section.primaryColorPicker.tex:SetAllPoints()
    section.primaryColorPicker.tex:SetColorTexture(r, g, b, 1)
    
    section.primaryColorPicker:SetScript("OnClick", function()
        local r, g, b = unpack(self.db.profile.theme.primaryColor)
        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            self.db.profile.theme.primaryColor = {r, g, b}
            section.primaryColorPicker.tex:SetColorTexture(r, g, b, 1)
            self:ApplyTheme(self.db.profile.theme)
        end
        
        ColorPickerFrame.cancelFunc = function()
            section.primaryColorPicker.tex:SetColorTexture(r, g, b, 1)
        end
        
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame:Show()
    end)
    
    -- Font selection
    section.fontText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.fontText:SetPoint("TOPLEFT", section.primaryColorText, "BOTTOMLEFT", 0, -15)
    section.fontText:SetText("Font:")
    
    section.fontDropdown = self.UI:CreateDropdown(section, "VUIFontDropdown", "", 150)
    section.fontDropdown:SetPoint("LEFT", section.fontText, "RIGHT", 10, 0)
    
    -- Populate font dropdown
    UIDropDownMenu_Initialize(section.fontDropdown, function(dropdown, level)
        local fonts = {"Expressway", "Friz Quadrata", "Arial Narrow", "Morpheus"}
        local info = UIDropDownMenu_CreateInfo()
        
        for _, font in ipairs(fonts) do
            info.text = font
            info.value = font
            info.func = function(self)
                self.db.profile.theme.font = self.value
                UIDropDownMenu_SetText(dropdown, self.value)
                VUI:ApplyTheme(VUI.db.profile.theme)
            end
            info.checked = (self.db.profile.theme.font == font)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetText(section.fontDropdown, self.db.profile.theme.font)
    
    -- Font size
    section.fontSizeText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.fontSizeText:SetPoint("TOPLEFT", section.fontText, "BOTTOMLEFT", 0, -15)
    section.fontSizeText:SetText("Font Size:")
    
    section.fontSizeSlider = self.UI:CreateSlider(section, "VUIFontSizeSlider", "", 8, 18, 1)
    section.fontSizeSlider:SetPoint("LEFT", section.fontSizeText, "RIGHT", 30, 0)
    section.fontSizeSlider:SetWidth(150)
    section.fontSizeSlider:SetValue(self.db.profile.theme.fontSize)
    
    section.fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        VUI.db.profile.theme.fontSize = value
        VUI:ApplyTheme(VUI.db.profile.theme)
    end)
    
    -- Texture selection
    section.textureText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.textureText:SetPoint("TOPLEFT", section.fontSizeText, "BOTTOMLEFT", 0, -15)
    section.textureText:SetText("Bar Texture:")
    
    section.textureDropdown = self.UI:CreateDropdown(section, "VUITextureDropdown", "", 150)
    section.textureDropdown:SetPoint("LEFT", section.textureText, "RIGHT", 10, 0)
    
    -- Populate texture dropdown
    UIDropDownMenu_Initialize(section.textureDropdown, function(dropdown, level)
        local textures = {"Smooth", "Flat", "Gloss", "Gradient"}
        local info = UIDropDownMenu_CreateInfo()
        
        for _, texture in ipairs(textures) do
            info.text = texture
            info.value = texture
            info.func = function(self)
                VUI.db.profile.theme.barTexture = self.value
                UIDropDownMenu_SetText(dropdown, self.value)
                VUI:ApplyTheme(VUI.db.profile.theme)
            end
            info.checked = (VUI.db.profile.theme.barTexture == texture)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetText(section.textureDropdown, self.db.profile.theme.barTexture)
    
    -- Store the section
    frame.sections["General"] = section
end

-- Create module options panel
function VUI:CreateModuleOptions(frame)
    local section = CreateFrame("Frame", nil, frame.contentContainer)
    section:SetAllPoints()
    section:Hide()
    
    -- Title
    section.title = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    section.title:SetPoint("TOPLEFT", 20, -20)
    section.title:SetText("Module Settings")
    
    -- Module list
    section.moduleList = CreateFrame("Frame", nil, section)
    section.moduleList:SetPoint("TOPLEFT", section.title, "BOTTOMLEFT", 0, -20)
    section.moduleList:SetSize(150, 400)
    
    -- Module list background
    section.moduleListBg = section.moduleList:CreateTexture(nil, "BACKGROUND")
    section.moduleListBg:SetAllPoints()
    section.moduleListBg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    
    -- Create module buttons
    section.moduleButtons = {}
    local prevButton
    
    for i, moduleName in ipairs(self.modules) do
        local button = CreateFrame("Button", nil, section.moduleList)
        button:SetSize(140, 30)
        
        if prevButton then
            button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, -5)
        else
            button:SetPoint("TOPLEFT", section.moduleList, "TOPLEFT", 5, -5)
        end
        
        -- Enable/disable checkbox
        button.checkbox = self.UI:CreateCheckbox(button, "VUI"..moduleName.."Checkbox", "")
        button.checkbox:SetPoint("LEFT", 5, 0)
        button.checkbox:SetChecked(self.enabledModules[moduleName])
        
        button.checkbox:SetScript("OnClick", function(self)
            VUI.db.profile.modules[moduleName] = self:GetChecked()
            VUI.enabledModules[moduleName] = self:GetChecked()
            
            -- Enable/disable the module functionality
            if VUI.enabledModules[moduleName] then
                if VUI[moduleName] and VUI[moduleName].Enable then
                    VUI[moduleName]:Enable()
                end
            else
                if VUI[moduleName] and VUI[moduleName].Disable then
                    VUI[moduleName]:Disable()
                end
            end
        end)
        
        -- Module name
        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.text:SetPoint("LEFT", button.checkbox, "RIGHT", 5, 0)
        button.text:SetText(moduleName)
        
        -- Click behavior
        button:SetScript("OnClick", function()
            self:ShowModuleConfig(section, moduleName)
        end)
        
        -- Highlight
        button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
        button.highlight:SetAllPoints()
        button.highlight:SetColorTexture(1, 1, 1, 0.2)
        
        button.selected = button:CreateTexture(nil, "BACKGROUND")
        button.selected:SetAllPoints()
        button.selected:SetColorTexture(0.2, 0.4, 0.8, 0.3)
        button.selected:Hide()
        
        section.moduleButtons[moduleName] = button
        prevButton = button
    end
    
    -- Module config container
    section.moduleConfig = CreateFrame("Frame", nil, section)
    section.moduleConfig:SetPoint("TOPLEFT", section.moduleList, "TOPRIGHT", 10, 0)
    section.moduleConfig:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", -10, 10)
    
    -- Module config background
    section.moduleConfigBg = section.moduleConfig:CreateTexture(nil, "BACKGROUND")
    section.moduleConfigBg:SetAllPoints()
    section.moduleConfigBg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    
    -- Default message
    section.moduleConfig.defaultText = section.moduleConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.moduleConfig.defaultText:SetPoint("CENTER")
    section.moduleConfig.defaultText:SetText("Select a module to configure")
    
    -- Module config frames
    section.moduleConfigFrames = {}
    
    -- Show default module (first one)
    if #self.modules > 0 then
        self:ShowModuleConfig(section, self.modules[1])
    end
    
    -- Store the section
    frame.sections["Modules"] = section
end

-- Show specific module config
function VUI:ShowModuleConfig(section, moduleName)
    -- Hide default text
    section.moduleConfig.defaultText:Hide()
    
    -- Highlight selected module
    for name, button in pairs(section.moduleButtons) do
        if name == moduleName then
            button.selected:Show()
        else
            button.selected:Hide()
        end
    end
    
    -- Create config frame for module if it doesn't exist
    if not section.moduleConfigFrames[moduleName] then
        local configFrame = CreateFrame("Frame", nil, section.moduleConfig)
        configFrame:SetAllPoints()
        
        -- Title
        configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        configFrame.title:SetPoint("TOPLEFT", 20, -20)
        configFrame.title:SetText(moduleName .. " Configuration")
        
        -- Create module-specific settings
        if self[moduleName] and self[moduleName].CreateConfigOptions then
            self[moduleName]:CreateConfigOptions(configFrame)
        else
            -- Default message if no custom config
            configFrame.defaultText = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            configFrame.defaultText:SetPoint("CENTER")
            configFrame.defaultText:SetText("No configuration options available for this module")
        end
        
        section.moduleConfigFrames[moduleName] = configFrame
    end
    
    -- Show selected module config and hide others
    for name, frame in pairs(section.moduleConfigFrames) do
        if name == moduleName then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

-- Create profile options panel
function VUI:CreateProfileOptions(frame)
    local section = CreateFrame("Frame", nil, frame.contentContainer)
    section:SetAllPoints()
    section:Hide()
    
    -- Title
    section.title = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    section.title:SetPoint("TOPLEFT", 20, -20)
    section.title:SetText("Profile Settings")
    
    -- Current profile
    section.currentProfileText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.currentProfileText:SetPoint("TOPLEFT", section.title, "BOTTOMLEFT", 0, -20)
    section.currentProfileText:SetText("Current Profile: " .. self.db:GetCurrentProfile())
    
    -- Profile dropdown
    section.profileDropdown = self.UI:CreateDropdown(section, "VUIProfileDropdown", "Select Profile:", 200)
    section.profileDropdown:SetPoint("TOPLEFT", section.currentProfileText, "BOTTOMLEFT", 0, -20)
    
    -- Populate profile dropdown
    UIDropDownMenu_Initialize(section.profileDropdown, function(dropdown, level)
        local profiles = self.db:GetProfiles()
        local info = UIDropDownMenu_CreateInfo()
        
        for _, profile in ipairs(profiles) do
            info.text = profile
            info.value = profile
            info.func = function(self)
                VUI.db:SetProfile(self.value)
                UIDropDownMenu_SetText(dropdown, self.value)
                section.currentProfileText:SetText("Current Profile: " .. VUI.db:GetCurrentProfile())
            end
            info.checked = (VUI.db:GetCurrentProfile() == profile)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetText(section.profileDropdown, self.db:GetCurrentProfile())
    
    -- New profile
    section.newProfileText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.newProfileText:SetPoint("TOPLEFT", section.profileDropdown, "BOTTOMLEFT", 0, -20)
    section.newProfileText:SetText("Create New Profile:")
    
    section.newProfileEditBox = CreateFrame("EditBox", "VUINewProfileEditBox", section, "InputBoxTemplate")
    section.newProfileEditBox:SetSize(200, 20)
    section.newProfileEditBox:SetPoint("TOPLEFT", section.newProfileText, "BOTTOMLEFT", 5, -5)
    section.newProfileEditBox:SetAutoFocus(false)
    
    section.newProfileButton = self.UI:CreateButton(section, "VUINewProfileButton", "Create", 100, 25)
    section.newProfileButton:SetPoint("LEFT", section.newProfileEditBox, "RIGHT", 10, 0)
    
    section.newProfileButton:SetScript("OnClick", function()
        local profileName = section.newProfileEditBox:GetText()
        if profileName and profileName ~= "" then
            self.db:SetProfile(profileName)
            section.newProfileEditBox:SetText("")
            section.currentProfileText:SetText("Current Profile: " .. self.db:GetCurrentProfile())
            UIDropDownMenu_SetText(section.profileDropdown, self.db:GetCurrentProfile())
        end
    end)
    
    -- Copy profile
    section.copyProfileText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.copyProfileText:SetPoint("TOPLEFT", section.newProfileEditBox, "BOTTOMLEFT", -5, -20)
    section.copyProfileText:SetText("Copy From Profile:")
    
    section.copyProfileDropdown = self.UI:CreateDropdown(section, "VUICopyProfileDropdown", "", 200)
    section.copyProfileDropdown:SetPoint("TOPLEFT", section.copyProfileText, "BOTTOMLEFT", 0, -5)
    
    -- Populate copy profile dropdown
    UIDropDownMenu_Initialize(section.copyProfileDropdown, function(dropdown, level)
        local profiles = self.db:GetProfiles()
        local info = UIDropDownMenu_CreateInfo()
        local currentProfile = self.db:GetCurrentProfile()
        
        for _, profile in ipairs(profiles) do
            if profile ~= currentProfile then
                info.text = profile
                info.value = profile
                info.func = function(self)
                    UIDropDownMenu_SetText(dropdown, self.value)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    
    section.copyProfileButton = self.UI:CreateButton(section, "VUICopyProfileButton", "Copy", 100, 25)
    section.copyProfileButton:SetPoint("LEFT", section.copyProfileDropdown, "RIGHT", 10, 0)
    
    section.copyProfileButton:SetScript("OnClick", function()
        local sourceProfile = UIDropDownMenu_GetText(section.copyProfileDropdown)
        if sourceProfile and sourceProfile ~= "" then
            self.db:CopyProfile(sourceProfile)
        end
    end)
    
    -- Delete profile
    section.deleteProfileText = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.deleteProfileText:SetPoint("TOPLEFT", section.copyProfileDropdown, "BOTTOMLEFT", 0, -20)
    section.deleteProfileText:SetText("Delete Profile:")
    
    section.deleteProfileDropdown = self.UI:CreateDropdown(section, "VUIDeleteProfileDropdown", "", 200)
    section.deleteProfileDropdown:SetPoint("TOPLEFT", section.deleteProfileText, "BOTTOMLEFT", 0, -5)
    
    -- Populate delete profile dropdown
    UIDropDownMenu_Initialize(section.deleteProfileDropdown, function(dropdown, level)
        local profiles = self.db:GetProfiles()
        local info = UIDropDownMenu_CreateInfo()
        local currentProfile = self.db:GetCurrentProfile()
        
        for _, profile in ipairs(profiles) do
            if profile ~= currentProfile then
                info.text = profile
                info.value = profile
                info.func = function(self)
                    UIDropDownMenu_SetText(dropdown, self.value)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    
    section.deleteProfileButton = self.UI:CreateButton(section, "VUIDeleteProfileButton", "Delete", 100, 25)
    section.deleteProfileButton:SetPoint("LEFT", section.deleteProfileDropdown, "RIGHT", 10, 0)
    
    section.deleteProfileButton:SetScript("OnClick", function()
        local profileToDelete = UIDropDownMenu_GetText(section.deleteProfileDropdown)
        if profileToDelete and profileToDelete ~= "" and profileToDelete ~= self.db:GetCurrentProfile() then
            self.db:DeleteProfile(profileToDelete)
            UIDropDownMenu_SetText(section.deleteProfileDropdown, "")
        end
    end)
    
    -- Reset profile
    section.resetProfileButton = self.UI:CreateButton(section, "VUIResetProfileButton", "Reset Current Profile", 150, 25)
    section.resetProfileButton:SetPoint("TOPLEFT", section.deleteProfileDropdown, "BOTTOMLEFT", 0, -30)
    
    section.resetProfileButton:SetScript("OnClick", function()
        StaticPopupDialogs["VUI_RESET_PROFILE"] = {
            text = "Are you sure you want to reset the current profile?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                self.db:ResetProfile()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("VUI_RESET_PROFILE")
    end)
    
    -- Store the section
    frame.sections["Profiles"] = section
end
