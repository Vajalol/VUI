-- VUIepf Module (based on ElitePlayerFrame_Enhanced)
-- Enhances the player frame with various custom appearances and options

local AddonName, VUI = ...
local MODNAME = "VUIepf"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.SHORT_NAME = "EPF"
M.TITLE = "VUI Elite Player Frame"
M.DESCRIPTION = "Changes the look of your player frame to various target and custom frames."
M.VERSION = "1.0"
M.BASE_RESOLUTION = 768  -- Hardcoded base resolution height value for textures
M.CUSTOM_FRAME_MODES = {}

-- Colors
M.COLOR = CreateColor(0.8, 0.667, 0.2)  -- CCAA33
local DISABLED_FONT_COLOR = CreateColor(1, 0.2, 0.2)      -- FF3333
local ENABLED_FONT_COLOR = CreateColor(0.2, 1, 0.2)       -- 33FF33

-- Observed frames
M.PLAYER_FRAME = "PlayerFrame"
M.PLAYER_CONTAINER_FRAME = M.PLAYER_FRAME.."Container"
M.PLAYER_TEXTURE_FRAME = "FrameTexture"
M.PLAYER_CONTENT_FRAME = M.PLAYER_FRAME.."Content"
M.PLAYER_CONTEXTUAL_CONTENT_FRAME = M.PLAYER_CONTENT_FRAME.."Contextual"
M.PLAYER_REST_ICON_FRAME = "PlayerRestLoop"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        frameMode = 0,  -- Default/no change
        customFrameMode = 1,
        classSelection = true,
        showFrameLevel = false,
        observeFrameLevel = false,
        showAddonCompartment = true,
        outputLevel = 3,  -- NOTICE level
        -- Other settings will be added here
    }
}

-- Texture utilities
function M:GetMediaPath(file)
    return "Interface\\AddOns\\VUI\\Media\\modules\\VUIepf\\" .. file
end

function M:SetTexture(t, p)
    return function(f, g)
        local r = {}
        r.texture = t
        r.point = p
        r.frame = f
        r.group = g
        return r
    end
end

function M:SetLayeredTextures(...)
    local r = {}
    for i, v in ipairs({...}) do
        r[i] = v
    end
    return r
end

function M:SetPointOffset(x, y)
    return function(f, a)
        local r = {}
        r.x = x
        r.y = y
        r.frame = f
        r.anchor = a
        return r
    end
end

-- Initialize frame data and class colors
function M:InitializeFrameData()
    -- Set up class data
    self.CLASSES = {}
    for i, className in ipairs(CLASS_SORT_ORDER) do
        local classInfo = C_CreatureInfo.GetClassInfo(i)
        if classInfo then
            local classColor = RAID_CLASS_COLORS[className]
            self.CLASSES[className] = {
                color = CreateColor(classColor.r, classColor.g, classColor.b),
                name = { classInfo.className, classInfo.classFile }
            }
        end
    end
end

-- Setup the player frame mixin
local VUIepfMixin = {}

function VUIepfMixin:Loaded()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ADDON_LOADED")
end

function VUIepfMixin:Event_Received(event, ...)
    if event == "PLAYER_LOGIN" then
        M:InitializePlayerFrame()
    elseif event == "ADDON_LOADED" then
        local addon = ...
        if addon == AddonName then
            M:InitializeSettings()
        end
    end
end

function M:OnInitialize()
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(MODNAME, self.defaults)
    
    -- Initialize frame data
    self:InitializeFrameData()
    
    -- Load custom frame modes
    self:LoadCustomFrameModes()
    
    -- Create our frame
    self.frame = CreateFrame("Frame", "VUIepf_Frame", PlayerFrame, "VUIepfTemplate")
    Mixin(self.frame, VUIepfMixin)
    self.frame:Loaded()
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    
    self:Debug("VUIepf module initialized")
end

