local addonName, VUI = ...

-- Register the SpellNotifications module
local module = VUI:NewModule("SpellNotifications", "AceEvent-3.0")

-- Reference to frames created in core.lua - accessible via module.frames in core.lua
module.frames = {}

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        size = 64,
        alpha = 1.0,
        sound = true,
        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\spell_notification.ogg",
        interruptSound = true,
        dispelSound = true,
        importantSound = true,
        showSpellIcon = true,
        showAnimations = true,
        notifyAllInterrupts = true,      -- Notify for all interrupts regardless of spell list
        notifyAllDispels = true,         -- Notify for all dispels regardless of spell list
        notifyAllHostileDebuffs = false, -- Notify for all hostile debuffs (can be noisy)
        customSpells = {},               -- Storage for custom important spells
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
                border = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga",
                sound = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\notification.ogg",
                sounds = {
                    interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\interrupt.ogg",
                    dispel = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\dispel.ogg",
                    important = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\important.ogg",
                    default = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\spell_notification.ogg"
                }
            },
            thunderstorm = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification.tga",
                color = {0, 0.6, 1, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga",
                sound = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\notification.ogg",
                sounds = {
                    interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\interrupt.ogg",
                    dispel = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\dispel.ogg",
                    important = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\important.ogg",
                    default = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\spell_notification.ogg"
                }
            },
            arcanemystic = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\notification.tga",
                color = {0.8, 0, 1, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\glow.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\border.tga",
                sound = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\notification.ogg",
                sounds = {
                    interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\interrupt.ogg",
                    dispel = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\dispel.ogg",
                    important = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\important.ogg",
                    default = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\spell_notification.ogg"
                }
            },
            felenergy = {
                texture = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\notification.tga",
                color = {0, 1, 0, 1},
                glow = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\glow.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\border.tga",
                sound = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\notification.ogg",
                sounds = {
                    interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\interrupt.ogg",
                    dispel = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\dispel.ogg",
                    important = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\important.ogg",
                    default = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\spell_notification.ogg"
                }
            }
        }
    }
}

function module:OnInitialize()
    self.db = VUI.db:RegisterNamespace("SpellNotifications", defaults)
    self:SetEnabledState(self.db.profile.enabled)
    
    -- Initialize the spell list
    if self.InitializeSpellList then
        self:InitializeSpellList()
    end
end

