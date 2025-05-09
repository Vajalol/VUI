-- VUIAnyFrame - A module of VUI for moving any frame
-- Based on MoveAny by D4KiR

-- Create the addon using AceAddon
local VUIAnyFrame = LibStub("AceAddon-3.0"):NewAddon("VUIAnyFrame", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- Setup locals
local _, VUI = ...

-- Make it accessible globally but namespaced
_G["VUIAnyFrame"] = VUIAnyFrame

-- Set up localization
VUIAnyFrame.L = {}
local L = VUIAnyFrame.L

-- Default settings
local defaults = {
    profile = {
        general = {
            enabled = true,
            lockFrames = false,
        },
        frames = {
            -- This will be populated with frame settings
        },
        elements = {
            -- Element-specific settings will go here
        },
        minimap = {
            hide = false,
        },
    }
}

-- Colors
local colors = {}
colors["bg"] = {0.03, 0.03, 0.03}
colors["se"] = {1.0, 1.0, 0.0}
colors["el"] = {0.6, 0.84, 1.0}
colors["hidden"] = {1.0, 0.0, 0.0}
colors["clickthrough"] = {0.2, 0.2, 1.0}

function VUIAnyFrame:GetColor(key)
    return colors[key][1], colors[key][2], colors[key][3]
end

-- Create the hidden frame container
local VAHIDDEN = CreateFrame("Frame", "VAHIDDEN")
VAHIDDEN:Hide()
VAHIDDEN.unit = "player"
VAHIDDEN.auraRows = 0
VUIAnyFrame.HIDDEN_FRAME = VAHIDDEN

-- Storage for drag frames
local VADF = {}
function VUIAnyFrame:GetDragFrames()
    return VADF
end

-- Define addon version
VUIAnyFrame.version = "0.1.0"

-- Return the addon object for other files to use
return VUIAnyFrame