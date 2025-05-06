-- VUI OmniCD Party Frame Integration
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local OmniCD = VUI.omnicd

-- Constants
local ICON_SIZE = 22         -- Default icon size for party frames
local ICON_SPACING = 2       -- Spacing between icons
local MAX_ICONS_PER_UNIT = 5 -- Maximum number of cooldown icons to show per unit
local GROW_DIRECTION = "RIGHT" -- Default growth direction

-- Storage for frame references
OmniCD.partyFrames = {}
OmniCD.partyFrameIcons = {}

-- Initialize party frame integration
function OmniCD:InitializePartyFrames()
    -- Create a config if it doesn't exist
    if not self.db.partyFrames then
        self.db.partyFrames = {
            enabled = true,
            iconSize = ICON_SIZE,
            iconSpacing = ICON_SPACING,
            maxIcons = MAX_ICONS_PER_UNIT,
            growDirection = GROW_DIRECTION,
            offsetX = 0,
            offsetY = -25,
            showTooltips = true,
            attachMethod = "BELOW", -- BELOW, RIGHT, LEFT
            filterByType = {
                interrupt = true,
                defensive = true,
                offensive = true,
                utility = false,
            },
            hideInCombat = false
        }
    end
    
    -- Register for events
    self:RegisterPartyFrameEvents()
    
    -- Initial setup of frames
    self:SetupPartyFrames()
    
    -- Apply theme
    self:ApplyThemeToPartyFrames()
    
    -- Debug disabled in production release
end

-- Register for party frame related events
function OmniCD:RegisterPartyFrameEvents()
    -- Create event frame if it doesn't exist
    if not self.partyEventFrame then
        self.partyEventFrame = CreateFrame("Frame")
        
        -- Register events
        self.partyEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        self.partyEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.partyEventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        self.partyEventFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
        self.partyEventFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
        
        -- For handling combat-specific behaviors
        self.partyEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.partyEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        
        -- Event handler
        self.partyEventFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
                self:SetupPartyFrames()
            elseif event == "UNIT_PORTRAIT_UPDATE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" then
                local unit = ...
                if unit and (unit == "player" or unit:find("party")) then
                    self:UpdatePartyFrame(unit)
                end
            elseif event == "PLAYER_REGEN_ENABLED" then
                -- Exiting combat
                if self.db.partyFrames.hideInCombat then
                    self:ShowPartyFrameIcons()
                end
            elseif event == "PLAYER_REGEN_DISABLED" then
                -- Entering combat
                if self.db.partyFrames.hideInCombat then
                    self:HidePartyFrameIcons()
                end
            end
        end)
    end
end

-- Set up party frames
function OmniCD:SetupPartyFrames()
    if not self.db.partyFrames.enabled then return end
    
    -- Clear existing frames
    self:ClearPartyFrames()
    
    -- Find party frames and attach icons
    self:FindAndAttachToPartyFrames()
    
    -- Update with current cooldown state
    self:UpdateAllPartyFrameCooldowns()
end

-- Find party frames and attach cooldown icons
function OmniCD:FindAndAttachToPartyFrames()
    -- First, set up the player frame
    self:SetupUnitFrame("player", PlayerFrame)
    
    -- Then set up party member frames
    local numGroupMembers = GetNumGroupMembers()
    for i = 1, numGroupMembers - 1 do -- -1 because player is already counted
        local unit = "party" .. i
        local frame = _G["PartyMemberFrame" .. i]
        
        if frame and frame:IsShown() then
            self:SetupUnitFrame(unit, frame)
        end
    end
end

-- Set up cooldown tracking for a specific unit frame
function OmniCD:SetupUnitFrame(unit, frame)
    if not unit or not frame then return end
    
    -- Store reference to the unit's frame
    self.partyFrames[unit] = frame
    
    -- Create container for cooldown icons
    self:CreateCooldownIconsContainer(unit, frame)
    
    -- Create icon frames for this unit
    self:CreateCooldownIconsForUnit(unit)
    
    -- Position the icons
    self:PositionCooldownIconsForUnit(unit)
    
    -- Apply themes
    self:ApplyThemeToUnitIcons(unit)
end

