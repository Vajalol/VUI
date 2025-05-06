local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Action Bars module
VUI.ActionBars = VUI:NewModule("ActionBars")

-- Get configuration options for main UI integration
function VUI.ActionBars:GetConfig()
    local config = {
        name = "ActionBars",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable ActionBars",
                desc = "Enable or disable the ActionBars module",
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
            enhancedStyles = {
                type = "toggle",
                name = "Enhanced Button Styles",
                desc = "Apply enhanced styling to action buttons",
                get = function() return self.db.enhancedStyles end,
                set = function(_, value) 
                    self.db.enhancedStyles = value
                    self:RefreshButtonStyles()
                end,
                order = 2
            },
            showHotkeys = {
                type = "toggle",
                name = "Show Hotkeys",
                desc = "Show keybindings on action buttons",
                get = function() return self.db.showHotkeys end,
                set = function(_, value) 
                    self.db.showHotkeys = value
                    self:UpdateHotkeyDisplay()
                end,
                order = 3
            },
            showMacroNames = {
                type = "toggle",
                name = "Show Macro Names",
                desc = "Show macro names on action buttons",
                get = function() return self.db.showMacroNames end,
                set = function(_, value) 
                    self.db.showMacroNames = value
                    self:UpdateMacroNameDisplay()
                end,
                order = 4
            },
            configButton = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open detailed configuration panel",
                func = function()
                    -- This would open a detailed config panel
                    if self.ToggleAdvancedConfig then
                        self:ToggleAdvancedConfig()
                    end
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("actionbars", VUI.ActionBars:GetConfig())

-- Local variables
local activeTheme = "thunderstorm"  -- Default to Thunder Storm theme
local themeColors = {}
local combatFeedbackEffects = {}   -- Store combat feedback effects
local isInCombat = false           -- Track combat state
local lastCastTime = 0             -- Track last spell cast time

function VUI.ActionBars:OnInitialize()
    -- Default settings
    self.defaults = {
        enabled = true,
        enhancedStyles = true,
        showHotkeys = true,
        showMacroNames = true,
        showCooldownText = true,
        showItemCount = true,
        gridLayout = false,
        highlightEquipped = true,
        customBarBackground = true,
        hideEmptyButtons = false,
        colorKeyBinds = true,
        largerButtons = false,
        themeButtonBorders = true,
        
        -- New improved settings
        enhancedCombatFeedback = true,
        smoothCooldownAnimation = true,
        improvedKeyBindDisplay = true,
        buttonPulseOnActivation = true,
        animatedGlowEffects = true,
        dynamicButtonHighlight = true
    }
    
    -- Initialize with default settings
    self.settings = VUI:MergeDefaults(self.defaults, VUI.db.profile.modules.actionbars)
    
    -- Get current theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    activeTheme = theme
    themeColors = VUI.media.themes[theme] or {}
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    self:RegisterEvent("UPDATE_BINDINGS")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    
    -- Apply initial settings
    if self.settings.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function VUI.ActionBars:OnEnable()
    -- Hook into action bars
    self:HookActionBars()
    -- Apply theme
    self:ApplyTheme(activeTheme, themeColors)
    -- Update all bars
    self:UpdateActionBars()
    
    -- Register additional events for enhanced functionality
    if self.settings.enhancedCombatFeedback then
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        self:RegisterEvent("UNIT_SPELLCAST_START")
        self:RegisterEvent("UNIT_SPELLCAST_STOP")
        self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    end
    
    -- Initialize improved key bind display
    if self.settings.improvedKeyBindDisplay then
        self:EnhanceKeyBindDisplay()
    end
    
    -- Initialize smooth cooldown animations
    if self.settings.smoothCooldownAnimation then
        self:InitializeSmoothCooldowns()
    end
end

function VUI.ActionBars:OnDisable()
    -- Unregister events
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:UnregisterEvent("UNIT_SPELLCAST_START")
    self:UnregisterEvent("UNIT_SPELLCAST_STOP")
    self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
    
    -- Reset to Blizzard defaults if needed
    -- Remove any active visual effects
    self:ClearAllCombatFeedback()
end

function VUI.ActionBars:PLAYER_ENTERING_WORLD()
    self:UpdateActionBars()
    isInCombat = InCombatLockdown()
    
    -- Clear any lingering effects
    self:ClearAllCombatFeedback()
end

function VUI.ActionBars:PLAYER_REGEN_DISABLED()
    isInCombat = true
    self:ApplyCombatState(true)
end

function VUI.ActionBars:PLAYER_REGEN_ENABLED()
    isInCombat = false
    self:ApplyCombatState(false)
end

function VUI.ActionBars:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
    if unit ~= "player" or not self.settings.enhancedCombatFeedback then return end
    
    -- Track the spell cast and create button feedback
    lastCastTime = GetTime()
    self:CreateSpellCastFeedback(spellID)
end

function VUI.ActionBars:UNIT_SPELLCAST_START(event, unit, castGUID, spellID)
    if unit ~= "player" or not self.settings.enhancedCombatFeedback then return end
    
    -- Highlight the spell being cast
    self:HighlightCastingSpell(spellID)
end

function VUI.ActionBars:UNIT_SPELLCAST_STOP(event, unit, castGUID, spellID)
    if unit ~= "player" or not self.settings.enhancedCombatFeedback then return end
    
    -- Clear the casting highlight
    self:ClearCastingHighlight(spellID)
end

function VUI.ActionBars:UNIT_SPELLCAST_FAILED(event, unit, castGUID, spellID)
    if unit ~= "player" or not self.settings.enhancedCombatFeedback then return end
    
    -- Show failure feedback
    self:ShowCastFailFeedback(spellID)
end

function VUI.ActionBars:ACTIONBAR_UPDATE_COOLDOWN()
    if self.settings.showCooldownText then
        self:UpdateCooldownText()
    end
    
    -- Apply enhanced cooldown visuals
    if self.settings.smoothCooldownAnimation then
        self:UpdateEnhancedCooldowns()
    end
end

function VUI.ActionBars:ACTIONBAR_UPDATE_STATE()
    self:UpdateActionButtonState()
    
    -- Apply combat state enhancements if in combat
    if isInCombat and self.settings.enhancedCombatFeedback then
        self:RefreshCombatFeedback()
    end
end

function VUI.ActionBars:HookActionBars()
    if self.hooked then return end
    
    -- Hook into action button creation
    hooksecurefunc("ActionButton_OnLoad", function(self)
        VUI.ActionBars:StyleActionButton(self)
    end)
    
    -- Hook into action button update
    hooksecurefunc("ActionButton_UpdateState", function(self)
        VUI.ActionBars:UpdateActionButtonState(self)
    end)
    
    -- Hook into cooldown update
    hooksecurefunc("ActionButton_UpdateCooldown", function(self)
        VUI.ActionBars:UpdateButtonCooldown(self)
    end)
    
    -- Hook into count update
    hooksecurefunc("ActionButton_UpdateCount", function(self)
        VUI.ActionBars:UpdateButtonCount(self)
    end)
    
    -- Hook keybind display
    hooksecurefunc("ActionButton_UpdateHotkeys", function(self)
        VUI.ActionBars:UpdateHotkeys(self)
    end)
    
    -- Create themed backgrounds for each action bar
    self:CreateActionBarBackgrounds()
    
    self.hooked = true
end

function VUI.ActionBars:CreateActionBarBackgrounds()
    if not self.settings.customBarBackground then return end
    
    -- Create backgrounds for each action bar
    self:CreateBarBackground(1, "BOTTOM", UIParent, "BOTTOM", 0, 20, 12)
    self:CreateBarBackground(2, "BOTTOM", UIParent, "BOTTOM", 0, 55, 12)
    self:CreateBarBackground(3, "RIGHT", UIParent, "RIGHT", -5, 0, 12)
    self:CreateBarBackground(4, "RIGHT", self.barBackgrounds[3], "LEFT", -1, 0, 12)
    
    -- Style stance bar if present
    if StanceBarFrame then
        self:CreateBarBackground("stance", "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 160, GetNumShapeshiftForms())
    end
    
    -- Style pet bar if present
    if PetActionBarFrame then
        self:CreateBarBackground("pet", "BOTTOM", UIParent, "BOTTOM", 0, 90, 10)
    end
end

function VUI.ActionBars:CreateBarBackground(barIndex, point, relativeTo, relativePoint, xOffset, yOffset, numButtons)
    if not self.barBackgrounds then
        self.barBackgrounds = {}
    end
    
    if self.barBackgrounds[barIndex] then
        self.barBackgrounds[barIndex]:Show()
        return
    end
    
    local frame = CreateFrame("Frame", "VUIActionBarBackground"..barIndex, UIParent)
    
    -- Set position and size based on bar index
    local buttonSize = 36
    if self.settings.largerButtons then
        buttonSize = 40
    end
    
    local width = buttonSize * numButtons + 10
    local height = buttonSize + 10
    
    frame:SetSize(width, height)
    frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    
    -- Create a backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = {left = 3, right = 3, top = 3, bottom = 3}
    })
    
    -- Apply theme color to the background
    frame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.7)
    frame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    
    -- Store the frame
    self.barBackgrounds[barIndex] = frame
    
    -- Set as lower level than buttons
    frame:SetFrameLevel(1)
