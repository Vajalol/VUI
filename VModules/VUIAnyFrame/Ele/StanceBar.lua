-- VUIAnyFrame - StanceBar Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register stance bars (shapeshifting, stances, etc.)
local function RegisterStanceBars()
    -- Main stance bar frame
    if _G["StanceBarFrame"] then
        VUIAnyFrame:RegisterWidget("StanceBarFrame", L["Stance Bar"], L["Class Bars"])
    end
    
    -- Modern UI in some clients might use this name
    if _G["ShapeshiftBarFrame"] then
        VUIAnyFrame:RegisterWidget("ShapeshiftBarFrame", L["Stance Bar"], L["Class Bars"])
    end
    
    -- Individual stance buttons
    for i = 1, 10 do
        local frameName = "StanceButton" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Stance Button"] .. " " .. i, L["Class Bars"])
        end
        
        -- Check for ShapeshiftButton name as well (used in some client versions)
        local shiftFrameName = "ShapeshiftButton" .. i
        if _G[shiftFrameName] then
            VUIAnyFrame:RegisterWidget(shiftFrameName, L["Shapeshift Button"] .. " " .. i, L["Class Bars"])
        end
    end
    
    -- Check for possessbar too
    if _G["PossessBarFrame"] then
        VUIAnyFrame:RegisterWidget("PossessBarFrame", L["Possess Bar"], L["Class Bars"])
    end
    
    -- Individual possess buttons
    for i = 1, 2 do
        local frameName = "PossessButton" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Possess Button"] .. " " .. i, L["Class Bars"])
        end
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterStanceBars()
end)