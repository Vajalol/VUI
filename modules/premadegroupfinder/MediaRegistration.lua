-- VUI Premade Group Finder Module - Media Registration
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local PGF = VUI.premadegroupfinder
local LSM = LibStub("LibSharedMedia-3.0")

-- Register media assets
function PGF:RegisterMedia()
    -- Phoenix Flame theme
    self:RegisterThemeMedia("phoenixflame")
    
    -- Thunder Storm theme
    self:RegisterThemeMedia("thunderstorm")
    
    -- Arcane Mystic theme
    self:RegisterThemeMedia("arcanemystic")
    
    -- Fel Energy theme
    self:RegisterThemeMedia("felenergy")
end

-- Register all media for a specific theme
function PGF:RegisterThemeMedia(theme)
    -- Define the icons to register
    local icons = {
        "tank", "healer", "dps", "mythicplus", "raid", "pvp", 
        "questing", "favorite", "favorites", "blacklist", 
        "refresh", "filter", "voicechat"
    }
    
    -- Register all icons for this theme
    for _, icon in ipairs(icons) do
        self:RegisterThemeIcon(theme, icon)
    end
end

-- Register a single theme icon
function PGF:RegisterThemeIcon(theme, iconName)
    local mediaType = "texture"
    local mediaName = string.format("vui_pgf_%s_%s", theme, iconName)
    local mediaPath = string.format("Interface\\AddOns\\VUI\\media\\textures\\%s\\premadegroupfinder\\%s", theme, iconName)
    
    -- Register with LibSharedMedia
    LSM:Register(mediaType, mediaName, mediaPath)
    
    -- Store the path in our assets table
    if not self.themeAssets[theme] then
        self.themeAssets[theme] = { icons = {} }
    end
    
    self.themeAssets[theme].icons[iconName] = mediaPath
end

-- Create SVG assets for each theme
function PGF:CreateThemeAssets()
    -- Create Phoenix Flame theme assets
    self:CreatePhoenixFlameAssets()
    
    -- Create Thunder Storm theme assets
    self:CreateThunderStormAssets()
    
    -- Create Arcane Mystic theme assets
    self:CreateArcaneMysticAssets()
    
    -- Create Fel Energy theme assets
    self:CreateFelEnergyAssets()
end

