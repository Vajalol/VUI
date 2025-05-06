-- VUI TrufiGCD Module
-- Adapted from: https://github.com/Trufi/TrufiGCD
-- Author: VortexQ8

-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the namespace if it doesn't exist
if not VUI.TrufiGCD then
    VUI.TrufiGCD = {}
end

-- Create lowercase reference for backward compatibility
if not VUI.trufigcd then
    VUI.trufigcd = VUI.TrufiGCD
end

-- Create a local reference for easier access
local TrufiGCD = VUI.TrufiGCD

-- Default settings
TrufiGCD.defaults = {
    enabled = true,
    size = 30,
    maxIcons = 5,
    orientation = "HORIZONTAL",
    direction = "RIGHT",
    position = {"CENTER", UIParent, "CENTER", 0, -200},
    fadeOutTime = 1.5,
    showSpellName = true,
    showCooldown = true,
    hideCooldownNumbers = false,
    hideInPetBattle = true,
    hideOutOfCombat = false,
    blacklist = {},
    showTooltip = true,
    scale = 1.0,
    alpha = 1.0,
    showBorder = true,
    borderColor = {r = 0, g = 0, b = 0, a = 1},
    backgroundColor = {r = 0, g = 0, b = 0, a = 0.5},
    theme = "thunderstorm" -- Default theme
}

-- Initialize the module
function VUI.TrufiGCD:Initialize()
    if not VUI.enabledModules.TrufiGCD then return end
    
    -- Initialize database reference
    self:InitializeDB()
    
    -- Spell queue
    self.spellQueue = {}
    
    -- Preload the atlas textures for optimization
    self:PreloadAtlasTextures()
    
    -- Create main frame for displaying GCD icons
    self:CreateGCDFrame()
    
    -- Register events
    self:RegisterEvents()
    
    -- Apply settings
    self:ApplySettings()
    
    -- Initialize tracked spells
    self:InitializeSpellList()
    
    -- Register theme hooks
    self:RegisterThemeHooks()
    
    -- Apply current theme
    self:ApplyTheme(self.db.profile.theme or "thunderstorm")
    
    -- Log initialization
    VUI:Print("TrufiGCD module initialized with Atlas texture optimization")
end

-- Initialize database
function VUI.TrufiGCD:InitializeDB()
    -- Ensure we have both camelCase and lowercase db paths for backward compatibility
    if not VUI.db.profile.modules.TrufiGCD then
        VUI.db.profile.modules.TrufiGCD = {}
    end
    
    -- Standardize database paths by copying existing data to camelCase version
    if VUI.db.profile.modules.trufigcd then
        for k, v in pairs(VUI.db.profile.modules.trufigcd) do
            VUI.db.profile.modules.TrufiGCD[k] = v
        end
    end
    
    -- Create reference for backward compatibility
    VUI.db.profile.modules.trufigcd = VUI.db.profile.modules.TrufiGCD
    
    -- Create a direct reference
    self.db = {}
    self.db.profile = VUI.db.profile.modules.TrufiGCD
    
    -- Apply defaults for missing values
    for k, v in pairs(self.defaults) do
        if self.db.profile[k] == nil then
            self.db.profile[k] = v
        end
    end
end

-- Preload the atlas textures for better performance
function VUI.TrufiGCD:PreloadAtlasTextures()
    -- Preload the module's texture atlas if available
    -- Load texture atlas for better performance
    if VUI.Atlas and VUI.Atlas.PreloadAtlas then
        VUI.Atlas:PreloadAtlas("modules.trufigcd")
    end
end

