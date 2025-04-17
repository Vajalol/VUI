-- VUI Dashboard Main Panel
local _, VUI = ...

-- Create the Dashboard module
VUI.Dashboard = {}

-- Default settings
VUI.Dashboard.defaults = {
    enabled = true,
    scale = 1.0,
    position = { x = 0, y = 0 },
    width = 800,
    height = 600,
    autoHide = false,
    showModuleCards = true,
    showStatusDisplay = true,
    showCategoryFilters = true,
    showSearchBar = true,
    showPerformanceMonitor = true,
    showQuickButtons = true,
    theme = "dark", -- dark or light
    compactView = false,
    cardSize = "medium", -- small, medium, large
    activeCategory = "all" -- all, core, ui, tools, addon
}

-- Dashboard panel reference
local Dashboard = VUI.Dashboard
local panel = nil
local moduleCards = {}
local statusWidgets = {}

-- Constants
local HEADER_HEIGHT = 40
local CARD_WIDTH = 175
local CARD_HEIGHT = 90
local CARD_MARGIN = 10
local PANEL_PADDING = 20
local STATUS_HEIGHT = 30
local FILTER_BAR_HEIGHT = 36
local SEARCH_BAR_WIDTH = 200
local PERFORMANCE_WIDGET_WIDTH = 200

-- Module categories
local MODULE_CATEGORIES = {
    ["Core"] = {"Core", "ModuleAPI", "Integration"},
    ["UI"] = {"UnitFrames", "ActionBars", "Skins", "VisualConfig"},
    ["Tools"] = {"Profiles", "Automation", "Performance"},
    ["Addons"] = {"AngryKeystone", "Auctionator", "BuffOverlay", "idTip", "MoveAny", "OmniCC", "OmniCD", "TrufiGCD", "PremadeGroupFinder"}
}

-- Initialize module
function Dashboard:Initialize()
    -- Initialize dashboard components
    self:SetupFrame()
    
    -- Create filter and search components if enabled
    if VUI.db.profile.dashboard.showCategoryFilters then
        self:CreateFilterBar()
    end
    
    if VUI.db.profile.dashboard.showSearchBar then
        self:CreateSearchBar()
    end
    
    if VUI.db.profile.dashboard.showPerformanceMonitor then
        self:CreatePerformanceMonitor()
    end
    
    if VUI.db.profile.dashboard.showQuickButtons then
        self:CreateQuickButtons()
    end
    
    -- Create module cards and status display
    self:CreateModuleCards()
    self:CreateStatusDisplay()
    
    -- Register slash commands
    self:RegisterSlashCommands()
    
    -- Print initialization message
    VUI:Print("Dashboard module initialized")
    
    -- Enable if set in profile
    if VUI.db.profile.dashboard.enabled then
        self:Enable()
    end
end

-- Enable module
function Dashboard:Enable()
    self.enabled = true
    
    -- Show the panel if not auto-hiding
    if not VUI.db.profile.dashboard.autoHide then
        self:Show()
    end
    
    VUI:Print("Dashboard module enabled")
end

-- Disable module
function Dashboard:Disable()
    self.enabled = false
    
    -- Hide the panel
    self:Hide()
    
    VUI:Print("Dashboard module disabled")
end

