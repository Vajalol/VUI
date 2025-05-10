local Module = VUI:NewModule("Config.Install");

-- Define the enhanced multi-step installation wizard using VUIConfig
local function CreateInstallWizard()
    local VUIConfig = LibStub('VUIConfig')
    
    -- Create main window with VUIConfig
    local Install = VUIConfig:Window(UIParent, 800, 600, "|cffea00ffV|r|cff00a2ffUI|r - Installation")
    Install:SetPoint("CENTER")
    Install:SetFrameStrata("HIGH")
    Install:SetMovable(true)
    Install:EnableMouse(true)
    
    -- Add VUI logo
    local logo = VUIConfig:Texture(Install.titlePanel, 120, 35, "Interface\\AddOns\\VUI\\Media\\Textures\\Config\\Logo")
    VUIConfig:GlueLeft(logo, Install.titlePanel, 10, 0)
    
    -- Subtitle
    local subtitle = VUIConfig:Label(Install.titlePanel, "Installation Wizard")
    subtitle:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 14)
    VUIConfig:GlueRight(subtitle, Install.titlePanel, -40, 0)
    
    -- Better navigation buttons using VUIConfig widgets
    Install.prevButton = VUIConfig:Button(Install, 120, 30, "Previous")
    Install.prevButton:SetPoint("BOTTOMLEFT", 20, 20)
    Install.prevButton:Disable() -- Initially disabled
    
    Install.nextButton = VUIConfig:Button(Install, 120, 30, "Next")
    Install.nextButton:SetPoint("BOTTOMRIGHT", -20, 20)
    
    Install.skipButton = VUIConfig:Button(Install, 120, 30, "Skip Setup")
    Install.skipButton:SetPoint("BOTTOM", 0, 20)
    
    -- Page indicator text with VUIConfig styling
    Install.pageText = VUIConfig:Label(Install, "")
    Install.pageText:SetPoint("BOTTOM", 0, 55)
    
    -- Create content area with proper styling
    Install.content = VUIConfig:Panel(Install, 760, 450)
    VUIConfig:GlueTop(Install.content, Install, 0, -60)
    VUIConfig:ApplyBackdrop(Install.content, "panel")
    
    -- Page tracking same as before
    Install.pages = {}
    Install.currentPage = 1
    
    -- Enhanced page navigation with animations
    Install.GoToPage = function(self, pageNum)
        if pageNum >= 1 and pageNum <= #self.pages then
            -- Update page indicator
            self.pageText:SetText("Page " .. pageNum .. " of " .. #self.pages)
            
            -- Animate current page out
            if self.pages[self.currentPage]:IsShown() then
                VUI.Animations:FadeOut(self.pages[self.currentPage], 0.3, function()
                    self.pages[self.currentPage]:Hide()
                    self.currentPage = pageNum
                    
                    -- Animate new page in
                    self.pages[pageNum]:Show()
                    VUI.Animations:FadeIn(self.pages[pageNum], 0.3)
                    
                    -- Update button states
                    if pageNum == 1 then
                        self.prevButton:Disable()
                    else
                        self.prevButton:Enable()
                    end
                    
                    if pageNum == #self.pages then
                        self.nextButton:SetText("Finish")
                    else
                        self.nextButton:SetText("Next")
                    end
                end)
            else
                -- First page or no current page shown
                self.currentPage = pageNum
                self.pages[pageNum]:Show()
                VUI.Animations:FadeIn(self.pages[pageNum], 0.3)
                
                -- Update button states
                if pageNum == 1 then
                    self.prevButton:Disable()
                else
                    self.prevButton:Enable()
                end
                
                if pageNum == #self.pages then
                    self.nextButton:SetText("Finish")
                else
                    self.nextButton:SetText("Next")
                end
            end
        end
    end
    
    -- Setup enhanced button scripts with animated effects
    Install.prevButton:SetScript("OnClick", function()
        if Install.currentPage > 1 then
            VUI.Animations:Pulse(Install.prevButton, 0.2)
            Install:GoToPage(Install.currentPage - 1)
        end
    end)
    
    Install.nextButton:SetScript("OnClick", function()
        VUI.Animations:Pulse(Install.nextButton, 0.2)
        
        if Install.currentPage < #Install.pages then
            Install:GoToPage(Install.currentPage + 1)
        else
            -- On the last page, clicking "Finish" completes installation
            VUI.db.profile.install = true
            VUI.db.profile.reset = true
            
            -- Apply default settings
            VUI:ConfigureFirstTimeSetup()
            
            -- Use animation system instead of UIFrameFade
            VUI.Animations:FadeOut(Install, 0.4, function()
                Install:Hide()
                VUI:Config()
            end)
        end
    end)
    
    Install.skipButton:SetScript("OnClick", function()
        VUI.Animations:Pulse(Install.skipButton, 0.2)
        
        VUI.db.profile.install = true
        VUI.db.profile.reset = true
        
        -- Apply default settings even when skipping
        VUI:ConfigureFirstTimeSetup()
        
        -- Use animation system
        VUI.Animations:FadeOut(Install, 0.4, function()
            Install:Hide()
            VUI:Config()
        end)
    end)
    
    return Install
end

-- Create enhanced welcome page with VUIConfig and animations
local function CreateWelcomePage(parent)
    local VUIConfig = LibStub('VUIConfig')
    
    local page = VUIConfig:Panel(parent.content)
    page:SetAllPoints()
    page:Hide() -- Initially hidden for animation
    
    -- VUI Logo with enhanced visual style
    local logoPanel = VUIConfig:Panel(page, 280, 140)
    logoPanel:SetPoint("TOP", 0, -20)
    VUIConfig:ApplyBackdrop(logoPanel, "panel")
    
    -- Create a glow frame behind the logo for a more premium look
    local glowFrame = CreateFrame("Frame", nil, logoPanel)
    glowFrame:SetPoint("CENTER")
    glowFrame:SetSize(280, 140)
    
    local glowTexture = glowFrame:CreateTexture(nil, "BACKGROUND")
    glowTexture:SetAllPoints()
    glowTexture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\UI-Achievement-Guild-Glow")
    glowTexture:SetBlendMode("ADD")
    glowTexture:SetVertexColor(0.3, 0.6, 1, 0.3) -- Soft blue glow
    
    -- Create a border frame for a premium feel
    local borderFrame = CreateFrame("Frame", nil, logoPanel)
    borderFrame:SetPoint("TOPLEFT", -2, 2)
    borderFrame:SetPoint("BOTTOMRIGHT", 2, -2)
    borderFrame:SetBackdrop({
        edgeFile = "Interface\\AddOns\\VUI\\Media\\Textures\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    borderFrame:SetBackdropBorderColor(0.7, 0.4, 0.9, 0.7) -- Subtle purple border
    
    -- Add the Vortex thunderstorm icon for branding
    local logoIcon = logoPanel:CreateTexture(nil, "ARTWORK")
    logoIcon:SetSize(64, 64) 
    logoIcon:SetPoint("LEFT", logoPanel, "LEFT", 20, 0)
    logoIcon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm")
    
    local logoText = VUIConfig:Label(logoPanel, "|cffea00ffV|r|cff00a2ffUI|r")
    logoText:SetPoint("CENTER", 20, 0) -- Shift text slightly to balance with the icon
    logoText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 84, "OUTLINE")
    
    -- Add version text for professional appearance
    local versionText = VUIConfig:Label(logoPanel, "v1.0.1")
    versionText:SetPoint("BOTTOM", 0, 10)
    versionText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 14)
    versionText:SetTextColor(0.8, 0.8, 0.8)
    
    -- Welcome panel with animated border
    local welcomePanel = VUIConfig:Panel(page, 650, 120)
    welcomePanel:SetPoint("TOP", logoPanel, "BOTTOM", 0, -20)
    VUIConfig:ApplyBackdrop(welcomePanel, "panel", "border")
    
    -- Welcome text with more inspiring message
    local welcomeText = VUIConfig:Label(welcomePanel, "Welcome to the Future of WoW UI")
    welcomeText:SetPoint("TOP", 0, -15)
    welcomeText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 22)
    welcomeText:SetTextColor(0.9, 0.4, 1) -- Vibrant purple
    
    local taglineText = VUIConfig:Label(welcomePanel, "VUI - Vortex UI")
    taglineText:SetPoint("TOP", welcomeText, "BOTTOM", 0, -5)
    taglineText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 16)
    taglineText:SetTextColor(0, 0.7, 1) -- Bright blue
    
    local welcomeDesc = VUIConfig:Label(welcomePanel, "Transform your gameplay with the most advanced UI enhancement suite ever created for World of Warcraft. VUI seamlessly blends performance and aesthetics to elevate your gaming experience to new heights.")
    welcomeDesc:SetPoint("TOP", taglineText, "BOTTOM", 0, -10)
    welcomeDesc:SetWidth(600)
    welcomeDesc:SetJustifyH("CENTER")
    
    -- Features panel
    local featuresPanel = VUIConfig:Panel(page, 650, 180)
    featuresPanel:SetPoint("TOP", welcomePanel, "BOTTOM", 0, -20)
    VUIConfig:ApplyBackdrop(featuresPanel, "panel", "border")
    
    -- Features header with more premium styling
    local featuresHeader = VUIConfig:Label(featuresPanel, "PREMIUM FEATURES")
    featuresHeader:SetPoint("TOP", 0, -15)
    featuresHeader:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 18, "OUTLINE")
    featuresHeader:SetTextColor(0.95, 0.85, 0.45) -- Gold color for premium feel
    
    -- Add a separator line for professional look
    local separatorTexture = featuresPanel:CreateTexture(nil, "ARTWORK")
    separatorTexture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\UI-Tooltip-Border")
    separatorTexture:SetSize(400, 2)
    separatorTexture:SetPoint("TOP", featuresHeader, "BOTTOM", 0, -5)
    separatorTexture:SetTexCoord(0.2, 0.8, 0.25, 0.75) -- Use just the center part of the texture
    separatorTexture:SetVertexColor(0.6, 0.4, 0.8) -- Purple tint
    
    -- Feature list using individual labels for animation - more inspirational wording
    local features = {
        "• Intelligent Modular Architecture — Customize to Your Perfect UI",
        "• Dynamic Combat Analytics — Gain the Competitive Edge",
        "• Streamlined Auction & Economic Tools — Maximize Your Profits",
        "• Premium Raid & Party Frames — Lead With Confidence",
        "• Intuitive Notification System — Never Miss Critical Events",
        "• Advanced Cooldown Visualization — Perfect Your Rotation"
    }
    
    local featureLabels = {}
    for i, feature in ipairs(features) do
        local label = VUIConfig:Label(featuresPanel, feature)
        label:SetPoint("TOPLEFT", 50, -40 - (i-1) * 20)
        label:SetWidth(550)
        label:SetJustifyH("LEFT")
        label:SetAlpha(0) -- Start invisible for animation
        table.insert(featureLabels, label)
    end
    
    -- Setup page load animation
    page.OnShow = function(self)
        -- Reset elements for animation
        logoPanel:SetAlpha(0)
        welcomePanel:SetAlpha(0)
        featuresPanel:SetAlpha(0)
        
        for _, label in ipairs(featureLabels) do
            label:SetAlpha(0)
        end
        
        -- Animate logo
        C_Timer.After(0.2, function()
            VUI.Animations:FadeIn(logoPanel, 0.4)
            VUI.Animations:Pulse(logoPanel, 0.6)
        end)
        
        -- Animate welcome panel
        C_Timer.After(0.7, function()
            VUI.Animations:FadeIn(welcomePanel, 0.4)
        end)
        
        -- Animate features panel
        C_Timer.After(1.1, function()
            VUI.Animations:FadeIn(featuresPanel, 0.4)
            
            -- Animate individual features with a cascade effect
            for i, label in ipairs(featureLabels) do
                C_Timer.After(1.3 + (i * 0.15), function()
                    VUI.Animations:FadeIn(label, 0.3)
                end)
            end
        end)
    end
    
    -- Set up hooks for animations
    page:HookScript("OnShow", page.OnShow)
    
    return page
