local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Enhanced Player Frame Module based on EPF-Enhanced from Wago.io
local EPF = {
    name = "Enhanced Player Frame",
    enabled = true, -- Enabled by default
    settings = {},
    version = "1.0.0",
    moduleInitList = {}, -- List of initialization functions for submodules
}

-- Initialize the EPF module
function EPF:Initialize()
    -- Load settings from saved variables
    self.settings = VUI.db.profile.modules.epf or {}
    
    -- Set default enabled state
    self.enabled = self.settings.enabled
    if self.enabled == nil then -- if not explicitly set
        self.enabled = true
        self.settings.enabled = true
    end

    -- Initialize default settings if they don't exist
    self:InitializeDefaults()
    
    -- Make this module accessible globally within VUI
    VUI.epf = self
    
    -- Register for theme changes
    self:RegisterThemeCallbacks()
    
    -- Initialize EPF features
    if self.enabled then
        self:Enable()
    end
    
    -- Initialize submodules
    for _, initFunc in pairs(self.moduleInitList) do
        if type(initFunc) == "function" then
            initFunc()
        end
    end
end

-- Initialize default settings
function EPF:InitializeDefaults()
    -- Health bar settings
    if self.settings.healthFormat == nil then self.settings.healthFormat = "both" end
    if self.settings.healthFontSize == nil then self.settings.healthFontSize = 12 end
    if self.settings.healthFontOutline == nil then self.settings.healthFontOutline = "OUTLINE" end
    if self.settings.healthBarTexture == nil then self.settings.healthBarTexture = "VUI_Smooth" end
    if self.settings.healthBarHeight == nil then self.settings.healthBarHeight = 26 end
    if self.settings.classColoredHealthBar == nil then self.settings.classColoredHealthBar = true end
    
    -- Power bar settings
    if self.settings.powerFormat == nil then self.settings.powerFormat = "both" end
    if self.settings.powerFontSize == nil then self.settings.powerFontSize = 10 end
    if self.settings.powerFontOutline == nil then self.settings.powerFontOutline = "OUTLINE" end
    if self.settings.powerBarTexture == nil then self.settings.powerBarTexture = "VUI_Smooth" end
    if self.settings.powerBarHeight == nil then self.settings.powerBarHeight = 12 end
    
    -- Portrait settings
    if self.settings.portraitStyle == nil then self.settings.portraitStyle = "3D" end
    if self.settings.portraitBackgroundStyle == nil then self.settings.portraitBackgroundStyle = "solid" end
    
    -- HUD settings
    if self.settings.showCastingBar == nil then self.settings.showCastingBar = true end
    if self.settings.showXpBar == nil then self.settings.showXpBar = true end
    if self.settings.showRestingIcon == nil then self.settings.showRestingIcon = true end
    if self.settings.showPvPIcon == nil then self.settings.showPvPIcon = true end
    if self.settings.showLeaderIcon == nil then self.settings.showLeaderIcon = true end
    if self.settings.showLootIcon == nil then self.settings.showLootIcon = true end
    if self.settings.showAuras == nil then self.settings.showAuras = true end
    if self.settings.auraSize == nil then self.settings.auraSize = 24 end
    if self.settings.aurasPerRow == nil then self.settings.aurasPerRow = 8 end
    if self.settings.showCooldownText == nil then self.settings.showCooldownText = true end
    
    -- Advanced settings
    if self.settings.customPosition == nil then self.settings.customPosition = false end
    if self.settings.frameScale == nil then self.settings.frameScale = 1.0 end
    if self.settings.frameAlpha == nil then self.settings.frameAlpha = 1.0 end
    if self.settings.useThemeColors == nil then self.settings.useThemeColors = true end
end

-- Enable the module
function EPF:Enable()
    self.enabled = true
    self.settings.enabled = true
    
    -- Initialize ThemeIntegration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Apply configuration to PlayerFrame
    self:SetupPlayerFrame()
    
    -- Create hooks for events
    self:RegisterHooks()
    
    VUI:Print("Enhanced Player Frame enabled")
end

-- Disable the module
function EPF:Disable()
    self.enabled = false
    self.settings.enabled = false
    
    -- Remove hooks and restore default frame
    self:UnregisterHooks()
    self:RestoreDefaultPlayerFrame()
    
    VUI:Print("Enhanced Player Frame disabled")
end

