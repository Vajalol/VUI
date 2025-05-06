-------------------------------------------------------------------------------
-- Title: VUI BuffOverlay Module
-- Adapted from: https://github.com/clicketz/buff-overlay
-- Author: VortexQ8
-- Enhanced with better performance and additional features
-------------------------------------------------------------------------------

-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Standardize on a single namespace (CamelCase) for consistency
if not VUI.BuffOverlay then
    VUI.BuffOverlay = {}
end

-- Create a consistent reference to the lowercase version for backward compatibility
-- This ensures all references to buffoverlay point to BuffOverlay
VUI.buffoverlay = VUI.BuffOverlay

-- Create a local reference for easier access
local BuffOverlay = VUI.BuffOverlay

-- Performance optimization
local GetTime = GetTime
local UnitAura = UnitAura
local UnitExists = UnitExists
local ceil = math.ceil
local floor = math.floor
local min = math.min
local max = math.max
local format = string.format
local pairs = pairs
local ipairs = ipairs
local next = next
local type = type
local tostring = tostring
local table = table
local unpack = unpack
local select = select
local string = string
local wipe = table.wipe or wipe

-- Default values for enhanced display
local ENHANCED_DEFAULTS = {
    enableEnhancedDisplay = true,
    maxAurasPerUnit = 8,
    showCooldownSpiral = true,
    showCooldownNumbers = true,
    enhancedTimerFormat = true,
    showDebuffs = true,
    trackFriendlyUnits = true,
    trackEnemyUnits = true,
    unitSpacing = 10,
    unitScale = 1.0,
    showUnitLabels = true,
    labelFont = "Expressway",
    labelFontSize = 10,
    labelFontStyle = "OUTLINE",
    colorByType = true,
    buffColor = {r = 0.4, g = 0.8, b = 0.2, a = 1.0},
    debuffColor = {r = 0.9, g = 0.1, b = 0.1, a = 1.0}
}

-- Initialize the module
function VUI.BuffOverlay:Initialize()
    -- First, ensure the module name is standardized in enabledModules
    if VUI.enabledModules.buffoverlay and not VUI.enabledModules.BuffOverlay then
        VUI.enabledModules.BuffOverlay = VUI.enabledModules.buffoverlay
    end
    
    -- Return if the module is disabled
    if not VUI.enabledModules.BuffOverlay then return end
    
    -- Ensure we have both camelCase and lowercase db paths for backward compatibility
    if not VUI.db.profile.modules.BuffOverlay then
        VUI.db.profile.modules.BuffOverlay = {}
    end
    
    -- Standardize database paths by copying existing data to camelCase version
    if VUI.db.profile.modules.buffoverlay then
        for k, v in pairs(VUI.db.profile.modules.buffoverlay) do
            VUI.db.profile.modules.BuffOverlay[k] = v
        end
    end
    
    -- Create reference for backward compatibility
    VUI.db.profile.modules.buffoverlay = VUI.db.profile.modules.BuffOverlay
    
    -- Get direct reference to DB for cleaner code
    local dbProfile = VUI.db.profile.modules.BuffOverlay
    
    -- Initialize enhanced display defaults if not set
    if not dbProfile.enhancedDisplay then
        dbProfile.enhancedDisplay = ENHANCED_DEFAULTS.enableEnhancedDisplay
    end
    
    if not dbProfile.maxAurasPerUnit then
        dbProfile.maxAurasPerUnit = ENHANCED_DEFAULTS.maxAurasPerUnit
    end
    
    if not dbProfile.showCooldownSpiral then
        dbProfile.showCooldownSpiral = ENHANCED_DEFAULTS.showCooldownSpiral
    end
    
    if not dbProfile.showCooldownNumbers then
        dbProfile.showCooldownNumbers = ENHANCED_DEFAULTS.showCooldownNumbers
    end
    
    -- Create frame for buff tracking
    self:CreateBuffOverlayFrame()
    
    -- Register events
    self:RegisterEvents()
    
    -- Apply settings
    self:ApplySettings()
    
    -- Initialize the enhanced display if enabled
    if dbProfile.enhancedDisplay then
        self:InitializeEnhancedDisplay()
    end
    
    -- Log initialization
    VUI:Print("BuffOverlay module initialized")