-- Set up the main dashboard frame
function Dashboard:SetupFrame()
    -- Create the main panel frame
    panel = CreateFrame("Frame", "VUIDashboardPanel", UIParent, "BackdropTemplate")
    panel:SetSize(VUI.db.profile.dashboard.width, VUI.db.profile.dashboard.height)
    panel:SetPoint("CENTER", UIParent, "CENTER", VUI.db.profile.dashboard.position.x, VUI.db.profile.dashboard.position.y)
    panel:SetScale(VUI.db.profile.dashboard.scale)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(1)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local uiParentX, uiParentY = UIParent:GetCenter()
        VUI.db.profile.dashboard.position.x = x - uiParentX
        VUI.db.profile.dashboard.position.y = y - uiParentY
    end)
    
    -- Set backdrop
    local theme = VUI.db.profile.dashboard.theme
    panel:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-" .. theme .. ".tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Create header
    local header = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    header:SetSize(panel:GetWidth(), HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    header:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-solid.tga",
        edgeFile = nil,
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    header:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    
    -- Logo and title
    local logo = header:CreateTexture(nil, "OVERLAY")
    logo:SetSize(32, 32)
    logo:SetPoint("LEFT", header, "LEFT", 10, 0)
    logo:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\logo.tga")
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 10, 0)
    title:SetText("VUI Dashboard")
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeButton:SetPoint("RIGHT", header, "RIGHT", -5, 0)
    closeButton:SetSize(24, 24)
    closeButton:SetScript("OnClick", function() Dashboard:Hide() end)
    
    -- Settings button
    local settingsButton = CreateFrame("Button", nil, header)
    settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -5, 0)
    settingsButton:SetSize(24, 24)
    settingsButton:SetNormalTexture("Interface\\AddOns\\VUI\\media\\Icons\\SUI.tga")
    settingsButton:GetNormalTexture():SetTexCoord(0.75, 1, 0, 0.25) -- Settings icon portion
    settingsButton:SetScript("OnClick", function() 
        InterfaceOptionsFrame_OpenToCategory("VUI")
        InterfaceOptionsFrame_OpenToCategory("VUI") -- Call twice to ensure it opens (WoW bug)
    end)
    
    -- Save panel reference
    self.panel = panel
    self.header = header
    
    -- Hide by default
    panel:Hide()
end

