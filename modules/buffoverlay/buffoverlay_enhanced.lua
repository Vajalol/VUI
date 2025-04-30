-------------------------------------------------------------------------------
-- Title: VUI BuffOverlay Enhanced Implementation
-- Author: VortexQ8
-- Enhanced implementation of the BuffOverlay module with advanced features
-------------------------------------------------------------------------------

local _, VUI = ...
local BuffOverlay = VUI.modules.buffoverlay

if not BuffOverlay then return end

-- Performance optimization
local GetTime = GetTime
local UnitAura = UnitAura
local UnitExists = UnitExists
local ceil = math.ceil
local floor = math.floor
local min = math.min
local max = math.max
local format = string.format

-- Initialize defaults if not set
local defaults = {
    enableEnhancedDisplay = true,
    maxAurasPerUnit = 20,    -- Maximum number of auras to show per unit
    showCooldownSpiral = true,
    showCooldownNumbers = true,
    enhancedTimerFormat = true,
    showDecimalSeconds = true,
    hideIconBorders = false,
    enableAnimations = true,
    growDirection = {
        player = "RIGHT",
        target = "LEFT",
        focus = "DOWN",
        pet = "UP"
    },
    unitSpacing = 30,        -- Spacing between different units
    iconSpacing = 2,         -- Spacing between icons
    iconArrangement = "grid", -- "grid" or "line"
    groupAurasByType = true, -- Group buffs and debuffs
    maxIconsPerRow = 8,      -- Only applies to grid arrangement
    showPlayerAuras = true,
    showTargetAuras = true,
    showFocusAuras = true,
    showPetAuras = true,
    unitFrames = {
        player = {
            point = "CENTER",
            relativeTo = "UIParent",
            relativePoint = "CENTER",
            xOffset = -200,
            yOffset = 150,
            scale = 1.0
        },
        target = {
            point = "CENTER",
            relativeTo = "UIParent",
            relativePoint = "CENTER",
            xOffset = 200,
            yOffset = 150,
            scale = 1.0
        },
        focus = {
            point = "CENTER",
            relativeTo = "UIParent",
            relativePoint = "CENTER",
            xOffset = 0,
            yOffset = 250,
            scale = 1.0
        },
        pet = {
            point = "CENTER",
            relativeTo = "UIParent",
            relativePoint = "CENTER",
            xOffset = -250,
            yOffset = 0,
            scale = 0.8
        }
    }
}

