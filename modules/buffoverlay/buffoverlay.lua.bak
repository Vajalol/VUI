-- VUI BuffOverlay Module
-- Adapted from: https://github.com/clicketz/buff-overlay
-- Author: VortexQ8

-- Initialize the module
function VUI.BuffOverlay:Initialize()
    if not VUI.enabledModules.BuffOverlay then return end
    
    -- Create frame for buff tracking
    self:CreateBuffOverlayFrame()
    
    -- Register events
    self:RegisterEvents()
    
    -- Apply settings
    self:ApplySettings()
    
    -- Log initialization
    VUI:Print("BuffOverlay module initialized")
end

-- Create the main frame for the buff overlays
function VUI.BuffOverlay:CreateBuffOverlayFrame()
    -- Create main frame
    self.frame = CreateFrame("Frame", "VUIBuffOverlayFrame", UIParent)
    self.frame:SetPoint(unpack(self.db.profile.position))
    self.frame:SetSize(self.db.profile.size, self.db.profile.size)
    self.frame:SetScale(self.db.profile.scale)
    self.frame:SetAlpha(self.db.profile.alpha)
    
    -- Make frame movable
    self.frame:SetMovable(true)
    self.frame:SetClampedToScreen(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame)
        if not VUI.configFrame or not VUI.configFrame:IsShown() then return end
        frame:StartMoving()
    end)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        self.db.profile.position = {point, relativeTo, relativePoint, xOfs, yOfs}
    end)
    
    -- Create container for aura icons
    self.buffContainer = CreateFrame("Frame", "VUIBuffOverlayContainer", self.frame)
    self.buffContainer:SetPoint("CENTER")
    self.buffContainer:SetSize(200, 200) -- Will adjust based on content
    
    -- Table to store active buff frames
    self.activeBuffs = {}
    
    -- Create config button
    self.configButton = CreateFrame("Button", nil, self.frame)
    self.configButton:SetSize(20, 20)
    self.configButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 5, 5)
    self.configButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    self.configButton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
    self.configButton:SetScript("OnClick", function()
        VUI:ToggleConfig()
        -- Select BuffOverlay in the config panel
        if VUI.configFrame and VUI.configFrame:IsShown() then
            VUI:ShowConfigSection(VUI.configFrame, "Modules")
            VUI:ShowModuleConfig(VUI.configFrame.sections["Modules"], "BuffOverlay")
        end
    end)
    self.configButton:Hide() -- Only show when in config mode
    
    -- Show config button when config is open
    self.frame:SetScript("OnEnter", function()
        if VUI.configFrame and VUI.configFrame:IsShown() then
            self.configButton:Show()
        end
    end)
    
    self.frame:SetScript("OnLeave", function()
        if not MouseIsOver(self.configButton) then
            self.configButton:Hide()
        end
    end)
    
    self.configButton:SetScript("OnLeave", function()
        if not MouseIsOver(self.frame) then
            self.configButton:Hide()
        end
    end)
end

-- Register events for buff tracking
function VUI.BuffOverlay:RegisterEvents()
    -- Create event frame
    self.eventFrame = CreateFrame("Frame")
    
    -- Register events
    self.eventFrame:RegisterEvent("UNIT_AURA")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_AURA" then
            local unit = ...
            if unit == "player" then
                self:UpdateBuffs()
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UpdateBuffs()
        end
    end)
end

-- Update the display of buff icons
function VUI.BuffOverlay:UpdateBuffs()
    -- Clear existing buffs
    for _, frame in pairs(self.activeBuffs) do
        frame:Hide()
        frame.used = false
    end
    
    local index = 1
    local buffCount = 0
    
    -- Filter for tracking only important buffs
    while true do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
              nameplateShowPersonal, spellId = UnitAura("player", index, "HELPFUL")
        
        if not name then break end
        
        -- Check if buff should be shown (apply filters)
        if self:ShouldShowBuff(name, spellId) then
            -- Create or reuse a buff frame
            local buffFrame = self:GetBuffFrame(buffCount + 1)
            
            -- Update the buff frame
            self:UpdateBuffFrame(buffFrame, icon, count, duration, expirationTime, name, spellId)
            
            -- Position the buff frame
            self:PositionBuffFrame(buffFrame, buffCount)
            
            buffCount = buffCount + 1
        end
        
        index = index + 1
    end
    
    -- Hide unused buff frames
    for i, frame in pairs(self.activeBuffs) do
        if not frame.used then
            frame:Hide()
        end
    end
    
    -- Resize container based on number of buffs
    self:ResizeContainer(buffCount)
