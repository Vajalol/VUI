-- VUI Skins Module - Initialization
local _, VUI = ...

-- Create the module using the module API
local Skins = VUI.ModuleAPI:CreateModule("skins")

-- Get configuration options for main UI integration
function Skins:GetConfig()
    local config = {
        name = "Skins",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Skins",
                desc = "Enable or disable the Skins module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            blizzardHeader = {
                type = "header",
                name = "Blizzard UI Skins",
                order = 2
            },
            blizzardEnabled = {
                type = "toggle",
                name = "Enable Blizzard Skins",
                desc = "Enable or disable skinning for Blizzard UI frames",
                get = function() return self.db.blizzard.enabled end,
                set = function(_, value) 
                    self.db.blizzard.enabled = value
                    self:UpdateBlizzardSkins()
                end,
                order = 3
            },
            actionbars = {
                type = "toggle",
                name = "Action Bars",
                desc = "Apply skin to Action Bars",
                get = function() return self.db.blizzard.actionbars end,
                set = function(_, value) 
                    self.db.blizzard.actionbars = value
                    self:UpdateSkin("actionbars")
                end,
                disabled = function() return not self.db.blizzard.enabled end,
                order = 4
            },
            bags = {
                type = "toggle",
                name = "Bags",
                desc = "Apply skin to Bags",
                get = function() return self.db.blizzard.bags end,
                set = function(_, value) 
                    self.db.blizzard.bags = value
                    self:UpdateSkin("bags")
                end,
                disabled = function() return not self.db.blizzard.enabled end,
                order = 5
            },
            addonSkinsHeader = {
                type = "header",
                name = "Addon Skins",
                order = 20
            },
            addonSkinsEnabled = {
                type = "toggle",
                name = "Enable Addon Skins",
                desc = "Enable or disable skinning for supported addons",
                get = function() return self.db.addons.enabled end,
                set = function(_, value) 
                    self.db.addons.enabled = value
                    self:UpdateAddonSkins()
                end,
                order = 21
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
-- Module config registration is done later with extended options

-- Set up module defaults
local defaults = {
    enabled = true,
    blizzard = {
        enabled = true,
        actionbars = true,
        bags = true,
        character = true,
        chat = true,
        collections = true,
        communities = true,
        dressingroom = true,
        friends = true,
        gossip = true,
        guild = true,
        help = true,
        lfg = true,
        loot = true,
        mail = true,
        merchant = true,
        options = true,
        petbattle = true,
        pvp = true,
        quest = true,
        spellbook = true,
        talent = true,
        taxi = true,
        timemanager = true,
        tooltip = true,
        worldmap = true,
        frames = true,
        alerts = true,
        achievement = true,
        encounterjournal = true,
        garrison = true,
        calendar = true,
        orderhall = true,
        garrison = true,
        archaeology = true,
        barber = true,
        macro = true,
        debugtools = true,
        contribution = true,
        binding = true,
        blizzardui = true,
    },
    addons = {
        enabled = true,
        auctionator = true,
        omnicc = true,
        angrykeystones = true,
        omnicd = true,
        buffoverlay = true,
        moveany = true,
        idtip = true,
        trufigcd = true,
        details = true,
        dbm = true,
        weakauras = true,
        plater = true,
    },
    style = {
        shadowSize = 3,
        shadowOverlayAlpha = 0.25,
        borderSize = 1,
        borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1.0},
        backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
        colorInteractive = true,
        colorBorderInteractive = true,
        buttonStyle = "gradient",  -- gradient, flat, shadow
        -- Button styling
        buttons = {
            hoverColor = {r = 0.4, g = 0.4, b = 0.4, a = 0.4},
            borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1.0},
            backdropColor = {r = 0.15, g = 0.15, b = 0.15, a = 1.0},
            gradientColor = {r = 0.3, g = 0.3, b = 0.3, a = 0.3},
        },
    },
    advancedUI = {
        enabled = true,
        customFonts = true,
        fontName = "Friz Quadrata TT",
        fontSize = 12,
        fontFlags = "",
        usePixelPerfect = true
    },
    minimap = {
        enabled = true,
        showCoordinates = true,
        showClock = true,
        use12HourFormat = true,
        enhancedZoneText = true,
        squareMinimap = false,
        useClassColoredBorder = true,
        cleanupButtons = true,
        buttonContainerToggle = true,
    },
}

-- Initialize module settings
Skins.settings = VUI.ModuleAPI:InitializeModuleSettings("skins", defaults)

