local _, VUI = ...

-- VUI Plater Nameplates Module (inspired by WhiiskeyZ Plater profile)
local Nameplates = {
    name = "VUI Plater",
    enabled = true, -- Enabled by default
    settings = {},
    version = "1.0.0",
}

-- Initialize the nameplates module
function Nameplates:Initialize()
    -- Load settings from saved variables
    self.settings = VUI.db.profile.modules.nameplates or {}
    
    -- Set default enabled state
    self.enabled = self.settings.enabled
    if self.enabled == nil then -- if not explicitly set
        self.enabled = true
        self.settings.enabled = true
    end
    
    -- Make this module accessible globally within VUI
    VUI.nameplates = self
    
    -- Register for theme changes
    self:RegisterThemeCallbacks()
    
    -- Initialize nameplate hooks and features
    if self.enabled then
        self:Enable()
    end
end

-- Enable the module
function Nameplates:Enable()
    self.enabled = true
    self.settings.enabled = true
    
    -- Check which styling mode to use
    if self.settings.styling == "plater" then
        -- Initialize VUI Plater
        self:InitializePlater()
    else
        -- Setup standard nameplates based on settings
        self:SetupNameplates()
    end
end

-- Initialize the VUI Plater implementation
function Nameplates:InitializePlater()
    -- Initialize supporting systems
    if self.cvars then self.cvars:Initialize() end
    if self.auras then self.auras:Initialize() end
    if self.scripts then self.scripts:Initialize() end
    
    -- Initialize the Plater core
    if self.plater then
        VUI:Print("Initializing VUI Plater nameplates...")
        self.plater:Initialize()
    else
        VUI:Print("Error initializing VUI Plater: Core component missing")
    end
end

-- Register callbacks for theme changes
function Nameplates:RegisterThemeCallbacks()
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            if self.enabled and self.settings.useThemeColors and self.plater then
                self.plater:ApplyTheme(theme)
            end
        end)
    end
end

-- Setup nameplates based on settings
function Nameplates:SetupNameplates()
    -- Set nameplates to default if either not enabled or set to default
    if not self.enabled or not self.settings.styling or self.settings.styling == "default" then
        -- Restore default nameplate settings
        if C_NamePlate and C_NamePlate.SetNamePlateFriendlySize then
            C_NamePlate.SetNamePlateFriendlySize(1.0, 1.0)
            C_NamePlate.SetNamePlateEnemySize(1.0, 1.0)
        end
        
        -- Reset alpha levels 
        SetCVar("nameplateMinAlpha", 1.0)
        SetCVar("nameplateMaxAlpha", 1.0)
        
        -- Disable any custom nameplate frames or modifications
        if self.nameplateHooked then
            -- Reset any custom nameplate frames
            -- Unhook any nameplate events
            self.nameplateHooked = false
        end
        
        -- Let the user know that nameplates are using default settings
        if self.enabled and self.settings.styling == "default" then
            VUI:Print("Nameplates set to default Blizzard style")
        end
    else
        -- Apply custom nameplate settings
        if C_NamePlate and C_NamePlate.SetNamePlateFriendlySize then
            local friendlySize = self.settings.friendlySize or 1.0
            local enemySize = self.settings.enemySize or 1.0
            
            C_NamePlate.SetNamePlateFriendlySize(friendlySize, friendlySize)
            C_NamePlate.SetNamePlateEnemySize(enemySize, enemySize)
        end
        
        -- Apply custom alpha settings
        if self.settings.friendlyAlpha then
            SetCVar("nameplateMinAlpha", self.settings.friendlyAlpha)
        end
        
        if self.settings.enemyAlpha then
            SetCVar("nameplateMaxAlpha", self.settings.enemyAlpha)
        end
        
        -- Hook nameplate events if not already hooked
        if not self.nameplateHooked then
            -- Hook nameplate creation to apply our style
            if not self.nameplateHookFrame then
                self.nameplateHookFrame = CreateFrame("Frame")
                self.nameplateHookFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
                self.nameplateHookFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
                self.nameplateHookFrame:SetScript("OnEvent", function(_, event, unit)
                    if event == "NAME_PLATE_UNIT_ADDED" then
                        self:StyleNameplate(unit)
                    end
                end)
            end
            
            self.nameplateHooked = true
            VUI:Print("Custom nameplate styling applied")
        end
    end
end

