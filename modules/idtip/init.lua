-- VUI idtip Module Initialization
local _, VUI = ...

-- Create module
VUI.idtip = {}

-- Default settings
VUI.idtip.defaults = {
    enabled = true,
    showSpellID = true,
    showItemID = true,
    showCurrencyID = true,
    showAchievementID = true,
    showQuestID = true,
    showTalentID = true,
    showCovenantID = true,
    showTraitID = true,
    showEnhancedTooltip = true,
    colorCodedIDs = true
}

-- Get configuration options for main UI integration
function VUI.idtip:GetConfig()
    local config = {
        name = "idTip",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable idTip",
                desc = "Enable or disable the idTip module",
                get = function() return VUI.db.profile.modules.idtip.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.idtip.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            showSpellID = {
                type = "toggle",
                name = "Show Spell IDs",
                desc = "Show spell IDs in tooltips",
                get = function() return VUI.db.profile.modules.idtip.showSpellID end,
                set = function(_, value) 
                    VUI.db.profile.modules.idtip.showSpellID = value
                end,
                order = 2
            },
            showItemID = {
                type = "toggle",
                name = "Show Item IDs",
                desc = "Show item IDs in tooltips",
                get = function() return VUI.db.profile.modules.idtip.showItemID end,
                set = function(_, value) 
                    VUI.db.profile.modules.idtip.showItemID = value
                end,
                order = 3
            },
            colorCodedIDs = {
                type = "toggle",
                name = "Color-Coded IDs",
                desc = "Show IDs with theme-based color coding",
                get = function() return VUI.db.profile.modules.idtip.colorCodedIDs end,
                set = function(_, value) 
                    VUI.db.profile.modules.idtip.colorCodedIDs = value
                end,
                order = 4
            },
            showEnhancedTooltip = {
                type = "toggle",
                name = "Enhanced Tooltips",
                desc = "Show additional information in tooltips",
                get = function() return VUI.db.profile.modules.idtip.showEnhancedTooltip end,
                set = function(_, value) 
                    VUI.db.profile.modules.idtip.showEnhancedTooltip = value
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("idtip", VUI.idtip:GetConfig())

-- Initialize module
function VUI.idtip:Initialize()
    -- Initialize module components
    self:SetupHooks()

    -- Print initialization message
    VUI:Print("idTip module initialized")
    
    -- Enable if set in profile
    if VUI.db.profile.modules.idtip.enabled then
        self:Enable()
    end
end

-- Enable module
function VUI.idtip:Enable()
    self.enabled = true
    
    -- Apply hooks and show frames
    self:ApplyHooks()
    
    VUI:Print("idTip module enabled")
end

-- Disable module
function VUI.idtip:Disable()
    self.enabled = false
    
    -- Remove hooks and hide frames
    self:RemoveHooks()
    
    VUI:Print("idTip module disabled")
end

-- Set up hooks for this module
function VUI.idtip:SetupHooks()
    -- Define hooks but don't apply them yet
end

-- Apply hooks
function VUI.idtip:ApplyHooks()
    if not self.enabled then return end
    -- Apply the hooks defined in SetupHooks
end

-- Remove hooks
function VUI.idtip:RemoveHooks()
    -- Remove any applied hooks
end
