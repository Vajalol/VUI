local Gui = VUI:NewModule("Config.Gui")

local General = VUI:GetModule("Config.Layout.General")
local Unitframes = VUI:GetModule("Config.Layout.Unitframes")
local Nameplates = VUI:GetModule("Config.Layout.Nameplates")
local Actionbar = VUI:GetModule("Config.Layout.Actionbar")
local Castbars = VUI:GetModule("Config.Layout.Castbars")
local Map = VUI:GetModule("Config.Layout.Map")
local Misc = VUI:GetModule("Config.Layout.Misc")
local FAQ = VUI:GetModule("Config.Layout.FAQ")
local Tooltip = VUI:GetModule("Config.Layout.Tooltip")
local Chat = VUI:GetModule("Config.Layout.Chat")
local Buffs = VUI:GetModule("Config.Layout.Buffs")
local Profiles = VUI:GetModule("Config.Layout.Profiles")
-- VModules
local VUIBuffs = VUI:GetModule("Config.Layout.VUIBuffs")
local VUIAnyFrame = VUI:GetModule("Config.Layout.VUIAnyFrame")
local VUIKeystones = VUI:GetModule("Config.Layout.VUIKeystones")
local VUICC = VUI:GetModule("Config.Layout.VUICC")
local VUICD = VUI:GetModule("Config.Layout.VUICD")
local VUIIDs = VUI:GetModule("Config.Layout.VUIIDs")
local VUIGfinder = VUI:GetModule("Config.Layout.VUIGfinder")
local VUITGCD = VUI:GetModule("Config.Layout.VUITGCD")
local VUIAuctionator = VUI:GetModule("Config.Layout.VUIAuctionator")
local VUINotifications = VUI:GetModule("Config.Layout.VUINotifications")
local VUIScrollingText = VUI:GetModule("Config.Layout.VUIScrollingText")
local VUIepf = VUI:GetModule("Config.Layout.VUIepf")
local VUIConsumables = VUI:GetModule("Config.Layout.VUIConsumables")
local VUIPositionOfPower = VUI:GetModule("Config.Layout.VUIPositionOfPower")
local VUIMissingRaidBuffs = VUI:GetModule("Config.Layout.VUIMissingRaidBuffs")
local VUIMouseFireTrail = VUI:GetModule("Config.Layout.VUIMouseFireTrail")
local VUIHealerMana = VUI:GetModule("Config.Layout.VUIHealerMana")
-- Note: VUIPlater integrated with Nameplates section

