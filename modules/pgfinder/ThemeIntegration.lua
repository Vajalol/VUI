-------------------------------------------------------------------------------
-- Title: PGFinder Theme Integration
-- Author: VortexQ8
-- Theme integration for the Premade Group Finder
-------------------------------------------------------------------------------

local addonName, VUI = ...
local PGF = VUI.modules.pgfinder

-- Skip if PGFinder module is not available
if not PGF then return end

-- Create the theme integration namespace
PGF.ThemeIntegration = {}
local ThemeIntegration = PGF.ThemeIntegration

-- Media references
local LSM = LibStub("LibSharedMedia-3.0")

-- Theme configuration
local themeConfig = {
    -- Thunder Storm theme
    thunderstorm = {
        backgroundColor = {r = 0.05, g = 0.05, b = 0.1, a = 0.95},
        borderColor = {r = 0.129, g = 0.611, b = 0.901, a = 1.0},
        headerColor = {r = 0.129, g = 0.611, b = 0.901, a = 1.0},
        highlightColor = {r = 0.2, g = 0.4, b = 0.8, a = 0.3},
        buttonColor = {r = 0.129, g = 0.611, b = 0.901, a = 1.0},
        font = "Fonts\\FRIZQT__.TTF",
        statusBar = "VUI:StatusBar:thunderstorm",
        iconPath = "Interface\\Addons\\VUI\\media\\textures\\thunderstorm\\pgfinder\\",
        glow = "Interface\\Addons\\VUI\\media\\textures\\thunderstorm\\glow",
        buttonBorder = "Interface\\Addons\\VUI\\media\\textures\\thunderstorm\\border",
    },
    
    -- Phoenix Flame theme
    phoenixflame = {
        backgroundColor = {r = 0.1, g = 0.05, b = 0.02, a = 0.95},
        borderColor = {r = 0.901, g = 0.302, b = 0.051, a = 1.0},
        headerColor = {r = 0.901, g = 0.302, b = 0.051, a = 1.0},
        highlightColor = {r = 0.8, g = 0.3, b = 0.1, a = 0.3},
        buttonColor = {r = 0.901, g = 0.302, b = 0.051, a = 1.0},
        font = "Fonts\\FRIZQT__.TTF",
        statusBar = "VUI:StatusBar:phoenixflame",
        iconPath = "Interface\\Addons\\VUI\\media\\textures\\phoenixflame\\pgfinder\\",
        glow = "Interface\\Addons\\VUI\\media\\textures\\phoenixflame\\glow",
        buttonBorder = "Interface\\Addons\\VUI\\media\\textures\\phoenixflame\\border",
    },
    
    -- Arcane Mystic theme
    arcanemystic = {
        backgroundColor = {r = 0.05, g = 0.02, b = 0.1, a = 0.95},
        borderColor = {r = 0.611, g = 0.129, b = 0.901, a = 1.0},
        headerColor = {r = 0.611, g = 0.129, b = 0.901, a = 1.0},
        highlightColor = {r = 0.4, g = 0.2, b = 0.8, a = 0.3},
        buttonColor = {r = 0.611, g = 0.129, b = 0.901, a = 1.0},
        font = "Fonts\\FRIZQT__.TTF",
        statusBar = "VUI:StatusBar:arcanemystic",
        iconPath = "Interface\\Addons\\VUI\\media\\textures\\arcanemystic\\pgfinder\\",
        glow = "Interface\\Addons\\VUI\\media\\textures\\arcanemystic\\glow",
        buttonBorder = "Interface\\Addons\\VUI\\media\\textures\\arcanemystic\\border",
    },
    
    -- Fel Energy theme
    felenergy = {
        backgroundColor = {r = 0.02, g = 0.1, b = 0.02, a = 0.95},
        borderColor = {r = 0.129, g = 0.901, b = 0.129, a = 1.0},
        headerColor = {r = 0.129, g = 0.901, b = 0.129, a = 1.0},
        highlightColor = {r = 0.2, g = 0.8, b = 0.2, a = 0.3},
        buttonColor = {r = 0.129, g = 0.901, b = 0.129, a = 1.0},
        font = "Fonts\\FRIZQT__.TTF",
        statusBar = "VUI:StatusBar:felenergy",
        iconPath = "Interface\\Addons\\VUI\\media\\textures\\felenergy\\pgfinder\\",
        glow = "Interface\\Addons\\VUI\\media\\textures\\felenergy\\glow",
        buttonBorder = "Interface\\Addons\\VUI\\media\\textures\\felenergy\\border",
    }
}

