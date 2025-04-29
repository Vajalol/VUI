local _, VUI = ...

-- Initialize the DetailsSkin module
local DetailsSkin = VUI.detailsskin or {}
VUI.detailsskin = DetailsSkin

-- Localize frequently used globals
local _G = _G
local Details = _G.Details

-- Module information
DetailsSkin.name = "DetailsSkin"
DetailsSkin.description = "Skins the Details! damage meter with VUI's theme."
DetailsSkin.version = VUI.version
DetailsSkin.author = "VUI Team"

-- Internal state
local initialSkinComplete = false
local skinTimer = nil

-- Create a function that applies the skin to Details
function DetailsSkin:ApplySkin(instance)
    if not instance then return end
    
    local settings = VUI.db.profile.modules.detailsskin
    if not settings.enabled then return end
    
    -- Save the original skin for restoration if needed
    if settings.saveOriginal and not instance._originalSkin then
        instance._originalSkin = {
            bars_texture = instance.bars_texture,
            row_height = instance.row_height,
            row_info = CopyTable(instance.row_info),
            frame_backdrop = CopyTable(instance.frame_backdrop),
            statusbar_info = CopyTable(instance.statusbar_info),
            menu_backdrop = CopyTable(instance.menu_backdrop)
        }
    end
    
    -- Get current theme
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Apply common settings to all themes
    instance.backdrop_texture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background"
    instance.backdrop_alpha = settings.backgroundOpacity
    
    -- Row and bar settings
    if settings.customBarTexture then
        instance.bars_texture = VUI.LSM:Fetch("statusbar", settings.barTexture)
    else
        -- Use the theme-specific bar texture
        instance.bars_texture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\statusbar_details"
    end
    
    if settings.fixedHeight then
        instance.row_height = settings.rowHeight
    end
    
    -- Update row info
    instance.row_info.alpha = settings.rowOpacity
    instance.row_info.fixed_texture_background_color = {0, 0, 0, 0}
    
    -- Apply theme-specific row texture
    instance.row_info.texture_background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\row_texture"
    
    -- Apply theme-specific colors based on the theme
    local themeColors = {
        ["thunderstorm"] = {r = 0.05, g = 0.62, b = 0.9, a = 1}, -- Electric blue
        ["phoenixflame"] = {r = 0.9, g = 0.3, b = 0.05, a = 1},  -- Fiery orange
        ["arcanemystic"] = {r = 0.62, g = 0.05, b = 0.9, a = 1}, -- Violet purple
        ["felenergy"] = {r = 0.1, g = 1.0, b = 0.1, a = 1}       -- Fel green
    }
    
    -- Apply theme color to certain UI elements
    if themeColors[theme] then
        instance.row_info.fixed_texture_color = themeColors[theme]
        
        -- Only apply these if not using class colors
        if not instance.row_info.texture_class_colors then
            instance.row_info.texture_background_class_color = false
            instance.row_info.textL_class_colors = false
            instance.row_info.textR_class_colors = false
        end
    end
    
    if settings.customFonts then
        instance.row_info.font_face = VUI.LSM:Fetch("font", settings.rowFont)
        instance.row_info.font_size = settings.fontSize
    end
    
    if settings.customSpacing then
        instance.row_info.space.between = settings.rowSpacing
    end
    
    -- Frame and border settings
    instance.frame_backdrop = {
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\border", 
        tileEdge = true,
        edgeSize = 12,
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background",
        insets = {left = 3, right = 3, top = 3, bottom = 3}
    }
    
    instance.frame_backdrop_color = {0.1, 0.1, 0.1, settings.borderOpacity}
    
    -- Status bar settings
    instance.statusbar_info = {
        overlay = {
            texture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\highlight_details",
            color = {0.7, 0.7, 0.7, 0.5},
            texture_coordinates = {0, 1, 0, 0.5},
            enabled = true
        },
        alpha = settings.statusBarOpacity,
        texture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\statusbar_details"
    }
    
    -- Menu backdrop
    instance.menu_backdrop = {
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\border", 
        tileEdge = true, 
        edgeSize = 8, 
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background",
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    }
    
    instance.menu_backdrop_color = {0.05, 0.05, 0.05, settings.menuOpacity}
    
    -- Apply skin changes
    if instance.RefreshSkin then
        instance:RefreshSkin()
    end
    
    -- Apply title bar texture
    local titleBar = instance.baseframe.cabecalho.border
    if titleBar then
        titleBar:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\titlebar")
    end
    
    -- Apply style-specific customizations
    if settings.skinStyle == "ElvUI" then
        -- ElvUI-like style additions
        instance.row_info.texture_background_class_color = false
        instance.row_info.no_icon_backdrop = true
        instance.row_info.texture_background = ""
    end
