local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Module constants
VUICD.Constants = {
    -- Cooldown types
    COOLDOWN_TYPE = {
        DEFENSIVE = "defensive",
        OFFENSIVE = "offensive",
        INTERRUPT = "interrupt",
        UTILITY = "utility",
        COVENANT = "covenant",
        CUSTOM = "custom"
    },
    
    -- Instance types
    INSTANCE_TYPE = {
        NONE = "none",
        PARTY = "party",
        RAID = "raid",
        ARENA = "arena",
        PVP = "pvp",
        SCENARIO = "scenario"
    },
    
    -- Growth directions
    GROWTH_DIRECTION = {
        RIGHT = "RIGHT",
        LEFT = "LEFT",
        UP = "UP",
        DOWN = "DOWN"
    },
    
    -- Icon anchors
    ICON_ANCHOR = {
        TOPLEFT = "TOPLEFT",
        TOP = "TOP",
        TOPRIGHT = "TOPRIGHT",
        RIGHT = "RIGHT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
        BOTTOM = "BOTTOM",
        BOTTOMLEFT = "BOTTOMLEFT",
        LEFT = "LEFT",
        CENTER = "CENTER"
    },
    
    -- Frame strata levels
    FRAME_STRATA = {
        BACKGROUND = "BACKGROUND",
        LOW = "LOW",
        MEDIUM = "MEDIUM",
        HIGH = "HIGH",
        DIALOG = "DIALOG"
    },
    
    -- Status bar positions
    STATUSBAR_POSITION = {
        TOP = "TOP",
        RIGHT = "RIGHT",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT"
    },
    
    -- Default icon size
    DEFAULT_ICON_SIZE = 30,
    
    -- Default spacing
    DEFAULT_SPACING = 2,
    
    -- Default alpha
    DEFAULT_ALPHA = 1.0,
    
    -- Default scale
    DEFAULT_SCALE = 1.0,
    
    -- Default columns
    DEFAULT_COLUMNS = 8,
    
    -- Default font size
    DEFAULT_FONT_SIZE = 12,
    
    -- Addon prefix for sync
    ADDON_PREFIX = "VUICD",
    
    -- Update intervals
    UPDATE_INTERVAL = 0.1,
    SYNC_INTERVAL = 1.0
}

-- Class colors for those that might not have RAID_CLASS_COLORS
if not RAID_CLASS_COLORS then
    VUICD.Constants.CLASS_COLORS = {
        ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43 },
        ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73 },
        ["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45 },
        ["ROGUE"] = { r = 1.00, g = 0.96, b = 0.41 },
        ["PRIEST"] = { r = 1.00, g = 1.00, b = 1.00 },
        ["DEATHKNIGHT"] = { r = 0.77, g = 0.12, b = 0.23 },
        ["SHAMAN"] = { r = 0.00, g = 0.44, b = 0.87 },
        ["MAGE"] = { r = 0.41, g = 0.80, b = 0.94 },
        ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79 },
        ["MONK"] = { r = 0.00, g = 1.00, b = 0.59 },
        ["DRUID"] = { r = 1.00, g = 0.49, b = 0.04 },
        ["DEMONHUNTER"] = { r = 0.64, g = 0.19, b = 0.79 },
        ["EVOKER"] = { r = 0.20, g = 0.58, b = 0.50 }
    }
else
    VUICD.Constants.CLASS_COLORS = RAID_CLASS_COLORS
end