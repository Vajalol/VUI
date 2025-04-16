local _, VUI = ...

-- Default configuration values for all modules
VUI.defaults = {
    profile = {
        general = {
            scale = 1.0,
            minimap = {
                hide = false,
                position = 45,
            },
        },
        appearance = {
            theme = "dark",
            font = "Friz Quadrata TT",
            fontSize = 12,
            border = "blizzard",
            backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1},
            classColoredBorders = true,
            useClassColors = true,
        },
        
        -- Modules settings with their defaults
        modules = {
            -- BuffOverlay Module
            buffoverlay = {
                enabled = true,
                scale = 1.0,
                growthDirection = "UP",
                spacing = 2,
                size = 32,
                showTooltip = true,
                showTimer = true,
                showStackCount = true,
                borderStyle = "default",
                filterBuffs = true,
                filterDebuffs = true,
                whitelist = {},
                blacklist = {},
            },
            
            -- TrufiGCD Module
            trufigcd = {
                enabled = true,
                scale = 1.0,
                maxIcons = 5,
                iconSize = 30,
                iconSpacing = 2,
                fadeTime = 0.3,
                showSpellName = true,
                direction = "LEFT",
                ignoreItems = true,
                whitelist = {},
                blacklist = {},
            },
            
            -- MoveAny Module
            moveany = {
                enabled = true,
                savedFrames = {},
                lockFrames = true,
                showGrid = true,
                gridSize = 32,
                snapToGrid = true,
                snapThreshold = 10,
                showTooltips = true,
                frameScaling = {},
            },
            
            -- Auctionator Module
            auctionator = {
                enabled = true,
                autoscan = true,
                defaultTab = "sell",
                scanSpeed = "normal",
                stackSize = 0,
                undercutPercent = 0,
                defaultDuration = 24,
                autoScanInterval = 60,
                showLinkBrackets = true,
                useCompactUI = false,
                historyDays = 21,
                tooltipConfig = {
                    showMarketValue = true,
                    showHistoricalPrice = true,
                    showDisenchantValue = true,
                    showVendorPrice = true,
                },
            },
            
            -- AngryKeystones Module
            angrykeystone = {
                enabled = true,
                showObjectives = true,
                showProgress = true,
                showTimers = true,
                progressFormat = "percent",
                objectiveStyle = "normal",
                scheduleFormat = "full",
                showChests = true,
                autoTrackBosses = true,
                deathCounter = true,
                recordTimers = true,
                showProudCount = true,
            },
            
            -- OmniCC Module
            omnicc = {
                enabled = true,
                useModernFont = true,
                minDuration = 2.0,
                minSize = 0.5,
                enableText = true,
                showTenthsOfSeconds = true,
                textColor = {
                    regular = {r = 1, g = 1, b = 1},
                    expiring = {r = 1, g = 0, b = 0},
                    seconds = {r = 1, g = 1, b = 0.4},
                    minutes = {r = 1, g = 1, b = 1},
                    hours = {r = 0.7, g = 0.7, b = 0.7},
                    days = {r = 0.5, g = 0.5, b = 0.5},
                },
                spiralOpacity = 1.0,
                fontOutline = "OUTLINE",
                scaleText = true,
            },
            
            -- OmniCD Module
            omnicd = {
                enabled = true,
                showIcons = true,
                iconSize = 24,
                iconSpacing = 2,
                growthDirection = "RIGHT",
                barDirection = "DOWN",
                barWidth = 100,
                barHeight = 14,
                showStatusText = true,
                sortBy = "ready",
                groupBy = "none",
                highlightTarget = true,
                zoneConfig = {
                    arena = {
                        enabled = true,
                        showUnused = true,
                    },
                    dungeons = {
                        enabled = true,
                        showUnused = false,
                    },
                    raid = {
                        enabled = true,
                        showUnused = false,
                    },
                    pvp = {
                        enabled = true,
                        showUnused = true,
                    },
                    scenario = {
                        enabled = true,
                        showUnused = true,
                    },
                    none = {
                        enabled = true,
                        showUnused = true,
                    },
                },
                spellFilters = {},
            },
        }
    },
    char = {}
}

-- Character-specific defaults
VUI.charDefaults = {
    profile = {
        -- Character-specific module settings
        modules = {
            auctionator = {
                favorites = {},
                recentSearches = {},
                lastScan = 0,
            },
            angrykeystone = {
                pastRuns = {},
                bestTimes = {},
            },
        }
    }
}
