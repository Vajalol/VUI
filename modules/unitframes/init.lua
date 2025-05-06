-- VUI UnitFrames Module - Initialization
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create the module using the module API
local UnitFrames = VUI.ModuleAPI:CreateModule("unitframes")

-- Get configuration options for main UI integration
function UnitFrames:GetConfig()
    local config = {
        name = "UnitFrames",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable UnitFrames",
                desc = "Enable or disable the UnitFrames module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            style = {
                type = "select",
                name = "Frame Style",
                desc = "Select the style for unit frames",
                values = {
                    ["modern"] = "Modern",
                    ["classic"] = "Classic",
                    ["minimal"] = "Minimal"
                },
                get = function() return self.db.style end,
                set = function(_, value) 
                    self.db.style = value
                    self:ApplyStyle()
                end,
                order = 2
            },
            classColoredBars = {
                type = "toggle",
                name = "Class Colored Bars",
                desc = "Use class colors for health bars",
                get = function() return self.db.classColoredBars end,
                set = function(_, value) 
                    self.db.classColoredBars = value
                    self:UpdateAllFrames()
                end,
                order = 3
            },
            showPortraits = {
                type = "toggle",
                name = "Show Portraits",
                desc = "Show unit portraits in frames",
                get = function() return self.db.showPortraits end,
                set = function(_, value) 
                    self.db.showPortraits = value
                    self:UpdatePortraits()
                end,
                order = 4
            },
            configButton = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open detailed configuration panel",
                func = function()
                    -- This would open a detailed config panel
                    if self.ShowAdvancedConfig then
                        self:ShowAdvancedConfig()
                    end
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
-- Module config registration is done later with extended options

