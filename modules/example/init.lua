-- VUI Example Module - Initialization
-- This module demonstrates proper integration with the VUI framework
local _, VUI = ...

-- Create the example module using the module API
local Example = VUI.ModuleAPI:CreateModule("example")

-- Set up module defaults
local defaults = {
    enabled = true,
    scale = 1.0,
    position = {"CENTER", 0, 0},
    showTitle = true,
    textColor = {r = 1, g = 1, b = 1, a = 1},
    backgroundColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
}

-- Initialize module settings
Example.settings = VUI.ModuleAPI:InitializeModuleSettings("example", defaults)

-- Register module configuration
local config = {
    type = "group",
    name = "Example Module",
    desc = "Configuration for the Example module",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the Example module",
            order = 1,
            get = function() return VUI:IsModuleEnabled("example") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("example")
                else
                    VUI:DisableModule("example")
                end
            end,
        },
        scale = {
            type = "range",
            name = "Scale",
            desc = "Adjust the scale of the Example module UI",
            min = 0.5,
            max = 2.0,
            step = 0.1,
            order = 2,
            get = function() return Example.settings.scale end,
            set = function(_, value)
                Example.settings.scale = value
                if Example.frame then
                    Example.frame:SetScale(value)
                end
            end,
        },
        showTitle = {
            type = "toggle",
            name = "Show Title",
            desc = "Show or hide the title bar",
            order = 3,
            get = function() return Example.settings.showTitle end,
            set = function(_, value)
                Example.settings.showTitle = value
                Example:UpdateUI()
            end,
        },
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("example", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("example", "vuiexample", function(input)
    if input and input:trim() == "show" then
        Example:Show()
    elseif input and input:trim() == "hide" then
        Example:Hide()
    elseif input and input:trim() == "toggle" then
        Example:Toggle()
    elseif input and input:trim() == "reset" then
        Example:ResetPosition()
    else
        VUI:Print("Example Module Commands:")
        VUI:Print("  /vuiexample show - Shows the module")
        VUI:Print("  /vuiexample hide - Hides the module")
        VUI:Print("  /vuiexample toggle - Toggles visibility")
        VUI:Print("  /vuiexample reset - Resets position")
    end
end)

-- Initialize module
function Example:Initialize()
    -- Register with VUI
    VUI:Print("Example module initialized")
    
    -- Register for UI integration when the UI is loaded
    VUI.ModuleAPI:EnableModuleUI("example", function(module)
        module:CreateUI()
    end)
end

-- Enable module
function Example:Enable()
    self.enabled = true
    
    -- Create UI if it doesn't exist
    if not self.frame and self.CreateUI then
        self:CreateUI()
    end
    
    -- Show the UI
    if self.frame then
        self.frame:Show()
    end
    
    VUI:Print("Example module enabled")
end

-- Disable module
function Example:Disable()
    self.enabled = false
    
    -- Hide the UI
    if self.frame then
        self.frame:Hide()
    end
    
    VUI:Print("Example module disabled")
end

-- Register the module with VUI
VUI.example = Example