end

-- Determine if a buff should be shown based on filters
function VUI.BuffOverlay:ShouldShowBuff(name, spellId)
    -- If whitelist exists and is not empty, only show whitelisted buffs
    if self.db.profile.filters.whitelist and next(self.db.profile.filters.whitelist) then
        return self.db.profile.filters.whitelist[spellId] or self.db.profile.filters.whitelist[name]
    end
    
    -- Otherwise, show all buffs except blacklisted ones
    return not (self.db.profile.filters.blacklist and 
                (self.db.profile.filters.blacklist[spellId] or 
                 self.db.profile.filters.blacklist[name]))
end

-- Get a buff frame (reuse or create)
function VUI.BuffOverlay:GetBuffFrame(index)
    if not self.activeBuffs[index] then
        -- Create new buff frame
        local frame = CreateFrame("Frame", "VUIBuffOverlay"..index, self.buffContainer)
        frame:SetSize(self.db.profile.size, self.db.profile.size)
        
        -- Icon
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetAllPoints()
        frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim the icon borders
        
        -- Border
        if self.db.profile.border then
            frame.border = frame:CreateTexture(nil, "OVERLAY")
            frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
            frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
            frame.border:SetColorTexture(0, 0, 0, 1)
        end
        
        -- Count
        frame.count = frame:CreateFontString(nil, "OVERLAY")
        frame.count:SetFont(VUI:GetFont("expressway"), 12, "OUTLINE")
        frame.count:SetPoint("BOTTOMRIGHT", -2, 2)
        
        -- Cooldown
        frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        frame.cooldown:SetAllPoints()
        frame.cooldown:SetDrawEdge(false)
        frame.cooldown:SetDrawSwipe(true)
        frame.cooldown:SetReverse(false)
        
        -- Duration text
        frame.duration = frame:CreateFontString(nil, "OVERLAY")
        frame.duration:SetFont(VUI:GetFont("expressway"), 10, "OUTLINE")
        frame.duration:SetPoint("TOP", 0, 14)
        
        -- Tooltip handling
        frame:SetScript("OnEnter", function(self)
            if not VUI.BuffOverlay.db.profile.showTooltip then return end
            
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        end)
        
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        self.activeBuffs[index] = frame
    end
    
    -- Mark frame as used
    self.activeBuffs[index].used = true
    self.activeBuffs[index]:Show()
    
    return self.activeBuffs[index]
end

-- Update a buff frame with new buff data
function VUI.BuffOverlay:UpdateBuffFrame(frame, icon, count, duration, expirationTime, name, spellId)
    -- Set the icon
    frame.icon:SetTexture(icon)
    
    -- Set stack count
    if count and count > 1 then
        frame.count:SetText(count)
        frame.count:Show()
    else
        frame.count:Hide()
    end
    
    -- Set cooldown
    if duration and duration > 0 and expirationTime and expirationTime > 0 then
        frame.cooldown:SetCooldown(expirationTime - duration, duration)
        frame.cooldown:Show()
        
        -- Update duration text if enabled
        if self.db.profile.showDuration then
            frame.duration:Show()
            
            -- Update timer
            frame:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed < 0.1 then return end
                self.elapsed = 0
                
                local timeLeft = expirationTime - GetTime()
                if timeLeft <= 0 then
                    self.duration:SetText("")
                else
                    self.duration:SetText(VUI:FormatTime(timeLeft))
                end
            end)
        else
            frame.duration:Hide()
            frame:SetScript("OnUpdate", nil)
        end
    else
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
    end
    
    -- Store spell ID for tooltip
    frame.spellId = spellId
    frame.name = name
end

-- Position a buff frame based on its index
function VUI.BuffOverlay:PositionBuffFrame(frame, index)
    local size = self.db.profile.size
    local spacing = self.db.profile.spacing
    local direction = self.db.profile.growthDirection
    
    if index == 0 then
        frame:SetPoint("CENTER", self.buffContainer, "CENTER", 0, 0)
    else
        if direction == "UP" then
            frame:SetPoint("BOTTOM", self.activeBuffs[index], "TOP", 0, spacing)
        elseif direction == "DOWN" then
            frame:SetPoint("TOP", self.activeBuffs[index], "BOTTOM", 0, -spacing)
        elseif direction == "LEFT" then
            frame:SetPoint("RIGHT", self.activeBuffs[index], "LEFT", -spacing, 0)
        elseif direction == "RIGHT" then
            frame:SetPoint("LEFT", self.activeBuffs[index], "RIGHT", spacing, 0)
        end
    end