-- Register for theme changes
function EPF:RegisterThemeCallbacks()
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            if self.enabled and self.settings.useThemeColors then
                -- Use ThemeIntegration if available, otherwise fall back to old method
                if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
                    self.ThemeIntegration:ApplyTheme(theme)
                else
                    self:ApplyTheme(theme)
                end
            end
        end)
    end
end

-- Apply the current VUI theme to EPF elements
function EPF:ApplyTheme(theme)
    theme = theme or VUI.db.profile.core.theme
    if not theme or not self.enabled then return end
    
    -- Get theme colors
    local colors = VUI.Media.ThemeColors[theme]
    if not colors then return end
    
    -- Apply theme to player frame elements
    if PlayerFrame and self.settings.useThemeColors then
        -- Apply to health bar background
        if PlayerFrameHealthBar.background then
            PlayerFrameHealthBar.background:SetColorTexture(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, 0.7)
        end
        
        -- Apply to power bar background
        if PlayerFrameManaBar.background then
            PlayerFrameManaBar.background:SetColorTexture(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, 0.7)
        end
        
        -- Apply to frame border
        if self.frameBorder then
            self.frameBorder:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, 1.0)
        end
        
        -- Apply theme colors to other elements as needed
    end
end

-- Setup the player frame with enhanced features
function EPF:SetupPlayerFrame()
    if not PlayerFrame then return end
    
    -- Store original PlayerFrame scale/alpha for restoration if needed
    if not self.originalScale then
        self.originalScale = PlayerFrame:GetScale()
    end
    if not self.originalAlpha then
        self.originalAlpha = PlayerFrame:GetAlpha()
    end
    
    -- Apply scale and alpha settings
    PlayerFrame:SetScale(self.settings.frameScale)
    PlayerFrame:SetAlpha(self.settings.frameAlpha)
    
    -- Set up health bar
    self:SetupHealthBar()
    
    -- Set up power bar
    self:SetupPowerBar()
    
    -- Set up portrait
    self:SetupPortrait()
    
    -- Set up HUD elements
    self:SetupHUD()
    
    -- Set up auras
    self:SetupAuras()
    
    -- Set custom position if enabled
    if self.settings.customPosition then
        self:SetupCustomPosition()
    end
    
    -- Apply current theme
    if self.settings.useThemeColors then
        -- Use ThemeIntegration if available, otherwise fall back to old method
        if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
            self.ThemeIntegration:ApplyTheme()
        else
            self:ApplyTheme()
        end
    end
end

-- Set up the health bar
function EPF:SetupHealthBar()
    local healthBar = PlayerFrameHealthBar
    if not healthBar then return end
    
    -- Apply texture
    local texture = self.settings.healthBarTexture
    local texturePath = VUI.Media:Fetch("statusbar", texture) or texture
    healthBar:SetStatusBarTexture(texturePath)
    
    -- Set height
    local height = self.settings.healthBarHeight
    healthBar:SetHeight(height)
    
    -- Class color if enabled
    if self.settings.classColoredHealthBar then
        local _, class = UnitClass("player")
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            healthBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
    
    -- Set up health text
    if not healthBar.valueText then
        healthBar.valueText = healthBar:CreateFontString(nil, "OVERLAY")
        healthBar.valueText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    end
    
    -- Set font properties
    local font = VUI.Media:Fetch("font", self.settings.healthFont) or STANDARD_TEXT_FONT
    healthBar.valueText:SetFont(font, self.settings.healthFontSize, self.settings.healthFontOutline)
    
    -- Create background if it doesn't exist
    if not healthBar.background then
        healthBar.background = healthBar:CreateTexture(nil, "BACKGROUND")
        healthBar.background:SetAllPoints(healthBar)
        healthBar.background:SetColorTexture(0.1, 0.1, 0.1, 0.7)
    end
    
    -- Hook health update function
    if not self.healthUpdateHooked then
        hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar)
            if statusbar == healthBar then
                self:UpdateHealthText(statusbar)
            end
        end)
        
        hooksecurefunc("UnitFrameHealthBar_OnValueChanged", function(statusbar)
            if statusbar == healthBar then
                self:UpdateHealthText(statusbar)
            end
        end)
        
        self.healthUpdateHooked = true
    end
    
    -- Force initial update
    self:UpdateHealthText(healthBar)
end

