-------------------------------------------------------------------------------
-- Title: AngryKeystones Media Registration
-- Author: VortexQ8
-- Register AngryKeystones module media with LibSharedMedia
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local AngryKeystones = VUI.angrykeystone
if not AngryKeystones then return end

local LSM = LibStub("LibSharedMedia-3.0")
if not LSM then return end

-- Media categories
local MEDIA_TYPE_BACKGROUND = LSM.MediaType.BACKGROUND
local MEDIA_TYPE_BORDER = LSM.MediaType.BORDER
local MEDIA_TYPE_FONT = LSM.MediaType.FONT
local MEDIA_TYPE_STATUSBAR = LSM.MediaType.STATUSBAR
local MEDIA_TYPE_SOUND = LSM.MediaType.SOUND

-- Register theme-specific AngryKeystones textures
local function RegisterAngryKeystonesMedia()
    -- Register textures for each theme
    local themes = {"phoenixflame", "thunderstorm", "arcanemystic", "felenergy"}
    
    for _, theme in ipairs(themes) do
        -- Register the timer bar texture
        local timerBarPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\angrykeystone\\TimerBar"
        local timerBarName = "VUI:AngryKeystones:" .. theme .. ":TimerBar"
        
        -- Register the progress bar texture
        local progressBarPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\angrykeystone\\ProgressBar"
        local progressBarName = "VUI:AngryKeystones:" .. theme .. ":ProgressBar"
        
        -- Register chest icon texture
        local chestIconPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\angrykeystone\\ChestIcon"
        local chestIconName = "VUI:AngryKeystones:" .. theme .. ":ChestIcon"
        
        -- Register with LSM
        LSM:Register(MEDIA_TYPE_STATUSBAR, timerBarName, timerBarPath)
        LSM:Register(MEDIA_TYPE_STATUSBAR, progressBarName, progressBarPath)
        LSM:Register(MEDIA_TYPE_BACKGROUND, chestIconName, chestIconPath)
        
        -- Register completion sound if it exists
        local completionSoundPath = "Interface\\AddOns\\VUI\\media\\sounds\\" .. theme .. "\\angrykeystone\\completion"
        local completionSoundName = "VUI:AngryKeystones:" .. theme .. ":CompletionSound"
        
        -- Register with LSM
        LSM:Register(MEDIA_TYPE_SOUND, completionSoundName, completionSoundPath)
    end
end

-- Initialize
RegisterAngryKeystonesMedia()