end

-- Resize the container based on number of buffs
function VUI.BuffOverlay:ResizeContainer(buffCount)
    local size = self.db.profile.size
    local spacing = self.db.profile.spacing
    local direction = self.db.profile.growthDirection
    
    if buffCount == 0 then
        self.buffContainer:SetSize(size, size)
    else
        if direction == "UP" or direction == "DOWN" then
            self.buffContainer:SetSize(size, buffCount * (size + spacing))
        elseif direction == "LEFT" or direction == "RIGHT" then
            self.buffContainer:SetSize(buffCount * (size + spacing), size)
        end
    end
end

-- Apply settings from the database
function VUI.BuffOverlay:ApplySettings()
    -- Apply settings to the frame
    self.frame:SetScale(self.db.profile.scale)
    self.frame:SetAlpha(self.db.profile.alpha)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.db.profile.position))
    
    -- Update all buffs to apply new settings
    self:UpdateBuffs()
end

-- Refresh config when profile changes
function VUI.BuffOverlay:RefreshConfig()
    self:ApplySettings()
end

-- Create module-specific config options
function VUI.BuffOverlay:CreateConfigOptions(parentFrame)
    -- Scale slider
    parentFrame.scaleText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.scaleText:SetPoint("TOPLEFT", parentFrame.title, "BOTTOMLEFT", 0, -20)
    parentFrame.scaleText:SetText("Scale:")
    
    parentFrame.scaleSlider = VUI.UI:CreateSlider(parentFrame, "VUIBuffOverlayScaleSlider", "", 0.5, 2.0, 0.1)
    parentFrame.scaleSlider:SetPoint("TOPLEFT", parentFrame.scaleText, "BOTTOMLEFT", 0, -10)
    parentFrame.scaleSlider:SetWidth(200)
    parentFrame.scaleSlider:SetValue(self.db.profile.scale)
    
    parentFrame.scaleSlider:SetScript("OnValueChanged", function(self, value)
        VUI.BuffOverlay.db.profile.scale = value
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Alpha slider
    parentFrame.alphaText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.alphaText:SetPoint("TOPLEFT", parentFrame.scaleSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.alphaText:SetText("Alpha:")
    
    parentFrame.alphaSlider = VUI.UI:CreateSlider(parentFrame, "VUIBuffOverlayAlphaSlider", "", 0.1, 1.0, 0.1)
    parentFrame.alphaSlider:SetPoint("TOPLEFT", parentFrame.alphaText, "BOTTOMLEFT", 0, -10)
    parentFrame.alphaSlider:SetWidth(200)
    parentFrame.alphaSlider:SetValue(self.db.profile.alpha)
    
    parentFrame.alphaSlider:SetScript("OnValueChanged", function(self, value)
        VUI.BuffOverlay.db.profile.alpha = value
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Size slider
    parentFrame.sizeText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.sizeText:SetPoint("TOPLEFT", parentFrame.alphaSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.sizeText:SetText("Icon Size:")
    
    parentFrame.sizeSlider = VUI.UI:CreateSlider(parentFrame, "VUIBuffOverlaySizeSlider", "", 16, 64, 4)
    parentFrame.sizeSlider:SetPoint("TOPLEFT", parentFrame.sizeText, "BOTTOMLEFT", 0, -10)
    parentFrame.sizeSlider:SetWidth(200)
    parentFrame.sizeSlider:SetValue(self.db.profile.size)
    
    parentFrame.sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        VUI.BuffOverlay.db.profile.size = value
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Spacing slider
    parentFrame.spacingText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.spacingText:SetPoint("TOPLEFT", parentFrame.sizeSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.spacingText:SetText("Icon Spacing:")
    
    parentFrame.spacingSlider = VUI.UI:CreateSlider(parentFrame, "VUIBuffOverlaySpacingSlider", "", 0, 20, 1)
    parentFrame.spacingSlider:SetPoint("TOPLEFT", parentFrame.spacingText, "BOTTOMLEFT", 0, -10)
    parentFrame.spacingSlider:SetWidth(200)
    parentFrame.spacingSlider:SetValue(self.db.profile.spacing)
    
    parentFrame.spacingSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        VUI.BuffOverlay.db.profile.spacing = value
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Growth direction dropdown
    parentFrame.directionText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.directionText:SetPoint("TOPLEFT", parentFrame.spacingSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.directionText:SetText("Growth Direction:")
    
    parentFrame.directionDropdown = VUI.UI:CreateDropdown(parentFrame, "VUIBuffOverlayDirectionDropdown", "", 150)
    parentFrame.directionDropdown:SetPoint("TOPLEFT", parentFrame.directionText, "BOTTOMLEFT", 0, -10)
    
    -- Populate growth direction dropdown
    UIDropDownMenu_Initialize(parentFrame.directionDropdown, function(dropdown, level)
        local directions = {"UP", "DOWN", "LEFT", "RIGHT"}
        local info = UIDropDownMenu_CreateInfo()
        
        for _, direction in ipairs(directions) do
            info.text = direction
            info.value = direction
            info.func = function(self)
                VUI.BuffOverlay.db.profile.growthDirection = self.value
                UIDropDownMenu_SetText(dropdown, self.value)
                VUI.BuffOverlay:ApplySettings()
            end
            info.checked = (VUI.BuffOverlay.db.profile.growthDirection == direction)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetText(parentFrame.directionDropdown, self.db.profile.growthDirection)
    
    -- Show duration checkbox
    parentFrame.durationCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUIBuffOverlayDurationCheckbox", "Show Duration")
    parentFrame.durationCheckbox:SetPoint("TOPLEFT", parentFrame.directionDropdown, "BOTTOMLEFT", 0, -20)
    parentFrame.durationCheckbox:SetChecked(self.db.profile.showDuration)
    
    parentFrame.durationCheckbox:SetScript("OnClick", function(self)
        VUI.BuffOverlay.db.profile.showDuration = self:GetChecked()
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Show tooltip checkbox
    parentFrame.tooltipCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUIBuffOverlayTooltipCheckbox", "Show Tooltip")
    parentFrame.tooltipCheckbox:SetPoint("TOPLEFT", parentFrame.durationCheckbox, "BOTTOMLEFT", 0, -10)
    parentFrame.tooltipCheckbox:SetChecked(self.db.profile.showTooltip)
    
    parentFrame.tooltipCheckbox:SetScript("OnClick", function(self)
        VUI.BuffOverlay.db.profile.showTooltip = self:GetChecked()
    end)
    
    -- Show border checkbox
    parentFrame.borderCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUIBuffOverlayBorderCheckbox", "Show Border")
    parentFrame.borderCheckbox:SetPoint("TOPLEFT", parentFrame.tooltipCheckbox, "BOTTOMLEFT", 0, -10)
    parentFrame.borderCheckbox:SetChecked(self.db.profile.border)
    
    parentFrame.borderCheckbox:SetScript("OnClick", function(self)
        VUI.BuffOverlay.db.profile.border = self:GetChecked()
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Reset position button
    parentFrame.resetButton = VUI.UI:CreateButton(parentFrame, "VUIBuffOverlayResetButton", "Reset Position", 120, 25)
    parentFrame.resetButton:SetPoint("TOPLEFT", parentFrame.borderCheckbox, "BOTTOMLEFT", 0, -20)
    
    parentFrame.resetButton:SetScript("OnClick", function()
        VUI.BuffOverlay.db.profile.position = {"CENTER", UIParent, "CENTER", 0, 0}
        VUI.BuffOverlay:ApplySettings()
    end)
    
    -- Filter management (simplified for this implementation)
    parentFrame.filterTitle = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    parentFrame.filterTitle:SetPoint("TOPLEFT", parentFrame.resetButton, "BOTTOMLEFT", 0, -20)
    parentFrame.filterTitle:SetText("Buff Filters")
    
    parentFrame.filterNote = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.filterNote:SetPoint("TOPLEFT", parentFrame.filterTitle, "BOTTOMLEFT", 0, -10)
    parentFrame.filterNote:SetText("Filter settings will be expanded in a future update.")
end

-- Enable the module
function VUI.BuffOverlay:Enable()
    if not self.frame then
        self:Initialize()
    else
        self.frame:Show()
        self:UpdateBuffs()
    end
end

-- Disable the module
function VUI.BuffOverlay:Disable()
    if self.frame then
        self.frame:Hide()
    end
end