function Gui:OnEnable()
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

    local version = VUIConfig:Label(config.titlePanel, C_AddOns.GetAddOnMetadata("VUI", "version"))
    VUIConfig:GlueLeft(version, config.titlePanel, 50, 0)

    local logo = VUIConfig:Texture(config.titlePanel, 120, 35, "Interface\\AddOns\\VUI\\Media\\Textures\\Config\\Logo")
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
            self:AddSection();
            self:AddButton("|cffea00ffV|r|cff00a2ffUI|r", VUI:Config(true))
        end

        hooksecurefunc(GameMenuFrame, "InitButtons", VUIGameMenuButton)
    end

    -- Minimap AddOns Option
    _G.VUI_Options = function()
        VUI:Config()
     end

    --Options
    local options = {
        General = General.layout,
        Unitframes = Unitframes.layout,
        Nameplates = Nameplates.layout,
        Actionbar = Actionbar.layout,
        Castbars = Castbars.layout,
        Tooltip = Tooltip.layout,
        Buffs = Buffs.layout,
        Map = Map.layout,
        Chat = Chat.layout,
        Misc = Misc.layout,
        Profiles = Profiles.layout,
        FAQ = FAQ.layout,
        -- VModules - Core Modules (Phase 1)
        VUIBuffs = VUIBuffs.layout,
        VUIAnyFrame = VUIAnyFrame.layout,
        VUIKeystones = VUIKeystones.layout,
        VUICC = VUICC.layout,
        VUICD = VUICD and VUICD.layout,
        VUIIDs = VUIIDs and VUIIDs.layout,
        VUIGfinder = VUIGfinder and VUIGfinder.layout,
        VUITGCD = VUITGCD and VUITGCD.layout,
        VUIAuctionator = VUIAuctionator and VUIAuctionator.layout,
        VUINotifications = VUINotifications and VUINotifications.layout,
        -- VModules - WeakAura Replacements (Phase 2)
        VUIScrollingText = VUIScrollingText and VUIScrollingText.layout,
        VUIepf = VUIepf and VUIepf.layout,
        VUIConsumables = VUIConsumables and VUIConsumables.layout,
        VUIPositionOfPower = VUIPositionOfPower and VUIPositionOfPower.layout,
        VUIMissingRaidBuffs = VUIMissingRaidBuffs and VUIMissingRaidBuffs.layout,
        VUIMouseFireTrail = VUIMouseFireTrail and VUIMouseFireTrail.layout,
        VUIHealerMana = VUIHealerMana and VUIHealerMana.layout
        -- Note: VUIPlater integrated with Nameplates section
    }

    --Categories
    local categories = {
        -- Core SUI Modules
        { title = 'General', name = 'General', layout = options['General'] },
        { title = 'Unitframes', name = 'Unitframes', layout = options['Unitframes'] },
        { title = 'Nameplates', name = 'Nameplates', layout = options['Nameplates'] },
        { title = 'Actionbar', name = 'Actionbar', layout = options['Actionbar'] },
        { title = 'Castbars', name = 'Castbars', layout = options['Castbars'] },
        { title = 'Tooltip', name = 'Tooltip', layout = options['Tooltip'] },
        { title = 'Buffs', name = 'Buffs', layout = options['Buffs'] },
        { title = 'Map', name = 'Map', layout = options['Map'] },
        { title = 'Chat', name = 'Chat', layout = options['Chat'] },
        { title = 'Misc', name = 'Misc', layout = options['Misc'] },
        { title = 'Profiles', name = 'Profiles', layout = options['Profiles'] },
        { title = 'FAQ', name = 'FAQ', layout = options['FAQ'] },
        
        -- VModules Header (Phase 1)
        { title = '|cFFFF6600Core Addon Modules|r', name = 'CoreHeader', layout = nil },
        
        -- Phase 1: Core Addon Modules
        { title = 'VUI Buffs', name = 'VUIBuffs', layout = options['VUIBuffs'] },
        { title = 'VUI AnyFrame', name = 'VUIAnyFrame', layout = options['VUIAnyFrame'] },
        { title = 'VUI Keystones', name = 'VUIKeystones', layout = options['VUIKeystones'] },
        { title = 'VUI CC', name = 'VUICC', layout = options['VUICC'] },
        
        -- Only add if the module layout exists
        options['VUICD'] and { title = 'VUI CD', name = 'VUICD', layout = options['VUICD'] },
        options['VUIIDs'] and { title = 'VUI IDs', name = 'VUIIDs', layout = options['VUIIDs'] },
        options['VUIGfinder'] and { title = 'VUI Gfinder', name = 'VUIGfinder', layout = options['VUIGfinder'] },
        options['VUITGCD'] and { title = 'VUI TGCD', name = 'VUITGCD', layout = options['VUITGCD'] },
        options['VUIAuctionator'] and { title = 'VUI Auctionator', name = 'VUIAuctionator', layout = options['VUIAuctionator'] },
        options['VUINotifications'] and { title = 'VUI Notifications', name = 'VUINotifications', layout = options['VUINotifications'] },
        
        -- Phase 2 Header
        { title = '|cFF44DD00WeakAura Modules|r', name = 'WeakAuraHeader', layout = nil },
        
        -- Phase 2: WeakAura Feature Modules
        options['VUIScrollingText'] and { title = 'VUI Scrolling Text', name = 'VUIScrollingText', layout = options['VUIScrollingText'] },
        options['VUIepf'] and { title = 'VUI Enhanced Player Frame', name = 'VUIepf', layout = options['VUIepf'] },
        options['VUIConsumables'] and { title = 'VUI Consumables', name = 'VUIConsumables', layout = options['VUIConsumables'] },
        options['VUIPositionOfPower'] and { title = 'VUI Position of Power', name = 'VUIPositionOfPower', layout = options['VUIPositionOfPower'] },
        options['VUIMissingRaidBuffs'] and { title = 'VUI Missing Raid Buffs', name = 'VUIMissingRaidBuffs', layout = options['VUIMissingRaidBuffs'] },
        options['VUIMouseFireTrail'] and { title = 'VUI Mouse Fire Trail', name = 'VUIMouseFireTrail', layout = options['VUIMouseFireTrail'] },
        options['VUIHealerMana'] and { title = 'VUI Healer Mana', name = 'VUIHealerMana', layout = options['VUIHealerMana'] },
        
        -- Phase 3 Header
        { title = '|cFF00AAFFNew Features|r', name = 'NewFeaturesHeader', layout = nil }
        
        -- Note: VUIPlater integrated with Nameplates section
    }
    
    -- Filter out nil entries (modules that might not be available)
    local filteredCategories = {}
    for _, category in ipairs(categories) do
        if category then
            table.insert(filteredCategories, category)
        end
    end
    categories = filteredCategories

    -- Tabs
    local tabs = VUIConfig:TabPanel(config, nil, nil, categories, true, 200, 27)
    VUIConfig:GlueAcross(tabs, config, 10, -35, -10, 10)

    --local scrollContainer = VUIConfig:Panel(config, 515, 370, tabs.container)
    --VUIConfig:GlueTop(scrollContainer, config, -10, -35, 'RIGHT')

    -- SCROLL FRAMES BUGGY
    local scrollTabs = VUIConfig:ScrollFrame(config, 200, 500, tabs.buttonContainer)
    VUIConfig:GlueTop(scrollTabs, config, 10, -35, 'LEFT')

    local scrollContainer = VUIConfig:ScrollFrame(config, 575, 555, tabs.container)
    VUIConfig:GlueTop(scrollContainer, config, -10, -35, 'RIGHT')

    -- Button container for better organization
    local buttonContainer = VUIConfig:Panel(config, 580, 40)
    buttonContainer:SetPoint("BOTTOM", config, "BOTTOM", 0, 10)
    
    -- Reset button
    local reset = VUIConfig:Button(buttonContainer, 160, 30, 'Reset Module')
    reset:SetPoint("LEFT", buttonContainer, "LEFT", 10, 0)
    reset:SetScript('OnClick', function()
        -- Get the selected tab
        local selectedTab = tabs:GetSelectedTab()
        if selectedTab and selectedTab.name then
            local moduleName = selectedTab.name
            
            -- Confirm dialog
            StaticPopupDialogs["VUI_RESET_MODULE"] = StaticPopupDialogs["VUI_RESET_MODULE"] or {
                text = "Are you sure you want to reset %s to default settings?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function(self)
                    -- Reset module settings
                    if VUI.db.namespaces[moduleName] then
                        VUI.db.namespaces[moduleName]:ResetProfile()
                        VUI:Print("Reset settings for " .. moduleName)
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            
            StaticPopup_Show("VUI_RESET_MODULE", moduleName)
        end
    end)
    
    -- Export button
    local export = VUIConfig:Button(buttonContainer, 160, 30, 'Export Profile')
    export:SetPoint("LEFT", reset, "RIGHT", 10, 0)
    export:SetScript('OnClick', function()
        -- Create a basic export dialog with current profile
        StaticPopupDialogs["VUI_EXPORT_PROFILE"] = StaticPopupDialogs["VUI_EXPORT_PROFILE"] or {
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
    
    -- Save button
    local save = VUIConfig:Button(buttonContainer, 160, 30, 'Save & Reload')
    save:SetPoint("LEFT", export, "RIGHT", 10, 0)
    save:SetScript('OnClick', function()
        ReloadUI()
    end)
end
