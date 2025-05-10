---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")
local L = VUIBuffs.L

-- Initialize VUI integration
function VUIBuffs:InitVUIIntegration()
    -- This function will be called after VUIBuffs is initialized
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
    
    if not VUI.db.profile.vmodules.vuibuffs then
        VUI.db.profile.vmodules.vuibuffs = {
            enabled = true,
            lockFrames = false,
            barDisplayEnabled = true,
            barHeight = 14,
            barWidth = 126,
            barPadding = 2
        }
    end
    
    -- Sync settings from VUIBuffs to VUI
    self:SyncSettingsToVUI()
    
    -- Hook our settings changed function to update VUI panel settings
    hooksecurefunc(self, "UpdateAllDisplays", function()
        self:SyncSettingsToVUI()
    end)
    
    -- The VUI Config registration will be handled in SetupOptions,
    -- which is called in OnInitialize
end

-- Sync settings from VUIBuffs to VUI
function VUIBuffs:SyncSettingsToVUI()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuibuffs then
        return
    end
    
    -- Copy settings from VUIBuffs to VUI
    VUI.db.profile.vmodules.vuibuffs.enabled = self.db.profile.general.enabled
    VUI.db.profile.vmodules.vuibuffs.lockFrames = self.db.profile.general.lockFrames
    VUI.db.profile.vmodules.vuibuffs.barDisplayEnabled = self.db.profile.barDisplays.global.enabled
    VUI.db.profile.vmodules.vuibuffs.barHeight = self.db.profile.barDisplays.global.barHeight
    VUI.db.profile.vmodules.vuibuffs.barWidth = self.db.profile.barDisplays.global.barWidth
    VUI.db.profile.vmodules.vuibuffs.barPadding = self.db.profile.barDisplays.global.barPadding
end

-- Sync settings from VUI to VUIBuffs
function VUIBuffs:SyncSettingsFromVUI()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuibuffs then
        return
    end
    
    -- Copy settings from VUI to VUIBuffs
    self.db.profile.general.enabled = VUI.db.profile.vmodules.vuibuffs.enabled
    self.db.profile.general.lockFrames = VUI.db.profile.vmodules.vuibuffs.lockFrames
    self.db.profile.barDisplays.global.enabled = VUI.db.profile.vmodules.vuibuffs.barDisplayEnabled
    self.db.profile.barDisplays.global.barHeight = VUI.db.profile.vmodules.vuibuffs.barHeight
    self.db.profile.barDisplays.global.barWidth = VUI.db.profile.vmodules.vuibuffs.barWidth
    self.db.profile.barDisplays.global.barPadding = VUI.db.profile.vmodules.vuibuffs.barPadding
    
    -- Update displays
    self:UpdateAllDisplays()
end