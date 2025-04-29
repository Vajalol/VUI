local _, VUI = ...

-- Enhanced Player Frame Module based on EPF-Enhanced from Wago.io
local EPF = {
    name = "Enhanced Player Frame",
    enabled = true, -- Enabled by default
    settings = {},
    version = "1.0.0",
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
                self:ApplyTheme(theme)
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
        self:ApplyTheme()
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
    
    -- Set up group icons
    if PlayerLeaderIcon then
        PlayerLeaderIcon:SetShown(self.settings.showLeaderIcon)
    end
    
    if PlayerMasterIcon then
        PlayerMasterIcon:SetShown(self.settings.showLootIcon)
    end
end

-- Set up auras (buffs and debuffs)
function EPF:SetupAuras()
    if not self.settings.showAuras then
        -- Hide buff frames if they exist
        if BuffFrame then
            BuffFrame:Hide()
        end
        return
    end
    
    -- Show buff frames
    if BuffFrame then
        BuffFrame:Show()
    end
    
    -- Customize buff display
    local size = self.settings.auraSize
    local perRow = self.settings.aurasPerRow
    
    -- Apply settings to buff frames
    if BUFF_ACTUAL_DISPLAY and size and perRow then
        for i = 1, BUFF_ACTUAL_DISPLAY do
            local buffName = "BuffButton" .. i
            local button = _G[buffName]
            
            if button then
                button:SetSize(size, size)
                
                -- Set position based on index and perRow
                local index = i - 1
                local row = math.floor(index / perRow)
                local col = index % perRow
                
                button:ClearAllPoints()
                if i == 1 then
                    -- First buff
                    button:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", -15, -15)
                else
                    if col == 0 then
                        -- New row
                        local prevRow = "BuffButton" .. (i - perRow)
                        button:SetPoint("TOPRIGHT", _G[prevRow], "BOTTOMRIGHT", 0, -5)
                    else
                        -- Same row, next column
                        local prev = "BuffButton" .. (i - 1)
                        button:SetPoint("TOPRIGHT", _G[prev], "TOPLEFT", -5, 0)
                    end
                end
                
                -- Set up cooldown text
                local cooldown = _G[buffName .. "Cooldown"]
                if cooldown then
                    if self.settings.showCooldownText then
                        if not cooldown.text then
                            cooldown.text = cooldown:CreateFontString(nil, "OVERLAY")
                            cooldown.text:SetFont(STANDARD_TEXT_FONT, size/3, "OUTLINE")
                            cooldown.text:SetPoint("CENTER", cooldown, "CENTER", 0, 0)
                        end
                        cooldown.text:Show()
                    elseif cooldown.text then
                        cooldown.text:Hide()
                    end
                end
            end
        end
    end
    
    -- Hook buff updates if not already hooked
    if not self.buffUpdateHooked then
        hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", function()
            self:SetupAuras()
        end)
        self.buffUpdateHooked = true
    end
end

-- Set up custom position for player frame
function EPF:SetupCustomPosition()
    if not PlayerFrame or not self.settings.customPosition then return end
    
    -- Make frame movable
    PlayerFrame:SetMovable(true)
    PlayerFrame:SetUserPlaced(true)
    
    -- Set position if stored values exist
    if self.settings.position then
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint(
            self.settings.position.point,
            self.settings.position.relativeTo,
            self.settings.position.relativePoint,
            self.settings.position.x,
            self.settings.position.y
        )
    end
    
    -- Create drag functionality if it doesn't exist
    if not self.dragFrame then
        self.dragFrame = CreateFrame("Frame", nil, PlayerFrame)
        self.dragFrame:SetAllPoints(PlayerFrame)
        self.dragFrame:SetFrameStrata("HIGH")
        self.dragFrame:EnableMouse(false)
        self.dragFrame:Hide()
        
        self.dragFrame.text = self.dragFrame:CreateFontString(nil, "OVERLAY")
        self.dragFrame.text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
        self.dragFrame.text:SetPoint("CENTER", self.dragFrame, "CENTER", 0, 0)
        self.dragFrame.text:SetText("Left-click and drag to move")
        
        self.dragFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                PlayerFrame:StartMoving()
            end
        end)
        
        self.dragFrame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                PlayerFrame:StopMovingOrSizing()
                
                -- Store position
                local point, relativeTo, relativePoint, x, y = PlayerFrame:GetPoint()
                EPF.settings.position = {
                    point = point,
                    relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
                    relativePoint = relativePoint,
                    x = x,
                    y = y
                }
            end
        end)
    end
