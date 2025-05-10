-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module: Dialog - Main filter dialog interface
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L
local C = VUIGfinder.C

-- Create the Dialog submodule
VUIGfinder.Dialog = {}
local Dialog = VUIGfinder.Dialog

-- Initialize the Dialog UI
function Dialog:Initialize()
    -- Create main frame if it doesn't exist
    if not self.frame then
        self:CreateMainFrame()
    end
    
    -- Set up the initial state
    self.activePanel = "dungeon" -- Default panel
    self.minimized = Module.db.profile.ui.minimized
    
    -- Update frame display
    self:UpdateVisibility()
end

-- Create the main dialog frame
function Dialog:CreateMainFrame()
    -- Main frame
    self.frame = CreateFrame("Frame", "VUIGfinderDialog", LFGListFrame, "UIPanelDialogTemplate")
    self.frame:SetSize(350, 400)
    self.frame:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 5, 0)
    self.frame:SetClampedToScreen(true)
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:SetScale(Module.db.profile.ui.dialogScale or 1)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)
    self.frame:SetFrameStrata("HIGH")
    
    -- Title
    self.frame.title = _G[self.frame:GetName() .. "TitleText"]
    self.frame.title:SetText("VUI Gfinder")
    
    -- Close button
    self.frame.closeButton = _G[self.frame:GetName() .. "CloseButton"]
    self.frame.closeButton:SetScript("OnClick", function()
        self:Hide()
    end)
    
    -- Minimize button (next to close button)
    self.frame.minimizeButton = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    self.frame.minimizeButton:SetSize(20, 20)
    self.frame.minimizeButton:SetPoint("RIGHT", self.frame.closeButton, "LEFT", -2, 0)
    self.frame.minimizeButton:SetText("_")
    self.frame.minimizeButton:SetScript("OnClick", function()
        self:ToggleMinimize()
    end)
    
    -- Content frame (inside main frame)
    self.frame.content = CreateFrame("Frame", nil, self.frame)
    self.frame.content:SetPoint("TOPLEFT", 10, -30)
    self.frame.content:SetPoint("BOTTOMRIGHT", -10, 10)
    
    -- Tab buttons at top
    self:CreateTabButtons()
    
    -- Panel frames for each tab
    self:CreatePanelFrames()
    
    -- Button container at bottom
    self:CreateButtonContainer()
    
    -- Select the default tab
    self:SelectTab("dungeon")
    
    -- Hide by default until needed
    self.frame:Hide()
end

-- Create tab buttons
function Dialog:CreateTabButtons()
    self.tabs = {}
    local tabs = {
        { id = "dungeon", text = L["Dungeon"], order = 1 },
        { id = "raid", text = L["Raid"], order = 2 },
        { id = "arena", text = L["Arena"], order = 3 },
        { id = "rbg", text = L["Rated Battleground"], order = 4 },
        { id = "advanced", text = L["Advanced Filtering"], order = 5 }
    }
    
    -- Sort tabs by order
    table.sort(tabs, function(a, b) return a.order < b.order end)
    
    -- Create tab buttons
    for i, tab in ipairs(tabs) do
        local button = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
        button:SetSize(70, 22)
        button:SetText(tab.text)
        
        -- Position tabs horizontally
        if i == 1 then
            button:SetPoint("TOPLEFT", self.frame.content, "TOPLEFT", 0, 25)
        else
            button:SetPoint("LEFT", self.tabs[i-1].button, "RIGHT", 5, 0)
        end
        
        -- Tab selection behavior
        button:SetScript("OnClick", function()
            self:SelectTab(tab.id)
        end)
        
        -- Store the tab reference
        self.tabs[i] = {
            id = tab.id,
            button = button
        }
    end
end

