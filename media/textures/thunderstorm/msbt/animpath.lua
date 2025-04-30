--[[
  Thunderstorm animation path for MSBT
  
  This file defines a custom animation path for the Thunderstorm theme
  Creating a lightning bolt-like animation pattern
]]

local points = {
  {x = 0, y = 0, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0},
  {x = 0, y = 0.1, deltaX = 0.05, deltaY = 0.1, scaleX = 1.1, scaleY = 1.1, alpha = 0.5},
  {x = 0.05, y = 0.2, deltaX = -0.08, deltaY = 0.15, scaleX = 1.2, scaleY = 1.2, alpha = 0.8},
  {x = -0.03, y = 0.35, deltaX = 0.06, deltaY = 0.15, scaleX = 1.2, scaleY = 1.2, alpha = 1},
  {x = 0.03, y = 0.5, deltaX = -0.07, deltaY = 0.15, scaleX = 1.1, scaleY = 1.1, alpha = 0.9},
  {x = -0.04, y = 0.65, deltaX = 0.06, deltaY = 0.15, scaleX = 1, scaleY = 1, alpha = 0.8},
  {x = 0.02, y = 0.8, deltaX = 0.04, deltaY = 0.1, scaleX = 0.9, scaleY = 0.9, alpha = 0.6},
  {x = 0.06, y = 0.9, deltaX = -0.06, deltaY = 0.1, scaleX = 0.8, scaleY = 0.8, alpha = 0.3},
  {x = 0, y = 1, deltaX = 0, deltaY = 0, scaleX = 0.7, scaleY = 0.7, alpha = 0},
}

return points