-- Apply custom styling to a nameplate
function Nameplates:StyleNameplate(unit)
    if not self.enabled or not self.settings.styling or self.settings.styling == "default" then
        return
    end
    
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end
    
    -- Apply custom styling to the nameplate
    local frame = nameplate.UnitFrame
    
    -- Apply class colors to health bar if enabled
    if self.settings.showClassColors and UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            if frame.healthBar then
                frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
    end
    
    -- Set up health text if enabled
    if self.settings.showHealthText then
        if not frame.healthText then
            frame.healthText = frame:CreateFontString(nil, "OVERLAY")
            frame.healthText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            frame.healthText:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
        end
        
        -- Update health text based on format setting
        local healthFormat = self.settings.healthFormat or "percent"
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        if healthFormat == "percent" then
            local healthPercent = math.floor(health / maxHealth * 100)
            frame.healthText:SetText(healthPercent .. "%")
        elseif healthFormat == "value" then
            frame.healthText:SetText(VUI:FormatNumber(health))
        elseif healthFormat == "both" then
            local healthPercent = math.floor(health / maxHealth * 100)
            frame.healthText:SetText(VUI:FormatNumber(health) .. " - " .. healthPercent .. "%")
        end
        
        frame.healthText:Show()
    elseif frame.healthText then
        frame.healthText:Hide()
    end
    
    -- Additional nameplate customizations can be added here
    -- For example, custom borders, background textures, etc.
end

-- Disable the module
function Nameplates:Disable()
    self.enabled = false
    self.settings.enabled = false
    
    -- Restore nameplate defaults if needed
    if C_NamePlate and C_NamePlate.SetNamePlateFriendlySize then
        C_NamePlate.SetNamePlateFriendlySize(1.0, 1.0)
        C_NamePlate.SetNamePlateEnemySize(1.0, 1.0)
    end
    
    SetCVar("nameplateMinAlpha", 1.0)
    SetCVar("nameplateMaxAlpha", 1.0)
    
    -- Clean up nameplate hooks
    if self.nameplateHooked then
        if self.nameplateHookFrame then
            self.nameplateHookFrame:UnregisterAllEvents()
            self.nameplateHookFrame:SetScript("OnEvent", nil)
        end
        self.nameplateHooked = false
    end
    
    -- Notify user
    VUI:Print("Nameplates module disabled")
end

