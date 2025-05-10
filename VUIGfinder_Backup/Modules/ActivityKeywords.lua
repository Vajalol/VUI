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

-- Raid keywords - used to identify raid roles/qualifications from LFG titles
ActivityKeywords.RAID_KEYWORDS = {
    -- General experience keywords
    EXPERIENCE = {
        exp = true,
        expe = true,
        experienced = true,
        ["1x"] = true, -- One raid clear
        ["2x"] = true, -- Two raid clears
        ["3x"] = true, -- Three raid clears
        ["4x"] = true, -- Four raid clears
        ["5x"] = true, -- Five raid clears
        ["6+"] = true, -- Six or more clears
        ["6x"] = true, -- Six raid clears
        ["10+"] = true, -- Ten or more clears
        ["10x"] = true, -- Ten raid clears
        progress = true,
        prog = true,
        full = true, -- Full clear
        farm = true,
        skilled = true,
    },
    
    -- Progression/familiarity keywords
    PROGRESSION = {
        prog = true,
        progress = true,
        learning = true,
        ["1/8"] = true, -- One out of eight bosses
        ["2/8"] = true, -- Two out of eight bosses
        ["3/8"] = true, -- Three out of eight bosses
        ["4/8"] = true, -- Four out of eight bosses
        ["5/8"] = true, -- Five out of eight bosses
        ["6/8"] = true, -- Six out of eight bosses
        ["7/8"] = true, -- Seven out of eight bosses
        ["8/8"] = true, -- Eight out of eight bosses (full clear)
        ["1/10"] = true, -- One out of ten bosses
        ["2/10"] = true, -- Two out of ten bosses
        ["3/10"] = true, -- Three out of ten bosses
        ["4/10"] = true, -- Four out of ten bosses
        ["5/10"] = true, -- Five out of ten bosses
        ["6/10"] = true, -- Six out of ten bosses
        ["7/10"] = true, -- Seven out of ten bosses
        ["8/10"] = true, -- Eight out of ten bosses
        ["9/10"] = true, -- Nine out of ten bosses
        ["10/10"] = true, -- Ten out of ten bosses (full clear)
        ["1/11"] = true, -- One out of eleven bosses
        ["2/11"] = true, -- Two out of eleven bosses
        ["3/11"] = true, -- Three out of eleven bosses
        ["4/11"] = true, -- Four out of eleven bosses
        ["5/11"] = true, -- Five out of eleven bosses
        ["6/11"] = true, -- Six out of eleven bosses
        ["7/11"] = true, -- Seven out of eleven bosses
        ["8/11"] = true, -- Eight out of eleven bosses
        ["9/11"] = true, -- Nine out of eleven bosses
        ["10/11"] = true, -- Ten out of eleven bosses
        ["11/11"] = true, -- Eleven out of eleven bosses (full clear)
    },
    
    -- Achievement requirements
    ACHIEVEMENT = {
        achiev = true,
        achieve = true,
        achievement = true,
        ach = true,
        link = true, -- Linking achievement
        aotc = true, -- Ahead of the Curve
        aoc = true, -- Ahead of the Curve (typo)
        curve = true, -- Ahead of the Curve
        ce = true, -- Cutting Edge
        cutting = true, -- Cutting Edge
        cutting_edge = true, -- Cutting Edge
        glory = true, -- Glory achievement
        meta = true, -- Meta achievement
    },
    
    -- Voice requirements
    VOICE = {
        voice = true,
        discord = true,
        disc = true,
        teamspeak = true,
        ts = true,
        ts3 = true,
        mumble = true,
        ventrilo = true,
        vent = true,
        voip = true,
        mic = true,
    },
    
    -- Miscellaneous terms
    MISC = {
        social = true,
        community = true,
        guild = true,
        alt = true, -- Alt run
        alts = true, -- Alt run
        ["alt-run"] = true, -- Alt run
        altrun = true, -- Alt run
        ["alt run"] = true, -- Alt run
        twink = true, -- Alt character
        transmog = true, -- Transmog run
        tmog = true, -- Transmog run
        mog = true, -- Transmog run
        gold = true, -- Gold run (boosting)
        carry = true, -- Carrying others
        boost = true, -- Boosting others
        sale = true, -- Selling runs
        sell = true, -- Selling runs
        selling = true, -- Selling runs
        lockout = true, -- Saved lockout
        locked = true, -- Saved to certain bosses
        skip = true, -- Skip to boss
    },
}

