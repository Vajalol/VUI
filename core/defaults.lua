-- VUI Default Settings

-- Load defaults into VUI
function VUI:LoadDefaults()
    -- Core defaults
    self.defaults = {
        profile = {
            modules = {
                BuffOverlay = true,
                TrufiGCD = true,
                MoveAny = true,
                Auctionator = true,
                AngryKeystones = true,
                OmniCC = true,
                OmniCD = true
            },
            theme = {
                primaryColor = {0.09, 0.51, 0.82}, -- #1784d1
                accentColor = {0.9, 0.3, 0.3},
                font = "Expressway",
                fontSize = 12,
                barTexture = "Smooth"
            }
        }
    }
    
    -- BuffOverlay defaults
    self.BuffOverlay.defaults = {
        profile = {
            enabled = true,
            scale = 1.0,
            position = {"CENTER", UIParent, "CENTER", 0, 0},
            growthDirection = "UP",
            showDuration = true,
            showTimer = true,
            showIcon = true,
            showTooltip = true,
            backdrop = true,
            border = true,
            spacing = 2,
            size = 32,
            alpha = 1.0,
            filters = {
                blacklist = {},
                whitelist = {}
            }
        }
    }
    
    -- TrufiGCD defaults
    self.TrufiGCD.defaults = {
        profile = {
            enabled = true,
            fadeOutTime = 1.5,
            size = 30,
            maxIcons = 8,
            position = {"CENTER", UIParent, "CENTER", 0, -100},
            showSpellName = true,
            showCooldown = true,
            orientation = "HORIZONTAL",
            direction = "LEFT",
            showTooltip = true,
            hideInPetBattle = true,
            blacklist = {}
        }
    }
    
    -- MoveAny defaults
    self.MoveAny.defaults = {
        profile = {
            enabled = true,
            locked = false,
            showGrid = true,
            gridSize = 10,
            savedFrames = {},
            scale = {
                playerFrame = 1.0,
                targetFrame = 1.0,
                castingBar = 1.0,
                minimap = 1.0,
                buffs = 1.0,
                actionBars = 1.0
            }
        }
    }
    
    -- Auctionator defaults
    self.Auctionator.defaults = {
        profile = {
            enabled = true,
            autoScan = true,
            defaultTab = "SELLING",
            undercutPercentage = 5,
            defaultDuration = 24,
            tooltipPrice = true,
            tooltipTrend = true,
            displayBags = true,
            columnDisplay = {
                showQuantity = true,
                showItemLevel = true,
                showBid = false,
                showOwner = true
            }
        }
    }
    
    -- AngryKeystones defaults
    self.AngryKeystones.defaults = {
        profile = {
            enabled = true,
            showObjectives = true,
            showProgress = true,
            showSchedule = true,
            showDeathCounter = true,
            objectiveColor = {0.6, 0.8, 1},
            completedColor = {0.6, 0.8, 0.6},
            timerColor = {1, 1, 1},
            scheduleColor = {0.8, 0.8, 0.8},
            deathColor = {1, 0.3, 0.3},
            objectiveStyle = 1,
            progressFormat = 1
        }
    }
    
    -- OmniCC defaults
    self.OmniCC.defaults = {
        profile = {
            enabled = true,
            showText = true,
            showModels = true,
            fontSize = 12,
            fontOutline = "OUTLINE",
            minDuration = 2.5,
            minSize = 0.5,
            formatText = true,
            finishEffect = "PULSE",
            styles = {
                short = {r = 1, g = 0, b = 0},
                seconds = {r = 1, g = 1, b = 0.4},
                minutes = {r = 1, g = 1, b = 1},
                hours = {r = 0.7, g = 0.7, b = 0.7}
            }
        }
    }
    
    -- OmniCD defaults
    self.OmniCD.defaults = {
        profile = {
            enabled = true,
            showIcons = true,
            growUpward = false,
            iconSize = 30,
            barHeight = 12,
            showBars = true,
            barWidth = 150,
            texture = "Default",
            borderStyle = "Default",
            showTooltip = true,
            showCharges = true,
            filters = {
                showDefensives = true,
                showOffensives = true,
                showUtility = true,
                showInterrupts = true,
                showSelfBuffs = true,
                showCustom = true
            }
        }
    }
end