-- Initialize theme integration
function ThemeIntegration:Initialize()
    self.currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Register media
    self:RegisterMedia()
    
    -- Apply theme
    self:ApplyTheme()
end

-- Register media with LibSharedMedia
function ThemeIntegration:RegisterMedia()
    -- Register role icons for each theme
    self:RegisterRoleIcons("thunderstorm")
    self:RegisterRoleIcons("phoenixflame")
    self:RegisterRoleIcons("arcanemystic")
    self:RegisterRoleIcons("felenergy")
    
    -- Register activity icons for each theme
    self:RegisterActivityIcons("thunderstorm")
    self:RegisterActivityIcons("phoenixflame")
    self:RegisterActivityIcons("arcanemystic")
    self:RegisterActivityIcons("felenergy")
end

-- Register role icons for a specific theme
function ThemeIntegration:RegisterRoleIcons(theme)
    local iconPath = themeConfig[theme].iconPath
    
    -- Tank icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":TankIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":TankIcon", iconPath .. "tank.tga")
    end
    
    -- Healer icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":HealerIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":HealerIcon", iconPath .. "healer.tga")
    end
    
    -- Damage icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":DamageIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":DamageIcon", iconPath .. "damage.tga")
    end
    
    -- Leader icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":LeaderIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":LeaderIcon", iconPath .. "leader.tga")
    end
    
    -- Voice chat icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":VoiceIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":VoiceIcon", iconPath .. "voice.tga")
    end
end

-- Register activity icons for a specific theme
function ThemeIntegration:RegisterActivityIcons(theme)
    local iconPath = themeConfig[theme].iconPath
    
    -- Dungeon icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":DungeonIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":DungeonIcon", iconPath .. "dungeon.tga")
    end
    
    -- Raid icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":RaidIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":RaidIcon", iconPath .. "raid.tga")
    end
    
    -- PvP icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":PvPIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":PvPIcon", iconPath .. "pvp.tga")
    end
    
    -- Other activity icon
    if not LSM:IsValid(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":OtherIcon") then
        LSM:Register(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. theme .. ":OtherIcon", iconPath .. "other.tga")
    end
end

-- Apply theme to all PGFinder elements
function ThemeIntegration:ApplyTheme()
    -- Update current theme
    self.currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Apply theme to specific elements
    self:ApplyThemeToLFGPanel()
    self:ApplyThemeToSearchPanel()
    self:ApplyThemeToEntryPanel()
    self:ApplyThemeToApplicationViewer()
    self:ApplyThemeToActivityFinder()
    
    -- Update all visible elements
    self:UpdateAllElements()
end