function module:OnEnable()
    -- Will be implemented in core.lua
    
    -- Register slash command for the spell management UI
    self:RegisterChatCommand("vuispells", function() self:OpenSpellManagementUI() end)
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
            soundHeader = {
                order = 2,
                type = "header",
                name = "Sound Settings"
            },
            sound = {
                order = 3,
                type = "toggle",
                name = "Enable Sounds",
                desc = "Enable or disable notification sounds",
                get = function() return self.db.profile.sound end,
                set = function(_, value)
                    self.db.profile.sound = value
                end,
                width = "full"
            },
            -- Note: WoW API doesn't support direct volume control for addon sounds
            -- Volume is controlled through game sound settings
            
            interruptSound = {
                order = 5,
                type = "toggle",
                name = "Interrupt Sounds",
                desc = "Play a sound when you successfully interrupt a spell",
                get = function() return self.db.profile.interruptSound end,
                set = function(_, value)
                    self.db.profile.interruptSound = value
                end,
                width = "full",
                disabled = function() return not self.db.profile.sound end
            },
            dispelSound = {
                order = 6,
                type = "toggle",
                name = "Dispel Sounds",
                desc = "Play a sound when you successfully dispel or purge a buff",
                get = function() return self.db.profile.dispelSound end,
                set = function(_, value)
                    self.db.profile.dispelSound = value
                end,
                width = "full",
                disabled = function() return not self.db.profile.sound end
            },
            importantSound = {
                order = 7,
                type = "toggle",
                name = "Important Debuff Sounds",
                desc = "Play a sound when an important debuff is applied to you",
                get = function() return self.db.profile.importantSound end,
                set = function(_, value)
                    self.db.profile.importantSound = value
                end,
                width = "full",
                disabled = function() return not self.db.profile.sound end
            },
            visualHeader = {
                order = 8,
                type = "header",
                name = "Visual Settings"
            },
            size = {
                order = 9,
                type = "range",
                name = "Size",
                desc = "Set the size of the notification icon",
                min = 32,
                max = 128,
                step = 4,
                get = function() return self.db.profile.size end,
                set = function(_, value)
                    self.db.profile.size = value
                    -- Update frame size if it exists
                    if self.frames and self.frames[1] then
                        self.frames[1]:SetSize(value, value)
                        self.frames[1].glow:SetSize(value, value)
                    end
                end,
                width = "full"
            },
            alpha = {
                order = 10,
                type = "range",
                name = "Alpha",
                desc = "Set the transparency of the notification icon",
                min = 0.1,
                max = 1,
                step = 0.05,
                get = function() return self.db.profile.alpha end,
                set = function(_, value)
                    self.db.profile.alpha = value
                end,
                width = "full"
            },
            showSpellIcon = {
                order = 10.1,
                type = "toggle",
                name = "Show Spell Icon",
                desc = "Display the spell icon in the notification",
                get = function() return self.db.profile.showSpellIcon end,
                set = function(_, value)
                    self.db.profile.showSpellIcon = value
                    -- Update visibility if frame exists
                    if self.frames and self.frames[1] and self.frames[1].spellIcon then
                        if value then
                            self.frames[1].spellIcon:Show()
                        else
                            self.frames[1].spellIcon:Hide()
                        end
                    end
                end,
                width = "full"
            },
            showAnimations = {
                order = 10.2,
                type = "toggle",
                name = "Show Animations",
                desc = "Enable or disable notification animations",
                get = function() return self.db.profile.showAnimations end,
                set = function(_, value)
                    self.db.profile.showAnimations = value
                end,
                width = "full"
            },
            spellsHeader = {
                order = 10.5,
                type = "header",
                name = "Spell Notification Settings"
            },
            notifyAllInterrupts = {
                order = 10.6,
                type = "toggle",
                name = "Notify All Interrupts",
                desc = "Show notifications for all interrupts, not just those in the important spell list",
                get = function() return self.db.profile.notifyAllInterrupts end,
                set = function(_, value)
                    self.db.profile.notifyAllInterrupts = value
                end,
                width = "full"
            },
            notifyAllDispels = {
                order = 10.7,
                type = "toggle",
                name = "Notify All Dispels",
                desc = "Show notifications for all dispels/purges, not just those in the important spell list",
                get = function() return self.db.profile.notifyAllDispels end,
                set = function(_, value)
                    self.db.profile.notifyAllDispels = value
                end,
                width = "full"
            },
            notifyAllHostileDebuffs = {
                order = 10.8,
                type = "toggle",
                name = "Notify All Hostile Debuffs",
                desc = "Show notifications for all hostile debuffs applied to you (can be noisy in combat)",
                get = function() return self.db.profile.notifyAllHostileDebuffs end,
                set = function(_, value)
                    self.db.profile.notifyAllHostileDebuffs = value
                end,
                width = "full"
            },
            openSpellManager = {
                order = 10.9,
                type = "execute",
                name = "Manage Important Spells",
                desc = "Open the spell management UI to customize which spells trigger notifications",
                func = function()
                    self:OpenSpellManagementUI()
                end,
                width = "full"
            },
            positionHeader = {
                order = 11,
                type = "header",
                name = "Position"
            },
            position = {
                order = 12,
                type = "select",
                name = "Anchor Point",
                desc = "Set the anchor point for the notification frame",
                values = {
                    ["CENTER"] = "Center",
                    ["TOP"] = "Top",
                    ["TOPLEFT"] = "Top Left",
                    ["TOPRIGHT"] = "Top Right",
                    ["BOTTOM"] = "Bottom",
                    ["BOTTOMLEFT"] = "Bottom Left",
                    ["BOTTOMRIGHT"] = "Bottom Right",
                    ["LEFT"] = "Left",
                    ["RIGHT"] = "Right"
                },
                get = function() return self.db.profile.position.point end,
                set = function(_, value)
                    self.db.profile.position.point = value
                    -- Update frame position if it exists
                    if self.frames and self.frames[1] then
                        self.frames[1]:ClearAllPoints()
                        self.frames[1]:SetPoint(
                            value,
                            UIParent,
                            value,
                            self.db.profile.position.x,
                            self.db.profile.position.y
                        )
                    end
                end,
                width = "full"
            },
            xOffset = {
                order = 13,
                type = "range",
                name = "X Offset",
                desc = "Set the horizontal offset",
                min = -500,
                max = 500,
                step = 1,
                get = function() return self.db.profile.position.x end,
                set = function(_, value)
                    self.db.profile.position.x = value
                    -- Update frame position if it exists
                    if self.frames and self.frames[1] then
                        self.frames[1]:ClearAllPoints()
                        self.frames[1]:SetPoint(
                            self.db.profile.position.point,
                            UIParent,
                            self.db.profile.position.point,
                            value,
                            self.db.profile.position.y
                        )
                    end
                end,
                width = "full"
            },
            yOffset = {
                order = 14,
                type = "range",
                name = "Y Offset",
                desc = "Set the vertical offset",
                min = -500,
                max = 500,
                step = 1,
                get = function() return self.db.profile.position.y end,
                set = function(_, value)
                    self.db.profile.position.y = value
                    -- Update frame position if it exists
                    if self.frames and self.frames[1] then
                        self.frames[1]:ClearAllPoints()
                        self.frames[1]:SetPoint(
                            self.db.profile.position.point,
                            UIParent,
                            self.db.profile.position.point,
                            self.db.profile.position.x,
                            value
                        )
                    end
                end,
                width = "full"
            }
        }
    }
end