--[[
    Gossip.lua
    Part of VUIKeystones
    Handles NPC gossip automation for Mythic+ keystones
    Based on AngryKeystones by Ermad (https://github.com/Ermad/angry-keystones)
]]

local ADDON, Addon = ...
local Mod = Addon:NewModule('Gossip')
local L = Addon.L

-- Blizzard APIs
local C_GossipInfo = C_GossipInfo
local C_ChallengeMode = C_ChallengeMode

-- Constants
local CHALLENGE_MODE_GOSSIP_PATTERN = L["Challenge Mode: %s"]
local CHALLENGE_MODE_KEYSTONE_LINE = L["Insert your Keystone"]

-- Module variables
local isInitialized = false
local autoConfirmKeystone = true
local autoSelectKeystone = true

-- Initialize module
function Mod:OnInitialize()
    self:RegisterConfig()
    self:RegisterEvent("GOSSIP_SHOW")
    self:RegisterEvent("GOSSIP_CLOSED")
    isInitialized = true
end

function Mod:OnEnable()
    self:Debug("Gossip module enabled")
end

function Mod:OnDisable()
    self:Debug("Gossip module disabled")
end

-- Register configuration options
function Mod:RegisterConfig()
    local defaults = {
        profile = {
            enabled = true,
            autoConfirmKeystone = true,
            autoSelectKeystone = true,
        }
    }
    
    Addon.Config:RegisterModuleDefaults("Gossip", defaults)
    
    local options = {
        enabled = {
            type = "toggle",
            name = L["Keystone Automation"],
            desc = L["Automatically handle keystone-related dialog options"],
            width = "full",
            order = 1,
            get = function() return Addon.db.profile.Gossip.enabled end,
            set = function(_, value) 
                Addon.db.profile.Gossip.enabled = value
                if value then
                    Mod:OnEnable()
                else
                    Mod:OnDisable()
                end
            end
        },
        autoSelectKeystone = {
            type = "toggle",
            name = L["Auto-select Keystone"],
            desc = L["Automatically select the keystone dialog option"],
            width = "full",
            order = 2,
            get = function() return Addon.db.profile.Gossip.autoSelectKeystone end,
            set = function(_, value) 
                Addon.db.profile.Gossip.autoSelectKeystone = value
                autoSelectKeystone = value
            end
        },
        autoConfirmKeystone = {
            type = "toggle",
            name = L["Auto-confirm Keystone"],
            desc = L["Automatically confirm keystone insertion"],
            width = "full",
            order = 3,
            get = function() return Addon.db.profile.Gossip.autoConfirmKeystone end,
            set = function(_, value) 
                Addon.db.profile.Gossip.autoConfirmKeystone = value
                autoConfirmKeystone = value
            end
        }
    }
    
    Addon.Config:RegisterModuleOptions("Gossip", options, L["Keystone Automation"])
    
    -- Initialize from saved settings
    autoConfirmKeystone = defaults.profile.autoConfirmKeystone
    autoSelectKeystone = defaults.profile.autoSelectKeystone
end

-- Event handlers
function Mod:GOSSIP_SHOW()
    if not Addon.db.profile.Gossip.enabled then return end
    
    local gossipOptions = C_GossipInfo.GetOptions()
    if not gossipOptions or #gossipOptions == 0 then return end
    
    -- Look for the keystone option
    if autoSelectKeystone then
        for i, option in ipairs(gossipOptions) do
            if option.name and (option.name:find(CHALLENGE_MODE_KEYSTONE_LINE) or option.name:match(CHALLENGE_MODE_GOSSIP_PATTERN:format(".*"))) then
                C_GossipInfo.SelectOption(option.gossipOptionID)
                self:Debug("Auto-selected keystone option")
                return
            end
        end
    end
    
    -- Handle automating keystone insertion based on current UI state
    if autoConfirmKeystone and C_ChallengeMode.HasSlottedKeystone() then
        -- Check if this is the keystone insertion dialog
        local title = StaticPopup1 and StaticPopup1.text and StaticPopup1.text:GetText()
        if title and title:find(L["Challenge Mode"]) then
            StaticPopup1Button1:Click()
            self:Debug("Auto-confirmed keystone insertion")
            return
        end
    end
end

function Mod:GOSSIP_CLOSED()
    -- Nothing to do here for now
end

-- Debug function
function Mod:Debug(...)
    if Addon.debug then
        Addon:Print("Gossip:", ...)
    end
end