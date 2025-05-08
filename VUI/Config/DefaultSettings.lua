-- VUI Default Settings Manager
-- Provides optimized default settings for all modules

local AddonName, VUI = ...
local DefaultSettings = VUI:NewModule("DefaultSettings")

-- Define default settings for all modules
-- These will be applied during first-time setup
DefaultSettings.moduleDefaults = {
    -- Core Module defaults
    General = {
        minimap = {
            scale = 1.0,
            position = "TOPRIGHT",
            enableBlizzard = false
        },
        fonts = {
            global = "Interface\\AddOns\\VUI\\Media\\Fonts\\expressway.ttf",
            size = 12
        },
        colors = {
            primary = {r = 0.917, g = 0, b = 1, a = 1}, -- Vortex purple
            secondary = {r = 0, g = 0.635, b = 1, a = 1} -- VUI blue
        }
    },
    
    Unitframes = {
        enabled = true,
        playerFrame = {
            scale = 1.0,
            width = 250,
            height = 45,
            position = {"CENTER", UIParent, "CENTER", -270, -100}
        },
        targetFrame = {
            scale = 1.0,
            width = 250,
            height = 45,
            position = {"CENTER", UIParent, "CENTER", 270, -100}
        },
        partyFrames = {
            enabled = true,
            scale = 0.9,
            width = 200,
            height = 40,
            position = {"LEFT", UIParent, "LEFT", 15, 0}
        },
        raidFrames = {
            enabled = true,
            scale = 0.8,
            width = 80,
            height = 40,
            position = {"TOPLEFT", UIParent, "TOPLEFT", 15, -150}
        }
    },
    
    Nameplates = {
        enabled = true,
        style = "VUI",
        width = 120,
        height = 14,
        targetScale = 1.2,
        showCastbar = true,
        showHealthText = true,
        classColors = true
    },
    
    Actionbar = {
        enabled = true,
        layout = "standard", -- "standard", "centered", "extended"
        scale = 1.0,
        padding = 2,
        rows = 3,
        buttonsPerRow = 12,
        buttonSize = 32,
        showHotkeys = true,
        showMacroNames = false
    },
    
    Castbars = {
        enabled = true,
        player = {
            width = 250,
            height = 25,
            position = {"CENTER", UIParent, "CENTER", 0, -235}
        },
        target = {
            width = 250,
            height = 20,
            position = {"CENTER", UIParent, "CENTER", 0, 235}
        }
    },
    
    Tooltip = {
        enabled = true,
        scale = 1.0,
        position = "BOTTOMRIGHT",
        showSpellID = true,
        showItemLevel = true,
        showRank = true
    },
    
    Buffs = {
        enabled = true,
        scale = 1.0,
        buffSize = 32,
        debuffSize = 32,
        position = {"TOPRIGHT", UIParent, "TOPRIGHT", -15, -15},
        growthDirection = "LEFT_DOWN",
        showDuration = true
    },
    
    Map = {
        enabled = true,
        scale = 1.0,
        transparency = 0.8,
        coordinates = true,
        questObjectives = true
    },
    
    Chat = {
        enabled = true,
        fontSize = 12,
        width = 400,
        height = 180,
        position = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 15, 15},
        tabsPosition = "TOP",
        fadeInactiveChat = true,
        timeStamps = true
    },
    
    Misc = {
        errorFrame = {
            enabled = true,
            position = {"TOP", UIParent, "TOP", 0, -30},
            filterCommon = true
        },
        lootFrame = {
            improved = true,
            position = {"CENTER", UIParent, "CENTER", 0, 0}
        },
        durability = {
            position = {"TOPRIGHT", UIParent, "TOPRIGHT", -200, -15},
            showAlways = false
        }
    },
    
    -- VModule defaults
    VUIBuffs = {
        enabled = true,
        style = "icon", -- "icon" or "bar"
        growthDirection = "RIGHT_DOWN",
        size = 32,
        showDuration = true,
        position = {"TOPRIGHT", UIParent, "TOPRIGHT", -15, -15}
    },
    
    VUIAnyFrame = {
        enabled = true,
        savedFrames = {}
    },
    
    VUIKeystones = {
        enabled = true,
        position = {"CENTER", UIParent, "CENTER", 0, 0},
        showInChat = true,
        announceKey = true
    },
    
    VUICC = {
        enabled = true,
        scale = 1.0,
        position = {"CENTER", UIParent, "CENTER", 0, 100},
        showIcons = true,
        showText = true,
        showTimer = true
    },
    
    VUICD = {
        enabled = true,
        style = "GRID", -- "GRID", "BAR", "ICON"
        scale = 1.0,
        position = {"CENTER", UIParent, "CENTER", 0, -100},
        showText = true,
        showCooldownSpiral = true,
        groupByCategory = true
    },
    
    VUIIDs = {
        enabled = true,
        showTooltip = true,
        showChat = false,
        chatChannel = "SELF"
    },
    
    VUIGfinder = {
        enabled = true,
        enhancedFiltering = true,
        savedSearches = true,
        oneClickSignup = true
    },
    
    VUITGCD = {
        enabled = true,
        size = 6,
        position = {"CENTER", UIParent, "CENTER", 0, -60},
        color = {r = 0.7, g = 0.7, b = 0.7, a = 0.7}
    },
    
    VUIAuctionator = {
        enabled = true,
        compactView = true,
        enhancedSearch = true,
        showMarketValue = true,
        alertPriceThreshold = 0.8 -- Alert at 80% of market value
    },
    
    VUINotifications = {
        enabled = true,
        position = {"TOP", UIParent, "TOP", 0, -50},
        duration = 3,
        size = 1.0,
        showSound = true,
        events = {
            rareSpawn = true,
            groupInvite = true,
            battlegroundQueue = true,
            itemSold = true,
            friendOnline = true,
            guildChat = false,
            instanceReset = true
        }
    },
    
    VUIScrollingText = {
        enabled = true,
        style = "dynamic", -- "static", "dynamic", "fountain"
        scale = 1.0,
        speed = 1.5,
        position = {"CENTER", UIParent, "CENTER", 0, 100},
        critScale = 1.5,
        showIcon = true,
        showSchoolColors = true,
        mergeThreshold = 0.3
    },
    
    VUIepf = {
        enabled = true,
        style = "enhanced", -- "default", "enhanced", "minimal"
        scale = 1.0,
        position = {"CENTER", UIParent, "CENTER", 0, 0},
        showDetails = true,
        showPetFrame = true,
        classTheme = true
    },
    
    VUIConsumables = {
        enabled = true,
        position = {"CENTER", UIParent, "CENTER", 0, 200},
        showIcons = true,
        showDuration = true,
        groupByType = true,
        alertThreshold = 300 -- 5 minutes
    },
    
    VUIPositionOfPower = {
        enabled = true,
        scale = 1.0,
        position = {"CENTER", UIParent, "CENTER", 0, 150},
        showIcon = true,
        showBar = true,
        showText = true
    },
    
    VUIMissingRaidBuffs = {
        enabled = true,
        position = {"TOPLEFT", UIParent, "TOPLEFT", 15, -15},
        showIcons = true,
        showNames = true,
        showAlways = false,
        alertInChat = true
    },
    
    VUIMouseFireTrail = {
        enabled = false, -- Disabled by default as it's purely cosmetic
        style = "vortex", -- "fire", "arcane", "vortex"
        scale = 1.0,
        opacity = 0.7,
        length = 1.0
    },
    
    VUIHealerMana = {
        enabled = true,
        showInParty = true,
        showInRaid = true,
        position = {"CENTER", UIParent, "CENTER", -200, 0},
        scale = 1.0,
        sortOrder = "ASCENDING"
    },
    
    VUIPlater = {
        enabled = true,
        useVUIStyle = true,
        showResourceBar = true,
        showCastbar = true,
        showAuras = true,
        friendlyAlpha = 1.0,
        enemyAlpha = 1.0,
        threatColor = true
    }
}

