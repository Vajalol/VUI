-- VUIAnyFrame - BuffBar Element
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIAnyFrame = _G["VUIAnyFrame"]
local L = VUIAnyFrame.L

-- Register buff frames
local function RegisterBuffFrames()
    -- Main buff frame
    if _G["BuffFrame"] then
        VUIAnyFrame:RegisterWidget("BuffFrame", L["Buff Frame"], L["Buffs"])
    end
    
    -- Individual buff containers (if they exist as separate frames)
    if _G["PlayerBuffsMover"] then
        VUIAnyFrame:RegisterWidget("PlayerBuffsMover", L["Player Buffs"], L["Buffs"])
    end
    
    -- Temp Enchant frames
    if _G["TemporaryEnchantFrame"] then
        VUIAnyFrame:RegisterWidget("TemporaryEnchantFrame", L["Weapon Enchants"], L["Buffs"])
    end
    
    -- Consolidated buffs container (if it exists in this client version)
    if _G["ConsolidatedBuffsContainer"] then
        VUIAnyFrame:RegisterWidget("ConsolidatedBuffsContainer", L["Consolidated Buffs"], L["Buffs"])
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterBuffFrames()
end)