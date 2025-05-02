local _, VUI = ...

-- The War Within Skin Module for DetailsSkin
local DetailsSkin = VUI.detailsskin
local WarWithinSkin = {}
DetailsSkin.WarWithin = WarWithinSkin

-- Credit information
WarWithinSkin.originalAuthor = "Resike"
WarWithinSkin.originalAddon = "Details: Skin The War Within"
WarWithinSkin.originalURL = "https://www.curseforge.com/wow/addons/details-skin-the-war-within"

-- Skin config and settings
WarWithinSkin.skinName = "TheWarWithin"
WarWithinSkin.skinDisplayName = "The War Within"
WarWithinSkin.skinDescription = "An authentic skin inspired by Resike's The War Within theme"

-- Path constants for textures
local TEXTURE_PATH = "Interface\\AddOns\\VUI\\media\\textures\\detailsskin\\warwithin\\"

-- Available textures (placeholder paths until we integrate the actual textures)
WarWithinSkin.textures = {
    barTexture = TEXTURE_PATH .. "bar.tga",
    backgroundTexture = TEXTURE_PATH .. "background.tga",
    borderTexture = TEXTURE_PATH .. "border.tga",
    titleBarTexture = TEXTURE_PATH .. "title.tga",
    statusBarTexture = TEXTURE_PATH .. "statusbar.tga",
}

-- Color scheme for The War Within theme
WarWithinSkin.colors = {
    border = {r = 0.5, g = 0.3, b = 0.15, a = 1.0},         -- Rustic bronze
    background = {r = 0.08, g = 0.08, b = 0.12, a = 0.95},  -- Dark slate
    highlight = {r = 0.7, g = 0.5, b = 0.3, a = 0.8},       -- Golden highlight
    text = {r = 0.95, g = 0.95, b = 0.95, a = 1.0},         -- Almost white text
    title = {r = 0.9, g = 0.8, b = 0.6, a = 1.0},           -- Light gold title
    statusbar = {r = 0.12, g = 0.12, b = 0.18, a = 0.9},    -- Slightly lighter background
}

-- Apply the War Within skin to an instance
function WarWithinSkin:ApplySkin(instance)
    if not instance then return false end
    
    -- Save original skin if needed
    if DetailsSkin:GetSettings().saveOriginal and not instance._originalSkin then
        instance._originalSkin = {
            bars_texture = instance.bars_texture,
            row_height = instance.row_height,
            row_info = CopyTable(instance.row_info),
            frame_backdrop = CopyTable(instance.frame_backdrop),
            statusbar_info = CopyTable(instance.statusbar_info),
            menu_backdrop = CopyTable(instance.menu_backdrop)
        }
    end
    
    -- Apply frame styling
    self:StyleWindowFrame(instance)
    self:StyleTitleBar(instance)
    self:StyleMenuElements(instance)
    self:StyleStatusBar(instance)
    self:StyleRows(instance)
    
    -- Apply fonts
    self:StyleFonts(instance)
    
    -- Update instance
    instance:InstanceRefreshRows()
    instance:RefreshWindow()
    
    return true
end