-- Apply theme to main LFG panel
function ThemeIntegration:ApplyThemeToLFGPanel()
    if not LFGListFrame then return end
    
    local theme = themeConfig[self.currentTheme]
    
    -- Apply background and border
    if not LFGListFrame.VUIBackground then
        -- Create background
        LFGListFrame.VUIBackground = LFGListFrame:CreateTexture(nil, "BACKGROUND")
        LFGListFrame.VUIBackground:SetAllPoints()
        
        -- Create border
        LFGListFrame.VUIBorder = CreateFrame("Frame", nil, LFGListFrame, "BackdropTemplate")
        LFGListFrame.VUIBorder:SetPoint("TOPLEFT", -1, 1)
        LFGListFrame.VUIBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        LFGListFrame.VUIBorder:SetBackdrop({
            edgeFile = theme.buttonBorder,
            edgeSize = 2,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
    end
    
    -- Update background and border with current theme
    LFGListFrame.VUIBackground:SetColorTexture(
        theme.backgroundColor.r,
        theme.backgroundColor.g,
        theme.backgroundColor.b,
        theme.backgroundColor.a
    )
    
    LFGListFrame.VUIBorder:SetBackdropBorderColor(
        theme.borderColor.r,
        theme.borderColor.g,
        theme.borderColor.b,
        theme.borderColor.a
    )
    
    -- Apply theme to tab buttons
    for i = 1, #LFGListFrame.CategorySelection.CategoryButtons do
        self:ApplyButtonTheme(LFGListFrame.CategorySelection.CategoryButtons[i])
    end
end

-- Apply theme to search panel
function ThemeIntegration:ApplyThemeToSearchPanel()
    if not LFGListFrame.SearchPanel then return end
    
    local panel = LFGListFrame.SearchPanel
    local theme = themeConfig[self.currentTheme]
    
    -- Apply theme to search buttons
    self:ApplyButtonTheme(panel.SearchButton)
    self:ApplyButtonTheme(panel.RefreshButton)
    self:ApplyButtonTheme(panel.BackButton)
    self:ApplyButtonTheme(panel.SignUpButton)
    
    -- Apply theme to search box
    if panel.SearchBox then
        panel.SearchBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = theme.buttonBorder,
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        
        panel.SearchBox:SetBackdropColor(
            theme.backgroundColor.r,
            theme.backgroundColor.g,
            theme.backgroundColor.b,
            theme.backgroundColor.a
        )
        
        panel.SearchBox:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
    
    -- Apply theme to scroll frame
    if panel.ScrollFrame then
        -- Modify scrollbar
        local scrollBar = panel.ScrollFrame.ScrollBar
        if scrollBar then
            -- Modify Thumb
            if scrollBar.ThumbTexture then
                scrollBar.ThumbTexture:SetColorTexture(
                    theme.buttonColor.r,
                    theme.buttonColor.g,
                    theme.buttonColor.b,
                    0.7
                )
            end
            
            -- Modify buttons
            if scrollBar.ScrollUpButton then
                self:ApplyButtonTheme(scrollBar.ScrollUpButton)
            end
            
            if scrollBar.ScrollDownButton then
                self:ApplyButtonTheme(scrollBar.ScrollDownButton)
            end
        end
    end
end

-- Apply theme to search entry
function ThemeIntegration:ApplySearchEntryTheme(button)
    if not button then return end
    
    local theme = themeConfig[self.currentTheme]
    
    -- Apply backdrop
    if not button.VUIBackdrop then
        button.VUIBackdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
        button.VUIBackdrop:SetPoint("TOPLEFT")
        button.VUIBackdrop:SetPoint("BOTTOMRIGHT")
        button.VUIBackdrop:SetFrameLevel(button:GetFrameLevel() - 1)
    end
    
    button.VUIBackdrop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = theme.buttonBorder,
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    
    button.VUIBackdrop:SetBackdropColor(
        theme.backgroundColor.r,
        theme.backgroundColor.g,
        theme.backgroundColor.b,
        theme.backgroundColor.a
    )
    
    -- Normal state
    if not button.selected then
        button.VUIBackdrop:SetBackdropBorderColor(
            theme.borderColor.r * 0.7,
            theme.borderColor.g * 0.7,
            theme.borderColor.b * 0.7,
            theme.borderColor.a
        )
    else
        -- Selected state
        button.VUIBackdrop:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
    
    -- Apply font theme to text elements
    if button.Name then
        button.Name:SetFont(theme.font, 12, "OUTLINE")
    end
    
    if button.ActivityName then
        button.ActivityName:SetFont(theme.font, 11, "NONE")
    end
    
    if button.VoiceChat then
        button.VoiceChat:SetFont(theme.font, 10, "NONE")
    end
    
    -- Replace role icons with themed versions
    if PGF.db.profile.roleRequirements.iconsStyle == "theme" then
        -- Replace tank icon
        if button.TankIcon and button.TankIcon:IsShown() then
            if not button.VUITankIcon then
                button.VUITankIcon = button:CreateTexture(nil, "ARTWORK")
                button.VUITankIcon:SetSize(16, 16)
                button.VUITankIcon:SetPoint("LEFT", button.TankIcon, "LEFT", 0, 0)
            end
            
            button.VUITankIcon:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. self.currentTheme .. ":TankIcon"))
            button.VUITankIcon:Show()
            button.TankIcon:SetAlpha(0)
        elseif button.VUITankIcon then
            button.VUITankIcon:Hide()
        end
        
        -- Replace healer icon
        if button.HealerIcon and button.HealerIcon:IsShown() then
            if not button.VUIHealerIcon then
                button.VUIHealerIcon = button:CreateTexture(nil, "ARTWORK")
                button.VUIHealerIcon:SetSize(16, 16)
                button.VUIHealerIcon:SetPoint("LEFT", button.HealerIcon, "LEFT", 0, 0)
            end
            
            button.VUIHealerIcon:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. self.currentTheme .. ":HealerIcon"))
            button.VUIHealerIcon:Show()
            button.HealerIcon:SetAlpha(0)
        elseif button.VUIHealerIcon then
            button.VUIHealerIcon:Hide()
        end
        
        -- Replace damage icon
        if button.DamagerIcon and button.DamagerIcon:IsShown() then
            if not button.VUIDamagerIcon then
                button.VUIDamagerIcon = button:CreateTexture(nil, "ARTWORK")
                button.VUIDamagerIcon:SetSize(16, 16)
                button.VUIDamagerIcon:SetPoint("LEFT", button.DamagerIcon, "LEFT", 0, 0)
            end
            
            button.VUIDamagerIcon:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. self.currentTheme .. ":DamageIcon"))
            button.VUIDamagerIcon:Show()
            button.DamagerIcon:SetAlpha(0)
        elseif button.VUIDamagerIcon then
            button.VUIDamagerIcon:Hide()
        end
    else
        -- Restore default icons
        if button.TankIcon then button.TankIcon:SetAlpha(1) end
        if button.HealerIcon then button.HealerIcon:SetAlpha(1) end
        if button.DamagerIcon then button.DamagerIcon:SetAlpha(1) end
        
        -- Hide themed icons
        if button.VUITankIcon then button.VUITankIcon:Hide() end
        if button.VUIHealerIcon then button.VUIHealerIcon:Hide() end
        if button.VUIDamagerIcon then button.VUIDamagerIcon:Hide() end
    end
