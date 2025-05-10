-- VUIAnyFrame - BagBar Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register bag frames
local function RegisterBagFrames()
    -- Main bag bar
    if _G["MicroButtonAndBagsBar"] then
        VUIAnyFrame:RegisterWidget("MicroButtonAndBagsBar", L["Bag Bar"], L["Bags"])
    end
    
    -- Individual bag slots
    for i = 0, 4 do
        local frameName = "CharacterBag" .. i .. "Slot"
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Bag Slot"] .. " " .. i, L["Bags"])
        end
    end
    
    -- Main/Backpack slot
    if _G["MainMenuBarBackpackButton"] then
        VUIAnyFrame:RegisterWidget("MainMenuBarBackpackButton", L["Backpack"], L["Bags"])
    end
    
    -- Keyring button (if exists in this client version)
    if _G["KeyRingButton"] then
        VUIAnyFrame:RegisterWidget("KeyRingButton", L["Key Ring"], L["Bags"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterBagFrames()
end)