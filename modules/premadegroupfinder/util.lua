-- VUI Premade Group Finder Module - Utility Functions
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local PGF = VUI.premadegroupfinder

-- Create directories if they don't exist
function PGF:EnsureDirectoryExists(path)
    -- In WoW, we can't directly create directories, so this is a helper for development
    -- In the actual addon, directories should be pre-created in the package
    if CreateDirectory then -- Only available in development environment
        CreateDirectory(path)
    end
end

-- Save file to disk (development only function)
function PGF:SaveFile(filePath, content)
    -- This is a development-only function used to generate assets
    -- In the actual addon, all files should be pre-generated and included in the package
    if WriteFile then -- Only available in development environment
        WriteFile(filePath, content)
        return true
    end
    return false
end

-- Convert SVG to TGA (development only function)
function PGF:ConvertSVGToTGA(svgPath, tgaPath)
    -- This is a development-only function
    -- In the actual addon, SVG files should be pre-converted to TGA format
    -- since WoW client doesn't support loading SVG files
    if ConvertImage then -- Only available in development environment
        ConvertImage(svgPath, tgaPath)
        return true
    end
    return false
end

-- Get the path to a media file for the specific theme
function PGF:GetThemeMediaPath(theme, category, filename)
    return string.format("Interface\\AddOns\\VUI\\media\\textures\\%s\\%s\\%s", theme, category, filename)
end

-- Check if an asset exists
function PGF:AssetExists(path)
    -- In WoW, we can check if a texture exists by attempting to load it
    local texture = CreateFrame("Frame"):CreateTexture()
    local success = pcall(function() texture:SetTexture(path) end)
    texture:SetTexture(nil)
    return success
end

-- Get appropriate asset based on theme
function PGF:GetAssetPath(theme, category, name)
    local specificPath = self:GetThemeMediaPath(theme, category, name)
    
    -- Check if theme-specific asset exists, otherwise use default
    if self:AssetExists(specificPath) then
        return specificPath
    else
        -- Fallback to default asset
        return string.format("Interface\\AddOns\\VUI\\media\\icons\\%s\\%s", category, name)
    end
end