-- Apply defaults to settings if needed
local function ApplyDefaults()
    if not VUI.db.profile.modules.buffoverlay.enhancedDisplay then
        VUI.db.profile.modules.buffoverlay.enhancedDisplay = defaults.enableEnhancedDisplay
    end
    
    if not VUI.db.profile.modules.buffoverlay.maxAurasPerUnit then
        VUI.db.profile.modules.buffoverlay.maxAurasPerUnit = defaults.maxAurasPerUnit
    end
    
    if not VUI.db.profile.modules.buffoverlay.showCooldownSpiral then
        VUI.db.profile.modules.buffoverlay.showCooldownSpiral = defaults.showCooldownSpiral
    end
    
    if not VUI.db.profile.modules.buffoverlay.showCooldownNumbers then
        VUI.db.profile.modules.buffoverlay.showCooldownNumbers = defaults.showCooldownNumbers
    end
    
    if not VUI.db.profile.modules.buffoverlay.enhancedTimerFormat then
        VUI.db.profile.modules.buffoverlay.enhancedTimerFormat = defaults.enhancedTimerFormat
    end
    
    if not VUI.db.profile.modules.buffoverlay.showDecimalSeconds then
        VUI.db.profile.modules.buffoverlay.showDecimalSeconds = defaults.showDecimalSeconds
    end
    
    if not VUI.db.profile.modules.buffoverlay.hideIconBorders then
        VUI.db.profile.modules.buffoverlay.hideIconBorders = defaults.hideIconBorders
    end
    
    if not VUI.db.profile.modules.buffoverlay.enableAnimations then
        VUI.db.profile.modules.buffoverlay.enableAnimations = defaults.enableAnimations
    end
    
    if not VUI.db.profile.modules.buffoverlay.growDirection then
        VUI.db.profile.modules.buffoverlay.growDirection = defaults.growDirection
    end
    
    if not VUI.db.profile.modules.buffoverlay.unitSpacing then
        VUI.db.profile.modules.buffoverlay.unitSpacing = defaults.unitSpacing
    end
    
    if not VUI.db.profile.modules.buffoverlay.iconSpacing then
        VUI.db.profile.modules.buffoverlay.iconSpacing = defaults.iconSpacing
    end
    
    if not VUI.db.profile.modules.buffoverlay.iconArrangement then
        VUI.db.profile.modules.buffoverlay.iconArrangement = defaults.iconArrangement
    end
    
    if not VUI.db.profile.modules.buffoverlay.groupAurasByType then
        VUI.db.profile.modules.buffoverlay.groupAurasByType = defaults.groupAurasByType
    end
    
    if not VUI.db.profile.modules.buffoverlay.maxIconsPerRow then
        VUI.db.profile.modules.buffoverlay.maxIconsPerRow = defaults.maxIconsPerRow
    end
    
    if not VUI.db.profile.modules.buffoverlay.showPlayerAuras then
        VUI.db.profile.modules.buffoverlay.showPlayerAuras = defaults.showPlayerAuras
    end
    
    if not VUI.db.profile.modules.buffoverlay.showTargetAuras then
        VUI.db.profile.modules.buffoverlay.showTargetAuras = defaults.showTargetAuras
    end
    
    if not VUI.db.profile.modules.buffoverlay.showFocusAuras then
        VUI.db.profile.modules.buffoverlay.showFocusAuras = defaults.showFocusAuras
    end
    
    if not VUI.db.profile.modules.buffoverlay.showPetAuras then
        VUI.db.profile.modules.buffoverlay.showPetAuras = defaults.showPetAuras
    end
    
    if not VUI.db.profile.modules.buffoverlay.unitFrames then
        VUI.db.profile.modules.buffoverlay.unitFrames = defaults.unitFrames
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

-- Format time with color coding based on remaining time
local function FormatTimeWithColor(timeLeft, showDecimal, duration)
    local colorCode
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

-- Create unit buff container
function BuffOverlay:CreateUnitContainer(unitID)
    if not self.unitContainers then
        self.unitContainers = {}
    end
    
    -- Skip if already created
    if self.unitContainers[unitID] then
        return self.unitContainers[unitID]
    end
    
    -- Create container frame
    local container = CreateFrame("Frame", "VUIBuffOverlay_" .. unitID, UIParent)
    
    -- Position based on settings
    local unitSettings = VUI.db.profile.modules.buffoverlay.unitFrames[unitID]
    if unitSettings then
        container:SetPoint(
            unitSettings.point,
            unitSettings.relativeTo,
            unitSettings.relativePoint,
            unitSettings.xOffset,
            unitSettings.yOffset
        )
        container:SetScale(unitSettings.scale or 1.0)
    else
        -- Default position if settings not found
        container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        container:SetScale(1.0)
    end
    
    -- Set size (will be adjusted based on content)
    container:SetSize(32, 32)
    
    -- Make movable in config mode
    container:SetMovable(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    
    container:SetScript("OnDragStart", function(frame)
        if not VUI.configMode then return end
        frame:StartMoving()
    end)
    
    container:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        
        -- Save position
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
        
        -- Create unit settings if needed
        if not VUI.db.profile.modules.buffoverlay.unitFrames[unitID] then
            VUI.db.profile.modules.buffoverlay.unitFrames[unitID] = {}
        end
        
        VUI.db.profile.modules.buffoverlay.unitFrames[unitID].point = point
        VUI.db.profile.modules.buffoverlay.unitFrames[unitID].relativeTo = relativeTo and relativeTo:GetName() or "UIParent"
        VUI.db.profile.modules.buffoverlay.unitFrames[unitID].relativePoint = relativePoint
        VUI.db.profile.modules.buffoverlay.unitFrames[unitID].xOffset = xOffset
        VUI.db.profile.modules.buffoverlay.unitFrames[unitID].yOffset = yOffset
    end)
    
    -- Create unit label
    container.unitLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    container.unitLabel:SetPoint("BOTTOM", container, "TOP", 0, 2)
    container.unitLabel:SetText(unitID:upper())
    container.unitLabel:Hide() -- Only show in config mode
    
    -- Config mode indicator backdrop
    container.configIndicator = container:CreateTexture(nil, "BACKGROUND")
    container.configIndicator:SetAllPoints()
    container.configIndicator:SetColorTexture(0.2, 0.4, 0.8, 0.3)
    container.configIndicator:Hide() -- Only show in config mode
    
    -- Store buffs and debuffs for this unit
    container.buffFrames = {}
    container.debuffFrames = {}
    
    -- Track visible auras
    container.visibleBuffs = {}
    container.visibleDebuffs = {}
    
    -- Store in unit containers
    self.unitContainers[unitID] = container
    
    return container