-- Create module cards
function Dashboard:CreateModuleCards()
    -- Get module list from VUI
    local modules = {}
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and name ~= "Dashboard" and type(name) == "string" then
            table.insert(modules, {name = name, module = module})
        end
    end
    
    -- Sort modules alphabetically
    table.sort(modules, function(a, b) return a.name < b.name end)
    
    -- Calculate layout
    local contentWidth = self.panel:GetWidth() - (2 * PANEL_PADDING)
    local cardsPerRow = math.floor(contentWidth / (CARD_WIDTH + CARD_MARGIN))
    local totalRows = math.ceil(#modules / cardsPerRow)
    
    -- Create container for scrolling
    local scrollFrame = CreateFrame("ScrollFrame", nil, self.panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", self.panel, "TOPLEFT", PANEL_PADDING, -(HEADER_HEIGHT + 5))
    scrollFrame:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -PANEL_PADDING - 20, STATUS_HEIGHT + PANEL_PADDING)
    
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(contentWidth, totalRows * (CARD_HEIGHT + CARD_MARGIN))
    scrollFrame:SetScrollChild(contentFrame)
    
    -- Create cards for each module
    for i, moduleInfo in ipairs(modules) do
        local row = math.ceil(i / cardsPerRow) - 1
        local col = (i - 1) % cardsPerRow
        
        local x = col * (CARD_WIDTH + CARD_MARGIN)
        local y = -row * (CARD_HEIGHT + CARD_MARGIN)
        
        -- Create card frame
        local card = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
        card:SetSize(CARD_WIDTH, CARD_HEIGHT)
        card:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", x, y)
        card:SetBackdrop({
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-solid.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\border-simple.tga",
            tile = false,
            tileSize = 0,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        card:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        
        -- Module name
        local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOP", card, "TOP", 0, -10)
        name:SetText(moduleInfo.name)
        
        -- Status indicator
        local statusTexture = card:CreateTexture(nil, "OVERLAY")
        statusTexture:SetSize(16, 16)
        statusTexture:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)
        statusTexture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\glow.tga")
        
        -- Update status color based on module enabled state
        local isModuleEnabled = VUI.db.profile.modules[moduleInfo.name:lower()] 
            and VUI.db.profile.modules[moduleInfo.name:lower()].enabled
        statusTexture:SetVertexColor(isModuleEnabled and 0.2 or 0.7, isModuleEnabled and 0.8 or 0.2, 0.2, 1)
        
        -- Toggle button
        local toggleButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        toggleButton:SetSize(80, 22)
        toggleButton:SetPoint("BOTTOM", card, "BOTTOM", 0, 10)
        toggleButton:SetText(isModuleEnabled and "Disable" or "Enable")
        toggleButton:SetScript("OnClick", function(self)
            local module = moduleInfo.module
            local moduleNameLower = moduleInfo.name:lower()
            
            if VUI.db.profile.modules[moduleNameLower] and VUI.db.profile.modules[moduleNameLower].enabled then
                -- Disable module
                VUI.db.profile.modules[moduleNameLower].enabled = false
                if module.Disable then module:Disable() end
                self:SetText("Enable")
                statusTexture:SetVertexColor(0.7, 0.2, 0.2, 1)
            else
                -- Enable module
                if not VUI.db.profile.modules[moduleNameLower] then
                    VUI.db.profile.modules[moduleNameLower] = {}
                end
                VUI.db.profile.modules[moduleNameLower].enabled = true
                if module.Enable then module:Enable() end
                self:SetText("Disable")
                statusTexture:SetVertexColor(0.2, 0.8, 0.2, 1)
            end
        end)
        
        -- Config button
        local configButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        configButton:SetSize(22, 22)
        configButton:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 10)
        configButton:SetText("⚙")
        configButton:SetScript("OnClick", function()
            InterfaceOptionsFrame_OpenToCategory("VUI")
            InterfaceOptionsFrame_OpenToCategory("VUI") -- Call twice to ensure it opens (WoW bug)
            -- TODO: Open specific module config page
        end)
        
        -- Store card reference
        moduleCards[moduleInfo.name] = {
            frame = card,
            status = statusTexture,
            toggleButton = toggleButton
        }
    end
    
    -- Save references
    self.scrollFrame = scrollFrame
    self.contentFrame = contentFrame
end

-- Create status display
function Dashboard:CreateStatusDisplay()
    -- Create status bar at bottom
    local statusBar = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    statusBar:SetSize(self.panel:GetWidth(), STATUS_HEIGHT)
    statusBar:SetPoint("BOTTOMLEFT", self.panel, "BOTTOMLEFT", 0, 0)
    statusBar:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-solid.tga",
        edgeFile = nil,
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    statusBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    
    -- Version info
    local versionText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    versionText:SetPoint("LEFT", statusBar, "LEFT", 10, 0)
    versionText:SetText("VUI v" .. (VUI.version or "0.0.1"))
    
    -- Active modules count
    local activeModules = 0
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" then
            local moduleName = name:lower()
            if VUI.db.profile.modules[moduleName] and VUI.db.profile.modules[moduleName].enabled then
                activeModules = activeModules + 1
            end
        end
    end
    
    local activeText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activeText:SetPoint("RIGHT", statusBar, "RIGHT", -10, 0)
    activeText:SetText("Active Modules: " .. activeModules)
    
    -- Store references
    self.statusBar = statusBar
    statusWidgets.version = versionText
    statusWidgets.active = activeText
end

-- Register slash commands
function Dashboard:RegisterSlashCommands()
    -- Register slash command to toggle dashboard
    SLASH_VUIDASHBOARD1 = "/vui"
    SLASH_VUIDASHBOARD2 = "/vuidash"
    SlashCmdList["VUIDASHBOARD"] = function(msg)
        if msg and msg:lower() == "config" then
            InterfaceOptionsFrame_OpenToCategory("VUI")
            InterfaceOptionsFrame_OpenToCategory("VUI") -- Call twice to ensure it opens (WoW bug)
        else
            Dashboard:Toggle()
        end
    end
end

-- Create filter bar for module categories
function Dashboard:CreateFilterBar()
    -- Create filter bar frame
    local filterBar = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    filterBar:SetSize(self.panel:GetWidth(), FILTER_BAR_HEIGHT)
    filterBar:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, 0)
    filterBar:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-solid.tga",
        edgeFile = nil,
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    filterBar:SetBackdropColor(0.15, 0.15, 0.15, 0.7)
    
    -- Create category buttons
    local buttonWidth = 80
    local padding = 10
    local xOffset = padding
    
    -- All modules button
    local allButton = CreateFrame("Button", nil, filterBar, "UIPanelButtonTemplate")
    allButton:SetSize(buttonWidth, FILTER_BAR_HEIGHT - 10)
    allButton:SetPoint("LEFT", filterBar, "LEFT", xOffset, 0)
    allButton:SetText("All")
    if VUI.db.profile.dashboard.activeCategory == "all" then
        allButton:SetButtonState("PUSHED", true)
    end
    allButton:SetScript("OnClick", function()
        VUI.db.profile.dashboard.activeCategory = "all"
        self:FilterModules("all")
        self:UpdateCategoryButtons()
    end)
    
    xOffset = xOffset + buttonWidth + padding
    
    -- Core modules button
    local coreButton = CreateFrame("Button", nil, filterBar, "UIPanelButtonTemplate")
    coreButton:SetSize(buttonWidth, FILTER_BAR_HEIGHT - 10)
    coreButton:SetPoint("LEFT", filterBar, "LEFT", xOffset, 0)
    coreButton:SetText("Core")
    if VUI.db.profile.dashboard.activeCategory == "core" then
        coreButton:SetButtonState("PUSHED", true)
    end
    coreButton:SetScript("OnClick", function()
        VUI.db.profile.dashboard.activeCategory = "core"
        self:FilterModules("Core")
        self:UpdateCategoryButtons()
    end)
    
    xOffset = xOffset + buttonWidth + padding
    
    -- UI modules button
    local uiButton = CreateFrame("Button", nil, filterBar, "UIPanelButtonTemplate")
    uiButton:SetSize(buttonWidth, FILTER_BAR_HEIGHT - 10)
    uiButton:SetPoint("LEFT", filterBar, "LEFT", xOffset, 0)
    uiButton:SetText("UI")
    if VUI.db.profile.dashboard.activeCategory == "ui" then
        uiButton:SetButtonState("PUSHED", true)
    end
    uiButton:SetScript("OnClick", function()
        VUI.db.profile.dashboard.activeCategory = "ui"
        self:FilterModules("UI")
        self:UpdateCategoryButtons()
    end)
    
    xOffset = xOffset + buttonWidth + padding
    
    -- Tools modules button
    local toolsButton = CreateFrame("Button", nil, filterBar, "UIPanelButtonTemplate")
    toolsButton:SetSize(buttonWidth, FILTER_BAR_HEIGHT - 10)
    toolsButton:SetPoint("LEFT", filterBar, "LEFT", xOffset, 0)
    toolsButton:SetText("Tools")
    if VUI.db.profile.dashboard.activeCategory == "tools" then
        toolsButton:SetButtonState("PUSHED", true)
    end
    toolsButton:SetScript("OnClick", function()
        VUI.db.profile.dashboard.activeCategory = "tools"
        self:FilterModules("Tools")
        self:UpdateCategoryButtons()
    end)
    
    xOffset = xOffset + buttonWidth + padding
    
    -- Addon modules button
    local addonButton = CreateFrame("Button", nil, filterBar, "UIPanelButtonTemplate")
    addonButton:SetSize(buttonWidth, FILTER_BAR_HEIGHT - 10)
    addonButton:SetPoint("LEFT", filterBar, "LEFT", xOffset, 0)
    addonButton:SetText("Addons")
    if VUI.db.profile.dashboard.activeCategory == "addon" then
        addonButton:SetButtonState("PUSHED", true)
    end
    addonButton:SetScript("OnClick", function()
        VUI.db.profile.dashboard.activeCategory = "addon"
        self:FilterModules("Addons")
        self:UpdateCategoryButtons()
    end)
    
    -- Store references
    self.filterBar = filterBar
    self.categoryButtons = {
        all = allButton,
        core = coreButton,
        ui = uiButton,
        tools = toolsButton,
        addon = addonButton
    }
