--- VUIAnyFrame: Main Module
--- Based on MoveAny by D4KiR
---@class VUIAnyFrame: AceModule
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIAnyFrame = _G["VUIAnyFrame"]
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
    self.db = VUI.db:RegisterNamespace("VUIAnyFrame", self.defaults)
    
    -- Initialize settings
    self:InitSettings()
    
    -- Set up minimap button
    if LDB and LDBIcon then
        self:SetupDataBroker()
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    self:RegisterChatCommand("move", "SlashCommand")
    
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
end

-- Enable the module
function VUIAnyFrame:OnEnable()
    -- Register for events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Set up the frames and grid
    self:SetupFrames()
    self:UpdateGrid()
    
    -- Apply existing settings
    self:ApplyAllFrameSettings()
    
    -- Set initial visibility based on lock state
    self:UpdateFrameVisibility()
    
    -- Start the update cycle for scaling and dragging
    C_Timer.After(0.1, function() self:UpdateCurrentWindow() end)
    
    -- Report enabled
    self:Print(string.format("%s v%s enabled", self.TITLE or "VUI AnyFrame", self.VERSION or "1.0"))
end

-- Handle events
function VUIAnyFrame:PLAYER_ENTERING_WORLD()
    -- Apply settings after a short delay to ensure all frames are loaded
    C_Timer.After(1, function()
        self:ApplyAllFrameSettings()
        self:UpdateFrameVisibility()
    end)
end

function VUIAnyFrame:ADDON_LOADED(event, addonName)
    -- When any addon loads, check if we need to register frames from it
    C_Timer.After(0.5, function()
        self:SetupFrames()
    end)
end

function VUIAnyFrame:PLAYER_REGEN_DISABLED()
    -- Player entered combat
    if self.db.profile.global.combatLock and not self.db.profile.global.lockFrames then
        -- Save the pre-combat lock state
        self.preCombatLock = false
        
        -- Lock frames during combat
        self.db.profile.global.lockFrames = true
        self:UpdateFrameVisibility()
        
        self:Print("Frames temporarily locked for combat")
    end
end

function VUIAnyFrame:PLAYER_REGEN_ENABLED()
    -- Player left combat
    if self.db.profile.global.combatLock and self.preCombatLock == false then
        -- Restore pre-combat lock state
        self.db.profile.global.lockFrames = false
        self:UpdateFrameVisibility()
        
        self:Print("Combat ended - frames unlocked")
        self.preCombatLock = nil
    end
end

-- Handle slash commands
function VUIAnyFrame:SlashCommand(input)
    input = input:trim():lower()
    
    if input == "config" or input == "options" or input == "opt" or input == "" then
        self:OpenOptions()
    elseif input == "reset" or input == "r" then
        self:ResetAllFrameSettings()
    elseif input == "lock" or input == "l" then
        self:SetSetting("lockFrames", true)
        self:Print("Frames locked")
    elseif input == "unlock" or input == "u" then
        self:SetSetting("lockFrames", false)
        self:Print("Frames unlocked")
    elseif input == "grid" or input == "g" then
        self:ToggleSetting("showGrid")
        self:Print("Grid " .. (self.db.profile.global.showGrid and "shown" or "hidden"))
    elseif input == "snap" or input == "s" then
        self:ToggleSetting("snapToGrid")
        self:Print("Snap to grid " .. (self.db.profile.global.snapToGrid and "enabled" or "disabled"))
    elseif input == "help" or input == "h" or input == "?" then
        self:Print("VUI AnyFrame commands:")
        self:Print(" - /va : Open config panel")
        self:Print(" - /va reset (or r): Reset all frames")
        self:Print(" - /va lock (or l): Lock all frames")
        self:Print(" - /va unlock (or u): Unlock all frames")
        self:Print(" - /va grid (or g): Toggle grid")
        self:Print(" - /va snap (or s): Toggle snap to grid")
        self:Print(" - /va help (or h, ?): Show this help")
    else
        -- Toggle lock/unlock
        self:ToggleSetting("lockFrames")
        self:Print("Frames " .. (self.db.profile.global.lockFrames and "locked" or "unlocked"))
    end
end

