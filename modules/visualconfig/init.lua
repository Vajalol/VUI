-- VUI Visual Configuration Module - Initialization
local _, VUI = ...

-- Create the module using the module API
local VisualConfig = VUI.ModuleAPI:CreateModule("visualconfig")

-- Get configuration options for main UI integration
function VisualConfig:GetConfig()
    local config = {
        name = "Visual Configuration",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Visual Configuration",
                desc = "Enable or disable the Visual Configuration module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            showModuleIcons = {
                type = "toggle",
                name = "Show Module Icons",
                desc = "Show icons in the module list",
                get = function() return self.db.general.showModuleIcons end,
                set = function(_, value) 
                    self.db.general.showModuleIcons = value
                    self:UpdateUI()
                end,
                order = 2
            },
            enablePreview = {
                type = "toggle",
                name = "Enable Preview",
                desc = "Show previews when changing settings",
                get = function() return self.db.general.enablePreview end,
                set = function(_, value) 
                    self.db.general.enablePreview = value
                    self:UpdateUI()
                end,
                order = 3
            },
            animateChanges = {
                type = "toggle",
                name = "Animate Changes",
                desc = "Animate UI changes for a smoother experience",
                get = function() return self.db.general.animateChanges end,
                set = function(_, value) 
                    self.db.general.animateChanges = value
                    self:UpdateAnimationSettings()
                end,
                order = 4
            },
            layoutEditor = {
                type = "toggle",
                name = "Enable Layout Editor",
                desc = "Enable the advanced layout editor for UI customization",
                get = function() return self.db.layoutEditor.enabled end,
                set = function(_, value) 
                    self.db.layoutEditor.enabled = value
                    self:UpdateLayoutEditor()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("visualconfig", VisualConfig:GetConfig())

-- Set up module defaults
local defaults = {
    enabled = true,
    
    -- General Settings
    general = {
        showModuleIcons = true,        -- Show icons in the module list
        enableTooltips = true,         -- Show enhanced tooltips
        enablePreview = true,          -- Show previews when possible
        enableDragDropUI = true,       -- Enable drag and drop in the UI
        saveWindowPosition = true,     -- Save window position between sessions
        enhancedMenus = true,          -- Use enhanced dropdown menus
        animateChanges = true,         -- Animate UI changes
        useVUITheme = true,            -- Use VUI theme for the config window
        enableIntroTutorial = true,    -- Show tutorial for first-time users
    },
    
    -- Layout Editor Settings
    layoutEditor = {
        enabled = true,
        showGrid = true,               -- Show a grid in the layout editor
        gridSize = 10,                 -- Grid size in pixels
        snapToGrid = true,             -- Snap elements to grid when moving
        highlightGroups = true,        -- Highlight related UI elements
        showDimensions = true,         -- Show dimensions when resizing elements
        showDragHandles = true,        -- Show drag handles on elements
        enableMultiSelect = true,      -- Allow selecting multiple elements
        showAlignmentGuides = true,    -- Show alignment guides when moving elements
        saveBackup = true,             -- Create a backup before editing layout
        undoLevels = 20,               -- Number of undo steps to save
    },
    
    -- Profile Display Settings
    profiles = {
        showProfilePreview = true,     -- Show preview when selecting a profile
        showDifferences = true,        -- Highlight differences when comparing profiles
        visualProfileComparison = true, -- Use visual comparison for profiles
        categorizeProfiles = true,     -- Categorize profiles by type
    },
    
    -- Color Picker Settings
    colorPicker = {
        enhancedColorPicker = true,    -- Use enhanced color picker
        showColorHistory = true,       -- Show recently used colors
        showPresets = true,            -- Show preset colors
        showClassColors = true,        -- Show class colors
        livePreview = true,            -- Update UI in real-time during color picking
    },
    
    -- Module Configuration Settings
    moduleConfig = {
        showModuleStatus = true,       -- Show module status indicators
        groupRelatedOptions = true,    -- Group related options together
        searchEnabled = true,          -- Enable search in config panels
        showRecentOptions = true,      -- Show recently changed options
        expandedCategories = {},       -- Track which categories are expanded
        lastVisitedModule = nil,       -- Last visited module
    },
    
    -- Interface Scaling Settings
    scaling = {
        enableScaling = true,          -- Enable UI scaling controls
        showScalePreview = true,       -- Show previews when scaling
        rememberScalePerModule = true, -- Remember scale settings per module
        customScaleFactors = {},       -- Custom scale factors for UI elements
    },
    
    -- Visual Presets Settings
    presets = {
        enabled = true,
        savedPresets = {},             -- Saved UI presets
        showPresetPreviews = true,     -- Show visual previews of presets
        allowSharing = true,           -- Allow sharing presets
    },
}

-- Initialize module settings
VisualConfig.settings = VUI.ModuleAPI:InitializeModuleSettings("visualconfig", defaults)

-- Register module configuration
local config = {
    type = "group",
    name = "Visual Configuration",
    desc = "Enhanced visual configuration settings",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable visual configuration module",
            order = 1,
            get = function() return VUI:IsModuleEnabled("visualconfig") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("visualconfig")
                else
                    VUI:DisableModule("visualconfig")
                end
            end,
        },
        generalHeader = {
            type = "header",
            name = "General Settings",
            order = 2,
        },
        showModuleIcons = {
            type = "toggle",
            name = "Show Module Icons",
            desc = "Show icons in the module list",
            order = 3,
            get = function() return VisualConfig.settings.general.showModuleIcons end,
            set = function(_, value) 
                VisualConfig.settings.general.showModuleIcons = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        enableTooltips = {
            type = "toggle",
            name = "Enhanced Tooltips",
            desc = "Show enhanced tooltips with more information",
            order = 4,
            get = function() return VisualConfig.settings.general.enableTooltips end,
            set = function(_, value) 
                VisualConfig.settings.general.enableTooltips = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        enablePreview = {
            type = "toggle",
            name = "Enable Preview",
            desc = "Show live previews when changing settings",
            order = 5,
            get = function() return VisualConfig.settings.general.enablePreview end,
            set = function(_, value) 
                VisualConfig.settings.general.enablePreview = value 
            end,
        },
        enableDragDropUI = {
            type = "toggle",
            name = "Enable Drag & Drop",
            desc = "Enable drag and drop functionality in the UI",
            order = 6,
            get = function() return VisualConfig.settings.general.enableDragDropUI end,
            set = function(_, value) 
                VisualConfig.settings.general.enableDragDropUI = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        saveWindowPosition = {
            type = "toggle",
            name = "Save Window Position",
            desc = "Save configuration window position between sessions",
            order = 7,
            get = function() return VisualConfig.settings.general.saveWindowPosition end,
            set = function(_, value) 
                VisualConfig.settings.general.saveWindowPosition = value 
            end,
        },
        enhancedMenus = {
            type = "toggle",
            name = "Enhanced Menus",
            desc = "Use enhanced dropdown menus with icons and descriptions",
            order = 8,
            get = function() return VisualConfig.settings.general.enhancedMenus end,
            set = function(_, value) 
                VisualConfig.settings.general.enhancedMenus = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        animateChanges = {
            type = "toggle",
            name = "Animate Changes",
            desc = "Animate UI changes for a smoother experience",
            order = 9,
            get = function() return VisualConfig.settings.general.animateChanges end,
            set = function(_, value) 
                VisualConfig.settings.general.animateChanges = value 
            end,
        },
        useVUITheme = {
            type = "toggle",
            name = "Use VUI Theme",
            desc = "Use VUI theme for the configuration window",
            order = 10,
            get = function() return VisualConfig.settings.general.useVUITheme end,
            set = function(_, value) 
                VisualConfig.settings.general.useVUITheme = value 
                VisualConfig:ApplyTheme()
            end,
        },
        layoutEditorHeader = {
            type = "header",
            name = "Layout Editor",
            order = 11,
        },
        layoutEditorEnabled = {
            type = "toggle",
            name = "Enable Layout Editor",
            desc = "Enable the visual layout editor",
            order = 12,
            get = function() return VisualConfig.settings.layoutEditor.enabled end,
            set = function(_, value) 
                VisualConfig.settings.layoutEditor.enabled = value 
            end,
        },
        showGrid = {
            type = "toggle",
            name = "Show Grid",
            desc = "Show a grid in the layout editor",
            order = 13,
            get = function() return VisualConfig.settings.layoutEditor.showGrid end,
            set = function(_, value) 
                VisualConfig.settings.layoutEditor.showGrid = value 
                if VisualConfig.layoutEditor then
                    VisualConfig.layoutEditor:UpdateGrid()
                end
            end,
            disabled = function() return not VisualConfig.settings.layoutEditor.enabled end,
        },
        gridSize = {
            type = "range",
            name = "Grid Size",
            desc = "Set the size of the grid in pixels",
            min = 5,
            max = 50,
            step = 5,
            order = 14,
            get = function() return VisualConfig.settings.layoutEditor.gridSize end,
            set = function(_, value) 
                VisualConfig.settings.layoutEditor.gridSize = value 
                if VisualConfig.layoutEditor then
                    VisualConfig.layoutEditor:UpdateGrid()
                end
            end,
            disabled = function() return not (VisualConfig.settings.layoutEditor.enabled and 
                                             VisualConfig.settings.layoutEditor.showGrid) end,
        },
        snapToGrid = {
            type = "toggle",
            name = "Snap to Grid",
            desc = "Snap elements to grid when moving",
            order = 15,
            get = function() return VisualConfig.settings.layoutEditor.snapToGrid end,
            set = function(_, value) 
                VisualConfig.settings.layoutEditor.snapToGrid = value 
            end,
            disabled = function() return not (VisualConfig.settings.layoutEditor.enabled and 
                                             VisualConfig.settings.layoutEditor.showGrid) end,
        },
        showDimensions = {
            type = "toggle",
            name = "Show Dimensions",
            desc = "Show dimensions when resizing elements",
            order = 16,
            get = function() return VisualConfig.settings.layoutEditor.showDimensions end,
            set = function(_, value) 
                VisualConfig.settings.layoutEditor.showDimensions = value 
            end,
            disabled = function() return not VisualConfig.settings.layoutEditor.enabled end,
        },
        colorPickerHeader = {
            type = "header",
            name = "Color Picker",
            order = 17,
        },
        enhancedColorPicker = {
            type = "toggle",
            name = "Enhanced Color Picker",
            desc = "Use the enhanced color picker with more features",
            order = 18,
            get = function() return VisualConfig.settings.colorPicker.enhancedColorPicker end,
            set = function(_, value) 
                VisualConfig.settings.colorPicker.enhancedColorPicker = value 
            end,
        },
        showColorHistory = {
            type = "toggle",
            name = "Show Color History",
            desc = "Show recently used colors in the color picker",
            order = 19,
            get = function() return VisualConfig.settings.colorPicker.showColorHistory end,
            set = function(_, value) 
                VisualConfig.settings.colorPicker.showColorHistory = value 
            end,
            disabled = function() return not VisualConfig.settings.colorPicker.enhancedColorPicker end,
        },
        showPresets = {
            type = "toggle",
            name = "Show Presets",
            desc = "Show preset colors in the color picker",
            order = 20,
            get = function() return VisualConfig.settings.colorPicker.showPresets end,
            set = function(_, value) 
                VisualConfig.settings.colorPicker.showPresets = value 
            end,
            disabled = function() return not VisualConfig.settings.colorPicker.enhancedColorPicker end,
        },
        moduleConfigHeader = {
            type = "header",
            name = "Module Configuration",
            order = 21,
        },
        showModuleStatus = {
            type = "toggle",
            name = "Show Module Status",
            desc = "Show module status indicators in the config panel",
            order = 22,
            get = function() return VisualConfig.settings.moduleConfig.showModuleStatus end,
            set = function(_, value) 
                VisualConfig.settings.moduleConfig.showModuleStatus = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        groupRelatedOptions = {
            type = "toggle",
            name = "Group Related Options",
            desc = "Group related options together in the config panel",
            order = 23,
            get = function() return VisualConfig.settings.moduleConfig.groupRelatedOptions end,
            set = function(_, value) 
                VisualConfig.settings.moduleConfig.groupRelatedOptions = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        searchEnabled = {
            type = "toggle",
            name = "Enable Search",
            desc = "Enable search functionality in config panels",
            order = 24,
            get = function() return VisualConfig.settings.moduleConfig.searchEnabled end,
            set = function(_, value) 
                VisualConfig.settings.moduleConfig.searchEnabled = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        showRecentOptions = {
            type = "toggle",
            name = "Show Recent Options",
            desc = "Show recently changed options at the top",
            order = 25,
            get = function() return VisualConfig.settings.moduleConfig.showRecentOptions end,
            set = function(_, value) 
                VisualConfig.settings.moduleConfig.showRecentOptions = value 
                VisualConfig:RefreshConfigUI()
            end,
        },
        presetsHeader = {
            type = "header",
            name = "Visual Presets",
            order = 26,
        },
        presetsEnabled = {
            type = "toggle",
            name = "Enable Presets",
            desc = "Enable saving and loading visual presets",
            order = 27,
            get = function() return VisualConfig.settings.presets.enabled end,
            set = function(_, value) 
                VisualConfig.settings.presets.enabled = value 
            end,
        },
        showPresetPreviews = {
            type = "toggle",
            name = "Show Preset Previews",
            desc = "Show visual previews of presets",
            order = 28,
            get = function() return VisualConfig.settings.presets.showPresetPreviews end,
            set = function(_, value) 
                VisualConfig.settings.presets.showPresetPreviews = value 
            end,
            disabled = function() return not VisualConfig.settings.presets.enabled end,
        },
        allowSharing = {
            type = "toggle",
            name = "Allow Sharing",
            desc = "Allow sharing presets with other players",
            order = 29,
            get = function() return VisualConfig.settings.presets.allowSharing end,
            set = function(_, value) 
                VisualConfig.settings.presets.allowSharing = value 
            end,
            disabled = function() return not VisualConfig.settings.presets.enabled end,
        },
        actionsHeader = {
            type = "header",
            name = "Actions",
            order = 30,
        },
        openLayoutEditor = {
            type = "execute",
            name = "Open Layout Editor",
            desc = "Open the visual layout editor",
            order = 31,
            func = function()
                VisualConfig:OpenLayoutEditor()
            end,
            disabled = function() return not VisualConfig.settings.layoutEditor.enabled end,
        },
        createPresetFromCurrent = {
            type = "execute",
            name = "Create Preset from Current Settings",
            desc = "Create a new preset from your current settings",
            order = 32,
            func = function()
                VisualConfig:CreatePresetFromCurrent()
            end,
            disabled = function() return not VisualConfig.settings.presets.enabled end,
        },
        resetToDefaults = {
            type = "execute",
            name = "Reset to Defaults",
            desc = "Reset all visual configuration settings to defaults",
            confirm = true,
            order = 33,
            func = function()
                VisualConfig:ResetToDefaults()
            end,
        },
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("visualconfig", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("visualconfig", "vuivisual", function(input)
    if not input or input:trim() == "" then
        -- Show configuration panel
        VUI.ModuleAPI:OpenModuleConfig("visualconfig")
    elseif input:trim() == "editor" or input:trim() == "layout" then
        -- Open the layout editor
        VisualConfig:OpenLayoutEditor()
    elseif input:trim() == "presets" then
        -- Open the presets manager
        VisualConfig:OpenPresetsManager()
    elseif input:trim() == "theme" then
        -- Open the theme editor
        VisualConfig:OpenThemeEditor()
    elseif input:trim() == "colors" then
        -- Open the color picker
        VisualConfig:OpenColorPicker()
    elseif input:trim() == "reset" then
        -- Reset to defaults
        VisualConfig:ResetToDefaults()
    elseif input:trim() == "help" then
        -- Show help
        VUI:Print("Visual Configuration Commands:")
        VUI:Print("  /vuivisual - Open configuration panel")
        VUI:Print("  /vuivisual editor - Open the layout editor")
        VUI:Print("  /vuivisual presets - Open the presets manager")
        VUI:Print("  /vuivisual theme - Open the theme editor")
        VUI:Print("  /vuivisual colors - Open the color picker")
        VUI:Print("  /vuivisual reset - Reset to defaults")
        VUI:Print("  /vuivisual help - Show this help")
    else
        -- Unknown command, show help
        VUI:Print("Unknown command: " .. input)
        VUI:Print("Type /vuivisual help for a list of commands.")
    end
end)

-- Initialize module
function VisualConfig:Initialize()
    -- Register with VUI
    VUI:Print("Visual Configuration module initialized")
    
    -- Set up Ace3 config hooks
    self:SetupConfigHooks()
    
    -- Initialize components
    self:InitLayoutEditor()
    self:InitPresetsManager()
    self:InitThemeEditor()
    self:InitColorPicker()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    
    -- Register callbacks
    VUI.ConfigCallbacks = VUI.ConfigCallbacks or {}
    VUI.ConfigCallbacks.PreShow = VUI.ConfigCallbacks.PreShow or {}
    VUI.ConfigCallbacks.PreShow.VisualConfig = function() self:OnConfigShow() end
    
    VUI.ConfigCallbacks.PostShow = VUI.ConfigCallbacks.PostShow or {}
    VUI.ConfigCallbacks.PostShow.VisualConfig = function() self:OnConfigShown() end
    
    VUI.ConfigCallbacks.PreHide = VUI.ConfigCallbacks.PreHide or {}
    VUI.ConfigCallbacks.PreHide.VisualConfig = function() self:OnConfigHide() end
    
    -- Storage for module data
    self.moduleData = {}
    
    -- Storage for color history
    self.colorHistory = {}
    
    -- Track UI modification state
    self.isModifyingUI = false
    
    -- Track recently changed options
    self.recentOptions = {}
    
    -- Track window positions
    self.windowPositions = {}
end

-- Enable module
function VisualConfig:Enable()
    self.enabled = true
    
    -- Apply theme
    self:ApplyTheme()
    
    VUI:Print("Visual Configuration module enabled")
end

-- Disable module
function VisualConfig:Disable()
    self.enabled = false
    
    -- Remove enhancements
    self:RemoveEnhancements()
    
    VUI:Print("Visual Configuration module disabled")
end

-- Event registration helper
function VisualConfig:RegisterEvent(event, method)
    if type(method) == "string" and self[method] then
        method = self[method]
    end
    
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    self.eventFrame:RegisterEvent(event)
    self[event] = method
end

-- Set up Ace3 config hooks
function VisualConfig:SetupConfigHooks()
    -- This function will be implemented in core.lua
end

-- Initialize the layout editor
function VisualConfig:InitLayoutEditor()
    -- This function will be implemented in core.lua
end

-- Initialize the presets manager
function VisualConfig:InitPresetsManager()
    -- This function will be implemented in core.lua
end

-- Initialize the theme editor
function VisualConfig:InitThemeEditor()
    -- This function will be implemented in core.lua
end

-- Initialize the color picker
function VisualConfig:InitColorPicker()
    -- This function will be implemented in core.lua
end

-- Open the layout editor
function VisualConfig:OpenLayoutEditor()
    if not self.enabled or not self.settings.layoutEditor.enabled then
        VUI:Print("Layout Editor is not enabled.")
        return
    end
    
    -- This function will be implemented in core.lua
    VUI:Print("Opening Layout Editor...")
end

-- Open the presets manager
function VisualConfig:OpenPresetsManager()
    if not self.enabled or not self.settings.presets.enabled then
        VUI:Print("Presets are not enabled.")
        return
    end
    
    -- This function will be implemented in core.lua
    VUI:Print("Opening Presets Manager...")
end

-- Open the theme editor
function VisualConfig:OpenThemeEditor()
    if not self.enabled then
        VUI:Print("Visual Configuration module is not enabled.")
        return
    end
    
    -- This function will be implemented in core.lua
    VUI:Print("Opening Theme Editor...")
end

-- Open the color picker
function VisualConfig:OpenColorPicker()
    if not self.enabled then
        VUI:Print("Visual Configuration module is not enabled.")
        return
    end
    
    -- This function will be implemented in core.lua
    VUI:Print("Opening Color Picker...")
end

-- Reset to defaults
function VisualConfig:ResetToDefaults()
    if not self.enabled then
        VUI:Print("Visual Configuration module is not enabled.")
        return
    end
    
    -- Save window positions if enabled
    if self.settings.general.saveWindowPosition then
        self:SaveWindowPositions()
    end
    
    -- Reset settings
    self.settings = VUI.ModuleAPI:InitializeModuleSettings("visualconfig", defaults)
    
    -- Restore window positions if enabled
    if self.settings.general.saveWindowPosition then
        self:RestoreWindowPositions()
    end
    
    -- Refresh UI
    self:RefreshConfigUI()
    
    VUI:Print("Visual Configuration settings have been reset to defaults.")
end

-- Create a preset from current settings
function VisualConfig:CreatePresetFromCurrent()
    if not self.enabled or not self.settings.presets.enabled then
        VUI:Print("Presets are not enabled.")
        return
    end
    
    -- This function will be implemented in core.lua
    VUI:Print("Creating preset from current settings...")
end

-- Apply theme to configuration UI
function VisualConfig:ApplyTheme()
    if not self.enabled then return end
    
    -- Use ThemeIntegration if available, otherwise fall back to old method
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme()
    else
        -- This function will be implemented in core.lua
    end
end

-- Remove enhancements from configuration UI
function VisualConfig:RemoveEnhancements()
    -- This function will be implemented in core.lua
end

-- Refresh configuration UI
function VisualConfig:RefreshConfigUI()
    if not self.enabled then return end
    
    -- This function will be implemented in core.lua
end

-- Event handlers
function VisualConfig:OnPlayerEnteringWorld()
    if not self.enabled then return end
    
    -- Initialize ThemeIntegration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    else
        -- Apply theme using legacy method if needed
        if self.settings.general.useVUITheme then
            self:ApplyTheme()
        end
    end
    
    -- Restore window positions if needed
    if self.settings.general.saveWindowPosition then
        self:RestoreWindowPositions()
    end
    
    -- Show intro tutorial if enabled and this is the first time
    if self.settings.general.enableIntroTutorial and not self.introDone then
        self:ShowIntroTutorial()
        self.introDone = true
    end
end

-- Save window positions
function VisualConfig:SaveWindowPositions()
    -- This function will be implemented in core.lua
end

-- Restore window positions
function VisualConfig:RestoreWindowPositions()
    -- This function will be implemented in core.lua
end

-- Show intro tutorial
function VisualConfig:ShowIntroTutorial()
    -- This function will be implemented in core.lua
end

-- Configuration UI callbacks
function VisualConfig:OnConfigShow()
    -- This function will be implemented in core.lua
end

function VisualConfig:OnConfigShown()
    -- This function will be implemented in core.lua
end

function VisualConfig:OnConfigHide()
    -- This function will be implemented in core.lua
end

-- Helper to modify Ace3 config table
function VisualConfig:EnhanceConfigTable(configTable)
    -- This function will be implemented in core.lua and will enhance
    -- the Ace3 config table with icons, better organization, etc.
end

-- Register the module with VUI
VUI.visualconfig = VisualConfig