-- Create configuration options for the module
function Nameplates:CreateConfigOptions(parent)
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- Nameplate Settings Group
    local nameplateSettingsGroup = AceGUI:Create("InlineGroup")
    nameplateSettingsGroup:SetTitle("Nameplate Settings")
    nameplateSettingsGroup:SetLayout("Flow")
    nameplateSettingsGroup:SetFullWidth(true)
    parent:AddChild(nameplateSettingsGroup)
    
    -- Nameplate Style
    local styleDropdown = AceGUI:Create("Dropdown")
    styleDropdown:SetLabel("Nameplate Styling")
    styleDropdown:SetList({
        ["default"] = "Default Blizzard",
        ["custom"] = "Basic Custom",
        ["plater"] = "VUI Plater"
    })
    styleDropdown:SetValue(self.settings.styling or "plater")
    styleDropdown:SetFullWidth(true)
    styleDropdown:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.styling = value
        
        -- Use the appropriate method based on style selection
        if value == "plater" then
            self:InitializePlater()
        else
            self:SetupNameplates()
        end
        
        -- Update UI element states
        self:UpdateConfigUIState(nameplateSettingsGroup, value)
    end)
    nameplateSettingsGroup:AddChild(styleDropdown)
    
    -- Use VUI Theme Colors
    local useThemeColorsCheckbox = AceGUI:Create("CheckBox")
    useThemeColorsCheckbox:SetLabel("Use VUI Theme Colors")
    useThemeColorsCheckbox:SetValue(self.settings.useThemeColors == nil and true or self.settings.useThemeColors)
    useThemeColorsCheckbox:SetFullWidth(true)
    useThemeColorsCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.useThemeColors = value
        
        -- Refresh nameplate display
        if self.settings.styling == "plater" and self.plater then
            self.plater:ApplyTheme()
        end
    end)
    useThemeColorsCheckbox:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(useThemeColorsCheckbox)
    
    -- Friendly Nameplate Size
    local friendlySizeSlider = AceGUI:Create("Slider")
    friendlySizeSlider:SetLabel("Friendly Nameplate Size")
    friendlySizeSlider:SetSliderValues(0.5, 1.5, 0.1)
    friendlySizeSlider:SetValue(self.settings.friendlySize or 1.0)
    friendlySizeSlider:SetFullWidth(true)
    friendlySizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.friendlySize = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    friendlySizeSlider:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(friendlySizeSlider)
    
    -- Enemy Nameplate Size
    local enemySizeSlider = AceGUI:Create("Slider")
    enemySizeSlider:SetLabel("Enemy Nameplate Size")
    enemySizeSlider:SetSliderValues(0.5, 1.5, 0.1)
    enemySizeSlider:SetValue(self.settings.enemySize or 1.0)
    enemySizeSlider:SetFullWidth(true)
    enemySizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.enemySize = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    enemySizeSlider:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(enemySizeSlider)
    
    -- Friendly Nameplate Alpha
    local friendlyAlphaSlider = AceGUI:Create("Slider")
    friendlyAlphaSlider:SetLabel("Friendly Nameplate Alpha")
    friendlyAlphaSlider:SetSliderValues(0.3, 1.0, 0.1)
    friendlyAlphaSlider:SetValue(self.settings.friendlyAlpha or 1.0)
    friendlyAlphaSlider:SetFullWidth(true)
    friendlyAlphaSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.friendlyAlpha = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    friendlyAlphaSlider:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(friendlyAlphaSlider)
    
    -- Enemy Nameplate Alpha
    local enemyAlphaSlider = AceGUI:Create("Slider")
    enemyAlphaSlider:SetLabel("Enemy Nameplate Alpha")
    enemyAlphaSlider:SetSliderValues(0.3, 1.0, 0.1)
    enemyAlphaSlider:SetValue(self.settings.enemyAlpha or 1.0)
    enemyAlphaSlider:SetFullWidth(true)
    enemyAlphaSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.enemyAlpha = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    enemyAlphaSlider:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(enemyAlphaSlider)
    
    -- Show Class Colors
    local showClassColorsCheckbox = AceGUI:Create("CheckBox")
    showClassColorsCheckbox:SetLabel("Show Class Colors on Nameplates")
    showClassColorsCheckbox:SetValue(self.settings.showClassColors or true)
    showClassColorsCheckbox:SetFullWidth(true)
    showClassColorsCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showClassColors = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    showClassColorsCheckbox:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(showClassColorsCheckbox)
    
    -- Show Health Text
    local showHealthTextCheckbox = AceGUI:Create("CheckBox")
    showHealthTextCheckbox:SetLabel("Show Health Text on Nameplates")
    showHealthTextCheckbox:SetValue(self.settings.showHealthText or true)
    showHealthTextCheckbox:SetFullWidth(true)
    showHealthTextCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showHealthText = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    showHealthTextCheckbox:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(showHealthTextCheckbox)
    
    -- Health Text Format
    local healthFormatDropdown = AceGUI:Create("Dropdown")
    healthFormatDropdown:SetLabel("Health Text Format")
    healthFormatDropdown:SetList({
        ["percent"] = "Percentage",
        ["value"] = "Value",
        ["both"] = "Both"
    })
    healthFormatDropdown:SetValue(self.settings.healthFormat or "percent")
    healthFormatDropdown:SetFullWidth(true)
    healthFormatDropdown:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.healthFormat = value
        if self.settings.styling == "custom" and self.settings.showHealthText then
            self:SetupNameplates()
        end
    end)
    healthFormatDropdown:SetDisabled(self.settings.styling == "default" or not self.settings.showHealthText)
    nameplateSettingsGroup:AddChild(healthFormatDropdown)
    
    -- Show Castbars
    local showCastbarsCheckbox = AceGUI:Create("CheckBox")
    showCastbarsCheckbox:SetLabel("Show Castbars on Nameplates")
    showCastbarsCheckbox:SetValue(self.settings.showCastbars or true)
    showCastbarsCheckbox:SetFullWidth(true)
    showCastbarsCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showCastbars = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    showCastbarsCheckbox:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(showCastbarsCheckbox)
    
    -- Show Auras
    local showAurasCheckbox = AceGUI:Create("CheckBox")
    showAurasCheckbox:SetLabel("Show Auras on Nameplates")
    showAurasCheckbox:SetValue(self.settings.showAuras or true)
    showAurasCheckbox:SetFullWidth(true)
    showAurasCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showAuras = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    showAurasCheckbox:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(showAurasCheckbox)
    
    -- Max Auras
    local maxAurasSlider = AceGUI:Create("Slider")
    maxAurasSlider:SetLabel("Maximum Auras per Nameplate")
    maxAurasSlider:SetSliderValues(2, 12, 1)
    maxAurasSlider:SetValue(self.settings.maxAuras or 6)
    maxAurasSlider:SetFullWidth(true)
    maxAurasSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.maxAuras = value
        if self.settings.styling == "custom" and self.settings.showAuras then
            self:SetupNameplates()
        end
    end)
    maxAurasSlider:SetDisabled(self.settings.styling == "default" or not self.settings.showAuras)
    nameplateSettingsGroup:AddChild(maxAurasSlider)
    
    -- Show Threat Indicator
    local showThreatCheckbox = AceGUI:Create("CheckBox")
    showThreatCheckbox:SetLabel("Show Threat Indicators")
    showThreatCheckbox:SetValue(self.settings.showThreatIndicator or true)
    showThreatCheckbox:SetFullWidth(true)
    showThreatCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showThreatIndicator = value
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    showThreatCheckbox:SetDisabled(self.settings.styling == "default")
    nameplateSettingsGroup:AddChild(showThreatCheckbox)
    
    -- Clickthrough Nameplates
    local clickthroughCheckbox = AceGUI:Create("CheckBox")
    clickthroughCheckbox:SetLabel("Clickthrough Nameplates")
    clickthroughCheckbox:SetValue(self.settings.clickthrough or false)
    clickthroughCheckbox:SetFullWidth(true)
    clickthroughCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.clickthrough = value
        -- Apply clickthrough setting
        C_NamePlate.SetNamePlateEnemyClickThrough(value)
        C_NamePlate.SetNamePlateFriendlyClickThrough(value)
    end)
    nameplateSettingsGroup:AddChild(clickthroughCheckbox)
    
    -- Stacking Nameplates
    local stackingCheckbox = AceGUI:Create("CheckBox")
    stackingCheckbox:SetLabel("Stacking Nameplates")
    stackingCheckbox:SetValue(self.settings.stackingNameplates or true)
    stackingCheckbox:SetFullWidth(true)
    stackingCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.stackingNameplates = value
        -- Apply stacking setting
        SetCVar("nameplateMotion", value and "1" or "0")
    end)
    nameplateSettingsGroup:AddChild(stackingCheckbox)
    
    -- Update control states based on styling and other options
    styleDropdown:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.styling = value
        
        -- Update disabled states based on selections
        local disableCustom = (value == "default")
        friendlySizeSlider:SetDisabled(disableCustom)
        enemySizeSlider:SetDisabled(disableCustom)
        friendlyAlphaSlider:SetDisabled(disableCustom)
        enemyAlphaSlider:SetDisabled(disableCustom)
        showClassColorsCheckbox:SetDisabled(disableCustom)
        showHealthTextCheckbox:SetDisabled(disableCustom)
        healthFormatDropdown:SetDisabled(disableCustom or not self.settings.showHealthText)
        showCastbarsCheckbox:SetDisabled(disableCustom)
        showAurasCheckbox:SetDisabled(disableCustom)
        maxAurasSlider:SetDisabled(disableCustom or not self.settings.showAuras)
        showThreatCheckbox:SetDisabled(disableCustom)
        
        self:SetupNameplates()
    end)
    
    -- Dynamic enabling/disabling of dependent controls
    showHealthTextCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showHealthText = value
        healthFormatDropdown:SetDisabled(self.settings.styling == "default" or not value)
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
    
    showAurasCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showAuras = value
        maxAurasSlider:SetDisabled(self.settings.styling == "default" or not value)
        if self.settings.styling == "custom" then
            self:SetupNameplates()
        end
    end)