end

function VUI.ActionBars:StyleActionButton(button)
    if not button or button.VUISkinned then return end
    
    -- Add a backdrop to the button
    if not button.backdrop then
        button.backdrop = CreateFrame("Frame", nil, button)
        button.backdrop:SetAllPoints(button)
        button.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
        
        -- Create a backdrop
        button.backdrop:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = {left = -1, right = -1, top = -1, bottom = -1}
        })
    end
    
    -- Apply theme color to the button backdrop
    button.backdrop:SetBackdropColor(0, 0, 0, 0.5) -- Transparent black background
    
    if self.settings.themeButtonBorders then
        button.backdrop:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.8)
    else
        button.backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8) -- Default gray border
    end
    
    -- Make the button slightly larger if enabled
    if self.settings.largerButtons then
        button:SetSize(40, 40)
    end
    
    -- Style the normal texture (the border that appears when mousing over)
    local normalTexture = button:GetNormalTexture()
    if normalTexture then
        normalTexture:SetVertexColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b, 0.3)
    end
    
    -- Style hotkey text
    local hotkey = button.HotKey
    if hotkey and self.settings.showHotkeys then
        hotkey:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        
        if self.settings.colorKeyBinds then
            hotkey:SetTextColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b)
        else
            hotkey:SetTextColor(0.75, 0.75, 0.75)
        end
        hotkey:SetDrawLayer("OVERLAY")
        hotkey:ClearAllPoints()
        hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -1)
    elseif hotkey and not self.settings.showHotkeys then
        hotkey:Hide()
    end
    
    -- Style macro name text
    local macroName = button.Name
    if macroName and self.settings.showMacroNames then
        macroName:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        macroName:SetTextColor(1, 1, 1)
        macroName:SetDrawLayer("OVERLAY")
        macroName:ClearAllPoints()
        macroName:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)
    elseif macroName and not self.settings.showMacroNames then
        macroName:Hide()
    end
    
    -- Style count text
    local count = button.Count
    if count and self.settings.showItemCount then
        count:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        count:SetTextColor(1, 1, 1)
        count:SetDrawLayer("OVERLAY")
        count:ClearAllPoints()
        count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    elseif count and not self.settings.showItemCount then
        count:Hide()
    end
    
    -- Add a cooldown count text if it doesn't exist
    if self.settings.showCooldownText and not button.cooldownCount then
        button.cooldownCount = button:CreateFontString(nil, "OVERLAY")
        button.cooldownCount:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        button.cooldownCount:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.cooldownCount:SetTextColor(1, 1, 1)
        button.cooldownCount:Hide()
    end
    
    -- Add a border for equipped items if enabled
    if self.settings.highlightEquipped and not button.equippedHighlight then
        button.equippedHighlight = button:CreateTexture(nil, "OVERLAY")
        button.equippedHighlight:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        button.equippedHighlight:SetBlendMode("ADD")
        button.equippedHighlight:SetAllPoints(button)
        button.equippedHighlight:Hide()
    end
    
    button.VUISkinned = true