function M:OnEnable()
    -- Check if UnitFrames module is enabled
    self.unitFramesEnabled = VUI:GetModule("UnitFrames.Player", true) and VUI:GetModule("UnitFrames.Player"):IsEnabled()
    
    -- Apply current frame mode
    self:ApplyFrameMode(self.db.profile.frameMode, self.db.profile.customFrameMode)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- Delay frame application slightly to ensure proper order with other modules
        C_Timer.After(0.2, function() 
            if M.db.profile.frameMode ~= 0 then
                M:ApplyFrameMode(M.db.profile.frameMode, M.db.profile.customFrameMode)
            end
        end)
    end)
    self:RegisterEvent("UI_SCALE_CHANGED")
    self:RegisterEvent("PLAYER_LOGIN")
    
    -- Hook into the UnitFrames resting state handler to maintain our frame style
    if self.unitFramesEnabled then
        hooksecurefunc("PlayerFrame_UpdateStatus", function(self)
            if (IsResting()) then
                -- Re-apply our frame mode if it's not default
                if M.db.profile.frameMode ~= 0 then
                    C_Timer.After(0.1, function() 
                        M:ApplyFrameMode(M.db.profile.frameMode, M.db.profile.customFrameMode)
                    end)
                end
            end
        end)
    end
    
    self:Debug("VUIepf module enabled")
end