end

-- Update configuration UI state based on selected style
function Nameplates:UpdateConfigUIState(parentGroup, style)
    -- Find all child widgets
    local children = parentGroup.children
    if not children then return end
    
    -- Determine which controls to show/hide based on style
    local isDefault = style == "default"
    local isPlater = style == "plater"
    
    -- Update each control
    for _, child in ipairs(children) do
        -- Skip the style dropdown itself
        if child.label and child.label:GetText() ~= "Nameplate Styling" then
            -- Special handling for theme colors checkbox
            if child.label and child.label:GetText() == "Use VUI Theme Colors" then
                child:SetDisabled(isDefault)
            -- For regular Blizzard nameplate customization
            elseif not isPlater and child.label and (
                child.label:GetText():find("Nameplate Size") or
                child.label:GetText():find("Nameplate Alpha") or
                child.label:GetText():find("Class Colors") or
                child.label:GetText():find("Health Text") or
                child.label:GetText():find("Health Text Format") or
                child.label:GetText():find("Castbars") or
                child.label:GetText():find("Auras") or
                child.label:GetText():find("Maximum Auras") or
                child.label:GetText():find("Threat")
            ) then
                child:SetDisabled(isDefault)
            end
        end
    end
    
    -- Add VUI Plater advanced config button if using Plater mode
    if isPlater and not parentGroup.platerConfigButton then
        local AceGUI = LibStub("AceGUI-3.0")
        
        -- Create a spacer
        local spacer = AceGUI:Create("Label")
        spacer:SetText(" ")
        spacer:SetFullWidth(true)
        parentGroup:AddChild(spacer)
        
        -- Create Plater advanced config button
        local configButton = AceGUI:Create("Button")
        configButton:SetText("VUI Plater Advanced Configuration")
        configButton:SetFullWidth(true)
        configButton:SetCallback("OnClick", function()
            -- Open the VUI Plater advanced configuration panel
            self:OpenPlaterAdvancedConfig()
        end)
        parentGroup:AddChild(configButton)
        
        -- Store reference to the button
        parentGroup.platerConfigButton = configButton
    elseif not isPlater and parentGroup.platerConfigButton then
        -- Hide the Plater config button if not using Plater
        parentGroup.platerConfigButton:SetVisible(false)
    end
