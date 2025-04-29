local _, VUI = ...
local Nameplates = VUI.nameplates

-- CVars management for VUI Plater nameplate system
Nameplates.cvars = {}
local CVars = Nameplates.cvars

-- Table of CVars we want to manage
CVars.managedVars = {
    -- Core nameplate CVars
    ["nameplateShowAll"] = "1",
    ["nameplateShowEnemies"] = "1",
    ["nameplateShowFriends"] = "1",
    ["nameplateShowSelf"] = "0", -- Hide personal resource bar

    -- Size and position CVars
    ["nameplateSelectedScale"] = "1.15",
    ["nameplateMinScale"] = "0.8",
    ["nameplateMaxScale"] = "1.0",
    ["nameplateMinAlpha"] = "0.8",
    ["nameplateMaxAlpha"] = "1.0",
    ["nameplateMinAlphaDistance"] = "10",
    ["nameplateMaxAlphaDistance"] = "40",
    ["nameplateOverlapH"] = "0.8",
    ["nameplateOverlapV"] = "1.1",
    
    -- Stacking CVars
    ["nameplateMotion"] = "1", -- 0 for overlap, 1 for stacking
    ["nameplateMotionSpeed"] = "0.025",
    
    -- Distance CVars
    ["nameplateMaxDistance"] = "60", -- Maximum viewing distance
    ["nameplateTargetBehindMaxDistance"] = "30",
    
    -- Visibility CVars
    ["nameplateShowOnlyNames"] = "0", -- Show full nameplates, not just names
    ["nameplateShowDebuffsOnFriendly"] = "1",
    
    -- Combat behavior
    ["nameplateShowEnemyMinus"] = "1", -- Show minor enemies
    ["nameplateShowEnemyMinions"] = "1", -- Show enemy pets
    ["nameplateShowFriendlyNPCs"] = "1", -- Show friendly NPCs
    ["nameplateShowFriendlyMinions"] = "1", -- Show friendly pets
    ["nameplateShowFriendlyGuardians"] = "1", -- Show friendly guardians
    
    -- Nameplate clicks
    ["nameplateTargetableOffScreen"] = "1", -- Allow clicking on offscreen nameplates
    ["NamePlateHorizontalScale"] = "1",
    ["NamePlateVerticalScale"] = "1",
    
    -- Class resources
    ["nameplateResourceOnTarget"] = "0", -- Hide class resource widgets
    
    -- Advanced options
    ["nameplateOtherBottomInset"] = "0.1",
    ["nameplateOtherTopInset"] = "0.08",
    ["nameplateLargeBottomInset"] = "0.15",
    ["nameplateLargeTopInset"] = "0.1",
    ["nameplateClassResourceTopInset"] = "0.04",
    ["clampTargetNameplateToScreen"] = "1",
    ["ShowClassColorInNameplate"] = "1"
}

-- Initialize the customized CVars
function CVars:Initialize()
    -- Skip if they've already been loaded
    if Nameplates.settings.cvarsLoaded then
        return
    end
    
    -- Store original CVars for later restoration if needed
    if not Nameplates.originalCVars then
        Nameplates.originalCVars = {}
        for cvar, _ in pairs(self.managedVars) do
            Nameplates.originalCVars[cvar] = GetCVar(cvar)
        end
    end
    
    -- Apply our custom CVars
    self:Apply()
    
    -- Mark as loaded
    Nameplates.settings.cvarsLoaded = true
end

-- Apply all managed CVars
function CVars:Apply()
    for cvar, value in pairs(self.managedVars) do
        SetCVar(cvar, value)
    end
    
    -- Apply user's custom sizes if using custom styling
    if Nameplates.settings.styling == "plater" or Nameplates.settings.styling == "custom" then
        -- Size settings
        if Nameplates.settings.friendlySize then
            C_NamePlate.SetNamePlateFriendlySize(
                Nameplates.settings.plateWidth * Nameplates.settings.friendlySize, 
                Nameplates.settings.plateHeight * Nameplates.settings.friendlySize
            )
        end
        
        if Nameplates.settings.enemySize then
            C_NamePlate.SetNamePlateEnemySize(
                Nameplates.settings.plateWidth * Nameplates.settings.enemySize, 
                Nameplates.settings.plateHeight * Nameplates.settings.enemySize
            )
        end
        
        -- Alpha settings
        if Nameplates.settings.friendlyAlpha then
            SetCVar("nameplateMinAlpha", Nameplates.settings.friendlyAlpha)
        end
        
        if Nameplates.settings.enemyAlpha then
            SetCVar("nameplateMaxAlpha", Nameplates.settings.enemyAlpha)
        end
        
        -- Clickthrough settings
        if Nameplates.settings.clickthrough ~= nil then
            C_NamePlate.SetNamePlateFriendlyClickThrough(Nameplates.settings.clickthrough)
            C_NamePlate.SetNamePlateEnemyClickThrough(Nameplates.settings.clickthrough)
        end
        
        -- Stacking settings
        if Nameplates.settings.stackingNameplates ~= nil then
            SetCVar("nameplateMotion", Nameplates.settings.stackingNameplates and "1" or "0")
        end
    end
end

-- Restore original CVars
function CVars:RestoreOriginal()
    if Nameplates.originalCVars then
        for cvar, value in pairs(Nameplates.originalCVars) do
            SetCVar(cvar, value)
        end
    end
    
    -- Reset sizes
    C_NamePlate.SetNamePlateFriendlySize(110, 45) -- Default Blizzard sizes
    C_NamePlate.SetNamePlateEnemySize(110, 45)    -- Default Blizzard sizes
    
    -- Mark as not loaded
    Nameplates.settings.cvarsLoaded = false
end

-- Set specific CVar with a custom value
function CVars:Set(cvar, value)
    if self.managedVars[cvar] then
        self.managedVars[cvar] = value
        SetCVar(cvar, value)
    end
end