function M:OnDisable()
    -- Restore default player frame
    self:RestoreDefaultFrame()
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    self:Debug("VUIepf module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    if self.db.profile.outputLevel >= 4 then
        VUI:Print("|cFF33AAFFVUIepf:|r", ...)
    end
end

function M:Notice(...)
    if self.db.profile.outputLevel >= 3 then
        VUI:Print("|cFF33AAFFVUIepf:|r", ...)
    end
end

function M:Warning(...)
    if self.db.profile.outputLevel >= 2 then
        VUI:Print("|cFFFFAA33VUIepf Warning:|r", ...)
    end
end

function M:Error(...)
    if self.db.profile.outputLevel >= 1 then
        VUI:Print("|cFFFF3333VUIepf Error:|r", ...)
    end
end

-- Load custom frame modes
function M:LoadCustomFrameModes()
    -- This will be populated from CustomFrameModes.lua
    -- For each class, we'll add custom frame appearance options
end

-- Initialize player frame
function M:InitializePlayerFrame()
    -- Get player frame elements
    self.playerFrame = _G[self.PLAYER_FRAME]
    if not self.playerFrame then
        self:Error("Could not find player frame.")
        return
    end
    
    -- Apply current frame mode
    self:ApplyFrameMode(self.db.profile.frameMode, self.db.profile.customFrameMode)
    
    self:Notice("Player frame initialized.")
end

-- Apply frame mode
function M:ApplyFrameMode(frameMode, customFrameMode)
    if not self.playerFrame then return end
    
    -- Restore default first
    self:RestoreDefaultFrame()
    
    if frameMode == 0 then
        -- Default frame, no change
        return
    elseif frameMode == 1 then
        -- Elite frame (dragon)
        self:ApplyEliteFrame()
    elseif frameMode == 2 then
        -- Rare frame (silver)
        self:ApplyRareFrame()
    elseif frameMode == 3 then
        -- Rare Elite frame (silver dragon)
        self:ApplyRareEliteFrame()
    elseif frameMode == 4 then
        -- Custom frame
        self:ApplyCustomFrame(customFrameMode)
    end
end

-- Apply elite frame (dragon)
function M:ApplyEliteFrame()
    if not self.playerFrame then return end
    
    -- Set player frame to elite (dragon)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
    
    self:Debug("Applied Elite frame.")
end

-- Apply rare frame (silver)
function M:ApplyRareFrame()
    if not self.playerFrame then return end
    
    -- Set player frame to rare (silver)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
    
    self:Debug("Applied Rare frame.")
end

-- Apply rare elite frame (silver dragon)
function M:ApplyRareEliteFrame()
    if not self.playerFrame then return end
    
    -- Set player frame to rare elite (silver dragon)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-RareElite")
    
    self:Debug("Applied Rare Elite frame.")
end

-- Apply custom frame
function M:ApplyCustomFrame(customFrameMode)
    if not self.playerFrame then return end
    
    -- Get the custom frame mode data
    local frameData = self.CUSTOM_FRAME_MODES[customFrameMode]
    if not frameData then
        self:Error("Custom frame mode not found:", customFrameMode)
        return
    end
    
    -- Apply the custom textures
    -- This is a simplified version - will be expanded with actual implementation
    local texturePath = self:GetMediaPath("textures/CustomTextures.blp")
    local textureHiResPath = self:GetMediaPath("textures/CustomTextures-2x.blp")
    
    -- Apply custom frame texture
    -- Detailed implementation will depend on the specific custom frame mode
    
    self:Debug("Applied Custom frame mode:", customFrameMode)
end

-- Restore default frame
function M:RestoreDefaultFrame()
    if not self.playerFrame then return end
    
    -- Reset player frame to default
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
    
    self:Debug("Restored default player frame.")
end

-- Get options for configuration panel
function M:GetOptions()
    local options = {
        name = self.TITLE,
        type = "group",
        args = {
            enabled = {
                name = L["Enable"],
                desc = L["Enable/disable this module"],
                type = "toggle",
                order = 1,
                get = function() return self.db.profile.enabled end,
                set = function(info, value) 
                    self.db.profile.enabled = value
                    if value then self:OnEnable() else self:OnDisable() end
                end,
            },
            frameMode = {
                name = L["Frame Mode"],
                desc = L["Select the player frame appearance"],
                type = "select",
                order = 2,
                values = {
                    [0] = L["Default"],
                    [1] = L["Elite (Dragon)"],
                    [2] = L["Rare (Silver)"],
                    [3] = L["Rare Elite (Silver Dragon)"],
                    [4] = L["Custom"],
                },
                get = function() return self.db.profile.frameMode end,
                set = function(info, value)
                    self.db.profile.frameMode = value
                    self:ApplyFrameMode(value, self.db.profile.customFrameMode)
                end,
            },
            customFrameMode = {
                name = L["Custom Frame Style"],
                desc = L["Select the custom frame style to use"],
                type = "select",
                order = 3,
                values = function()
                    local values = {}
                    for i, mode in ipairs(self.CUSTOM_FRAME_MODES) do
                        values[i] = mode[1] -- Display name of the custom frame
                    end
                    return values
                end,
                disabled = function() return self.db.profile.frameMode ~= 4 end,
                get = function() return self.db.profile.customFrameMode end,
                set = function(info, value)
                    self.db.profile.customFrameMode = value
                    if self.db.profile.frameMode == 4 then
                        self:ApplyCustomFrame(value)
                    end
                end,
            },
            classSelection = {
                name = L["Use Class-Specific Frames"],
                desc = L["Automatically select frame based on character class"],
                type = "toggle",
                order = 4,
                get = function() return self.db.profile.classSelection end,
                set = function(info, value)
                    self.db.profile.classSelection = value
                    self:ApplyFrameMode(self.db.profile.frameMode, self.db.profile.customFrameMode)
                end,
            },
            outputLevel = {
                name = L["Message Output Level"],
                desc = L["Set the verbosity level for addon messages"],
                type = "select",
                order = 5,
                values = {
                    [0] = L["Critical Errors Only"],
                    [1] = L["Errors"],
                    [2] = L["Warnings"],
                    [3] = L["Notices"],
                    [4] = L["Debug"],
                },
                get = function() return self.db.profile.outputLevel end,
                set = function(info, value) 
                    self.db.profile.outputLevel = value 
                end,
            },
        },
    }
    
    return options
end

-- Register the module
VUI:RegisterModule(MODNAME, M)