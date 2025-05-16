---@class VUIBuffs: AceModule
<<<<<<< HEAD
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIBuffs = _G["VUIBuffs"]
-- Create safe LibStub wrappers that won't crash the addon if libraries aren't loaded yet
local function SafeLibStub(name)
    if LibStub then
        -- Use pcall to catch errors rather than crashing
        local success, result = pcall(function() return LibStub(name) end)
        if success then
            return result
        else
            -- Return a no-op table if lib can't be found
            return {}
        end
    else
        return {}
    end
end

-- Safely load libraries
local AceConfigDialog = SafeLibStub("AceConfigDialog-3.0")
local AceRegistry = SafeLibStub("AceConfigRegistry-3.0")
local LDB = SafeLibStub("LibDataBroker-1.1")
local LCG = SafeLibStub("LibCustomGlow-1.0")
local LDBIcon = SafeLibStub("LibDBIcon-1.0")
local LSM = SafeLibStub("LibSharedMedia-3.0")
=======
local VUIBuffs = _G.VUIBuffs or {} -- Reference the global VUIBuffs created in Init.lua
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceRegistry = LibStub("AceConfigRegistry-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LCG = LibStub("LibCustomGlow-1.0")
local LDBIcon = LibStub("LibDBIcon-1.0")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
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
            useMasque = true,
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
    -- Get reference to the main VUI addon using global reference pattern to fix load order issues
    local VUI = _G["VUI"]
    
    -- Register with VUI's database namespace system
    self.db = VUI.db:RegisterNamespace("VUIBuffs", {
        profile = defaults.profile
    })
    
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
    
    -- Check environment immediately after initialization
    self:CheckEnvironment()
    
    -- Initialize VUI integration if VUI is available
    if VUI then
        self:InitVUIIntegration()
    end
end

-- Handle slash commands
function VUIBuffs:SlashCommand(input)
    -- Safety check to prevent "nil self" errors
    if not self then
        print("|cffff0000VUIBuffs Error:|r SlashCommand called with nil self")
        return
    end
    
    input = input:trim():lower()
    
    if input == "test" or input == "t" then
        -- Use pcall for safety
        local success, errorMsg = pcall(function()
            self:ToggleTestMode()
        end)
        
        if not success then
            print("|cffff0000VUIBuffs Error:|r Failed to toggle test mode: " .. (errorMsg or "Unknown error"))
        end
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
    -- Use a local variable for safety, allowing function to be called directly
    local self_ref = self
    
    -- Safety check to prevent "nil self" errors
    if not self_ref then
        print("|cffff0000VUIBuffs Error:|r Test function called with nil self")
        
        -- Try to find alternative module references if self is nil
        if _G["VUIBuffs"] and _G["VUIBuffs"] ~= self_ref then
            self_ref = _G["VUIBuffs"]
        elseif _G["VUI"] and _G["VUI"].GetModule then
            -- Try getting through VUI:GetModule
            local success, module = pcall(function() return _G["VUI"]:GetModule("VUIBuffs") end)
            if success and module then
                self_ref = module
            end
        end
        
        -- If we still don't have a valid module reference, give up
        if not self_ref then
            print("|cffff0000VUIBuffs Error:|r Could not find valid module reference for toggle test mode")
            return
        end
    end
    
    -- Now we should have a valid module reference in self_ref
    if self_ref.testMode then
        self_ref:DisableTestMode()
    else
        self_ref:EnableTestMode()
    end
end

-- Enable test mode
function VUIBuffs:EnableTestMode()
    -- Use local reference for safety
    local self_ref = self
    
    -- Safety check to prevent "nil self" errors
    if not self_ref then
        print("|cffff0000VUIBuffs Error:|r EnableTestMode called with nil self")
        
        -- Try to find alternative module references
        if _G["VUIBuffs"] and _G["VUIBuffs"] ~= self_ref then
            self_ref = _G["VUIBuffs"]
        else
            return
        end
    end
    
    -- Use pcall to catch any errors that might occur
    local success, errorMsg = pcall(function()
        self_ref.testMode = true
        
        -- Safe debug output
        if self_ref.Print then
            self_ref:Print("Test mode enabled")
        else
            print("|cFF33FF99VUIBuffs|r: Test mode enabled")
        end
        
        -- Safe update call
        if self_ref.UpdateAllDisplays then
            self_ref:UpdateAllDisplays()
        end
    end)
    
    -- Log errors if something went wrong
    if not success then
        print("|cffff0000VUIBuffs Error:|r Failed to enable test mode: " .. tostring(errorMsg))
    end
end

-- Disable test mode
function VUIBuffs:DisableTestMode()
    -- Use local reference for safety
    local self_ref = self
    
    -- Safety check to prevent "nil self" errors
    if not self_ref then
        print("|cffff0000VUIBuffs Error:|r DisableTestMode called with nil self")
        
        -- Try to find alternative module references
        if _G["VUIBuffs"] and _G["VUIBuffs"] ~= self_ref then
            self_ref = _G["VUIBuffs"]
        else
            return
        end
    end
    
    -- Use pcall to catch any errors that might occur
    local success, errorMsg = pcall(function()
        self_ref.testMode = false
        
        -- Safe debug output
        if self_ref.Print then
            self_ref:Print("Test mode disabled")
        else
            print("|cFF33FF99VUIBuffs|r: Test mode disabled")
        end
        
        -- Safe update call
        if self_ref.UpdateAllDisplays then
            self_ref:UpdateAllDisplays()
        end
    end)
    
    -- Log errors if something went wrong
    if not success then
        print("|cffff0000VUIBuffs Error:|r Failed to disable test mode: " .. tostring(errorMsg))
    end
end

-- Update all displays when settings change
function VUIBuffs:UpdateAllDisplays()
    -- Use a local variable for safety
    local self_ref = self
    
    -- Safety check to prevent "nil self" errors
    if not self_ref then
        print("|cffff0000VUIBuffs Error:|r UpdateAllDisplays called with nil self")
        
        -- Try to find alternative module references
        if _G["VUIBuffs"] and _G["VUIBuffs"] ~= self_ref then
            self_ref = _G["VUIBuffs"]
            
            -- Try to call the function on the found module
            if self_ref.UpdateAllDisplays then
                return self_ref:UpdateAllDisplays()
            end
        end
        
        return
    end
    
    -- Use pcall to safely perform updates
    local success, errorMsg = pcall(function()
        -- Check if we should display in current environment
        local shouldDisplay = self_ref:ShouldDisplayInCurrentEnvironment()
        
        -- Always show in test mode
        if self_ref.testMode then
            shouldDisplay = true
        end
        
        -- Update frame visibility
        self_ref:UpdateFrameVisibility(shouldDisplay)
        
        -- If we shouldn't display, no need to update the frames
        if not shouldDisplay and not self_ref.testMode then
            return
        end
        
        -- Update any frames we have created
        if self_ref.frames then
            for _, frame in pairs(self_ref.frames) do
                if frame.Update then
                    frame:Update()
                end
            end
        end
    end)
    
    -- Log errors if something went wrong
    if not success then
        if self_ref.Debug then
            self_ref:Debug("Error in UpdateAllDisplays: " .. tostring(errorMsg))
        else
            print("|cffff0000VUIBuffs Error:|r Failed to update displays: " .. tostring(errorMsg))
        end
    end
end

-- Set up the DataBroker (minimap button)
function VUIBuffs:SetupDataBroker()
    -- Safety check to prevent "nil self" errors
    if not self then
        print("|cffff0000VUIBuffs Error:|r SetupDataBroker called with nil self")
        return
    end
    
    local this = self -- Capture self in a local variable for closure
    
    local dataObj = LDB:NewDataObject("VUIBuffs", {
        type = "launcher",
        text = "VUI Buffs",
        icon = self:GetMediaPath("Icons", "Default"),
        OnClick = function(_, button)
            if button == "LeftButton" then
                this:OpenOptions()
            elseif button == "RightButton" then
                -- Use pcall for safety
                local success, errorMsg = pcall(function()
                    this:ToggleTestMode()
                end)
                
                if not success then
                    -- If direct call fails, try using global reference
                    local VUIBuffsGlobal = _G["VUIBuffs"]
                    if VUIBuffsGlobal and VUIBuffsGlobal.ToggleTestMode then
                        VUIBuffsGlobal:ToggleTestMode()
                    else
                        print("|cffff0000VUIBuffs Error:|r Failed to toggle test mode: " .. (errorMsg or "Unknown error"))
                    end
                end
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
    -- Safety check to prevent "nil self" errors
    if not self then
        print("|cffff0000VUIBuffs Error:|r OpenOptions called with nil self")
        
        -- Try alternative methods if self is nil
        if VUI and VUI.ConfigHelpers and VUI.ConfigHelpers.StandardOpenOptions then
            VUI.ConfigHelpers.StandardOpenOptions("VUIBuffs")
            return
        elseif _G.OpenVUIModuleOptions then
            _G.OpenVUIModuleOptions("VUIBuffs")
            return
        end
        
        -- Fallback to AceConfigDialog directly if all else fails
        local AceConfigDialog = LibStub and LibStub("AceConfigDialog-3.0", true)
        if AceConfigDialog then
            AceConfigDialog:Open("VUIBuffs")
        end
        
        return
    end

    -- Use the standardized helper if available
    if VUI and VUI.ConfigHelpers and VUI.ConfigHelpers.StandardOpenOptions then
        VUI.ConfigHelpers.StandardOpenOptions("VUIBuffs")
    elseif _G.OpenVUIModuleOptions then
        -- Use global helper as an alternative
        _G.OpenVUIModuleOptions("VUIBuffs")
    else
        -- First try to open through VUI config if available
        if VUI then
            if VUI.Config and type(VUI.Config) == "function" then
                -- When Config is a function, call it directly
                VUI.Config("VUIBuffs")
            elseif VUI.Config and type(VUI.Config) == "table" and VUI.Config.OpenModule then
                -- When Config is a table with OpenModule, use that
                VUI.Config:OpenModule("VUIBuffs")
            elseif VUI.OpenConfig then
                -- Try the VUI.OpenConfig function if it exists
                VUI:OpenConfig("VUIBuffs")
            else
                -- Fallback to Ace config if VUI config not available
                AceConfigDialog:Open("VUIBuffs")
            end
        else
            -- Fallback to Ace config if VUI config not available
            AceConfigDialog:Open("VUIBuffs")
        end
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
                    displayHeader = {
                        order = 5,
                        type = "header",
                        name = L["Display Conditions"] or "Display Conditions",
                    },
                    enabledInWorld = {
                        order = 6,
                        type = "toggle",
                        name = L["Show in World"] or "Show in World",
                        desc = L["Show buffs when in the open world"] or "Show buffs when in the open world",
                        get = function() return self.db.profile.general.enabledInWorld end,
                        set = function(_, value)
                            self.db.profile.general.enabledInWorld = value
                            self:CheckEnvironment()
                        end,
                        width = "full",
                    },
                    enabledInDungeons = {
                        order = 7,
                        type = "toggle",
                        name = L["Show in Dungeons"] or "Show in Dungeons",
                        desc = L["Show buffs when in dungeon instances"] or "Show buffs when in dungeon instances",
                        get = function() return self.db.profile.general.enabledInDungeons end,
                        set = function(_, value)
                            self.db.profile.general.enabledInDungeons = value
                            self:CheckEnvironment()
                        end,
                        width = "full",
                    },
                    enabledInRaids = {
                        order = 8,
                        type = "toggle",
                        name = L["Show in Raids"] or "Show in Raids",
                        desc = L["Show buffs when in raid instances"] or "Show buffs when in raid instances",
                        get = function() return self.db.profile.general.enabledInRaids end,
                        set = function(_, value)
                            self.db.profile.general.enabledInRaids = value
                            self:CheckEnvironment()
                        end,
                        width = "full",
                    },
                    enabledInArenas = {
                        order = 9,
                        type = "toggle",
                        name = L["Show in Arenas"] or "Show in Arenas",
                        desc = L["Show buffs when in arena instances"] or "Show buffs when in arena instances",
                        get = function() return self.db.profile.general.enabledInArenas end,
                        set = function(_, value)
                            self.db.profile.general.enabledInArenas = value
                            self:CheckEnvironment()
                        end,
                        width = "full",
                    },
                    enabledInBattlegrounds = {
                        order = 10,
                        type = "toggle",
                        name = L["Show in Battlegrounds"] or "Show in Battlegrounds",
                        desc = L["Show buffs when in battleground instances"] or "Show buffs when in battleground instances",
                        get = function() return self.db.profile.general.enabledInBattlegrounds end,
                        set = function(_, value)
                            self.db.profile.general.enabledInBattlegrounds = value
                            self:CheckEnvironment()
                        end,
                        width = "full",
                    },
                    masqueHeader = {
                        order = 20,
                        type = "header",
                        name = L["Skinning Options"] or "Skinning Options",
                    },
                    useMasque = {
                        order = 21,
                        type = "toggle",
                        name = L["Use Masque"] or "Use Masque",
                        desc = L["Enable Masque skinning for buff icons"] or "Enable Masque skinning for buff icons",
                        disabled = function() return not IsAddOnLoaded("Masque") end,
                        get = function() return self.db.profile.general.useMasque end,
                        set = function(_, value)
                            self.db.profile.general.useMasque = value
                            -- Reinitialize Masque groups if enabled
                            if value then
                                self:InitializeMasqueGroups()
                            end
                            self:UpdateAllDisplays()
                        end,
                        width = "full",
                    },
                    masqueStatus = {
                        order = 22,
                        type = "description",
                        name = function()
                            if IsAddOnLoaded("Masque") then
                                return "|cFF00FF00Masque is installed and available.|r"
                            else
                                return "|cFFFF0000Masque is not installed. Install it for additional skinning options.|r"
                            end
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
    -- Create a container for our frames if it doesn't exist
    if not self.frames then
        self.frames = {}
    end
    
    -- Create MasqueGroups table if it doesn't exist
    if not self.MasqueGroups then
        self.MasqueGroups = {}
    end
    
    -- Create main container frame
    if not self.frames.container then
        self.frames.container = CreateFrame("Frame", "VUIBuffsContainer", UIParent)
        self.frames.container:SetSize(300, 200)
        self.frames.container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        self.frames.container:SetMovable(true)
        self.frames.container:EnableMouse(true)
        self.frames.container:RegisterForDrag("LeftButton")
        self.frames.container:SetScript("OnDragStart", function(frame) 
            if not self.db.profile.general.lockFrames then
                frame:StartMoving() 
            end
        end)
        self.frames.container:SetScript("OnDragStop", function(frame) 
            frame:StopMovingOrSizing() 
            -- Save position
            local _, _, _, xOfs, yOfs = frame:GetPoint(1)
            if not self.db.profile.position.container then
                self.db.profile.position.container = {}
            end
            self.db.profile.position.container.x = xOfs
            self.db.profile.position.container.y = yOfs
        end)
        
        -- Check if we have a saved position
        if self.db.profile.position.container then
            self.frames.container:ClearAllPoints()
            self.frames.container:SetPoint("CENTER", UIParent, "CENTER", 
                self.db.profile.position.container.x or 0, 
                self.db.profile.position.container.y or 0)
        end
        
        -- Create texture for moving
        local moveTexture = self.frames.container:CreateTexture("VUIBuffsContainerMoveTexture", "BACKGROUND")
        moveTexture:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        moveTexture:SetAllPoints()
        moveTexture:Hide()
        
        -- Show texture when unlocked
        self.frames.container.showMoveTexture = function(show)
            if show then
                moveTexture:Show()
            else
                moveTexture:Hide()
            end
        end
    end
    
    -- Create buff frame if it doesn't exist
    if not self.frames.buffFrame then
        self.frames.buffFrame = CreateFrame("Frame", "VUIBuffsBuffFrame", self.frames.container)
        self.frames.buffFrame:SetSize(300, 200)
        self.frames.buffFrame:SetPoint("TOPLEFT", self.frames.container, "TOPLEFT", 0, 0)
        
        -- Initialize buffs table
        self.frames.buffFrame.buffs = {}
        
        -- Add methods for updating
        self.frames.buffFrame.Update = function(frame)
            self:UpdateBuffDisplay(frame)
        end
    end
    
    -- Create debuff frame if it doesn't exist
    if not self.frames.debuffFrame then
        self.frames.debuffFrame = CreateFrame("Frame", "VUIBuffsDebuffFrame", self.frames.container)
        self.frames.debuffFrame:SetSize(300, 200)
        self.frames.debuffFrame:SetPoint("TOPLEFT", self.frames.buffFrame, "BOTTOMLEFT", 0, -5)
        
        -- Initialize debuffs table
        self.frames.debuffFrame.debuffs = {}
        
        -- Add methods for updating
        self.frames.debuffFrame.Update = function(frame)
            self:UpdateDebuffDisplay(frame)
        end
    end
    
    -- Check if we should show the move texture
    self.frames.container.showMoveTexture(not self.db.profile.general.lockFrames)
    
    -- Initialize Masque groups
    self:InitializeMasqueGroups()
    
    -- Create test buffs if in test mode
    if self.testMode then
        self:CreateTestBuffs()
    end
    
    -- Update displays
    self:UpdateAllDisplays()
end

-- Initialize Masque groups for buff skinning
function VUIBuffs:InitializeMasqueGroups()
    -- Check if Masque is loaded and if we should use it
    if not Masque or not self.db.profile.general.useMasque then return end
    
    -- Create main group if it doesn't exist (parent group)
    if not self.MasqueGroup then
        self.MasqueGroup = Masque:Group("VUI", "Buffs")
    end
    
    -- Define a structure of all groups we need
    local groups = {
        PlayerBuffs = "Player Buffs",
        PlayerDebuffs = "Player Debuffs",
        TargetBuffs = "Target Buffs",
        TargetDebuffs = "Target Debuffs",
        FocusBuffs = "Focus Buffs",
        FocusDebuffs = "Focus Debuffs",
        BossBuffs = "Boss Buffs",
        BossDebuffs = "Boss Debuffs",
        ArenaBuffs = "Arena Buffs",
        ArenaDebuffs = "Arena Debuffs",
        CustomBuffs = "Custom Buffs",
        CustomDebuffs = "Custom Debuffs"
    }
    
    -- Initialize MasqueGroups table if it doesn't exist
    if not self.MasqueGroups then
        self.MasqueGroups = {}
    end
    
    -- Create all needed groups
    for key, name in pairs(groups) do
        if not self.MasqueGroups[key] then
            self.MasqueGroups[key] = Masque:Group("VUI", name)
        end
    end
    
    self:Debug("Masque groups initialized")
end

-- Create a buff/debuff icon with Masque support
function VUIBuffs:CreateBuffIcon(parent, buffInfo, index, isDebuff, unitType)
    -- Get the appropriate frame based on buff type
    local frame = isDebuff and self.frames.debuffFrame or self.frames.buffFrame
    local collection = isDebuff and frame.debuffs or frame.buffs
    
    unitType = unitType or "Player" -- Default to Player if not specified
    
    -- Create the button if it doesn't exist
    if not collection[index] then
        -- Create a button that Masque can skin
        local button = CreateFrame("Button", "VUIBuffsIcon"..index..(isDebuff and "Debuff" or "Buff"), parent)
        button:SetSize(36, 36)
        
        -- Create icon texture
        local icon = button:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        button.icon = icon
        
        -- Create cooldown frame
        local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetDrawEdge(false)
        cooldown:SetHideCountdownNumbers(false)
        button.cooldown = cooldown
        
        -- Create count text
        local count = button:CreateFontString(nil, "ARTWORK")
        count:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        button.count = count
        
        -- Create duration text
        local duration = button:CreateFontString(nil, "ARTWORK")
        duration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        duration:SetPoint("TOP", button, "BOTTOM", 0, -1)
        button.duration = duration
        
        -- Create border for debuff type coloring if Masque isn't available
        if not Masque or not self.db.profile.general.useMasque then
            local border = button:CreateTexture(nil, "OVERLAY")
            border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
            border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
            border:SetAllPoints()
            button.border = border
        end
        
        -- Store in collection
        collection[index] = button
        
        -- Add button to the appropriate Masque group if Masque is available and enabled
        if Masque and self.db.profile.general.useMasque then
            local groupKey = unitType .. (isDebuff and "Debuffs" or "Buffs")
            local group = self.MasqueGroups[groupKey]
            
            if group then
                -- Add the button to Masque group with data Masque expects
                group:AddButton(button, {
                    Icon = icon,
                    Cooldown = cooldown,
                    Count = count,
                    Duration = duration,
                    Flash = nil,
                    Pushed = nil,
                    Normal = nil,
                    Disabled = nil,
                    Checked = nil,
                    Border = nil, -- Let Masque handle borders
                    AutoCastable = nil,
                    Highlight = nil,
                    Hotkey = nil,
                    Name = nil,
                    Gloss = nil,
                })
            end
        end
    end
    
    -- Reference to the button
    local button = collection[index]
    
    -- Update the button with buff info
    if buffInfo then
        -- Set up icon and info
        button.icon:SetTexture(buffInfo.icon)
        button.count:SetText(buffInfo.count > 1 and buffInfo.count or "")
        
        -- Set up cooldown
        if buffInfo.duration and buffInfo.duration > 0 then
            button.cooldown:SetCooldown(buffInfo.expirationTime - buffInfo.duration, buffInfo.duration)
            
            -- Format time for duration text
            local timeLeft = buffInfo.expirationTime - GetTime()
            if timeLeft > 0 then
                if timeLeft > 60 then
                    button.duration:SetText(math.floor(timeLeft / 60) .. "m")
                else
                    button.duration:SetText(math.floor(timeLeft))
                end
                button.duration:Show()
            else
                button.duration:Hide()
            end
        else
            button.cooldown:Hide()
            button.duration:Hide()
        end
        
        -- Set up color based on debuff type
        if isDebuff and buffInfo.debuffType then
            local color = DebuffTypeColor[buffInfo.debuffType] or DebuffTypeColor["none"]
            -- If Masque isn't being used, color the border ourselves
            if not Masque or not self.db.profile.general.useMasque then
                if button.border then
                    button.border:SetVertexColor(color.r, color.g, color.b)
                    button.border:Show()
                end
            elseif self.MasqueGroups then
                -- For Masque, we can set the "debuff" color via the gloss color
                -- This is a trick that some addons use since Masque doesn't have direct debuff type support
                local groupKey = unitType .. "Debuffs"
                local group = self.MasqueGroups[groupKey]
                if group and group.SetGlossColor then
                    group:SetGlossColor(button, color.r, color.g, color.b, 1)
                end
            end
        else
            -- For non-debuffs, hide the border if we created one
            if button.border then
                button.border:Hide()
            end
        end
        
        -- Show the button
        button:Show()
    else
        -- Hide the button if no info provided
        button:Hide()
    end
    
    return button
end

-- Update the buff display
function VUIBuffs:UpdateBuffDisplay(frame)
    -- Safety check
    if not frame then return end
    
    local buffs = {}
    
    -- If in test mode, create some test buffs
    if self.testMode then
        buffs = self:GetTestBuffs(false)
    else
        -- Get actual player buffs
        local i = 1
        while true do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
                  nameplateShowPersonal, spellId = UnitBuff("player", i)
            
            if not name then break end
            
            buffs[i] = {
                name = name,
                icon = icon,
                count = count,
                debuffType = debuffType,
                duration = duration,
                expirationTime = expirationTime,
                source = source,
                isStealable = isStealable,
                nameplateShowPersonal = nameplateShowPersonal,
                spellId = spellId
            }
            
            i = i + 1
        end
    end
    
    -- Update all buff icons
    for i, buffInfo in ipairs(buffs) do
        self:CreateBuffIcon(frame, buffInfo, i, false, "Player")
    end
    
    -- Hide unused buff icons
    for i = #buffs + 1, #frame.buffs do
        if frame.buffs[i] then
            frame.buffs[i]:Hide()
        end
    end
    
    -- Arrange buff icons
    self:ArrangeBuffIcons(frame, false)
end

-- Update the debuff display
function VUIBuffs:UpdateDebuffDisplay(frame)
    -- Safety check
    if not frame then return end
    
    local debuffs = {}
    
    -- If in test mode, create some test debuffs
    if self.testMode then
        debuffs = self:GetTestBuffs(true)
    else
        -- Get actual player debuffs
        local i = 1
        while true do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
                  nameplateShowPersonal, spellId = UnitDebuff("player", i)
            
            if not name then break end
            
            debuffs[i] = {
                name = name,
                icon = icon,
                count = count,
                debuffType = debuffType,
                duration = duration,
                expirationTime = expirationTime,
                source = source,
                isStealable = isStealable,
                nameplateShowPersonal = nameplateShowPersonal,
                spellId = spellId
            }
            
            i = i + 1
        end
    end
    
    -- Update all debuff icons
    for i, debuffInfo in ipairs(debuffs) do
        self:CreateBuffIcon(frame, debuffInfo, i, true, "Player")
    end
    
    -- Hide unused debuff icons
    for i = #debuffs + 1, #frame.debuffs do
        if frame.debuffs[i] then
            frame.debuffs[i]:Hide()
        end
    end
    
    -- Arrange debuff icons
    self:ArrangeBuffIcons(frame, true)
end

-- Arrange buff icons in a grid
function VUIBuffs:ArrangeBuffIcons(frame, isDebuff)
    local collection = isDebuff and frame.debuffs or frame.buffs
    local iconSize = 36 -- Default size
    local spacing = 4 -- Space between icons
    local iconsPerRow = 8 -- How many icons per row
    
    -- Arrange the icons in a grid
    for i, button in ipairs(collection) do
        if button:IsShown() then
            local row = math.floor((i-1) / iconsPerRow)
            local col = (i-1) % iconsPerRow
            
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", col * (iconSize + spacing), -row * (iconSize + spacing))
        end
    end
end

-- Get test buffs for preview mode
function VUIBuffs:GetTestBuffs(isDebuff)
    local buffs = {}
    local count = isDebuff and 6 or 12
    
    -- Test buff/debuff data
    local testSpells = {
        -- Buffs
        {name = "Power Word: Fortitude", icon = 135987, count = 1, duration = 3600, expirationTime = GetTime() + 3600},
        {name = "Arcane Intellect", icon = 135932, count = 1, duration = 3600, expirationTime = GetTime() + 3500},
        {name = "Battle Shout", icon = 132333, count = 1, duration = 3600, expirationTime = GetTime() + 1800},
        {name = "Well Fed", icon = 134062, count = 1, duration = 3600, expirationTime = GetTime() + 300},
        {name = "Flask", icon = 967556, count = 1, duration = 3600, expirationTime = GetTime() + 2700},
        {name = "Bloodlust", icon = 132313, count = 1, duration = 40, expirationTime = GetTime() + 25},
        {name = "Shield Wall", icon = 132362, count = 1, duration = 8, expirationTime = GetTime() + 5},
        {name = "Blessing of Freedom", icon = 135968, count = 1, duration = 8, expirationTime = GetTime() + 3},
        
        -- Debuffs
        {name = "Curse of Weakness", icon = 136138, count = 1, debuffType = "Curse", duration = 120, expirationTime = GetTime() + 85},
        {name = "Shadow Word: Pain", icon = 136207, count = 1, debuffType = "Magic", duration = 18, expirationTime = GetTime() + 12},
        {name = "Slow", icon = 136091, count = 1, debuffType = "Magic", duration = 15, expirationTime = GetTime() + 8},
        {name = "Curse of Tongues", icon = 136140, count = 2, debuffType = "Curse", duration = 30, expirationTime = GetTime() + 22},
        {name = "Poison", icon = 132108, count = 3, debuffType = "Poison", duration = 12, expirationTime = GetTime() + 6},
        {name = "Sunder Armor", icon = 132363, count = 5, debuffType = "Physical", duration = 30, expirationTime = GetTime() + 18}
    }
    
    -- Create buffs or debuffs based on parameter
    for i = 1, count do
        local spellIndex = isDebuff and (i + 8) or i
        if spellIndex <= #testSpells then
            buffs[i] = testSpells[spellIndex]
        end
    end
    
    return buffs
end

-- Create test buffs for display
function VUIBuffs:CreateTestBuffs()
    -- Safety check
    if not self.frames or not self.frames.buffFrame or not self.frames.debuffFrame then return end
    
    -- Update displays with test data
    self:UpdateBuffDisplay(self.frames.buffFrame)
    self:UpdateDebuffDisplay(self.frames.debuffFrame)
end

-- Handle profile changes
function VUIBuffs:ProfileChanged()
    self:UpdateAllDisplays()
end

-- Print a debug message
function VUIBuffs:Print(...)
    print("|cFF33FF99VUIBuffs|r:", ...);
end

-- Debug logging function
function VUIBuffs:Debug(message)
    if self.db and self.db.profile and self.db.profile.general and self.db.profile.general.debug then
        print("|cFF33FF99VUIBuffs Debug:|r", message)
    end
end

-- Refresh Masque groups and update all skins
function VUIBuffs:RefreshMasqueGroups()
    -- Only do this if Masque is loaded and we're using it
    if not Masque or not self.db.profile.general.useMasque then return end
    
    -- Reset existing groups
    if self.MasqueGroups then
        for _, group in pairs(self.MasqueGroups) do
            if group and group.Delete then
                group:Delete()
            end
        end
        self.MasqueGroups = {}
    end
    
    -- Initialize new groups
    self:InitializeMasqueGroups()
    
    -- Update all displays to apply new skins
    self:UpdateAllDisplays()
end

-- Update the OnEnable function to initialize Masque (around line 270 if it exists, or add it)
function VUIBuffs:OnEnable()
    -- Initialize Masque integration if available
    if IsAddOnLoaded("Masque") and not Masque then
        Masque = LibStub("Masque", true)
        if Masque then
            self:InitializeMasqueGroups()
        end
    end
    
    -- Update any frames we've created
    self:UpdateAllDisplays()
    
    self:Debug("VUIBuffs enabled")
end

-- Add a new function to check if buffs should be displayed based on current environment
function VUIBuffs:ShouldDisplayInCurrentEnvironment()
    -- Safety check
    if not self or not self.db or not self.db.profile or not self.db.profile.general then
        return true -- Default to showing if settings are missing
    end
    
    -- If addon is disabled entirely, don't show
    if not self.db.profile.general.enabled then
        return false
    end
    
    -- Check current environment
    local inInstance, instanceType = IsInInstance()
    
    -- Not in an instance = world
    if not inInstance then
        return self.db.profile.general.enabledInWorld
    end
    
    -- Check instance type against settings
    if instanceType == "party" then
        return self.db.profile.general.enabledInDungeons
    elseif instanceType == "raid" then
        return self.db.profile.general.enabledInRaids
    elseif instanceType == "arena" then
        return self.db.profile.general.enabledInArenas
    elseif instanceType == "pvp" then
        return self.db.profile.general.enabledInBattlegrounds
    end
    
    -- Default to show in other instance types
    return true
end

-- Add a function to register for events that would trigger environment changes
function VUIBuffs:RegisterEvents()
    -- Register for events that would require us to check environment settings
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckEnvironment")
    self:RegisterEvent("ZONE_CHANGED", "CheckEnvironment")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "CheckEnvironment")
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "CheckEnvironment")
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", "CheckEnvironment") -- Arena specific
    
    -- Combat events for potential filtering
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatChange") -- Entering combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatChange") -- Leaving combat
end

-- Handle environment checks and update display visibility
function VUIBuffs:CheckEnvironment()
    -- Safety check
    if not self then
        print("|cffff0000VUIBuffs Error:|r CheckEnvironment called with nil self")
        return
    end
    
    -- Determine if we should show based on current environment
    local shouldDisplay = self:ShouldDisplayInCurrentEnvironment()
    
    -- Update the visibility of frames
    self:UpdateFrameVisibility(shouldDisplay)
    
    -- Debug output
    local inInstance, instanceType = IsInInstance()
    self:Debug("Environment check: " .. (inInstance and instanceType or "world") .. 
               ", Should display: " .. (shouldDisplay and "yes" or "no"))
end

-- Handle combat state changes
function VUIBuffs:OnCombatChange()
    -- Could implement additional combat-based filtering here
    self:UpdateAllDisplays()
end

-- Update frame visibility based on environment settings
function VUIBuffs:UpdateFrameVisibility(shouldDisplay)
    -- Safety check
    if not self.frames then return end
    
    -- Always show in test mode regardless of environment
    if self.testMode then
        shouldDisplay = true
    end
    
    -- Update container visibility
    if self.frames.container then
        if shouldDisplay then
            self.frames.container:Show()
        else
            self.frames.container:Hide()
        end
    end
end

-- Add a placeholder function for CheckForSupportedAddons if it doesn't exist
-- This is called in OnInitialize but doesn't seem to be defined
function VUIBuffs:CheckForSupportedAddons()
    -- This would check for addons that might integrate with VUIBuffs
    local masqueLoaded = IsAddOnLoaded("Masque")
    if masqueLoaded then
        self:Debug("Masque detected, skinning features available")
    end
    
    -- Could check for other addons here
end

-- Add a placeholder function for InitVUIIntegration if it doesn't exist
-- This is called in OnInitialize but doesn't seem to be defined
function VUIBuffs:InitVUIIntegration()
    -- This would handle any special integration with the main VUI addon
    local VUI = _G["VUI"]
    if not VUI then return end
    
    -- Add VUI integration code here
    self:Debug("VUI integration initialized")
end