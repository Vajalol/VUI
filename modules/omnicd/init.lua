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
    },
    -- New theme-related settings
    honorTheme = true,
    effectBrightness = 1.0,
    playReadySound = true,
    
    -- New cooldown group settings
    enableGroups = true,
    showCooldownText = true,
    showCooldownSpiral = true,
    showCooldownBars = true,
    cooldownBarWidth = 80,
    cooldownTextSize = 12,
    prioritizeInterrupts = true,
    highlightImportantCooldowns = true
}

-- Get configuration options for main UI integration
function VUI.omnicd:GetConfig()
    local config = {
        name = "OmniCD",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable OmniCD",
                desc = "Enable or disable the OmniCD module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            generalGroup = {
                type = "group",
                name = "General",
                desc = "General settings",
                inline = true,
                order = 2,
                args = {
                    animations = {
                        type = "toggle",
                        name = "Show Animations",
                        desc = "Enable or disable cooldown animations",
                        get = function() return self.db.animations end,
                        set = function(_, value) 
                            self.db.animations = value
                            if value then
                                self:EnableAnimations()
                            else
                                self:DisableAnimations()
                            end
                        end,
                        order = 1
                    },
                    iconSize = {
                        type = "range",
                        name = "Icon Size",
                        desc = "Size of cooldown icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        get = function() return self.db.iconSize end,
                        set = function(_, value)
                            self.db.iconSize = value
                            self:UpdateDisplay()
                        end,
                        order = 2
                    },
                    showNames = {
                        type = "toggle",
                        name = "Show Names",
                        desc = "Show spell names under icons",
                        get = function() return self.db.showNames end,
                        set = function(_, value)
                            self.db.showNames = value
                            self:UpdateDisplay()
                        end,
                        order = 3
                    },
                    maxIcons = {
                        type = "range",
                        name = "Maximum Icons",
                        desc = "Maximum number of cooldown icons to display",
                        min = 5,
                        max = 20,
                        step = 1,
                        get = function() return self.db.maxIcons end,
                        set = function(_, value)
                            self.db.maxIcons = value
                            self:UpdateDisplay()
                        end,
                        order = 4
                    }
                }
            },
            themeGroup = {
                type = "group",
                name = "Theme Settings",
                desc = "Theme-specific settings",
                inline = true,
                order = 3,
                args = {
                    honorTheme = {
                        type = "toggle",
                        name = "Honor VUI Theme",
                        desc = "Apply the current VUI theme to cooldown displays",
                        get = function() return self.db.honorTheme end,
                        set = function(_, value)
                            self.db.honorTheme = value
                            self:UpdateAllUIWithTheme()
                        end,
                        order = 1
                    },
                    effectBrightness = {
                        type = "range",
                        name = "Effect Brightness",
                        desc = "Brightness of cooldown effects",
                        min = 0.1,
                        max = 2.0,
                        step = 0.1,
                        get = function() return self.db.effectBrightness end,
                        set = function(_, value)
                            self.db.effectBrightness = value
                            self:UpdateAllUIWithTheme()
                        end,
                        order = 2
                    },
                    playReadySound = {
                        type = "toggle",
                        name = "Play Ready Sound",
                        desc = "Play a sound when a cooldown is ready",
                        get = function() return self.db.playReadySound end,
                        set = function(_, value)
                            self.db.playReadySound = value
                        end,
                        order = 3
                    }
                }
            },
            cooldownGroup = {
                type = "group",
                name = "Cooldown Groups",
                desc = "Cooldown grouping settings",
                inline = true,
                order = 4,
                args = {
                    enableGroups = {
                        type = "toggle",
                        name = "Enable Groups",
                        desc = "Organize cooldowns into priority groups",
                        get = function() return self.db.enableGroups end,
                        set = function(_, value)
                            self.db.enableGroups = value
                            self:UpdateCooldownIconsByGroups()
                        end,
                        order = 1
                    },
                    showCooldownText = {
                        type = "toggle",
                        name = "Show Cooldown Text",
                        desc = "Show countdown text on cooldowns",
                        get = function() return self.db.showCooldownText end,
                        set = function(_, value)
                            self.db.showCooldownText = value
                            self:UpdateDisplay()
                        end,
                        order = 2
                    },
                    showCooldownBars = {
                        type = "toggle",
                        name = "Show Cooldown Bars",
                        desc = "Show progress bars for cooldowns",
                        get = function() return self.db.showCooldownBars end,
                        set = function(_, value)
                            self.db.showCooldownBars = value
                            self:UpdateDisplay()
                        end,
                        order = 3
                    },
                    cooldownBarWidth = {
                        type = "range",
                        name = "Bar Width",
                        desc = "Width of cooldown progress bars",
                        min = 40,
                        max = 150,
                        step = 5,
                        get = function() return self.db.cooldownBarWidth end,
                        set = function(_, value)
                            self.db.cooldownBarWidth = value
                            self:UpdateDisplay()
                        end,
                        order = 4
                    },
                    prioritizeInterrupts = {
                        type = "toggle",
                        name = "Prioritize Interrupts",
                        desc = "Give higher priority to interrupt cooldowns",
                        get = function() return self.db.prioritizeInterrupts end,
                        set = function(_, value)
                            self.db.prioritizeInterrupts = value
                            self:UpdateCooldownIconsByGroups()
                        end,
                        order = 5
                    }
                }
            },
            configButton = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open detailed configuration panel",
                func = function()
                    -- This would open a detailed config panel
                    -- For now we'll just toggle the anchor visibility
                    if self.anchor then
                        self.anchor:SetShown(not self.anchor:IsShown())
                    end
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("omnicd", VUI.omnicd:GetConfig())

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