end

-- Get or create aura frame
function BuffOverlay:GetAuraFrame(unitID, index, isDebuff)
    local container = self:CreateUnitContainer(unitID)
    local frameTable = isDebuff and container.debuffFrames or container.buffFrames
    
    -- Create if it doesn't exist
    if not frameTable[index] then
        local frame = CreateFrame("Frame", nil, container)
        local iconSize = VUI.db.profile.modules.buffoverlay.size or 32
        frame:SetSize(iconSize, iconSize)
        
        -- Icon texture
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetAllPoints()
        
        -- Only trim borders if the setting is enabled
        if VUI.db.profile.modules.buffoverlay.hideIconBorders then
            frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim borders
        else
            frame.icon:SetTexCoord(0, 1, 0, 1) -- Don't trim
        end
        
        -- Theme-specific border
        frame.border = frame:CreateTexture(nil, "BORDER")
        frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
        frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
        
        -- Glow overlay for theme effects
        frame.glow = frame:CreateTexture(nil, "OVERLAY")
        frame.glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
        frame.glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
        frame.glow:SetBlendMode("ADD")
        frame.glow:SetAlpha(0)
        
        -- Theme-specific overlay texture
        frame.themeOverlay = frame:CreateTexture(nil, "OVERLAY")
        frame.themeOverlay:SetAllPoints(frame.icon)
        frame.themeOverlay:SetBlendMode("ADD")
        frame.themeOverlay:SetAlpha(0)
        
        -- Cooldown swipe
        frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        frame.cooldown:SetAllPoints()
        frame.cooldown:SetReverse(false)
        frame.cooldown:SetHideCountdownNumbers(not VUI.db.profile.modules.buffoverlay.showCooldownNumbers)
        frame.cooldown:SetDrawEdge(false)
        frame.cooldown:SetDrawSwipe(VUI.db.profile.modules.buffoverlay.showCooldownSpiral)
        
        -- Stack count text
        frame.count = frame:CreateFontString(nil, "OVERLAY")
        local font = VUI:GetFont("expressway")
        local fontSize = max(floor(iconSize / 3), 8)
        frame.count:SetFont(font, fontSize, "OUTLINE")
        frame.count:SetPoint("BOTTOMRIGHT", -1, 1)
        
        -- Timer text
        frame.timer = frame:CreateFontString(nil, "OVERLAY")
        fontSize = max(floor(iconSize / 3), 8)
        frame.timer:SetFont(font, fontSize, "OUTLINE")
        frame.timer:SetPoint("TOP", frame, "BOTTOM", 0, -1)
        
        -- Tooltip support
        frame:SetScript("OnEnter", function(self)
            if not VUI.db.profile.modules.buffoverlay.showTooltip then return end
            
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            if isDebuff then
                GameTooltip:SetUnitDebuff(unitID, self.auraIndex, "HARMFUL")
            else
                GameTooltip:SetUnitBuff(unitID, self.auraIndex, "HELPFUL")
            end
            GameTooltip:Show()
            
            -- Start hover animation if enabled
            if VUI.db.profile.modules.buffoverlay.enableAnimations and self.animations and self.animations.hoverAnimation then
                self.animations.hoverAnimation:Play()
            end
        end)
        
        frame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            
            -- Stop hover animation
            if self.animations and self.animations.hoverAnimation and self.animations.hoverAnimation:IsPlaying() then
                self.animations.hoverAnimation:Stop()
                self.glow:SetAlpha(0)
            end
        end)
        
        -- Store in frame table
        frameTable[index] = frame
        
        -- Apply theme settings
        self:ApplyThemeToBuffFrame(frame)
    end
    
    return frameTable[index]
end

