local _, VUI = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Main options table for the addon
VUI.options = {
    type = "group",
    name = VUI.NAME .. " v" .. VUI.VERSION,
    handler = VUI,
    args = {
        general = {
            type = "group",
            name = "General",
            order = 1,
            args = {
                header = {
                    type = "header",
                    name = "General Settings",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Configure general settings for " .. VUI.NAME,
                    order = 2,
                },
                scale = {
                    type = "range",
                    name = "UI Scale",
                    desc = "Adjust the overall scale of the addon UI elements",
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    order = 3,
                    get = function() return VUI.db.profile.general.scale end,
                    set = function(_, value)
                        VUI.db.profile.general.scale = value
                        VUI:ApplySettings()
                    end,
                },
                spacer1 = {
                    type = "description",
                    name = " ",
                    order = 4,
                },
                minimapIcon = {
                    type = "toggle",
                    name = "Show Minimap Icon",
                    desc = "Show/hide the minimap icon for quick access to " .. VUI.NAME,
                    order = 5,
                    get = function() return not VUI.db.profile.general.minimap.hide end,
                    set = function(_, value)
                        VUI.db.profile.general.minimap.hide = not value
                        VUI:UpdateMinimapIcon()
                    end,
                },
                spacer2 = {
                    type = "description",
                    name = " ",
                    order = 6,
                },
                resetButton = {
                    type = "execute",
                    name = "Reset All Settings",
                    desc = "Reset all settings to their default values",
                    order = 7,
                    func = function()
                        StaticPopupDialogs["VUI_RESET_CONFIRM"] = {
                            text = "Are you sure you want to reset all " .. VUI.NAME .. " settings to default values?",
                            button1 = "Yes",
                            button2 = "No",
                            OnAccept = function()
                                VUI.db:ResetProfile()
                                VUI:Print("All settings have been reset to defaults")
                                VUI:ApplySettings()
                            end,
                            timeout = 0,
                            whileDead = true,
                            hideOnEscape = true,
                            preferredIndex = 3,
                        }
                        StaticPopup_Show("VUI_RESET_CONFIRM")
                    end,
                    width = "full",
                },
            },
        },
        appearance = {
            type = "group",
            name = "Appearance",
            order = 2,
            args = {
                header = {
                    type = "header",
                    name = "Appearance Settings",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Configure the visual appearance of " .. VUI.NAME,
                    order = 2,
                },
                theme = {
                    type = "select",
                    name = "Theme",
                    desc = "Choose the visual theme for the addon",
                    order = 3,
                    values = {
                        ["dark"] = "Dark",
                        ["light"] = "Light",
                        ["classic"] = "Classic",
                        ["minimal"] = "Minimal",
                    },
                    get = function() return VUI.db.profile.appearance.theme end,
                    set = function(_, value)
                        VUI.db.profile.appearance.theme = value
                        VUI:ApplySettings()
                    end,
                },
                font = {
                    type = "select",
                    name = "Font",
                    desc = "Choose the font for UI elements",
                    order = 4,
                    values = VUI.GetFontList,
                    get = function() return VUI.db.profile.appearance.font end,
                    set = function(_, value)
                        VUI.db.profile.appearance.font = value
                        VUI:ApplySettings()
                    end,
                },
                fontSize = {
                    type = "range",
                    name = "Font Size",
                    desc = "Adjust the font size for UI elements",
                    order = 5,
                    min = 8,
                    max = 24,
                    step = 1,
                    get = function() return VUI.db.profile.appearance.fontSize end,
                    set = function(_, value)
                        VUI.db.profile.appearance.fontSize = value
                        VUI:ApplySettings()
                    end,
                },
                spacer1 = {
                    type = "description",
                    name = " ",
                    order = 6,
                },
                border = {
                    type = "select",
                    name = "Border Style",
                    desc = "Choose the border style for UI elements",
                    order = 7,
                    values = {
                        ["blizzard"] = "Blizzard",
                        ["thin"] = "Thin",
                        ["none"] = "None",
                        ["custom"] = "Custom",
                    },
                    get = function() return VUI.db.profile.appearance.border end,
                    set = function(_, value)
                        VUI.db.profile.appearance.border = value
                        VUI:ApplySettings()
                    end,
                },
                classColoredBorders = {
                    type = "toggle",
                    name = "Class Colored Borders",
                    desc = "Use your class color for UI borders",
                    order = 8,
                    get = function() return VUI.db.profile.appearance.classColoredBorders end,
                    set = function(_, value)
                        VUI.db.profile.appearance.classColoredBorders = value
                        VUI:ApplySettings()
                    end,
                },
                useClassColors = {
                    type = "toggle",
                    name = "Use Class Colors",
                    desc = "Use class colors in UI elements where appropriate",
                    order = 9,
                    get = function() return VUI.db.profile.appearance.useClassColors end,
                    set = function(_, value)
                        VUI.db.profile.appearance.useClassColors = value
                        VUI:ApplySettings()
                    end,
                },
                spacer2 = {
                    type = "description",
                    name = " ",
                    order = 10,
                },
                backdropColor = {
                    type = "color",
                    name = "Backdrop Color",
                    desc = "Choose the background color for UI elements",
                    order = 11,
                    hasAlpha = true,
                    get = function()
                        local c = VUI.db.profile.appearance.backdropColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = VUI.db.profile.appearance.backdropColor
                        c.r, c.g, c.b, c.a = r, g, b, a
                        VUI:ApplySettings()
                    end,
                },
                borderColor = {
                    type = "color",
                    name = "Border Color",
                    desc = "Choose the border color for UI elements",
                    order = 12,
                    hasAlpha = true,
                    disabled = function() return VUI.db.profile.appearance.classColoredBorders end,
                    get = function()
                        local c = VUI.db.profile.appearance.borderColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = VUI.db.profile.appearance.borderColor
                        c.r, c.g, c.b, c.a = r, g, b, a
                        VUI:ApplySettings()
                    end,
                },
            },
        },
        about = {
            type = "group",
            name = "About",
            order = 99,
            args = {
                header = {
                    type = "header",
                    name = "About " .. VUI.NAME,
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = VUI.NAME .. " is a unified World of Warcraft addon suite combining multiple popular addons with centralized configuration.\n\n" ..
                           "Version: " .. VUI.VERSION .. "\n" ..
                           "Author: " .. VUI.AUTHOR .. "\n\n" ..
                           "Integrated modules:\n" ..
                           "• BuffOverlay - Display important buffs and debuffs\n" ..
                           "• TrufiGCD - Track recently used abilities\n" ..
                           "• MoveAny - Repositioning of UI elements\n" ..
                           "• Auctionator - Auction house enhancements\n" ..
                           "• Angry Keystones - Mythic+ dungeon improvements\n" ..
                           "• OmniCC - Cooldown count on all buttons\n" ..
                           "• OmniCD - Party cooldown tracking\n",
                    order = 2,
                    fontSize = "medium",
                },
            },
        },
    },
}