-- Create the main frame for GCD tracking
function VUI.TrufiGCD:CreateGCDFrame()
    -- Create main frame
    self.frame = CreateFrame("Frame", "VUITrufiGCDFrame", UIParent)
    self.frame:SetPoint(unpack(self.db.profile.position))
    
    -- Calculate frame size based on orientation and max icons
    local size = self.db.profile.size
    local maxIcons = self.db.profile.maxIcons
    
    if self.db.profile.orientation == "HORIZONTAL" then
        self.frame:SetSize(size * maxIcons, size)
    else
        self.frame:SetSize(size, size * maxIcons)
    end
    
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
    
    -- Show frame border when in config mode
    self.frame:SetScript("OnEnter", function()
        if VUI.configFrame and VUI.configFrame:IsShown() then
            self.frameBorder:Show()
        end
    end)
    
    self.frame:SetScript("OnLeave", function()
        if not MouseIsOver(self.configButton) then
            self.frameBorder:Hide()
        end
    end)
    
    -- Create container with background for the frame (for theme coloring)
    self.container = CreateFrame("Frame", nil, self.frame)
    self.container:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -4, 4)
    self.container:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 4, -4)
    
    -- Add background for container using atlas textures if available
    self.container.background = self.container:CreateTexture(nil, "BACKGROUND")
    self.container.background:SetAllPoints()
    
    if VUI.GetTextureCached then
        local backgroundTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\background.tga")
        if backgroundTexture and backgroundTexture.isAtlas then
            VUI.Atlas:ApplyTextureCoordinates(self.container.background, backgroundTexture)
        else
            -- Fallback
            self.container.background:SetColorTexture(0, 0, 0, 0.3)
        end
    else
        -- Fallback
        self.container.background:SetColorTexture(0, 0, 0, 0.3)
    end
    
    -- Add border for container using atlas textures if available
    self.container.border = self.container:CreateTexture(nil, "BORDER")
    self.container.border:SetPoint("TOPLEFT", self.container, "TOPLEFT", -1, 1)
    self.container.border:SetPoint("BOTTOMRIGHT", self.container, "BOTTOMRIGHT", 1, -1)
    
    if VUI.GetTextureCached then
        local borderTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\border.tga")
        if borderTexture and borderTexture.isAtlas then
            VUI.Atlas:ApplyTextureCoordinates(self.container.border, borderTexture)
        else
            -- Fallback
            self.container.border:SetColorTexture(0, 0, 0, 0.8)
        end
    else
        -- Fallback
        self.container.border:SetColorTexture(0, 0, 0, 0.8)
    end
    
    -- Create border for when in config mode
    self.frameBorder = CreateFrame("Frame", nil, self.frame)
    self.frameBorder:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -2, 2)
    self.frameBorder:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 2, -2)
    self.frameBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    self.frameBorder:SetBackdropBorderColor(1, 1, 1, 0.3)
    self.frameBorder:Hide()
    
    -- Create config button
    self.configButton = CreateFrame("Button", nil, self.frame)
    self.configButton:SetSize(20, 20)
    self.configButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 5, 5)
    
    -- Use atlas textures if available
    if VUI.GetTextureCached then
        local normalTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\config-button.tga")
        local highlightTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\config-button-highlight.tga")
        
        if normalTexture and normalTexture.isAtlas then
            local normal = self.configButton:CreateTexture(nil, "ARTWORK")
            normal:SetAllPoints()
            VUI.Atlas:ApplyTextureCoordinates(normal, normalTexture)
            self.configButton:SetNormalTexture(normal)
            
            if highlightTexture and highlightTexture.isAtlas then
                local highlight = self.configButton:CreateTexture(nil, "HIGHLIGHT")
                highlight:SetAllPoints()
                VUI.Atlas:ApplyTextureCoordinates(highlight, highlightTexture)
                self.configButton:SetHighlightTexture(highlight)
            end
        else
            -- Fallback to default textures if atlas is not available
            self.configButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
            self.configButton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
        end
    else
        -- Fallback to default textures
        self.configButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
        self.configButton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
    end
    self.configButton:SetScript("OnClick", function()
        VUI:ToggleConfig()
        -- Select TrufiGCD in the config panel
        if VUI.configFrame and VUI.configFrame:IsShown() then
            VUI:ShowConfigSection(VUI.configFrame, "Modules")
            VUI:ShowModuleConfig(VUI.configFrame.sections["Modules"], "TrufiGCD")
        end
    end)
    self.configButton:Hide() -- Only show when in config mode
    
    -- Show config button when config is open
    self.frame:SetScript("OnEnter", function()
        if VUI.configFrame and VUI.configFrame:IsShown() then
            self.configButton:Show()
            self.frameBorder:Show()
        end
    end)
    
    self.frame:SetScript("OnLeave", function()
        if not MouseIsOver(self.configButton) then
            self.configButton:Hide()
            self.frameBorder:Hide()
        end
    end)
    
    self.configButton:SetScript("OnLeave", function()
        if not MouseIsOver(self.frame) then
            self.configButton:Hide()
            self.frameBorder:Hide()
        end
    end)
    
    -- Table to store icon frames
    self.iconFrames = {}
    
    -- Create icon frames
    for i = 1, maxIcons do
        self:CreateIconFrame(i)
    end