-- Update aura display for a specific unit
function BuffOverlay:UpdateUnitAuras(unitID)
    if not unitID or not UnitExists(unitID) then return end
    
    -- Check if we should show auras for this unit
    local showAurasForUnit = false
    if unitID == "player" and VUI.db.profile.modules.buffoverlay.showPlayerAuras then
        showAurasForUnit = true
    elseif unitID == "target" and VUI.db.profile.modules.buffoverlay.showTargetAuras then
        showAurasForUnit = true
    elseif unitID == "focus" and VUI.db.profile.modules.buffoverlay.showFocusAuras then
        showAurasForUnit = true
    elseif unitID == "pet" and VUI.db.profile.modules.buffoverlay.showPetAuras then
        showAurasForUnit = true
    end
    
    if not showAurasForUnit then
        -- Hide container if not showing auras for this unit
        if self.unitContainers and self.unitContainers[unitID] then
            self.unitContainers[unitID]:Hide()
        end
        return
    end
    
    -- Get unit container
    local container = self:CreateUnitContainer(unitID)
    container:Show()
    
    -- Get sorted auras for this unit
    local sortedAuras = self:GetSortedAuras(unitID)
    
    -- Cache previous visible auras for change detection
    local oldVisibleBuffs = container.visibleBuffs
    local oldVisibleDebuffs = container.visibleDebuffs
    
    -- Reset visible auras
    container.visibleBuffs = {}
    container.visibleDebuffs = {}
    
    -- Count buffs and debuffs for positioning
    local buffCount = 0
    local debuffCount = 0
    
    -- Max auras to show per unit
    local maxAuras = VUI.db.profile.modules.buffoverlay.maxAurasPerUnit or 20
    local maxBuffs = floor(maxAuras / 2)
    local maxDebuffs = maxAuras - maxBuffs
    
    -- Process sorted auras
    for i, aura in ipairs(sortedAuras) do
        -- Skip after max auras
        if (aura.isDebuff and debuffCount >= maxDebuffs) or 
           (not aura.isDebuff and buffCount >= maxBuffs) then
            break
        end
        
        -- Get appropriate frame
        local frameIndex = aura.isDebuff and debuffCount + 1 or buffCount + 1
        local frame = self:GetAuraFrame(unitID, frameIndex, aura.isDebuff)
        
        -- Update aura display
        self:UpdateAuraFrame(frame, aura, unitID)
        
        -- Store in visible auras
        if aura.isDebuff then
            container.visibleDebuffs[aura.auraID] = aura
            debuffCount = debuffCount + 1
        else
            container.visibleBuffs[aura.auraID] = aura
            buffCount = buffCount + 1
        end
    end
    
    -- Hide unused frames
    for i = buffCount + 1, #container.buffFrames do
        container.buffFrames[i]:Hide()
    end
    
    for i = debuffCount + 1, #container.debuffFrames do
        container.debuffFrames[i]:Hide()
    end
    
    -- Position visible auras
    self:PositionUnitAuras(container, buffCount, debuffCount)
    
    -- Check for aura changes
    self:ProcessAuraChanges(unitID, oldVisibleBuffs, container.visibleBuffs, false)
    self:ProcessAuraChanges(unitID, oldVisibleDebuffs, container.visibleDebuffs, true)
    
    -- Update container size based on content
    self:UpdateContainerSize(container, buffCount, debuffCount)
end

