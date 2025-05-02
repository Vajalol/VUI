--[[
    VUI - OmniCD Priority System Configuration
    Version: 0.3.0
    Author: VortexQ8
    
    This file implements the configuration UI for OmniCD's priority system:
    - Category management for cooldown types
    - Visual customization for priority levels
    - Spell priority customization
    - Integration with the main OmniCD config panel
]]

local _, VUI = ...
local OmniCD = VUI.omnicd
local PS = OmniCD.PrioritySystem
local L = VUI.L or {}  -- Localization

-- Create namespace for priority config
OmniCD.PriorityConfig = {}
local PC = OmniCD.PriorityConfig

-- Helper functions
local function GetColorPickerValues(color)
    return color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1
end

-- Initialize the config UI
function PC:Initialize()
    -- Hook into the main config
    self:HookMainConfig()
end

-- Hook into the main OmniCD configuration
function PC:HookMainConfig()
    -- Store original GetOptions function
    local originalGetOptions = OmniCD.GetOptions
    
    -- Replace with enhanced version
    OmniCD.GetOptions = function(self)
        -- Get original options
        local options = originalGetOptions(self)
        
        -- Add priority system tab
        options.args.prioritySystem = {
            type = "group",
            name = "Priority System",
            desc = "Configure the cooldown priority system",
            order = 50,
            args = PC:GetPriorityOptions()
        }
        
        return options
    end
end

-- Get priority system configuration options
function PC:GetPriorityOptions()
    local options = {
        header = {
            type = "header",
            name = "Cooldown Priority System",
            order = 1,
        },
        description = {
            type = "description",
            name = "The priority system classifies cooldowns into categories with visual distinctions and custom priorities.",
            order = 2,
            fontSize = "medium",
        },
        enabled = {
            type = "toggle",
            name = "Enable Priority System",
            desc = "Enable or disable the cooldown priority system",
            width = "full",
            order = 3,
            get = function() return PS.db.enabled end,
            set = function(_, value)
                PS.db.enabled = value
                OmniCD:UpdateCooldownDisplay()
            end,
        },
        visualGroup = {
            type = "group",
            name = "Visual Enhancement",
            order = 10,
            inline = true,
            args = {
                visualEnhancements = {
                    type = "toggle",
                    name = "Enable Visual Enhancements",
                    desc = "Apply visual styles based on cooldown category and importance",
                    width = "full",
                    order = 1,
                    get = function() return PS.db.visualEnhancements end,
                    set = function(_, value)
                        PS.db.visualEnhancements = value
                        OmniCD:UpdateCooldownDisplay()
                    end,
                },
                showGlows = {
                    type = "toggle",
                    name = "Show Glow Effects",
                    desc = "Enable glow effects for high-priority cooldowns",
                    width = "full",
                    order = 2,
                    get = function() return PS.db.showGlows end,
                    set = function(_, value)
                        PS.db.showGlows = value
                        OmniCD:UpdateCooldownDisplay()
                    end,
                },
                scalePriorities = {
                    type = "toggle",
                    name = "Scale By Priority",
                    desc = "Show higher priority cooldowns at a larger size",
                    width = "full",
                    order = 3,
                    get = function() return PS.db.scalePriorities end,
                    set = function(_, value)
                        PS.db.scalePriorities = value
                        OmniCD:UpdateCooldownDisplay()
                    end,
                },
            },
        },
        categoriesGroup = {
            type = "group",
            name = "Cooldown Categories",
            order = 20,
            inline = true,
            args = self:GetCategoryOptions(),
        },
        priorityHelp = {
            type = "description",
            name = "\nThe priority system organizes cooldowns into functional categories (defensive, offensive, etc.) and importance levels.\nCooldowns with higher priority appear first in the display.\n",
            order = 30,
            fontSize = "medium",
        },
        previewButton = {
            type = "execute",
            name = "Reset All to Defaults",
            desc = "Reset all priority settings to default values",
            order = 40,
            func = function()
                -- Reset custom priorities
                PS.db.customPriorities = {}
                
                -- Reset category settings
                PS.db.categories = {
                    defensive = true,
                    external = true, 
                    interrupt = true,
                    cc = true,
                    offensive = true,
                    movement = true,
                    utility = true,
                    standard = true
                }
                
                -- Enable all visual settings
                PS.db.visualEnhancements = true
                PS.db.showGlows = true
                PS.db.scalePriorities = true
                
                -- Update the display
                PS:UpdateSpellPriorities()
                OmniCD:UpdateCooldownDisplay()
            end,
        },
    }
    
    return options
end

-- Get options for each category
function PC:GetCategoryOptions()
    local options = {}
    local order = 1
    
    for catName, catData in pairs(PS.CATEGORIES) do
        local id = catData.id
        options[id] = {
            type = "toggle",
            name = catData.name,
            desc = catData.description,
            width = 1.5,
            order = order,
            get = function() return PS.db.categories[id] end,
            set = function(_, value)
                PS.db.categories[id] = value
                OmniCD:UpdateCooldownDisplay()
            end,
        }
        
        -- Add color picker
        options[id .. "_color"] = {
            type = "color",
            name = "",
            desc = "Set border color for " .. catData.name .. " cooldowns",
            width = 0.5,
            order = order + 1,
            get = function() 
                return GetColorPickerValues(catData.color)
            end,
            set = function(_, r, g, b, a)
                catData.color[1] = r
                catData.color[2] = g
                catData.color[3] = b
                catData.color[4] = a
                
                -- Update the glow color to match
                if catData.glowEnabled then
                    catData.glowColor[1] = r
                    catData.glowColor[2] = g
                    catData.glowColor[3] = b
                    catData.glowColor[4] = a * 0.7  -- Slightly more transparent
                end
                
                OmniCD:UpdateCooldownDisplay()
            end,
        }
        
        order = order + 2
    end
    
    return options
end

-- Create spell browser for adjusting individual spell priorities
function PC:CreateSpellBrowser()
    -- This would be an extensive implementation allowing users to browse
    -- and adjust priorities for specific spells. For the scope of this
    -- implementation, we'll focus on the category-based system first.
end