-- Register module configuration
local config = {
    type = "group",
    name = "Skins",
    desc = "Customizable UI skinning system",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable skins module",
            order = 1,
            get = function() return VUI:IsModuleEnabled("skins") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("skins")
                else
                    VUI:DisableModule("skins")
                end
            end,
        },
        blizzardHeader = {
            type = "header",
            name = "Blizzard UI",
            order = 2,
        },
        blizzardEnabled = {
            type = "toggle",
            name = "Enable Blizzard Skinning",
            desc = "Enable skinning of Blizzard UI elements",
            order = 3,
            get = function() return Skins.settings.blizzard.enabled end,
            set = function(_, value)
                Skins.settings.blizzard.enabled = value
                Skins:ApplySkins()
            end,
        },
        blizzardElements = {
            type = "group",
            name = "Blizzard UI Elements",
            desc = "Configure which Blizzard UI elements to skin",
            order = 4,
            inline = true,
            args = {
                -- These will be filled in by the InitializeBlizzardConfig function
            }
        },
        addonHeader = {
            type = "header",
            name = "Addon Skins",
            order = 5,
        },
        addonEnabled = {
            type = "toggle",
            name = "Enable Addon Skinning",
            desc = "Enable skinning of supported addons",
            order = 6,
            get = function() return Skins.settings.addons.enabled end,
            set = function(_, value)
                Skins.settings.addons.enabled = value
                Skins:ApplySkins()
            end,
        },
        addonElements = {
            type = "group",
            name = "Supported Addons",
            desc = "Configure which addons to skin",
            order = 7,
            inline = true,
            args = {
                -- These will be filled in by the InitializeAddonConfig function
            }
        },
        styleHeader = {
            type = "header",
            name = "Skin Style",
            order = 8,
        },
        styleGroup = {
            type = "group",
            name = "Style Settings",
            desc = "Configure the appearance of skinned elements",
            order = 9,
            inline = true,
            args = {
                shadowSize = {
                    type = "range",
                    name = "Shadow Size",
                    desc = "Size of shadows around frames",
                    min = 0,
                    max = 10,
                    step = 1,
                    order = 1,
                    get = function() return Skins.settings.style.shadowSize end,
                    set = function(_, value)
                        Skins.settings.style.shadowSize = value
                        Skins:ApplySkins()
                    end,
                },
                shadowAlpha = {
                    type = "range",
                    name = "Shadow Alpha",
                    desc = "Transparency of shadows",
                    min = 0,
                    max = 1,
                    step = 0.01,
                    order = 2,
                    get = function() return Skins.settings.style.shadowOverlayAlpha end,
                    set = function(_, value)
                        Skins.settings.style.shadowOverlayAlpha = value
                        Skins:ApplySkins()
                    end,
                },
                borderSize = {
                    type = "range",
                    name = "Border Size",
                    desc = "Thickness of borders",
                    min = 0,
                    max = 5,
                    step = 1,
                    order = 3,
                    get = function() return Skins.settings.style.borderSize end,
                    set = function(_, value)
                        Skins.settings.style.borderSize = value
                        Skins:ApplySkins()
                    end,
                },
                borderColor = {
                    type = "color",
                    name = "Border Color",
                    desc = "Color of frame borders",
                    hasAlpha = true,
                    order = 4,
                    get = function()
                        local c = Skins.settings.style.borderColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Skins.settings.style.borderColor
                        c.r, c.g, c.b, c.a = r, g, b, a
                        Skins:ApplySkins()
                    end,
                },
                backdropColor = {
                    type = "color",
                    name = "Backdrop Color",
                    desc = "Background color for frames",
                    hasAlpha = true,
                    order = 5,
                    get = function()
                        local c = Skins.settings.style.backdropColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        local c = Skins.settings.style.backdropColor
                        c.r, c.g, c.b, c.a = r, g, b, a
                        Skins:ApplySkins()
                    end,
                },
                colorInteractive = {
                    type = "toggle",
                    name = "Interactive Highlights",
                    desc = "Highlight interactive elements on mouseover",
                    order = 6,
                    get = function() return Skins.settings.style.colorInteractive end,
                    set = function(_, value)
                        Skins.settings.style.colorInteractive = value
                        Skins:ApplySkins()
                    end,
                },
                colorBorderInteractive = {
                    type = "toggle",
                    name = "Interactive Borders",
                    desc = "Change border color on interactive elements",
                    order = 7,
                    get = function() return Skins.settings.style.colorBorderInteractive end,
                    set = function(_, value)
                        Skins.settings.style.colorBorderInteractive = value
                        Skins:ApplySkins()
                    end,
                },
                buttonStyle = {
                    type = "select",
                    name = "Button Style",
                    desc = "Style for buttons",
                    order = 8,
                    values = {
                        ["gradient"] = "Gradient",
                        ["flat"] = "Flat",
                        ["shadow"] = "Shadow",
                    },
                    get = function() return Skins.settings.style.buttonStyle end,
                    set = function(_, value)
                        Skins.settings.style.buttonStyle = value
                        Skins:ApplySkins()
                    end,
                },
            },
        },
        advancedHeader = {
            type = "header",
            name = "Advanced UI",
            order = 10,
        },
        advancedEnabled = {
            type = "toggle",
            name = "Enable Advanced UI",
            desc = "Enable advanced UI improvements",
            order = 11,
            get = function() return Skins.settings.advancedUI.enabled end,
            set = function(_, value)
                Skins.settings.advancedUI.enabled = value
                Skins:ApplySkins()
            end,
        },
        customFonts = {
            type = "toggle",
            name = "Use Custom Fonts",
            desc = "Apply custom fonts to UI elements",
            order = 12,
            get = function() return Skins.settings.advancedUI.customFonts end,
            set = function(_, value)
                Skins.settings.advancedUI.customFonts = value
                Skins:ApplySkins()
            end,
            disabled = function() return not Skins.settings.advancedUI.enabled end,
        },
        fontName = {
            type = "select",
            name = "Font",
            desc = "Select the font to use",
            order = 13,
            values = function()
                local fonts = {}
                if VUI.media and VUI.media.fonts then
                    for name, _ in pairs(VUI.media.fonts) do
                        fonts[name] = name
                    end
                else
                    fonts["Friz Quadrata TT"] = "Friz Quadrata TT"
                end
                return fonts
            end,
            get = function() return Skins.settings.advancedUI.fontName end,
            set = function(_, value)
                Skins.settings.advancedUI.fontName = value
                Skins:ApplySkins()
            end,
            disabled = function() return not (Skins.settings.advancedUI.enabled and Skins.settings.advancedUI.customFonts) end,
        },
        fontSize = {
            type = "range",
            name = "Font Size",
            desc = "Size of font in UI elements",
            min = 8,
            max = 18,
            step = 1,
            order = 14,
            get = function() return Skins.settings.advancedUI.fontSize end,
            set = function(_, value)
                Skins.settings.advancedUI.fontSize = value
                Skins:ApplySkins()
            end,
            disabled = function() return not (Skins.settings.advancedUI.enabled and Skins.settings.advancedUI.customFonts) end,
        },
        fontFlags = {
            type = "select",
            name = "Font Style",
            desc = "Select the font style to use",
            order = 15,
            values = {
                [""] = "None",
                ["OUTLINE"] = "Outline",
                ["THICKOUTLINE"] = "Thick Outline",
                ["MONOCHROME"] = "Monochrome",
                ["MONOCHROME,OUTLINE"] = "Monochrome Outline",
            },
            get = function() return Skins.settings.advancedUI.fontFlags end,
            set = function(_, value)
                Skins.settings.advancedUI.fontFlags = value
                Skins:ApplySkins()
            end,
            disabled = function() return not (Skins.settings.advancedUI.enabled and Skins.settings.advancedUI.customFonts) end,
        },
        pixelPerfect = {
            type = "toggle",
            name = "Pixel Perfect Mode",
            desc = "Optimize UI elements for pixel-perfect rendering",
            order = 16,
            get = function() return Skins.settings.advancedUI.usePixelPerfect end,
            set = function(_, value)
                Skins.settings.advancedUI.usePixelPerfect = value
                Skins:ApplySkins()
            end,
            disabled = function() return not Skins.settings.advancedUI.enabled end,
        },
        minimapHeader = {
            type = "header",
            name = "Minimap",
            order = 17,
        },
        minimapEnabled = {
            type = "toggle",
            name = "Enable Minimap Enhancements",
            desc = "Enable enhanced minimap features",
            order = 18,
            get = function() return Skins.settings.minimap.enabled end,
            set = function(_, value)
                Skins.settings.minimap.enabled = value
                Skins:ApplySkins()
            end,
        },
        minimapGroup = {
            type = "group",
            name = "Minimap Settings",
            desc = "Configure minimap enhancements",
            order = 19,
            inline = true,
            args = {
                showCoordinates = {
                    type = "toggle",
                    name = "Show Coordinates",
                    desc = "Display player coordinates on the minimap",
                    order = 1,
                    get = function() return Skins.settings.minimap.showCoordinates end,
                    set = function(_, value)
                        Skins.settings.minimap.showCoordinates = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not Skins.settings.minimap.enabled end,
                },
                showClock = {
                    type = "toggle",
                    name = "Show Clock",
                    desc = "Display game time on the minimap",
                    order = 2,
                    get = function() return Skins.settings.minimap.showClock end,
                    set = function(_, value)
                        Skins.settings.minimap.showClock = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not Skins.settings.minimap.enabled end,
                },
                use12HourFormat = {
                    type = "toggle",
                    name = "Use 12-Hour Format",
                    desc = "Use 12-hour format for the clock (AM/PM)",
                    order = 3,
                    get = function() return Skins.settings.minimap.use12HourFormat end,
                    set = function(_, value)
                        Skins.settings.minimap.use12HourFormat = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not (Skins.settings.minimap.enabled and Skins.settings.minimap.showClock) end,
                },
                enhancedZoneText = {
                    type = "toggle",
                    name = "Enhanced Zone Text",
                    desc = "Show enhanced zone text with zone type coloring",
                    order = 4,
                    get = function() return Skins.settings.minimap.enhancedZoneText end,
                    set = function(_, value)
                        Skins.settings.minimap.enhancedZoneText = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not Skins.settings.minimap.enabled end,
                },
                squareMinimap = {
                    type = "toggle",
                    name = "Square Minimap",
                    desc = "Make the minimap square instead of round",
                    order = 5,
                    get = function() return Skins.settings.minimap.squareMinimap end,
                    set = function(_, value)
                        Skins.settings.minimap.squareMinimap = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not Skins.settings.minimap.enabled end,
                },
                useClassColoredBorder = {
                    type = "toggle",
                    name = "Class-Colored Border",
                    desc = "Use player class color for the minimap border",
                    order = 6,
                    get = function() return Skins.settings.minimap.useClassColoredBorder end,
                    set = function(_, value)
                        Skins.settings.minimap.useClassColoredBorder = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not Skins.settings.minimap.enabled end,
                },
                cleanupButtons = {
                    type = "toggle",
                    name = "Clean Up Buttons",
                    desc = "Organize addon buttons around the minimap",
                    order = 7,
                    get = function() return Skins.settings.minimap.cleanupButtons end,
                    set = function(_, value)
                        Skins.settings.minimap.cleanupButtons = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not Skins.settings.minimap.enabled end,
                },
                buttonContainerToggle = {
                    type = "toggle",
                    name = "Button Container Toggle",
                    desc = "Add a button to show/hide the minimap button container",
                    order = 8,
                    get = function() return Skins.settings.minimap.buttonContainerToggle end,
                    set = function(_, value)
                        Skins.settings.minimap.buttonContainerToggle = value
                        Skins:ApplySkins()
                    end,
                    disabled = function() return not (Skins.settings.minimap.enabled and Skins.settings.minimap.cleanupButtons) end,
                },
            },
        },
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("skins", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("skins", "vuiskin", function(input)
    if input and input:trim() == "apply" then
        Skins:ApplySkins()
    elseif input and input:trim() == "blizzard" then
        Skins.settings.blizzard.enabled = not Skins.settings.blizzard.enabled
        Skins:ApplySkins()
    elseif input and input:trim() == "addons" then
        Skins.settings.addons.enabled = not Skins.settings.addons.enabled
        Skins:ApplySkins()
    elseif input and input:trim() == "reset" then
        Skins:ResetSkins()
    else
        VUI:Print("Skins Commands:")
        VUI:Print("  /vuiskin apply - Apply all skins")
        VUI:Print("  /vuiskin blizzard - Toggle Blizzard UI skinning")
        VUI:Print("  /vuiskin addons - Toggle addon skinning")
        VUI:Print("  /vuiskin reset - Reset skin settings")
    end
end)

-- Initialize module
function Skins:Initialize()
    -- Register with VUI
    VUI:Print("Skins module initialized")
    
    -- Initialize configuration elements
    self:InitializeBlizzardConfig()
    self:InitializeAddonConfig()
    
    -- Initialize skin tracking tables
    self.skinnedFrames = {}
    self.registeredSkins = {}
    self.activeSkins = {}
    self.hooked = {}
    
    -- Initialize theme integration
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Initialize skin function tables
    self.blizzardSkinFuncs = {
        ["minimap"] = function()
            -- Initialize the minimap skin
            local MinimapSkin = _G["VUIMinimapSkin"]
            if MinimapSkin then
                MinimapSkin:OnEnable()
            else
                -- Fallback - load the minimap skin manually
                local minimap = self:FindChild("blizzard", "minimap")
                if minimap and minimap.OnEnable then
                    minimap:OnEnable()
                end
            end
        end
    }
    
    self.addonSkinFuncs = {}
    
    -- Add skin categories
    self.categories = {
        ["Blizzard"] = {
            name = "Blizzard UI",
            description = "Skins for the default Blizzard user interface elements",
            priority = 10,
        },
        ["Addons"] = {
            name = "Addon Skins",
            description = "Skins for supported third-party addons",
            priority = 20,
        },
        ["Custom"] = {
            name = "Custom Skins",
            description = "User-created and custom skins",
            priority = 30,
        }
    }
    
    -- Register for UI integration
    VUI.ModuleAPI:EnableModuleUI("skins", function(module)
        module:SetupHooks()
    end)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
    
    -- Register with dashboard if available
    if VUI.Dashboard then
        VUI.Dashboard:RegisterModule("Skins", {
            icon = "Interface\\AddOns\\VUI\\media\\textures\\SUI",
            description = "Customize the appearance of frames and elements",
            category = "UI",
            config = function() 
                if InterfaceOptionsFrame_OpenToCategory then
                    InterfaceOptionsFrame_OpenToCategory("VUI")
                    InterfaceOptionsFrame_OpenToCategory("VUI Skins")
                end
            end,
            getStatus = function() 
                local activeCount = 0
                local totalCount = 0
                
                for _, _ in pairs(self.registeredSkins) do
                    totalCount = totalCount + 1
                end
                
                for _, _ in pairs(self.activeSkins) do
                    activeCount = activeCount + 1
                end
                
                return {
                    active = activeCount,
                    total = totalCount,
                    enabled = self.enabled
                }
            end
        })
    end
    
    -- Load skin modules
    self:LoadSkinModules()
end

-- Enable module
function Skins:Enable()
    self.enabled = true
    
    -- Set up hooks and integrations
    self:SetupHooks()
    
    -- Apply skins to currently loaded frames
    self:ApplySkins()
    
    VUI:Print("Skins module enabled")
end

-- Disable module
function Skins:Disable()
    self.enabled = false
    
    VUI:Print("Skins module disabled")
end

-- Initialize Blizzard UI config options
function Skins:InitializeBlizzardConfig()
    local options = config.args.blizzardElements.args
    local order = 1
    
    -- Add toggles for each Blizzard UI element
    for element, _ in pairs(self.settings.blizzard) do
        if element ~= "enabled" then
            options[element] = {
                type = "toggle",
                name = element:gsub("^%l", string.upper):gsub("(%l)(%u)", "%1 %2"),
                desc = "Enable skinning of " .. element:gsub("^%l", string.upper):gsub("(%l)(%u)", "%1 %2"),
                width = "half",
                order = order,
                get = function() return self.settings.blizzard[element] end,
                set = function(_, value)
                    self.settings.blizzard[element] = value
                    self:ApplySkins()
                end,
                disabled = function() return not self.settings.blizzard.enabled end,
            }
            order = order + 1
        end
    end
end

-- Initialize addon config options
function Skins:InitializeAddonConfig()
    local options = config.args.addonElements.args
    local order = 1
    
    -- Add toggles for each supported addon
    for addon, _ in pairs(self.settings.addons) do
        if addon ~= "enabled" then
            options[addon] = {
                type = "toggle",
                name = addon:gsub("^%l", string.upper):gsub("(%l)(%u)", "%1 %2"),
                desc = "Enable skinning of " .. addon:gsub("^%l", string.upper):gsub("(%l)(%u)", "%1 %2"),
                width = "half",
                order = order,
                get = function() return self.settings.addons[addon] end,
                set = function(_, value)
                    self.settings.addons[addon] = value
                    self:ApplySkins()
                end,
                disabled = function() return not self.settings.addons.enabled end,
            }
            order = order + 1
        end
    end
end

-- Event registration helper
function Skins:RegisterEvent(event, method)
    if type(method) == "string" and self[method] then
        method = self[method]
    end
    
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    self.eventFrame:RegisterEvent(event)
    self[event] = method
end

-- PLAYER_ENTERING_WORLD event handler
function Skins:OnPlayerEnteringWorld()
    -- Apply skins on login
    self:ApplySkins()
end

-- ADDON_LOADED event handler
function Skins:OnAddonLoaded(addonName)
    -- Check if loaded addon is one we support skinning
    if self.settings.addons[addonName:lower()] and self.settings.addons.enabled then
        -- Delay slightly to ensure addon UI is initialized
        C_Timer.After(0.5, function()
            self:ApplyAddonSkin(addonName:lower())
        end)
    end
    
    -- Apply Blizzard UI skins
    if self.settings.blizzard.enabled then
        self:ApplyBlizzardSkins()
    end
end

-- Set up hooks
function Skins:SetupHooks()
    -- Hook CreateFrame to skin new frames
    if not self.hookCreated then
        hooksecurefunc("CreateFrame", function(frameType, name, parent, template)
            if self.enabled and self.settings.advancedUI.enabled then
                -- Only process frames with names to avoid excessive skinning
                if name and type(name) == "string" then
                    C_Timer.After(0.1, function()
                        local frame = _G[name]
                        if frame then
                            self:ProcessNewFrame(frame, frameType, template)
                        end
                    end)
                end
            end
        end)
        
        self.hookCreated = true
    end
end

-- Process a newly created frame
function Skins:ProcessNewFrame(frame, frameType, template)
    -- Skip if we've already skinned this frame
    if frame.VUISkinned then return end
    
    -- Apply skins based on frame type and template
    if frameType == "Button" then
        self:SkinButton(frame)
    elseif (frameType == "Frame" or frameType == "ScrollFrame") and not template then
        -- Only skin standalone frames, not templates
        if frame:IsVisible() and frame:GetName() and not frame:IsForbidden() then
            -- Avoid skinning system frames
            if not frame:GetName():match("^Blizzard") then
                self:SkinFrame(frame)
            end
        end
    end
end

-- Apply all skins
function Skins:ApplySkins()
    if not self.enabled then return end
    
    -- Apply Blizzard UI skins
    if self.settings.blizzard.enabled then
        self:ApplyBlizzardSkins()
    end
    
    -- Apply addon skins
    if self.settings.addons.enabled then
        self:ApplyAddonSkins()
    end
end

-- Apply Blizzard UI skins
function Skins:ApplyBlizzardSkins()
    VUI:Print("Applying Blizzard UI skins")
    
    -- First initialize in core.lua
    if self.core and self.core.Initialize then
        self.core:Initialize()
    end
    
    -- Load all Blizzard UI skin files
    -- Load frames
    self:ApplyBlizzardSkin("actionbar", self.settings.blizzard.actionbars)
    self:ApplyBlizzardSkin("bags", self.settings.blizzard.bags)
    self:ApplyBlizzardSkin("character", self.settings.blizzard.character)
    self:ApplyBlizzardSkin("chat", self.settings.blizzard.chat)
    self:ApplyBlizzardSkin("collections", self.settings.blizzard.collections)
    self:ApplyBlizzardSkin("communities", self.settings.blizzard.communities)
    self:ApplyBlizzardSkin("dressingroom", self.settings.blizzard.dressingroom)
    self:ApplyBlizzardSkin("friends", self.settings.blizzard.friends)
    self:ApplyBlizzardSkin("gossip", self.settings.blizzard.gossip)
    self:ApplyBlizzardSkin("guild", self.settings.blizzard.guild)
    self:ApplyBlizzardSkin("help", self.settings.blizzard.help)
    self:ApplyBlizzardSkin("lfg", self.settings.blizzard.lfg)
    self:ApplyBlizzardSkin("loot", self.settings.blizzard.loot)
    self:ApplyBlizzardSkin("mail", self.settings.blizzard.mail)
    self:ApplyBlizzardSkin("merchant", self.settings.blizzard.merchant)
    self:ApplyBlizzardSkin("options", self.settings.blizzard.options)
    self:ApplyBlizzardSkin("pvp", self.settings.blizzard.pvp)
    self:ApplyBlizzardSkin("quest", self.settings.blizzard.quest)
    self:ApplyBlizzardSkin("spellbook", self.settings.blizzard.spellbook)
    self:ApplyBlizzardSkin("talent", self.settings.blizzard.talent)
    self:ApplyBlizzardSkin("taxi", self.settings.blizzard.taxi)
    self:ApplyBlizzardSkin("timemanager", self.settings.blizzard.timemanager)
    self:ApplyBlizzardSkin("tooltip", self.settings.blizzard.tooltip)
    self:ApplyBlizzardSkin("worldmap", self.settings.blizzard.worldmap)
    self:ApplyBlizzardSkin("frames", self.settings.blizzard.frames)
    self:ApplyBlizzardSkin("achievement", self.settings.blizzard.achievement)
    self:ApplyBlizzardSkin("encounterjournal", self.settings.blizzard.encounterjournal)
    self:ApplyBlizzardSkin("garrison", self.settings.blizzard.garrison)
    self:ApplyBlizzardSkin("calendar", self.settings.blizzard.calendar)
    self:ApplyBlizzardSkin("orderhall", self.settings.blizzard.orderhall)
    self:ApplyBlizzardSkin("archaeology", self.settings.blizzard.archaeology)
    self:ApplyBlizzardSkin("macro", self.settings.blizzard.macro)
    self:ApplyBlizzardSkin("binding", self.settings.blizzard.binding)
    self:ApplyBlizzardSkin("unitframes", true) -- Always enable unitframes
    self:ApplyBlizzardSkin("minimap", true) -- Always enable minimap
end

-- Apply a specific Blizzard skin
function Skins:ApplyBlizzardSkin(name, enabled)
    if not enabled then return end
    
    local func = self.blizzardSkinFuncs[name]
    if func then
        func()
    end
end

-- Apply addon skins
function Skins:ApplyAddonSkins()
    -- Check each enabled addon
    for addon, enabled in pairs(self.settings.addons) do
        if addon ~= "enabled" and enabled then
            self:ApplyAddonSkin(addon)
        end
    end
end

-- Apply skin to specific addon
function Skins:ApplyAddonSkin(addon)
    -- Check if addon is loaded
    local isLoaded = C_AddOns.IsAddOnLoaded(addon)
    if not isLoaded then
        -- Some addons have different names than their skin
        if addon == "bartender" and C_AddOns.IsAddOnLoaded("Bartender4") then
            isLoaded = true
        elseif addon == "omnicc" and C_AddOns.IsAddOnLoaded("OmniCC") then
            isLoaded = true
        elseif addon == "omnicd" and C_AddOns.IsAddOnLoaded("OmniCD") then
            isLoaded = true
        elseif addon == "angrykeystones" and C_AddOns.IsAddOnLoaded("AngryKeystones") then
            isLoaded = true
        elseif addon == "idtip" and C_AddOns.IsAddOnLoaded("idTip") then
            isLoaded = true
        elseif addon == "buffoverlay" and C_AddOns.IsAddOnLoaded("BuffOverlay") then
            isLoaded = true
        elseif addon == "moveany" and C_AddOns.IsAddOnLoaded("MoveAny") then
            isLoaded = true
        elseif addon == "trufigcd" and C_AddOns.IsAddOnLoaded("TrufiGCD") then
            isLoaded = true
        end
    end
    
    if not isLoaded then
        -- VUI:Print("Skipping skin for " .. addon .. " (not loaded)")
        return
    end
    
    -- Apply the skin
    local func = self.addonSkinFuncs[addon]
    if func then
        VUI:Print("Applying skin to addon: " .. addon)
        func()
    end
end

-- Reset all skins
function Skins:ResetSkins()
    -- Reset to defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings("skins", defaults)
    
    -- Apply skins with new settings
    self:ApplySkins()
    
    VUI:Print("Skin settings have been reset to defaults")
end

-- Function to register a skin module
function Skins:RegisterSkin(name, category)
    category = category or "Blizzard"
    local skin = {
        name = name,
        category = category,
        enabled = false,
        OnEnable = function() end,
        OnDisable = function() end,
        OnInitialize = function() end
    }
    
    self.registeredSkins[name] = skin
    
    -- Return the skin object for method chaining
    return skin
end

-- Initialize all registered skins
function Skins:InitializeSkins()
    VUI:Print("Initializing skins...")
    
    for name, skin in pairs(self.registeredSkins) do
        if type(skin.OnInitialize) == "function" then
            skin:OnInitialize()
        end
        
        -- Check if this skin should be enabled by default
        local category = skin.category:lower()
        local skinName = name:lower()
        
        if self.settings[category] and self.settings[category][skinName] then
            self:EnableSkin(name)
        end
    end
end

-- Enable a specific skin
function Skins:EnableSkin(name)
    local skin = self.registeredSkins[name]
    if not skin or skin.enabled then return end
    
    VUI:Print("Enabling skin: " .. name)
    
    -- Run the OnEnable function
    if type(skin.OnEnable) == "function" then
        skin:OnEnable()
    end
    
    skin.enabled = true
    self.activeSkins[name] = skin
end

-- Disable a specific skin
function Skins:DisableSkin(name)
    local skin = self.registeredSkins[name]
    if not skin or not skin.enabled then return end
    
    VUI:Print("Disabling skin: " .. name)
    
    -- Run the OnDisable function
    if type(skin.OnDisable) == "function" then
        skin:OnDisable()
    end
    
    skin.enabled = false
    self.activeSkins[name] = nil
end

-- Get a list of registered skins by category
function Skins:GetSkinsByCategory(category)
    local result = {}
    
    for name, skin in pairs(self.registeredSkins) do
        if skin.category == category then
            table.insert(result, skin)
        end
    end
    
    return result
end

-- Helper function to find a skin by category and name
function Skins:FindChild(category, name)
    category = category:lower()
    name = name:lower()
    
    for skinName, skin in pairs(self.registeredSkins) do
        if skin.category:lower() == category and skinName:lower() == name then
            return skin
        end
    end
    
    return nil
end

-- Load skin modules from directories
function Skins:LoadSkinModules()
    VUI:Print("Loading skin modules...")
    
    -- Load Blizzard skin modules
    self:LoadBlizzardSkins()
    
    -- Load Addon skin modules
    self:LoadAddonSkins()
end

-- Load Blizzard skin modules
function Skins:LoadBlizzardSkins()
    -- This would typically load skin modules from blizzard directory
    -- For simplicity, we'll just register skins directly
    
    -- Register core UI skins
    local actionBarSkin = self:RegisterSkin("ActionBar", "Blizzard")
    actionBarSkin.OnEnable = function()
        if self.blizzardSkinFuncs["actionbar"] then
            self.blizzardSkinFuncs["actionbar"]()
        end
    end
    
    local bagsSkin = self:RegisterSkin("Bags", "Blizzard")
    bagsSkin.OnEnable = function()
        if self.blizzardSkinFuncs["bags"] then
            self.blizzardSkinFuncs["bags"]()
        end
    end
    
    local unitframesSkin = self:RegisterSkin("UnitFrames", "Blizzard")
    unitframesSkin.OnEnable = function()
        if self.blizzardSkinFuncs["unitframes"] then
            self.blizzardSkinFuncs["unitframes"]()
        end
    end
    
    local minimapSkin = self:RegisterSkin("Minimap", "Blizzard")
    minimapSkin.OnEnable = function()
        if self.blizzardSkinFuncs["minimap"] then
            self.blizzardSkinFuncs["minimap"]()
        end
    end
end

-- Load Addon skin modules
function Skins:LoadAddonSkins()
    -- Register addon skins
    local bartenderSkin = self:RegisterSkin("Bartender", "Addons")
    bartenderSkin.OnEnable = function()
        if self.addonSkinFuncs["bartender"] then
            self.addonSkinFuncs["bartender"]()
        end
    end
    
    local classicuiSkin = self:RegisterSkin("ClassicUI", "Addons")
    classicuiSkin.OnEnable = function()
        if self.addonSkinFuncs["classicui"] then
            self.addonSkinFuncs["classicui"]()
        end
    end
    
    local auctionatorSkin = self:RegisterSkin("Auctionator", "Addons")
    auctionatorSkin.OnEnable = function()
        if self.addonSkinFuncs["auctionator"] then
            self.addonSkinFuncs["auctionator"]()
        end
    end
    
    local angrykeystone = self:RegisterSkin("AngryKeystone", "Addons")
    angrykeystone.OnEnable = function()
        if self.addonSkinFuncs["angrykeystones"] then
            self.addonSkinFuncs["angrykeystones"]()
        end
    end
    
    local omniccSkin = self:RegisterSkin("OmniCC", "Addons")
    omniccSkin.OnEnable = function()
        if self.addonSkinFuncs["omnicc"] then
            self.addonSkinFuncs["omnicc"]()
        end
    end
    
    local omnicdSkin = self:RegisterSkin("OmniCD", "Addons")
    omnicdSkin.OnEnable = function()
        if self.addonSkinFuncs["omnicd"] then
            self.addonSkinFuncs["omnicd"]()
        end
    end
    
    local trufigcdSkin = self:RegisterSkin("TrufiGCD", "Addons")
    trufigcdSkin.OnEnable = function()
        if self.addonSkinFuncs["trufigcd"] then
            self.addonSkinFuncs["trufigcd"]()
        end
    end
    
    local idtipSkin = self:RegisterSkin("IDTip", "Addons")
    idtipSkin.OnEnable = function()
        if self.addonSkinFuncs["idtip"] then
            self.addonSkinFuncs["idtip"]()
        end
    end
    
    local buffoSkin = self:RegisterSkin("BuffOverlay", "Addons")
    buffoSkin.OnEnable = function()
        if self.addonSkinFuncs["buffoverlay"] then
            self.addonSkinFuncs["buffoverlay"]()
        end
    end
    
    local moveAnySkin = self:RegisterSkin("MoveAny", "Addons")
    moveAnySkin.OnEnable = function()
        if self.addonSkinFuncs["moveany"] then
            self.addonSkinFuncs["moveany"]()
        end
    end
end

-- Register the module with VUI
VUI.skins = Skins