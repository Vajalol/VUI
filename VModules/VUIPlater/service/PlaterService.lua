-- VUIPlater PlaterService
-- Provides integration with Plater Nameplates addon
-- Based on source: https://wago.io/whiiskeyzplater

local AddonName, VUI = ...
<<<<<<< HEAD
local M = VUI and VUI.VUIPlater or {}
if not M then return end
=======
local M = VUI.VUIPlater or VUI:GetModule("VUIPlater")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
local PlaterService = {}
M.PlaterService = PlaterService

-- Texture paths - Updated to use existing textures from the VUI addon
local TEXTURES = {
    HEALTH_BAR = "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Smooth.blp",
    CAST_BAR = "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Flat.blp",
    NAME_TEXT = "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Minimalist.tga",
    TARGET_INDICATOR = "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Glaze.tga",
    BORDER = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_1px.tga",
    SHIELD = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\shield.tga",
    THREAT = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\threat.tga",
    BORDER_GLOW = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_glow.tga",
}

-- Default configuration
local defaultConfig = {
    -- Health Bar
    healthBarTexture = TEXTURES.HEALTH_BAR,
    healthBarHeight = 10,
    healthBarWidth = 140,
    healthBarColor = {0.2, 0.8, 0.2, 1.0},
    
    -- Cast Bar
    castBarTexture = TEXTURES.CAST_BAR,
    castBarHeight = 10,
    castBarWidth = 140,
    castBarColor = {0.4, 0.6, 0.8, 1.0},
    
    -- Name Text
    nameTextFont = "Arial Narrow",
    nameTextSize = 10,
    nameTextColor = {1.0, 1.0, 1.0, 1.0},
    
    -- Target Indicator
    targetIndicatorTexture = TEXTURES.TARGET_INDICATOR,
    targetIndicatorWidth = 30,
    targetIndicatorHeight = 30,
    targetIndicatorColor = {1.0, 1.0, 1.0, 0.3},
    
    -- Threat Colors
    tankThreatColor = {0.0, 0.7, 1.0, 1.0},
    offTankThreatColor = {0.5, 0.5, 0.5, 1.0},
    dpsThreatOnColor = {1.0, 0.3, 0.3, 1.0},
    dpsThreatOffColor = {0.5, 0.5, 0.5, 1.0},
    
    -- Buff/Debuff Settings
    showBuffs = true,
    showDebuffs = true,
    buffSize = 20,
    debuffSize = 24,
    buffRows = 1,
    debuffRows = 2,
    buffColumns = 3,
    debuffColumns = 3,
    
    -- Special Units
    bossNameplateScale = 1.2,
    rareNameplateScale = 1.1,
    friendlyNameplateScale = 0.9,
    
    -- Additional Options
    showResourceOnTarget = true,
    nameOnlyOnFriendly = true,
    clickThroughUnattackable = true,
    classColoredHealthbar = true,
    executionThreshold = 35,
    fadeAmount = 0.6,
    targetScale = 1.2,
}

-- Initialize the Plater service
function PlaterService:Initialize()
    -- Check if Plater is loaded
    self.platerLoaded = IsAddOnLoaded("Plater")
    
    if not self.platerLoaded then
        M:Print("Plater Nameplates addon is not loaded. VUIPlater integration is disabled.")
        return false
    end
    
    -- Store reference to Plater object
    if Plater then
        self.plater = Plater
        self:SetupHooks()
        self:ApplySettings()
        
        M:Debug("PlaterService initialized - Plater integration active")
        return true
    end
    
    return false
end

-- Set up hooks to Plater functions
function PlaterService:SetupHooks()
    if not self.plater then return end
    
    -- Hook profile changes
    hooksecurefunc(self.plater, "RefreshConfig", function()
        self:OnPlaterProfileChanged()
    end)
    
    -- Hook nameplate creation
    hooksecurefunc(self.plater, "OnNewNameplate", function(plate)
        self:OnNewNameplate(plate)
    end)
    
    -- Hook nameplate update
    hooksecurefunc(self.plater, "UpdatePlateFrame", function(plate)
        self:OnUpdatePlate(plate)
    end)
    
    -- Hook threat updates
    hooksecurefunc(self.plater, "UpdateThreatTable", function()
        self:OnThreatUpdate()
    end)
    
    -- Hook specific unit updates
    hooksecurefunc(self.plater, "UpdateSingleUnit", function(plate, unitFrame, unitId)
        self:OnUnitUpdate(plate, unitFrame, unitId)
    end)
    
    M:Debug("PlaterService hooks applied")
