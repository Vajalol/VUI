-- VUIKeystones - A module of VUI for enhancing Mythic+ Keystones
-- Based on Angry Keystones by Ermad

-- Create the addon using AceAddon
local VUIKeystones = LibStub("AceAddon-3.0"):NewAddon("VUIKeystones", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

-- Setup locals
local _, VUI = ...

-- Make it accessible globally but namespaced
_G["VUIKeystones"] = VUIKeystones

-- Creating a module system similar to the original
VUIKeystones.Modules = {}

function VUIKeystones:NewModule(name)
    if not self.Modules[name] then
        self.Modules[name] = {}
    end
    return self.Modules[name]
end

function VUIKeystones:GetModule(name)
    return self.Modules[name]
end

-- Set up localization
VUIKeystones.L = {}
local L = VUIKeystones.L

-- Default settings
local defaults = {
    profile = {
        general = {
            enabled = true,
        },
        progressTooltip = true,
        progressTooltipMDT = false,
        progressFormat = 1,
        autoGossip = true,
        cosRumors = false,
        silverGoldTimer = false,
        splitsFormat = 1,
        completionMessage = true,
        smallAffixes = true,
        deathTracker = true,
        recordSplits = false,
        showLevelModifier = false,
        hideTalkingHead = true,
        resetPopup = false,
        announceKeystones = false,
        schedule = true,
    }
}

-- Define addon version
VUIKeystones.version = "0.1.0"

-- Register core events
local EventListener = CreateFrame('Frame', "VUIKeystonesListener")
local EventListeners = {}

local function Addon_OnEvent(frame, event, ...)
    if EventListeners[event] then
        for callback, func in pairs(EventListeners[event]) do
            if func == 0 then
                callback[event](callback, ...)
            else
                callback[func](callback, event, ...)
            end
        end
    end
end

EventListener:SetScript('OnEvent', Addon_OnEvent)

function VUIKeystones:RegisterEvent(event, callback, func)
    if func == nil then func = 0 end
    if EventListeners[event] == nil then
        EventListener:RegisterEvent(event)
        EventListeners[event] = { [callback]=func }
    else
        EventListeners[event][callback] = func
    end
end

function VUIKeystones:UnregisterEvent(event, callback)
    local listeners = EventListeners[event]
    if listeners then
        listeners[callback] = nil
        if not next(listeners) then
            EventListener:UnregisterEvent(event)
            EventListeners[event] = nil
        end
    end
end

-- Return the addon object for other files to use
return VUIKeystones