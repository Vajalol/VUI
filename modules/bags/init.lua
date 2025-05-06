local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create a module using the ModuleAPI
local moduleName = "bags"
local module = VUI.ModuleAPI:CreateModule(moduleName)

-- Export module to global VUI namespace
VUI.bags = module

-- Default settings
local defaults = {
    enabled = true,
    combineAllBags = true,
    showItemLevel = true,
    showItemBorders = true,
    colorItemBorders = true,
    compactLayout = false,
    itemLevelThreshold = 1,
    enhancedSearch = true,
    bagSlotOrder = {0, 1, 2, 3, 4}  -- Main bag (0) and additional bags 1-4
}

function module:OnInitialize()
    -- Initialize settings with defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings(moduleName, defaults)
    
    -- Set enabled state based on settings
    self:SetEnabledState(self.settings.enabled)
    
    -- Register for events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    
    -- Initialize ThemeIntegration module
    -- ThemeIntegration will be loaded from ThemeIntegration.lua
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
end

function module:OnEnable()
    self:HookBagFunctions()
    
    -- Apply theme via ThemeIntegration
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme()
    end
    
    self:UpdateAllBags()
end

function module:OnDisable()
    -- Hide and reset frames if needed
end

function module:ADDON_LOADED(event, addon)
    if addon == "Blizzard_GuildBankUI" then
        self:HookGuildBank()
    end
end

function module:PLAYER_ENTERING_WORLD()
    self:UpdateAllBags()
end

function module:BAG_UPDATE()
    self:UpdateAllBags()
end

-- Theme handling is now delegated to ThemeIntegration
function module:ApplyTheme(theme)
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme(theme)
    else
        -- Fallback if ThemeIntegration isn't available yet
        self:UpdateAllBags()
    end
end

-- Additional module functions will be in core.lua