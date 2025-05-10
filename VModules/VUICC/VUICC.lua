-- code to drive the addon
local AddonName, Addon = ...
local CONFIG_ADDON = AddonName .. '_Config'
local L = LibStub('AceLocale-3.0'):GetLocale(AddonName)

EventUtil.ContinueOnAddOnLoaded(AddonName, function(addonName)
    Addon:InitializeDB()
    Addon.Cooldown:SetupHooks()

    -- setup addon compartment button
        if AddonCompartmentFrame then
                AddonCompartmentFrame:RegisterAddon{
                        text = C_AddOns.GetAddOnMetadata(addonName, "Title"),
                        icon = C_AddOns.GetAddOnMetadata(addonName, "IconTexture"),
                        func = function() Addon:ShowOptionsFrame() end,
                }
        end

    -- setup slash commands
    SlashCmdList[AddonName] = function(cmd, ...)
        if cmd == 'version' then
            print(L.Version:format(Addon.db.global.addonVersion))
        elseif cmd == 'blizzard' then
            if Addon.db.global.disableBlizzardCooldownText then
                Addon.db.global.disableBlizzardCooldownText = false
            else
                Addon.db.global.disableBlizzardCooldownText = true
            end
            C_UI.Reload()
        elseif cmd == 'config' then
            Addon:ShowOptionsFrame()
        else
            Addon:ShowOptionsFrame()
        end
    end
    
    -- Initialize VUI Integration
    Addon:InitVUIIntegration()

    SLASH_OmniCC1 = '/omnicc'
    SLASH_OmniCC2 = '/occ'

    -- watch for subsequent events
    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Addon.PLAYER_ENTERING_WORLD, Addon)
end)

function Addon:PLAYER_ENTERING_WORLD()
    self.Timer:ForActive('Update')
end

-- utility methods
function Addon:ShowOptionsFrame()
    -- Try to use VUI Config first if available
    if VUI and VUI.Config and VUI.Config.OpenConfigPanel then
        VUI.Config:OpenConfigPanel("VUICC")
        return true
    end
    
    -- Fall back to original config method
    if C_AddOns.LoadAddOn(CONFIG_ADDON) then
        local dialog = LibStub('AceConfigDialog-3.0')

        dialog:Open(AddonName)
        dialog:SelectGroup(AddonName, "themes", DEFAULT)

        return true
    end

    return false
end

-- Get options for configuration panel - standard function name used across VUI modules
function Addon:GetOptions()
    -- Basic options structure
    local options = {
        name = "VUI OmniCC",
        handler = self,
        type = "group",
        icon = "Interface\\AddOns\\VUI\\Media\\Icons\\tga\\vortex_thunderstorm.tga",
        args = {
            general = {
                order = 1,
                type = "group",
                name = "General",
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = "Enable",
                        desc = "Enable/disable VUI OmniCC cooldown text",
                        get = function() return self.db.profile.enabled end,
                        set = function(_, value)
                            self.db.profile.enabled = value
                            self.Cooldown:ForAll('UpdateSettings')
                        end,
                        width = "full",
                    },
                    disableBlizzardCooldownText = {
                        order = 2,
                        type = "toggle",
                        name = "Disable Blizzard Cooldown Text",
                        desc = "Disable the built-in cooldown text",
                        get = function() return self.db.global.disableBlizzardCooldownText end,
                        set = function(_, value)
                            self.db.global.disableBlizzardCooldownText = value
                            print("Reload UI to see changes")
                        end,
                        width = "full",
                    },
                    configure = {
                        order = 3,
                        type = "execute",
                        name = "Advanced Settings",
                        desc = "Open the full OmniCC configuration panel",
                        func = function() Addon:ShowOptionsFrame() end,
                        width = "full",
                    },
                },
            },
        },
    }
    
    return options
end

-- Initialize VUI integration
function Addon:InitVUIIntegration()
    -- This function will be called after VUICC is initialized
    -- It handles integration with the main VUI configuration panel
    
    -- Initialize default VUI settings if they don't exist
    if not VUI_SavedVariables then
        VUI_SavedVariables = {}
    end
    
    -- Initialize the VUI db if needed
    if not VUI or not VUI.db or not VUI.db.profile then
        return
    end
    
    -- Initialize vmodules settings if they don't exist
    if not VUI.db.profile.vmodules then
        VUI.db.profile.vmodules = {}
    end
    
    if not VUI.db.profile.vmodules.vuicc then
        VUI.db.profile.vmodules.vuicc = {
            enabled = true,
            disableBlizzardCooldownText = true
        }
    end
    
    -- Sync settings from VUICC to VUI
    self:SyncSettingsToVUI()
    
    -- Register with VUI Config system if available
    if VUI and VUI.Config and VUI.Config.RegisterModuleOptions then
        local options = self:GetOptions()
        VUI.Config:RegisterModuleOptions("VUICC", options, "VUI OmniCC")
    end
end

-- Sync settings from VUICC to VUI
function Addon:SyncSettingsToVUI()
    if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuicc then
        return
    end
    
    -- Copy settings from VUICC to VUI
    VUI.db.profile.vmodules.vuicc.enabled = self.db.profile.enabled
    VUI.db.profile.vmodules.vuicc.disableBlizzardCooldownText = self.db.global.disableBlizzardCooldownText
end

-- Sync settings from VUI to VUICC
function Addon:SyncSettingsFromVUI()
    if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.vmodules or not VUI.db.profile.vmodules.vuicc then
        return
    end
    
    -- Copy settings from VUI to VUICC
    self.db.profile.enabled = VUI.db.profile.vmodules.vuicc.enabled
    self.db.global.disableBlizzardCooldownText = VUI.db.profile.vmodules.vuicc.disableBlizzardCooldownText
    
    -- Update cooldown settings
    self.Cooldown:ForAll('UpdateSettings')
end

function Addon:CreateHiddenFrame(...)
    local f = CreateFrame(...)

    f:Hide()

    return f
end

function Addon:GetButtonIcon(frame)
    if frame then
        local icon = frame.icon
        if type(icon) == 'table' and icon.GetTexture then
            return icon
        end

        local name = frame:GetName()
        if name then
            icon = _G[name .. 'Icon'] or _G[name .. 'IconTexture']

            if type(icon) == 'table' and icon.GetTexture then
                return icon
            end
        end
    end
end

-- exports
_G[AddonName] = Addon