end

-- Initialize the enhanced display
function VUI.BuffOverlay:InitializeEnhancedDisplay()
    -- Create unit containers table if it doesn't exist
    self.unitContainers = self.unitContainers or {}
    
    -- Track aura state for each unit
    self.unitAuras = {}
    self.unitDebuffs = {}
    
    -- Register additional events for enhanced display
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self.eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self.eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    
    -- Extend the event handler
    local originalOnEvent = self.eventFrame:GetScript("OnEvent")
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        -- Call the original handler first
        if originalOnEvent then
            originalOnEvent(_, event, ...)
        end
        
        -- Handle enhanced display events
        if event == "GROUP_ROSTER_UPDATE" then
            self:UpdateAllAuras()
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:UpdateUnitAuras("target")
        elseif event == "PLAYER_FOCUS_CHANGED" then
            self:UpdateUnitAuras("focus")
        elseif event == "NAME_PLATE_UNIT_ADDED" then
            local unitID = ...
            self:UpdateUnitAuras(unitID)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            local unitID = ...
            if self.unitContainers[unitID] then
                self.unitContainers[unitID]:Hide()
            end
        end
    end)
    
    -- Start the enhanced display
    self:StartEnhancedDisplay()
end

-- Create a container frame for unit auras
function VUI.BuffOverlay:CreateUnitContainer(unitID)
    if self.unitContainers[unitID] then
        return self.unitContainers[unitID]
    end
    
    local container = CreateFrame("Frame", "VUIBuffOverlay_"..unitID, UIParent)
    container:SetSize(200, 50)
    container.unitID = unitID
    
    -- Position based on unit type
    if unitID == "player" then
        container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    elseif unitID == "target" then
        container:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    elseif unitID == "focus" then
        container:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
    else
        -- For nameplate units, attach to nameplate
        local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
        if nameplate then
            container:SetPoint("BOTTOM", nameplate, "TOP", 0, 10)
        else
            container:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
        end
    end
    
    -- Create label for unit
    container.label = container:CreateFontString(nil, "OVERLAY")
    container.label:SetFont(VUI:GetFont(VUI.db.profile.modules.buffoverlay.labelFont or "Expressway"), 
                      VUI.db.profile.modules.buffoverlay.labelFontSize or 10, 
                      VUI.db.profile.modules.buffoverlay.labelFontStyle or "OUTLINE")
    container.label:SetPoint("BOTTOM", container, "TOP", 0, 2)
    container.label:SetText(self:GetUnitDisplayName(unitID))
    
    -- Setup buff and debuff areas
    container.buffs = CreateFrame("Frame", nil, container)
    container.buffs:SetPoint("TOPLEFT", container, "TOPLEFT")
    container.buffs:SetSize(200, 25)
    
    container.debuffs = CreateFrame("Frame", nil, container)
    container.debuffs:SetPoint("TOPLEFT", container.buffs, "BOTTOMLEFT", 0, -5)
    container.debuffs:SetSize(200, 25)
    
    -- Tables to store aura frames
    container.buffFrames = {}
    container.debuffFrames = {}
    
    self.unitContainers[unitID] = container
    return container
end