end

-- Register event hooks
function EPF:RegisterHooks()
    -- Create an event frame if it doesn't exist
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if EPF[event] then
                EPF[event](EPF, ...)
            end
        end)
    end
    
    -- Register required events
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    self.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
    self.eventFrame:RegisterEvent("UPDATE_FACTION")
    
    -- Hook frame handlers if not already hooked
    if not self.frameHooksRegistered then
        -- Hook PlayerFrame_UpdateStatus
        hooksecurefunc("PlayerFrame_UpdateStatus", function()
            if EPF.enabled then
                EPF:SetupPlayerFrame()
            end
        end)
        
        -- Hook PlayerFrame_UpdateRolesAssigned
        hooksecurefunc("PlayerFrame_UpdateRolesAssigned", function()
            if EPF.enabled then
                EPF:SetupPlayerFrame()
            end
        end)
        
        self.frameHooksRegistered = true
    end
end

-- Unregister event hooks
function EPF:UnregisterHooks()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
    end
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
    
    -- Reset position
    if self.settings.customPosition then
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4)
    end
    
    -- Reset health bar
    if PlayerFrameHealthBar then
        PlayerFrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        PlayerFrameHealthBar:SetHeight(12)
        if PlayerFrameHealthBar.valueText then
            PlayerFrameHealthBar.valueText:Hide()
        end
        if PlayerFrameHealthBar.background then
            PlayerFrameHealthBar.background:Hide()
        end
    end
    
    -- Reset power bar
    if PlayerFrameManaBar then
        PlayerFrameManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        PlayerFrameManaBar:SetHeight(12)
        if PlayerFrameManaBar.valueText then
            PlayerFrameManaBar.valueText:Hide()
        end
        if PlayerFrameManaBar.background then
            PlayerFrameManaBar.background:Hide()
        end
    end
    
    -- Reset portrait
    if PlayerPortrait3D and PlayerPortrait2D then
        PlayerPortrait3D:Show()
        PlayerPortrait2D:Hide()
    end
    
    if self.portraitBg then
        self.portraitBg:Hide()
    end
    
    -- Reset HUD elements
    if PlayerRestIcon then
        PlayerRestIcon:Show()
    end
    
    if PlayerPVPIcon then
        PlayerPVPIcon:Show()
    end
    
    if PlayerLeaderIcon then
        PlayerLeaderIcon:Show()
    end
    
    if PlayerMasterIcon then
        PlayerMasterIcon:Show()
    end
    
    -- Reset buff frames
    if BuffFrame then
        BuffFrame:Show()
    end
    
    -- Hide drag frame
    if self.dragFrame then
        self.dragFrame:Hide()
    end
end

