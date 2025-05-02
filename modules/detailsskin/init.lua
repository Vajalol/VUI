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
local isDetailsLoaded = false

-- Check if Details is loaded before proceeding
local function CheckDetailsLoaded()
    if _G.Details then
        isDetailsLoaded = true
        return true
    end
    return false
end

-- Function to apply the theme to all Details instances
function DetailsSkin:ApplyThemeToAll()
    if not CheckDetailsLoaded() then
        return false
    end
    
    local settings = self:GetSettings()
    if not settings.enabled then
        return false
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local numInstances = Details:GetNumInstances()
    
    for i = 1, numInstances do
        local instance = Details:GetInstance(i)
        if instance then
            self:ApplySkinToInstance(instance, theme)
        end
    end
    
    return true
end

-- Apply skin to a specific Details instance
function DetailsSkin:ApplySkinToInstance(instance, theme)
    if not instance then return false end
    
    local settings = self:GetSettings()
    
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
    
    -- Apply panel styling (frames, headers, footers)
    self.Panels:StyleWindowFrame(instance, self:GetThemeColors(theme), settings)
    self.Panels:StyleTitleBar(instance, self:GetHeaderStyle(theme), settings)
    self.Panels:StyleMenuElements(instance, self:GetThemeColors(theme), settings)
    self.Panels:StyleStatusBar(instance, self:GetThemeColors(theme), settings)
    self.Panels:StyleRows(instance, self:GetThemeColors(theme), settings, theme)
    self.Panels:CustomizeWindow(instance, self:GetThemeColors(theme), settings, theme)
    
    -- Apply graph styling if enabled
    if settings.styleGraphs then
        self.Graphs:ApplyStyle(instance, theme)
    end
    
    -- Request instance refresh
    instance:InstanceRefreshRows()
    instance:RefreshWindow()
    
    return true
end

-- Get module settings with defaults
function DetailsSkin:GetSettings()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.modules or not VUI.db.profile.modules.detailsskin then
        -- Return default settings if DB isn't loaded yet
        return {
            enabled = true,
            saveOriginal = true,
            backgroundOpacity = 0.7,
            borderSize = 1,
            customHeader = true,
            styleGraphs = true,
            useCustomTemplates = true,
            barAlpha = 0.9,
            rowHeight = 16,
            fontSize = 10
        }
    end
    
    return VUI.db.profile.modules.detailsskin
end

-- Main function to apply skin to Details
function DetailsSkin:ApplySkin(instance)
    -- If no instance is provided, try to apply to all instances
    if not instance then
        return self:ApplyThemeToAll()
    end
    
    local settings = self:GetSettings()
    if not settings.enabled then
        return false
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Call our comprehensive skin application function
    return self:ApplySkinToInstance(instance, theme)
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
    
    -- Use ThemeIntegration if available
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme(newTheme)
    else
        -- Legacy fallback
        -- Update all instances with the new theme
        self:ApplySkinToAllInstances()
        
        -- Update all plugin windows
        self:ApplySkinToPlugins()
    end
end