end

-- Create an individual icon frame
function VUI.TrufiGCD:CreateIconFrame(index)
    local size = self.db.profile.size
    
    -- Create frame
    local frame = CreateFrame("Frame", "VUITrufiGCDIcon"..index, self.frame)
    frame:SetSize(size, size)
    
    -- Set position based on orientation and direction
    self:PositionIconFrame(frame, index)
    
    -- Background texture (for theme coloring) with atlas support
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    
    if VUI.GetTextureCached then
        local backgroundTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\background.tga")
        if backgroundTexture and backgroundTexture.isAtlas then
            VUI.Atlas:ApplyTextureCoordinates(frame.background, backgroundTexture)
        else
            -- Fallback
            frame.background:SetColorTexture(0, 0, 0, 0.3)
        end
    else
        -- Fallback
        frame.background:SetColorTexture(0, 0, 0, 0.3)
    end
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim the icon borders
    
    -- Icon frame (border) with atlas support
    frame.iconFrame = frame:CreateTexture(nil, "OVERLAY")
    frame.iconFrame:SetAllPoints()
    
    if VUI.GetTextureCached then
        local iconFrameTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\icon-frame.tga")
        if iconFrameTexture and iconFrameTexture.isAtlas then
            VUI.Atlas:ApplyTextureCoordinates(frame.iconFrame, iconFrameTexture)
        end
    end
    
    -- Standard border as fallback/overlay
    frame.border = frame:CreateTexture(nil, "OVERLAY")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    frame.border:SetColorTexture(0, 0, 0, 1)
    
    -- Cooldown with atlas support
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetDrawSwipe(true)
    frame.cooldown:SetReverse(false)
    
    -- Apply custom cooldown swipe texture if available
    if VUI.GetTextureCached then
        local cooldownSwipeTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\cooldown-swipe.tga")
        if cooldownSwipeTexture and cooldownSwipeTexture.isAtlas and frame.cooldown.SetSwipeTexture then
            -- Not all WoW API versions support SetSwipeTexture, so we check first
            local swipe = frame.cooldown:CreateTexture(nil, "OVERLAY")
            VUI.Atlas:ApplyTextureCoordinates(swipe, cooldownSwipeTexture)
            if frame.cooldown.SetSwipeTexture then
                frame.cooldown:SetSwipeTexture(swipe:GetTexture())
            end
        end
    end
    
    -- Spell name text
    if self.db.profile.showSpellName then
        frame.spellName = frame:CreateFontString(nil, "OVERLAY")
        frame.spellName:SetFont(VUI:GetFont("expressway"), math.max(size/3, 8), "OUTLINE")
        frame.spellName:SetPoint("BOTTOM", 0, -size/3)
        frame.spellName:SetText("")
        frame.spellName:SetWidth(size * 1.5)
        frame.spellName:SetHeight(size/3)
        frame.spellName:SetJustifyH("CENTER")
    end
    
    -- Tooltip handling
    frame:SetScript("OnEnter", function(self)
        if not VUI.TrufiGCD.db.profile.showTooltip or not self.spellID then return end
        
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetSpellByID(self.spellID)
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Store frame
    self.iconFrames[index] = frame
    frame:Hide()
end

-- Position an icon frame based on its index
function VUI.TrufiGCD:PositionIconFrame(frame, index)
    local size = self.db.profile.size
    local orientation = self.db.profile.orientation
    local direction = self.db.profile.direction
    
    if index == 1 then
        -- First icon is always at the starting point
        if orientation == "HORIZONTAL" then
            if direction == "LEFT" then
                frame:SetPoint("RIGHT", self.frame, "RIGHT", 0, 0)
            else
                frame:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
            end
        else -- VERTICAL
            if direction == "UP" then
                frame:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0)
            else
                frame:SetPoint("TOP", self.frame, "TOP", 0, 0)
            end
        end
    else
        -- Position relative to previous icon
        local prevFrame = self.iconFrames[index-1]
        
        if orientation == "HORIZONTAL" then
            if direction == "LEFT" then
                frame:SetPoint("RIGHT", prevFrame, "LEFT", 0, 0)
            else
                frame:SetPoint("LEFT", prevFrame, "RIGHT", 0, 0)
            end
        else -- VERTICAL
            if direction == "UP" then
                frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, 0)
            else
                frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, 0)
            end
        end
    end