-- Get a frame for displaying an aura
function VUI.BuffOverlay:GetAuraFrame(unitID, index, isDebuff)
    local container = self:CreateUnitContainer(unitID)
    local frames = isDebuff and container.debuffFrames or container.buffFrames
    
    if not frames[index] then
        local frameParent = isDebuff and container.debuffs or container.buffs
        local frame = CreateFrame("Frame", nil, frameParent)
        local size = VUI.db.profile.modules.buffoverlay.size or 24
        frame:SetSize(size, size)
        
        -- Scale based on settings
        local scale = VUI.db.profile.modules.buffoverlay.unitScale or 1.0
        frame:SetScale(scale)
        
        -- Icon
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetAllPoints()
        frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim borders
        
        -- Border
        frame.border = frame:CreateTexture(nil, "OVERLAY")
        frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
        frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
        
        -- Set border color based on aura type
        if isDebuff then
            if VUI.db.profile.modules.buffoverlay.colorByType then
                -- Will be set dynamically for each debuff
                frame.border:SetColorTexture(1, 0, 0, 1)
            else
                local color = VUI.db.profile.modules.buffoverlay.debuffColor or {r = 0.9, g = 0.1, b = 0.1, a = 1.0}
                frame.border:SetColorTexture(color.r, color.g, color.b, color.a)
            end
        else
            local color = VUI.db.profile.modules.buffoverlay.buffColor or {r = 0.4, g = 0.8, b = 0.2, a = 1.0}
            frame.border:SetColorTexture(color.r, color.g, color.b, color.a)
        end
        
        -- Count
        frame.count = frame:CreateFontString(nil, "OVERLAY")
        frame.count:SetFont(VUI:GetFont("expressway"), 10, "OUTLINE")
        frame.count:SetPoint("BOTTOMRIGHT", -2, 2)
        
        -- Cooldown
        if VUI.db.profile.modules.buffoverlay.showCooldownSpiral then
            frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
            frame.cooldown:SetAllPoints()
            frame.cooldown:SetDrawEdge(false)
            frame.cooldown:SetDrawSwipe(true)
            frame.cooldown:SetReverse(false)
        end
        
        -- Duration text
        if VUI.db.profile.modules.buffoverlay.showDuration then
            frame.duration = frame:CreateFontString(nil, "OVERLAY")
            frame.duration:SetFont(VUI:GetFont("expressway"), 10, "OUTLINE")
            frame.duration:SetPoint("TOP", 0, 14)
        end
        
        -- Tooltip
        frame:SetScript("OnEnter", function(self)
            if not VUI.BuffOverlay.db.profile.showTooltip then return end
            
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:SetUnitAura(unitID, self.auraIndex, self.filter)
            GameTooltip:Show()
        end)
        
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        frames[index] = frame
    end
    
    frames[index].used = true
    frames[index]:Show()
    
    return frames[index]
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

-- Enhanced format time function for better readability
local function FormatTimeEnhanced(timeLeft, showDecimal)
    if not timeLeft or timeLeft <= 0 then return "" end
    
    -- Days
    if timeLeft >= 86400 then
        return format("%dd", floor(timeLeft/86400 + 0.5))
    -- Hours
    elseif timeLeft >= 3600 then
        return format("%dh", floor(timeLeft/3600 + 0.5))
    -- Minutes
    elseif timeLeft >= 60 then
        return format("%dm", floor(timeLeft/60 + 0.5))
    -- Seconds with decimal
    elseif timeLeft < 10 and showDecimal then
        return format("%.1f", timeLeft)
    -- Seconds
    else
        return format("%d", floor(timeLeft + 0.5))
    end
end

-- Format time with color based on percentage of duration remaining
local function FormatTimeWithColor(timeLeft, showDecimal, duration)
    local colorCode = "|cFFFFFFFF" -- Default white
    
    local formattedTime = FormatTimeEnhanced(timeLeft, showDecimal)
    
    -- Skip empty time
    if formattedTime == "" then return "" end
    
    -- Percentage of time remaining
    local percentage = timeLeft / duration
    
    -- Color code based on remaining time percentage
    if percentage < 0.2 then
        colorCode = "|cFFFF0000" -- Red for < 20%
    elseif percentage < 0.5 then
        colorCode = "|cFFFFFF00" -- Yellow for < 50%
    else
        colorCode = "|cFF00FF00" -- Green for >= 50%
    end
    
    return colorCode .. formattedTime .. "|r"
