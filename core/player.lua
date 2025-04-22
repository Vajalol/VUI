local _, VUI = ...

-- Player module for all player-related features
VUI.Player = {}

-- Create a table to store cast bar elements
local castBars = {
    player = nil,
    target = nil,
    focus = nil
}

local latencyFrames = {}
local targetNameFrames = {}
local castTimeFrames = {}
local spellIconFrames = {}

local function FormatTime(time)
    if time < 1 then
        return string.format("%.1f", time)
    elseif time < 60 then
        return string.format("%.1f", time)
    else
        local minutes = math.floor(time / 60)
        local seconds = time % 60
        return string.format("%d:%02d", minutes, seconds)
    end
end

local function GetLatencyInMS()
    local _, _, latencyHome = GetNetStats()
    return latencyHome
end

-- Apply Thunder Storm theme to a castbar
local function ApplyThunderStormTheme(castbar, unitID)
    if not castbar then return end
    
    -- Thunder Storm colors
    local backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.8} -- Deep blue background
    local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue borders
    local barColor = {r = 0.1, g = 0.4, b = 0.9, a = 1} -- Bright blue for the progress bar
    
    -- Apply backdrop
    if not castbar.backdrop then
        castbar.backdrop = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
        castbar.backdrop:SetAllPoints()
        castbar.backdrop:SetFrameStrata("BACKGROUND")
    end
    
    castbar.backdrop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    castbar.backdrop:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
    castbar.backdrop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Style the castbar itself
    castbar:SetStatusBarTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\statusbar.tga")
    castbar:SetStatusBarColor(barColor.r, barColor.g, barColor.b, barColor.a)
    
    -- Add a subtle lightning effect
    if not castbar.lightning then
        castbar.lightning = castbar:CreateTexture(nil, "OVERLAY")
        castbar.lightning:SetPoint("TOPLEFT", castbar, "TOPLEFT", 0, 0)
        castbar.lightning:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 0, 0)
        castbar.lightning:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\lightning_overlay.tga")
        castbar.lightning:SetBlendMode("ADD")
        castbar.lightning:SetAlpha(0.1)
    end
    
    -- Animation for the lightning
    if not castbar.lightningAnim then
        castbar.lightningAnim = castbar.lightning:CreateAnimationGroup()
        castbar.lightningAnim:SetLooping("REPEAT")
        
        local fadeIn = castbar.lightningAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.1)
        fadeIn:SetToAlpha(0.3)
        fadeIn:SetDuration(0.3)
        fadeIn:SetOrder(1)
        
        local fadeOut = castbar.lightningAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.3)
        fadeOut:SetToAlpha(0.1)
        fadeOut:SetDuration(0.7)
        fadeOut:SetOrder(2)
        
        castbar.lightningAnim:Play()
    end
    
    -- Style the text
    if castbar.Text then
        castbar.Text:SetFont("Interface\\AddOns\\VUI\\media\\fonts\\expressway.ttf", 10, "OUTLINE")
        castbar.Text:SetTextColor(1, 1, 1)
        castbar.Text:SetShadowOffset(1, -1)
        castbar.Text:SetShadowColor(0, 0, 0, 1)
    end
    
    -- Style timer text
    if castbar.Timer then
        castbar.Timer:SetFont("Interface\\AddOns\\VUI\\media\\fonts\\expressway.ttf", 10, "OUTLINE")
        castbar.Timer:SetTextColor(1, 1, 1)
        castbar.Timer:SetShadowOffset(1, -1)
        castbar.Timer:SetShadowColor(0, 0, 0, 1)
    end
    
    -- Style the icon if it exists
    if castbar.Icon then
        -- Create a border for the icon
        if not castbar.Icon.backdrop then
            castbar.Icon.backdrop = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
            castbar.Icon.backdrop:SetFrameLevel(castbar:GetFrameLevel() - 1)
            castbar.Icon.backdrop:SetPoint("TOPLEFT", castbar.Icon, "TOPLEFT", -2, 2)
            castbar.Icon.backdrop:SetPoint("BOTTOMRIGHT", castbar.Icon, "BOTTOMRIGHT", 2, -2)
        end
        
        castbar.Icon.backdrop:SetBackdrop({
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        castbar.Icon.backdrop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end
    
    -- Add latency indicator (for player castbar only)
    if unitID == "player" and not latencyFrames[castbar] then
        local latencyFrame = CreateFrame("Frame", nil, castbar)
        latencyFrame:SetHeight(castbar:GetHeight())
        latencyFrame:SetFrameLevel(castbar:GetFrameLevel() + 1)
        
        -- Create the latency texture
        local latencyTexture = latencyFrame:CreateTexture(nil, "OVERLAY")
        latencyTexture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\statusbar.tga")
        latencyTexture:SetVertexColor(1, 0, 0, 0.5) -- Red with 50% transparency
        latencyTexture:SetAllPoints(latencyFrame)
        latencyFrame.texture = latencyTexture
        
        -- Create the latency text
        local latencyText = latencyFrame:CreateFontString(nil, "OVERLAY")
        latencyText:SetFont("Interface\\AddOns\\VUI\\media\\fonts\\expressway.ttf", 9, "OUTLINE")
        latencyText:SetTextColor(1, 0.8, 0.8, 1)
        latencyText:SetPoint("LEFT", castbar, "LEFT", 5, 0)
        latencyText:SetJustifyH("LEFT")
        latencyFrame.text = latencyText
        
        -- Store reference to the latency frame
        latencyFrames[castbar] = latencyFrame
    end
    
    -- Add target name display (for player castbar only when targeting something)
    if unitID == "player" and not targetNameFrames[castbar] then
        local targetNameFrame = CreateFrame("Frame", nil, castbar)
        targetNameFrame:SetFrameLevel(castbar:GetFrameLevel() + 1)
        targetNameFrame:SetAllPoints(castbar)
        
        local targetNameText = targetNameFrame:CreateFontString(nil, "OVERLAY")
        targetNameText:SetFont("Interface\\AddOns\\VUI\\media\\fonts\\expressway.ttf", 9, "OUTLINE")
        targetNameText:SetTextColor(0.8, 1, 0.8, 1) -- Light green
        targetNameText:SetPoint("RIGHT", castbar, "RIGHT", -5, 0)
        targetNameText:SetJustifyH("RIGHT")
        targetNameFrame.text = targetNameText
        
        targetNameFrames[castbar] = targetNameFrame
    end
    
    -- Add cast time display (shows after cast is complete)
    if not castTimeFrames[castbar] then
        local castTimeFrame = CreateFrame("Frame", nil, castbar)
        castTimeFrame:SetFrameLevel(castbar:GetFrameLevel() + 1)
        castTimeFrame:SetAllPoints(castbar)
        
        local castTimeText = castTimeFrame:CreateFontString(nil, "OVERLAY")
        castTimeText:SetFont("Interface\\AddOns\\VUI\\media\\fonts\\expressway.ttf", 9, "OUTLINE")
        castTimeText:SetTextColor(1, 1, 1, 1)
        castTimeText:SetPoint("RIGHT", castbar, "RIGHT", -5, 0)
        castTimeText:SetJustifyH("RIGHT")
        castTimeFrame.text = castTimeText
        castTimeFrame:Hide() -- Hidden by default, shown when cast completes
        
        castTimeFrames[castbar] = castTimeFrame
    end
    
    -- Add bigger spell icon before the castbar
    if VUI.db.profile.general.castbar.showIcon and not spellIconFrames[castbar] then
        local iconSize = castbar:GetHeight() * 1.2
        local spellIconFrame = CreateFrame("Frame", nil, castbar)
        spellIconFrame:SetSize(iconSize, iconSize)
        
        if unitID == "player" then
            spellIconFrame:SetPoint("RIGHT", castbar, "LEFT", -5, 0)
        elseif unitID == "target" then
            spellIconFrame:SetPoint("RIGHT", castbar, "LEFT", -5, 0)
        elseif unitID == "focus" then
            spellIconFrame:SetPoint("RIGHT", castbar, "LEFT", -5, 0)
        end
        
        local spellIcon = spellIconFrame:CreateTexture(nil, "BACKGROUND")
        spellIcon:SetAllPoints(spellIconFrame)
        spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop the icon to remove the border
        spellIconFrame.icon = spellIcon
        
        -- Create a border for the icon
        local iconBorder = CreateFrame("Frame", nil, spellIconFrame, "BackdropTemplate")
        iconBorder:SetFrameLevel(spellIconFrame:GetFrameLevel() - 1)
        iconBorder:SetPoint("TOPLEFT", spellIconFrame, "TOPLEFT", -2, 2)
        iconBorder:SetPoint("BOTTOMRIGHT", spellIconFrame, "BOTTOMRIGHT", 2, -2)
        
        iconBorder:SetBackdrop({
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        iconBorder:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        
        spellIconFrame.border = iconBorder
        spellIconFrames[castbar] = spellIconFrame
    end
end

-- Update the castbar with latency, target name, and cast time
local function UpdateCastbar(castbar, unitID)
    if not castbar or not castbar:IsVisible() then return end
    
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unitID)
    local isChanneling = false
    
    if not name then
        name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(unitID)
        isChanneling = name ~= nil
    end
    
    -- Update spell icon before the castbar
    if spellIconFrames[castbar] and texture and VUI.db.profile.general.castbar.showIcon then
        spellIconFrames[castbar].icon:SetTexture(texture)
        spellIconFrames[castbar]:Show()
    elseif spellIconFrames[castbar] then
        spellIconFrames[castbar]:Hide()
    end
    
    -- Update latency (player only) - shown on left side
    if unitID == "player" and latencyFrames[castbar] and name and VUI.db.profile.general.castbar.showLatency then
        local latency = GetLatencyInMS() / 1000
        local castDuration = (endTime - startTime) / 1000
        local latencyWidth = castbar:GetWidth() * (latency / castDuration)
        
        -- Position latency indicator at the end of the cast
        latencyFrames[castbar]:SetWidth(latencyWidth)
        latencyFrames[castbar]:ClearAllPoints()
        
        if isChanneling then
            -- For channeling spells, latency is at the beginning
            latencyFrames[castbar]:SetPoint("LEFT", castbar, "LEFT", 0, 0)
        else
            -- For regular casts, latency is at the end
            latencyFrames[castbar]:SetPoint("RIGHT", castbar, "RIGHT", 0, 0)
        end
        
        -- Show latency text on the left side of the castbar
        latencyFrames[castbar].text:SetText(string.format("%dms", GetLatencyInMS()))
        latencyFrames[castbar]:Show()
    elseif latencyFrames[castbar] then
        latencyFrames[castbar]:Hide()
    end
    
    -- Update target name (player only) - shown on right side
    if unitID == "player" and targetNameFrames[castbar] and VUI.db.profile.general.castbar.showTarget then
        local hasTarget = UnitExists("target")
        if hasTarget and name then
            local targetName = UnitName("target")
            targetNameFrames[castbar].text:SetText("|cffffffff→|r " .. targetName)
            targetNameFrames[castbar]:Show()
        else
            targetNameFrames[castbar]:Hide()
        end
    end
    
    -- Handle cast completion to show cast time - shown on right side after cast completes
    if castTimeFrames[castbar] and not name and VUI.db.profile.general.castbar.showCastTime then
        -- This means the cast has completed
        if castTimeFrames[castbar].lastCastTime then
            castTimeFrames[castbar].text:SetText(string.format("%.2fs", castTimeFrames[castbar].lastCastTime))
            castTimeFrames[castbar]:Show()
            
            -- Hide after 2 seconds
            C_Timer.After(2, function()
                if castTimeFrames[castbar] then
                    castTimeFrames[castbar]:Hide()
                end
            end)
        end
    elseif castTimeFrames[castbar] and name then
        -- Store the current cast time for showing after cast completes
        castTimeFrames[castbar].lastCastTime = (endTime - startTime) / 1000
        castTimeFrames[castbar]:Hide()
    end
end

-- Main function to initialize castbars
function VUI.Player:InitializeCastbars()
    -- Get references to default castbars
    castBars.player = CastingBarFrame
    castBars.target = TargetFrameSpellBar
    castBars.focus = FocusFrameSpellBar
    
    if VUI.db.profile.general.castbar.enabled then
        if VUI.db.profile.general.castbar.customColors then
            -- Apply Thunder Storm theme to castbars
            ApplyThunderStormTheme(castBars.player, "player")
            ApplyThunderStormTheme(castBars.target, "target")
            ApplyThunderStormTheme(castBars.focus, "focus")
            
            -- Show/hide spell name based on settings
            if castBars.player.Text then
                castBars.player.Text:SetShown(VUI.db.profile.general.castbar.showSpellName)
            end
            if castBars.target.Text then
                castBars.target.Text:SetShown(VUI.db.profile.general.castbar.showSpellName)
            end
            if castBars.focus.Text then
                castBars.focus.Text:SetShown(VUI.db.profile.general.castbar.showSpellName)
            end
            
            -- Show/hide timer based on settings
            if castBars.player.Timer then
                castBars.player.Timer:SetShown(VUI.db.profile.general.castbar.showTimer)
            end
            if castBars.target.Timer then
                castBars.target.Timer:SetShown(VUI.db.profile.general.castbar.showTimer)
            end
            if castBars.focus.Timer then
                castBars.focus.Timer:SetShown(VUI.db.profile.general.castbar.showTimer)
            end
        else
            -- Reset to default appearance if themes are disabled
            if castBars.player.backdrop then castBars.player.backdrop:Hide() end
            if castBars.target.backdrop then castBars.target.backdrop:Hide() end
            if castBars.focus.backdrop then castBars.focus.backdrop:Hide() end
            
            if castBars.player.lightning then castBars.player.lightning:Hide() end
            if castBars.target.lightning then castBars.target.lightning:Hide() end
            if castBars.focus.lightning then castBars.focus.lightning:Hide() end
            
            -- Reset textures
            castBars.player:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            castBars.target:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            castBars.focus:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end
    else
        -- Hide custom elements if castbar is disabled
        if castBars.player.backdrop then castBars.player.backdrop:Hide() end
        if castBars.target.backdrop then castBars.target.backdrop:Hide() end
        if castBars.focus.backdrop then castBars.focus.backdrop:Hide() end
        
        if castBars.player.lightning then castBars.player.lightning:Hide() end
        if castBars.target.lightning then castBars.target.lightning:Hide() end
        if castBars.focus.lightning then castBars.focus.lightning:Hide() end
        
        -- Reset to default appearance
        castBars.player:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        castBars.target:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        castBars.focus:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        
        -- Hide additional elements
        for castbar, frame in pairs(latencyFrames) do
            frame:Hide()
        end
        
        for castbar, frame in pairs(targetNameFrames) do
            frame:Hide()
        end
        
        for castbar, frame in pairs(castTimeFrames) do
            frame:Hide()
        end
        
        for castbar, frame in pairs(spellIconFrames) do
            frame:Hide()
        end
    end
end

-- Register for events to update the castbars
function VUI.Player:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("UNIT_SPELLCAST_START")
    frame:RegisterEvent("UNIT_SPELLCAST_STOP")
    frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" or event == "ADDON_LOADED" then
            VUI.Player:InitializeCastbars()
        elseif event == "UNIT_SPELLCAST_START" or 
               event == "UNIT_SPELLCAST_STOP" or 
               event == "UNIT_SPELLCAST_CHANNEL_START" or 
               event == "UNIT_SPELLCAST_CHANNEL_STOP" or
               event == "UNIT_SPELLCAST_FAILED" or 
               event == "UNIT_SPELLCAST_INTERRUPTED" or
               event == "UNIT_SPELLCAST_DELAYED" or
               event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            local unit = ...
            if unit == "player" then
                UpdateCastbar(castBars.player, "player")
            elseif unit == "target" then
                UpdateCastbar(castBars.target, "target")
            elseif unit == "focus" then
                UpdateCastbar(castBars.focus, "focus")
            end
        elseif event == "PLAYER_TARGET_CHANGED" then
            -- Update target castbar on target change
            UpdateCastbar(castBars.target, "target")
            -- Update player castbar target name
            UpdateCastbar(castBars.player, "player")
        end
    end)
    
    -- Also create a OnUpdate handler to continually update castbars
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.05 then -- update every 50ms
            UpdateCastbar(castBars.player, "player")
            UpdateCastbar(castBars.target, "target")
            UpdateCastbar(castBars.focus, "focus")
            self.elapsed = 0
        end
    end)
end

-- Initialize the player module
function VUI.Player:OnInitialize()
    self:InitializeCastbars()
end

-- Other player-related functions would go here

-- Hook into the ApplySettings function to update player elements
local originalApplySettings = VUI.ApplySettings
function VUI:ApplySettings()
    originalApplySettings(self)
    self.Player:InitializeCastbars()
end