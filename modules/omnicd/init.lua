-- VUI omnicd Module Initialization
local _, VUI = ...

-- Create module
VUI.omnicd = {}

-- Default settings
VUI.omnicd.defaults = {
    enabled = true,
    animations = true,
    growDirection = "RIGHT",
    iconSize = 30,
    iconSpacing = 2,
    maxIcons = 10,
    showNames = true,
    position = {"TOPLEFT", "CENTER", 0, 150},
    spellFilters = {},
    performance = {
        disableAnimationsInCombat = false
    }
}

-- Initialize module
function VUI.omnicd:Initialize()
    -- Initialize settings
    self.db = VUI.db.profile.modules.omnicd
    
    -- Initialize module components
    self:SetupModule()
    self:SetupHooks()
    self:InitializeAnimations()

    -- Print initialization message
    VUI:Print("OmniCD module initialized")
    
    -- Register for theme changes
    VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
        self:UpdateThemeAnimations()
    end)
    
    -- Set up performance monitor
    self:SetupPerformanceMonitoring()
    
    -- Enable if set in profile
    if self.db.enabled then
        self:Enable()
    end
end

-- Enable module
function VUI.omnicd:Enable()
    self.enabled = true
    
    -- Apply hooks and show frames
    self:ApplyHooks()
    
    -- Initialize animations
    self:InitializeAnimations()
    
    VUI:Print("OmniCD module enabled")
end

-- Disable module
function VUI.omnicd:Disable()
    self.enabled = false
    
    -- Remove hooks and hide frames
    self:RemoveHooks()
    
    -- Hide all icons
    if self.iconFrames then
        for _, frame in ipairs(self.iconFrames) do
            frame:Hide()
        end
    end
    
    VUI:Print("OmniCD module disabled")
end

-- Set up hooks for this module
function VUI.omnicd:SetupHooks()
    -- Define hooks but don't apply them yet
end

-- Apply hooks
function VUI.omnicd:ApplyHooks()
    if not self.enabled then return end
    -- Apply the hooks defined in SetupHooks
end

-- Remove hooks
function VUI.omnicd:RemoveHooks()
    -- Remove any applied hooks
end

-- Set up performance monitoring
function VUI.omnicd:SetupPerformanceMonitoring()
    -- Create frame for monitoring combat state
    self.performanceMonitor = CreateFrame("Frame")
    
    -- Register for combat events
    self.performanceMonitor:RegisterEvent("PLAYER_REGEN_DISABLED")  -- Entering combat
    self.performanceMonitor:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Leaving combat
    
    -- Event handler
    self.performanceMonitor:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            -- Entering combat
            if self.db.performance.disableAnimationsInCombat then
                self:DisableAnimations()
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            -- Leaving combat
            if self.db.performance.disableAnimationsInCombat then
                self:EnableAnimations()
            end
        end
    end)
end

-- Temporarily disable animations for performance
function VUI.omnicd:DisableAnimations()
    self.animationsDisabled = true
    
    -- Stop any running animations
    if self.iconFrames then
        for _, frame in ipairs(self.iconFrames) do
            if frame.animations then
                for _, anim in pairs(frame.animations) do
                    if anim:IsPlaying() then
                        anim:Stop()
                    end
                end
            end
            
            if frame.themeElements then
                for _, element in pairs(frame.themeElements) do
                    if element.animGroup and element.animGroup:IsPlaying() then
                        element.animGroup:Stop()
                    end
                    if element.texture then
                        element.texture:Hide()
                    end
                end
            end
        end
    end
end

-- Re-enable animations
function VUI.omnicd:EnableAnimations()
    self.animationsDisabled = false
    
    -- Apply theme animations if needed
    self:UpdateThemeAnimations()
end
