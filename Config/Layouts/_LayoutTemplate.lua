--[[
    VUI Config Layout Template
    This is a template for creating new layout files with proper
    structure and organization.
]]

local Layout = VUI:NewModule('Config.Layout.TemplateName')

-- Use the centralized helper for finding VModules
local SafeGetVModule = _G.SafeGetVModule or VUI.ConfigHelpers.SafeGetVModule

function Layout:OnEnable()
    -- Database reference
    local db = VUI.db
    
    -- Get module safely with centralized helper
    local module = SafeGetVModule("ModuleName")
    
    if not module then 
        -- Use the retry mechanism with proper callback
        VUI.ConfigHelpers.FindVModule("ModuleName", function(foundModule)
            module = foundModule
            if module then 
                self:OnEnable() 
            end
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