end

-- Handle Plater profile changes
function PlaterService:OnPlaterProfileChanged()
    self:ApplySettings()
    M:Debug("Applied settings after Plater profile change")
end

-- Handle new nameplate creation
function PlaterService:OnNewNameplate(plate)
    -- Apply VUI styling to the new nameplate
    if not plate then return end
    
    -- Additional styling code here
    self:StyleNameplate(plate)
end

-- Handle nameplate updates
function PlaterService:OnUpdatePlate(plate)
    -- Apply conditional styling based on unit type
    if not plate then return end
    
    local unitFrame = plate.unitFrame
    if not unitFrame then return end
    
    -- Check for special unit types
    local unitType = self:GetUnitType(unitFrame)
    
    if unitType == "BOSS" then
        self:StyleBossNameplate(unitFrame)
    elseif unitType == "RARE" then
        self:StyleRareNameplate(unitFrame)
    elseif unitType == "FRIENDLY" then
        self:StyleFriendlyNameplate(unitFrame)
    else
        -- Regular enemy
        self:StyleEnemyNameplate(unitFrame)
    end
end

-- Handle threat updates
function PlaterService:OnThreatUpdate()
    -- Update the threat status of all nameplates
    if not self.plater then return end
    
    for _, plateFrame in ipairs(self.plater.GetAllShownPlates()) do
        if plateFrame and plateFrame.unitFrame then
            self:UpdateThreatIndicator(plateFrame.unitFrame)
        end
    end
end

-- Handle specific unit updates
function PlaterService:OnUnitUpdate(plate, unitFrame, unitId)
    if not plate or not unitFrame or not unitId then return end
    
    -- Update execution indicator based on health percentage
    self:UpdateExecutionIndicator(unitFrame, unitId)
    
    -- Update class icon if it's a player
    if UnitIsPlayer(unitId) then
        self:UpdateClassIcon(unitFrame, unitId)
    end
    
    -- Update buff and debuff display
    self:UpdateAuras(unitFrame, unitId)
end

-- Apply VUI settings to Plater
function PlaterService:ApplySettings()
    if not self.plater then return end
    
    local settings = M.db.profile
    
    -- Get current Plater profile
    local currentProfile = self.plater.db.profile
    
    -- Apply our settings that differ from defaults
    if settings.useVUISettings then
        -- Health Bar
        currentProfile.health_bar_texture = settings.healthBarTexture or defaultConfig.healthBarTexture
        currentProfile.health_bar_height = settings.healthBarHeight or defaultConfig.healthBarHeight
        
        -- Cast Bar
        currentProfile.cast_bar_texture = settings.castBarTexture or defaultConfig.castBarTexture
        currentProfile.cast_bar_height = settings.castBarHeight or defaultConfig.castBarHeight
        
        -- Buffs/Debuffs
        currentProfile.aura_show_buffs = settings.showBuffs or defaultConfig.showBuffs
        currentProfile.aura_show_debuffs = settings.showDebuffs or defaultConfig.showDebuffs
        currentProfile.aura_width = settings.buffSize or defaultConfig.buffSize
        currentProfile.aura_height = settings.debuffSize or defaultConfig.debuffSize
        
        -- Class Colors
        currentProfile.use_playerclass_color = settings.classColoredHealthbar or defaultConfig.classColoredHealthbar
        
        -- The War Within specific options
        if self:IsWarWithinOrLater() then
            -- Adjust nameplate padding for The War Within's new stacking system
            currentProfile.plate_config.player.vertical_offset = 50
            currentProfile.plate_config.player.horizontal_offset = 0
            
            -- Adjust nameplate scale for The War Within UI changes
            currentProfile.global_health_width_scale = 1.1
            currentProfile.global_health_height_scale = 1.1
            
            -- Enable modern nameplate features
            currentProfile.use_health_gradient = true
            currentProfile.health_fade_animation = true
            currentProfile.use_quick_hide = true
            
            -- Adjust for The War Within's new health text format
            currentProfile.health_statusbar_texture_overlay = "VUI Gradient"
            currentProfile.health_statusbar_bgtexture = "VUI Gradient"
            
            -- Add new TWW features from Whiiskeyz profile
            currentProfile.target_shading = true
            currentProfile.target_shading_intensity = 0.3
            currentProfile.target_shading_texture = TEXTURES.TARGET_INDICATOR
            
            -- Add execution range indicators
            currentProfile.general_health_threshold_execute_enabled = true
            currentProfile.general_health_threshold_execute = settings.executionThreshold or defaultConfig.executionThreshold
            currentProfile.general_health_threshold_execute_glow = true
        end
        
        -- Force a Plater update
        self.plater:RefreshDBUpvalues()
        self.plater:RefreshAll()
    end
    
    M:Debug("Applied VUI settings to Plater")
