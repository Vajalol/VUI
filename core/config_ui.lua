-- VUI Configuration UI
-- Provides a modern tabbed interface for better organization of settings
local _, VUI = ...

-- Create Configuration UI module
VUI.ConfigUI = {}

-- Default settings
VUI.ConfigUI.defaults = {
    enabled = true,
    lastTab = "general",  -- Last open tab
    showSearch = true,    -- Show search bar
    showContextHelp = true, -- Show context-sensitive help
    showPreview = true,   -- Show visual previews
}

-- ConfigUI panel reference
local ConfigUI = VUI.ConfigUI
local panel = nil
local tabButtons = {}
local tabFrames = {}
local searchResults = {}

-- Constants
local TAB_HEIGHT = 32
local TAB_PADDING = 10
local PANEL_PADDING = 20
local SEARCH_HEIGHT = 24
local PREVIEW_WIDTH = 220
local HELP_ICON_SIZE = 16

-- Tab definitions - organized sections of the configuration
local TABS = {
    general = {
        name = "General",
        icon = "Interface\\AddOns\\VUI\\media\\icons\\common\\settings.tga",
        order = 10,
        sections = {"Core Settings", "Profile Management", "Addon Integration"},
    },
    appearance = {
        name = "Appearance",
        icon = "Interface\\AddOns\\VUI\\media\\icons\\common\\theme.tga",
        order = 20,
        sections = {"Themes", "Colors", "Fonts", "Textures"},
    },
    modules = {
        name = "Modules",
        icon = "Interface\\AddOns\\VUI\\media\\icons\\common\\modules.tga",
        order = 30,
        sections = {"Module Settings", "Module Management"},
    },
    skins = {
        name = "Skins",
        icon = "Interface\\AddOns\\VUI\\media\\icons\\common\\skins.tga",
        order = 40,
        sections = {"Blizzard UI", "Frame Groups", "Style Options"},
    },
    advanced = {
        name = "Advanced",
        icon = "Interface\\AddOns\\VUI\\media\\icons\\common\\advanced.tga",
        order = 50,
        sections = {"Performance", "Debug", "Export/Import"},
    }
}

-- Initialize module
function ConfigUI:Initialize()
    -- Set up the config UI frame
    self:SetupFrame()
    
    -- Create tab interface
    self:CreateTabs()
    
    -- Create search functionality if enabled
    if VUI.db.profile.configUI.showSearch then
        self:CreateSearchBar()
    end
    
    -- Enable if set in profile
    if VUI.db.profile.configUI.enabled then
        self:Enable()
    end
    
    -- Register with interface options panel
    self:RegisterWithBlizzardOptions()
    
    VUI:Print("ConfigUI module initialized")
end

-- Enable module
function ConfigUI:Enable()
    self.enabled = true
    VUI:Print("ConfigUI module enabled")
end

-- Disable module
function ConfigUI:Disable()
    self.enabled = false
    VUI:Print("ConfigUI module disabled")
end

-- Set up the main configuration frame
function ConfigUI:SetupFrame()
    -- Create the main panel frame that will contain everything
    panel = CreateFrame("Frame", "VUIConfigPanel")
    panel:SetSize(InterfaceOptionsFramePanelContainer:GetWidth(), InterfaceOptionsFramePanelContainer:GetHeight())
    panel.name = "VUI"
    panel:Hide()
    
    -- Title text
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("VUI Configuration")
    
    -- Version text
    local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -16)
    version:SetText("v" .. (VUI.version or "0.0.1"))
    
    -- Description text
    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    desc:SetNonSpaceWrap(true)
    desc:SetJustifyH("LEFT")
    desc:SetText("Configure VUI settings and manage addon modules with this tabbed interface.")
    
    -- Separator line
    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetSize(panel:GetWidth() - 32, 1)
    line:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)
    line:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    
    -- Save panel reference
    self.panel = panel
    self.title = title
    self.description = desc
    
    -- Calculate content area
    self.contentTop = line:GetBottom() - 16
    self.contentWidth = panel:GetWidth() - 32
    self.contentHeight = panel:GetHeight() - (panel:GetHeight() - self.contentTop) - 40
    
    return panel
end

