---@class VUIAnyFrame: AceModule
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Initialize VUI integration
function VUIAnyFrame:InitVUIIntegration()
    -- This function will be called after VUIAnyFrame is initialized
    -- It handles integration with the main VUI configuration panel
    
    -- Initialize default VUI settings if they don't exist
    if not VUI_SavedVariables then
        VUI_SavedVariables = {}
    end
    
    -- Initialize the VUI db if needed
    if not VUI.db or not VUI.db.profile then
        return
    end
    
    -- Initialize vmodules settings if they don't exist
    if not VUI.db.profile.vmodules then
        VUI.db.profile.vmodules = {}
    end
    
    if not VUI.db.profile.vmodules.vuianyframe then
        VUI.db.profile.vmodules.vuianyframe = {
            enabled = true,
            lockFrames = false
        }
    end
    
    -- Sync settings from VUIAnyFrame to VUI
    self:SyncSettingsToVUI()
    
    -- Hook our settings changed function to update VUI panel settings
    hooksecurefunc(self, "UpdateAllFrames", function()
        self:SyncSettingsToVUI()
    end)
    
    -- The VUI Config registration will be handled in SetupOptions,
    -- which is called in OnInitialize
end

-- Sync settings from VUIAnyFrame to VUI
function VUIAnyFrame:SyncSettingsToVUI()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuianyframe then
        return
    end
    
    -- Copy settings from VUIAnyFrame to VUI
    VUI.db.profile.vmodules.vuianyframe.enabled = self.db.profile.general.enabled
    VUI.db.profile.vmodules.vuianyframe.lockFrames = self.db.profile.general.lockFrames
end

-- Sync settings from VUI to VUIAnyFrame
function VUIAnyFrame:SyncSettingsFromVUI()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuianyframe then
        return
    end
    
    -- Copy settings from VUI to VUIAnyFrame
    self.db.profile.general.enabled = VUI.db.profile.vmodules.vuianyframe.enabled
    self.db.profile.general.lockFrames = VUI.db.profile.vmodules.vuianyframe.lockFrames
    
    -- Update displays
    self:UpdateAllFrames()
end