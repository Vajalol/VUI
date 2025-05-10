-- VUIAnyFrame - PetBar Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register pet action bars
local function RegisterPetActionBars()
    -- Main pet action bar
    if _G["PetActionBarFrame"] then
        VUIAnyFrame:RegisterWidget("PetActionBarFrame", L["Pet Action Bar"], L["Pet UI"])
    end
    
    -- Individual pet action buttons
    for i = 1, 10 do
        local frameName = "PetActionButton" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Pet Action Button"] .. " " .. i, L["Pet UI"])
        end
    end
    
    -- Pet frame itself (portrait)
    if _G["PetFrame"] then
        VUIAnyFrame:RegisterWidget("PetFrame", L["Pet Frame"], L["Pet UI"])
    end
    
    -- Pet casting bar (if separate from player casting bar)
    if _G["PetCastingBarFrame"] then
        VUIAnyFrame:RegisterWidget("PetCastingBarFrame", L["Pet Casting Bar"], L["Pet UI"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterPetActionBars()
end)