end

function VUI.ActionBars:UpdateActionButtonState(button)
    if not button or not button.VUISkinned then return end
    
    -- Update equipped item highlight
    if self.settings.highlightEquipped and button.equippedHighlight then
        local actionType, id = GetActionInfo(button.action)
        
        if actionType == "item" then
            -- Check if this item is equipped
            local isEquipped = false
            for slot = 1, 19 do -- Check all equipment slots
                local itemID = GetInventoryItemID("player", slot)
                if itemID and itemID == id then
                    isEquipped = true
                    break
                end
            end
            
            if isEquipped then
                button.equippedHighlight:Show()
            else
                button.equippedHighlight:Hide()
            end
        else
            button.equippedHighlight:Hide()
        end
    end
    
    -- Hide empty buttons if configured
    if self.settings.hideEmptyButtons then
        local actionType = GetActionInfo(button.action)
        if not actionType then
            button:SetAlpha(0)
        else
            button:SetAlpha(1)
        end
    end
end

function VUI.ActionBars:UpdateButtonCooldown(button)
    if not button or not button.VUISkinned or not button.cooldownCount then return end
    
    local cooldown = button.cooldown
    if cooldown and self.settings.showCooldownText then
        local start, duration = cooldown:GetCooldownTimes()
        
        if start > 0 and duration > 0 then
            local remaining = (start + duration) / 1000 - GetTime()
            
            if remaining > 0 then
                button.cooldownCount:Show()
                button.cooldownCount:SetText(self:FormatCooldownTime(remaining))
                
                -- Schedule an update for this cooldown
                if not button.cooldownUpdate then
                    button.cooldownUpdate = C_Timer.NewTicker(0.1, function()
                        self:UpdateCooldownText(button)
                    end)
                end
            else
                button.cooldownCount:Hide()
                if button.cooldownUpdate then
                    button.cooldownUpdate:Cancel()
                    button.cooldownUpdate = nil
                end
            end
        else
            button.cooldownCount:Hide()
            if button.cooldownUpdate then
                button.cooldownUpdate:Cancel()
                button.cooldownUpdate = nil
            end
        end
    end
end

