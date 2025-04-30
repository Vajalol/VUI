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
    theme = "thunderstorm", -- thunderstorm or light
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
    ["UI"] = {"unitframes", "ActionBars", "skins", "visualconfig"},
    ["Tools"] = {"profiles", "automation", "Performance"},
    ["Addons"] = {"angrykeystone", "auctionator", "buffoverlay", "idtip", "moveany", "omnicc", "omnicd", "trufigcd", "premadegroupfinder"}
}

-- Registered modules
local registeredModules = {}

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
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
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
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
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
    logo:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\logo.tga")
    
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
    settingsButton:SetNormalTexture("Interface\\AddOns\\VUI\\media\\icons\\common\\settings.tga")
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
    -- Combine traditional modules with registered modules
    local allModules = {}
    
    -- Add traditional modules from VUI table
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and name ~= "Dashboard" and type(name) == "string" then
            allModules[name] = {
                name = name,
                module = module,
                registered = false
            }
        end
    end
    
    -- Add modules from the registry if available
    if VUI.ModuleRegistry and VUI.ModuleRegistry.modules then
        for name, metadata in pairs(VUI.ModuleRegistry.modules) do
            if not allModules[name] then
                allModules[name] = {
                    name = name,
                    module = VUI[name],
                    metadata = metadata,
                    registered = true
                }
            end
        end
    end
    
    -- Add registered modules from old system (for backward compatibility)
    for name, options in pairs(registeredModules) do
        allModules[name] = {
            name = name,
            options = options,
            registered = true
        }
    end
    
    -- Convert to list for sorting
    local modules = {}
    for _, moduleInfo in pairs(allModules) do
        table.insert(modules, moduleInfo)
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
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
            tile = false,
            tileSize = 0,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        card:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        
        -- Module icon
        local icon = card:CreateTexture(nil, "OVERLAY")
        icon:SetSize(24, 24)
        icon:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -10)
        icon:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\logo.tga") -- Default icon
        
        -- Module name
        local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOP", card, "TOP", 0, -10)
        name:SetText(moduleInfo.name)
        
        -- Status indicator
        local statusTexture = card:CreateTexture(nil, "OVERLAY")
        statusTexture:SetSize(16, 16)
        statusTexture:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)
        statusTexture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\glow.tga")
        
        -- Description text
        local description = card:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        description:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, -2)
        description:SetPoint("TOPRIGHT", statusTexture, "TOPLEFT", -5, 0)
        description:SetJustifyH("LEFT")
        description:SetWordWrap(true)
        
        -- Toggle button
        local toggleButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        toggleButton:SetSize(80, 22)
        toggleButton:SetPoint("BOTTOM", card, "BOTTOM", 0, 10)
        
        -- Config button
        local configButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        configButton:SetSize(22, 22)
        configButton:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 10)
        configButton:SetText("⚙")
        
        if moduleInfo.registered then
            -- Handle registered module
            local options = moduleInfo.options
            
            -- Set icon if provided
            if options.icon then
                icon:SetTexture(options.icon)
            end
            
            -- Set description
            description:SetText(options.description or "")
            
            -- Get module status
            local status = options.getStatus()
            
            -- Update status indicator
            statusTexture:SetVertexColor(status.enabled and 0.2 or 0.7, status.enabled and 0.8 or 0.2, 0.2, 1)
            
            -- Update toggle button
            toggleButton:SetText(status.enabled and "Disable" or "Enable")
            
            -- Set up config button
            configButton:SetScript("OnClick", options.config)
            
            -- Add status information if available
            if status.active and status.total then
                local statusText = card:CreateFontString(nil, "OVERLAY", "GameFontSmall")
                statusText:SetPoint("BOTTOM", toggleButton, "TOP", 0, 5)
                statusText:SetText(status.active .. " / " .. status.total .. " active")
                statusText:SetTextColor(0.7, 0.7, 0.7)
            end
        else
            -- Handle traditional module
            local module = moduleInfo.module
            local moduleNameLower = moduleInfo.name:lower()
            
            -- Set description (placeholder)
            description:SetText("Core VUI module")
            
            -- Update status based on module enabled state
            local isModuleEnabled = VUI.db.profile.modules[moduleNameLower] and VUI.db.profile.modules[moduleNameLower].enabled
            statusTexture:SetVertexColor(isModuleEnabled and 0.2 or 0.7, isModuleEnabled and 0.8 or 0.2, 0.2, 1)
            
            -- Configure toggle button
            toggleButton:SetText(isModuleEnabled and "Disable" or "Enable")
            toggleButton:SetScript("OnClick", function(self)
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
                
                -- Update status display
                Dashboard:UpdateModuleStatus()
            end)
            
            -- Configure settings button
            configButton:SetScript("OnClick", function()
                -- Try to open module-specific config, or fallback to main config
                InterfaceOptionsFrame_OpenToCategory("VUI " .. moduleInfo.name)
                if not InterfaceOptionsFrame:IsShown() then
                    InterfaceOptionsFrame_OpenToCategory("VUI")
                end
            end)
        end
        
        -- Store card reference
        moduleCards[moduleInfo.name] = {
            frame = card,
            status = statusTexture,
            toggleButton = toggleButton,
            icon = icon,
            description = description
        }
    end
    
    -- Save references
    self.scrollFrame = scrollFrame
    self.contentFrame = contentFrame
    
    -- Apply initial category filter
    if VUI.db.profile.dashboard.activeCategory then
        self:FilterModules(VUI.db.profile.dashboard.activeCategory)
    else
        self:FilterModules("all")
    end
