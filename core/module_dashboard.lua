-- VUI Module Dashboard
-- A comprehensive dashboard for managing all modules in the VUI addon suite
local addonName, VUI = ...

-- Create the Module Dashboard namespace
VUI.ModuleDashboard = {}

-- Default settings
VUI.ModuleDashboard.defaults = {
    enabled = true,
    width = 900,
    height = 700,
    scale = 1.0,
    position = { x = 0, y = 0 },
    showPerformance = true,
    showModuleCards = true,
    showCategorySelector = true,
    compactView = false,
    activeCategory = "all",
    activeTheme = "thunderstorm",
    defaultSort = "name", -- name, category, status
    showDisabled = true,
    showStandaloneButton = true
}

-- Dashboard panel references
local ModuleDashboard = VUI.ModuleDashboard
local panel = nil
local moduleCards = {}

-- Constants and UI metrics
local HEADER_HEIGHT = 40
local FOOTER_HEIGHT = 40
local CARD_WIDTH = 200
local CARD_HEIGHT = 120
local CARD_MARGIN = 15
local PANEL_PADDING = 20
local CATEGORY_BAR_HEIGHT = 36
local SEARCH_BAR_WIDTH = 200
local PERFORMANCE_WIDGET_WIDTH = 220

-- Module categories with color coding
local MODULE_CATEGORIES = {
    ["Core"] = {
        label = "Core Systems",
        color = { r = 0.7, g = 0.7, b = 0.9 },
        modules = { "core", "moduleapi", "integration", "dashboard" }
    },
    ["UI"] = {
        label = "UI Elements", 
        color = { r = 0.2, g = 0.7, b = 0.9 },
        modules = { "unitframes", "actionbars", "nameplates", "castbar", "tooltip", "bags", "paperdoll" }
    },
    ["Visuals"] = {
        label = "Visual Enhancements",
        color = { r = 0.9, g = 0.5, b = 0.9 },
        modules = { "skins", "visualconfig", "buffoverlay", "spellnotifications", "msbt" }
    },
    ["Tools"] = {
        label = "Tools & Utilities",
        color = { r = 0.9, g = 0.7, b = 0.2 },
        modules = { "tools", "profiles", "automation", "infoframe", "epf" }
    },
    ["Addons"] = {
        label = "Embedded Addons",
        color = { r = 0.5, g = 0.9, b = 0.5 },
        modules = { "angrykeystone", "auctionator", "idtip", "moveany", "omnicc", "omnicd", "trufigcd", "premadegroupfinder", "detailsskin" }
    }
}

-- Cache module metadata from registry
local moduleMetadata = {}

-- Get category for a module name
local function GetModuleCategory(moduleName)
    if not moduleName then return "Uncategorized" end
    
    -- Convert to lowercase for consistent matching
    local lowerName = moduleName:lower()
    
    -- Check each category
    for category, data in pairs(MODULE_CATEGORIES) do
        for _, module in ipairs(data.modules) do
            if module == lowerName then
                return category
            end
        end
    end
    
    -- Default to Uncategorized
    return "Uncategorized"
end

-- Initialize the Module Dashboard
function ModuleDashboard:Initialize()
    -- Create settings in database if they don't exist
    if not VUI.db.profile.moduleDashboard then
        VUI.db.profile.moduleDashboard = self.defaults
    end
    
    -- Set up the main frame
    self:CreateMainFrame()
    
    -- Create UI components
    if VUI.db.profile.moduleDashboard.showCategorySelector then
        self:CreateCategorySelector()
    end
    
    if VUI.db.profile.moduleDashboard.showPerformance then
        self:CreatePerformanceDisplay()
    end
    
    -- Create module cards
    self:CreateModuleCards()
    
    -- Create search bar and filters
    self:CreateSearchAndFilters()
    
    -- Create footer with actions
    self:CreateFooterActions()
    
    -- Register slash commands
    self:RegisterSlashCommands()
    
    -- Hide by default, will be shown via slash command
    panel:Hide()
    
    VUI:Print("Module Dashboard initialized")
end

-- Enable the dashboard
function ModuleDashboard:Enable()
    VUI.db.profile.moduleDashboard.enabled = true
    -- No need to do anything else as the panel is shown via slash command
end

-- Disable the dashboard
function ModuleDashboard:Disable()
    VUI.db.profile.moduleDashboard.enabled = false
    self:Hide()
end