function VUI.ActionBars:UpdateCooldownText(button)
    if not button then
        -- Update all buttons if none specified
        for i = 1, 120 do
            local btn = _G["ActionButton"..i]
            if btn and btn.VUISkinned then
                self:UpdateButtonCooldown(btn)
            end
            
            -- Check stance buttons
            if StanceBarFrame then
                for j = 1, GetNumShapeshiftForms() do
                    local stanceBtn = _G["StanceButton"..j]
                    if stanceBtn and stanceBtn.VUISkinned then
                        self:UpdateButtonCooldown(stanceBtn)
                    end
                end
            end
            
            -- Check pet buttons
            if PetActionBarFrame then
                for j = 1, 10 do
                    local petBtn = _G["PetActionButton"..j]
                    if petBtn and petBtn.VUISkinned then
                        self:UpdateButtonCooldown(petBtn)
                    end
                end
            end
        end
    else
        local cooldown = button.cooldown
        if cooldown and button.cooldownCount and self.settings.showCooldownText then
            local start, duration = cooldown:GetCooldownTimes()
            
            if start > 0 and duration > 0 then
                local remaining = (start + duration) / 1000 - GetTime()
                
                if remaining > 0 then
                    button.cooldownCount:Show()
                    button.cooldownCount:SetText(self:FormatCooldownTime(remaining))
                else
                    button.cooldownCount:Hide()
                    if button.cooldownUpdate then
                        button.cooldownUpdate:Cancel()
                        button.cooldownUpdate = nil
                    end
                end
            else
                button.cooldownCount:Hide()
                if button.cooldownUpdate then
                    button.cooldownUpdate:Cancel()
                    button.cooldownUpdate = nil
                end
            end
        end
    end
end

function VUI.ActionBars:FormatCooldownTime(time)
    if time <= 0 then
        return ""
    elseif time < 1 then
        return string.format("%.1f", time)
    elseif time < 60 then
        return string.format("%d", time)
    elseif time < 3600 then
        return string.format("%d:%02d", time / 60, time % 60)
    else
        return string.format("%d:%02d", time / 3600, (time % 3600) / 60)
    end
end

function VUI.ActionBars:UpdateButtonCount(button)
    if not button or not button.VUISkinned then return end
    
    -- Update the count visibility
    local count = button.Count
    if count then
        if self.settings.showItemCount then
            count:Show()
        else
            count:Hide()
        end
    end
end

function VUI.ActionBars:UpdateHotkeys(button)
    if not button or not button.VUISkinned then return end
    
    -- Update the hotkey visibility and color
    local hotkey = button.HotKey
    if hotkey then
        if self.settings.showHotkeys then
            hotkey:Show()
            
            if self.settings.colorKeyBinds then
                hotkey:SetTextColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b)
            else
                hotkey:SetTextColor(0.75, 0.75, 0.75)
            end
        else
            hotkey:Hide()
        end
    end
end

function VUI.ActionBars:UpdateActionBars()
    -- Style all action buttons
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button then
            self:StyleActionButton(button)
            self:UpdateActionButtonState(button)
            self:UpdateButtonCooldown(button)
            self:UpdateButtonCount(button)
            self:UpdateHotkeys(button)
        end
    end
    
    -- Style stance buttons if they exist
    if StanceBarFrame then
        for i = 1, GetNumShapeshiftForms() do
            local button = _G["StanceButton"..i]
            if button then
                self:StyleActionButton(button)
                self:UpdateButtonCooldown(button)
            end
        end
    end
    
    -- Style pet buttons if they exist
    if PetActionBarFrame then
        for i = 1, 10 do
            local button = _G["PetActionButton"..i]
            if button then
                self:StyleActionButton(button)
                self:UpdateButtonCooldown(button)
            end
        end
    end
    
    -- Update background visibility
    if self.barBackgrounds then
        for idx, frame in pairs(self.barBackgrounds) do
            if self.settings.customBarBackground then
                frame:Show()
            else
                frame:Hide()
            end
        end
    end
end

-- Enhanced keybind display for better visibility
function VUI.ActionBars:EnhanceKeyBindDisplay()
    -- Apply to all action buttons
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.HotKey then
            -- Only update if keybinds are shown
            if self.settings.showHotkeys then
                -- Clear any previous enhancements
                if button.keyBindBackground then
                    button.keyBindBackground:Hide()
                end
                
                -- Create a background frame for the keybind if it doesn't exist
                if not button.keyBindBackground then
                    button.keyBindBackground = CreateFrame("Frame", nil, button)
                    button.keyBindBackground:SetFrameLevel(button:GetFrameLevel() + 1)
                    
                    -- Position to match hotkey text
                    button.keyBindBackground:ClearAllPoints()
                    button.keyBindBackground:SetPoint("TOPRIGHT", button, "TOPRIGHT", 2, 2)
                    button.keyBindBackground:SetSize(20, 14)
                    
                    -- Create backdrop
                    button.keyBindBackground:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                        edgeFile = "Interface\\Buttons\\WHITE8x8",
                        tile = false,
                        tileSize = 0,
                        edgeSize = 1,
                        insets = {left = 1, right = 1, top = 1, bottom = 1}
                    })
                    
                    -- Apply semi-transparent background
                    button.keyBindBackground:SetBackdropColor(0, 0, 0, 0.7)
                    
                    -- Apply theme-colored border
                    button.keyBindBackground:SetBackdropBorderColor(
                        themeColors.border.r, 
                        themeColors.border.g, 
                        themeColors.border.b, 
                        0.9
                    )
                end
                
                -- Show the enhanced background
                button.keyBindBackground:Show()
                
                -- Make sure hotkey is above the background
                button.HotKey:SetDrawLayer("OVERLAY", 2)
                
                -- Enhance font size and style
                button.HotKey:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                
                -- Update text color based on theme
                if self.settings.colorKeyBinds then
                    button.HotKey:SetTextColor(
                        themeColors.highlight.r,
                        themeColors.highlight.g,
                        themeColors.highlight.b,
                        1
                    )
                else
                    button.HotKey:SetTextColor(0.9, 0.9, 0.9)
                end
                
                -- Adjust position for better visibility
                button.HotKey:ClearAllPoints()
                button.HotKey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -2)
                
                -- Get the current key text and make it more readable
                local keyText = button.HotKey:GetText()
                if keyText and keyText ~= "" and keyText ~= RANGE_INDICATOR then
                    -- Replace confusing key symbols with more readable ones
                    keyText = keyText:gsub("(s%-)", "S") -- Shift
                    keyText = keyText:gsub("(a%-)", "A") -- Alt
                    keyText = keyText:gsub("(c%-)", "C") -- Control
                    
                    -- Remove the "Down" text that sometimes appears
                    keyText = keyText:gsub("Down", "")
                    
                    -- Set the improved text
                    button.HotKey:SetText(keyText)
                end
            elseif button.keyBindBackground then
                button.keyBindBackground:Hide()
            end
        end
    end