end

-- Style a nameplate according to VUI design
function PlaterService:StyleNameplate(plate)
    local unitFrame = plate.unitFrame
    if not unitFrame then return end
    
    local settings = M.db.profile
    
    -- Apply border texture
    if unitFrame.healthBar and unitFrame.healthBar.border then
        unitFrame.healthBar.border:SetTexture(TEXTURES.BORDER)
    end
    
    -- Get smooth statusbar texture from LSM
    local healthTexture = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", "VUI Smooth") or TEXTURES.HEALTH_BAR
    local castTexture = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", "VUI Flat") or TEXTURES.CAST_BAR
    
    -- Apply shared styling for all nameplates (Whiiskeyz style)
    if unitFrame.healthBar then
        -- Apply updated texture styles
        unitFrame.healthBar:SetStatusBarTexture(healthTexture)
        
        -- Set health bar height and width for better visibility
        local height = settings.enemy and settings.enemy.height or 10
        unitFrame.healthBar:SetHeight(height)
        
        -- Adjust health bar appearance for Whiiskeyz UI style
        unitFrame.healthBar.background:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        
        -- Add shadow to make text more readable
        if unitFrame.healthBar.unitName then
            unitFrame.healthBar.unitName:SetShadowOffset(1, -1)
            unitFrame.healthBar.unitName:SetShadowColor(0, 0, 0, 1)
            unitFrame.healthBar.unitName:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        end
        
        -- Update health percentage text
        if unitFrame.healthBar.lifePercent then
            unitFrame.healthBar.lifePercent:SetShadowOffset(1, -1)
            unitFrame.healthBar.lifePercent:SetShadowColor(0, 0, 0, 1)
            unitFrame.healthBar.lifePercent:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        end
    end
    
    -- Apply cast bar styling
    if unitFrame.castBar then
        unitFrame.castBar:SetStatusBarTexture(castTexture)
        
        -- Set cast bar height
        local castHeight = settings.enemy and settings.enemy.castBarHeight or 10
        unitFrame.castBar:SetHeight(castHeight)
        
        -- Style cast bar text
        if unitFrame.castBar.Text then
            unitFrame.castBar.Text:SetShadowOffset(1, -1)
            unitFrame.castBar.Text:SetShadowColor(0, 0, 0, 1)
            unitFrame.castBar.Text:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
        end
        
        -- Style cast time text
        if unitFrame.castBar.percentText then
            unitFrame.castBar.percentText:SetShadowOffset(1, -1)
            unitFrame.castBar.percentText:SetShadowColor(0, 0, 0, 1)
            unitFrame.castBar.percentText:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
        end
        
        -- Adjust castbar background
        unitFrame.castBar.background:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        
        -- Add shield icon for non-interruptible casts
        if unitFrame.castBar.BorderShield then
            unitFrame.castBar.BorderShield:SetTexture(TEXTURES.SHIELD)
            unitFrame.castBar.BorderShield:SetSize(16, 16)
            unitFrame.castBar.BorderShield:ClearAllPoints()
            unitFrame.castBar.BorderShield:SetPoint("RIGHT", unitFrame.castBar.Icon, "LEFT", -2, 0)
        end
    end
    
    -- Apply target highlight styling if present
    if unitFrame.targetOverlay then
        unitFrame.targetOverlay:SetColorTexture(1, 1, 1, 0.3)
    end
    
    -- The War Within specific nameplate styling
    if self:IsWarWithinOrLater() then
        -- Handle The War Within specific nameplate features
        if self.plater.AddBorderToHealthBar then
            self.plater.AddBorderToHealthBar(unitFrame)
        end
        
        -- Add specific styling for The War Within nameplates
        if unitFrame.ActorTitleSpecial and unitFrame.ActorTitleSpecial.SetVertexColor then
            unitFrame.ActorTitleSpecial:SetVertexColor(1, 0.8, 0, 1) -- Gold color for special titles
        end
    end
    
    -- Apply specific styling based on unit type
    local unitType = self:GetUnitType(unitFrame)
    if unitType == "BOSS" then
        self:StyleBossNameplate(unitFrame)
    elseif unitType == "RARE" then
        self:StyleRareNameplate(unitFrame)
    elseif unitType == "FRIENDLY" then
        self:StyleFriendlyNameplate(unitFrame)
    else
        self:StyleEnemyNameplate(unitFrame)
    end
