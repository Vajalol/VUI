local _, VUI = ...

-- Access the MSBT module
local MSBT = VUI.msbt
MSBT.ThemeIntegration = {}

-- Initialize theme integration
function MSBT.ThemeIntegration:Initialize()
    if not MikSBT or not MikSBT.Profiles then
        return
    end
    
    -- Register for theme changes
    VUI.ThemeIntegration:RegisterThemeChangeCallback(function(newTheme)
        self:ApplyTheme(newTheme)
    end)
    
    -- Apply the current theme
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    self:ApplyTheme(currentTheme)
end

-- Apply the given theme to MSBT
function MSBT.ThemeIntegration:ApplyTheme(theme)
    if not MikSBT or not MikSBT.Profiles or not MikSBT.Profiles.currentProfile then
        return
    end
    
    local settings = VUI.db.profile.modules.msbt
    if not settings.useVUITheme then
        return
    end
    
    -- Theme colors based on VUI themes
    local themeColors = {
        ["thunderstorm"] = {
            normal = {r = 0.05, g = 0.62, b = 0.9}, -- Electric blue
            crit = {r = 0.1, g = 0.8, b = 1.0},
            background = {r = 0.04, g = 0.04, b = 0.1, a = 0.5}
        },
        ["phoenixflame"] = {
            normal = {r = 0.9, g = 0.3, b = 0.05}, -- Fiery orange
            crit = {r = 1.0, g = 0.4, b = 0.1},
            background = {r = 0.1, g = 0.04, b = 0.02, a = 0.5}
        },
        ["arcanemystic"] = {
            normal = {r = 0.61, g = 0.05, b = 0.9}, -- Violet
            crit = {r = 0.8, g = 0.1, b = 1.0},
            background = {r = 0.1, g = 0.04, b = 0.18, a = 0.5}
        },
        ["felenergy"] = {
            normal = {r = 0.1, g = 1.0, b = 0.1}, -- Fel green
            crit = {r = 0.2, g = 1.0, b = 0.2},
            background = {r = 0.04, g = 0.1, b = 0.04, a = 0.5}
        }
    }
    
    -- Get colors for the current theme
    local colors = themeColors[theme] or themeColors["thunderstorm"]
    
    -- Apply theme to all scroll areas
    for scrollAreaKey, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
        if settings.useVUITheme then
            -- Store that we're using the VUI theme
            scrollArea.useVUITheme = true
            
            -- Apply background color if it exists
            if scrollArea.backgroundSettings then
                scrollArea.backgroundSettings.r = colors.background.r
                scrollArea.backgroundSettings.g = colors.background.g
                scrollArea.backgroundSettings.b = colors.background.b
                scrollArea.backgroundSettings.a = colors.background.a or 0.5
            end
            
            -- Apply text colors if theme colored text is enabled
            if settings.themeColoredText and scrollArea.scrollHeight then
                -- We'll create new event settings based on the theme
                if not scrollArea.vui_eventSettings then
                    scrollArea.vui_eventSettings = {}
                end
                
                -- Save original colors if we haven't already
                if not scrollArea.vui_originalEventSettings then
                    scrollArea.vui_originalEventSettings = CopyTable(scrollArea.eventSettings or {})
                end
                
                -- Apply theme colors to common events
                for eventType, eventSettings in pairs(scrollArea.eventSettings) do
                    -- Create a copy to avoid modifying original
                    scrollArea.vui_eventSettings[eventType] = CopyTable(eventSettings)
                    
                    -- Apply theme color based on event type
                    if string.find(eventType, "DAMAGE") or string.find(eventType, "HEAL") then
                        if string.find(eventType, "CRIT") then
                            -- Critical hits/heals
                            scrollArea.vui_eventSettings[eventType].colorR = colors.crit.r
                            scrollArea.vui_eventSettings[eventType].colorG = colors.crit.g
                            scrollArea.vui_eventSettings[eventType].colorB = colors.crit.b
                        else
                            -- Normal hits/heals
                            scrollArea.vui_eventSettings[eventType].colorR = colors.normal.r
                            scrollArea.vui_eventSettings[eventType].colorG = colors.normal.g
                            scrollArea.vui_eventSettings[eventType].colorB = colors.normal.b
                        end
                    end
                end
                
                -- Apply the theme-colored event settings
                scrollArea.eventSettings = scrollArea.vui_eventSettings
            else
                -- Restore original color settings if theme coloring is disabled
                if scrollArea.vui_originalEventSettings then
                    scrollArea.eventSettings = CopyTable(scrollArea.vui_originalEventSettings)
                end
            end
        else
            -- If theme integration is disabled, restore original settings
            scrollArea.useVUITheme = false
            
            -- Restore original color settings if available
            if scrollArea.vui_originalEventSettings then
                scrollArea.eventSettings = CopyTable(scrollArea.vui_originalEventSettings)
            end
        end
    end
    
    -- Refresh the MikSBT display if it's already initialized
    if MikSBT.Main and MikSBT.Main.isInitialized and MikSBT.Main.EnableMSBT then
        if MikSBT.Main.DisableMSBT then
            MikSBT.Main:DisableMSBT()
        end
        
        C_Timer.After(0.1, function()
            if MikSBT.Main.EnableMSBT then
                MikSBT.Main:EnableMSBT()
            end
        end)
    end
