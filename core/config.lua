local _, VUI = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- Main options table for the addon
VUI.options = {
    type = "group",
    name = "VUI v" .. VUI.version,
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
                    name = "Configure general settings for VUI",
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
                    desc = "Show/hide the minimap icon for quick access to VUI",
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
                playerHeader = {
                    type = "header",
                    name = "Player Settings",
                    order = 7,
                },
                castbarSubHeader = {
                    type = "description",
                    name = "|cff00ffffCastbar Options|r",
                    order = 8,
                    fontSize = "medium",
                },
                castbarEnabled = {
                    type = "toggle",
                    name = "Enable Custom Castbar",
                    desc = "Enable or disable the custom castbar with Thunder Storm theme",
                    order = 9,
                    get = function() return VUI.db.profile.general.castbar.enabled end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.enabled = value
                        VUI:ApplySettings()
                    end,
                    width = 1.5,
                },
                castbarCustomColors = {
                    type = "toggle",
                    name = "Use Theme Colors",
                    desc = "Apply Thunder Storm theme colors to the castbar",
                    order = 10,
                    get = function() return VUI.db.profile.general.castbar.customColors end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.customColors = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1.5,
                },
                castbarShowSpellName = {
                    type = "toggle",
                    name = "Show Spell Name",
                    desc = "Show spell name on the castbar",
                    order = 11,
                    get = function() return VUI.db.profile.general.castbar.showSpellName end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.showSpellName = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1,
                },
                castbarShowIcon = {
                    type = "toggle",
                    name = "Show Spell Icon",
                    desc = "Show spell icon before the castbar",
                    order = 12,
                    get = function() return VUI.db.profile.general.castbar.showIcon end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.showIcon = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1,
                },
                castbarShowTimer = {
                    type = "toggle",
                    name = "Show Timer",
                    desc = "Show the remaining time on the castbar",
                    order = 13,
                    get = function() return VUI.db.profile.general.castbar.showTimer end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.showTimer = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1,
                },
                castbarShowLatency = {
                    type = "toggle",
                    name = "Show Latency",
                    desc = "Show your current latency on the castbar",
                    order = 14,
                    get = function() return VUI.db.profile.general.castbar.showLatency end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.showLatency = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1,
                },
                castbarShowTarget = {
                    type = "toggle",
                    name = "Show Target",
                    desc = "Show your current target's name on the castbar",
                    order = 15,
                    get = function() return VUI.db.profile.general.castbar.showTarget end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.showTarget = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1,
                },
                castbarShowCastTime = {
                    type = "toggle",
                    name = "Show Cast Time",
                    desc = "Show cast time after cast completes",
                    order = 16,
                    get = function() return VUI.db.profile.general.castbar.showCastTime end,
                    set = function(_, value)
                        VUI.db.profile.general.castbar.showCastTime = value
                        VUI:ApplySettings()
                    end,
                    disabled = function() return not VUI.db.profile.general.castbar.enabled end,
                    width = 1,
                },
                spacerAfterCastbar = {
                    type = "description",
                    name = " ",
                    order = 17,
                },
                resetButton = {
                    type = "execute",
                    name = "Reset All Settings",
                    desc = "Reset all settings to their default values",
                    order = 18,
                    func = function()
                        StaticPopupDialogs["VUI_RESET_CONFIRM"] = {
                            text = "Are you sure you want to reset all VUI settings to default values?",
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
        dashboard = {
            type = "group",
            name = "Dashboard",
            order = 2,
            args = {
                header = {
                    type = "header",
                    name = "Dashboard Settings",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Configure the VUI Dashboard panel",
                    order = 2,
                },
                enabled = {
                    type = "toggle",
                    name = "Enable Dashboard",
                    desc = "Enable or disable the VUI Dashboard",
                    order = 3,
                    get = function() return VUI.db.profile.dashboard.enabled end,
                    set = function(_, value)
                        VUI.db.profile.dashboard.enabled = value
                        if value and VUI.Dashboard then
                            VUI.Dashboard:Enable()
                        elseif not value and VUI.Dashboard then
                            VUI.Dashboard:Disable()
                        end
                    end,
                },
                autoHide = {
                    type = "toggle",
                    name = "Auto-Hide Dashboard",
                    desc = "Automatically hide the dashboard when not in use",
                    order = 4,
                    get = function() return VUI.db.profile.dashboard.autoHide end,
                    set = function(_, value)
                        VUI.db.profile.dashboard.autoHide = value
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                spacer1 = {
                    type = "description",
                    name = " ",
                    order = 5,
                },
                scale = {
                    type = "range",
                    name = "Dashboard Scale",
                    desc = "Adjust the scale of the Dashboard panel",
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    order = 6,
                    get = function() return VUI.db.profile.dashboard.scale end,
                    set = function(_, value)
                        VUI.db.profile.dashboard.scale = value
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                width = {
                    type = "range",
                    name = "Width",
                    desc = "Adjust the width of the Dashboard panel",
                    min = 500,
                    max = 1200,
                    step = 10,
                    order = 7,
                    get = function() return VUI.db.profile.dashboard.width end,
                    set = function(_, value)
                        VUI.db.profile.dashboard.width = value
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                height = {
                    type = "range",
                    name = "Height",
                    desc = "Adjust the height of the Dashboard panel",
                    min = 400,
                    max = 800,
                    step = 10,
                    order = 8,
                    get = function() return VUI.db.profile.dashboard.height end,
                    set = function(_, value)
                        VUI.db.profile.dashboard.height = value
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                spacer2 = {
                    type = "description",
                    name = " ",
                    order = 9,
                },
                theme = {
                    type = "select",
                    name = "Dashboard Theme",
                    desc = "Choose the theme for the Dashboard",
                    order = 10,
                    values = {
                        ["thunderstorm"] = "Thunder Storm",
                        ["phoenixflame"] = "Phoenix Flame",
                        ["arcanemystic"] = "Arcane Mystic",
                        ["felenergy"] = "Fel Energy",
                        ["dark"] = "Dark",
                        ["light"] = "Light",
                    },
                    get = function() return VUI.db.profile.dashboard.theme end,
                    set = function(_, value)
                        VUI.db.profile.dashboard.theme = value
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                display = {
                    type = "multiselect",
                    name = "Display Elements",
                    desc = "Choose which elements to display on the Dashboard",
                    order = 11,
                    values = {
                        ["showModuleCards"] = "Module Cards",
                        ["showStatusDisplay"] = "Status Display",
                    },
                    get = function(_, key)
                        return VUI.db.profile.dashboard[key]
                    end,
                    set = function(_, key, value)
                        VUI.db.profile.dashboard[key] = value
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                spacer3 = {
                    type = "description",
                    name = " ",
                    order = 12,
                },
                resetPosition = {
                    type = "execute",
                    name = "Reset Position",
                    desc = "Reset the Dashboard position to the center of the screen",
                    order = 13,
                    func = function()
                        VUI.db.profile.dashboard.position = { x = 0, y = 0 }
                        if VUI.Dashboard then
                            VUI.Dashboard:Refresh()
                        end
                    end,
                },
                showDashboard = {
                    type = "execute",
                    name = "Show Dashboard",
                    desc = "Display the Dashboard",
                    order = 14,
                    func = function()
                        if VUI.Dashboard then
                            VUI.Dashboard:Show()
                        end
                    end,
                },
            },
        },
        appearance = {
            type = "group",
            name = "Appearance",
            order = 3,
            args = {
                header = {
                    type = "header",
                    name = "Appearance Settings",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Configure the visual appearance of VUI",
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
                        ["thunderstorm"] = "Thunder Storm",
                        ["phoenixflame"] = "Phoenix Flame",
                        ["arcanemystic"] = "Arcane Mystic",
                        ["felenergy"] = "Fel Energy",
                        ["classcolor"] = "Class Color",
                    },
                    get = function() return VUI.db.profile.appearance.theme end,
                    set = function(_, value)
                        VUI.db.profile.appearance.theme = value
                        VUI:ApplySettings()
                        
                        -- Set colors based on the selected theme
                        if value == "thunderstorm" then
                            -- Thunder Storm theme colors
                            VUI.db.profile.appearance.backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.8} -- Deep blue
                            VUI.db.profile.appearance.borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
                        elseif value == "phoenixflame" then
                            -- Phoenix Flame theme colors
                            VUI.db.profile.appearance.backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.8} -- Dark red/brown
                            VUI.db.profile.appearance.borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
                        elseif value == "arcanemystic" then
                            -- Arcane Mystic theme colors
                            VUI.db.profile.appearance.backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.8} -- Deep purple
                            VUI.db.profile.appearance.borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Bright violet
                        elseif value == "felenergy" then
                            -- Fel Energy theme colors
                            VUI.db.profile.appearance.backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.8} -- Dark green
                            VUI.db.profile.appearance.borderColor = {r = 0.1, g = 1.0, b = 0.1, a = 1} -- Fel green
                        elseif value == "dark" then
                            -- Default Dark theme colors
                            VUI.db.profile.appearance.backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                            VUI.db.profile.appearance.borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1}
                        elseif value == "light" then
                            -- Light theme colors
                            VUI.db.profile.appearance.backdropColor = {r = 0.8, g = 0.8, b = 0.8, a = 0.8}
                            VUI.db.profile.appearance.borderColor = {r = 0.5, g = 0.5, b = 0.5, a = 1}
                        elseif value == "classcolor" then
                            -- Apply Class Color theme
                            local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
                            local darkClassColor = {
                                r = classColor.r * 0.2,
                                g = classColor.g * 0.2,
                                b = classColor.b * 0.2,
                                a = 0.8
                            }
                            VUI.db.profile.appearance.backdropColor = darkClassColor
                            VUI.db.profile.appearance.borderColor = {
                                r = classColor.r,
                                g = classColor.g,
                                b = classColor.b,
                                a = 1
                            }
                            
                            -- Enable additional class color settings
                            VUI.db.profile.appearance.useClassColors = true
                            VUI.db.profile.appearance.classColoredBorders = true
                            VUI.db.profile.skins.useClassColors = true
                        end
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
        modules = {
            type = "group",
            name = "Modules",
            order = 4,
            args = {
                header = {
                    type = "header",
                    name = "Module Settings",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Enable or disable VUI modules and configure their settings.",
                    order = 2,
                },
                moduleSelect = {
                    type = "select",
                    name = "Module",
                    desc = "Select a module to configure",
                    order = 3,
                    values = {
                        ["chat"] = "Chat",
                        ["buffoverlay"] = "BuffOverlay",
                        ["trufigcd"] = "TrufiGCD",
                        ["moveany"] = "MoveAny",
                        ["auctionator"] = "Auctionator",
                        ["angrykeystone"] = "Angry Keystones",
                        ["omnicc"] = "OmniCC",
                        ["omnicd"] = "OmniCD",
                        ["idtip"] = "idTip",
                        ["premadegroupfinder"] = "Premade Group Finder",
                        ["detailsskin"] = "Details Skin",
                        ["msbt"] = "Scrolling Battle Text",
                        ["multinotification"] = "Multi-Notification"
                    },
                    get = function() return VUI.selectedModule or "buffoverlay" end,
                    set = function(_, value)
                        VUI.selectedModule = value
                        VUI:ShowModuleConfig()
                    end,
                },
                spacer1 = {
                    type = "description",
                    name = " ",
                    order = 4,
                },
                moduleSettings = {
                    type = "group",
                    name = function() return VUI.selectedModule and VUI.selectedModule:gsub("^%l", string.upper) or "Module" end,
                    inline = true,
                    order = 5,
                    args = {
                        -- This will be populated dynamically based on the selected module
                        placeholder = {
                            type = "description",
                            name = "Select a module to configure its settings.",
                            order = 1,
                        }
                    }
                }
            }
        },
        profiles = {
            type = "group",
            name = "Profiles",
            order = 5,
            args = {
                header = {
                    type = "header",
                    name = "Profile Settings",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Manage your VUI configuration profiles.",
                    order = 2,
                },
                -- Profiles will be handled by Ace3 profile functionality
                -- This is just a placeholder for now
            }
        },
        about = {
            type = "group",
            name = "About",
            order = 99,
            args = {
                header = {
                    type = "header",
                    name = "About VUI",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "VUI is a unified World of Warcraft addon suite combining multiple popular addons with centralized configuration.\n\n" ..
                           "Version: " .. VUI.version .. "\n" ..
                           "Author: " .. VUI.author .. "\n\n" ..
                           "Integrated modules:\n" ..
                           "• BuffOverlay - Display important buffs and debuffs\n" ..
                           "• TrufiGCD - Track recently used abilities\n" ..
                           "• MoveAny - Repositioning of UI elements\n" ..
                           "• Auctionator - Auction house enhancements\n" ..
                           "• Angry Keystones - Mythic+ dungeon improvements\n" ..
                           "• OmniCC - Cooldown count on all buttons\n" ..
                           "• OmniCD - Party cooldown tracking\n" ..
                           "• idTip - Display spell, item, quest IDs in tooltips\n" ..
                           "• Premade Group Finder - Enhanced LFG interface\n" ..
                           "• Details Skin - Themed appearance for Details! damage meter\n" ..
                           "• Scrolling Battle Text - Combat info display (MSBT)\n" ..
                           "• Multi-Notification - Unified notification system\n",
                    order = 2,
                    fontSize = "medium",
                },
                credits = {
                    type = "description",
                    name = "VUI integrates code from:\n" ..
                           "- BuffOverlay by clicketz\n" ..
                           "- TrufiGCD by Trufi\n" ..
                           "- MoveAny by d4kir92\n" ..
                           "- Auctionator by the Auctionator team\n" ..
                           "- Angry Keystones by Ermad\n" ..
                           "- OmniCC by tullamods\n" ..
                           "- OmniCD (adapted implementation)\n" ..
                           "- idTip by Silverwind\n" ..
                           "- Premade Group Finder by Savhz\n" ..
                           "- Details Damage Meter by Terciob\n" ..
                           "- MikScrollingBattleText by Mikord\n" ..
                           "- Notification System by VortexQ8\n" ..
                           "\nSpecial thanks to all the original addon authors.",
                    order = 3,
                    fontSize = "medium",
                }
            },
        },
    },
}

-- Save the current profile as a preset
function VUI:SaveProfileAsPreset(presetName, description)
    if not presetName or presetName == "" then
        self:Print("Error: Invalid preset name.")
        return false
    end
    
    -- Make a deep copy of the current profile data
    local currentProfile = {}
    local sourceProfile = self.db.profile
    
    -- Deep copy function for nested tables
    local function deepCopy(source, destination)
        for k, v in pairs(source) do
            if type(v) == "table" then
                destination[k] = {}
                deepCopy(v, destination[k])
            else
                destination[k] = v
            end
        end
    end
    
    -- Create deep copy of profile
    deepCopy(sourceProfile, currentProfile)
    
    -- Save the preset
    if not self.db.global.presets then
        self.db.global.presets = {}
    end
    
    self.db.global.presets[presetName] = {
        profileData = currentProfile,
        description = description or "",
        created = date("%Y-%m-%d %H:%M:%S"),
        version = self.version
    }
    
    self:Print("Preset '" .. presetName .. "' has been saved.")
    return true
end

-- Load a preset into the current profile
function VUI:LoadPreset(presetName)
    if not presetName or not self.db.global.presets or not self.db.global.presets[presetName] then
        self:Print("Error: Preset '" .. (presetName or "unknown") .. "' not found.")
        return false
    end
    
    local preset = self.db.global.presets[presetName]
    local presetData = preset.profileData
    
    -- Replace current profile with preset data
    local function deepReplace(source, destination)
        -- Clear destination table
        for k in pairs(destination) do
            destination[k] = nil
        end
        
        -- Copy data from source to destination
        for k, v in pairs(source) do
            if type(v) == "table" then
                destination[k] = {}
                deepReplace(v, destination[k])
            else
                destination[k] = v
            end
        end
    end
    
    -- Replace profile data
    deepReplace(presetData, self.db.profile)
    
    -- Apply settings
    self:ApplySettings()
    
    self:Print("Preset '" .. presetName .. "' has been loaded.")
    return true
end

-- Delete a preset
function VUI:DeletePreset(presetName)
    if not presetName or not self.db.global.presets or not self.db.global.presets[presetName] then
        self:Print("Error: Preset '" .. (presetName or "unknown") .. "' not found.")
        return false
    end
    
    self.db.global.presets[presetName] = nil
    self:Print("Preset '" .. presetName .. "' has been deleted.")
    return true
end

-- Export a preset to a string
function VUI:ExportPreset(presetName)
    if not presetName or not self.db.global.presets or not self.db.global.presets[presetName] then
        self:Print("Error: Preset '" .. (presetName or "unknown") .. "' not found.")
        return nil
    end
    
    local preset = self.db.global.presets[presetName]
    
    -- Convert preset to a string for export
    local serialized = LibStub:GetLibrary("AceSerializer-3.0"):Serialize(preset)
    local encoded = LibStub:GetLibrary("LibDeflate"):EncodeForPrint(
        LibStub:GetLibrary("LibDeflate"):CompressDeflate(serialized)
    )
    
    return encoded
end

-- Import a preset from a string
function VUI:ImportPreset(presetName, encodedString)
    if not presetName or presetName == "" then
        self:Print("Error: Invalid preset name.")
        return false
    end
    
    if not encodedString or encodedString == "" then
        self:Print("Error: Invalid import string.")
        return false
    end
    
    local decoded = LibStub:GetLibrary("LibDeflate"):DecodeForPrint(encodedString)
    if not decoded then
        self:Print("Error: Import string is corrupted or invalid.")
        return false
    end
    
    local decompressed = LibStub:GetLibrary("LibDeflate"):DecompressDeflate(decoded)
    if not decompressed then
        self:Print("Error: Failed to decompress import string.")
        return false
    end
    
    local success, presetData = LibStub:GetLibrary("AceSerializer-3.0"):Deserialize(decompressed)
    if not success then
        self:Print("Error: Failed to deserialize preset data.")
        return false
    end
    
    -- Validate preset data
    if not presetData.profileData then
        self:Print("Error: Invalid preset data (missing profile data).")
        return false
    end
    
    -- Add imported preset
    if not self.db.global.presets then
        self.db.global.presets = {}
    end
    
    -- Add import note
    presetData.imported = true
    presetData.importDate = date("%Y-%m-%d %H:%M:%S")
    
    self.db.global.presets[presetName] = presetData
    self:Print("Preset '" .. presetName .. "' has been imported.")
    return true
end

-- Add profile options to the config panel
function VUI:SetupProfileOptions()
    -- Get the profile options table from AceDBOptions
    local profilesOptions = AceDBOptions:GetOptionsTable(self.db)
    
    -- Add the profiles tab to our options table
    self.options.args.profiles = profilesOptions
    self.options.args.profiles.order = 99  -- Make it appear at the end
    self.options.args.profiles.name = "Profiles"
    
    -- Add presets section to profiles tab
    self.options.args.profiles.args.presetsHeader = {
        type = "header",
        name = "Configuration Presets",
        order = 100,
    }
    
    self.options.args.profiles.args.presetsDesc = {
        type = "description",
        name = "Save and load configuration presets. Presets capture your entire profile configuration and can be shared with others.",
        order = 101,
    }
    
    -- Save preset section
    self.options.args.profiles.args.savePresetGroup = {
        type = "group",
        name = "Save Preset",
        inline = true,
        order = 102,
        args = {
            presetName = {
                type = "input",
                name = "Preset Name",
                desc = "Enter a name for your preset",
                order = 1,
                width = "full",
                get = function() return self.tempPresetName or "" end,
                set = function(_, value) self.tempPresetName = value end,
            },
            presetDesc = {
                type = "input",
                name = "Description",
                desc = "Enter a description for your preset",
                order = 2,
                width = "full",
                multiline = 2,
                get = function() return self.tempPresetDesc or "" end,
                set = function(_, value) self.tempPresetDesc = value end,
            },
            savePreset = {
                type = "execute",
                name = "Save Preset",
                desc = "Save your current configuration as a preset",
                order = 3,
                func = function()
                    if self.tempPresetName and self.tempPresetName ~= "" then
                        self:SaveProfileAsPreset(self.tempPresetName, self.tempPresetDesc)
                        self.tempPresetName = nil
                        self.tempPresetDesc = nil
                    else
                        self:Print("Please enter a name for your preset.")
                    end
                end,
            },
        },
    }
    
    -- Load preset section
    self.options.args.profiles.args.loadPresetGroup = {
        type = "group",
        name = "Load Preset",
        inline = true,
        order = 103,
        args = {
            presetSelect = {
                type = "select",
                name = "Select Preset",
                desc = "Choose a preset to load",
                order = 1,
                width = "full",
                values = function()
                    local presets = {}
                    if self.db.global.presets then
                        for name, data in pairs(self.db.global.presets) do
                            presets[name] = name
                        end
                    end
                    return presets
                end,
                get = function() return self.selectedPreset end,
                set = function(_, value) 
                    self.selectedPreset = value
                    -- Update preview description if available
                    if value and self.db.global.presets and self.db.global.presets[value] then
                        self.presetPreviewDesc = self.db.global.presets[value].description or ""
                        self.presetPreviewDate = self.db.global.presets[value].created or "Unknown"
                    else
                        self.presetPreviewDesc = ""
                        self.presetPreviewDate = ""
                    end
                end,
            },
            presetInfo = {
                type = "description",
                name = function()
                    if self.selectedPreset and self.db.global.presets and self.db.global.presets[self.selectedPreset] then
                        local preset = self.db.global.presets[self.selectedPreset]
                        return "Description: " .. (preset.description or "None") .. 
                               "\nCreated: " .. (preset.created or "Unknown") ..
                               "\nVersion: " .. (preset.version or "Unknown")
                    else
                        return "Select a preset to view information"
                    end
                end,
                order = 2,
                width = "full",
            },
            loadPreset = {
                type = "execute",
                name = "Load Preset",
                desc = "Load the selected preset",
                order = 3,
                width = "half",
                disabled = function() return not self.selectedPreset end,
                confirm = function() return "Are you sure you want to load this preset? Your current settings will be overwritten." end,
                func = function()
                    if self.selectedPreset then
                        self:LoadPreset(self.selectedPreset)
                    end
                end,
            },
            deletePreset = {
                type = "execute",
                name = "Delete Preset",
                desc = "Delete the selected preset",
                order = 4,
                width = "half",
                disabled = function() return not self.selectedPreset end,
                confirm = function() return "Are you sure you want to delete this preset? This cannot be undone." end,
                func = function()
                    if self.selectedPreset then
                        self:DeletePreset(self.selectedPreset)
                        self.selectedPreset = nil
                        self.presetPreviewDesc = ""
                        self.presetPreviewDate = ""
                    end
                end,
            },
        },
    }
    
    -- Import/Export section
    self.options.args.profiles.args.importExportGroup = {
        type = "group",
        name = "Import/Export Presets",
        inline = true,
        order = 104,
        args = {
            exportPresetSelect = {
                type = "select",
                name = "Select Preset to Export",
                desc = "Choose a preset to export",
                order = 1,
                width = "full",
                values = function()
                    local presets = {}
                    if self.db.global.presets then
                        for name, data in pairs(self.db.global.presets) do
                            presets[name] = name
                        end
                    end
                    return presets
                end,
                get = function() return self.exportPreset end,
                set = function(_, value) self.exportPreset = value end,
            },
            exportPreset = {
                type = "execute",
                name = "Export Preset",
                desc = "Export the selected preset as a string",
                order = 2,
                width = "half",
                disabled = function() return not self.exportPreset end,
                func = function()
                    if self.exportPreset then
                        local exportString = self:ExportPreset(self.exportPreset)
                        if exportString then
                            self.exportString = exportString
                            self:Print("Preset exported. Copy the string from the text box below.")
                        end
                    end
                end,
            },
            spacer1 = {
                type = "description",
                name = " ",
                order = 3,
                width = "half",
            },
            exportString = {
                type = "input",
                name = "Export String",
                desc = "Copy this string to share your preset",
                order = 4,
                width = "full",
                multiline = 8,
                get = function() return self.exportString or "" end,
                set = function() end, -- Read-only
            },
            importNameInput = {
                type = "input",
                name = "Import Preset Name",
                desc = "Enter a name for the preset you're importing",
                order = 5,
                width = "full",
                get = function() return self.importPresetName or "" end,
                set = function(_, value) self.importPresetName = value end,
            },
            importString = {
                type = "input",
                name = "Import String",
                desc = "Paste a preset string here to import",
                order = 6,
                width = "full",
                multiline = 8,
                get = function() return self.importString or "" end,
                set = function(_, value) self.importString = value end,
            },
            importPreset = {
                type = "execute",
                name = "Import Preset",
                desc = "Import the preset from the string",
                order = 7,
                width = "full",
                disabled = function() return not self.importPresetName or self.importPresetName == "" or not self.importString or self.importString == "" end,
                func = function()
                    if self.importPresetName and self.importPresetName ~= "" and self.importString and self.importString ~= "" then
                        self:ImportPreset(self.importPresetName, self.importString)
                        self.importPresetName = nil
                        self.importString = nil
                    end
                end,
            },
        },
    }
end

-- Custom VUI config panel
function VUI:CreateConfigPanel()
    -- If the panel already exists and is shown, just return it
    if self.configFrame and self.configFrame:IsShown() then
        return self.configFrame
    end
    
    -- Create or reset the config frame
    if not self.configFrame then
        -- Create the main frame
        self.configFrame = CreateFrame("Frame", "VUIConfigFrame", UIParent)
        self.configFrame:SetSize(900, 650)
        self.configFrame:SetPoint("CENTER")
        self.configFrame:SetFrameStrata("DIALOG")
        self.configFrame:EnableMouse(true)
        self.configFrame:SetMovable(true)
        self.configFrame:RegisterForDrag("LeftButton")
        self.configFrame:SetScript("OnDragStart", self.configFrame.StartMoving)
        self.configFrame:SetScript("OnDragStop", self.configFrame.StopMovingOrSizing)
        
        -- Add background and border
        self.configFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        
        -- Add title
        self.configFrame.title = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.configFrame.title:SetPoint("TOPLEFT", 16, -16)
        self.configFrame.title:SetText("VUI Configuration")
        
        -- Add close button
        self.configFrame.closeButton = CreateFrame("Button", nil, self.configFrame, "UIPanelCloseButton")
        self.configFrame.closeButton:SetPoint("TOPRIGHT", -5, -5)
        
        -- Create sections container
        self.configFrame.sections = {}
        
        -- Create navigation sidebar
        self.configFrame.sidebar = CreateFrame("Frame", nil, self.configFrame)
        self.configFrame.sidebar:SetSize(200, self.configFrame:GetHeight() - 40)
        self.configFrame.sidebar:SetPoint("TOPLEFT", 16, -40)
        
        -- Add sidebar background
        self.configFrame.sidebar:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Create content area
        self.configFrame.content = CreateFrame("Frame", nil, self.configFrame)
        self.configFrame.content:SetSize(self.configFrame:GetWidth() - 240, self.configFrame:GetHeight() - 40)
        self.configFrame.content:SetPoint("TOPLEFT", self.configFrame.sidebar, "TOPRIGHT", 20, 0)
        
        -- Add content background
        self.configFrame.content:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Create navigation buttons
        local buttons = {
            { text = "General", section = "General" },
            { text = "Appearance", section = "Appearance" },
            { text = "Modules", section = "Modules" },
            { text = "Profiles", section = "Profiles" },
            { text = "About", section = "About" }
        }
        
        for i, buttonInfo in ipairs(buttons) do
            local button = CreateFrame("Button", nil, self.configFrame.sidebar)
            button:SetSize(170, 30)
            button:SetPoint("TOPLEFT", 15, -15 - ((i-1) * 35))
            
            -- Normal texture
            button.normaltexture = button:CreateTexture(nil, "BACKGROUND")
            button.normaltexture:SetAllPoints()
            button.normaltexture:SetColorTexture(0.2, 0.2, 0.2, 0.5)
            
            -- Highlight texture
            button.highlighttexture = button:CreateTexture(nil, "HIGHLIGHT")
            button.highlighttexture:SetAllPoints()
            button.highlighttexture:SetColorTexture(0.3, 0.3, 0.3, 0.5)
            button:SetHighlightTexture(button.highlighttexture)
            
            -- Text
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetPoint("CENTER")
            button.text:SetText(buttonInfo.text)
            
            -- Click handler
            button:SetScript("OnClick", function()
                self:ShowConfigSection(buttonInfo.section)
            end)
            
            -- Store button
            self.configFrame.sidebar["button"..i] = button
        end
        
        -- Create section frames
        self:CreateGeneralSection()
        self:CreateAppearanceSection()
        self:CreateModulesSection()
        self:CreateProfilesSection()
        self:CreateAboutSection()
    end
    
    -- Show the default section
    self:ShowConfigSection("General")
    
    -- Show the frame
    self.configFrame:Show()
    
    return self.configFrame
end

-- Show a specific section of the config panel
function VUI:ShowConfigSection(section)
    -- Hide all sections
    for name, frame in pairs(self.configFrame.sections) do
        frame:Hide()
    end
    
    -- Show the requested section
    if self.configFrame.sections[section] then
        self.configFrame.sections[section]:Show()
        
        -- Update button highlights
        for i = 1, 5 do
            local button = self.configFrame.sidebar["button"..i]
            if button and button.text:GetText() == section then
                button.normaltexture:SetColorTexture(0.4, 0.4, 0.4, 0.5)
            else
                button.normaltexture:SetColorTexture(0.2, 0.2, 0.2, 0.5)
            end
        end
    end
end

-- Create the General section
function VUI:CreateGeneralSection()
    -- Create the section frame if it doesn't exist
    if not self.configFrame.sections.General then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText("General Settings")
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.desc:SetText("Configure general settings for VUI")
        
        -- Scale slider
        frame.scaleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.scaleText:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -20)
        frame.scaleText:SetText("UI Scale:")
        
        frame.scaleSlider = CreateFrame("Slider", "VUIGeneralScaleSlider", frame, "OptionsSliderTemplate")
        frame.scaleSlider:SetPoint("TOPLEFT", frame.scaleText, "BOTTOMLEFT", 0, -10)
        frame.scaleSlider:SetWidth(200)
        frame.scaleSlider:SetMinMaxValues(0.5, 2.0)
        frame.scaleSlider:SetValueStep(0.05)
        frame.scaleSlider:SetObeyStepOnDrag(true)
        _G[frame.scaleSlider:GetName().."Low"]:SetText("0.5")
        _G[frame.scaleSlider:GetName().."High"]:SetText("2.0")
        frame.scaleSlider:SetValue(self.db.profile.general.scale or 1.0)
        
        frame.scaleSlider:SetScript("OnValueChanged", function(self, value)
            VUI.db.profile.general.scale = value
            _G[self:GetName().."Text"]:SetText(format("%.2f", value))
            VUI:ApplySettings()
        end)
        
        -- Minimap icon checkbox
        frame.minimapCheckbox = CreateFrame("CheckButton", "VUIGeneralMinimapCheckbox", frame, "OptionsCheckButtonTemplate")
        frame.minimapCheckbox:SetPoint("TOPLEFT", frame.scaleSlider, "BOTTOMLEFT", 0, -20)
        _G[frame.minimapCheckbox:GetName().."Text"]:SetText("Show Minimap Icon")
        frame.minimapCheckbox:SetChecked(not self.db.profile.general.minimap.hide)
        
        frame.minimapCheckbox:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            VUI.db.profile.general.minimap.hide = not checked
            VUI:UpdateMinimapIcon()
        end)
        
        -- Reset button
        frame.resetButton = CreateFrame("Button", "VUIGeneralResetButton", frame, "UIPanelButtonTemplate")
        frame.resetButton:SetPoint("TOPLEFT", frame.minimapCheckbox, "BOTTOMLEFT", 0, -20)
        frame.resetButton:SetSize(150, 22)
        frame.resetButton:SetText("Reset All Settings")
        
        frame.resetButton:SetScript("OnClick", function()
            StaticPopupDialogs["VUI_RESET_CONFIRM"] = {
                text = "Are you sure you want to reset all VUI settings to default values?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    VUI.db:ResetProfile()
                    VUI:Print("All settings have been reset to defaults")
                    VUI:ApplySettings()
                    
                    -- Update UI elements
                    frame.scaleSlider:SetValue(VUI.db.profile.general.scale or 1.0)
                    frame.minimapCheckbox:SetChecked(not VUI.db.profile.general.minimap.hide)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUI_RESET_CONFIRM")
        end)
        
        -- Store the frame
        self.configFrame.sections.General = frame
    end
end

-- Create the Appearance section
function VUI:CreateAppearanceSection()
    -- Create the section frame if it doesn't exist
    if not self.configFrame.sections.Appearance then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText("Appearance Settings")
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.desc:SetText("Configure the visual appearance of VUI")
        
        -- Theme dropdown
        frame.themeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.themeText:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -20)
        frame.themeText:SetText("Theme:")
        
        -- Simple dropdown implementation
        frame.themeDropdown = CreateFrame("Frame", "VUIAppearanceThemeDropdown", frame, "UIDropDownMenuTemplate")
        frame.themeDropdown:SetPoint("TOPLEFT", frame.themeText, "BOTTOMLEFT", -15, -5)
        
        local themes = {
            {text = "Thunder Storm", value = "thunderstorm"}, -- Make Thunder Storm first/default
            {text = "Phoenix Flame", value = "phoenixflame"},
            {text = "Arcane Mystic", value = "arcanemystic"},
            {text = "Fel Energy", value = "felenergy"}
        }
        
        frame.themeDropdown.initialize = function(dropdown)
            local info = UIDropDownMenu_CreateInfo()
            
            for _, theme in ipairs(themes) do
                info.text = theme.text
                info.value = theme.value
                info.checked = VUI.db.profile.appearance.theme == theme.value
                info.func = function()
                    VUI.db.profile.appearance.theme = theme.value
                    UIDropDownMenu_SetText(dropdown, theme.text)
                    
                    -- Set colors based on the selected theme
                    if theme.value == "thunderstorm" then
                        -- Thunder Storm theme colors
                        VUI.db.profile.appearance.backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.8} -- Deep blue
                        VUI.db.profile.appearance.borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
                    elseif theme.value == "phoenixflame" then
                        -- Phoenix Flame theme colors
                        VUI.db.profile.appearance.backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.8} -- Dark red/brown
                        VUI.db.profile.appearance.borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
                    elseif theme.value == "arcanemystic" then
                        -- Arcane Mystic theme colors
                        VUI.db.profile.appearance.backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.8} -- Deep purple
                        VUI.db.profile.appearance.borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Bright violet
                    elseif theme.value == "felenergy" then
                        -- Fel Energy theme colors
                        VUI.db.profile.appearance.backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.8} -- Dark green
                        VUI.db.profile.appearance.borderColor = {r = 0.1, g = 1.0, b = 0.1, a = 1} -- Fel green
                    end
                    
                    VUI:ApplySettings()
                end
                UIDropDownMenu_AddButton(info)
            end
        end
        
        -- Set initial text
        for _, theme in ipairs(themes) do
            if theme.value == VUI.db.profile.appearance.theme then
                UIDropDownMenu_SetText(frame.themeDropdown, theme.text)
                break
            end
        end
        
        -- Font dropdown
        frame.fontText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.fontText:SetPoint("TOPLEFT", frame.themeDropdown, "BOTTOMLEFT", 15, -15)
        frame.fontText:SetText("Font:")
        
        frame.fontDropdown = CreateFrame("Frame", "VUIAppearanceFontDropdown", frame, "UIDropDownMenuTemplate")
        frame.fontDropdown:SetPoint("TOPLEFT", frame.fontText, "BOTTOMLEFT", -15, -5)
        
        local fonts = {
            {text = "Friz Quadrata TT", value = "Friz Quadrata TT"},
            {text = "Arial Narrow", value = "Arial Narrow"},
            {text = "Skurri", value = "Skurri"},
            {text = "Morpheus", value = "Morpheus"}
        }
        
        frame.fontDropdown.initialize = function(dropdown)
            local info = UIDropDownMenu_CreateInfo()
            
            for _, font in ipairs(fonts) do
                info.text = font.text
                info.value = font.value
                info.checked = VUI.db.profile.appearance.font == font.value
                info.func = function()
                    VUI.db.profile.appearance.font = font.value
                    UIDropDownMenu_SetText(dropdown, font.text)
                    VUI:ApplySettings()
                end
                UIDropDownMenu_AddButton(info)
            end
        end
        
        -- Set initial text
        for _, font in ipairs(fonts) do
            if font.value == VUI.db.profile.appearance.font then
                UIDropDownMenu_SetText(frame.fontDropdown, font.text)
                break
            end
        end
        
        -- Font size slider
        frame.fontSizeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.fontSizeText:SetPoint("TOPLEFT", frame.fontDropdown, "BOTTOMLEFT", 15, -15)
        frame.fontSizeText:SetText("Font Size:")
        
        frame.fontSizeSlider = CreateFrame("Slider", "VUIAppearanceFontSizeSlider", frame, "OptionsSliderTemplate")
        frame.fontSizeSlider:SetPoint("TOPLEFT", frame.fontSizeText, "BOTTOMLEFT", 0, -10)
        frame.fontSizeSlider:SetWidth(200)
        frame.fontSizeSlider:SetMinMaxValues(8, 24)
        frame.fontSizeSlider:SetValueStep(1)
        frame.fontSizeSlider:SetObeyStepOnDrag(true)
        _G[frame.fontSizeSlider:GetName().."Low"]:SetText("8")
        _G[frame.fontSizeSlider:GetName().."High"]:SetText("24")
        frame.fontSizeSlider:SetValue(self.db.profile.appearance.fontSize or 12)
        
        frame.fontSizeSlider:SetScript("OnValueChanged", function(self, value)
            VUI.db.profile.appearance.fontSize = value
            _G[self:GetName().."Text"]:SetText(format("%d", value))
            VUI:ApplySettings()
        end)
        
        -- Use class colors checkbox
        frame.classColorsCheckbox = CreateFrame("CheckButton", "VUIAppearanceClassColorsCheckbox", frame, "OptionsCheckButtonTemplate")
        frame.classColorsCheckbox:SetPoint("TOPLEFT", frame.fontSizeSlider, "BOTTOMLEFT", 0, -20)
        _G[frame.classColorsCheckbox:GetName().."Text"]:SetText("Use Class Colors")
        frame.classColorsCheckbox:SetChecked(self.db.profile.appearance.useClassColors)
        
        frame.classColorsCheckbox:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            VUI.db.profile.appearance.useClassColors = checked
            VUI:ApplySettings()
        end)
        
        -- Class colored borders checkbox
        frame.classColoredBordersCheckbox = CreateFrame("CheckButton", "VUIAppearanceClassColoredBordersCheckbox", frame, "OptionsCheckButtonTemplate")
        frame.classColoredBordersCheckbox:SetPoint("TOPLEFT", frame.classColorsCheckbox, "BOTTOMLEFT", 0, -5)
        _G[frame.classColoredBordersCheckbox:GetName().."Text"]:SetText("Class Colored Borders")
        frame.classColoredBordersCheckbox:SetChecked(self.db.profile.appearance.classColoredBorders)
        
        frame.classColoredBordersCheckbox:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            VUI.db.profile.appearance.classColoredBorders = checked
            VUI:ApplySettings()
        end)
        
        -- Store the frame
        self.configFrame.sections.Appearance = frame
    end
