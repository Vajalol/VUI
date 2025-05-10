-- VUIAnyFrame - PartyFrame Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register party frames
local function RegisterPartyFrames()
    -- Main party frame container
    if _G["PartyFrame"] then
        VUIAnyFrame:RegisterWidget("PartyFrame", L["Party Frame"], L["Unit Frames"])
    end
    
    -- Individual party member frames
    for i = 1, 4 do
        local frameName = "PartyMemberFrame" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Party Member"] .. " " .. i, L["Unit Frames"])
        end
    end
    
    -- Party pet frames
    for i = 1, 4 do
        local frameName = "PartyMemberFrame" .. i .. "PetFrame"
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Party Pet"] .. " " .. i, L["Unit Frames"])
        end
    end
    
    -- Party target frames (if they exist in the client version)
    for i = 1, 4 do
        local frameName = "PartyMemberFrame" .. i .. "TargetFrame"
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Party Target"] .. " " .. i, L["Unit Frames"])
        end
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterPartyFrames()
end)