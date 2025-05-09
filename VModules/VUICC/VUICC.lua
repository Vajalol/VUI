-- VUICC: Main module file
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:NewModule("VUICC", "AceEvent-3.0")
local L = LibStub('AceLocale-3.0'):GetLocale("VUI")

-- Local references for performance
local GetTime = GetTime
local pairs = pairs

-- Constants
local MIN_START_OFFSET = -86400 -- Filter out buggy cooldowns
local GCD_SPELL_ID = 61304 -- Global cooldown spell ID
local FINISH_EFFECT_BUFFER = -0.15 -- Buffer for finish effects

-- Module initialization
function Module:OnInitialize()
    -- Default settings
    local defaults = {
        profile = {
            enabled = true,
            disableBlizzardCooldownText = true,
            minimumDuration = 2,
            minEffectDuration = 30,
            tenthsDuration = 0,
            mmSSDuration = 0,
            spiralOpacity = 0.7,
            -- Default theme
            theme = {
                fontSize = 18,
                fontFace = 'Friz Quadrata TT',
                fontOutline = 'OUTLINE',
                minSize = 0.5,
                minDuration = 3,
                tenthsThreshold = 0,
                mmssThreshold = 0,
                xOff = 0,
                yOff = 0,
                anchor = 'CENTER',
                styles = {
                    soon = {
                        r = 1.0, g = 0.0, b = 0.0, a = 1.0,
                        scale = 1.0
                    },
                    seconds = {
                        r = 1.0, g = 1.0, b = 0.0, a = 1.0,
                        scale = 1.0
                    },
                    minutes = {
                        r = 1.0, g = 1.0, b = 1.0, a = 1.0,
                        scale = 1.0
                    },
                    hours = {
                        r = 0.7, g = 0.7, b = 0.7, a = 1.0,
                        scale = 0.75
                    },
                    days = {
                        r = 0.7, g = 0.7, b = 0.7, a = 1.0,
                        scale = 0.75
                    }
                },
                effect = 'pulse',
                effectSettings = {}
            },
            rules = {},
            useGlobalSettings = true
        }
    }

    -- Initialize database
    if not VUI_SavedVariables.VUICC then
        VUI_SavedVariables.VUICC = {}
    end
    
    self.db = VUI_SavedVariables.VUICC
    
    -- Merge defaults with saved variables
    for k, v in pairs(defaults.profile) do
        if self.db[k] == nil then
            self.db[k] = v
        end
    end
    
    -- Initialize components
    self:SetupComponents()
    
    -- Initialize settings
    self.Settings:Init()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Module:OnEnable()
    -- Hook cooldown functions
    self.Cooldown:SetupHooks()
end

function Module:PLAYER_ENTERING_WORLD()
    self.Timer:ForActive('Update')
end

-- Setup core components
function Module:SetupComponents()
    self.Cooldown = {}
    self.Timer = {}
    self.Display = {}
    self.FX = {}
    self.Effects = {}
    self.Settings = {}
    
    -- These will be populated from the component files
end

-- Utility function for creating hidden frames
function Module:CreateHiddenFrame(...)
    local f = CreateFrame(...)
    f:Hide()
    return f
end

-- Get button icon
function Module:GetButtonIcon(frame)
    if frame then
        local icon = frame.icon
        if type(icon) == 'table' and icon.GetTexture then
            return icon
        end

        local name = frame:GetName()
        if name then
            icon = _G[name .. 'Icon'] or _G[name .. 'IconTexture']

            if type(icon) == 'table' and icon.GetTexture then
                return icon
            end
        end
    end
end

-- Theme management
function Module:GetDefaultTheme()
    return self.db.theme
end

function Module:GetTheme(name)
    return name and self.db.themes and self.db.themes[name] or self:GetDefaultTheme()
end

function Module:GetMatchingRule(cooldownName)
    if cooldownName and self.db.rules then
        for _, rule in pairs(self.db.rules) do
            if self:IsRuleMatch(cooldownName, rule.pattern) then
                return rule
            end
        end
    end
    return nil
end

function Module:IsRuleMatch(name, pattern)
    if pattern == '' then
        return false
    end
    
    return name:match(pattern) ~= nil
end

-- Show options frame
function Module:ShowOptions()
    if InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame:Hide()
    else
        InterfaceOptionsFrame_OpenToCategory("VUI")
        InterfaceOptionsFrame_OpenToCategory("VUI VUICC")
    end
end

-- Exports for other components
_G["VUICC"] = Module