end

-- Apply theme to entry panel
function ThemeIntegration:ApplyThemeToEntryPanel()
    if not LFGListFrame.EntryCreation then return end
    
    local panel = LFGListFrame.EntryCreation
    local theme = themeConfig[self.currentTheme]
    
    -- Apply theme to buttons
    self:ApplyButtonTheme(panel.CancelButton)
    self:ApplyButtonTheme(panel.ListGroupButton)
    
    -- Apply theme to edit boxes
    if panel.Name then
        panel.Name:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = theme.buttonBorder,
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        
        panel.Name:SetBackdropColor(
            theme.backgroundColor.r,
            theme.backgroundColor.g,
            theme.backgroundColor.b,
            theme.backgroundColor.a
        )
        
        panel.Name:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
    
    if panel.Description then
        panel.Description:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = theme.buttonBorder,
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        
        panel.Description:SetBackdropColor(
            theme.backgroundColor.r,
            theme.backgroundColor.g,
            theme.backgroundColor.b,
            theme.backgroundColor.a
        )
        
        panel.Description:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
    
    if panel.ItemLevel then
        panel.ItemLevel:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = theme.buttonBorder,
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        
        panel.ItemLevel:SetBackdropColor(
            theme.backgroundColor.r,
            theme.backgroundColor.g,
            theme.backgroundColor.b,
            theme.backgroundColor.a
        )
        
        panel.ItemLevel:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
    
    if panel.VoiceChat then
        panel.VoiceChat:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = theme.buttonBorder,
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        
        panel.VoiceChat:SetBackdropColor(
            theme.backgroundColor.r,
            theme.backgroundColor.g,
            theme.backgroundColor.b,
            theme.backgroundColor.a
        )
        
        panel.VoiceChat:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