end

-- Create the Modules section
function VUI:CreateModulesSection()
    -- Create the section frame if it doesn't exist
    if not self.configFrame.sections.Modules then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText("Module Settings")
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.desc:SetText("Enable or disable VUI modules and configure their settings")
        
        -- Module selector dropdown
        frame.moduleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.moduleText:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -20)
        frame.moduleText:SetText("Select Module:")
        
        frame.moduleDropdown = CreateFrame("Frame", "VUIModulesDropdown", frame, "UIDropDownMenuTemplate")
        frame.moduleDropdown:SetPoint("TOPLEFT", frame.moduleText, "BOTTOMLEFT", -15, -5)
        
        local modules = {
            {text = "BuffOverlay", value = "buffoverlay"},
            {text = "TrufiGCD", value = "trufigcd"},
            {text = "MoveAny", value = "moveany"},
            {text = "Auctionator", value = "auctionator"},
            {text = "Angry Keystones", value = "angrykeystone"},
            {text = "OmniCC", value = "omnicc"},
            {text = "OmniCD", value = "omnicd"},
            {text = "idTip", value = "idtip"},
            {text = "MultiNotification", value = "multinotification"},
            {text = "Details Skin", value = "detailsskin"},
            {text = "MSBT", value = "msbt"},
            {text = "Premade Group Finder", value = "premadegroupfinder"}
        }
        
        frame.moduleDropdown.initialize = function(dropdown)
            local info = UIDropDownMenu_CreateInfo()
            
            for _, module in ipairs(modules) do
                info.text = module.text
                info.value = module.value
                info.checked = (VUI.selectedModule or "buffoverlay") == module.value
                info.func = function()
                    VUI.selectedModule = module.value
                    UIDropDownMenu_SetText(dropdown, module.text)
                    VUI:ShowModuleConfig(frame)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
        
        -- Set initial module and text
        VUI.selectedModule = "buffoverlay"
        UIDropDownMenu_SetText(frame.moduleDropdown, "BuffOverlay")
        
        -- Create module content area
        frame.moduleContent = CreateFrame("Frame", "VUIModuleContent", frame)
        frame.moduleContent:SetSize(frame:GetWidth() - 40, frame:GetHeight() - 150)
        frame.moduleContent:SetPoint("TOPLEFT", frame.moduleDropdown, "BOTTOMLEFT", 15, -15)
        
        -- Add background
        frame.moduleContent:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Store the frame
        self.configFrame.sections.Modules = frame
        
        -- Show the default module config
        self:ShowModuleConfig(frame)
    end