end

-- Register events for ability tracking
function VUI.TrufiGCD:RegisterEvents()
    -- Create event frame
    self.eventFrame = CreateFrame("Frame")
    
    -- Register events
    self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("PLAYER_LOGIN")
    self.eventFrame:RegisterEvent("PLAYER_LOGOUT")
    self.eventFrame:RegisterEvent("ADDON_LOADED")
    
    -- For pet battle hiding
    if self.db.profile.hideInPetBattle then
        self.eventFrame:RegisterEvent("PET_BATTLE_OPENING_START")
        self.eventFrame:RegisterEvent("PET_BATTLE_CLOSE")
    end
    
    -- Event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, _, spellID = ...
            if unit == "player" then
                self:ProcessSpellCast(spellID)
            end
        elseif event == "PET_BATTLE_OPENING_START" then
            self.frame:Hide()
        elseif event == "PET_BATTLE_CLOSE" then
            self.frame:Show()
        elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then
            self:ClearIcons()
        end
    end)
    
    -- Animation update
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        self:UpdateIconAnimations(elapsed)
    end)
end

-- Initialize list of tracked spells
function VUI.TrufiGCD:InitializeSpellList()
    -- Initialize the tracked spells list
    self.trackedSpells = {}
    self.blacklistedSpells = self.db.profile.blacklist or {}
    
    -- By default, we track all spells that trigger the GCD
    -- Blacklist is used to ignore specific spells
end

-- Process a spell cast and add it to the queue
function VUI.TrufiGCD:ProcessSpellCast(spellID)
    -- Skip if spell is blacklisted
    if self.blacklistedSpells[spellID] then return end
    
    -- Get spell info
    local name, _, icon = GetSpellInfo(spellID)
    if not name or not icon then return end
    
    -- Add spell to queue
    self:AddSpellToQueue(spellID, name, icon)
end

-- Add a spell to the queue and update the icon display
function VUI.TrufiGCD:AddSpellToQueue(spellID, name, icon)
    -- Add to queue
    table.insert(self.spellQueue, 1, {
        spellID = spellID,
        name = name,
        icon = icon,
        time = GetTime(),
        fadeTime = self.db.profile.fadeOutTime
    })
    
    -- Trim queue if it exceeds the maximum
    while #self.spellQueue > self.db.profile.maxIcons do
        table.remove(self.spellQueue)
    end
    
    -- Update icon display
    self:UpdateIcons()
end

