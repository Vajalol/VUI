-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Media
-- Author: Vortex-WoW
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local ST = VUI.ScrollingText
if not ST then return end

-- Paths
local FONT_PATH = "Interface\\AddOns\\VUI\\VModules\\VUIScrollingText\\fonts\\"
local SOUND_PATH = "Interface\\AddOns\\VUI\\VModules\\VUIScrollingText\\sounds\\"

-- Fonts table
local AVAILABLE_FONTS = {
    ["Adventure"] = FONT_PATH .. "adventure.ttf",
    ["Bazooka"] = FONT_PATH .. "bazooka.ttf",
    ["Cooline"] = FONT_PATH .. "cooline.ttf",
    ["Diogenes"] = FONT_PATH .. "diogenes.ttf",
    ["Diediedie"] = FONT_PATH .. "diediedie.ttf",
    ["Ginko"] = FONT_PATH .. "ginko.ttf",
    ["Heroic"] = FONT_PATH .. "heroic.ttf",
    ["Porky"] = FONT_PATH .. "porky.ttf",
    ["Talisman"] = FONT_PATH .. "talisman.ttf",
    ["Transformers"] = FONT_PATH .. "transformers.ttf",
    ["YellowJacket"] = FONT_PATH .. "yellowjacket.ttf",
    -- Include game fonts
    ["Friz Quadrata TT"] = GameFontNormal:GetFont(),
    ["Arial Narrow"] = "Fonts\\ARIALN.TTF",
    ["Skurri"] = "Fonts\\SKURRI.TTF",
}

-- Default font
local DEFAULT_FONT = "Friz Quadrata TT"

-- Outlines table
local AVAILABLE_OUTLINES = {
    ["None"] = "",
    ["Thin"] = "OUTLINE",
    ["Thick"] = "THICKOUTLINE",
    ["Monochrome"] = "MONOCHROME",
    ["Thin, Monochrome"] = "OUTLINE,MONOCHROME",
    ["Thick, Monochrome"] = "THICKOUTLINE,MONOCHROME",
}

-- Default outline
local DEFAULT_OUTLINE = "None"

-- Sounds table
local AVAILABLE_SOUNDS = {
    ["None"] = nil,
    ["Cooldown"] = SOUND_PATH .. "Cooldown.ogg",
    ["Low Health"] = SOUND_PATH .. "LowHealth.ogg",
    ["Low Mana"] = SOUND_PATH .. "LowMana.ogg",
}

-- Default sound
local DEFAULT_SOUND = "None"

-- LSM integration if available
local LSM = nil
if LibStub then
    LSM = LibStub:GetLibrary("LibSharedMedia-3.0", true)
    if LSM then
        -- Register our fonts with LSM
        for name, path in pairs(AVAILABLE_FONTS) do
            LSM:Register("font", name, path)
        end
        
        -- Register our sounds with LSM
        for name, path in pairs(AVAILABLE_SOUNDS) do
            if path then
                LSM:Register("sound", name, path)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------------

-- Get a font path by name
local function GetFontPath(fontName)
    return AVAILABLE_FONTS[fontName] or AVAILABLE_FONTS[DEFAULT_FONT]
end

-- Get a list of available fonts
local function GetAvailableFonts()
    local fonts = {}
    for name in pairs(AVAILABLE_FONTS) do
        table.insert(fonts, name)
    end
    table.sort(fonts)
    return fonts
end

-- Get an outline by index
local function GetOutlineByIndex(outlineIndex)
    local outlines = GetAvailableOutlines()
    local name = outlines[outlineIndex] or DEFAULT_OUTLINE
    return AVAILABLE_OUTLINES[name]
end

-- Get an outline index by name
local function GetOutlineIndex(outlineName)
    local outlines = GetAvailableOutlines()
    for i, name in ipairs(outlines) do
        if name == outlineName then
            return i
        end
    end
    return 1 -- Default to first outline
end

-- Get a list of available outlines
local function GetAvailableOutlines()
    local outlines = {}
    for name in pairs(AVAILABLE_OUTLINES) do
        table.insert(outlines, name)
    end
    table.sort(outlines)
    return outlines
end

-- Get a sound path by name
local function GetSoundPath(soundName)
    if soundName == "None" then return nil end
    return AVAILABLE_SOUNDS[soundName]
end

-- Get a list of available sounds
local function GetAvailableSounds()
    local sounds = {}
    for name in pairs(AVAILABLE_SOUNDS) do
        table.insert(sounds, name)
    end
    table.sort(sounds)
    return sounds
end

-- Play a sound
local function PlaySound(soundName)
    local path = GetSoundPath(soundName)
    if path then
        PlaySoundFile(path, "Master")
    end
end

-- Get VUI theme color
local function GetThemeColor()
    if VUI then
        local color = VUI:GetThemeColor()
        return color.r, color.g, color.b
    else
        return 0, 0.44, 0.87 -- Default VUI blue
    end
end

-- Register a custom font
local function RegisterFont(name, path)
    if not name or not path then return false end
    
    AVAILABLE_FONTS[name] = path
    
    -- Register with LSM if available
    if LSM then
        LSM:Register("font", name, path)
    end
    
    return true
end

-- Register a custom sound
local function RegisterSound(name, path)
    if not name or not path then return false end
    
    AVAILABLE_SOUNDS[name] = path
    
    -- Register with LSM if available
    if LSM then
        LSM:Register("sound", name, path)
    end
    
    return true
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Module public interface
ST.Media = {
    GetFontPath = GetFontPath,
    GetAvailableFonts = GetAvailableFonts,
    GetOutlineByIndex = GetOutlineByIndex,
    GetOutlineIndex = GetOutlineIndex,
    GetAvailableOutlines = GetAvailableOutlines,
    GetSoundPath = GetSoundPath,
    GetAvailableSounds = GetAvailableSounds,
    PlaySound = PlaySound,
    GetThemeColor = GetThemeColor,
    RegisterFont = RegisterFont,
    RegisterSound = RegisterSound,
}