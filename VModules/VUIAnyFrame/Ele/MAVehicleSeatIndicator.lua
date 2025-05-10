-- VUIAnyFrame - Vehicle Seat Indicator Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register vehicle seat indicator frames
local function RegisterVehicleSeatFrames()
    -- Main vehicle seat indicator frame
    if _G["VehicleSeatIndicator"] then
        VUIAnyFrame:RegisterWidget("VehicleSeatIndicator", L["Vehicle Seat Indicator"], L["Vehicle UI"])
    end
    
    -- Vehicle UI (may exist in some client versions)
    if _G["VehicleMenuBar"] then
        VUIAnyFrame:RegisterWidget("VehicleMenuBar", L["Vehicle Menu Bar"], L["Vehicle UI"])
    end
    
    -- Vehicle ability buttons (may exist depending on client version)
    for i = 1, 6 do
        local frameName = "VehicleActionButton" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Vehicle Button"] .. " " .. i, L["Vehicle UI"])
        end
    end
    
    -- Check for vehicle leave button as well
    if _G["VehicleExitButton"] then
        VUIAnyFrame:RegisterWidget("VehicleExitButton", L["Vehicle Exit Button"], L["Vehicle UI"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterVehicleSeatFrames()
end)