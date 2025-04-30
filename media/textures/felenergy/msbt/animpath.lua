--[[
  Fel Energy animation path for MSBT
  
  This file defines a custom animation path for the Fel Energy theme
  Creating a corrupting, fel-like animation pattern
]]

local points = {
  {x = 0, y = 0, deltaX = -0.05, deltaY = 0.07, scaleX = 1, scaleY = 1, alpha = 0},
  {x = -0.05, y = 0.07, deltaX = -0.02, deltaY = 0.09, scaleX = 1.1, scaleY = 1.1, alpha = 0.5},
  {x = -0.07, y = 0.16, deltaX = 0.04, deltaY = 0.11, scaleX = 1.15, scaleY = 1.15, alpha = 0.7},
  {x = -0.03, y = 0.27, deltaX = 0.08, deltaY = 0.1, scaleX = 1.2, scaleY = 1.2, alpha = 0.85},
  {x = 0.05, y = 0.37, deltaX = 0.06, deltaY = 0.1, scaleX = 1.25, scaleY = 1.25, alpha = 0.95},
  {x = 0.11, y = 0.47, deltaX = 0.02, deltaY = 0.1, scaleX = 1.3, scaleY = 1.3, alpha = 1},
  {x = 0.13, y = 0.57, deltaX = -0.03, deltaY = 0.11, scaleX = 1.25, scaleY = 1.25, alpha = 0.9},
  {x = 0.1, y = 0.68, deltaX = -0.07, deltaY = 0.1, scaleX = 1.2, scaleY = 1.2, alpha = 0.8},
  {x = 0.03, y = 0.78, deltaX = -0.05, deltaY = 0.08, scaleX = 1.1, scaleY = 1.1, alpha = 0.6},
  {x = -0.02, y = 0.86, deltaX = 0.02, deltaY = 0.08, scaleX = 1, scaleY = 1, alpha = 0.4},
  {x = 0, y = 0.94, deltaX = 0, deltaY = 0.06, scaleX = 0.9, scaleY = 0.9, alpha = 0.2},
  {x = 0, y = 1, deltaX = 0, deltaY = 0, scaleX = 0.8, scaleY = 0.8, alpha = 0},
}

return points