-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- English (Default) Localization
local LOCALE = GetLocale()
if LOCALE == "enUS" or LOCALE == "enGB" then
    -- General strings
    L["VUI Gfinder"] = true
    L["VUIGfinder enabled"] = true
    L["VUIGfinder disabled"] = true
    L["Open Filter Dialog"] = true
    L["Find Groups"] = true
    L["Reset Filters"] = true
    L["Use Expression"] = true
    L["Expression Help"] = "Use expressions like: 'mythicplus >= 10 and members < 4'. See help for more info."
    L["ago"] = "ago"
    
    -- Tab names
    L["Dungeon"] = true
    L["Raid"] = true
    L["Arena"] = true
    L["Rated Battleground"] = true
    L["Advanced Filtering"] = true
    
    -- Difficulties
    L["Normal"] = true
    L["Heroic"] = true
    L["Mythic"] = true
    L["Mythic+"] = true
    L["Arena 2v2"] = true
    L["Arena 3v3"] = true
    
    -- Group details
    L["Group Details"] = true
    L["Activity"] = true
    L["Difficulty"] = true
    L["Leader"] = true
    L["Members"] = true
    L["Created"] = true
    
    -- Filter UI
    L["Minimum Level"] = true
    L["Maximum Level"] = true
    L["Minimum Rating"] = true
    L["Maximum Rating"] = true
    L["Minimum Score"] = true
    L["Maximum Score"] = true
    L["Filter by Type"] = true
    L["Filter by Difficulty"] = true
    L["Filter by Role"] = true
    L["Filter by Keywords"] = true
    
    -- Roles
    L["Tank"] = true
    L["Healer"] = true
    L["DPS"] = true
    L["Any Role"] = true
    
    -- Mythic+ specific
    L["Mythic+ Level"] = true
    L["Timed only"] = true
    L["Within weekly limit"] = true
    
    -- PvP specific
    L["Rating Range"] = true
    L["Voice required"] = true
    L["Exclude sold runs"] = true
    
    -- Misc
    L["Loading..."] = true
    L["No groups found"] = true
    L["Apply filters"] = true
    L["Clear filters"] = true
    L["Show options"] = true
    L["Hide options"] = true
end