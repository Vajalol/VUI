local LSM = LibStub("LibSharedMedia-3.0")

-- -----
-- BACKGROUND
-- -----
LSM:Register("background", "VUI Dark", [[Interface\AddOns\VUI\media\textures\common\background-dark.tga]])
LSM:Register("background", "VUI Light", [[Interface\AddOns\VUI\media\textures\common\background-light.tga]])
LSM:Register("background", "VUI Solid", [[Interface\AddOns\VUI\media\textures\common\background-solid.tga]])

-- -----
--  BORDER
-- ----
LSM:Register("border", "VUI Simple", [[Interface\AddOns\VUI\media\textures\common\border-simple.tga]])

-- -----
--   FONT
-- -----
LSM:Register("font", "Default", STANDARD_TEXT_FONT, bit.bor(LSM.LOCALE_BIT_western, LSM.LOCALE_BIT_ruRU))
LSM:Register("font", "VUI", [[Interface\Addons\VUI\Media\Fonts\Prototype.ttf]])
LSM:Register("font", "Avant Garde", [[Interface\Addons\VUI\Media\Fonts\AvantGarde.ttf]], bit.bor(LSM.LOCALE_BIT_western, LSM.LOCALE_BIT_ruRU))
LSM:Register("font", "Arial Bold", [[Interface\Addons\VUI\Media\Fonts\Arial_Bold.ttf]])
LSM:Register("font", "Doris P Bold", [[Interface\Addons\VUI\Media\Fonts\DorisPBold.ttf]])
LSM:Register("font", "Exo 2 Bold", [[Interface\Addons\VUI\Media\Fonts\Exo2Bold.ttf]])
LSM:Register("font", "Expressway", [[Interface\Addons\VUI\Media\Fonts\Expressway.ttf]])
LSM:Register("font", "Gotham Narrow Black", [[Interface\Addons\VUI\Media\Fonts\GothamNarrow-Black.ttf]])
LSM:Register("font", "Inter Bold", [[Interface\Addons\VUI\Media\Fonts\InterBold.ttf]])
LSM:Register("font", "MagistralTT Bold", [[Interface\Addons\VUI\Media\Fonts\MagistralTTBold.ttf]])
LSM:Register("font", "Myriad Web Bold", [[Interface\Addons\VUI\Media\Fonts\MyriadWebBold.ttf]])

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
LSM:Register("statusbar", "Flat", [[Interface\Addons\VUI\Media\Textures\Status\Flat.blp]])
LSM:Register("statusbar", "Melli", [[Interface\Addons\VUI\Media\Textures\Status\Melli.tga]])
LSM:Register("statusbar", "Melli 6px", [[Interface\Addons\VUI\Media\Textures\Status\Melli6px.tga]])
LSM:Register("statusbar", "Melli Dark", [[Interface\Addons\VUI\Media\Textures\Status\MelliDark.tga]])
LSM:Register("statusbar", "Melli Dark Rough", [[Interface\Addons\VUI\Media\Textures\Status\MelliDarkRough.tga]])
LSM:Register("statusbar", "Minimalist", [[Interface\Addons\VUI\Media\Textures\Status\Minimalist.tga]])
LSM:Register("statusbar", "Smooth", [[Interface\Addons\VUI\Media\Textures\Status\Smooth.blp]])
LSM:Register("statusbar", "Smooth v2", [[Interface\Addons\VUI\Media\Textures\Status\Smoothv2.tga]])
LSM:Register("statusbar", "Dragonflight", [[Interface\AddOns\VUI\Media\Textures\Status\DragonflightTexture.tga]])

-- -----
--   THEME TEXTURES
-- -----

-- Thunder Storm Theme
LSM:Register("statusbar", "ThunderStorm Bar", [[Interface\AddOns\VUI\media\textures\themes\thunderstorm\statusbar.blp]])
LSM:Register("border", "ThunderStorm Border", [[Interface\AddOns\VUI\media\textures\themes\thunderstorm\border.tga]])
LSM:Register("background", "ThunderStorm Background", [[Interface\AddOns\VUI\media\textures\themes\thunderstorm\background.tga]])

-- Phoenix Flame Theme
LSM:Register("statusbar", "PhoenixFlame Bar", [[Interface\AddOns\VUI\media\textures\themes\phoenixflame\statusbar.blp]])
LSM:Register("border", "PhoenixFlame Border", [[Interface\AddOns\VUI\media\textures\themes\phoenixflame\border.tga]])
LSM:Register("background", "PhoenixFlame Background", [[Interface\AddOns\VUI\media\textures\themes\phoenixflame\background.tga]])

-- Arcane Mystic Theme
LSM:Register("statusbar", "ArcaneMystic Bar", [[Interface\AddOns\VUI\media\textures\themes\arcanemystic\statusbar.blp]])
LSM:Register("border", "ArcaneMystic Border", [[Interface\AddOns\VUI\media\textures\themes\arcanemystic\border.tga]])
LSM:Register("background", "ArcaneMystic Background", [[Interface\AddOns\VUI\media\textures\themes\arcanemystic\background.tga]])

-- Fel Energy Theme
LSM:Register("statusbar", "FelEnergy Bar", [[Interface\AddOns\VUI\media\textures\themes\felenergy\statusbar.blp]])
LSM:Register("border", "FelEnergy Border", [[Interface\AddOns\VUI\media\textures\themes\felenergy\border.tga]])
LSM:Register("background", "FelEnergy Background", [[Interface\AddOns\VUI\media\textures\themes\felenergy\background.tga]])