end

-- Create enhanced module overview page with VUIConfig and animations
local function CreateModulesPage(parent)
    local VUIConfig = LibStub('VUIConfig')
    
    local page = VUIConfig:Panel(parent.content)
    page:SetAllPoints()
    page:Hide() -- Initially hidden for animation
    
    -- Title with VUIConfig styling
    local titlePanel = VUIConfig:Panel(page, 700, 60)
    titlePanel:SetPoint("TOP", 0, -20)
    VUIConfig:ApplyBackdrop(titlePanel, "panel")
    
    local title = VUIConfig:Label(titlePanel, "VUI Modules Overview")
    title:SetPoint("CENTER", 0, 0)
    title:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 20)
    VUIConfig:SetTextColor(title, "header")
    
    -- Description panel
    local descPanel = VUIConfig:Panel(page, 700, 60)
    descPanel:SetPoint("TOP", titlePanel, "BOTTOM", 0, -10)
    VUIConfig:ApplyBackdrop(descPanel, "panel")
    
    local desc = VUIConfig:Label(descPanel, "VUI is composed of several specialized modules. Each module focuses on enhancing specific aspects of the game interface.\n\nYou can enable or disable individual modules based on your preferences.")
    desc:SetPoint("CENTER", 0, 0)
    desc:SetWidth(650)
    desc:SetJustifyH("CENTER")
    
    -- Create enhanced scrollframe using VUIConfig
    local scrollFrame = VUIConfig:ScrollFrame(page, 700, 300)
    scrollFrame:SetPoint("TOP", descPanel, "BOTTOM", 0, -10)
    
    -- Module descriptions
    local moduleDescriptions = {
        {name = "VUIBuffs", desc = "Enhanced buff and debuff tracking with configurable layouts and priorities."},
        {name = "VUIAnyFrame", desc = "Control the position and appearance of any frame in the game."},
        {name = "VUIKeystones", desc = "Mythic+ keystone tracking and management tools."},
        {name = "VUICC", desc = "Advanced crowd control tracking for PvP and dungeons."},
        {name = "VUICD", desc = "Comprehensive cooldown tracking with visual alerts."},
        {name = "VUIIDs", desc = "Improved spell and ability identification system."},
        {name = "VUIGfinder", desc = "Enhanced group finder interface with additional filtering options."},
        {name = "VUITGCD", desc = "Track global cooldowns with customizable visual indicators."},
        {name = "VUIAuctionator", desc = "Streamlined auction house interface with advanced search capabilities."},
        {name = "VUINotifications", desc = "Customizable notification system for important game events."},
        {name = "VUIScrollingText", desc = "Combat text enhancement with configurable appearance and filtering."},
        {name = "VUIConsumables", desc = "Track and manage consumables with visual alerts."},
        {name = "VUIMissingRaidBuffs", desc = "Alerts for missing important raid buffs and consumables."},
        {name = "VUIMouseFireTrail", desc = "Visual enhancement for cursor movement."},
        {name = "VUIPlater", desc = "Advanced nameplate customization integrated with VUI."}
    }
    
    -- Add module panels to the scroll frame with animations
    local moduleFrames = {}
    local yOffset = 10
    
    for i, module in ipairs(moduleDescriptions) do
        -- Create module panel with VUIConfig styling
        local moduleFrame = VUIConfig:Panel(scrollFrame.content)
        moduleFrame:SetSize(660, 60)
        moduleFrame:SetPoint("TOPLEFT", 10, -yOffset)
        
        -- Apply VUIConfig styling with alternating colors
        if i % 2 == 0 then
            VUIConfig:ApplyBackdrop(moduleFrame, "button")
        else
            VUIConfig:ApplyBackdrop(moduleFrame, "panel")
        end
        
        -- Module name
        local name = VUIConfig:Label(moduleFrame, module.name)
        name:SetPoint("TOPLEFT", 15, -12)
        name:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 16)
        VUIConfig:SetTextColor(name, "header")
        
        -- Module description
        local descText = VUIConfig:Label(moduleFrame, module.desc)
        descText:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -5)
        descText:SetPoint("RIGHT", moduleFrame, "RIGHT", -15, 0)
        descText:SetJustifyH("LEFT")
        
        -- Add hover highlight effect
        VUIConfig:HookHoverBorder(moduleFrame)
        
        -- Add tooltip functionality with VUIConfig style
        moduleFrame:EnableMouse(true)
        moduleFrame:SetScript("OnEnter", function(self)
            VUI.Animations:Pulse(self, 0.3)
            
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(module.name, 0, 0.9, 1)
            GameTooltip:AddLine(module.desc, 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("You can enable or disable this module in the VUI configuration panel.", 0.6, 0.9, 0.6, true)
            GameTooltip:Show()
        end)
        moduleFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Prepare for animation
        moduleFrame:SetAlpha(0)
        table.insert(moduleFrames, moduleFrame)
        
        yOffset = yOffset + 70
    end
    
    -- Adjust scrollChild height based on content
    scrollFrame.content:SetHeight(yOffset + 20)
    
    -- Set up animation sequence when the page is shown
    page.OnShow = function(self)
        -- Reset elements for animation
        titlePanel:SetAlpha(0)
        descPanel:SetAlpha(0)
        scrollFrame:SetAlpha(0)
        
        for _, frame in ipairs(moduleFrames) do
            frame:SetAlpha(0)
        end
        
        -- Animate title
        C_Timer.After(0.2, function()
            VUI.Animations:FadeIn(titlePanel, 0.4)
        end)
        
        -- Animate description
        C_Timer.After(0.6, function()
            VUI.Animations:FadeIn(descPanel, 0.4)
        end)
        
        -- Animate scroll frame
        C_Timer.After(1.0, function()
            VUI.Animations:FadeIn(scrollFrame, 0.4)
            
            -- Animate modules with cascade effect
            for i, frame in ipairs(moduleFrames) do
                C_Timer.After(1.2 + (i * 0.1), function()
                    VUI.Animations:FadeIn(frame, 0.3)
                    
                    -- Add a subtle bounce effect to draw attention
                    if i % 3 == 0 then  -- Every third module gets a bounce for visual interest
                        C_Timer.After(0.3, function()
                            VUI.Animations:Bounce(frame, 0.4, nil, {height = 5, bounces = 1})
                        end)
                    end
                end)
            end
        end)
    end
    
    -- Set up hooks for animations
    page:HookScript("OnShow", page.OnShow)
    
    return page
end

-- Create enhanced quick-start configuration page with VUIConfig and animations
local function CreateQuickStartPage(parent)
    local VUIConfig = LibStub('VUIConfig')
    
    local page = VUIConfig:Panel(parent.content)
    page:SetAllPoints()
    page:Hide() -- Initially hidden for animation
    
    -- Title with VUIConfig styling
    local titlePanel = VUIConfig:Panel(page, 700, 60)
    titlePanel:SetPoint("TOP", 0, -20)
    VUIConfig:ApplyBackdrop(titlePanel, "panel")
    
    local title = VUIConfig:Label(titlePanel, "Quick-Start Configuration")
    title:SetPoint("CENTER", 0, 0)
    title:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 20)
    VUIConfig:SetTextColor(title, "header")
    
    -- Description panel
    local descPanel = VUIConfig:Panel(page, 700, 60)
    descPanel:SetPoint("TOP", titlePanel, "BOTTOM", 0, -10)
    VUIConfig:ApplyBackdrop(descPanel, "panel")
    
    local desc = VUIConfig:Label(descPanel, "Here are some recommended settings to get you started with VUI. You can always adjust these later through the VUI configuration panel.")
    desc:SetPoint("CENTER", 0, 0)
    desc:SetWidth(650)
    desc:SetJustifyH("CENTER")
    
    -- Create enhanced scrollframe using VUIConfig
    local scrollFrame = VUIConfig:ScrollFrame(page, 700, 300)
    scrollFrame:SetPoint("TOP", descPanel, "BOTTOM", 0, -10)
    
    -- Quick start options
    local options = {
        {category = "General", name = "Minimap Scale", desc = "Adjust the minimap size", value = "1.0"},
        {category = "Unitframes", name = "Player Frame Scale", desc = "Size of your character's unitframe", value = "1.0"},
        {category = "Unitframes", name = "Party Frames", desc = "Show customized party frames", value = "Enabled"},
        {category = "Nameplates", name = "Nameplate Style", desc = "Visual appearance of nameplates", value = "VUI Style"},
        {category = "Actionbars", name = "Action Bar Layout", desc = "Organization of your action buttons", value = "Standard (3 rows)"},
        {category = "Buffs", name = "Buff Position", desc = "Where your buffs appear on screen", value = "Top Right"},
        {category = "Cooldowns", name = "VUICD Style", desc = "Visual style for cooldown tracking", value = "Icon Grid"},
        {category = "Text", name = "VUIScrollingText", desc = "Combat text appearance", value = "Animated"}
    }
    
    -- Storage for animation elements
    local categoryPanels = {}
    local optionPanels = {}
    
    -- Add options using VUIConfig elements
    local yOffset = 10
    
    -- Category headers - using a table to track them
    local categories = {}
    
    for i, option in ipairs(options) do
        -- Create category header if this is the first time we've seen this category
        if not categories[option.category] then
            local categoryPanel = VUIConfig:Panel(scrollFrame.content)
            categoryPanel:SetSize(660, 30)
            categoryPanel:SetPoint("TOPLEFT", 10, -yOffset)
            VUIConfig:ApplyBackdrop(categoryPanel, "button", "border")
            
            -- Category name with VUIConfig styling
            local catName = VUIConfig:Label(categoryPanel, option.category)
            catName:SetPoint("LEFT", 15, 0)
            catName:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 16)
            VUIConfig:SetTextColor(catName, "header")
            
            -- Store for animation
            categoryPanel:SetAlpha(0)
            table.insert(categoryPanels, categoryPanel)
            
            categories[option.category] = true
            yOffset = yOffset + 40
        end
        
        -- Create option panel with VUIConfig styling
        local optionPanel = VUIConfig:Panel(scrollFrame.content)
        optionPanel:SetSize(660, 50)
        optionPanel:SetPoint("TOPLEFT", 10, -yOffset)
        
        -- Apply VUIConfig styling with alternating colors
        if i % 2 == 0 then
            VUIConfig:ApplyBackdrop(optionPanel, "button")
        else
            VUIConfig:ApplyBackdrop(optionPanel, "panel")
        end
        
        -- Option name
        local nameText = VUIConfig:Label(optionPanel, option.name)
        nameText:SetPoint("TOPLEFT", 20, -12)
        nameText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 14)
        
        -- Option description
        local descText = VUIConfig:Label(optionPanel, option.desc)
        descText:SetPoint("BOTTOMLEFT", 20, 12)
        descText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 12)
        
        -- Default value with accent color
        local valueText = VUIConfig:Label(optionPanel, option.value)
        valueText:SetPoint("RIGHT", -20, 0)
        valueText:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 14)
        valueText:SetTextColor(0, 1, 0.4) -- Bright green
        
        -- Add hover highlight and tooltip
        VUIConfig:HookHoverBorder(optionPanel)
        
        optionPanel:EnableMouse(true)
        optionPanel:SetScript("OnEnter", function(self)
            VUI.Animations:Pulse(self, 0.3)
            
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(option.name, 0, 0.9, 1)
            GameTooltip:AddLine(option.desc, 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("This setting can be changed later in the VUI configuration panel.", 0.6, 0.9, 0.6, true)
            GameTooltip:Show()
        end)
        optionPanel:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Prepare for animation
        optionPanel:SetAlpha(0)
        table.insert(optionPanels, optionPanel)
        
        yOffset = yOffset + 60
    end
    
    -- Adjust scrollFrame content height
    scrollFrame.content:SetHeight(yOffset + 20)
    
    -- Note about further customization
    local notePanel = VUIConfig:Panel(page, 700, 60)
    notePanel:SetPoint("BOTTOM", 0, 20)
    VUIConfig:ApplyBackdrop(notePanel, "panel")
    
    local note = VUIConfig:Label(notePanel, "These are baseline settings to get you started. You can fully customize every aspect of VUI through the configuration panel that will open after this setup.")
    note:SetPoint("CENTER", 0, 0)
    note:SetWidth(680)
    note:SetJustifyH("CENTER")
    notePanel:SetAlpha(0) -- Hidden for animation
    
    -- Set up animation sequence when the page is shown
    page.OnShow = function(self)
        -- Reset elements for animation
        titlePanel:SetAlpha(0)
        descPanel:SetAlpha(0)
        scrollFrame:SetAlpha(0)
        notePanel:SetAlpha(0)
        
        -- Reset all option and category panels
        for _, panel in ipairs(categoryPanels) do
            panel:SetAlpha(0)
        end
        
        for _, panel in ipairs(optionPanels) do
            panel:SetAlpha(0)
        end
        
        -- Animate title
        C_Timer.After(0.2, function()
            VUI.Animations:FadeIn(titlePanel, 0.4)
        end)
        
        -- Animate description
        C_Timer.After(0.6, function()
            VUI.Animations:FadeIn(descPanel, 0.4)
        end)
        
        -- Animate scroll frame
        C_Timer.After(1.0, function()
            VUI.Animations:FadeIn(scrollFrame, 0.4)
            
            -- Animate categories with staggered timing
            for i, panel in ipairs(categoryPanels) do
                C_Timer.After(1.2 + (i * 0.2), function()
                    VUI.Animations:FadeIn(panel, 0.3)
                    VUI.Animations:Pulse(panel, 0.4)
                end)
            end
            
            -- Animate options with cascade effect
            for i, panel in ipairs(optionPanels) do
                C_Timer.After(1.4 + (i * 0.1), function()
                    VUI.Animations:FadeIn(panel, 0.3)
                end)
            end
        end)
        
        -- Animate note at the end
        C_Timer.After(3.0, function()
            VUI.Animations:FadeIn(notePanel, 0.6)
        end)
    end
    
    -- Set up hooks for animations
    page:HookScript("OnShow", page.OnShow)
    
    return page
end

-- Create enhanced completion page with VUIConfig and animations
local function CreateCompletionPage(parent)
    local VUIConfig = LibStub('VUIConfig')
    
    local page = VUIConfig:Panel(parent.content)
    page:SetAllPoints()
    page:Hide() -- Initially hidden for animation
    
    -- Premium styled completion header panel
    local headerPanel = VUIConfig:Panel(page, 700, 120)
    headerPanel:SetPoint("TOP", 0, -20)
    VUIConfig:ApplyBackdrop(headerPanel, "panel")
    
    -- Add a decorative border for premium feel
    local borderFrame = CreateFrame("Frame", nil, headerPanel)
    borderFrame:SetPoint("TOPLEFT", -3, 3)
    borderFrame:SetPoint("BOTTOMRIGHT", 3, -3)
    borderFrame:SetBackdrop({
        edgeFile = "Interface\\AddOns\\VUI\\Media\\Textures\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    borderFrame:SetBackdropBorderColor(0.8, 0.7, 0.2, 0.7) -- Gold border for achievement feel
    
    -- Add decorative corners for elegant design
    local function CreateCornerTexture(parent, position)
        local texture = parent:CreateTexture(nil, "OVERLAY")
        texture:SetSize(32, 32)
        texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner")
        
        if position == "TOPLEFT" then
            texture:SetPoint("TOPLEFT", parent, "TOPLEFT", -5, 5)
            texture:SetTexCoord(0, 0.5, 0, 0.5)
        elseif position == "TOPRIGHT" then
            texture:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 5, 5)
            texture:SetTexCoord(0.5, 1, 0, 0.5)
        elseif position == "BOTTOMLEFT" then
            texture:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", -5, -5)
            texture:SetTexCoord(0, 0.5, 0.5, 1)
        elseif position == "BOTTOMRIGHT" then
            texture:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 5, -5)
            texture:SetTexCoord(0.5, 1, 0.5, 1)
        end
        
        return texture
    end
    
    CreateCornerTexture(headerPanel, "TOPLEFT")
    CreateCornerTexture(headerPanel, "TOPRIGHT")
    CreateCornerTexture(headerPanel, "BOTTOMLEFT")
    CreateCornerTexture(headerPanel, "BOTTOMRIGHT")
    
    -- "Setup Complete" title with premium styling
    local title = VUIConfig:Label(headerPanel, "Installation Complete!")
    title:SetPoint("CENTER", 0, 20)
    title:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 36, "OUTLINE")
    
    -- Create a gradient color effect for the text
    local titleAnimation = title:CreateAnimationGroup()
    titleAnimation:SetLooping("REPEAT")
    
    local colorShift = titleAnimation:CreateAnimation("Color")
    colorShift:SetDuration(3)
    colorShift:SetColorType("Vertex")
    colorShift:SetFromAlpha(1)
    colorShift:SetToAlpha(1)
    colorShift:SetFromR(0.1)
    colorShift:SetFromG(0.6)
    colorShift:SetFromB(1)
    colorShift:SetToR(0.8)
    colorShift:SetToG(0.3)
    colorShift:SetToB(1)
    
    titleAnimation:Play()
    
    -- Add a subtitle for extra polish
    local subtitle = VUIConfig:Label(headerPanel, "Your journey to a perfect UI begins now")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    subtitle:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 18)
    subtitle:SetTextColor(0.9, 0.9, 0.9)
    
    -- VUI logo with Vortex thunderstorm icon
    local logoPanel = VUIConfig:Panel(page, 300, 100)
    logoPanel:SetPoint("TOP", headerPanel, "BOTTOM", 0, -20)
    VUIConfig:ApplyBackdrop(logoPanel, "panel")
    
    -- Add the Vortex thunderstorm icon
    local logoIcon = logoPanel:CreateTexture(nil, "ARTWORK")
    logoIcon:SetSize(64, 64) 
    logoIcon:SetPoint("LEFT", logoPanel, "LEFT", 30, 0)
    logoIcon:SetTexture("Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm")
    
    -- Add a subtle pulse animation to the icon
    local iconAnimGroup = logoIcon:CreateAnimationGroup()
    iconAnimGroup:SetLooping("REPEAT")
    
    local iconGrowth = iconAnimGroup:CreateAnimation("Scale")
    iconGrowth:SetScaleFrom(1.0, 1.0)
    iconGrowth:SetScaleTo(1.1, 1.1)
    iconGrowth:SetDuration(1.5)
    iconGrowth:SetOrder(1)
    
    local iconShrink = iconAnimGroup:CreateAnimation("Scale")
    iconShrink:SetScaleFrom(1.1, 1.1)
    iconShrink:SetScaleTo(1.0, 1.0)
    iconShrink:SetDuration(1.5)
    iconShrink:SetOrder(2)
    
    iconAnimGroup:Play()
    
    local logo = VUIConfig:Label(logoPanel, "|cffea00ffV|r|cff00a2ffUI|r")
    logo:SetPoint("CENTER", 20, 0) -- Shift text to balance with icon
    logo:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 64, "OUTLINE")
    
    -- Enhanced congratulations panel with professional styling
    local congratsPanel = VUIConfig:Panel(page, 700, 140)
    congratsPanel:SetPoint("TOP", logoPanel, "BOTTOM", 0, -20)
    VUIConfig:ApplyBackdrop(congratsPanel, "panel")
    
    -- Add a subtle texture background for more visual interest
    local bgTexture = congratsPanel:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints()
    bgTexture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\UI-GuildAchievement-Parchment-Horizontal")
    bgTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Adjust to show just the clean part
    bgTexture:SetAlpha(0.15) -- Very subtle
    
    -- Create a header for the congratulations text
    local congratsHeader = VUIConfig:Label(congratsPanel, "Begin Your Enhanced WoW Experience")
    congratsHeader:SetPoint("TOP", 0, -15)
    congratsHeader:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 20)
    congratsHeader:SetTextColor(0.2, 0.8, 0.4) -- Emerald green for success
    
    -- Main congratulations text with more inspiring message
    local finalText = VUIConfig:Label(congratsPanel, "You've successfully installed the most advanced UI enhancement suite available for World of Warcraft. VUI has been configured with optimal settings to provide both performance and visual excellence.\n\nYour next step is to explore the wealth of customization options that await you in the VUI configuration panel.")
    finalText:SetPoint("TOP", congratsHeader, "BOTTOM", 0, -10)
    finalText:SetWidth(650)
    finalText:SetJustifyH("CENTER")
    
    -- Command reference panel
    local commandPanel = VUIConfig:Panel(page, 400, 60)
    commandPanel:SetPoint("TOP", congratsPanel, "BOTTOM", 0, -20)
    VUIConfig:ApplyBackdrop(commandPanel, "button")
    
    local commandText = VUIConfig:Label(commandPanel, "Access VUI settings anytime with:")
    commandText:SetPoint("TOP", 0, -10)
    
    local commandExample = VUIConfig:Label(commandPanel, "|cff00a2ff/vui|r or |cff00a2ff/vui config|r")
    commandExample:SetPoint("BOTTOM", 0, 10)
    commandExample:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 16)
    
    -- Enhanced tips panel with professional styling
    local tipsPanel = VUIConfig:Panel(page, 700, 140)
    tipsPanel:SetPoint("TOP", commandPanel, "BOTTOM", 0, -20)
    VUIConfig:ApplyBackdrop(tipsPanel, "panel")
    
    -- Add subtle golden glow around the tips panel for premium feel
    local glowFrame = CreateFrame("Frame", nil, tipsPanel)
    glowFrame:SetPoint("TOPLEFT", -5, 5)
    glowFrame:SetPoint("BOTTOMRIGHT", 5, -5)
    local glowTexture = glowFrame:CreateTexture(nil, "BACKGROUND")
    glowTexture:SetAllPoints()
    glowTexture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\UI-Achievement-Guild-Glow")
    glowTexture:SetBlendMode("ADD")
    glowTexture:SetVertexColor(0.7, 0.7, 0.2, 0.1) -- Subtle gold
    
    -- Premium styled header with icon
    local tipsHeaderFrame = CreateFrame("Frame", nil, tipsPanel)
    tipsHeaderFrame:SetSize(200, 28)
    tipsHeaderFrame:SetPoint("TOP", 0, -10)
    
    local tipsIcon = tipsHeaderFrame:CreateTexture(nil, "ARTWORK")
    tipsIcon:SetSize(24, 24)
    tipsIcon:SetPoint("LEFT", tipsHeaderFrame, "LEFT")
    tipsIcon:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\Config\\Icon")
    
    local tipsHeader = VUIConfig:Label(tipsHeaderFrame, "PRO TIPS")
    tipsHeader:SetPoint("LEFT", tipsIcon, "RIGHT", 10, 0)
    tipsHeader:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 18, "OUTLINE")
    tipsHeader:SetTextColor(0.95, 0.85, 0.45) -- Gold color for premium feel
    
    -- Create individual tip items with more professional wording
    local tips = {
        "• Explore tooltips in the configuration panel for advanced feature insights",
        "• Utilize VUI profiles to create specialized setups for different play styles",
        "• Fine-tune your experience by selectively enabling just the modules you need",
        "• Access the complete command reference with '/vui help' anytime"
    }
    
    local tipLabels = {}
    for i, tip in ipairs(tips) do
        local tipLabel = VUIConfig:Label(tipsPanel, tip)
        tipLabel:SetPoint("TOPLEFT", 40, -30 - ((i-1) * 18))
        tipLabel:SetWidth(620)
        tipLabel:SetJustifyH("LEFT")
        tipLabel:SetAlpha(0) -- Start invisible for animation
        table.insert(tipLabels, tipLabel)
    end
    
    -- Set up animation sequence when the page is shown
    page.OnShow = function(self)
        -- Reset elements for animation
        headerPanel:SetAlpha(0)
        logoPanel:SetAlpha(0)
        congratsPanel:SetAlpha(0)
        commandPanel:SetAlpha(0)
        tipsPanel:SetAlpha(0)
        
        for _, label in ipairs(tipLabels) do
            label:SetAlpha(0)
        end
        
        -- Animate header with pulse
        C_Timer.After(0.2, function()
            VUI.Animations:FadeIn(headerPanel, 0.5)
            C_Timer.After(0.5, function()
                VUI.Animations:Pulse(headerPanel, 0.6)
            end)
        end)
        
        -- Animate logo with bounce
        C_Timer.After(0.7, function()
            VUI.Animations:FadeIn(logoPanel, 0.5)
            C_Timer.After(0.5, function()
                VUI.Animations:Bounce(logoPanel, 0.7, nil, {height = 15, bounces = 2})
            end)
        end)
        
        -- Animate congratulations text
        C_Timer.After(1.4, function()
            VUI.Animations:FadeIn(congratsPanel, 0.5)
        end)
        
        -- Animate command panel with pulse
        C_Timer.After(1.9, function()
            VUI.Animations:FadeIn(commandPanel, 0.5)
            C_Timer.After(0.5, function()
                VUI.Animations:Pulse(commandPanel, 0.4)
            end)
        end)
        
        -- Animate tips panel
        C_Timer.After(2.4, function()
            VUI.Animations:FadeIn(tipsPanel, 0.5)
            
            -- Animate individual tips with cascade effect
            for i, label in ipairs(tipLabels) do
                C_Timer.After(2.6 + (i * 0.2), function()
                    VUI.Animations:SlideIn(label, "RIGHT", 0.4, nil, {distance = 50})
                end)
            end
        end)
    end
    
    -- Set up hooks for animations
    page:HookScript("OnShow", page.OnShow)
    
    return page
end

function Module:OnEnable()
    if not (VUI.db.profile.install) then
        -- Create the installation wizard
        local Install = CreateInstallWizard()
        
        -- Add pages to the wizard
        table.insert(Install.pages, CreateWelcomePage(Install))
        table.insert(Install.pages, CreateModulesPage(Install))
        table.insert(Install.pages, CreateQuickStartPage(Install))
        table.insert(Install.pages, CreateCompletionPage(Install))
        
        -- Initialize with the first page
        Install:GoToPage(1)
    end
end