end

-- Show the configuration for a specific module
function VUI:ShowModuleConfig(frame)
    if not frame then frame = self.configFrame.sections.Modules end
    if not frame or not frame.moduleContent then return end
    
    -- Clear the module content
    for _, child in pairs({frame.moduleContent:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local moduleName = VUI.selectedModule
    if not moduleName then return end
    
    -- Module-specific elements (example for BuffOverlay)
    local module = self[moduleName:gsub("^%l", string.upper)]
    
    if not module then 
        -- Create placeholder text for module that doesn't exist
        local text = frame.moduleContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Module configuration is not available")
        return
    end
    
    -- Create enable checkbox
    local enableCheckbox = CreateFrame("CheckButton", "VUI"..moduleName.."EnableCheckbox", frame.moduleContent, "OptionsCheckButtonTemplate")
    enableCheckbox:SetPoint("TOPLEFT", 20, -20)
    _G[enableCheckbox:GetName().."Text"]:SetText("Enable " .. moduleName:gsub("^%l", string.upper))
    
    -- Check if module is enabled
    local isEnabled = false
    if self.db.profile.modules and self.db.profile.modules[moduleName] then
        isEnabled = self.db.profile.modules[moduleName].enabled
    end
    
    enableCheckbox:SetChecked(isEnabled)
    
    enableCheckbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        
        -- Ensure the module profile exists
        if not VUI.db.profile.modules then VUI.db.profile.modules = {} end
        if not VUI.db.profile.modules[moduleName] then VUI.db.profile.modules[moduleName] = {} end
        
        VUI.db.profile.modules[moduleName].enabled = checked
        
        -- Enable or disable the module
        if checked then
            if module.Enable then module:Enable() end
        else
            if module.Disable then module:Disable() end
        end
    end)
    
    -- Add module-specific config options
    if isEnabled and module.CreateConfigOptions then
        module:CreateConfigOptions(frame.moduleContent)
    end
end

-- Create the Profiles section
function VUI:CreateProfilesSection()
    -- Create the section frame if it doesn't exist
    if not self.configFrame.sections.Profiles then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText("Profile Settings")
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.desc:SetText("Manage your VUI configuration profiles")
        
        -- Make sure profile options are added first
        if not self.options.args.profiles then
            self:SetupProfileOptions()
        end
        
        -- Create a container for the AceConfig profile options
        frame.profilesContainer = CreateFrame("Frame", "VUIProfilesContainer", frame)
        frame.profilesContainer:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -20)
        frame.profilesContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
        
        -- Use AceConfigDialog to render the profile options
        AceConfigDialog:Open("VUI", frame.profilesContainer, "profiles")
        
        -- Store the frame
        self.configFrame.sections.Profiles = frame
    end
