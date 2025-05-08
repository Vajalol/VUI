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

function Gui:OnEnable()
    local VUIConfig = LibStub('VUIConfig')
    VUIConfig.config = {
        font = {
            family    = STANDARD_TEXT_FONT,
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
    local config = VUIConfig:Window(UIParent, 700, 415)
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
            self:AddButton("|cffea00ffS|r|cff00a2ffUI|r", VUI:Config(true))
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
        -- VModules
        VUIBuffs = VUIBuffs.layout,
        VUIAnyFrame = VUIAnyFrame.layout,
        VUIKeystones = VUIKeystones.layout
    }

    --Categories
    local categories = {
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
        -- VModules
        { title = 'VUI Buffs', name = 'VUIBuffs', layout = options['VUIBuffs'] },
        { title = 'VUI AnyFrame', name = 'VUIAnyFrame', layout = options['VUIAnyFrame'] },
        { title = 'VUI Keystones', name = 'VUIKeystones', layout = options['VUIKeystones'] }
    }

    -- Tabs
    local tabs = VUIConfig:TabPanel(config, nil, nil, categories, true, 160, 27)
    VUIConfig:GlueAcross(tabs, config, 10, -35, -10, 10)

    --local scrollContainer = VUIConfig:Panel(config, 515, 370, tabs.container)
    --VUIConfig:GlueTop(scrollContainer, config, -10, -35, 'RIGHT')

    -- SCROLL FRAMES BUGGY
    local scrollTabs = VUIConfig:ScrollFrame(config,  160, 315, tabs.buttonContainer)
    VUIConfig:GlueTop(scrollTabs, config, 10, -35, 'LEFT')

    local scrollContainer = VUIConfig:ScrollFrame(config, 515, 370, tabs.container)
    VUIConfig:GlueTop(scrollContainer, config, -10, -35, 'RIGHT')

    --Save
    local save = VUIConfig:Button(config, 160, 30, 'Save')
    VUIConfig:GlueBottom(save, config, 10, 10, 'LEFT')
    save:SetScript('OnClick', function()
        ReloadUI()
    end)
end
