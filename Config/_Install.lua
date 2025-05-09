local Module = VUI:NewModule("Config.Install");

-- Define the multi-step installation wizard
local function CreateInstallWizard()
    -- Main frame for installation wizard
    local Install = CreateFrame("Frame", "VUIInstallWizard", UIParent)
    Install:SetWidth(800)
    Install:SetHeight(600)
    Install:SetPoint("CENTER", 0, 0)
    Install:EnableMouse(true)
    Install:SetFrameStrata("HIGH")
    
    -- Background texture
    local Texture = Install:CreateTexture(nil, "BACKGROUND")
    Texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    Texture:SetAllPoints(Install)
    Install.texture = Texture
    
    -- Title header
    Install.header = Install:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    Install.header:SetPoint("TOP", 0, -20)
    Install.header:SetText("|cffea00ffV|r|cff00a2ffUI|r - The Vortex UI Suite")
    Install.header:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 24, "OUTLINE")
    
    -- Subtitle
    Install.subtitle = Install:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    Install.subtitle:SetPoint("TOP", Install.header, "BOTTOM", 0, -5)
    Install.subtitle:SetText("A Comprehensive UI Customization Suite")
    
    -- Page indicator text
    Install.pageText = Install:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    Install.pageText:SetPoint("BOTTOMRIGHT", -10, 10)
    
    -- Navigation buttons
    Install.prevButton = CreateFrame("Button", nil, Install, "UIPanelButtonTemplate")
    Install.prevButton:SetSize(100, 25)
    Install.prevButton:SetPoint("BOTTOMLEFT", 10, 10)
    Install.prevButton:SetText("Previous")
    Install.prevButton:Hide()
    
    Install.nextButton = CreateFrame("Button", nil, Install, "UIPanelButtonTemplate")
    Install.nextButton:SetSize(100, 25)
    Install.nextButton:SetPoint("BOTTOMRIGHT", -10, 10)
    Install.nextButton:SetText("Next")
    
    Install.skipButton = CreateFrame("Button", nil, Install, "UIPanelButtonTemplate")
    Install.skipButton:SetSize(100, 25)
    Install.skipButton:SetPoint("BOTTOM", 0, 10)
    Install.skipButton:SetText("Skip Setup")
    
    -- Content container frame
    Install.content = CreateFrame("Frame", nil, Install)
    Install.content:SetSize(750, 450)
    Install.content:SetPoint("TOP", Install.subtitle, "BOTTOM", 0, -20)
    
    -- Store pages and current page
    Install.pages = {}
    Install.currentPage = 1
    
    -- Navigation functions
    Install.GoToPage = function(self, pageNum)
        -- Hide all pages
        for i, page in ipairs(self.pages) do
            page:Hide()
        end
        
        -- Show requested page
        if pageNum >= 1 and pageNum <= #self.pages then
            self.currentPage = pageNum
            self.pages[pageNum]:Show()
            
            -- Update page indicator
            self.pageText:SetText("Page " .. pageNum .. " of " .. #self.pages)
            
            -- Update button visibility
            if pageNum == 1 then
                self.prevButton:Hide()
            else
                self.prevButton:Show()
            end
            
            if pageNum == #self.pages then
                self.nextButton:SetText("Finish")
            else
                self.nextButton:SetText("Next")
            end
        end
    end
    
    -- Setup button scripts
    Install.prevButton:SetScript("OnClick", function()
        if Install.currentPage > 1 then
            Install:GoToPage(Install.currentPage - 1)
        end
    end)
    
    Install.nextButton:SetScript("OnClick", function()
        if Install.currentPage < #Install.pages then
            Install:GoToPage(Install.currentPage + 1)
        else
            -- On the last page, clicking "Finish" completes installation
            VUI.db.profile.install = true
            VUI.db.profile.reset = true
            
            -- Apply default settings
            VUI:ConfigureFirstTimeSetup()
            
            local fadeInfo = {};
            fadeInfo.mode = "OUT";
            fadeInfo.timeToFade = 0.4;
            fadeInfo.finishedFunc = function()
                Install:Hide()
                VUI:Config()
            end
            UIFrameFade(Install, fadeInfo);
        end
    end)
    
    Install.skipButton:SetScript("OnClick", function()
        VUI.db.profile.install = true
        VUI.db.profile.reset = true
        
        -- Apply default settings even when skipping
        VUI:ConfigureFirstTimeSetup()
        
        local fadeInfo = {};
        fadeInfo.mode = "OUT";
        fadeInfo.timeToFade = 0.4;
        fadeInfo.finishedFunc = function()
            Install:Hide()
            VUI:Config()
        end
        UIFrameFade(Install, fadeInfo);
    end)
    
    return Install
end

-- Create pages for the installation wizard
local function CreateWelcomePage(parent)
    local page = CreateFrame("Frame", nil, parent.content)
    page:SetAllPoints()
    
    -- VUI Logo (we'll use text since we don't have direct image access)
    local logo = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    logo:SetPoint("TOP", 0, 0)
    logo:SetText("|cffea00ffV|r|cff00a2ffUI|r")
    logo:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 64, "OUTLINE")
    
    -- Welcome text
    local welcomeText = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    welcomeText:SetPoint("TOP", logo, "BOTTOM", 0, -40)
    welcomeText:SetWidth(650)
    welcomeText:SetJustifyH("CENTER")
    welcomeText:SetText("Welcome to VUI (Vortex UI), a comprehensive user interface enhancement suite for World of Warcraft.\n\nVUI brings together the best addons and features in a unified, customizable package to improve your gameplay experience.\n\nThis setup wizard will guide you through the initial configuration of VUI.")
    
    -- Feature highlights
    local features = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    features:SetPoint("TOP", welcomeText, "BOTTOM", 0, -40)
    features:SetWidth(650)
    features:SetJustifyH("LEFT")
    features:SetText("Key Features:\n\n• Modular design - Enable only what you need\n• Enhanced combat feedback and tracking\n• Streamlined auction house interface\n• Advanced raid and party tools\n• Customizable notifications\n• Comprehensive cooldown management")
    
    return page
