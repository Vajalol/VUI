-------------------------------------------------------------------------------
-- Title: VUI AngryKeystones Module
-- Author: VortexQ8
-- Integration of AngryKeystones with VUI theme system
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI:NewModule("angrykeystones", "AceEvent-3.0", "AceHook-3.0")
VUI.modules.angrykeystones = AK

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        useVUITheme = true,
        enhancedTimers = true,
        chestTimerNotifications = true,
        progressPrecision = 2, -- Decimal places for progress percentage
        timerStyles = {
            showMilliseconds = true,
            colorGradient = true,
            fontSize = 16,
        },
        objectiveStyles = {
            progressBarWidth = 150,
            showPercentSymbol = true,
            colorByType = true,
        }
    }
}

-- Module initialization
function AK:OnInitialize()
    -- Create database
    self.db = VUI.db:RegisterNamespace("angrykeystones", defaults)
    
    -- Register module with VUI
    VUI:RegisterModule(self, "AngryKeystones", "Mythic+ progress and timer enhancements")
    
    -- Load ThemeIntegration
    self.ThemeIntegration = self.ThemeIntegration or VUI.GetModule("angrykeystones.ThemeIntegration")
    if self.ThemeIntegration then
        self.ThemeIntegration:Initialize()
    end
    
    -- Load Configuration UI
    self.Config = self.Config or VUI.GetModule("angrykeystones.Config")
    if self.Config then
        VUI:RegisterModuleOptions("angrykeystones", self.Config:GetOptions(), "AngryKeystones")
    end
end

-- Enable module
function AK:OnEnable()
    if not self.db.profile.enabled then return end
    
    -- Hook into original AngryKeystones if present
    if _G.AngryKeystones then
        self:InitializeIntegration()
    else
        -- Register for ADDON_LOADED to detect when AngryKeystones loads
        self:RegisterEvent("ADDON_LOADED")
    end
    
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        if self.ThemeIntegration then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
    
    -- Initialize optional feature modules
    self:InitializeSubModules()
end

-- Initialize the optional feature sub-modules
function AK:InitializeSubModules()
    -- Initialize chest timer notifications
    if self.db.profile.chestTimerNotifications then
        self.ChestTimerNotifications = self.ChestTimerNotifications or {}
        if self.ChestTimerNotifications.Initialize then
            self.ChestTimerNotifications:Initialize()
        end
    end
    
    -- Initialize progress tracker
    self.ProgressTracker = self.ProgressTracker or {}
    if self.ProgressTracker.Initialize then
        self.ProgressTracker:Initialize()
    end
    
    -- Initialize enhanced timers
    if self.db.profile.enhancedTimers then
        self.EnhancedTimers = self.EnhancedTimers or {}
        if self.EnhancedTimers.Initialize then
            self.EnhancedTimers:Initialize()
        end
    end
end

-- Handle addon loaded event
function AK:ADDON_LOADED(event, addonName)
    if addonName == "AngryKeystones" and _G.AngryKeystones then
        self:InitializeIntegration()
        self:UnregisterEvent("ADDON_LOADED")
    end
end

-- Initialize integration with original AngryKeystones
function AK:InitializeIntegration()
    -- Store reference to original AngryKeystones
    self.OriginalAK = _G.AngryKeystones
    
    -- Check if Challenges module exists
    if self.OriginalAK.Modules and self.OriginalAK.Modules.Challenges then
        -- Hook into Challenges module
        self:HookChallengesModule()
    end
    
    -- Check if Progress module exists
    if self.OriginalAK.Modules and self.OriginalAK.Modules.Progress then
        -- Hook into Progress module
        self:HookProgressModule()
    end
    
    -- Check if Objectives module exists
    if self.OriginalAK.Modules and self.OriginalAK.Modules.Objectives then
        -- Hook into Objectives module
        self:HookObjectivesModule()
    end
    
    -- Apply theme to all AngryKeystones elements
    if self.ThemeIntegration then
        self.ThemeIntegration:ApplyTheme()
    end
end

