-- VUIMouseFireTrail Config.lua
-- Handles configuration options and integration with VUI config panel

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Open the config panel
function M:OpenConfig()
    VUI.Config:OpenToCategory(M.TITLE)
end

-- Initialize configuration panel
function M:InitializeConfig()
    -- Get localization
    local L = LibStub("AceLocale-3.0"):GetLocale("VUI")
    
    -- Register the module with the VUI config system
    local config = {
        name = M.TITLE,
        desc = M.DESCRIPTION,
        type = "group",
        args = {
            header = {
                type = "header",
                name = M.TITLE,
                order = 1,
            },
            version = {
                type = "description",
                name = "|cffff9900Version:|r " .. M.VERSION,
                order = 2,
            },
            desc = {
                type = "description",
                name = M.DESCRIPTION,
                order = 3,
            },
            spacer1 = {
                type = "description",
                name = " ",
                order = 4,
            },
            
            -- General Settings
            generalHeader = {
                type = "header",
                name = "General Settings",
                order = 10,
            },
            enabled = {
                type = "toggle",
                name = "Enable Mouse Trail Effects",
                desc = "Enable or disable the mouse cursor trail effects",
                width = "full",
                order = 11,
                get = function() return M.db.profile.enabled end,
                set = function(_, val) M.db.profile.enabled = val end,
            },
            trailType = {
                type = "select",
                name = "Trail Type",
                desc = "Select the type of trail effect",
                order = 12,
                values = {
                    ["PARTICLE"] = "Particle Effect",
                    ["TEXTURE"] = "Texture",
                    ["SHAPE"] = "Shape",
                    ["GLOW"] = "Glow",
                },
                get = function() return M.db.profile.trailType end,
                set = function(_, val) 
                    M.db.profile.trailType = val
                    -- Rebuild trail frames with new type
                    if M.CreateTrailFrames then
                        M:CreateTrailFrames()
                    end
                end,
            },
            trailCount = {
                type = "range",
                name = "Trail Count",
                desc = "Number of segments in the trail",
                order = 13,
                min = 5,
                max = 50,
                step = 1,
                get = function() return M.db.profile.trailCount end,
                set = function(_, val) 
                    M.db.profile.trailCount = val
                    -- Rebuild trail frames with new count
                    if M.CreateTrailFrames then
                        M:CreateTrailFrames()
                    end
                end,
            },
            trailSize = {
                type = "range",
                name = "Trail Size",
                desc = "Size of each trail segment",
                order = 14,
                min = 5,
                max = 50,
                step = 1,
                get = function() return M.db.profile.trailSize end,
                set = function(_, val) 
                    M.db.profile.trailSize = val
                    -- Update size on existing frames
                    if M.CreateTrailFrames then
                        M:CreateTrailFrames()
                    end
                end,
            },
            trailAlpha = {
                type = "range",
                name = "Trail Opacity",
                desc = "Transparency of the trail",
                order = 15,
                min = 0.1,
                max = 1.0,
                step = 0.05,
                get = function() return M.db.profile.trailAlpha end,
                set = function(_, val) M.db.profile.trailAlpha = val end,
            },
            trailDecay = {
                type = "range",
                name = "Trail Fade Speed",
                desc = "How quickly the trail fades (lower values = faster fade)",
                order = 16,
                min = 0.8,
                max = 0.98,
                step = 0.01,
                get = function() return M.db.profile.trailDecay end,
                set = function(_, val) M.db.profile.trailDecay = val end,
            },
            
            -- Appearance Settings
            appearanceHeader = {
                type = "header",
                name = "Appearance",
                order = 20,
            },
            colorMode = {
                type = "select",
                name = "Color Mode",
                desc = "Select the coloring style for the trail",
                order = 21,
                values = {
                    ["FIRE"] = "Fire",
                    ["ARCANE"] = "Arcane",
                    ["FROST"] = "Frost",
                    ["NATURE"] = "Nature",
                    ["RAINBOW"] = "Rainbow",
                    ["THEME"] = "Theme Color",
                    ["CUSTOM"] = "Custom Color",
                },
                get = function() return M.db.profile.colorMode end,
                set = function(_, val) 
                    M.db.profile.colorMode = val
                    -- Update colors on existing frames
                    if M.UpdateTheme then
                        M:UpdateTheme()
                    end
                end,
            },
            customColor = {
                type = "color",
                name = "Custom Color",
                desc = "Select a custom color for the trail",
                order = 22,
                hasAlpha = false,
                get = function() 
                    return M.db.profile.customColorR or 1, 
                           M.db.profile.customColorG or 1, 
                           M.db.profile.customColorB or 1
                end,
                set = function(_, r, g, b) 
                    M.db.profile.customColorR = r
                    M.db.profile.customColorG = g
                    M.db.profile.customColorB = b
                    
                    -- Update colors on existing frames if using custom color
                    if M.db.profile.colorMode == "CUSTOM" and M.UpdateTheme then
                        M:UpdateTheme()
                    end
                end,
                disabled = function() return M.db.profile.colorMode ~= "CUSTOM" end,
            },
            trailShape = {
                type = "select",
                name = "Shape Type",
                desc = "Select the shape for shape-type trails",
                order = 23,
                values = {
                    ["V_SHAPE"] = "V Shape",
                    ["ARROW"] = "Arrow",
                    ["U_SHAPE"] = "U Shape",
                    ["ELLIPSE"] = "Ellipse",
                    ["SPIRAL"] = "Spiral",
                },
                get = function() return M.db.profile.trailShape end,
                set = function(_, val) M.db.profile.trailShape = val end,
                disabled = function() return M.db.profile.trailType ~= "SHAPE" end,
            },
            textureCategory = {
                type = "select",
                name = "Texture Category",
                desc = "Select the texture category for texture-type trails",
                order = 24,
                values = function()
                    -- If we have the texture manager, use it to get categories
                    if M.GetCategories then
                        local categories = M:GetCategories()
                        local result = {}
                        for _, category in ipairs(categories) do
                            result[category] = category
                        end
                        return result
                    else
                        -- Default categories
                        return {
                            ["Basic"] = "Basic",
                            ["Flame"] = "Flame",
                            ["Bubble"] = "Bubble",
                            ["Circle"] = "Circle",
                            ["Fantasy"] = "Fantasy",
                            ["Heart"] = "Heart",
                            ["Magic"] = "Magic",
                            ["Military"] = "Military",
                            ["Nature"] = "Nature",
                            ["Shapes"] = "Shapes",
                            ["Star"] = "Star",
                        }
                    end
                end,
                get = function() return M.db.profile.textureCategory or "Basic" end,
                set = function(_, val) 
                    M.db.profile.textureCategory = val
                    -- Rebuild trail frames with new textures
                    if M.CreateTrailFrames then
                        M:CreateTrailFrames()
                    end
                end,
                disabled = function() return M.db.profile.trailType ~= "TEXTURE" end,
            },
            trailVariation = {
                type = "range",
                name = "Size Variation",
                desc = "Random variation in size of trail elements (0 = none, 1 = maximum)",
                order = 25,
                min = 0,
                max = 1,
                step = 0.05,
                get = function() return M.db.profile.trailVariation end,
                set = function(_, val) M.db.profile.trailVariation = val end,
            },
            
            -- Special Effects
            effectsHeader = {
                type = "header",
                name = "Special Effects",
                order = 30,
            },
            connectSegments = {
                type = "toggle",
                name = "Connect Trail Segments",
                desc = "Draw lines between trail segments",
                width = "full",
                order = 31,
                get = function() return M.db.profile.connectSegments end,
                set = function(_, val) M.db.profile.connectSegments = val end,
            },
            enableGlow = {
                type = "toggle",
                name = "Enable Glow Effect",
                desc = "Add a glow effect around the cursor",
                width = "full",
                order = 32,
                get = function() return M.db.profile.enableGlow end,
                set = function(_, val) M.db.profile.enableGlow = val end,
            },
            pulsingGlow = {
                type = "toggle",
                name = "Pulsing Glow",
                desc = "Make the glow effect pulse",
                width = "full",
                order = 33,
                get = function() return M.db.profile.pulsingGlow end,
                set = function(_, val) M.db.profile.pulsingGlow = val end,
                disabled = function() return not M.db.profile.enableGlow end,
            },
            
            -- Display Conditions
            conditionsHeader = {
                type = "header",
                name = "Display Conditions",
                order = 40,
            },
            showInCombat = {
                type = "toggle",
                name = "Show in Combat",
                desc = "Display the trail during combat",
                width = "full",
                order = 41,
                get = function() return M.db.profile.showInCombat end,
                set = function(_, val) M.db.profile.showInCombat = val end,
            },
            showInInstances = {
                type = "toggle",
                name = "Show in Dungeons/Raids",
                desc = "Display the trail in instances",
                width = "full",
                order = 42,
                get = function() return M.db.profile.showInInstances end,
                set = function(_, val) M.db.profile.showInInstances = val end,
            },
            showInRestArea = {
                type = "toggle",
                name = "Show in Rest Areas",
                desc = "Display the trail in cities and inns",
                width = "full",
                order = 43,
                get = function() return M.db.profile.showInRestArea end,
                set = function(_, val) M.db.profile.showInRestArea = val end,
            },
            showInWorld = {
                type = "toggle",
                name = "Show in Open World",
                desc = "Display the trail in the open world",
                width = "full",
                order = 44,
                get = function() return M.db.profile.showInWorld end,
                set = function(_, val) M.db.profile.showInWorld = val end,
            },
            requireMouseButton = {
                type = "toggle",
                name = "Require Mouse Button",
                desc = "Only show the trail when a mouse button is held down",
                width = "full",
                order = 45,
                get = function() return M.db.profile.requireMouseButton end,
                set = function(_, val) M.db.profile.requireMouseButton = val end,
            },
            requireModifierKey = {
                type = "toggle",
                name = "Require Key Modifier",
                desc = "Only show the trail when a modifier key (Shift, Ctrl, Alt) is held",
                width = "full",
                order = 46,
                get = function() return M.db.profile.requireModifierKey end,
                set = function(_, val) M.db.profile.requireModifierKey = val end,
            },
        },
    }
    
    -- Register with VUI config
    VUI.Config:RegisterModuleOptions(M.NAME, config, M.TITLE)
end