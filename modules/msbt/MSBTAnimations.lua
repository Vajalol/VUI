-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Animations
-- Author: Mikord
-- VUI Integration by VortexQ8
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Animations"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTMedia = MikSBT.Media
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

-- Local references to various functions for faster access.
local table_remove = table.remove
local string_find = string.find
local string_lower = string.lower
local IsModDisabled = MSBTProfiles.IsModDisabled
local EraseTable = MikSBT.EraseTable

-- Local references to various variables for faster access.
local fonts = MSBTMedia.fonts
local sounds = MSBTMedia.sounds


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Max number of animations to show in a scroll area and animation defaults.
local MAX_ANIMATIONS_PER_AREA = 15
local DEFAULT_SCROLL_TIME = 3
local DEFAULT_FADE_PERCENT = 0.8

-- The amount of time to delay between updating an animating object.
local ANIMATION_DELAY = 0.015

-- Left, Center, Right Text Aligns.
local TEXT_ALIGN_MAP = {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

-- Outline styles.
local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROME,OUTLINE", "MONOCHROME,THICKOUTLINE"}


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Dynamically created frames for animating text.
local animationFrames = {}

-- Dynamically created animation paths. Defined in the RegisterAnimationPath function
local animationPaths = {}

-- Animation data for each scroll area.
local animationData = {}

-- Flag indicating that the all animation frames have been created.
local animationFramesCreated

-- Flag for whether or not the animation system is running.
local isRunning


-------------------------------------------------------------------------------
-- Animation path functions.
-------------------------------------------------------------------------------

-- **********************************************************************************
-- Register a new animation path.
-- **********************************************************************************
local function RegisterAnimationPath(name, pointsTable)
  animationPaths[name] = pointsTable
end


-- **********************************************************************************
-- Linear animation path.
-- **********************************************************************************
local function GetLinearPoints()
  return {
    {x = 0, y = 0, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0},
    {x = 0, y = 0.1, deltaX = 0, deltaY = 0.8, scaleX = 1, scaleY = 1, alpha = 1},
    {x = 0, y = 0.9, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0},
  }
end


-- **********************************************************************************
-- Parabola animation path.
-- **********************************************************************************
local function GetParabolaPoints()
  return {
    {x = 0, y = 0, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0},
    {x = 0, y = 0.1, deltaX = 0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.7},
    {x = 0.1, y = 0.2, deltaX = 0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.8},
    {x = 0.25, y = 0.3, deltaX = 0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.9},
    {x = 0.4, y = 0.4, deltaX = 0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 1},
    {x = 0.5, y = 0.5, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 1},
    {x = 0.5, y = 0.6, deltaX = -0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 1},
    {x = 0.4, y = 0.7, deltaX = -0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.9},
    {x = 0.25, y = 0.8, deltaX = -0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.8},
    {x = 0.1, y = 0.9, deltaX = -0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.7},
    {x = 0, y = 1, deltaX = 0, deltaY = 0, scaleX = 1, scaleY = 1, alpha = 0},
  }
end


-------------------------------------------------------------------------------
-- VUI custom animation paths.
-------------------------------------------------------------------------------

-- Register VUI custom animation paths for each theme
local function RegisterVUIAnimationPaths()
  -- Load the animation paths for each theme from their respective files
  local function LoadThemeAnimPath(theme)
    local success, animPoints = pcall(function()
      local loadPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\msbt\\animpath.lua"
      -- Using dofile to directly load and execute the file
      return dofile(loadPath)
    end)
    
    if success and animPoints then
      return animPoints
    else
      -- If there's an error loading the file, return the parabola points as a fallback
      return GetParabolaPoints()
    end
  end
  
  -- Register each theme's animation path
  RegisterAnimationPath("VUI Thunder Storm", LoadThemeAnimPath("thunderstorm"))
  RegisterAnimationPath("VUI Phoenix Flame", LoadThemeAnimPath("phoenixflame"))
  RegisterAnimationPath("VUI Arcane Mystic", LoadThemeAnimPath("arcanemystic"))
  RegisterAnimationPath("VUI Fel Energy", LoadThemeAnimPath("felenergy"))
end


-------------------------------------------------------------------------------
-- Module initialization.
-------------------------------------------------------------------------------

-- Register default animation paths.
RegisterAnimationPath("Straight", GetLinearPoints())
RegisterAnimationPath("Parabola", GetParabolaPoints())

-- Register VUI animation paths.
RegisterVUIAnimationPaths()


-- Module functions
module.DisplayEvent = function(self, eventType, message, throttleTime)
  -- Animation display logic will be implemented here
  -- This is a placeholder for the full implementation
end

module.DisplayMessage = function(self, scrollArea, message, colorR, colorG, colorB, fontSize, fontName, fontOutline, texturePath, showSticky)
  -- Message display logic will be implemented here
  -- This is a placeholder for the full implementation
end

module.UpdateAnimationSpeed = function(self, scrollSpeed)
  -- Animation speed update logic will be implemented here
  -- This is a placeholder for the full implementation
end

module.ResetAnimationData = function(self)
  -- Animation data reset logic will be implemented here
  -- This is a placeholder for the full implementation
end

module.Enable = function(self)
  -- Enable logic will be implemented here
  -- This is a placeholder for the full implementation
  isRunning = true
end

module.Disable = function(self)
  -- Disable logic will be implemented here
  -- This is a placeholder for the full implementation
  isRunning = false
end