end

-- Apply theme to application viewer
function ThemeIntegration:ApplyThemeToApplicationViewer()
    if not LFGListFrame.ApplicationViewer then return end
    
    local panel = LFGListFrame.ApplicationViewer
    local theme = themeConfig[self.currentTheme]
    
    -- Apply theme to buttons
    self:ApplyButtonTheme(panel.RefreshButton)
    self:ApplyButtonTheme(panel.RemoveEntryButton)
    self:ApplyButtonTheme(panel.EditButton)
    
    -- Apply theme to scroll frame
    if panel.ScrollFrame then
        -- Modify scrollbar
        local scrollBar = panel.ScrollFrame.ScrollBar
        if scrollBar then
            -- Modify Thumb
            if scrollBar.ThumbTexture then
                scrollBar.ThumbTexture:SetColorTexture(
                    theme.buttonColor.r,
                    theme.buttonColor.g,
                    theme.buttonColor.b,
                    0.7
                )
            end
            
            -- Modify buttons
            if scrollBar.ScrollUpButton then
                self:ApplyButtonTheme(scrollBar.ScrollUpButton)
            end
            
            if scrollBar.ScrollDownButton then
                self:ApplyButtonTheme(scrollBar.ScrollDownButton)
            end
        end
    end
end

-- Apply theme to activity finder
function ThemeIntegration:ApplyThemeToActivityFinder()
    if not LFGListFrame.EntryCreation.ActivityFinder then return end
    
    local panel = LFGListFrame.EntryCreation.ActivityFinder
    local theme = themeConfig[self.currentTheme]
    
    -- Apply theme to search box
    if panel.Dialog and panel.Dialog.SearchBox then
        panel.Dialog.SearchBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = theme.buttonBorder,
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
        
        panel.Dialog.SearchBox:SetBackdropColor(
            theme.backgroundColor.r,
            theme.backgroundColor.g,
            theme.backgroundColor.b,
            theme.backgroundColor.a
        )
        
        panel.Dialog.SearchBox:SetBackdropBorderColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            theme.borderColor.a
        )
    end
    
    -- Apply theme to buttons
    if panel.Dialog then
        self:ApplyButtonTheme(panel.Dialog.SelectButton)
        self:ApplyButtonTheme(panel.Dialog.CancelButton)
    end
end

