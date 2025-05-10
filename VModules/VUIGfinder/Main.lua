-- VUIGfinder Main (based on PGFinder)
local L = PGFinderLocals; -- Strings

-- Frame for theme elements to register
local themeElements = {}

-- Main frame reference - will be populated by MainWrapper.lua
local f 

--[[
    Cache all of the global functions that are heavily used to improve performance
]]

local LFGListFrame = LFGListFrame;
local PVEFrame = PVEFrame;

local LFGListSearchPanel_UpdateResults = LFGListSearchPanel_UpdateResults;
local LFGListGroupDataDisplay_Update = LFGListGroupDataDisplay_Update;
local GetAchievementInfo = GetAchievementInfo;
local GetAchievementLink = GetAchievementLink;
local IsInGroup = IsInGroup;
local UnitIsGroupLeader = UnitIsGroupLeader;
local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
local GetSpecialization = GetSpecialization;
local GetSpecializationRole = GetSpecializationRole;
local GetSpecializationInfoByID = GetSpecializationInfoByID;
local GetNumGroupMembers = GetNumGroupMembers;
local GetTimePreciseSec = GetTimePreciseSec;
local ClearAllPoints = ClearAllPoints;
local SetSize = SetSize;
local SetPoint = SetPoint;
local SetText = SetText;
local SetScript = SetScript;
local SetTexture = SetTexture;
local SetJustifyH = SetJustifyH;
local SetAtlas = SetAtlas;
local SetTextColor = SetTextColor;
local SetAlpha = SetAlpha;
local GetParent = GetParent
local SetDesaturated = SetDesaturated;
local SetTexCoord = SetTexCoord;
local SetShown = SetShown;
local GetWidth = GetWidth;
local GetHeight = GetHeight;
local GetPoint = GetPoint;

-- Local variables
local refreshButtonTimer = nil;
local isRefreshEnabled = true;
local allActivityKeys = {}
local expandedActivityList = {}
local activityToID = {}
local activityToID2 = {}
local idToActivity = {}
local activityIndex = {}
local dungeons = {}
local raids = {}
local pvp = {}
local other = {}

-- Texture paths updated for VUI
local texturePrefix = "Interface\\AddOns\\VUI\\VModules\\VUIGfinder\\Media\\Icons\\"

-- Initialize PGFinder
function InitializePGFinder(parentFrame)
    f = parentFrame or VUIGfinder.mainFrame
    if not f then
        -- Create a fallback frame if needed
        f = CreateFrame("Frame", "VUIGfinderMainFrame", PVEFrame)
        f:SetFrameStrata("HIGH")
        f:SetPoint("RIGHT", LFGListFrame.SearchPanel.ResultsInset, "RIGHT", 395, 55)
        f:SetFrameLevel(800)
        f:SetSize(400, 300)
        f:Hide()
    end
    
    -- Set up main UI elements
    CreateMainUI()
    
    -- Hook into the group finder
    HookGroupFinder()
    
    -- Register slash commands
    RegisterSlashCommands()
    
    -- Setup minimap button
    CreateMinimapButton()
end

-- Create main UI elements
function CreateMainUI()
    -- Header
    local header = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -15)
    header:SetText(L.OPTIONS_TITLE)
    
    -- Register with theme system
    if VUIGfinder.RegisterThemeElement then
        VUIGfinder.RegisterThemeElement(header)
    end
    
    -- Create the rest of the UI elements here
    -- (This will be a simplified version for now, to be expanded)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    
    -- Apply VUI theme to UI elements
    ApplyVUIThemeToElements()
end

-- Apply VUI theme to UI elements
function ApplyVUIThemeToElements()
    -- Get current theme color if available
    local r, g, b = 0.0, 0.44, 0.87 -- Default color
    if VUIGfinder.GetThemeColor then
        r, g, b = VUIGfinder.GetThemeColor()
    end
    
    -- Apply theme to elements
    for _, element in ipairs(themeElements) do
        if element.SetTextColor then
            element:SetTextColor(r, g, b, 1)
        elseif element.SetColorTexture then
            element:SetColorTexture(r, g, b, 1)
        elseif element.SetVertexColor then
            element:SetVertexColor(r, g, b, 1)
        end
    end
end

-- Register an element for theme coloring
function RegisterThemeElement(element)
    if element then
        table.insert(themeElements, element)
        -- Apply theme immediately
        if element.SetTextColor then
            local r, g, b = VUIGfinder.GetThemeColor()
            element:SetTextColor(r, g, b, 1)
        end
    end
end

-- Hook into the group finder
function HookGroupFinder()
    -- Hook search results to apply our filter
    hooksecurefunc("LFGListSearchPanel_UpdateResults", FilterResults)
    
    -- Hook other functions as needed
end

-- Filter search results
function FilterResults(panel)
    -- Implementation of filtering logic
    -- This will be expanded
end

-- Register slash commands
function RegisterSlashCommands()
    -- These are registered in the wrapper
end

-- Create minimap button
function CreateMinimapButton()
    -- Create a minimap button for easy access
    -- This will be expanded
end

-- Make functions available to wrapper
VUIGfinder.FilterResults = FilterResults
VUIGfinder.InitializeMainUI = CreateMainUI
VUIGfinder.RegisterThemeElement = RegisterThemeElement
VUIGfinder.ApplyVUIThemeToElements = ApplyVUIThemeToElements

-- Function to respond to theme changes
VUIGfinder.OnThemeChanged = function(r, g, b)
    ApplyVUIThemeToElements()
end