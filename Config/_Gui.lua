local Gui = VUI:NewModule("Config.Gui")

-- Core Layout Modules - use VUI's SafeGetModule
local General = VUI:SafeGetModule("Config.Layout.General")
local Unitframes = VUI:SafeGetModule("Config.Layout.Unitframes")
local Nameplates = VUI:SafeGetModule("Config.Layout.Nameplates")
local Actionbar = VUI:SafeGetModule("Config.Layout.Actionbar")
local Castbars = VUI:SafeGetModule("Config.Layout.Castbars")
local Map = VUI:SafeGetModule("Config.Layout.Map")
local Misc = VUI:SafeGetModule("Config.Layout.Misc")
local FAQ = VUI:SafeGetModule("Config.Layout.FAQ")
local Tooltip = VUI:SafeGetModule("Config.Layout.Tooltip")
local Chat = VUI:SafeGetModule("Config.Layout.Chat")
local Buffs = VUI:SafeGetModule("Config.Layout.Buffs")
local Profiles = VUI:SafeGetModule("Config.Layout.Profiles")

-- VModules - retrieve safely
local VUIBuffs = VUI:SafeGetModule("Config.Layout.VUIBuffs")
local VUIAnyFrame = VUI:SafeGetModule("Config.Layout.VUIAnyFrame")
local VUIKeystones = VUI:SafeGetModule("Config.Layout.VUIKeystones")
local VUICC = VUI:SafeGetModule("Config.Layout.VUICC")
local VUICD = VUI:SafeGetModule("Config.Layout.VUICD")
local VUIIDs = VUI:SafeGetModule("Config.Layout.VUIIDs")
local VUIGfinder = VUI:SafeGetModule("Config.Layout.VUIGfinder")
local VUITGCD = VUI:SafeGetModule("Config.Layout.VUITGCD")
local VUIAuctionator = VUI:SafeGetModule("Config.Layout.VUIAuctionator")
local VUINotifications = VUI:SafeGetModule("Config.Layout.VUINotifications")
local VUIScrollingText = VUI:SafeGetModule("Config.Layout.VUIScrollingText")
local VUIepf = VUI:SafeGetModule("Config.Layout.VUIepf")
local VUIConsumables = VUI:SafeGetModule("Config.Layout.VUIConsumables")
local VUIPositionOfPower = VUI:SafeGetModule("Config.Layout.VUIPositionOfPower")
local VUIMissingRaidBuffs = VUI:SafeGetModule("Config.Layout.VUIMissingRaidBuffs")
local VUIMouseFireTrail = VUI:SafeGetModule("Config.Layout.VUIMouseFireTrail")
local VUIHealerMana = VUI:SafeGetModule("Config.Layout.VUIHealerMana")
local VUISkin = VUI:SafeGetModule("Config.Layout.VUISkin")
-- Note: VUIPlater integrated with Nameplates section

