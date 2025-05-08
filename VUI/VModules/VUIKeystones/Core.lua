-- VUIKeystones - Core functionality
local VUIKeystones = LibStub("AceAddon-3.0"):GetAddon("VUIKeystones")
local L = VUIKeystones.L

-- Initialize any shared variables or utility functions

-- Utility function: format time in seconds to a readable string
local function SecondsToTime(seconds, format)
    local negative = seconds < 0
    seconds = math.abs(seconds)
    
    local t = {}
    t.h = math.floor(seconds / 3600)
    t.m = math.floor((seconds / 60) % 60)
    t.s = math.floor(seconds % 60)
    
    if negative then
        return string.format("-%01d:%02d:%02d", t.h, t.m, t.s)
    else
        return string.format("%01d:%02d:%02d", t.h, t.m, t.s)
    end
end

function VUIKeystones:FormatTime(seconds)
    return SecondsToTime(seconds)
end

-- Initialize the addon
function VUIKeystones:OnInitialize()
    -- Register SavedVariables under the unified VUI_SavedVariables structure
    if not VUI_SavedVariables then VUI_SavedVariables = {} end
    if not VUI_SavedVariables.VUIKeystones then VUI_SavedVariables.VUIKeystones = {} end
    
    self.db = LibStub("AceDB-3.0"):New("VUI_SavedVariables.VUIKeystones", defaults, true)
    
    -- Initialize data storage
    self.data = VUI_SavedVariables.VUIKeystones.data or {}
    VUI_SavedVariables.VUIKeystones.data = self.data
    
    -- Register slash commands
    self:RegisterChatCommand("vuikeystones", "SlashCommand")
    self:RegisterChatCommand("vk", "SlashCommand")
    
    -- Register callbacks for profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
    
    -- Initialize VUI integration
    self:InitVUIIntegration()
    
    -- Register for game events
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("CHALLENGE_MODE_RESET")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize module components
    for name, module in pairs(self.Modules) do
        if module.OnInitialize then
            module:OnInitialize()
        end
    end
end

-- Handle slash commands
function VUIKeystones:SlashCommand(input)
    input = input:trim()
    
    if input == "config" or input == "options" or input == "opt" or input == "" then
        self:OpenOptions()
    elseif input == "reset" then
        self:ResetOptions()
    else
        self:Print("VUI Keystones commands:")
        self:Print("/vk - Open configuration panel")
        self:Print("/vk reset - Reset configuration to defaults")
    end
end

-- Handle profile changes
function VUIKeystones:ProfileChanged()
    -- Update settings on profile change
    for name, module in pairs(self.Modules) do
        if module.ProfileChanged then
            module:ProfileChanged()
        end
    end
end

-- Open the options panel
function VUIKeystones:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory("VUIKeystones")
    InterfaceOptionsFrame_OpenToCategory("VUIKeystones") -- Twice to ensure it opens (Blizzard UI bug)
end

-- Reset options to defaults
function VUIKeystones:ResetOptions()
    self.db:ResetProfile()
    self:Print("VUI Keystones options reset to defaults.")
end

-- Event handlers
function VUIKeystones:CHALLENGE_MODE_START()
    for name, module in pairs(self.Modules) do
        if module.CHALLENGE_MODE_START then
            module:CHALLENGE_MODE_START()
        end
    end
end

function VUIKeystones:CHALLENGE_MODE_COMPLETED()
    for name, module in pairs(self.Modules) do
        if module.CHALLENGE_MODE_COMPLETED then
            module:CHALLENGE_MODE_COMPLETED()
        end
    end
end

function VUIKeystones:CHALLENGE_MODE_RESET()
    for name, module in pairs(self.Modules) do
        if module.CHALLENGE_MODE_RESET then
            module:CHALLENGE_MODE_RESET()
        end
    end
end

function VUIKeystones:PLAYER_ENTERING_WORLD()
    for name, module in pairs(self.Modules) do
        if module.PLAYER_ENTERING_WORLD then
            module:PLAYER_ENTERING_WORLD()
        end
    end
end

-- Print a message
function VUIKeystones:Print(...)
    print("|cFF3FC7EBVUI Keystones|r:", ...);
end