-- Apply skin to Details plugins
function DetailsSkin:ApplySkinToPlugins()
    if not Details then return end
    local settings = self:GetSettings()
    if not settings.enabled then return end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local colors = self:GetThemeColors(theme)
    
    -- Get textures using the atlas system if available
    local bgTexture = self:GetBackgroundTexture(theme)
    local borderTexture = self:GetBorderTexture()
    local titleTexture = self:GetTitleTexture(theme)
    
    -- Apply skin to all plugin frames
    if Details.PluginCount and Details.PluginCount > 0 then
        for i = 1, Details.PluginCount do
            local plugin = Details.tabela_plugins[i]
            if plugin and plugin.Frame then
                local frame = plugin.Frame
                
                -- Apply border and background
                if not frame.VUISkinned then
                    -- Skip plugins that don't want to be skinned
                    if not plugin.NoFrameSkin then
                        -- Apply theme backdrop with atlas textures
                        frame:SetBackdrop({
                            edgeFile = borderTexture, 
                            tileEdge = true,
                            edgeSize = settings.borderSize or 1,
                            bgFile = bgTexture,
                            insets = {left = 3, right = 3, top = 3, bottom = 3}
                        })
                        
                        -- Apply theme colors
                        frame:SetBackdropBorderColor(
                            colors.border.r,
                            colors.border.g,
                            colors.border.b,
                            settings.borderOpacity or 0.7
                        )
                        frame:SetBackdropColor(
                            colors.background.r,
                            colors.background.g,
                            colors.background.b,
                            settings.backgroundOpacity or 0.5
                        )
                        
                        -- Apply theme to title bar if it exists
                        if frame.TitleBar then
                            frame.TitleBar:SetTexture(titleTexture)
                        end
                        
                        -- Mark as skinned
                        frame.VUISkinned = true
                        frame.VUITheme = theme -- Store current theme
                    end
                else
                    -- Check if theme changed and update textures if needed
                    if frame.VUITheme ~= theme then
                        -- Update textures with new theme
                        frame:SetBackdrop({
                            edgeFile = borderTexture, 
                            tileEdge = true,
                            edgeSize = settings.borderSize or 1,
                            bgFile = bgTexture,
                            insets = {left = 3, right = 3, top = 3, bottom = 3}
                        })
                        
                        -- Update title bar texture if it exists
                        if frame.TitleBar then
                            frame.TitleBar:SetTexture(titleTexture)
                        end
                        
                        frame.VUITheme = theme
                    end
                    
                    -- Update colors
                    frame:SetBackdropBorderColor(
                        colors.border.r,
                        colors.border.g,
                        colors.border.b,
                        settings.borderOpacity or 0.7
                    )
                    frame:SetBackdropColor(
                        colors.background.r,
                        colors.background.g,
                        colors.background.b,
                        settings.backgroundOpacity or 0.5
                    )
                end
            end
        end
    end
end

-- Function called by ThemeIntegration to style plugin frames
function DetailsSkin:StylizePluginFrames(theme, backgroundTexture, borderTexture)
    if not Details then return end
    local settings = self:GetSettings()
    if not settings.enabled then return end
    
    -- Use passed textures or get them from our atlas
    local bgTexture = backgroundTexture or self:GetBackgroundTexture(theme)
    local edgeTexture = borderTexture or self:GetBorderTexture()
    local titleTexture = self:GetTitleTexture(theme)
    local colors = self:GetThemeColors(theme)
    
    -- Apply skin to all plugin frames
    if Details.PluginCount and Details.PluginCount > 0 then
        for i = 1, Details.PluginCount do
            local plugin = Details.tabela_plugins[i]
            if plugin and plugin.Frame then
                local frame = plugin.Frame
                
                -- Skip plugins that don't want to be skinned
                if not plugin.NoFrameSkin then
                    -- Apply theme backdrop with atlas textures
                    frame:SetBackdrop({
                        edgeFile = edgeTexture, 
                        tileEdge = true,
                        edgeSize = settings.borderSize or 1,
                        bgFile = bgTexture,
                        insets = {left = 3, right = 3, top = 3, bottom = 3}
                    })
                    
                    -- Apply theme colors
                    frame:SetBackdropBorderColor(
                        colors.border.r,
                        colors.border.g,
                        colors.border.b,
                        settings.borderOpacity or 0.7
                    )
                    
                    frame:SetBackdropColor(
                        colors.background.r,
                        colors.background.g,
                        colors.background.b,
                        settings.backgroundOpacity or 0.5
                    )
                    
                    -- Apply theme to title bar if it exists
                    if frame.TitleBar then
                        frame.TitleBar:SetTexture(titleTexture)
                    end
                    
                    -- Mark as skinned
                    frame.VUISkinned = true
                    frame.VUITheme = theme -- Store current theme
                end
            end
        end
    end
    
    return true