-- Update an aura frame with aura data
function BuffOverlay:UpdateAuraFrame(frame, aura, unitID)
    -- Set icon
    frame.icon:SetTexture(aura.icon)
    
    -- Store aura information
    frame.auraID = aura.auraID
    frame.auraIndex = aura.index
    frame.category = aura.category
    frame.priority = aura.priority
    frame.unitID = unitID
    frame:Show()
    
    -- Set count text
    if aura.count and aura.count > 1 then
        frame.count:SetText(aura.count)
        frame.count:Show()
    else
        frame.count:SetText("")
        frame.count:Hide()
    end
    
    -- Set cooldown
    if aura.duration and aura.duration > 0 and aura.expirationTime and aura.expirationTime > 0 then
        -- Start cooldown swipe if enabled
        if VUI.db.profile.modules.buffoverlay.showCooldownSpiral then
            frame.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
            frame.cooldown:Show()
        else
            frame.cooldown:Hide()
        end
        
        -- Update timer
        frame.timeLeft = aura.expirationTime - GetTime()
        frame.duration = aura.duration
        
        -- Use OnUpdate to update timer display
        frame:SetScript("OnUpdate", function(self, elapsed)
            self.updateThrottle = (self.updateThrottle or 0) + elapsed
            if self.updateThrottle < 0.1 then return end
            self.updateThrottle = 0
            
            -- Update timer
            self.timeLeft = aura.expirationTime - GetTime()
            
            -- Format time based on settings
            local timerText = ""
            if VUI.db.profile.modules.buffoverlay.enhancedTimerFormat then
                local showDecimal = VUI.db.profile.modules.buffoverlay.showDecimalSeconds
                timerText = FormatTimeWithColor(self.timeLeft, showDecimal, aura.duration)
            else
                timerText = FormatTimeEnhanced(self.timeLeft, VUI.db.profile.modules.buffoverlay.showDecimalSeconds)
            end
            
            -- Update timer text
            if timerText ~= "" then
                self.timer:SetText(timerText)
                self.timer:Show()
            else
                self.timer:Hide()
            end
            
            -- If aura has expired, trigger an update
            if self.timeLeft <= 0 then
                self:Hide() -- Hide immediately
                BuffOverlay:UpdateUnitAuras(self.unitID) -- Refresh unit auras
            end
        end)
        
        frame.timer:Show()
    else
        -- No duration, hide cooldown and timer
        frame.cooldown:Hide()
        frame.timer:Hide()
        frame:SetScript("OnUpdate", nil)
    end
    
    -- Apply border based on category
    local category = aura.category or "STANDARD"
    local border = self:GetThemeBorderTexture(category)
    if border then
        frame.border:SetTexture(border)
        frame.border:Show()
    else
        frame.border:Hide()
    end
    
    -- Apply color based on category
    local color = self:GetCategoryColor(category)
    if color then
        frame.border:SetVertexColor(color.r, color.g, color.b)
    end
    
    -- Start category-specific animation if enabled
    if VUI.db.profile.modules.buffoverlay.enableAnimations then
        self:StartCategoryAnimation(frame, category)
    end
    
    -- Play notification sound if appropriate
    self:ProcessAuraNotification(unitID, aura.auraID, category, aura.isDebuff, true)
end

-- Position auras for a unit
function BuffOverlay:PositionUnitAuras(container, buffCount, debuffCount)
    local iconSize = VUI.db.profile.modules.buffoverlay.size or 32
    local spacing = VUI.db.profile.modules.buffoverlay.iconSpacing or 2
    local arrangement = VUI.db.profile.modules.buffoverlay.iconArrangement or "grid"
    local maxIconsPerRow = VUI.db.profile.modules.buffoverlay.maxIconsPerRow or 8
    local growDirection = VUI.db.profile.modules.buffoverlay.growDirection[container.unitID] or "RIGHT"
    
    -- Position buffs
    if buffCount > 0 then
        if arrangement == "grid" then
            -- Grid arrangement
            local rows = ceil(buffCount / maxIconsPerRow)
            local cols = min(buffCount, maxIconsPerRow)
            
            for i = 1, buffCount do
                local frame = container.buffFrames[i]
                local row = ceil(i / maxIconsPerRow) - 1
                local col = (i - 1) % maxIconsPerRow
                
                frame:ClearAllPoints()
                
                if i == 1 then
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
                else
                    local xOffset = col * (iconSize + spacing)
                    local yOffset = -row * (iconSize + spacing)
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", xOffset, yOffset)
                end
            end
        else
            -- Line arrangement based on growth direction
            for i = 1, buffCount do
                local frame = container.buffFrames[i]
                frame:ClearAllPoints()
                
                if i == 1 then
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
                else
                    local prevFrame = container.buffFrames[i-1]
                    
                    if growDirection == "RIGHT" then
                        frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
                    elseif growDirection == "LEFT" then
                        frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0)
                    elseif growDirection == "DOWN" then
                        frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
                    elseif growDirection == "UP" then
                        frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing)
                    end
                end
            end
        end
    end
    
    -- Position debuffs
    if debuffCount > 0 then
        if arrangement == "grid" then
            -- Grid arrangement
            local rows = ceil(debuffCount / maxIconsPerRow)
            local cols = min(debuffCount, maxIconsPerRow)
            
            -- Calculate offset for debuffs based on buffs
            local buffRows = ceil(buffCount / maxIconsPerRow)
            local topOffset = buffRows * (iconSize + spacing) + 10 -- Extra spacing between buffs and debuffs
            
            for i = 1, debuffCount do
                local frame = container.debuffFrames[i]
                local row = ceil(i / maxIconsPerRow) - 1
                local col = (i - 1) % maxIconsPerRow
                
                frame:ClearAllPoints()
                
                if i == 1 then
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -topOffset)
                else
                    local xOffset = col * (iconSize + spacing)
                    local yOffset = -topOffset - (row * (iconSize + spacing))
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", xOffset, yOffset)
                end
            end
        else
            -- Line arrangement
            -- Calculate offset for debuffs
            local xOffset, yOffset = 0, 0
            
            if growDirection == "RIGHT" or growDirection == "LEFT" then
                -- For horizontal growth, place debuffs below buffs
                yOffset = -(iconSize + 10) -- 10px spacing between buffs and debuffs
            else
                -- For vertical growth, place debuffs next to buffs
                xOffset = iconSize + 10
            end
            
            for i = 1, debuffCount do
                local frame = container.debuffFrames[i]
                frame:ClearAllPoints()
                
                if i == 1 then
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", xOffset, yOffset)
                else
                    local prevFrame = container.debuffFrames[i-1]
                    
                    if growDirection == "RIGHT" then
                        frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
                    elseif growDirection == "LEFT" then
                        frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0)
                    elseif growDirection == "DOWN" then
                        frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
                    elseif growDirection == "UP" then
                        frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing)
                    end
                end
            end
        end
    end
