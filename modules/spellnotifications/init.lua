local addonName, VUI = ...

-- Register the SpellNotifications module
local module = VUI:NewModule("SpellNotifications", "AceEvent-3.0")

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        size = 64,
        alpha = 1.0,
        sound = true,
        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\spell_notification.ogg",
        position = {
            point = "CENTER",
            x = 0,
            y = 100
        },
        -- Theme-specific settings
        theme = {
            phoenixflame = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\notification.tga",
                color = {1, 0.5, 0, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga",
            },
            thunderstorm = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification.tga",
                color = {0, 0.6, 1, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga",
            },
            arcanemystic = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\notification.tga",
                color = {0.8, 0, 1, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\glow.tga",
            },
            felenergy = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\notification.tga",
                color = {0, 1, 0, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\glow.tga",
            }
        }
    }
}

function module:OnInitialize()
    self.db = VUI.db:RegisterNamespace("SpellNotifications", defaults)
    self:SetEnabledState(self.db.profile.enabled)
end

function module:OnEnable()
    -- Will be implemented in core.lua
end

function module:OnDisable()
    -- Will be implemented in core.lua
end

function module:GetConfig()
    return {
        order = 16,
        type = "group",
        name = "Spell Notifications",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the Spell Notifications module",
                get = function() return self.db.profile.enabled end,
                set = function(_, value)
                    self.db.profile.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                width = "full"
            },
            -- Additional config options will be added
        }
    }
end