--[[
    VUI - Castbar Configuration
    Version: 0.0.1
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Castbar = VUI.Castbar
local L = VUI.Localization

-- Setup castbar configuration panel
function Castbar:SetupConfig()
    local configPanel = VUI.ConfigPanel
    
    -- Register module configuration
    configPanel:RegisterModule({
        name = "castbar",
        displayName = L["Castbar"],
        description = L["Customize castbars for spells and abilities"],
        icon = [[Interface\Icons\Spell_Nature_FaerieFire]],
        childGroups = "tab"
    })
    
    -- General settings
    configPanel:RegisterGroup("castbar", {
        name = "general",
        displayName = L["General"],
        type = "group",
        order = 1,
        args = {
            header1 = {
                name = L["Castbar Module"],
                type = "header",
                order = 1
            },
            enabled = {
                name = L["Enable Castbar Module"],
                desc = L["Enable or disable the castbar module"],
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return Castbar.settings.enabled end,
                set = function(_, value)
                    Castbar.settings.enabled = value
                    VUI:ReloadUI()
                end
            },
            animationsHeader = {
                name = L["Animation Settings"],
                type = "header",
                order = 3
            },
            enableAnimations = {
                name = L["Enable Animations"],
                desc = L["Enable or disable castbar animations"],
                type = "toggle",
                width = "full",
                order = 4,
                get = function() return Castbar.settings.animations.enabled end,
                set = function(_, value)
                    Castbar.settings.animations.enabled = value
                    VUI:ReloadUI()
                end
            },
            themeIntegration = {
                name = L["Theme Integration"],
                desc = L["Enable theme-specific animations and effects for castbars"],
                type = "toggle",
                width = "full",
                order = 5,
                get = function() return Castbar.settings.animations.themeIntegration end,
                set = function(_, value)
                    Castbar.settings.animations.themeIntegration = value
                    VUI:ReloadUI()
                end
            },
            castStartAnimation = {
                name = L["Cast Start Animation"],
                desc = L["Show animation when a cast begins"],
                type = "toggle",
                width = "full",
                order = 6,
                disabled = function() return not Castbar.settings.animations.enabled end,
                get = function() return Castbar.settings.animations.castStart end,
                set = function(_, value)
                    Castbar.settings.animations.castStart = value
                end
            },
            castCompleteAnimation = {
                name = L["Cast Complete Animation"],
                desc = L["Show animation when a cast completes successfully"],
                type = "toggle",
                width = "full",
                order = 7,
                disabled = function() return not Castbar.settings.animations.enabled end,
                get = function() return Castbar.settings.animations.castComplete end,
                set = function(_, value)
                    Castbar.settings.animations.castComplete = value
                end
            },
            castFailAnimation = {
                name = L["Cast Fail Animation"],
                desc = L["Show animation when a cast fails or is interrupted"],
                type = "toggle",
                width = "full",
                order = 8,
                disabled = function() return not Castbar.settings.animations.enabled end,
                get = function() return Castbar.settings.animations.castFail end,
                set = function(_, value)
                    Castbar.settings.animations.castFail = value
                end
            },
            iconPulseAnimation = {
                name = L["Icon Pulse Animation"],
                desc = L["Enable icon pulse animations"],
                type = "toggle",
                width = "full",
                order = 9,
                disabled = function() return not Castbar.settings.animations.enabled end,
                get = function() return Castbar.settings.animations.iconPulse end,
                set = function(_, value)
                    Castbar.settings.animations.iconPulse = value
                end
            },
            textPulseAnimation = {
                name = L["Text Pulse Animation"],
                desc = L["Enable text pulse animations"],
                type = "toggle",
                width = "full",
                order = 10,
                disabled = function() return not Castbar.settings.animations.enabled end,
                get = function() return Castbar.settings.animations.textPulse end,
                set = function(_, value)
                    Castbar.settings.animations.textPulse = value
                end
            },
            barPulseAnimation = {
                name = L["Bar Pulse Animation"],
                desc = L["Enable bar pulse animations for important casts"],
                type = "toggle",
                width = "full",
                order = 11,
                disabled = function() return not Castbar.settings.animations.enabled end,
                get = function() return Castbar.settings.animations.barPulse end,
                set = function(_, value)
                    Castbar.settings.animations.barPulse = value
                end
            }
        }
    })
    
    -- Player castbar settings
    configPanel:RegisterGroup("castbar", {
        name = "playerCastbar",
        displayName = L["Player Castbar"],
        type = "group",
        order = 2,
        args = {
            header1 = {
                name = L["Player Castbar Settings"],
                type = "header",
                order = 1
            },
            enabled = {
                name = L["Enable Player Castbar"],
                desc = L["Show the castbar for your character"],
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return Castbar.settings.units.player.enabled end,
                set = function(_, value)
                    Castbar.settings.units.player.enabled = value
                    VUI:ReloadUI()
                end
            },
            width = {
                name = L["Width"],
                desc = L["Set the width of the player castbar"],
                type = "range",
                min = 100,
                max = 500,
                step = 1,
                order = 3,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.width end,
                set = function(_, value)
                    Castbar.settings.units.player.width = value
                    VUI:ReloadUI()
                end
            },
            height = {
                name = L["Height"],
                desc = L["Set the height of the player castbar"],
                type = "range",
                min = 10,
                max = 50,
                step = 1,
                order = 4,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.height end,
                set = function(_, value)
                    Castbar.settings.units.player.height = value
                    VUI:ReloadUI()
                end
            },
            scale = {
                name = L["Scale"],
                desc = L["Set the scale of the player castbar"],
                type = "range",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                order = 5,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.scale end,
                set = function(_, value)
                    Castbar.settings.units.player.scale = value
                    VUI:ReloadUI()
                end
            },
            showIcon = {
                name = L["Show Spell Icon"],
                desc = L["Show the spell icon next to the castbar"],
                type = "toggle",
                width = "full",
                order = 6,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.showIcon end,
                set = function(_, value)
                    Castbar.settings.units.player.showIcon = value
                    VUI:ReloadUI()
                end
            },
            showLatency = {
                name = L["Show Latency"],
                desc = L["Show your network latency on the castbar"],
                type = "toggle",
                width = "full",
                order = 7,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.showLatency end,
                set = function(_, value)
                    Castbar.settings.units.player.showLatency = value
                    VUI:ReloadUI()
                end
            },
            showTimer = {
                name = L["Show Timer"],
                desc = L["Show the cast time remaining on the castbar"],
                type = "toggle",
                width = "full",
                order = 8,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.showTimer end,
                set = function(_, value)
                    Castbar.settings.units.player.showTimer = value
                    VUI:ReloadUI()
                end
            },
            showTargetName = {
                name = L["Show Target Name"],
                desc = L["Show the name of your target when casting targeted spells"],
                type = "toggle",
                width = "full",
                order = 9,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.showTargetName end,
                set = function(_, value)
                    Castbar.settings.units.player.showTargetName = value
                    VUI:ReloadUI()
                end
            },
            showCompletionText = {
                name = L["Show Completion Text"],
                desc = L["Show cast time when cast completes"],
                type = "toggle",
                width = "full",
                order = 10,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.showCompletionText end,
                set = function(_, value)
                    Castbar.settings.units.player.showCompletionText = value
                    VUI:ReloadUI()
                end
            },
            attachToPlayerFrame = {
                name = L["Attach to Player Frame"],
                desc = L["Attach the castbar to the player unit frame"],
                type = "toggle",
                width = "full",
                order = 11,
                disabled = function() return not Castbar.settings.units.player.enabled end,
                get = function() return Castbar.settings.units.player.attachToPlayerFrame end,
                set = function(_, value)
                    Castbar.settings.units.player.attachToPlayerFrame = value
                    VUI:ReloadUI()
                end
            }
        }
    })
    
    -- Target castbar settings
    configPanel:RegisterGroup("castbar", {
        name = "targetCastbar",
        displayName = L["Target Castbar"],
        type = "group",
        order = 3,
        args = {
            header1 = {
                name = L["Target Castbar Settings"],
                type = "header",
                order = 1
            },
            enabled = {
                name = L["Enable Target Castbar"],
                desc = L["Show the castbar for your target"],
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return Castbar.settings.units.target.enabled end,
                set = function(_, value)
                    Castbar.settings.units.target.enabled = value
                    VUI:ReloadUI()
                end
            },
            width = {
                name = L["Width"],
                desc = L["Set the width of the target castbar"],
                type = "range",
                min = 100,
                max = 500,
                step = 1,
                order = 3,
                disabled = function() return not Castbar.settings.units.target.enabled end,
                get = function() return Castbar.settings.units.target.width end,
                set = function(_, value)
                    Castbar.settings.units.target.width = value
                    VUI:ReloadUI()
                end
            },
            height = {
                name = L["Height"],
                desc = L["Set the height of the target castbar"],
                type = "range",
                min = 10,
                max = 50,
                step = 1,
                order = 4,
                disabled = function() return not Castbar.settings.units.target.enabled end,
                get = function() return Castbar.settings.units.target.height end,
                set = function(_, value)
                    Castbar.settings.units.target.height = value
                    VUI:ReloadUI()
                end
            },
            scale = {
                name = L["Scale"],
                desc = L["Set the scale of the target castbar"],
                type = "range",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                order = 5,
                disabled = function() return not Castbar.settings.units.target.enabled end,
                get = function() return Castbar.settings.units.target.scale end,
                set = function(_, value)
                    Castbar.settings.units.target.scale = value
                    VUI:ReloadUI()
                end
            },
            showIcon = {
                name = L["Show Spell Icon"],
                desc = L["Show the spell icon next to the castbar"],
                type = "toggle",
                width = "full",
                order = 6,
                disabled = function() return not Castbar.settings.units.target.enabled end,
                get = function() return Castbar.settings.units.target.showIcon end,
                set = function(_, value)
                    Castbar.settings.units.target.showIcon = value
                    VUI:ReloadUI()
                end
            },
            showTimer = {
                name = L["Show Timer"],
                desc = L["Show the cast time remaining on the castbar"],
                type = "toggle",
                width = "full",
                order = 7,
                disabled = function() return not Castbar.settings.units.target.enabled end,
                get = function() return Castbar.settings.units.target.showTimer end,
                set = function(_, value)
                    Castbar.settings.units.target.showTimer = value
                    VUI:ReloadUI()
                end
            }
        }
    })
    
    -- Focus castbar settings
    configPanel:RegisterGroup("castbar", {
        name = "focusCastbar",
        displayName = L["Focus Castbar"],
        type = "group",
        order = 4,
        args = {
            header1 = {
                name = L["Focus Castbar Settings"],
                type = "header",
                order = 1
            },
            enabled = {
                name = L["Enable Focus Castbar"],
                desc = L["Show the castbar for your focus target"],
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return Castbar.settings.units.focus.enabled end,
                set = function(_, value)
                    Castbar.settings.units.focus.enabled = value
                    VUI:ReloadUI()
                end
            },
            width = {
                name = L["Width"],
                desc = L["Set the width of the focus castbar"],
                type = "range",
                min = 100,
                max = 500,
                step = 1,
                order = 3,
                disabled = function() return not Castbar.settings.units.focus.enabled end,
                get = function() return Castbar.settings.units.focus.width end,
                set = function(_, value)
                    Castbar.settings.units.focus.width = value
                    VUI:ReloadUI()
                end
            },
            height = {
                name = L["Height"],
                desc = L["Set the height of the focus castbar"],
                type = "range",
                min = 10,
                max = 50,
                step = 1,
                order = 4,
                disabled = function() return not Castbar.settings.units.focus.enabled end,
                get = function() return Castbar.settings.units.focus.height end,
                set = function(_, value)
                    Castbar.settings.units.focus.height = value
                    VUI:ReloadUI()
                end
            },
            scale = {
                name = L["Scale"],
                desc = L["Set the scale of the focus castbar"],
                type = "range",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                order = 5,
                disabled = function() return not Castbar.settings.units.focus.enabled end,
                get = function() return Castbar.settings.units.focus.scale end,
                set = function(_, value)
                    Castbar.settings.units.focus.scale = value
                    VUI:ReloadUI()
                end
            },
            showIcon = {
                name = L["Show Spell Icon"],
                desc = L["Show the spell icon next to the castbar"],
                type = "toggle",
                width = "full",
                order = 6,
                disabled = function() return not Castbar.settings.units.focus.enabled end,
                get = function() return Castbar.settings.units.focus.showIcon end,
                set = function(_, value)
                    Castbar.settings.units.focus.showIcon = value
                    VUI:ReloadUI()
                end
            },
            showTimer = {
                name = L["Show Timer"],
                desc = L["Show the cast time remaining on the castbar"],
                type = "toggle",
                width = "full",
                order = 7,
                disabled = function() return not Castbar.settings.units.focus.enabled end,
                get = function() return Castbar.settings.units.focus.showTimer end,
                set = function(_, value)
                    Castbar.settings.units.focus.showTimer = value
                    VUI:ReloadUI()
                end
            }
        }
    })
    
    -- Colors settings
    configPanel:RegisterGroup("castbar", {
        name = "colors",
        displayName = L["Colors"],
        type = "group",
        order = 5,
        args = {
            header1 = {
                name = L["Castbar Colors"],
                type = "header",
                order = 1
            },
            standardColor = {
                name = L["Standard Cast"],
                desc = L["Color for normal spell casts"],
                type = "color",
                hasAlpha = true,
                order = 2,
                get = function()
                    local color = Castbar.settings.colors.standard
                    return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                    Castbar.settings.colors.standard.r = r
                    Castbar.settings.colors.standard.g = g
                    Castbar.settings.colors.standard.b = b
                    Castbar.settings.colors.standard.a = a
                end
            },
            channelingColor = {
                name = L["Channeled Cast"],
                desc = L["Color for channeled spell casts"],
                type = "color",
                hasAlpha = true,
                order = 3,
                get = function()
                    local color = Castbar.settings.colors.channeling
                    return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                    Castbar.settings.colors.channeling.r = r
                    Castbar.settings.colors.channeling.g = g
                    Castbar.settings.colors.channeling.b = b
                    Castbar.settings.colors.channeling.a = a
                end
            },
            uninterruptibleColor = {
                name = L["Uninterruptible Cast"],
                desc = L["Color for casts that cannot be interrupted"],
                type = "color",
                hasAlpha = true,
                order = 4,
                get = function()
                    local color = Castbar.settings.colors.uninterruptible
                    return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                    Castbar.settings.colors.uninterruptible.r = r
                    Castbar.settings.colors.uninterruptible.g = g
                    Castbar.settings.colors.uninterruptible.b = b
                    Castbar.settings.colors.uninterruptible.a = a
                end
            },
            successColor = {
                name = L["Successful Cast"],
                desc = L["Color for successful spell casts"],
                type = "color",
                hasAlpha = true,
                order = 5,
                get = function()
                    local color = Castbar.settings.colors.success
                    return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                    Castbar.settings.colors.success.r = r
                    Castbar.settings.colors.success.g = g
                    Castbar.settings.colors.success.b = b
                    Castbar.settings.colors.success.a = a
                end
            },
            failedColor = {
                name = L["Failed Cast"],
                desc = L["Color for failed or interrupted spell casts"],
                type = "color",
                hasAlpha = true,
                order = 6,
                get = function()
                    local color = Castbar.settings.colors.failed
                    return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                    Castbar.settings.colors.failed.r = r
                    Castbar.settings.colors.failed.g = g
                    Castbar.settings.colors.failed.b = b
                    Castbar.settings.colors.failed.a = a
                end
            },
            themeNote = {
                name = L["Note: Theme-specific colors will override these settings when Theme Integration is enabled."],
                type = "description",
                fontSize = "medium",
                order = 7
            }
        }
    })
end