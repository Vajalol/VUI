-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Initialization
-- Author: Vortex-WoW
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

-- Create the addon.
local addonName, VUI = ...
if not VUI then return end

-- Create a module in the VUI namespace
local VUIScrollingText = VUI:NewModule("VUIScrollingText", "AceConsole-3.0")

-- Create table for ScrollingText component in the VUI namespace
VUI.ScrollingText = {}
local ST = VUI.ScrollingText

-- Animation directions.
ST.SCROLL_UP = 1
ST.SCROLL_DOWN = 2
ST.SCROLL_LEFT = 3
ST.SCROLL_RIGHT = 4

-- Text alignment
ST.ALIGN_LEFT = "LEFT"
ST.ALIGN_RIGHT = "RIGHT"
ST.ALIGN_CENTER = "CENTER"

-- Animation behaviors.
ST.BEHAVIOR_SCROLL = 1
ST.BEHAVIOR_PARABOLA = 2
ST.BEHAVIOR_STRAIGHT = 3
ST.BEHAVIOR_STATIC = 4

-- Default theme color (VUI blue)
ST.defaultThemeColor = {r = 0, g = 0.44, b = 0.87}

-- ScrollingText private data
ST.isInitialized = false
ST.scrollAreas = {}
ST.animationSpeed = 1
ST.enableScrollArea = {}
ST.masterFont = "Friz Quadrata TT"
ST.normalFontSize = 18
ST.normalOutlineIndex = 2
ST.critFontSize = 26
ST.critOutlineIndex = 2
ST.soundsEnabled = true
ST.useThemeColor = true

-- Module object
VUIScrollingText.ST = ST
VUIScrollingText.version = GetAddOnMetadata("VUI", "Version") or "Unknown"

-- Make the ScrollingText object accessible for other modules
_G["VUIScrollingText"] = ST