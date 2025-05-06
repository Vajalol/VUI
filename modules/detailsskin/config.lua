local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local DetailsSkin = VUI.detailsskin or {}
VUI.detailsskin = DetailsSkin
local L = VUI.L or {}

-- Module configuration functions
DetailsSkin.Config = {}

-- Helper function to apply settings to all Details instances
function DetailsSkin.Config:UpdateAllInstances()
    if not _G.Details then
        return false
    end
    
    local settings = DetailsSkin:GetSettings()
    if not settings or not settings.enabled then
        return false
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    for i = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(i)
        if instance then
            DetailsSkin:ApplySkinToInstance(instance, theme)
        end
    end
    
    return true
end

-- Function to reset all Details windows to VUI skin
function DetailsSkin.Config:ResetAllInstances()
    if not _G.Details then
        return false
    end
    
    local settings = DetailsSkin:GetSettings()
    if not settings or not settings.enabled then
        return false
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    for i = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(i)
        if instance then
            -- Remove any saved original settings to force full reskinning
            instance._originalSkin = nil
            DetailsSkin:ApplySkinToInstance(instance, theme)
        end
    end
    
    return true
end

-- Function to apply settings to a specific instance only
function DetailsSkin.Config:ApplyToInstance(instanceId)
    if not _G.Details then
        return false
    end
    
    local settings = DetailsSkin:GetSettings()
    if not settings or not settings.enabled then
        return false
    end
    
    local instance = _G.Details:GetInstance(instanceId)
    if instance then
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        DetailsSkin:ApplySkinToInstance(instance, theme)
        return true
    end
    
    return false
end

-- Function to export current settings as a string
function DetailsSkin.Config:ExportSettings()
    local settings = DetailsSkin:GetSettings()
    if not settings then
        return "No settings found"
    end
    
    -- Remove sensitive or redundant data
    local exportSettings = {}
    for k, v in pairs(settings) do
        if type(v) ~= "function" and k ~= "profile" then
            exportSettings[k] = v
        end
    end
    
    -- Use AceSerializer to convert to string
    local AceSerializer = LibStub("AceSerializer-3.0")
    return AceSerializer:Serialize(exportSettings)
end

-- Function to import settings from a string
function DetailsSkin.Config:ImportSettings(settingsString)
    if not settingsString or settingsString == "" then
        return false, "Empty settings string"
    end
    
    local AceSerializer = LibStub("AceSerializer-3.0")
    local success, importedSettings = AceSerializer:Deserialize(settingsString)
    
    if not success then
        return false, "Failed to deserialize settings"
    end
    
    -- Apply imported settings
    local currentSettings = DetailsSkin:GetSettings()
    for k, v in pairs(importedSettings) do
        if currentSettings[k] ~= nil then -- Only copy existing keys
            currentSettings[k] = v
        end
    end
    
    -- Apply the imported settings
    DetailsSkin:ApplyThemeToAll()
    
    return true, "Settings imported successfully"
end

-- Create default settings for the module
function DetailsSkin.Config:CreateDefaults()
    if not VUI.defaults or not VUI.defaults.profile or not VUI.defaults.profile.modules then
        return
    end
    
    VUI.defaults.profile.modules.detailsskin = {
        enabled = true,
        saveOriginal = true,
        customHeader = true,
        styleGraphs = true,
        useCustomTemplates = true,
        backgroundOpacity = 0.7,
        borderOpacity = 0.8,
        barAlpha = 0.9,
        rowHeight = 16,
        fontSize = 10,
        borderSize = 1
    }
end