-- Apply theme to a button
function ThemeIntegration:ApplyButtonTheme(button)
    if not button then return end
    
    local theme = themeConfig[self.currentTheme]
    
    -- Create background and border if they don't exist
    if not button.VUIBg then
        button.VUIBg = button:CreateTexture(nil, "BACKGROUND")
        button.VUIBg:SetAllPoints()
    end
    
    if not button.VUIBorder then
        button.VUIBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
        button.VUIBorder:SetPoint("TOPLEFT", -1, 1)
        button.VUIBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        button.VUIBorder:SetFrameLevel(button:GetFrameLevel() - 1)
    end
    
    -- Update with current theme
    button.VUIBg:SetColorTexture(
        theme.backgroundColor.r,
        theme.backgroundColor.g,
        theme.backgroundColor.b,
        theme.backgroundColor.a
    )
    
    button.VUIBorder:SetBackdrop({
        edgeFile = theme.buttonBorder,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    
    button.VUIBorder:SetBackdropBorderColor(
        theme.borderColor.r,
        theme.borderColor.g,
        theme.borderColor.b,
        theme.borderColor.a
    )
    
    -- Modify text
    local fontName, fontSize, fontFlags = button:GetFontString():GetFont()
    button:GetFontString():SetFont(theme.font, fontSize or 12, fontFlags or "")
    
    -- Add highlight effect
    if not button.VUIHighlight then
        button.VUIHighlight = button:CreateTexture(nil, "HIGHLIGHT")
        button.VUIHighlight:SetAllPoints()
        button.VUIHighlight:SetColorTexture(
            theme.highlightColor.r,
            theme.highlightColor.g,
            theme.highlightColor.b,
            theme.highlightColor.a
        )
        button.VUIHighlight:SetBlendMode("ADD")
    else
        button.VUIHighlight:SetColorTexture(
            theme.highlightColor.r,
            theme.highlightColor.g,
            theme.highlightColor.b,
            theme.highlightColor.a
        )
    end
end

-- Apply active button theme (for buttons that are in an active state)
function ThemeIntegration:ApplyButtonActiveTheme(button)
    if not button then return end
    
    local theme = themeConfig[self.currentTheme]
    
    -- Create background and border if they don't exist
    if not button.VUIBg then
        button.VUIBg = button:CreateTexture(nil, "BACKGROUND")
        button.VUIBg:SetAllPoints()
    end
    
    if not button.VUIBorder then
        button.VUIBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
        button.VUIBorder:SetPoint("TOPLEFT", -1, 1)
        button.VUIBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        button.VUIBorder:SetFrameLevel(button:GetFrameLevel() - 1)
    end
    
    -- Update with active theme (brighter colors)
    button.VUIBg:SetColorTexture(
        theme.borderColor.r * 0.3,
        theme.borderColor.g * 0.3,
        theme.borderColor.b * 0.3,
        0.8
    )
    
    button.VUIBorder:SetBackdrop({
        edgeFile = theme.buttonBorder,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    
    button.VUIBorder:SetBackdropBorderColor(
        theme.borderColor.r,
        theme.borderColor.g,
        theme.borderColor.b,
        theme.borderColor.a
    )
    
    -- Add glow effect
    if not button.VUIGlow then
        button.VUIGlow = button:CreateTexture(nil, "OVERLAY")
        button.VUIGlow:SetPoint("TOPLEFT", -3, 3)
        button.VUIGlow:SetPoint("BOTTOMRIGHT", 3, -3)
        button.VUIGlow:SetTexture(theme.glow)
        button.VUIGlow:SetVertexColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            0.5
        )
        button.VUIGlow:SetBlendMode("ADD")
    else
        button.VUIGlow:SetTexture(theme.glow)
        button.VUIGlow:SetVertexColor(
            theme.borderColor.r,
            theme.borderColor.g,
            theme.borderColor.b,
            0.5
        )
        button.VUIGlow:Show()
    end
    
    -- Modify text
    local fontName, fontSize, fontFlags = button:GetFontString():GetFont()
    button:GetFontString():SetFont(theme.font, fontSize or 12, fontFlags or "")
    button:GetFontString():SetTextColor(1, 1, 1)
end

-- Apply frame theme
function ThemeIntegration:ApplyFrameTheme(frame)
    if not frame then return end
    
    local theme = themeConfig[self.currentTheme]
    
    -- Set backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = theme.buttonBorder,
        tile = true,
        tileSize = 16,
        edgeSize = 2,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    
    frame:SetBackdropColor(
        theme.backgroundColor.r,
        theme.backgroundColor.g,
        theme.backgroundColor.b,
        theme.backgroundColor.a
    )
    
    frame:SetBackdropBorderColor(
        theme.borderColor.r,
        theme.borderColor.g,
        theme.borderColor.b,
        theme.borderColor.a
    )
end

-- Apply theme to applicant
function ThemeIntegration:ApplyApplicantTheme(member)
    if not member then return end
    
    local theme = themeConfig[self.currentTheme]
    
    -- Create backdrop if it doesn't exist
    if not member.VUIBackdrop then
        member.VUIBackdrop = CreateFrame("Frame", nil, member, "BackdropTemplate")
        member.VUIBackdrop:SetPoint("TOPLEFT")
        member.VUIBackdrop:SetPoint("BOTTOMRIGHT")
        member.VUIBackdrop:SetFrameLevel(member:GetFrameLevel() - 1)
    end
    
    -- Update with current theme
    member.VUIBackdrop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = theme.buttonBorder,
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    
    member.VUIBackdrop:SetBackdropColor(
        theme.backgroundColor.r,
        theme.backgroundColor.g,
        theme.backgroundColor.b,
        theme.backgroundColor.a
    )
    
    member.VUIBackdrop:SetBackdropBorderColor(
        theme.borderColor.r * 0.7,
        theme.borderColor.g * 0.7,
        theme.borderColor.b * 0.7,
        theme.borderColor.a
    )
    
    -- Apply theme to name text
    if member.Name then
        member.Name:SetFont(theme.font, 12, "OUTLINE")
    end
    
    -- Replace role icon with themed version
    if PGF.db.profile.roleRequirements.iconsStyle == "theme" then
        if member.RoleIcon and member.RoleIcon:IsShown() then
            if not member.VUIRoleIcon then
                member.VUIRoleIcon = member:CreateTexture(nil, "ARTWORK")
                member.VUIRoleIcon:SetSize(16, 16)
                member.VUIRoleIcon:SetPoint("CENTER", member.RoleIcon, "CENTER", 0, 0)
            end
            
            local role = member.roleID
            if role == "TANK" then
                member.VUIRoleIcon:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. self.currentTheme .. ":TankIcon"))
            elseif role == "HEALER" then
                member.VUIRoleIcon:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. self.currentTheme .. ":HealerIcon"))
            elseif role == "DAMAGER" then
                member.VUIRoleIcon:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "VUI:PGFinder:" .. self.currentTheme .. ":DamageIcon"))
            end
            
            member.VUIRoleIcon:Show()
            member.RoleIcon:SetAlpha(0)
        elseif member.VUIRoleIcon then
            member.VUIRoleIcon:Hide()
        end
    else
        -- Restore default icon
        if member.RoleIcon then member.RoleIcon:SetAlpha(1) end
        
        -- Hide themed icon
        if member.VUIRoleIcon then member.VUIRoleIcon:Hide() end
    end
    
    -- Apply theme to buttons
    if member.InviteButton then
        self:ApplyButtonTheme(member.InviteButton)
    end
    
    if member.DeclineButton then
        self:ApplyButtonTheme(member.DeclineButton)
    end