-- Update health text display
function EPF:UpdateHealthText(healthBar)
    if not healthBar or not healthBar.valueText then return end
    
    local unit = healthBar.unit or "player"
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    
    if not health or not maxHealth then
        healthBar.valueText:SetText("")
        return
    end
    
    local format = self.settings.healthFormat or "both"
    local text = ""
    
    if format == "percent" then
        -- Display percentage only
        text = math.floor((health / maxHealth) * 100) .. "%"
    elseif format == "value" then
        -- Display value only
        text = self:FormatValue(health)
    elseif format == "both" then
        -- Display both value and percentage
        text = self:FormatValue(health) .. " - " .. math.floor((health / maxHealth) * 100) .. "%"
    elseif format == "deficit" then
        -- Show deficit if not full health, otherwise show max health
        if health == maxHealth then
            text = self:FormatValue(maxHealth)
        else
            text = "-" .. self:FormatValue(maxHealth - health)
        end
    end
    
    healthBar.valueText:SetText(text)
end

-- Set up power bar (mana, rage, energy, etc.)
function EPF:SetupPowerBar()
    local powerBar = PlayerFrameManaBar
    if not powerBar then return end
    
    -- Apply texture
    local texture = self.settings.powerBarTexture
    local texturePath = VUI.Media:Fetch("statusbar", texture) or texture
    powerBar:SetStatusBarTexture(texturePath)
    
    -- Set height
    local height = self.settings.powerBarHeight
    powerBar:SetHeight(height)
    
    -- Set up power text
    if not powerBar.valueText then
        powerBar.valueText = powerBar:CreateFontString(nil, "OVERLAY")
        powerBar.valueText:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    end
    
    -- Set font properties
    local font = VUI.Media:Fetch("font", self.settings.powerFont) or STANDARD_TEXT_FONT
    powerBar.valueText:SetFont(font, self.settings.powerFontSize, self.settings.powerFontOutline)
    
    -- Create background if it doesn't exist
    if not powerBar.background then
        powerBar.background = powerBar:CreateTexture(nil, "BACKGROUND")
        powerBar.background:SetAllPoints(powerBar)
        powerBar.background:SetColorTexture(0.1, 0.1, 0.1, 0.7)
    end
    
    -- Hook power update function
    if not self.powerUpdateHooked then
        hooksecurefunc("UnitFrameManaBar_Update", function(statusbar)
            if statusbar == powerBar then
                self:UpdatePowerText(statusbar)
            end
        end)
        
        hooksecurefunc("UnitFrameManaBar_OnValueChanged", function(statusbar)
            if statusbar == powerBar then
                self:UpdatePowerText(statusbar)
            end
        end)
        
        self.powerUpdateHooked = true
    end
    
    -- Force initial update
    self:UpdatePowerText(powerBar)
end

-- Update power text display
function EPF:UpdatePowerText(powerBar)
    if not powerBar or not powerBar.valueText then return end
    
    local unit = powerBar.unit or "player"
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)
    
    if not power or not maxPower then
        powerBar.valueText:SetText("")
        return
    end
    
    local format = self.settings.powerFormat or "both"
    local text = ""
    
    if format == "percent" then
        -- Display percentage only
        text = math.floor((power / maxPower) * 100) .. "%"
    elseif format == "value" then
        -- Display value only
        text = self:FormatValue(power)
    elseif format == "both" then
        -- Display both value and percentage
        text = self:FormatValue(power) .. " - " .. math.floor((power / maxPower) * 100) .. "%"
    elseif format == "deficit" then
        -- Show deficit if not full power, otherwise show max power
        if power == maxPower then
            text = self:FormatValue(maxPower)
        else
            text = "-" .. self:FormatValue(maxPower - power)
        end
    end
    
    powerBar.valueText:SetText(text)
end