-- Create container for cooldown icons
function OmniCD:CreateCooldownIconsContainer(unit, parentFrame)
    local container = CreateFrame("Frame", "VUIOmniCDParty_" .. unit, parentFrame)
    local config = self.db.partyFrames
    
    -- Position based on attach method
    container:ClearAllPoints()
    if config.attachMethod == "BELOW" then
        container:SetPoint("TOP", parentFrame, "BOTTOM", config.offsetX, config.offsetY)
    elseif config.attachMethod == "RIGHT" then
        container:SetPoint("LEFT", parentFrame, "RIGHT", config.offsetX, config.offsetY)
    elseif config.attachMethod == "LEFT" then
        container:SetPoint("RIGHT", parentFrame, "LEFT", config.offsetX, config.offsetY)
    end
    
    -- Size the container based on max icons and direction
    local iconSize = config.iconSize
    local spacing = config.iconSpacing
    local maxIcons = config.maxIcons
    
    if config.growDirection == "RIGHT" or config.growDirection == "LEFT" then
        -- Horizontal layout
        container:SetSize((iconSize + spacing) * maxIcons, iconSize)
    else
        -- Vertical layout
        container:SetSize(iconSize, (iconSize + spacing) * maxIcons)
    end
    
    -- Store reference
    if not self.partyFrameIcons[unit] then
        self.partyFrameIcons[unit] = {}
    end
    self.partyFrameIcons[unit].container = container
end

-- Create cooldown icon frames for a unit
function OmniCD:CreateCooldownIconsForUnit(unit)
    if not self.partyFrameIcons[unit] then return end
    
    local container = self.partyFrameIcons[unit].container
    if not container then return end
    
    local config = self.db.partyFrames
    local iconSize = config.iconSize
    local maxIcons = config.maxIcons
    
    -- Create icon frames up to the max limit
    self.partyFrameIcons[unit].icons = {}
    
    for i = 1, maxIcons do
        local icon = CreateFrame("Frame", "VUIOmniCDParty_" .. unit .. "_Icon" .. i, container)
        icon:SetSize(iconSize, iconSize)
        
        -- Icon texture
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the borders
        
        -- Cooldown overlay
        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown:SetAllPoints()
        icon.cooldown:SetReverse(false)
        icon.cooldown:SetHideCountdownNumbers(true)
        
        -- Border (using atlas texture)
        icon.border = icon:CreateTexture(nil, "OVERLAY")
        icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        
        -- Get cached border texture from the atlas
        local borderTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\border.tga")
        if borderTexture and borderTexture.isAtlas then
            icon.border:SetTexture(borderTexture.path)
            icon.border:SetTexCoord(
                borderTexture.coords.left,
                borderTexture.coords.right,
                borderTexture.coords.top,
                borderTexture.coords.bottom
            )
        else
            icon.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
            icon.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        end
        
        -- Ready pulse effect
        icon.readyPulse = icon:CreateTexture(nil, "OVERLAY", nil, 3)
        icon.readyPulse:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
        icon.readyPulse:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)
        icon.readyPulse:SetAlpha(0) -- Hidden until ready
        
        -- Get cached ready pulse texture from the atlas
        local readyPulseTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\ready-pulse.tga")
        if readyPulseTexture and readyPulseTexture.isAtlas then
            icon.readyPulse:SetTexture(readyPulseTexture.path)
            icon.readyPulse:SetTexCoord(
                readyPulseTexture.coords.left,
                readyPulseTexture.coords.right,
                readyPulseTexture.coords.top,
                readyPulseTexture.coords.bottom
            )
        end
        
        -- Timer text
        icon.timer = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        icon.timer:SetPoint("CENTER", icon, "CENTER", 0, 0)
        icon.timer:SetTextColor(1, 1, 1)
        
        -- Store data about this icon
        icon.unit = unit
        icon.index = i
        icon.spellID = nil
        icon.cooldownInfo = nil
        
        -- Add tooltip functionality
        if config.showTooltips then
            icon:SetScript("OnEnter", function(self)
                if self.spellID then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetSpellByID(self.spellID)
                    GameTooltip:Show()
                end
            end)
            
            icon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
        
        -- Initially hide the icon
        icon:Hide()
        
        -- Store in our table
        self.partyFrameIcons[unit].icons[i] = icon
    end
end

