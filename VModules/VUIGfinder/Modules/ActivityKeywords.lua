-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create ActivityKeywords namespace
VUIGfinder.ActivityKeywords = {}
local ActivityKeywords = VUIGfinder.ActivityKeywords

-- Reference Activity module
local Activity = VUIGfinder.Activity

-- Common positional keywords (these are found in many listings)
ActivityKeywords.POSITIONAL = {
    ["wts"] = true,
    ["need"] = true,
    ["wtb"] = true,
    ["last"] = true,
    ["looking"] = true,
    ["lfm"] = true,
    ["lf"] = true,
    ["guild"] = true,
    ["please"] = true,
    ["checking"] = true,
    ["check"] = true,
    ["hc"] = true,
    ["nm"] = true,
}

-- Common raid progression terms
ActivityKeywords.PROGRESSION = {
    ["prog"] = true,
    ["progress"] = true,
    ["progression"] = true,
    ["progg"] = true,
    ["learning"] = true,
    ["learn"] = true,
    ["fresh"] = true,
    ["reclear"] = true,
    ["farm"] = true,
    ["farming"] = true,
    ["boost"] = true,
    ["carry"] = true,
    ["alt"] = true,
    ["alts"] = true,
    ["last boss"] = true,
    ["gold"] = true,
    ["skip"] = true,
    ["fast"] = true,
    ["quick"] = true,
    ["curve"] = true,
    ["mount"] = true,
}

-- Common PvP terms
ActivityKeywords.PVP = {
    ["push"] = true,
    ["pushing"] = true,
    ["chill"] = true,
    ["cap"] = true,
    ["capping"] = true,
    ["rating"] = true,
    ["exp"] = true,
    ["low"] = true,
    ["high"] = true,
    ["mmr"] = true,
    ["cr"] = true,
    ["rival"] = true,
    ["duelist"] = true,
    ["glad"] = true,
    ["gladiator"] = true,
    ["voice"] = true,
    ["discord"] = true,
    ["no voice"] = true,
}

-- Common Mythic+ terms
ActivityKeywords.MYTHICPLUS = {
    ["plus"] = true,
    ["key"] = true,
    ["keys"] = true,
    ["push"] = true,
    ["pushing"] = true,
    ["timed"] = true,
    ["timer"] = true,
    ["weekly"] = true,
    ["score"] = true,
    ["scores"] = true,
    ["io"] = true,
    ["rio"] = true,
    ["r.io"] = true,
    ["raider"] = true,
    ["raider.io"] = true,
    ["alt"] = true,
    ["alts"] = true,
    ["carry"] = true,
    ["boost"] = true,
    ["portals"] = true,
    ["intime"] = true,
    ["chill"] = true,
    ["fast"] = true,
    ["quick"] = true,
}

-- Prepare all keywords for faster searching
function ActivityKeywords:Prepare()
    -- Combine all keyword sets into a master list
    self.ALL_KEYWORDS = {}
    
    for k, v in pairs(self.POSITIONAL) do
        self.ALL_KEYWORDS[k] = v
    end
    
    for k, v in pairs(self.PROGRESSION) do
        self.ALL_KEYWORDS[k] = v
    end
    
    for k, v in pairs(self.PVP) do
        self.ALL_KEYWORDS[k] = v
    end
    
    for k, v in pairs(self.MYTHICPLUS) do
        self.ALL_KEYWORDS[k] = v
    end
end

-- Check if text contains a keyword
function ActivityKeywords:ContainsKeyword(text, keyword)
    if not text or not keyword then return false end
    
    -- Convert to lowercase for case-insensitive matching
    text = string.lower(text)
    keyword = string.lower(keyword)
    
    -- Simple word boundary check
    return text:match("%f[%a]" .. keyword .. "%f[^%a]") ~= nil
end

-- Find all keywords in a text
function ActivityKeywords:FindKeywords(text)
    if not text then return {} end
    
    local found = {}
    text = string.lower(text)
    
    for keyword in pairs(self.ALL_KEYWORDS) do
        if self:ContainsKeyword(text, keyword) then
            found[keyword] = true
        end
    end
    
    return found
end

-- Check if text has PvP related keywords
function ActivityKeywords:HasPvPKeywords(text)
    if not text then return false end
    
    text = string.lower(text)
    
    for keyword in pairs(self.PVP) do
        if self:ContainsKeyword(text, keyword) then
            return true
        end
    end
    
    return false
end

-- Check if text has Mythic+ related keywords
function ActivityKeywords:HasMythicPlusKeywords(text)
    if not text then return false end
    
    text = string.lower(text)
    
    for keyword in pairs(self.MYTHICPLUS) do
        if self:ContainsKeyword(text, keyword) then
            return true
        end
    end
    
    return false
end

-- Extract key level from M+ listing name
function ActivityKeywords:ExtractKeyLevel(text)
    if not text then return 0 end
    
    -- Delegate to Activity module
    return Activity:GetMythicPlusLevelFromName(text)
end

-- Initialize the keyword system
ActivityKeywords:Prepare()