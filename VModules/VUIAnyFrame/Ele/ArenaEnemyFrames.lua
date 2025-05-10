-- VUIAnyFrame - ArenaEnemyFrames Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register arena enemy frames
local function RegisterArenaEnemyFrames()
    -- Main arena frame
    if _G["ArenaEnemyFrames"] then
        VUIAnyFrame:RegisterWidget("ArenaEnemyFrames", L["Arena Enemy Frames"], L["Unit Frames"])
    end
    
    -- Individual arena frames
    for i = 1, 5 do
        local frameName = "ArenaEnemyFrame" .. i
        if _G[frameName] then
            VUIAnyFrame:RegisterWidget(frameName, L["Arena Enemy"] .. " " .. i, L["Unit Frames"])
        end
    end
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterArenaEnemyFrames()
end)