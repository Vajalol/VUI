-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Options
-- Author: VortexQ8
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local AddonName, VUI = ...

-- Ensure VUI exists
VUI = VUI or {}

-- Ensure ScrollingText namespace exists
VUI.ScrollingText = VUI.ScrollingText or {}
local ST = VUI.ScrollingText

-- Create options table
ST.options = ST.options or {}

-- Font handling helper functions
local function GetFontName(fontObject)
    if not fontObject then return "Fonts\\FRIZQT__.TTF" end
    
    local font, size, flags
    if type(fontObject) == "string" then
        return fontObject
    elseif type(fontObject) == "table" and fontObject.GetFont then
        -- It's a font object
        font, size, flags = fontObject:GetFont()
        return font or "Fonts\\FRIZQT__.TTF"
    else
        return "Fonts\\FRIZQT__.TTF"
    end
end

local function SetFontProperties(fontString, fontName, fontSize, fontOutline)
    if not fontString then return end
    
    fontName = fontName or "Fonts\\FRIZQT__.TTF"
    fontSize = fontSize or 12
    fontOutline = fontOutline or "OUTLINE"
    
    -- Use pcall to catch any errors
    local success, result = pcall(function()
        fontString:SetFont(fontName, fontSize, fontOutline)
    end)
    
    if not success then
        -- Fallback to default font if there was an error
        pcall(function()
            fontString:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        end)
    end
end

-- Default settings
ST.defaults = {
    profile = {
        enabled = true,
        
        -- Animation settings
        animations = {
            style = "scroll",
            speed = 1.0,
            fadeOut = true,
        },
        
        -- Font settings
        font = {
            name = "Fonts\\FRIZQT__.TTF",
            size = 18,
            outline = "OUTLINE",
        },
        
        -- Scrolling areas
        scrollAreas = {
            -- Player scrolling area (center/damage)
            player = {
                enabled = true,
                name = "Player",
                position = {"CENTER", UIParent, "CENTER", 0, 0},
                size = {width = 300, height = 150},
                direction = "UP",
                behavior = "MSBT_NORMAL",
                textAlign = "CENTER",
                scrollHeight = 150,
                scrollWidth = 300,
                animationSpeed = 1.0,
                animationStyle = "Straight",
                iconSize = 18,
                fontSize = 18,
                showIcons = true,
                showCrits = true,
                inheritFontSize = true,
                fontOutline = true,
            },
            
            -- Outgoing scrolling area (bottom right)
            outgoing = {
                enabled = true,
                name = "Outgoing",
                position = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -150, 150},
                size = {width = 300, height = 150},
                direction = "UP",
                behavior = "MSBT_NORMAL",
                textAlign = "RIGHT",
                scrollHeight = 150,
                scrollWidth = 300,
                animationSpeed = 1.0,
                animationStyle = "Straight",
                iconSize = 18,
                fontSize = 18,
                showIcons = true,
                showCrits = true,
                inheritFontSize = true,
                fontOutline = true,
            },
            
            -- Incoming scrolling area (bottom left)
            incoming = {
                enabled = true,
                name = "Incoming",
                position = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 150, 150},
                size = {width = 300, height = 150},
                direction = "UP",
                behavior = "MSBT_NORMAL",
                textAlign = "LEFT",
                scrollHeight = 150,
                scrollWidth = 300,
                animationSpeed = 1.0,
                animationStyle = "Straight",
                iconSize = 18,
                fontSize = 18,
                showIcons = true,
                showCrits = true,
                inheritFontSize = true,
                fontOutline = true,
            },
            
            -- Notification scrolling area (top)
            notification = {
                enabled = true,
                name = "Notification",
                position = {"TOP", UIParent, "TOP", 0, -150},
                size = {width = 500, height = 100},
                direction = "UP",
                behavior = "MSBT_STATIC",
                textAlign = "CENTER",
                scrollHeight = 100,
                scrollWidth = 500,
                animationSpeed = 0.5,
                animationStyle = "Static",
                iconSize = 18,
                fontSize = 20,
                showIcons = true,
                inheritFontSize = true,
                fontOutline = true,
            },
        },
        
        -- Events configuration
        events = {
            -- Damage events
            playerDamage = {
                enabled = true,
                scrollArea = "player",
                showOverheals = true,
                showIcons = true,
                fontSize = 0, -- 0 means use scrollArea setting
                fontOutline = true,
                color = {r = 1, g = 0.1, b = 0.1, a = 1},
                critColor = {r = 1, g = 0.5, b = 0, a = 1},
                critPrefix = "*",
                critSuffix = "*",
                soundFile = "",
            },
            
            -- Healing events
            playerHealing = {
                enabled = true,
                scrollArea = "player",
                showOverheals = true,
                showIcons = true,
                fontSize = 0, -- 0 means use scrollArea setting
                fontOutline = true,
                color = {r = 0.1, g = 1, b = 0.1, a = 1},
                critColor = {r = 0.1, g = 1, b = 0.5, a = 1},
                critPrefix = "*",
                critSuffix = "*",
                soundFile = "",
            },
            
            -- Notification events
            notification = {
                enabled = true,
                scrollArea = "notification",
                showIcons = true,
                fontSize = 0, -- 0 means use scrollArea setting
                fontOutline = true,
                color = {r = 1, g = 1, b = 0, a = 1},
                soundFile = "",
            },
        },
    }
}

