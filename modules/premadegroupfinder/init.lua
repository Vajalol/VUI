-- VUI Premade Group Finder Module - Initialization
local _, VUI = ...

-- Create the module using the module API
local PGF = VUI.ModuleAPI:CreateModule("premadegroupfinder")

-- Get configuration options for main UI integration
function PGF:GetConfig()
    local config = {
        name = "Premade Group Finder",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Premade Group Finder",
                desc = "Enable or disable the Premade Group Finder module",
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
            autoRefresh = {
                type = "toggle",
                name = "Auto-Refresh",
                desc = "Automatically refresh the group listing",
                get = function() return self.db.filters.autoRefresh end,
                set = function(_, value) 
                    self.db.filters.autoRefresh = value
                    self:UpdateRefreshTimer()
                end,
                order = 2
            },
            refreshInterval = {
                type = "range",
                name = "Refresh Interval",
                desc = "How often to refresh the group listing (in seconds)",
                min = 10,
                max = 300,
                step = 5,
                get = function() return self.db.filters.refreshInterval end,
                set = function(_, value) 
                    self.db.filters.refreshInterval = value
                    self:UpdateRefreshTimer()
                end,
                order = 3
            },
            enhancedTooltip = {
                type = "toggle",
                name = "Enhanced Tooltips",
                desc = "Show additional information in tooltips",
                get = function() return self.db.appearance.enhancedTooltip end,
                set = function(_, value) 
                    self.db.appearance.enhancedTooltip = value
                end,
                order = 4
            },
            compactList = {
                type = "toggle",
                name = "Compact List",
                desc = "Show a more compact group listing",
                get = function() return self.db.appearance.compactList end,
                set = function(_, value) 
                    self.db.appearance.compactList = value
                    self:UpdateListDisplay()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("premadegroupfinder", PGF:GetConfig())

-- Set up module defaults
local defaults = {
    enabled = true,
    filters = {
        autoClear = true,
        autoRefresh = true,
        refreshInterval = 60, -- seconds
        minimumItemLevel = 0,
        voiceChat = false,
        tankOnly = false,
        healerOnly = false,
        dpsOnly = false,
    },
    appearance = {
        enhancedTooltip = true,
        coloredNames = true,
        compactList = false,
        showLeaderScore = true,
        showRole = true,
        showItemLevel = true,
        showActivityName = true,
    },
    advanced = {
        autoApply = false,
        hideAds = true,
        showRaiderIO = true,
        showPlayerInfo = true,
        markFavorites = true,
    },
    position = {"CENTER", 0, 0},
    scale = 1.0,
    favoriteActivities = {},
    blacklist = {},
}

-- Initialize module settings
PGF.settings = VUI.ModuleAPI:InitializeModuleSettings("premadegroupfinder", defaults)

-- Register module configuration
local config = {
    type = "group",
    name = "Premade Group Finder",
    desc = "Enhanced Premade Group Finder with advanced filters and utilities",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the Premade Group Finder enhancements",
            order = 1,
            get = function() return VUI:IsModuleEnabled("premadegroupfinder") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("premadegroupfinder")
                else
                    VUI:DisableModule("premadegroupfinder")
                end
            end,
        },
        appearance = {
            type = "group",
            name = "Appearance",
            desc = "Configure the appearance of the Premade Group Finder",
            order = 2,
            args = {
                enhancedTooltip = {
                    type = "toggle",
                    name = "Enhanced Tooltip",
                    desc = "Show detailed information in tooltips",
                    order = 1,
                    get = function() return PGF.settings.appearance.enhancedTooltip end,
                    set = function(_, value) 
                        PGF.settings.appearance.enhancedTooltip = value
                        PGF:UpdateUI()
                    end,
                },
                coloredNames = {
                    type = "toggle",
                    name = "Colored Player Names",
                    desc = "Color player names by their class",
                    order = 2,
                    get = function() return PGF.settings.appearance.coloredNames end,
                    set = function(_, value) 
                        PGF.settings.appearance.coloredNames = value
                        PGF:UpdateUI()
                    end,
                },
                compactList = {
                    type = "toggle",
                    name = "Compact List",
                    desc = "Show a more compact group list to fit more groups",
                    order = 3,
                    get = function() return PGF.settings.appearance.compactList end,
                    set = function(_, value) 
                        PGF.settings.appearance.compactList = value
                        PGF:UpdateUI()
                    end,
                },
                showLeaderScore = {
                    type = "toggle",
                    name = "Show Leader Score",
                    desc = "Show leader's Mythic+ or PvP score",
                    order = 4,
                    get = function() return PGF.settings.appearance.showLeaderScore end,
                    set = function(_, value) 
                        PGF.settings.appearance.showLeaderScore = value
                        PGF:UpdateUI()
                    end,
                },
                showRole = {
                    type = "toggle",
                    name = "Show Group Roles",
                    desc = "Show available roles in the group",
                    order = 5,
                    get = function() return PGF.settings.appearance.showRole end,
                    set = function(_, value) 
                        PGF.settings.appearance.showRole = value
                        PGF:UpdateUI()
                    end,
                },
                showItemLevel = {
                    type = "toggle",
                    name = "Show Item Level",
                    desc = "Show required item level in the list",
                    order = 6,
                    get = function() return PGF.settings.appearance.showItemLevel end,
                    set = function(_, value) 
                        PGF.settings.appearance.showItemLevel = value
                        PGF:UpdateUI()
                    end,
                },
                showActivityName = {
                    type = "toggle",
                    name = "Show Activity Name",
                    desc = "Show the full activity name in the list",
                    order = 7,
                    get = function() return PGF.settings.appearance.showActivityName end,
                    set = function(_, value) 
                        PGF.settings.appearance.showActivityName = value
                        PGF:UpdateUI()
                    end,
                },
            },
        },
        filters = {
            type = "group",
            name = "Filters",
            desc = "Configure group filtering options",
            order = 3,
            args = {
                autoClear = {
                    type = "toggle",
                    name = "Auto Clear",
                    desc = "Automatically clear filters when you close and reopen the finder",
                    order = 1,
                    get = function() return PGF.settings.filters.autoClear end,
                    set = function(_, value) 
                        PGF.settings.filters.autoClear = value
                    end,
                },
                autoRefresh = {
                    type = "toggle",
                    name = "Auto Refresh",
                    desc = "Automatically refresh the list periodically",
                    order = 2,
                    get = function() return PGF.settings.filters.autoRefresh end,
                    set = function(_, value) 
                        PGF.settings.filters.autoRefresh = value
                        PGF:SetupAutoRefresh()
                    end,
                },
                refreshInterval = {
                    type = "range",
                    name = "Refresh Interval",
                    desc = "How often to refresh the list (in seconds)",
                    min = 10,
                    max = 300,
                    step = 5,
                    order = 3,
                    get = function() return PGF.settings.filters.refreshInterval end,
                    set = function(_, value) 
                        PGF.settings.filters.refreshInterval = value
                        PGF:SetupAutoRefresh()
                    end,
                },
                minimumItemLevel = {
                    type = "range",
                    name = "Minimum Item Level",
                    desc = "Filter groups requiring this minimum item level",
                    min = 0,
                    max = 500,
                    step = 5,
                    order = 4,
                    get = function() return PGF.settings.filters.minimumItemLevel end,
                    set = function(_, value) 
                        PGF.settings.filters.minimumItemLevel = value
                        PGF:UpdateFilters()
                    end,
                },
                roleFilters = {
                    type = "header",
                    name = "Role Filters",
                    order = 5,
                },
                tankOnly = {
                    type = "toggle",
                    name = "Tank Only",
                    desc = "Only show groups looking for a tank",
                    order = 6,
                    get = function() return PGF.settings.filters.tankOnly end,
                    set = function(_, value) 
                        PGF.settings.filters.tankOnly = value
                        PGF:UpdateFilters()
                    end,
                },
                healerOnly = {
                    type = "toggle",
                    name = "Healer Only",
                    desc = "Only show groups looking for a healer",
                    order = 7,
                    get = function() return PGF.settings.filters.healerOnly end,
                    set = function(_, value) 
                        PGF.settings.filters.healerOnly = value
                        PGF:UpdateFilters()
                    end,
                },
                dpsOnly = {
                    type = "toggle",
                    name = "DPS Only",
                    desc = "Only show groups looking for DPS",
                    order = 8,
                    get = function() return PGF.settings.filters.dpsOnly end,
                    set = function(_, value) 
                        PGF.settings.filters.dpsOnly = value
                        PGF:UpdateFilters()
                    end,
                },
                voiceChat = {
                    type = "toggle",
                    name = "Voice Chat Only",
                    desc = "Only show groups with voice chat",
                    order = 9,
                    get = function() return PGF.settings.filters.voiceChat end,
                    set = function(_, value) 
                        PGF.settings.filters.voiceChat = value
                        PGF:UpdateFilters()
                    end,
                },
            },
        },
        advanced = {
            type = "group",
            name = "Advanced",
            desc = "Configure advanced options",
            order = 4,
            args = {
                autoApply = {
                    type = "toggle",
                    name = "Auto Apply",
                    desc = "Automatically apply saved filters when opening the finder",
                    order = 1,
                    get = function() return PGF.settings.advanced.autoApply end,
                    set = function(_, value) 
                        PGF.settings.advanced.autoApply = value
                    end,
                },
                hideAds = {
                    type = "toggle",
                    name = "Hide Advertisements",
                    desc = "Hide groups that appear to be advertisements",
                    order = 2,
                    get = function() return PGF.settings.advanced.hideAds end,
                    set = function(_, value) 
                        PGF.settings.advanced.hideAds = value
                        PGF:UpdateFilters()
                    end,
                },
                showRaiderIO = {
                    type = "toggle",
                    name = "Show Raider.IO",
                    desc = "Show Raider.IO scores if available",
                    order = 3,
                    get = function() return PGF.settings.advanced.showRaiderIO end,
                    set = function(_, value) 
                        PGF.settings.advanced.showRaiderIO = value
                        PGF:UpdateFilters()
                    end,
                },
                showPlayerInfo = {
                    type = "toggle",
                    name = "Show Player Info",
                    desc = "Show detailed player information on hover",
                    order = 4,
                    get = function() return PGF.settings.advanced.showPlayerInfo end,
                    set = function(_, value) 
                        PGF.settings.advanced.showPlayerInfo = value
                    end,
                },
                markFavorites = {
                    type = "toggle",
                    name = "Mark Favorites",
                    desc = "Mark favorite activities for quick access",
                    order = 5,
                    get = function() return PGF.settings.advanced.markFavorites end,
                    set = function(_, value) 
                        PGF.settings.advanced.markFavorites = value
                        PGF:UpdateUI()
                    end,
                },
            },
        },
        position = {
            type = "header",
            name = "Position and Scale",
            order = 5,
        },
        resetPosition = {
            type = "execute",
            name = "Reset Position",
            desc = "Reset the position of the Premade Group Finder frame",
            order = 6,
            func = function() PGF:ResetPosition() end,
        },
        scale = {
            type = "range",
            name = "Scale",
            desc = "Adjust the scale of the Premade Group Finder frame",
            min = 0.5,
            max = 2.0,
            step = 0.05,
            order = 7,
            get = function() return PGF.settings.scale end,
            set = function(_, value)
                PGF.settings.scale = value
                PGF:UpdateScale()
            end,
        },
        favoriteHeader = {
            type = "header",
            name = "Favorites",
            order = 8,
        },
        clearFavorites = {
            type = "execute",
            name = "Clear Favorites",
            desc = "Clear all favorite activities",
            order = 9,
            func = function() 
                PGF.settings.favoriteActivities = {}
                PGF:UpdateUI()
            end,
        },
        blacklistHeader = {
            type = "header",
            name = "Blacklist",
            order = 10,
        },
        clearBlacklist = {
            type = "execute",
            name = "Clear Blacklist",
            desc = "Clear all blacklisted players and groups",
            order = 11,
            func = function() 
                PGF.settings.blacklist = {}
                PGF:UpdateFilters()
            end,
        },
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("premadegroupfinder", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("premadegroupfinder", "vuipgf", function(input)
    if input and input:trim() == "toggle" then
        PGF:ToggleEnhancedUI()
    elseif input and input:trim() == "reset" then
        PGF:ResetPosition()
    elseif input and input:trim() == "config" then
        PGF:OpenConfig()
    elseif input and input:trim() == "refresh" then
        PGF:RefreshList()
    else
        VUI:Print("Premade Group Finder Commands:")
        VUI:Print("  /vuipgf toggle - Toggle enhanced UI")
        VUI:Print("  /vuipgf reset - Reset position")
        VUI:Print("  /vuipgf config - Open configuration")
        VUI:Print("  /vuipgf refresh - Refresh group list")
    end
end)

-- Initialize module
function PGF:Initialize()
    -- Register with VUI
    VUI:Print("Premade Group Finder module initialized")
    
    -- Register for UI integration when the UI is loaded
    VUI.ModuleAPI:EnableModuleUI("premadegroupfinder", function(module)
        module:SetupHooks()
    end)
    
    -- Initialize our data
    self.favoriteActivities = self.settings.favoriteActivities or {}
    self.blacklist = self.settings.blacklist or {}
    
    -- Register events
    self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", "OnSearchResultsReceived")
    self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE", "OnAvailabilityUpdate")
    self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", "OnApplicantListUpdated")
    self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE", "OnActiveEntryUpdate")
    self:RegisterEvent("LFG_LIST_ENTRY_CREATION_FAILED", "OnEntryCreationFailed")
    
    -- Cache for group data
    self.groupCache = {}
    
    -- Create our filter data
    self:InitializeFilters()
end

-- Enable module
function PGF:Enable()
    self.enabled = true
    
    -- Set up hooks and integrations
    self:SetupHooks()
    
    -- Set up auto-refresh if enabled
    self:SetupAutoRefresh()
    
    VUI:Print("Premade Group Finder module enabled")
end

-- Disable module
function PGF:Disable()
    self.enabled = false
    
    -- Remove hooks and integrations
    self:DisableHooks()
    
    -- Disable auto-refresh
    self:DisableAutoRefresh()
    
    VUI:Print("Premade Group Finder module disabled")
end

-- Event registration helper
function PGF:RegisterEvent(event, method)
    if type(method) == "string" and self[method] then
        method = self[method]
    end
    
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    self.eventFrame:RegisterEvent(event)
    self[event] = method
end

-- Initialize filters
function PGF:InitializeFilters()
    self.filters = {
        active = false,
        name = "",
        minIlvl = self.settings.filters.minimumItemLevel,
        roleRequired = {
            tank = self.settings.filters.tankOnly,
            healer = self.settings.filters.healerOnly,
            dps = self.settings.filters.dpsOnly
        },
        voiceChat = self.settings.filters.voiceChat
    }
end

-- Set up auto-refresh
function PGF:SetupAutoRefresh()
    if self.refreshTimer then
        self:DisableAutoRefresh()
    end
    
    if self.settings.filters.autoRefresh then
        self.refreshTimer = C_Timer.NewTicker(self.settings.filters.refreshInterval, function()
            self:RefreshList()
        end)
    end
end

-- Disable auto-refresh
function PGF:DisableAutoRefresh()
    if self.refreshTimer then
        self.refreshTimer:Cancel()
        self.refreshTimer = nil
    end
end

-- Reset position
function PGF:ResetPosition()
    if not LFGListFrame then return end
    
    self.settings.position = {"CENTER", 0, 0}
    
    if self.lfgFrameHooked then
        LFGListFrame:ClearAllPoints()
        LFGListFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    VUI:Print("Premade Group Finder position reset")
end

-- Update filters
function PGF:UpdateFilters()
    -- Update our filter data
    self.filters.minIlvl = self.settings.filters.minimumItemLevel
    self.filters.roleRequired.tank = self.settings.filters.tankOnly
    self.filters.roleRequired.healer = self.settings.filters.healerOnly
    self.filters.roleRequired.dps = self.settings.filters.dpsOnly
    self.filters.voiceChat = self.settings.filters.voiceChat
    
    -- Apply filters if the frame is open
    if LFGListFrame and LFGListFrame:IsVisible() then
        self:ApplyFilters()
    end
end

-- Update scale
function PGF:UpdateScale()
    if not LFGListFrame then return end
    
    if self.lfgFrameHooked then
        LFGListFrame:SetScale(self.settings.scale)
    end
end

-- Open configuration
function PGF:OpenConfig()
    InterfaceOptionsFrame_OpenToCategory("VUI")
    InterfaceOptionsFrame_OpenToCategory("VUI - Premade Group Finder")
end

-- Toggle enhanced UI
function PGF:ToggleEnhancedUI()
    if not self.enabled then
        VUI:EnableModule("premadegroupfinder")
    else
        VUI:DisableModule("premadegroupfinder")
    end
end

-- Refresh list
function PGF:RefreshList()
    if LFGListFrame and LFGListFrame.SearchPanel then
        C_LFGList.Search(LFGListFrame.SearchPanel.categoryID, LFGListFrame.SearchPanel.filters, LFGListFrame.SearchPanel.preferredFilters)
        VUI:Print("Refreshing group list...")
    end
end

-- Initialize module theme assets
function PGF:InitializeTheme()
    -- Initialize theme-specific media assets
    self:InitializeMedia()
    
    -- Apply theme to elements
    self:ThemeIntegrationInit()
end

-- Enable module
function PGF:OnEnable()
    if self.enabled then return end
    
    self.enabled = true
    self:SetupHooks()
    self:SetupAutoRefresh()
    self:InitializeTheme()
    
    -- Show enabled message
    VUI:Print("Premade Group Finder module enabled")
end

-- Disable module
function PGF:OnDisable()
    if not self.enabled then return end
    
    self.enabled = false
    self:DisableHooks()
    self:CancelAutoRefresh()
    
    -- Show disabled message
    VUI:Print("Premade Group Finder module disabled")
end

-- Register the module with VUI
VUI.premadegroupfinder = PGF