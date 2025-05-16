-------------------------------------------------------------------------------
-- VUIScrollingText Module
-- Displays animated text messages for combat events and notifications
-- Based on MikScrollingBattleText with VUI integration
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUIScrollingText"

-- Use global reference pattern instead of direct access
VUI = _G["VUI"]

-- Exit early if VUI is not available
if not VUI then return end

-- Module definition with proper initialization handling
local M

-- Attempt to create module the standard way
if VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
else
    -- Create minimal module object to prevent errors
    M = {
        NAME = MODNAME,
        TITLE = "VUI Scrolling Text",
        DESCRIPTION = "Dynamic combat text animations with VUI theme integration",
        VERSION = "1.0",
        OnEnable = function() end,
        OnDisable = function() end
    }
    
    -- Register in VUI namespace
    VUI[MODNAME] = M
    
    -- Try one more time after a short delay
    C_Timer.After(0.5, function()
        if VUI and VUI.NewModule then
            -- Create and register the module properly
            local RealModule = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
            
            -- Copy any changes made to the temporary module
            for k, v in pairs(M) do
                if k ~= "NAME" and k ~= "TITLE" and type(v) ~= "function" then
                    RealModule[k] = v
                end
            end
            
            -- Replace the minimal module with the real one
            VUI[MODNAME] = RealModule
            
            -- Initialize the module
            if RealModule.OnInitialize then RealModule:OnInitialize() end
            if RealModule.OnEnable then RealModule:OnEnable() end
        end
    end)
end

-- Ensure NAME property is set
M.NAME = M.NAME or MODNAME

-- Create table for ScrollingText component in the VUI namespace for legacy compatibility
VUI.ScrollingText = VUI.ScrollingText or {}
local ST = VUI.ScrollingText

-- Initialize key properties with safeguards
ST.scrollAreas = ST.scrollAreas or {}
ST.isInitialized = ST.isInitialized or false

-- Additional nil check in case the above assignment didn't work
if ST.scrollAreas == nil then
    ST.scrollAreas = {}
end

-- Animation directions
ST.SCROLL_UP = 1
ST.SCROLL_DOWN = 2
ST.SCROLL_LEFT = 3
ST.SCROLL_RIGHT = 4

-- Text alignment
ST.ALIGN_LEFT = "LEFT"
ST.ALIGN_RIGHT = "RIGHT"
ST.ALIGN_CENTER = "CENTER"