-- Create panel frames for each tab
function Dialog:CreatePanelFrames()
    -- Container for all panels
    self.panels = {}
    
    -- Create each panel
    local panels = {
        "dungeon", "raid", "arena", "rbg", "advanced"
    }
    
    for _, panelID in ipairs(panels) do
        local panel = CreateFrame("Frame", nil, self.frame.content)
        panel:SetPoint("TOPLEFT", 0, 0)
        panel:SetPoint("BOTTOMRIGHT", 0, 40) -- Leave space for buttons at bottom
        panel:Hide() -- Hide initially
        
        -- Store reference to panel
        self.panels[panelID] = panel
        
        -- Create content specific to each panel
        -- In a real implementation, we'd create specific UI elements for each panel
        -- For demonstration, we're just adding a simple text label
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("CENTER")
        label:SetText(panelID .. " panel")
    end
    
    -- Special handling for advanced panel - it has a text input
    if self.panels.advanced then
        local panel = self.panels.advanced
        
        -- Create checkbox to enable advanced mode
        local enableCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        enableCheckbox:SetPoint("TOPLEFT", 10, -10)
        enableCheckbox:SetSize(24, 24)
        enableCheckbox.text = enableCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enableCheckbox.text:SetPoint("LEFT", enableCheckbox, "RIGHT", 5, 0)
        enableCheckbox.text:SetText(L["Use Expression"])
        
        -- Set initial value
        enableCheckbox:SetChecked(Module.db.profile.advanced.enabled)
        
        -- Update on click
        enableCheckbox:SetScript("OnClick", function()
            Module.db.profile.advanced.enabled = enableCheckbox:GetChecked()
        end)
        
        -- Create input box for filter expression
        local expressionBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        expressionBox:SetPoint("TOPLEFT", enableCheckbox, "BOTTOMLEFT", 5, -10)
        expressionBox:SetPoint("RIGHT", panel, "RIGHT", -15, 0)
        expressionBox:SetHeight(20)
        expressionBox:SetAutoFocus(false)
        expressionBox:SetText(Module.db.profile.advanced.expression)
        
        -- Save changes when focus is lost
        expressionBox:SetScript("OnEditFocusLost", function()
            Module.db.profile.advanced.expression = expressionBox:GetText()
        end)
        
        -- Submit on enter
        expressionBox:SetScript("OnEnterPressed", function()
            Module.db.profile.advanced.expression = expressionBox:GetText()
            expressionBox:ClearFocus()
        end)
        
        -- Help text
        local helpText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        helpText:SetPoint("TOPLEFT", expressionBox, "BOTTOMLEFT", 0, -5)
        helpText:SetPoint("RIGHT", panel, "RIGHT", -15, 0)
        helpText:SetJustifyH("LEFT")
        helpText:SetJustifyV("TOP")
        helpText:SetText(L["Expression Help"] or "Use expressions like: 'mythicplus >= 10 and members < 4'. See help for more info.")
        
        -- Help button
        local helpButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        helpButton:SetSize(60, 22)
        helpButton:SetText("Help")
        helpButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
        helpButton:SetScript("OnClick", function()
            if VUIGfinder.Help then
                VUIGfinder.Help:Show()
            else
                -- Fallback if Help module isn't loaded
                print("|cFF33FF99VUI Gfinder:|r Help module not available.")
            end
        end)
        
        -- Store references
        panel.enableCheckbox = enableCheckbox
        panel.expressionBox = expressionBox
        panel.helpText = helpText
        panel.helpButton = helpButton
    end
end

-- Create button container at bottom
function Dialog:CreateButtonContainer()
    -- Button container
    self.frame.buttonContainer = CreateFrame("Frame", nil, self.frame.content)
    self.frame.buttonContainer:SetPoint("BOTTOMLEFT", 0, 0)
    self.frame.buttonContainer:SetPoint("BOTTOMRIGHT", 0, 0)
    self.frame.buttonContainer:SetHeight(40)
    
    -- Find Groups button
    self.frame.buttonContainer.findButton = CreateFrame("Button", nil, self.frame.buttonContainer, "UIPanelButtonTemplate")
    self.frame.buttonContainer.findButton:SetSize(120, 25)
    self.frame.buttonContainer.findButton:SetPoint("RIGHT", self.frame.buttonContainer, "RIGHT", -10, 0)
    self.frame.buttonContainer.findButton:SetText(L["Find Groups"])
    self.frame.buttonContainer.findButton:SetScript("OnClick", function()
        self:FindGroups()
    end)
    
    -- Reset button
    self.frame.buttonContainer.resetButton = CreateFrame("Button", nil, self.frame.buttonContainer, "UIPanelButtonTemplate")
    self.frame.buttonContainer.resetButton:SetSize(120, 25)
    self.frame.buttonContainer.resetButton:SetPoint("RIGHT", self.frame.buttonContainer.findButton, "LEFT", -10, 0)
    self.frame.buttonContainer.resetButton:SetText(L["Reset Filters"])
    self.frame.buttonContainer.resetButton:SetScript("OnClick", function()
        self:ResetFilters()
    end)