-- Create Phoenix Flame theme assets
function PGF:CreatePhoenixFlameAssets()
    -- Define colors
    local primaryColor = "#E64D0D" -- Fiery orange
    local secondaryColor = "#FFA31A" -- Amber
    local accentColor = "#FF7D45" -- Bright orange
    local backgroundFill = "#1A0A05" -- Dark red/brown bg
    
    -- Create tank icon
    self:CreateSVGIcon("phoenixflame", "tank", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M16,10c-2.2,0-4,1.8-4,4h8C20,11.8,18.2,10,16,10z" fill="]]..accentColor..[["/>
  <rect x="14" y="14" width="4" height="8" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create healer icon
    self:CreateSVGIcon("phoenixflame", "healer", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <rect x="12" y="10" width="8" height="3" fill="]]..accentColor..[["/>
  <rect x="14.5" y="9" width="3" height="14" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create dps icon
    self:CreateSVGIcon("phoenixflame", "dps", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M11,11l10,10 M21,11l-10,10" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create mythicplus icon
    self:CreateSVGIcon("phoenixflame", "mythicplus", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,7v18 M7,16h18" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="3" fill="]]..secondaryColor..[["/>
  <path d="M13,10l3,-3l3,3 M13,22l3,3l3,-3 M10,13l-3,3l3,3 M22,13l3,3l-3,3" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create raid icon
    self:CreateSVGIcon("phoenixflame", "raid", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,5v22 M5,16h22" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M7.5,7.5l17,17 M24.5,7.5l-17,17" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="4" fill="]]..secondaryColor..[["/>
</svg>
    ]])
    
    -- Create PvP icon
    self:CreateSVGIcon("phoenixflame", "pvp", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,10l-4,4 M12,8l-2,6 M16,7v6 M20,8l2,6 M22,10l4,4" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M10,22c0-3.3,2.7-6,6-6s6,2.7,6,6H10z" fill="]]..accentColor..[["/>
  <circle cx="16" cy="12" r="3" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create remaining icons (questing, favorite, etc.)
    -- Questing icon
    self:CreateSVGIcon("phoenixflame", "questing", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,11h12v10H10z" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M14,8v6 M18,8v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M10,14h12 M13,19l3,-2l3,2" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Favorite icon (filled star)
    self:CreateSVGIcon("phoenixflame", "favorite", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <polygon points="16,5 19.5,12.5 28,13.8 22,19.5 23.5,28 16,24 8.5,28 10,19.5 4,13.8 12.5,12.5" fill="]]..accentColor..[[" stroke="]]..primaryColor..[[" stroke-width="1.5"/>
</svg>
    ]])
    
    -- Favorites icon (multiple stars)
    self:CreateSVGIcon("phoenixflame", "favorites", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <polygon points="16,8 18,13 23,13.5 19.5,17 20.5,22 16,19.5 11.5,22 12.5,17 9,13.5 14,13" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="1"/>
  <polygon points="8,17 9,19 11,19.2 9.5,21 10,23 8,22 6,23 6.5,21 5,19.2 7,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
  <polygon points="24,17 25,19 27,19.2 25.5,21 26,23 24,22 22,23 22.5,21 21,19.2 23,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
</svg>
    ]])
    
    -- Blacklist icon
    self:CreateSVGIcon("phoenixflame", "blacklist", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <circle cx="16" cy="16" r="10" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M10,10l12,12 M22,10l-12,12" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Refresh icon
    self:CreateSVGIcon("phoenixflame", "refresh", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M23,16c0,3.9-3.1,7-7,7s-7-3.1-7-7s3.1-7,7-7c1.9,0,3.7,0.8,5,2l-2,2" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
  <path d="M19,9l4,2l-2,4" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>
    ]])
    
    -- Filter icon
    self:CreateSVGIcon("phoenixflame", "filter", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M7,10h18 M9,16h14 M11,22h10" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Voice chat icon
    self:CreateSVGIcon("phoenixflame", "voicechat", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,8v16 M12,11v10 M8,13v6 M20,11v10 M24,13v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
end

-- Create Thunder Storm theme assets
function PGF:CreateThunderStormAssets()
    -- Define colors
    local primaryColor = "#0D9DE6" -- Electric blue
    local secondaryColor = "#56CFE9" -- Light blue
    local accentColor = "#A7DCFF" -- Pale blue
    local backgroundFill = "#0A0A1A" -- Deep blue bg
    
    -- Create tank icon
    self:CreateSVGIcon("thunderstorm", "tank", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M16,10c-2.2,0-4,1.8-4,4h8C20,11.8,18.2,10,16,10z" fill="]]..accentColor..[["/>
  <rect x="14" y="14" width="4" height="8" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create healer icon
    self:CreateSVGIcon("thunderstorm", "healer", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <rect x="12" y="10" width="8" height="3" fill="]]..accentColor..[["/>
  <rect x="14.5" y="9" width="3" height="14" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create dps icon
    self:CreateSVGIcon("thunderstorm", "dps", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M11,11l10,10 M21,11l-10,10" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create mythicplus icon
    self:CreateSVGIcon("thunderstorm", "mythicplus", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,7v18 M7,16h18" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="3" fill="]]..secondaryColor..[["/>
  <path d="M13,10l3,-3l3,3 M13,22l3,3l3,-3 M10,13l-3,3l3,3 M22,13l3,3l-3,3" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create raid icon
    self:CreateSVGIcon("thunderstorm", "raid", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,5v22 M5,16h22" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M7.5,7.5l17,17 M24.5,7.5l-17,17" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="4" fill="]]..secondaryColor..[["/>
</svg>
    ]])
    
    -- Create PvP icon
    self:CreateSVGIcon("thunderstorm", "pvp", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,10l-4,4 M12,8l-2,6 M16,7v6 M20,8l2,6 M22,10l4,4" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M10,22c0-3.3,2.7-6,6-6s6,2.7,6,6H10z" fill="]]..accentColor..[["/>
  <circle cx="16" cy="12" r="3" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Questing icon
    self:CreateSVGIcon("thunderstorm", "questing", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,11h12v10H10z" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M14,8v6 M18,8v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M10,14h12 M13,19l3,-2l3,2" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Favorite icon
    self:CreateSVGIcon("thunderstorm", "favorite", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <polygon points="16,5 19.5,12.5 28,13.8 22,19.5 23.5,28 16,24 8.5,28 10,19.5 4,13.8 12.5,12.5" fill="]]..accentColor..[[" stroke="]]..primaryColor..[[" stroke-width="1.5"/>
</svg>
    ]])
    
    -- Favorites icon
    self:CreateSVGIcon("thunderstorm", "favorites", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <polygon points="16,8 18,13 23,13.5 19.5,17 20.5,22 16,19.5 11.5,22 12.5,17 9,13.5 14,13" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="1"/>
  <polygon points="8,17 9,19 11,19.2 9.5,21 10,23 8,22 6,23 6.5,21 5,19.2 7,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
  <polygon points="24,17 25,19 27,19.2 25.5,21 26,23 24,22 22,23 22.5,21 21,19.2 23,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
</svg>
    ]])
    
    -- Blacklist icon
    self:CreateSVGIcon("thunderstorm", "blacklist", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <circle cx="16" cy="16" r="10" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M10,10l12,12 M22,10l-12,12" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Refresh icon
    self:CreateSVGIcon("thunderstorm", "refresh", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M23,16c0,3.9-3.1,7-7,7s-7-3.1-7-7s3.1-7,7-7c1.9,0,3.7,0.8,5,2l-2,2" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
  <path d="M19,9l4,2l-2,4" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>
    ]])
    
    -- Filter icon
    self:CreateSVGIcon("thunderstorm", "filter", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M7,10h18 M9,16h14 M11,22h10" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Voice chat icon
    self:CreateSVGIcon("thunderstorm", "voicechat", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,8v16 M12,11v10 M8,13v6 M20,11v10 M24,13v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
end

-- Create Arcane Mystic theme assets
function PGF:CreateArcaneMysticAssets()
    -- Define colors
    local primaryColor = "#9D0DE6" -- Violet
    local secondaryColor = "#CB6CE6" -- Light purple
    local accentColor = "#E2A9FF" -- Pale purple
    local backgroundFill = "#1A0A2F" -- Deep purple bg
    
    -- Create tank icon
    self:CreateSVGIcon("arcanemystic", "tank", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M16,10c-2.2,0-4,1.8-4,4h8C20,11.8,18.2,10,16,10z" fill="]]..accentColor..[["/>
  <rect x="14" y="14" width="4" height="8" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create healer icon
    self:CreateSVGIcon("arcanemystic", "healer", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <rect x="12" y="10" width="8" height="3" fill="]]..accentColor..[["/>
  <rect x="14.5" y="9" width="3" height="14" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create dps icon
    self:CreateSVGIcon("arcanemystic", "dps", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M11,11l10,10 M21,11l-10,10" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create mythicplus icon
    self:CreateSVGIcon("arcanemystic", "mythicplus", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,7v18 M7,16h18" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="3" fill="]]..secondaryColor..[["/>
  <path d="M13,10l3,-3l3,3 M13,22l3,3l3,-3 M10,13l-3,3l3,3 M22,13l3,3l-3,3" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Implement the remaining icons (raid, pvp, questing, etc.) following the same pattern
    -- Raid icon
    self:CreateSVGIcon("arcanemystic", "raid", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,5v22 M5,16h22" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M7.5,7.5l17,17 M24.5,7.5l-17,17" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="4" fill="]]..secondaryColor..[["/>
</svg>
    ]])
    
    -- PvP icon
    self:CreateSVGIcon("arcanemystic", "pvp", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,10l-4,4 M12,8l-2,6 M16,7v6 M20,8l2,6 M22,10l4,4" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M10,22c0-3.3,2.7-6,6-6s6,2.7,6,6H10z" fill="]]..accentColor..[["/>
  <circle cx="16" cy="12" r="3" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create the remaining icons following the same pattern
    -- Questing icon
    self:CreateSVGIcon("arcanemystic", "questing", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,11h12v10H10z" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M14,8v6 M18,8v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M10,14h12 M13,19l3,-2l3,2" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Favorite icon
    self:CreateSVGIcon("arcanemystic", "favorite", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <polygon points="16,5 19.5,12.5 28,13.8 22,19.5 23.5,28 16,24 8.5,28 10,19.5 4,13.8 12.5,12.5" fill="]]..accentColor..[[" stroke="]]..primaryColor..[[" stroke-width="1.5"/>
</svg>
    ]])
    
    -- Favorites icon
    self:CreateSVGIcon("arcanemystic", "favorites", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <polygon points="16,8 18,13 23,13.5 19.5,17 20.5,22 16,19.5 11.5,22 12.5,17 9,13.5 14,13" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="1"/>
  <polygon points="8,17 9,19 11,19.2 9.5,21 10,23 8,22 6,23 6.5,21 5,19.2 7,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
  <polygon points="24,17 25,19 27,19.2 25.5,21 26,23 24,22 22,23 22.5,21 21,19.2 23,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
</svg>
    ]])
    
    -- Blacklist icon
    self:CreateSVGIcon("arcanemystic", "blacklist", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <circle cx="16" cy="16" r="10" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M10,10l12,12 M22,10l-12,12" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Refresh icon
    self:CreateSVGIcon("arcanemystic", "refresh", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M23,16c0,3.9-3.1,7-7,7s-7-3.1-7-7s3.1-7,7-7c1.9,0,3.7,0.8,5,2l-2,2" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
  <path d="M19,9l4,2l-2,4" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>
    ]])
    
    -- Filter icon
    self:CreateSVGIcon("arcanemystic", "filter", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M7,10h18 M9,16h14 M11,22h10" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Voice chat icon
    self:CreateSVGIcon("arcanemystic", "voicechat", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,8v16 M12,11v10 M8,13v6 M20,11v10 M24,13v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
end

-- Create Fel Energy theme assets
function PGF:CreateFelEnergyAssets()
    -- Define colors
    local primaryColor = "#1AFF1A" -- Fel green
    local secondaryColor = "#8CFF8C" -- Light green
    local accentColor = "#B2FFB2" -- Pale green
    local backgroundFill = "#0A1A0A" -- Dark green bg
    
    -- Create tank icon
    self:CreateSVGIcon("felenergy", "tank", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M16,10c-2.2,0-4,1.8-4,4h8C20,11.8,18.2,10,16,10z" fill="]]..accentColor..[["/>
  <rect x="14" y="14" width="4" height="8" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create healer icon
    self:CreateSVGIcon("felenergy", "healer", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <rect x="12" y="10" width="8" height="3" fill="]]..accentColor..[["/>
  <rect x="14.5" y="9" width="3" height="14" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Create dps icon
    self:CreateSVGIcon("felenergy", "dps", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="none"/>
  <path d="M16,5L7,8v7c0,5.1,3.8,9.8,9,10.8c5.2-1,9-5.7,9-10.8V8L16,5z" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2" stroke-linejoin="round"/>
  <path d="M11,11l10,10 M21,11l-10,10" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create mythicplus icon
    self:CreateSVGIcon("felenergy", "mythicplus", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,7v18 M7,16h18" stroke="]]..accentColor..[[" stroke-width="3" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="3" fill="]]..secondaryColor..[["/>
  <path d="M13,10l3,-3l3,3 M13,22l3,3l3,-3 M10,13l-3,3l3,3 M22,13l3,3l-3,3" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Create the remaining icons following the same pattern
    -- Raid icon
    self:CreateSVGIcon("felenergy", "raid", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,5v22 M5,16h22" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M7.5,7.5l17,17 M24.5,7.5l-17,17" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <circle cx="16" cy="16" r="4" fill="]]..secondaryColor..[["/>
</svg>
    ]])
    
    -- PvP icon
    self:CreateSVGIcon("felenergy", "pvp", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,10l-4,4 M12,8l-2,6 M16,7v6 M20,8l2,6 M22,10l4,4" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M10,22c0-3.3,2.7-6,6-6s6,2.7,6,6H10z" fill="]]..accentColor..[["/>
  <circle cx="16" cy="12" r="3" fill="]]..accentColor..[["/>
</svg>
    ]])
    
    -- Questing icon
    self:CreateSVGIcon("felenergy", "questing", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M10,11h12v10H10z" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M14,8v6 M18,8v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
  <path d="M10,14h12 M13,19l3,-2l3,2" stroke="]]..secondaryColor..[[" stroke-width="1.5" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Favorite icon
    self:CreateSVGIcon("felenergy", "favorite", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <polygon points="16,5 19.5,12.5 28,13.8 22,19.5 23.5,28 16,24 8.5,28 10,19.5 4,13.8 12.5,12.5" fill="]]..accentColor..[[" stroke="]]..primaryColor..[[" stroke-width="1.5"/>
</svg>
    ]])
    
    -- Favorites icon
    self:CreateSVGIcon("felenergy", "favorites", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <polygon points="16,8 18,13 23,13.5 19.5,17 20.5,22 16,19.5 11.5,22 12.5,17 9,13.5 14,13" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="1"/>
  <polygon points="8,17 9,19 11,19.2 9.5,21 10,23 8,22 6,23 6.5,21 5,19.2 7,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
  <polygon points="24,17 25,19 27,19.2 25.5,21 26,23 24,22 22,23 22.5,21 21,19.2 23,19" fill="]]..accentColor..[[" stroke="]]..secondaryColor..[[" stroke-width="0.8"/>
</svg>
    ]])
    
    -- Blacklist icon
    self:CreateSVGIcon("felenergy", "blacklist", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <circle cx="16" cy="16" r="10" fill="none" stroke="]]..accentColor..[[" stroke-width="2"/>
  <path d="M10,10l12,12 M22,10l-12,12" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Refresh icon
    self:CreateSVGIcon("felenergy", "refresh", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M23,16c0,3.9-3.1,7-7,7s-7-3.1-7-7s3.1-7,7-7c1.9,0,3.7,0.8,5,2l-2,2" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
  <path d="M19,9l4,2l-2,4" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>
    ]])
    
    -- Filter icon
    self:CreateSVGIcon("felenergy", "filter", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M7,10h18 M9,16h14 M11,22h10" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
    
    -- Voice chat icon
    self:CreateSVGIcon("felenergy", "voicechat", [[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="14" fill="]]..backgroundFill..[[" stroke="]]..primaryColor..[[" stroke-width="2"/>
  <path d="M16,8v16 M12,11v10 M8,13v6 M20,11v10 M24,13v6" stroke="]]..accentColor..[[" stroke-width="2" stroke-linecap="round"/>
</svg>
    ]])
end

-- Helper function to create a theme-specific icon and save it
function PGF:CreateSVGIcon(theme, iconName, svgContent)
    -- Create the directory if it doesn't exist
    local directory = string.format("media/textures/%s/premadegroupfinder", theme)
    self:EnsureDirectoryExists(directory)
    
    -- Save the SVG file
    local svgFilePath = string.format("%s/%s.svg", directory, iconName)
    self:SaveFile(svgFilePath, svgContent)
    
    -- Convert to TGA format for WoW
    local tgaFilePath = string.format("%s/%s.tga", directory, iconName)
    self:ConvertSVGToTGA(svgFilePath, tgaFilePath)
end

-- Initialize media
function PGF:InitializeMedia()
    -- Create theme-specific assets
    self:CreateThemeAssets()
    
    -- Register media with LibSharedMedia
    self:RegisterMedia()
end