-- Create the tabbed interface
function ConfigUI:CreateTabs()
    -- Tab container area
    local tabContainer = CreateFrame("Frame", nil, self.panel)
    tabContainer:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, self.contentTop)
    tabContainer:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -16, 40)
    
    -- Create tab buttons
    local tabList = {}
    for id, tabInfo in pairs(TABS) do
        table.insert(tabList, {id = id, order = tabInfo.order, info = tabInfo})
    end
    
    -- Sort tabs by order
    table.sort(tabList, function(a, b) return a.order < b.order end)
    
    -- Create tab buttons along the top
    local prevTab = nil
    for i, tabData in ipairs(tabList) do
        local id = tabData.id
        local info = tabData.info
        
        -- Create tab button
        local tab = CreateFrame("Button", "VUIConfigTab" .. id, self.panel, "OptionsFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(info.name)
        tab:SetScript("OnClick", function(self)
            ConfigUI:SelectTab(id)
        end)
        
        -- Position tab
        if prevTab then
            tab:SetPoint("LEFT", prevTab, "RIGHT", -15, 0)
        else
            tab:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, self.contentTop + 10)
        end
        
        -- Create content frame for this tab
        local content = CreateFrame("Frame", "VUIConfigTabContent" .. id, tabContainer)
        content:SetPoint("TOPLEFT", tabContainer, "TOPLEFT", 10, -10)
        content:SetPoint("BOTTOMRIGHT", tabContainer, "BOTTOMRIGHT", -10, 10)
        content:Hide()
        
        -- Add icon if specified
        if info.icon then
            local icon = content:CreateTexture(nil, "ARTWORK")
            icon:SetSize(24, 24)
            icon:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            icon:SetTexture(info.icon)
            
            local heading = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            heading:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -4)
            heading:SetText(info.name .. " Settings")
        else
            local heading = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            heading:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            heading:SetText(info.name .. " Settings")
        end
        
        -- Create sections within the tab
        if info.sections then
            local prevSection = nil
            for j, sectionName in ipairs(info.sections) do
                local yOffset = 40 + ((j-1) * 20)
                
                local section = CreateFrame("Frame", "VUIConfigSection" .. id .. j, content)
                section:SetSize(content:GetWidth(), 20)
                section:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
                
                local sectionTitle = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                sectionTitle:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
                sectionTitle:SetText(sectionName)
                
                local sectionLine = section:CreateTexture(nil, "ARTWORK")
                sectionLine:SetHeight(1)
                sectionLine:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -2)
                sectionLine:SetPoint("RIGHT", section, "RIGHT", 0, 0)
                sectionLine:SetColorTexture(0.3, 0.3, 0.3, 0.8)
                
                -- Create content area for this section
                local sectionContent = CreateFrame("Frame", "VUIConfigSectionContent" .. id .. j, content)
                sectionContent:SetPoint("TOPLEFT", section, "BOTTOMLEFT", 10, -10)
                if j < #info.sections then
                    -- Fixed height for all but the last section
                    sectionContent:SetHeight(120)
                    sectionContent:SetPoint("RIGHT", content, "RIGHT", -10, 0)
                else
                    -- Last section expands to fill remaining space
                    sectionContent:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -10, 10)
                end
                
                -- We'd add actual controls here for each section
                -- This will be implemented separately for each specific module
                
                prevSection = section
            end
        end
        
        -- Store references
        tabButtons[id] = tab
        tabFrames[id] = content
        
        prevTab = tab
    end
    
    -- Add preview panel if enabled
    if VUI.db.profile.configUI.showPreview then
        self:CreatePreviewPanel(tabContainer)
    end
    
    -- Initialize with last selected tab or default to first tab
    local initialTab = VUI.db.profile.configUI.lastTab
    if not initialTab or not tabButtons[initialTab] then
        initialTab = "general"
    end
    
    self:SelectTab(initialTab)
    
    -- Store container reference
    self.tabContainer = tabContainer
end