-- Function to apply the current settings to all modules
function VUI:ApplySettings()
    -- Apply general settings
    local scale = self.db.profile.general.scale
    
    -- Update appearance
    self:UpdateAppearance()
    
    -- Update all enabled modules with their settings
    for name, module in pairs(self.modules) do
        if self:IsModuleEnabled(name) and module.UpdateSettings then
            module:UpdateSettings()
        end
    end
    
    -- Notify user
    self:Print("Settings applied")
end

-- Function to update the appearance based on current settings
function VUI:UpdateAppearance()
    local appearance = self.db.profile.appearance
    
    -- Set font
    local font = self:GetFont(appearance.font)
    local fontSize = appearance.fontSize
    
    -- Set colors
    local backdrop = appearance.backdropColor
    local border = appearance.classColoredBorders and self.CLASSCOLOR or appearance.borderColor
    
    -- Update all frames with the new appearance
    for _, frame in pairs(self.frames or {}) do
        if frame.UpdateAppearance then
            frame:UpdateAppearance(appearance)
        end
    end
end

-- Function to update minimap icon visibility
function VUI:UpdateMinimapIcon()
    if self.LDBIcon then
        if self.db.profile.general.minimap.hide then
            self.LDBIcon:Hide("VUI")
        else
            self.LDBIcon:Show("VUI")
        end
    end
end

-- Get a list of available fonts (would be populated from the actual available fonts)
function VUI:GetFontList()
    return {
        ["Friz Quadrata TT"] = "Friz Quadrata TT",
        ["Arial Narrow"] = "Arial Narrow",
        ["Skurri"] = "Skurri",
        ["Morpheus"] = "Morpheus",
    }
end

-- Get the actual font path based on the font name
function VUI:GetFont(fontName)
    local fonts = {
        ["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF",
        ["Arial Narrow"] = "Fonts\\ARIALN.TTF",
        ["Skurri"] = "Fonts\\SKURRI.TTF",
        ["Morpheus"] = "Fonts\\MORPHEUS.TTF",
    }
    
    return fonts[fontName] or "Fonts\\FRIZQT__.TTF" -- Default to Friz Quadrata
end

-- Initialize configuration
function VUI:InitializeConfig()
    -- Register the options table
    AceConfig:RegisterOptionsTable(VUI.NAME, self.options)
    
    -- Create the main options panel frame
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(VUI.NAME, VUI.NAME)
    
    -- Create sections for each category
    self.generalFrame = AceConfigDialog:AddToBlizOptions(VUI.NAME, "General", VUI.NAME, "general")
    self.appearanceFrame = AceConfigDialog:AddToBlizOptions(VUI.NAME, "Appearance", VUI.NAME, "appearance")
    
    -- Create a modules frame if modules exist
    if self.options.args.modules then
        self.modulesFrame = AceConfigDialog:AddToBlizOptions(VUI.NAME, "Modules", VUI.NAME, "modules")
    end
    
    -- Add about panel
    self.aboutFrame = AceConfigDialog:AddToBlizOptions(VUI.NAME, "About", VUI.NAME, "about")
    
    -- Set up a callback for profile changed
    self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")
end
