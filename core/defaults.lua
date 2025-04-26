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
            castbar = {
                enabled = true,
                customColors = true,
                showSpellName = true,
                showIcon = true,
                showTimer = true,
                showLatency = true,
                showTarget = true,
                showCastTime = true,
            },
        },
        appearance = {
            theme = "thunderstorm", -- Set Thunder Storm as the default theme
            font = "Friz Quadrata TT",
            fontSize = 12,
            border = "blizzard",
            backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.8}, -- Deep blue background for Thunder Storm
            borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1}, -- Electric blue borders for Thunder Storm
            classColoredBorders = true,
            useClassColors = true,
            statusbarTexture = "smooth", -- Default statusbar texture
            scale = 1.0, -- UI scale
            compactMode = false, -- Use smaller UI elements
            enableAnimations = true, -- Use animated effects
        },
        
        -- Dashboard settings
        dashboard = {
            enabled = true,
            scale = 1.0,
            position = { x = 0, y = 0 },
            width = 800,
            height = 600,
            autoHide = false,
            showModuleCards = true,
            showStatusDisplay = true,
            theme = "thunderstorm", -- Set Thunder Storm as default for dashboard too
        },
        
        -- Modules settings with their defaults
        modules = {
            -- Bags Module
            bags = {
                enabled = true,
                combineAllBags = true,
                showItemLevel = true,
                showItemBorders = true,
                colorItemBorders = true,
                compactLayout = false,
                itemLevelThreshold = 1,
                enhancedSearch = true,
            },
            
            -- Paperdoll (Character Panel) Module
            paperdoll = {
                enabled = true,
                showItemLevel = true,
                showIlvlDetails = true,
                colorStatValues = true,
                colorPrimaryStats = true,
                showDurability = true,
                highQualityPortrait = true,
                enhancedItemTooltips = true,
            },
            
            -- Action Bars Module
            actionbars = {
                enabled = true,
                enhancedStyles = true,
                showHotkeys = true,
                showMacroNames = true,
                showCooldownText = true,
                showItemCount = true,
                gridLayout = false,
                highlightEquipped = true,
                customBarBackground = true,
                hideEmptyButtons = false,
                colorKeyBinds = true,
                largerButtons = false,
                themeButtonBorders = true
            },
            
            -- Chat Module
            chat = {
                enabled = true,
                fontSize = 12,
                font = "Friz Quadrata TT",
                chatHistory = 500,         -- Store 500 lines of chat history
                showCopyButton = true,     -- Show copy chat button
                showClassIcons = true,     -- Show class icons in chat
                useClassColors = true,     -- Use class colors for names
                timestampFormat = "[%H:%M:%S] ", -- Format for chat timestamps
                classIconSize = 14,        -- Size of class icons in chat
                saveHistory = true,        -- Save chat history between sessions
                filterRaidSpam = true,     -- Filter out common raid spam messages
                chatURLCopy = true,        -- Make URLs in chat clickable
                nameplateStyling = "custom", -- Can be "default" or "custom"
                nameplateFriendlySize = 1.0,
                nameplateFriendlyAlpha = 1.0,
                nameplateEnemySize = 1.0,
                nameplateEnemyAlpha = 1.0,
            },
            
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
                trackHealerSpells = true,    -- Track important healer spells in M+
                showHealerSpellNotifications = true, -- Show notifications for healer spells
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
            
            -- idTip Module
            idtip = {
                enabled = true,
                showIds = true,
                showItemIds = true,
                showSpellIds = true,
                showNpcIds = true,
                showQuestIds = true,
                showAchievementIds = true,
                showTalentIds = true,
                showCurrencyIds = true,
                coloredText = true,
                iconDisplay = true,
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
