-- VUIAnyFrame - Minimap Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register Minimap and related frames
local function RegisterMinimapFrames()
    -- Main minimap frame
    if _G["Minimap"] then
        VUIAnyFrame:RegisterWidget("Minimap", L["Minimap"], L["UI Elements"])
    end
    
    -- MinimapCluster (the entire minimap area including buttons)
    if _G["MinimapCluster"] then
        VUIAnyFrame:RegisterWidget("MinimapCluster", L["Minimap Cluster"], L["UI Elements"])
    end
    
    -- Additional minimap elements
    local minimapElements = {
        "MinimapZoneTextButton",
        "MinimapBorderTop",
        "MiniMapTracking",
        "GameTimeFrame",
        "MinimapZoomIn",
        "MinimapZoomOut"
    }
    
    for _, elementName in ipairs(minimapElements) do
        if _G[elementName] then
            VUIAnyFrame:RegisterWidget(elementName, elementName, L["Minimap"])
        end
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterMinimapFrames()
end)