-- VUIAnyFrame - VUI Integration
local AddonName, VUI = ...
local M = _G["VUIAnyFrame"]
local L = M.L

-- Initialize VUI Integration
function M:InitVUIIntegration()
    -- This function will be called after VUIAnyFrame is initialized
    
    -- Make sure VUI exists
    if not VUI then
        return
    end
    
    -- Register with VUI's config system
    if VUI.Config then
        VUI.Config:RegisterModuleOptions("VUIAnyFrame", function()
            return self:GetOptions()
        end, {
            name = "AnyFrame",
            desc = "Move and scale any frame",
            icon = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\icon",
            order = 800
        })
    end
    
    -- Register with VUI's module system
    if VUI.RegisterModule then
        VUI:RegisterModule("vuianyframe", self)
    end
    
    -- Set up default settings in VUI database if they don't exist
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules then
        return
    end
    
    if not VUI.db.profile.vmodules.vuianyframe then
        VUI.db.profile.vmodules.vuianyframe = {
            enabled = true,
            lockFrames = true
        }
    end
    
    -- Set up two-way communication with VUI
    self:SyncSettingsFromVUI()
    
    -- Set up callbacks for changes
    if VUI.RegisterCallback then
        VUI:RegisterCallback("OnModuleSettingChanged", function(module, setting, value)
            if module == "vuianyframe" then
                self:SyncSettingsFromVUI()
            end
        end)
    end
end

-- Sync settings from VUIAnyFrame to VUI
function M:SyncSettingsToVUI()
    if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuianyframe then
        return
    end
    
    -- Copy settings from VUIAnyFrame to VUI
    VUI.db.profile.vmodules.vuianyframe.enabled = self.db.profile.enabled
    VUI.db.profile.vmodules.vuianyframe.lockFrames = self.db.profile.global.lockFrames
end

-- Sync settings from VUI to VUIAnyFrame
function M:SyncSettingsFromVUI()
    if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuianyframe then
        return
    end
    
    -- Copy settings from VUI to VUIAnyFrame
    self.db.profile.enabled = VUI.db.profile.vmodules.vuianyframe.enabled
    self.db.profile.global.lockFrames = VUI.db.profile.vmodules.vuianyframe.lockFrames
    
    -- Apply settings
    C_Timer.After(0.1, function()
        self:ApplySettings()
    end)
end

-- Register theme callback
function M:UpdateTheme()
    -- Update any theme-dependent elements
    self:UpdateGrid()
    
    -- Update frames if needed
    self:UpdateAllFrames()
end 