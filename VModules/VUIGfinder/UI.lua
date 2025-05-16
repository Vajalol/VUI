-- VUIGfinder UI
-- Handles the user interface with theme integration

-- Create global aliases for backward compatibility
_G.VUIFinder = _G.VUIFinder or _G.VUIGfinder or {}
_G.VUIGfinder = _G.VUIGfinder or {}

local L = PGFinderLocals or {}; -- Strings with fallback
local VUI, VUIGfinderModule

-- UI elements that need theme coloring
local themeElements = {}

-- Main UI frames
local mainFrame
local filterFrame
local configFrame
local resultsInfoFrame

-- Initialize the UI
local function InitializeUI()
    VUI = _G.VUI
<<<<<<< HEAD
    
    -- Try to get the module, but handle the case where it doesn't exist
    if VUI then
        local success, module = pcall(function() return VUI.GetModule and VUI:GetModule("VUIGfinder") end)
        if success and module then
            VUIGfinderModule = module
        else
            VUIGfinderModule = {
                db = {
                    profile = {
                        theme = { useVUITheme = true }
                    }
                }
            }
        end
    end
=======
    VUIGfinderModule = VUI and (VUI.VUIGfinder or VUI:GetModule("VUIGfinder"))
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
    
    -- Create main UI frame if it doesn't exist yet
    if not mainFrame then
        -- Ensure CreateMainFrame function exists before calling it
        if type(CreateMainFrame) == "function" then
            CreateMainFrame()
        else
            -- Create the frame directly instead
            mainFrame = CreateFrame("Frame", "VUIGfinderMainFrame", PVEFrame)
            mainFrame:SetFrameStrata("HIGH")
            mainFrame:SetPoint("RIGHT", LFGListFrame.SearchPanel.ResultsInset, "RIGHT", 395, 55)
            mainFrame:SetFrameLevel(800)
            mainFrame:SetSize(400, 300)
            mainFrame:Hide()
            
            -- Add background
            local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.9)
            
            -- Add border
            local border = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            border:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Register border for theming
            table.insert(themeElements, border)
            
            -- Add header
            local header = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            header:SetPoint("TOPLEFT", 15, -15)
            header:SetText(L.OPTIONS_TITLE or "VUI Group Finder")
            
            -- Register header for theming
            table.insert(themeElements, header)
            
            -- Add close button
            local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
            closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
            
            -- Make frame available
            VUIGfinder.mainFrame = mainFrame
        end
    end
    
    -- Create filter UI - check if the function exists first
    if not filterFrame then
        if type(CreateFilterUI) == "function" then
            CreateFilterUI()
        else
            -- Create a fallback filter UI if the function doesn't exist
            filterFrame = CreateFrame("Frame", "VUIGfinderFilterFrame", mainFrame)
            filterFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -40)
            filterFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -10, 10)
            
            -- Create a message that the filter UI is unavailable
            local message = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            message:SetPoint("CENTER", filterFrame, "CENTER")
            message:SetText("Filter functionality unavailable")
            message:SetTextColor(1, 0.5, 0.5)
            
            -- Make filter frame available
            VUIGfinder.filterFrame = filterFrame
        end
    end
    
    -- Create results info frame if needed
    if not resultsInfoFrame then
        if type(CreateResultsInfoFrame) == "function" then
            CreateResultsInfoFrame()
        else
            -- Create basic results info frame
            resultsInfoFrame = CreateFrame("Frame", "VUIGfinderResultsInfoFrame", LFGListFrame.SearchPanel)
            resultsInfoFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel, "TOPRIGHT", -5, -25)
            resultsInfoFrame:SetSize(200, 20)
            
            -- Create info text
            local infoText = resultsInfoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            infoText:SetPoint("RIGHT", resultsInfoFrame, "RIGHT")
            infoText:SetText("VUI Gfinder")
            
            -- Register for theming
            table.insert(themeElements, infoText)
            
            -- Store reference for updating
            resultsInfoFrame.infoText = infoText
            
            -- Make available
            VUIGfinder.resultsInfoFrame = resultsInfoFrame
        end
    end
    
    -- Apply theme
    if type(ApplyVUITheme) == "function" then
        ApplyVUITheme()
    end
    
    -- Register with theme system
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if VUIGfinderModule and VUIGfinderModule.db and 
               VUIGfinderModule.db.profile and 
               VUIGfinderModule.db.profile.theme and 
               VUIGfinderModule.db.profile.theme.useVUITheme then
                if type(ApplyVUITheme) == "function" then
                    ApplyVUITheme()
                end
            end
        end)
    end
