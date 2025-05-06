-- VUI Integration
-- This file ensures that all modules and systems properly integrate with each other
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create integrations namespace
VUI.Integration = {}

-- Keeps track of integration statuses
VUI.Integration.status = {}

-- Function to initialize all integrations
function VUI.Integration:Initialize()
    -- Register for initialization completion event
    VUI:RegisterEvent("PLAYER_LOGIN", function()
        self:ConnectSystems()
    end)
    
    -- Begin dependency tracking
    self:RegisterDependencies()
    
    -- Register module connections
    VUI:RegisterEvent("ADDON_LOADED", function()
        self:ConnectModules()
    end)
    
    -- Print status when everything is ready
    VUI:ScheduleTimer(function()
        self:PrintStatus()
    end, 2)
end

-- Define all system dependencies
function VUI.Integration:RegisterDependencies()
    self.dependencies = {
        UI = {"media"},
        Widgets = {"UI"},
        modules = {"UI", "Widgets", "media", "utils"}
    }
    
    -- Record initial status
    for system, deps in pairs(self.dependencies) do
        self.status[system] = {
            connected = false,
            dependencies = deps,
            dependenciesMet = false
        }
    end
end

-- Connect core systems together
function VUI.Integration:ConnectSystems()
    -- Connect media to UI
    if VUI.UI and VUI.media then
        -- Register connection function if one exists
        if VUI.RegisterMediaWithUI then
            VUI:RegisterMediaWithUI()
        end
        
        self.status.UI.dependenciesMet = true
        self.status.UI.connected = true
        
        VUI:Print("Media system connected to UI Framework")
    end
    
    -- Connect Widgets to UI
    if VUI.UI and VUI.Widgets then
        -- Connect colors
        VUI.Widgets.GetThemeColors = function()
            return VUI.UI:GetThemeColors()
        end
        
        -- Connect font functions
        VUI.Widgets.GetFont = function(self, fontName)
            return VUI:GetFont(fontName)
        end
        
        self.status.Widgets.dependenciesMet = true
        self.status.Widgets.connected = true
        
        VUI:Print("Widgets connected to UI Framework")
    end
end

-- Connect all modules to the right systems
function VUI.Integration:ConnectModules()
    -- Only proceed if dependencies are met
    if not self.status.modules.dependenciesMet then
        for _, dep in ipairs(self.dependencies.modules) do
            if not VUI[dep] then
                return
            end
        end
        
        -- If we get here, all dependencies are available
        self.status.modules.dependenciesMet = true
    end
    
    -- Connect each module to the frameworks
    for name, module in pairs(VUI.modules) do
        if not module.uiConnected then
            -- Connect UI framework to module
            if module.ConnectUI then
                module:ConnectUI(VUI.UI)
            end
            
            -- Connect widget framework to module
            if module.ConnectWidgets then
                module:ConnectWidgets(VUI.Widgets)
            end
            
            -- Connect media system to module
            if module.ConnectMedia then
                module:ConnectMedia(VUI.media)
            end
            
            -- Mark as connected
            module.uiConnected = true
            
            -- Debug print
            VUI:Print("Module '"..name.."' connected to frameworks")
        end
    end
    
    -- Only mark as connected once
    if not self.status.modules.connected then
        self.status.modules.connected = true
    end
end

-- Print integration status
function VUI.Integration:PrintStatus()
    local allConnected = true
    local messages = {
        "VUI Integration Status:"
    }
    
    -- Check status of all systems
    for system, status in pairs(self.status) do
        local statusText = status.connected and "|cFF00FF00Connected|r" or "|cFFFF0000Not Connected|r"
        local depsText = status.dependenciesMet and "|cFF00FF00Met|r" or "|cFFFF0000Not Met|r"
        
        table.insert(messages, "• " .. system .. ": " .. statusText .. " (Dependencies: " .. depsText .. ")")
        
        if not status.connected then
            allConnected = false
        end
    end
    
    -- Add summary
    if allConnected then
        table.insert(messages, "\n|cFF00FF00All systems successfully integrated!|r")
    else
        table.insert(messages, "\n|cFFFF0000Some systems failed to connect properly.|r")
    end
    
    -- Print all messages
    for _, msg in ipairs(messages) do
        VUI:Print(msg)
    end
end

-- Function to check if a specific system is properly connected
function VUI.Integration:IsConnected(system)
    if not self.status[system] then
        return false
    end
    
    return self.status[system].connected
end

-- Function to ensure a component exists and is ready
function VUI.Integration:EnsureComponent(component)
    if not VUI[component] then
        VUI:Print("Warning: Component '" .. component .. "' is missing")
        return false
    end
    
    return true
end

-- Handle integration of module UI across themes
function VUI.Integration:ApplyThemeToModules()
    -- Only process if UI and modules are connected
    if not self:IsConnected("UI") or not self:IsConnected("modules") then
        return
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeData = VUI.media.themes[theme]
    
    -- Apply theme to each module
    for name, module in pairs(VUI.modules) do
        if VUI:IsModuleEnabled(name) and module.ApplyTheme then
            module:ApplyTheme(theme, themeData)
        end
    end
end

-- Add theme change handler
function VUI.Integration:RegisterThemeChangeHandler()
    local originalUpdateUI = VUI.UpdateUI
    
    -- Override UpdateUI to also handle module themes
    VUI.UpdateUI = function(self)
        -- Call the original function
        originalUpdateUI(self)
        
        -- Apply theme to modules
        VUI.Integration:ApplyThemeToModules()
    end
end