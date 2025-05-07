--[[
    VUI - Help System
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Help module if it doesn't exist
if not VUI.modules then VUI.modules = {} end
if not VUI.modules.help then VUI.modules.help = {} end

local Help = VUI.modules.help

-- Initialize the module
function Help:Initialize()
    -- Default configuration
    self.defaults = {
        profile = {
            enabled = true,
            showTooltips = true,
            enhancedTooltips = true,
            contextualHelp = true,
            showTips = true,
            helpLevel = 2, -- 1 = Basic, 2 = Detailed, 3 = Advanced
            firstTimeHelp = true,
            showAliases = true,
            showCooldowns = true,
            highlightNewFeatures = true
        }
    }
    
    -- Register module with core
    VUI:RegisterModule("help", self)
    
    -- Initialize theme integration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Setup configuration panel
    self:CreateConfigPanel()
    
    -- Register for various events to display contextual help
    self:RegisterEvents()
    
    -- Initialize help database
    self:InitializeHelpDatabase()
    
    -- Register slash command
    self:RegisterSlashCommands()
    
    -- Register tooltips for standard UI elements
    self:RegisterStandardTooltips()
    
    VUI:Print("Help module initialized")
end

-- Register necessary events
function Help:RegisterEvents()
    -- Register for events when module config opens
    VUI:RegisterCallback("ConfigPanelOpened", function(module)
        self:ShowModuleHelp(module)
    end)
    
    -- Register for first time setup
    VUI:RegisterCallback("FirstTimeSetup", function()
        if self.settings.firstTimeHelp then
            self:ShowWelcomeHelp()
        end
    end)
    
    -- Register for new features
    VUI:RegisterCallback("VersionChanged", function(oldVersion, newVersion)
        if self.settings.highlightNewFeatures then
            self:ShowNewFeatures(oldVersion, newVersion)
        end
    end)
end

-- Create the configuration panel
function Help:CreateConfigPanel()
    local options = {
        name = "Help System",
        type = "group",
        args = {
            enabled = {
                name = "Enable Help System",
                desc = "Enable or disable the help system",
                type = "toggle",
                width = "full",
                order = 1,
                get = function() return VUI.db.profile.help.enabled end,
                set = function(_, value) 
                    VUI.db.profile.help.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end
            },
            showTooltips = {
                name = "Show Tooltips",
                desc = "Show helpful tooltips when hovering over UI elements",
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return VUI.db.profile.help.showTooltips end,
                set = function(_, value) VUI.db.profile.help.showTooltips = value end
            },
            enhancedTooltips = {
                name = "Enhanced Tooltips",
                desc = "Show more detailed information in tooltips",
                type = "toggle",
                width = "full",
                order = 3,
                get = function() return VUI.db.profile.help.enhancedTooltips end,
                set = function(_, value) VUI.db.profile.help.enhancedTooltips = value end
            },
            contextualHelp = {
                name = "Contextual Help",
                desc = "Show relevant help based on what you're currently doing",
                type = "toggle",
                width = "full",
                order = 4,
                get = function() return VUI.db.profile.help.contextualHelp end,
                set = function(_, value) VUI.db.profile.help.contextualHelp = value end
            },
            showTips = {
                name = "Show Tips",
                desc = "Show helpful tips about VUI features occasionally",
                type = "toggle",
                width = "full",
                order = 5,
                get = function() return VUI.db.profile.help.showTips end,
                set = function(_, value) VUI.db.profile.help.showTips = value end
            },
            helpLevel = {
                name = "Help Detail Level",
                desc = "Set how detailed the help information should be",
                type = "select",
                values = {
                    [1] = "Basic - Essential information only",
                    [2] = "Detailed - Comprehensive help for most features",
                    [3] = "Advanced - Include technical details and advanced usage"
                },
                width = "full",
                order = 6,
                get = function() return VUI.db.profile.help.helpLevel end,
                set = function(_, value) VUI.db.profile.help.helpLevel = value end
            },
            resetHelp = {
                name = "Reset First-Time Help",
                desc = "Show the welcome help and introductory messages again",
                type = "execute",
                width = "full",
                order = 7,
                func = function()
                    VUI.db.profile.help.firstTimeHelp = true
                    self:ShowWelcomeHelp()
                end
            }
        }
    }
    
    -- Register with VUI's config system
    VUI.ModuleAPI:RegisterModuleConfig("help", options)
end

-- Initialize database of help content
function Help:InitializeHelpDatabase()
    self.helpContent = {
        -- General help
        general = {
            title = "VUI Help",
            content = "VUI is a comprehensive UI enhancement suite with multiple modules.",
            commands = {
                { command = "/vui", description = "Open the main configuration panel" },
                { command = "/rl", description = "Reload the UI" },
                { command = "/vui help", description = "Show this help" }
            },
            tips = {
                "You can change themes in the Appearance tab.",
                "Right-click many UI elements for quick options.",
                "Performance options can help on lower-end systems."
            }
        },
        
        -- Module-specific help
        modules = {
            buffoverlay = {
                title = "BuffOverlay Help",
                content = "BuffOverlay enhances buff and debuff tracking with categorization and visibility options.",
                features = {
                    "Five priority categories for auras",
                    "Enhanced visibility for important buffs",
                    "PvP diminishing returns tracking",
                    "Special effects for critical buffs"
                },
                tips = {
                    "Try the 'High Contrast' mode for better visibility in busy situations.",
                    "Right-click buffs to quickly blacklist them."
                }
            },
            
            trufigcd = {
                title = "TrufiGCD Help",
                content = "TrufiGCD tracks recently used abilities with a visual timeline.",
                features = {
                    "Visual history of recent spell casts",
                    "Categorized ability tracking",
                    "Enhanced visibility options",
                    "Timeline view option"
                },
                tips = {
                    "Try different layout options to find what works best for you.",
                    "You can filter specific spells or categories."
                }
            },
            
            multinotification = {
                title = "MultiNotification Help",
                content = "MultiNotification provides alerts for important game events.",
                features = {
                    "Centralized notification system",
                    "Multiple animation styles",
                    "Sound alerts for critical events",
                    "Priority-based filtering"
                },
                tips = {
                    "Customize which events trigger notifications in the settings.",
                    "Try different animation styles for better visibility."
                }
            },
            
            omnicd = {
                title = "OmniCD Help",
                content = "OmniCD tracks party and raid cooldowns with enhanced visibility.",
                features = {
                    "Party cooldown tracking",
                    "Eight functional categories",
                    "Enhanced raid layouts",
                    "Priority-based display"
                },
                tips = {
                    "Use different layouts for different group sizes.",
                    "Prioritize important cooldowns for better visibility."
                }
            },
            
            detailsskin = {
                title = "DetailsSkin Help",
                content = "DetailsSkin provides themed appearance for the Details! damage meter.",
                features = {
                    "Theme-specific appearance",
                    "Enhanced graph styling",
                    "Custom report templates",
                    "War Within special skin"
                },
                tips = {
                    "Try different themes to match your UI.",
                    "Check out the custom report templates for sharing data."
                }
            }
        },
        
        -- Feature-specific help
        features = {
            themes = {
                title = "Themes Help",
                content = "VUI includes five comprehensive UI themes that transform the appearance of all UI elements.",
                themes = {
                    { name = "Phoenix Flame", description = "Warm, fiery appearance with orange accents" },
                    { name = "Thunder Storm", description = "Cool blue color scheme (Default)" },
                    { name = "Arcane Mystic", description = "Mystical purple appearance" },
                    { name = "Fel Energy", description = "Vibrant green theme" },
                    { name = "Class Color", description = "Adapts to your character's class color" }
                },
                tips = {
                    "Try different themes to find what matches your style.",
                    "All themes are designed for optimal visibility in all situations."
                }
            },
            
            performance = {
                title = "Performance Help",
                content = "VUI includes several performance optimization systems.",
                features = {
                    "Texture Atlas system for improved memory usage",
                    "Frame pooling for dynamic UI elements",
                    "Spell detection optimization",
                    "Event handling optimization",
                    "Memory usage reduction"
                },
                tips = {
                    "Check the Performance Dashboard for real-time metrics.",
                    "Try different performance profiles for different scenarios."
                }
            },
            
            profiles = {
                title = "Profiles Help",
                content = "VUI's profile system allows you to save and share settings.",
                features = {
                    "Character-specific profiles",
                    "Role-based profiles",
                    "Import/export functionality",
                    "Copy settings between characters"
                },
                tips = {
                    "Create specific profiles for different content types.",
                    "Export your profiles to share with friends."
                }
            }
        },
        
        -- New features by version
        newFeatures = {
            ["1.0.0"] = {
                title = "What's New in VUI 1.0.0",
                features = {
                    "Standardized version numbering across all modules",
                    "Enhanced theme integration for all modules",
                    "Complete module verification and validation",
                    "Fixed initialization functions in InfoFrame and Tooltip modules",
                    "Improved theme preview with all five theme options",
                    "Streamlined configuration panel with better organization",
                    "Fixed DetailsSkin module graphs and functionality"
                }
            },
            ["0.3.0"] = {
                title = "Previous Release: VUI 0.3.0",
                features = {
                    "Comprehensive documentation system",
                    "Enhanced configuration tooltips",
                    "Improved first-time user experience",
                    "Enhanced theme preview system",
                    "Module dependency visualization",
                    "Profile export/import functionality",
                    "Enhanced macro template system"
                }
            },
            ["0.2.0"] = {
                title = "Previous Release: VUI 0.2.0",
                features = {
                    "Performance optimization systems",
                    "Accessibility improvements",
                    "Advanced spell system enhancements",
                    "Theme enhancements with standardized system",
                    "Unified notification system",
                    "Enhanced cooldown tracking"
                }
            }
        }
    }
end

-- Register slash commands
function Help:RegisterSlashCommands()
    VUI:RegisterSlashCommand("help", function(args)
        self:ShowHelpWindow(args)
    end)
end

-- Show the welcome help for first-time users
function Help:ShowWelcomeHelp()
    -- Create welcome frame if it doesn't exist
    if not self.welcomeFrame then
        local frame = CreateFrame("Frame", "VUIWelcomeFrame", UIParent, "BackdropTemplate")
        frame:SetSize(600, 400)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("DIALOG")
        
        -- Apply theme
        local theme = VUI.db.profile.theme or "thunderstorm"
        local colors = VUI.media.themes[theme] or {}
        
        frame:SetBackdrop({
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
            tile = false,
            tileSize = 0,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        if colors.background then
            frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
        else
            frame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
        end
        
        if colors.border then
            frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
        else
            frame:SetBackdropBorderColor(0, 0.6, 1, 1)
        end
        
        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", frame, "TOP", 0, -15)
        title:SetText("Welcome to VUI v" .. VUI.version)
        
        -- Logo
        local logo = frame:CreateTexture(nil, "ARTWORK")
        logo:SetSize(64, 64)
        logo:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -10)
        logo:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\logo.tga")
        
        -- Content
        local content = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -80)
        content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 100)
        content:SetJustifyH("LEFT")
        content:SetJustifyV("TOP")
        content:SetText("Thank you for installing VUI, a comprehensive UI enhancement suite for World of Warcraft.\n\n" ..
                       "VUI offers numerous features to improve your gameplay experience:\n" ..
                       "• Comprehensive UI theming with five unique visual styles\n" ..
                       "• Enhanced buff and debuff tracking with priority categories\n" ..
                       "• Advanced notification system for important events\n" ..
                       "• Party cooldown tracking with enhanced visibility\n" ..
                       "• Optimized performance even in demanding situations\n\n" ..
                       "Getting started is easy:\n" ..
                       "1. Type /vui to open the main configuration panel\n" ..
                       "2. Choose your preferred theme in the Appearance tab\n" ..
                       "3. Configure individual modules to your liking\n\n" ..
                       "Need help? Type /vui help for assistance at any time.")
        
        -- Close button
        local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        closeButton:SetSize(100, 25)
        closeButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
        closeButton:SetText("Get Started")
        closeButton:SetScript("OnClick", function()
            frame:Hide()
            VUI.db.profile.help.firstTimeHelp = false
            -- Open the main VUI config panel
            VUI.ModuleAPI:OpenConfigPanel()
        end)
        
        -- Don't show again checkbox
        local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        checkbox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 20)
        checkbox:SetChecked(false)
        checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
        checkbox.text:SetText("Don't show again")
        checkbox:SetScript("OnClick", function()
            VUI.db.profile.help.firstTimeHelp = not checkbox:GetChecked()
        end)
        
        self.welcomeFrame = frame
    end
    
    self.welcomeFrame:Show()