end

-- Select a tab to display
function Dialog:SelectTab(tabID)
    -- Hide all panels first
    for id, panel in pairs(self.panels) do
        panel:Hide()
    end
    
    -- Show the selected panel
    if self.panels[tabID] then
        self.panels[tabID]:Show()
    end
    
    -- Update tab button appearance
    for _, tab in ipairs(self.tabs) do
        if tab.id == tabID then
            tab.button:SetEnabled(false) -- Visual indication of selected tab
        else
            tab.button:SetEnabled(true)
        end
    end
    
    -- Store the active panel
    self.activePanel = tabID
end

-- Toggle dialog visibility
function Dialog:Toggle()
    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Show the dialog
function Dialog:Show()
    if not self.frame then
        self:Initialize()
    end
    
    self.frame:Show()
    self:UpdateVisibility()
end

-- Hide the dialog
function Dialog:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

-- Toggle minimized state
function Dialog:ToggleMinimize()
    self.minimized = not self.minimized
    Module.db.profile.ui.minimized = self.minimized
    self:UpdateVisibility()
end

-- Update frame visibility based on minimized state
function Dialog:UpdateVisibility()
    if not self.frame then return end
    
    if self.minimized then
        -- Hide content when minimized
        self.frame.content:Hide()
        -- Adjust frame height
        self.frame:SetHeight(40)
    else
        -- Show content when not minimized
        self.frame.content:Show()
        -- Restore frame height
        self.frame:SetHeight(400)
    end
end

-- Get the active panel
function Dialog:GetActivePanel()
    if self.activePanel == "dungeon" then
        return VUIGfinder.DungeonPanel
    elseif self.activePanel == "raid" then
        return VUIGfinder.RaidPanel
    elseif self.activePanel == "arena" then
        return VUIGfinder.ArenaPanel
    elseif self.activePanel == "rbg" then
        return VUIGfinder.RBGPanel
    else
        return nil
    end
end

-- Get the current sorting expression
function Dialog:GetSortingExpression()
    return Module.db.profile.sorting.enabled and Module.db.profile.sorting.expression or ""
end

-- Find groups with current filters
function Dialog:FindGroups()
    -- In a real implementation, this would start a search with the current filters
    -- Since we're just demonstrating the UI structure, we'll print a message
    print("|cFF33FF99VUI Gfinder:|r Searching for groups...")
    
    -- Update search expression
    if self.activePanel == "advanced" and self.panels.advanced.expressionBox then
        Module.db.profile.advanced.expression = self.panels.advanced.expressionBox:GetText()
    end
    
    -- Actual implementation would trigger the group finder search
    if LFGListSearchPanel_StartSearch then
        LFGListSearchPanel_StartSearch(LFGListFrame.SearchPanel)
    end
end

-- Reset all filters to defaults
function Dialog:ResetFilters()
    -- Reset advanced expression
    if self.activePanel == "advanced" and self.panels.advanced.expressionBox then
        Module.db.profile.advanced.expression = ""
        self.panels.advanced.expressionBox:SetText("")
    end
    
    -- In a real implementation, we would reset all panel-specific filters as well
    print("|cFF33FF99VUI Gfinder:|r Filters reset to defaults.")
    
    -- Actual implementation would reset each panel's filters
    local panel = self:GetActivePanel()
    if panel and panel.ResetFilters then
        panel:ResetFilters()
    end
end