-------------------------------------------------------------------------------
-- VUIKeystones Module
-- Enhanced Mythic+ keystone UI with advanced features
-- Based on Angry Keystones with VUI integration
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUIKeystones"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Keystones"
M.DESCRIPTION = "Enhanced Mythic+ keystone tracking and UI improvements"
M.VERSION = "1.0"

-- Module System (for backwards compatibility with original structure)
M.Modules = {}

function M:NewModule(name)
    if not self.Modules[name] then
        self.Modules[name] = {}
    end
    return self.Modules[name]
end

function M:GetModule(name)
    return self.Modules[name]
end

-- Expose globally while maintaining the namespace
_G["VUIKeystones"] = M

-- Localization
local L = {}
M.L = L

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        useThemeColors = true,
        
        -- Tooltip settings
        progressTooltip = true,
        progressTooltipMDT = false,
        progressFormat = 1,
        
        -- Timer and display settings
        silverGoldTimer = false,
        splitsFormat = 1,
        completionMessage = true,
        smallAffixes = true,
        
        -- Death and progress tracking
        deathTracker = true,
        recordSplits = false,
        
        -- UI enhancements
        showLevelModifier = false,
        hideTalkingHead = true,
        resetPopup = false,
        
        -- Dungeon-specific features
        autoGossip = true,
        cosRumors = false,
        
        -- Visual settings
        scheduleColor = {r = 0.1, g = 0.6, b = 0.8},
        completedColor = {r = 0.6, g = 0.8, b = 0.1},
        
        -- Frame positions
        objectivePosition = {"CENTER", nil, "CENTER", 0, 80},
        timerPosition = {"CENTER", nil, "CENTER", 0, 110},
        deathTrackerPosition = {"CENTER", nil, "CENTER", 240, 100},
        
        -- Leaderboard enhancements
        showLeaderRunSummary = true,
        enhancedLeaderboard = true,
        
        -- Weekly best frame
        weeklyBestFramePosition = {"TOPRIGHT", nil, "TOPRIGHT", -250, -15},
        weeklyBestFrameScale = 1,
        
        -- Chat and social features
        announceKeystones = true,
        announceChannel = "PARTY",
        announceMilestones = true
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Initialize submodules
    self:InitializeSubmodules()
    
    -- Register slash command
    self:RegisterChatCommand("vuiks", "SlashCommand")
    
    -- Legacy support
    self:RegisterChatCommand("aks", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("CHALLENGE_MODE_RESET")
    self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Hook functions
    self:HookScripts()
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Unhook scripts
    self:UnhookAll()
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Initialize submodules
function M:InitializeSubmodules()
    -- Create the submodules
    local submodules = {
        "Schedule", "ProgressTooltip", "ObjectiveTracker", 
        "Timer", "DeathTracker", "WeeklyBest", "Gossip"
    }
    
    -- Load each submodule
    for _, name in ipairs(submodules) do
        local module = self:NewModule(name)
        
        -- Initialize if it has an init function
        if module.Init then
            module:Init()
        end
    end
end

-- Hook scripts for various UI elements
function M:HookScripts()
    -- Challenge Mode UI
    if ChallengesKeystoneFrame then
        self:HookScript(ChallengesKeystoneFrame, "OnShow", "OnKeystoneFrameShow")
    end
    
    -- Objective Tracker
    if ObjectiveTrackerFrame then
        self:SecureHook(ObjectiveTrackerFrame, "OnEvent", "OnObjectiveTrackerEvent")
    end
    
    -- Talking Head (if hiding is enabled)
    if self.db.profile.hideTalkingHead and TalkingHeadFrame then
        self:SecureHook(TalkingHeadFrame, "PlayCurrent", "OnTalkingHeadShow")
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Create config options table
    local options = {
        name = self.TITLE,
        desc = self.DESCRIPTION,
        type = "group",
        args = {
            header = {
                type = "header",
                name = self.TITLE,
                order = 1,
            },
            version = {
                type = "description",
                name = "|cffff9900Version:|r " .. self.VERSION,
                order = 2,
            },
            desc = {
                type = "description",
                name = self.DESCRIPTION,
                order = 3,
            },
            spacer = {
                type = "description",
                name = " ",
                order = 4,
            },
            enabled = {
                type = "toggle",
                name = L["Enable"] or "Enable",
                desc = L["Enable_Desc"] or "Enable or disable keystone enhancements",
                width = "full",
                order = 5,
                get = function() return self.db.profile.enabled end,
                set = function(_, val) 
                    self.db.profile.enabled = val
                    if val then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
            },
            useThemeColors = {
                type = "toggle",
                name = L["Use Theme Colors"] or "Use Theme Colors",
                desc = L["UseThemeColors_Desc"] or "Apply VUI theme colors to keystone elements",
                width = "full",
                order = 6,
                get = function() return self.db.profile.useThemeColors end,
                set = function(_, val) 
                    self.db.profile.useThemeColors = val
                    if self.UpdateTheme then
                        self:UpdateTheme()
                    end
                end,
            },
            -- Additional options would go here
        }
    }
    
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, options, self.TITLE)
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        if self.db.profile.enabled then
            self:Enable()
        else
            self:Disable()
        end
    else
        -- Open configuration
        VUI.Config:OpenToCategory(self.TITLE)
    end
