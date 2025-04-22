local _, VUI = ...

-- Castbar styling module
VUI.Castbar = {}

local function ApplyThunderStormTheme(castbar)
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
end

function VUI.Castbar:InitializeCastbar()
    local playerCastbar = CastingBarFrame
    local targetCastbar = TargetFrameSpellBar
    local focusCastbar = FocusFrameSpellBar
    
    if VUI.db.profile.general.castbar.enabled then
        if VUI.db.profile.general.castbar.customColors then
            -- Apply Thunder Storm theme to castbars
            ApplyThunderStormTheme(playerCastbar)
            ApplyThunderStormTheme(targetCastbar)
            ApplyThunderStormTheme(focusCastbar)
            
            -- Show/hide spell name based on settings
            if playerCastbar.Text then
                playerCastbar.Text:SetShown(VUI.db.profile.general.castbar.showSpellName)
            end
            if targetCastbar.Text then
                targetCastbar.Text:SetShown(VUI.db.profile.general.castbar.showSpellName)
            end
            if focusCastbar.Text then
                focusCastbar.Text:SetShown(VUI.db.profile.general.castbar.showSpellName)
            end
            
            -- Show/hide timer based on settings
            if playerCastbar.Timer then
                playerCastbar.Timer:SetShown(VUI.db.profile.general.castbar.showTimer)
            end
            if targetCastbar.Timer then
                targetCastbar.Timer:SetShown(VUI.db.profile.general.castbar.showTimer)
            end
            if focusCastbar.Timer then
                focusCastbar.Timer:SetShown(VUI.db.profile.general.castbar.showTimer)
            end
            
            -- Show/hide spell icon based on settings
            if playerCastbar.Icon then
                playerCastbar.Icon:SetShown(VUI.db.profile.general.castbar.showIcon)
            end
            if targetCastbar.Icon then
                targetCastbar.Icon:SetShown(VUI.db.profile.general.castbar.showIcon)
            end
            if focusCastbar.Icon then
                focusCastbar.Icon:SetShown(VUI.db.profile.general.castbar.showIcon)
            end
        else
            -- Reset to default appearance if themes are disabled
            if playerCastbar.backdrop then playerCastbar.backdrop:Hide() end
            if targetCastbar.backdrop then targetCastbar.backdrop:Hide() end
            if focusCastbar.backdrop then focusCastbar.backdrop:Hide() end
            
            if playerCastbar.lightning then playerCastbar.lightning:Hide() end
            if targetCastbar.lightning then targetCastbar.lightning:Hide() end
            if focusCastbar.lightning then focusCastbar.lightning:Hide() end
            
            -- Reset textures
            playerCastbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            targetCastbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            focusCastbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end
    else
        -- Hide custom elements if castbar is disabled
        if playerCastbar.backdrop then playerCastbar.backdrop:Hide() end
        if targetCastbar.backdrop then targetCastbar.backdrop:Hide() end
        if focusCastbar.backdrop then focusCastbar.backdrop:Hide() end
        
        if playerCastbar.lightning then playerCastbar.lightning:Hide() end
        if targetCastbar.lightning then targetCastbar.lightning:Hide() end
        if focusCastbar.lightning then focusCastbar.lightning:Hide() end
        
        -- Reset to default appearance
        playerCastbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        targetCastbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        focusCastbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    end
end

-- Hook into the ApplySettings function to update castbars
local originalApplySettings = VUI.ApplySettings
function VUI:ApplySettings()
    originalApplySettings(self)
    self.Castbar:InitializeCastbar()
end

-- Initialize on load
function VUI.Castbar:OnInitialize()
    self:InitializeCastbar()
end

-- Register events for castbar updates
function VUI.Castbar:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" or event == "ADDON_LOADED" then
            VUI.Castbar:InitializeCastbar()
        end
    end)
end