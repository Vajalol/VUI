-- VUICC Configuration Layout
local _, ns = ...

-- Grab addon references
local VUI = ns.VUI or _G.VUI
local Layout = VUI:NewModule('Config.Layout.VUICC')
local Module = VUI:GetModule("VUICC")
local L = LibStub('AceLocale-3.0'):GetLocale('VUI')

local options = {
    order = 100,
    type = 'group',
    name = function() return L['VUICC'] end,
    get = function(info)
        local key = info[#info]
        return Module.db[key]
    end,
    set = function(info, value)
        local key = info[#info]
        Module.db[key] = value
        
        -- Apply changes immediately
        if key == "disableBlizzardCooldownText" then
            -- Special handling for UI reload required setting
            StaticPopup_Show("VUI_RELOAD_UI")
        end
    end,
    args = {
        header = {
            order = 1,
            type = 'header',
            name = L['VUICC'],
        },
        desc = {
            order = 2,
            type = 'description',
            name = L['VUICC_DESC'] or "Cooldown timer display settings",
        },
        enabled = {
            order = 3,
            type = 'toggle',
            name = L['Enable'],
            desc = L['VUICC_ENABLE_DESC'] or "Enable cooldown text on action buttons and items",
            width = 'full',
        },
        disableBlizzardCooldownText = {
            order = 4,
            type = 'toggle',
            name = L['DISABLE_BLIZZARD_COOLDOWN'] or "Disable Blizzard cooldown text",
            desc = L['DISABLE_BLIZZARD_COOLDOWN_DESC'] or "Hide Blizzard's built-in cooldown text to avoid conflicts (requires UI reload)",
            width = 'full',
        },
        general = {
            order = 10,
            type = 'group',
            name = L['General'],
            inline = true,
            args = {
                minimumDuration = {
                    order = 1,
                    type = 'range',
                    name = L['MINIMUM_DURATION'] or "Minimum Duration",
                    desc = L['MINIMUM_DURATION_DESC'] or "The minimum duration in seconds a cooldown must have to display text",
                    min = 0,
                    max = 30,
                    step = 0.5,
                    width = 'full',
                },
                tenthsDuration = {
                    order = 2,
                    type = 'range',
                    name = L['TENTHS_THRESHOLD'] or "Tenths Threshold",
                    desc = L['TENTHS_THRESHOLD_DESC'] or "Display tenths of seconds when time remaining is below this value",
                    min = 0,
                    max = 10,
                    step = 0.1,
                    width = 'full',
                },
                minEffectDuration = {
                    order = 3,
                    type = 'range',
                    name = L['MIN_EFFECT_DURATION'] or "Minimum Effect Duration",
                    desc = L['MIN_EFFECT_DURATION_DESC'] or "Minimum cooldown duration required to show a finish effect",
                    min = 0,
                    max = 60,
                    step = 1,
                    width = 'full',
                },
                spiralOpacity = {
                    order = 4,
                    type = 'range',
                    name = L['SPIRAL_OPACITY'] or "Cooldown Spiral Opacity",
                    desc = L['SPIRAL_OPACITY_DESC'] or "Set the opacity of the cooldown spiral animation",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    width = 'full',
                },
            },
        },
        appearance = {
            order = 20,
            type = 'group',
            name = L['Appearance'],
            inline = true,
            get = function(info)
                local key = info[#info]
                return Module.db.theme[key]
            end,
            set = function(info, value)
                local key = info[#info]
                Module.db.theme[key] = value
            end,
            args = {
                fontSize = {
                    order = 1,
                    type = 'range',
                    name = L['FONT_SIZE'] or "Font Size",
                    desc = L['FONT_SIZE_DESC'] or "The base font size for cooldown text",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = 'full',
                },
                fontFace = {
                    order = 2,
                    type = 'select',
                    name = L['FONT_FACE'] or "Font",
                    desc = L['FONT_FACE_DESC'] or "The font used for cooldown text",
                    values = function()
                        local fonts = {}
                        local mediaFonts = LibStub("LibSharedMedia-3.0"):HashTable("font")
                        
                        for name, path in pairs(mediaFonts) do
                            fonts[name] = name
                        end
                        
                        return fonts
                    end,
                    width = 'full',
                },
                fontOutline = {
                    order = 3,
                    type = 'select',
                    name = L['FONT_OUTLINE'] or "Font Outline",
                    desc = L['FONT_OUTLINE_DESC'] or "The outline style of the cooldown text",
                    values = {
                        NONE = "None",
                        OUTLINE = "Outline",
                        THICKOUTLINE = "Thick Outline",
                        MONOCHROME = "Monochrome"
                    },
                    width = 'full',
                },
                minSize = {
                    order = 4,
                    type = 'range',
                    name = L['MIN_SIZE'] or "Minimum Size",
                    desc = L['MIN_SIZE_DESC'] or "The minimum size of a frame its cooldown text will display at 100% scale",
                    min = 0.1,
                    max = 2,
                    step = 0.05,
                    width = 'full',
                },
                minDuration = {
                    order = 5,
                    type = 'range',
                    name = L['MIN_DURATION'] or "Soon Duration",
                    desc = L['MIN_DURATION_DESC'] or "Cooldowns with less than this many seconds left will be shown with the 'soon' color",
                    min = 0,
                    max = 10,
                    step = 0.5,
                    width = 'full',
                },
                xOff = {
                    order = 6,
                    type = 'range',
                    name = L['X_OFFSET'] or "X Offset",
                    desc = L['X_OFFSET_DESC'] or "Horizontal offset of cooldown text from its anchor",
                    min = -10,
                    max = 10,
                    step = 1,
                    width = 'half',
                },
                yOff = {
                    order = 7,
                    type = 'range',
                    name = L['Y_OFFSET'] or "Y Offset",
                    desc = L['Y_OFFSET_DESC'] or "Vertical offset of cooldown text from its anchor",
                    min = -10,
                    max = 10,
                    step = 1,
                    width = 'half',
                },
                anchor = {
                    order = 8,
                    type = 'select',
                    name = L['ANCHOR'] or "Anchor",
                    desc = L['ANCHOR_DESC'] or "Position of the cooldown text on the frame",
                    values = {
                        CENTER = "Center",
                        TOP = "Top",
                        TOPLEFT = "Top Left",
                        TOPRIGHT = "Top Right",
                        BOTTOM = "Bottom",
                        BOTTOMLEFT = "Bottom Left",
                        BOTTOMRIGHT = "Bottom Right",
                        LEFT = "Left",
                        RIGHT = "Right"
                    },
                    width = 'full',
                },
            },
        },
        colorSoon = {
            order = 30,
            type = 'group',
            name = L['COLOR_SOON'] or "Soon Color",
            inline = true,
            get = function(info)
                local key = info[#info]
                return Module.db.theme.styles.soon[key]
            end,
            set = function(info, value)
                local key = info[#info]
                Module.db.theme.styles.soon[key] = value
            end,
            args = {
                color = {
                    order = 1,
                    type = 'color',
                    name = L['COLOR'] or "Color",
                    desc = L['COLOR_SOON_DESC'] or "Text color when cooldown is about to expire",
                    hasAlpha = true,
                    get = function()
                        local c = Module.db.theme.styles.soon
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Module.db.theme.styles.soon
                        c.r, c.g, c.b, c.a = r, g, b, a
                    end,
                    width = 'full',
                },
                scale = {
                    order = 2,
                    type = 'range',
                    name = L['SCALE'] or "Scale",
                    desc = L['SCALE_SOON_DESC'] or "Size multiplier for text when cooldown is about to expire",
                    min = 0.5,
                    max = 2,
                    step = 0.05,
                    width = 'full',
                },
            },
        },
        colorSeconds = {
            order = 31,
            type = 'group',
            name = L['COLOR_SECONDS'] or "Seconds Color",
            inline = true,
            get = function(info)
                local key = info[#info]
                return Module.db.theme.styles.seconds[key]
            end,
            set = function(info, value)
                local key = info[#info]
                Module.db.theme.styles.seconds[key] = value
            end,
            args = {
                color = {
                    order = 1,
                    type = 'color',
                    name = L['COLOR'] or "Color",
                    desc = L['COLOR_SECONDS_DESC'] or "Text color when cooldown is in seconds",
                    hasAlpha = true,
                    get = function()
                        local c = Module.db.theme.styles.seconds
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Module.db.theme.styles.seconds
                        c.r, c.g, c.b, c.a = r, g, b, a
                    end,
                    width = 'full',
                },
                scale = {
                    order = 2,
                    type = 'range',
                    name = L['SCALE'] or "Scale",
                    desc = L['SCALE_SECONDS_DESC'] or "Size multiplier for text when cooldown is in seconds",
                    min = 0.5,
                    max = 2,
                    step = 0.05,
                    width = 'full',
                },
            },
        },
        colorMinutes = {
            order = 32,
            type = 'group',
            name = L['COLOR_MINUTES'] or "Minutes Color",
            inline = true,
            get = function(info)
                local key = info[#info]
                return Module.db.theme.styles.minutes[key]
            end,
            set = function(info, value)
                local key = info[#info]
                Module.db.theme.styles.minutes[key] = value
            end,
            args = {
                color = {
                    order = 1,
                    type = 'color',
                    name = L['COLOR'] or "Color",
                    desc = L['COLOR_MINUTES_DESC'] or "Text color when cooldown is in minutes",
                    hasAlpha = true,
                    get = function()
                        local c = Module.db.theme.styles.minutes
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Module.db.theme.styles.minutes
                        c.r, c.g, c.b, c.a = r, g, b, a
                    end,
                    width = 'full',
                },
                scale = {
                    order = 2,
                    type = 'range',
                    name = L['SCALE'] or "Scale",
                    desc = L['SCALE_MINUTES_DESC'] or "Size multiplier for text when cooldown is in minutes",
                    min = 0.5,
                    max = 2,
                    step = 0.05,
                    width = 'full',
                },
            },
        },
        colorHours = {
            order = 33,
            type = 'group',
            name = L['COLOR_HOURS'] or "Hours Color",
            inline = true,
            get = function(info)
                local key = info[#info]
                return Module.db.theme.styles.hours[key]
            end,
            set = function(info, value)
                local key = info[#info]
                Module.db.theme.styles.hours[key] = value
            end,
            args = {
                color = {
                    order = 1,
                    type = 'color',
                    name = L['COLOR'] or "Color",
                    desc = L['COLOR_HOURS_DESC'] or "Text color when cooldown is in hours",
                    hasAlpha = true,
                    get = function()
                        local c = Module.db.theme.styles.hours
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Module.db.theme.styles.hours
                        c.r, c.g, c.b, c.a = r, g, b, a
                    end,
                    width = 'full',
                },
                scale = {
                    order = 2,
                    type = 'range',
                    name = L['SCALE'] or "Scale",
                    desc = L['SCALE_HOURS_DESC'] or "Size multiplier for text when cooldown is in hours",
                    min = 0.5,
                    max = 2,
                    step = 0.05,
                    width = 'full',
                },
            },
        },
        effects = {
            order = 40,
            type = 'group',
            name = L['FINISH_EFFECTS'] or "Finish Effects",
            inline = true,
            get = function(info)
                local key = info[#info]
                return Module.db.theme[key]
            end,
            set = function(info, value)
                local key = info[#info]
                Module.db.theme[key] = value
            end,
            args = {
                effect = {
                    order = 1,
                    type = 'select',
                    name = L['EFFECT_TYPE'] or "Effect Type",
                    desc = L['EFFECT_TYPE_DESC'] or "The visual effect to display when a cooldown finishes",
                    values = function()
                        local effects = {}
                        for _, effect in ipairs(Module.FX:GetList()) do
                            effects[effect] = effect:gsub("^%l", string.upper)
                        end
                        return effects
                    end,
                    width = 'full',
                },
                effectDesc = {
                    order = 2,
                    type = 'description',
                    name = L['EFFECT_DESC'] or "Choose what happens when a cooldown completes",
                    width = 'full',
                },
            },
        },
    },
}

-- Assign to Layout
Layout.layout = options

-- Return the options table
return options