-- Format a numeric value for display
function EPF:FormatValue(value)
    if value >= 1000000 then
        return string.format("%.1fm", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fk", value / 1000)
    else
        return value
    end
end

-- Set up portrait display
function EPF:SetupPortrait()
    local portrait = PlayerPortrait
    if not portrait then return end
    
    local style = self.settings.portraitStyle
    if style == "3D" then
        -- Use default 3D portrait
        if PlayerPortrait3D and PlayerPortrait2D then
            PlayerPortrait3D:Show()
            PlayerPortrait2D:Hide()
        end
    elseif style == "2D" then
        -- Use 2D class icon
        if PlayerPortrait3D and PlayerPortrait2D then
            PlayerPortrait3D:Hide()
            PlayerPortrait2D:Show()
            
            local _, class = UnitClass("player")
            if class then
                local coords = CLASS_ICON_TCOORDS[class]
                if coords then
                    PlayerPortrait2D:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                    PlayerPortrait2D:SetTexCoord(unpack(coords))
                end
            end
        end
    elseif style == "none" then
        -- Hide portrait completely
        if PlayerPortrait3D and PlayerPortrait2D then
            PlayerPortrait3D:Hide()
            PlayerPortrait2D:Hide()
        end
    end
    
    -- Set up portrait background
    local bgStyle = self.settings.portraitBackgroundStyle
    if bgStyle == "solid" then
        -- Solid color background
        if not self.portraitBg then
            self.portraitBg = PlayerFrame:CreateTexture(nil, "BACKGROUND")
            self.portraitBg:SetPoint("TOPLEFT", portrait, "TOPLEFT")
            self.portraitBg:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT")
        end
        
        self.portraitBg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
        self.portraitBg:Show()
    elseif bgStyle == "class" then
        -- Class color background
        if not self.portraitBg then
            self.portraitBg = PlayerFrame:CreateTexture(nil, "BACKGROUND")
            self.portraitBg:SetPoint("TOPLEFT", portrait, "TOPLEFT")
            self.portraitBg:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT")
        end
        
        local _, class = UnitClass("player")
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            self.portraitBg:SetColorTexture(color.r, color.g, color.b, 0.3)
        end
        
        self.portraitBg:Show()
    elseif bgStyle == "none" then
        -- No background
        if self.portraitBg then
            self.portraitBg:Hide()
        end
    end
end

-- Set up HUD elements
function EPF:SetupHUD()
    -- Set up casting bar
    if self.settings.showCastingBar then
        -- Ensure casting bar hooks are in place
        -- Implementation depends on whether we're using the default UI casting bar or custom
    end
    
    -- Set up XP bar
    if self.settings.showXpBar then
        if MainMenuExpBar then
            MainMenuExpBar:Show()
        end
    else
        if MainMenuExpBar then
            MainMenuExpBar:Hide()
        end
    end
    
    -- Set up resting icon
    if PlayerRestIcon then
        PlayerRestIcon:SetShown(self.settings.showRestingIcon)
    end
    
    -- Set up PvP icon
    if PlayerPVPIcon then
        PlayerPVPIcon:SetShown(self.settings.showPvPIcon)
    end
    
    -- Set up leader icon
    if PlayerLeaderIcon then
        PlayerLeaderIcon:SetShown(self.settings.showLeaderIcon)
    end
    
    -- Set up loot master icon
    if PlayerMasterIcon then
        PlayerMasterIcon:SetShown(self.settings.showLootIcon)
    end
end

-- Set up auras (buffs/debuffs)
function EPF:SetupAuras()
    -- Set up player auras
    if self.settings.showAuras then
        -- Resize and position auras
        local size = self.settings.auraSize
        local perRow = self.settings.aurasPerRow
        
        -- Get buff and debuff frames
        local buffFrame = BuffFrame
        local debuffFrame = DebuffFrame
        
        if buffFrame then
            -- Modify buff display as needed
            hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", function()
                -- Customize buff layout
                if not self.enabled then return end
                
                -- Apply size and layout changes
                local numBuffs = BUFF_MAX_DISPLAY
                for i = 1, numBuffs do
                    local button = _G["BuffButton" .. i]
                    if button and button:IsShown() then
                        button:SetScale(size / 32) -- Default size is 32, so scale accordingly
                    end
                end
            end)
        end
        
        if debuffFrame then
            -- Modify debuff display as needed
            hooksecurefunc("DebuffButton_UpdateAnchors", function()
                -- Customize debuff layout
                if not self.enabled then return end
                
                -- Apply size and layout changes
                local numDebuffs = DEBUFF_MAX_DISPLAY
                for i = 1, numDebuffs do
                    local button = _G["DebuffButton" .. i]
                    if button and button:IsShown() then
                        button:SetScale(size / 32) -- Default size is 32, so scale accordingly
                    end
                end
            end)
        end
    end
    
    -- Apply cooldown text
    if self.settings.showCooldownText then
        -- Ensure OmniCC or similar cooldown text is enabled for auras
    else
        -- Disable cooldown text for auras
    end
