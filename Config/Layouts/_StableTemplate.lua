--[[
    VUI Config Layout Stable Template
    This template is designed to work reliably even when ConfigHelpers isn't loaded.
    All layout files should follow this pattern for maximum stability.
]]

local Layout = VUI:NewModule('Config.Layout.StableTemplate')

-- Safe access to helper functions with fallback
local SafeGetVModule

-- Initialize the helper function
local function InitHelpers()
    -- Use global if available, otherwise try to get from VUI
    SafeGetVModule = _G.SafeGetVModule
    
    -- If the global helper isn't available yet, create a simple version
    if not SafeGetVModule and VUI then
        SafeGetVModule = function(name)
            return VUI:GetModule(name, true)
        end
    end
end

function Layout:OnEnable()
    -- Initialize helpers
    InitHelpers()

    -- Database reference
    local db = VUI.db
    
    -- Get module safely (replace ModuleName with your actual module name)
    local module = SafeGetVModule and SafeGetVModule("ModuleName") 
    
    if not module then 
        -- Retry after a delay if helpers not loaded yet
        C_Timer.After(0.5, function()
            InitHelpers()
            self:OnEnable()
        end)
        return 
    end
    
    -- Data module references (if needed)
    local Textures = VUI:GetModule("Data.Textures", true)
    local Fonts = VUI:GetModule("Data.Fonts", true)
    
    -- Layout definition
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile, -- Or specific namespace if needed
        rows = {
            -- Section 1: Main settings
            {
                header = {
                    type = 'header',
                    label = 'Module Name'
                },
            },
            {
                enabled = {
                    key = 'modulePath.enabled',
                    type = 'checkbox',
                    label = 'Enable Module',
                    tooltip = 'Enable or disable this module',
                    column = 4, -- Ensure column allocation per row doesn't exceed 12
                    order = 1,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.enabled = self:GetValue()
                            if self:GetValue() then
                                if module.OnEnable then module:OnEnable() end
                            else
                                if module.OnDisable then module:OnDisable() end
                            end
                        end
                    end
                },
                -- Additional settings in same row (total columns ≤ 12)
            },
            
            -- Section 2: Group related settings together
            {
                header = {
                    type = 'header',
                    label = 'Category Name'
                },
            },
            {
                -- First row of settings for this category
                setting1 = {
                    key = 'modulePath.setting1',
                    type = 'checkbox', -- or other control type
                    label = 'Setting 1',
                    tooltip = 'Description of setting 1',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.setting1 = self:GetValue()
                            if module.UpdateSettings then
                                module:UpdateSettings()
                            end
                        end
                    end
                },
                setting2 = {
                    key = 'modulePath.setting2',
                    type = 'checkbox',
                    label = 'Setting 2',
                    tooltip = 'Description of setting 2',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        -- Implementation
                    end
                },
            },
            
            -- Add more sections as needed
        }
    }
end 