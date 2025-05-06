local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Default configuration values for all modules
VUI.defaults = {
    global = {
        presets = {
            -- Example preset formats:
            -- ["My DPS Preset"] = { profileData = {}, description = "Optimized for DPS classes" },
            -- ["My Healer Preset"] = { profileData = {}, description = "Optimized for healing" },
        },
    },
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
            
            -- EPF (Enhanced Player Frame) Module
            epf = {
                enabled = true,
                useThemeColors = true,
                showPortrait = true,
                portraitStyle = "3D",
                showHealthPercentage = true,
                showPowerPercentage = true,
                showPredictionBars = true,
                showAbsorbBars = true,
                classColoredBars = true,
                customBarTexture = true,
                barTexture = "VUI_Smooth",
                customFonts = true,
                font = "VUI PT Sans Narrow",
                fontSize = 10,
                fontOutline = "OUTLINE",
                scale = 1.0,
                position = { x = 0, y = 0 },
                width = 200,
                height = 60,
                powerBarHeight = 15,
                showCastbar = true,
                castbarPosition = "BOTTOM",
                castbarHeight = 15,
                showGroupIndicator = true,
                showCombatIndicator = true,
                showRestingIndicator = true,
                showStatusText = true,
                customStatusText = false,
                statusTextFormat = "[healthpercent] | [power:current]",
                auraDisplay = {
                    showBuffs = true,
                    showDebuffs = true,
                    buffSize = 22,
                    debuffSize = 22,
                    buffSpacing = 2,
                    debuffSpacing = 2,
                    buffGrowDirection = "RIGHT",
                    debuffGrowDirection = "RIGHT",
                    maxBuffs = 16,
                    maxDebuffs = 16,
                    buffSort = "TIME",
                    debuffSort = "TIME",
                    showAuraBorders = true,
                    colorAuraBorders = true,
                    onlyShowPlayerAuras = false,
                    highlightPlayerAuras = true,
                    showBuffTooltips = true,
                    showDebuffTooltips = true,
                }
            },
            
            -- Infoframe Module
            infoframe = {
                enabled = true,
                scale = 1.0,
                updateInterval = 1.0,
                autoHide = false,
                position = { x = 0, y = 0 },
                width = 200,
                height = 150,
                showBorder = true,
                useFading = true,
                backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 },
                borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1.0 },
                font = "VUI PT Sans Narrow",
                fontSize = 10,
                fontOutline = "OUTLINE",
                textColor = { r = 1, g = 1, b = 1, a = 1 },
                headerColor = { r = 0.9, g = 0.8, b = 0, a = 1 },
                panels = {
                    playerInfo = {
                        enabled = true,
                        order = 1,
                        showItemLevel = true,
                        showDurability = true,
                        showGold = true,
                        showCoordinates = true,
                        showLatency = true,
                        showFPS = true,
                        showTime = true,
                    },
                    combatStats = {
                        enabled = true,
                        order = 2,
                        showDPS = true,
                        showHPS = true,
                        showDTPS = true,
                        combatTimeWindow = 30,
                        resetOnCombatEnd = true,
                    },
                    keystone = {
                        enabled = true,
                        order = 3,
                        showTimer = true,
                        showAffixes = true,
                        showPercentage = true,
                        showChests = true,
                    },
                    raid = {
                        enabled = true,
                        order = 4,
                        showRaidCooldowns = true,
                        showRaidBuffs = true,
                        trackMissingBuffs = true,
                    },
                    customPanels = {
                        -- Custom panels defined by user
                    }
                },
            },
            
            -- Multi Notification Module
            multinotification = {
                enabled = true,
                scale = 1.0,
                position = { x = 0, y = 100 },
                iconSize = 36,
                textSize = 14,
                showText = true,
                showIcons = true,
                useAnimations = true,
                animationType = "bounce",
                duration = 3.0,
                spacing = 4,
                maxNotifications = 5,
                useSound = true,
                soundChannel = "Master",
                fadeTime = 0.5,
                groups = {
                    interrupts = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 },
                        sound = "VUI_Interrupt",
                        position = "TOP",
                    },
                    dispels = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.9, g = 0.7, b = 0.1, a = 1.0 },
                        sound = "VUI_Dispel",
                        position = "TOP",
                    },
                    defensives = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.2, g = 0.8, b = 0.2, a = 1.0 },
                        sound = "VUI_Defensive",
                        position = "TOP",
                    },
                    healing = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.2, g = 1.0, b = 0.2, a = 1.0 },
                        sound = "VUI_Healing",
                        position = "TOP",
                    },
                    damage = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 1.0, g = 0.2, b = 0.2, a = 1.0 },
                        sound = "VUI_Damage",
                        position = "TOP",
                    },
                    utility = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.8, g = 0.8, b = 0.2, a = 1.0 },
                        sound = "VUI_Utility",
                        position = "TOP",
                    },
                    warning = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 1.0, g = 0.1, b = 0.1, a = 1.0 },
                        sound = "VUI_Warning",
                        position = "TOP",
                    },
                }
            },
            
            -- Castbar Module
            castbar = {
                enabled = true,
                showPlayerCastbar = true,
                showTargetCastbar = true,
                showFocusCastbar = true,
                barTexture = "VUI_Smooth",
                useCustomStyle = true,
                showIcon = true,
                showSpellName = true,
                showTimer = true,
                showSpark = true,
                showLatency = true,
                colorByType = true, -- Color differently for normal, channeled, etc
                borderStyle = "thin",
                player = {
                    scale = 1.0,
                    width = 260,
                    height = 20,
                    position = { x = 0, y = -200 },
                    font = "VUI PT Sans Narrow",
                    fontSize = 10,
                    fontOutline = "OUTLINE",
                    iconPosition = "LEFT",
                    iconSize = 24,
                    barColor = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 },
                    channelColor = { r = 0.2, g = 0.8, b = 0.2, a = 1.0 },
                    nonInterruptibleColor = { r = 0.7, g = 0.3, b = 0.3, a = 1.0 },
                    backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                    borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 },
                    textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                },
                target = {
                    scale = 1.0,
                    width = 240,
                    height = 18,
                    position = { x = 0, y = -180 },
                    font = "VUI PT Sans Narrow",
                    fontSize = 10,
                    fontOutline = "OUTLINE",
                    iconPosition = "LEFT",
                    iconSize = 22,
                    barColor = { r = 0.6, g = 0.2, b = 0.2, a = 1.0 },
                    channelColor = { r = 0.7, g = 0.3, b = 0.3, a = 1.0 },
                    nonInterruptibleColor = { r = 0.7, g = 0.7, b = 0.3, a = 1.0 },
                    backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                    borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 },
                    textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                },
                focus = {
                    scale = 1.0,
                    width = 220,
                    height = 16,
                    position = { x = 0, y = -160 },
                    font = "VUI PT Sans Narrow",
                    fontSize = 9,
                    fontOutline = "OUTLINE",
                    iconPosition = "LEFT",
                    iconSize = 20,
                    barColor = { r = 0.2, g = 0.2, b = 0.8, a = 1.0 },
                    channelColor = { r = 0.3, g = 0.3, b = 0.8, a = 1.0 },
                    nonInterruptibleColor = { r = 0.5, g = 0.5, b = 0.7, a = 1.0 },
                    backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                    borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 },
                    textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                },
            },
            
            -- Tooltip Module
            tooltip = {
                enabled = true,
                scale = 1.0,
                fontSize = 11,
                fontOutline = "NONE",
                useGameTooltip = true,
                customTooltips = true,
                position = "CURSOR",
                offset = { x = 5, y = 5 },
                hideInCombat = false,
                colorBorderByType = true, -- Color border by item quality, unit class, etc
                backdropColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.8 },
                borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1.0 },
                healthBar = {
                    enabled = true,
                    height = 6,
                    texture = "VUI_Smooth",
                    useClassColors = true,
                    colorByHealth = true,
                },
                enhancedInfo = {
                    showItemLevel = true,
                    showItemID = false,
                    showSpellID = false,
                    showClassifiction = true,
                    showCastBy = true,
                    showRole = true,
                    showTarget = true,
                    showGuildRank = true,
                    showCovenantInfo = true,
                    showKeystone = true,
                },
                auras = {
                    showBuffs = true,
                    showDebuffs = true,
                    maxBuffs = 16,
                    maxDebuffs = 16,
                    buffSize = 20,
                    debuffSize = 20,
                    spacing = 2,
                    showDuration = true,
                },
            },
            
            -- UnitFrames Module
            unitframes = {
                enabled = true,
                scale = 1.0,
                useClassColors = true,
                colorHealthByValue = true,
                showSmoothHealthUpdates = true,
                healthBarTexture = "VUI_Smooth",
                powerBarTexture = "VUI_Smooth",
                borderStyle = "thin",
                
                player = {
                    enabled = true,
                    width = 230,
                    height = 60,
                    position = { x = -260, y = -250 },
                    showPortrait = true,
                    portraitStyle = "3D",
                    showPowerBar = true,
                    powerBarHeight = 12,
                    showName = true,
                    showLevel = true,
                    showHealthValue = true,
                    showHealthPercent = true,
                    showPowerValue = true,
                    showPowerPercent = true,
                    classColoredName = true,
                    font = "VUI PT Sans Narrow",
                    fontSize = 10,
                    fontOutline = "OUTLINE",
                    textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                    healthColor = { r = 0.2, g = 0.8, b = 0.2, a = 1.0 },
                    manaColor = { r = 0.2, g = 0.2, b = 0.8, a = 1.0 },
                    rageColor = { r = 0.8, g = 0.2, b = 0.2, a = 1.0 },
                    energyColor = { r = 0.8, g = 0.8, b = 0.2, a = 1.0 },
                    focusColor = { r = 0.8, g = 0.4, b = 0.0, a = 1.0 },
                    backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                    borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 },
                    auras = {
                        showBuffs = true,
                        showDebuffs = true,
                        maxBuffs = 32,
                        maxDebuffs = 16,
                        buffSize = 24,
                        debuffSize = 24,
                        buffSpacing = 2,
                        debuffSpacing = 2,
                        buffGrowDirection = "UP",
                        debuffGrowDirection = "DOWN",
                        showBuffDuration = true,
                        showDebuffDuration = true,
                        showBuffStacks = true,
                        showDebuffStacks = true,
                        showBuffTooltips = true,
                        showDebuffTooltips = true,
                        colorBuffBorders = true,
                        filterBuffs = true,
                        filterDebuffs = true,
                        onlyPlayerDebuffs = false,
                        prioritizeDispellable = true,
                    },
                },
                
                target = {
                    enabled = true,
                    width = 230,
                    height = 60,
                    position = { x = 260, y = -250 },
                    showPortrait = true,
                    portraitStyle = "3D",
                    showPowerBar = true,
                    powerBarHeight = 12,
                    showName = true,
                    showLevel = true,
                    showHealthValue = true,
                    showHealthPercent = true,
                    showPowerValue = true,
                    showPowerPercent = true,
                    classColoredName = true,
                    font = "VUI PT Sans Narrow",
                    fontSize = 10,
                    fontOutline = "OUTLINE",
                    textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                    friendlyHealthColor = { r = 0.2, g = 0.8, b = 0.2, a = 1.0 },
                    neutralHealthColor = { r = 0.8, g = 0.8, b = 0.0, a = 1.0 },
                    hostileHealthColor = { r = 0.8, g = 0.2, b = 0.2, a = 1.0 },
                    manaColor = { r = 0.2, g = 0.2, b = 0.8, a = 1.0 },
                    rageColor = { r = 0.8, g = 0.2, b = 0.2, a = 1.0 },
                    energyColor = { r = 0.8, g = 0.8, b = 0.2, a = 1.0 },
                    focusColor = { r = 0.8, g = 0.4, b = 0.0, a = 1.0 },
                    backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                    borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 },
                    auras = {
                        showBuffs = true,
                        showDebuffs = true,
                        maxBuffs = 16,
                        maxDebuffs = 32,
                        buffSize = 24,
                        debuffSize = 24,
                        buffSpacing = 2,
                        debuffSpacing = 2,
                        buffGrowDirection = "DOWN",
                        debuffGrowDirection = "DOWN",
                        showBuffDuration = true,
                        showDebuffDuration = true,
                        showBuffStacks = true,
                        showDebuffStacks = true,
                        showBuffTooltips = true,
                        showDebuffTooltips = true,
                        colorBuffBorders = true,
                        filterBuffs = true,
                        filterDebuffs = true,
                        onlyPlayerDebuffs = false,
                        prioritizeDispellable = true,
                    },
                },
                
                targettarget = {
                    enabled = true,
                    width = 130,
                    height = 34,
                    position = { x = 400, y = -250 },
                    showPortrait = false,
                    showPowerBar = true,
                    powerBarHeight = 8,
                    showName = true,
                    showLevel = false,
                    showHealthValue = false,
                    showHealthPercent = true,
                    showPowerValue = false,
                    showPowerPercent = false,
                    classColoredName = true,
                    font = "VUI PT Sans Narrow",
                    fontSize = 9,
                    fontOutline = "OUTLINE",
                },
                
                focus = {
                    enabled = true,
                    width = 180,
                    height = 46,
                    position = { x = 0, y = -100 },
                    showPortrait = true,
                    portraitStyle = "3D",
                    showPowerBar = true,
                    powerBarHeight = 10,
                    showName = true,
                    showLevel = true,
                    showHealthValue = false,
                    showHealthPercent = true,
                    showPowerValue = false,
                    showPowerPercent = false,
                    classColoredName = true,
                    font = "VUI PT Sans Narrow",
                    fontSize = 9,
                    fontOutline = "OUTLINE",
                    auras = {
                        showBuffs = false,
                        showDebuffs = true,
                        maxDebuffs = 8,
                        debuffSize = 22,
                        debuffSpacing = 2,
                        debuffGrowDirection = "RIGHT",
                        showDebuffDuration = true,
                        showDebuffStacks = true,
                        colorDebuffBorders = true,
                        filterDebuffs = true,
                        onlyPlayerDebuffs = true,
                    },
                },
                
                party = {
                    enabled = true,
                    width = 180,
                    height = 46,
                    position = { x = 0, y = 200 },
                    growthDirection = "DOWN",
                    spacing = 2,
                    maxColumns = 1,
                    unitsPerColumn = 5,
                    columnSpacing = 5,
                    showPlayer = true,
                    showPets = true,
                    sortBy = "GROUP",
                    showPortrait = true,
                    portraitStyle = "3D",
                    showPowerBar = true,
                    powerBarHeight = 10,
                    showName = true,
                    showLevel = false,
                    showHealthValue = false,
                    showHealthPercent = true,
                    showPowerValue = false,
                    showPowerPercent = false,
                    classColoredName = true,
                    font = "VUI PT Sans Narrow",
                    fontSize = 9,
                    fontOutline = "OUTLINE",
                    auras = {
                        showBuffs = false,
                        showDebuffs = true,
                        maxDebuffs = 4,
                        debuffSize = 22,
                        debuffSpacing = 2,
                        debuffGrowDirection = "RIGHT",
                        showDebuffDuration = true,
                        showDebuffStacks = true,
                        colorDebuffBorders = true,
                        filterDebuffs = true,
                        onlyDispellable = true,
                    },
                },
                
                raid = {
                    enabled = true,
                    width = 80,
                    height = 36,
                    position = { x = -600, y = 250 },
                    growthDirection = "DOWN_RIGHT",
                    spacing = 2,
                    maxColumns = 8,
                    unitsPerColumn = 5,
                    columnSpacing = 5,
                    showPlayer = true,
                    showPets = false,
                    sortBy = "GROUP",
                    groupBy = "GROUP",
                    raidLayout = "GROUP", -- GROUP or CLASS
                    showName = true,
                    showHealthValue = false,
                    showHealthPercent = false,
                    useClassColors = true,
                    showAuras = true,
                    maxAuras = 4,
                    auraSize = 16,
                    font = "VUI PT Sans Narrow",
                    fontSize = 8,
                    fontOutline = "OUTLINE",
                },
                
                boss = {
                    enabled = true,
                    width = 180,
                    height = 46,
                    position = { x = 600, y = 0 },
                    growthDirection = "DOWN",
                    spacing = 2,
                    maxBossFrames = 5,
                    showPortrait = false,
                    showPowerBar = true,
                    powerBarHeight = 10,
                    showName = true,
                    showLevel = false,
                    showHealthValue = false,
                    showHealthPercent = true,
                    showPowerValue = false,
                    showPowerPercent = false,
                    font = "VUI PT Sans Narrow",
                    fontSize = 9,
                    fontOutline = "OUTLINE",
                    healthColor = { r = 0.8, g = 0.2, b = 0.2, a = 1.0 },
                    auras = {
                        showBuffs = true,
                        showDebuffs = true,
                        maxBuffs = 4,
                        maxDebuffs = 4,
                        buffSize = 22,
                        debuffSize = 22,
                        buffSpacing = 2,
                        debuffSpacing = 2,
                        buffGrowDirection = "LEFT",
                        debuffGrowDirection = "RIGHT",
                        showBuffDuration = true,
                        showDebuffDuration = true,
                        showBuffStacks = true,
                        showDebuffStacks = true,
                        colorBuffBorders = true,
                    },
                },
                
                arena = {
                    enabled = true,
                    width = 180,
                    height = 46,
                    position = { x = 600, y = 0 },
                    growthDirection = "DOWN",
                    spacing = 2,
                    maxArenaFrames = 5,
                    showPortrait = false,
                    showPowerBar = true,
                    powerBarHeight = 10,
                    showName = true,
                    showSpec = true,
                    showTrinket = true,
                    trinketSize = 24,
                    showDRTracker = true,
                    drTrackerSize = 20,
                    showHealthValue = false,
                    showHealthPercent = true,
                    showPowerValue = false,
                    showPowerPercent = false,
                    font = "VUI PT Sans Narrow",
                    fontSize = 9,
                    fontOutline = "OUTLINE",
                    auras = {
                        showBuffs = true,
                        showDebuffs = true,
                        maxBuffs = 4,
                        maxDebuffs = 4,
                        buffSize = 22,
                        debuffSize = 22,
                        buffSpacing = 2,
                        debuffSpacing = 2,
                        buffGrowDirection = "LEFT",
                        debuffGrowDirection = "RIGHT",
                    },
                },
            },
            
            -- Profiles Module
            profiles = {
                enabled = true,
                showProfileList = true,
                profileListWidth = 150,
                showDescription = true,
                showImportExport = true,
                confirmProfileDeletion = true,
                autosaveOnChanges = true,
                defaultClass = {
                    WARRIOR = "DPS",
                    PALADIN = "Tank",
                    HUNTER = "DPS",
                    ROGUE = "DPS",
                    PRIEST = "Healer",
                    SHAMAN = "DPS",
                    MAGE = "DPS",
                    WARLOCK = "DPS",
                    DRUID = "DPS",
                    MONK = "DPS",
                    DEMONHUNTER = "DPS",
                    DEATHKNIGHT = "DPS",
                    EVOKER = "DPS"
                },
                predefinedProfiles = {
                    DPS = {
                        description = "Optimized for DPS classes",
                        layoutFocus = "combat",
                        auraSize = "large",
                        cooldownTracking = "intensive"
                    },
                    Tank = {
                        description = "Optimized for tank classes",
                        layoutFocus = "defensive",
                        auraSize = "medium",
                        cooldownTracking = "defensive"
                    },
                    Healer = {
                        description = "Optimized for healing classes",
                        layoutFocus = "healing",
                        auraSize = "medium",
                        cooldownTracking = "healing"
                    },
                    PvP = {
                        description = "Optimized for PvP content",
                        layoutFocus = "awareness",
                        auraSize = "large",
                        cooldownTracking = "intensive"
                    },
                    Minimal = {
                        description = "Minimal UI with only essential elements",
                        layoutFocus = "minimal",
                        auraSize = "small",
                        cooldownTracking = "basic"
                    }
                }
            },
            
            -- Automation Module
            automation = {
                enabled = true,
                autoLoot = true,
                autoLootIgnoreBOE = false,
                autoRepair = true,
                autoRepairGuild = true,
                autoSell = true,
                autoSellPoorItems = true,
                autoSellUncommonItems = false,
                autoSellList = {},
                autoAcceptResurrect = true,
                autoAcceptSummon = true,
                autoRelease = true,
                autoReleaseInBattleground = true,
                autoReleaseInArena = false,
                autoReleaseDelay = 0.5,
                autoGossip = true,
                autoSkipCutscenes = false,
                autoQuestComplete = true,
                autoQuestAccept = true,
                autoQuestTrivial = false,
                autoQuestDaily = true,
                autoQuestAutoSelect = true,
                autoInvite = true,
                autoInviteKeywords = {"inv", "invite"},
                autoInviteGuild = false,
                autoInviteFriends = true,
                autoLeaveParty = false,
                autoLeavePartyDelay = 10.0,
                autoDismountFlying = true,
                autoStandUp = true,
                autoScreenshot = true,
                autoScreenshotAchievements = true,
                autoScreenshotLevelUp = true,
                autoScreenshotRare = true,
                autoScreenshotBoss = false,
                autoToggleBags = false,
                autoToggleMap = false,
                minimapZoom = true,
                autoResetInstances = false,
                autoResetInstancesConfirm = true,
                autoHideUI = false,
                autoHideUIInCombat = false,
                autoHideUIDelay = 30.0,
            },
            
            -- Premade Group Finder Module
            premadegroupfinder = {
                enabled = true,
                defaultTab = "search",
                defaultActivity = 0,
                defaultRole = "DAMAGER",
                autoCopy = true,
                autoRefresh = true,
                refreshInterval = 30,
                autoSignUp = false,
                autoSignUpMsg = "Hey there! Looking to join.",
                enhancedInfo = true,
                showLeaderScore = true,
                showLeaderClass = true,
                showLeaderItemLevel = true,
                showGroupComposition = true,
                showCompletionTime = true,
                showListed = true,
                groupCreation = {
                    autoGroup = false,
                    autoVoice = false,
                    defaultPrivate = false,
                    defaultTitle = "",
                    defaultVoice = "",
                    defaultItemLevel = 0,
                    useClassicDescription = true,
                    savedDescriptions = {},
                },
                filters = {
                    minItemLevel = 0,
                    maxItemLevel = 0,
                    minMythicLevel = 0,
                    maxMythicLevel = 0,
                    minMembers = 0,
                    maxMembers = 0,
                    filterClasses = false,
                    requiredClasses = {},
                    excludeClasses = {},
                    filterRoles = false,
                    requiredRoles = {},
                    missingRoles = {},
                    hideVoiceRequired = false,
                    hideFull = false,
                    hideInProgress = false,
                }
            },
            
            -- Visual Config Module
            visualconfig = {
                enabled = true,
                usePreview = true,
                previewScale = 0.8,
                theme = "thunderstorm",
                framerate = 60,
                showFramerate = true,
                showConfirmButtons = true,
                showCancelButton = true,
                confirmOnChange = false,
                savePositions = true,
                snapToGrid = true,
                gridSize = 10,
                showGrid = true,
                showTooltips = true,
                tooltipDelay = 0.5,
                panels = {
                    unitFrames = true,
                    actionBars = true,
                    nameplates = true,
                    buffs = true,
                    minimap = true,
                    raidFrames = true,
                    partyFrames = true,
                    castBars = true,
                },
            },
            
            -- Help Module
            help = {
                enabled = true,
                showTips = true,
                showStartupTip = true,
                showTooltipHelp = true,
                showContextualHelp = true,
                showKeyBindings = true,
                tipsProgress = {},
                tutorialProgress = {},
                tipsShown = {},
                tutorialsShown = {},
                helpPanelWidth = 300,
                helpPanelHeight = 400,
                helpPanelScale = 1.0,
                helpPanelPosition = { x = 0, y = 0 },
                videoGuides = true,
                imageGuides = true,
                searchHistory = {},
            },
            
            -- Tools Module
            tools = {
                enabled = true,
                showInDashboard = true,
                showInMinimap = true,
                customTools = {},
                internalTools = {
                    reloadUI = true,
                    configReset = true,
                    frameDebug = true,
                    textureDebug = true,
                    errorLog = true,
                    memoryUsage = true,
                },
                developerMode = false,
                developerTools = {
                    showAPIBrowser = false,
                    showExportTools = false,
                    showEventTracer = false,
                    showModuleInfo = false,
                },
                debugging = {
                    logLevel = "ERROR",
                    fileLogging = false,
                    chatLogging = false,
                    frameLogging = false,
                },
            },
            
            -- Skins Module
            skins = {
                enabled = true,
                skinFrameBorders = true,
                skinMainMenuBar = true,
                skinBags = true,
                skinLootFrames = true,
                skinQuestFrames = true,
                skinVendorFrames = true,
                skinBankFrames = true,
                skinAchievementFrames = true,
                skinCharacterFrame = true,
                skinSpellbookFrame = true,
                skinTalentFrame = true,
                skinTradeSkillFrame = true,
                skinGuildFrame = true,
                skinOptionsFrame = true,
                skinChatFrame = true,
                skinMailFrame = true,
                skinAuctionFrame = true,
                skinPvPFrames = true,
                skinEncounterJournal = true,
                skinCalendarFrame = true,
                skinBlizzardAlerts = true,
                skinStaticPopups = true,
                skinErrorFrames = true,
                skinInterfaceOptions = true,
                skinMacroFrame = true,
                skinHelpFrame = true,
                skinGarrisonFrames = true,
                skinBindingFrame = true,
                skinMirrorTimers = true,
                skinWorldMap = true,
                themeStyle = "thunderstorm",
                borderStyle = "thin",
                backdropOpacity = 0.8,
                backdropColor = { r = 0.04, g = 0.04, b = 0.1, a = 0.8 },
                borderColor = { r = 0.05, g = 0.62, b = 0.9, a = 1 },
                useClassColors = false,
                customSkins = {},
            },
            
            -- MultiNotification Module (already added this earlier, removing duplicate)
            multinotification = {
                enabled = true,
                scale = 1.0,
                position = { x = 0, y = 100 },
                iconSize = 36,
                textSize = 14,
                showText = true,
                showIcons = true,
                useAnimations = true,
                animationType = "bounce",
                duration = 3.0,
                spacing = 4,
                maxNotifications = 5,
                useSound = true,
                soundChannel = "Master",
                fadeTime = 0.5,
                groups = {
                    interrupts = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 },
                        sound = "VUI_Interrupt",
                        position = "TOP",
                    },
                    dispels = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.9, g = 0.7, b = 0.1, a = 1.0 },
                        sound = "VUI_Dispel",
                        position = "TOP",
                    },
                    defensives = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.2, g = 0.8, b = 0.2, a = 1.0 },
                        sound = "VUI_Defensive",
                        position = "TOP",
                    },
                    healing = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.2, g = 1.0, b = 0.2, a = 1.0 },
                        sound = "VUI_Healing",
                        position = "TOP",
                    },
                    damage = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 1.0, g = 0.2, b = 0.2, a = 1.0 },
                        sound = "VUI_Damage",
                        position = "TOP",
                    },
                    utility = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 0.8, g = 0.8, b = 0.2, a = 1.0 },
                        sound = "VUI_Utility",
                        position = "TOP",
                    },
                    warning = {
                        enabled = true,
                        showIcons = true,
                        showText = true,
                        textColor = { r = 1.0, g = 0.1, b = 0.1, a = 1.0 },
                        sound = "VUI_Warning",
                        position = "TOP",
                    },
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