end

-- Create search bar
function Dashboard:CreateSearchBar()
    -- Create search bar frame
    local searchBar = CreateFrame("EditBox", nil, self.panel, "InputBoxTemplate")
    searchBar:SetSize(SEARCH_BAR_WIDTH, 20)
    searchBar:SetPoint("TOPRIGHT", self.panel, "TOPRIGHT", -PANEL_PADDING - 20, -(HEADER_HEIGHT + 8))
    searchBar:SetAutoFocus(false)
    searchBar:SetText("Search modules...")
    searchBar:SetTextColor(0.7, 0.7, 0.7)
    
    -- Focus behavior
    searchBar:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "Search modules..." then
            self:SetText("")
            self:SetTextColor(1, 1, 1)
        end
    end)
    
    searchBar:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText("Search modules...")
            self:SetTextColor(0.7, 0.7, 0.7)
        end
    end)
    
    -- Search functionality
    searchBar:SetScript("OnTextChanged", function(self)
        local searchText = self:GetText()
        if searchText == "Search modules..." then return end
        
        -- Perform search
        Dashboard:SearchModules(searchText)
    end)
    
    -- Store reference
    self.searchBar = searchBar
end

-- Create performance monitor widget
function Dashboard:CreatePerformanceMonitor()
    -- Create frame for performance info
    local perfFrame = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    perfFrame:SetSize(PERFORMANCE_WIDGET_WIDTH, FILTER_BAR_HEIGHT - 10)
    perfFrame:SetPoint("RIGHT", self.panel, "TOPRIGHT", -PANEL_PADDING, -(HEADER_HEIGHT + 13))
    perfFrame:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-solid.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    perfFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
    perfFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Create fps text
    local fpsText = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fpsText:SetPoint("LEFT", perfFrame, "LEFT", 10, 0)
    fpsText:SetText("FPS: --")
    
    -- Create memory text
    local memoryText = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    memoryText:SetPoint("RIGHT", perfFrame, "RIGHT", -10, 0)
    memoryText:SetText("Memory: --")
    
    -- Update performance info every second
    local updateTimer = 0
    perfFrame:SetScript("OnUpdate", function(self, elapsed)
        updateTimer = updateTimer + elapsed
        if updateTimer >= 1.0 then
            -- Update FPS display
            local fps = GetFramerate()
            fpsText:SetText(string.format("FPS: %.1f", fps))
            fpsText:SetTextColor(
                fps < 20 and 1.0 or 0.1,
                fps > 30 and 1.0 or (fps > 20 and 0.7 or 0.1),
                0.1
            )
            
            -- Update memory usage
            local addonMemory = 0
            UpdateAddOnMemoryUsage()
            for i = 1, GetNumAddOns() do
                addonMemory = addonMemory + GetAddOnMemoryUsage(i)
            end
            
            local totalMB = addonMemory / 1024
            if totalMB > 50 then
                memoryText:SetTextColor(1.0, 0.1, 0.1)
            elseif totalMB > 25 then
                memoryText:SetTextColor(1.0, 0.7, 0.1)
            else
                memoryText:SetTextColor(0.1, 1.0, 0.1)
            end
            
            memoryText:SetText(string.format("Memory: %.1f MB", totalMB))
            
            updateTimer = 0
        end
    end)
    
    -- Store reference
    self.performanceFrame = perfFrame
