-- VUIAnyFrame - Media path handler
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Media paths
local MEDIA_PATH = "Interface\\AddOns\\VUI\\media\\modules\\VUIAnyFrame\\"

-- Function to get media file path
function VUIAnyFrame:GetMediaPath(mediaType, fileName)
    if mediaType == "Icons" or mediaType == "Icon" then
        return MEDIA_PATH .. "textures\\icon_anyframe.svg"
    elseif mediaType == "Textures" or mediaType == "Texture" then
        return MEDIA_PATH .. "textures\\" .. fileName
    elseif mediaType == "Fonts" or mediaType == "Font" then
        return MEDIA_PATH .. "fonts\\" .. fileName
    elseif mediaType == "Sounds" or mediaType == "Sound" then
        return MEDIA_PATH .. "sounds\\" .. fileName
    else
        -- Default case
        return MEDIA_PATH .. mediaType .. "\\" .. (fileName or "")
    end
end