end

-- Initialize improved cooldown animations
function VUI.ActionBars:InitializeSmoothCooldowns()
    -- Apply to all action buttons
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.cooldown then
            -- Make sure the cooldown animation is smoother
            button.cooldown:SetDrawEdge(true)
            button.cooldown:SetSwipeColor(0, 0, 0, 0.8) -- More visible but not too distracting
            
            -- Add a pulsing effect when cooldown is about to finish
            if not button.cooldownPulse then
                button.cooldownPulse = button:CreateTexture(nil, "OVERLAY")
                button.cooldownPulse:SetAllPoints(button)
                button.cooldownPulse:SetTexture("Interface\\Buttons\\CheckButtonHilight")
                button.cooldownPulse:SetBlendMode("ADD")
                button.cooldownPulse:SetAlpha(0)
                
                -- Apply theme color to the pulse
                button.cooldownPulse:SetVertexColor(
                    themeColors.highlight.r,
                    themeColors.highlight.g,
                    themeColors.highlight.b,
                    0.7
                )
            end
        end
    end
end

-- Apply animation when ability comes off cooldown
function VUI.ActionBars:AnimateCooldownFinish(button)
    if not button or not button.cooldownPulse then return end
    
    -- Cancel any existing animation
    if button.pulseAnim then
        button.pulseAnim:Cancel()
    end
    
    -- Create a smooth pulse animation
    button.cooldownPulse:SetAlpha(0)
    button.cooldownPulse:Show()
    
    button.pulseAnim = C_Timer.NewTimer(0.1, function()
        -- Create a smooth pulse effect
        local fadeInfo = {
            mode = "IN",
            timeToFade = 0.3,
            startAlpha = 0,
            endAlpha = 0.7,
            finishedFunc = function()
                local fadeOutInfo = {
                    mode = "OUT",
                    timeToFade = 0.5,
                    startAlpha = 0.7,
                    endAlpha = 0,
                    finishedFunc = function()
                        button.cooldownPulse:Hide()
                    end
                }
                UIFrameFade(button.cooldownPulse, fadeOutInfo)
            end
        }
        
        UIFrameFade(button.cooldownPulse, fadeInfo)
    end)
end

-- Apply visual effects based on combat state
function VUI.ActionBars:ApplyCombatState(inCombat)
    if not self.settings.enhancedCombatFeedback then return end
    
    -- Apply to all action buttons
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.VUISkinned then
            if inCombat then
                -- In combat - make buttons more prominent
                
                -- Enhance border
                if button.backdrop then
                    button.backdrop:SetBackdropBorderColor(
                        themeColors.border.r * 1.5,
                        themeColors.border.g * 1.5,
                        themeColors.border.b * 1.5,
                        0.9
                    )
                end
                
                -- Create a subtle glow effect if not already present
                if not button.combatGlow and self.settings.animatedGlowEffects then
                    button.combatGlow = button:CreateTexture(nil, "OVERLAY")
                    button.combatGlow:SetPoint("CENTER", button, "CENTER", 0, 0)
                    button.combatGlow:SetSize(button:GetWidth() + 15, button:GetHeight() + 15)
                    button.combatGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
                    button.combatGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
                    button.combatGlow:SetBlendMode("ADD")
                    button.combatGlow:SetVertexColor(
                        themeColors.highlight.r,
                        themeColors.highlight.g,
                        themeColors.highlight.b,
                        0.3
                    )
                    button.combatGlow:SetAlpha(0.5)
                    
                    -- Add a breathing animation
                    if not button.glow_animation then
                        button.glow_animation = button.combatGlow:CreateAnimationGroup()
                        button.glow_animation:SetLooping("REPEAT")
                        
                        local fade1 = button.glow_animation:CreateAnimation("Alpha")
                        fade1:SetFromAlpha(0.3)
                        fade1:SetToAlpha(0.7)
                        fade1:SetDuration(1.0)
                        fade1:SetSmoothing("IN_OUT")
                        
                        local fade2 = button.glow_animation:CreateAnimation("Alpha")
                        fade2:SetFromAlpha(0.7)
                        fade2:SetToAlpha(0.3)
                        fade2:SetDuration(1.0)
                        fade2:SetSmoothing("IN_OUT")
                        fade2:SetStartDelay(1.0)
                    end
                    
                    button.glow_animation:Play()
                end
                
                -- Show the combat glow
                if button.combatGlow then
                    button.combatGlow:Show()
                    if button.glow_animation then
                        button.glow_animation:Play()
                    end
                end
            else
                -- Out of combat - restore normal appearance
                
                -- Restore border
                if button.backdrop then
                    if self.settings.themeButtonBorders then
                        button.backdrop:SetBackdropBorderColor(
                            themeColors.border.r,
                            themeColors.border.g,
                            themeColors.border.b,
                            0.8
                        )
                    else
                        button.backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
                    end
                end
                
                -- Hide combat glow
                if button.combatGlow then
                    button.combatGlow:Hide()
                    if button.glow_animation then
                        button.glow_animation:Stop()
                    end
                end
            end
        end
    end