end

-- Create the main frame
local function CreateMainFrame()
    -- Make sure the function exists at global level for backward compatibility
    if not _G.CreateMainFrame then
        _G.CreateMainFrame = CreateMainFrame
    end
    
    mainFrame = CreateFrame("Frame", "VUIGfinderMainFrame", PVEFrame)
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:SetPoint("RIGHT", LFGListFrame.SearchPanel.ResultsInset, "RIGHT", 395, 55)
    mainFrame:SetFrameLevel(800)
    mainFrame:SetSize(400, 300)
    mainFrame:Hide()
    
    -- Add background
    local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.9)
    
    -- Add border
    local border = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Register border for theming
    table.insert(themeElements, border)
    
    -- Add header
    local header = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetText(L.OPTIONS_TITLE or "VUI Group Finder")
    
    -- Register header for theming
    table.insert(themeElements, header)
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    
    -- Make frame available
    VUIGfinder.mainFrame = mainFrame
end

-- Create the filter UI
local function CreateFilterUI()
    -- Make sure the function exists at global level for backward compatibility
    if not _G.CreateFilterUI then
        _G.CreateFilterUI = CreateFilterUI
    end

    -- Create the filter frame
    filterFrame = CreateFrame("Frame", "VUIGfinderFilterFrame", mainFrame)
    filterFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -40)
    filterFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -10, 10)
    
    -- Create dummy filter options for now
    -- This will be expanded in a future implementation
    
    -- Get current filter settings
    local settings = VUIGfinder.GetFilterSettings and VUIGfinder.GetFilterSettings() or {
        categories = { dungeon = true, raid = true, arena = true, rbg = true, custom = true, other = true },
        minMythicLevel = 2,
        maxMythicLevel = 30,
        minRating = 0,
        maxRating = 3000
    }
    
    -- Dungeon filter
    local dungeonCheck = CreateFrame("CheckButton", "VUIGfinderDungeonCheck", filterFrame, "UICheckButtonTemplate")
    dungeonCheck:SetPoint("TOPLEFT", 10, -10)
    dungeonCheck:SetChecked(settings.categories and settings.categories.dungeon or true)
    dungeonCheck.text:SetText("Dungeon")
    dungeonCheck:SetScript("OnClick", function(self)
        if VUIGfinder.UpdateFilterSettings then
            VUIGfinder.UpdateFilterSettings({
                categories = { dungeon = self:GetChecked() }
            })
        end
    end)
    
    -- Raid filter
    local raidCheck = CreateFrame("CheckButton", "VUIGfinderRaidCheck", filterFrame, "UICheckButtonTemplate")
    raidCheck:SetPoint("TOPLEFT", 10, -40)
    raidCheck:SetChecked(settings.categories and settings.categories.raid or true)
    raidCheck.text:SetText("Raid")
    raidCheck:SetScript("OnClick", function(self)
        if VUIGfinder.UpdateFilterSettings then
            VUIGfinder.UpdateFilterSettings({
                categories = { raid = self:GetChecked() }
            })
        end
    end)
    
    -- Arena filter
    local arenaCheck = CreateFrame("CheckButton", "VUIGfinderArenaCheck", filterFrame, "UICheckButtonTemplate")
    arenaCheck:SetPoint("TOPLEFT", 10, -70)
    arenaCheck:SetChecked(settings.categories and settings.categories.arena or true)
    arenaCheck.text:SetText("Arena")
    arenaCheck:SetScript("OnClick", function(self)
        if VUIGfinder.UpdateFilterSettings then
            VUIGfinder.UpdateFilterSettings({
                categories = { arena = self:GetChecked() }
            })
        end
    end)
    
    -- Make filter frame available
    VUIGfinder.filterFrame = filterFrame