end

-- Create a themed configuration panel
function MSBT.ThemeIntegration:CreateConfigPanel()
    -- Only create if ThemeHelpers is available
    if not VUI.ThemeHelpers then
        return nil
    end
    
    -- Create the main panel
    local panel = VUI.ThemeHelpers:CreatePanel("MSBT Configuration", nil, 600, 500)
    panel:Hide()
    
    -- Create tabs for different config sections
    local tabs = {
        { name = "General", setup = function(tab) self:CreateGeneralTab(tab) end },
        { name = "Appearance", setup = function(tab) self:CreateAppearanceTab(tab) end },
        { name = "Scrolling", setup = function(tab) self:CreateScrollingTab(tab) end },
        { name = "Test", setup = function(tab) self:CreateTestTab(tab) end }
    }
    
    -- Create tab system
    panel.tabs = VUI.ThemeHelpers:CreateTabSystem(panel, panel:GetWidth() - 40, panel:GetHeight() - 60, tabs)
    
    -- Add show/hide methods
    function panel:Show()
        getmetatable(self).__index.Show(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    
    function panel:Hide()
        getmetatable(self).__index.Hide(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end
    
    -- Return the panel
    return panel
end

-- Create the General tab content
function MSBT.ThemeIntegration:CreateGeneralTab(tab)
    local settings = VUI.db.profile.modules.msbt
    
    -- Add descriptive text
    local desc = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 20, -20)
    desc:SetPoint("TOPRIGHT", -20, -20)
    desc:SetJustifyH("LEFT")
    desc:SetText("MikScrollingBattleText (MSBT) shows damage and healing as animated text in the game world. Configure general settings here.")
    desc:SetTextColor(0.9, 0.9, 0.9)
    
    -- Preview image
    local preview = tab:CreateTexture(nil, "ARTWORK")
    preview:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\config\\msbt_preview.svg")
    preview:SetSize(240, 120)
    preview:SetPoint("TOPRIGHT", -20, -60)
    
    -- Enable checkbox
    local enableCB = VUI.ThemeHelpers:CreateCheckbox(tab, "Enable MSBT", settings.enabled)
    enableCB:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    enableCB:SetScript("OnClick", function(self)
        settings.enabled = self:GetChecked()
        if settings.enabled then
            if not MikSBT.Main then
                MSBT:Initialize()
            end
            if MikSBT.Main and MikSBT.Main.EnableMSBT then
                MikSBT.Main:EnableMSBT()
            end
        else
            if MikSBT.Main and MikSBT.Main.DisableMSBT then
                MikSBT.Main:DisableMSBT()
            end
        end
    end)
    
    -- Open default MSBT config button
    local configBtn = VUI.ThemeHelpers:CreateButton(tab, "Open MSBT Configuration", 200, 30)
    configBtn:SetPoint("TOPLEFT", enableCB, "BOTTOMLEFT", 0, -20)
    configBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Main and MikSBT.Main.isInitialized then
            MSBT:ToggleOriginalConfig()
        else
            print("|cff1784d1VUI MSBT|r: MSBT needs to be enabled first.")
        end
    end)
end

