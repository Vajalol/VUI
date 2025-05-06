--[[
    VUI - Actionbars Module Configuration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local module = VUI.actionbars

if not module then return end

-- Get configuration options for main UI integration
function module:GetConfigOptions()
    local config = {
        name = "Action Bars",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Action Bars",
                desc = "Enable or disable the Action Bars module",
                get = function() return self.settings.enabled end,
                set = function(_, value) 
                    self.settings.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            enhancedButtonStyle = {
                type = "toggle",
                name = "Enhanced Button Style",
                desc = "Use the enhanced button style with theme integration",
                get = function() return self.settings.enhancedButtonStyle end,
                set = function(_, value) 
                    self.settings.enhancedButtonStyle = value
                    self:UpdateActionBarVisuals()
                end,
                order = 2
            },
            showHotkeys = {
                type = "toggle",
                name = "Show Hotkeys",
                desc = "Show keybind text on action buttons",
                get = function() return self.settings.showHotkeys end,
                set = function(_, value) 
                    self.settings.showHotkeys = value
                    self:UpdateHotkeyText()
                end,
                order = 3
            },
            showMacroText = {
                type = "toggle",
                name = "Show Macro Text",
                desc = "Show macro names on action buttons",
                get = function() return self.settings.showMacroText end,
                set = function(_, value) 
                    self.settings.showMacroText = value
                    self:UpdateActionBarVisuals()
                end,
                order = 4
            },
            enhancedVisibility = {
                type = "toggle",
                name = "Enhanced Visibility",
                desc = "Enable enhanced visibility options for action bars",
                get = function() return self.settings.enhancedVisibility end,
                set = function(_, value) 
                    self.settings.enhancedVisibility = value
                    self:UpdateActionBarVisuals()
                end,
                order = 5
            },
            fadeOutOfCombat = {
                type = "toggle",
                name = "Fade Out of Combat",
                desc = "Fade action bars when out of combat",
                get = function() return self.settings.fadeOutOfCombat end,
                set = function(_, value) 
                    self.settings.fadeOutOfCombat = value
                    self:UpdateActionBarVisuals()
                end,
                order = 6
            },
            fadeAlpha = {
                type = "range",
                name = "Fade Alpha",
                desc = "Out of combat transparency (0 = invisible, 1 = fully visible)",
                min = 0,
                max = 1,
                step = 0.05,
                get = function() return self.settings.fadeAlpha end,
                set = function(_, value) 
                    self.settings.fadeAlpha = value
                    self:UpdateActionBarVisuals()
                end,
                order = 7
            },
            buttonSize = {
                type = "range",
                name = "Button Size",
                desc = "Size of action buttons in pixels",
                min = 20,
                max = 48,
                step = 1,
                get = function() return self.settings.buttonSize end,
                set = function(_, value) 
                    self.settings.buttonSize = value
                    self:UpdateActionBarLayout()
                end,
                order = 8
            },
            spacing = {
                type = "range",
                name = "Button Spacing",
                desc = "Space between action buttons in pixels",
                min = 0,
                max = 10,
                step = 1,
                get = function() return self.settings.spacing end,
                set = function(_, value) 
                    self.settings.spacing = value
                    self:UpdateActionBarLayout()
                end,
                order = 9
            },
            advanced = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open advanced settings panel",
                func = function()
                    if self.OpenAdvancedConfig then
                        self:OpenAdvancedConfig()
                    end
                end,
                order = 10
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("actionbars", module:GetConfigOptions())