end

-- Update all visible elements
function ThemeIntegration:UpdateAllElements()
    -- Update LFGListFrame
    if LFGListFrame then
        -- Update category buttons
        if LFGListFrame.CategorySelection and LFGListFrame.CategorySelection.CategoryButtons then
            for i = 1, #LFGListFrame.CategorySelection.CategoryButtons do
                self:ApplyButtonTheme(LFGListFrame.CategorySelection.CategoryButtons[i])
            end
        end
        
        -- Update search results
        if LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.ScrollFrame and LFGListFrame.SearchPanel.ScrollFrame.buttons then
            for i = 1, #LFGListFrame.SearchPanel.ScrollFrame.buttons do
                self:ApplySearchEntryTheme(LFGListFrame.SearchPanel.ScrollFrame.buttons[i])
            end
        end
        
        -- Update applicants
        if LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer.ScrollFrame and LFGListFrame.ApplicationViewer.ScrollFrame.buttons then
            for i = 1, #LFGListFrame.ApplicationViewer.ScrollFrame.buttons do
                self:ApplyApplicantTheme(LFGListFrame.ApplicationViewer.ScrollFrame.buttons[i])
            end
        end
    end
end

-- Get theme color
function ThemeIntegration:GetThemeColor()
    local theme = themeConfig[self.currentTheme]
    return theme.borderColor.r, theme.borderColor.g, theme.borderColor.b
end

-- Get theme background color
function ThemeIntegration:GetThemeBackgroundColor()
    local theme = themeConfig[self.currentTheme]
    return theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b, theme.backgroundColor.a
end

-- Get themed font
function ThemeIntegration:GetThemeFont()
    local theme = themeConfig[self.currentTheme]
    return theme.font
end