end

-- Theme update handler
function M:UpdateTheme()
    -- Update visuals based on current theme
    if not self.db.profile.useThemeColors then return end
    
    local theme = VUI:GetActiveTheme()
    if not theme then return end
    
    -- Apply theme colors
    self.db.profile.scheduleColor = {r = theme.colors.primary.r, g = theme.colors.primary.g, b = theme.colors.primary.b}
    self.db.profile.completedColor = {r = theme.colors.secondary.r, g = theme.colors.secondary.g, b = theme.colors.secondary.b}
    
    -- Update visuals in each submodule that supports themes
    for name, module in pairs(self.Modules) do
        if module.UpdateTheme then
            module:UpdateTheme(theme)
        end
    end
end

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end

-- Event handlers
function M:CHALLENGE_MODE_START()
    if not self.db.profile.enabled then return end
    
    -- Handle challenge mode start
    for _, module in pairs(self.Modules) do
        if module.OnChallengeStart then
            module:OnChallengeStart()
        end
    end
end

function M:CHALLENGE_MODE_COMPLETED()
    if not self.db.profile.enabled then return end
    
    -- Handle challenge mode completion
    for _, module in pairs(self.Modules) do
        if module.OnChallengeComplete then
            module:OnChallengeComplete()
        end
    end
    
    -- Show completion message if enabled
    if self.db.profile.completionMessage then
        -- Implementation would show a message here
    end
end

function M:CHALLENGE_MODE_RESET()
    if not self.db.profile.enabled then return end
    
    -- Handle challenge mode reset
    for _, module in pairs(self.Modules) do
        if module.OnChallengeReset then
            module:OnChallengeReset()
        end
    end
    
    -- Show reset popup if enabled
    if self.db.profile.resetPopup then
        -- Implementation would show a popup here
    end
end

function M:CHALLENGE_MODE_DEATH_COUNT_UPDATED()
    if not self.db.profile.enabled or not self.db.profile.deathTracker then return end
    
    -- Update death tracker
    local deathTracker = self:GetModule("DeathTracker")
    if deathTracker and deathTracker.Update then
        deathTracker:Update()
    end
end

function M:PLAYER_ENTERING_WORLD()
    if not self.db.profile.enabled then return end
    
    -- Notify modules
    for _, module in pairs(self.Modules) do
        if module.OnPlayerEnteringWorld then
            module:OnPlayerEnteringWorld()
        end
    end
end

-- Keystone frame show handler
function M:OnKeystoneFrameShow()
    if not self.db.profile.enabled then return end
    
    -- Enhance keystone frame
    local scheduleModule = self:GetModule("Schedule")
    if scheduleModule and scheduleModule.OnKeystoneFrameShow then
        scheduleModule:OnKeystoneFrameShow()
    end
end

-- Objective tracker event handler
function M:OnObjectiveTrackerEvent(event, ...)
    if not self.db.profile.enabled then return end
    
    -- Enhance objective tracker
    local objectiveModule = self:GetModule("ObjectiveTracker")
    if objectiveModule and objectiveModule.OnObjectiveTrackerEvent then
        objectiveModule:OnObjectiveTrackerEvent(event, ...)
    end
end

-- Talking head show handler
function M:OnTalkingHeadShow()
    if not self.db.profile.enabled or not self.db.profile.hideTalkingHead then return end
    
    -- Hide in mythic+ dungeons only
    local inMythic = C_ChallengeMode.IsChallengeModeActive()
    if inMythic then
        TalkingHeadFrame:Hide()
    end
end