local addonName, VUI = ...

-- Create a module using the ModuleAPI
local moduleName = "bags"
local module = VUI.ModuleAPI:CreateModule(moduleName)

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

-- Local variables
local activeTheme = "thunderstorm"
local themeColors = {}

function module:OnInitialize()
    -- Initialize settings with defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings(moduleName, defaults)
    
    -- Set enabled state based on settings
    self:SetEnabledState(self.settings.enabled)
    
    -- Get current theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    activeTheme = theme
    themeColors = VUI.media.themes[theme] or {}
    
    -- Register for events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    
    -- Register for theme changes
    VUI.RegisterCallback(self, "ThemeChanged", "ApplyTheme")
end

function module:OnEnable()
    self:HookBagFunctions()
    self:ApplyTheme(activeTheme)
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

function module:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Update all bags with new theme
    self:UpdateAllBags()
end

-- Additional module functions will be in core.lua