end

-- Create quick access buttons
function Dashboard:CreateQuickButtons()
    -- Create quick buttons container
    local quickButtons = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    quickButtons:SetSize(self.panel:GetWidth() - 40, 30)
    quickButtons:SetPoint("BOTTOMLEFT", self.panel, "BOTTOMLEFT", PANEL_PADDING, STATUS_HEIGHT + 5)
    
    -- Create some useful quick action buttons
    local buttonWidth = 100
    local buttonHeight = 24
    local spacing = 10
    local xOffset = 0
    
    -- Reload UI button
    local reloadButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    reloadButton:SetSize(buttonWidth, buttonHeight)
    reloadButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    reloadButton:SetText("Reload UI")
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Toggle All button
    local toggleAllButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    toggleAllButton:SetSize(buttonWidth, buttonHeight)
    toggleAllButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    toggleAllButton:SetText("Toggle All")
    toggleAllButton:SetScript("OnClick", function()
        -- Count enabled modules
        local enabledCount = 0
        local totalCount = 0
        
        for name, module in pairs(VUI) do
            if type(module) == "table" and module.Initialize and name ~= "Dashboard" and type(name) == "string" then
                totalCount = totalCount + 1
                local moduleName = name:lower()
                if VUI.db.profile.modules[moduleName] and VUI.db.profile.modules[moduleName].enabled then
                    enabledCount = enabledCount + 1
                end
            end
        end
        
        -- If more than half are enabled, disable all. Otherwise, enable all.
        local enableAll = (enabledCount <= totalCount / 2)
        
        for name, module in pairs(VUI) do
            if type(module) == "table" and module.Initialize and name ~= "Dashboard" and type(name) == "string" then
                local moduleName = name:lower()
                
                if enableAll then
                    -- Enable module
                    if not VUI.db.profile.modules[moduleName] then
                        VUI.db.profile.modules[moduleName] = {}
                    end
                    VUI.db.profile.modules[moduleName].enabled = true
                    if module.Enable then module:Enable() end
                else
                    -- Disable module
                    if VUI.db.profile.modules[moduleName] then
                        VUI.db.profile.modules[moduleName].enabled = false
                        if module.Disable then module:Disable() end
                    end
                end
            end
        end
        
        -- Update UI
        Dashboard:UpdateModuleStatus()
    end)
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Memory cleanup button
    local cleanupButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    cleanupButton:SetSize(buttonWidth, buttonHeight)
    cleanupButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    cleanupButton:SetText("Clear Memory")
    cleanupButton:SetScript("OnClick", function()
        collectgarbage("collect")
        VUI:Print("Memory cleanup performed")
    end)
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Toggle theme button
    local themeButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    themeButton:SetSize(buttonWidth, buttonHeight)
    themeButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    themeButton:SetText("Toggle Theme")
    themeButton:SetScript("OnClick", function()
        if VUI.db.profile.dashboard.theme == "dark" then
            VUI.db.profile.dashboard.theme = "light"
        else
            VUI.db.profile.dashboard.theme = "dark"
        end
        Dashboard:Refresh()
    end)
    
    -- Store reference
    self.quickButtons = quickButtons
