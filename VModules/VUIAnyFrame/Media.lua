-- VUIAnyFrame - Media Definitions
local AddonName, VUI = ...
local M = _G["VUIAnyFrame"]
local L = M.L

-- Define media paths
M.MEDIA = {
    ICON = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\icon",
    GRID10 = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\grid_10",
    GRID20 = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\grid_20",
    GRID40 = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\grid_40",
}

-- Function to get media path
function M:GetMedia(key)
    if not key or not M.MEDIA[key] then
        return nil
    end
    return M.MEDIA[key]
end

-- Function to create basic grid textures if they don't exist
function M:CreateGridTextures()
    -- Create media directory if it doesn't exist
    local mediaDir = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media"
    
    -- Use LibPixelPerfect if available
    if LibStub and LibStub("LibPixelPerfect-1.0", true) then
        local LPP = LibStub("LibPixelPerfect-1.0")
        -- LPP can generate grid textures
        return
    end
    
    -- Otherwise, we'll create grid textures dynamically when needed
    -- using the code in UpdateGrid() function
end 