end

-- Set up custom position
function EPF:SetupCustomPosition()
    if not self.settings.customPosition or not PlayerFrame then return end
    
    -- This would typically use saved coordinates
    if self.settings.position then
        local pos = self.settings.position
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
        PlayerFrame:SetUserPlaced(true)
    end
end

-- Save custom position
function EPF:SaveCustomPosition()
    if not PlayerFrame then return end
    
    local point, _, relativePoint, x, y = PlayerFrame:GetPoint()
    self.settings.position = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y
    }
end

-- Register hooks
function EPF:RegisterHooks()
    -- Hook Player and Pet Frame handlers
    if not self.hooked then
        -- Hook player frame updates
        hooksecurefunc("PlayerFrame_Update", function()
            if self.enabled then
                self:SetupPlayerFrame()
            end
        end)
        
        self.hooked = true
    end
end

-- Unregister hooks
function EPF:UnregisterHooks()
    -- Nothing to unregister specifically since we're using hooksecurefunc
    -- which doesn't allow unhooking. We just check self.enabled in our hooks.
end

-- Restore default player frame
function EPF:RestoreDefaultPlayerFrame()
    if not PlayerFrame then return end
    
    -- Restore original scale and alpha
    if self.originalScale then
        PlayerFrame:SetScale(self.originalScale)
    end
    if self.originalAlpha then
        PlayerFrame:SetAlpha(self.originalAlpha)
    end
    
    -- Restore default position
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4)
    
    -- Reset health bar
    if PlayerFrameHealthBar then
        PlayerFrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        if PlayerFrameHealthBar.valueText then
            PlayerFrameHealthBar.valueText:Hide()
        end
        if PlayerFrameHealthBar.background then
            PlayerFrameHealthBar.background:SetColorTexture(0, 0, 0, 0.5)
        end
    end
    
    -- Reset power bar
    if PlayerFrameManaBar then
        PlayerFrameManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        if PlayerFrameManaBar.valueText then
            PlayerFrameManaBar.valueText:Hide()
        end
        if PlayerFrameManaBar.background then
            PlayerFrameManaBar.background:SetColorTexture(0, 0, 0, 0.5)
        end
    end
    
    -- Restore portrait
    if PlayerPortrait3D and PlayerPortrait2D then
        PlayerPortrait3D:Show()
        PlayerPortrait2D:Hide()
    end
    
    -- Show HUD elements
    if MainMenuExpBar then
        MainMenuExpBar:Show()
    end
    if PlayerRestIcon then
        PlayerRestIcon:Show()
    end
    if PlayerPVPIcon then
        PlayerPVPIcon:Show()
    end
    
    -- Reset portrait background
    if self.portraitBg then
        self.portraitBg:Hide()
    end
end

