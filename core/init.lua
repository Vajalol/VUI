-- VUI Core Initialization
-- Author: VortexQ8
-- Version: 0.3.0

local addonName, VUI = ...
_G["VUI"] = VUI

-- Initialize the main addon using AceAddon-3.0 framework
VUI = LibStub("AceAddon-3.0"):NewAddon(VUI, addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- Global constants
VUI.name = "VUI"
VUI.version = "0.3.0"
VUI.author = "VortexQ8"
VUI.CLASSCOLOR = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

-- Initialize modules table to store all the sub-addons
VUI.modules = {}

-- Initialize frames table to track UI elements
VUI.frames = {}

-- Module registration function
function VUI:RegisterModule(name, module)
    if not name or not module then return end
    
    -- Apply the module template to ensure framework compatibility
    if self.ModuleTemplate then
        module = self.ModuleTemplate:Extend(module)
    end
    
    -- Set module metadata
    self.modules[name] = module
    module.moduleName = name
    
    -- Set up frames array for UI tracking
    if not module.frames then
        module.frames = {}
    end
    
    -- Initialize module options
    if not VUI.options.args.modules then
        VUI.options.args.modules = {
            type = "group",
            name = "Modules",
            order = 2,
            args = {}
        }
    end
    
    -- Add module to options panel if it has a config
    if module.GetOptions then
        VUI.options.args.modules.args[name] = module:GetOptions()
    end
    
    -- Connect to integration system for framework access
    if self.Integration and self.Integration:EnsureComponent("Integration") then
        -- This will be handled by the integration system on ADDON_LOADED
        module.pendingIntegration = true
    end
    
    return module
end

-- Function to check if a module exists and is enabled
function VUI:IsModuleEnabled(name)
    if not self.modules[name] then return false end
    
    -- Use database optimization if available
    if self.DatabaseOptimization then
        return self.DatabaseOptimization:Get(self.db, "profile.modules." .. name .. ".enabled", false)
    else
        return self.db.profile.modules[name].enabled
    end
end

-- Function to enable a module
function VUI:EnableModule(name)
    if not self.modules[name] then return end
    if self:IsModuleEnabled(name) then return end
    
    -- Use database optimization if available
    if self.DatabaseOptimization then
        self.DatabaseOptimization:Set(self.db, "profile.modules." .. name .. ".enabled", true, true) -- Immediate update
    else
        self.db.profile.modules[name].enabled = true
    end
    
    if self.modules[name].Enable then
        self.modules[name]:Enable()
    end
    
    self:Print(name .. " module enabled")
end

-- Function to disable a module
function VUI:DisableModule(name)
    if not self.modules[name] then return end
    if not self:IsModuleEnabled(name) then return end
    
    -- Use database optimization if available
    if self.DatabaseOptimization then
        self.DatabaseOptimization:Set(self.db, "profile.modules." .. name .. ".enabled", false, true) -- Immediate update
    else
        self.db.profile.modules[name].enabled = false
    end
    
    if self.modules[name].Disable then
        self.modules[name]:Disable()
    end
    
    self:Print(name .. " module disabled")
end

-- Main initialization function
function VUI:OnInitialize()
    -- Load saved variables using AceDB
    self.db = LibStub("AceDB-3.0"):New("VUIDB", VUI.defaults, true)
    self.charDB = LibStub("AceDB-3.0"):New("VUICharacterDB", VUI.charDefaults, true)
    
    -- Initialize the UI framework
    self:InitializeUI()
    
    -- Setup profile options
    self:SetupProfileOptions()
    
    -- Register options table
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, self.name)
    
    -- Set up slash commands
    self:RegisterChatCommand("vui", "SlashCommand")
    
    -- Initialize the Database Optimization System first to benefit other systems
    if self.DatabaseOptimization then
        self.DatabaseOptimization:Initialize()
        
        -- Register core databases with optimization system
        self.DatabaseOptimization:RegisterModuleDatabase("Core", self.db)
        self.DatabaseOptimization:RegisterModuleDatabase("Character", self.charDB)
        
        -- Preload common settings
        self:PreloadCommonDatabaseValues()
    end
    
    -- Load media files
    self:InitializeMedia()
    
    -- Initialize integration system
    if self.Integration then
        self.Integration:Initialize()
        self.Integration:RegisterThemeChangeHandler()
    end
    
    -- Initialize Dashboard
    if self.Dashboard then
        self.Dashboard:Initialize()
    end
    
    -- Initialize ConfigUI for improved settings organization
    if self.ConfigUI then
        self.ConfigUI:Initialize()
    end
    
    -- Initialize ThemeEditor for customizing themes
    if self.ThemeEditor then
        self.ThemeEditor:Initialize()
    end
    
    -- Initialize Chat module (core feature)
    if self.Chat then
        self.Chat:Initialize()
    end
    
    -- Initialize modules
    for name, module in pairs(self.modules) do
        if module.Initialize then
            module:Initialize()
        end
        
        -- Enable module if it's enabled in the settings
        if self:IsModuleEnabled(name) and module.Enable then
            module:Enable()
        end
        
        -- Register module database with optimization system if available
        if self.DatabaseOptimization and module.db then
            self.DatabaseOptimization:RegisterModuleDatabase(name, module.db)
        end
    end
    
    self:Print("VUI v" .. self.version .. " initialized. Type /vui for options.")
