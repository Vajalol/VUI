local LSM = LibStub("LibSharedMedia-3.0")

-- -----
-- BACKGROUND
-- -----
LSM:Register("background", "VUI Dark", [[Interface\Addons\VUI\media\textures\common\background-dark.tga]])
LSM:Register("background", "VUI Light", [[Interface\Addons\VUI\media\textures\common\background-light.tga]])
LSM:Register("background", "VUI Solid", [[Interface\Addons\VUI\media\textures\common\background-solid.tga]])

-- -----
--  BORDER
-- ----
LSM:Register("border", "VUI Simple", [[Interface\Addons\VUI\media\textures\common\border-simple.tga]])

-- -----
--   FONT
-- -----
LSM:Register("font", "Default", STANDARD_TEXT_FONT, bit.bor(LSM.LOCALE_BIT_western, LSM.LOCALE_BIT_ruRU))
LSM:Register("font", "VUI", [[Interface\Addons\VUI\media\Fonts\Prototype.ttf]])
LSM:Register("font", "Avant Garde", [[Interface\Addons\VUI\media\Fonts\AvantGarde.ttf]], bit.bor(LSM.LOCALE_BIT_western, LSM.LOCALE_BIT_ruRU))
LSM:Register("font", "Arial Bold", [[Interface\Addons\VUI\media\Fonts\Arial_Bold.ttf]])
LSM:Register("font", "Doris P Bold", [[Interface\Addons\VUI\media\Fonts\DorisPBold.ttf]])
LSM:Register("font", "Exo 2 Bold", [[Interface\Addons\VUI\media\Fonts\Exo2Bold.ttf]])
LSM:Register("font", "Expressway", [[Interface\Addons\VUI\media\Fonts\Expressway.ttf]])
LSM:Register("font", "Gotham Narrow Black", [[Interface\Addons\VUI\media\Fonts\GothamNarrow-Black.ttf]])
LSM:Register("font", "Inter Bold", [[Interface\Addons\VUI\media\Fonts\InterBold.ttf]])
LSM:Register("font", "MagistralTT Bold", [[Interface\Addons\VUI\media\Fonts\MagistralTTBold.ttf]])
LSM:Register("font", "Myriad Web Bold", [[Interface\Addons\VUI\media\Fonts\MyriadWebBold.ttf]])

-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
LSM:Register("statusbar", "Default", [[Interface\Default]])
LSM:Register("statusbar", "VUI Flat", [[Interface\Addons\VUI\media\textures\common\statusbar-flat.blp]])
LSM:Register("statusbar", "VUI Gloss", [[Interface\Addons\VUI\media\textures\common\statusbar-gloss.tga]])
LSM:Register("statusbar", "VUI Smooth", [[Interface\Addons\VUI\media\textures\common\statusbar-smooth.blp]])

-- Also register SUI media for backward compatibility
LSM:Register("statusbar", "Flat", [[Interface\Addons\VUI\media\textures\status\Flat.blp]])
LSM:Register("statusbar", "Melli", [[Interface\Addons\VUI\media\textures\status\Melli.tga]])
LSM:Register("statusbar", "Melli 6px", [[Interface\Addons\VUI\media\textures\status\Melli6px.tga]])
LSM:Register("statusbar", "Melli Dark", [[Interface\Addons\VUI\media\textures\status\MelliDark.tga]])
LSM:Register("statusbar", "Melli Dark Rough", [[Interface\Addons\VUI\media\textures\status\MelliDarkRough.tga]])
LSM:Register("statusbar", "Minimalist", [[Interface\Addons\VUI\media\textures\status\Minimalist.tga]])
LSM:Register("statusbar", "Smooth", [[Interface\Addons\VUI\media\textures\status\Smooth.blp]])
LSM:Register("statusbar", "Smooth v2", [[Interface\Addons\VUI\media\textures\status\Smoothv2.tga]])
LSM:Register("statusbar", "Dragonflight", [[Interface\Addons\VUI\media\textures\status\DragonflightTexture.tga]])

-- -----
--   THEME TEXTURES
-- -----

-- Thunder Storm Theme
LSM:Register("statusbar", "ThunderStorm Bar", [[Interface\Addons\VUI\media\textures\themes\thunderstorm\statusbar.blp]])
LSM:Register("border", "ThunderStorm Border", [[Interface\Addons\VUI\media\textures\themes\thunderstorm\border.tga]])
LSM:Register("background", "ThunderStorm Background", [[Interface\Addons\VUI\media\textures\themes\thunderstorm\background.tga]])

-- Phoenix Flame Theme
LSM:Register("statusbar", "PhoenixFlame Bar", [[Interface\Addons\VUI\media\textures\themes\phoenixflame\statusbar.blp]])
LSM:Register("border", "PhoenixFlame Border", [[Interface\Addons\VUI\media\textures\themes\phoenixflame\border.tga]])
LSM:Register("background", "PhoenixFlame Background", [[Interface\Addons\VUI\media\textures\themes\phoenixflame\background.tga]])

-- Arcane Mystic Theme
LSM:Register("statusbar", "ArcaneMystic Bar", [[Interface\Addons\VUI\media\textures\themes\arcanemystic\statusbar.blp]])
LSM:Register("border", "ArcaneMystic Border", [[Interface\Addons\VUI\media\textures\themes\arcanemystic\border.tga]])
LSM:Register("background", "ArcaneMystic Background", [[Interface\Addons\VUI\media\textures\themes\arcanemystic\background.tga]])

-- Fel Energy Theme
LSM:Register("statusbar", "FelEnergy Bar", [[Interface\Addons\VUI\media\textures\themes\felenergy\statusbar.blp]])
LSM:Register("border", "FelEnergy Border", [[Interface\Addons\VUI\media\textures\themes\felenergy\border.tga]])
LSM:Register("background", "FelEnergy Background", [[Interface\Addons\VUI\media\textures\themes\felenergy\background.tga]])