-- Create search functionality
function ConfigUI:CreateSearchBar()
    -- Create search bar at the top
    local searchContainer = CreateFrame("Frame", nil, self.panel)
    searchContainer:SetSize(200, SEARCH_HEIGHT)
    searchContainer:SetPoint("TOPRIGHT", self.panel, "TOPRIGHT", -16, self.contentTop + 12)
    
    -- Search box
    local searchBox = CreateFrame("EditBox", "VUIConfigSearchBox", searchContainer, "SearchBoxTemplate")
    searchBox:SetSize(200, SEARCH_HEIGHT)
    searchBox:SetPoint("RIGHT", searchContainer, "RIGHT", 0, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text and text:len() > 2 then
            ConfigUI:PerformSearch(text)
        else
            ConfigUI:ClearSearch()
        end
    end)
    
    -- Results dropdown (will be populated on search)
    local resultsFrame = CreateFrame("Frame", "VUIConfigSearchResults", self.panel, "BackdropTemplate")
    resultsFrame:SetSize(300, 200)
    resultsFrame:SetPoint("TOPRIGHT", searchBox, "BOTTOMRIGHT", 0, -2)
    resultsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    resultsFrame:SetFrameStrata("DIALOG")
    resultsFrame:Hide()
    
    -- Results scrollframe
    local scrollFrame = CreateFrame("ScrollFrame", "VUIConfigSearchScroll", resultsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", resultsFrame, "TOPLEFT", 12, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", resultsFrame, "BOTTOMRIGHT", -30, 12)
    
    local scrollChild = CreateFrame("Frame", "VUIConfigSearchScrollChild", scrollFrame)
    scrollChild:SetSize(scrollFrame:GetWidth(), 500) -- Will be resized based on results
    scrollFrame:SetScrollChild(scrollChild)
    
    -- Close button for results
    local closeButton = CreateFrame("Button", nil, resultsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", resultsFrame, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() resultsFrame:Hide() end)
    
    -- Store references
    self.searchBox = searchBox
    self.resultsFrame = resultsFrame
    self.scrollChild = scrollChild
end

-- Create preview panel
function ConfigUI:CreatePreviewPanel(parent)
    -- Create a frame on the right side to preview settings
    local previewPanel = CreateFrame("Frame", "VUIConfigPreviewPanel", parent, "BackdropTemplate")
    previewPanel:SetWidth(PREVIEW_WIDTH)
    previewPanel:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -10)
    previewPanel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
    previewPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 10 }
    })
    
    -- Preview title
    local title = previewPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", previewPanel, "TOPLEFT", 16, -16)
    title:SetText("Preview")
    
    -- Adjust tab content frames to make room for preview
    for id, frame in pairs(tabFrames) do
        frame:SetPoint("RIGHT", previewPanel, "LEFT", -10, 0)
    end
    
    -- Preview content area 
    local content = CreateFrame("Frame", "VUIConfigPreviewContent", previewPanel)
    content:SetPoint("TOPLEFT", previewPanel, "TOPLEFT", 16, -40)
    content:SetPoint("BOTTOMRIGHT", previewPanel, "BOTTOMRIGHT", -16, 16)
    
    -- Store references
    self.previewPanel = previewPanel
    self.previewContent = content
    
    return previewPanel
end

-- Select a tab
function ConfigUI:SelectTab(tabID)
    -- Hide all tab content frames
    for id, frame in pairs(tabFrames) do
        frame:Hide()
        PanelTemplates_DeselectTab(tabButtons[id])
    end
    
    -- Show the selected tab content
    if tabFrames[tabID] then
        tabFrames[tabID]:Show()
        PanelTemplates_SelectTab(tabButtons[tabID])
        
        -- Save the last selected tab
        VUI.db.profile.configUI.lastTab = tabID
        
        -- Update preview if applicable
        if self.previewContent and VUI.db.profile.configUI.showPreview then
            self:UpdatePreview(tabID)
        end
    end
end

