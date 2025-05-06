local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Initialize the DetailsSkin module
local DetailsSkin = VUI.detailsskin or {}
VUI.detailsskin = DetailsSkin

-- Create the skin registry
DetailsSkin.SkinRegistry = {}
local SkinRegistry = DetailsSkin.SkinRegistry

-- Table of registered skins
SkinRegistry.skins = {}
SkinRegistry.defaultSkin = "VUITheme"

-- Register a new skin
function SkinRegistry:RegisterSkin(skinID, skinInfo)
    if not skinID or not skinInfo then return false end
    
    -- Ensure required fields exist
    skinInfo.name = skinInfo.name or skinID
    skinInfo.description = skinInfo.description or "A Details skin"
    skinInfo.author = skinInfo.author or "Unknown"
    
    -- Ensure apply and reset functions exist
    if not skinInfo.applyFunction or type(skinInfo.applyFunction) ~= "function" then
        return false
    end
    
    if not skinInfo.resetFunction or type(skinInfo.resetFunction) ~= "function" then
        skinInfo.resetFunction = function(instance) return true end -- Default no-op
    end
    
    -- Register the skin
    self.skins[skinID] = skinInfo
    
    -- If this is the first skin or marked as default, set it as default
    if not self.defaultSkin or skinInfo.isDefault then
        self.defaultSkin = skinID
    end
    
    return true
end

-- Get a registered skin
function SkinRegistry:GetSkin(skinID)
    if not skinID then return self.skins[self.defaultSkin] end
    return self.skins[skinID]
end

-- Apply a skin to an instance
function SkinRegistry:ApplySkin(skinID, instance)
    local skin = self:GetSkin(skinID)
    if not skin then return false end
    
    -- Call the skin's apply function
    return skin.applyFunction(instance)
end

-- Reset an instance's skin
function SkinRegistry:ResetSkin(skinID, instance)
    local skin = self:GetSkin(skinID)
    if not skin then return false end
    
    -- Call the skin's reset function
    return skin.resetFunction(instance)
end

-- Get a list of available skins
function SkinRegistry:GetAvailableSkins()
    local skinList = {}
    
    for skinID, skinInfo in pairs(self.skins) do
        table.insert(skinList, {
            id = skinID,
            name = skinInfo.name,
            description = skinInfo.description,
            author = skinInfo.author,
            isDefault = (skinID == self.defaultSkin)
        })
    end
    
    -- Sort by name
    table.sort(skinList, function(a, b) 
        if a.isDefault then return true end
        if b.isDefault then return false end
        return a.name < b.name
    end)
    
    return skinList
end

-- Set the default skin
function SkinRegistry:SetDefaultSkin(skinID)
    if self.skins[skinID] then
        self.defaultSkin = skinID
        return true
    end
    return false
end

-- Register the VUI Theme skin
function SkinRegistry:RegisterVUIThemeSkin()
    self:RegisterSkin("VUITheme", {
        name = "VUI Theme",
        description = "The default VUI-themed skin that changes with your selected theme",
        author = "VUI Team",
        applyFunction = function(instance) 
            local theme = VUI.db.profile.appearance.theme or "thunderstorm"
            return DetailsSkin:ApplySkinToInstance(instance, theme)
        end,
        resetFunction = function(instance)
            if instance and instance._originalSkin then
                -- Restore original skin settings
                for key, value in pairs(instance._originalSkin) do
                    instance[key] = CopyTable(value)
                end
                instance._originalSkin = nil
                
                -- Refresh instance
                instance:InstanceRefreshRows()
                instance:RefreshWindow()
                return true
            end
            return false
        end,
        isDefault = true
    })
end

-- Initialize the registry
function SkinRegistry:Initialize()
    -- Register the default VUI theme skin
    self:RegisterVUIThemeSkin()
    
    -- Hook skin application to theme changes
    if VUI.ThemeIntegration and VUI.ThemeIntegration.RegisterThemeChangeCallback then
        VUI.ThemeIntegration:RegisterThemeChangeCallback(function(newTheme)
            -- Update instances using the VUI Theme skin
            local instances = Details:GetAllInstances()
            for _, instance in ipairs(instances) do
                if instance._currentSkin == "VUITheme" then
                    self:ApplySkin("VUITheme", instance)
                end
            end
        end)
    end
end