end

-- Show module-specific help
function Help:ShowModuleHelp(moduleName)
    if not VUI.db.profile.help.enabled or not VUI.db.profile.help.contextualHelp then return end
    
    local moduleHelp = self.helpContent.modules[moduleName:lower()]
    if not moduleHelp then return end
    
    -- Create small floating help indicator near the config panel
    if VUI.configFrame and VUI.configFrame:IsShown() then
        -- Check if help button already exists
        local buttonName = "VUI_ModuleHelp_" .. moduleName
        local helpButton = _G[buttonName]
        
        if not helpButton then
            helpButton = CreateFrame("Button", buttonName, VUI.configFrame, "UIPanelButtonTemplate")
            helpButton:SetSize(24, 24)
            helpButton:SetPoint("TOPRIGHT", VUI.configFrame, "TOPRIGHT", -5, -5)
            helpButton:SetText("?")
            
            -- Style the button based on current theme
            local theme = VUI.db.profile.theme or "thunderstorm"
            local colors = VUI.media.themes[theme] or {}
            
            if colors.button then
                helpButton:SetNormalFontObject("GameFontNormalSmall")
                helpButton:SetHighlightFontObject("GameFontHighlightSmall")
                
                if helpButton.SetNormalTexture then
                    local normalTexture = helpButton:CreateTexture(nil, "BACKGROUND")
                    normalTexture:SetColorTexture(colors.button.r, colors.button.g, colors.button.b, 0.7)
                    normalTexture:SetAllPoints()
                    helpButton:SetNormalTexture(normalTexture)
                end
                
                if helpButton.SetHighlightTexture then
                    local highlightTexture = helpButton:CreateTexture(nil, "HIGHLIGHT")
                    highlightTexture:SetColorTexture(colors.button.r * 1.2, colors.button.g * 1.2, colors.button.b * 1.2, 0.7)
                    highlightTexture:SetAllPoints()
                    helpButton:SetHighlightTexture(highlightTexture)
                end
            end
            
            -- Setup tooltip and click behavior
            helpButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
                GameTooltip:SetText("Click for help with " .. (moduleHelp.title or moduleName), nil, nil, nil, nil, true)
                GameTooltip:AddLine("Shows detailed information about this module", 1, 0.82, 0, true)
                GameTooltip:Show()
            end)
            
            helpButton:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            
            helpButton:SetScript("OnClick", function()
                self:ShowHelpPanel(moduleName)
            end)
        end
    end
