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
    -- Safety check for frame
    if not mainFrame then return end
    
    -- Get current theme color with safety check
    local r, g, b = 0.0, 0.44, 0.87 -- Default VUI blue color
    if VUIGfinder and VUIGfinder.GetThemeColor and type(VUIGfinder.GetThemeColor) == "function" then
        -- Use pcall to prevent errors if the function fails
        local success, result = pcall(VUIGfinder.GetThemeColor)
        if success and result then
            r, g, b = result, select(2, result), select(3, result)
        end
    end
    
    -- Apply to header textures, borders, etc.
    -- This will be expanded as we integrate with specific UI elements
    
    -- Notify the rest of the addon that theme has changed with safety check
    if VUIGfinder and VUIGfinder.OnThemeChanged and type(VUIGfinder.OnThemeChanged) == "function" then
        pcall(function() VUIGfinder.OnThemeChanged(r, g, b) end)
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
    
    -- Register with VUI theme system with safety checks
    if VUI and VUI.RegisterCallback and type(VUI.RegisterCallback) == "function" then
        pcall(function()
            VUI:RegisterCallback("OnThemeChanged", function()
                -- Add safety check for module
                if VUIGfinderModule and VUIGfinderModule.db and 
                   VUIGfinderModule.db.profile and 
                   VUIGfinderModule.db.profile.theme and 
                   VUIGfinderModule.db.profile.theme.useVUITheme then
                    -- Call theme function safely
                    if ApplyVUITheme then
                        pcall(ApplyVUITheme)
                    end
                end
            end)
        end)
    end
    
    -- Initialize UI
    if InitializeUI then
        pcall(InitializeUI)
    end
    
    -- Debug message with safety check
    if VUI and VUI.Debug and type(VUI.Debug) == "function" then
        pcall(function() VUI:Debug("VUIGfinder integrated with VUI") end)
    end
end

-- Make functions available to the addon
VUIGfinder.InitializeVUIGfinder = InitializeVUIGfinder
VUIGfinder.ApplyVUITheme = ApplyVUITheme
VUIGfinder.ToggleVUIGfinder = ToggleVUIGfinder