end

-- Open VUI Plater Advanced Configuration
function Nameplates:OpenPlaterAdvancedConfig()
    -- Ensure plater module file is loaded
    if not self.plater then
        VUI:Print("Error: VUI Plater core not loaded")
        return
    end
    
    -- Create configuration frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI Plater Advanced Configuration")
    frame:SetLayout("Flow")
    frame:SetWidth(800)
    frame:SetHeight(600)
    
    -- Add tab group
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs({
        {text = "General", value = "general"},
        {text = "Appearance", value = "appearance"},
        {text = "Auras", value = "auras"},
        {text = "Scripts", value = "scripts"},
        {text = "Special Effects", value = "effects"},
        {text = "CVars", value = "cvars"},
    })
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    
    -- Set tab change callback
    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        
        if group == "general" then
            self:CreateGeneralOptionsTab(container)
        elseif group == "appearance" then
            self:CreateAppearanceOptionsTab(container)
        elseif group == "auras" then
            self:CreateAurasOptionsTab(container)
        elseif group == "scripts" then
            self:CreateScriptsOptionsTab(container)
        elseif group == "effects" then
            self:CreateEffectsOptionsTab(container)
        elseif group == "cvars" then
            self:CreateCVarsOptionsTab(container)
        end
    end)
    
    -- Select the first tab by default
    tabGroup:SelectTab("general")
    
    -- Add the tab group to the frame
    frame:AddChild(tabGroup)
    
    -- Close button
    local closeButton = AceGUI:Create("Button")
    closeButton:SetText("Close and Save")
    closeButton:SetFullWidth(true)
    closeButton:SetCallback("OnClick", function()
        -- Save settings
        VUI.db.profile.modules.nameplates = self.settings
        
        -- Refresh nameplates
        if self.plater then
            self.plater:ReloadPlates()
        end
        
        -- Close the frame
        frame:Hide()
    end)
    
    -- Add close button to frame (outside the tab group)
    frame:AddChild(closeButton)
end

-- Return configuration options for the module's integration in the main config panel
function Nameplates:GetConfig()
    return {
        order = 25, -- Position in the modules list
        type = "group",
        name = "Nameplates",
        desc = "Custom Nameplate formatting",
        get = function(info) return self.settings[info[#info]] end,
        set = function(info, value)
            self.settings[info[#info]] = value
            if self.enabled then
                self:SetupNameplates()
            end
        end,
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable",
                desc = "Enable the Nameplates module",
                width = "full",
                set = function(info, value)
                    self.settings[info[#info]] = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
            },
            styling = {
                order = 2,
                type = "select",
                name = "Nameplate Styling",
                desc = "Choose between default Blizzard nameplates, custom styling, or VUI Plater",
                width = "double",
                values = {
                    ["default"] = "Default Blizzard",
                    ["custom"] = "Basic Custom",
                    ["plater"] = "VUI Plater"
                },
                set = function(info, value)
                    self.settings[info[#info]] = value
                    if value == "plater" then
                        self:InitializePlater()
                    else
                        self:SetupNameplates()
                    end
                end,
                disabled = function() return not self.enabled end,
            },
            configbutton = {
                order = 3,
                type = "execute",
                name = "Advanced Settings",
                func = function()
                    VUI:OpenModuleConfig(self.name)
                end,
                disabled = function() return not self.enabled end,
            },
        },
    }
end

-- Get the module's display name for the UI
function Nameplates:GetDisplayName()
    return "VUI Plater Nameplates"
end

-- Get the module's description for the UI
function Nameplates:GetDescription()
    return "Advanced nameplate customization with WhiiskeyZ Plater integration"
end

-- Get the module's category for organization in the UI
function Nameplates:GetCategory()
    return "Interface Enhancements"
end

-- Register the module with VUI
VUI:RegisterModule("nameplates", Nameplates)