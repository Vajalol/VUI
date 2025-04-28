local _, VUI = ...
local DS = VUI.DetailsSkin
local L = VUI.L

-- Helper functions for configuration
function DS:UpdateAllInstances()
    if not self.detailsLoaded or not self:GetSettings().enabled then
        return
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    for i = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(i)
        if instance then
            self:ApplySkinToInstance(instance, theme)
        end
    end
end

-- Function to reset all Details windows to VUI skin
function DS:ResetAllInstances()
    if not self.detailsLoaded or not self:GetSettings().enabled then
        return
    end
    
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    for i = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(i)
        if instance then
            -- Remove any saved original settings to force full reskinning
            instance.VUI_original_settings = nil
            self:ApplySkinToInstance(instance, theme)
        end
    end
end

-- Function to apply settings to a specific instance only
function DS:ApplyToInstance(instanceId)
    if not self.detailsLoaded or not self:GetSettings().enabled then
        return
    end
    
    local instance = _G.Details:GetInstance(instanceId)
    if instance then
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        self:ApplySkinToInstance(instance, theme)
    end
end

-- Function to export current settings as a string
function DS:ExportSettings()
    local settings = self:GetSettings()
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
function DS:ImportSettings(settingsString)
    if not settingsString or settingsString == "" then
        return false, "Empty settings string"
    end
    
    local AceSerializer = LibStub("AceSerializer-3.0")
    local success, importedSettings = AceSerializer:Deserialize(settingsString)
    
    if not success then
        return false, "Failed to deserialize settings"
    end
    
    -- Apply imported settings
    local currentSettings = self:GetSettings()
    for k, v in pairs(importedSettings) do
        if currentSettings[k] ~= nil then -- Only copy existing keys
            currentSettings[k] = v
        end
    end
    
    -- Apply the imported settings
    self:ApplySkin()
    
    return true, "Settings imported successfully"
end

-- Function to create theme-specific textures
function DS:CreateThemeTextures()
    -- This would be implemented to generate theme-specific textures
    -- or load them from files if they exist
end