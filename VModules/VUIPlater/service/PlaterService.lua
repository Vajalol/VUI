-- VUIPlater PlaterService
-- Provides integration with Plater Nameplates addon
-- Based on source: https://wago.io/whiiskeyzplater

local AddonName, VUI = ...
local M = VUI:GetModule("VUIPlater")
local PlaterService = {}
M.PlaterService = PlaterService

-- Texture paths
local TEXTURES = {
    HEALTH_BAR = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\health_bar.tga",
    CAST_BAR = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\cast_bar.tga",
    NAME_TEXT = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\name_text.tga",
    TARGET_INDICATOR = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\target_indicator.tga",
    BORDER = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_1px.tga",
}

-- Default configuration
local defaultConfig = {
    -- Health Bar
    healthBarTexture = TEXTURES.HEALTH_BAR,
    healthBarHeight = 10,
    healthBarWidth = 120,
    healthBarColor = {0.2, 0.8, 0.2, 1.0},
    
    -- Cast Bar
    castBarTexture = TEXTURES.CAST_BAR,
    castBarHeight = 8,
    castBarWidth = 120,
    castBarColor = {0.8, 0.8, 0.2, 1.0},
    
    -- Name Text
    nameTextFont = "Friz Quadrata TT",
    nameTextSize = 10,
    nameTextColor = {1.0, 1.0, 1.0, 1.0},
    
    -- Target Indicator
    targetIndicatorTexture = TEXTURES.TARGET_INDICATOR,
    targetIndicatorWidth = 30,
    targetIndicatorHeight = 30,
    targetIndicatorColor = {1.0, 0.8, 0.0, 0.7},
    
    -- Threat Colors
    tankThreatColor = {0.0, 0.7, 1.0, 1.0},
    offTankThreatColor = {0.5, 0.5, 0.5, 1.0},
    dpsThreatOnColor = {1.0, 0.0, 0.0, 1.0},
    dpsThreatOffColor = {0.5, 0.5, 0.5, 1.0},
    
    -- Buff/Debuff Settings
    showBuffs = true,
    showDebuffs = true,
    buffSize = 20,
    debuffSize = 24,
    
    -- Special Units
    bossNameplateScale = 1.2,
    rareNameplateScale = 1.1,
    friendlyNameplateScale = 0.9,
    
    -- Additional Options
    showResourceOnTarget = true,
    nameOnlyOnFriendly = true,
    clickThroughUnattackable = true,
    classColoredHealthbar = true,
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
    
    -- Apply other styling as needed
end

-- Determine unit type (boss, rare, etc.)
function PlaterService:GetUnitType(unitFrame)
    if not unitFrame or not unitFrame.displayedUnit then return "NORMAL" end
    
    local unit = unitFrame.displayedUnit
    
    -- Check if it's a boss
    if UnitClassification(unit) == "worldboss" or UnitClassification(unit) == "elite" and UnitLevel(unit) == -1 then
        return "BOSS"
    end
    
    -- Check if it's a rare
    if UnitClassification(unit) == "rare" or UnitClassification(unit) == "rareelite" then
        return "RARE"
    end
    
    -- Check if it's friendly
    if not UnitCanAttack("player", unit) then
        return "FRIENDLY"
    end
    
    return "NORMAL"
end

-- Style boss nameplates
function PlaterService:StyleBossNameplate(unitFrame)
    local settings = M.db.profile
    
    -- Apply boss-specific styling
    if settings.bossNameplateScale and settings.bossNameplateScale ~= 1.0 then
        unitFrame:SetScale(settings.bossNameplateScale)
    end
end

-- Style rare nameplates
function PlaterService:StyleRareNameplate(unitFrame)
    local settings = M.db.profile
    
    -- Apply rare-specific styling
    if settings.rareNameplateScale and settings.rareNameplateScale ~= 1.0 then
        unitFrame:SetScale(settings.rareNameplateScale)
    end
end

-- Style friendly nameplates
function PlaterService:StyleFriendlyNameplate(unitFrame)
    local settings = M.db.profile
    
    -- Apply friendly-specific styling
    if settings.friendlyNameplateScale and settings.friendlyNameplateScale ~= 1.0 then
        unitFrame:SetScale(settings.friendlyNameplateScale)
    end
    
    -- Apply name-only mode for friendly units if enabled
    if settings.nameOnlyOnFriendly then
        self:ApplyNameOnlyMode(unitFrame)
    end
end

-- Style enemy nameplates
function PlaterService:StyleEnemyNameplate(unitFrame)
    -- Apply enemy-specific styling
    -- TODO: Implement enemy nameplates styling
end

-- Apply name-only mode to a unit frame
function PlaterService:ApplyNameOnlyMode(unitFrame)
    if not unitFrame then return end
    
    -- Hide health bar
    if unitFrame.healthBar then
        unitFrame.healthBar:Hide()
    end
    
    -- Hide cast bar
    if unitFrame.castBar then
        unitFrame.castBar:Hide()
    end
    
    -- Position name text appropriately
    if unitFrame.name then
        unitFrame.name:ClearAllPoints()
        unitFrame.name:SetPoint("CENTER", unitFrame, "CENTER", 0, 0)
    end
end

-- Return the service object
return PlaterService