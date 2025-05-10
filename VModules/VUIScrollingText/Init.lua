-------------------------------------------------------------------------------
-- VUIScrollingText Module
-- Displays animated text messages for combat events and notifications
-- Based on MikScrollingBattleText with VUI integration
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUIScrollingText"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Scrolling Text"
M.DESCRIPTION = "Dynamic combat text animations with VUI theme integration"
M.VERSION = "1.0"

-- Create table for ScrollingText component in the VUI namespace for legacy compatibility
VUI.ScrollingText = VUI.ScrollingText or {}
local ST = VUI.ScrollingText

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
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Set up the master frame
    self:SetupMasterFrame()
    
    -- Register slash command
    self:RegisterChatCommand("vuist", "SlashCommand")
    
    -- Legacy support
    self:RegisterChatCommand("msbt", "SlashCommand")
    
    -- Expose module to ST for legacy compatibility
    ST.module = self
    
    -- Flag as initialized
    ST.isInitialized = true
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_POWER_UPDATE")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
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
    -- Create scroll areas based on configuration
    for areaName, areaConfig in pairs(self.db.profile.areas) do
        if areaConfig.enabled then
            self:CreateScrollArea(areaName, areaConfig)
        end
    end
end

-- Create a scroll area
function M:CreateScrollArea(name, config)
    -- Create a new scroll area if it doesn't exist
    if not ST.scrollAreas[name] then
        ST.scrollAreas[name] = {
            name = name,
            frame = CreateFrame("Frame", "VUIScrollingText_" .. name, ST.masterFrame),
            config = config,
            animationStyleSettings = {
                scrollDirection = config.scrollDirection,
                scrollHeight = config.size[2],
                scrollWidth = config.size[1],
                behavior = config.behavior,
                textAlign = config.textAlign,
                useThemeColor = self.db.profile.useThemeColors
            },
            frames = {}
        }
        
        local frame = ST.scrollAreas[name].frame
        frame:SetSize(config.size[1], config.size[2])
        frame:SetPoint(unpack(config.position))
        frame:Show()
    end
end

-- Hide all frames
function M:HideAllFrames()
    -- Hide all scroll area frames
    for _, scrollArea in pairs(ST.scrollAreas) do
        if scrollArea.frame then
            scrollArea.frame:Hide()
        end
    end
    
    -- Hide the master frame
    if ST.masterFrame then
        ST.masterFrame:Hide()
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, function()
        -- Open the configuration panel
        if self.OpenConfig then
            self:OpenConfig()
        end
    end)
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        if self.db.profile.enabled then
            self:Enable()
        else
            self:Disable()
        end
    else
        -- Open configuration
        if self.OpenConfig then
            self:OpenConfig()
        else
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

-- Connect to the Main module
ST.module = M