end

-- Filter modules by category
function Dashboard:FilterModules(category)
    if not self.contentFrame then return end
    
    -- Get the list of modules in this category
    local categoryModules = {}
    
    if category == "all" then
        -- Show all modules
        for name, card in pairs(moduleCards) do
            card.frame:Show()
        end
    else
        -- Get the list of modules in this category
        if MODULE_CATEGORIES[category] then
            categoryModules = MODULE_CATEGORIES[category]
            
            -- Hide all cards first
            for name, card in pairs(moduleCards) do
                card.frame:Hide()
            end
            
            -- Show only cards in the selected category
            for _, moduleName in ipairs(categoryModules) do
                if moduleCards[moduleName] then
                    moduleCards[moduleName].frame:Show()
                end
            end
        end
    end
    
    -- Update scrollframe size
    self:UpdateScrollFrameSize()
end

-- Search modules by text
function Dashboard:SearchModules(searchText)
    if not self.contentFrame or not searchText then return end
    
    searchText = searchText:lower()
    
    -- If search is empty, show all cards (or filtered by category)
    if searchText == "" then
        self:FilterModules(VUI.db.profile.dashboard.activeCategory)
        return
    end
    
    -- Hide all cards first
    for name, card in pairs(moduleCards) do
        card.frame:Hide()
    end
    
    -- Show matching cards
    for name, card in pairs(moduleCards) do
        if name:lower():find(searchText) then
            card.frame:Show()
        end
    end
    
    -- Update scrollframe size
    self:UpdateScrollFrameSize()
