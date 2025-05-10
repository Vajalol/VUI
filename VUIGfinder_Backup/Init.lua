-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUIGfinder = {}
local VUI_SavedVariables = VUI_SavedVariables or {}
VUI_SavedVariables.VUIGfinder = VUI_SavedVariables.VUIGfinder or {}

-- Set up module in VUI
local VUI = _G.VUI
local Module = VUI:NewModule("VUIGfinder", "AceEvent-3.0", "AceHook-3.0")

-- Store module reference in the global namespace for debugging/development
_G.VUIGfinder = VUIGfinder
VUIGfinder.Module = Module

-- Make the VUIGfinder table available as a debug reference
Module.Debug = VUIGfinder

-- Set up localization and constants tables
VUIGfinder.L = {}
VUIGfinder.C = {}

local L = VUIGfinder.L
local C = VUIGfinder.C

-- Constants for difficulty levels
C.NORMAL     = 1
C.HEROIC     = 2
C.MYTHIC     = 3
C.MYTHICPLUS = 4
C.ARENA2V2   = 5
C.ARENA3V3   = 6
C.ARENA5V5   = 7

-- Difficulty values mapping as used in GroupFinderActivity and lockouts
C.DIFFICULTY_MAP = {
    [  1] = C.NORMAL,     -- DungeonNormal
    [  2] = C.HEROIC,     -- DungeonHeroic
    [  3] = C.NORMAL,     -- Raid10Normal
    [  4] = C.NORMAL,     -- Raid25Normal
    [  5] = C.HEROIC,     -- Raid10Heroic
    [  6] = C.HEROIC,     -- Raid25Heroic
    [  7] = C.NORMAL,     -- RaidLFR
    [  8] = C.MYTHIC,     -- RaidChallenge (removed)
    [  9] = C.NORMAL,     -- Raid40
    [ 11] = C.HEROIC,     -- HeroicScenario
    [ 12] = C.NORMAL,     -- NormalScenario
    [ 14] = C.NORMAL,     -- Raid
    [ 15] = C.HEROIC,     -- RaidHeroic
    [ 16] = C.MYTHIC,     -- RaidMythic
    [ 17] = C.NORMAL,     -- RaidLFR (post-MoP)
    [ 18] = C.ARENA2V2,   -- PvPScenario
    [ 19] = C.ARENA3V3,   -- EventScenario
    [ 20] = C.NORMAL,     -- EventScenario
    [ 23] = C.MYTHIC,     -- DungeonMythic
    [ 24] = C.MYTHICPLUS, -- DungeonMythicChallenge
    [ 25] = C.ARENA5V5,   -- PvPScenario
    [ 29] = C.ARENA2V2,   -- PvPScenario
    [ 30] = C.ARENA3V3,   -- PvPScenario
    [ 32] = C.ARENA2V2,   -- PvPScenario
    [ 33] = C.ARENA3V3,   -- PvPScenario
    [ 34] = C.ARENA5V5,   -- PvPScenario
    [ 38] = C.NORMAL,     -- IslandExpeditionNormal (BfA)
    [ 39] = C.HEROIC,     -- IslandExpeditionHeroic (BfA)
    [ 40] = C.MYTHIC,     -- IslandExpeditionMythic (BfA)
    [ 45] = C.NORMAL,     -- PvPScenario
    [ 147] = C.NORMAL,    -- NormalScenario (Warfronts BfA)
    [ 149] = C.HEROIC,    -- HeroicScenario (Warfronts BfA)
}

-- Time constants
C.ROLE_PREFIX = {
    ["DAMAGER"] = "dps",
    ["HEALER"] = "heal",
    ["TANK"] = "tank",
}

C.ROLE_SUFFIX = {
    ["DAMAGER"] = "dps",
    ["HEALER"] = "healer",
    ["TANK"] = "tank",
}

C.SPECIALIZATION_CACHE_TIMEOUT = 1 * 60 -- 1 minute
C.ROLE_TYPE_CACHE_TIMEOUT = 60 * 60 -- 60 minutes
C.LOCKOUT_CACHE_TIMEOUT = 5 * 60 -- 5 minutes

C.APPLICANT_STATUS_INVITED = 1 
C.APPLICANT_STATUS_FAILED = 2 -- This includes both declines and timeouts
C.APPLICANT_STATUS_CANCELLED = 3
C.APPLICANT_STATUS_DECLINED = 4
C.APPLICANT_STATUS_TIMEDOUT = 5
C.APPLICANT_STATUS_APPLIED = Applied

C.COVENANT_NONE = 0
C.COVENANT_KYRIAN = 1
C.COVENANT_VENTHYR = 2
C.COVENANT_NIGHTFAE = 3
C.COVENANT_NECROLORD = 4

C.SEARCH_ENTRY_RESET_WAIT = 10 -- seconds
C.SIGNUP_NOTE_TIMEOUT = 60 -- seconds

-- Search state variables
VUIGfinder.currentSearchResults = {}
VUIGfinder.lastSearchEntryReset = time()
VUIGfinder.previousSearchExpression = ""
VUIGfinder.currentSearchExpression = ""
VUIGfinder.previousSearchGroupKeys = {}
VUIGfinder.currentSearchGroupKeys = {}
VUIGfinder.searchResultIDInfo = {}
VUIGfinder.numResultsBeforeFilter = 0
VUIGfinder.numResultsAfterFilter = 0

-- Module initialization
function Module:OnInitialize()
    -- Set up the database with saved variables
    self.db = VUI_SavedVariables.VUIGfinder
    
    -- Set default settings if they don't exist
    if not self.db.profile then
        self.db.profile = {
            enabled = true,
            dungeon = {
                enabled = true,
                minimumDifficulty = C.NORMAL,
                maximumDifficulty = C.MYTHICPLUS,
                minMythicPlusLevel = 2,
                maxMythicPlusLevel = 30,
            },
            raid = {
                enabled = true,
                minimumDifficulty = C.NORMAL,
                maximumDifficulty = C.MYTHIC,
            },
            arena = {
                enabled = true,
                minRating = 0,
                maxRating = 3000,
            },
            rbg = {
                enabled = true,
                minRating = 0,
                maxRating = 3000,
            },
            advanced = {
                enabled = false,
                expression = "",
            },
            sorting = {
                enabled = false,
                expression = "",
            },
            ui = {
                minimized = false,
                dialogScale = 1.0,
                tooltipEnhancement = true,
                oneClickSignUp = true,
                persistSignUpNote = true,
                signUpOnEnter = true,
                usePGFButton = true,
            },
        }
    end
    
    -- Initialize with database
    Module.db.profile = Module.db.profile or {}
    
    -- Debug message
    self:Debug("VUIGfinder initialized")
end

-- Enables the module when user logs in
function Module:OnEnable()
    -- Register events and hooks here
    self:RegisterEvent("PLAYER_LOGIN")
end

-- Handle player login
function Module:PLAYER_LOGIN()
    if self.db.profile.enabled then
        self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
        self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
        -- Hook into the appropriate UI functions
        self:HookPremadeGroupsUI()
    end
end

-- Debug function
function Module:Debug(msg)
    if VUI.db.profile.debug then
        VUI:Print("[VUIGfinder] " .. msg)
    end
end

-- Hook into the Premade Groups UI
function Module:HookPremadeGroupsUI()
    -- Implementation of hooks into LFG UI
    -- We'll expand this in the Main.lua file
end