-- Update the icon display based on the spell queue
function VUI.TrufiGCD:UpdateIcons()
    -- Hide all icons first
    for i = 1, #self.iconFrames do
        self.iconFrames[i]:Hide()
    end
    
    -- Show icons for queued spells
    for i = 1, math.min(#self.spellQueue, #self.iconFrames) do
        local spell = self.spellQueue[i]
        local frame = self.iconFrames[i]
        
        -- Update icon
        frame.icon:SetTexture(spell.icon)
        
        -- Set spell ID for tooltip
        frame.spellID = spell.spellID
        
        -- Update spell name
        if self.db.profile.showSpellName and frame.spellName then
            local shortName = (spell.name:len() > 10) and spell.name:sub(1, 8) .. "..." or spell.name
            frame.spellName:SetText(shortName)
        end
        
        -- Show the frame
        frame:Show()
        
        -- Start cooldown animation
        if self.db.profile.showCooldown then
            frame.cooldown:SetCooldown(spell.time, spell.fadeTime)
        else
            frame.cooldown:Hide()
        end
    end
end

-- Update icon animations (fading)
function VUI.TrufiGCD:UpdateIconAnimations(elapsed)
    local currentTime = GetTime()
    local updated = false
    
    -- Update fade time for each spell in queue
    for i, spell in ipairs(self.spellQueue) do
        local timeElapsed = currentTime - spell.time
        
        -- If spell has exceeded its fade time, remove it
        if timeElapsed > spell.fadeTime then
            table.remove(self.spellQueue, i)
            updated = true
            break -- Only remove one per frame to avoid table shifting issues
        end
    end
    
    -- Update icon display if needed
    if updated then
        self:UpdateIcons()
    end
end

-- Clear all icons
function VUI.TrufiGCD:ClearIcons()
    wipe(self.spellQueue)
    self:UpdateIcons()
end

-- Apply settings from the database
function VUI.TrufiGCD:ApplySettings()
    -- Apply settings to the frame
    local size = self.db.profile.size
    local maxIcons = self.db.profile.maxIcons
    
    -- Resize main frame
    if self.db.profile.orientation == "HORIZONTAL" then
        self.frame:SetSize(size * maxIcons, size)
    else
        self.frame:SetSize(size, size * maxIcons)
    end
    
    -- Reposition main frame
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.db.profile.position))
    
    -- Update icon frames
    for i = 1, maxIcons do
        -- Create frame if it doesn't exist
        if not self.iconFrames[i] then
            self:CreateIconFrame(i)
        end
        
        -- Resize frame
        self.iconFrames[i]:SetSize(size, size)
        
        -- Reposition frame
        self:PositionIconFrame(self.iconFrames[i], i)
        
        -- Update spell name text size
        if self.db.profile.showSpellName and self.iconFrames[i].spellName then
            self.iconFrames[i].spellName:SetFont(VUI:GetFont("expressway"), math.max(size/3, 8), "OUTLINE")
            self.iconFrames[i].spellName:SetPoint("BOTTOM", 0, -size/3)
        end
    end
    
    -- Hide excess frames if max icons decreased
    for i = maxIcons + 1, #self.iconFrames do
        self.iconFrames[i]:Hide()
    end
    
    -- Check if we need to recreate the spell name text objects
    local showSpellName = self.db.profile.showSpellName
    for i = 1, maxIcons do
        if showSpellName and not self.iconFrames[i].spellName then
            self.iconFrames[i].spellName = self.iconFrames[i]:CreateFontString(nil, "OVERLAY")
            self.iconFrames[i].spellName:SetFont(VUI:GetFont("expressway"), math.max(size/3, 8), "OUTLINE")
            self.iconFrames[i].spellName:SetPoint("BOTTOM", 0, -size/3)
            self.iconFrames[i].spellName:SetWidth(size * 1.5)
            self.iconFrames[i].spellName:SetHeight(size/3)
            self.iconFrames[i].spellName:SetJustifyH("CENTER")
        elseif not showSpellName and self.iconFrames[i].spellName then
            self.iconFrames[i].spellName:SetText("")
            self.iconFrames[i].spellName:Hide()
        end
    end
    
    -- Update icons with new settings
    self:UpdateIcons()
    
    -- Update PET_BATTLE event registration based on settings
    if self.db.profile.hideInPetBattle then
        self.eventFrame:RegisterEvent("PET_BATTLE_OPENING_START")
        self.eventFrame:RegisterEvent("PET_BATTLE_CLOSE")
    else
        self.eventFrame:UnregisterEvent("PET_BATTLE_OPENING_START")
        self.eventFrame:UnregisterEvent("PET_BATTLE_CLOSE")
    end
end

