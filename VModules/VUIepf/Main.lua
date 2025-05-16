-- VUIepf Module (based on ElitePlayerFrame_Enhanced)
-- Enhances the player frame with various custom appearances and options

local AddonName = ...
local VUI = _G["VUI"]
local MODNAME = "VUIepf"

-- Create minimal fallback if global VUI doesn't exist
if not VUI then
    VUI = {}
    VUI.NewModule = function() return {} end
    _G["VUI"] = VUI
end

-- Try to create the module with error handling
local M

if VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")
else
    -- Create minimal module object to prevent errors
    M = {
        NAME = MODNAME,
        TITLE = "VUI Elite Player Frame",
        DESCRIPTION = "Changes the look of your player frame to various target and custom frames.",
        VERSION = "1.0",
        OnEnable = function() end,
        OnDisable = function() end
    }
    
    -- Register in VUI namespace
    VUI[MODNAME] = M
    
    -- Try initialization again after delay
    C_Timer.After(0.5, function()
        if VUI and VUI.NewModule then
            local RealModule = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")
            
            -- Transfer any properties from temporary module
            for k, v in pairs(M) do
                if k ~= "NAME" and k ~= "TITLE" and type(v) ~= "function" then
                    RealModule[k] = v
                end
            end
            
            -- Replace with real module
            VUI[MODNAME] = RealModule
            
            -- Initialize the module
            if RealModule.OnInitialize then RealModule:OnInitialize() end
            if RealModule.OnEnable then RealModule:OnEnable() end
        end
    end)
end

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

-- Add compatibility handling for The War Within expansion
-- Add this in the Module Constants section, around line 60-70
M.EXPANSION_INFO = {
    [1] = { name = "Classic", maxLevel = 60 },
    [2] = { name = "The Burning Crusade", maxLevel = 70 },
    [3] = { name = "Wrath of the Lich King", maxLevel = 80 },
    [4] = { name = "Cataclysm", maxLevel = 85 },
    [5] = { name = "Mists of Pandaria", maxLevel = 90 },
    [6] = { name = "Warlords of Draenor", maxLevel = 100 },
    [7] = { name = "Legion", maxLevel = 110 },
    [8] = { name = "Battle for Azeroth", maxLevel = 120 },
    [9] = { name = "Shadowlands", maxLevel = 60 },
    [10] = { name = "Dragonflight", maxLevel = 70 },
    [11] = { name = "The War Within", maxLevel = 80 },
    -- Future expansion placeholders
    [12] = { name = "Midnight", maxLevel = 80 }, -- Placeholder
    [13] = { name = "The Last Titan", maxLevel = 80 }, -- Placeholder
}

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
        useThemeColors = true, -- Use VUI theme colors by default
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