-- Mythic+ keywords - used to identify M+ roles/qualifications from LFG titles
ActivityKeywords.MYTHICPLUS_KEYWORDS = {
    -- General experience keywords
    EXPERIENCE = {
        exp = true,
        expe = true,
        experienced = true,
        chill = true, -- Relaxed run
        patient = true, -- Patient/learning group
        learning = true, -- Learning group
        fast = true, -- Fast run
        quick = true, -- Quick run
        speed = true, -- Speed run
    },
    
    -- Raider.IO score requirements
    RAIDERIO = {
        ["score"] = true,
        ["rio"] = true,
        ["r.io"] = true,
        ["io"] = true,
        ["raider.io"] = true,
        ["raiderio"] = true,
    },
    
    -- Key level requirements
    KEY_LEVEL = {
        ["2+"] = true, -- Level 2 or higher key
        ["3+"] = true, -- Level 3 or higher key
        ["4+"] = true, -- Level 4 or higher key
        ["5+"] = true, -- Level 5 or higher key
        ["6+"] = true, -- Level 6 or higher key
        ["7+"] = true, -- Level 7 or higher key
        ["8+"] = true, -- Level 8 or higher key
        ["9+"] = true, -- Level 9 or higher key
        ["10+"] = true, -- Level 10 or higher key
        ["11+"] = true, -- Level 11 or higher key
        ["12+"] = true, -- Level 12 or higher key
        ["13+"] = true, -- Level 13 or higher key
        ["14+"] = true, -- Level 14 or higher key
        ["15+"] = true, -- Level 15 or higher key
        ["16+"] = true, -- Level 16 or higher key
        ["17+"] = true, -- Level 17 or higher key
        ["18+"] = true, -- Level 18 or higher key
        ["19+"] = true, -- Level 19 or higher key
        ["20+"] = true, -- Level 20 or higher key
        ["21+"] = true, -- Level 21 or higher key
        ["22+"] = true, -- Level 22 or higher key
        ["23+"] = true, -- Level 23 or higher key
        ["24+"] = true, -- Level 24 or higher key
        ["25+"] = true, -- Level 25 or higher key
        ["26+"] = true, -- Level 26 or higher key
        ["27+"] = true, -- Level 27 or higher key
        ["28+"] = true, -- Level 28 or higher key
        ["29+"] = true, -- Level 29 or higher key
        ["30+"] = true, -- Level 30 or higher key
    },
    
    -- Voice requirements
    VOICE = {
        voice = true,
        discord = true,
        disc = true,
        teamspeak = true,
        ts = true,
        ts3 = true,
        mumble = true,
        ventrilo = true,
        vent = true,
        voip = true,
        mic = true,
    },
    
    -- Specific completion goals
    COMPLETION = {
        intime = true, -- Complete in time
        ["in-time"] = true, -- Complete in time
        ["in time"] = true, -- Complete in time
        timed = true, -- Timed run
        untimed = true, -- Not worried about timing
        completion = true, -- Just completion
        weekly = true, -- Weekly key
        vault = true, -- For Great Vault reward
        ["great vault"] = true, -- For Great Vault reward
    },
    
    -- Miscellaneous terms
    MISC = {
        social = true, -- Social run
        community = true, -- Community run
        guild = true, -- Guild run
        alt = true, -- Alt run
        alts = true, -- Alt run
        ["alt-run"] = true, -- Alt run
        altrun = true, -- Alt run
        ["alt run"] = true, -- Alt run
        twink = true, -- Alt character
        boost = true, -- Boosting others
        carry = true, -- Carrying others
        gold = true, -- Gold run (boosting)
        sale = true, -- Selling runs
        sell = true, -- Selling runs
        selling = true, -- Selling runs
        ["your key"] = true, -- Using someone else's key
        ["my key"] = true, -- Using leader's key
        ["our key"] = true, -- Using group's key
    },
}

