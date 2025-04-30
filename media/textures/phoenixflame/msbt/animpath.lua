--[[
  Phoenix Flame animation path for MSBT
  
  This file defines a custom animation path for the Phoenix Flame theme
  Creating a rising flame-like animation pattern
]]

local points = {
  {x = 0, y = 0, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0},
  {x = 0, y = 0.1, deltaX = -0.02, deltaY = 0.12, scaleX = 1.1, scaleY = 1.1, alpha = 0.5},
  {x = -0.02, y = 0.22, deltaX = 0.04, deltaY = 0.13, scaleX = 1.15, scaleY = 1.2, alpha = 0.7},
  {x = 0.02, y = 0.35, deltaX = -0.04, deltaY = 0.12, scaleX = 1.2, scaleY = 1.25, alpha = 0.9},
  {x = -0.02, y = 0.47, deltaX = 0.02, deltaY = 0.12, scaleX = 1.25, scaleY = 1.3, alpha = 1},
  {x = 0, y = 0.59, deltaX = 0.03, deltaY = 0.11, scaleX = 1.2, scaleY = 1.25, alpha = 0.9},
  {x = 0.03, y = 0.7, deltaX = -0.03, deltaY = 0.1, scaleX = 1.15, scaleY = 1.2, alpha = 0.75},
  {x = 0, y = 0.8, deltaX = 0.02, deltaY = 0.1, scaleX = 1.1, scaleY = 1.15, alpha = 0.5},
  {x = 0.02, y = 0.9, deltaX = -0.02, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.25},
  {x = 0, y = 1, deltaX = 0, deltaY = 0, scaleX = 0.9, scaleY = 0.9, alpha = 0},
}

return points