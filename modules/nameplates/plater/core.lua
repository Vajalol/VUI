local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Nameplates = VUI.nameplates

-- VUI Plater Core Implementation
Nameplates.plater = {}
local Plater = Nameplates.plater

-- Initialize the VUI Plater nameplates
function Plater:Initialize()
    -- Setup internal structures
    self:SetupInternals()
    
    -- Import WhiiskeyZ profile from wago.io/whiiskeyzplater
    if not VUI.db.char.whiiskeyzProfileImported then
        C_Timer.After(2, function() 
            self:ImportWhiiskeyZProfile()
            VUI.db.char.whiiskeyzProfileImported = true
        end)
    end
    
    -- Initialize all components
    self:InitializeComponents()
    
    -- Register events
    self:RegisterEvents()
    
    VUI:Print("VUI Plater nameplates initialized with exact WhiiskeyZ profile from wago.io/whiiskeyzplater")
end

-- Setup internal structures
function Plater:SetupInternals()
    -- Current theme tracking
    self.currentTheme = VUI.db.profile.core.theme or "thunderstorm"
    
    -- Plate tracking
    self.activePlates = {}
    
    -- Create frame for events
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:Hide()
    end
    
    -- Create update frame
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
        self.updateFrame:Hide()
    end
end

-- Initialize all the components of Plater
function Plater:InitializeComponents()
    -- Load CVars
    Nameplates.cvars:Initialize()
    
    -- Initialize auras system
    Nameplates.auras:Initialize()
    
    -- Initialize scripts
    Nameplates.scripts:Initialize()
    
    -- Initialize hooks
    Nameplates.hooks:Initialize()
    
    -- Initialize specific components
    self:InitializeHealthBars()
    self:InitializeCastBars()
    self:InitializeAuraBars()
    self:InitializeResourceBars()
    self:InitializeTextElements()
    self:InitializeIndicators()
end

-- Register necessary events
function Plater:RegisterEvents()
    -- Clear previous events
    self.eventFrame:UnregisterAllEvents()
    
    -- Register required events
    self.eventFrame:RegisterEvent("PLAYER_LOGIN")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    self.eventFrame:RegisterEvent("UNIT_AURA")
    self.eventFrame:RegisterEvent("UNIT_HEALTH")
    self.eventFrame:RegisterEvent("UNIT_MAXHEALTH")
    self.eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
    self.eventFrame:RegisterEvent("UNIT_FACTION")
    self.eventFrame:RegisterEvent("UNIT_LEVEL")
    self.eventFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
    self.eventFrame:RegisterEvent("RAID_TARGET_UPDATE")
    
    -- Set up event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    -- Create OnUpdate for performance-critical updates
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
    
    -- Show the frames to enable processing
    self.eventFrame:Show()
    self.updateFrame:Show()
end

-- Initialize health bars
function Plater:InitializeHealthBars()
    -- Set up health bar defaults
    local defaultBarTexture = Nameplates.settings.healthBarTexture or "VUI_Smooth"
    
    -- Hook Blizzard's health bar updates
    hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
        -- Only apply to nameplates
        if not frame.namePlateUnitToken then return end
        
        if Nameplates.enabled and Nameplates.settings.styling == "plater" then
            -- Get color from our utilities
            local color = Nameplates.utils:GetHealthColor(frame.namePlateUnitToken, frame)
            if color then
                frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
    end)
    
    -- Hook health bar creation/setup
    hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
        -- Only apply to nameplates
        if not frame.namePlateUnitToken then return end
        
        if Nameplates.enabled and Nameplates.settings.styling == "plater" then
            -- Set statusbar texture
            frame.healthBar:SetStatusBarTexture(defaultBarTexture)
            
            -- Apply theme colors if enabled
            if Nameplates.settings.useThemeColors then
                Nameplates.utils:ApplyThemeColors(frame.healthBar, "healthBar")
            end
            
            -- Apply border if specified
            if Nameplates.settings.healthBarBorderType and Nameplates.settings.healthBarBorderType ~= "none" then
                Nameplates.hooks:ApplyBorder(frame.healthBar, Nameplates.settings.healthBarBorderType)
            end
        end
    end)
end

-- Initialize cast bars
function Plater:InitializeCastBars()
    -- Don't do anything if castbars are disabled
    if not Nameplates.settings.showCastbars then
        return
    end
    
    -- Set up cast bar defaults
    local defaultBarTexture = Nameplates.settings.castBarTexture or "VUI_Smooth"
    
    -- Hook Blizzard's cast bar updates
    hooksecurefunc("CompactUnitFrame_UpdateCastingInfo", function(frame)
        -- Only apply to nameplates
        if not frame.namePlateUnitToken then return end
        
        if Nameplates.enabled and Nameplates.settings.styling == "plater" and frame.castBar then
            -- Set texture
            frame.castBar:SetStatusBarTexture(defaultBarTexture)
            
            -- Apply color based on interruptible status
            local notInterruptible = false
            if frame.castBar.notInterruptible ~= nil then
                notInterruptible = frame.castBar.notInterruptible
            end
            
            local color = Nameplates.utils:GetCastBarColor(frame.namePlateUnitToken, not notInterruptible)
            if color then
                frame.castBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1.0)
            end
            
            -- Apply theme colors if enabled
            if Nameplates.settings.useThemeColors then
                Nameplates.utils:ApplyThemeColors(frame.castBar, "castBar")
            end
            
            -- Apply border if specified
            if Nameplates.settings.healthBarBorderType and Nameplates.settings.healthBarBorderType ~= "none" then
                Nameplates.hooks:ApplyBorder(frame.castBar, Nameplates.settings.healthBarBorderType)
            end
        end
    end)