end

-- Create results info frame
local function CreateResultsInfoFrame()
    -- Will display statistics about filtered results
    resultsInfoFrame = CreateFrame("Frame", "VUIGfinderResultsInfoFrame", LFGListFrame.SearchPanel)
    resultsInfoFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel, "TOPRIGHT", -5, -25)
    resultsInfoFrame:SetSize(200, 20)
    
    -- Create info text
    local infoText = resultsInfoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoText:SetPoint("RIGHT", resultsInfoFrame, "RIGHT")
    infoText:SetText("VUI Gfinder: No filtering")
    
    -- Register for theming
    table.insert(themeElements, infoText)
    
    -- Store reference for updating
    resultsInfoFrame.infoText = infoText
    
    -- Make available
    VUIGfinder.resultsInfoFrame = resultsInfoFrame
end

-- Update results stats display
local function UpdateFilterStats(total, filtered)
    if not resultsInfoFrame or not resultsInfoFrame.infoText then return end
    
    if total == filtered then
        resultsInfoFrame.infoText:SetText("VUI Gfinder: No filtering")
    else
        resultsInfoFrame.infoText:SetText(string.format("VUI Gfinder: %d/%d", filtered, total))
    end
end

-- Apply VUI theme to UI elements
local function ApplyVUITheme()
    -- Get theme color
    local r, g, b = 0.0, 0.44, 0.87 -- Default blue
    if VUIGfinder and VUIGfinder.GetThemeColor then
        r, g, b = VUIGfinder.GetThemeColor()
    end
    
    -- Apply to themed elements
    for _, element in ipairs(themeElements) do
        if element then
            if element.SetBackdropBorderColor then
                element:SetBackdropBorderColor(r, g, b, 1)
            elseif element.SetTextColor then
                element:SetTextColor(r, g, b, 1)
            elseif element.SetVertexColor then
                element:SetVertexColor(r, g, b, 1)
            end
        end
    end
end

-- Register an element for theming
local function RegisterThemeElement(element)
    if element then
        table.insert(themeElements, element)
        -- Apply theme immediately
        local r, g, b = VUIGfinder.GetThemeColor and VUIGfinder.GetThemeColor() or 0.0, 0.44, 0.87
        if element.SetBackdropBorderColor then
            element:SetBackdropBorderColor(r, g, b, 1)
        elseif element.SetTextColor then
            element:SetTextColor(r, g, b, 1)
        elseif element.SetVertexColor then
            element:SetVertexColor(r, g, b, 1)
        end
    end
end

-- Toggle the UI
local function ToggleUI()
    if mainFrame then
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show()
        end
    end
end

-- Export functions to the global namespace
VUIGfinder.InitializeUI = InitializeUI
VUIGfinder.ApplyUITheme = ApplyVUITheme
VUIGfinder.RegisterThemeElement = RegisterThemeElement
VUIGfinder.UpdateFilterStats = UpdateFilterStats
VUIGfinder.ToggleUI = ToggleUI

-- Also make them available through VUIFinder namespace for backward compatibility
_G.VUIFinder = _G.VUIFinder or {}
_G.VUIFinder.InitializeUI = InitializeUI
_G.VUIFinder.ApplyUITheme = ApplyVUITheme
_G.VUIFinder.RegisterThemeElement = RegisterThemeElement
_G.VUIFinder.UpdateFilterStats = UpdateFilterStats
_G.VUIFinder.ToggleUI = ToggleUI