end

-- Initialize the module
function DetailsSkin:Initialize()
    -- Only initialize if Details! is loaded
    if not Details then
        print("|cff1784d1VUI DetailsSkin|r: Details! not found. Module will activate when Details! loads.")
        return
    end
    
    -- Register theme textures
    self:RegisterThemeMedia()
    
    -- Initialize report templates if enabled
    if self:GetSettings().useCustomTemplates then
        self.Reports:Initialize()
    end
    
    -- Initialize theme integration
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Register for theme changes (legacy support)
    if VUI.ThemeIntegration and VUI.ThemeIntegration.RegisterThemeChangeCallback then
        VUI.ThemeIntegration:RegisterThemeChangeCallback(function(newTheme)
            DetailsSkin:OnThemeChanged(newTheme)
        end)
    end
    
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

-- Convenience functions to access theme data
function DetailsSkin:GetThemeColors(theme)
    return self.Themes.GetThemeColors(theme)
end

function DetailsSkin:GetHeaderStyle(theme)
    return self.Themes.GetHeaderStyle(theme)
end

function DetailsSkin:GetBarTexture(theme)
    -- Use atlas texture if available
    if self.Atlas and self.Atlas.GetBarTexture then
        return self.Atlas:GetBarTexture(theme)
    end
    -- Fallback to traditional texture path
    return self.Themes.GetBarTexture(theme)
end

function DetailsSkin:GetTitleTexture(theme)
    -- Use atlas texture if available
    if self.Atlas and self.Atlas.GetTitleTexture then
        return self.Atlas:GetTitleTexture(theme)
    end
    -- Fallback to traditional texture path
    local headerStyle = self:GetHeaderStyle(theme)
    return headerStyle and headerStyle.texture
end

function DetailsSkin:GetBackgroundTexture(theme)
    -- Use atlas texture if available
    if self.Atlas and self.Atlas.GetBackgroundTexture then
        return self.Atlas:GetBackgroundTexture(theme)
    end
    -- Fallback to traditional texture path
    return "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. (theme or "thunderstorm") .. "\\background.tga"
end

function DetailsSkin:GetBorderTexture()
    -- Use atlas texture if available
    if self.Atlas and self.Atlas.GetBorderTexture then
        return self.Atlas:GetBorderTexture()
    end
    -- Fallback to traditional texture path
    return "Interface\\AddOns\\VUI\\media\\textures\\border.tga"
end

function DetailsSkin:GetAnimationSettings(theme)
    return self.Themes.GetAnimationSettings(theme)
end

function DetailsSkin:GetAnimTexture(theme, animType)
    -- Use atlas texture if available
    if self.Atlas and self.Atlas.GetAnimTexture then
        return self.Atlas:GetAnimTexture(theme, animType)
    end
    -- Fallback to traditional texture path
    local animations = self.Themes.GetAnimationSettings(theme)
    return animations and animations[animType]
end

function DetailsSkin:RegisterThemeMedia()
    self.Themes.RegisterThemeMedia()
    
    -- Register atlas textures if available
    if self.Atlas and self.Atlas.RegisterAtlas then
        self.Atlas:RegisterAtlas()
    end
end

-- Get atlas performance statistics
function DetailsSkin:GetAtlasStats()
    if self.Atlas and self.Atlas.GetStats then
        return self.Atlas:GetStats()
    end
    return {
        textureLoads = 0,
        atlasHits = 0,
        cacheMisses = 0,
        memoryEstimatedSaved = 0
    }
end

-- Reset atlas statistics
function DetailsSkin:ResetAtlasStats()
    if self.Atlas and self.Atlas.ResetStats then
        self.Atlas:ResetStats()
        return true
    end
    return false
end