end

-- Create and show a full help panel for a module
function Help:ShowHelpPanel(moduleName)
    if not moduleName then return end
    
    -- Get module help data
    local moduleHelp = self.helpContent.modules[moduleName:lower()]
    if not moduleHelp then return end
    
    -- Create main frame if it doesn't exist
    local frameName = "VUI_HelpPanel_" .. moduleName
    local helpFrame = _G[frameName]
    
    if helpFrame then
        helpFrame:Show()
        return helpFrame
    end
    
    -- Create new frame
    helpFrame = CreateFrame("Frame", frameName, UIParent, "BackdropTemplate")
    helpFrame:SetSize(650, 450)
    helpFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    helpFrame:SetFrameStrata("DIALOG")
    helpFrame:SetMovable(true)
    helpFrame:EnableMouse(true)
    helpFrame:RegisterForDrag("LeftButton")
    helpFrame:SetScript("OnDragStart", helpFrame.StartMoving)
    helpFrame:SetScript("OnDragStop", helpFrame.StopMovingOrSizing)
    
    -- Apply theme
    local theme = VUI.db.profile.theme or "thunderstorm"
    local colors = VUI.media.themes[theme] or {}
    
    helpFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    if colors.background then
        helpFrame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
    else
        helpFrame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
    end
    
    if colors.border then
        helpFrame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    else
        helpFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end
    
    -- Title
    local title = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 15, -15)
    title:SetText(moduleHelp.title or ("Help: " .. moduleName))
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, helpFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() helpFrame:Hide() end)
    
    -- Module description
    local description = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
    description:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    description:SetJustifyH("LEFT")
    description:SetText(moduleHelp.content or "No description available.")
    description:SetTextColor(1, 0.82, 0)
    
    -- Features section
    local featuresTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    featuresTitle:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -25)
    featuresTitle:SetText("Key Features")
    
    -- Feature list
    local featureContainer = CreateFrame("Frame", nil, helpFrame)
    featureContainer:SetPoint("TOPLEFT", featuresTitle, "BOTTOMLEFT", 10, -10)
    featureContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    featureContainer:SetHeight(100)
    
    local featureText = featureContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    featureText:SetPoint("TOPLEFT", featureContainer, "TOPLEFT", 0, 0)
    featureText:SetPoint("BOTTOMRIGHT", featureContainer, "BOTTOMRIGHT", 0, 0)
    featureText:SetJustifyH("LEFT")
    
    -- Build feature list text
    local featureList = ""
    if moduleHelp.features and #moduleHelp.features > 0 then
        for i, feature in ipairs(moduleHelp.features) do
            featureList = featureList .. "• " .. feature .. "\n"
        end
    else
        featureList = "No specific features listed."
    end
    featureText:SetText(featureList)
    
    -- Tips section
    local tipsTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tipsTitle:SetPoint("TOPLEFT", featureContainer, "BOTTOMLEFT", -10, -25)
    tipsTitle:SetText("Tips & Tricks")
    
    -- Tips list
    local tipsContainer = CreateFrame("Frame", nil, helpFrame)
    tipsContainer:SetPoint("TOPLEFT", tipsTitle, "BOTTOMLEFT", 10, -10)
    tipsContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    tipsContainer:SetHeight(100)
    
    local tipsText = tipsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tipsText:SetPoint("TOPLEFT", tipsContainer, "TOPLEFT", 0, 0)
    tipsText:SetPoint("BOTTOMRIGHT", tipsContainer, "BOTTOMRIGHT", 0, 0)
    tipsText:SetJustifyH("LEFT")
    
    -- Build tips list text
    local tipsList = ""
    if moduleHelp.tips and #moduleHelp.tips > 0 then
        for i, tip in ipairs(moduleHelp.tips) do
            tipsList = tipsList .. "• " .. tip .. "\n"
        end
    else
        tipsList = "No specific tips available."
    end
    tipsText:SetText(tipsList)
    
    -- Related modules/settings section (if available)
    if moduleHelp.related then
        local relatedTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        relatedTitle:SetPoint("TOPLEFT", tipsContainer, "BOTTOMLEFT", -10, -25)
        relatedTitle:SetText("Related Settings")
        
        local relatedContainer = CreateFrame("Frame", nil, helpFrame)
        relatedContainer:SetPoint("TOPLEFT", relatedTitle, "BOTTOMLEFT", 10, -10)
        relatedContainer:SetPoint("BOTTOMRIGHT", helpFrame, "BOTTOMRIGHT", -15, 45)
        
        local relatedText = relatedContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        relatedText:SetPoint("TOPLEFT", relatedContainer, "TOPLEFT", 0, 0)
        relatedText:SetPoint("BOTTOMRIGHT", relatedContainer, "BOTTOMRIGHT", 0, 0)
        relatedText:SetJustifyH("LEFT")
        
        -- Build related list text
        local relatedList = ""
        for i, related in ipairs(moduleHelp.related) do
            relatedList = relatedList .. "• " .. related .. "\n"
        end
        relatedText:SetText(relatedList)
    end
    
    -- OK button at bottom
    local okButton = CreateFrame("Button", nil, helpFrame, "UIPanelButtonTemplate")
    okButton:SetSize(100, 24)
    okButton:SetPoint("BOTTOM", helpFrame, "BOTTOM", 0, 15)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function() helpFrame:Hide() end)
    
    helpFrame:Show()
    return helpFrame