end

-- Preload frequently accessed database values
function VUI:PreloadCommonDatabaseValues()
    if not self.DatabaseOptimization then return end
    
    -- Core settings frequently accessed
    local commonPaths = {
        -- General appearance
        "profile.appearance.theme",
        "profile.appearance.font",
        "profile.appearance.fontSize",
        "profile.appearance.statusbarTexture",
        
        -- Module states
        "profile.modules",
        
        -- Performance settings
        "profile.performance",
        
        -- UI layout
        "profile.layout",
        
        -- Character-specific settings
        "profile.characterSettings." .. (UnitName("player") or "Unknown")
    }
    
    -- Preload core paths
    for _, path in ipairs(commonPaths) do
        local value = self.DatabaseOptimization:GetNestedValue(self.db, path)
        if value ~= nil then
            self.DatabaseOptimization:CacheValue(self.db, path, value)
        end
    end
end

-- Initialize UI Framework
function VUI:InitializeUI()
    -- Ensure appearance settings exist
    if not self.db.profile.appearance then
        self.db.profile.appearance = {
            theme = "thunderstorm",
            font = "Friz Quadrata TT",
            fontSize = 12,
            border = "thin",
            classColoredBorders = true,
            useClassColors = true,
            backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0.4, g = 0.4, b = 0.4, a = 1},
            statusbarTexture = "smooth"
        }
    end
    
    -- Register callbacks for UI updates
    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateUI")
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateUI")
    self.db.RegisterCallback(self, "OnProfileReset", "UpdateUI")
    
    -- Register UI-related events
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "UpdateUI")
    self:RegisterEvent("UI_SCALE_CHANGED", "UpdateUI")
end

-- Update UI when settings change
function VUI:UpdateUI(_, database, profileKey)
    self:Print("Applying profile changes...")
    
    -- Update framework UI elements
    if self.UI and self.UI.UpdateAppearance then
        self.UI:UpdateAppearance()
    end
    
    -- Update widgets
    if self.Widgets and self.Widgets.UpdateAppearance then
        self.Widgets:UpdateAppearance()
    end
    
    -- Update all module UI elements
    for name, module in pairs(self.modules) do
        if self:IsModuleEnabled(name) and module.UpdateUI then
            module:UpdateUI()
        end
    end
    
    -- Notify the user that the profile change is complete
    if profileKey then
        self:Print("Profile '" .. profileKey .. "' has been applied.")
    else
        self:Print("Settings updated.")
    end
end

-- Event handling when addon is fully loaded
function VUI:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")
    
    -- Hook into the game's interface options
    self:HookScript(GameMenuFrame, "OnShow", "GameMenuFrame_OnShow")
end

-- PLAYER_ENTERING_WORLD event handler
function VUI:PLAYER_ENTERING_WORLD()
    local inInstance, instanceType = IsInInstance()
    for name, module in pairs(self.modules) do
        if self:IsModuleEnabled(name) and module.OnEnterWorld then
            module:OnEnterWorld(inInstance, instanceType)
        end
    end
end

-- PLAYER_LOGOUT event handler
function VUI:PLAYER_LOGOUT()
    for name, module in pairs(self.modules) do
        if module.OnLogout then
            module:OnLogout()
        end
    end
end

