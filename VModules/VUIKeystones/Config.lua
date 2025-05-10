-- VUIKeystones - Configuration handling
local VUIKeystones = LibStub("AceAddon-3.0"):GetAddon("VUIKeystones")
local Config = VUIKeystones:NewModule('Config')
local L = VUIKeystones.L

-- Default settings
local configDefaults = {
    progressTooltip = true,
    progressTooltipMDT = false,
    progressFormat = 1,
    autoGossip = true,
    cosRumors = false,
    silverGoldTimer = false,
    splitsFormat = 1,
    completionMessage = true,
    smallAffixes = true,
    deathTracker = true,
    recordSplits = false,
    showLevelModifier = false,
    hideTalkingHead = true,
    resetPopup = false,
    announceKeystones = false,
    schedule = true,
}

-- Config callbacks
local callbacks = {}

-- Format values for options
local progressFormatValues = { 1, 2, 3, 4, 5, 6 }
local splitsFormatValues = { 1, 2, 3 }

-- Initialize configuration
function Config:OnInitialize()
    -- Initialize the config system
    self:RegisterCallback("OnUpdate", function()
        for name, module in pairs(VUIKeystones.Modules) do
            if module.UpdateConfig then
                module:UpdateConfig()
            end
        end
    end)
    
    -- Setup options panel using the standard VUI approach
    self:SetupOptions()
    
    -- Apply default configuration if needed
    self:ApplyDefaults()
    
    -- Initialize VUI integration
    self:InitVUIIntegration()
end

-- Apply default configuration values
function Config:ApplyDefaults()
    local db = VUIKeystones.db.profile
    
    -- Add default values for any missing config options
    for key, value in pairs(configDefaults) do
        if db[key] == nil then
            db[key] = value
        end
    end
end