-- Animation behaviors
ST.BEHAVIOR_SCROLL = 1
ST.BEHAVIOR_PARABOLA = 2
ST.BEHAVIOR_STRAIGHT = 3
ST.BEHAVIOR_STATIC = 4

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        
        -- Animation settings
        style = "dynamic", -- "static", "dynamic", "fountain", "threshold", "vuithemed"
        animationSpeed = 1.0,
        useThemeColors = true,
        
        -- Font settings
        masterFont = "Friz Quadrata TT",
        normalFontSize = 18,
        normalOutlineIndex = 2, -- 1=None, 2=Thin, 3=Thick
        critFontSize = 26,
        critOutlineIndex = 2,
        
        -- Sound settings
        soundsEnabled = true,
        
        -- Areas to display
        areas = {
            incoming = {
                enabled = true,
                position = {"CENTER", nil, "CENTER", 0, 100},
                size = {300, 260},
                scrollDirection = ST.SCROLL_UP,
                behavior = ST.BEHAVIOR_SCROLL,
                textAlign = ST.ALIGN_CENTER
            },
            outgoing = {
                enabled = true,
                position = {"CENTER", nil, "CENTER", 0, -100},
                size = {300, 260},
                scrollDirection = ST.SCROLL_DOWN,
                behavior = ST.BEHAVIOR_SCROLL,
                textAlign = ST.ALIGN_CENTER
            },
            notifications = {
                enabled = true,
                position = {"TOP", nil, "TOP", 0, -120},
                size = {400, 100},
                scrollDirection = ST.SCROLL_RIGHT,
                behavior = ST.BEHAVIOR_STATIC,
                textAlign = ST.ALIGN_CENTER
            }
        },
        
        -- Events to trigger scrolling text
        events = {
            combatDamage = true,
            combatMisses = true,
            combatHealing = true,
            resourceGains = true,
            deaths = true,
            honorGains = true,
            buffGains = true,
            buffFades = true,
            combatState = true,
            lootItems = true,
            skillGains = true,
            experience = true
        },
        
        -- Color settings
        colors = {
            normal = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            crit = {r = 1.0, g = 0.0, b = 0.0, a = 1.0},
            mana = {r = 0.0, g = 0.0, b = 1.0, a = 1.0},
            rage = {r = 1.0, g = 0.0, b = 0.0, a = 1.0},
            energy = {r = 1.0, g = 1.0, b = 0.0, a = 1.0},
            runic = {r = 0.0, g = 0.8, b = 1.0, a = 1.0},
            holy = {r = 1.0, g = 0.9, b = 0.5, a = 1.0},
            fire = {r = 1.0, g = 0.5, b = 0.0, a = 1.0},
            nature = {r = 0.3, g = 1.0, b = 0.3, a = 1.0},
            frost = {r = 0.5, g = 0.5, b = 1.0, a = 1.0},
            shadow = {r = 0.5, g = 0.0, b = 1.0, a = 1.0},
            arcane = {r = 1.0, g = 0.5, b = 1.0, a = 1.0},
            physical = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            heal = {r = 0.0, g = 1.0, b = 0.0, a = 1.0},
            buff = {r = 0.0, g = 0.0, b = 1.0, a = 1.0},
            debuff = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
        }
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIScrollingText"] or VUI.db.namespaces["vuiscrollingtext"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIScrollingText"] = namespace
            VUI.db.namespaces["vuiscrollingtext"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIScrollingText", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuiscrollingtext"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if self.UpdateTheme then
                self:UpdateTheme()
            end
        end)
    end
    
    -- Set up the master frame
    self:SetupMasterFrame()
    
    -- Register slash command
    if self.RegisterChatCommand and type(self.RegisterChatCommand) == "function" then
        self:RegisterChatCommand("vuist", "SlashCommand")
        
        -- Legacy support
        self:RegisterChatCommand("msbt", "SlashCommand")
    else
        -- Fallback: Register with SlashCmdList
        _G.SLASH_VUIST1 = "/vuist"
        _G.SLASH_VUIST2 = "/msbt"
        SlashCmdList["VUIST"] = function(input)
            self:SlashCommand(input)
        end
    end
    
    -- Expose module to ST for legacy compatibility
    ST.module = self
    
    -- Initialize ST namespace with this module instance
    if ST.OnInitialize then
        ST.OnInitialize(self)
    end
    
    -- Flag as initialized
    ST.isInitialized = true
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events with proper handlers
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEvent")
    self:RegisterEvent("UNIT_HEALTH", "OnUnitHealth")
    self:RegisterEvent("UNIT_POWER_UPDATE", "OnUnitPowerUpdate")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnUnitSpellcastSucceeded")
    
    -- Create scroll areas
    self:CreateScrollAreas()
    
    -- Load additional components if not loaded yet
    if not ST.Main and VUI.LoadUIComponent then
        VUI:LoadUIComponent("VUIScrollingText/Main")
    end
    
    if not ST.AnimationStyles and VUI.LoadUIComponent then
        VUI:LoadUIComponent("VUIScrollingText/animations/Styles")
    end
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Hide all frames
    self:HideAllFrames()
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Set up the master frame
function M:SetupMasterFrame()
    -- Create master frame if it doesn't exist
    if not ST.masterFrame then
        ST.masterFrame = CreateFrame("Frame", "VUIScrollingTextMasterFrame", UIParent)
        ST.masterFrame:SetSize(1, 1)
        ST.masterFrame:SetPoint("CENTER")
        ST.masterFrame:Hide()
    end
end

-- Create scroll areas
function M:CreateScrollAreas()
    -- Ensure scrollAreas exists
    if not ST.scrollAreas then
        ST.scrollAreas = {}
    end
    
    -- Create scroll areas based on configuration
    if self.db and self.db.profile and self.db.profile.areas then
        for areaName, areaConfig in pairs(self.db.profile.areas) do
            if areaConfig and areaConfig.enabled then
                self:CreateScrollArea(areaName, areaConfig)
            end
        end
    end
end

