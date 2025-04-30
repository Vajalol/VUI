-------------------------------------------------------------------------------
-- Title: AngryKeystones Media Registration
-- Author: VortexQ8
-- Registers media assets with LibSharedMedia
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI.modules.angrykeystones

-- Skip if AngryKeystones module is not available
if not AK then return end

-- Create the media registration namespace
AK.MediaRegistration = {}
local MediaReg = AK.MediaRegistration

-- Helper function to register textures
function MediaReg:RegisterTextures()
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Register default theme textures
    self:RegisterThemeTextures("thunderstorm")
    
    -- Register other theme textures
    self:RegisterThemeTextures("phoenixflame")
    self:RegisterThemeTextures("arcanemystic")
    self:RegisterThemeTextures("felenergy")
end

-- Register textures for a specific theme
function MediaReg:RegisterThemeTextures(theme)
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Define texture paths
    local texturePath = "Interface\\Addons\\VUI\\media\\textures\\" .. theme .. "\\angrykeystones\\"
    
    -- Register timer bar texture
    local timerBarName = "VUI:AngryKeystones:" .. theme .. ":TimerBar"
    LSM:Register(LSM.MediaType.STATUSBAR, timerBarName, texturePath .. "TimerBar.tga")
    
    -- Register progress bar texture
    local progressBarName = "VUI:AngryKeystones:" .. theme .. ":ProgressBar"
    LSM:Register(LSM.MediaType.STATUSBAR, progressBarName, texturePath .. "ProgressBar.tga")
    
    -- Register objective bar texture
    local objectiveBarName = "VUI:AngryKeystones:" .. theme .. ":ObjectiveBar"
    LSM:Register(LSM.MediaType.STATUSBAR, objectiveBarName, texturePath .. "ObjectiveBar.tga")
end

-- Helper function to register fonts
function MediaReg:RegisterFonts()
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Register theme-specific fonts
    self:RegisterThemeFonts("thunderstorm")
    self:RegisterThemeFonts("phoenixflame")
    self:RegisterThemeFonts("arcanemystic")
    self:RegisterThemeFonts("felenergy")
    
    -- Register generic fonts
    if not LSM:IsValid(LSM.MediaType.FONT, "VUI:AngryKeystones:Font") then
        LSM:Register(LSM.MediaType.FONT, "VUI:AngryKeystones:Font", "Fonts\\FRIZQT__.TTF")
    end
end

-- Register fonts for a specific theme
function MediaReg:RegisterThemeFonts(theme)
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Define font path based on theme
    local fontPath = "Fonts\\FRIZQT__.TTF" -- Default font
    
    -- Theme-specific fonts could be added here
    if theme == "phoenixflame" then
        fontPath = "Fonts\\FRIZQT__.TTF"
    elseif theme == "thunderstorm" then
        fontPath = "Fonts\\FRIZQT__.TTF"
    elseif theme == "arcanemystic" then
        fontPath = "Fonts\\FRIZQT__.TTF"
    elseif theme == "felenergy" then
        fontPath = "Fonts\\FRIZQT__.TTF"
    end
    
    -- Register theme-specific font
    local fontName = "VUI:AngryKeystones:" .. theme .. ":Font"
    LSM:Register(LSM.MediaType.FONT, fontName, fontPath)
end

-- Helper function to register sounds
function MediaReg:RegisterSounds()
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Register theme-specific sounds
    self:RegisterThemeSounds("thunderstorm")
    self:RegisterThemeSounds("phoenixflame")
    self:RegisterThemeSounds("arcanemystic")
    self:RegisterThemeSounds("felenergy")
end

