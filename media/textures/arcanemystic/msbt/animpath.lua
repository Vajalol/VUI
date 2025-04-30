--[[
  Arcane Mystic animation path for MSBT
  
  This file defines a custom animation path for the Arcane Mystic theme
  Creating a swirling, magic-like animation pattern
]]

local points = {
  {x = 0, y = 0, deltaX = 0.04, deltaY = 0.08, scaleX = 1, scaleY = 1, alpha = 0},
  {x = 0.04, y = 0.08, deltaX = 0.07, deltaY = 0.09, scaleX = 1.05, scaleY = 1.05, alpha = 0.4},
  {x = 0.11, y = 0.17, deltaX = 0.04, deltaY = 0.1, scaleX = 1.1, scaleY = 1.1, alpha = 0.7},
  {x = 0.15, y = 0.27, deltaX = -0.02, deltaY = 0.11, scaleX = 1.15, scaleY = 1.15, alpha = 0.9},
  {x = 0.13, y = 0.38, deltaX = -0.06, deltaY = 0.12, scaleX = 1.2, scaleY = 1.2, alpha = 1},
  {x = 0.07, y = 0.5, deltaX = -0.08, deltaY = 0.11, scaleX = 1.15, scaleY = 1.15, alpha = 0.9},
  {x = -0.01, y = 0.61, deltaX = -0.06, deltaY = 0.1, scaleX = 1.1, scaleY = 1.1, alpha = 0.8},
  {x = -0.07, y = 0.71, deltaX = -0.02, deltaY = 0.09, scaleX = 1.05, scaleY = 1.05, alpha = 0.7},
  {x = -0.09, y = 0.8, deltaX = 0.03, deltaY = 0.09, scaleX = 1, scaleY = 1, alpha = 0.4},
  {x = -0.06, y = 0.89, deltaX = 0.06, deltaY = 0.11, scaleX = 0.95, scaleY = 0.95, alpha = 0.2},
  {x = 0, y = 1, deltaX = 0, deltaY = 0, scaleX = 0.9, scaleY = 0.9, alpha = 0},
}

return points