-- Set up module defaults
local defaults = {
    enabled = true,
    style = "modern", -- modern, classic, minimal
    scale = 1.0,
    classColoredBars = true,
    classColoredBorders = false,
    showPortraits = true,
    useClassPortraits = false,
    showPvPIndicator = true,
    showRoleIcon = true,
    showGroupNumber = true,
    showTargetHighlight = true,
    
    -- Animation settings
    enableSmoothUpdates = true,
    animationDuration = 0.3,
    useFadeAnimations = true,
    showCombatAnimations = true,
    showHealthChangeAnimations = true,
    showPowerChangeAnimations = true,
    frames = {
        player = {
            enabled = true,
            scale = 1.0,
            width = 220,
            height = 55,
            showPowerPercent = true,
            showHealthPercent = true,
            position = {"CENTER", "UIParent", "CENTER", -280, -140},
            customText = "%HEALTH_CURRENT% / %HEALTH_MAX%",
            showPowerValue = true,
            showCombatIndicator = true,
            showRestingIndicator = true,
            showFullHPIndicator = true,
            showLeaderIndicator = true,
            showPvPTimer = true,
            nameLength = 20,
            nameAbbreviate = false
        },
        target = {
            enabled = true,
            scale = 1.0,
            width = 220,
            height = 55,
            showPowerPercent = true,
            showHealthPercent = true,
            position = {"CENTER", "UIParent", "CENTER", 280, -140},
            customText = "%HEALTH_CURRENT% / %HEALTH_MAX%",
            showPowerValue = true,
            showDetailedInfo = true,
            classificationIndicator = true,
            nameLength = 20,
            nameAbbreviate = false
        },
        targettarget = {
            enabled = true,
            scale = 0.8,
            width = 140,
            height = 36,
            showPowerPercent = false,
            showHealthPercent = true,
            position = {"TOPLEFT", "VUITargetFrame", "BOTTOMLEFT", 0, -18},
            nameLength = 12,
            nameAbbreviate = true
        },
        pet = {
            enabled = true,
            scale = 0.8,
            width = 140,
            height = 36,
            showPowerPercent = false,
            showHealthPercent = true,
            position = {"TOPRIGHT", "VUIPlayerFrame", "BOTTOMRIGHT", 0, -18},
            nameLength = 12,
            nameAbbreviate = true
        },
        focus = {
            enabled = true,
            scale = 0.9,
            width = 180,
            height = 42,
            showPowerPercent = false,
            showHealthPercent = true,
            position = {"LEFT", "UIParent", "LEFT", 20, 0},
            customText = "%HEALTH_CURRENT% / %HEALTH_MAX%",
            showPowerValue = false,
            nameLength = 16,
            nameAbbreviate = true
        },
        party = {
            enabled = true,
            scale = 0.9,
            width = 180,
            height = 42,
            showPowerPercent = false,
            showHealthPercent = true,
            showAuras = true,
            showRoleIcon = true,
            showTargetHighlight = true,
            vertical = false,
            spacing = 5,
            position = {"TOPLEFT", "UIParent", "TOPLEFT", 20, -200},
            nameLength = 12,
            nameAbbreviate = true,
            showRaidTargetIndicator = true,
            showGroupNumber = true
        },
        boss = {
            enabled = true,
            scale = 0.9,
            width = 180,
            height = 42,
            showPowerPercent = false,
            showHealthPercent = true,
            showAuras = true,
            vertical = true,
            spacing = 25,
            position = {"RIGHT", "UIParent", "RIGHT", -100, 0},
            showTargetHighlight = true,
            nameLength = 16,
            nameAbbreviate = false
        },
        arena = {
            enabled = true,
            scale = 0.9,
            width = 180,
            height = 42,
            showPowerPercent = false,
            showHealthPercent = true,
            showSpecIcon = true,
            showTrinketIcon = true,
            vertical = true,
            spacing = 25,
            position = {"RIGHT", "UIParent", "RIGHT", -100, 0},
            showTargetHighlight = true,
            nameLength = 16,
            nameAbbreviate = false
        }
    },
    auras = {
        player = {
            buffs = {
                enabled = true,
                perRow = 8,
                size = 30,
                spacing = 2,
                growDirection = "RIGHT",
                position = {"TOPRIGHT", "VUIPlayerFrame", "TOPLEFT", -10, 0}
            },
            debuffs = {
                enabled = true,
                perRow = 8,
                size = 30,
                spacing = 2,
                growDirection = "RIGHT",
                position = {"BOTTOMRIGHT", "VUIPlayerFrame", "BOTTOMLEFT", -10, 0}
            }
        },
        target = {
            buffs = {
                enabled = true,
                perRow = 8,
                size = 30,
                spacing = 2,
                growDirection = "LEFT",
                position = {"TOPLEFT", "VUITargetFrame", "TOPRIGHT", 10, 0}
            },
            debuffs = {
                enabled = true,
                perRow = 8,
                size = 30,
                spacing = 2,
                growDirection = "LEFT",
                position = {"BOTTOMLEFT", "VUITargetFrame", "BOTTOMRIGHT", 10, 0}
            }
        },
        focus = {
            buffs = {
                enabled = true,
                perRow = 6,
                size = 24,
                spacing = 2,
                growDirection = "RIGHT",
                position = {"TOPLEFT", "VUIFocusFrame", "BOTTOMLEFT", 0, -5}
            },
            debuffs = {
                enabled = true,
                perRow = 6,
                size = 24,
                spacing = 2,
                growDirection = "RIGHT",
                position = {"BOTTOMLEFT", "VUIFocusFrame", "TOPLEFT", 0, 5}
            }
        }
    },
    castbar = {
        player = {
            enabled = true,
            scale = 1.0,
            width = 220,
            height = 22,
            position = {"CENTER", "UIParent", "CENTER", 0, -225},
            showIcon = true,
            showShield = true,
            showTimer = true,
            attachToFrame = false
        },
        target = {
            enabled = true,
            scale = 1.0,
            width = 220,
            height = 22,
            position = {"CENTER", "UIParent", "CENTER", 0, -200},
            showIcon = true,
            showShield = true,
            showTimer = true,
            attachToFrame = false
        },
        focus = {
            enabled = true,
            scale = 0.9,
            width = 180,
            height = 20,
            position = {"TOP", "VUIFocusFrame", "BOTTOM", 0, -5},
            showIcon = true,
            showShield = true,
            showTimer = true,
            attachToFrame = true
        }
    },
    colors = {
        health = {
            tapped = {r = 0.5, g = 0.5, b = 0.5, a = 0.7},
            disconnected = {r = 0.6, g = 0.6, b = 0.6, a = 0.7},
            reaction = {
                hostile = {r = 0.9, g = 0.2, b = 0.3, a = 1.0},
                neutral = {r = 0.9, g = 0.8, b = 0.1, a = 1.0},
                friendly = {r = 0.2, g = 0.8, b = 0.2, a = 1.0}
            }
        },
        power = {
            MANA = {r = 0.3, g = 0.5, b = 0.9, a = 1.0},
            RAGE = {r = 0.9, g = 0.2, b = 0.3, a = 1.0},
            FOCUS = {r = 0.9, g = 0.5, b = 0.1, a = 1.0},
            ENERGY = {r = 0.9, g = 0.9, b = 0.3, a = 1.0},
            RUNIC_POWER = {r = 0.0, g = 0.8, b = 0.9, a = 1.0},
            LUNAR_POWER = {r = 0.3, g = 0.5, b = 0.9, a = 1.0},
            MAELSTROM = {r = 0.0, g = 0.5, b = 0.9, a = 1.0},
            INSANITY = {r = 0.7, g = 0.4, b = 0.9, a = 1.0},
            FURY = {r = 0.8, g = 0.4, b = 0.0, a = 1.0},
            PAIN = {r = 0.9, g = 0.2, b = 0.5, a = 1.0}
        },
        castbar = {
            standard = {r = 0.2, g = 0.7, b = 0.9, a = 1.0},
            uninterruptible = {r = 0.7, g = 0.7, b = 0.7, a = 1.0},
            success = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            failed = {r = 0.8, g = 0.2, b = 0.2, a = 1.0}
        }
    }
}