end

-- Show new features after version change
function Help:ShowNewFeatures(oldVersion, newVersion)
    local features = self.helpContent.newFeatures[newVersion]
    if not features then return end
    
    -- Create new features frame
    -- Similar to welcome frame but with version-specific content
    VUI:Print(features.title)
    
    for _, feature in ipairs(features.features) do
        VUI:Print("• " .. feature)
    end
    
    VUI:Print("Type /vui help for more information")
end

-- Show help window based on arguments
function Help:ShowHelpWindow(args)
    if not args or args == "" then
        -- Show general help
        self:ShowGeneralHelp()
    else
        -- Show specific help based on arguments
        local topic = args:lower()
        
        if self.helpContent.modules[topic] then
            self:ShowHelpPanel(topic)
        elseif self.helpContent.features[topic] then
            self:ShowFeatureHelpPanel(topic)
        else
            VUI:Print("Help topic not found: " .. topic)
            VUI:Print("Available topics: general, modules, themes, performance, profiles")
            VUI:Print("Type /vui help for general help")
        end
    end
end

-- Show general help
function Help:ShowGeneralHelp()
    -- Create main help panel if it doesn't exist
    local frameName = "VUI_GeneralHelpPanel"
    local helpFrame = _G[frameName]
    
    if helpFrame then
        helpFrame:Show()
        return helpFrame
    end
    
    -- Get general help data
    local general = self.helpContent.general
    
    -- Create new frame
    helpFrame = CreateFrame("Frame", frameName, UIParent, "BackdropTemplate")
    helpFrame:SetSize(650, 450)
    helpFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    helpFrame:SetFrameStrata("DIALOG")
    helpFrame:SetMovable(true)
    helpFrame:EnableMouse(true)
    helpFrame:RegisterForDrag("LeftButton")
    helpFrame:SetScript("OnDragStart", helpFrame.StartMoving)
    helpFrame:SetScript("OnDragStop", helpFrame.StopMovingOrSizing)
    
    -- Apply theme
    local theme = VUI.db.profile.theme or "thunderstorm"
    local colors = VUI.media.themes[theme] or {}
    
    helpFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    if colors.background then
        helpFrame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
    else
        helpFrame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
    end
    
    if colors.border then
        helpFrame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    else
        helpFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end
    
    -- Title
    local title = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 15, -15)
    title:SetText(general.title or "VUI Help")
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, helpFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() helpFrame:Hide() end)
    
    -- Description
    local description = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
    description:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    description:SetJustifyH("LEFT")
    description:SetText(general.content or "No description available.")
    description:SetTextColor(1, 0.82, 0)
    
    -- Commands section
    local commandsTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    commandsTitle:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -25)
    commandsTitle:SetText("Commands")
    
    -- Commands list
    local commandContainer = CreateFrame("Frame", nil, helpFrame)
    commandContainer:SetPoint("TOPLEFT", commandsTitle, "BOTTOMLEFT", 10, -10)
    commandContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    commandContainer:SetHeight(80)
    
    local commandText = commandContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    commandText:SetPoint("TOPLEFT", commandContainer, "TOPLEFT", 0, 0)
    commandText:SetPoint("BOTTOMRIGHT", commandContainer, "BOTTOMRIGHT", 0, 0)
    commandText:SetJustifyH("LEFT")
    
    -- Build command list text
    local commandList = ""
    if general.commands and #general.commands > 0 then
        for i, cmd in ipairs(general.commands) do
            commandList = commandList .. "• " .. cmd.command .. " - " .. cmd.description .. "\n"
        end
    else
        commandList = "No commands available."
    end
    commandText:SetText(commandList)
    
    -- Tips section
    local tipsTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tipsTitle:SetPoint("TOPLEFT", commandContainer, "BOTTOMLEFT", -10, -25)
    tipsTitle:SetText("Tips & Tricks")
    
    -- Tips list
    local tipsContainer = CreateFrame("Frame", nil, helpFrame)
    tipsContainer:SetPoint("TOPLEFT", tipsTitle, "BOTTOMLEFT", 10, -10)
    tipsContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    tipsContainer:SetHeight(80)
    
    local tipsText = tipsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tipsText:SetPoint("TOPLEFT", tipsContainer, "TOPLEFT", 0, 0)
    tipsText:SetPoint("BOTTOMRIGHT", tipsContainer, "BOTTOMRIGHT", 0, 0)
    tipsText:SetJustifyH("LEFT")
    
    -- Build tips list text
    local tipsList = ""
    if general.tips and #general.tips > 0 then
        for i, tip in ipairs(general.tips) do
            tipsList = tipsList .. "• " .. tip .. "\n"
        end
    else
        tipsList = "No tips available."
    end
    tipsText:SetText(tipsList)
    
    -- Modules section
    local modulesTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    modulesTitle:SetPoint("TOPLEFT", tipsContainer, "BOTTOMLEFT", -10, -25)
    modulesTitle:SetText("Available Modules")
    
    -- Create a scrolling container for module buttons
    local modulesContainer = CreateFrame("ScrollFrame", nil, helpFrame, "UIPanelScrollFrameTemplate")
    modulesContainer:SetPoint("TOPLEFT", modulesTitle, "BOTTOMLEFT", 10, -10)
    modulesContainer:SetPoint("BOTTOMRIGHT", helpFrame, "BOTTOMRIGHT", -30, 45)
    
    local modulesContent = CreateFrame("Frame", nil, modulesContainer)
    modulesContent:SetSize(565, 200) -- This height may need to be adjusted based on content
    modulesContainer:SetScrollChild(modulesContent)
    
    -- Create buttons for each module
    local moduleX, moduleY = 0, 0
    local moduleButtonWidth, moduleButtonHeight = 180, 30
    local moduleButtonsPerRow = 3
    
    for moduleName, moduleData in pairs(self.helpContent.modules) do
        local moduleButton = CreateFrame("Button", nil, modulesContent, "UIPanelButtonTemplate")
        moduleButton:SetSize(moduleButtonWidth, moduleButtonHeight)
        moduleButton:SetPoint("TOPLEFT", modulesContent, "TOPLEFT", moduleX, -moduleY)
        moduleButton:SetText(moduleData.title or moduleName)
        
        moduleButton:SetScript("OnClick", function()
            helpFrame:Hide()
            self:ShowHelpPanel(moduleName)
        end)
        
        -- Calculate next position
        moduleX = moduleX + moduleButtonWidth + 10
        if moduleX > (moduleButtonWidth + 10) * (moduleButtonsPerRow - 1) then
            moduleX = 0
            moduleY = moduleY + moduleButtonHeight + 10
        end
    end
    
    -- Feature buttons section
    local featuresTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    featuresTitle:SetPoint("TOPLEFT", modulesContent, "BOTTOMLEFT", -10, -25)
    featuresTitle:SetText("Common Features")
    
    -- Features buttons
    local featureX, featureY = 0, 0
    local featureButtonWidth, featureButtonHeight = 180, 30
    local featureButtonsPerRow = 3
    
    for featureName, featureData in pairs(self.helpContent.features) do
        local featureButton = CreateFrame("Button", nil, modulesContent, "UIPanelButtonTemplate")
        featureButton:SetSize(featureButtonWidth, featureButtonHeight)
        featureButton:SetPoint("TOPLEFT", featuresTitle, "BOTTOMLEFT", featureX, -featureY - 10)
        featureButton:SetText(featureData.title and featureData.title:gsub("Help$", "") or featureName)
        
        featureButton:SetScript("OnClick", function()
            helpFrame:Hide()
            self:ShowFeatureHelpPanel(featureName)
        end)
        
        -- Calculate next position
        featureX = featureX + featureButtonWidth + 10
        if featureX > (featureButtonWidth + 10) * (featureButtonsPerRow - 1) then
            featureX = 0
            featureY = featureY + featureButtonHeight + 10
        end
    end
    
    -- OK button at bottom
    local okButton = CreateFrame("Button", nil, helpFrame, "UIPanelButtonTemplate")
    okButton:SetSize(100, 24)
    okButton:SetPoint("BOTTOM", helpFrame, "BOTTOM", 0, 15)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function() helpFrame:Hide() end)
    
    helpFrame:Show()
    return helpFrame