end

-- Create the About section
function VUI:CreateAboutSection()
    -- Create the section frame if it doesn't exist
    if not self.configFrame.sections.About then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText("About VUI")
        
        -- Logo
        frame.logo = frame:CreateTexture(nil, "ARTWORK")
        frame.logo:SetSize(64, 64)
        frame.logo:SetPoint("TOPRIGHT", -20, -20)
        frame.logo:SetTexture("Interface\\Addons\\VUI\\media\\textures\\common\\logo.tga")
        
        -- Version
        frame.version = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.version:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.version:SetText("Version: " .. self.version)
        
        -- Author
        frame.author = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.author:SetPoint("TOPLEFT", frame.version, "BOTTOMLEFT", 0, -5)
        frame.author:SetText("Author: " .. self.author)
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.author, "BOTTOMLEFT", 0, -20)
        frame.desc:SetWidth(frame:GetWidth() - 40)
        frame.desc:SetText("VUI is a unified World of Warcraft addon suite that combines multiple popular addons into a single, cohesive package with centralized configuration.")
        
        -- Modules
        frame.modulesTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.modulesTitle:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -20)
        frame.modulesTitle:SetText("Integrated Modules")
        
        -- Module list
        local moduleList = {
            "• BuffOverlay - Display important buffs and debuffs",
            "• TrufiGCD - Track recently used abilities",
            "• MoveAny - Repositioning of UI elements",
            "• Auctionator - Auction house enhancements",
            "• Angry Keystones - Mythic+ dungeon improvements",
            "• OmniCC - Cooldown count on all buttons",
            "• OmniCD - Party cooldown tracking",
            "• idTip - Display spell, item, quest IDs in tooltips",
            "• MultiNotification - Enhanced notification system",
            "• Details Skin - Customized appearance for Details damage meter",
            "• MSBT - MikScrollingBattleText integration",
            "• Premade Group Finder - LFG interface enhancements"
        }
        
        for i, moduleText in ipairs(moduleList) do
            local module = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            module:SetPoint("TOPLEFT", i == 1 and frame.modulesTitle or frame["module"..(i-1)], i == 1 and "BOTTOMLEFT" or "BOTTOMLEFT", 0, -5)
            module:SetText(moduleText)
            frame["module"..i] = module
        end
        
        -- Credits
        frame.creditsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.creditsTitle:SetPoint("TOPLEFT", frame["module"..#moduleList], "BOTTOMLEFT", 0, -20)
        frame.creditsTitle:SetText("Credits")
        
        frame.credits = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.credits:SetPoint("TOPLEFT", frame.creditsTitle, "BOTTOMLEFT", 0, -10)
        frame.credits:SetWidth(frame:GetWidth() - 40)
        frame.credits:SetText("VUI integrates code from several open-source addons. Special thanks to all the original addon authors for their contributions to the World of Warcraft addon community.")
        
        -- Store the frame
        self.configFrame.sections.About = frame
    end
end

-- Function to apply the current settings to all modules
function VUI:ApplySettings()
    -- Apply general settings
    local scale = self.db.profile.general.scale
    
    -- Update appearance
    self:UpdateAppearance()
    
    -- Update all enabled modules with their settings
    for moduleName, _ in pairs(self.enabledModules) do
        local module = self[moduleName]
        if module and module.UpdateSettings then
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
    local border = appearance.classColoredBorders and RAID_CLASS_COLORS[select(2, UnitClass("player"))] or appearance.borderColor
    
    -- Update all frames with the new appearance
    for _, frame in pairs(self.frames or {}) do
        if frame.UpdateAppearance then
            frame:UpdateAppearance(appearance)
        end
    end
    
    -- Update config frame if it exists
    if self.configFrame then
        self.configFrame:SetScale(self.db.profile.general.scale or 1.0)
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

-- Get a list of available fonts
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

-- Function to check if a module is enabled
function VUI:IsModuleEnabled(moduleName)
    if not self.db.profile.modules then return false end
    if not self.db.profile.modules[moduleName:lower()] then return false end
    
    return self.db.profile.modules[moduleName:lower()].enabled
end

-- Function to enable a module
function VUI:EnableModule(moduleName)
    if not self.db.profile.modules then self.db.profile.modules = {} end
    if not self.db.profile.modules[moduleName:lower()] then self.db.profile.modules[moduleName:lower()] = {} end
    
    self.db.profile.modules[moduleName:lower()].enabled = true
    
    -- Enable the module functionality
    local module = self[moduleName:gsub("^%l", string.upper)]
    if module and module.Enable then
        module:Enable()
    end
    
    -- Update enabled modules tracking
    self.enabledModules[moduleName:gsub("^%l", string.upper)] = true
    
    -- Notify
    self:Print(moduleName:gsub("^%l", string.upper) .. " module enabled")
end

-- Function to disable a module
function VUI:DisableModule(moduleName)
    if not self.db.profile.modules then self.db.profile.modules = {} end
    if not self.db.profile.modules[moduleName:lower()] then self.db.profile.modules[moduleName:lower()] = {} end
    
    self.db.profile.modules[moduleName:lower()].enabled = false
    
    -- Disable the module functionality
    local module = self[moduleName:gsub("^%l", string.upper)]
    if module and module.Disable then
        module:Disable()
    end
    
    -- Update enabled modules tracking
    self.enabledModules[moduleName:gsub("^%l", string.upper)] = false
    
    -- Notify
    self:Print(moduleName:gsub("^%l", string.upper) .. " module disabled")
end

-- Initialize configuration
function VUI:InitializeConfig()
    -- Create the slash command
    SLASH_VUI1 = "/vui"
    SlashCmdList["VUI"] = function(msg)
        self:CreateConfigPanel()
    end
    
    -- Ensure appearance defaults exist
    if not self.db.profile.appearance then self.db.profile.appearance = {} end
    if not self.db.profile.appearance.backdropColor then self.db.profile.appearance.backdropColor = {r=0.1, g=0.1, b=0.1, a=0.8} end
    if not self.db.profile.appearance.borderColor then self.db.profile.appearance.borderColor = {r=0.4, g=0.4, b=0.4, a=1} end
    
    -- Set up minimap icon using LibDBIcon if available
    if LibStub and LibStub("LibDBIcon-1.0", true) then
        self.LDBIcon = LibStub("LibDBIcon-1.0")
        
        -- Ensure minimap settings exist
        if not self.db.profile.general then self.db.profile.general = {} end
        if not self.db.profile.general.minimap then self.db.profile.general.minimap = {hide = false} end
        
        -- Create LibDataBroker object
        local LDB = LibStub("LibDataBroker-1.1", true)
        if LDB then
            local launcher = LDB:NewDataObject("VUI", {
                type = "launcher",
                text = "VUI",
                icon = "Interface\\Addons\\VUI\\media\\textures\\common\\logo.tga",
                OnClick = function(_, button)
                    if button == "LeftButton" then
                        self:CreateConfigPanel()
                    end
                end,
                OnTooltipShow = function(tooltip)
                    tooltip:AddLine("VUI")
                    tooltip:AddLine("Click to open configuration", 1, 1, 1)
                end,
            })
            
            -- Register with LibDBIcon
            self.LDBIcon:Register("VUI", launcher, self.db.profile.general.minimap)
        end
    end
end
