-- VUI Premade Group Finder Module - Theme Integration
local _, VUI = ...
local PGF = VUI.premadegroupfinder

-- Theme-specific textures for each theme
PGF.themeAssets = {
    -- Phoenix Flame theme assets
    phoenixflame = {
        icons = {
            tank = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\tank.tga",
            healer = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\healer.tga",
            dps = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\dps.tga",
            mythicplus = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\mythicplus.tga",
            raid = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\raid.tga",
            pvp = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\pvp.tga",
            questing = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\questing.tga",
            favorite = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\favorite.tga",
            favorites = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\favorites.tga",
            blacklist = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\blacklist.tga",
            refresh = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\refresh.tga",
            filter = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\filter.tga",
            voicechat = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\premadegroupfinder\\voicechat.tga",
        },
        colors = {
            rating = {
                low = {r = 0.8, g = 0.3, b = 0.1},
                medium = {r = 0.9, g = 0.5, b = 0.1},
                high = {r = 1.0, g = 0.7, b = 0.1},
            },
            header = {r = 0.3, g = 0.1, b = 0.05, a = 0.9},
            groupHeader = {r = 0.4, g = 0.15, b = 0.07, a = 0.8},
            groupBorder = {r = 0.9, g = 0.3, b = 0.05, a = 1.0}
        }
    },
    
    -- Thunder Storm theme assets
    thunderstorm = {
        icons = {
            tank = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\tank.tga",
            healer = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\healer.tga",
            dps = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\dps.tga",
            mythicplus = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\mythicplus.tga",
            raid = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\raid.tga",
            pvp = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\pvp.tga",
            questing = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\questing.tga",
            favorite = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\favorite.tga",
            favorites = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\favorites.tga",
            blacklist = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\blacklist.tga",
            refresh = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\refresh.tga",
            filter = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\filter.tga",
            voicechat = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\premadegroupfinder\\voicechat.tga",
        },
        colors = {
            rating = {
                low = {r = 0.1, g = 0.4, b = 0.7},
                medium = {r = 0.1, g = 0.6, b = 0.9},
                high = {r = 0.1, g = 0.8, b = 1.0},
            },
            header = {r = 0.05, g = 0.1, b = 0.3, a = 0.9},
            groupHeader = {r = 0.07, g = 0.15, b = 0.4, a = 0.8},
            groupBorder = {r = 0.05, g = 0.3, b = 0.9, a = 1.0}
        }
    },
    
    -- Arcane Mystic theme assets
    arcanemystic = {
        icons = {
            tank = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\tank.tga",
            healer = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\healer.tga",
            dps = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\dps.tga",
            mythicplus = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\mythicplus.tga",
            raid = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\raid.tga",
            pvp = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\pvp.tga",
            questing = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\questing.tga",
            favorite = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\favorite.tga",
            favorites = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\favorites.tga",
            blacklist = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\blacklist.tga",
            refresh = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\refresh.tga",
            filter = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\filter.tga",
            voicechat = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\premadegroupfinder\\voicechat.tga",
        },
        colors = {
            rating = {
                low = {r = 0.4, g = 0.1, b = 0.6},
                medium = {r = 0.6, g = 0.1, b = 0.8},
                high = {r = 0.8, g = 0.1, b = 1.0},
            },
            header = {r = 0.15, g = 0.05, b = 0.3, a = 0.9},
            groupHeader = {r = 0.2, g = 0.07, b = 0.4, a = 0.8},
            groupBorder = {r = 0.5, g = 0.05, b = 0.9, a = 1.0}
        }
    },
    
    -- Fel Energy theme assets
    felenergy = {
        icons = {
            tank = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\tank.tga",
            healer = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\healer.tga",
            dps = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\dps.tga",
            mythicplus = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\mythicplus.tga",
            raid = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\raid.tga",
            pvp = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\pvp.tga",
            questing = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\questing.tga",
            favorite = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\favorite.tga",
            favorites = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\favorites.tga",
            blacklist = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\blacklist.tga",
            refresh = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\refresh.tga",
            filter = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\filter.tga",
            voicechat = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\premadegroupfinder\\voicechat.tga",
        },
        colors = {
            rating = {
                low = {r = 0.1, g = 0.5, b = 0.1},
                medium = {r = 0.1, g = 0.7, b = 0.1},
                high = {r = 0.1, g = 1.0, b = 0.1},
            },
            header = {r = 0.05, g = 0.2, b = 0.05, a = 0.9},
            groupHeader = {r = 0.07, g = 0.3, b = 0.07, a = 0.8},
            groupBorder = {r = 0.05, g = 0.8, b = 0.05, a = 1.0}
        }
    }
}

-- Get theme asset path
function PGF:GetThemeAsset(assetType, assetName)
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    if not self.themeAssets[theme] then
        theme = "thunderstorm" -- Fallback to thunderstorm theme
    end
    
    if assetType == "icon" then
        return self.themeAssets[theme].icons[assetName] or ""
    elseif assetType == "color" then
        return self.themeAssets[theme].colors[assetName] or {}
    end
    
    return nil