-- Update the preview panel based on selected tab
function ConfigUI:UpdatePreview(tabID)
    local content = self.previewContent
    
    -- Clear existing preview content
    for i, child in ipairs({content:GetChildren()}) do
        child:Hide()
    end
    
    -- Add new preview content based on tab
    if tabID == "appearance" then
        -- Theme preview - show a sample frame with the current theme
        local themePreview = CreateFrame("Frame", "VUIConfigThemePreview", content, "BackdropTemplate")
        themePreview:SetSize(180, 120)
        themePreview:SetPoint("TOP", content, "TOP", 0, -20)
        
        -- Get current theme
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        
        -- Set backdrop based on theme
        themePreview:SetBackdrop({
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
            tile = false,
            tileSize = 0,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Add theme color samples
        local colors = VUI.Skins:GetColors()
        local colorSwatches = {"border", "backdrop", "highlight", "button"}
        
        for i, colorName in ipairs(colorSwatches) do
            local color = colors[colorName]
            
            local swatch = CreateFrame("Frame", nil, themePreview, "BackdropTemplate")
            swatch:SetSize(30, 30)
            swatch:SetPoint("TOPLEFT", themePreview, "TOPLEFT", 20, -20 - ((i-1) * 40))
            swatch:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            swatch:SetBackdropColor(color.r, color.g, color.b, color.a)
            swatch:SetBackdropBorderColor(1, 1, 1, 0.5)
            
            local label = swatch:CreateFontString(nil, "OVERLAY", "GameFontSmall")
            label:SetPoint("LEFT", swatch, "RIGHT", 10, 0)
            label:SetText(colorName:gsub("^%l", string.upper))
        end
        
        -- Theme name
        local themeName = themePreview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        themeName:SetPoint("TOP", themePreview, "BOTTOM", 0, -10)
        
        -- Format theme name with proper capitalization
        local formattedName = theme:gsub("^%l", string.upper):gsub("(%u)([%l]*)", function(first, rest) 
            return first .. rest .. " " 
        end):trim()
        
        themeName:SetText(formattedName .. " Theme")
        
    elseif tabID == "skins" then
        -- Skin preview - show a sample skinned button/frame
        local skinPreview = CreateFrame("Frame", "VUIConfigSkinPreview", content, "BackdropTemplate")
        skinPreview:SetSize(180, 180)
        skinPreview:SetPoint("TOP", content, "TOP", 0, -20)
        
        -- Get current theme colors
        local colors = VUI.Skins:GetColors()
        
        -- Create a sample frame with theme styling
        skinPreview:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        skinPreview:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        skinPreview:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        
        -- Add a sample button
        local button = CreateFrame("Button", nil, skinPreview, "UIPanelButtonTemplate")
        button:SetSize(120, 30)
        button:SetPoint("TOP", skinPreview, "TOP", 0, -40)
        button:SetText("Sample Button")
        
        -- Add a sample statusbar
        local statusbar = CreateFrame("StatusBar", nil, skinPreview)
        statusbar:SetSize(140, 20)
        statusbar:SetPoint("TOP", button, "BOTTOM", 0, -20)
        statusbar:SetStatusBarTexture(VUI.Skins.DefaultTextures.statusbar)
        statusbar:SetStatusBarColor(colors.highlight.r, colors.highlight.g, colors.highlight.b, 0.8)
        statusbar:SetMinMaxValues(0, 100)
        statusbar:SetValue(75)
        
        -- Add a border around statusbar
        statusbar.border = statusbar:CreateTexture(nil, "OVERLAY")
        statusbar.border:SetTexture(VUI.Skins.DefaultTextures.border)
        statusbar.border:SetPoint("TOPLEFT", statusbar, "TOPLEFT", -1, 1)
        statusbar.border:SetPoint("BOTTOMRIGHT", statusbar, "BOTTOMRIGHT", 1, -1)
        statusbar.border:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        
        -- Add skin style label
        local styleLabel = skinPreview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        styleLabel:SetPoint("TOP", statusbar, "BOTTOM", 0, -20)
        styleLabel:SetText(VUI.db.profile.skins.style:gsub("^%l", string.upper) .. " Style")
    end
end

-- Perform a search across settings
function ConfigUI:PerformSearch(text)
    -- Clear previous results
    self.scrollChild:SetHeight(1) -- Reset height
    for i, child in ipairs({self.scrollChild:GetChildren()}) do
        child:Hide()
    end
    
    -- Convert to lowercase for case-insensitive search
    local searchText = text:lower()
    local results = {}
    
    -- Search through all tab data
    for tabID, tabInfo in pairs(TABS) do
        -- Match tab names
        if tabInfo.name:lower():find(searchText) then
            table.insert(results, {
                type = "tab",
                id = tabID,
                name = tabInfo.name,
                path = tabInfo.name
            })
        end
        
        -- Match section names
        if tabInfo.sections then
            for i, sectionName in ipairs(tabInfo.sections) do
                if sectionName:lower():find(searchText) then
                    table.insert(results, {
                        type = "section",
                        id = tabID .. i,
                        name = sectionName,
                        path = tabInfo.name .. " → " .. sectionName,
                        tabID = tabID
                    })
                end
            end
        end
    end
    
    -- Search through all settings (this would be implemented more thoroughly to search actual settings)
    -- For now, we'll just add a placeholder for demonstration
    
    -- No results found
    if #results == 0 then
        local noResults = self.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noResults:SetPoint("TOP", self.scrollChild, "TOP", 0, -10)
        noResults:SetText("No results found for: " .. text)
        
        self.scrollChild:SetHeight(40)
        self.resultsFrame:Show()
        return
    end
    
    -- Display results
    local yOffset = -10
    for i, result in ipairs(results) do
        local resultButton = CreateFrame("Button", "VUIConfigSearchResult" .. i, self.scrollChild)
        resultButton:SetSize(self.scrollChild:GetWidth() - 20, 30)
        resultButton:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 10, yOffset)
        
        -- Highlight on mouseover
        resultButton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        
        -- Result text
        local text = resultButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", resultButton, "LEFT", 5, 0)
        text:SetPoint("RIGHT", resultButton, "RIGHT", -5, 0)
        text:SetJustifyH("LEFT")
        text:SetText(result.name)
        
        -- Path text
        local path = resultButton:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        path:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -2)
        path:SetPoint("RIGHT", resultButton, "RIGHT", -5, 0)
        path:SetJustifyH("LEFT")
        path:SetTextColor(0.7, 0.7, 0.7)
        path:SetText(result.path)
        
        -- Click handler
        resultButton:SetScript("OnClick", function()
            if result.type == "tab" or result.type == "section" then
                self:SelectTab(result.tabID or result.id)
                self.resultsFrame:Hide()
            end
        end)
        
        yOffset = yOffset - 35
    end
    
    -- Adjust scroll child height
    self.scrollChild:SetHeight(math.abs(yOffset) + 10)
    
    -- Show results frame
    self.resultsFrame:Show()