-- Initialize module settings
UnitFrames.settings = VUI.ModuleAPI:InitializeModuleSettings("unitframes", defaults)

-- Create db reference for consistent API across modules
UnitFrames.db = UnitFrames.settings

-- Register module configuration
local config = {
    type = "group",
    name = "UnitFrames",
    desc = "Configuration for the UnitFrames module",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable UnitFrames",
            order = 1,
            get = function() return VUI:IsModuleEnabled("unitframes") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("unitframes")
                else
                    VUI:DisableModule("unitframes")
                end
            end,
        },
        style = {
            type = "select",
            name = "Style",
            desc = "Select the UnitFrames style",
            order = 2,
            values = {
                ["modern"] = "Modern",
                ["classic"] = "Classic",
                ["minimal"] = "Minimal"
            },
            get = function() return UnitFrames.settings.style end,
            set = function(_, value)
                UnitFrames.settings.style = value
                UnitFrames:UpdateFrames()
            end,
        },
        scale = {
            type = "range",
            name = "Global Scale",
            desc = "Adjust the global scale of the UnitFrames",
            min = 0.5,
            max = 2.0,
            step = 0.05,
            order = 3,
            get = function() return UnitFrames.settings.scale end,
            set = function(_, value)
                UnitFrames.settings.scale = value
                UnitFrames:UpdateFrames()
            end,
        },
        classColoredBars = {
            type = "toggle",
            name = "Class Colored Health Bars",
            desc = "Color health bars based on unit class",
            order = 4,
            get = function() return UnitFrames.settings.classColoredBars end,
            set = function(_, value)
                UnitFrames.settings.classColoredBars = value
                UnitFrames:UpdateFrames()
            end,
        },
        classColoredBorders = {
            type = "toggle",
            name = "Class Colored Borders",
            desc = "Color frame borders based on unit class",
            order = 5,
            get = function() return UnitFrames.settings.classColoredBorders end,
            set = function(_, value)
                UnitFrames.settings.classColoredBorders = value
                UnitFrames:UpdateFrames()
            end,
        },
        showPortraits = {
            type = "toggle",
            name = "Show Portraits",
            desc = "Show unit portraits on frames",
            order = 6,
            get = function() return UnitFrames.settings.showPortraits end,
            set = function(_, value)
                UnitFrames.settings.showPortraits = value
                UnitFrames:UpdateFrames()
            end,
        },
        useClassPortraits = {
            type = "toggle",
            name = "Use Class Icons as Portraits",
            desc = "Use class icons instead of character portraits",
            order = 7,
            get = function() return UnitFrames.settings.useClassPortraits end,
            set = function(_, value)
                UnitFrames.settings.useClassPortraits = value
                UnitFrames:UpdateFrames()
            end,
            disabled = function() return not UnitFrames.settings.showPortraits end,
        },
        frameOptions = {
            type = "group",
            name = "Frame Options",
            desc = "Configure individual unit frames",
            order = 8,
            args = {
                -- Individual frame settings will be added by UnitFrames:SetupConfig()
            }
        }
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("unitframes", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("unitframes", "vuiuf", function(input)
    if input and input:trim() == "reset" then
        UnitFrames:ResetPositions()
    elseif input and input:trim() == "toggle" then
        if VUI:IsModuleEnabled("unitframes") then
            VUI:DisableModule("unitframes")
        else
            VUI:EnableModule("unitframes")
        end
    elseif input and input:trim() == "unlock" then
        UnitFrames:UnlockFrames()
    elseif input and input:trim() == "lock" then
        UnitFrames:LockFrames()
    else
        VUI:Print("UnitFrames Commands:")
        VUI:Print("  /vuiuf reset - Reset all frame positions")
        VUI:Print("  /vuiuf toggle - Toggle UnitFrames on/off")
        VUI:Print("  /vuiuf unlock - Unlock frames for movement")
        VUI:Print("  /vuiuf lock - Lock frames")
    end
end)

-- Initialize module
function UnitFrames:Initialize()
    -- Register with VUI
    VUI:Print("UnitFrames module initialized")
    
    -- Ensure db reference is set up properly
    if not self.db then
        self.db = self.settings or {}
    end
    
    -- Set up configuration for each frame type
    self:SetupConfig()
    
    -- Initialize ThemeIntegration module
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Register for UI integration when the UI is loaded
    VUI.ModuleAPI:EnableModuleUI("unitframes", function(module)
        module:CreateFrames()
    end)
    
    -- Register events
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTarget")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", "UpdateFocus")
    self:RegisterEvent("UNIT_HEALTH", "UpdateHealth")
    self:RegisterEvent("UNIT_MAXHEALTH", "UpdateHealth")
    self:RegisterEvent("UNIT_POWER_UPDATE", "UpdatePower")
    self:RegisterEvent("UNIT_MAXPOWER", "UpdatePower")
    self:RegisterEvent("UNIT_NAME_UPDATE", "UpdateName")
    self:RegisterEvent("UNIT_LEVEL", "UpdateLevel")
    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateClassification")
    self:RegisterEvent("UNIT_FACTION", "UpdateReaction")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdatePortrait")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllFrames")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateAllFrames")
    self:RegisterEvent("PARTY_MEMBER_ENABLE", "UpdateParty")
    self:RegisterEvent("PARTY_MEMBER_DISABLE", "UpdateParty")
    
    -- Combat state for animations
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeaveCombat")
    
    -- Events for improved animation handling
    self:RegisterEvent("UNIT_DISPLAYPOWER", "UpdatePowerType")
    self:RegisterEvent("UNIT_COMBAT", "OnUnitCombatEvent")
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", "UpdateThreatState")
end