end

-- Get theme color for rating
function PGF:GetRatingColor(rating)
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local ratingColors = self.themeAssets[theme].colors.rating
    
    if rating < 1000 then
        return ratingColors.low.r, ratingColors.low.g, ratingColors.low.b
    elseif rating < 2000 then
        return ratingColors.medium.r, ratingColors.medium.g, ratingColors.medium.b
    else
        return ratingColors.high.r, ratingColors.high.g, ratingColors.high.b
    end
end

-- Apply theme to all PGF elements
function PGF:ApplyThemeToElements()
    if not self.enabled then return end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeData = self.themeAssets[theme]
    
    if not themeData then return end
    
    -- Update theme-specific icons
    self:UpdateThemeIcons()
    
    -- Apply theme colors to frames
    self:ApplyThemeColors()
    
    -- Apply theme to group listings
    if LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.ScrollFrame then
        self:UpdateSearchResults(LFGListFrame.SearchPanel)
    end
end

-- Update theme-specific icons
function PGF:UpdateThemeIcons()
    -- Update role icons
    if self.tankCheckbox then
        self.tankCheckbox:SetNormalTexture(self:GetThemeAsset("icon", "tank"))
    end
    
    if self.healerCheckbox then
        self.healerCheckbox:SetNormalTexture(self:GetThemeAsset("icon", "healer"))
    end
    
    if self.dpsCheckbox then
        self.dpsCheckbox:SetNormalTexture(self:GetThemeAsset("icon", "dps"))
    end
    
    if self.voiceChatCheckbox then
        self.voiceChatCheckbox:SetNormalTexture(self:GetThemeAsset("icon", "voicechat"))
    end
    
    -- Update button icons
    if self.refreshButton then
        self.refreshButton:SetNormalTexture(self:GetThemeAsset("icon", "refresh"))
    end
    
    if self.resetFiltersButton then
        self.resetFiltersButton:SetNormalTexture(self:GetThemeAsset("icon", "filter"))
    end
    
    -- Update quick search buttons
    if self.quickSearchButtons then
        for i, button in ipairs(self.quickSearchButtons) do
            if button.iconType then
                button:SetNormalTexture(self:GetThemeAsset("icon", button.iconType))
            end
        end
    end
end

-- Apply theme colors to frames
function PGF:ApplyThemeColors()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeData = VUI.media.themes[theme]
    local pgfThemeData = self.themeAssets[theme]
    
    if not themeData or not pgfThemeData then return end
    
    -- Apply to header
    if self.dragHeader then
        self.dragHeader:SetBackdropColor(
            pgfThemeData.colors.header.r,
            pgfThemeData.colors.header.g,
            pgfThemeData.colors.header.b,
            pgfThemeData.colors.header.a
        )
        
        self.dragHeader:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply to filter frame
    if self.filterFrame then
        self.filterFrame:SetBackdropColor(
            themeData.colors.backdrop.r,
            themeData.colors.backdrop.g,
            themeData.colors.backdrop.b,
            themeData.colors.backdrop.a
        )
        
        self.filterFrame:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply to quick search frame
    if self.quickSearchFrame then
        self.quickSearchFrame:SetBackdropColor(
            themeData.colors.backdrop.r,
            themeData.colors.backdrop.g,
            themeData.colors.backdrop.b,
            themeData.colors.backdrop.a
        )
        
        self.quickSearchFrame:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply to buttons
    local function ApplyButtonStyle(button)
        if not button then return end
        
        button:SetBackdropColor(
            themeData.colors.button.r,
            themeData.colors.button.g,
            themeData.colors.button.b,
            themeData.colors.button.a
        )
        
        button:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply to our buttons
    if self.settingsButton then
        ApplyButtonStyle(self.settingsButton)
    end
    
    if self.refreshButton then
        ApplyButtonStyle(self.refreshButton)
    end
    
    if self.resetFiltersButton then
        ApplyButtonStyle(self.resetFiltersButton)
    end
    
    -- Apply to quick search buttons
    if self.quickSearchButtons then
        for _, button in ipairs(self.quickSearchButtons) do
            ApplyButtonStyle(button)
        end
    end
    
    -- Apply to sliders
    if self.ilvlSlider then
        self.ilvlSlider:SetBackdropColor(
            themeData.colors.backdrop.r,
            themeData.colors.backdrop.g,
            themeData.colors.backdrop.b,
            themeData.colors.backdrop.a
        )
    end
end

-- Hook the search result update to apply theme
function PGF:ThemeIntegrationInit()
    -- Hook into theme changes
    hooksecurefunc(VUI, "UpdateTheme", function()
        self:ApplyThemeToElements()
    end)
    
    -- Initial setup when module is enabled
    self:ApplyThemeToElements()
end