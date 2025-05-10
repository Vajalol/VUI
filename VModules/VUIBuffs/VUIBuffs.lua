---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceRegistry = LibStub("AceConfigRegistry-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LCG = LibStub("LibCustomGlow-1.0")
local LDBIcon = LibStub("LibDBIcon-1.0")
local version = C_AddOns.GetAddOnMetadata("VUI", "Version")
local Masque

local LATEST_DB_VERSION = 1.0

-- Localization Table
local L = VUIBuffs.L

-- Upvalues
local _G = _G
local C_Spell = C_Spell
local C_Timer = C_Timer
local PixelUtil = PixelUtil
local CopyTable = CopyTable
local GetSpellTexture = (C_Spell and C_Spell.GetSpellTexture) or GetSpellTexture
local GetSpellInfo = VUIBuffs.GetSpellInfo
local UnitIsPlayer = UnitIsPlayer
local InCombatLockdown = InCombatLockdown
local GetNumGroupMembers = GetNumGroupMembers
local IsInInstance = IsInInstance
local next = next
local pairs = pairs
local ipairs = ipairs
local wipe = wipe
local type = type
local rawset = rawset
local format = format
local select = select
local CreateFrame = CreateFrame
local table_sort = table.sort
local string_find = string.find
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local math_rand = math.random
local DebuffTypeColor = DebuffTypeColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local testBuffs = {}
local testBuffIds = {}
local testBarNames = {}
local testSingleAura
local testTextFrame

-- Default settings for the addon
local defaults = {
    profile = {
        db_version = LATEST_DB_VERSION,
        general = {
            enabled = true,
            enabledInWorld = true,
            enabledInDungeons = true,
            enabledInRaids = true,
            enabledInArenas = true,
            enabledInBattlegrounds = true,
            blizzardBuffs = false,
            positionWorldMapButton = true,
            hideIconBorder = false,
            showEmptyBuffs = false,
            anchorMinimap = false,
            lockFrames = false,
            borderStyle = 1, -- 1 = thin, 2 = classic
            showBigDebuffs = true,
            bigDebuffAnchors = {
                anchor = "CENTER",
                xOffset = 0,
                yOffset = 0,
            }
        },
        customSpells = {
            spells = {},
        },
        
        -- Bar display settings
        barDisplays = {
            global = {
                enabled = true,
                barHeight = 14,
                barWidth = 126,
                barPadding = 2,
                anchorPoint = "TOPLEFT",
                growthDirection = "DOWN",
                iconSize = 16,
                showSpark = true,
                sparkWidth = 8,
                showTimer = true,
                timerPosition = "RIGHT",
                timerJustifyH = "RIGHT",
                timerTextSize = 12,
                timerFormat = "condensed",
                showTimerDecimals = true,
                showName = true,
                namePosition = "LEFT",
                nameJustifyH = "LEFT",
                nameTextSize = 12,
                nameLengthLimit = 0,
                showCount = true,
                countPosition = "LEFT", -- LEFT, RIGHT, ICON
                countJustifyH = "CENTER",
                countTextSize = 12,
                countXOffset = 0,
                countYOffset = 0,
                colorBarByType = true,
                barTexture = VUIBuffs:GetMediaPath("Bars", "Smooth"),
                edgeTexture = VUIBuffs:GetMediaPath("Borders", "Default"),
                backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 },
                barColor = { r = 0.8, g = 0.8, b = 0.8, a = 0.7 },
                font = "Interface\\AddOns\\VUI\\Media\\Fonts\\expressway.ttf",
                fontOutline = "OUTLINE",
                displayMode = "currentMax",
                sortMethod = "timeleft",
                sortDirection = "asc",
                barSettings = {
                    player = {
                        enabled = true,
                        visible = true,
                    },
                    party = {
                        enabled = true,
                        visible = true,
                    },
                    raid = {
                        enabled = true,
                        visible = true,
                    },
                    pet = {
                        enabled = true,
                        visible = true,
                    },
                    arena = {
                        enabled = true,
                        visible = true,
                    },
                    tank = {
                        enabled = true,
                        visible = true,
                    },
                    assist = {
                        enabled = true,
                        visible = true,
                    },
                },
                additionalFrames = {},
            },
        },
        
        -- Frame settings for specific groups (player, party, etc.)
        frameSettings = {
        },

        -- Custom categories
        customCategories = {
            -- Categories for custom buffs/debuffs
        },

        -- Minimap button
        minimap = {
            hide = false,
        },

        -- Position data for various frames
        position = {},

        -- Aura cache
        auraCache = {},
    }
}

