-- VUIKeystones - Media path handler
<<<<<<< HEAD
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIKeystones = _G["VUIKeystones"]
local L = VUIKeystones.L or {}
=======
local VUIKeystones = _G.VUIKeystones or {}
local L = VUIKeystones.L
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

-- Media paths
local MEDIA_PATH = "Interface\\AddOns\\VUI\\Media\\modules\\VUIKeystones\\"

-- Function to get media file path
function VUIKeystones:GetMediaPath(mediaType, fileName)
    if mediaType == "Icons" or mediaType == "Icon" then
        return "Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm.tga"
    elseif mediaType == "Textures" or mediaType == "Texture" then
        return MEDIA_PATH .. "textures\\" .. (fileName or "")
    elseif mediaType == "Bar" then
        return "Interface\\AddOns\\VUI\\VModules\\VUIKeystones\\bar.blp"
    elseif mediaType == "Fonts" or mediaType == "Font" then
        return MEDIA_PATH .. "fonts\\" .. (fileName or "")
    elseif mediaType == "Sounds" or mediaType == "Sound" then
        return MEDIA_PATH .. "sounds\\" .. (fileName or "")
    else
        -- Default case
        return MEDIA_PATH .. mediaType .. "\\" .. (fileName or "")
    end
end