-- Hook into the Challenges module (timers)
function AK:HookChallengesModule()
    local Challenges = self.OriginalAK.Modules.Challenges
    
    -- Store a reference to the original module
    self.ChallengesModule = Challenges
    
    -- Create frame references for theming
    self.challengesFrames = {}
    
    -- Hook into timer creation
    if Challenges.CreateTimer then
        self:RawHook(Challenges, "CreateTimer", function(...)
            local timerFrame = self.hooks[Challenges].CreateTimer(...)
            
            -- Store reference to the timer frame
            table.insert(self.challengesFrames, timerFrame)
            
            -- Apply theme to the frame
            if self.ThemeIntegration then
                self.ThemeIntegration:ApplyThemeToFrame(timerFrame)
            end
            
            return timerFrame
        end, true)
    end
    
    -- If timers are already created, theme them
    if Challenges.timerFrame then
        table.insert(self.challengesFrames, Challenges.timerFrame)
        
        if self.ThemeIntegration then
            self.ThemeIntegration:ApplyThemeToFrame(Challenges.timerFrame)
        end
    end
end

-- Hook into the Progress module (enemy forces tracking)
function AK:HookProgressModule()
    local Progress = self.OriginalAK.Modules.Progress
    
    -- Store a reference to the original module
    self.ProgressModule = Progress
    
    -- Create frame references for theming
    self.progressFrames = {}
    
    -- Hook into progress display creation
    if Progress.CreateBar then
        self:RawHook(Progress, "CreateBar", function(...)
            local progressBar = self.hooks[Progress].CreateBar(...)
            
            -- Store reference to the progress bar
            table.insert(self.progressFrames, progressBar)
            
            -- Apply theme to the frame
            if self.ThemeIntegration then
                self.ThemeIntegration:ApplyThemeToProgressBar(progressBar)
            end
            
            return progressBar
        end, true)
    end
    
    -- If progress bar is already created, theme it
    if Progress.progressBar then
        table.insert(self.progressFrames, Progress.progressBar)
        
        if self.ThemeIntegration then
            self.ThemeIntegration:ApplyThemeToProgressBar(Progress.progressBar)
        end
    end
end

-- Hook into the Objectives module (objective list)
function AK:HookObjectivesModule()
    local Objectives = self.OriginalAK.Modules.Objectives
    
    -- Store a reference to the original module
    self.ObjectivesModule = Objectives
    
    -- Create frame references for theming
    self.objectiveFrames = {}
    
    -- Hook into objective update function
    if Objectives.UpdateState then
        self:SecureHook(Objectives, "UpdateState", function()
            if self.ThemeIntegration then
                self.ThemeIntegration:ApplyThemeToObjectives()
            end
        end)
    end
    
    -- Theme objective frames if they exist
    if ScenarioObjectiveBlock and ScenarioObjectiveBlock.Buttons then
        for i, button in pairs(ScenarioObjectiveBlock.Buttons) do
            table.insert(self.objectiveFrames, button)
        end
        
        if self.ThemeIntegration then
            self.ThemeIntegration:ApplyThemeToObjectives()
        end
    end
end

-- Disable module
function AK:OnDisable()
    -- Unhook all hooks
    self:UnhookAll()
    
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Restore original frames if needed
    if self.ChallengesModule and self.challengesFrames then
        for _, frame in ipairs(self.challengesFrames) do
            -- Reset frame to default
            if frame.Reset then
                frame:Reset()
            end
        end
    end
    
    if self.ProgressModule and self.progressFrames then
        for _, frame in ipairs(self.progressFrames) do
            -- Reset frame to default
            if frame.Reset then
                frame:Reset()
            end
        end
    end
    
    if self.ObjectivesModule and self.objectiveFrames then
        for _, frame in ipairs(self.objectiveFrames) do
            -- Reset frame to default
            if frame.Reset then
                frame:Reset()
            end
        end
    end
end

-- Get precision formatted percentage
function AK:GetFormattedPercentage(value)
    local precision = self.db.profile.progressPrecision or 2
    local formatString = "%." .. precision .. "f%%"
    return string.format(formatString, value * 100)
end