function Gui:OnEnable()
    -- Check if configuration is already initialized to prevent double initialization
    if self.configInitialized then
        return
    end
    
    -- Ensure all layout modules are loaded before proceeding
    self:EnsureLayoutModulesLoaded()
    
    -- Ensure General layout is always available
    local GeneralModule = VUI:GetModule("Config.Layout.General", true)
    if GeneralModule and not GeneralModule.layout then
        VUI:Print("Forcing General layout creation")
        if GeneralModule.OnEnable then
            GeneralModule:OnEnable()
        end
    end
    
    local VUIConfig = LibStub('VUIConfig')
    VUIConfig.config = {
        font = {
            family    = "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf",
            size      = 12,
            titleSize = 16,
            effect    = 'NONE',
            strata    = 'OVERLAY',
            color     = {
                normal   = { r = 1, g = 1, b = 1, a = 1 },
                disabled = { r = 1, g = 1, b = 1, a = 1 },
                header   = { r = 1, g = 0.9, b = 0, a = 1 },
            }
        },
        backdrop = {
            texture        = [[Interface\Buttons\WHITE8X8]],
            highlight      = { r = 0.40, g = 0.40, b = 0, a = 0.5 },
            panel          = { r = 0.065, g = 0.065, b = 0.065, a = 0.95 },
            slider         = { r = 0.15, g = 0.15, b = 0.15, a = 1 },
            checkbox       = { r = 0.125, g = 0.125, b = 0.125, a = 1 },
            dropdown       = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
            button         = { r = 0.055, g = 0.055, b = 0.055, a = 1 },
            buttonDisabled = { r = 0, g = 0.55, b = 1, a = 0.5 },
            border         = { r = 0.01, g = 0.01, b = 0.01, a = 1 },
            borderDisabled = { r = 0, g = 0.50, b = 1, a = 1 },
        },
        progressBar = {
            color = { r = 1, g = 0.9, b = 0, a = 0.5 },
        },
        highlight = {
            color = { r = 0, g = 0.55, b = 1, a = 0.5 },
            blank = { r = 0, g = 0, b = 0 }
        },
        dialog = {
            width  = 400,
            height = 100,
            button = {
                width  = 100,
                height = 20,
                margin = 5
            }
        },
        tooltip = {
            padding = 10
        }
    }

    -- Database
    local db = VUI.db

    -- Config
    local config = VUIConfig:Window(UIParent, 800, 600)  -- Increased size to accommodate more modules
    config:SetPoint('CENTER')
    config.titlePanel:SetPoint('LEFT', 10, 0)
    config.titlePanel:SetPoint('RIGHT', -35, 0)
    config:Hide()
    
    -- Store reference for refresh functions to access
    _G.VUIConfigRef = config

    -- Create enhanced version display with color animation
    local versionText = "Vortex UI Version " .. C_AddOns.GetAddOnMetadata("VUI", "version")
    local version = VUIConfig:Label(config.titlePanel, versionText)
    version:SetFont(VUIConfig.config.font.family, VUIConfig.config.font.titleSize, "")
    VUIConfig:GlueLeft(version, config.titlePanel, 145, 0)

    -- Create a safer color transition effect using alpha animations and color changes
    local animGroup = version:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Use a more compatible animation approach
    local fadeOut = animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.7)
    fadeOut:SetDuration(1.5)
    fadeOut:SetOrder(1)
    fadeOut:SetScript("OnPlay", function() 
        version:SetTextColor(0.8, 0, 1) -- Purple
    end)
    
    local fadeIn = animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.7)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(1.5)
    fadeIn:SetOrder(2)
    fadeIn:SetScript("OnPlay", function() 
        version:SetTextColor(0, 0.6, 1) -- Light Blue
    end)
    
    -- Start the animation
    animGroup:Play()

    local logo = VUIConfig:Texture(config.titlePanel, 40, 40, "Interface\\AddOns\\VUI\\Media\\Textures\\Config\\Logo")
    VUIConfig:GlueAbove(logo, config, 0, -35)

    function VUI:Config(toggle)
        if (toggle) then
            return function()
                if (config:IsVisible()) then
                    local fadeInfo = {}
                    fadeInfo.mode = "OUT"
                    fadeInfo.timeToFade = 0.2
                    fadeInfo.finishedFunc = function()
                        config:Hide()
                    end
                    UIFrameFade(config, fadeInfo)
                    ToggleGameMenu()
                else
                    local fadeInfo = {}
                    fadeInfo.mode = "IN"
                    fadeInfo.timeToFade = 0.2
                    fadeInfo.finishedFunc = function()
                        config:Show()
                    end
                    UIFrameFade(config, fadeInfo)
                    ToggleGameMenu()
                end
            end
        else
            if (config:IsVisible()) then
                local fadeInfo = {}
                fadeInfo.mode = "OUT"
                fadeInfo.timeToFade = 0.2
                fadeInfo.finishedFunc = function()
                    config:Hide()
                end
                UIFrameFade(config, fadeInfo)
            else
                local fadeInfo = {}
                fadeInfo.mode = "IN"
                fadeInfo.timeToFade = 0.2
                fadeInfo.finishedFunc = function()
                    config:Show()
                end
                UIFrameFade(config, fadeInfo)
            end
        end
    end

    -- GameMenu
    if db.profile.misc.menubutton then
        local function VUIGameMenuButton(self)
            -- Add debug to see if this function gets called
            VUI:Debug("CONFIG", "VUIGameMenuButton called")
            
            -- Skip if in combat lockdown
            if InCombatLockdown() then
                return
            end
            
            -- Always add a section and button
            self:AddSection()
            self:AddButton("|cffea00ffV|r|cff00a2ffUI|r", VUI:Config(true))
        end

        -- Hook directly to the function
        hooksecurefunc(GameMenuFrame, "InitButtons", VUIGameMenuButton)
        
        -- Force refresh when menu is shown
        GameMenuFrame:HookScript("OnShow", function()
            if GameMenuFrame.numButtons then
                VUIGameMenuButton(GameMenuFrame)
            end
        end)
    end

    -- Minimap AddOns Option
    _G.VUI_Options = function()
        VUI:Config()
     end

    -- Options - safely access module layouts
    local options = {}
    
    -- Helper function to ensure module layouts are loaded
    local function ensureModuleLayout(moduleName)
        local module = VUI:GetModule(moduleName, true)
        
        -- Special case for Map module since it's shown in screenshot as not working
        if moduleName == "Config.Layout.Map" then
            -- Create a guaranteed map layout
            return {
                layoutConfig = { padding = { top = 15 } },
                database = VUI.db.profile.maps or VUI.db.profile.map or {},
                rows = {
                    -- SECTION 1: Main Map Settings
                    {
                        header = {
                            type = 'header',
                            label = 'World Map Settings'
                        }
                    },
                    {
                        opacity = {
                            key = 'opacity',
                            type = 'slider',
                            label = 'Map Opacity',
                            tooltip = 'Adjust the opacity of the world map',
                            min = 0,
                            max = 1,
                            step = 0.05, 
                            column = 6,
                            order = 1
                        },
                        scale = {
                            key = 'scale',
                            type = 'slider',
                            label = 'Map Scale',
                            tooltip = 'Adjust the scale of the world map',
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            column = 6,
                            order = 2
                        }
                    },
                    
                    -- SECTION 2: Minimap Settings
                    {
                        header = {
                            type = 'header',
                            label = 'Minimap Settings'
                        }
                    },
                    {
                        enableMinimap = {
                            key = 'minimap.enabled',
                            type = 'checkbox',
                            label = 'Enable VUI Minimap',
                            tooltip = 'Use the enhanced VUI minimap',
                            column = 4,
                            order = 1
                        },
                        clock = {
                            key = 'minimap.clock',
                            type = 'checkbox',
                            label = 'Show Clock',
                            tooltip = 'Display time on minimap',
                            column = 4,
                            order = 2
                        },
                        coords = {
                            key = 'minimap.coords',
                            type = 'checkbox',
                            label = 'Show Coordinates',
                            tooltip = 'Display coordinates',
                            column = 4,
                            order = 3
                        }
                    }
                }
            }
        end
        
        if module then
            -- Enable if not enabled
            if not module:IsEnabled() then
                module:Enable()
            end
            
            -- Call OnEnable if layout is missing
            if not module.layout and module.OnEnable then
                module:OnEnable()
            end
            
            -- Return layout if available
            if module.layout then
                return module.layout
            end
            
            -- If we get here, the module exists but has no layout
            -- Create a basic layout for it
            module.layout = {
                layoutConfig = { padding = { top = 15 } },
                database = VUI.db.profile,
                rows = {
                    {
                        header = {
                            type = 'header',
                            label = moduleName:gsub("Config%.Layout%.", "") .. " Settings"
                        }
                    },
                    {
                        status = {
                            type = 'label',
                            label = "This module's settings are currently unavailable.",
                            column = 12
                        }
                    },
                    {
                        reload = {
                            type = 'button',
                            text = 'Reload UI',
                            column = 12,
                            onClick = function()
                                ReloadUI()
                            end
                        }
                    }
                }
            }
            
            return module.layout
        end
        
        -- Module doesn't exist, create a fallback layout
        return {
            layoutConfig = { padding = { top = 15 } },
            database = VUI.db.profile,
            rows = {
                {
                    header = {
                        type = 'header',
                        label = moduleName:gsub("Config%.Layout%.", "") .. " Settings"
                    }
                },
                {
                    status = {
                        type = 'label',
                        label = "This module is not loaded.",
                        column = 12
                    }
                },
                {
                    reload = {
                        type = 'button',
                        text = 'Reload UI',
                        column = 12,
                        onClick = function()
                            ReloadUI()
                        end
                    }
                }
            }
        }
    end
    
    -- Force load all module layouts, ensuring Core modules load before VUI modules
    
    -- Load Core modules first (always needed)
    options.General = ensureModuleLayout("Config.Layout.General")
    options.Unitframes = ensureModuleLayout("Config.Layout.Unitframes")
    options.Nameplates = ensureModuleLayout("Config.Layout.Nameplates")
    options.Actionbar = ensureModuleLayout("Config.Layout.Actionbar")
    options.Castbars = ensureModuleLayout("Config.Layout.Castbars")
    options.Tooltip = ensureModuleLayout("Config.Layout.Tooltip")
    options.Buffs = ensureModuleLayout("Config.Layout.Buffs")
    options.Map = ensureModuleLayout("Config.Layout.Map")
    options.Chat = ensureModuleLayout("Config.Layout.Chat")
    options.Misc = ensureModuleLayout("Config.Layout.Misc")
    options.Profiles = ensureModuleLayout("Config.Layout.Profiles")
    options.FAQ = ensureModuleLayout("Config.Layout.FAQ")
    
    -- Then load VUI modules
    options.VUIBuffs = ensureModuleLayout("Config.Layout.VUIBuffs")
    options.VUIAnyFrame = ensureModuleLayout("Config.Layout.VUIAnyFrame")
    options.VUIKeystones = ensureModuleLayout("Config.Layout.VUIKeystones")
    options.VUICC = ensureModuleLayout("Config.Layout.VUICC")
    options.VUICD = ensureModuleLayout("Config.Layout.VUICD")
    options.VUIIDs = ensureModuleLayout("Config.Layout.VUIIDs")
    options.VUIGfinder = ensureModuleLayout("Config.Layout.VUIGfinder")
    options.VUITGCD = ensureModuleLayout("Config.Layout.VUITGCD")
    options.VUIAuctionator = ensureModuleLayout("Config.Layout.VUIAuctionator")
    options.VUINotifications = ensureModuleLayout("Config.Layout.VUINotifications")
    options.VUIScrollingText = ensureModuleLayout("Config.Layout.VUIScrollingText")
    options.VUIepf = ensureModuleLayout("Config.Layout.VUIepf")
    options.VUIConsumables = ensureModuleLayout("Config.Layout.VUIConsumables")
    options.VUIPositionOfPower = ensureModuleLayout("Config.Layout.VUIPositionOfPower")
    options.VUIMissingRaidBuffs = ensureModuleLayout("Config.Layout.VUIMissingRaidBuffs")
    options.VUIMouseFireTrail = ensureModuleLayout("Config.Layout.VUIMouseFireTrail")
    options.VUIHealerMana = ensureModuleLayout("Config.Layout.VUIHealerMana")
    options.VUISkin = ensureModuleLayout("Config.Layout.VUISkin")
    -- Note: VUIPlater integrated with Nameplates section

    -- Debug layout availability
    for name, layout in pairs(options) do
        VUI:Debug("CONFIG", name .. " layout " .. (layout and "LOADED" or "NOT LOADED"))
    end

    --Categories
    local categories = {
        -- Core VUI Modules
        { title = 'VUI General', name = 'General', layout = options['General'] },
        { title = 'VUI Unitframes', name = 'Unitframes', layout = options['Unitframes'] },
        { title = 'VUI Nameplates', name = 'Nameplates', layout = options['Nameplates'] },
        { title = 'VUI Actionbar', name = 'Actionbar', layout = options['Actionbar'] },
        { title = 'VUI Castbars', name = 'Castbars', layout = options['Castbars'] },
        { title = 'VUI Tooltip', name = 'Tooltip', layout = options['Tooltip'] },
        { title = 'VUI Buffs', name = 'Buffs', layout = options['Buffs'] },
        { title = 'VUI Map', name = 'Map', layout = options['Map'] },
        { title = 'VUI Chat', name = 'Chat', layout = options['Chat'] },
        
        -- VModules Header (Phase 1)
        { title = '|cFFFF6600Core Addon Modules|r', name = 'CoreHeader', layout = nil },
        
        -- Phase 1: Core Addon Modules
        { title = 'VUI Buffs', name = 'VUIBuffs', layout = options['VUIBuffs'] },
        { title = 'VUI AnyFrame', name = 'VUIAnyFrame', layout = options['VUIAnyFrame'] },
        { title = 'VUI Keystones', name = 'VUIKeystones', layout = options['VUIKeystones'] },
        { title = 'VUI CC', name = 'VUICC', layout = options['VUICC'] },
        { title = 'VUI CD', name = 'VUICD', layout = options['VUICD'] },
        { title = 'VUI IDs', name = 'VUIIDs', layout = options['VUIIDs'] },
        { title = 'VUI Gfinder', name = 'VUIGfinder', layout = options['VUIGfinder'] },
        { title = 'VUI TGCD', name = 'VUITGCD', layout = options['VUITGCD'] },
        { title = 'VUI Auctionator', name = 'VUIAuctionator', layout = options['VUIAuctionator'] },
        { title = 'VUI Notifications', name = 'VUINotifications', layout = options['VUINotifications'] },
        
        -- Phase 2 Header
        { title = '|cFF44DD00WeakAura Modules|r', name = 'WeakAuraHeader', layout = nil },
        
        -- Phase 2: WeakAura Feature Modules
        { title = 'VUI Scrolling Text', name = 'VUIScrollingText', layout = options['VUIScrollingText'] },
        { title = 'VUI Elite Player Frame', name = 'VUIepf', layout = options['VUIepf'] },
        { title = 'VUI Consumables', name = 'VUIConsumables', layout = options['VUIConsumables'] },
        { title = 'VUI Position of Power', name = 'VUIPositionOfPower', layout = options['VUIPositionOfPower'] },
        { title = 'VUI Missing Buffs', name = 'VUIMissingRaidBuffs', layout = options['VUIMissingRaidBuffs'] },
        { title = 'VUI Mouse Trail', name = 'VUIMouseFireTrail', layout = options['VUIMouseFireTrail'] },
        { title = 'VUI Healer Mana', name = 'VUIHealerMana', layout = options['VUIHealerMana'] },
        { title = 'VUI Details! Skin', name = 'VUISkin', layout = options['VUISkin'] },


        { title = '|cFF44DD00Support|r', name = 'CoreHeader', layout = nil },
        -- Misc
        { title = 'VUI Misc', name = 'Misc', layout = options['Misc'] },
        { title = 'VUI Profiles', name = 'Profiles', layout = options['Profiles'] },
        { title = 'VUI FAQ', name = 'FAQ', layout = options['FAQ'] },
    }
    
    -- Filter out nil entries (modules that might not be available)
    local filteredCategories = {}
    for _, category in ipairs(categories) do
        if category then
            table.insert(filteredCategories, category)
        end
    end
    categories = filteredCategories

    -- Set up tabs and layout container
    local container = VUIConfig:Panel(config, 600, 520)
    VUIConfig:GlueTop(container, config, 0, -35)
    
    -- Create scrolling tab area
    local scrollTabs = VUIConfig:ScrollFrame(config, 200, 520)
    scrollTabs:SetPoint("TOPLEFT", config, "TOPLEFT", 5, -35)
    scrollTabs:SetPoint("BOTTOMLEFT", config, "BOTTOMLEFT", 5, 45)
    
    -- Create buttons container inside scroll frame
    local buttonsContainer = VUIConfig:Panel(scrollTabs.scrollChild, 190, 520)
    buttonsContainer:SetPoint("TOPLEFT", scrollTabs.scrollChild, "TOPLEFT", 0, 0)
    
    -- Create content scroll frame
    local scrollContent = VUIConfig:ScrollFrame(config, 580, 520)
    scrollContent:SetPoint("TOPRIGHT", config, "TOPRIGHT", -5, -35)
    scrollContent:SetPoint("BOTTOMRIGHT", config, "BOTTOMRIGHT", -5, 45)
    
    -- Setup content panel
    local contentPanel = VUIConfig:Panel(scrollContent.scrollChild, 580, 520)
    contentPanel:SetPoint("TOPLEFT", scrollContent.scrollChild, "TOPLEFT", 0, 0)
    
    -- Store for use in other functions
    config.scrollTabs = scrollTabs
    config.scrollContent = scrollContent
    config.contentPanel = contentPanel
    config.buttonsContainer = buttonsContainer
    
    -- Tab setup and button creation
    local tabFrames = {}
    local selectedTab = nil
    local lastButton = nil
    
    for _, category in ipairs(categories) do
        -- Force create a layout if it doesn't exist (fallback for all categories)
        if not category.layout and category.name and category.name ~= "CoreHeader" and 
           category.name ~= "WeakAuraHeader" and category.name ~= "NewFeaturesHeader" then
            VUI:Print("Creating fallback layout for: " .. category.name)
            
            -- Create a basic fallback layout for this category
            category.layout = {
                layoutConfig = { padding = { top = 15 } },
                database = VUI.db.profile,
                rows = {
                    {
                        header = {
                            type = 'header',
                            label = category.title or category.name
                        }
                    },
                    {
                        placeholder = {
                            type = 'label',
                            label = "This module's settings are currently unavailable.",
                            column = 12
                        }
                    },
                    {
                        info = {
                            type = 'label',
                            label = "The module may need to be loaded or enabled first.",
                            column = 12
                        }
                    }
                }
            }
        end
        
        if category.layout then
            -- Create content frame for this tab
            local frame = VUIConfig:Panel(contentPanel, 560, 500)
            frame:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 10, -10)
            frame:Hide()
            
            -- Create tab button
            local button = VUIConfig:Button(buttonsContainer, 180, 25, category.title)
            
            -- Position the button
            if not lastButton then
                button:SetPoint("TOPLEFT", buttonsContainer, "TOPLEFT", 5, -5)
            else
                button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -2)
            end
            
            -- Store for access
            tabFrames[category.name] = {
                frame = frame,
                button = button,
                layout = category.layout
            }
            
            -- Create on click handler
            button:SetScript("OnClick", function()
                -- Hide previous tab content
                if selectedTab and tabFrames[selectedTab] then
                    tabFrames[selectedTab].frame:Hide()
                    tabFrames[selectedTab].button:Enable()
                end
                
                -- Show this tab content
                frame:Show()
                button:Disable()
                selectedTab = category.name
                
                -- Build layout if needed
                if not frame.layoutBuilt then
                    -- Check if this is a VUI module
                    local isVUIModule = category.name:match("^VUI")
                    
                    -- Try to get layout directly first
                    if category.layout and type(category.layout) == "table" and category.layout.rows then
                        -- Use the provided layout
                        VUIConfig:BuildWindow(frame, category.layout)
                    else
                        -- Try to get or create layout
                        local moduleObject = nil
                        
                        -- Try standard module path first
                        moduleObject = VUI:GetModule("Config.Layout." .. category.name, true)
                        
                        -- For VUI modules, try direct access too
                        if isVUIModule and not moduleObject then
                            moduleObject = VUI:GetModule(category.name, true) or VUI[category.name]
                        end
                        
                        if moduleObject then
                            -- Enable module if needed
                            if not moduleObject:IsEnabled() then
                                moduleObject:Enable()
                            end
                            
                            -- Call OnEnable if layout is missing
                            if not moduleObject.layout and moduleObject.OnEnable then
                                moduleObject:OnEnable()
                            end
                            
                            -- If we found a layout, use it
                            if moduleObject.layout then
                                category.layout = moduleObject.layout
                                VUIConfig:BuildWindow(frame, category.layout)
                            else
                                -- Create fallback layout
                                local fallbackLayout = {
                                    layoutConfig = { padding = { top = 15 } },
                                    database = VUI.db.profile,
                                    rows = {
                                        {
                                            header = {
                                                type = 'header',
                                                label = category.title or category.name
                                            }
                                        },
                                        {
                                            placeholder = {
                                                type = 'label',
                                                label = "This module's settings are currently unavailable.",
                                                column = 12
                                            }
                                        },
                                        {
                                            info = {
                                                type = 'label',
                                                label = "The module may need to be loaded or enabled first.",
                                                column = 12
                                            }
                                        },
                                        {
                                            reload = {
                                                type = 'button',
                                                text = 'Reload UI',
                                                column = 12,
                                                onClick = function()
                                                    ReloadUI()
                                                end
                                            }
                                        }
                                    }
                                }
                                
                                -- Use fallback layout
                                VUIConfig:BuildWindow(frame, fallbackLayout)
                            end
                        else
                            -- No module found, create basic fallback
                            local fallbackLayout = {
                                layoutConfig = { padding = { top = 15 } },
                                database = VUI.db.profile,
                                rows = {
                                    {
                                        header = {
                                            type = 'header',
                                            label = category.title or category.name
                                        }
                                    },
                                    {
                                        status = {
                                            type = 'label',
                                            label = "Module not found: " .. category.name,
                                            column = 12
                                        }
                                    },
                                    {
                                        reload = {
                                            type = 'button',
                                            text = 'Reload UI',
                                            column = 12,
                                            onClick = function()
                                                ReloadUI()
                                            end
                                        }
                                    }
                                }
                            }
                            
                            VUIConfig:BuildWindow(frame, fallbackLayout)
                        end
                    end
                    
                    frame.layoutBuilt = true
                    frame:SetScript("OnShow", function(self)
                        if self.DoLayout then
                            self:DoLayout()
                        end
                    end)
                end
                
                -- Force layout update
                if frame.DoLayout then
                    frame:DoLayout()
                end
            end)
            
            lastButton = button
        elseif category.title:find("|c") then
            -- This is a header/separator
            local label = VUIConfig:Label(buttonsContainer, category.title)
            label:SetPoint("TOPLEFT", lastButton or buttonsContainer, lastButton and "BOTTOMLEFT" or "TOPLEFT", 5, lastButton and -10 or 5)
            label:SetWidth(180)
            label:SetJustifyH("LEFT")
            lastButton = label
        end
    end
    
    -- Select the first tab by default
    for name, tabData in pairs(tabFrames) do
        -- Skip headers
        if name ~= "CoreHeader" and name ~= "WeakAuraHeader" and name ~= "NewFeaturesHeader" then
            tabData.button:Click()
            break
        end
    end

    -- Add bottom buttons container
    local buttonContainer = VUIConfig:Panel(config, 580, 40)
    buttonContainer:SetPoint("BOTTOM", config, "BOTTOM", 0, 5)
    VUIConfig:ApplyBackdrop(buttonContainer, "panel")
    
    -- Reset module button
    local reset = VUIConfig:Button(buttonContainer, 150, 30, 'Reset Module')
    reset:SetPoint("LEFT", buttonContainer, "LEFT", 20, 0)
    reset:SetScript('OnClick', function()
        if selectedTab then
            -- Confirm reset
            StaticPopupDialogs["VUI_RESET_MODULE"] = {
                text = "Are you sure you want to reset %s to default settings?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    -- Reset module settings
                    if VUI.db.profile[selectedTab] then
                        VUI.db.profile[selectedTab] = {}
                        VUI:Print("Reset settings for " .. selectedTab)
                        
                        -- Rebuild tab
                        if tabFrames[selectedTab] and tabFrames[selectedTab].frame and tabFrames[selectedTab].layout then
                            tabFrames[selectedTab].frame:Hide()
                            tabFrames[selectedTab].frame = VUIConfig:Panel(contentPanel, 560, 500)
                            tabFrames[selectedTab].frame:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 10, -10)
                            VUIConfig:BuildWindow(tabFrames[selectedTab].frame, tabFrames[selectedTab].layout)
                            tabFrames[selectedTab].frame:Show()
                        end
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            
            StaticPopup_Show("VUI_RESET_MODULE", selectedTab)
        end
    end)
    
    -- Export profile button
    local export = VUIConfig:Button(buttonContainer, 150, 30, 'Export Profile')
    export:SetPoint("LEFT", reset, "RIGHT", 20, 0)
    export:SetScript('OnClick', function()
        -- Create export dialog
        StaticPopupDialogs["VUI_EXPORT_PROFILE"] = {
            text = "Copy this export string for your VUI profile:",
            button1 = "Close",
            OnShow = function(self)
                self.editBox:SetText("VUI_PROFILE_" .. date("%Y%m%d") .. "_" .. UnitName("player"))
                self.editBox:HighlightText()
                self.editBox:SetFocus()
            end,
            hasEditBox = true,
            editBoxWidth = 350,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        
        StaticPopup_Show("VUI_EXPORT_PROFILE")
    end)
    
    -- Save & reload button
    local save = VUIConfig:Button(buttonContainer, 150, 30, 'Save & Reload')
    save:SetPoint("LEFT", export, "RIGHT", 20, 0)
    save:SetScript('OnClick', function()
        ReloadUI()
    end)

    -- Mark configuration as initialized
    self.configInitialized = true
    
    -- Select the first tab by default if none is already selected
    if config:IsShown() and scrollTabs and scrollTabs.tabs then
        if not scrollTabs.selectedTab then
            C_Timer.After(0.1, function()
                -- Try to select the first valid tab with content
                for _, tab in ipairs(scrollTabs.tabs) do
                    if tab and tab.name and tab.name ~= "CoreHeader" and tab.name ~= "WeakAuraHeader" and tab.name ~= "NewFeaturesHeader" then
                        VUI:Debug("CONFIG", "Auto-selecting tab: " .. tab.name)
                        scrollTabs:SelectTab(tab.name)
                        break
                    end
                end
            end)
        end
    end
end

-- Function to refresh config when a module becomes available
function Gui:RefreshConfig()
    -- This function is called by VUI:RefreshModuleUI()
    if self.configInitialized then
        VUI:Debug("CONFIG", "Refreshing configuration UI")
        
        -- Just find the current instance and refresh it
        local config = _G.VUIConfigRef
        if config and config:IsShown() then
            -- If configuration window is open and we have the current tab
            if selectedTab and tabFrames and tabFrames[selectedTab] then
                local tabData = tabFrames[selectedTab]
                
                -- Rebuild the current tab's content if needed
                if tabData.frame and tabData.layout then
                    tabData.frame:Hide()
                    tabData.frame = VUIConfig:Panel(contentPanel, 560, 500)
                    tabData.frame:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 10, -10)
                    VUIConfig:BuildWindow(tabData.frame, tabData.layout)
                    tabData.frame:Show()
                    
                    if tabData.frame.DoLayout then
                        tabData.frame:DoLayout()
                    end
                end
            end
        end
    end
