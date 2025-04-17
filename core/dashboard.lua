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
    theme = "dark", -- dark or light
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

-- Initialize module
function Dashboard:Initialize()
    -- Initialize dashboard components
    self:SetupFrame()
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

-- Show dashboard
function Dashboard:Show()
    if not self.enabled then return end
    if not self.panel then
        self:SetupFrame()
        self:CreateModuleCards()
        self:CreateStatusDisplay()
    end
    
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