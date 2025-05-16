--[[
    VUI Auctionator Module Configuration
    Advanced auction house tools
]]

local Layout = VUI:NewModule('Config.Layout.VUIAuctionator')

-- Safe access to helper functions with fallback
local SafeGetVModule

-- Initialize the helper function
local function InitHelpers()
    -- Use global if available, otherwise try to get from VUI
    SafeGetVModule = _G.SafeGetVModule
    
    -- If the global helper isn't available yet, create a simple version
    if not SafeGetVModule and VUI then
        SafeGetVModule = function(name)
            return VUI:GetModule(name, true)
        end
    end
end

function Layout:OnEnable()
    -- Initialize helpers
    InitHelpers()

    -- Database reference
    local db = VUI.db
    
    -- Get module safely
    local module = SafeGetVModule and SafeGetVModule("VUIAuctionator") 
    
    if not module then 
        -- Try direct reference to global module
        module = _G["VUIAuctionator"]
        
        if not module then
            -- Retry after a delay if helpers not loaded yet
            C_Timer.After(0.5, function()
                InitHelpers()
                self:OnEnable()
            end)
            return 
        end
    end
    
    -- Layout definition
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            -- Section 1: Main settings
            {
                header = {
                    type = 'header',
                    label = 'VUI Auctionator'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuiauctionator.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Auctionator',
                    tooltip = 'Enable or disable the VUI Auctionator module',
                    column = 12,
                    order = 1,
                    callback = function(self)
                        if module then
                            if not db.profile.vmodules then db.profile.vmodules = {} end
                            if not db.profile.vmodules.vuiauctionator then db.profile.vmodules.vuiauctionator = {} end
                            db.profile.vmodules.vuiauctionator.enabled = self:GetValue()
                            
                            -- Refresh module state
                            if self:GetValue() then
                                if module.Initialize then module:Initialize() end
                            end
                        end
                    end
                },
            },
            
            -- Section 2: Auction Interface
            {
                header = {
                    type = 'header',
                    label = 'Auction Interface'
                },
            },
            {
                autoOpenPanel = {
                    key = 'vmodules.vuiauctionator.autoOpenPanel',
                    type = 'checkbox',
                    label = 'Auto Open Panel',
                    tooltip = 'Automatically open the VUI Auctionator panel when visiting the Auction House',
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module then
                            if not db.profile.vmodules then db.profile.vmodules = {} end
                            if not db.profile.vmodules.vuiauctionator then db.profile.vmodules.vuiauctionator = {} end
                            db.profile.vmodules.vuiauctionator.autoOpenPanel = self:GetValue()
                        end
                    end
                },
                defaultTab = {
                    key = 'vmodules.vuiauctionator.defaultTab',
                    type = 'dropdown',
                    label = 'Default Tab',
                    tooltip = 'Select the default tab to show when opening VUI Auctionator',
                    options = {
                        {text = "Selling", value = "SELLING"},
                        {text = "Shopping", value = "SHOPPING"},
                        {text = "Cancelling", value = "CANCELLING"},
                        {text = "Browse", value = "BROWSE"}
                    },
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if module then
                            if not db.profile.vmodules then db.profile.vmodules = {} end
                            if not db.profile.vmodules.vuiauctionator then db.profile.vmodules.vuiauctionator = {} end
                            db.profile.vmodules.vuiauctionator.defaultTab = self:GetValue()
                        end
                    end
                },
            },
            
            -- Section 3: Selling Options
            {
                header = {
                    type = 'header',
                    label = 'Selling Options'
                },
            },
            {
                defaultUndercutValue = {
                    key = 'vmodules.vuiauctionator.defaultUndercutValue',
                    type = 'slider',
                    label = 'Default Undercut Value',
                    tooltip = 'The default amount to undercut by when selling items',
                    min = 1,
                    max = 100,
                    step = 1,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module then
                            if not db.profile.vmodules then db.profile.vmodules = {} end
                            if not db.profile.vmodules.vuiauctionator then db.profile.vmodules.vuiauctionator = {} end
                            db.profile.vmodules.vuiauctionator.defaultUndercutValue = self:GetValue()
                        end
                    end
                },
                alwaysShowBuyouts = {
                    key = 'vmodules.vuiauctionator.alwaysShowBuyouts',
                    type = 'checkbox',
                    label = 'Always Show Buyout Prices',
                    tooltip = 'Always show buyout prices instead of bid prices in the auction listings',
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if module then
                            if not db.profile.vmodules then db.profile.vmodules = {} end
                            if not db.profile.vmodules.vuiauctionator then db.profile.vmodules.vuiauctionator = {} end
                            db.profile.vmodules.vuiauctionator.alwaysShowBuyouts = self:GetValue()
                        end
                    end
                },
            },
            
            -- Section 4: Advanced Settings
            {
                header = {
                    type = 'header',
                    label = 'Advanced Settings'
                },
            },
            {
                debugMode = {
                    key = 'vmodules.vuiauctionator.debugMode',
                    type = 'checkbox',
                    label = 'Debug Mode',
                    tooltip = 'Enable debug mode for troubleshooting',
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module and module.Debug then
                            if not db.profile.vmodules then db.profile.vmodules = {} end
                            if not db.profile.vmodules.vuiauctionator then db.profile.vmodules.vuiauctionator = {} end
                            db.profile.vmodules.vuiauctionator.debugMode = self:GetValue()
                            module.Debug.Toggle = self:GetValue()
                        end
                    end
                },
                advancedConfig = {
                    type = 'button',
                    label = 'Advanced Configuration',
                    tooltip = 'Open the advanced configuration panel for VUI Auctionator',
                    column = 6,
                    order = 2,
                    callback = function()
                        if module then
                            -- Execute the slash command to open advanced config
                            SlashCmdList["VUIAUCTIONATOR"]("config")
                        end
                    end
                },
            },
            
            -- Section 5: Data Management
            {
                header = {
                    type = 'header',
                    label = 'Data Management'
                },
            },
            {
                resetDatabase = {
                    type = 'button',
                    label = 'Reset Database',
                    tooltip = 'Reset the VUI Auctionator database. This will clear all saved auction data.',
                    column = 4,
                    order = 1,
                    callback = function()
                        if module and module.Database and module.Database.ResetAll then
                            module.Database.ResetAll()
                            if VUI.ShowNotification then
                                VUI:ShowNotification("VUI Auctionator database has been reset.")
                            else
                                print("VUI Auctionator database has been reset.")
                            end
                        end
                    end
                },
                clearHistory = {
                    type = 'button',
                    label = 'Clear History',
                    tooltip = 'Clear the auction history data only',
                    column = 4,
                    order = 2,
                    callback = function()
                        if module and module.Database and module.Database.ClearHistory then
                            module.Database.ClearHistory()
                            if VUI.ShowNotification then
                                VUI:ShowNotification("VUI Auctionator history has been cleared.")
                            else
                                print("VUI Auctionator history has been cleared.")
                            end
                        end
                    end
                },
                exportData = {
                    type = 'button',
                    label = 'Export Settings',
                    tooltip = 'Export your VUI Auctionator settings',
                    column = 4,
                    order = 3,
                    callback = function()
                        if module and module.Config and module.Config.ExportSettings then
                            module.Config.ExportSettings()
                        end
                    end
                },
            },
        }
    }
end 

return Layout 