-- Position cooldown icons for a unit
function OmniCD:PositionCooldownIconsForUnit(unit)
    if not self.partyFrameIcons[unit] or not self.partyFrameIcons[unit].icons then return end
    
    local config = self.db.partyFrames
    local growDir = config.growDirection
    local iconSize = config.iconSize
    local spacing = config.iconSpacing
    local container = self.partyFrameIcons[unit].container
    
    for i, icon in ipairs(self.partyFrameIcons[unit].icons) do
        icon:ClearAllPoints()
        
        if i == 1 then
            -- First icon positioning depends on growth direction
            if growDir == "RIGHT" then
                icon:SetPoint("LEFT", container, "LEFT", 0, 0)
            elseif growDir == "LEFT" then
                icon:SetPoint("RIGHT", container, "RIGHT", 0, 0)
            elseif growDir == "UP" then
                icon:SetPoint("BOTTOM", container, "BOTTOM", 0, 0)
            elseif growDir == "DOWN" then
                icon:SetPoint("TOP", container, "TOP", 0, 0)
            end
        else
            -- Other icons positioned relative to previous icon
            local prevIcon = self.partyFrameIcons[unit].icons[i-1]
            
            if growDir == "RIGHT" then
                icon:SetPoint("LEFT", prevIcon, "RIGHT", spacing, 0)
            elseif growDir == "LEFT" then
                icon:SetPoint("RIGHT", prevIcon, "LEFT", -spacing, 0)
            elseif growDir == "UP" then
                icon:SetPoint("BOTTOM", prevIcon, "TOP", 0, spacing)
            elseif growDir == "DOWN" then
                icon:SetPoint("TOP", prevIcon, "BOTTOM", 0, -spacing)
            end
        end
    end
end

-- Apply theme to party frame icons
function OmniCD:ApplyThemeToPartyFrames()
    -- Apply theme to all unit icons
    for unit, _ in pairs(self.partyFrameIcons or {}) do
        self:ApplyThemeToUnitIcons(unit)
    end
end

-- Apply theme to a specific unit's icons
function OmniCD:ApplyThemeToUnitIcons(unit)
    if not self.partyFrameIcons[unit] or not self.partyFrameIcons[unit].icons then return end
    
    local currentTheme = VUI:GetTheme()
    
    for _, icon in ipairs(self.partyFrameIcons[unit].icons) do
        -- Apply theme colors to border
        if icon.border then
            local borderColor = self:GetThemeElementColor("border")
            if borderColor then
                icon.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1.0)
            end
        end
        
        -- Theme the ready pulse
        if icon.readyPulse then
            local pulseColor = self:GetThemeElementColor("highlight")
            if pulseColor then
                icon.readyPulse:SetVertexColor(pulseColor.r, pulseColor.g, pulseColor.b, pulseColor.a or 0.7)
            end
        end
        
        -- Theme the cooldown styling
        if icon.cooldown then
            -- Theme-specific coloring would happen here
            -- Current WoW API doesn't allow easy cooldown styling changes
        end
        
        -- Theme the timer text
        if icon.timer then
            local textColor = self:GetThemeElementColor("text")
            if textColor then
                icon.timer:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1.0)
            end
            
            -- Apply the theme font
            local font, size, flags = self:GetThemeFont("regular")
            if font then
                icon.timer:SetFont(font, size or 10, flags or "OUTLINE")
            end
        end
    end
end

-- Update cooldowns for all party frames
function OmniCD:UpdateAllPartyFrameCooldowns()
    if not self.db.partyFrames.enabled then return end
    
    -- Update each unit's cooldowns
    for unit, _ in pairs(self.partyFrames or {}) do
        self:UpdateUnitCooldowns(unit)
    end
end

-- Update cooldowns for a specific unit
function OmniCD:UpdateUnitCooldowns(unit)
    if not unit or not self.partyFrameIcons[unit] or not self.partyFrameIcons[unit].icons then return end
    
    -- Get the unit's GUID
    local guid = UnitGUID(unit)
    if not guid then return end
    
    -- Get active cooldowns for this unit
    local unitCooldowns = self.activeCooldowns and self.activeCooldowns[guid] or {}
    
    -- Filter cooldowns based on settings
    local filteredCooldowns = self:FilterCooldownsBySettings(unitCooldowns)
    
    -- Update icons with cooldown info
    self:UpdateUnitCooldownIcons(unit, filteredCooldowns)
