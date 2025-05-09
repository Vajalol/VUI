-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- English localization (default)
-- This serves as a reference for other localizations

-- General
L["VUI Gfinder"] = true
L["Enhances the Group Finder with advanced filtering"] = true

-- UI Text
L["Enable"] = true
L["Open Filter Dialog"] = true
L["Dialog Scale"] = true
L["Enhanced Tooltips"] = true
L["One-Click Sign Up"] = true
L["Remember Sign Up Notes"] = true
L["Sign Up on Enter"] = true
L["Show Filter Button"] = true

-- Advanced Filter
L["Enable Advanced Mode"] = true
L["Filter Expression"] = true
L["Enable Custom Sorting"] = true
L["Sorting Expression"] = true

-- Difficulties
L["Normal"] = true
L["Heroic"] = true
L["Mythic"] = true
L["Mythic+"] = true
L["Arena 2v2"] = true
L["Arena 3v3"] = true

-- Dialog
L["Minimum Difficulty"] = true
L["Maximum Difficulty"] = true
L["Min Mythic+ Level"] = true
L["Max Mythic+ Level"] = true
L["Min Rating"] = true
L["Max Rating"] = true
L["Find Groups"] = true
L["Reset Filters"] = true
L["Close"] = true

-- Tooltip
L["Group Details"] = true
L["Activity"] = true
L["Difficulty"] = true
L["Leader Score"] = true
L["Members"] = true
L["Created"] = true
L["ago"] = true

-- Categories
L["Dungeon"] = true
L["Raid"] = true
L["Arena"] = true
L["Rated Battleground"] = true

-- Roles
L["Tank"] = true
L["Healer"] = true
L["DPS"] = true

-- Misc
L["Advanced Filtering"] = true
L["Use Expression"] = true
L["Expression Help"] = true