end

-- Determine unit type (boss, rare, etc.)
function PlaterService:GetUnitType(unitFrame)
    if not unitFrame or not unitFrame.namePlateUnitToken then
        return "UNKNOWN"
    end
    
    local unitId = unitFrame.namePlateUnitToken
    
    -- Check if unit is boss
    if UnitClassification(unitId) == "worldboss" or UnitClassification(unitId) == "rareelite" then
        return "BOSS"
    end
    
    -- Check if unit is rare
    if UnitClassification(unitId) == "rare" or UnitClassification(unitId) == "rareelite" then
        return "RARE"
    end
    
    -- Check if unit is friendly
    if UnitReaction("player", unitId) and UnitReaction("player", unitId) > 4 then
        return "FRIENDLY"
    end
    
    -- Default: regular enemy
    return "ENEMY"
end

-- Style boss nameplates
function PlaterService:StyleBossNameplate(unitFrame)
    if not unitFrame then return end
    
    local settings = M.db.profile
    
    -- Increase scale for boss nameplates
    unitFrame:SetScale(settings.bossNameplateScale or defaultConfig.bossNameplateScale)
    
    -- Add boss-specific styling
    if unitFrame.healthBar and unitFrame.healthBar.border then
        unitFrame.healthBar.border:SetBackdropBorderColor(1, 0.85, 0, 1)
    end
end

-- Style rare nameplates
function PlaterService:StyleRareNameplate(unitFrame)
    if not unitFrame then return end
    
    local settings = M.db.profile
    
    -- Increase scale for rare nameplates
    unitFrame:SetScale(settings.rareNameplateScale or defaultConfig.rareNameplateScale)
    
    -- Add rare-specific styling
    if unitFrame.healthBar and unitFrame.healthBar.border then
        unitFrame.healthBar.border:SetBackdropBorderColor(0.3, 0.5, 1, 1)
    end
end

-- Style friendly nameplates
function PlaterService:StyleFriendlyNameplate(unitFrame)
    if not unitFrame then return end
    
    local settings = M.db.profile
    
    -- Scale friendly nameplates
    unitFrame:SetScale(settings.friendlyNameplateScale or defaultConfig.friendlyNameplateScale)
    
    -- Apply friendly name-only mode if enabled
    if settings.nameOnlyOnFriendly or defaultConfig.nameOnlyOnFriendly then
        unitFrame.healthBar:Hide()
        
        -- Make name more prominent
        if unitFrame.healthBar.unitName then
            unitFrame.healthBar.unitName:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            unitFrame.healthBar.unitName:ClearAllPoints()
            unitFrame.healthBar.unitName:SetPoint("CENTER", unitFrame, "CENTER", 0, 0)
        end
    else
        unitFrame.healthBar:Show()
    end
end

