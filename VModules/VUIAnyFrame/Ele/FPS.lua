-- VUIAnyFrame - FPS Element
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Register FPS and latency frames
local function RegisterPerformanceFrames()
    -- Main FPS frame (this might be different depending on client version)
    if _G["FramerateFrame"] then
        VUIAnyFrame:RegisterWidget("FramerateFrame", L["FPS Display"], L["Performance"])
    end
    
    -- Latency display (this might be integrated with FPS or separate depending on client version)
    if _G["MainMenuBarPerformanceBar"] then
        VUIAnyFrame:RegisterWidget("MainMenuBarPerformanceBar", L["Latency Display"], L["Performance"])
    end
    
    -- In modern clients, there's a combined performance button
    if _G["MainMenuBarPerformanceButton"] then
        VUIAnyFrame:RegisterWidget("MainMenuBarPerformanceButton", L["Performance Button"], L["Performance"])
    end
    
    -- If addon managers like addon usage displays are present, add them here
    -- This varies by client version and user addons
end

-- Register this on PLAYER_LOGIN to ensure all frames exist
VUIAnyFrame:RegisterEvent("PLAYER_LOGIN", function()
    RegisterPerformanceFrames()
end)