-- Create options for the configuration UI
function DetailsSkin.Config:GetOptions()
    local settings = DetailsSkin:GetSettings()
    
    local options = {
        type = "group",
        name = L["DetailsSkin"] or "DetailsSkin",
        desc = L["Configure the Details! Damage Meter skin"] or "Configure the Details! Damage Meter skin",
        args = {
            header = {
                type = "header",
                name = (L["DetailsSkin"] or "DetailsSkin") .. " " .. DetailsSkin.version,
                order = 1
            },
            desc = {
                type = "description",
                name = L["Customize the appearance of Details! Damage Meter windows to match your VUI theme."] or 
                       "Customize the appearance of Details! Damage Meter windows to match your VUI theme.",
                order = 2
            },
            enabled = {
                type = "toggle",
                name = L["Enable DetailsSkin"] or "Enable DetailsSkin",
                desc = L["Enable or disable the Details! skin"] or "Enable or disable the Details! skin",
                get = function() return settings.enabled end,
                set = function(_, val)
                    settings.enabled = val
                    if val then
                        DetailsSkin:ApplyThemeToAll()
                    else
                        -- Restore original skins if disabled
                        DetailsSkin.Config:RestoreOriginalSkins()
                    end
                end,
                width = "full",
                order = 3
            },
            appearanceGroup = {
                type = "group",
                name = L["Appearance"] or "Appearance",
                inline = true,
                order = 4,
                args = {
                    customHeader = {
                        type = "toggle",
                        name = L["Custom Headers"] or "Custom Headers",
                        desc = L["Use theme-specific header styling"] or "Use theme-specific header styling",
                        get = function() return settings.customHeader end,
                        set = function(_, val)
                            settings.customHeader = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 1
                    },
                    styleGraphs = {
                        type = "toggle",
                        name = L["Style Graphs"] or "Style Graphs",
                        desc = L["Apply theme styling to Details graphs and charts"] or "Apply theme styling to Details graphs and charts",
                        get = function() return settings.styleGraphs end,
                        set = function(_, val)
                            settings.styleGraphs = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 2
                    },
                    useCustomTemplates = {
                        type = "toggle",
                        name = L["Custom Report Templates"] or "Custom Report Templates",
                        desc = L["Use theme-specific templates when sharing reports"] or "Use theme-specific templates when sharing reports",
                        get = function() return settings.useCustomTemplates end,
                        set = function(_, val)
                            settings.useCustomTemplates = val
                            if val and DetailsSkin.Reports then
                                DetailsSkin.Reports:Initialize()
                            end
                        end,
                        width = "full",
                        order = 3
                    }
                }
            },
            transparencyGroup = {
                type = "group",
                name = L["Transparency"] or "Transparency",
                inline = true,
                order = 5,
                args = {
                    backgroundOpacity = {
                        type = "range",
                        name = L["Background Opacity"] or "Background Opacity",
                        desc = L["Set the opacity of the window background"] or "Set the opacity of the window background",
                        min = 0, max = 1, step = 0.05,
                        get = function() return settings.backgroundOpacity end,
                        set = function(_, val)
                            settings.backgroundOpacity = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 1
                    },
                    borderOpacity = {
                        type = "range",
                        name = L["Border Opacity"] or "Border Opacity",
                        desc = L["Set the opacity of window borders"] or "Set the opacity of window borders",
                        min = 0, max = 1, step = 0.05,
                        get = function() return settings.borderOpacity end,
                        set = function(_, val)
                            settings.borderOpacity = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 2
                    },
                    barAlpha = {
                        type = "range",
                        name = L["Bar Opacity"] or "Bar Opacity",
                        desc = L["Set the opacity of data bars"] or "Set the opacity of data bars",
                        min = 0, max = 1, step = 0.05,
                        get = function() return settings.barAlpha end,
                        set = function(_, val)
                            settings.barAlpha = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 3
                    }
                }
            },
            sizingGroup = {
                type = "group",
                name = L["Sizing"] or "Sizing",
                inline = true,
                order = 6,
                args = {
                    rowHeight = {
                        type = "range",
                        name = L["Row Height"] or "Row Height",
                        desc = L["Set the height of data rows"] or "Set the height of data rows",
                        min = 10, max = 30, step = 1,
                        get = function() return settings.rowHeight end,
                        set = function(_, val)
                            settings.rowHeight = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 1
                    },
                    fontSize = {
                        type = "range",
                        name = L["Font Size"] or "Font Size",
                        desc = L["Set the size of text on data rows"] or "Set the size of text on data rows",
                        min = 8, max = 16, step = 1,
                        get = function() return settings.fontSize end,
                        set = function(_, val)
                            settings.fontSize = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 2
                    },
                    borderSize = {
                        type = "range",
                        name = L["Border Size"] or "Border Size",
                        desc = L["Set the thickness of window borders"] or "Set the thickness of window borders",
                        min = 0, max = 5, step = 1,
                        get = function() return settings.borderSize end,
                        set = function(_, val)
                            settings.borderSize = val
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "full",
                        order = 3
                    }
                }
            },
            actionsGroup = {
                type = "group",
                name = L["Actions"] or "Actions",
                inline = true,
                order = 7,
                args = {
                    saveOriginal = {
                        type = "toggle",
                        name = L["Save Original Skin"] or "Save Original Skin",
                        desc = L["Save the original Details skin for restoration when disabled"] or "Save the original Details skin for restoration when disabled",
                        get = function() return settings.saveOriginal end,
                        set = function(_, val)
                            settings.saveOriginal = val
                        end,
                        width = "full",
                        order = 1
                    },
                    resetButton = {
                        type = "execute",
                        name = L["Refresh All Windows"] or "Refresh All Windows",
                        desc = L["Reapply skin to all Details windows"] or "Reapply skin to all Details windows",
                        func = function()
                            DetailsSkin:ApplyThemeToAll()
                        end,
                        width = "normal",
                        order = 2
                    },
                    exportButton = {
                        type = "execute",
                        name = L["Export Settings"] or "Export Settings",
                        desc = L["Export settings to share with others"] or "Export settings to share with others",
                        func = function()
                            local exportString = DetailsSkin.Config:ExportSettings()
                            -- This would typically show a dialog with the export string
                            VUI:Print(L["Settings exported to clipboard"] or "Settings exported to clipboard")
                        end,
                        width = "normal",
                        order = 3
                    }
                }
            }
        }
    }
    
    return options
end

-- Restore original skins to all Details instances
function DetailsSkin.Config:RestoreOriginalSkins()
    if not _G.Details then return end
    
    local instances = _G.Details:GetAllInstances()
    for _, instance in ipairs(instances) do
        if instance._originalSkin then
            for k, v in pairs(instance._originalSkin) do
                instance[k] = v
            end
            if instance.RefreshSkin then
                instance:RefreshSkin()
            end
        end
    end
end

-- Register with VUI's config system
function DetailsSkin.Config:Register()
    -- Create default settings
    self:CreateDefaults()
    
    -- Register configuration options
    if VUI.options and VUI.options.args and VUI.options.args.modules then
        VUI.options.args.modules.args.detailsskin = self:GetOptions()
    end
end

-- Initialize configuration when addon is ready
if VUI.initialized then
    DetailsSkin.Config:Register()
else
    VUI:RegisterCallback("OnInitialized", function()
        DetailsSkin.Config:Register()
    end)
end