end

-- Add enhanced time formatting to our UpdateBuffFrame function
function VUI.BuffOverlay:UpdateBuffFrameWithEnhancedDisplay(frame, icon, count, duration, expirationTime, name, spellId)
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
            
            -- Update timer with enhanced formatting
            frame:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed < 0.1 then return end
                self.elapsed = 0
                
                local timeLeft = expirationTime - GetTime()
                if timeLeft <= 0 then
                    self.duration:SetText("")
                else
                    -- Use enhanced time formatting with color
                    self.duration:SetText(FormatTimeWithColor(timeLeft, 
                        VUI.BuffOverlay.db.profile.showDecimalSeconds,
                        duration))
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

-- Use the enhanced update function if enabled in settings
function VUI.BuffOverlay:UpdateBuffFrame(frame, icon, count, duration, expirationTime, name, spellId)
    if self.db.profile.useEnhancedDisplay then
        self:UpdateBuffFrameWithEnhancedDisplay(frame, icon, count, duration, expirationTime, name, spellId)
    else
        -- Original update function (simple version)
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
end

-- Disable the module
function VUI.BuffOverlay:Disable()
    if self.frame then
        self.frame:Hide()
    end
    
    -- Also hide enhanced display if active
    if self.unitContainers then
        for _, container in pairs(self.unitContainers) do
            container:Hide()
        end
    end
    
    -- Stop enhanced display timers
    self:StopEnhancedDisplay()
end

-- Update auras for a specific unit
function VUI.BuffOverlay:UpdateUnitAuras(unitID)
    if not unitID or not UnitExists(unitID) then return end
    
    -- Skip units we're not tracking based on settings
    local isFriendly = UnitIsFriend("player", unitID)
    if (isFriendly and not VUI.db.profile.modules.buffoverlay.trackFriendlyUnits) or
       (not isFriendly and not VUI.db.profile.modules.buffoverlay.trackEnemyUnits) then
        return
    end
    
    local container = self:CreateUnitContainer(unitID)
    local buffCount = 0
    local debuffCount = 0
    
    -- Update unit label
    container.label:SetText(self:GetUnitDisplayName(unitID))
    
    -- Save old auras for comparison
    local oldAuras = self.unitAuras[unitID] or {}
    local oldDebuffs = self.unitDebuffs[unitID] or {}
    
    -- Initialize new aura tables
    self.unitAuras[unitID] = {}
    self.unitDebuffs[unitID] = {}
    
    -- Scan buffs
    local index = 1
    while buffCount < VUI.db.profile.modules.buffoverlay.maxAurasPerUnit do
        local name, icon, count, debuffType, duration, expirationTime, caster, 
              isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
              castByPlayer = UnitAura(unitID, index, "HELPFUL")
        
        if not name then break end
        
        -- Store aura info
        self.unitAuras[unitID][index] = {
            name = name,
            icon = icon,
            count = count,
            duration = duration,
            expirationTime = expirationTime,
            debuffType = debuffType,
            spellId = spellId,
            index = index,
            filter = "HELPFUL"
        }
        
        -- Update frame
        local buffFrame = self:GetAuraFrame(unitID, buffCount + 1, false)
        self:UpdateAuraFrame(buffFrame, self.unitAuras[unitID][index], unitID)
        
        buffCount = buffCount + 1
        index = index + 1
    end
    
    -- Scan debuffs if enabled
    if VUI.db.profile.modules.buffoverlay.showDebuffs then
        index = 1
        while debuffCount < VUI.db.profile.modules.buffoverlay.maxAurasPerUnit do
            local name, icon, count, debuffType, duration, expirationTime, caster, 
                  isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, 
                  castByPlayer = UnitAura(unitID, index, "HARMFUL")
            
            if not name then break end
            
            -- Store debuff info
            self.unitDebuffs[unitID][index] = {
                name = name,
                icon = icon,
                count = count,
                duration = duration,
                expirationTime = expirationTime,
                debuffType = debuffType,
                spellId = spellId,
                index = index,
                filter = "HARMFUL"
            }
            
            -- Update frame
            local debuffFrame = self:GetAuraFrame(unitID, debuffCount + 1, true)
            self:UpdateAuraFrame(debuffFrame, self.unitDebuffs[unitID][index], unitID)
            
            debuffCount = debuffCount + 1
            index = index + 1
        end
    end
    
    -- Hide unused frames
    for i = buffCount + 1, #container.buffFrames do
        if container.buffFrames[i] then
            container.buffFrames[i]:Hide()
            container.buffFrames[i].used = false
        end
    end
    
    for i = debuffCount + 1, #container.debuffFrames do
        if container.debuffFrames[i] then
            container.debuffFrames[i]:Hide()
            container.debuffFrames[i].used = false
        end
    end
    
    -- Position auras in the container
    self:PositionUnitAuras(container, buffCount, debuffCount)
    
    -- Update container size
    self:UpdateContainerSize(container, buffCount, debuffCount)
    
    -- Show container if it has auras, hide if empty
    if buffCount > 0 or debuffCount > 0 then
        container:Show()
    else
        container:Hide()
    end
    
    -- Process aura changes for animations/notifications
    self:ProcessAuraChanges(unitID, oldAuras, self.unitAuras[unitID], false)
    if VUI.db.profile.modules.buffoverlay.showDebuffs then
        self:ProcessAuraChanges(unitID, oldDebuffs, self.unitDebuffs[unitID], true)
    end
