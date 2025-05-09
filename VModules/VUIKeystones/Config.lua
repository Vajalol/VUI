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
    
    -- Create the options panel
    self:CreateOptions()
    
    -- Apply default configuration if needed
    self:ApplyDefaults()
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

-- Create options panel
function Config:CreateOptions()
    -- Create options using AceConfig
    local options = {
        name = "VUI Keystones",
        handler = VUIKeystones,
        type = "group",
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
    
    -- Register with AceConfig
    LibStub("AceConfig-3.0"):RegisterOptionsTable("VUIKeystones", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("VUIKeystones", "VUI Keystones")
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