-- Get the module configuration for AceConfig
function EPF:GetConfig()
    return {
        order = 27, -- Position in the modules list
        type = "group",
        name = "Enhanced Player Frame",
        desc = "Configure the player frame appearance and functionality",
        get = function(info) return self.settings[info[#info]] end,
        set = function(info, value)
            self.settings[info[#info]] = value
            if self.enabled then
                self:SetupPlayerFrame()
            end
        end,
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable Enhanced Player Frame",
                desc = "Toggle the enhanced player frame on/off",
                width = "full",
                get = function() return self.enabled end,
                set = function(_, value)
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end
            },
            general = {
                order = 2,
                type = "group",
                name = "General Settings",
                inline = true,
                args = {
                    frameScale = {
                        order = 1,
                        type = "range",
                        name = "Frame Scale",
                        desc = "Adjust the size of the player frame",
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                    },
                    frameAlpha = {
                        order = 2,
                        type = "range",
                        name = "Frame Alpha",
                        desc = "Adjust the transparency of the player frame",
                        min = 0.1,
                        max = 1.0,
                        step = 0.1,
                    },
                    useThemeColors = {
                        order = 3,
                        type = "toggle",
                        name = "Use Theme Colors",
                        desc = "Apply the current VUI theme colors to player frame elements",
                    },
                },
            },
            healthBar = {
                order = 3,
                type = "group",
                name = "Health Bar",
                inline = true,
                args = {
                    healthBarHeight = {
                        order = 1,
                        type = "range",
                        name = "Height",
                        desc = "Adjust the height of the health bar",
                        min = 10,
                        max = 50,
                        step = 1,
                    },
                    healthBarTexture = {
                        order = 2,
                        type = "select",
                        name = "Texture",
                        desc = "Choose the texture for the health bar",
                        values = function() 
                            return VUI.Media:HashTable("statusbar") or {VUI_Smooth = "VUI Smooth"} 
                        end,
                    },
                    classColoredHealthBar = {
                        order = 3,
                        type = "toggle",
                        name = "Class Color",
                        desc = "Color the health bar based on player class",
                    },
                },
            },
            healthText = {
                order = 4,
                type = "group",
                name = "Health Text",
                inline = true,
                args = {
                    healthFormat = {
                        order = 1,
                        type = "select",
                        name = "Format",
                        desc = "Choose how health value is displayed",
                        values = {
                            ["percent"] = "Percentage only",
                            ["value"] = "Current value only",
                            ["both"] = "Current value and percentage",
                            ["deficit"] = "Health deficit (when not full)",
                        },
                    },
                    healthFontSize = {
                        order = 2,
                        type = "range",
                        name = "Font Size",
                        desc = "Adjust the size of the health text",
                        min = 8,
                        max = 20,
                        step = 1,
                    },
                    healthFontOutline = {
                        order = 3,
                        type = "select",
                        name = "Font Outline",
                        desc = "Choose the outline style for health text",
                        values = {
                            [""] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                        },
                    },
                },
            },
            powerBar = {
                order = 5,
                type = "group",
                name = "Power Bar",
                inline = true,
                args = {
                    powerBarHeight = {
                        order = 1,
                        type = "range",
                        name = "Height",
                        desc = "Adjust the height of the power bar",
                        min = 5,
                        max = 30,
                        step = 1,
                    },
                    powerBarTexture = {
                        order = 2,
                        type = "select",
                        name = "Texture",
                        desc = "Choose the texture for the power bar",
                        values = function() 
                            return VUI.Media:HashTable("statusbar") or {VUI_Smooth = "VUI Smooth"} 
                        end,
                    },
                },
            },
            powerText = {
                order = 6,
                type = "group",
                name = "Power Text",
                inline = true,
                args = {
                    powerFormat = {
                        order = 1,
                        type = "select",
                        name = "Format",
                        desc = "Choose how power value is displayed",
                        values = {
                            ["percent"] = "Percentage only",
                            ["value"] = "Current value only",
                            ["both"] = "Current value and percentage",
                            ["deficit"] = "Power deficit (when not full)",
                        },
                    },
                    powerFontSize = {
                        order = 2,
                        type = "range",
                        name = "Font Size",
                        desc = "Adjust the size of the power text",
                        min = 8,
                        max = 16,
                        step = 1,
                    },
                    powerFontOutline = {
                        order = 3,
                        type = "select",
                        name = "Font Outline",
                        desc = "Choose the outline style for power text",
                        values = {
                            [""] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                        },
                    },
                },
            },
            portrait = {
                order = 7,
                type = "group",
                name = "Portrait",
                inline = true,
                args = {
                    portraitStyle = {
                        order = 1,
                        type = "select",
                        name = "Style",
                        desc = "Choose how the portrait is displayed",
                        values = {
                            ["3D"] = "3D Model",
                            ["2D"] = "2D Class Icon",
                            ["none"] = "Hide Portrait",
                        },
                    },
                    portraitBackgroundStyle = {
                        order = 2,
                        type = "select",
                        name = "Background",
                        desc = "Choose the portrait background style",
                        values = {
                            ["solid"] = "Solid Color",
                            ["class"] = "Class Color",
                            ["none"] = "No Background",
                        },
                    },
                },
            },
            hudElements = {
                order = 8,
                type = "group",
                name = "HUD Elements",
                inline = true,
                args = {
                    showCastingBar = {
                        order = 1,
                        type = "toggle",
                        name = "Show Casting Bar",
                        desc = "Show or hide the player casting bar",
                    },
                    showXpBar = {
                        order = 2,
                        type = "toggle",
                        name = "Show XP Bar",
                        desc = "Show or hide the experience bar",
                    },
                    showRestingIcon = {
                        order = 3,
                        type = "toggle",
                        name = "Show Resting Icon",
                        desc = "Show or hide the resting state icon",
                    },
                    showPvPIcon = {
                        order = 4,
                        type = "toggle",
                        name = "Show PvP Icon",
                        desc = "Show or hide the PvP status icon",
                    },
                    showLeaderIcon = {
                        order = 5,
                        type = "toggle",
                        name = "Show Leader Icon",
                        desc = "Show or hide the group leader icon",
                    },
                    showLootIcon = {
                        order = 6,
                        type = "toggle",
                        name = "Show Loot Master Icon",
                        desc = "Show or hide the loot master icon",
                    },
                },
            },
            auras = {
                order = 9,
                type = "group",
                name = "Auras (Buffs/Debuffs)",
                inline = true,
                args = {
                    showAuras = {
                        order = 1,
                        type = "toggle",
                        name = "Show Auras",
                        desc = "Show or hide player buffs and debuffs",
                    },
                    auraSize = {
                        order = 2,
                        type = "range",
                        name = "Aura Size",
                        desc = "Adjust the size of buff and debuff icons",
                        min = 16,
                        max = 40,
                        step = 2,
                        disabled = function() return not self.settings.showAuras end,
                    },
                    aurasPerRow = {
                        order = 3,
                        type = "range",
                        name = "Auras Per Row",
                        desc = "Set the number of auras displayed per row",
                        min = 4,
                        max = 16,
                        step = 1,
                        disabled = function() return not self.settings.showAuras end,
                    },
                    showCooldownText = {
                        order = 4,
                        type = "toggle",
                        name = "Show Cooldown Text",
                        desc = "Show countdown numbers on buff/debuff icons",
                        disabled = function() return not self.settings.showAuras end,
                    },
                },
            },
            positioning = {
                order = 10,
                type = "group",
                name = "Positioning",
                inline = true,
                args = {
                    customPosition = {
                        order = 1,
                        type = "toggle",
                        name = "Custom Position",
                        desc = "Enable custom positioning of the player frame",
                    },
                    savePosition = {
                        order = 2,
                        type = "execute",
                        name = "Save Current Position",
                        desc = "Save the current player frame position",
                        func = function() self:SaveCustomPosition() end,
                        disabled = function() return not self.settings.customPosition end,
                    },
                    resetPosition = {
                        order = 3,
                        type = "execute",
                        name = "Reset Position",
                        desc = "Reset player frame to default position",
                        func = function()
                            self.settings.position = nil
                            self:RestoreDefaultPlayerFrame()
                            
                            -- Re-apply settings if enabled
                            if self.enabled then
                                self:SetupPlayerFrame()
                            end
                        end,
                        disabled = function() return not self.settings.customPosition end,
                    },
                },
            },

            resetModule = {
                order = 1000,
                type = "execute",
                width = "full",
                name = "Reset Module Settings",
                desc = "Reset all Enhanced Player Frame settings to defaults",
                func = function()
                    -- Disable first
                    self:Disable()
                    
                    -- Reset settings
                    self.settings = {}
                    
                    -- Initialize defaults
                    self:InitializeDefaults()
                    
                    -- Apply changes
                    if self.enabled then
                        self:SetupPlayerFrame()
                    end
                end,
                disabled = function() return not self.enabled end,
            },
        },
    }
end

-- Get the module's widget for the simple tab UI
function EPF:GetWidget()
    return {
        type = "group",
        name = "Enhanced Player Frame",
        args = {
            desc = {
                order = 1,
                type = "description",
                name = "Configure the player frame appearance and functionality",
                fontSize = "medium",
            },
            enabled = {
                order = 2,
                type = "toggle",
                name = "Enable Enhanced Player Frame",
                width = "full",
                get = function() return self.enabled end,
                set = function(_, value)
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
            },
            frameScale = {
                order = 3,
                type = "range",
                name = "Frame Scale",
                desc = "Adjust the size of the player frame",
                min = 0.5,
                max = 2.0,
                step = 0.1,
                get = function() return self.settings.frameScale end,
                set = function(_, value)
                    self.settings.frameScale = value
                    if self.enabled then
                        self:SetupPlayerFrame()
                    end
                end,
                disabled = function() return not self.enabled end,
            },
            spacer = {
                order = 4,
                type = "description",
                name = " ",
            },
            fullConfigButton = {
                order = 5,
                type = "execute",
                name = "Open Full Configuration",
                func = function()
                    VUI:OpenConfig("modules", "epf")
                end,
            },
        },
    }
end

-- Register this module with VUI
VUI:RegisterModule("epf", EPF)