-- Initialize options
function ST:InitializeOptions()
    -- Create a database if one doesn't exist
    if VUI.db then
        self.db = VUI.db:RegisterNamespace("VUIScrollingText", {
            profile = self.defaults.profile
        })
    else
        -- Create a standalone database if VUI.db doesn't exist
        local AceDB = LibStub and LibStub("AceDB-3.0")
        if AceDB then
            self.db = AceDB:New("VUIScrollingTextDB", self.defaults)
        else
            -- Fallback to a simple table
            self.db = {
                profile = self.defaults.profile
            }
        end
    end
    
    -- Expose the font helper functions
    self.GetFontName = GetFontName
    self.SetFontProperties = SetFontProperties
    
    -- Create AceConfig options if AceConfig is available
    local AceConfig = LibStub and LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub and LibStub("AceConfigDialog-3.0")
    
    if AceConfig and AceConfigDialog then
        -- Create options table
        local options = {
            name = "VUI Scrolling Text",
            type = "group",
            args = {
                general = {
                    name = "General",
                    type = "group",
                    order = 1,
                    args = {
                        enabled = {
                            name = "Enable",
                            desc = "Enable or disable the addon",
                            type = "toggle",
                            order = 1,
                            get = function() return self.db.profile.enabled end,
                            set = function(_, value) self.db.profile.enabled = value end,
                        },
                        animationHeader = {
                            name = "Animation Settings",
                            type = "header",
                            order = 2,
                        },
                        animationStyle = {
                            name = "Default Animation",
                            desc = "Set the default animation style",
                            type = "select",
                            order = 3,
                            values = {
                                scroll = "Scroll",
                                parabola = "Parabola",
                                static = "Static (No Animation)",
                            },
                            get = function() return self.db.profile.animations.style end,
                            set = function(_, value) self.db.profile.animations.style = value end,
                        },
                        animationSpeed = {
                            name = "Animation Speed",
                            desc = "Set the animation speed (lower is faster)",
                            type = "range",
                            order = 4,
                            min = 0.5,
                            max = 2.0,
                            step = 0.1,
                            get = function() return self.db.profile.animations.speed end,
                            set = function(_, value) self.db.profile.animations.speed = value end,
                        },
                        fontHeader = {
                            name = "Font Settings",
                            type = "header",
                            order = 5,
                        },
                        fontName = {
                            name = "Font",
                            desc = "Set the default font",
                            type = "select",
                            order = 6,
                            values = {
                                -- List available fonts
                                ["Fonts\\FRIZQT__.TTF"] = "FRIZQT (Default)",
                                ["Fonts\\ARIALN.TTF"] = "ARIALN",
                                ["Fonts\\skurri.ttf"] = "Skurri",
                                ["Fonts\\MORPHEUS.ttf"] = "Morpheus",
                            },
                            get = function() return self.db.profile.font.name end,
                            set = function(_, value) self.db.profile.font.name = value end,
                        },
                        fontSize = {
                            name = "Font Size",
                            desc = "Set the default font size",
                            type = "range",
                            order = 7,
                            min = 8,
                            max = 32,
                            step = 1,
                            get = function() return self.db.profile.font.size end,
                            set = function(_, value) self.db.profile.font.size = value end,
                        },
                        fontOutline = {
                            name = "Font Outline",
                            desc = "Set the default font outline",
                            type = "select",
                            order = 8,
                            values = {
                                [""] = "None",
                                ["OUTLINE"] = "Outline",
                                ["THICKOUTLINE"] = "Thick Outline",
                            },
                            get = function() return self.db.profile.font.outline end,
                            set = function(_, value) self.db.profile.font.outline = value end,
                        },
                    },
                },
            },
        }
        
        -- Register options with AceConfig
        AceConfig:RegisterOptionsTable("VUIScrollingText", options)
        
        -- Add to Blizzard interface options
        self.optionsFrame = AceConfigDialog:AddToBlizOptions("VUIScrollingText", "VUI Scrolling Text")
    end
end

-- Apply settings from options
function ST:ApplySettings()
    -- Apply global settings
    self.enabled = self.db.profile.enabled
    
    -- Apply settings to each scroll area
    if self.UpdateScrollAreas and type(self.UpdateScrollAreas) == "function" then
        self:UpdateScrollAreas()
    end
end

-- Setup slash commands
function ST:SetupSlashCommands()
    -- Register slash command if AceConsole is available
    if VUI.RegisterChatCommand and type(VUI.RegisterChatCommand) == "function" then
        VUI:RegisterChatCommand("vuist", function() 
            if ST.optionsFrame then
                InterfaceOptionsFrame_OpenToCategory(ST.optionsFrame)
            end
        end)
    end
end

-- Initialize options when addon loads
if ST.InitializeOptions then
    ST:InitializeOptions()
    ST:SetupSlashCommands()
end 