-- VUI angrykeystone Module Initialization
local _, VUI = ...

-- Create module
VUI.angrykeystone = {}

-- Default settings
VUI.angrykeystone.defaults = {
    enabled = true,
    showObjectiveTracker = true,
    showEnemyCounter = true,
    showChestTimer = true,
    showDeathCounter = true,
    showKeystoneInfo = true,
    timerFormat = "mm:ss",
    progressFormat = "percent",
    announceProgress = false,
    showForces = true,
    showPercentage = true,
    customStyle = "thunderstorm"
}

-- Get configuration options for main UI integration
function VUI.angrykeystone:GetConfig()
    local config = {
        name = "AngryKeystones",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable AngryKeystones",
                desc = "Enable or disable the AngryKeystones module",
                get = function() return VUI.db.profile.modules.angrykeystone.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            showObjectiveTracker = {
                type = "toggle",
                name = "Show Objective Tracker",
                desc = "Show enhanced objective tracker during Mythic+ dungeons",
                get = function() return VUI.db.profile.modules.angrykeystone.showObjectiveTracker end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.showObjectiveTracker = value
                    self:RefreshSettings()
                end,
                order = 2
            },
            showEnemyCounter = {
                type = "toggle",
                name = "Show Enemy Forces",
                desc = "Show enemy forces percentage and count",
                get = function() return VUI.db.profile.modules.angrykeystone.showEnemyCounter end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.showEnemyCounter = value
                    self:RefreshSettings()
                end,
                order = 3
            },
            showChestTimer = {
                type = "toggle",
                name = "Show Chest Timer",
                desc = "Show time remaining for each chest/medal tier",
                get = function() return VUI.db.profile.modules.angrykeystone.showChestTimer end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.showChestTimer = value
                    self:RefreshSettings()
                end,
                order = 4
            },
            timerFormat = {
                type = "select",
                name = "Timer Format",
                desc = "Format for displaying the timer",
                values = {
                    ["mm:ss"] = "MM:SS",
                    ["mmss"] = "MMSS",
                    ["full"] = "Full Time"
                },
                get = function() return VUI.db.profile.modules.angrykeystone.timerFormat end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.timerFormat = value
                    self:RefreshSettings()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("angrykeystone", VUI.angrykeystone:GetConfig())

-- Initialize module
function VUI.angrykeystone:Initialize()
    -- Initialize module components
    self:SetupHooks()

    -- Print initialization message
    VUI:Print("AngryKeystones module initialized")
    
    -- Enable if set in profile
    if VUI.db.profile.modules.angrykeystone.enabled then
        self:Enable()
    end
end

-- Enable module
function VUI.angrykeystone:Enable()
    self.enabled = true
    
    -- Apply hooks and show frames
    self:ApplyHooks()
    
    VUI:Print("AngryKeystones module enabled")
end

-- Disable module
function VUI.angrykeystone:Disable()
    self.enabled = false
    
    -- Remove hooks and hide frames
    self:RemoveHooks()
    
    VUI:Print("AngryKeystones module disabled")
end

-- Set up hooks for this module
function VUI.angrykeystone:SetupHooks()
    -- Define hooks but don't apply them yet
end

-- Apply hooks
function VUI.angrykeystone:ApplyHooks()
    if not self.enabled then return end
    -- Apply the hooks defined in SetupHooks
end

-- Remove hooks
function VUI.angrykeystone:RemoveHooks()
    -- Remove any applied hooks
end