-- Style the main window frame
function WarWithinSkin:StyleWindowFrame(instance)
    -- Set frame backdrop
    instance.frame_backdrop = {
        bgFile = self.textures.backgroundTexture,
        edgeFile = self.textures.borderTexture,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    
    -- Apply backdrop to instance
    instance:InstanceBackdrop(
        self.textures.backgroundTexture,
        self.textures.borderTexture,
        self.colors.background.r,
        self.colors.background.g,
        self.colors.background.b,
        self.colors.background.a,
        self.colors.border.r,
        self.colors.border.g,
        self.colors.border.b,
        self.colors.border.a,
        16,
        {left = 4, right = 4, top = 4, bottom = 4}
    )
    
    -- Apply frame color with The War Within colors
    instance:SetFrameColor(
        self.colors.background.r,
        self.colors.background.g,
        self.colors.background.b,
        self.colors.background.a
    )
    
    -- Apply border color
    instance:SetFrameStrata("LOW")
    instance:SetBackdropBorderColor(
        self.colors.border.r,
        self.colors.border.g,
        self.colors.border.b,
        self.colors.border.a
    )
end

-- Style title bar
function WarWithinSkin:StyleTitleBar(instance)
    -- Set title bar texture and color
    if instance.titleBar and instance.titleBar.texture then
        instance.titleBar.texture:SetTexture(self.textures.titleBarTexture)
    end
    
    -- Set title text color
    if instance.baseframe and instance.baseframe.cabecalho and instance.baseframe.cabecalho.texto then
        instance.baseframe.cabecalho.texto:SetTextColor(
            self.colors.title.r,
            self.colors.title.g,
            self.colors.title.b,
            self.colors.title.a
        )
    end
end

-- Style menu elements
function WarWithinSkin:StyleMenuElements(instance)
    -- Set menu backdrop
    instance.menu_backdrop = {
        bgFile = self.textures.backgroundTexture,
        edgeFile = self.textures.borderTexture,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    
    -- Apply to menu frames
    if instance.menu_anchor then
        instance.menu_anchor:SetBackdrop({
            bgFile = self.textures.backgroundTexture,
            edgeFile = self.textures.borderTexture,
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        
        instance.menu_anchor:SetBackdropColor(
            self.colors.background.r,
            self.colors.background.g,
            self.colors.background.b,
            self.colors.background.a
        )
        
        instance.menu_anchor:SetBackdropBorderColor(
            self.colors.border.r,
            self.colors.border.g,
            self.colors.border.b,
            self.colors.border.a
        )
    end
end

-- Style status bar
function WarWithinSkin:StyleStatusBar(instance)
    -- Status bar texture
    instance.statusbar_info = {
        overlay = {self.textures.statusBarTexture, 16, 16, true},
        color = {
            self.colors.statusbar.r,
            self.colors.statusbar.g,
            self.colors.statusbar.b,
            self.colors.statusbar.a
        },
        enabled = true
    }
    
    -- Apply status bar
    if instance.baseframe and instance.baseframe.rodape and instance.baseframe.rodape.StatusBarLeftAnchor then
        local statusBar = instance.baseframe.rodape.StatusBarLeftAnchor:GetParent()
        
        if statusBar then
            statusBar:SetStatusBarTexture(self.textures.statusBarTexture)
            statusBar:SetStatusBarColor(
                self.colors.statusbar.r,
                self.colors.statusbar.g,
                self.colors.statusbar.b,
                self.colors.statusbar.a
            )
        end
    end
    
    -- Style status bar text
    if instance.baseframe and instance.baseframe.rodape and instance.baseframe.rodape.text_esquerdo then
        instance.baseframe.rodape.text_esquerdo:SetTextColor(
            self.colors.text.r,
            self.colors.text.g,
            self.colors.text.b,
            self.colors.text.a
        )
    end
    
    if instance.baseframe and instance.baseframe.rodape and instance.baseframe.rodape.text_direita then
        instance.baseframe.rodape.text_direita:SetTextColor(
            self.colors.text.r,
            self.colors.text.g,
            self.colors.text.b,
            self.colors.text.a
        )
    end
end

-- Style data rows
function WarWithinSkin:StyleRows(instance)
    -- Row texture and appearance
    instance.row_info = {
        texture = self.textures.barTexture,
        texture_background = self.textures.backgroundTexture,
        texture_highlight = self.textures.backgroundTexture,
        texture_class_colors = true,
        fixed_texture_color = {0, 0, 0, 0},
        fixed_texture_background_color = {
            self.colors.background.r * 0.3,
            self.colors.background.g * 0.3,
            self.colors.background.b * 0.3,
            0.2
        },
        fixed_texture_highlight_color = {
            self.colors.highlight.r,
            self.colors.highlight.g,
            self.colors.highlight.b,
            self.colors.highlight.a
        },
        texture_background_class_color = false,
        texture_background_file = self.textures.backgroundTexture,
        overlay_texture = self.textures.barTexture,
        no_icon_backdrop = false,
        icon_size = {14, 14},
        icon_file = "Interface\\AddOns\\Details\\images\\classes_small",
        start_after_icon = true,
        icon_grayscale = false,
        font_face = "Expressway",
        font_size = 10,
        font_face_file = [[Interface\Addons\VUI\media\fonts\Expressway.ttf]],
        texture_class_colors = true,
        alpha = 1,
        backdrop = {
            enabled = false,
            size = 4,
            color = {0, 0, 0, 0.2}
        }
    }
    
    -- Set bar texture
    instance.bars_texture = self.textures.barTexture
    
    -- Set bar height
    instance.row_height = 16
end

-- Style fonts
function WarWithinSkin:StyleFonts(instance)
    -- Title font
    if instance.baseframe and instance.baseframe.cabecalho and instance.baseframe.cabecalho.texto then
        instance.baseframe.cabecalho.texto:SetFont(
            "Interface\\Addons\\VUI\\media\\fonts\\Expressway.ttf",
            12,
            "OUTLINE"
        )
    end
    
    -- Status bar fonts
    if instance.baseframe and instance.baseframe.rodape and instance.baseframe.rodape.text_esquerdo then
        instance.baseframe.rodape.text_esquerdo:SetFont(
            "Interface\\Addons\\VUI\\media\\fonts\\Expressway.ttf",
            10,
            "OUTLINE"
        )
    end
    
    if instance.baseframe and instance.baseframe.rodape and instance.baseframe.rodape.text_direita then
        instance.baseframe.rodape.text_direita:SetFont(
            "Interface\\Addons\\VUI\\media\\fonts\\Expressway.ttf",
            10,
            "OUTLINE"
        )
    end
end

-- Register the War Within skin with DetailsSkin
function WarWithinSkin:Register()
    -- Register the skin with DetailsSkin's skin registry if it exists
    if DetailsSkin.SkinRegistry then
        DetailsSkin.SkinRegistry:RegisterSkin(self.skinName, {
            name = self.skinDisplayName,
            description = self.skinDescription,
            author = "VUI Team (inspired by " .. self.originalAuthor .. ")",
            applyFunction = function(instance) return self:ApplySkin(instance) end,
            resetFunction = function(instance) return DetailsSkin:ResetSkin(instance) end,
            isDefault = false -- Set VUI's skin as the default
        })
    end
end

-- Initialize the War Within skin
function WarWithinSkin:Initialize()
    -- Ensure path for textures
    self:Register()
    -- Initialization message disabled in production release
end