end

-- Update container size based on content
function BuffOverlay:UpdateContainerSize(container, buffCount, debuffCount)
    local iconSize = VUI.db.profile.modules.buffoverlay.size or 32
    local spacing = VUI.db.profile.modules.buffoverlay.iconSpacing or 2
    local arrangement = VUI.db.profile.modules.buffoverlay.iconArrangement or "grid"
    local maxIconsPerRow = VUI.db.profile.modules.buffoverlay.maxIconsPerRow or 8
    
    local width, height = iconSize, iconSize
    
    if arrangement == "grid" then
        -- Calculate size for grid arrangement
        local buffRows = ceil(buffCount / maxIconsPerRow)
        local buffCols = min(buffCount, maxIconsPerRow)
        
        local debuffRows = ceil(debuffCount / maxIconsPerRow)
        local debuffCols = min(debuffCount, maxIconsPerRow)
        
        -- Calculate max width
        width = max(
            buffCount > 0 and (buffCols * iconSize + (buffCols - 1) * spacing) or 0,
            debuffCount > 0 and (debuffCols * iconSize + (debuffCols - 1) * spacing) or 0,
            iconSize -- Minimum size
        )
        
        -- Calculate total height
        local totalRows = buffRows + debuffRows
        if totalRows > 0 then
            height = (totalRows * iconSize) + ((totalRows - 1) * spacing)
            
            -- If both buffs and debuffs exist, add extra spacing between them
            if buffCount > 0 and debuffCount > 0 then
                height = height + 10
            end
        end
    else
        -- Calculate size for line arrangement
        local growDirection = VUI.db.profile.modules.buffoverlay.growDirection[container.unitID] or "RIGHT"
        
        if growDirection == "RIGHT" or growDirection == "LEFT" then
            -- Horizontal growth
            if buffCount > 0 then
                width = max(width, buffCount * iconSize + (buffCount - 1) * spacing)
            end
            
            if debuffCount > 0 then
                width = max(width, debuffCount * iconSize + (debuffCount - 1) * spacing)
            end
            
            height = iconSize
            
            -- If both buffs and debuffs exist, increase height
            if buffCount > 0 and debuffCount > 0 then
                height = (iconSize * 2) + 10
            end
        else
            -- Vertical growth
            height = 0
            
            if buffCount > 0 then
                height = height + (buffCount * iconSize) + ((buffCount - 1) * spacing)
            end
            
            if debuffCount > 0 then
                height = height + (debuffCount * iconSize) + ((debuffCount - 1) * spacing)
            end
            
            width = iconSize
            
            -- If both buffs and debuffs exist, increase width
            if buffCount > 0 and debuffCount > 0 then
                width = (iconSize * 2) + 10
            end
        end
    end
    
    -- Set container size
    container:SetSize(max(width, 32), max(height, 32))