-- Enable module
function UnitFrames:Enable()
    self.enabled = true
    
    -- Create frames if they don't exist
    if not self.framesCreated and self.CreateFrames then
        self:CreateFrames()
    end
    
    -- Show all frames
    self:ShowFrames()
    
    VUI:Print("UnitFrames module enabled")
end

-- Disable module
function UnitFrames:Disable()
    self.enabled = false
    
    -- Hide all frames
    self:HideFrames()
    
    VUI:Print("UnitFrames module disabled")
end

-- Set up the configuration options for each frame type
function UnitFrames:SetupConfig()
    -- Add each frame's configuration to the main config
    local frameTypes = {"player", "target", "targettarget", "pet", "focus", "party", "boss", "arena"}
    
    for _, frameType in ipairs(frameTypes) do
        config.args.frameOptions.args[frameType] = {
            type = "group",
            name = frameType:gsub("^%l", string.upper) .. " Frame",
            desc = "Configure the " .. frameType .. " frame",
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable or disable this frame",
                    order = 1,
                    get = function() return self.settings.frames[frameType].enabled end,
                    set = function(_, value)
                        self.settings.frames[frameType].enabled = value
                        self:UpdateFrameVisibility(frameType)
                    end,
                },
                scale = {
                    type = "range",
                    name = "Scale",
                    desc = "Adjust the scale of this frame",
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    order = 2,
                    get = function() return self.settings.frames[frameType].scale end,
                    set = function(_, value)
                        self.settings.frames[frameType].scale = value
                        self:UpdateFrameScale(frameType)
                    end,
                },
                width = {
                    type = "range",
                    name = "Width",
                    desc = "Adjust the width of this frame",
                    min = 40,
                    max = 400,
                    step = 1,
                    order = 3,
                    get = function() return self.settings.frames[frameType].width end,
                    set = function(_, value)
                        self.settings.frames[frameType].width = value
                        self:UpdateFrameSize(frameType)
                    end,
                },
                height = {
                    type = "range",
                    name = "Height",
                    desc = "Adjust the height of this frame",
                    min = 20,
                    max = 200,
                    step = 1,
                    order = 4,
                    get = function() return self.settings.frames[frameType].height end,
                    set = function(_, value)
                        self.settings.frames[frameType].height = value
                        self:UpdateFrameSize(frameType)
                    end,
                },
                resetPosition = {
                    type = "execute",
                    name = "Reset Position",
                    desc = "Reset the position of this frame to its default",
                    order = 5,
                    func = function()
                        self:ResetPosition(frameType)
                    end,
                }
            }
        }
    end
end

-- Event registration helper
function UnitFrames:RegisterEvent(event, method)
    if type(method) == "string" and self[method] then
        method = self[method]
    end
    
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    self.eventFrame:RegisterEvent(event)
    self[event] = method
end

-- Register the module with VUI
VUI.unitframes = UnitFrames