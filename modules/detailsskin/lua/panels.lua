local _, VUI = ...
local DS = VUI.detailsskin or {}
VUI.detailsskin = DS

-- Local references for performance
local _G = _G
local Details = _G.Details
local pairs = pairs
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Panel styling functions
DS.Panels = {}

-- Apply comprehensive styling to a Details! window
function DS.Panels:ApplyStyle(instance, theme)
    if not instance then return end
    
    -- Get theme settings
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    local settings = VUI.db.profile.modules.detailsskin
    local colors = DS:GetThemeColors(theme)
    local headerStyle = DS:GetHeaderStyle(theme)
    
    -- Style the instance container frame
    self:StyleWindowFrame(instance, colors, settings)
    
    -- Style the title bar/header
    self:StyleTitleBar(instance, headerStyle, settings)
    
    -- Style menu elements
    self:StyleMenuElements(instance, colors, settings)
    
    -- Style status bar
    self:StyleStatusBar(instance, colors, settings)
    
    -- Style rows
    self:StyleRows(instance, colors, settings, theme)
    
    -- Apply other customizations
    self:CustomizeWindow(instance, colors, settings, theme)
    
    -- Request a full refresh of the window
    instance:InstanceRefreshRows()
    instance:RefreshWindow()
end

-- Style the main window frame
function DS.Panels:StyleWindowFrame(instance, colors, settings)
    -- Frame backdrop
    -- Get textures from atlas if available
    if DS.Atlas and DS.Atlas.GetBackgroundTexture then
        -- Use atlas texture
        instance.baseframe.backdrop_texture = DS.Atlas:GetBackgroundTexture(VUI.db.profile.appearance.theme or "thunderstorm")
    else
        -- Fallback to regular texture path
        instance.baseframe.backdrop_texture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. 
                                            (VUI.db.profile.appearance.theme or "thunderstorm") .. "\\background"
    end
    instance.baseframe.backdrop_alpha = settings.backgroundOpacity
    
    -- Border
    instance.frame_border.alpha = settings.borderOpacity or 0.7
    instance.frame_border.color = {
        colors.border.r,
        colors.border.g,
        colors.border.b
    }
    
    -- Frame backdrop
    local borderTexture
    -- Get border texture from atlas if available
    if DS.Atlas and DS.Atlas.GetBorderTexture then
        borderTexture = DS.Atlas:GetBorderTexture()
    else
        borderTexture = "Interface\\AddOns\\VUI\\media\\textures\\border"
    end
    
    instance.frame_backdrop = {
        edgeFile = borderTexture,
        tileEdge = true,
        edgeSize = settings.borderSize or 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
        backdrop_color = {
            colors.backdrop.r,
            colors.backdrop.g, 
            colors.backdrop.b,
            settings.backdropAlpha or 0.7
        },
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            settings.borderAlpha or 0.5
        }
    }
    
    -- Update the actual backdrop
    instance:InstanceBackdrop()
end

-- Style the title bar/header
function DS.Panels:StyleTitleBar(instance, headerStyle, settings)
    if not settings.customHeader then 
        return 
    end
    
    -- Title bar settings
    instance.header_texture = headerStyle.texture
    instance.header_backdrop_texture = headerStyle.texture
    instance.header_bar_height = headerStyle.height
    
    -- Text settings
    instance.title_text_size = headerStyle.fontSize
    instance.title_text_color = {
        headerStyle.textColor.r,
        headerStyle.textColor.g,
        headerStyle.textColor.b,
        headerStyle.textColor.a or 1
    }
    
    -- Title bar background
    instance.title_backdrop_color = {
        headerStyle.backdropColor.r,
        headerStyle.backdropColor.g,
        headerStyle.backdropColor.b, 
        headerStyle.backdropColor.a or 0.9
    }
    
    -- Title bar border
    instance.title_border_color = {
        headerStyle.borderColor.r,
        headerStyle.borderColor.g,
        headerStyle.borderColor.b,
        headerStyle.borderColor.a or 0.8
    }
    
    -- Adjust title bar icons
    instance.menu_icons_size = headerStyle.iconSize
    
    -- Refresh the titlebar
    instance:InstanceRefreshRows()
end

-- Style menu elements
function DS.Panels:StyleMenuElements(instance, colors, settings)
    -- Menu backdrop
    local borderTexture
    -- Get border texture from atlas if available
    if DS.Atlas and DS.Atlas.GetBorderTexture then
        borderTexture = DS.Atlas:GetBorderTexture()
    else
        borderTexture = "Interface\\AddOns\\VUI\\media\\textures\\border"
    end
    
    instance.menu_backdrop = {
        edgeFile = borderTexture,
        tileEdge = true,
        edgeSize = settings.borderSize or 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
        backdrop_color = {
            colors.backdrop.r,
            colors.backdrop.g, 
            colors.backdrop.b,
            settings.backdropAlpha or 0.7
        },
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            settings.borderAlpha or 0.5
        }
    }
    
    -- Menu alpha settings
    instance.menu_alpha = {
        enabled = true,
        onenter = 1,
        onleave = 0.9,
        ignorebars = false
    }
    
    -- Menu icons color
    instance.menu_icons_color = {
        colors.text.r,
        colors.text.g,
        colors.text.b,
        0.9
    }
    
    -- Desaturate icons
    instance.desaturated_menu = false
    
    -- Menubar icon settings
    if instance.menu_icons then
        for _, icon in pairs(instance.menu_icons) do
            if icon.widget then
                icon.widget:SetDesaturated(false)
                icon.widget:SetVertexColor(
                    colors.text.r,
                    colors.text.g,
                    colors.text.b,
                    0.9
                )
            end
        end
    end
