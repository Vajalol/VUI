-- VUIAnyFrame - MicroMenu Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register MicroMenu frames
local function RegisterMicroMenuFrames()
    -- The main micro menu frame
    if _G["MicroButtonAndBagsBar"] then
        VUIAnyFrame:RegisterWidget("MicroButtonAndBagsBar", L["Micro Menu"], L["UI Elements"])
    end
    
    -- Individual micro menu buttons
    local microButtons = {
        "CharacterMicroButton",
        "SpellbookMicroButton",
        "TalentMicroButton",
        "AchievementMicroButton",
        "QuestLogMicroButton",
        "GuildMicroButton",
        "LFDMicroButton",
        "CollectionsMicroButton",
        "EJMicroButton",
        "StoreMicroButton",
        "MainMenuMicroButton"
    }
    
    for _, buttonName in ipairs(microButtons) do
        if _G[buttonName] then
            local displayName = buttonName:gsub("MicroButton", "")
            VUIAnyFrame:RegisterWidget(buttonName, displayName .. " " .. L["Button"], L["Micro Menu"])
        end
    end
    
    -- Bags bar (right side of micro menu)
    if _G["BagsBar"] then
        VUIAnyFrame:RegisterWidget("BagsBar", L["Bags Bar"], L["UI Elements"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterMicroMenuFrames()
end)