end

-- Create module overview page
local function CreateModulesPage(parent)
    local page = CreateFrame("Frame", nil, parent.content)
    page:SetAllPoints()
    
    -- Title
    local title = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, 0)
    title:SetText("VUI Modules Overview")
    
    -- Description
    local desc = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    desc:SetPoint("TOP", title, "BOTTOM", 0, -20)
    desc:SetWidth(700)
    desc:SetJustifyH("CENTER")
    desc:SetText("VUI is composed of several specialized modules. Each module focuses on enhancing specific aspects of the game interface.\n\nYou can enable or disable individual modules based on your preferences.")
    
    -- Create scrollframe for module list
    local scrollFrame = CreateFrame("ScrollFrame", nil, page, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 300)
    scrollFrame:SetPoint("TOP", desc, "BOTTOM", 0, -20)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(680, 600) -- Extra height for scrolling
    
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
    
    -- Add module descriptions
    local lastElement
    local yOffset = 10
    
    for i, module in ipairs(moduleDescriptions) do
        local moduleFrame = CreateFrame("Frame", nil, scrollChild)
        moduleFrame:SetSize(660, 50)
        moduleFrame:SetPoint("TOPLEFT", 10, -yOffset)
        
        -- Add a subtle background
        local bg = moduleFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, i % 2 == 0 and 0.3 or 0.1) -- Alternating row colors
        
        -- Module name
        local name = moduleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        name:SetPoint("TOPLEFT", 10, -10)
        name:SetText("|cff00a2ff" .. module.name .. "|r")
        
        -- Module description
        local desc = moduleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -5)
        desc:SetPoint("RIGHT", moduleFrame, "RIGHT", -10, 0)
        desc:SetJustifyH("LEFT")
        desc:SetText(module.desc)
        
        -- Add tooltip functionality
        moduleFrame:EnableMouse(true)
        moduleFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(module.name, 1, 0.5, 1)
            GameTooltip:AddLine(module.desc, 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("You can enable or disable this module in the VUI configuration panel.", 0.6, 0.9, 0.6, true)
            GameTooltip:Show()
        end)
        moduleFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        yOffset = yOffset + 60
        lastElement = moduleFrame
    end
    
    -- Adjust scrollChild height based on content
    scrollChild:SetHeight(yOffset + 20)
    
    return page
end

