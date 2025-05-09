local addonName, ns = ...
local VUI = _G.VUI

VUI.Media = VUI.Media or {}
local media = VUI.Media

-- FONTS
media.Fonts = {
  PRIMARY = "Interface\\Addons\\VUI\\Media\\Fonts\\PTSansNarrow.ttf",
  BOLD = "Interface\\Addons\\VUI\\Media\\Fonts\\PTSansNarrowBold.ttf",
  DAMAGE = "Interface\\Addons\\VUI\\Media\\Fonts\\Adventure.ttf",
  HEADER = "Interface\\Addons\\VUI\\Media\\Fonts\\CaviarDreams.ttf",
  HEADER_BOLD = "Interface\\Addons\\VUI\\Media\\Fonts\\CaviarDreamsBold.ttf",
  MONO = "Interface\\Addons\\VUI\\Media\\Fonts\\RobotoMono.ttf",
  NUMBER = "Interface\\Addons\\VUI\\Media\\Fonts\\Expressway.ttf",
}

-- STATUSBAR TEXTURES
media.Statusbars = {
  FLAT = "Interface\\Addons\\VUI\\Media\\Textures\\Statusbars\\Flat.tga",
  GRADIENT = "Interface\\Addons\\VUI\\Media\\Textures\\Statusbars\\Gradient.tga",
  SMOOTH = "Interface\\Addons\\VUI\\Media\\Textures\\Statusbars\\Smooth.tga",
  MINIMALIST = "Interface\\Addons\\VUI\\Media\\Textures\\Statusbars\\Minimalist.tga",
}

-- BACKGROUND TEXTURES
media.Backgrounds = {
  DARK = "Interface\\Addons\\VUI\\Media\\Textures\\Backgrounds\\Dark.tga",
  LIGHT = "Interface\\Addons\\VUI\\Media\\Textures\\Backgrounds\\Light.tga",
  VORTEX = "Interface\\Addons\\VUI\\Media\\Textures\\Backgrounds\\Vortex.tga",
}

-- BORDER TEXTURES
media.Borders = {
  ROUNDED = "Interface\\Addons\\VUI\\Media\\Textures\\Borders\\Rounded.tga",
  SQUARE = "Interface\\Addons\\VUI\\Media\\Textures\\Borders\\Square.tga",
  GLOW = "Interface\\Addons\\VUI\\Media\\Textures\\Borders\\Glow.tga",
}

-- THEME COLORS
media.Colors = {
  VUI = {
    r = 0.054, g = 0.615, b = 0.902, -- #0D9DE6
    hex = "0D9DE6",
  },
  VUI_LIGHT = {
    r = 0.243, g = 0.745, b = 1.000, -- #3EBEFF
    hex = "3EBEFF",
  },
  WHITE = {
    r = 1.000, g = 1.000, b = 1.000,
    hex = "FFFFFF",
  },
  BLACK = {
    r = 0.000, g = 0.000, b = 0.000,
    hex = "000000",
  },
}

-- Register our media with LibSharedMedia if it's available
local LSM = LibStub("LibSharedMedia-3.0", true)
if LSM then
  -- Register fonts
  for name, path in pairs(media.Fonts) do
    LSM:Register("font", "VUI_" .. name, path)
  end
  
  -- Register statusbar textures
  for name, path in pairs(media.Statusbars) do
    LSM:Register("statusbar", "VUI_" .. name, path)
  end
  
  -- Register backgrounds
  for name, path in pairs(media.Backgrounds) do
    LSM:Register("background", "VUI_" .. name, path)
  end
  
  -- Register borders
  for name, path in pairs(media.Borders) do
    LSM:Register("border", "VUI_" .. name, path)
  end
end
