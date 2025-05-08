-- VUIAnyFrame - ActionBars Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register action bar frames
local function RegisterActionBars()
    -- Main action bar (bottom bar)
    VUIAnyFrame:RegisterWidget("MainMenuBar", L["Main Menu Bar"], L["Action Bars"])
    
    -- Additional action bars
    for i = 1, 6 do
        local barName = "MultiBarBottomLeft"
        if i == 2 then barName = "MultiBarBottomRight" 
        elseif i == 3 then barName = "MultiBarRight" 
        elseif i == 4 then barName = "MultiBarLeft" 
        elseif i == 5 then barName = "MultiBar5" 
        elseif i == 6 then barName = "MultiBar6" end
        
        if _G[barName] then
            VUIAnyFrame:RegisterWidget(barName, L["Action Bar"] .. " " .. i, L["Action Bars"])
        end
    end
    
    -- Pet action bar
    if _G["PetActionBar"] then
        VUIAnyFrame:RegisterWidget("PetActionBar", L["Pet Action Bar"], L["Action Bars"])
    end
    
    -- Stance bar
    if _G["StanceBar"] then
        VUIAnyFrame:RegisterWidget("StanceBar", L["Stance Bar"], L["Action Bars"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterActionBars()
end)