-- Initialize the addon
function VUIBuffs:OnInitialize()
    -- Register saved variables under the unified VUI_SavedVariables structure
    if not VUI_SavedVariables then VUI_SavedVariables = {} end
    if not VUI_SavedVariables.VUIBuffs then VUI_SavedVariables.VUIBuffs = {} end
    
    self.db = LibStub("AceDB-3.0"):New("VUI_SavedVariables.VUIBuffs", defaults, true)
    
    -- Set up minimap button
    self:SetupDataBroker()
    
    -- Check for Masque (skinning addon)
    if IsAddOnLoaded("Masque") then
        Masque = LibStub("Masque", true)
        if Masque then
            self.MasqueGroup = Masque:Group("VUI", "Buffs")
        end
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuibuffs", "SlashCommand")
    self:RegisterChatCommand("vb", "SlashCommand")
    
    -- Register callbacks for profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
    
    -- Check for supported addons
    self:CheckForSupportedAddons()
    
    -- Initialize addon options
    self:SetupOptions()
    
    -- Create our frames
    self:CreateFrames()
    
    -- Register any events we need
    self:RegisterEvents()
    
    -- Initialize VUI integration if VUI is available
    if VUI then
        self:InitVUIIntegration()
    end
end

-- Handle slash commands
function VUIBuffs:SlashCommand(input)
    input = input:trim():lower()
    
    if input == "test" or input == "t" then
        self:ToggleTestMode()
    elseif input == "reset" or input == "r" then
        self:ResetPositions()
    elseif input == "unlock" or input == "u" then
        self:ToggleLock()
    elseif input == "help" or input == "h" or input == "?" then
        self:Print("VUI Buffs commands:")
        self:Print(" - /vb : Open config panel")
        self:Print(" - /vb test (or t): Toggle test mode")
        self:Print(" - /vb reset (or r): Reset positions")
        self:Print(" - /vb unlock (or u): Toggle frame lock")
        self:Print(" - /vb help (or h, ?): Show this help")
    else
        -- Default to opening options
        self:OpenOptions()
    end
end

-- Toggle lock/unlock of frames
function VUIBuffs:ToggleLock()
    self.db.profile.general.lockFrames = not self.db.profile.general.lockFrames
    self:Print(self.db.profile.general.lockFrames and "Frames locked" or "Frames unlocked")
    self:UpdateAllDisplays()
end

-- Reset positions of all frames
function VUIBuffs:ResetPositions()
    wipe(self.db.profile.position)
    self:Print("All frame positions have been reset")
    self:UpdateAllDisplays() 
end

-- Toggle test mode
function VUIBuffs:ToggleTestMode()
    if self.testMode then
        self:DisableTestMode()
    else
        self:EnableTestMode()
    end
end

-- Enable test mode
function VUIBuffs:EnableTestMode()
    self.testMode = true
    self:Print("Test mode enabled")
    self:UpdateAllDisplays()
end

-- Disable test mode
function VUIBuffs:DisableTestMode()
    self.testMode = false
    self:Print("Test mode disabled")
    self:UpdateAllDisplays()
end

-- Update all displays when settings change
function VUIBuffs:UpdateAllDisplays()
    -- Implement this once we have displays to update
end

-- Set up the DataBroker (minimap button)
function VUIBuffs:SetupDataBroker()
    local dataObj = LDB:NewDataObject("VUIBuffs", {
        type = "launcher",
        text = "VUI Buffs",
        icon = self:GetMediaPath("Icons", "Default"),
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:OpenOptions()
            elseif button == "RightButton" then
                self:ToggleTestMode()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("VUI Buffs")
            tooltip:AddLine(" ")
            tooltip:AddLine("Left Click: Open Options")
            tooltip:AddLine("Right Click: Toggle Test Mode")
        end,
    })
    
    LDBIcon:Register("VUIBuffs", dataObj, self.db.profile.minimap)
end

-- Open the options panel
function VUIBuffs:OpenOptions()
    -- First try to open through VUI config if available
    if VUI and VUI.Config and VUI.Config.OpenModule then
        VUI.Config:OpenModule("VUIBuffs")
    else
        -- Fallback to Ace config if VUI config not available
        AceConfigDialog:Open("VUIBuffs")
    end
end

-- Get options for configuration panel - standard function name used across VUI modules
function VUIBuffs:GetOptions()
    -- Basic options structure
    local options = {
        name = "VUI Buffs",
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
                        desc = L["Enable/disable VUI Buffs"],
                        get = function() return self.db.profile.general.enabled end,
                        set = function(_, value)
                            self.db.profile.general.enabled = value
                            self:UpdateAllDisplays()
                        end,
                        width = "full",
                    },
                    -- More options to be added
                },
            },
            -- More option categories to be added
        },
    }
    
    return options
end

-- Set up options
function VUIBuffs:SetupOptions()
    local options = self:GetOptions()
    
    -- Register with VUI Config system if available
    if VUI and VUI.Config and VUI.Config.RegisterModuleOptions then
        VUI.Config:RegisterModuleOptions("VUIBuffs", options, "VUI Buffs")
    end
    
    -- Also register with AceConfig for backward compatibility
    AceRegistry:RegisterOptionsTable("VUIBuffs", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("VUIBuffs", "VUIBuffs")
end

-- Create our frames
function VUIBuffs:CreateFrames()
    -- To be implemented
end

-- Register events
function VUIBuffs:RegisterEvents()
    -- To be implemented 
end

-- Handle profile changes
function VUIBuffs:ProfileChanged()
    self:UpdateAllDisplays()
end

-- Print a debug message
function VUIBuffs:Print(...)
    print("|cFF33FF99VUIBuffs|r:", ...);
end