local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Module theme integration helper
VUI.ModuleThemeIntegration = {}

-- Apply ThemeHelpers to module configuration panels
function VUI.ModuleThemeIntegration:ApplyToModule(moduleName)
    if not VUI.ThemeHelpers or not VUI[moduleName] then
        return false
    end
    
    local module = VUI[moduleName]
    
    -- Store original GetConfig function if it exists
    if module.GetConfig then
        module._originalGetConfig = module.GetConfig
    end
    
    -- Create a themed configuration panel for the module
    function module:CreateThemedConfigPanel()
        if self._themedConfigPanel then
            return self._themedConfigPanel
        end
        
        -- Create panel with module name
        local displayName = self.displayName or self.name or moduleName:gsub("^%l", string.upper)
        local panel = VUI.ThemeHelpers:CreatePanel(displayName .. " Configuration", nil, 600, 500)
        panel:Hide()
        
        -- Get existing config if available
        local config = self._originalGetConfig and self._originalGetConfig(self) or nil
        
        -- Default tab content setup
        local function setupGeneralTab(tab)
            -- Add title
            local title = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 20, -20)
            title:SetText(displayName)
            
            -- Add description
            local desc = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
            desc:SetPoint("TOPRIGHT", -20, -30)
            desc:SetJustifyH("LEFT")
            desc:SetText(self.description or ("Configuration for the " .. displayName .. " module."))
            desc:SetTextColor(0.9, 0.9, 0.9)
            
            -- Add enable checkbox if available in config
            if config and config.args and config.args.enabled then
                local enabled = VUI.db.profile.modules[moduleName] and VUI.db.profile.modules[moduleName].enabled
                local enableCB = VUI.ThemeHelpers:CreateCheckbox(tab, "Enable " .. displayName, enabled)
                enableCB:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
                enableCB:SetScript("OnClick", function(self)
                    -- Use original setter if available
                    if config.args.enabled.set then
                        config.args.enabled.set(nil, self:GetChecked())
                    else
                        -- Default implementation
                        if not VUI.db.profile.modules[moduleName] then
                            VUI.db.profile.modules[moduleName] = {}
                        end
                        VUI.db.profile.modules[moduleName].enabled = self:GetChecked()
                    end
                end)
            end
        end
        
        -- Create tabs based on config structure
        local tabs = {
            { name = "General", setup = setupGeneralTab },
        }
        
        -- Add more tabs based on module structure or config grouping
        if config and config.args then
            local groups = {}
            
            -- Identify potential tab groups in config
            for key, option in pairs(config.args) do
                if option.type == "group" and option.name and option.args and not groups[option.name] then
                    groups[option.name] = key
                end
            end
            
            -- Add tabs for each group
            for groupName, groupKey in pairs(groups) do
                local tabSetup = function(tab)
                    -- Title
                    local title = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                    title:SetPoint("TOPLEFT", 20, -20)
                    title:SetText(groupName)
                    
                    -- Add options from this group
                    local groupConfig = config.args[groupKey]
                    if groupConfig and groupConfig.args then
                        local lastElement = title
                        local yOffset = -20
                        
                        for optionKey, option in pairs(groupConfig.args) do
                            if option.type == "toggle" then
                                -- Add checkbox for toggle options
                                local value = false
                                if option.get then
                                    value = option.get()
                                elseif VUI.db.profile.modules[moduleName] then
                                    value = VUI.db.profile.modules[moduleName][optionKey]
                                end
                                
                                local cb = VUI.ThemeHelpers:CreateCheckbox(tab, option.name, value)
                                cb:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, yOffset)
                                cb.optionKey = optionKey
                                cb:SetScript("OnClick", function(self)
                                    local checked = self:GetChecked()
                                    if option.set then
                                        option.set(nil, checked)
                                    else
                                        -- Default implementation
                                        if not VUI.db.profile.modules[moduleName] then
                                            VUI.db.profile.modules[moduleName] = {}
                                        end
                                        VUI.db.profile.modules[moduleName][self.optionKey] = checked
                                    end
                                end)
                                
                                lastElement = cb
                                yOffset = -10
                            elseif option.type == "range" then
                                -- Add slider for range options
                                local value = option.min or 0
                                if option.get then
                                    value = option.get()
                                elseif VUI.db.profile.modules[moduleName] then
                                    value = VUI.db.profile.modules[moduleName][optionKey] or option.min or 0
                                end
                                
                                local slider = VUI.ThemeHelpers:CreateSlider(tab, option.name, option.min or 0, option.max or 1, option.step or 0.1, value)
                                slider:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 20, yOffset - 10)
                                slider.optionKey = optionKey
                                slider:SetScript("OnValueChanged", function(self, value)
                                    if option.set then
                                        option.set(nil, value)
                                    else
                                        -- Default implementation
                                        if not VUI.db.profile.modules[moduleName] then
                                            VUI.db.profile.modules[moduleName] = {}
                                        end
                                        VUI.db.profile.modules[moduleName][self.optionKey] = value
                                    end
                                end)
                                
                                lastElement = slider
                                yOffset = -30
                            elseif option.type == "select" and option.values then
                                -- Add dropdown for select options
                                local value = nil
                                if option.get then
                                    value = option.get()
                                elseif VUI.db.profile.modules[moduleName] then
                                    value = VUI.db.profile.modules[moduleName][optionKey]
                                end
                                
                                local dropdown = VUI.ThemeHelpers:CreateDropdown(tab, option.name, 180, option.values)
                                dropdown:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, yOffset - 10)
                                dropdown.optionKey = optionKey
                                dropdown.OnValueChanged = function(self, value)
                                    if option.set then
                                        option.set(nil, value)
                                    else
                                        -- Default implementation
                                        if not VUI.db.profile.modules[moduleName] then
                                            VUI.db.profile.modules[moduleName] = {}
                                        end
                                        VUI.db.profile.modules[moduleName][self.optionKey] = value
                                    end
                                end
                                if value and option.values[value] then
                                    UIDropDownMenu_SetText(dropdown, option.values[value])
                                end
                                
                                lastElement = dropdown
                                yOffset = -40
                            elseif option.type == "execute" then
                                -- Add button for execute options
                                local button = VUI.ThemeHelpers:CreateButton(tab, option.name, 180, 30)
                                button:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, yOffset - 10)
                                button:SetScript("OnClick", function()
                                    if option.func then
                                        option.func()
                                    end
                                end)
                                
                                lastElement = button
                                yOffset = -10
                            elseif option.type == "header" then
                                -- Add header text
                                local header = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                                header:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, yOffset - 20)
                                header:SetText(option.name)
                                
                                lastElement = header
                                yOffset = -10
                            elseif option.type == "description" then
                                -- Add description text
                                local desc = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                                desc:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, yOffset - 5)
                                desc:SetPoint("TOPRIGHT", -20, 0)
                                desc:SetJustifyH("LEFT")
                                desc:SetText(option.name)
                                desc:SetTextColor(0.9, 0.9, 0.9)
                                
                                lastElement = desc
                                yOffset = -10
                            end
                        end
                    end
                end
                
                table.insert(tabs, { name = groupName, setup = tabSetup })
            end
        end
        
        -- Create tab system
        panel.tabs = VUI.ThemeHelpers:CreateTabSystem(panel, panel:GetWidth() - 40, panel:GetHeight() - 60, tabs)
        
        -- Add sound effects
        function panel:Show()
            getmetatable(self).__index.Show(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        end
        
        function panel:Hide()
            getmetatable(self).__index.Hide(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
        end
        
        -- Store the panel
        self._themedConfigPanel = panel
        return panel
    end
    
    -- Override GetConfig to include a button to open themed panel
    function module:GetConfig()
        -- Get original config
        local config = self._originalGetConfig and self._originalGetConfig(self) or {
            type = "group",
            name = self.displayName or self.name or moduleName:gsub("^%l", string.upper),
            args = {
                header = {
                    type = "header",
                    name = (self.displayName or self.name or moduleName:gsub("^%l", string.upper)) .. " " .. (self.version or ""),
                    order = 1
                },
                desc = {
                    type = "description",
                    name = self.description or "Configuration for this module",
                    order = 2
                },
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable or disable this module",
                    get = function() 
                        return VUI.db.profile.modules[moduleName] and VUI.db.profile.modules[moduleName].enabled 
                    end,
                    set = function(_, val) 
                        if not VUI.db.profile.modules[moduleName] then
                            VUI.db.profile.modules[moduleName] = {}
                        end
                        VUI.db.profile.modules[moduleName].enabled = val
                    end,
                    width = "full",
                    order = 3
                }
            }
        }
        
        -- Add button to open themed config
        if not config.args.openThemedConfig then
            config.args.spacer = {
                type = "description",
                name = " ",
                order = 90
            }
            
            config.args.openThemedConfig = {
                type = "execute",
                name = "Advanced Configuration",
                desc = "Open the styled configuration panel for more options",
                func = function()
                    local panel = self:CreateThemedConfigPanel()
                    if panel then
                        panel:Show()
                    end
                end,
                width = "full",
                order = 100
            }
        end
        
        return config
    end
    
    -- Hook into panel creation if the module has its own method
    if module.CreateConfigPanel and not module._originalCreateConfigPanel then
        module._originalCreateConfigPanel = module.CreateConfigPanel
        
        function module:CreateConfigPanel()
            -- Use themed panel if available
            if VUI.ThemeHelpers then
                return self:CreateThemedConfigPanel()
            else
                -- Fallback to original
                return self._originalCreateConfigPanel(self)
            end
        end
    end
    
    return true
end

-- Apply ThemeHelpers to all modules
function VUI.ModuleThemeIntegration:ApplyToAllModules()
    -- Skip these modules as they have specialized theme integration already
    local skipModules = {
        ["msbt"] = true,
        ["detailsskin"] = true
    }
    
    for _, moduleName in ipairs(VUI.modules) do
        if not skipModules[moduleName] and VUI[moduleName] then
            self:ApplyToModule(moduleName)
        end
    end
end