end

-- Process aura changes for notifications
function BuffOverlay:ProcessAuraChanges(unitID, oldAuras, newAuras, isDebuff)
    -- Check if notifications are enabled
    if not VUI.db.profile.modules.buffoverlay.enableNotifications then return end
    
    -- Process added auras
    for auraID, aura in pairs(newAuras) do
        if not oldAuras[auraID] then
            -- New aura gained
            local category = self:GetAuraCategory(unitID, auraID, isDebuff)
            self:ProcessAuraNotification(unitID, auraID, category, isDebuff, true)
        end
    end
    
    -- Process removed auras
    for auraID, aura in pairs(oldAuras) do
        if not newAuras[auraID] then
            -- Aura faded
            local category = self:GetAuraCategory(unitID, auraID, isDebuff)
            self:ProcessAuraNotification(unitID, auraID, category, isDebuff, false)
        end
    end
end

-- Update all units' auras
function BuffOverlay:UpdateAllAuras()
    self:UpdateUnitAuras("player")
    
    if UnitExists("target") then
        self:UpdateUnitAuras("target")
    elseif self.unitContainers and self.unitContainers["target"] then
        self.unitContainers["target"]:Hide()
    end
    
    if UnitExists("focus") then
        self:UpdateUnitAuras("focus")
    elseif self.unitContainers and self.unitContainers["focus"] then
        self.unitContainers["focus"]:Hide()
    end
    
    if UnitExists("pet") then
        self:UpdateUnitAuras("pet")
    elseif self.unitContainers and self.unitContainers["pet"] then
        self.unitContainers["pet"]:Hide()
    end
end

-- Start the enhanced monitoring
function BuffOverlay:StartEnhancedDisplay()
    -- Create event frame if needed
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end
    
    -- Register for events
    self.eventFrame:RegisterEvent("UNIT_AURA")
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self.eventFrame:RegisterEvent("UNIT_PET")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_AURA" then
            local unit = ...
            self:UpdateUnitAuras(unit)
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:UpdateUnitAuras("target")
        elseif event == "PLAYER_FOCUS_CHANGED" then
            self:UpdateUnitAuras("focus")
        elseif event == "UNIT_PET" then
            local unit = ...
            if unit == "player" then
                self:UpdateUnitAuras("pet")
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UpdateAllAuras()
        end
    end)
    
    -- Initial update
    self:UpdateAllAuras()
end

-- Stop enhanced monitoring
function BuffOverlay:StopEnhancedDisplay()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
    end
    
    -- Hide all containers
    if self.unitContainers then
        for unitID, container in pairs(self.unitContainers) do
            container:Hide()
        end
    end
end

-- Toggle config mode display
function BuffOverlay:ToggleConfigMode(enabled)
    if not self.unitContainers then return end
    
    for unitID, container in pairs(self.unitContainers) do
        if enabled then
            container.unitLabel:Show()
            container.configIndicator:Show()
        else
            container.unitLabel:Hide()
            container.configIndicator:Hide()
        end
    end
end

-- Initialize the enhanced display
function BuffOverlay:InitializeEnhancedDisplay()
    -- Apply defaults if needed
    ApplyDefaults()
    
    -- Start enhanced display if enabled
    if VUI.db.profile.modules.buffoverlay.enhancedDisplay then
        self:StartEnhancedDisplay()
    end
    
    -- Register for theme changes
    VUI.RegisterCallback(self, "THEME_CHANGED", function()
        -- Update all frames with new theme
        if self.unitContainers then
            for unitID, container in pairs(self.unitContainers) do
                -- Update buff frames
                for _, frame in ipairs(container.buffFrames) do
                    self:ApplyThemeToBuffFrame(frame)
                end
                
                -- Update debuff frames
                for _, frame in ipairs(container.debuffFrames) do
                    self:ApplyThemeToBuffFrame(frame)
                end
            end
        end
        
        -- Refresh displays
        self:UpdateAllAuras()
    end)
end