-- Create initial frames
function VUIAnyFrame:CreateFrames()
    -- Create the hidden container frame if it doesn't exist
    if not self.HIDDEN_FRAME then
        self.HIDDEN_FRAME = CreateFrame("Frame", "VUIHIDDEN")
        self.HIDDEN_FRAME:Hide()
        self.HIDDEN_FRAME.unit = "player"
        self.HIDDEN_FRAME.auraRows = 0
    end
    
    -- Create UI Parent if needed
    if not self.UI_PARENT then
        self.UI_PARENT = CreateFrame("Frame", "VUIUIP")
        self.UI_PARENT:SetAllPoints(UIParent)
        self.UI_PARENT.unit = "player"
        self.UI_PARENT.auraRows = 0
    end
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
                        get = function() return self.db.profile.enabled end,
                        set = function(_, value)
                            self.db.profile.enabled = value
                            if value then
                                self:OnEnable()
                            else
                                self:OnDisable()
                            end
                        end,
                        width = "full",
                    },
                    lockFrames = {
                        order = 2,
                        type = "toggle",
                        name = L["Lock Frames"],
                        get = function() return self.db.profile.global.lockFrames end,
                        set = function(_, value)
                            self:SetSetting("lockFrames", value)
                        end,
                        width = "full",
                    },
                    allowScaling = {
                        order = 3,
                        type = "toggle",
                        name = L["Allow Frame Scaling"],
                        desc = L["Enable scaling frames with right-click + drag"],
                        get = function() return self.db.profile.global.allowScaling end,
                        set = function(_, value)
                            self:SetSetting("allowScaling", value)
                        end,
                        width = "full",
                    },
                    showGrid = {
                        order = 4,
                        type = "toggle",
                        name = L["Show Grid"],
                        desc = L["Show a grid when moving frames"],
                        get = function() return self.db.profile.global.showGrid end,
                        set = function(_, value)
                            self:SetSetting("showGrid", value)
                        end,
                        width = "full",
                    },
                    snapToGrid = {
                        order = 5,
                        type = "toggle",
                        name = L["Snap To Grid"],
                        desc = L["Snap frames to grid when moving"],
                        get = function() return self.db.profile.global.snapToGrid end,
                        set = function(_, value)
                            self:SetSetting("snapToGrid", value)
                        end,
                        width = "full",
                    },
                    gridSize = {
                        order = 6,
                        type = "range",
                        name = L["Grid Size"],
                        desc = L["Set the size of the grid"],
                        min = 5,
                        max = 50,
                        step = 1,
                        get = function() return self.db.profile.global.grid end,
                        set = function(_, value)
                            self:SetSetting("grid", value)
                        end,
                        width = "full",
                    },
                    combatLock = {
                        order = 7,
                        type = "toggle",
                        name = L["Lock in Combat"],
                        desc = L["Automatically lock frames when entering combat"],
                        get = function() return self.db.profile.global.combatLock end,
                        set = function(_, value)
                            self:SetSetting("combatLock", value)
                        end,
                        width = "full",
                    },
                    resetAllFrames = {
                        order = 8,
                        type = "execute",
                        name = L["Reset All Frames"],
                        desc = L["Reset all frame positions and scales"],
                        func = function() self:ResetAllFrameSettings() end,
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
                    intro = {
                        order = 0,
                        type = "description",
                        name = L["Select frames to customize their appearance or visibility."],
                        width = "full",
                    },
                    -- Blizzard frames will be added here
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
    
    -- Add blizzard frames that can be hidden
    for frameName, hidden in pairs(self.db.profile.global.hideBlizzardFrames) do
        options.args.frames.args[frameName] = {
            type = "toggle",
            name = frameName,
            desc = L["Toggle visibility of "] .. frameName,
            get = function() return self:GetBlizzardFrameVisibility(frameName) end,
            set = function(_, value)
                self:SetBlizzardFrameVisibility(frameName, value)
            end,
            width = "full",
        }
    end
    
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

-- Register events
function VUIAnyFrame:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

-- Handle profile changes
function VUIAnyFrame:ProfileChanged()
    self:InitSettings()
    self:ApplyAllFrameSettings()
    self:UpdateFrameVisibility()
end

-- Print a message
function VUIAnyFrame:Print(...)
    print("|cFF3FC7EBVUI AnyFrame|r:", ...);
end