-- VUIGfinder Main Wrapper
-- Wraps the original PGFinder code and adds VUI integration

-- Global references
local VUI, VUIGfinderModule
local L = PGFinderLocals; -- Strings

-- Main frame reference
local mainFrame

-- Initialize UI components that need VUI theming
local function InitializeUI()
    -- Main container frame with VUI styling
    mainFrame = CreateFrame("Frame", "VUIGfinderMainFrame", PVEFrame)
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:SetPoint("RIGHT", LFGListFrame.SearchPanel.ResultsInset, "RIGHT", 395, 55)
    mainFrame:SetFrameLevel(800)
    mainFrame:SetSize(400, 300)
    mainFrame:Hide()
    
    -- Apply VUI theme
    ApplyVUITheme()
    
    -- Make frame available to the rest of the addon
    VUIGfinder.mainFrame = mainFrame
    
    -- Initialize the actual PGFinder functionality
    -- This will be a stub that the original Main.lua will call into
    InitializePGFinder(mainFrame)
    
    -- Register slash commands
    SlashCmdList["VUIGFINDER"] = function(msg)
        ToggleVUIGfinder()
    end
    SlashCmdList["PREMADEGROUPFINDER"] = function(msg)
        ToggleVUIGfinder()
    end
end

-- Apply VUI theme to UI elements
function ApplyVUITheme()
    if not mainFrame then return end
    
    -- Get current theme color
    local r, g, b = VUIGfinder.GetThemeColor()
    
    -- Apply to header textures, borders, etc.
    -- This will be expanded as we integrate with specific UI elements
    
    -- Notify the rest of the addon that theme has changed
    if VUIGfinder.OnThemeChanged then
        VUIGfinder.OnThemeChanged(r, g, b)
    end
end

-- This function is called from original Main.lua
function InitializePGFinder(frame)
    -- Set up hooks and modifications
    
    -- Hook into LFG list update to apply our filters
    hooksecurefunc("LFGListSearchPanel_UpdateResults", function(panel)
        VUIGfinder.FilterResults(panel)
    end)
    
    -- More hooks as needed
end

-- Toggle VUIGfinder UI
function ToggleVUIGfinder()
    if not mainFrame then 
        InitializeUI()
    end
    
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- Initialize the addon within VUI's framework
function InitializeVUIGfinder(vui, module)
    VUI = vui
    VUIGfinderModule = module
    
    -- Register with VUI theme system
    VUI:RegisterCallback("OnThemeChanged", function()
        if VUIGfinderModule.db.profile.theme.useVUITheme then
            ApplyVUITheme()
        end
    end)
    
    -- Initialize UI
    InitializeUI()
    
    -- Debug message
    VUI:Debug("VUIGfinder integrated with VUI")
end

-- Make functions available to the addon
VUIGfinder.InitializeVUIGfinder = InitializeVUIGfinder
VUIGfinder.ApplyVUITheme = ApplyVUITheme
VUIGfinder.ToggleVUIGfinder = ToggleVUIGfinder