end

-- Create visual feedback when casting a spell
function VUI.ActionBars:CreateSpellCastFeedback(spellID)
    if not spellID or not self.settings.buttonPulseOnActivation then return end
    
    -- Find button containing this spell
    local targetButton = nil
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.action then
            local actionType, id = GetActionInfo(button.action)
            if actionType == "spell" and id == spellID then
                targetButton = button
                break
            end
        end
    end
    
    if targetButton then
        -- Create feedback effect
        if not targetButton.castFlash then
            targetButton.castFlash = targetButton:CreateTexture(nil, "OVERLAY")
            targetButton.castFlash:SetAllPoints(targetButton)
            targetButton.castFlash:SetTexture("Interface\\Buttons\\CheckButtonHilight")
            targetButton.castFlash:SetBlendMode("ADD")
            targetButton.castFlash:SetVertexColor(
                themeColors.highlight.r * 1.5,
                themeColors.highlight.g * 1.5,
                themeColors.highlight.b * 1.5,
                0.7
            )
            targetButton.castFlash:Hide()
        end
        
        -- Cancel any existing animation
        if targetButton.flashAnimTimer then
            targetButton.flashAnimTimer:Cancel()
        end
        
        -- Show and animate the flash
        targetButton.castFlash:Show()
        targetButton.castFlash:SetAlpha(0.7)
        
        targetButton.flashAnimTimer = C_Timer.NewTimer(0.1, function()
            local fadeInfo = {
                mode = "OUT",
                timeToFade = 0.4,
                startAlpha = 0.7,
                endAlpha = 0,
                finishedFunc = function()
                    targetButton.castFlash:Hide()
                end
            }
            
            UIFrameFade(targetButton.castFlash, fadeInfo)
        end)
        
        -- Store this effect for potential cleanup
        combatFeedbackEffects[targetButton] = true
    end
end

-- Highlight the spell being cast
function VUI.ActionBars:HighlightCastingSpell(spellID)
    if not spellID or not self.settings.enhancedCombatFeedback then return end
    
    -- Find button containing this spell
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.action then
            local actionType, id = GetActionInfo(button.action)
            if actionType == "spell" and id == spellID then
                -- Create highlight effect
                if not button.castingHighlight then
                    button.castingHighlight = button:CreateTexture(nil, "OVERLAY")
                    button.castingHighlight:SetAllPoints(button.icon)
                    button.castingHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
                    button.castingHighlight:SetBlendMode("ADD")
                    button.castingHighlight:SetVertexColor(
                        themeColors.highlight.r,
                        themeColors.highlight.g,
                        themeColors.highlight.b,
                        0.3
                    )
                    button.castingHighlight:Hide()
                end
                
                button.castingHighlight:Show()
                
                -- Store for later reference
                button.castingSpellID = spellID
                combatFeedbackEffects[button] = true
            end
        end
    end
end

-- Clear casting highlight
function VUI.ActionBars:ClearCastingHighlight(spellID)
    if not spellID then return end
    
    -- Find button containing this spell
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.castingSpellID == spellID and button.castingHighlight then
            button.castingHighlight:Hide()
            button.castingSpellID = nil
        end
    end
end