end

-- Create and show a feature help panel
function Help:ShowFeatureHelpPanel(featureName)
    if not featureName then return end
    
    -- Get feature help data
    local featureHelp = self.helpContent.features[featureName:lower()]
    if not featureHelp then return end
    
    -- Create main frame if it doesn't exist
    local frameName = "VUI_FeatureHelpPanel_" .. featureName
    local helpFrame = _G[frameName]
    
    if helpFrame then
        helpFrame:Show()
        return helpFrame
    end
    
    -- Create new frame (similar to module help panel but with feature-specific content)
    helpFrame = CreateFrame("Frame", frameName, UIParent, "BackdropTemplate")
    helpFrame:SetSize(650, 450)
    helpFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    helpFrame:SetFrameStrata("DIALOG")
    helpFrame:SetMovable(true)
    helpFrame:EnableMouse(true)
    helpFrame:RegisterForDrag("LeftButton")
    helpFrame:SetScript("OnDragStart", helpFrame.StartMoving)
    helpFrame:SetScript("OnDragStop", helpFrame.StopMovingOrSizing)
    
    -- Apply theme (same as other help panels)
    local theme = VUI.db.profile.theme or "thunderstorm"
    local colors = VUI.media.themes[theme] or {}
    
    helpFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    if colors.background then
        helpFrame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
    else
        helpFrame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
    end
    
    if colors.border then
        helpFrame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    else
        helpFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end
    
    -- Title
    local title = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 15, -15)
    title:SetText(featureHelp.title or ("Feature: " .. featureName))
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, helpFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() helpFrame:Hide() end)
    
    -- Feature description
    local description = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
    description:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    description:SetJustifyH("LEFT")
    description:SetText(featureHelp.content or "No description available.")
    description:SetTextColor(1, 0.82, 0)
    
    -- Feature-specific content sections
    local contentY = 25
    
    -- Different sections based on feature type
    if featureName == "themes" and featureHelp.themes then
        -- Themes section
        local themesTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        themesTitle:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -contentY)
        themesTitle:SetText("Available Themes")
        
        local themesContainer = CreateFrame("Frame", nil, helpFrame)
        themesContainer:SetPoint("TOPLEFT", themesTitle, "BOTTOMLEFT", 10, -10)
        themesContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
        themesContainer:SetHeight(150)
        
        local themesText = themesContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        themesText:SetPoint("TOPLEFT", themesContainer, "TOPLEFT", 0, 0)
        themesText:SetPoint("BOTTOMRIGHT", themesContainer, "BOTTOMRIGHT", 0, 0)
        themesText:SetJustifyH("LEFT")
        
        -- Build themes list
        local themesList = ""
        for i, theme in ipairs(featureHelp.themes) do
            themesList = themesList .. "• " .. theme.name .. " - " .. theme.description .. "\n"
        end
        themesText:SetText(themesList)
        
        contentY = contentY + 170
    elseif featureHelp.features then
        -- Features list section for other feature types
        local featuresTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        featuresTitle:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -contentY)
        featuresTitle:SetText("Key Capabilities")
        
        local featuresContainer = CreateFrame("Frame", nil, helpFrame)
        featuresContainer:SetPoint("TOPLEFT", featuresTitle, "BOTTOMLEFT", 10, -10)
        featuresContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
        featuresContainer:SetHeight(150)
        
        local featuresText = featuresContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        featuresText:SetPoint("TOPLEFT", featuresContainer, "TOPLEFT", 0, 0)
        featuresText:SetPoint("BOTTOMRIGHT", featuresContainer, "BOTTOMRIGHT", 0, 0)
        featuresText:SetJustifyH("LEFT")
        
        -- Build features list
        local featuresList = ""
        for i, feat in ipairs(featureHelp.features) do
            featuresList = featuresList .. "• " .. feat .. "\n"
        end
        featuresText:SetText(featuresList)
        
        contentY = contentY + 170
    end
    
    -- Tips section
    local tipsTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tipsTitle:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -contentY)
    tipsTitle:SetText("Tips & Tricks")
    
    local tipsContainer = CreateFrame("Frame", nil, helpFrame)
    tipsContainer:SetPoint("TOPLEFT", tipsTitle, "BOTTOMLEFT", 10, -10)
    tipsContainer:SetPoint("TOPRIGHT", helpFrame, "TOPRIGHT", -15, 0)
    tipsContainer:SetHeight(80)
    
    local tipsText = tipsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tipsText:SetPoint("TOPLEFT", tipsContainer, "TOPLEFT", 0, 0)
    tipsText:SetPoint("BOTTOMRIGHT", tipsContainer, "BOTTOMRIGHT", 0, 0)
    tipsText:SetJustifyH("LEFT")
    
    -- Build tips list
    local tipsList = ""
    if featureHelp.tips and #featureHelp.tips > 0 then
        for i, tip in ipairs(featureHelp.tips) do
            tipsList = tipsList .. "• " .. tip .. "\n"
        end
    else
        tipsList = "No specific tips available."
    end
    tipsText:SetText(tipsList)
    
    -- OK button at bottom
    local okButton = CreateFrame("Button", nil, helpFrame, "UIPanelButtonTemplate")
    okButton:SetSize(100, 24)
    okButton:SetPoint("BOTTOM", helpFrame, "BOTTOM", 0, 15)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function() helpFrame:Hide() end)
    
    helpFrame:Show()
    return helpFrame