end

-- Create status display
function Dashboard:CreateStatusDisplay()
    -- Create status bar at bottom
    local statusBar = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    statusBar:SetSize(self.panel:GetWidth(), STATUS_HEIGHT)
    statusBar:SetPoint("BOTTOMLEFT", self.panel, "BOTTOMLEFT", 0, 0)
    statusBar:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
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

-- Update module cards display (recreate the cards)
function Dashboard:UpdateModuleCards()
    -- Remove existing cards if any
    if self.contentFrame then
        self.contentFrame:SetParent(nil)
        self.contentFrame = nil
    end
    
    if self.scrollFrame then
        self.scrollFrame:SetParent(nil)
        self.scrollFrame = nil
    end
    
    moduleCards = {}
    
    -- Recreate all cards
    self:CreateModuleCards()
    
    -- Update status display
    self:UpdateModuleStatus()
end

-- Register a module with the dashboard
function Dashboard:RegisterModule(name, options)
    if not name or not options then return end
    
    -- Default options
    options.icon = options.icon or "Interface\\AddOns\\VUI\\media\\textures\\common\\logo.tga"
    options.description = options.description or "No description provided"
    options.category = options.category or "Core"
    options.config = options.config or function() end
    options.getStatus = options.getStatus or function() return {enabled = false} end
    
    -- Register the module
    registeredModules[name] = options
    
    -- Refresh the dashboard if it's open
    if self.panel and self.panel:IsShown() then
        self:UpdateModuleCards()
    end
    
    return true
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
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
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
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
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
    
    -- Module Dashboard button
    local moduleButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    moduleButton:SetSize(buttonWidth, buttonHeight)
    moduleButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    moduleButton:SetText("Modules")
    moduleButton:SetScript("OnClick", function()
        -- Show module list using our simpler module helper
        if VUI.ModuleHelper then
            local modules = VUI.ModuleHelper:GetAllModules()
            VUI:Print("Available modules:")
            for _, module in ipairs(modules) do
                local status = module.enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
                VUI:Print("  - " .. module.name .. ": " .. status)
            end
        end
    end)
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Toggle All button
    local toggleAllButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    toggleAllButton:SetSize(buttonWidth, buttonHeight)
    toggleAllButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    toggleAllButton:SetText("Toggle All")
    toggleAllButton:SetScript("OnClick", function()
        -- Use ModuleHelper to toggle all modules
        if VUI.ModuleHelper then
            -- Get all modules
            local modules = VUI.ModuleHelper:GetAllModules()
            
            -- Count enabled modules
            local enabledCount = 0
            local totalCount = #modules
            
            for _, module in ipairs(modules) do
                if module.enabled then
                    enabledCount = enabledCount + 1
                end
            end
            
            -- If more than half are enabled, disable all. Otherwise, enable all.
            local enableAll = (enabledCount <= totalCount / 2)
            
            -- Toggle all modules
            for _, moduleInfo in ipairs(modules) do
                if enableAll then
                    VUI.ModuleHelper:EnableModule(moduleInfo.name)
                else
                    VUI.ModuleHelper:DisableModule(moduleInfo.name)
                end
            end
        else
            -- Fallback to original method
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
        end
        
        -- Update UI
        Dashboard:UpdateModuleStatus()
    end)
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Module manager button with dropdown
    local moduleManagerButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    moduleManagerButton:SetSize(buttonWidth, buttonHeight)
    moduleManagerButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    moduleManagerButton:SetText("Modules")
    
    -- Create module manager dropdown
    local moduleDropdown = CreateFrame("Frame", "VUIDashboardModuleDropdown", self.panel, "BackdropTemplate")
    moduleDropdown:SetSize(250, 300)
    moduleDropdown:SetPoint("BOTTOMLEFT", moduleManagerButton, "TOPLEFT", 0, 5)
    moduleDropdown:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    moduleDropdown:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Add title
    local title = moduleDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", moduleDropdown, "TOP", 0, -15)
    title:SetText("Quick Module Manager")
    
    -- Create scroll frame for module list
    local scrollFrame = CreateFrame("ScrollFrame", nil, moduleDropdown, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", moduleDropdown, "TOPLEFT", 15, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", moduleDropdown, "BOTTOMRIGHT", -35, 15)
    
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 500) -- Height will be adjusted based on content
    scrollFrame:SetScrollChild(contentFrame)
    
    -- Function to update the module list
    function self:UpdateModuleList()
        -- Clear existing content
        for i = 1, contentFrame:GetNumChildren() do
            local child = select(i, contentFrame:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
        
        -- Get modules from VUI table
        local modules = {}
        for name, module in pairs(VUI) do
            if type(module) == "table" and module.Initialize and type(name) == "string" and name ~= "Dashboard" then
                table.insert(modules, {name = name, module = module})
            end
        end
        
        -- Sort modules alphabetically
        table.sort(modules, function(a, b) return a.name < b.name end)
        
        -- Create toggles for each module
        local toggleHeight = 30
        local spacing = 5
        local yOffset = 0
        
        for i, moduleInfo in ipairs(modules) do
            local moduleName = moduleInfo.name
            local moduleLower = moduleName:lower()
            
            -- Check if module is enabled
            local isEnabled = VUI.db.profile.modules[moduleLower] and VUI.db.profile.modules[moduleLower].enabled
            
            -- Create toggle container
            local toggleContainer = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
            toggleContainer:SetSize(contentFrame:GetWidth() - 20, toggleHeight)
            toggleContainer:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
            
            -- Module name
            local nameText = toggleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", toggleContainer, "LEFT", 5, 0)
            nameText:SetText(moduleName)
            
            -- Toggle checkbox
            local checkbox = CreateFrame("CheckButton", nil, toggleContainer, "UICheckButtonTemplate")
            checkbox:SetSize(24, 24)
            checkbox:SetPoint("RIGHT", toggleContainer, "RIGHT", -5, 0)
            checkbox:SetChecked(isEnabled)
            
            checkbox:SetScript("OnClick", function(self)
                local isChecked = self:GetChecked()
                
                -- Update module status
                if not VUI.db.profile.modules[moduleLower] then
                    VUI.db.profile.modules[moduleLower] = {}
                end
                
                VUI.db.profile.modules[moduleLower].enabled = isChecked
                
                -- Enable or disable module
                if isChecked then
                    if moduleInfo.module.Enable then moduleInfo.module:Enable() end
                else
                    if moduleInfo.module.Disable then moduleInfo.module:Disable() end
                end
                
                -- Update dashboard UI
                Dashboard:UpdateModuleStatus()
            end)
            
            -- Config button
            local configButton = CreateFrame("Button", nil, toggleContainer, "UIPanelButtonTemplate")
            configButton:SetSize(50, 20)
            configButton:SetPoint("RIGHT", checkbox, "LEFT", -5, 0)
            configButton:SetText("Config")
            configButton:SetScript("OnClick", function()
                -- Try to open module-specific config
                InterfaceOptionsFrame_OpenToCategory("VUI " .. moduleName)
                if not InterfaceOptionsFrame:IsShown() then
                    InterfaceOptionsFrame_OpenToCategory("VUI")
                end
                moduleDropdown:Hide()
            end)
            
            -- Add separator line except for the last item
            if i < #modules then
                local separator = toggleContainer:CreateTexture(nil, "OVERLAY")
                separator:SetHeight(1)
                separator:SetPoint("BOTTOMLEFT", toggleContainer, "BOTTOMLEFT", 0, -2)
                separator:SetPoint("BOTTOMRIGHT", toggleContainer, "BOTTOMRIGHT", 0, -2)
                separator:SetColorTexture(0.3, 0.3, 0.3, 0.6)
            end
            
            yOffset = yOffset + toggleHeight + spacing
        end
        
        -- Update content frame height
        contentFrame:SetHeight(math.max(yOffset, scrollFrame:GetHeight()))
    end
    
    -- Initialize the module list
    self:UpdateModuleList()
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, moduleDropdown, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", moduleDropdown, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() moduleDropdown:Hide() end)
    
    -- Quick actions section
    local actionsTitle = moduleDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    actionsTitle:SetPoint("BOTTOM", moduleDropdown, "BOTTOM", 0, 40)
    actionsTitle:SetText("Quick Actions")
    
    -- Enable All button
    local enableAllBtn = CreateFrame("Button", nil, moduleDropdown, "UIPanelButtonTemplate")
    enableAllBtn:SetSize(80, 22)
    enableAllBtn:SetPoint("BOTTOMLEFT", moduleDropdown, "BOTTOMLEFT", 20, 15)
    enableAllBtn:SetText("Enable All")
    enableAllBtn:SetScript("OnClick", function()
        -- Use ModuleHelper if available
        if VUI.ModuleHelper then
            local modules = VUI.ModuleHelper:GetAllModules()
            for _, moduleInfo in ipairs(modules) do
                VUI.ModuleHelper:EnableModule(moduleInfo.name)
            end
        else
            -- Fallback to original code
            for name, module in pairs(VUI) do
                if type(module) == "table" and module.Initialize and name ~= "Dashboard" and type(name) == "string" then
                    local moduleName = name:lower()
                    if not VUI.db.profile.modules[moduleName] then
                        VUI.db.profile.modules[moduleName] = {}
                    end
                    VUI.db.profile.modules[moduleName].enabled = true
                    if module.Enable then module:Enable() end
                end
            end
        end
        -- Update UI
        self:UpdateModuleList()
        Dashboard:UpdateModuleStatus()
    end)
    
    -- Disable All button
    local disableAllBtn = CreateFrame("Button", nil, moduleDropdown, "UIPanelButtonTemplate")
    disableAllBtn:SetSize(80, 22)
    disableAllBtn:SetPoint("BOTTOMRIGHT", moduleDropdown, "BOTTOMRIGHT", -20, 15)
    disableAllBtn:SetText("Disable All")
    disableAllBtn:SetScript("OnClick", function()
        for name, module in pairs(VUI) do
            if type(module) == "table" and module.Initialize and name ~= "Dashboard" and type(name) == "string" then
                local moduleName = name:lower()
                if VUI.db.profile.modules[moduleName] then
                    VUI.db.profile.modules[moduleName].enabled = false
                    if module.Disable then module:Disable() end
                end
            end
        end
        -- Update UI
        self:UpdateModuleList()
        Dashboard:UpdateModuleStatus()
    end)
    
    -- Hide by default
    moduleDropdown:Hide()
    
    -- Show dropdown when the module manager button is clicked
    moduleManagerButton:SetScript("OnClick", function()
        if moduleDropdown:IsShown() then
            moduleDropdown:Hide()
        else
            -- Refresh module list
            self:UpdateModuleList()
            moduleDropdown:Show()
        end
    end)
    
    -- Store reference for later updates
    self.moduleDropdown = moduleDropdown
    
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
    
    -- Quick Tools button with dropdown
    local toolsButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    toolsButton:SetSize(buttonWidth, buttonHeight)
    toolsButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    toolsButton:SetText("Tools")
    
    -- Create tools dropdown
    local toolsDropdown = CreateFrame("Frame", "VUIDashboardToolsDropdown", self.panel, "BackdropTemplate")
    toolsDropdown:SetSize(200, 240)
    toolsDropdown:SetPoint("BOTTOMLEFT", toolsButton, "TOPLEFT", 0, 5)
    toolsDropdown:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    toolsDropdown:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Add title
    local title = toolsDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", toolsDropdown, "TOP", 0, -15)
    title:SetText("Quick Tools")
    
    -- Spell Management button
    local spellManagementButton = CreateFrame("Button", nil, toolsDropdown, "UIPanelButtonTemplate")
    spellManagementButton:SetSize(160, 24)
    spellManagementButton:SetPoint("TOP", title, "BOTTOM", 0, -20)
    spellManagementButton:SetText("Spell Management")
    spellManagementButton:SetScript("OnClick", function()
        -- Get SpellNotifications module
        local module = VUI:GetModule("SpellNotifications")
        if module and module.OpenSpellManagementUI then
            -- Close the dropdown
            toolsDropdown:Hide()
            -- Open the spell management UI
            module:OpenSpellManagementUI()
        else
            VUI:Print("SpellNotifications module not available")
        end
    end)
    
    -- Test Notification section
    local testNotificationLabel = toolsDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testNotificationLabel:SetPoint("TOP", spellManagementButton, "BOTTOM", 0, -15)
    testNotificationLabel:SetText("Test Spell Notification")
    
    -- Box to enter spell ID
    local spellIDBox = CreateFrame("EditBox", nil, toolsDropdown, "InputBoxTemplate")
    spellIDBox:SetSize(120, 20)
    spellIDBox:SetPoint("TOP", testNotificationLabel, "BOTTOM", 0, -5)
    spellIDBox:SetAutoFocus(false)
    spellIDBox:SetText("Enter spell ID...")
    spellIDBox:SetTextColor(0.7, 0.7, 0.7)
    
    -- Focus behavior
    spellIDBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "Enter spell ID..." then
            self:SetText("")
            self:SetTextColor(1, 1, 1)
        end
    end)
    
    spellIDBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText("Enter spell ID...")
            self:SetTextColor(0.7, 0.7, 0.7)
        end
    end)
    
    -- Test button
    local testButton = CreateFrame("Button", nil, toolsDropdown, "UIPanelButtonTemplate")
    testButton:SetSize(80, 22)
    testButton:SetPoint("TOP", spellIDBox, "BOTTOM", 0, -5)
    testButton:SetText("Test")
    testButton:SetScript("OnClick", function()
        local spellID = spellIDBox:GetText()
        if spellID and spellID ~= "Enter spell ID..." then
            spellID = tonumber(spellID)
            if spellID then
                -- Get SpellNotifications module
                local module = VUI:GetModule("SpellNotifications")
                if module and module.TestNotification then
                    -- Close the dropdown
                    toolsDropdown:Hide()
                    -- Test notification
                    module:TestNotification(spellID)
                    VUI:Print("Testing notification for spell ID: " .. spellID)
                else
                    VUI:Print("SpellNotifications module not available")
                end
            else
                VUI:Print("Please enter a valid spell ID")
            end
        else
            VUI:Print("Please enter a spell ID to test")
        end
    end)
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, toolsDropdown, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", toolsDropdown, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() toolsDropdown:Hide() end)
    
    -- Hide by default
    toolsDropdown:Hide()
    
    -- Show dropdown when the tools button is clicked
    toolsButton:SetScript("OnClick", function()
        if toolsDropdown:IsShown() then
            toolsDropdown:Hide()
        else
            toolsDropdown:Show()
        end
    end)
    
    -- Store reference for later updates
    self.toolsDropdown = toolsDropdown
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Profile management button with dropdown
    local profileButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    profileButton:SetSize(buttonWidth, buttonHeight)
    profileButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    profileButton:SetText("Profiles")
    
    -- Create profile dropdown
    local profileDropdown = CreateFrame("Frame", "VUIDashboardProfileDropdown", self.panel, "BackdropTemplate")
    profileDropdown:SetSize(200, 240)
    profileDropdown:SetPoint("BOTTOMLEFT", profileButton, "TOPLEFT", 0, 5)
    profileDropdown:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    profileDropdown:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Add title
    local title = profileDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", profileDropdown, "TOP", 0, -15)
    title:SetText("Profile Management")
    
    -- Current profile text
    local currentProfileText = profileDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentProfileText:SetPoint("TOP", title, "BOTTOM", 0, -15)
    currentProfileText:SetText("Current: " .. (VUI.db:GetCurrentProfile() or "Default"))
    currentProfileText:SetTextColor(0.7, 0.7, 1)
    
    -- Add new profile section
    local newProfileLabel = profileDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    newProfileLabel:SetPoint("TOPLEFT", profileDropdown, "TOPLEFT", 20, -60)
    newProfileLabel:SetText("Create new profile:")
    
    local newProfileBox = CreateFrame("EditBox", "VUINewProfileBox", profileDropdown, "InputBoxTemplate")
    newProfileBox:SetSize(120, 20)
    newProfileBox:SetPoint("TOPLEFT", newProfileLabel, "BOTTOMLEFT", 5, -5)
    newProfileBox:SetAutoFocus(false)
    newProfileBox:SetMaxLetters(20)
    
    local createButton = CreateFrame("Button", nil, profileDropdown, "UIPanelButtonTemplate")
    createButton:SetSize(80, 22)
    createButton:SetPoint("TOPLEFT", newProfileBox, "BOTTOMLEFT", 0, -5)
    createButton:SetText("Create")
    createButton:SetScript("OnClick", function()
        local profileName = newProfileBox:GetText()
        if profileName and profileName ~= "" then
            -- Create and switch to the new profile
            VUI.db:SetProfile(profileName)
            
            -- Update the display
            currentProfileText:SetText("Current: " .. (VUI.db:GetCurrentProfile() or "Default"))
            VUI:Print("Created and switched to profile: " .. profileName)
            newProfileBox:SetText("")
            
            -- Refresh dashboard to reflect the new profile settings
            Dashboard:Refresh()
            
            -- Update available profiles list
            self:UpdateProfileList(profileDropdown, currentProfileText)
        end
    end)
    
    -- Copy from section
    local copyLabel = profileDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    copyLabel:SetPoint("TOPLEFT", profileDropdown, "TOPLEFT", 20, -130)
    copyLabel:SetText("Copy from profile:")
    
    -- Add available profiles for copy/delete
    local profileListFrame = CreateFrame("Frame", nil, profileDropdown)
    profileListFrame:SetSize(160, 70)
    profileListFrame:SetPoint("TOP", copyLabel, "BOTTOM", 0, -5)
    
    -- Function to update profile list
    function self:UpdateProfileList(dropdown, currentText)
        -- Clear existing list items
        if profileListFrame.buttons then
            for _, button in ipairs(profileListFrame.buttons) do
                button:Hide()
                button:SetParent(nil)
            end
        end
        
        profileListFrame.buttons = {}
        
        -- Current profile name
        local currentProfile = VUI.db:GetCurrentProfile()
        currentText:SetText("Current: " .. (currentProfile or "Default"))
        
        -- Get profiles list
        local profiles = VUI.db:GetProfiles()
        table.sort(profiles)
        
        -- Create buttons for each profile
        local buttonHeight = 22
        local yOffset = 0
        
        for i, profile in ipairs(profiles) do
            if profile ~= currentProfile then
                -- Profile button
                local profileButton = CreateFrame("Button", nil, profileListFrame, "UIPanelButtonTemplate")
                profileButton:SetSize(100, 20)
                profileButton:SetPoint("TOPLEFT", profileListFrame, "TOPLEFT", 0, -yOffset)
                profileButton:SetText(profile)
                
                -- Copy button
                local copyBtn = CreateFrame("Button", nil, profileListFrame, "UIPanelButtonTemplate")
                copyBtn:SetSize(22, 20)
                copyBtn:SetPoint("LEFT", profileButton, "RIGHT", 2, 0)
                copyBtn:SetText("C")
                copyBtn:SetScript("OnClick", function()
                    VUI.db:CopyProfile(profile)
                    VUI:Print("Copied settings from profile: " .. profile)
                    Dashboard:Refresh()
                end)
                
                -- Delete button
                local deleteBtn = CreateFrame("Button", nil, profileListFrame, "UIPanelButtonTemplate")
                deleteBtn:SetSize(22, 20)
                deleteBtn:SetPoint("LEFT", copyBtn, "RIGHT", 2, 0)
                deleteBtn:SetText("X")
                deleteBtn:SetScript("OnClick", function()
                    -- Confirm deletion
                    StaticPopupDialogs["VUI_CONFIRM_DELETE_PROFILE"] = {
                        text = "Are you sure you want to delete the profile '" .. profile .. "'?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            VUI.db:DeleteProfile(profile)
                            VUI:Print("Deleted profile: " .. profile)
                            self:UpdateProfileList(dropdown, currentText)
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("VUI_CONFIRM_DELETE_PROFILE")
                end)
                
                -- Add to buttons table
                table.insert(profileListFrame.buttons, profileButton)
                table.insert(profileListFrame.buttons, copyBtn)
                table.insert(profileListFrame.buttons, deleteBtn)
                
                yOffset = yOffset + buttonHeight
            end
        end
    end
    
    -- Initialize profile list
    self:UpdateProfileList(profileDropdown, currentProfileText)
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, profileDropdown, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", profileDropdown, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() profileDropdown:Hide() end)
    
    -- Hide by default
    profileDropdown:Hide()
    
    -- Show dropdown when the profile button is clicked
    profileButton:SetScript("OnClick", function()
        if profileDropdown:IsShown() then
            profileDropdown:Hide()
        else
            -- Refresh available profiles list
            self:UpdateProfileList(profileDropdown, currentProfileText)
            profileDropdown:Show()
        end
    end)
    
    -- Store reference for later updates
    self.profileDropdown = profileDropdown
    
    xOffset = xOffset + buttonWidth + spacing
    
    -- Theme button with dropdown preview
    local themeButton = CreateFrame("Button", nil, quickButtons, "UIPanelButtonTemplate")
    themeButton:SetSize(buttonWidth, buttonHeight)
    themeButton:SetPoint("LEFT", quickButtons, "LEFT", xOffset, 0)
    themeButton:SetText("Themes")
    
    -- Create theme preview dropdown
    local themeDropdown = CreateFrame("Frame", "VUIDashboardThemeDropdown", self.panel, "BackdropTemplate")
    themeDropdown:SetSize(220, 260)
    themeDropdown:SetPoint("BOTTOMLEFT", themeButton, "TOPLEFT", 0, 5)
    themeDropdown:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    themeDropdown:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Add title
    local title = themeDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", themeDropdown, "TOP", 0, -15)
    title:SetText("Theme Preview")
    
    -- Theme data
    local themes = {
        {id = "thunderstorm", name = "Thunder Storm", bg = {10/255, 10/255, 26/255}, accent = {13/255, 157/255, 230/255}},
        {id = "phoenixflame", name = "Phoenix Flame", bg = {26/255, 10/255, 5/255}, accent = {230/255, 77/255, 13/255}},
        {id = "arcanemystic", name = "Arcane Mystic", bg = {26/255, 10/255, 47/255}, accent = {157/255, 13/255, 230/255}},
        {id = "felenergy", name = "Fel Energy", bg = {10/255, 26/255, 10/255}, accent = {26/255, 230/255, 13/255}}
    }
    
    -- Create preview swatches for each theme
    local swatchSize = 180
    local swatchHeight = 40
    local swatchSpacing = 10
    local yOffset = -40
    
    for i, theme in ipairs(themes) do
        -- Create container frame
        local swatch = CreateFrame("Frame", nil, themeDropdown, "BackdropTemplate")
        swatch:SetSize(swatchSize, swatchHeight)
        swatch:SetPoint("TOP", themeDropdown, "TOP", 0, yOffset)
        swatch:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        swatch:SetBackdropColor(theme.bg[1], theme.bg[2], theme.bg[3], 0.8)
        swatch:SetBackdropBorderColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.8)
        
        -- Add theme name
        local name = swatch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", swatch, "LEFT", 10, 0)
        name:SetText(theme.name)
        name:SetTextColor(1, 1, 1)
        
        -- Add select button
        local selectButton = CreateFrame("Button", nil, swatch, "UIPanelButtonTemplate")
        selectButton:SetSize(60, 20)
        selectButton:SetPoint("RIGHT", swatch, "RIGHT", -5, 0)
        selectButton:SetText("Select")
        
        -- Highlight current theme
        if theme.id == VUI.db.profile.appearance.theme then
            swatch:SetBackdropBorderColor(1, 1, 1, 1)
            selectButton:SetText("Active")
            selectButton:Disable()
        end
        
        -- Set up the click handler
        selectButton:SetScript("OnClick", function()
            -- Set the theme globally
            VUI.db.profile.appearance.theme = theme.id
            
            -- Apply theme to all modules that support it
            VUI:ApplyTheme(theme.id)
            
            -- Update the dashboard UI
            Dashboard:Refresh()
            
            -- Hide the dropdown
            themeDropdown:Hide()
        end)
        
        -- Add swatch hover effects
        swatch:SetScript("OnEnter", function()
            if theme.id ~= VUI.db.profile.appearance.theme then
                swatch:SetBackdropBorderColor(1, 1, 1, 0.5)
            end
        end)
        
        swatch:SetScript("OnLeave", function()
            if theme.id ~= VUI.db.profile.appearance.theme then
                swatch:SetBackdropBorderColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.8)
            end
        end)
        
        yOffset = yOffset - (swatchHeight + swatchSpacing)
    end
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, themeDropdown, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", themeDropdown, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() themeDropdown:Hide() end)
    
    -- Hide by default
    themeDropdown:Hide()
    
    -- Show dropdown when the theme button is clicked
    themeButton:SetScript("OnClick", function()
        if themeDropdown:IsShown() then
            themeDropdown:Hide()
        else
            themeDropdown:Show()
        end
    end)
    
    -- Store reference for later updates
    self.themeDropdown = themeDropdown
    
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
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Update module status
    self:UpdateModuleStatus()
end