end

-- Clear search results
function ConfigUI:ClearSearch()
    if self.resultsFrame then
        self.resultsFrame:Hide()
    end
end

-- Register with Blizzard Interface Options
function ConfigUI:RegisterWithBlizzardOptions()
    -- Add main panel to interface options
    InterfaceOptions_AddCategory(self.panel)
    
    -- Create additional category panels for major sections
    -- This allows direct navigation to specific tabs
    for tabID, tabInfo in pairs(TABS) do
        -- Skip "general" since it's covered by the main panel
        if tabID ~= "general" then
            local categoryPanel = CreateFrame("Frame")
            categoryPanel:SetSize(InterfaceOptionsFramePanelContainer:GetWidth(), InterfaceOptionsFramePanelContainer:GetHeight())
            categoryPanel.name = "VUI " .. tabInfo.name
            categoryPanel.parent = "VUI"
            categoryPanel:Hide()
            
            -- Redirect to main panel with appropriate tab
            categoryPanel:SetScript("OnShow", function()
                -- Select the appropriate tab in the main panel
                InterfaceOptionsFrame_OpenToCategory("VUI")
                ConfigUI:SelectTab(tabID)
            end)
            
            InterfaceOptions_AddCategory(categoryPanel)
        end
    end
end

-- Add context-sensitive help to a frame
function ConfigUI:AddContextHelp(frame, helpText)
    if not VUI.db.profile.configUI.showContextHelp then return end
    
    local helpIcon = frame:CreateTexture(nil, "OVERLAY")
    helpIcon:SetSize(HELP_ICON_SIZE, HELP_ICON_SIZE)
    helpIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    helpIcon:SetTexture("Interface\\FriendsFrame\\InformationIcon")
    
    -- Create the tooltip functionality
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(helpText)
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return helpIcon
end

-- Update and refresh configuration UI
function ConfigUI:Refresh()
    -- Update all visible elements to reflect current settings
    local currentTab = VUI.db.profile.configUI.lastTab
    if currentTab and tabFrames[currentTab] then
        self:UpdatePreview(currentTab)
    end
end