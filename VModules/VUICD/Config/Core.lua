local _, VUI = ...
<<<<<<< HEAD

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Setup localization with fallback
local L = {}
try = pcall(function() L = LibStub("AceLocale-3.0"):GetLocale("VUI") end)
if not try then
    -- Fallback localization table
    L["VUI Cooldown Tracker"] = "VUI Cooldown Tracker"
    L["General"] = "General"
    L["Party"] = "Party"
    L["Spell Editor"] = "Spell Editor"
    L["Profiles"] = "Profiles"
end

-- Store localization globally for other files to use
VUICD.L = VUICD.L or L

-- Ace libraries
-- Set up Ace libraries with fallbacks
local AceConfigRegistry, AceConfigDialog, VUIConfig
try = pcall(function() 
    AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigDialog = LibStub("AceConfigDialog-3.0")
    VUIConfig = LibStub("VUIConfig-1.0") 
end)

-- Initialize empty objects if libraries aren't available
AceConfigRegistry = AceConfigRegistry or {}
AceConfigDialog = AceConfigDialog or {}
VUIConfig = VUIConfig or {}
=======
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local VUIConfig = LibStub("VUIConfig-1.0")
local VUICD = VUI.VUICD or VUI:GetModule("VUICD")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

-- Configuration variables
local E = VUICD
local OCD = E.OmniCD
local P = E.Party
local optionFrames = {}
local isRegistered

-- Register configuration
function E:RegisterOptions()
    if isRegistered then return end

    -- Create main configuration panel
    local function GetOptions()
        if not E.Config.options then
            E:CreateOptions()
        end
        return E.Config.options
    end

    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions("VUICD", function()
        AceConfigDialog:Open("VUICD")
    end)

    -- Register with Ace3 configuration
    AceConfigRegistry:RegisterOptionsTable("VUICD", GetOptions)
    optionFrames.general = AceConfigDialog:AddToBlizOptions("VUICD", "VUI Cooldown Tracker")

    -- Register slash command
    VUI:RegisterChatCommand("vuicd", function() AceConfigDialog:Open("VUICD") end)
    
    isRegistered = true
end

-- Create the options table
function E:CreateOptions()
    E.Config.options = {
        name = "|cff00b4ff"..L["VUI Cooldown Tracker"].."|r",
        type = "group",
        args = {
            general = {
                order = 10,
                type = "group",
                name = L["General"],
                get = function(info) return E.DB.profile[info[#info]] end,
                set = function(info, value) 
                    E.DB.profile[info[#info]] = value
                    E:Refresh() 
                end,
                args = {}
            },
            party = {
                order = 20,
                type = "group",
                childGroups = "tab",
                name = L["Party"],
                get = function(info) return P.db.profile[info[#info]] end,
                set = function(info, value) 
                    P.db.profile[info[#info]] = value
                    P:Refresh() 
                end,
                args = {}
            },
            spellEditor = {
                order = 30,
                type = "group",
                name = L["Spell Editor"],
                args = {}
            },
            profiles = {
                order = 40,
                type = "group",
                name = L["Profiles"],
                args = {}
            }
        }
    }

    -- Load sub-module options
    E:AddGeneralOptions(E.Config.options.args.general.args)
    
    -- Party module options
    P:AddPartyOptions(E.Config.options.args.party.args)

    -- Add profile options
    E.Config.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.DB)
end

-- Apply current theme to the module
function E:ApplyTheme()
    local themeColor = VUI:GetThemeColor()
    -- Apply theme color to module elements
    if P.bars then
        for i = 1, #P.bars do
            local statusBar = P.bars[i].statusBar
            if statusBar and statusBar.SetStatusBarColor then
                statusBar:SetStatusBarColor(themeColor.r, themeColor.g, themeColor.b)
            end
        end
    end
end

-- Register the module with VUI's core theme system
function E:RegisterWithThemeSystem()
    VUI:RegisterThemeCallback(function()
        E:ApplyTheme()
    end)
end