end

-- Apply skin to all Details instances
function DetailsSkin:ApplySkinToAllInstances()
    if not Details then return end
    
    local instances = Details:GetAllInstances()
    for _, instance in ipairs(instances) do
        self:ApplySkin(instance)
    end
    
    initialSkinComplete = true
end

-- Theme changed handler - update skins when theme changes
function DetailsSkin:OnThemeChanged(newTheme)
    if not Details then return end
    
    -- Update all instances with the new theme
    self:ApplySkinToAllInstances()
    
    -- Update all plugin windows
    self:ApplySkinToPlugins()
end

-- Apply skin to Details plugins
function DetailsSkin:ApplySkinToPlugins()
    if not Details then return end
    local settings = VUI.db.profile.modules.detailsskin
    if not settings.enabled then return end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Apply skin to all plugin frames
    if Details.PluginCount and Details.PluginCount > 0 then
        for i = 1, Details.PluginCount do
            local plugin = Details.tabela_plugins[i]
            if plugin and plugin.Frame then
                local frame = plugin.Frame
                
                -- Apply border and background
                if not frame.VUISkinned then
                    -- Skip plugins that don't want to be skinned
                    if not plugin.NoFrameSkinn then
                        -- Apply theme backdrop
                        frame:SetBackdrop({
                            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\border", 
                            tileEdge = true,
                            edgeSize = 12,
                            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background",
                            insets = {left = 3, right = 3, top = 3, bottom = 3}
                        })
                        
                        -- Apply theme colors
                        local themeColors = {
                            ["thunderstorm"] = {0.05, 0.62, 0.9, settings.borderOpacity}, -- Electric blue
                            ["phoenixflame"] = {0.9, 0.3, 0.05, settings.borderOpacity},  -- Fiery orange
                            ["arcanemystic"] = {0.62, 0.05, 0.9, settings.borderOpacity}, -- Violet purple
                            ["felenergy"] = {0.1, 1.0, 0.1, settings.borderOpacity}       -- Fel green
                        }
                        
                        frame:SetBackdropBorderColor(unpack(themeColors[theme] or {0.1, 0.1, 0.1, settings.borderOpacity}))
                        frame:SetBackdropColor(0.1, 0.1, 0.1, settings.backgroundOpacity)
                        
                        -- Apply theme to title bar if it exists
                        if frame.TitleBar then
                            frame.TitleBar:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\titlebar")
                        end
                        
                        -- Mark as skinned
                        frame.VUISkinned = true
                    end
                end
            end
        end
    end
end

-- Initialize the module
function DetailsSkin:Initialize()
    -- Only initialize if Details! is loaded
    if not Details then
        print("|cff1784d1VUI DetailsSkin|r: Details! not found. Module will activate when Details! loads.")
        return
    end
    
    -- Register for theme changes
    VUI.ThemeIntegration:RegisterThemeChangeCallback(function(newTheme)
        DetailsSkin:OnThemeChanged(newTheme)
    end)
    
    -- Hook Details instance creation to apply skin to new instances
    if Details.CreateInstance then
        hooksecurefunc(Details, "CreateInstance", function(self, instance)
            C_Timer.After(0.5, function()
                DetailsSkin:ApplySkin(instance)
            end)
        end)
    end
    
    -- Hook plugin frames creation
    if Details.CreatePluginFrames then
        hooksecurefunc(Details, "CreatePluginFrames", function(self, plugin)
            C_Timer.After(0.5, function()
                DetailsSkin:ApplySkinToPlugins()
            end)
        end)
    end
    
    -- Initial skin application with a slight delay to ensure Details is fully loaded
    C_Timer.After(1, function() 
        DetailsSkin:ApplySkinToAllInstances()
        DetailsSkin:ApplySkinToPlugins()
    end)
    
    -- Set a repeating timer to catch any newly created instances and plugins
    skinTimer = C_Timer.NewTicker(5, function()
        if not initialSkinComplete then
            DetailsSkin:ApplySkinToAllInstances()
            DetailsSkin:ApplySkinToPlugins()
        end
    end, 6) -- Try for 30 seconds
    
    print("|cff1784d1VUI DetailsSkin|r module initialized.")
