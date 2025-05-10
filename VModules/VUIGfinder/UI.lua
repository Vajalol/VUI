-- VUIGfinder UI
-- Handles the user interface with theme integration

local L = PGFinderLocals; -- Strings
local VUI, VUIGfinderModule

-- UI elements that need theme coloring
local themeElements = {}

-- Main UI frames
local mainFrame
local filterFrame
local configFrame
local resultsInfoFrame

-- Initialize the UI
function InitializeUI()
    VUI = _G.VUI
    VUIGfinderModule = VUI and VUI:GetModule("VUIGfinder")
    
    -- Create main UI frame if it doesn't exist yet
    if not mainFrame then
        CreateMainFrame()
    end
    
    -- Create filter UI
    CreateFilterUI()
    
    -- Create results info frame
    CreateResultsInfoFrame()
    
    -- Apply theme
    ApplyVUITheme()
    
    -- Register with theme system
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if VUIGfinderModule.db.profile.theme.useVUITheme then
                ApplyVUITheme()
            end
        end)
    end
end

-- Create the main frame
function CreateMainFrame()
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
    header:SetText(L.OPTIONS_TITLE)
    
    -- Register header for theming
    table.insert(themeElements, header)
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    
    -- Make frame available
    VUIGfinder.mainFrame = mainFrame
end

-- Create the filter UI
function CreateFilterUI()
    -- Will be expanded with all filter options
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
    dungeonCheck:SetChecked(settings.categories.dungeon)
    dungeonCheck.text:SetText("Dungeon")
    dungeonCheck:SetScript("OnClick", function(self)
        VUIGfinder.UpdateFilterSettings({
            categories = { dungeon = self:GetChecked() }
        })
    end)
    
    -- Raid filter
    local raidCheck = CreateFrame("CheckButton", "VUIGfinderRaidCheck", filterFrame, "UICheckButtonTemplate")
    raidCheck:SetPoint("TOPLEFT", 10, -40)
    raidCheck:SetChecked(settings.categories.raid)
    raidCheck.text:SetText("Raid")
    raidCheck:SetScript("OnClick", function(self)
        VUIGfinder.UpdateFilterSettings({
            categories = { raid = self:GetChecked() }
        })
    end)
    
    -- Arena filter
    local arenaCheck = CreateFrame("CheckButton", "VUIGfinderArenaCheck", filterFrame, "UICheckButtonTemplate")
    arenaCheck:SetPoint("TOPLEFT", 10, -70)
    arenaCheck:SetChecked(settings.categories.arena)
    arenaCheck.text:SetText("Arena")
    arenaCheck:SetScript("OnClick", function(self)
        VUIGfinder.UpdateFilterSettings({
            categories = { arena = self:GetChecked() }
        })
    end)
    
    -- Make filter frame available
    VUIGfinder.filterFrame = filterFrame
end

-- Create results info frame
function CreateResultsInfoFrame()
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
function UpdateFilterStats(total, filtered)
    if not resultsInfoFrame or not resultsInfoFrame.infoText then return end
    
    if total == filtered then
        resultsInfoFrame.infoText:SetText("VUI Gfinder: No filtering")
    else
        resultsInfoFrame.infoText:SetText(string.format("VUI Gfinder: %d/%d", filtered, total))
    end
end

-- Apply VUI theme to UI elements
function ApplyVUITheme()
    -- Get theme color
    local r, g, b = 0.0, 0.44, 0.87 -- Default blue
    if VUIGfinder.GetThemeColor then
        r, g, b = VUIGfinder.GetThemeColor()
    end
    
    -- Apply to themed elements
    for _, element in ipairs(themeElements) do
        if element.SetBackdropBorderColor then
            element:SetBackdropBorderColor(r, g, b, 1)
        elseif element.SetTextColor then
            element:SetTextColor(r, g, b, 1)
        elseif element.SetVertexColor then
            element:SetVertexColor(r, g, b, 1)
        end
    end
end

-- Register an element for theming
function RegisterThemeElement(element)
    if element then
        table.insert(themeElements, element)
        -- Apply theme immediately
        local r, g, b = VUIGfinder.GetThemeColor()
        if element.SetBackdropBorderColor then
            element:SetBackdropBorderColor(r, g, b, 1)
        elseif element.SetTextColor then
            element:SetTextColor(r, g, b, 1)
        elseif element.SetVertexColor then
            element:SetVertexColor(r, g, b, 1)
        end
    end
end

-- Toggle UI visibility
function ToggleUI()
    if not mainFrame then
        InitializeUI()
    end
    
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- Export functions
VUIGfinder.InitializeUI = InitializeUI
VUIGfinder.UpdateFilterStats = UpdateFilterStats
VUIGfinder.RegisterUIElement = RegisterThemeElement
VUIGfinder.ApplyUITheme = ApplyVUITheme
VUIGfinder.ToggleUI = ToggleUI