-- Show the dashboard
function ModuleDashboard:Show()
    if not VUI.db.profile.moduleDashboard.enabled then
        VUI:Print("Module Dashboard is disabled. Enable it first.")
        return
    end
    
    -- Refresh module data before showing
    self:RefreshModuleData()
    
    -- Show the panel
    panel:Show()
end

-- Hide the dashboard
function ModuleDashboard:Hide()
    if panel then
        panel:Hide()
    end
end

-- Toggle the dashboard visibility
function ModuleDashboard:Toggle()
    if panel and panel:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Create the main frame for the dashboard
function ModuleDashboard:CreateMainFrame()
    -- Create main panel
    panel = CreateFrame("Frame", "VUIModuleDashboardPanel", UIParent, "BackdropTemplate")
    panel:SetSize(VUI.db.profile.moduleDashboard.width, VUI.db.profile.moduleDashboard.height)
    panel:SetPoint("CENTER", UIParent, "CENTER", VUI.db.profile.moduleDashboard.position.x, VUI.db.profile.moduleDashboard.position.y)
    panel:SetScale(VUI.db.profile.moduleDashboard.scale)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(10)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local x, y = self:GetCenter()
        local uiParentX, uiParentY = UIParent:GetCenter()
        VUI.db.profile.moduleDashboard.position.x = x - uiParentX
        VUI.db.profile.moduleDashboard.position.y = y - uiParentY
    end)
    
    -- Set backdrop based on theme
    local theme = VUI.db.profile.moduleDashboard.activeTheme or "thunderstorm"
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
    title:SetText("VUI Module Dashboard")
    
    -- Theme selector
    local themeLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    themeLabel:SetPoint("LEFT", title, "RIGHT", 40, 0)
    themeLabel:SetText("Theme:")
    
    local themeDropdown = CreateFrame("Frame", "VUIModuleDashboardThemeDropdown", header, "UIDropDownMenuTemplate")
    themeDropdown:SetPoint("LEFT", themeLabel, "RIGHT", 5, 0)
    UIDropDownMenu_SetWidth(themeDropdown, 120)
    
    -- Theme dropdown initialization
    UIDropDownMenu_Initialize(themeDropdown, function(self, level)
        local themes = {
            { text = "Thunder Storm", value = "thunderstorm" },
            { text = "Phoenix Flame", value = "phoenixflame" },
            { text = "Arcane Mystic", value = "arcanemystic" },
            { text = "Fel Energy", value = "felenergy" },
            { text = "Class Colors", value = "classcolor" }
        }
        
        local info = UIDropDownMenu_CreateInfo()
        for _, theme in ipairs(themes) do
            info.text = theme.text
            info.value = theme.value
            info.checked = VUI.db.profile.moduleDashboard.activeTheme == theme.value
            info.func = function()
                VUI.db.profile.moduleDashboard.activeTheme = theme.value
                UIDropDownMenu_SetText(themeDropdown, theme.text)
                -- Update backdrop
                panel:SetBackdrop({
                    bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme.value .. "\\background.tga",
                    edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
                    tile = false,
                    tileSize = 0,
                    edgeSize = 16,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Set initial text
    if VUI.db.profile.moduleDashboard.activeTheme == "thunderstorm" then
        UIDropDownMenu_SetText(themeDropdown, "Thunder Storm")
    elseif VUI.db.profile.moduleDashboard.activeTheme == "phoenixflame" then
        UIDropDownMenu_SetText(themeDropdown, "Phoenix Flame")
    elseif VUI.db.profile.moduleDashboard.activeTheme == "arcanemystic" then
        UIDropDownMenu_SetText(themeDropdown, "Arcane Mystic")
    elseif VUI.db.profile.moduleDashboard.activeTheme == "felenergy" then
        UIDropDownMenu_SetText(themeDropdown, "Fel Energy")
    elseif VUI.db.profile.moduleDashboard.activeTheme == "classcolor" then
        UIDropDownMenu_SetText(themeDropdown, "Class Colors")
    else
        UIDropDownMenu_SetText(themeDropdown, "Thunder Storm")
    end
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeButton:SetPoint("RIGHT", header, "RIGHT", -5, 0)
    closeButton:SetSize(24, 24)
    closeButton:SetScript("OnClick", function() ModuleDashboard:Hide() end)
    
    -- Settings button
    local settingsButton = CreateFrame("Button", nil, header)
    settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -5, 0)
    settingsButton:SetSize(24, 24)
    settingsButton:SetNormalTexture("Interface\\AddOns\\VUI\\media\\icons\\common\\settings.tga")
    settingsButton:GetNormalTexture():SetTexCoord(0.75, 1, 0, 0.25)
    settingsButton:SetScript("OnClick", function()
        InterfaceOptionsFrame_OpenToCategory("VUI")
        InterfaceOptionsFrame_OpenToCategory("VUI")
    end)
    
    -- Save references
    self.panel = panel
    self.header = header
end

-- Create category selector
function ModuleDashboard:CreateCategorySelector()
    -- Create category bar
    local categoryBar = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    categoryBar:SetSize(self.panel:GetWidth(), CATEGORY_BAR_HEIGHT)
    categoryBar:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 0, -HEADER_HEIGHT)
    categoryBar:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
        edgeFile = nil,
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    categoryBar:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
    
    -- Create tabs for each category
    local buttonWidth = 100
    local spacing = 5
    local xOffset = 10
    
    -- All button
    local allButton = CreateFrame("Button", nil, categoryBar, "UIPanelButtonTemplate")
    allButton:SetSize(60, 24)
    allButton:SetPoint("LEFT", categoryBar, "LEFT", xOffset, 0)
    allButton:SetText("All")
    allButton:SetScript("OnClick", function()
        self:FilterByCategory("all")
    end)
    
    xOffset = xOffset + 60 + spacing
    
    -- Category buttons
    for category, data in pairs(MODULE_CATEGORIES) do
        local button = CreateFrame("Button", nil, categoryBar, "UIPanelButtonTemplate")
        button:SetSize(buttonWidth, 24)
        button:SetPoint("LEFT", categoryBar, "LEFT", xOffset, 0)
        button:SetText(data.label)
        
        -- Add color indicator
        local colorIndicator = button:CreateTexture(nil, "OVERLAY")
        colorIndicator:SetSize(8, 8)
        colorIndicator:SetPoint("LEFT", button, "LEFT", 6, 0)
        colorIndicator:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\glow.tga")
        colorIndicator:SetVertexColor(data.color.r, data.color.g, data.color.b, 1)
        
        -- Add click handler
        button:SetScript("OnClick", function()
            self:FilterByCategory(category)
        end)
        
        xOffset = xOffset + buttonWidth + spacing
    end
    
    -- Save reference
    self.categoryBar = categoryBar
end

-- Create performance display
function ModuleDashboard:CreatePerformanceDisplay()
    -- Create performance frame
    local perfFrame = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    perfFrame:SetSize(PERFORMANCE_WIDGET_WIDTH, 50)
    perfFrame:SetPoint("TOPRIGHT", self.panel, "TOPRIGHT", -PANEL_PADDING, -(HEADER_HEIGHT + CATEGORY_BAR_HEIGHT + 10))
    perfFrame:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    perfFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    
    -- Title
    local title = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", perfFrame, "TOP", 0, -5)
    title:SetText("Performance")
    
    -- Memory usage 
    local memoryText = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    memoryText:SetPoint("TOPLEFT", perfFrame, "TOPLEFT", 10, -20)
    memoryText:SetJustifyH("LEFT")
    
    -- Frame rate
    local fpsText = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fpsText:SetPoint("TOPLEFT", memoryText, "BOTTOMLEFT", 0, -5)
    fpsText:SetJustifyH("LEFT")
    
    -- Update stats function
    local function UpdateStats()
        -- Memory usage
        local totalMemory = 0
        UpdateAddOnMemoryUsage()
        totalMemory = GetAddOnMemoryUsage(addonName)
        
        -- Format memory text
        local memText = "Memory: "
        if totalMemory < 1024 then
            memText = memText .. string.format("%.2f KB", totalMemory)
        else
            memText = memText .. string.format("%.2f MB", totalMemory / 1024)
        end
        memoryText:SetText(memText)
        
        -- FPS
        local fps = GetFramerate()
        fpsText:SetText(string.format("FPS: %.1f", fps))
    end
    
    -- Create update timer
    local updateTimer = 0
    perfFrame:SetScript("OnUpdate", function(self, elapsed)
        updateTimer = updateTimer + elapsed
        if updateTimer >= 1 then
            UpdateStats()
            updateTimer = 0
        end
    end)
    
    -- Initial update
    UpdateStats()
    
    -- Save reference
    self.performanceFrame = perfFrame
end

-- Create module cards
function ModuleDashboard:CreateModuleCards()
    -- Get module data
    self:RefreshModuleData()
    
    -- Calculate layout
    local contentTop = HEADER_HEIGHT + CATEGORY_BAR_HEIGHT + 5
    local contentWidth = self.panel:GetWidth() - (2 * PANEL_PADDING)
    local contentHeight = self.panel:GetHeight() - contentTop - FOOTER_HEIGHT - 5
    
    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, self.panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", self.panel, "TOPLEFT", PANEL_PADDING, -contentTop)
    scrollFrame:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -PANEL_PADDING - 20, FOOTER_HEIGHT + 5)
    
    -- Create content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(contentWidth, 1000) -- Height will be adjusted dynamically
    scrollFrame:SetScrollChild(contentFrame)
    
    -- Calculate cards per row
    local cardsPerRow = math.floor(contentWidth / (CARD_WIDTH + CARD_MARGIN))
    
    -- Create cards for each module
    local row = 0
    local col = 0
    local maxRows = 0
    
    -- Create cards for modules
    for i, moduleData in ipairs(moduleMetadata) do
        -- Calculate position
        local x = col * (CARD_WIDTH + CARD_MARGIN)
        local y = -row * (CARD_HEIGHT + CARD_MARGIN)
        
        -- Create card frame
        local card = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
        card:SetSize(CARD_WIDTH, CARD_HEIGHT)
        card:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", x, y)
        
        -- Get category color
        local categoryName = moduleData.category or "Uncategorized"
        local categoryColor = { r = 0.5, g = 0.5, b = 0.5 } -- Default
        
        if MODULE_CATEGORIES[categoryName] then
            categoryColor = MODULE_CATEGORIES[categoryName].color
        end
        
        -- Set backdrop with category color for the border
        card:SetBackdrop({
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
            tile = false,
            tileSize = 0,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        card:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        card:SetBackdropBorderColor(categoryColor.r, categoryColor.g, categoryColor.b, 0.8)
        
        -- Module name (with color based on status)
        local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        nameText:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -10)
        nameText:SetText(moduleData.name)
        
        if moduleData.enabled then
            nameText:SetTextColor(0.2, 1, 0.2)
        else
            nameText:SetTextColor(1, 0.3, 0.3)
        end
        
        -- Category label
        local categoryText = card:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        categoryText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
        categoryText:SetText(categoryName)
        categoryText:SetTextColor(categoryColor.r, categoryColor.g, categoryColor.b)
        
        -- Description
        local descText = card:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        descText:SetPoint("TOPLEFT", categoryText, "BOTTOMLEFT", 0, -5)
        descText:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 40)
        descText:SetJustifyH("LEFT")
        descText:SetJustifyV("TOP")
        descText:SetWordWrap(true)
        descText:SetText(moduleData.description or "No description available")
        descText:SetTextColor(0.8, 0.8, 0.8)
        
        -- Create buttons
        local buttonWidth = 70
        local buttonHeight = 22
        local buttonSpacing = 5
        
        -- Toggle button
        local toggleButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        toggleButton:SetSize(buttonWidth, buttonHeight)
        toggleButton:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 10, 10)
        toggleButton:SetText(moduleData.enabled and "Disable" or "Enable")
        toggleButton:SetScript("OnClick", function()
            self:ToggleModule(moduleData.name)
            -- Update button text
            toggleButton:SetText(moduleData.enabled and "Disable" or "Enable")
            -- Update name text color
            if moduleData.enabled then
                nameText:SetTextColor(0.2, 1, 0.2)
            else
                nameText:SetTextColor(1, 0.3, 0.3)
            end
        end)
        
        -- Config button
        local configButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        configButton:SetSize(buttonWidth, buttonHeight)
        configButton:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 10)
        configButton:SetText("Config")
        configButton:SetScript("OnClick", function()
            self:OpenModuleConfig(moduleData.name)
        end)
        
        -- Store card data
        moduleCards[moduleData.name] = {
            frame = card,
            nameText = nameText,
            descText = descText,
            toggleButton = toggleButton,
            configButton = configButton,
            data = moduleData
        }
        
        -- Update layout counters
        col = col + 1
        if col >= cardsPerRow then
            col = 0
            row = row + 1
        end
    end
    
    -- Calculate total rows needed
    maxRows = math.ceil(#moduleMetadata / cardsPerRow)
    
    -- Adjust content height based on cards
    contentFrame:SetHeight(maxRows * (CARD_HEIGHT + CARD_MARGIN) + CARD_MARGIN)
    
    -- Save references
    self.scrollFrame = scrollFrame
    self.contentFrame = contentFrame
    
    -- Apply initial category filter
    if VUI.db.profile.moduleDashboard.activeCategory then
        self:FilterByCategory(VUI.db.profile.moduleDashboard.activeCategory)
    else
        self:FilterByCategory("all")
    end
end

-- Create search and filters
function ModuleDashboard:CreateSearchAndFilters()
    -- Create search frame
    local searchFrame = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    searchFrame:SetSize(SEARCH_BAR_WIDTH, 30)
    searchFrame:SetPoint("TOPRIGHT", self.panel, "TOPRIGHT", -PANEL_PADDING, -(HEADER_HEIGHT + 5))
    
    -- Search box
    local searchBox = CreateFrame("EditBox", nil, searchFrame, "SearchBoxTemplate")
    searchBox:SetSize(SEARCH_BAR_WIDTH, 20)
    searchBox:SetPoint("TOP", searchFrame, "TOP", 0, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        ModuleDashboard:FilterBySearch(self:GetText())
    end)
    
    -- Sort dropdown
    local sortLabel = self.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sortLabel:SetPoint("TOPLEFT", self.panel, "TOPLEFT", PANEL_PADDING, -(HEADER_HEIGHT + CATEGORY_BAR_HEIGHT + 15))
    sortLabel:SetText("Sort by:")
    
    local sortDropdown = CreateFrame("Frame", "VUIModuleDashboardSortDropdown", self.panel, "UIDropDownMenuTemplate")
    sortDropdown:SetPoint("LEFT", sortLabel, "RIGHT", 5, 0)
    UIDropDownMenu_SetWidth(sortDropdown, 100)
    
    -- Sort dropdown initialization
    UIDropDownMenu_Initialize(sortDropdown, function(self, level)
        local sortOptions = {
            { text = "Name", value = "name" },
            { text = "Category", value = "category" },
            { text = "Status", value = "status" }
        }
        
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(sortOptions) do
            info.text = option.text
            info.value = option.value
            info.checked = VUI.db.profile.moduleDashboard.defaultSort == option.value
            info.func = function()
                VUI.db.profile.moduleDashboard.defaultSort = option.value
                UIDropDownMenu_SetText(sortDropdown, option.text)
                ModuleDashboard:SortModules(option.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Set initial text
    if VUI.db.profile.moduleDashboard.defaultSort == "name" then
        UIDropDownMenu_SetText(sortDropdown, "Name")
    elseif VUI.db.profile.moduleDashboard.defaultSort == "category" then
        UIDropDownMenu_SetText(sortDropdown, "Category")
    elseif VUI.db.profile.moduleDashboard.defaultSort == "status" then
        UIDropDownMenu_SetText(sortDropdown, "Status")
    else
        UIDropDownMenu_SetText(sortDropdown, "Name")
    end
    
    -- Show disabled modules checkbox
    local showDisabledCheckbox = CreateFrame("CheckButton", nil, self.panel, "UICheckButtonTemplate")
    showDisabledCheckbox:SetSize(24, 24)
    showDisabledCheckbox:SetPoint("LEFT", sortDropdown, "RIGHT", 20, 0)
    showDisabledCheckbox:SetChecked(VUI.db.profile.moduleDashboard.showDisabled)
    showDisabledCheckbox.text:SetText("Show Disabled")
    showDisabledCheckbox:SetScript("OnClick", function(self)
        VUI.db.profile.moduleDashboard.showDisabled = self:GetChecked()
        ModuleDashboard:RefreshDisplay()
    end)
    
    -- Compact view checkbox
    local compactViewCheckbox = CreateFrame("CheckButton", nil, self.panel, "UICheckButtonTemplate")
    compactViewCheckbox:SetSize(24, 24)
    compactViewCheckbox:SetPoint("LEFT", showDisabledCheckbox.text, "RIGHT", 5, 0)
    compactViewCheckbox:SetChecked(VUI.db.profile.moduleDashboard.compactView)
    compactViewCheckbox.text:SetText("Compact View")
    compactViewCheckbox:SetScript("OnClick", function(self)
        VUI.db.profile.moduleDashboard.compactView = self:GetChecked()
        -- Recreate module cards with new layout
        ModuleDashboard:RecreateModuleCards()
    end)
    
    -- Save references
    self.searchBox = searchBox
    self.sortDropdown = sortDropdown
    self.showDisabledCheckbox = showDisabledCheckbox
    self.compactViewCheckbox = compactViewCheckbox
end

-- Create footer with action buttons
function ModuleDashboard:CreateFooterActions()
    -- Create footer bar
    local footerBar = CreateFrame("Frame", nil, self.panel, "BackdropTemplate")
    footerBar:SetSize(self.panel:GetWidth(), FOOTER_HEIGHT)
    footerBar:SetPoint("BOTTOMLEFT", self.panel, "BOTTOMLEFT", 0, 0)
    footerBar:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
        edgeFile = nil,
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    footerBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    
    -- Status counts
    local statusText = footerBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("LEFT", footerBar, "LEFT", 10, 0)
    
    -- Action buttons
    local buttonWidth = 100
    local buttonHeight = 24
    local buttonSpacing = 10
    local xOffset = self.panel:GetWidth() - buttonWidth - 10
    
    -- Enable All button
    local enableAllButton = CreateFrame("Button", nil, footerBar, "UIPanelButtonTemplate")
    enableAllButton:SetSize(buttonWidth, buttonHeight)
    enableAllButton:SetPoint("RIGHT", footerBar, "RIGHT", -10, 0)
    enableAllButton:SetText("Enable All")
    enableAllButton:SetScript("OnClick", function()
        self:EnableAllModules()
    end)
    
    -- Disable All button
    local disableAllButton = CreateFrame("Button", nil, footerBar, "UIPanelButtonTemplate")
    disableAllButton:SetSize(buttonWidth, buttonHeight)
    disableAllButton:SetPoint("RIGHT", enableAllButton, "LEFT", -buttonSpacing, 0)
    disableAllButton:SetText("Disable All")
    disableAllButton:SetScript("OnClick", function()
        self:DisableAllModules()
    end)
    
    -- Reload UI button
    local reloadButton = CreateFrame("Button", nil, footerBar, "UIPanelButtonTemplate")
    reloadButton:SetSize(buttonWidth, buttonHeight)
    reloadButton:SetPoint("RIGHT", disableAllButton, "LEFT", -buttonSpacing, 0)
    reloadButton:SetText("Reload UI")
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Save references
    self.footerBar = footerBar
    self.statusText = statusText
    
    -- Update status text initially
    self:UpdateStatusCounts()
end

-- Register slash commands
function ModuleDashboard:RegisterSlashCommands()
    -- Register with VUI slash command handler if available
    if VUI.RegisterSlashCommand then
        VUI:RegisterSlashCommand("modules", function() self:Toggle() end, "Opens the module dashboard")
    end
    
    -- Add standalone slash command if enabled
    if VUI.db.profile.moduleDashboard.showStandaloneButton then
        SLASH_VUIMODULES1 = "/vuimodules"
        SlashCmdList["VUIMODULES"] = function(input)
            self:Toggle()
        end
    end
end

-- Refresh module metadata from the registry
function ModuleDashboard:RefreshModuleData()
    moduleMetadata = {}
    
    -- Check if registry exists and has modules
    if VUI.ModuleRegistry and VUI.ModuleRegistry.modules then
        for name, data in pairs(VUI.ModuleRegistry.modules) do
            -- Determine enabled status
            local lowerName = name:lower()
            local enabled = false
            
            if VUI.db and VUI.db.profile and VUI.db.profile.modules then
                enabled = VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled
            end
            
            -- Create metadata entry
            table.insert(moduleMetadata, {
                name = name,
                category = GetModuleCategory(name),
                description = data.description or "No description available",
                version = data.version or "0.1",
                author = data.author or "Unknown",
                enabled = enabled,
                dependencies = data.dependencies or {},
                conflicts = data.conflicts or {},
                features = data.features or {},
                settings = VUI.db and VUI.db.profile.modules[lowerName] or {}
            })
        end
    end
    
    -- Also scan for traditional modules in VUI table
    for name, module in pairs(VUI) do
        -- Only process traditional modules that haven't been added yet
        if type(module) == "table" and module.Initialize and type(name) == "string" then
            -- Check if module is not already in metadata
            local found = false
            for _, metadata in ipairs(moduleMetadata) do
                if metadata.name == name then
                    found = true
                    break
                end
            end
            
            if not found then
                -- Determine enabled status
                local lowerName = name:lower()
                local enabled = false
                
                if VUI.db and VUI.db.profile and VUI.db.profile.modules then
                    enabled = VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled
                end
                
                -- Create metadata entry
                table.insert(moduleMetadata, {
                    name = name,
                    category = GetModuleCategory(name),
                    description = "Core VUI module",
                    version = "0.1",
                    author = "VUI Team",
                    enabled = enabled,
                    dependencies = {},
                    conflicts = {},
                    features = {},
                    settings = VUI.db and VUI.db.profile.modules[lowerName] or {}
                })
            end
        end
    end
    
    -- Sort metadata based on current sort setting
    self:SortModules(VUI.db.profile.moduleDashboard.defaultSort or "name")
end

-- Sort modules based on given criteria
function ModuleDashboard:SortModules(sortBy)
    if sortBy == "name" then
        table.sort(moduleMetadata, function(a, b) return a.name < b.name end)
    elseif sortBy == "category" then
        table.sort(moduleMetadata, function(a, b)
            if a.category == b.category then
                return a.name < b.name
            else
                return a.category < b.category
            end
        end)
    elseif sortBy == "status" then
        table.sort(moduleMetadata, function(a, b)
            if a.enabled == b.enabled then
                return a.name < b.name
            else
                return a.enabled and not b.enabled
            end
        end)
    end
    
    -- Save sort preference
    VUI.db.profile.moduleDashboard.defaultSort = sortBy
    
    -- Refresh display if necessary
    if self.contentFrame then
        self:RefreshDisplay()
    end
end

-- Filter modules by category
function ModuleDashboard:FilterByCategory(category)
    -- Save active category
    VUI.db.profile.moduleDashboard.activeCategory = category
    
    -- Apply filter to all module cards
    for name, card in pairs(moduleCards) do
        local moduleCategory = card.data.category
        local shouldShow = (category == "all" or moduleCategory == category)
        
        -- Also check if disabled modules should be shown
        if not VUI.db.profile.moduleDashboard.showDisabled and not card.data.enabled then
            shouldShow = false
        end
        
        -- Show or hide card
        if shouldShow then
            card.frame:Show()
        else
            card.frame:Hide()
        end
    end
    
    -- Adjust content frame height
    self:AdjustContentHeight()
end

-- Filter modules by search text
function ModuleDashboard:FilterBySearch(searchText)
    if not searchText or searchText == "" then
        -- Reset to category filter only
        self:FilterByCategory(VUI.db.profile.moduleDashboard.activeCategory)
        return
    end
    
    -- Convert to lowercase for case-insensitive search
    searchText = searchText:lower()
    
    -- Apply search filter to all module cards
    for name, card in pairs(moduleCards) do
        local moduleData = card.data
        local moduleCategory = moduleData.category
        local currentCategory = VUI.db.profile.moduleDashboard.activeCategory
        
        -- Check if module matches search text
        local nameMatch = moduleData.name:lower():find(searchText, 1, true)
        local descMatch = moduleData.description and moduleData.description:lower():find(searchText, 1, true)
        local categoryMatch = moduleCategory:lower():find(searchText, 1, true)
        
        -- Determine if card should be shown
        local shouldShow = nameMatch or descMatch or categoryMatch
        
        -- Apply category filter if active
        if currentCategory ~= "all" and moduleCategory ~= currentCategory then
            shouldShow = false
        end
        
        -- Also check if disabled modules should be shown
        if not VUI.db.profile.moduleDashboard.showDisabled and not moduleData.enabled then
            shouldShow = false
        end
        
        -- Show or hide card
        if shouldShow then
            card.frame:Show()
        else
            card.frame:Hide()
        end
    end
    
    -- Adjust content frame height
    self:AdjustContentHeight()
end

-- Adjust content frame height based on visible cards
function ModuleDashboard:AdjustContentHeight()
    if not self.contentFrame then return end
    
    local visibleCards = 0
    local contentWidth = self.contentFrame:GetWidth()
    local cardsPerRow = math.floor(contentWidth / (CARD_WIDTH + CARD_MARGIN))
    
    -- Count visible cards
    for _, card in pairs(moduleCards) do
        if card.frame:IsShown() then
            visibleCards = visibleCards + 1
        end
    end
    
    -- Calculate total rows needed
    local totalRows = math.ceil(visibleCards / cardsPerRow)
    
    -- Adjust content height
    self.contentFrame:SetHeight(totalRows * (CARD_HEIGHT + CARD_MARGIN) + CARD_MARGIN)
end

-- Recreate module cards (used when layout changes)
function ModuleDashboard:RecreateModuleCards()
    -- Remove existing cards
    if self.contentFrame then
        self.contentFrame:SetParent(nil)
        self.contentFrame = nil
    end
    
    if self.scrollFrame then
        self.scrollFrame:SetParent(nil)
        self.scrollFrame = nil
    end
    
    moduleCards = {}
    
    -- Recreate cards
    self:CreateModuleCards()
end

-- Refresh display (recalculate card visibility)
function ModuleDashboard:RefreshDisplay()
    -- Apply current filters
    if self.searchBox and self.searchBox:GetText() ~= "" then
        self:FilterBySearch(self.searchBox:GetText())
    else
        self:FilterByCategory(VUI.db.profile.moduleDashboard.activeCategory)
    end
    
    -- Update status counts
    self:UpdateStatusCounts()
end

-- Toggle a module's enabled state
function ModuleDashboard:ToggleModule(moduleName)
    -- Get module from VUI table
    local module = VUI[moduleName]
    if not module then return end
    
    -- Get current enabled status
    local lowerName = moduleName:lower()
    local isEnabled = false
    
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] then
        isEnabled = VUI.db.profile.modules[lowerName].enabled
    end
    
    -- Toggle state
    if isEnabled then
        -- Disable module
        VUI.db.profile.modules[lowerName].enabled = false
        if module.Disable then module:Disable() end
    else
        -- Enable module
        if not VUI.db.profile.modules[lowerName] then
            VUI.db.profile.modules[lowerName] = {}
        end
        VUI.db.profile.modules[lowerName].enabled = true
        if module.Enable then module:Enable() end
    end
    
    -- Update module metadata and cards
    self:RefreshModuleData()
    
    -- Find and update card if it exists
    local card = moduleCards[moduleName]
    if card then
        -- Update module data
        for _, metadata in ipairs(moduleMetadata) do
            if metadata.name == moduleName then
                card.data = metadata
                break
            end
        end
        
        -- Update toggle button text
        card.toggleButton:SetText(card.data.enabled and "Disable" or "Enable")
        
        -- Update name text color
        if card.data.enabled then
            card.nameText:SetTextColor(0.2, 1, 0.2)
        else
            card.nameText:SetTextColor(1, 0.3, 0.3)
        end
    end
    
    -- Refresh display
    self:RefreshDisplay()
end

-- Open a module's configuration panel
function ModuleDashboard:OpenModuleConfig(moduleName)
    -- Try to open module-specific config, or fallback to main config
    InterfaceOptionsFrame_OpenToCategory("VUI " .. moduleName)
    if not InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame_OpenToCategory("VUI")
        InterfaceOptionsFrame_OpenToCategory("VUI")
    end
end

-- Enable all modules
function ModuleDashboard:EnableAllModules()
    -- Enable all modules
    for _, moduleData in ipairs(moduleMetadata) do
        local module = VUI[moduleData.name]
        if module then
            local lowerName = moduleData.name:lower()
            
            -- Create settings if they don't exist
            if not VUI.db.profile.modules[lowerName] then
                VUI.db.profile.modules[lowerName] = {}
            end
            
            -- Enable module
            VUI.db.profile.modules[lowerName].enabled = true
            if module.Enable then module:Enable() end
        end
    end
    
    -- Refresh data and display
    self:RefreshModuleData()
    self:RefreshDisplay()
end

-- Disable all modules
function ModuleDashboard:DisableAllModules()
    -- Disable all modules
    for _, moduleData in ipairs(moduleMetadata) do
        local module = VUI[moduleData.name]
        if module then
            local lowerName = moduleData.name:lower()
            
            -- Create settings if they don't exist
            if not VUI.db.profile.modules[lowerName] then
                VUI.db.profile.modules[lowerName] = {}
            end
            
            -- Disable module
            VUI.db.profile.modules[lowerName].enabled = false
            if module.Disable then module:Disable() end
        end
    end
    
    -- Refresh data and display
    self:RefreshModuleData()
    self:RefreshDisplay()
end

-- Update status counts in footer
function ModuleDashboard:UpdateStatusCounts()
    if not self.statusText then return end
    
    -- Count enabled modules
    local totalModules = #moduleMetadata
    local enabledModules = 0
    
    for _, moduleData in ipairs(moduleMetadata) do
        if moduleData.enabled then
            enabledModules = enabledModules + 1
        end
    end
    
    -- Update status text
    self.statusText:SetText(string.format("Modules: %d enabled / %d total", enabledModules, totalModules))
end

-- Hook the dashboard into VUI initialization
function ModuleDashboard:OnInitialize()
    -- Register with VUI core
    VUI.ModuleDashboard = self
    
    -- Initialize when DB is ready
    if VUI.HookInitialize then
        VUI:HookInitialize(function()
            self:Initialize()
        end)
    end
end

-- Call initialization
ModuleDashboard:OnInitialize()