end

-- Configuration getter for the options panel
function DetailsSkin:GetConfig()
    local settings = VUI.db.profile.modules.detailsskin
    
    local options = {
        type = "group",
        name = "DetailsSkin",
        desc = "Configure the Details! Damage Meter skin",
        args = {
            header = {
                type = "header",
                name = "DetailsSkin " .. DetailsSkin.version,
                order = 1
            },
            desc = {
                type = "description",
                name = "Customize the appearance of Details! Damage Meter windows to match your VUI theme.",
                order = 2
            },
            preview = {
                type = "execute",
                name = "",
                desc = "Preview of the DetailsSkin module",
                image = "Interface\\AddOns\\VUI\\media\\textures\\config\\detailsskin_preview.svg",
                imageWidth = 240,
                imageHeight = 120,
                func = function() end,
                order = 2.5
            },
            enabled = {
                type = "toggle",
                name = "Enable DetailsSkin",
                desc = "Enable or disable the Details! skin",
                get = function() return settings.enabled end,
                set = function(_, val)
                    settings.enabled = val
                    if val then
                        DetailsSkin:ApplySkinToAllInstances()
                        DetailsSkin:ApplySkinToPlugins()
                    else
                        -- Restore original skins if disabled
                        if Details then
                            local instances = Details:GetAllInstances()
                            for _, instance in ipairs(instances) do
                                if instance._originalSkin then
                                    for k, v in pairs(instance._originalSkin) do
                                        instance[k] = v
                                    end
                                    if instance.RefreshSkin then
                                        instance:RefreshSkin()
                                    end
                                end
                            end
                        end
                    end
                end,
                width = "full",
                order = 3
            },
            skinStyle = {
                type = "select",
                name = "Skin Style",
                desc = "Choose the base style for the skin",
                values = {
                    ["ElvUI"] = "ElvUI Style",
                    ["Standard"] = "Standard Style",
                    ["Compact"] = "Compact Style"
                },
                get = function() return settings.skinStyle end,
                set = function(_, val)
                    settings.skinStyle = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 4
            },
            saveOriginal = {
                type = "toggle",
                name = "Save Original Settings",
                desc = "Save the original skin settings for restoration when the module is disabled",
                get = function() return settings.saveOriginal end,
                set = function(_, val)
                    settings.saveOriginal = val
                end,
                width = "full",
                order = 5
            },
            opacityHeader = {
                type = "header",
                name = "Opacity Settings",
                order = 10
            },
            backgroundOpacity = {
                type = "range",
                name = "Background Opacity",
                desc = "Set the opacity of window backgrounds",
                min = 0, max = 1, step = 0.05,
                get = function() return settings.backgroundOpacity end,
                set = function(_, val)
                    settings.backgroundOpacity = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 11
            },
            rowOpacity = {
                type = "range",
                name = "Row Opacity",
                desc = "Set the opacity of data rows",
                min = 0, max = 1, step = 0.05,
                get = function() return settings.rowOpacity end,
                set = function(_, val)
                    settings.rowOpacity = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 12
            },
            menuOpacity = {
                type = "range",
                name = "Menu Opacity",
                desc = "Set the opacity of dropdown menus",
                min = 0, max = 1, step = 0.05,
                get = function() return settings.menuOpacity end,
                set = function(_, val)
                    settings.menuOpacity = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 13
            },
            borderOpacity = {
                type = "range",
                name = "Border Opacity",
                desc = "Set the opacity of window borders",
                min = 0, max = 1, step = 0.05,
                get = function() return settings.borderOpacity end,
                set = function(_, val)
                    settings.borderOpacity = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 14
            },
            statusBarOpacity = {
                type = "range",
                name = "Status Bar Opacity",
                desc = "Set the opacity of status bars",
                min = 0, max = 1, step = 0.05,
                get = function() return settings.statusBarOpacity end,
                set = function(_, val)
                    settings.statusBarOpacity = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 15
            },
            textureHeader = {
                type = "header",
                name = "Bar Settings",
                order = 20
            },
            customBarTexture = {
                type = "toggle",
                name = "Use Custom Bar Texture",
                desc = "Override the default bar texture with a custom one",
                get = function() return settings.customBarTexture end,
                set = function(_, val)
                    settings.customBarTexture = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 21
            },
            barTexture = {
                type = "select",
                dialogControl = "LSM30_Statusbar",
                name = "Bar Texture",
                desc = "Choose the texture for data bars",
                values = function() return VUI.LSM:HashTable("statusbar") end,
                get = function() return settings.barTexture end,
                set = function(_, val)
                    settings.barTexture = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 22,
                disabled = function() return not settings.customBarTexture end
            },
            fontHeader = {
                type = "header",
                name = "Font Settings",
                order = 30
            },
            customFonts = {
                type = "toggle",
                name = "Use Custom Fonts",
                desc = "Override the default fonts with custom ones",
                get = function() return settings.customFonts end,
                set = function(_, val)
                    settings.customFonts = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 31
            },
            rowFont = {
                type = "select",
                dialogControl = "LSM30_Font",
                name = "Row Font",
                desc = "Choose the font for data rows",
                values = function() return VUI.LSM:HashTable("font") end,
                get = function() return settings.rowFont end,
                set = function(_, val)
                    settings.rowFont = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 32,
                disabled = function() return not settings.customFonts end
            },
            fontSize = {
                type = "range",
                name = "Font Size",
                desc = "Set the size of data text",
                min = 6, max = 20, step = 1,
                get = function() return settings.fontSize end,
                set = function(_, val)
                    settings.fontSize = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 33,
                disabled = function() return not settings.customFonts end
            },
            layoutHeader = {
                type = "header",
                name = "Layout Settings",
                order = 40
            },
            fixedHeight = {
                type = "toggle",
                name = "Use Fixed Row Height",
                desc = "Override the default row height with a custom value",
                get = function() return settings.fixedHeight end,
                set = function(_, val)
                    settings.fixedHeight = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 41
            },
            rowHeight = {
                type = "range",
                name = "Row Height",
                desc = "Set the height of data rows",
                min = 8, max = 30, step = 1,
                get = function() return settings.rowHeight end,
                set = function(_, val)
                    settings.rowHeight = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 42,
                disabled = function() return not settings.fixedHeight end
            },
            customSpacing = {
                type = "toggle",
                name = "Use Custom Row Spacing",
                desc = "Override the default spacing between rows",
                get = function() return settings.customSpacing end,
                set = function(_, val)
                    settings.customSpacing = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 43
            },
            rowSpacing = {
                type = "range",
                name = "Row Spacing",
                desc = "Set the space between data rows",
                min = 0, max = 10, step = 1,
                get = function() return settings.rowSpacing end,
                set = function(_, val)
                    settings.rowSpacing = val
                    DetailsSkin:ApplySkinToAllInstances()
                end,
                width = "full",
                order = 44,
                disabled = function() return not settings.customSpacing end
            },
            applyButton = {
                type = "execute",
                name = "Apply Skin Now",
                desc = "Apply skin settings to all Details! windows immediately",
                func = function() 
                    DetailsSkin:ApplySkinToAllInstances()
                    DetailsSkin:ApplySkinToPlugins()
                end,
                width = "full",
                order = 50
            }
        }
    }
    
    return options
end

-- Register the module with the VUI core
VUI:RegisterModule("DetailsSkin", DetailsSkin)