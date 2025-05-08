---@class VUIKeystones: AceModule
local VUIKeystones = LibStub("AceAddon-3.0"):GetAddon("VUIKeystones")
local L = VUIKeystones.L

-- Initialize VUI integration
function VUIKeystones:InitVUIIntegration()
    -- This function will be called after VUIKeystones is initialized
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
    
    if not VUI.db.profile.vmodules.vuikeystones then
        VUI.db.profile.vmodules.vuikeystones = {
            enabled = true,
            progressTooltip = true,
            progressFormat = 1,
            autoGossip = true,
            silverGoldTimer = false,
            splitsFormat = 1,
            completionMessage = true,
            smallAffixes = true,
            deathTracker = true
        }
    end
    
    -- Sync settings from VUIKeystones to VUI
    self:SyncSettingsToVUI()
    
    -- Hook our settings changed function to update VUI panel settings
    local Config = self:GetModule("Config")
    if Config then
        Config:RegisterCallback("OnUpdate", function()
            self:SyncSettingsToVUI()
        end)
    end
end

-- Sync settings from VUIKeystones to VUI
function VUIKeystones:SyncSettingsToVUI()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuikeystones then
        return
    end
    
    -- Copy settings from VUIKeystones to VUI
    VUI.db.profile.vmodules.vuikeystones.enabled = self.db.profile.general.enabled
    VUI.db.profile.vmodules.vuikeystones.progressTooltip = self.db.profile.progressTooltip
    VUI.db.profile.vmodules.vuikeystones.progressFormat = self.db.profile.progressFormat
    VUI.db.profile.vmodules.vuikeystones.autoGossip = self.db.profile.autoGossip
    VUI.db.profile.vmodules.vuikeystones.silverGoldTimer = self.db.profile.silverGoldTimer
    VUI.db.profile.vmodules.vuikeystones.splitsFormat = self.db.profile.splitsFormat
    VUI.db.profile.vmodules.vuikeystones.completionMessage = self.db.profile.completionMessage
    VUI.db.profile.vmodules.vuikeystones.smallAffixes = self.db.profile.smallAffixes
    VUI.db.profile.vmodules.vuikeystones.deathTracker = self.db.profile.deathTracker
end

-- Sync settings from VUI to VUIKeystones
function VUIKeystones:SyncSettingsFromVUI()
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuikeystones then
        return
    end
    
    -- Copy settings from VUI to VUIKeystones
    self.db.profile.general.enabled = VUI.db.profile.vmodules.vuikeystones.enabled
    self.db.profile.progressTooltip = VUI.db.profile.vmodules.vuikeystones.progressTooltip
    self.db.profile.progressFormat = VUI.db.profile.vmodules.vuikeystones.progressFormat
    self.db.profile.autoGossip = VUI.db.profile.vmodules.vuikeystones.autoGossip
    self.db.profile.silverGoldTimer = VUI.db.profile.vmodules.vuikeystones.silverGoldTimer
    self.db.profile.splitsFormat = VUI.db.profile.vmodules.vuikeystones.splitsFormat
    self.db.profile.completionMessage = VUI.db.profile.vmodules.vuikeystones.completionMessage
    self.db.profile.smallAffixes = VUI.db.profile.vmodules.vuikeystones.smallAffixes
    self.db.profile.deathTracker = VUI.db.profile.vmodules.vuikeystones.deathTracker
    
    -- Notify any modules of config updates
    local Config = self:GetModule("Config")
    if Config and Config.NotifyUpdate then
        Config:NotifyUpdate()
    end
end