end

-- Update aura frame with data
function VUI.BuffOverlay:UpdateAuraFrame(frame, aura, unitID)
    if not frame or not aura then return end
    
    -- Set the icon
    frame.icon:SetTexture(aura.icon)
    
    -- Store aura data for tooltip
    frame.auraIndex = aura.index
    frame.filter = aura.filter
    frame.unitID = unitID
    
    -- Set stack count
    if aura.count and aura.count > 1 then
        frame.count:SetText(aura.count)
        frame.count:Show()
    else
        frame.count:Hide()
    end
    
    -- Set border color for debuffs based on type if enabled
    if aura.filter == "HARMFUL" and VUI.db.profile.modules.buffoverlay.colorByType and aura.debuffType then
        local color = DebuffTypeColor[aura.debuffType] or DebuffTypeColor["none"]
        if color then
            frame.border:SetColorTexture(color.r, color.g, color.b, 1.0)
        end
    end
    
    -- Set cooldown
    if frame.cooldown and aura.duration and aura.duration > 0 and aura.expirationTime and aura.expirationTime > 0 then
        frame.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
        
        if VUI.db.profile.modules.buffoverlay.showCooldownSpiral then
            frame.cooldown:Show()
        else
            frame.cooldown:Hide()
        end
        
        -- Update duration text if enabled
        if frame.duration and VUI.db.profile.modules.buffoverlay.showDuration then
            frame.duration:Show()
            
            -- Update timer
            frame:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed < 0.1 then return end
                self.elapsed = 0
                
                local timeLeft = aura.expirationTime - GetTime()
                if timeLeft <= 0 then
                    self.duration:SetText("")
                else
                    -- Format based on setting
                    if VUI.db.profile.modules.buffoverlay.enhancedTimerFormat then
                        -- Enhanced formatting (more precise)
                        if timeLeft > 60 then
                            self.duration:SetText(format("%d:%02d", floor(timeLeft/60), floor(timeLeft%60)))
                        elseif timeLeft > 10 then
                            self.duration:SetText(format("%d", floor(timeLeft)))
                        else
                            self.duration:SetText(format("%.1f", timeLeft))
                        end
                    else
                        -- Standard formatting
                        self.duration:SetText(VUI:FormatTime(timeLeft))
                    end
                end
            end)
        elseif frame.duration then
            frame.duration:Hide()
            frame:SetScript("OnUpdate", nil)
        end
    elseif frame.cooldown then
        frame.cooldown:Hide()
        if frame.duration then
            frame.duration:Hide()
            frame:SetScript("OnUpdate", nil)
        end
    end
    
    frame.used = true
    frame:Show()