-- Configuration getter for the options panel
function DetailsSkin:GetConfig()
    local settings = self:GetSettings()
    
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
            appearanceGroup = {
                type = "group",
                name = "Appearance",
                inline = true,
                order = 4,
                args = {
                    customHeader = {
                        type = "toggle",
                        name = "Custom Headers",
                        desc = "Use theme-specific header styling",
                        get = function() return settings.customHeader end,
                        set = function(_, val)
                            settings.customHeader = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 1
                    },
                    styleGraphs = {
                        type = "toggle",
                        name = "Style Graphs",
                        desc = "Apply theme styling to Details graphs and charts",
                        get = function() return settings.styleGraphs end,
                        set = function(_, val)
                            settings.styleGraphs = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 2
                    },
                    useCustomTemplates = {
                        type = "toggle",
                        name = "Custom Report Templates",
                        desc = "Use theme-specific templates when sharing reports",
                        get = function() return settings.useCustomTemplates end,
                        set = function(_, val)
                            settings.useCustomTemplates = val
                            if val then
                                DetailsSkin.Reports:Initialize()
                            end
                        end,
                        width = "full",
                        order = 3
                    },
                    backgroundOpacity = {
                        type = "range",
                        name = "Background Opacity",
                        desc = "Set the opacity of the window background",
                        min = 0, max = 1, step = 0.05,
                        get = function() return settings.backgroundOpacity end,
                        set = function(_, val)
                            settings.backgroundOpacity = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 4
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
                        order = 5
                    },
                    borderSize = {
                        type = "range",
                        name = "Border Size",
                        desc = "Set the thickness of window borders",
                        min = 0, max = 5, step = 1,
                        get = function() return settings.borderSize end,
                        set = function(_, val)
                            settings.borderSize = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 6
                    }
                }
            },
            barGroup = {
                type = "group",
                name = "Bars and Rows",
                inline = true,
                order = 5,
                args = {
                    rowHeight = {
                        type = "range",
                        name = "Row Height",
                        desc = "Set the height of data rows",
                        min = 10, max = 30, step = 1,
                        get = function() return settings.rowHeight end,
                        set = function(_, val)
                            settings.rowHeight = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 1
                    },
                    barAlpha = {
                        type = "range",
                        name = "Bar Opacity",
                        desc = "Set the opacity of data bars",
                        min = 0, max = 1, step = 0.05,
                        get = function() return settings.barAlpha end,
                        set = function(_, val)
                            settings.barAlpha = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 2
                    },
                    fontSize = {
                        type = "range",
                        name = "Font Size",
                        desc = "Set the size of text on data rows",
                        min = 8, max = 16, step = 1,
                        get = function() return settings.fontSize end,
                        set = function(_, val)
                            settings.fontSize = val
                            DetailsSkin:ApplySkinToAllInstances()
                        end,
                        width = "full",
                        order = 3
                    }
                }
            },
            advancedGroup = {
                type = "group",
                name = "Advanced",
                inline = true,
                order = 6,
                args = {
                    saveOriginal = {
                        type = "toggle",
                        name = "Save Original Skin",
                        desc = "Save the original Details skin for restoration when disabled",
                        get = function() return settings.saveOriginal end,
                        set = function(_, val)
                            settings.saveOriginal = val
                        end,
                        width = "full",
                        order = 1
                    },
                    resetButton = {
                        type = "execute",
                        name = "Refresh All Windows",
                        desc = "Reapply skin to all Details windows",
                        func = function()
                            DetailsSkin:ApplySkinToAllInstances()
                            DetailsSkin:ApplySkinToPlugins()
                        end,
                        width = "full",
                        order = 2
                    }
                }
            }
        }
    }
    
    return options
end

-- Hook initialization when addon is ready
if VUI.initialized then
    DetailsSkin:Initialize()
else
    VUI:RegisterCallback("OnInitialized", function()
        DetailsSkin:Initialize()
    end)
end