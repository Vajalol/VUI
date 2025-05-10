local _, VUI = ...
local E = VUI:GetModule("VUICD")
local P = E.Party

-- Default configuration values
E.defaults = {
    global = {
        cooldowns = {},
    },
    profile = {
        enable = true,
        showAnchor = false,
        tooltipScale = 1,
        customPriority = {},
        mergeHealAbilities = true,
        noRatingGlow = false,
        border = {
            enabled = true,
            thickness = 1,
            coloring = "class",
            color = {r=1, g=1, b=1, a=1},
            themeBorder = true
        },
        modules = {
            party = true,
        },
        position = {
            detached = false,
            anchor = "TOPLEFT",
            x = 365,
            y = -260,
            preset = "TOPLEFT",
        },
    }
}

-- Party module defaults
P.defaults = {
    profile = {
        -- General settings
        general = {
            showPlayer = true,
            showTooltip = true,
            showTooltipID = false,
            showTooltipNotes = true,
            enableAlpha = true,
            disableTab = false,
            tooltipScale = 1,
            iconTexture = "interface\\cooldown\\star4",
            extraBarTexture = "interface\\targetingframe\\ui-statusbar",
            customWidth = {},
            customHeight = {},
            highlightWidth = 1,
            activeAlpha = 1.0,
            inactiveAlpha = 1.0,
            dimAlpha = 0.5,
            fillAlpha = 0.5,
        },

        -- Icons
        icons = {
            statusBarWidth = 256,
            statusBarHeight = 18,
            statusBarTexture = "BantoBar",
            barIcon = true,
            chargeScale = 0.60,
            chargePoint = "TOPLEFT",
            swipeAlpha = 0.8,
            textAnchorPoint = "CENTER",
            statusTextEnabled = true,
            statusTextPosition = "BOTTOM",
            statusTextYOffset = 0,
            growUpward = false,
            hideDisabledSpells = false,
            showCounter = true,
            counterColor = { r=1, g=1, b=1 },
            layout = "horizontal",
        },

        -- Highlight settings
        highlight = {
            enabled = true,
            shine = true,
            glow = true,
            glowColor = { r=1, g=1, b=1 },
            themes = {
                r = 1,
                g = 1,
                b = 1,
            },
        },

        -- Visibility settings
        visibility = {
            inLFR = true,
            onlyShowPlayersWithTalents = false,
            zone = {
                none = true,
                pvp = true,
                arena = true,
                party = true,
                raid = true,
                scenario = true,
            },
            instance = {
                none = true,
                scenario = true,
                party = true,
                raid = true,
                arena = true,
                pvp = true,
            },
            size = {
                none = true,
                arena = true,
                party = true,
                ten = true,
                twentyfive = true,
                fortyfive = true,
                fourty = true,
            },
        },

        -- Extra bars
        extraBars = {
            detached = false,
            growUpward = false,
            barWidth = 260,
            barHeight = 24,
            barSpacing = 1,
            textColors = {},
            statusBarTexture = "BantoBar",
            bgTexture = "Solid"
        },

        -- Position settings
        position = {
            detached = false,
            anchor = "TOPLEFT",
            x = 365,
            y = -260,
            preset = "TOPLEFT",
        },
    }
}

-- Setup databases
function E:SetupDB()
    -- Main DB
    if not E.DB then
        E.DB = LibStub("AceDB-3.0"):New("VUICDDB", E.defaults, true)
    end
    
    -- Party DB
    if not P.db then
        P.db = LibStub("AceDB-3.0"):New("VUICDPartyDB", P.defaults, true)
    end
    
    -- Initialize Config table
    if not E.Config then
        E.Config = {}
    end
end