end

-- Filter cooldowns based on party frame settings
function OmniCD:FilterCooldownsBySettings(cooldowns)
    if not cooldowns or #cooldowns == 0 then return {} end
    
    local filtered = {}
    local config = self.db.partyFrames
    
    -- Check if we should filter by type
    local filterByType = config.filterByType
    
    for _, cooldown in ipairs(cooldowns) do
        local spellID = cooldown.spellID
        local shouldInclude = true
        
        -- Check spell category against filters
        if filterByType then
            local group = self:GetSpellGroup(spellID)
            if group then
                local groupName = group.name:lower()
                
                if groupName:find("interrupt") and not filterByType.interrupt then
                    shouldInclude = false
                elseif groupName:find("defensive") and not filterByType.defensive then
                    shouldInclude = false
                elseif groupName:find("offensive") and not filterByType.offensive then
                    shouldInclude = false
                elseif (groupName:find("utility") or groupName:find("other")) and not filterByType.utility then
                    shouldInclude = false
                end
            end
        end
        
        if shouldInclude then
            table.insert(filtered, cooldown)
        end
    end
    
    -- Sort by priority
    table.sort(filtered, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    
    return filtered
end

-- Update a unit's cooldown icons with current cooldowns
function OmniCD:UpdateUnitCooldownIcons(unit, cooldowns)
    if not unit or not self.partyFrameIcons[unit] or not self.partyFrameIcons[unit].icons then return end
    
    local icons = self.partyFrameIcons[unit].icons
    local maxIcons = self.db.partyFrames.maxIcons
    local now = GetTime()
    
    -- Hide all icons first
    for i = 1, maxIcons do
        if icons[i] then
            icons[i]:Hide()
            icons[i].spellID = nil
            icons[i].cooldownInfo = nil
        end
    end
    
    -- Apply cooldowns to icons
    for i = 1, math.min(#cooldowns, maxIcons) do
        local cooldown = cooldowns[i]
        local icon = icons[i]
        
        if cooldown and icon then
            -- Set the spell texture
            local spellTexture = select(3, GetSpellInfo(cooldown.spellID))
            if spellTexture then
                icon.texture:SetTexture(spellTexture)
            end
            
            -- Calculate remaining time
            local remaining = cooldown.endTime - now
            if remaining <= 0 then
                -- Ready state
                icon.cooldown:Clear()
                icon.timer:SetText("")
                
                -- Show ready pulse effect
                if self:GetThemeEffectSetting("readyPulse") then
                    icon.readyPulse:SetAlpha(0.7)
                    
                    -- Cancel any existing animations
                    if icon.pulseAnim then
                        icon.pulseAnim:Stop()
                    end
                    
                    -- Create pulse animation
                    icon.pulseAnim = icon.readyPulse:CreateAnimationGroup()
                    local fade = icon.pulseAnim:CreateAnimation("Alpha")
                    fade:SetFromAlpha(0.7)
                    fade:SetToAlpha(0)
                    fade:SetDuration(1)
                    fade:SetSmoothing("OUT")
                    
                    -- Make it repeat
                    icon.pulseAnim:SetLooping("REPEAT")
                    icon.pulseAnim:Play()
                end
            else
                -- On cooldown state
                icon.cooldown:SetCooldown(cooldown.startTime, cooldown.duration)
                
                -- Format and show timer text
                if remaining <= 60 then
                    -- Less than a minute, show seconds
                    icon.timer:SetText(math.floor(remaining))
                else
                    -- More than a minute, show minutes:seconds
                    local minutes = math.floor(remaining / 60)
                    local seconds = math.floor(remaining % 60)
                    icon.timer:SetText(string.format("%d:%02d", minutes, seconds))
                end
                
                -- Hide pulse if it was showing
                icon.readyPulse:SetAlpha(0)
                if icon.pulseAnim then
                    icon.pulseAnim:Stop()
                end
            end
            
            -- Store cooldown info
            icon.spellID = cooldown.spellID
            icon.cooldownInfo = cooldown
            
            -- Show the icon
            icon:Show()
        end
    end
    
    -- Apply theme to the icons
    self:ApplyThemeToUnitIcons(unit)
end

-- Update a specific party frame
function OmniCD:UpdatePartyFrame(unit)
    if not unit or not self.db.partyFrames.enabled then return end
    
    -- Set up the frame again
    if unit == "player" then
        self:SetupUnitFrame("player", PlayerFrame)
    elseif unit:find("party") then
        local index = unit:match("party(%d+)")
        if index then
            local frame = _G["PartyMemberFrame" .. index]
            if frame and frame:IsShown() then
                self:SetupUnitFrame(unit, frame)
            end
        end
    end
    
    -- Update cooldowns for this unit
    self:UpdateUnitCooldowns(unit)
end

-- Clear all party frames
function OmniCD:ClearPartyFrames()
    -- Hide and remove all icons
    for unit, data in pairs(self.partyFrameIcons or {}) do
        if data.container then
            data.container:Hide()
        end
        
        if data.icons then
            for _, icon in ipairs(data.icons) do
                icon:Hide()
            end
        end
    end
    
    -- Reset our tables
    self.partyFrames = {}
    self.partyFrameIcons = {}
end

-- Show all party frame icons
function OmniCD:ShowPartyFrameIcons()
    for unit, data in pairs(self.partyFrameIcons or {}) do
        if data.container then
            data.container:Show()
        end
    end
end

-- Hide all party frame icons
function OmniCD:HidePartyFrameIcons()
    for unit, data in pairs(self.partyFrameIcons or {}) do
        if data.container then
            data.container:Hide()
        end
    end
end

-- Debug function (disabled in production)
function OmniCD:Debug(...)
    -- Debug output has been disabled for production release
    return
end

-- Get theme element color 
function OmniCD:GetThemeElementColor(elementType)
    local theme = VUI:GetTheme()
    if not theme or not elementType then return nil end
    
    local colors = {
        border = {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        background = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
        highlight = {r = 1.0, g = 0.8, b = 0.0, a = 0.7},
        text = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
        ready = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
    }
    
    -- Apply theme-specific colors
    if theme == "phoenixflame" then
        colors.border = {r = 0.9, g = 0.3, b = 0.05, a = 1.0}
        colors.highlight = {r = 1.0, g = 0.64, b = 0.1, a = 0.7}
    elseif theme == "thunderstorm" then
        colors.border = {r = 0.05, g = 0.62, b = 0.9, a = 1.0}
        colors.highlight = {r = 0.4, g = 0.8, b = 1.0, a = 0.7}
    elseif theme == "arcanemystic" then
        colors.border = {r = 0.62, g = 0.05, b = 0.9, a = 1.0}
        colors.highlight = {r = 1.0, g = 0.4, b = 1.0, a = 0.7}
    elseif theme == "felenergy" then
        colors.border = {r = 0.1, g = 1.0, b = 0.1, a = 1.0}
        colors.highlight = {r = 0.75, g = 1.0, b = 0.0, a = 0.7}
    end
    
    return colors[elementType]
end

-- Get theme font
function OmniCD:GetThemeFont(fontType, size)
    local defaultFont = "Fonts\\FRIZQT__.TTF"
    local defaultSize = size or 10
    local defaultFlags = "OUTLINE"
    
    -- In a production version, we would have theme-specific fonts
    return defaultFont, defaultSize, defaultFlags
end

-- Get theme effect setting
function OmniCD:GetThemeEffectSetting(effectName)
    -- Default settings
    local defaults = {
        readyPulse = true,
        glowEffect = true,
        coloredBorders = true
    }
    
    -- Override with user settings if they exist
    if self.db.effects and self.db.effects[effectName] ~= nil then
        return self.db.effects[effectName]
    end
    
    return defaults[effectName]
end

-- Hook this into the main module initialization
local originalSetupModule = OmniCD.SetupModule
OmniCD.SetupModule = function(self)
    originalSetupModule(self)
    
    -- Initialize party frames integration
    self:InitializePartyFrames()
end

-- Hook into cooldown updates
local originalUpdateCooldownDisplay = OmniCD.UpdateCooldownDisplay
OmniCD.UpdateCooldownDisplay = function(self)
    originalUpdateCooldownDisplay(self)
    
    -- Update party frame cooldowns as well
    self:UpdateAllPartyFrameCooldowns()
end