-- Create the Appearance tab content
function MSBT.ThemeIntegration:CreateAppearanceTab(tab)
    local settings = VUI.db.profile.modules.msbt
    
    -- Add descriptive text
    local desc = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 20, -20)
    desc:SetPoint("TOPRIGHT", -20, -20)
    desc:SetJustifyH("LEFT")
    desc:SetText("Configure the appearance and theme integration for MSBT.")
    desc:SetTextColor(0.9, 0.9, 0.9)
    
    -- Theme integration checkbox
    local themeIntegrationCB = VUI.ThemeHelpers:CreateCheckbox(tab, "Use VUI Theme Colors", settings.useVUITheme)
    themeIntegrationCB:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    themeIntegrationCB:SetScript("OnClick", function(self)
        settings.useVUITheme = self:GetChecked()
        
        -- Apply to all scroll areas
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                scrollArea.useVUITheme = settings.useVUITheme
            end
            
            -- Apply the theme
            if MSBT.ThemeIntegration then
                MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
            end
        end
    end)
    
    -- Theme-colored text checkbox
    local themeColoredTextCB = VUI.ThemeHelpers:CreateCheckbox(tab, "Theme-Colored Text", settings.themeColoredText)
    themeColoredTextCB:SetPoint("TOPLEFT", themeIntegrationCB, "BOTTOMLEFT", 0, -10)
    themeColoredTextCB:SetScript("OnClick", function(self)
        settings.themeColoredText = self:GetChecked()
        
        -- Apply the theme
        if MSBT.ThemeIntegration then
            MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
        end
    end)
    
    -- Font size slider
    local fontSizeSlider = VUI.ThemeHelpers:CreateSlider(tab, "Font Size", 8, 32, 1, settings.fontSize or 18)
    fontSizeSlider:SetPoint("TOPLEFT", themeColoredTextCB, "BOTTOMLEFT", 20, -30)
    fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        settings.fontSize = value
        
        -- Apply font size to all scroll areas
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                scrollArea.scrollHeight = value
            end
            
            -- Refresh the display
            if MikSBT.Main and MikSBT.Main.isInitialized then
                if MikSBT.Main.DisableMSBT then MikSBT.Main:DisableMSBT() end
                C_Timer.After(0.1, function()
                    if MikSBT.Main.EnableMSBT then MikSBT.Main:EnableMSBT() end
                end)
            end
        end
    end)
    
    -- Animation speed slider
    local animSpeedSlider = VUI.ThemeHelpers:CreateSlider(tab, "Animation Speed", 25, 250, 5, settings.animationSpeed or 100)
    animSpeedSlider:SetPoint("TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -30)
    animSpeedSlider:SetScript("OnValueChanged", function(self, value)
        settings.animationSpeed = value
        
        -- Apply animation speed to all scroll areas
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                scrollArea.animationSpeed = value
            end
            
            -- Refresh the display
            if MikSBT.Main and MikSBT.Main.isInitialized then
                if MikSBT.Main.DisableMSBT then MikSBT.Main:DisableMSBT() end
                C_Timer.After(0.1, function()
                    if MikSBT.Main.EnableMSBT then MikSBT.Main:EnableMSBT() end
                end)
            end
        end
    end)
end

-- Create the Scrolling tab content
function MSBT.ThemeIntegration:CreateScrollingTab(tab)
    local settings = VUI.db.profile.modules.msbt
    
    -- Add descriptive text
    local desc = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 20, -20)
    desc:SetPoint("TOPRIGHT", -20, -20)
    desc:SetJustifyH("LEFT")
    desc:SetText("Configure how text scrolls and animates in MSBT.")
    desc:SetTextColor(0.9, 0.9, 0.9)
    
    -- Scroll area visibility
    local areaHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    areaHeader:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    areaHeader:SetText("Scroll Areas")
    areaHeader:SetTextColor(0.9, 0.9, 0.9)
    
    -- Create checkboxes for each default scroll area
    local scrollAreas = {
        { name = "Incoming", key = "Incoming" },
        { name = "Outgoing", key = "Outgoing" },
        { name = "Notification", key = "Notification" },
        { name = "Static", key = "Static" }
    }
    
    local lastElement = areaHeader
    for i, area in ipairs(scrollAreas) do
        local cb = VUI.ThemeHelpers:CreateCheckbox(tab, area.name .. " Area", settings["show" .. area.key] ~= false)
        cb:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, i == 1 and -10 or -5)
        cb.scrollArea = area.key
        cb:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            settings["show" .. self.scrollArea] = checked
            
            -- Apply visibility to the scroll area
            if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile and MikSBT.Profiles.currentProfile.scrollAreas then
                local scrollArea = MikSBT.Profiles.currentProfile.scrollAreas[self.scrollArea]
                if scrollArea then
                    scrollArea.disabled = not checked
                    
                    -- Refresh the display
                    if MikSBT.Main and MikSBT.Main.isInitialized then
                        if MikSBT.Main.DisableMSBT then MikSBT.Main:DisableMSBT() end
                        C_Timer.After(0.1, function()
                            if MikSBT.Main.EnableMSBT then MikSBT.Main:EnableMSBT() end
                        end)
                    end
                end
            end
        end)
        
        lastElement = cb
    end
    
    -- Animation styles
    local styleHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    styleHeader:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -20)
    styleHeader:SetText("Animation Styles")
    styleHeader:SetTextColor(0.9, 0.9, 0.9)
    
    -- Create dropdown for animation styles
    local animStyles = {
        ["Straight"] = "Straight",
        ["Parabola"] = "Parabola",
        ["Powder"] = "Powder",
        ["Angled"] = "Angled",
        ["Horizontal"] = "Horizontal",
        ["Static"] = "Static"
    }
    
    local normalStyleDropdown = VUI.ThemeHelpers:CreateDropdown(tab, "Normal Hits Style", 150, animStyles)
    normalStyleDropdown:SetPoint("TOPLEFT", styleHeader, "BOTTOMLEFT", 20, -30)
    normalStyleDropdown.OnValueChanged = function(self, value)
        settings.normalHitStyle = value
        
        -- Apply animation style
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                for eventType, eventSettings in pairs(scrollArea.eventSettings or {}) do
                    if string.find(eventType, "DAMAGE") or string.find(eventType, "HEAL") then
                        if not string.find(eventType, "CRIT") then
                            eventSettings.animationStyle = value
                        end
                    end
                end
            end
            
            -- Refresh the display
            if MikSBT.Main and MikSBT.Main.isInitialized then
                if MikSBT.Main.DisableMSBT then MikSBT.Main:DisableMSBT() end
                C_Timer.After(0.1, function()
                    if MikSBT.Main.EnableMSBT then MikSBT.Main:EnableMSBT() end
                end)
            end
        end
    end
    UIDropDownMenu_SetText(normalStyleDropdown, settings.normalHitStyle or "Straight")
    
    local critStyleDropdown = VUI.ThemeHelpers:CreateDropdown(tab, "Critical Hits Style", 150, animStyles)
    critStyleDropdown:SetPoint("TOPLEFT", normalStyleDropdown, "BOTTOMLEFT", 0, -40)
    critStyleDropdown.OnValueChanged = function(self, value)
        settings.critHitStyle = value
        
        -- Apply animation style
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                for eventType, eventSettings in pairs(scrollArea.eventSettings or {}) do
                    if string.find(eventType, "DAMAGE") or string.find(eventType, "HEAL") then
                        if string.find(eventType, "CRIT") then
                            eventSettings.animationStyle = value
                        end
                    end
                end
            end
            
            -- Refresh the display
            if MikSBT.Main and MikSBT.Main.isInitialized then
                if MikSBT.Main.DisableMSBT then MikSBT.Main:DisableMSBT() end
                C_Timer.After(0.1, function()
                    if MikSBT.Main.EnableMSBT then MikSBT.Main:EnableMSBT() end
                end)
            end
        end
    end
    UIDropDownMenu_SetText(critStyleDropdown, settings.critHitStyle or "Parabola")
