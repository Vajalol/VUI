local _, VUI = ...

-- Action Bars module
VUI.ActionBars = VUI:NewModule("ActionBars")

-- Local variables
local activeTheme = "thunderstorm"  -- Default to Thunder Storm theme
local themeColors = {}

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
        themeButtonBorders = true
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
end

function VUI.ActionBars:OnDisable()
    -- Reset to Blizzard defaults if needed
end

function VUI.ActionBars:PLAYER_ENTERING_WORLD()
    self:UpdateActionBars()
end

function VUI.ActionBars:ACTIONBAR_UPDATE_COOLDOWN()
    if self.settings.showCooldownText then
        self:UpdateCooldownText()
    end
end

function VUI.ActionBars:ACTIONBAR_UPDATE_STATE()
    self:UpdateActionButtonState()
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