end

-- Update container size based on content
function VUI.BuffOverlay:UpdateContainerSize(container, buffCount, debuffCount)
    if not container then return end
    
    local size = VUI.db.profile.modules.buffoverlay.size or 24
    local spacing = VUI.db.profile.modules.buffoverlay.spacing or 2
    
    -- Calculate width based on aura count
    local maxAuras = max(buffCount, debuffCount)
    local containerWidth = maxAuras * (size + spacing) + spacing
    
    -- Calculate height based on showing buffs/debuffs
    local containerHeight = size + spacing * 2
    if VUI.db.profile.modules.buffoverlay.showDebuffs and debuffCount > 0 then
        containerHeight = containerHeight * 2 + spacing
    end
    
    -- Update sizes
    container.buffs:SetWidth(containerWidth)
    container.debuffs:SetWidth(containerWidth)
    container:SetSize(containerWidth, containerHeight)
    
    -- Position for nameplate units
    if container.unitID and container.unitID:match("nameplate") then
        local nameplate = C_NamePlate.GetNamePlateForUnit(container.unitID)
        if nameplate then
            container:ClearAllPoints()
            container:SetPoint("BOTTOM", nameplate, "TOP", 0, 10)
        end
    end
end

-- Process aura changes for notifications
function VUI.BuffOverlay:ProcessAuraChanges(unitID, oldAuras, newAuras, isDebuff)
    -- Implement notification logic if needed
end

-- Update all auras for tracked units
function VUI.BuffOverlay:UpdateAllAuras()
    -- Update player auras
    self:UpdateUnitAuras("player")
    
    -- Update target and focus if they exist
    if UnitExists("target") then
        self:UpdateUnitAuras("target")
    end
    
    if UnitExists("focus") then
        self:UpdateUnitAuras("focus")
    end
    
    -- Update group members
    if IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local unit = IsInRaid() and "raid"..i or "party"..i
            if UnitExists(unit) then
                self:UpdateUnitAuras(unit)
            end
        end
    end
    
    -- Update nameplates
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        local unitID = nameplate.namePlateUnitToken
        if unitID and UnitExists(unitID) then
            self:UpdateUnitAuras(unitID)
        end
    end
end

-- Start the enhanced display
function VUI.BuffOverlay:StartEnhancedDisplay()
    -- Create update frame if needed
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
    end
    
    -- Start the update timer
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
        if self.timeSinceLastUpdate >= 0.2 then -- Update every 0.2 seconds
            self.timeSinceLastUpdate = 0
            self:UpdateAllAuras()
        end
    end)
    
    -- Force an initial update
    self:UpdateAllAuras()
end

-- Stop the enhanced display
function VUI.BuffOverlay:StopEnhancedDisplay()
    if self.updateFrame then
        self.updateFrame:SetScript("OnUpdate", nil)
    end
    
    -- Hide all unit containers
    if self.unitContainers then
        for _, container in pairs(self.unitContainers) do
            container:Hide()
        end
    end
end

-- Get a display name for the unit
function VUI.BuffOverlay:GetUnitDisplayName(unitID)
    if not unitID then return "" end
    
    if unitID == "player" then
        return "You"
    elseif UnitExists(unitID) then
        local name = UnitName(unitID)
        if name then
            if UnitIsPlayer(unitID) then
                local _, className = UnitClass(unitID)
                if className then
                    local classColor = RAID_CLASS_COLORS[className]
                    if classColor then
                        return format("|cff%02x%02x%02x%s|r", 
                            classColor.r * 255, 
                            classColor.g * 255, 
                            classColor.b * 255, 
                            name)
                    end
                end
            end
            return name
        end
    end
    
    return unitID
end