end

-- Style status bar
function DS.Panels:StyleStatusBar(instance, colors, settings)
    -- Status bar settings
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local statusbarTexture
    
    -- Get statusbar texture from atlas if available
    if DS.Atlas and DS.Atlas.GetStatusBarTexture then
        statusbarTexture = DS.Atlas:GetStatusBarTexture(theme)
    else
        statusbarTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\statusbar"
    end
    
    instance.statusbar_info = {
        texture = statusbarTexture,
        color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        }
    }
    
    -- Status bar background
    instance.statusbar_background_color = {
        colors.background.r,
        colors.background.g,
        colors.background.b,
        0.4
    }
    
    -- Status text color
    instance.statusbar_text_color = {
        colors.text.r,
        colors.text.g,
        colors.text.b,
        0.9
    }
    
    -- Refresh the statusbar
    if instance.statusbar then
        instance.statusbar:UpdateColors({
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        })
    end
end

-- Style data rows
function DS.Panels:StyleRows(instance, colors, settings, theme)
    -- Get theme-specific bar texture
    local barTexture = DS:GetBarTexture(theme)
    
    -- Row settings
    instance.bars_texture = barTexture
    instance.row_height = settings.rowHeight or 16
    
    -- Row info
    -- Get texture for row background from atlas if available
    local rowBackgroundTexture
    if DS.Atlas and DS.Atlas.GetBackgroundDarkTexture then
        rowBackgroundTexture = DS.Atlas:GetBackgroundDarkTexture(theme)
    else
        rowBackgroundTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background_dark"
    end
    
    -- Get border texture from atlas if available
    local rowBorderTexture
    if DS.Atlas and DS.Atlas.GetBorderDarkTexture then
        rowBorderTexture = DS.Atlas:GetBorderDarkTexture()
    else
        rowBorderTexture = "Interface\\AddOns\\VUI\\media\\textures\\border_dark"
    end
    
    instance.row_info = {
        -- Basic appearance
        texture = barTexture,
        texture_background = rowBackgroundTexture,
        backdrop = {
            enabled = settings.rowBackdrop or false,
            texture = rowBorderTexture,
            color = {0, 0, 0, 0.2},
            size = 1
        },
        
        -- Colors
        fixed_texture_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            settings.barAlpha or 0.9
        },
        fixed_texture_background_color = {
            colors.background.r * 0.6,
            colors.background.g * 0.6,
            colors.background.b * 0.6,
            settings.barBackgroundAlpha or 0.3
        },
        
        -- Text settings
        font_size = settings.fontSize or 10,
        font_size_percent = settings.fontSizePercent or 10,
        fixed_text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b
        },
        
        -- Icon settings
        start_after_icon = settings.startAfterIcon or true,
        icon_file = settings.iconFile or "Interface\\AddOns\\Details\\images\\classes_small_alpha",
        icon_size_offset = settings.iconSizeOffset or 0,
        
        -- Advanced settings
        alpha = 1,
        enabled = true,
        icon_file_custom = settings.customIconFile or "",
        icon_file_coords = {0, 1, 0, 1},
        color_by_arena_team = false,
        use_spec_icons = settings.useSpecIcons or false,
        texture_custom = settings.customTexture or "",
        texture_background_file = settings.backgroundTextureFile or "",
        texture_background_class_color = false,
        texture_custom_file = settings.customTextureFile or ""
    }
    
    -- Update default colors
    instance.default_bg_color = {
        colors.background.r,
        colors.background.g,
        colors.background.b,
        settings.backgroundAlpha or 0.5
    }
    
    instance.default_bg_color_unstable = {
        colors.background.r * 1.5,
        colors.background.g * 1.5,
        colors.background.b * 1.5,
        settings.backgroundAlpha or 0.5
    }
end

-- Additional window customizations
function DS.Panels:CustomizeWindow(instance, colors, settings, theme)
    -- Window grow direction
    instance.bars_grow_direction = settings.barsGrowDirection or 1
    
    -- Bar spacing
    instance.bars_spacement = settings.barSpacing or 1
    
    -- Hide the search bar when not in use
    instance.hide_search = settings.hideSearch or false
    
    -- Hide or show icons
    instance.hide_icon = settings.hideIcon or false
    
    -- Window alpha settings
    instance.window_alpha = settings.windowAlpha or 1
    instance.window_alpha_enabled = settings.windowAlphaEnabled or false
    
    -- Menu anchoring
    instance.menu_anchor = {
        side = settings.menuAnchorSide or 1,
        x = settings.menuAnchorX or 0,
        y = settings.menuAnchorY or 0
    }
    
    -- Text behavior
    instance.truncate_text = settings.truncateText or true
    instance.truncate_size = settings.truncateSize or 30
    
    -- Set micro displays at the bottom
    if settings.customMicroDisplays then
        instance.micro_displays_side = settings.microDisplaysSide or 2
        instance.micro_displays_size = settings.microDisplaysSize or 150
    end
end