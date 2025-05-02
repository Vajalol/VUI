-- Example Module with Database Optimization Implementation
-- This serves as a reference for other modules to follow

local addonName, VUI = ...

-- Get reference to module
local Example = VUI:GetModule("Example") or {}
if not Example then return end

-- Set up local reference to DB optimization if available
local DBOpt = VUI.DatabaseOptimization

-- Cache some frequently used values
local defaultSettings = {
    enabled = true,
    scale = 1.0,
    opacity = 0.8,
    position = { x = 0, y = 0 },
    fontSize = 12,
    showBackground = true,
    border = "thin",
    autoHide = false,
    colorTheme = "default",
    showIcon = true,
    locked = false
}

-- ================================================================
-- Database Access Patterns - Best Practices
-- ================================================================

-- Helper function to get a setting with optimization if available
local function GetSetting(path, default)
    if DBOpt then
        -- Use the optimized database access
        return DBOpt:Get(Example.db, "profile." .. path, default)
    else
        -- Traditional nested table access
        local value = Example.db.profile
        for segment in string.gmatch(path, "[^%.]+") do
            if type(value) ~= "table" then
                return default
            end
            value = value[segment]
            if value == nil then
                return default
            end
        end
        return value
    end
end

-- Helper function to set a setting with optimization if available
local function SetSetting(path, value, immediate)
    if DBOpt then
        -- Use the optimized database access
        return DBOpt:Set(Example.db, "profile." .. path, value, immediate)
    else
        -- Traditional nested table access
        local segments = {}
        for segment in string.gmatch(path, "[^%.]+") do
            table.insert(segments, segment)
        end
        
        local current = Example.db.profile
        for i = 1, #segments - 1 do
            local segment = segments[i]
            if type(current[segment]) ~= "table" then
                current[segment] = {}
            end
            current = current[segment]
        end
        
        current[segments[#segments]] = value
    end
end

-- ================================================================
-- Module Interface
-- ================================================================

-- Initialize the module
function Example:Initialize()
    -- Set default settings if not already defined
    if not self.db.profile.general then
        self.db.profile.general = defaultSettings
    end
    
    -- Register with Database Optimization system if available
    if DBOpt then
        DBOpt:RegisterModuleDatabase("Example", self.db)
        
        -- Preload commonly accessed settings
        self:PreloadCommonSettings()
    end
    
    -- Create the UI components
    self:CreateFrames()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Preload frequently accessed settings for optimization
function Example:PreloadCommonSettings()
    if not DBOpt then return end
    
    -- List of commonly accessed settings
    local commonSettings = {
        "general.enabled",
        "general.scale",
        "general.opacity",
        "general.position",
        "general.fontSize",
        "general.showBackground",
        "general.border",
        "general.colorTheme"
    }
    
    -- Preload each setting
    for _, path in ipairs(commonSettings) do
        local value = DBOpt:GetNestedValue(self.db, "profile." .. path)
        if value ~= nil then
            DBOpt:CacheValue(self.db, "profile." .. path, value)
        end
    end
end

-- Apply the current settings
function Example:ApplySettings()
    -- Exit if frame doesn't exist yet
    if not self.frame then return end
    
    -- Get settings using the optimized function
    local enabled = GetSetting("general.enabled", true)
    local scale = GetSetting("general.scale", 1.0)
    local opacity = GetSetting("general.opacity", 0.8)
    local position = GetSetting("general.position", { x = 0, y = 0 })
    local fontSize = GetSetting("general.fontSize", 12)
    local showBackground = GetSetting("general.showBackground", true)
    local border = GetSetting("general.border", "thin")
    local colorTheme = GetSetting("general.colorTheme", "default")
    
    -- Apply settings to the frame
    self.frame:SetScale(scale)
    self.frame:SetAlpha(opacity)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", position.x, position.y)
    
    -- Apply font settings
    if self.textDisplay then
        self.textDisplay:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    end
    
    -- Apply background settings
    if showBackground then
        self.frame:SetBackdrop({
            bgFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-" .. border .. ".tga",
            tile = false,
            tileSize = 0,
            edgeSize = border == "thin" and 8 or 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Apply color theme
        local colors = self:GetThemeColors(colorTheme)
        self.frame:SetBackdropColor(colors.bg.r, colors.bg.g, colors.bg.b, colors.bg.a)
        self.frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    else
        self.frame:SetBackdrop(nil)
    end
    
    -- Show or hide based on enabled state
    if enabled then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

-- Get theme colors based on selected theme
function Example:GetThemeColors(theme)
    local themes = {
        default = {
            bg = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
            border = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 }
        },
        class = {
            bg = { r = VUI.CLASSCOLOR.r * 0.2, g = VUI.CLASSCOLOR.g * 0.2, b = VUI.CLASSCOLOR.b * 0.2, a = 0.8 },
            border = { r = VUI.CLASSCOLOR.r, g = VUI.CLASSCOLOR.g, b = VUI.CLASSCOLOR.b, a = 1.0 }
        },
        dark = {
            bg = { r = 0.05, g = 0.05, b = 0.05, a = 0.9 },
            border = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 }
        },
        light = {
            bg = { r = 0.8, g = 0.8, b = 0.8, a = 0.7 },
            border = { r = 0.6, g = 0.6, b = 0.6, a = 1.0 }
        }
    }
    
    -- Use the optimized database access
    local userThemes = GetSetting("themes", {})
    
    -- First try user-defined themes
    if userThemes and userThemes[theme] then
        return userThemes[theme]
    end
    
    -- Fall back to default themes
    return themes[theme] or themes.default
end

-- Create the UI frames
function Example:CreateFrames()
    -- Main frame
    self.frame = CreateFrame("Frame", "VUIExampleFrame", UIParent, "BackdropTemplate")
    self.frame:SetSize(200, 100)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.frame:SetFrameStrata("MEDIUM")
    
    -- Text display
    self.textDisplay = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.textDisplay:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
    self.textDisplay:SetText("Example Module")
    
    -- Make frame movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(f) 
        if not GetSetting("general.locked", false) then 
            f:StartMoving() 
        end 
    end)
    self.frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        -- Save the position
        local scale = f:GetScale()
        local x, y = f:GetCenter()
        local uiParentX, uiParentY = UIParent:GetCenter()
        x = (x - uiParentX) / scale
        y = (y - uiParentY) / scale
        
        -- Use the optimized setting function
        SetSetting("general.position", { x = x, y = y }, true) -- true = immediate write
    end)
    
    -- Hide by default until settings are applied
    self.frame:Hide()
    
    -- Apply settings
    self:ApplySettings()