-- Show feedback when spell casting fails
function VUI.ActionBars:ShowCastFailFeedback(spellID)
    if not spellID or not self.settings.enhancedCombatFeedback then return end
    
    -- Find button containing this spell
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.action then
            local actionType, id = GetActionInfo(button.action)
            if actionType == "spell" and id == spellID then
                -- Create fail effect
                if not button.castFailTexture then
                    button.castFailTexture = button:CreateTexture(nil, "OVERLAY")
                    button.castFailTexture:SetAllPoints(button)
                    button.castFailTexture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
                    button.castFailTexture:SetBlendMode("BLEND")
                    button.castFailTexture:SetAlpha(0.8)
                    button.castFailTexture:Hide()
                end
                
                -- Show the fail texture
                button.castFailTexture:Show()
                
                -- Cancel any existing animation
                if button.failAnimTimer then
                    button.failAnimTimer:Cancel()
                end
                
                -- Hide after a short delay
                button.failAnimTimer = C_Timer.NewTimer(0.5, function()
                    local fadeInfo = {
                        mode = "OUT",
                        timeToFade = 0.3,
                        startAlpha = 0.8,
                        endAlpha = 0,
                        finishedFunc = function()
                            button.castFailTexture:Hide()
                        end
                    }
                    
                    UIFrameFade(button.castFailTexture, fadeInfo)
                end)
                
                -- Store for potential cleanup
                combatFeedbackEffects[button] = true
            end
        end
    end
end

-- Clean up all combat feedback effects
function VUI.ActionBars:ClearAllCombatFeedback()
    for button, _ in pairs(combatFeedbackEffects) do
        if button.castFlash then
            button.castFlash:Hide()
        end
        
        if button.castingHighlight then
            button.castingHighlight:Hide()
        end
        
        if button.castFailTexture then
            button.castFailTexture:Hide()
        end
        
        if button.glow_animation then
            button.glow_animation:Stop()
        end
        
        if button.combatGlow then
            button.combatGlow:Hide()
        end
        
        -- Cancel any timers
        if button.flashAnimTimer then
            button.flashAnimTimer:Cancel()
            button.flashAnimTimer = nil
        end
        
        if button.failAnimTimer then
            button.failAnimTimer:Cancel()
            button.failAnimTimer = nil
        end
        
        button.castingSpellID = nil
    end
    
    -- Clear the table
    wipe(combatFeedbackEffects)
end

-- Refresh combat feedback effects
function VUI.ActionBars:RefreshCombatFeedback()
    -- This ensures that all visual combat effects stay active and properly visible
    for button, _ in pairs(combatFeedbackEffects) do
        if button.combatGlow and not button.combatGlow:IsShown() then
            button.combatGlow:Show()
            if button.glow_animation and not button.glow_animation:IsPlaying() then
                button.glow_animation:Play()
            end
        end
    end
end

-- Update enhanced cooldowns for all action buttons
function VUI.ActionBars:UpdateEnhancedCooldowns()
    for i = 1, 120 do
        local button = _G["ActionButton"..i]
        if button and button.cooldown then
            local start, duration = button.cooldown:GetCooldownTimes()
            
            -- If a cooldown is about to finish (less than 1.5 seconds remaining)
            if start > 0 and duration > 0 then
                local remaining = (start + duration) / 1000 - GetTime()
                
                if remaining <= 0.1 and remaining > 0 then
                    -- Cooldown just finished - animate
                    self:AnimateCooldownFinish(button)
                elseif remaining <= 1.5 and button.cooldownPulse and not button.cooldownPulse:IsShown() then
                    -- Getting close to finished - start pulsing
                    if not button.finalPulseAnim then
                        button.cooldownPulse:SetAlpha(0.3)
                        button.cooldownPulse:Show()
                        
                        button.finalPulseAnim = button.cooldownPulse:CreateAnimationGroup()
                        button.finalPulseAnim:SetLooping("REPEAT")
                        
                        local fadeIn = button.finalPulseAnim:CreateAnimation("Alpha")
                        fadeIn:SetFromAlpha(0.2)
                        fadeIn:SetToAlpha(0.5)
                        fadeIn:SetDuration(0.5)
                        fadeIn:SetOrder(1)
                        
                        local fadeOut = button.finalPulseAnim:CreateAnimation("Alpha")
                        fadeOut:SetFromAlpha(0.5)
                        fadeOut:SetToAlpha(0.2)
                        fadeOut:SetDuration(0.5)
                        fadeOut:SetOrder(2)
                        
                        button.finalPulseAnim:Play()
                    else
                        button.cooldownPulse:Show()
                        button.finalPulseAnim:Play()
                    end
                elseif remaining > 1.5 and button.cooldownPulse and button.cooldownPulse:IsShown() and button.finalPulseAnim then
                    -- No longer close to finishing - stop pulse
                    button.finalPulseAnim:Stop()
                    button.cooldownPulse:Hide()
                end
            elseif button.cooldownPulse and button.cooldownPulse:IsShown() and button.finalPulseAnim then
                -- No cooldown active - stop pulse
                button.finalPulseAnim:Stop()
                button.cooldownPulse:Hide()
            end
        end
    end
end

function VUI.ActionBars:ApplyTheme(theme, themeData)
    activeTheme = theme
    themeColors = themeData or VUI.media.themes[theme] or {}
    
    -- Update all with the new theme
    self:UpdateActionBars()
    
    -- Update background colors
    if self.barBackgrounds then
        for idx, frame in pairs(self.barBackgrounds) do
            frame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.7)
            frame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
        end
    end
    
    -- Reapply enhanced keybind display with new theme colors
    if self.settings.improvedKeyBindDisplay then
        self:EnhanceKeyBindDisplay()
    end
    
    -- Reapply smooth cooldown animations with new theme colors
    if self.settings.smoothCooldownAnimation then
        self:InitializeSmoothCooldowns()
    end
    
    -- Reapply combat state if applicable
    if isInCombat and self.settings.enhancedCombatFeedback then
        self:ApplyCombatState(true)
    end