-- Slash command handler
function VUI:SlashCommand(input)
    if not input or input:trim() == "" then
        -- Toggle dashboard
        if self.Dashboard then
            self.Dashboard:Toggle()
        else
            -- Fallback to main configuration panel if dashboard isn't available
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        end
    else
        -- Parse the command
        local command, arg = input:match("^(%S+)%s*(.*)$")
        
        if command == "enable" and arg ~= "" then
            self:EnableModule(arg)
        elseif command == "disable" and arg ~= "" then
            self:DisableModule(arg)
        elseif command == "toggle" and arg ~= "" then
            if self:IsModuleEnabled(arg) then
                self:DisableModule(arg)
            else
                self:EnableModule(arg)
            end
        elseif command == "version" then
            self:Print("Version: " .. self.version)
        elseif command == "config" or command == "options" then
            -- Open main configuration panel with the new tabbed interface if available
            if self.ConfigUI and self.ConfigUI.enabled then
                InterfaceOptionsFrame_OpenToCategory(self.ConfigUI.panel)
                InterfaceOptionsFrame_OpenToCategory(self.ConfigUI.panel)
            else
                -- Fallback to traditional panel
                InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
                InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            end
        elseif command == "timeline" then
            -- Toggle TrufiGCD timeline if available
            if self:IsModuleEnabled("trufigcd") and self.modules.trufigcd.Timeline and self.modules.trufigcd.Timeline.ToggleTimeline then
                self.modules.trufigcd.Timeline:ToggleTimeline()
            else
                self:Print("TrufiGCD Timeline view is not available. Make sure the TrufiGCD module is enabled.")
            end
        elseif command == "dashboard" then
            -- Toggle dashboard
            if self.Dashboard then
                self.Dashboard:Toggle()
            else
                self:Print("Dashboard is not available.")
            end
        elseif command == "theme" or command == "themes" then
            -- Open theme editor
            if self.ThemeEditor then
                self.ThemeEditor:Show()
            else
                self:Print("Theme Editor is not available.")
            end
        elseif command == "spells" or command == "spell" then
            -- Handle spell notifications subcommands
            local spellModule = self:GetModule("SpellNotifications")
            if spellModule and spellModule.ProcessChatCommand then
                spellModule:ProcessChatCommand(arg)
            else
                self:Print("Spell Notifications module is not available.")
            end
        elseif command == "profile" or command == "profiles" then
            -- Open profiles section of the config panel
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            LibStub("AceConfigDialog-3.0"):SelectGroup(addonName, "profiles")
        elseif command == "list" then
            self:Print("Available modules:")
            for name, _ in pairs(self.modules) do
                local status = self:IsModuleEnabled(name) and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
                self:Print("  " .. name .. ": " .. status)
            end
        else
            self:Print("Usage:")
            self:Print("  /vui - Opens the dashboard")
            self:Print("  /vui dashboard - Toggles the dashboard")
            self:Print("  /vui config - Opens the configuration panel")
            self:Print("  /vui theme - Opens the theme editor")
            self:Print("  /vui timeline - Opens the TrufiGCD spell history timeline")
            self:Print("  /vui profile - Opens the profile management panel")
            self:Print("  /vui spells - Opens the spell management UI")
            self:Print("  /vui spells list - Lists your custom spells")
            self:Print("  /vui spells add [spellID] [type] [priority] - Add a custom spell")
            self:Print("  /vui spells remove [spellID] - Remove a custom spell")
            self:Print("  /vui spells test [spellID] [type] - Test a spell notification")
            self:Print("  /vui enable <module> - Enables a module")
            self:Print("  /vui disable <module> - Disables a module")
            self:Print("  /vui toggle <module> - Toggles a module")
            self:Print("  /vui version - Displays the addon version")
            self:Print("  /vui list - Lists all available modules")
            self:Print("  /trufitimeline - Direct command to toggle the spell timeline view")
        end
    end
end

-- Add Interface Options button to Game Menu
function VUI:GameMenuFrame_OnShow()
    if not GameMenuButtonVUI then
        local configButton = CreateFrame("Button", "GameMenuButtonVUI", GameMenuFrame, "GameMenuButtonTemplate")
        configButton:SetText(VUI.name .. " Options")
        
        -- Position the first button under Addons
        local lastButton = GameMenuButtonAddons
        configButton:SetPoint("TOP", lastButton, "BOTTOM", 0, -1)
        
        -- Add Dashboard button if available
        if self.Dashboard then
            local dashButton = CreateFrame("Button", "GameMenuButtonVUIDashboard", GameMenuFrame, "GameMenuButtonTemplate")
            dashButton:SetText(VUI.name .. " Dashboard")
            
            -- Position the dashboard button under config button
            dashButton:SetPoint("TOP", configButton, "BOTTOM", 0, -1)
            
            -- Adjust other buttons
            GameMenuButtonLogout:SetPoint("TOP", dashButton, "BOTTOM", 0, -16)
            
            -- Adjust the height of the Game Menu frame for two buttons
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + configButton:GetHeight() + dashButton:GetHeight() + 2)
            
            -- Dashboard button click handler
            dashButton:SetScript("OnClick", function()
                HideUIPanel(GameMenuFrame)
                if self.Dashboard then
                    self.Dashboard:Show()
                end
            end)
        else
            -- Adjust other buttons
            GameMenuButtonLogout:SetPoint("TOP", configButton, "BOTTOM", 0, -16)
            
            -- Adjust the height of the Game Menu frame for one button
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + configButton:GetHeight() + 1)
        end
        
        -- Config button click handler
        configButton:SetScript("OnClick", function()
            HideUIPanel(GameMenuFrame)
            -- Use ConfigUI if available
            if self.ConfigUI and self.ConfigUI.enabled then
                InterfaceOptionsFrame_OpenToCategory(self.ConfigUI.panel)
                InterfaceOptionsFrame_OpenToCategory(self.ConfigUI.panel)
            else
                InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
                InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            end
        end)
    end
end

-- Print a message with addon prefix
function VUI:Print(msg)
    print("|cff1784d1" .. VUI.name .. "|r: " .. tostring(msg))
end