end

-- PLAYER_ENTERING_WORLD event handler
function Example:PLAYER_ENTERING_WORLD()
    self:ApplySettings()
end

-- ================================================================
-- Module Functions
-- ================================================================

-- Update the module with new data
function Example:UpdateData(data)
    if not self.frame or not data then return end
    
    -- Example of how to use batch processing for non-critical settings
    -- This will group multiple changes together
    SetSetting("data.lastUpdate", GetTime())
    SetSetting("data.count", (GetSetting("data.count", 0) + 1))
    
    -- For the UI element, we want an immediate update
    if self.textDisplay then
        self.textDisplay:SetText(data.text or "Updated: " .. GetSetting("data.count", 0))
    end
end

-- Toggle the module
function Example:ToggleModule()
    local currentState = GetSetting("general.enabled", true)
    
    -- Use immediate write for important state changes
    SetSetting("general.enabled", not currentState, true)
    
    -- Apply the new setting
    self:ApplySettings()
    
    -- Inform the user
    VUI:Print("Example module " .. (GetSetting("general.enabled", true) and "enabled" or "disabled"))
end

-- ================================================================
-- Configuration Options
-- ================================================================

-- Get module configuration options
function Example:GetOptions()
    return {
        type = "group",
        name = "Example",
        get = function(info) return GetSetting(info[#info]) end,
        set = function(info, value) 
            SetSetting(info[#info], value)
            self:ApplySettings()
        end,
        args = {
            general = {
                type = "group",
                name = "General",
                order = 1,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enable Module",
                        desc = "Enable or disable the example module",
                        order = 1,
                        get = function() return GetSetting("general.enabled", true) end,
                        set = function(_, value)
                            SetSetting("general.enabled", value, true) -- Immediate update
                            self:ApplySettings()
                        end,
                    },
                    -- Additional settings...
                }
            }
        }
    }
end

-- Return the module
VUI.Example = Example