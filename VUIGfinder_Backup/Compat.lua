-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-- Compatibility layer for different WoW versions
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create compatibility namespace
VUIGfinder.Compat = {}
local Compat = VUIGfinder.Compat

-- Get client version
local _, _, _, tocversion = GetBuildInfo()
Compat.isClassic = (tocversion < 20000)
Compat.isTBC = (tocversion >= 20000 and tocversion < 30000)
Compat.isWotLK = (tocversion >= 30000 and tocversion < 40000)
Compat.isCata = (tocversion >= 40000 and tocversion < 50000)
Compat.isMoP = (tocversion >= 50000 and tocversion < 60000)
Compat.isWoD = (tocversion >= 60000 and tocversion < 70000)
Compat.isLegion = (tocversion >= 70000 and tocversion < 80000)
Compat.isBFA = (tocversion >= 80000 and tocversion < 90000)
Compat.isShadowlands = (tocversion >= 90000 and tocversion < 100000)
Compat.isDragonflight = (tocversion >= 100000 and tocversion < 110000)
Compat.isWarWithin = (tocversion >= 110000)
Compat.isRetail = (not Compat.isClassic and not Compat.isTBC and not Compat.isWotLK)

-- Compatibility function for C_LFGList.GetActivityInfoTable 
function Compat.GetActivityInfoTable(activityID)
    -- For WoW versions where this function exists, use it directly
    if C_LFGList.GetActivityInfoTable then
        return C_LFGList.GetActivityInfoTable(activityID)
    end
    
    -- For older WoW versions, implement our own version
    local activityInfo = {}
    local name, shortName, category, group, minLevel, maxLevel, filters, minGS, displayType, orderIndex, useHonorLevel, showQuickJoin = C_LFGList.GetActivityInfo(activityID)
    
    activityInfo.fullName = name
    activityInfo.shortName = shortName or name
    activityInfo.categoryID = category
    activityInfo.groupFinderActivityGroupID = group
    activityInfo.minLevel = minLevel
    activityInfo.maxLevel = maxLevel
    activityInfo.filters = filters
    activityInfo.minItemLevel = minGS
    activityInfo.displayType = displayType
    activityInfo.orderIndex = orderIndex
    activityInfo.useHonorLevel = useHonorLevel
    activityInfo.showQuickJoin = showQuickJoin
    
    return activityInfo
end

-- Compatibility function for C_LFGList.GetSearchResultInfo
function Compat.GetSearchResultInfo(searchResultID)
    -- For WoW versions where this function exists, use it directly
    if C_LFGList.GetSearchResultInfo then
        return C_LFGList.GetSearchResultInfo(searchResultID)
    end
    
    -- Fall back to the older function if available
    local id, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, 
          numCharFriends, numGuildMates, isDelisted, leaderName, numMembers, 
          isAutoAccept, questID, leaderOverallDungeonScore, leaderDungeonScoreInfo,
          leaderPvpRatingInfo, requiredDungeonScore, autoAcceptOption, isWarModeActive,
          leaderFactionGroup
    
    if C_LFGList.GetSearchResultInfo then
        id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, 
        numCharFriends, numGuildMates, isDelisted, leaderName, numMembers, autoAcceptOption
            = C_LFGList.GetSearchResultInfo(searchResultID)
    end
    
    local searchResultInfo = {
        searchResultID = id,
        activityID = activityID,
        name = name,
        comment = comment,
        voiceChat = voiceChat,
        requiredItemLevel = iLvl,
        requiredHonorLevel = honorLevel,
        age = age,
        numBNetFriends = numBNetFriends,
        numCharFriends = numCharFriends,
        numGuildMates = numGuildMates,
        isDelisted = isDelisted,
        leaderName = leaderName,
        numMembers = numMembers,
        autoAccept = isAutoAccept or autoAcceptOption == 1,
        questID = questID,
        leaderOverallDungeonScore = leaderOverallDungeonScore,
        leaderDungeonScoreInfo = leaderDungeonScoreInfo,
        leaderPvpRatingInfo = leaderPvpRatingInfo,
        requiredDungeonScore = requiredDungeonScore,
        isWarModeActive = isWarModeActive,
        leaderFactionGroup = leaderFactionGroup,
    }
    
    -- Add member count info if available
    local memberCounts = C_LFGList.GetSearchResultMemberCounts and C_LFGList.GetSearchResultMemberCounts(searchResultID)
    if memberCounts then
        searchResultInfo.numTanks = memberCounts.tank or 0
        searchResultInfo.numHealers = memberCounts.healer or 0
        searchResultInfo.numDamagers = memberCounts.damager or 0
    end
    
    return searchResultInfo
end

-- Compatibility wrapper for C_LFGList functions
function Compat.LFGList_HasActiveEntryInfo()
    if C_LFGList.HasActiveEntryInfo then
        return C_LFGList.HasActiveEntryInfo()
    else
        return C_LFGList.GetActiveEntryInfo() ~= nil
    end
end

-- Set up overrides for C_LFGList functions
function Compat.ApplyCompatibilityLayer()
    -- Only apply compatibility layer if needed
    if not C_LFGList.GetActivityInfoTable then
        C_LFGList.GetActivityInfoTable = Compat.GetActivityInfoTable
    end
    
    -- Apply other overrides as needed
    if not VUIGfinder.C_LFGList_HasActiveEntryInfo then
        VUIGfinder.C_LFGList_HasActiveEntryInfo = Compat.LFGList_HasActiveEntryInfo
    end
end

-- Apply compatibility layer immediately
Compat.ApplyCompatibilityLayer()

-- Additional utility functions for handling version differences
function Compat.IsVoiceChatSupported()
    return Compat.isLegion or Compat.isBFA or Compat.isShadowlands or Compat.isDragonflight or Compat.isWarWithin
end

function Compat.IsMythicPlusSupported()
    return Compat.isLegion or Compat.isBFA or Compat.isShadowlands or Compat.isDragonflight or Compat.isWarWithin
end

function Compat.IsRaiderIOSupported()
    return Compat.isLegion or Compat.isBFA or Compat.isShadowlands or Compat.isDragonflight or Compat.isWarWithin
end