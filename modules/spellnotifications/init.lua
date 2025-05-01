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
        customSpells = {},               -- Storage for custom important spells (serialized)
        maxNotifications = 3,            -- Maximum number of notifications visible at once
        notificationSpacing = 10,        -- Spacing between notifications in pixels
        useFramePooling = true,          -- Use frame pooling system for improved performance
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
    
    -- We'll use the main /vui command with subcommands instead of registering our own commands
    -- Integration with the main command handler will be done in core/slashcommands.lua
    
    -- Register profile change callback
    VUI.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    VUI.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    VUI.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

-- Process chat commands (called from main slash command handler)
function module:ProcessChatCommand(input)
    local command, rest = self:GetArgs(input, 2)
    
    -- Handle different commands
    if not command or command == "help" then
        -- Show help message
        print("|cFF00FF00VUI Spell Notifications Commands:|r")
        print("  |cFFFFFF00/vui spells|r - Open the spell management UI")
        print("  |cFFFFFF00/vui spells list|r - List your custom spells")
        print("  |cFFFFFF00/vui spells add [spellID] [type] [priority]|r - Add a custom spell")
        print("  |cFFFFFF00/vui spells remove [spellID]|r - Remove a custom spell")
        print("  |cFFFFFF00/vui spells test [spellID] [type]|r - Test a spell notification")
    elseif command == "list" then
        -- List custom spells
        local count = 0
        print("|cFF00FF00Your Custom Spells:|r")
        for id, data in pairs(self.CustomSpells) do
            count = count + 1
            -- Priority levels
            local priorityText = "Medium"
            if data.priority == 1 then
                priorityText = "Low"
            elseif data.priority == 3 then
                priorityText = "High"
            end
            print(string.format("  %d. |cFFFFFF00%s|r (ID: |cFF00CCFF%d|r, Type: |cFF00CCFF%s|r, Priority: |cFF00CCFF%s|r)", 
                count, data.name, id, data.type, priorityText))
        end
        if count == 0 then
            print("  No custom spells found. Add some with |cFFFFFF00/vui spells add [spellID] [type] [priority]|r")
        end
    elseif command == "add" and rest then
        -- Extract spell info
        local spellID, spellType, priority = strsplit(" ", rest, 3)
        spellID = tonumber(spellID)
        priority = tonumber(priority) or 2
        
        if not spellID then
            print("|cFFFF0000Invalid spell ID. Usage: /vui spells add [spellID] [type] [priority]|r")
            return
        end
        
        if not spellType or not self.SpellCategories[spellType] then
            -- List valid spell types
            print("|cFFFF0000Invalid spell type. Valid types:|r")
            for key, name in pairs(self.SpellCategories) do
                print("  |cFFFFFF00" .. key .. "|r - " .. name)
            end
            return
        end
        
        -- Add the spell
        self:AddCustomSpell(spellID, spellType, priority)
    elseif command == "remove" and rest then
        -- Extract spell ID
        local spellID = tonumber(rest)
        if not spellID then
            print("|cFFFF0000Invalid spell ID. Usage: /vui spells remove [spellID]|r")
            return
        end
        
        -- Remove the spell
        local success = self:RemoveCustomSpell(spellID)
        if not success then
            print("|cFFFF0000No custom spell found with ID:|r " .. spellID)
        end
    elseif command == "test" and rest then
        -- Extract spell info
        local spellID, spellType = strsplit(" ", rest, 2)
        spellID = tonumber(spellID)
        
        if not spellID then
            print("|cFFFF0000Invalid spell ID. Usage: /vui spells test [spellID] [type]|r")
            return
        end
        
        -- Test the notification
        self:TestNotification(spellID, spellType)
    else
        -- Open the spell management UI by default
        self:OpenSpellManagementUI()
    end
end

-- Handle profile changes
function module:RefreshConfig()
    -- Reinitialize spell list
    if self.InitializeSpellList then
        self:InitializeSpellList()
    end
    
    -- Update frame settings if it exists
    if self.frames and self.frames[1] then
        -- Update size
        self.frames[1]:SetSize(self.db.profile.size, self.db.profile.size)
        self.frames[1].glow:SetSize(self.db.profile.size, self.db.profile.size)
        
        -- Update position
        self.frames[1]:ClearAllPoints()
        self.frames[1]:SetPoint(
            self.db.profile.position.point,
            UIParent,
            self.db.profile.position.point,
            self.db.profile.position.x,
            self.db.profile.position.y
        )
        
        -- Update visibility
        if self.db.profile.showSpellIcon and self.frames[1].spellIcon then
            self.frames[1].spellIcon:Show()
        else
            self.frames[1].spellIcon:Hide()
        end
        
        -- Update theme
        if self.ApplyTheme then
            self:ApplyTheme(self.frames[1])
        end
    end
    
    -- Update enabled state
    self:SetEnabledState(self.db.profile.enabled)
    if self.db.profile.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function module:OnEnable()
    -- Will be implemented in core.lua
    
    -- We already registered our slash commands in OnInitialize
    -- No need to re-register them here
    
    -- Register theme hooks
    self:RegisterThemeHooks()
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
            multiNotificationHeader = {
                order = 10.85,
                type = "header",
                name = "Multi-Notification Settings"
            },
            maxNotifications = {
                order = 10.86,
                type = "range",
                name = "Maximum Notifications",
                desc = "Set the maximum number of notifications visible at once",
                min = 1,
                max = 5,
                step = 1,
                get = function() return self.db.profile.maxNotifications end,
                set = function(_, value)
                    self.db.profile.maxNotifications = value
                end,
                width = "full"
            },
            notificationSpacing = {
                order = 10.87,
                type = "range",
                name = "Notification Spacing",
                desc = "Set the spacing between multiple notifications in pixels",
                min = 0,
                max = 50,
                step = 1,
                get = function() return self.db.profile.notificationSpacing end,
                set = function(_, value)
                    self.db.profile.notificationSpacing = value
                end,
                width = "full"
            },
            performanceHeader = {
                order = 10.89,
                type = "header",
                name = "Performance Settings"
            },
            useFramePooling = {
                order = 10.9,
                type = "toggle",
                name = "Use Frame Pooling",
                desc = "Enable frame pooling system for improved performance and reduced memory usage",
                get = function() 
                    if self.db.profile.useFramePooling == nil then
                        self.db.profile.useFramePooling = true
                    end
                    return self.db.profile.useFramePooling 
                end,
                set = function(_, value)
                    self.db.profile.useFramePooling = value
                    -- Initialize frame pool if it wasn't already
                    if value and self.FramePool and not self.FramePool.initialized then
                        self.FramePool:Initialize()
                        self.FramePool.initialized = true
                    end
                end,
                width = "full"
            },
            framePoolInfo = {
                order = 10.91,
                type = "description",
                name = function()
                    if not self.FramePool or not self.FramePool.GetStats then
                        return "Frame pooling statistics unavailable."
                    end
                    
                    local stats = self.FramePool:GetStats()
                    return string.format(
                        "Frame pooling statistics:\nFrames created: %d\nFrames recycled: %d\nActive frames: %d\nMemory saved: %.2f MB", 
                        stats.framesCreated, 
                        stats.framesRecycled,
                        stats.activeFrames,
                        stats.memoryReduction
                    )
                end,
                hidden = function() return not VUI.debug or not self.db.profile.useFramePooling end,
                width = "full"
            },
            spellManagementHeader = {
                order = 10.95,
                type = "header",
                name = "Spell Management"
            },
            openSpellManager = {
                order = 10.96,
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