-- VUI Skins Module - Initialization
local _, VUI = ...

-- Create the module using the module API
local Skins = VUI.ModuleAPI:CreateModule("skins")

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
    
    -- Cache for skinned elements
    self.skinnedFrames = {}
    
    -- Register for UI integration
    VUI.ModuleAPI:EnableModuleUI("skins", function(module)
        module:SetupHooks()
    end)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
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
    -- We'll implement specific Blizzard UI skinning in the next files
    
    -- For now, just print a message
    VUI:Print("Applying Blizzard UI skins")
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
    -- We'll implement specific addon skinning in the next files
    
    -- For now, just print a message
    VUI:Print("Applying skin to addon: " .. addon)
end

-- Reset all skins
function Skins:ResetSkins()
    -- Reset to defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings("skins", defaults)
    
    -- Apply skins with new settings
    self:ApplySkins()
    
    VUI:Print("Skin settings have been reset to defaults")
end

-- Register the module with VUI
VUI.skins = Skins