-- PvP keywords - used to identify PvP roles/qualifications from LFG titles
ActivityKeywords.PVP_KEYWORDS = {
    -- General experience keywords
    EXPERIENCE = {
        exp = true,
        expe = true,
        experienced = true,
        skilled = true,
        practice = true,
        practicing = true,
        learn = true,
        learning = true,
        chill = true, -- Relaxed games
        push = true, -- Pushing rating
    },
    
    -- Rating requirements
    RATING = {
        ["0cr"] = true, -- 0 combat rating
        ["0 cr"] = true, -- 0 combat rating
        ["1k"] = true, -- 1000 rating
        ["1.1k"] = true, -- 1100 rating
        ["1.2k"] = true, -- 1200 rating
        ["1.3k"] = true, -- 1300 rating
        ["1.4k"] = true, -- 1400 rating
        ["1.5k"] = true, -- 1500 rating
        ["1.6k"] = true, -- 1600 rating
        ["1.7k"] = true, -- 1700 rating
        ["1.8k"] = true, -- 1800 rating
        ["1.9k"] = true, -- 1900 rating
        ["2k"] = true, -- 2000 rating
        ["2.1k"] = true, -- 2100 rating
        ["2.2k"] = true, -- 2200 rating
        ["2.3k"] = true, -- 2300 rating
        ["2.4k"] = true, -- 2400 rating
        ["2.5k"] = true, -- 2500 rating
        ["2.6k"] = true, -- 2600 rating
        ["2.7k"] = true, -- 2700 rating
        ["cr"] = true, -- Combat rating
        ["mmr"] = true, -- Matchmaking rating
        ["rating"] = true, -- Rating
    },
    
    -- PvP terms
    PVP_TERMS = {
        ["rbg"] = true, -- Rated battleground
        ["3s"] = true, -- 3v3 arena
        ["2s"] = true, -- 2v2 arena
        ["3v3"] = true, -- 3v3 arena
        ["2v2"] = true, -- 2v2 arena
        ["arena"] = true, -- Arena
        ["bg"] = true, -- Battleground
        ["battleground"] = true, -- Battleground
        ["skirmish"] = true, -- Arena skirmish
        ["skirm"] = true, -- Arena skirmish
        ["duels"] = true, -- Dueling
        ["duel"] = true, -- Dueling
        ["wpvp"] = true, -- World PvP
        ["worldpvp"] = true, -- World PvP
        ["world pvp"] = true, -- World PvP
    },
    
    -- Achievement requirements
    ACHIEVEMENT = {
        gladiator = true, -- Gladiator
        glad = true, -- Gladiator
        rival = true, -- Rival
        challenger = true, -- Challenger
        combatant = true, -- Combatant
        duelist = true, -- Duelist
        elite = true, -- Elite
        hero = true, -- Hero of the Alliance/Horde
    },
    
    -- Voice requirements
    VOICE = {
        voice = true,
        discord = true,
        disc = true,
        teamspeak = true,
        ts = true,
        ts3 = true,
        mumble = true,
        ventrilo = true,
        vent = true,
        voip = true,
        mic = true,
    },
    
    -- Miscellaneous terms
    MISC = {
        social = true,
        community = true,
        guild = true,
        lfg = true, -- Looking for group
        lf1m = true, -- Looking for 1 more
        lf2m = true, -- Looking for 2 more
        lf3m = true, -- Looking for 3 more
        lfm = true, -- Looking for more
        boost = true, -- Boosting others
        carry = true, -- Carrying others
        gold = true, -- Gold services
        sale = true, -- Selling runs
        sell = true, -- Selling runs
        selling = true, -- Selling runs
        cap = true, -- Conquest cap
        conq = true, -- Conquest
        conquest = true, -- Conquest
        honor = true, -- Honor farming
        farm = true, -- Farming (honor/conquest)
    },
}

-- Match keywords in a string
function ActivityKeywords:MatchKeywords(text, keywordTable)
    if not text or not keywordTable then
        return {}
    end
    
    -- Convert text to lowercase for case-insensitive matching
    text = string.lower(text)
    
    -- Store all matched keywords
    local matches = {}
    
    -- Check each keyword category
    for category, keywords in pairs(keywordTable) do
        for keyword, _ in pairs(keywords) do
            -- Check if the keyword is in the text
            if string.find(text, "%f[%a]" .. keyword .. "%f[%A]") then
                -- Add to matches
                matches[category] = matches[category] or {}
                matches[category][keyword] = true
            end
        end
    end
    
    return matches
end

-- Get keywords from a raid group
function ActivityKeywords:GetRaidKeywords(searchResult)
    if not searchResult then
        return {}
    end
    
    -- Combine name and comment for matching
    local text = (searchResult.name or "") .. " " .. (searchResult.comment or "")
    
    -- Match keywords
    return self:MatchKeywords(text, self.RAID_KEYWORDS)
end

-- Get keywords from a mythic+ group
function ActivityKeywords:GetMythicPlusKeywords(searchResult)
    if not searchResult then
        return {}
    end
    
    -- Combine name and comment for matching
    local text = (searchResult.name or "") .. " " .. (searchResult.comment or "")
    
    -- Match keywords
    return self:MatchKeywords(text, self.MYTHICPLUS_KEYWORDS)
end

-- Get keywords from a PvP group
function ActivityKeywords:GetPvPKeywords(searchResult)
    if not searchResult then
        return {}
    end
    
    -- Combine name and comment for matching
    local text = (searchResult.name or "") .. " " .. (searchResult.comment or "")
    
    -- Match keywords
    return self:MatchKeywords(text, self.PVP_KEYWORDS)
end