end

-- Update category filter buttons
function Dashboard:UpdateCategoryButtons()
    if not self.categoryButtons then return end
    
    local activeCategory = VUI.db.profile.dashboard.activeCategory
    
    for category, button in pairs(self.categoryButtons) do
        if category == activeCategory then
            button:SetButtonState("PUSHED", true)
        else
            button:SetButtonState("NORMAL", false)
        end
    end
end

-- Update scroll frame size based on visible cards
function Dashboard:UpdateScrollFrameSize()
    if not self.contentFrame then return end
    
    -- Count visible cards
    local visibleCards = 0
    for name, card in pairs(moduleCards) do
        if card.frame:IsShown() then
            visibleCards = visibleCards + 1
        end
    end
    
    -- Calculate layout
    local contentWidth = self.panel:GetWidth() - (2 * PANEL_PADDING)
    local cardsPerRow = math.floor(contentWidth / (CARD_WIDTH + CARD_MARGIN))
    local totalRows = math.ceil(visibleCards / cardsPerRow)
    
    -- Update content frame height
    self.contentFrame:SetHeight(math.max(totalRows * (CARD_HEIGHT + CARD_MARGIN), 100))
end

-- Show dashboard
function Dashboard:Show()
    if not self.enabled then return end
    if not self.panel then
        self:SetupFrame()
        
        -- Create filter and search components if enabled
        if VUI.db.profile.dashboard.showCategoryFilters then
            self:CreateFilterBar()
        end
        
        if VUI.db.profile.dashboard.showSearchBar then
            self:CreateSearchBar()
        end
        
        if VUI.db.profile.dashboard.showPerformanceMonitor then
            self:CreatePerformanceMonitor()
        end
        
        if VUI.db.profile.dashboard.showQuickButtons then
            self:CreateQuickButtons()
        end
        
        self:CreateModuleCards()
        self:CreateStatusDisplay()
    end
    
    -- Apply filter based on active category
    self:FilterModules(VUI.db.profile.dashboard.activeCategory)
    
    self.panel:Show()
end

-- Hide dashboard
function Dashboard:Hide()
    if self.panel then
        self.panel:Hide()
    end
end

-- Toggle dashboard visibility
function Dashboard:Toggle()
    if not self.panel then
        self:Show()
        return
    end
    
    if self.panel:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Update all modules status
function Dashboard:UpdateModuleStatus()
    for name, card in pairs(moduleCards) do
        local moduleName = name:lower()
        local isEnabled = VUI.db.profile.modules[moduleName] and VUI.db.profile.modules[moduleName].enabled
        
        card.toggleButton:SetText(isEnabled and "Disable" or "Enable")
        card.status:SetVertexColor(isEnabled and 0.2 or 0.7, isEnabled and 0.8 or 0.2, 0.2, 1)
    end
    
    -- Update active modules count
    local activeModules = 0
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" then
            local moduleName = name:lower()
            if VUI.db.profile.modules[moduleName] and VUI.db.profile.modules[moduleName].enabled then
                activeModules = activeModules + 1
            end
        end
    end
    
    if statusWidgets.active then
        statusWidgets.active:SetText("Active Modules: " .. activeModules)
    end
end

-- Refresh dashboard UI (call when settings change)
function Dashboard:Refresh()
    if not self.panel then return end
    
    -- Update size and position
    self.panel:SetSize(VUI.db.profile.dashboard.width, VUI.db.profile.dashboard.height)
    self.panel:SetPoint("CENTER", UIParent, "CENTER", VUI.db.profile.dashboard.position.x, VUI.db.profile.dashboard.position.y)
    self.panel:SetScale(VUI.db.profile.dashboard.scale)
    
    -- Update theme
    local theme = VUI.db.profile.dashboard.theme
    self.panel:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\background-" .. theme .. ".tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Update module status
    self:UpdateModuleStatus()
end