end

-- Add a global refresh function that can be called when modules are loaded
function VUI:RefreshModuleUI(moduleName)
    VUI:Debug("CONFIG", "Module UI refresh requested for: " .. (moduleName or "all modules"))
    
    -- Get the GUI module
    local guiModule = VUI:GetModule("Config.Gui", true)
    
    -- If GUI module is available, refresh it
    if guiModule and guiModule.RefreshConfig then
        guiModule:RefreshConfig()
    end
    
    -- Notify any listeners that a module UI needs refresh
    if VUI.FireCallback then
        VUI:FireCallback("OnModuleUIRefresh", moduleName)
    end
end

-- Function to ensure all layout modules are loaded
function Gui:EnsureLayoutModulesLoaded()
    -- Quiet version of the loading function
    
    -- Core modules
    local coreModules = {
        "Config.Layout.General",
        "Config.Layout.Unitframes",
        "Config.Layout.Nameplates",
        "Config.Layout.Actionbar",
        "Config.Layout.Castbars",
        "Config.Layout.Tooltip",
        "Config.Layout.Buffs",
        "Config.Layout.Map",
        "Config.Layout.Chat",
        "Config.Layout.Misc",
        "Config.Layout.Profiles",
        "Config.Layout.FAQ"
    }
    
    -- VModule layouts
    local vmoduleLayouts = {
        "Config.Layout.VUIBuffs",
        "Config.Layout.VUIAnyFrame",
        "Config.Layout.VUIKeystones",
        "Config.Layout.VUICC",
        "Config.Layout.VUICD",
        "Config.Layout.VUIIDs",
        "Config.Layout.VUIGfinder",
        "Config.Layout.VUITGCD",
        "Config.Layout.VUIAuctionator",
        "Config.Layout.VUINotifications",
        "Config.Layout.VUIScrollingText",
        "Config.Layout.VUIepf",
        "Config.Layout.VUIConsumables",
        "Config.Layout.VUIPositionOfPower",
        "Config.Layout.VUIMissingRaidBuffs",
        "Config.Layout.VUIMouseFireTrail",
        "Config.Layout.VUIHealerMana",
        "Config.Layout.VUISkin"
    }
    
    -- Helper to load a module
    local function loadModule(moduleName)
        local module = VUI:GetModule(moduleName, true)
        
        if not module then
            -- Create the module
            module = VUI:NewModule(moduleName)
            
            -- Setup template for OnEnable
            module.OnEnable = function(self)
                -- Skip if already has layout
                if self.layout then return end
                
                -- For VUI modules, try to get the corresponding module
                local actualModuleName = moduleName:gsub("Config%.Layout%.", "")
                local actualModule = nil
                
                -- Try various ways to access the module
                if VUI[actualModuleName] then
                    actualModule = VUI[actualModuleName]
                elseif _G[actualModuleName] then
                    actualModule = _G[actualModuleName]
                elseif VUI:GetModule(actualModuleName, true) then
                    actualModule = VUI:GetModule(actualModuleName, true)
                end
                
                -- Create basic layout with detection of the actual module
                self.layout = {
                    layoutConfig = { padding = { top = 15 } },
                    database = VUI.db.profile,
                    rows = {
                        {
                            header = {
                                type = 'header',
                                label = actualModuleName:gsub("VUI", "VUI ") .. " Settings"
                            }
                        },
                        {
                            moduleStatus = {
                                type = 'label',
                                label = actualModule and "Module Status: Available" or "Module Status: Not Loaded",
                                column = 12
                            }
                        },
                        {
                            enableModule = {
                                key = 'vmodules.' .. string.lower(actualModuleName) .. '.enabled',
                                type = 'checkbox', 
                                label = 'Enable Module',
                                tooltip = 'Enable this module',
                                column = 6
                            }
                        },
                        {
                            loadModule = {
                                type = 'button',
                                text = 'Reload UI',
                                column = 6,
                                onClick = function()
                                    ReloadUI()
                                end
                            }
                        },
                        {
                            placeholder = {
                                type = 'label',
                                label = "Settings will appear after enabling the module and reloading the UI.",
                                column = 12
                            }
                        }
                    }
                }
            end
        end
        
        if module then
            if not module:IsEnabled() then
                module:Enable()
            end
            
            -- Force call OnEnable to ensure layout is created
            if module.OnEnable and not module.layout then
                module:OnEnable()
            end
            
            -- Create layout if still missing
            if not module.layout then
                module.layout = {
                    layoutConfig = { padding = { top = 15 } },
                    database = VUI.db.profile,
                    rows = {
                        {
                            header = {
                                type = 'header',
                                label = moduleName:gsub("Config%.Layout%.", ""):gsub("VUI", "VUI ") .. " Settings"
                            }
                        },
                        {
                            placeholder = {
                                type = 'label',
                                label = "This module's settings are currently unavailable.",
                                column = 12
                            }
                        },
                        {
                            info = {
                                type = 'label',
                                label = "The module may need to be loaded or enabled first.",
                                column = 12
                            }
                        },
                        {
                            reload = {
                                type = 'button',
                                text = 'Reload UI',
                                column = 12,
                                onClick = function()
                                    ReloadUI()
                                end
                            }
                        }
                    }
                }
            end
        end
        
        -- Return true if layout is available
        return module and module.layout
    end
    
    -- Load all core modules
    for _, moduleName in ipairs(coreModules) do
        loadModule(moduleName)
    end
    
    -- Load all VModule layouts
    for _, moduleName in ipairs(vmoduleLayouts) do
        loadModule(moduleName)
    end
end