end

-- Configuration options
function VUI.ActionBars:GetConfigOptions()
    return {
        name = "Action Bars",
        type = "group",
        args = {
            enabled = {
                name = "Enable Enhanced Action Bars",
                desc = "Enable the VUI enhanced action bar styling",
                type = "toggle",
                width = "full",
                order = 1,
                get = function() return self.settings.enabled end,
                set = function(_, val)
                    self.settings.enabled = val
                    VUI.db.profile.modules.actionbars.enabled = val
                    if val then self:Enable() else self:Disable() end
                end
            },
            showHotkeys = {
                name = "Show Keybinds",
                desc = "Display keybinding text on action buttons",
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return self.settings.showHotkeys end,
                set = function(_, val)
                    self.settings.showHotkeys = val
                    VUI.db.profile.modules.actionbars.showHotkeys = val
                    self:UpdateActionBars()
                end
            },
            colorKeyBinds = {
                name = "Color Keybinds",
                desc = "Apply theme color to keybinding text",
                type = "toggle",
                width = "full",
                order = 3,
                disabled = function() return not self.settings.showHotkeys end,
                get = function() return self.settings.colorKeyBinds end,
                set = function(_, val)
                    self.settings.colorKeyBinds = val
                    VUI.db.profile.modules.actionbars.colorKeyBinds = val
                    self:UpdateActionBars()
                end
            },
            showMacroNames = {
                name = "Show Macro Names",
                desc = "Display macro names on action buttons",
                type = "toggle",
                width = "full",
                order = 4,
                get = function() return self.settings.showMacroNames end,
                set = function(_, val)
                    self.settings.showMacroNames = val
                    VUI.db.profile.modules.actionbars.showMacroNames = val
                    self:UpdateActionBars()
                end
            },
            showItemCount = {
                name = "Show Item Counts",
                desc = "Display item counts on action buttons",
                type = "toggle",
                width = "full",
                order = 5,
                get = function() return self.settings.showItemCount end,
                set = function(_, val)
                    self.settings.showItemCount = val
                    VUI.db.profile.modules.actionbars.showItemCount = val
                    self:UpdateActionBars()
                end
            },
            showCooldownText = {
                name = "Show Cooldown Text",
                desc = "Display numerical cooldown counters on buttons",
                type = "toggle",
                width = "full",
                order = 6,
                get = function() return self.settings.showCooldownText end,
                set = function(_, val)
                    self.settings.showCooldownText = val
                    VUI.db.profile.modules.actionbars.showCooldownText = val
                    self:UpdateActionBars()
                end
            },
            customBarBackground = {
                name = "Show Bar Backgrounds",
                desc = "Display themed backgrounds behind action bars",
                type = "toggle",
                width = "full",
                order = 7,
                get = function() return self.settings.customBarBackground end,
                set = function(_, val)
                    self.settings.customBarBackground = val
                    VUI.db.profile.modules.actionbars.customBarBackground = val
                    self:UpdateActionBars()
                end
            },
            themeButtonBorders = {
                name = "Themed Button Borders",
                desc = "Apply theme color to action button borders",
                type = "toggle",
                width = "full",
                order = 8,
                get = function() return self.settings.themeButtonBorders end,
                set = function(_, val)
                    self.settings.themeButtonBorders = val
                    VUI.db.profile.modules.actionbars.themeButtonBorders = val
                    self:UpdateActionBars()
                end
            },
            highlightEquipped = {
                name = "Highlight Equipped Items",
                desc = "Highlight action buttons for items that are currently equipped",
                type = "toggle",
                width = "full",
                order = 9,
                get = function() return self.settings.highlightEquipped end,
                set = function(_, val)
                    self.settings.highlightEquipped = val
                    VUI.db.profile.modules.actionbars.highlightEquipped = val
                    self:UpdateActionBars()
                end
            },
            hideEmptyButtons = {
                name = "Hide Empty Buttons",
                desc = "Hide action buttons that don't have an action assigned",
                type = "toggle",
                width = "full",
                order = 10,
                get = function() return self.settings.hideEmptyButtons end,
                set = function(_, val)
                    self.settings.hideEmptyButtons = val
                    VUI.db.profile.modules.actionbars.hideEmptyButtons = val
                    self:UpdateActionBars()
                end
            },
            largerButtons = {
                name = "Larger Action Buttons",
                desc = "Increase the size of action buttons",
                type = "toggle",
                width = "full",
                order = 11,
                get = function() return self.settings.largerButtons end,
                set = function(_, val)
                    self.settings.largerButtons = val
                    VUI.db.profile.modules.actionbars.largerButtons = val
                    -- Need to reload UI for this to take effect
                    -- Usually would include a popup here asking for confirmation
                    ReloadUI()
                end
            }
        }
    }
end