-- Apply default settings to a specific module
function DefaultSettings:ApplyDefaultsToModule(moduleName)
    if not self.moduleDefaults[moduleName] then
        VUI:Print("No default settings found for module: " .. moduleName)
        return
    end
    
    -- Check if namespace exists
    if not VUI.db.namespaces[moduleName] then
        VUI:Print("Error: Cannot find settings database for module: " .. moduleName)
        return
    end
    
    -- Apply defaults to the module
    for key, value in pairs(self.moduleDefaults[moduleName]) do
        VUI.db.namespaces[moduleName].profile[key] = value
    end
    
    VUI:Print("Applied default settings to " .. moduleName)
end

-- Apply default settings to all modules
function DefaultSettings:ApplyAllDefaults()
    VUI:Print("Applying optimized default settings to all VUI modules...")
    
    for moduleName, defaults in pairs(self.moduleDefaults) do
        self:ApplyDefaultsToModule(moduleName)
    end
    
    VUI:Print("All default settings applied successfully!")
end

-- Function to be called from the installation wizard
function DefaultSettings:ConfigureFirstTimeSetup()
    self:ApplyAllDefaults()
    VUI:Print("First-time setup: Applied recommended settings to all modules")
end

-- Register with the installation wizard
function DefaultSettings:OnInitialize()
    -- We'll integrate with the installation wizard later
end

-- Export the module
VUI.DefaultSettings = DefaultSettings