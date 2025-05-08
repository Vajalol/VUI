-- VUIKeystones - Media path handler
local VUIKeystones = LibStub("AceAddon-3.0"):GetAddon("VUIKeystones")
local L = VUIKeystones.L

-- Media paths
local MEDIA_PATH = "Interface\\AddOns\\VUI\\media\\modules\\VUIKeystones\\"

-- Function to get media file path
function VUIKeystones:GetMediaPath(mediaType, fileName)
    if mediaType == "Icons" or mediaType == "Icon" then
        return MEDIA_PATH .. "textures\\icon_keystones.svg"
    elseif mediaType == "Textures" or mediaType == "Texture" then
        return MEDIA_PATH .. "textures\\" .. (fileName or "")
    elseif mediaType == "Bar" then
        return MEDIA_PATH .. "textures\\bar.blp"
    elseif mediaType == "Fonts" or mediaType == "Font" then
        return MEDIA_PATH .. "fonts\\" .. (fileName or "")
    elseif mediaType == "Sounds" or mediaType == "Sound" then
        return MEDIA_PATH .. "sounds\\" .. (fileName or "")
    else
        -- Default case
        return MEDIA_PATH .. mediaType .. "\\" .. (fileName or "")
    end
end