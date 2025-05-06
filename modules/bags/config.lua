local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

local moduleName = "bags"
local module = VUI[moduleName]

function module:GetConfig()
    local config = {
        name = "Bags",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Enhanced Bags",
                desc = "Enable or disable the Enhanced Bags module",
                get = function() return self.settings.enabled end,
                set = function(_, value) 
                    self.settings.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                    VUI.db.profile.modules[moduleName].enabled = value
                end,
                order = 1
            },
            combineAllBags = {
                type = "toggle",
                name = "Combine All Bags",
                desc = "Show all bags in a single window",
                get = function() return self.settings.combineAllBags end,
                set = function(_, value) 
                    self.settings.combineAllBags = value
                    VUI.db.profile.modules[moduleName].combineAllBags = value
                    self:UpdateAllBags()
                end,
                order = 2
            },
            showItemLevel = {
                type = "toggle",
                name = "Show Item Level",
                desc = "Display item level on equipment",
                get = function() return self.settings.showItemLevel end,
                set = function(_, value) 
                    self.settings.showItemLevel = value
                    VUI.db.profile.modules[moduleName].showItemLevel = value
                    self:UpdateAllBags()
                end,
                order = 3
            },
            showItemBorders = {
                type = "toggle",
                name = "Show Item Borders",
                desc = "Display colored borders around items based on quality",
                get = function() return self.settings.showItemBorders end,
                set = function(_, value) 
                    self.settings.showItemBorders = value
                    VUI.db.profile.modules[moduleName].showItemBorders = value
                    self:UpdateAllBags()
                end,
                order = 4
            },
            colorItemBorders = {
                type = "toggle",
                name = "Color Item Borders",
                desc = "Color borders based on item quality",
                get = function() return self.settings.colorItemBorders end,
                set = function(_, value) 
                    self.settings.colorItemBorders = value
                    VUI.db.profile.modules[moduleName].colorItemBorders = value
                    self:UpdateAllBags()
                end,
                order = 5
            },
            compactLayout = {
                type = "toggle",
                name = "Compact Layout",
                desc = "Use a more compact layout for the bag frames",
                get = function() return self.settings.compactLayout end,
                set = function(_, value) 
                    self.settings.compactLayout = value
                    VUI.db.profile.modules[moduleName].compactLayout = value
                    self:UpdateAllBags()
                end,
                order = 6
            },
            itemLevelThreshold = {
                type = "range",
                name = "Item Level Threshold",
                desc = "Only show item level for items with this level or higher",
                min = 1,
                max = 300,
                step = 1,
                get = function() return self.settings.itemLevelThreshold end,
                set = function(_, value) 
                    self.settings.itemLevelThreshold = value
                    VUI.db.profile.modules[moduleName].itemLevelThreshold = value
                    self:UpdateAllBags()
                end,
                order = 7
            },
            enhancedSearch = {
                type = "toggle",
                name = "Enhanced Search",
                desc = "Enable enhanced search features for bags",
                get = function() return self.settings.enhancedSearch end,
                set = function(_, value) 
                    self.settings.enhancedSearch = value
                    VUI.db.profile.modules[moduleName].enhancedSearch = value
                    self:UpdateAllBags()
                end,
                order = 8
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig(moduleName, module:GetConfig())