end

-- Create the Test tab content
function MSBT.ThemeIntegration:CreateTestTab(tab)
    local settings = VUI.db.profile.modules.msbt
    
    -- Add descriptive text
    local desc = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 20, -20)
    desc:SetPoint("TOPRIGHT", -20, -20)
    desc:SetJustifyH("LEFT")
    desc:SetText("Test MSBT functionality with sample text.")
    desc:SetTextColor(0.9, 0.9, 0.9)
    
    -- Test buttons
    local testHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    testHeader:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    testHeader:SetText("Test Display")
    testHeader:SetTextColor(0.9, 0.9, 0.9)
    
    -- Create test button for incoming damage
    local testIncomingBtn = VUI.ThemeHelpers:CreateButton(tab, "Test Incoming", 120, 30)
    testIncomingBtn:SetPoint("TOPLEFT", testHeader, "BOTTOMLEFT", 20, -20)
    testIncomingBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Main and MikSBT.Main.isInitialized then
            local amount = math.random(1000, 5000)
            if math.random(1, 100) > 70 then
                -- Critical hit
                MikSBT.DisplayEvent("INCOMING_SPELL_DAMAGE_CRIT", amount, "Test Spell")
            else
                -- Normal hit
                MikSBT.DisplayEvent("INCOMING_SPELL_DAMAGE", amount, "Test Spell")
            end
        else
            print("|cff1784d1VUI MSBT|r: MSBT needs to be enabled first.")
        end
    end)
    
    -- Create test button for outgoing damage
    local testOutgoingBtn = VUI.ThemeHelpers:CreateButton(tab, "Test Outgoing", 120, 30)
    testOutgoingBtn:SetPoint("LEFT", testIncomingBtn, "RIGHT", 20, 0)
    testOutgoingBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Main and MikSBT.Main.isInitialized then
            local amount = math.random(1000, 5000)
            if math.random(1, 100) > 70 then
                -- Critical hit
                MikSBT.DisplayEvent("OUTGOING_SPELL_DAMAGE_CRIT", amount, "Test Spell")
            else
                -- Normal hit
                MikSBT.DisplayEvent("OUTGOING_SPELL_DAMAGE", amount, "Test Spell")
            end
        else
            print("|cff1784d1VUI MSBT|r: MSBT needs to be enabled first.")
        end
    end)
    
    -- Create test button for healing
    local testHealBtn = VUI.ThemeHelpers:CreateButton(tab, "Test Healing", 120, 30)
    testHealBtn:SetPoint("LEFT", testOutgoingBtn, "RIGHT", 20, 0)
    testHealBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Main and MikSBT.Main.isInitialized then
            local amount = math.random(1000, 5000)
            if math.random(1, 100) > 70 then
                -- Critical heal
                MikSBT.DisplayEvent("OUTGOING_HEAL_CRIT", amount, "Test Heal")
            else
                -- Normal heal
                MikSBT.DisplayEvent("OUTGOING_HEAL", amount, "Test Heal")
            end
        else
            print("|cff1784d1VUI MSBT|r: MSBT needs to be enabled first.")
        end
    end)
    
    -- Create test button for notification
    local testNotifyBtn = VUI.ThemeHelpers:CreateButton(tab, "Test Notification", 120, 30)
    testNotifyBtn:SetPoint("TOPLEFT", testIncomingBtn, "BOTTOMLEFT", 0, -20)
    testNotifyBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Main and MikSBT.Main.isInitialized then
            MikSBT.DisplayEvent("NOTIFICATION_MONEY", GetCoinTextureString(math.random(10000, 100000)))
        else
            print("|cff1784d1VUI MSBT|r: MSBT needs to be enabled first.")
        end
    end)
    
    -- Create a reset button
    local resetBtn = VUI.ThemeHelpers:CreateButton(tab, "Reset All Settings", 150, 30)
    resetBtn:SetPoint("BOTTOMRIGHT", -20, 20)
    resetBtn:SetScript("OnClick", function()
        StaticPopupDialogs["VUI_MSBT_RESET"] = {
            text = "Are you sure you want to reset all MSBT settings?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                -- Reset all MSBT settings to defaults
                VUI.db.profile.modules.msbt = CopyTable(VUI.defaults.profile.modules.msbt)
                
                -- Reset the MikSBT profile to default if it exists
                if MikSBT and MikSBT.Profile and MikSBT.Profile.ResetProfile then
                    MikSBT.Profile:ResetProfile()
                end
                
                -- Refresh the display
                if MikSBT.Main and MikSBT.Main.isInitialized then
                    if MikSBT.Main.DisableMSBT then MikSBT.Main:DisableMSBT() end
                    C_Timer.After(0.1, function()
                        if MikSBT.Main.EnableMSBT then MikSBT.Main:EnableMSBT() end
                    end)
                end
                
                -- Apply the theme
                if MSBT.ThemeIntegration then
                    MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
                end
                
                print("|cff1784d1VUI MSBT|r: All settings have been reset to defaults.")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }
        StaticPopup_Show("VUI_MSBT_RESET")
    end)
end