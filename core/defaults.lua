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
            font = "VUI PT Sans Narrow",
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
        -- UI Skinning system
        skins = {
            enabled = true, -- Enable skinning by default
            style = "default", -- Default skin style
            useThemeColors = true, -- Use theme colors
            useClassColors = false, -- Don't use class colors by default
            skinBorders = true, -- Apply custom borders
            skinBackdrops = true, -- Apply custom backdrops
            skinButtons = true, -- Apply custom button styles
            skinStatusBars = true, -- Apply custom statusbar styles
            frameGroups = { -- Default frame groups to skin
                ["CHARACTER"] = true,
                ["SPELLBOOK"] = true,
                ["TALENTS"] = true,
                ["QUESTS"] = true,
                ["SOCIAL"] = true,
                ["MERCHANT"] = true,
                ["SYSTEM"] = true,
                ["MISC"] = true,
            },
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
        
        -- ConfigUI settings
        configUI = {
            enabled = true,
            lastTab = "general",
            showSearch = true,
            showContextHelp = true,
            showPreview = true,
        },
        
        -- ThemeEditor settings
        themeEditor = {
            enabled = true,
            lastColor = {r = 1, g = 1, b = 1, a = 1},
            lastTexture = "smooth",
            customThemes = {},
            showPreview = true,
            previewSize = "medium",
            autoSave = true,
            allowExport = true,
            confirmOverwrite = true,
            showTooltips = true,
            useRGBSliders = true,
            previewElements = {
                frame = true,
                button = true,
                statusbar = true,
                header = true,
                text = true
            }
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
                font = "VUI PT Sans Narrow",
                chatHistory = 500,         -- Store 500 lines of chat history
                showCopyButton = true,     -- Show copy chat button
                showClassIcons = true,     -- Show class icons in chat
                useClassColors = true,     -- Use class colors for names
                timestampFormat = "[%H:%M:%S] ", -- Format for chat timestamps
                classIconSize = 14,        -- Size of class icons in chat
                saveHistory = true,        -- Save chat history between sessions
                filterRaidSpam = true,     -- Filter out common raid spam messages
                chatURLCopy = true,        -- Make URLs in chat clickable
            },
            
            -- VUI Plater Module (Advanced Nameplates)
            nameplates = {
                enabled = true,
                profileName = "VUI Plater",
                styling = "plater",        -- Can be "default", "custom", or "plater"
                useThemeColors = true,     -- Match colors to current VUI theme
                
                -- Plater styling options
                platerVersion = "1.0.0",
                plateHeight = 36,
                plateWidth = 140,
                castBarHeight = 10,
                castBarIconSize = 16,
                useCustomCastbar = true,
                nameplateAlpha = 1.0,
                
                -- Global settings
                friendlySize = 1.0,
                enemySize = 1.0,
                friendlyAlpha = 1.0,
                enemyAlpha = 1.0,
                
                -- Health bar options
                showClassColors = true,
                healthBarTexture = "VUI_Smooth",
                healthBarBorderType = "thin",    -- none, thin, thick, or gloss
                
                -- Text options
                nameTextSize = 10,
                nameTextFont = "VUI PT Sans Narrow",
                nameTextOutline = "OUTLINE",
                showHealthText = true,
                healthTextSize = 10,
                healthTextFont = "VUI PT Sans Narrow",
                healthTextOutline = "OUTLINE",
                healthFormat = "percent",  -- percent, value, both
                
                -- Cast bar options
                showCastbars = true,
                castBarTexture = "VUI_Smooth", 
                castBarColor = {r = 0.4, g = 0.6, b = 0.8, a = 1.0},
                nonInterruptibleColor = {r = 0.7, g = 0.3, b = 0.3, a = 1.0},
                castBarTextSize = 8,
                castBarTextFont = "VUI PT Sans Narrow",
                showCastTarget = true,
                castTargetPosition = "below", -- below, right
                
                -- Aura display options
                showAuras = true,
                maxAuras = 6,
                filterAuras = true,
                auraSize = 22,
                auraSpacing = 1,
                auraPosition = "top",      -- top, bottom, left, right
                showAuraCooldown = true,
                showAuraStacks = true,
                auraSortMode = "duration", -- duration, name
                showEnrageEffects = true,
                prioritizeDebuffs = true,
                
                -- Aura filters
                whitelistedAuras = {},     -- Priority auras always shown
                blacklistedAuras = {},     -- Auras never shown
                
                -- Combat/threat indicators
                showThreatIndicator = true,
                threatWarningMode = "color", -- color, border, icon, glow
                tankMode = true,           -- Different threat coloring for tanks
                
                -- Special indicators
                showExecuteIndicator = true,
                executeThreshold = 20,      -- Health percentage for execute indicator
                showTargetHighlight = true,
                targetHighlightColor = {r = 1.0, g = 1.0, b = 1.0, a = 0.2},
                showFocusHighlight = true,
                focusHighlightColor = {r = 0.0, g = 1.0, b = 0.0, a = 0.2},
                showEliteIcon = true,
                showTotems = true,
                showRaidMarks = true,
                
                -- Visibility settings
                hideNeutralNPCs = false,
                hideFriendlyNPCs = false,
                hideFriendlyPlayers = false,
                hideInCombat = false,
                
                -- Utility settings
                clickthrough = false,
                stackingNameplates = true, -- Whether nameplates stack on top of each other or overlap
                cvarsLoaded = false,       -- Internal tracking for CVars
                
                -- Script hooks settings
                useCreateHook = true,      -- Create hook for plate initialization
                useUpdateHook = true,      -- Update hook for regular updates
                useAddedHook = true,       -- Added hook when plates appear
                useRemovedHook = false,    -- Removed hook when plates disappear
                useCreationHook = true,    -- Custom create hook for extensive customization
                
                -- Scripts and custom code
                customScripts = {
                    createPlate = "-- Custom create plate script\n-- Used for initial plate setup",
                    updatePlate = "-- Custom update plate script\n-- Used for regular plate updates",
                    plateAdded = "-- Custom plate added script\n-- Used when plate first appears"
                },
                
                -- Special effects
                useAnimations = true,
                useGlow = true,
                useShake = true,
                
                -- NPC colorization
                npcColorOverrides = {}     -- Custom NPC colors by NPC ID
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
            
            -- DetailsSkin Module
            detailsskin = {
                enabled = true,
                skinStyle = "ElvUI",
                saveOriginal = true,
                backgroundOpacity = 0.7,
                rowOpacity = 0.3,
                menuOpacity = 0.9,
                borderOpacity = 1.0,
                statusBarOpacity = 0.8,
                customBorder = true,
                customBarTexture = true,
                barTexture = "VUI_Smooth",
                customFonts = true,
                rowFont = "VUI PT Sans Narrow",
                fontSize = 10,
                fixedHeight = true,
                rowHeight = 16,
                customSpacing = true,
                rowSpacing = 1
            },
            
            -- SpellNotifications Module
            spellnotifications = {
                enabled = true,
                enableSounds = true,
                filterErrors = true,
                soundChannel = "Master",
                textSize = "BIG",
                
                -- Player events
                playerInterrupts = true,
                playerInterruptsSound = "bell",
                
                playerDispels = true,
                playerDispelsSound = "ding",
                
                playerStolen = true,
                playerStolenSound = "cling",
                
                playerMisses = true,
                playerMissesSound = "buzz",
                
                playerCrits = true,
                playerCritsSound = "laser",
                playerCritsMinHit = 5000,
                playerCritsHealthPct = 20,
                
                playerHeals = true,
                playerHealsSound = "pulse",
                playerHealsMinHit = 5000,
                playerHealsHealthPct = 20,
                
                -- Pet events
                petInterrupts = true,
                petInterruptsSound = "bell",
                
                petDispels = true,
                petDispelsSound = "ding",
                
                petMisses = true,
                petMissesSound = "buzz",
                
                petCrits = true,
                petCritsSound = "laser",
                petCritsMinHit = 3000
            },
            
            -- MSBT (MikScrollingBattleText) Module
            msbt = {
                enabled = true,
                useVUITheme = true,
                enhancedFonts = true,
                showAnimation = true,
                soundsEnabled = true,
                themeColoredText = true,
                scrollAreas = {
                    incoming = {
                        enabled = true,
                        useVUITheme = true
                    },
                    outgoing = {
                        enabled = true,
                        useVUITheme = true
                    },
                    notification = {
                        enabled = true,
                        useVUITheme = true
                    },
                    static = {
                        enabled = true,
                        useVUITheme = true
                    }
                }
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