-- Refresh config when profile changes
function VUI.TrufiGCD:RefreshConfig()
    self:ApplySettings()
end

-- Create module-specific config options
function VUI.TrufiGCD:CreateConfigOptions(parentFrame)
    -- Size slider
    parentFrame.sizeText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.sizeText:SetPoint("TOPLEFT", parentFrame.title, "BOTTOMLEFT", 0, -20)
    parentFrame.sizeText:SetText("Icon Size:")
    
    parentFrame.sizeSlider = VUI.UI:CreateSlider(parentFrame, "VUITrufiGCDSizeSlider", "", 16, 64, 2)
    parentFrame.sizeSlider:SetPoint("TOPLEFT", parentFrame.sizeText, "BOTTOMLEFT", 0, -10)
    parentFrame.sizeSlider:SetWidth(200)
    parentFrame.sizeSlider:SetValue(self.db.profile.size)
    
    parentFrame.sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        VUI.TrufiGCD.db.profile.size = value
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Max icons slider
    parentFrame.maxIconsText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.maxIconsText:SetPoint("TOPLEFT", parentFrame.sizeSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.maxIconsText:SetText("Maximum Icons:")
    
    parentFrame.maxIconsSlider = VUI.UI:CreateSlider(parentFrame, "VUITrufiGCDMaxIconsSlider", "", 1, 16, 1)
    parentFrame.maxIconsSlider:SetPoint("TOPLEFT", parentFrame.maxIconsText, "BOTTOMLEFT", 0, -10)
    parentFrame.maxIconsSlider:SetWidth(200)
    parentFrame.maxIconsSlider:SetValue(self.db.profile.maxIcons)
    
    parentFrame.maxIconsSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        VUI.TrufiGCD.db.profile.maxIcons = value
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Fade out time slider
    parentFrame.fadeOutText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.fadeOutText:SetPoint("TOPLEFT", parentFrame.maxIconsSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.fadeOutText:SetText("Fade Out Time (seconds):")
    
    parentFrame.fadeOutSlider = VUI.UI:CreateSlider(parentFrame, "VUITrufiGCDFadeOutSlider", "", 0.5, 5.0, 0.1)
    parentFrame.fadeOutSlider:SetPoint("TOPLEFT", parentFrame.fadeOutText, "BOTTOMLEFT", 0, -10)
    parentFrame.fadeOutSlider:SetWidth(200)
    parentFrame.fadeOutSlider:SetValue(self.db.profile.fadeOutTime)
    
    parentFrame.fadeOutSlider:SetScript("OnValueChanged", function(self, value)
        VUI.TrufiGCD.db.profile.fadeOutTime = value
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Orientation dropdown
    parentFrame.orientationText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.orientationText:SetPoint("TOPLEFT", parentFrame.fadeOutSlider, "BOTTOMLEFT", 0, -20)
    parentFrame.orientationText:SetText("Orientation:")
    
    parentFrame.orientationDropdown = VUI.UI:CreateDropdown(parentFrame, "VUITrufiGCDOrientationDropdown", "", 150)
    parentFrame.orientationDropdown:SetPoint("TOPLEFT", parentFrame.orientationText, "BOTTOMLEFT", 0, -10)
    
    -- Populate orientation dropdown
    UIDropDownMenu_Initialize(parentFrame.orientationDropdown, function(dropdown, level)
        local orientations = {
            {text = "Horizontal", value = "HORIZONTAL"},
            {text = "Vertical", value = "VERTICAL"}
        }
        local info = UIDropDownMenu_CreateInfo()
        
        for _, orientation in ipairs(orientations) do
            info.text = orientation.text
            info.value = orientation.value
            info.func = function(self)
                VUI.TrufiGCD.db.profile.orientation = self.value
                UIDropDownMenu_SetText(dropdown, self.text)
                VUI.TrufiGCD:ApplySettings()
            end
            info.checked = (VUI.TrufiGCD.db.profile.orientation == orientation.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetText(parentFrame.orientationDropdown, self.db.profile.orientation == "HORIZONTAL" and "Horizontal" or "Vertical")
    
    -- Direction dropdown
    parentFrame.directionText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.directionText:SetPoint("TOPLEFT", parentFrame.orientationDropdown, "BOTTOMLEFT", 0, -20)
    parentFrame.directionText:SetText("Direction:")
    
    parentFrame.directionDropdown = VUI.UI:CreateDropdown(parentFrame, "VUITrufiGCDDirectionDropdown", "", 150)
    parentFrame.directionDropdown:SetPoint("TOPLEFT", parentFrame.directionText, "BOTTOMLEFT", 0, -10)
    
    -- Populate direction dropdown
    UIDropDownMenu_Initialize(parentFrame.directionDropdown, function(dropdown, level)
        local directions = {}
        
        if VUI.TrufiGCD.db.profile.orientation == "HORIZONTAL" then
            directions = {
                {text = "Left", value = "LEFT"},
                {text = "Right", value = "RIGHT"}
            }
        else
            directions = {
                {text = "Up", value = "UP"},
                {text = "Down", value = "DOWN"}
            }
        end
        
        local info = UIDropDownMenu_CreateInfo()
        
        for _, direction in ipairs(directions) do
            info.text = direction.text
            info.value = direction.value
            info.func = function(self)
                VUI.TrufiGCD.db.profile.direction = self.value
                UIDropDownMenu_SetText(dropdown, self.text)
                VUI.TrufiGCD:ApplySettings()
            end
            info.checked = (VUI.TrufiGCD.db.profile.direction == direction.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Set initial text
    local directionText = ""
    if self.db.profile.direction == "LEFT" then directionText = "Left"
    elseif self.db.profile.direction == "RIGHT" then directionText = "Right"
    elseif self.db.profile.direction == "UP" then directionText = "Up"
    elseif self.db.profile.direction == "DOWN" then directionText = "Down"
    end
    UIDropDownMenu_SetText(parentFrame.directionDropdown, directionText)
    
    -- Show spell name checkbox
    parentFrame.spellNameCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUITrufiGCDSpellNameCheckbox", "Show Spell Name")
    parentFrame.spellNameCheckbox:SetPoint("TOPLEFT", parentFrame.directionDropdown, "BOTTOMLEFT", 0, -20)
    parentFrame.spellNameCheckbox:SetChecked(self.db.profile.showSpellName)
    
    parentFrame.spellNameCheckbox:SetScript("OnClick", function(self)
        VUI.TrufiGCD.db.profile.showSpellName = self:GetChecked()
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Show cooldown checkbox
    parentFrame.cooldownCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUITrufiGCDCooldownCheckbox", "Show Cooldown Animation")
    parentFrame.cooldownCheckbox:SetPoint("TOPLEFT", parentFrame.spellNameCheckbox, "BOTTOMLEFT", 0, -10)
    parentFrame.cooldownCheckbox:SetChecked(self.db.profile.showCooldown)
    
    parentFrame.cooldownCheckbox:SetScript("OnClick", function(self)
        VUI.TrufiGCD.db.profile.showCooldown = self:GetChecked()
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Show tooltip checkbox
    parentFrame.tooltipCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUITrufiGCDTooltipCheckbox", "Show Tooltip")
    parentFrame.tooltipCheckbox:SetPoint("TOPLEFT", parentFrame.cooldownCheckbox, "BOTTOMLEFT", 0, -10)
    parentFrame.tooltipCheckbox:SetChecked(self.db.profile.showTooltip)
    
    parentFrame.tooltipCheckbox:SetScript("OnClick", function(self)
        VUI.TrufiGCD.db.profile.showTooltip = self:GetChecked()
    end)
    
    -- Hide in pet battle checkbox
    parentFrame.petBattleCheckbox = VUI.UI:CreateCheckbox(parentFrame, "VUITrufiGCDPetBattleCheckbox", "Hide In Pet Battle")
    parentFrame.petBattleCheckbox:SetPoint("TOPLEFT", parentFrame.tooltipCheckbox, "BOTTOMLEFT", 0, -10)
    parentFrame.petBattleCheckbox:SetChecked(self.db.profile.hideInPetBattle)
    
    parentFrame.petBattleCheckbox:SetScript("OnClick", function(self)
        VUI.TrufiGCD.db.profile.hideInPetBattle = self:GetChecked()
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Reset position button
    parentFrame.resetButton = VUI.UI:CreateButton(parentFrame, "VUITrufiGCDResetButton", "Reset Position", 120, 25)
    parentFrame.resetButton:SetPoint("TOPLEFT", parentFrame.petBattleCheckbox, "BOTTOMLEFT", 0, -20)
    
    parentFrame.resetButton:SetScript("OnClick", function()
        VUI.TrufiGCD.db.profile.position = {"CENTER", UIParent, "CENTER", 0, -100}
        VUI.TrufiGCD:ApplySettings()
    end)
    
    -- Blacklist management (simplified for this implementation)
    parentFrame.blacklistTitle = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    parentFrame.blacklistTitle:SetPoint("TOPLEFT", parentFrame.resetButton, "BOTTOMLEFT", 0, -20)
    parentFrame.blacklistTitle:SetText("Spell Blacklist")
    
    parentFrame.blacklistNote = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parentFrame.blacklistNote:SetPoint("TOPLEFT", parentFrame.blacklistTitle, "BOTTOMLEFT", 0, -10)
    parentFrame.blacklistNote:SetText("Blacklist management will be expanded in a future update.")
end

-- Enable the module
function VUI.TrufiGCD:Enable()
    if not self.frame then
        self:Initialize()
    else
        self.frame:Show()
    end
end

-- Disable the module
function VUI.TrufiGCD:Disable()
    if self.frame then
        self.frame:Hide()
    end
end

-- Register theme hooks
function VUI.TrufiGCD:RegisterThemeHooks()
    -- Register with theme system if available
    if VUI.ThemeIntegration and VUI.ThemeIntegration.RegisterModule then
        VUI.ThemeIntegration:RegisterModule("TrufiGCD", self)
    elseif VUI.RegisterThemeableModule then
        VUI:RegisterThemeableModule("TrufiGCD", self)
    end
    
    -- Listen for theme changes
    if VUI.RegisterCallback then
        VUI:RegisterCallback("ThemeChanged", function(_, theme)
            self:ApplyTheme(theme)
        end)
    end
end

-- Apply a theme to the module
function VUI.TrufiGCD:ApplyTheme(theme)
    if not theme then 
        theme = self.db.profile.theme or "thunderstorm"
    end
    
    -- Save the current theme
    self.db.profile.theme = theme
    
    -- Get theme colors
    local colors = VUI.ThemeColors and VUI.ThemeColors[theme] or {
        -- Default colors if theme system is not available
        primary = {r = 0.4, g = 0.4, b = 0.95, a = 1.0},
        secondary = {r = 0.2, g = 0.2, b = 0.7, a = 1.0},
        background = {r = 0, g = 0, b = 0.2, a = 0.8},
        border = {r = 0.1, g = 0.1, b = 0.4, a = 1.0},
        highlight = {r = 0.7, g = 0.7, b = 1.0, a = 1.0}
    }
    
    -- Apply theme colors to UI elements
    if self.container and self.container.border then
        self.container.border:SetVertexColor(
            colors.border.r, colors.border.g, colors.border.b, colors.border.a
        )
    end
    
    if self.container and self.container.background then
        self.container.background:SetVertexColor(
            colors.background.r, colors.background.g, colors.background.b, colors.background.a
        )
    end
    
    -- Apply to icon frames
    for _, frame in pairs(self.iconFrames or {}) do
        if frame.border then
            frame.border:SetVertexColor(
                colors.border.r, colors.border.g, colors.border.b, colors.border.a
            )
        end
        
        if frame.background then
            frame.background:SetVertexColor(
                colors.background.r, colors.background.g, colors.background.b, colors.background.a * 0.7
            )
        end
        
        if frame.iconFrame then
            frame.iconFrame:SetVertexColor(
                colors.secondary.r, colors.secondary.g, colors.secondary.b, colors.secondary.a
            )
        end
    end
end
