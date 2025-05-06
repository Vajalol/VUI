--[[
    VUI - Help System
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

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
    
    -- Create module help tooltip or small frame
    -- Implementation would depend on your preferred UI approach
    VUI:Print(moduleHelp.title)
    VUI:Print(moduleHelp.content)
    
    -- Show a few tips based on help level
    local helpLevel = VUI.db.profile.help.helpLevel or 2
    local tipsToShow = math.min(helpLevel, #moduleHelp.tips)
    
    for i = 1, tipsToShow do
        VUI:Print("Tip: " .. moduleHelp.tips[i])
    end
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
            self:ShowModuleHelp(topic)
        elseif self.helpContent.features[topic] then
            self:ShowFeatureHelp(topic)
        else
            VUI:Print("Help topic not found: " .. topic)
            VUI:Print("Available topics: general, modules, themes, performance, profiles")
        end
    end
end

-- Show general help
function Help:ShowGeneralHelp()
    local general = self.helpContent.general
    
    VUI:Print(general.title)
    VUI:Print(general.content)
    
    VUI:Print("Commands:")
    for _, cmd in ipairs(general.commands) do
        VUI:Print("  " .. cmd.command .. " - " .. cmd.description)
    end
    
    VUI:Print("Tips:")
    for i = 1, math.min(3, #general.tips) do
        VUI:Print("  • " .. general.tips[i])
    end
    
    VUI:Print("For module-specific help, type /vui help [module]")
    VUI:Print("Available modules: buffoverlay, trufigcd, multinotification, omnicd, detailsskin")
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

-- Return the module table so it can be used in other files
VUI.modules.help = Help