-- Format values for display (e.g., 1.2k for 1200)
function EPF:FormatValue(value)
    if not value then return "" end
    
    if value >= 1000000 then
        return string.format("%.1fm", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fk", value / 1000)
    else
        return tostring(value)
    end
end

-- Event handlers
function EPF:PLAYER_ENTERING_WORLD()
    self:SetupPlayerFrame()
end

function EPF:UNIT_PORTRAIT_UPDATE(unit)
    if unit == "player" then
        self:SetupPortrait()
    end
end

function EPF:PLAYER_REGEN_DISABLED()
    -- Combat started, update frame with combat-specific features
    if self.enabled then
        -- Apply combat-specific settings
    end
end

function EPF:PLAYER_REGEN_ENABLED()
    -- Combat ended, return to normal state
    if self.enabled then
        -- Apply non-combat settings
    end
end

function EPF:PLAYER_LEVEL_UP(level)
    -- Update for level up
    if self.enabled then
        self:SetupPlayerFrame()
    end
end

-- Get the module's config options for the UI
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
                end,
            },
            generalHeader = {
                order = 2,
                type = "header",
                name = "General Settings",
            },
            frameScale = {
                order = 3,
                type = "range",
                name = "Frame Scale",
                desc = "Adjust the overall scale of the player frame",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                disabled = function() return not self.enabled end,
            },
            frameAlpha = {
                order = 4,
                type = "range",
                name = "Frame Alpha",
                desc = "Adjust the transparency of the player frame",
                min = 0.1,
                max = 1.0,
                step = 0.05,
                disabled = function() return not self.enabled end,
            },
            customPosition = {
                order = 5,
                type = "toggle",
                name = "Enable Custom Position",
                desc = "Allow the player frame to be moved to a custom position",
                disabled = function() return not self.enabled end,
                set = function(_, value)
                    self.settings.customPosition = value
                    if value then
                        self:SetupCustomPosition()
                        if self.dragFrame then
                            self.dragFrame:EnableMouse(true)
                            self.dragFrame:Show()
                        end
                    else
                        self:RestoreDefaultPlayerFrame()
                        self:SetupPlayerFrame()
                        if self.dragFrame then
                            self.dragFrame:EnableMouse(false)
                            self.dragFrame:Hide()
                        end
                    end
                end,
            },
            useThemeColors = {
                order = 6,
                type = "toggle",
                name = "Use Theme Colors",
                desc = "Apply the current VUI theme colors to the player frame",
                disabled = function() return not self.enabled end,
                set = function(_, value)
                    self.settings.useThemeColors = value
                    if value then
                        self:ApplyTheme()
                    else
                        -- Reset to default colors
                        self:SetupPlayerFrame()
                    end
                end,
            },
            healthHeader = {
                order = 10,
                type = "header",
                name = "Health Bar Settings",
            },
            healthBarTexture = {
                order = 11,
                type = "select",
                name = "Health Bar Texture",
                desc = "Choose the texture used for the health bar",
                values = function() return VUI.Media:GetStatusBarTextureTable() end,
                disabled = function() return not self.enabled end,
            },
            healthBarHeight = {
                order = 12,
                type = "range",
                name = "Health Bar Height",
                desc = "Adjust the height of the health bar",
                min = 6,
                max = 50,
                step = 1,
                disabled = function() return not self.enabled end,
            },
            classColoredHealthBar = {
                order = 13,
                type = "toggle",
                name = "Class Colored Health Bar",
                desc = "Color the health bar based on your class",
                disabled = function() return not self.enabled end,
            },
            healthFormat = {
                order = 14,
                type = "select",
                name = "Health Text Format",
                desc = "Choose how health values are displayed",
                values = {
                    none = "No Text",
                    value = "Current Value",
                    percent = "Percentage",
                    both = "Value and Percentage",
                    deficit = "Deficit When Not Full",
                },
                disabled = function() return not self.enabled end,
            },
            healthFontSize = {
                order = 15,
                type = "range",
                name = "Health Font Size",
                desc = "Adjust the size of the health text",
                min = 6,
                max = 20,
                step = 1,
                disabled = function() return not self.enabled or self.settings.healthFormat == "none" end,
            },
            healthFontOutline = {
                order = 16,
                type = "select",
                name = "Health Font Outline",
                desc = "Choose the outline style for health text",
                values = {
                    NONE = "None",
                    OUTLINE = "Outline",
                    THICKOUTLINE = "Thick Outline",
                    MONOCHROME = "Monochrome",
                },
                disabled = function() return not self.enabled or self.settings.healthFormat == "none" end,
            },
            powerHeader = {
                order = 20,
                type = "header",
                name = "Power Bar Settings",
            },
            powerBarTexture = {
                order = 21,
                type = "select",
                name = "Power Bar Texture",
                desc = "Choose the texture used for the power bar",
                values = function() return VUI.Media:GetStatusBarTextureTable() end,
                disabled = function() return not self.enabled end,
            },
            powerBarHeight = {
                order = 22,
                type = "range",
                name = "Power Bar Height",
                desc = "Adjust the height of the power bar",
                min = 6,
                max = 30,
                step = 1,
                disabled = function() return not self.enabled end,
            },
            powerFormat = {
                order = 23,
                type = "select",
                name = "Power Text Format",
                desc = "Choose how power values are displayed",
                values = {
                    none = "No Text",
                    value = "Current Value",
                    percent = "Percentage",
                    both = "Value and Percentage",
                    deficit = "Deficit When Not Full",
                },
                disabled = function() return not self.enabled end,
            },
            powerFontSize = {
                order = 24,
                type = "range",
                name = "Power Font Size",
                desc = "Adjust the size of the power text",
                min = 6,
                max = 20,
                step = 1,
                disabled = function() return not self.enabled or self.settings.powerFormat == "none" end,
            },
            powerFontOutline = {
                order = 25,
                type = "select",
                name = "Power Font Outline",
                desc = "Choose the outline style for power text",
                values = {
                    NONE = "None",
                    OUTLINE = "Outline",
                    THICKOUTLINE = "Thick Outline",
                    MONOCHROME = "Monochrome",
                },
                disabled = function() return not self.enabled or self.settings.powerFormat == "none" end,
            },
            portraitHeader = {
                order = 30,
                type = "header",
                name = "Portrait Settings",
            },
            portraitStyle = {
                order = 31,
                type = "select",
                name = "Portrait Style",
                desc = "Choose the style of portrait to display",
                values = {
                    ["3D"] = "3D Model",
                    ["2D"] = "Class Icon",
                    none = "No Portrait",
                },
                disabled = function() return not self.enabled end,
            },
            portraitBackgroundStyle = {
                order = 32,
                type = "select",
                name = "Portrait Background",
                desc = "Choose the background style for the portrait",
                values = {
                    none = "No Background",
                    solid = "Solid Color",
                    class = "Class Color",
                },
                disabled = function() return not self.enabled or self.settings.portraitStyle == "none" end,
            },
            elementsHeader = {
                order = 40,
                type = "header",
                name = "HUD Elements",
            },
            showCastingBar = {
                order = 41,
                type = "toggle",
                name = "Show Casting Bar",
                desc = "Show the player casting bar",
                disabled = function() return not self.enabled end,
            },
            showXpBar = {
                order = 42,
                type = "toggle",
                name = "Show XP Bar",
                desc = "Show the experience/reputation bar",
                disabled = function() return not self.enabled end,
            },
            showRestingIcon = {
                order = 43,
                type = "toggle",
                name = "Show Resting Icon",
                desc = "Show the resting status icon",
                disabled = function() return not self.enabled end,
            },
            showPvPIcon = {
                order = 44,
                type = "toggle",
                name = "Show PvP Icon",
                desc = "Show the PvP status icon",
                disabled = function() return not self.enabled end,
            },
            showLeaderIcon = {
                order = 45,
                type = "toggle",
                name = "Show Leader Icon",
                desc = "Show the group leader icon",
                disabled = function() return not self.enabled end,
            },
            showLootIcon = {
                order = 46,
                type = "toggle",
                name = "Show Loot Icon",
                desc = "Show the master looter icon",
                disabled = function() return not self.enabled end,
            },
            aurasHeader = {
                order = 50,
                type = "header",
                name = "Buff/Debuff Settings",
            },
            showAuras = {
                order = 51,
                type = "toggle",
                name = "Show Buffs & Debuffs",
                desc = "Show player buffs and debuffs",
                disabled = function() return not self.enabled end,
            },
            auraSize = {
                order = 52,
                type = "range",
                name = "Aura Size",
                desc = "Adjust the size of buff and debuff icons",
                min = 16,
                max = 40,
                step = 1,
                disabled = function() return not self.enabled or not self.settings.showAuras end,
            },
            aurasPerRow = {
                order = 53,
                type = "range",
                name = "Auras Per Row",
                desc = "Number of auras to display per row",
                min = 4,
                max = 16,
                step = 1,
                disabled = function() return not self.enabled or not self.settings.showAuras end,
            },
            showCooldownText = {
                order = 54,
                type = "toggle",
                name = "Show Cooldown Text",
                desc = "Show the remaining duration text on buffs and debuffs",
                disabled = function() return not self.enabled or not self.settings.showAuras end,
            },
            resetButton = {
                order = 100,
                type = "execute",
                name = "Reset All Settings",
                desc = "Reset all Enhanced Player Frame settings to defaults",
                func = function()
                    -- Reset to defaults
                    self.settings = {}
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
        name = self.name,
        order = 25,
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable",
                width = "full",
                get = function() return self.enabled end,
                set = function(_, val)
                    if val then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
            },
            configbutton = {
                order = 3,
                type = "execute",
                name = "Settings",
                func = function()
                    VUI:OpenModuleConfig(self.name)
                end,
                disabled = function() return not self.enabled end,
            },
        },
    }
end

-- Get the module's display name for the UI
function EPF:GetDisplayName()
    return "Enhanced Player Frame"
end

-- Get the module's description for the UI
function EPF:GetDescription()
    return "Comprehensive player frame enhancement with health/power text, portraits, and more"
end

-- Get the module's category for organization in the UI
function EPF:GetCategory()
    return "Tools"
end

-- Register the module with VUI
VUI:RegisterModule("epf", EPF)