end

-- Initialize aura bars
function Plater:InitializeAuraBars()
    -- Don't do anything if auras are disabled
    if not Nameplates.settings.showAuras then
        return
    end
    
    -- Hook into plate creation to set up aura containers
    hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
        -- Only apply to nameplates
        if not frame.namePlateUnitToken then return end
        
        if Nameplates.enabled and Nameplates.settings.styling == "plater" then
            -- Ensure aura container exists
            if not frame.VUIAuraContainer then
                frame.VUIAuraContainer = CreateFrame("Frame", nil, frame)
                frame.VUIAuraContainer:SetSize(Nameplates.settings.plateWidth, Nameplates.settings.auraSize)
                frame.VUIAuraContainer:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4)
            end
        end
    end)
end

-- Initialize resource bars
function Plater:InitializeResourceBars()
    -- These are the special resource bars for player-class resources (combo points, etc.)
    -- No implementation needed for initial version
end

-- Initialize text elements
function Plater:InitializeTextElements()
    -- Hook into name text updates
    hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
        -- Only apply to nameplates
        if not frame.namePlateUnitToken then return end
        
        if Nameplates.enabled and Nameplates.settings.styling == "plater" and frame.name then
            -- Set font
            frame.name:SetFont(Nameplates.settings.nameTextFont or "VUI PT Sans Narrow", 
                              Nameplates.settings.nameTextSize or 10,
                              Nameplates.settings.nameTextOutline or "OUTLINE")
            
            -- Make sure name is visible
            frame.name:Show()
        end
    end)
end

-- Initialize indicators (target, focus, threat, execute)
function Plater:InitializeIndicators()
    -- Most of this is handled in hooks.lua
    -- This function could be expanded later
end

-- PLAYER_LOGIN event
function Plater:PLAYER_LOGIN()
    -- Initialize the nameplates system
    self:Initialize()
    
    -- Apply settings to existing nameplates
    Nameplates.hooks:HookExistingNameplates()
end

-- PLAYER_ENTERING_WORLD event
function Plater:PLAYER_ENTERING_WORLD()
    -- Re-apply settings in case game UI reloaded
    self:Initialize()
    
    -- Apply settings to existing nameplates
    Nameplates.hooks:HookExistingNameplates()
end

-- OnUpdate handler for frequent plate updates
function Plater:OnUpdate(elapsed)
    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
    if self.timeSinceLastUpdate < 0.1 then
        return
    end
    self.timeSinceLastUpdate = 0
    
    -- Skip if disabled or wrong style
    if not Nameplates.enabled or Nameplates.settings.styling ~= "plater" then
        return
    end
    
    -- Update all visible nameplates
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            -- Update all aspects of the nameplate
            self:UpdateNameplate(namePlate)
        end
    end
end

-- Update a single nameplate
function Plater:UpdateNameplate(namePlate)
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    
    -- Update health text
    Nameplates.hooks:UpdateHealthText(namePlate)
    
    -- Update auras
    Nameplates.auras:UpdateAuras(unitFrame)
    
    -- Run user custom update script if enabled
    if Nameplates.settings.useUpdateHook and Nameplates.settings.customScripts.updatePlate then
        Nameplates.hooks:RunCustomScript("updatePlate", namePlate, unit)
    end
end

-- Reload all plates with new settings
function Plater:ReloadPlates()
    -- Reset CVars
    Nameplates.cvars:Apply()
    
    -- Update all hooks
    Nameplates.hooks:Initialize()
    
    -- Force update all existing nameplates
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            namePlate.UnitFrame.VUIPlaterStyled = nil -- Reset styled flag
            Nameplates.hooks:StylePlate(namePlate) -- Re-style the plate
            self:UpdateNameplate(namePlate) -- Update the plate
        end
    end
end

-- Apply current VUI theme to nameplate elements
function Plater:ApplyTheme(theme)
    -- Update internal tracking
    self.currentTheme = theme or VUI.db.profile.core.theme
    
    -- Only proceed if theme colors are enabled
    if not Nameplates.settings.useThemeColors then
        return
    end
    
    -- Force update all existing nameplates
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            -- Apply theme colors to health bar
            if namePlate.UnitFrame.healthBar then
                Nameplates.utils:ApplyThemeColors(namePlate.UnitFrame.healthBar, "healthBar")
            end
            
            -- Apply theme colors to cast bar
            if namePlate.UnitFrame.castBar then
                Nameplates.utils:ApplyThemeColors(namePlate.UnitFrame.castBar, "castBar")
            end
        end
    end
end