-- Create a scroll area
function M:CreateScrollArea(name, config)
    -- Safety checks
    if not name or not config then return end
    if not ST.scrollAreas then ST.scrollAreas = {} end
    if not ST.masterFrame then self:SetupMasterFrame() end
    
    -- Create a new scroll area if it doesn't exist
    if not ST.scrollAreas[name] then
        -- Create with error handling
        local success, result = pcall(function()
            local scrollArea = {
                name = name,
                frame = CreateFrame("Frame", "VUIScrollingText_" .. name, ST.masterFrame),
                config = config,
                animationStyleSettings = {
                    scrollDirection = config.scrollDirection or ST.SCROLL_UP,
                    scrollHeight = config.size and config.size[2] or 200,
                    scrollWidth = config.size and config.size[1] or 300,
                    behavior = config.behavior or ST.BEHAVIOR_SCROLL,
                    textAlign = config.textAlign or ST.ALIGN_CENTER,
                    useThemeColor = self.db and self.db.profile and self.db.profile.useThemeColors or false
                },
                frames = {}
            }
            
            local frame = scrollArea.frame
            if frame then
                frame:SetSize(
                    config.size and config.size[1] or 300, 
                    config.size and config.size[2] or 200
                )
                
                if config.position then
                    frame:SetPoint(unpack(config.position))
                else
                    frame:SetPoint("CENTER")
                end
                
                frame:Show()
            end
            
            return scrollArea
        end)
        
        if success and result then
            ST.scrollAreas[name] = result
        end
    end
end

-- Hide all frames
function M:HideAllFrames()
    -- Safety check
    if not ST then return end
    
    -- Hide all scroll area frames
    if ST.scrollAreas then
        for _, scrollArea in pairs(ST.scrollAreas) do
            if scrollArea and scrollArea.frame then
                pcall(function() scrollArea.frame:Hide() end)
            end
        end
    end
    
    -- Hide the master frame
    if ST.masterFrame then
        pcall(function() ST.masterFrame:Hide() end)
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, function()
            -- Open the configuration panel
            if self.OpenConfig then
                self:OpenConfig()
            end
        end)
    end
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if VUI and type(VUI.Print) == "function" then
            VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        else
            print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        end
        
        if self.db.profile.enabled then
            self:Enable()
        else
            self:Disable()
        end
    else
        -- Open configuration
        if self.OpenConfig then
            self:OpenConfig()
        elseif VUI and VUI.Config and type(VUI.Config.OpenToCategory) == "function" then
            VUI.Config:OpenToCategory(self.TITLE)
        end
    end
end

-- Theme update handler
function M:UpdateTheme()
    -- Only update if theme colors are enabled
    if not self.db.profile.useThemeColors then return end
    
    local theme = VUI:GetActiveTheme()
    if not theme then return end
    
    -- Call the AnimationStyles theme updater if available
    if ST.AnimationStyles and ST.AnimationStyles.ApplyTheme then
        ST.AnimationStyles.ApplyTheme()
    end
end

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end

-- Add a scrolling message
function M:AddMessage(text, scrollArea, colorType, fontSize, isCrit, iconPath)
    -- Make sure we're initialized and enabled
    if not ST.isInitialized or not self.db.profile.enabled then return end
    
    -- Get the scroll area
    local area = ST.scrollAreas[scrollArea]
    if not area then return end
    
    -- Get the color
    local color = self.db.profile.colors[colorType] or self.db.profile.colors.normal
    
    -- Check if theme colors should be used
    if self.db.profile.useThemeColors and colorType == "normal" then
        local theme = VUI:GetActiveTheme()
        if theme then
            color = {r = theme.colors.primary.r, g = theme.colors.primary.g, b = theme.colors.primary.b, a = 1.0}
        end
    end
    
    -- Add to scroll area (implementation would be in Main.lua)
    if ST.Main and ST.Main.AddMessageToScrollArea then
        ST.Main.AddMessageToScrollArea(area, text, color, fontSize, isCrit, iconPath)
    end
end

-- Event handler methods
function M:OnPlayerEnteringWorld()
    self:CreateScrollAreas()
    
    -- Initialize any dependent components
    if ST.Main and ST.Main.Initialize then
        ST.Main.Initialize()
    end
end

function M:OnCombatLogEvent()
    -- Forward to ST.Main if available
    if ST.Main and ST.Main.ProcessCombatLog then
        ST.Main.ProcessCombatLog(CombatLogGetCurrentEventInfo())
    end
end

function M:OnUnitHealth(event, unit)
    -- Forward to ST.Main if available
    if ST.Main and ST.Main.ProcessUnitHealth then
        ST.Main.ProcessUnitHealth(unit)
    end
end

function M:OnUnitPowerUpdate(event, unit, powerType)
    -- Forward to ST.Main if available
    if ST.Main and ST.Main.ProcessUnitPower then
        ST.Main.ProcessUnitPower(unit, powerType)
    end
end

function M:OnUnitSpellcastSucceeded(event, unit, castGUID, spellID)
    -- Forward to ST.Main if available
    if ST.Main and ST.Main.ProcessSpellcast then
        ST.Main.ProcessSpellcast(unit, castGUID, spellID)
    end
end

-- Connect to the Main module
ST.module = M