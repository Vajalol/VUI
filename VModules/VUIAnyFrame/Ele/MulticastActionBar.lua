-- VUIAnyFrame - MulticastActionBar Element (Totem Bar)
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register multicast action bar (totem bar for shamans)
local function RegisterMulticastActionBar()
    -- Main multicast (totem) action bar
    if _G["MultiCastActionBarFrame"] then
        VUIAnyFrame:RegisterWidget("MultiCastActionBarFrame", L["Totem Bar"], L["Class Bars"])
    end
    
    -- Check for newer spell bar
    if _G["MultiBarBottomLeftExtraActionBarFrame"] then
        VUIAnyFrame:RegisterWidget("MultiBarBottomLeftExtraActionBarFrame", L["Extra Action Bar"], L["Class Bars"])
    end
    
    -- Individual multicast buttons (they might exist in some client versions)
    for i = 1, 4 do
        local frameName = "MultiCastSlotButton" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Totem Slot"] .. " " .. i, L["Class Bars"])
        end
    end
    
    -- Check for MultiCastSummonSpellButton
    if _G["MultiCastSummonSpellButton"] then
        VUIAnyFrame:RegisterWidget("MultiCastSummonSpellButton", L["Summon Totems Button"], L["Class Bars"])
    end
    
    -- Check for MultiCastRecallSpellButton
    if _G["MultiCastRecallSpellButton"] then
        VUIAnyFrame:RegisterWidget("MultiCastRecallSpellButton", L["Recall Totems Button"], L["Class Bars"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterMulticastActionBar()
end)