-- Get options for configuration panel - standard function name used across VUI modules
function Config:GetOptions()
    -- Create options using standard VUI approach
    local options = {
        name = "VUI Keystones",
        handler = VUIKeystones,
        type = "group",
        icon = "Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm.tga",
        args = {
            general = {
                order = 1,
                type = "group",
                name = L["General"],
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = L["Enable"],
                        desc = L["Enable/disable VUI Keystones"],
                        get = function() return VUIKeystones.db.profile.general.enabled end,
                        set = function(_, value)
                            VUIKeystones.db.profile.general.enabled = value
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    progressTooltip = {
                        order = 2,
                        type = "toggle",
                        name = L["config_progressTooltip"],
                        get = function() return VUIKeystones.db.profile.progressTooltip end,
                        set = function(_, value)
                            VUIKeystones.db.profile.progressTooltip = value
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    progressTooltipMDT = {
                        order = 3,
                        type = "toggle",
                        name = L["config_progressTooltipMDT"],
                        get = function() return VUIKeystones.db.profile.progressTooltipMDT end,
                        set = function(_, value)
                            VUIKeystones.db.profile.progressTooltipMDT = value
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    progressFormat = {
                        order = 4,
                        type = "select",
                        name = L["config_progressFormat"],
                        values = {
                            L["config_progressFormat_1"],
                            L["config_progressFormat_2"],
                            L["config_progressFormat_3"],
                            L["config_progressFormat_4"],
                            L["config_progressFormat_5"],
                            L["config_progressFormat_6"],
                        },
                        get = function()
                            local value = VUIKeystones.db.profile.progressFormat
                            for i, allowed in ipairs(progressFormatValues) do
                                if value == allowed then return i end
                            end
                            return 1
                        end,
                        set = function(_, index)
                            VUIKeystones.db.profile.progressFormat = progressFormatValues[index]
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    autoGossip = {
                        order = 5,
                        type = "toggle",
                        name = L["config_autoGossip"],
                        get = function() return VUIKeystones.db.profile.autoGossip end,
                        set = function(_, value)
                            VUIKeystones.db.profile.autoGossip = value
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    silverGoldTimer = {
                        order = 6,
                        type = "toggle",
                        name = L["config_silverGoldTimer"],
                        get = function() return VUIKeystones.db.profile.silverGoldTimer end,
                        set = function(_, value)
                            VUIKeystones.db.profile.silverGoldTimer = value
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    splitsFormat = {
                        order = 7,
                        type = "select",
                        name = L["config_splitsFormat"],
                        values = {
                            L["config_splitsFormat_1"],
                            L["config_splitsFormat_2"],
                            L["config_splitsFormat_3"],
                        },
                        get = function()
                            local value = VUIKeystones.db.profile.splitsFormat
                            for i, allowed in ipairs(splitsFormatValues) do
                                if value == allowed then return i end
                            end
                            return 1
                        end,
                        set = function(_, index)
                            VUIKeystones.db.profile.splitsFormat = splitsFormatValues[index]
                            self:NotifyUpdate()
                        end,
                        width = "full",
                    },
                    -- Add more configuration options here
                },
            },
        },
    }
    
    -- Register with VUI Config system if available
    if VUI and VUI.Config and VUI.Config.RegisterModuleOptions then
        VUI.Config:RegisterModuleOptions("VUIKeystones", options, "VUI Keystones")
    end
    
    -- Also register with AceConfig for backward compatibility
    LibStub("AceConfig-3.0"):RegisterOptionsTable("VUIKeystones", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("VUIKeystones", "VUI Keystones")
end

-- Setup options - this is a standard function called in OnInitialize
function Config:SetupOptions()
    local options = self:GetOptions()
    
    -- Register with VUI Config system if available
    if VUI and VUI.Config and VUI.Config.RegisterModuleOptions then
        VUI.Config:RegisterModuleOptions("VUIKeystones", options, "VUI Keystones")
    end
    
    -- Also register with AceConfig for backward compatibility
    LibStub("AceConfig-3.0"):RegisterOptionsTable("VUIKeystones", options)
    VUIKeystones.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("VUIKeystones", "VUI Keystones")
end

-- Get a config option value
function Config:Get(key)
    if key then
        return VUIKeystones.db.profile[key]
    end
end

-- Set a config option value
function Config:Set(key, value)
    if key then
        VUIKeystones.db.profile[key] = value
        self:NotifyUpdate()
    end
end

-- Register a callback for when config changes
function Config:RegisterCallback(event, func)
    if not callbacks[event] then callbacks[event] = {} end
    callbacks[event][func] = true
end

-- Notify any registered callbacks of an update
function Config:NotifyUpdate()
    if callbacks["OnUpdate"] then
        for func, _ in pairs(callbacks["OnUpdate"]) do
            if type(func) == "function" then
                func()
            end
        end
    end
end

-- Initialize VUI integration
function Config:InitVUIIntegration()
    -- This function will be called after VUIKeystones is initialized
    -- It handles integration with the main VUI configuration panel
    
    -- Initialize default VUI settings if they don't exist
    if not VUI_SavedVariables then
        VUI_SavedVariables = {}
    end
    
    -- Initialize the VUI db if needed
    if not VUI or not VUI.db or not VUI.db.profile then
        return
    end
    
    -- Initialize vmodules settings if they don't exist
    if not VUI.db.profile.vmodules then
        VUI.db.profile.vmodules = {}
    end
    
    if not VUI.db.profile.vmodules.vuikeystones then
        VUI.db.profile.vmodules.vuikeystones = {
            enabled = true,
            progressTooltip = true,
            progressTooltipMDT = false,
            autoGossip = true,
            silverGoldTimer = false
        }
    end
    
    -- Sync settings from VUIKeystones to VUI
    self:SyncSettingsToVUI()
    
    -- Hook our settings changed function to update VUI panel settings
    hooksecurefunc(self, "NotifyUpdate", function()
        self:SyncSettingsToVUI()
    end)
end

-- Sync settings from VUIKeystones to VUI
function Config:SyncSettingsToVUI()
    if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuikeystones then
        return
    end
    
    -- Copy settings from VUIKeystones to VUI
    VUI.db.profile.vmodules.vuikeystones.enabled = VUIKeystones.db.profile.general and VUIKeystones.db.profile.general.enabled or true
    VUI.db.profile.vmodules.vuikeystones.progressTooltip = VUIKeystones.db.profile.progressTooltip
    VUI.db.profile.vmodules.vuikeystones.progressTooltipMDT = VUIKeystones.db.profile.progressTooltipMDT
    VUI.db.profile.vmodules.vuikeystones.autoGossip = VUIKeystones.db.profile.autoGossip
    VUI.db.profile.vmodules.vuikeystones.silverGoldTimer = VUIKeystones.db.profile.silverGoldTimer
end

-- Sync settings from VUI to VUIKeystones
function Config:SyncSettingsFromVUI()
    if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuikeystones then
        return
    end
    
    -- Initialize general if it doesn't exist
    if not VUIKeystones.db.profile.general then
        VUIKeystones.db.profile.general = {}
    end
    
    -- Copy settings from VUI to VUIKeystones
    VUIKeystones.db.profile.general.enabled = VUI.db.profile.vmodules.vuikeystones.enabled
    VUIKeystones.db.profile.progressTooltip = VUI.db.profile.vmodules.vuikeystones.progressTooltip
    VUIKeystones.db.profile.progressTooltipMDT = VUI.db.profile.vmodules.vuikeystones.progressTooltipMDT
    VUIKeystones.db.profile.autoGossip = VUI.db.profile.vmodules.vuikeystones.autoGossip
    VUIKeystones.db.profile.silverGoldTimer = VUI.db.profile.vmodules.vuikeystones.silverGoldTimer
    
    -- Notify modules of config changes
    self:NotifyUpdate()
end