-------------------------------------------------------------------------------
-- Title: VUI Config - Scrolling Text Module
-- Author: VortexQ8
-------------------------------------------------------------------------------

local addonName, VUI = ...
if not VUI then return end

local module = VUI:GetModule("VUIScrollingText")
if not module then return end

local L = LibStub("AceLocale-3.0"):GetLocale("VUI", false)

-- Register VUIScrollingText in the main config
local function SetupScrollingTextConfig()
    local config = {
        order = 9,
        type = "group",
        name = "Scrolling Text",
        desc = "Configure VUIScrollingText module",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable Module",
                desc = "Enable or disable the scrolling text module",
                width = "full",
                get = function() return VUI.db.profile.modules.VUIScrollingText.enabled end,
                set = function(info, value)
                    VUI.db.profile.modules.VUIScrollingText.enabled = value
                    if value then
                        module:Enable()
                    else
                        module:Disable()
                    end
                end,
            },
            general = {
                order = 2,
                type = "group",
                name = "General Settings",
                desc = "Configure general settings for VUIScrollingText",
                guiInline = true,
                disabled = function() return not VUI.db.profile.modules.VUIScrollingText.enabled end,
                args = {
                    useThemeColor = {
                        order = 1,
                        type = "toggle",
                        name = "Use Theme Color",
                        desc = "Apply VUI theme color to VUIScrollingText elements",
                        width = "full",
                        get = function() return VUI.db.profile.modules.VUIScrollingText.useThemeColor end,
                        set = function(info, value)
                            VUI.db.profile.modules.VUIScrollingText.useThemeColor = value
                            if module.ApplyTheme then module:ApplyTheme() end
                        end,
                    },
                    animationSpeed = {
                        order = 2,
                        type = "range",
                        name = "Animation Speed",
                        desc = "Adjust the speed of animations",
                        min = 0.5,
                        max = 2,
                        step = 0.1,
                        get = function() return VUI.db.profile.modules.VUIScrollingText.animationSpeed end,
                        set = function(info, value)
                            VUI.db.profile.modules.VUIScrollingText.animationSpeed = value
                            if VUI.ScrollingText then 
                                VUI.ScrollingText.animationSpeed = value
                            end
                        end,
                    },
                    config = {
                        order = 3,
                        type = "execute",
                        name = "Advanced Configuration",
                        desc = "Open the VUIScrollingText configuration panel",
                        func = function()
                            if module.ShowOptions then 
                                module:ShowOptions()
                            end
                        end,
                    }
                },
            },
            features = {
                order = 3,
                type = "group",
                name = "Features",
                desc = "Configure VUIScrollingText features",
                guiInline = true,
                disabled = function() return not VUI.db.profile.modules.VUIScrollingText.enabled end,
                args = {
                    enableLoot = {
                        order = 1,
                        type = "toggle",
                        name = "Loot Messages",
                        desc = "Show scrolling text for loot and money gained",
                        width = "full",
                        get = function() return VUI.db.profile.modules.VUIScrollingText.enableLoot end,
                        set = function(info, value)
                            VUI.db.profile.modules.VUIScrollingText.enableLoot = value
                            if VUI.ScrollingText and VUI.ScrollingText.Loot then
                                if value then
                                    VUI.ScrollingText.Loot.EnableLoot()
                                else
                                    VUI.ScrollingText.Loot.DisableLoot()
                                end
                            end
                        end,
                    },
                    enableCooldowns = {
                        order = 2,
                        type = "toggle",
                        name = "Cooldown Notifications",
                        desc = "Show scrolling text for ability cooldowns",
                        width = "full",
                        get = function() return VUI.db.profile.modules.VUIScrollingText.enableCooldowns end,
                        set = function(info, value)
                            VUI.db.profile.modules.VUIScrollingText.enableCooldowns = value
                            if VUI.ScrollingText and VUI.ScrollingText.Cooldowns then
                                if value then
                                    VUI.ScrollingText.Cooldowns.EnableCooldowns()
                                else
                                    VUI.ScrollingText.Cooldowns.DisableCooldowns()
                                end
                            end
                        end,
                    },
                    enableTriggers = {
                        order = 3,
                        type = "toggle",
                        name = "Event Triggers",
                        desc = "Enable or disable event trigger notifications",
                        width = "full",
                        get = function() return VUI.db.profile.modules.VUIScrollingText.enableTriggers end,
                        set = function(info, value)
                            VUI.db.profile.modules.VUIScrollingText.enableTriggers = value
                            if VUI.ScrollingText and VUI.ScrollingText.Triggers then
                                VUI.ScrollingText.Triggers.SetMasterEnable(value)
                            end
                        end,
                    },
                    enableSounds = {
                        order = 4,
                        type = "toggle",
                        name = "Sound Effects",
                        desc = "Play sounds with notifications",
                        width = "full",
                        get = function() return VUI.db.profile.modules.VUIScrollingText.enableSounds end,
                        set = function(info, value)
                            VUI.db.profile.modules.VUIScrollingText.enableSounds = value
                            if VUI.ScrollingText then
                                VUI.ScrollingText.soundsEnabled = value
                            end
                        end,
                    },
                },
            },
        },
    }
    
    VUI.Config:RegisterModuleConfig("VUIScrollingText", config)
end

-- Default settings for the module
local defaults = {
    profile = {
        modules = {
            VUIScrollingText = {
                enabled = true,
                useThemeColor = true,
                animationSpeed = 1,
                enableLoot = true,
                enableCooldowns = true,
                enableTriggers = true,
                enableSounds = true,
            },
        },
    },
}

-- Initialize the module
VUI:RegisterDefaults(defaults)
VUI:RegisterModuleConfigLoader("VUIScrollingText", SetupScrollingTextConfig)