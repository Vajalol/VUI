-- VUIAnyFrame - DebuffBar Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register debuff frames
local function RegisterDebuffFrames()
    -- Main debuff frame
    if _G["DebuffFrame"] then
        VUIAnyFrame:RegisterWidget("DebuffFrame", L["Debuff Frame"], L["Debuffs"])
    end
    
    -- In some versions, buffs and debuffs share the same frame but with different anchors
    -- Check for any debuff-specific movers
    if _G["PlayerDebuffsMover"] then
        VUIAnyFrame:RegisterWidget("PlayerDebuffsMover", L["Player Debuffs"], L["Debuffs"])
    end
    
    -- If DebuffFrame doesn't exist, BuffFrame might handle both
    if not _G["DebuffFrame"] and _G["BuffFrame"] then
        -- Check if we've already registered BuffFrame in the BuffBar module
        -- If not, register it here
        local registered = false
        for _, info in pairs(VUIAnyFrame:GetRegisteredWidgets()) do
            if info.frame == _G["BuffFrame"] then
                registered = true
                break
            end
        end
        
        if not registered then
            VUIAnyFrame:RegisterWidget("BuffFrame", L["Buff & Debuff Frame"], L["Debuffs"])
        end
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterDebuffFrames()
end)