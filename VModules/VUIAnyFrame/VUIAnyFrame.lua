--- VUIAnyFrame: Main Module
--- Based on MoveAny by D4KiR
---@class VUIAnyFrame: AceModule
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Libraries
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceDB = LibStub("AceDB-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

-- Local storage for SetHidden state
local sethidden = {}
local sethiddenSetup = {}

-- Initialize the addon
function VUIAnyFrame:OnInitialize()
    -- Get reference to the main VUI addon
    local VUI = LibStub("AceAddon-3.0"):GetAddon("VUI")
    
    -- Register with VUI's database namespace system
    self.db = VUI.db:RegisterNamespace("VUIAnyFrame", {
        profile = defaults.profile
    })
    
    -- Set up minimap button
    if LDB and LDBIcon then
        self:SetupDataBroker()
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    
    -- Register callbacks for profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
    
    -- Set up the options - use the standardized approach for VUI modules
    self:SetupOptions()
    
    -- Initialize VUI integration if VUI is available
    if VUI then
        self:InitVUIIntegration()
    end
    
    -- Create our frames
    self:CreateFrames()
    
    -- Register necessary events
    self:RegisterEvents()
    
    -- Initialize VUI integration
    self:InitVUIIntegration()
end

-- Handle slash commands
function VUIAnyFrame:SlashCommand(input)
    input = input:trim():lower()
    
    if input == "config" or input == "options" or input == "opt" or input == "" then
        self:OpenOptions()
    elseif input == "reset" or input == "r" then
        self:ResetAllFrames()
    elseif input == "lock" or input == "l" then
        self:LockFrames()
    elseif input == "unlock" or input == "u" then
        self:UnlockFrames()
    elseif input == "help" or input == "h" or input == "?" then
        self:Print("VUI AnyFrame commands:")
        self:Print(" - /va : Open config panel")
        self:Print(" - /va reset (or r): Reset all frames")
        self:Print(" - /va lock (or l): Lock all frames")
        self:Print(" - /va unlock (or u): Unlock all frames")
        self:Print(" - /va help (or h, ?): Show this help")
    else
        -- Show help by default for unknown commands
        self:Print("VUI AnyFrame commands:")
        self:Print(" - /va : Open config panel")
        self:Print(" - /va reset (or r): Reset all frames")
        self:Print(" - /va lock (or l): Lock all frames")
        self:Print(" - /va unlock (or u): Unlock all frames")
        self:Print(" - /va help (or h, ?): Show this help")
    end
end

-- Lock frames
function VUIAnyFrame:LockFrames()
    self.db.profile.general.lockFrames = true
    self:Print(L["Frames locked"])
    self:UpdateAllFrames() 
end

-- Unlock frames
function VUIAnyFrame:UnlockFrames()
    self.db.profile.general.lockFrames = false
    self:Print(L["Frames unlocked"])
    self:UpdateAllFrames() 
end

-- Reset positions of all frames
function VUIAnyFrame:ResetAllFrames()
    wipe(self.db.profile.frames)
    self:Print("All frame positions have been reset")
    self:UpdateAllFrames() 
end

-- Update all frame displays when settings change
function VUIAnyFrame:UpdateAllFrames()
    -- Implement this once we have frame management code
end

-- Hide a frame (put it in our hidden container)
function VUIAnyFrame:HideFrame(frame, soft)
    if not soft then
        if InCombatLockdown() then
            C_Timer.After(0.1, function() 
                self:HideFrame(frame, soft) 
            end)
            return
        end
        
        sethidden[frame] = true
        if sethiddenSetup[frame] == nil then
            sethiddenSetup[frame] = true
            local setparent = false
            hooksecurefunc(frame, "SetParent", function(sel, parent)
                if sethidden[sel] == nil then return end
                if setparent then return end
                setparent = true
                sel:SetParent(self.HIDDEN_FRAME)
                setparent = false
            end)
        end
        
        frame:SetParent(self.HIDDEN_FRAME)
    end
end

-- Show a previously hidden frame
function VUIAnyFrame:ShowFrame(frame)
    if InCombatLockdown() then
        C_Timer.After(0.1, function() 
            self:ShowFrame(frame) 
        end)
        return
    end
    
    sethidden[frame] = nil
    frame:SetParent(UIParent)
end

-- Set up the DataBroker (minimap button)
function VUIAnyFrame:SetupDataBroker()
    local dataObj = LDB:NewDataObject("VUIAnyFrame", {
        type = "launcher",
        text = "VUI AnyFrame",
        icon = self:GetMediaPath("Icons"),
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:OpenOptions()
            elseif button == "RightButton" then
                if self.db.profile.general.lockFrames then
                    self:UnlockFrames()
                else
                    self:LockFrames()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("VUI AnyFrame")
            tooltip:AddLine(" ")
            tooltip:AddLine(L["Left-click to move"])
            tooltip:AddLine(L["Right-click for options"])
        end,
    })
    
    LDBIcon:Register("VUIAnyFrame", dataObj, self.db.profile.minimap)
end

-- Open the options panel
function VUIAnyFrame:OpenOptions()
    -- First try to open through VUI config if available
    if VUI and VUI.Config and VUI.Config.OpenModule then
        VUI.Config:OpenModule("VUIAnyFrame")
    else
        -- Fallback to Ace config if VUI config not available
        AceConfigDialog:Open("VUIAnyFrame")
    end
end

-- Get options for configuration panel - standard function name used across VUI modules
function VUIAnyFrame:GetOptions()
    -- Basic options structure
    local options = {
        name = "VUI AnyFrame",
        handler = self,
        type = "group",
        icon = "Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm.tga",
        args = {
            general = {
                order = 1,
                type = "group",
                name = L["General"],
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = L["Enable"],
                        desc = L["Enable/disable VUI AnyFrame"],
                        get = function() return self.db.profile.general.enabled end,
                        set = function(_, value)
                            self.db.profile.general.enabled = value
                            self:UpdateAllFrames()
                        end,
                        width = "full",
                    },
                    lockFrames = {
                        order = 2,
                        type = "toggle",
                        name = L["Lock Frames"],
                        get = function() return self.db.profile.general.lockFrames end,
                        set = function(_, value)
                            self.db.profile.general.lockFrames = value
                            if value then
                                self:LockFrames()
                            else
                                self:UnlockFrames()
                            end
                        end,
                        width = "full",
                    },
                    resetAllFrames = {
                        order = 3,
                        type = "execute",
                        name = L["Reset All"],
                        func = function() self:ResetAllFrames() end,
                        width = "full",
                    },
                },
            },
            frames = {
                order = 2,
                type = "group",
                name = L["Frames"],
                args = {
                    -- Will be populated dynamically with registered frames
                },
            },
            elements = {
                order = 3,
                type = "group",
                name = L["Elements"],
                args = {
                    -- Will be populated dynamically with UI elements
                },
            },
        },
    }
    
    -- Return the generated options
    return options
end

-- Set up options
function VUIAnyFrame:SetupOptions()
    local options = self:GetOptions()
    
    -- Register with VUI Config system if available
    if VUI and VUI.Config and VUI.Config.RegisterModuleOptions then
        VUI.Config:RegisterModuleOptions("VUIAnyFrame", options, "VUI AnyFrame")
    end
    
    -- Also register with AceConfig for backward compatibility
    AceConfigRegistry:RegisterOptionsTable("VUIAnyFrame", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("VUIAnyFrame", "VUIAnyFrame")
end

-- Create our frames
function VUIAnyFrame:CreateFrames()
    -- Will be implemented in MoveFrames.lua
end

-- Register events
function VUIAnyFrame:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
end

-- Handle profile changes
function VUIAnyFrame:ProfileChanged()
    self:UpdateAllFrames()
end

-- Handle events
function VUIAnyFrame:PLAYER_ENTERING_WORLD()
    self:UpdateAllFrames()
end

function VUIAnyFrame:ADDON_LOADED(_, addon)
    -- Add any addon-specific handling here
end

-- Print a message
function VUIAnyFrame:Print(...)
    print("|cFF3FC7EBVUI AnyFrame|r:", ...);
end