-- Register sounds for a specific theme
function MediaReg:RegisterThemeSounds(theme)
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Define sound path based on theme
    local soundPath = "Interface\\Addons\\VUI\\media\\sounds\\" .. theme .. "\\angrykeystones\\"
    
    -- Register timer sounds
    local soundNames = {
        "TimerOnTrack",
        "TimerWarning",
        "TimerSuccess",
        "TimerFailure"
    }
    
    -- Map to actual sound files based on theme
    local soundFiles = {
        ["thunderstorm"] = {
            ["TimerOnTrack"] = "Interface\\AddOns\\VUI\\media\\sounds\\on_track.ogg",
            ["TimerWarning"] = "Interface\\AddOns\\VUI\\media\\sounds\\warning.ogg",
            ["TimerSuccess"] = "Interface\\AddOns\\VUI\\media\\sounds\\success.ogg",
            ["TimerFailure"] = "Interface\\AddOns\\VUI\\media\\sounds\\failure.ogg"
        },
        ["phoenixflame"] = {
            ["TimerOnTrack"] = "Interface\\AddOns\\VUI\\media\\sounds\\on_track.ogg",
            ["TimerWarning"] = "Interface\\AddOns\\VUI\\media\\sounds\\warning.ogg",
            ["TimerSuccess"] = "Interface\\AddOns\\VUI\\media\\sounds\\success.ogg",
            ["TimerFailure"] = "Interface\\AddOns\\VUI\\media\\sounds\\failure.ogg"
        },
        ["arcanemystic"] = {
            ["TimerOnTrack"] = "Interface\\AddOns\\VUI\\media\\sounds\\on_track.ogg",
            ["TimerWarning"] = "Interface\\AddOns\\VUI\\media\\sounds\\warning.ogg",
            ["TimerSuccess"] = "Interface\\AddOns\\VUI\\media\\sounds\\success.ogg",
            ["TimerFailure"] = "Interface\\AddOns\\VUI\\media\\sounds\\failure.ogg"
        },
        ["felenergy"] = {
            ["TimerOnTrack"] = "Interface\\AddOns\\VUI\\media\\sounds\\on_track.ogg",
            ["TimerWarning"] = "Interface\\AddOns\\VUI\\media\\sounds\\warning.ogg",
            ["TimerSuccess"] = "Interface\\AddOns\\VUI\\media\\sounds\\success.ogg",
            ["TimerFailure"] = "Interface\\AddOns\\VUI\\media\\sounds\\failure.ogg"
        }
    }
    
    -- Register each sound
    for _, soundName in ipairs(soundNames) do
        local fullName = "VUI:AngryKeystones:" .. theme .. ":" .. soundName
        
        if soundFiles[theme] and soundFiles[theme][soundName] then
            LSM:Register(LSM.MediaType.SOUND, fullName, soundFiles[theme][soundName])
        else
            -- Fallback to generic sounds
            local fallbackSound = "Interface\\AddOns\\VUI\\media\\sounds\\" .. soundName .. ".ogg"
            LSM:Register(LSM.MediaType.SOUND, fullName, fallbackSound)
        end
    end
    
    -- Register generic sounds as well
    for _, soundName in ipairs(soundNames) do
        local genericName = "VUI:AngryKeystones:" .. soundName
        if not LSM:IsValid(LSM.MediaType.SOUND, genericName) then
            local fallbackSound = "Interface\\AddOns\\VUI\\media\\sounds\\" .. soundName .. ".ogg"
            LSM:Register(LSM.MediaType.SOUND, genericName, fallbackSound)
        end
    end
end

-- Convert SVG to TGA format for WoW
function MediaReg:ConvertSVGtoTGA()
    -- List of textures to convert
    local textures = {
        "TimerBar",
        "ProgressBar",
        "ObjectiveBar"
    }
    
    -- List of themes
    local themes = {
        "thunderstorm",
        "phoenixflame",
        "arcanemystic",
        "felenergy"
    }
    
    -- In a real implementation, we would use a library to convert SVG to TGA
    -- Since we can't do that in-game, we'll just assume the TGA files will be present at load time
    -- This function is here as a placeholder for the conversion process
    
    print("VUI: SVG textures for AngryKeystones would be converted to TGA format here in a real implementation.")
end

-- Initialize media registration
function MediaReg:Initialize()
    -- Register all media types
    self:RegisterTextures()
    self:RegisterFonts()
    self:RegisterSounds()
    
    -- Convert SVG to TGA for WoW compatibility
    self:ConvertSVGtoTGA()
end

-- Call Initialize when the module loads
AK:RegisterEvent("PLAYER_LOGIN", function()
    MediaReg:Initialize()
end)