end

-- Show feature-specific help
function Help:ShowFeatureHelp(feature)
    local featureHelp = self.helpContent.features[feature]
    if not featureHelp then return end
    
    VUI:Print(featureHelp.title)
    VUI:Print(featureHelp.content)
    
    -- Show feature-specific content based on what's available
    if feature == "themes" and featureHelp.themes then
        VUI:Print("Available Themes:")
        for _, theme in ipairs(featureHelp.themes) do
            VUI:Print("  • " .. theme.name .. " - " .. theme.description)
        end
    elseif featureHelp.features then
        VUI:Print("Features:")
        for _, featText in ipairs(featureHelp.features) do
            VUI:Print("  • " .. featText)
        end
    end
    
    VUI:Print("Tips:")
    for i = 1, math.min(2, #featureHelp.tips) do
        VUI:Print("  • " .. featureHelp.tips[i])
    end
end

-- Add a help button to a frame
function Help:AddHelpButton(frame, helpTopic)
    if not frame or not helpTopic then return end
    
    local helpButton = CreateFrame("Button", nil, frame)
    helpButton:SetSize(16, 16)
    helpButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    local icon = helpButton:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\help-icon.tga")
    
    helpButton:SetScript("OnClick", function()
        if self.helpContent.modules[helpTopic] then
            self:ShowModuleHelp(helpTopic)
        elseif self.helpContent.features[helpTopic] then
            self:ShowFeatureHelp(helpTopic)
        else
            self:ShowGeneralHelp()
        end
    end)
    
    helpButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click for help", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    
    helpButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return helpButton
end

-- Enable module
function Help:Enable()
    self.enabled = true
    
    -- Register events
    self:RegisterEvents()
    
    VUI:Print("Help system enabled")
end

-- Disable module
function Help:Disable()
    self.enabled = false
    
    -- Unregister events
    VUI:UnregisterCallback("ConfigPanelOpened")
    VUI:UnregisterCallback("FirstTimeSetup")
    VUI:UnregisterCallback("VersionChanged")
    
    VUI:Print("Help system disabled")
end

-- Register with VUI initialization
VUI:RegisterCallback("OnInitialized", function()
    Help:Initialize()
end)

-- Module API for other modules to register help content
function Help:RegisterModuleHelp(moduleName, helpData)
    if not moduleName or not helpData then return end
    
    self.helpContent.modules[moduleName:lower()] = helpData
end

-- Enhanced Tooltip System --

-- Show tooltip for a UI element
function Help:ShowTooltip(frame, tooltipType, tooltipData)
    if not frame or not tooltipType or not tooltipData then return end
    if not VUI.db.profile.help.showTooltips then return end
    
    -- Basic validation
    if type(frame) ~= "table" or not frame.SetScript then return end
    
    -- Remove any existing tooltip handlers
    frame:SetScript("OnEnter", nil)
    frame:SetScript("OnLeave", nil)
    
    -- Add tooltip functionality
    frame:SetScript("OnEnter", function(self)
        Help:DisplayTooltip(self, tooltipType, tooltipData)
    end)
    
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    return true
end

-- Display tooltip with the appropriate format based on type
function Help:DisplayTooltip(frame, tooltipType, tooltipData)
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    
    -- Handle different tooltip types
    if tooltipType == "option" then
        self:FormatOptionTooltip(tooltipData)
    elseif tooltipType == "feature" then
        self:FormatFeatureTooltip(tooltipData)
    elseif tooltipType == "module" then
        self:FormatModuleTooltip(tooltipData)
    elseif tooltipType == "command" then
        self:FormatCommandTooltip(tooltipData)
    elseif tooltipType == "simple" then
        self:FormatSimpleTooltip(tooltipData)
    end
    
    GameTooltip:Show()
end

-- Format tooltip for configuration options
function Help:FormatOptionTooltip(data)
    -- Title
    GameTooltip:SetText(data.name or "Option", 1, 1, 1, 1, true)
    
    -- Description
    if data.desc then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(data.desc, 1, 0.82, 0, true)
    end
    
    -- Additional help text for enhanced tooltips
    if VUI.db.profile.help.enhancedTooltips and data.help then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(data.help, 0.7, 0.7, 0.7, true)
    end
    
    -- Example or usage
    if VUI.db.profile.help.enhancedTooltips and data.example then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Example: " .. data.example, 0.6, 0.9, 0.6, true)
    end
    
    -- Related options
    if VUI.db.profile.help.enhancedTooltips and data.related and #data.related > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Related Options:", 0.9, 0.9, 0.4)
        for _, related in ipairs(data.related) do
            GameTooltip:AddLine("- " .. related, 0.7, 0.7, 0.7, true)
        end
    end
end

-- Format tooltip for features
function Help:FormatFeatureTooltip(data)
    -- Title
    GameTooltip:SetText(data.title or "Feature", 1, 1, 1, 1, true)
    
    -- Description
    if data.description then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(data.description, 1, 0.82, 0, true)
    end
    
    -- Key capabilities
    if data.capabilities and #data.capabilities > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Key Capabilities:", 0.9, 0.9, 0.4)
        for _, capability in ipairs(data.capabilities) do
            GameTooltip:AddLine("- " .. capability, 0.7, 0.7, 0.7, true)
        end
    end
    
    -- Tips
    if VUI.db.profile.help.enhancedTooltips and data.tips and #data.tips > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Tips:", 0.4, 0.9, 0.4)
        for _, tip in ipairs(data.tips) do
            GameTooltip:AddLine("- " .. tip, 0.7, 0.7, 0.7, true)
        end
    end
end

-- Format tooltip for modules
function Help:FormatModuleTooltip(data)
    -- Title
    GameTooltip:SetText(data.title or data.name or "Module", 1, 1, 1, 1, true)
    
    -- Description
    if data.content or data.description then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(data.content or data.description, 1, 0.82, 0, true)
    end
    
    -- Key features
    if data.features and #data.features > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Key Features:", 0.9, 0.9, 0.4)
        
        -- Limit the number of features based on help level
        local helpLevel = VUI.db.profile.help.helpLevel or 2
        local maxFeatures = helpLevel == 1 and 2 or (helpLevel == 2 and 4 or 6)
        
        for i, feature in ipairs(data.features) do
            if i <= maxFeatures then
                GameTooltip:AddLine("- " .. feature, 0.7, 0.7, 0.7, true)
            elseif i == maxFeatures + 1 then
                GameTooltip:AddLine("- And more...", 0.5, 0.5, 0.5, true)
                break
            end
        end
    end
    
    -- Dependencies
    if VUI.db.profile.help.enhancedTooltips and data.dependencies and #data.dependencies > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Dependencies:", 0.9, 0.6, 0.6)
        for _, dependency in ipairs(data.dependencies) do
            GameTooltip:AddLine("- " .. dependency, 0.7, 0.7, 0.7, true)
        end
    end
    
    -- Tips (only for enhanced tooltips)
    if VUI.db.profile.help.enhancedTooltips and data.tips and #data.tips > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Tips:", 0.4, 0.9, 0.4)
        for i, tip in ipairs(data.tips) do
            if i <= 2 then  -- Show at most 2 tips
                GameTooltip:AddLine("- " .. tip, 0.7, 0.7, 0.7, true)
            end
        end
    end
end

-- Format tooltip for commands
function Help:FormatCommandTooltip(data)
    -- Command name
    GameTooltip:SetText(data.command or "/command", 1, 1, 1, 1, true)
    
    -- Description
    if data.description then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(data.description, 1, 0.82, 0, true)
    end
    
    -- Usage
    if data.usage then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Usage: " .. data.usage, 0.7, 0.7, 1, true)
    end
    
    -- Examples
    if VUI.db.profile.help.enhancedTooltips and data.examples and #data.examples > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Examples:", 0.9, 0.9, 0.4)
        for _, example in ipairs(data.examples) do
            GameTooltip:AddLine("- " .. example, 0.7, 0.7, 0.7, true)
        end
    end
    
    -- Aliases
    if VUI.db.profile.help.showAliases and data.aliases and #data.aliases > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Aliases:", 0.6, 0.6, 0.9)
        for _, alias in ipairs(data.aliases) do
            GameTooltip:AddLine("- " .. alias, 0.7, 0.7, 0.7, true)
        end
    end
end

-- Format a simple tooltip
function Help:FormatSimpleTooltip(data)
    -- If data is just a string, use it as the title
    if type(data) == "string" then
        GameTooltip:SetText(data, 1, 1, 1, 1, true)
        return
    end
    
    -- Title
    GameTooltip:SetText(data.title or data.name or "Help", 1, 1, 1, 1, true)
    
    -- Description
    if data.text or data.description then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(data.text or data.description, 1, 0.82, 0, true)
    end
    
    -- Any additional lines
    if data.lines and #data.lines > 0 then
        for _, line in ipairs(data.lines) do
            if type(line) == "table" then
                GameTooltip:AddLine(line.text, line.r or 1, line.g or 1, line.b or 1, true)
            else
                GameTooltip:AddLine(line, 0.7, 0.7, 0.7, true)
            end
        end
    end
end

-- Apply tooltips to all options in a configuration panel
function Help:ApplyTooltipsToOptions(optionsTable)
    if not optionsTable or not optionsTable.args then return end
    if not VUI.db.profile.help.showTooltips then return end
    
    -- Process each option
    for optionName, optionData in pairs(optionsTable.args) do
        -- Only process actual options
        if type(optionData) == "table" then
            -- Add help data to the option
            if not optionData.tooltipData then
                optionData.tooltipData = {
                    name = optionData.name,
                    desc = optionData.desc,
                    help = optionData.help,
                    example = optionData.example,
                    related = optionData.related
                }
            end
            
            -- Process sub-options if any
            if optionData.args then
                self:ApplyTooltipsToOptions(optionData)
            end
        end
    end
    
    return true
end

-- Register tooltips for standard UI frames
function Help:RegisterStandardTooltips()
    if not VUI.db.profile.help.showTooltips then return end
    
    -- Apply tooltips to all VUI-specific frames that need them
    self:RegisterVUIFrameTooltips()
    
    -- Apply tooltips to Blizzard frames if enhanced tooltips are enabled
    if VUI.db.profile.help.enhancedTooltips then
        self:RegisterBlizzardFrameTooltips()
    end
    
    return true
end

-- Register tooltips for VUI-specific frames
function Help:RegisterVUIFrameTooltips()
    -- Main VUI frames
    if VUI.frames then
        for name, frame in pairs(VUI.frames) do
            if frame.tooltipData then
                self:ShowTooltip(frame, frame.tooltipType or "simple", frame.tooltipData)
            end
        end
    end
    
    -- Module frames
    for moduleName, module in pairs(VUI.modules or {}) do
        if type(module) == "table" and module.frames then
            for frameName, frame in pairs(module.frames) do
                if frame.tooltipData then
                    self:ShowTooltip(frame, frame.tooltipType or "module", frame.tooltipData)
                end
            end
        end
    end
    
    -- Config buttons
    if VUI.configFrame and VUI.configFrame.sections then
        for sectionName, section in pairs(VUI.configFrame.sections) do
            if section.tooltipElements then
                for _, element in ipairs(section.tooltipElements) do
                    if element.frame and element.tooltipData then
                        self:ShowTooltip(element.frame, element.tooltipType or "option", element.tooltipData)
                    end
                end
            end
        end
    end
    
    return true
end

-- Register enhanced tooltips for Blizzard frames
function Help:RegisterBlizzardFrameTooltips()
    -- Only if we want enhanced tooltips for Blizzard frames
    if not VUI.db.profile.help.enhancedTooltips then return end
    
    -- Player frame tooltip
    if PlayerFrame then
        self:ShowTooltip(PlayerFrame, "simple", {
            title = "Player Frame",
            text = "Shows your character's health, power, and status.",
            lines = {
                { text = "Right-click for unit menu options", r = 0.7, g = 0.7, b = 1 },
                { text = "You can move this frame with VUI's MoveAny module", r = 0.7, g = 1, b = 0.7 }
            }
        })
    end
    
    -- Target frame tooltip
    if TargetFrame then
        self:ShowTooltip(TargetFrame, "simple", {
            title = "Target Frame",
            text = "Shows your current target's health, power, and status.",
            lines = {
                { text = "Right-click for unit menu options", r = 0.7, g = 0.7, b = 1 },
                { text = "You can move this frame with VUI's MoveAny module", r = 0.7, g = 1, b = 0.7 }
            }
        })
    end
    
    -- More can be added as needed...
    
    return true
end

-- Create help tooltips for a module's options panel
function Help:CreateModuleOptionTooltips(moduleName, options)
    if not moduleName or not options then return end
    if not VUI.db.profile.help.showTooltips then return end
    
    -- Get the module help data
    local moduleHelp = self.helpContent.modules[moduleName]
    if not moduleHelp then return end
    
    -- Apply help data to options
    self:ApplyTooltipsToOptions(options)
    
    return true
end

-- Return the module table so it can be used in other files
VUI.modules.help = Help