-- Create quick-start configuration page
local function CreateQuickStartPage(parent)
    local page = CreateFrame("Frame", nil, parent.content)
    page:SetAllPoints()
    
    -- Title
    local title = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, 0)
    title:SetText("Quick-Start Configuration")
    
    -- Description
    local desc = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    desc:SetPoint("TOP", title, "BOTTOM", 0, -20)
    desc:SetWidth(700)
    desc:SetJustifyH("CENTER")
    desc:SetText("Here are some recommended settings to get you started with VUI. You can always adjust these later through the VUI configuration panel.")
    
    -- Create scrollframe for settings
    local scrollFrame = CreateFrame("ScrollFrame", nil, page, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 300)
    scrollFrame:SetPoint("TOP", desc, "BOTTOM", 0, -20)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(680, 600) -- Extra height for scrolling
    
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
    
    -- Add options
    local lastElement
    local yOffset = 10
    
    -- Category headers
    local categories = {}
    
    for i, option in ipairs(options) do
        -- Create category header if this is the first time we've seen this category
        if not categories[option.category] then
            local categoryFrame = CreateFrame("Frame", nil, scrollChild)
            categoryFrame:SetSize(660, 30)
            categoryFrame:SetPoint("TOPLEFT", 10, -yOffset)
            
            -- Add category background
            local catBg = categoryFrame:CreateTexture(nil, "BACKGROUND")
            catBg:SetAllPoints()
            catBg:SetColorTexture(0.2, 0.2, 0.4, 0.5)
            
            -- Category name
            local catName = categoryFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            catName:SetPoint("LEFT", 10, 0)
            catName:SetText(option.category)
            
            categories[option.category] = true
            yOffset = yOffset + 40
        end
        
        -- Create option frame
        local optionFrame = CreateFrame("Frame", nil, scrollChild)
        optionFrame:SetSize(660, 40)
        optionFrame:SetPoint("TOPLEFT", 10, -yOffset)
        
        -- Add a subtle background
        local bg = optionFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, i % 2 == 0 and 0.2 or 0.1) -- Alternating row colors
        
        -- Option name
        local name = optionFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        name:SetPoint("TOPLEFT", 20, -10)
        name:SetText("|cffdddddd" .. option.name .. "|r")
        
        -- Option description
        local desc = optionFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        desc:SetPoint("BOTTOMLEFT", 20, 10)
        desc:SetText(option.desc)
        
        -- Default value
        local value = optionFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        value:SetPoint("RIGHT", -20, 0)
        value:SetText("|cff00ff00" .. option.value .. "|r")
        
        -- Add tooltip functionality
        optionFrame:EnableMouse(true)
        optionFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(option.name, 1, 1, 1)
            GameTooltip:AddLine(option.desc, 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("This setting can be changed later in the VUI configuration panel.", 0.6, 0.9, 0.6, true)
            GameTooltip:Show()
        end)
        optionFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        yOffset = yOffset + 50
        lastElement = optionFrame
    end
    
    -- Adjust scrollChild height based on content
    scrollChild:SetHeight(yOffset + 20)
    
    -- Note about further customization
    local note = page:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    note:SetPoint("BOTTOM", 0, 70)
    note:SetWidth(700)
    note:SetJustifyH("CENTER")
    note:SetText("Note: These are just baseline settings to get you started. You can fully customize every aspect of VUI through the configuration panel, which will open after this setup.")
    
    return page
end

-- Create final page with completion message
local function CreateCompletionPage(parent)
    local page = CreateFrame("Frame", nil, parent.content)
    page:SetAllPoints()
    
    -- Completion message
    local title = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, 0)
    title:SetText("Setup Complete!")
    
    -- VUI logo again
    local logo = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    logo:SetPoint("TOP", title, "BOTTOM", 0, -20)
    logo:SetText("|cffea00ffV|r|cff00a2ffUI|r")
    logo:SetFont("Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 48, "OUTLINE")
    
    -- Final instructions
    local finalText = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    finalText:SetPoint("TOP", logo, "BOTTOM", 0, -40)
    finalText:SetWidth(650)
    finalText:SetJustifyH("CENTER")
    finalText:SetText("Congratulations! VUI is now set up with recommended settings.\n\nAfter clicking 'Finish', the VUI configuration panel will open where you can further customize every aspect of the interface to your liking.\n\nYou can always access the VUI configuration panel by typing:\n\n|cff00a2ff/vui|r or |cff00a2ff/vui config|r")
    
    -- Tips section
    local tips = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tips:SetPoint("TOP", finalText, "BOTTOM", 0, -40)
    tips:SetWidth(650)
    tips:SetJustifyH("LEFT")
    tips:SetText("Quick Tips:\n\n• Hover over options in the configuration panel for detailed tooltips\n• Use VUI profiles to save different configurations for different characters\n• Most modules can be enabled/disabled independently\n• Type /vui help for a list of all available commands")
    
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