-- Initialize the module
function M:OnInitialize()
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIepf"] or VUI.db.namespaces["vuiepf"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIepf"] = namespace
            VUI.db.namespaces["vuiepf"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIepf", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuiepf"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Initialize frame data
    self:InitializeFrameData()
    
    -- Load custom frame modes
    self:LoadCustomFrameModes()
    
    -- Create our frame
    self.frame = CreateFrame("Frame", "VUIepf_Frame", PlayerFrame, "VUIepfTemplate")
    Mixin(self.frame, VUIepfMixin)
    
    -- Register with VUI's theme system
    self:RegisterWithThemeSystem()
    self.frame:Loaded()
    
    -- Register settings with VUI Config
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    end
    
    self:Debug("VUIepf module initialized")
end

function M:OnEnable()
    -- Register for PLAYER_ENTERING_WORLD event
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    
    -- Wait for PlayerFrame to be loaded then initialize
    C_Timer.After(0.5, function()
        if _G[self.PLAYER_FRAME] then
            self:InitializePlayerFrame()
        else
            -- Frame not found yet, try again
            self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
        end
    end)
    
    -- Register UI_SCALE_CHANGED event
    self:RegisterEvent("UI_SCALE_CHANGED", "OnUIScaleChanged")
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
    
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

-- Event handlers
function M:OnPlayerEnteringWorld()
    if _G[self.PLAYER_FRAME] then
        self:InitializePlayerFrame()
    end
end

function M:OnUIScaleChanged()
    -- Reapply frame mode when UI scale changes
    C_Timer.After(0.2, function()
        if M.db.profile.frameMode ~= 0 then
            M:ApplyFrameMode(M.db.profile.frameMode, M.db.profile.customFrameMode)
        end
    end)
end

function M:OnPlayerLogin()
    self:InitializePlayerFrame()
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
        VUI:Print("|cFF33CCFFVUI EPF Debug:|r", ...)
    end
end

function M:Notice(...)
    if self.db.profile.outputLevel >= 3 then
        VUI:Print("|cFF33AAFFVUIepf:|r", ...)
    end
end

function M:Warning(...)
    if self.db.profile.outputLevel >= 2 then
        VUI:Print("|cFFFFCC33VUI EPF Warning:|r", ...)
    end
end

function M:Error(...)
    if self.db.profile.outputLevel >= 1 then
        VUI:Print("|cFFFF3333VUI EPF Error:|r", ...)
    end
end

-- Load custom frame modes
function M:LoadCustomFrameModes()
    -- This will be populated from CustomFrameModes.lua
    -- For each class, we'll add custom frame appearance options
end

-- Initialize player frame
function M:InitializePlayerFrame()
    -- Safety check to avoid errors when the player frame isn't found
    local playerFrame = _G[self.PLAYER_FRAME]
    if not playerFrame then
        self:Error("Could not find player frame.")
        return
    end

    -- Ensure player frame container exists
    local playerFrameContainer = playerFrame and _G[self.PLAYER_CONTAINER_FRAME]
    if not playerFrameContainer then
        self:Error("Could not find player frame container.")
        return
    end
    
    -- Get the texture frame with better error handling
    local playerFrameTexture = playerFrameContainer and playerFrameContainer.FrameTexture
    if not playerFrameTexture then
        self:Error("Could not find player frame texture.")
        return
    end
    
    -- Apply the selected frame mode with safety checks
    self:ApplyFrameMode(self.db.profile.frameMode, self.db.profile.customFrameMode)
    
    -- Debug output to help troubleshoot issues
    self:Debug("Player frame initialized successfully")
end

-- Enhance the ApplyFrameMode function with better error handling
function M:ApplyFrameMode(frameMode, customFrameMode)
    -- Safety check for nil values
    frameMode = frameMode or 0
    
    -- Get player frame
    local playerFrame = _G[self.PLAYER_FRAME]
    if not playerFrame then
        self:Error("Player frame not found when applying frame mode")
        return false
    end
    
    -- Get player frame container
    local playerFrameContainer = _G[self.PLAYER_CONTAINER_FRAME]
    if not playerFrameContainer then
        self:Error("Player frame container not found when applying frame mode")
        return false
    end
    
    -- Get frame texture
    local frameTexture = playerFrameContainer.FrameTexture
    if not frameTexture then
        self:Error("Frame texture not found when applying frame mode")
        return false
    end
    
    -- Auto mode (0) - select frame based on player level, class, etc.
    if frameMode == 0 then
        frameMode = self:GetAutoFrameMode()
    end
    
    -- Handle normal frame modes (1-5)
    if frameMode >= 1 and frameMode <= 5 then
        local success = self:ApplyNormalFrameMode(frameMode)
        if success then
            self:Debug("Applied normal frame mode:", frameMode)
        else
            self:Warning("Failed to apply normal frame mode:", frameMode)
        end
        return success
    end
    
    -- Custom frame mode (6+)
    if frameMode >= 6 then
        -- Custom frame mode index
        local customIndex = frameMode - 5
        
        -- Override with specified custom mode if provided
        if customFrameMode and customFrameMode > 0 then
            customIndex = customFrameMode
        end
        
        -- Apply the custom frame mode
        local success = self:ApplyCustomFrameMode(customIndex)
        if success then
            self:Debug("Applied custom frame mode:", customIndex)
        else
            self:Warning("Failed to apply custom frame mode:", customIndex)
            
            -- Fallback to default if custom mode fails
            if frameMode ~= 0 then
                self:Notice("Falling back to auto frame mode")
                return self:ApplyFrameMode(0)
            end
        end
        return success
    end
    
    -- If we get here, invalid frame mode - reset to default
    self:Warning("Invalid frame mode:", frameMode, "- resetting to default")
    self.db.profile.frameMode = 0
    return self:ApplyFrameMode(0)
end

-- Enhance the ApplyCustomFrameMode function with better error handling
function M:ApplyCustomFrameMode(customFrameMode)
    -- Safety check
    if not customFrameMode or not self.CUSTOM_FRAME_MODES then
        self:Error("Custom frame mode not found:", customFrameMode)
        return false
    end
    
    -- Get the frame mode data
    local frameModeFunc = self.CUSTOM_FRAME_MODES[customFrameMode]
    if not frameModeFunc or type(frameModeFunc) ~= "function" then
        self:Error("Invalid custom frame mode:", customFrameMode)
        return false
    end
    
    -- Get frame data with pcall for safety
    local success, frameData = pcall(frameModeFunc, self)
    if not success or not frameData then
        self:Error("Error loading custom frame mode:", customFrameMode, frameData)
        return false
    end
    
    -- Apply the frame data with safety checks
    local frameName, frameColor, frameTextures, frameOffset, frameCondition = unpack(frameData)
    
    -- Check if the condition is met
    if frameCondition and type(frameCondition) == "function" then
        local conditionSuccess, conditionMet = pcall(frameCondition, self)
        if not conditionSuccess or not conditionMet then
            self:Debug("Custom frame mode condition not met:", frameName)
            return false
        end
    end
    
    -- Apply textures with better error handling
    if frameTextures then
        self:ApplyCustomTextures(frameTextures)
    end
    
    -- Apply offset
    if frameOffset then
        self:ApplyFrameOffset(frameOffset)
    end
    
    self:Debug("Applied custom frame mode:", frameName)
    return true
end

-- Add an enhanced ApplyCustomTextures function with better texture handling
function M:ApplyCustomTextures(textures)
    if not textures or type(textures) ~= "table" then
        self:Error("Invalid texture data")
        return
    end
    
    local playerFrame = _G[self.PLAYER_FRAME]
    if not playerFrame then
        self:Error("Player frame not found when applying custom textures")
        return
    end
    
    local playerFrameContainer = _G[self.PLAYER_CONTAINER_FRAME]
    if not playerFrameContainer then
        self:Error("Player frame container not found when applying custom textures")
        return
    end
    
    -- Get the frame texture
    local frameTexture = playerFrameContainer.FrameTexture
    if not frameTexture then
        self:Error("Frame texture not found when applying custom textures")
        return
    end
    
    -- Clear existing custom textures
    for i = 1, 10 do -- Assume max 10 custom textures
        local existingTexture = frameTexture["CustomTexture"..i]
        if existingTexture then
            existingTexture:Hide()
        end
    end
    
    -- Apply each texture layer
    for i, textureData in ipairs(textures) do
        local texture = textureData
        if type(texture) == "function" then
            -- If it's a function, execute it to get the texture info
            local success, result = pcall(texture, frameTexture, nil)
            if success then
                texture = result
            else
                self:Error("Error applying texture function:", result)
                texture = nil
            end
        end
        
        if texture and texture.texture then
            -- Get texture path with resolution support
            local textureFile = self:LoadTextureAtlas(texture.texture)
            
            if textureFile then
                -- Create or get texture frame
                local textureFrame = frameTexture["CustomTexture"..i]
                if not textureFrame then
                    textureFrame = frameTexture:CreateTexture("CustomTexture"..i, "ARTWORK")
                    frameTexture["CustomTexture"..i] = textureFrame
                end
                
                -- Apply texture
                textureFrame:SetTexture(textureFile)
                
                -- Set coordinates if provided
                if texture.texture.leftTexCoord and texture.texture.rightTexCoord and 
                   texture.texture.topTexCoord and texture.texture.bottomTexCoord then
                    textureFrame:SetTexCoord(
                        texture.texture.leftTexCoord,
                        texture.texture.rightTexCoord,
                        texture.texture.topTexCoord,
                        texture.texture.bottomTexCoord
                    )
                end
                
                -- Set size if provided
                if texture.texture.width and texture.texture.height then
                    textureFrame:SetSize(texture.texture.width, texture.texture.height)
                end
                
                -- Position the texture
                if texture.point and (texture.point.x or texture.point.frame) then
                    textureFrame:ClearAllPoints()
                    
                    if texture.point.frame then
                        -- Complex positioning with a specific anchor frame
                        local anchorFrame = _G[texture.point.frame] or frameTexture
                        local anchorPoint = texture.point.anchor or "CENTER"
                        textureFrame:SetPoint("CENTER", anchorFrame, anchorPoint, 
                            texture.point.x or 0, texture.point.y or 0)
                    else
                        -- Simple center offset
                        textureFrame:SetPoint("CENTER", frameTexture, "CENTER", 
                            texture.point.x or 0, texture.point.y or 0)
                    end
                end
                
                -- Show the texture
                textureFrame:Show()
            end
        end
    end
    
    self:Debug("Applied custom textures")
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
                        self:ApplyCustomFrameMode(value)
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
    
    -- Add theme integration option
    options.args.themeIntegration = {
        name = L["Use Theme Colors"],
        desc = L["Apply VUI theme colors to frame elements"],
        type = "toggle",
        width = "full",
        order = 6,
        get = function() return self.db.profile.useThemeColors end,
        set = function(info, value)
            self.db.profile.useThemeColors = value
            self:ApplyTheme()
        end,
    }
    
    return options
end

-- Register with VUI's theme system
function M:RegisterWithThemeSystem()
    if VUI.RegisterThemeCallback then
        VUI:RegisterThemeCallback(function()
            M:ApplyTheme()
        end)
    end
end

-- Apply current theme to module elements
function M:ApplyTheme()
    -- Skip if theme integration is disabled
    local useTheme = self.db.profile.useThemeColors
    if not useTheme then return end
    
    -- Get the current theme color
    local themeColor
    if VUI.GetThemeColor then
        themeColor = VUI:GetThemeColor()
    else
        themeColor = { r = 0, g = 0.77, b = 1 } -- Default VUI blue if theme system not available
    end
    
    -- Apply theme to frame elements
    if self.playerFrame then
        if self.playerFrame.DragonBorder and self.db.profile.frameMode ~= 0 then
            -- Apply theme color to the dragon border with slight adjustments to preserve details
            self.playerFrame.DragonBorder:SetVertexColor(
                0.85 + (themeColor.r * 0.15),
                0.85 + (themeColor.g * 0.15),
                0.85 + (themeColor.b * 0.15)
            )
        end
        
        -- Apply to any glow effects if they exist
        if self.playerFrame.Glow then
            self.playerFrame.Glow:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
        end
    end
    
    -- Reapply frame mode to ensure theme is properly applied
    self:ApplyFrameMode(self.db.profile.frameMode, self.db.profile.customFrameMode)
end

-- Register the module
if VUI.RegisterModule then
    VUI:RegisterModule(MODNAME, M)
end

-- Update GetExpansionInfo function to handle the latest expansions
function M:GetExpansionInfo()
    local currentExpansion = GetExpansionLevel()
    local accountExpansion = GetAccountExpansionLevel()
    
    -- Safety check for out of bounds
    if not self.EXPANSION_INFO[currentExpansion] then
        -- Unknown expansion, provide default values
        return {
            current = { id = currentExpansion, name = "Unknown", maxLevel = 80 },
            account = { id = accountExpansion, name = "Unknown", maxLevel = 80 },
            previous = { id = currentExpansion - 1, name = "Unknown", maxLevel = 70 }
        }
    end
    
    -- Get current expansion info
    local current = {
        id = currentExpansion,
        name = self.EXPANSION_INFO[currentExpansion].name,
        maxLevel = self.EXPANSION_INFO[currentExpansion].maxLevel
    }
    
    -- Get previous expansion info
    local previousId = math.max(1, currentExpansion - 1)
    local previous = {
        id = previousId,
        name = self.EXPANSION_INFO[previousId].name,
        maxLevel = self.EXPANSION_INFO[previousId].maxLevel
    }
    
    -- Get account expansion info
    local account = {
        id = accountExpansion,
        name = self.EXPANSION_INFO[accountExpansion] and self.EXPANSION_INFO[accountExpansion].name or "Unknown",
        maxLevel = self.EXPANSION_INFO[accountExpansion] and self.EXPANSION_INFO[accountExpansion].maxLevel or 80
    }
    
    return { current = current, previous = previous, account = account }
end

-- Add a new texture loading function to handle high-resolution textures properly
function M:LoadTextureAtlas(textureInfo)
    if not textureInfo then
        self:Error("Invalid texture information")
        return nil
    end
    
    -- Handle resolution-specific textures (1x, 2x)
    local baseResolution = self.BASE_RESOLUTION or 768
    local screenHeight = GetScreenHeight()
    local resolutionFactor = math.ceil(screenHeight / baseResolution)
    
    -- Check if we have a high-resolution version available
    if resolutionFactor > 1 and textureInfo["file-2x"] then
        return textureInfo["file-2x"]
    end
    
    return textureInfo["file"]
end

-- Add the GetAutoFrameMode function to determine frame mode based on player properties
function M:GetAutoFrameMode()
    -- Get player information
    local playerLevel = UnitLevel("player")
    local playerClass = select(2, UnitClass("player"))
    
    -- Get expansion info
    local expansionInfo = self:GetExpansionInfo()
    
    -- Default to normal frame (no change)
    local frameMode = 0
    
    -- Check if player is a Death Knight
    if playerClass == "DEATHKNIGHT" and self.db.profile.classSelection then
        -- Custom Death Knight frame (mode 6)
        return 6
    end
    
    -- Check if player is a Demon Hunter
    if playerClass == "DEMONHUNTER" and self.db.profile.classSelection then
        -- Custom Demon Hunter frame (mode 7)
        return 7
    end
    
    -- Check level ranges
    -- Max level in current expansion
    if playerLevel >= expansionInfo.current.maxLevel then
        -- Elite (Gold - Winged frame)
        frameMode = 3
    -- Level range between previous max and current max-1
    elseif playerLevel >= expansionInfo.previous.maxLevel and playerLevel < expansionInfo.current.maxLevel then
        -- Rare Elite (Silver - Winged frame)
        frameMode = 2
    -- Level 10 and above, but below previous expansion max
    elseif playerLevel >= 10 and playerLevel < expansionInfo.previous.maxLevel then
        -- Rare (Silver frame)
        frameMode = 1
    end
    
    self:Debug("Auto frame mode determined:", frameMode, "based on level", playerLevel)
    return frameMode
end

-- Add the ApplyNormalFrameMode function to handle standard frame modes
function M:ApplyNormalFrameMode(frameMode)
    -- Safety check
    if not frameMode or frameMode < 1 or frameMode > 5 then
        self:Error("Invalid normal frame mode:", frameMode)
        return false
    end
    
    -- Get player frame with safety check
    local playerFrame = _G[self.PLAYER_FRAME]
    if not playerFrame then
        self:Error("Player frame not found when applying normal frame mode")
        return false
    end
    
    -- Get content main with safety check
    local contentMain = playerFrame.PlayerFrameContent and playerFrame.PlayerFrameContent.PlayerFrameContentMain
    if not contentMain then
        self:Error("Player frame content main not found")
        return false
    end
    
    -- Get status texture with safety check
    local statusTexture = contentMain.StatusTexture
    if not statusTexture then
        self:Error("Status texture not found")
        return false
    end
    
    -- Apply the correct texture based on mode
    if frameMode == 1 then
        -- Silver frame (Rare)
        statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Boss-Silver")
        self:Debug("Applied Silver frame")
    elseif frameMode == 2 then
        -- Silver Winged frame (Rare Elite)
        statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Boss-Silver-Wing")
        self:Debug("Applied Silver Winged frame")
    elseif frameMode == 3 then
        -- Gold Winged frame (Elite)
        statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Boss-Gold-Wing")
        self:Debug("Applied Gold Winged frame")
    elseif frameMode == 4 then
        -- Gold frame (not used in auto mode)
        statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Boss-Gold")
        self:Debug("Applied Gold frame")
    elseif frameMode == 5 then
        -- Normal frame (default)
        statusTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn")
        self:Debug("Applied Normal frame")
    end
    
    -- Apply theme colors if enabled
    if self.db.profile.useThemeColors and frameMode > 0 then
        -- Apply theme with a small delay to ensure all elements are ready
        C_Timer.After(0.1, function()
            if self.ApplyTheme then
                self:ApplyTheme()
            end
        end)
    end
    
    return true
end

-- Add the ApplyFrameOffset function to handle custom frame positioning
function M:ApplyFrameOffset(offsetData)
    if not offsetData then return end
    
    -- Get offset values with safety
    local xOffset = offsetData.x or 0
    local yOffset = offsetData.y or 0
    
    -- Get player frame
    local playerFrame = _G[self.PLAYER_FRAME]
    if not playerFrame then return end
    
    -- Get rest icon
    local restIcon = _G[self.PLAYER_REST_ICON_FRAME]
    if restIcon then
        -- Adjust rest icon position
        restIcon:ClearAllPoints()
        restIcon:SetPoint("CENTER", playerFrame, "TOPLEFT", xOffset, yOffset)
        self:Debug("Applied rest icon offset:", xOffset, yOffset)
    end
end