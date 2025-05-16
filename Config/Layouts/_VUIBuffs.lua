--[[
    VUI Buffs Module Configuration
    Enhanced buff and debuff tracking with configurable layouts and priorities
]]

local Layout = VUI:NewModule('Config.Layout.VUIBuffs')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIBuffs", "VUI Buffs", "vmodules.vuibuffs")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'General Settings'
        },
    })
    
    -- Add general settings
    table.insert(Layout.layout.rows, {
        barEnabled = {
            key = 'vmodules.vuibuffs.general.enabled',
            type = 'checkbox',
            label = 'Enable VUI Buffs',
            tooltip = 'Enable or disable the VUI Buffs module',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enabled = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuibuffs.general.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock VUI Buffs frames',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        testMode = {
            type = 'button',
            text = 'Test Mode',
            tooltip = 'Toggle test mode to see how buffs will display',
            column = 4,
            order = 3,
            onClick = function()
                -- First try using the module parameter passed to the layout builder
                if module then
                    -- Create a safer reference to the ToggleTestMode function
                    local toggleFunction = module.ToggleTestMode
                    if type(toggleFunction) == "function" then
                        -- Use pcall with proper function context preservation
                        local success, errorMsg = pcall(function()
                            toggleFunction(module)
                        end)
                        
                        if success then
                            -- Success! No need to try fallbacks
                            return
                        end
                        
                        -- Log the error but continue to fallbacks
                        print("|cffff9900VUIBuffs Warning:|r First toggle attempt failed: " .. tostring(errorMsg))
                    end
                end
                
                -- Fallback #1: Try to find the module through GetModule
                if VUI and VUI.GetModule then
                    local success, vuiBuffsModule = pcall(function() return VUI:GetModule("VUIBuffs") end)
                    if success and vuiBuffsModule and vuiBuffsModule.ToggleTestMode then
                        local toggleSuccess, toggleError = pcall(function()
                            vuiBuffsModule:ToggleTestMode()
                        end)
                        
                        if toggleSuccess then
                            -- Success with fallback #1
                            return
                        end
                        
                        -- Log the error but continue to fallbacks
                        print("|cffff9900VUIBuffs Warning:|r Second toggle attempt failed: " .. tostring(toggleError))
                    end
                end
                
                -- Fallback #2: Try using the global reference as last resort
                local VUIBuffsGlobal = _G["VUIBuffs"]
                if VUIBuffsGlobal then
                    if type(VUIBuffsGlobal) == "table" and type(VUIBuffsGlobal.ToggleTestMode) == "function" then
                        local toggleSuccess, toggleError = pcall(function()
                            VUIBuffsGlobal:ToggleTestMode()
                        end)
                        
                        if toggleSuccess then
                            -- Success with fallback #2
                            return
                        end
                        
                        -- Log the error for debugging
                        print("|cffff0000VUIBuffs Error:|r Final toggle attempt failed: " .. tostring(toggleError))
                    else
                        -- Try direct call with context if the module exists but ToggleTestMode isn't a function
                        local toggleTestModeFunc = rawget(VUIBuffsGlobal, "ToggleTestMode")
                        if toggleTestModeFunc then
                            pcall(toggleTestModeFunc, VUIBuffsGlobal)
                        else
                            print("|cffff0000VUIBuffs Error:|r Could not find valid ToggleTestMode function")
                        end
                    end
                else
                    print("|cffff0000VUIBuffs Error:|r Module not found in global namespace")
                end
            end
        },
    })
    
    -- Add display settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Settings'
        },
    })
    
    -- Instance type settings
    table.insert(Layout.layout.rows, {
        enabledInWorld = {
            key = 'vmodules.vuibuffs.general.enabledInWorld',
            type = 'checkbox',
            label = 'Enable in World',
            tooltip = 'Enable or disable buff display in the open world',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enabledInWorld = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        enabledInDungeons = {
            key = 'vmodules.vuibuffs.general.enabledInDungeons',
            type = 'checkbox',
            label = 'Enable in Dungeons',
            tooltip = 'Enable or disable buff display in dungeons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enabledInDungeons = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        enabledInRaids = {
            key = 'vmodules.vuibuffs.general.enabledInRaids',
            type = 'checkbox',
            label = 'Enable in Raids',
            tooltip = 'Enable or disable buff display in raids',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enabledInRaids = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Appearance settings
    table.insert(Layout.layout.rows, {
        hideIconBorder = {
            key = 'vmodules.vuibuffs.general.hideIconBorder',
            type = 'checkbox',
            label = 'Hide Icon Border',
            tooltip = 'Hide or show borders around buff icons',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.hideIconBorder = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        showEmptyBuffs = {
            key = 'vmodules.vuibuffs.general.showEmptyBuffs',
            type = 'checkbox',
            label = 'Show Empty Buffs',
            tooltip = 'Show or hide slots for missing buffs',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.showEmptyBuffs = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        borderStyle = {
            key = 'vmodules.vuibuffs.general.borderStyle',
            type = 'dropdown',
            label = 'Border Style',
            tooltip = 'Select the style of borders around buff icons',
            options = {
                {value = 1, text = "Thin"},
                {value = 2, text = "Classic"}
            },
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.borderStyle = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Bar display settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Bar Display Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        barDisplayEnabled = {
            key = 'vmodules.vuibuffs.barDisplays.global.enabled',
            type = 'checkbox',
            label = 'Enable Bar Display',
            tooltip = 'Enable or disable the buff/debuff bar display',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.barDisplays.global.enabled = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        showIcon = {
            key = 'vmodules.vuibuffs.barDisplays.global.showIcon',
            type = 'checkbox',
            label = 'Show Icon',
            tooltip = 'Show or hide the spell icon on bars',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.barDisplays.global.showIcon = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        showText = {
            key = 'vmodules.vuibuffs.barDisplays.global.showText',
            type = 'checkbox',
            label = 'Show Text',
            tooltip = 'Show or hide text labels on bars',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.barDisplays.global.showText = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Size configuration
    table.insert(Layout.layout.rows, {
        barWidth = {
            key = 'vmodules.vuibuffs.barDisplays.global.barWidth',
            type = 'slider',
            label = 'Bar Width',
            tooltip = 'Set the width of buff/debuff bars',
            min = 50,
            max = 300,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.barDisplays.global.barWidth = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        barHeight = {
            key = 'vmodules.vuibuffs.barDisplays.global.barHeight',
            type = 'slider',
            label = 'Bar Height',
            tooltip = 'Set the height of buff/debuff bars',
            min = 1,
            max = 50,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.barDisplays.global.barHeight = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        barPadding = {
            key = 'vmodules.vuibuffs.barDisplays.global.barPadding',
            type = 'slider',
            label = 'Bar Padding',
            tooltip = 'Set the padding between buff/debuff bars',
            min = 0,
            max = 20,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.barDisplays.global.barPadding = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Advanced configuration
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Advanced Configuration'
        },
    })
    
    table.insert(Layout.layout.rows, {
        openConfig = {
            type = 'button',
            text = 'Open Full Configuration',
            tooltip = 'Open the detailed VUI Buffs configuration panel',
            column = 12,
            order = 1,
            onClick = function()
                if module and module.OpenOptions then
                    module:OpenOptions()
                end
            end
        },
    })
end

return Layout 