-- Style enemy nameplates
function PlaterService:StyleEnemyNameplate(unitFrame)
    if not unitFrame then return end
    
    local settings = M.db.profile
    
    -- Normal scale for standard enemies
    unitFrame:SetScale(1.0)
    
    -- Make sure health bar is visible
    unitFrame.healthBar:Show()
    
    -- Apply enemy-specific styling based on Whiiskeyz profile
    
    -- Apply class colors if unit is a player
    if settings.classColoredHealthbar and UnitIsPlayer(unitFrame.displayedUnit) then
        local _, class = UnitClass(unitFrame.displayedUnit)
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            unitFrame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
    
    -- Apply health text formatting for enemy units
    if unitFrame.healthBar and unitFrame.healthBar.lifePercent then
        unitFrame.healthBar.lifePercent:SetText(string.format("%.0f%%", (UnitHealth(unitFrame.displayedUnit) / UnitHealthMax(unitFrame.displayedUnit) * 100)))
    end
    
    -- Enhance enemy cast bars
    if unitFrame.castBar then
        -- Make cast bar slightly wider for better visibility of enemy casts
        unitFrame.castBar:SetWidth(unitFrame.healthBar:GetWidth())
        
        -- Add colored border for non-interruptible casts
        if not unitFrame.castBar.BorderShield then
            unitFrame.castBar.BorderShield = unitFrame.castBar:CreateTexture(nil, "OVERLAY")
            unitFrame.castBar.BorderShield:SetSize(16, 16)
            unitFrame.castBar.BorderShield:SetPoint("LEFT", unitFrame.castBar, "LEFT", -8, 0)
            unitFrame.castBar.BorderShield:SetTexture(TEXTURES.BORDER)
            unitFrame.castBar.BorderShield:Hide()
        end
        
        -- Update shield visibility for interruptible/non-interruptible casts
        if unitFrame.castBar.notInterruptible then
            unitFrame.castBar.BorderShield:Show()
            unitFrame.castBar:SetStatusBarColor(0.7, 0.3, 0) -- Orange for non-interruptible
        else
            unitFrame.castBar.BorderShield:Hide()
            unitFrame.castBar:SetStatusBarColor(0.4, 0.6, 0.8) -- Blue for interruptible
        end
    end
    
    -- Add threat indication if tank mode is enabled
    local playerRole = GetSpecializationRole(GetSpecialization())
    local isTank = playerRole == "TANK"
    
    if isTank and UnitCanAttack("player", unitFrame.displayedUnit) then
        local status = UnitThreatSituation("player", unitFrame.displayedUnit)
        
        -- Add threat glow if not main tank
        if status and status < 3 then  -- Not tanking
            if not unitFrame.ThreatGlow then
                unitFrame.ThreatGlow = unitFrame:CreateTexture(nil, "BACKGROUND")
                unitFrame.ThreatGlow:SetPoint("TOPLEFT", unitFrame.healthBar, "TOPLEFT", -4, 4)
                unitFrame.ThreatGlow:SetPoint("BOTTOMRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 4, -4)
                unitFrame.ThreatGlow:SetTexture(TEXTURES.BORDER)
                unitFrame.ThreatGlow:SetVertexColor(1, 0, 0, 0.6)
            end
            unitFrame.ThreatGlow:Show()
        elseif unitFrame.ThreatGlow then
            unitFrame.ThreatGlow:Hide()
        end
    end
end

-- Update threat indicator
function PlaterService:UpdateThreatIndicator(unitFrame)
    if not unitFrame or not unitFrame.namePlateUnitToken then return end
    
    local unitId = unitFrame.namePlateUnitToken
    local settings = M.db.profile
    
    -- Skip if unit is friendly
    if UnitReaction("player", unitId) and UnitReaction("player", unitId) > 4 then
        return
    end
    
    -- Get threat situation
    local isTanking, status, threatpct = UnitDetailedThreatSituation("player", unitId)
    
    -- Handle threat coloring based on role
    if unitFrame.threatIndicator then
        -- Check if we're a tank
        local isTank = false
        if GetSpecializationRole(GetSpecialization()) == "TANK" then
            isTank = true
        end
        
        -- Set threat color
        if isTank then
            -- Tank Mode
            if status == 3 then -- Securely tanking
                unitFrame.threatIndicator:SetVertexColor(unpack(defaultConfig.tankThreatColor))
                unitFrame.threatIndicator:Show()
            elseif status == 2 then -- Insecurely tanking
                unitFrame.threatIndicator:SetVertexColor(1, 0.6, 0, 1)
                unitFrame.threatIndicator:Show()
            elseif status == 1 or status == 0 then -- Not tanking but have threat or no threat
                unitFrame.threatIndicator:SetVertexColor(unpack(defaultConfig.offTankThreatColor))
                unitFrame.threatIndicator:Show()
            else
                unitFrame.threatIndicator:Hide()
            end
        else
            -- DPS Mode
            if status == 3 then -- Tanking as DPS - bad!
                unitFrame.threatIndicator:SetVertexColor(unpack(defaultConfig.dpsThreatOnColor))
                unitFrame.threatIndicator:Show()
            elseif status == 2 then -- About to pull threat
                unitFrame.threatIndicator:SetVertexColor(1, 0.6, 0, 1)
                unitFrame.threatIndicator:Show()
            elseif status == 1 then -- Higher threat but not tanking
                unitFrame.threatIndicator:SetVertexColor(0.6, 0.6, 0, 1)
                unitFrame.threatIndicator:Show()
            else
                unitFrame.threatIndicator:Hide()
            end
        end
    end
end

-- Update execution indicator
function PlaterService:UpdateExecutionIndicator(unitFrame, unitId)
    if not unitFrame or not unitId then return end
    
    local settings = M.db.profile
    local threshold = settings.enemy and settings.enemy.executionThreshold or defaultConfig.executionThreshold
    
    -- Skip friendly units
    if UnitReaction("player", unitId) and UnitReaction("player", unitId) > 4 then
        return
    end
    
    -- Check health percentage
    local healthPercent = UnitHealth(unitId) / UnitHealthMax(unitId) * 100
    
    -- Apply execution indicator if health is below threshold
    if unitFrame.executeIndicator then
        if healthPercent <= threshold then
            unitFrame.executeIndicator:Show()
        else
            unitFrame.executeIndicator:Hide()
        end
    end
end

-- Update class icon for players
function PlaterService:UpdateClassIcon(unitFrame, unitId)
    if not unitFrame or not unitId or not UnitIsPlayer(unitId) then return end
    
    local settings = M.db.profile
    
    -- Get unit reaction
    local reaction = UnitReaction("player", unitId) or 0
    local isFriendly = reaction > 4
    
    -- Check if we should show icon based on settings
    local shouldShowIcon = false
    if isFriendly and settings.friendly and settings.friendly.showFriendlyClassIcon then
        shouldShowIcon = true
    elseif not isFriendly and settings.enemy and settings.enemy.showEnemyClassIcon then
        shouldShowIcon = true
    end
    
    -- Update class icon
    if unitFrame.classIcon and shouldShowIcon then
        local _, unitClass = UnitClass(unitId)
        if unitClass then
            -- Get class icon coordinates
            local coords = CLASS_ICON_TCOORDS[unitClass]
            if coords then
                unitFrame.classIcon:SetTexCoord(unpack(coords))
                unitFrame.classIcon:Show()
            else
                unitFrame.classIcon:Hide()
            end
        else
            unitFrame.classIcon:Hide()
        end
    elseif unitFrame.classIcon then
        unitFrame.classIcon:Hide()
    end
end

-- Update auras (buffs and debuffs)
function PlaterService:UpdateAuras(unitFrame, unitId)
    if not unitFrame or not unitId then return end
    
    local settings = M.db.profile
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitId) or 0
    local isFriendly = reaction > 4
    
    -- Get the appropriate settings
    local typeSettings
    if isFriendly then
        typeSettings = settings.friendly
    else
        typeSettings = settings.enemy
    end
    
    -- Update buff container
    if typeSettings and typeSettings.showBuffs then
        -- Implementation for buffs
    end
    
    -- Update debuff container
    if typeSettings and typeSettings.showDebuffs then
        -- Implementation for debuffs
    end
end

-- Get instance information
function PlaterService:GetInstanceInfo()
    local inInstance, instanceType = IsInInstance()
    return inInstance, instanceType
end

-- Export Plater profile to string
function PlaterService:ExportProfile()
    if not self.plater then return nil end
    
    -- Generate export string
    local exportString = self.plater:ExportProfileToString()
    return exportString
end

-- Import Plater profile from string
function PlaterService:ImportProfile(importString)
    if not self.plater or not importString then return false end
    
    -- Import the profile
    local success = self.plater:ImportProfileFromString(importString)
    
    if success then
        -- Apply our customizations on top of the imported profile
        self:ApplySettings()
        M:Debug("Successfully imported and customized Plater profile")
    end
    
    return success
end

-- Check if client version is The War Within or later
function PlaterService:IsWarWithinOrLater()
    -- Build 50401 is The War Within pre-patch
    local _, _, _, tocversion = GetBuildInfo()
    return tocversion >= 100200
end

-- Return the service object
return PlaterService