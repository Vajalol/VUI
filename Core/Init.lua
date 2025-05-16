VUI = LibStub("AceAddon-3.0"):NewAddon("VUI", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceConsole-3.0")
local addonName, addonTable = ...

-- Store addon table in VUI for easy access
VUI.addonTable = addonTable

-- Ensure the global VUI exists IMMEDIATELY and initialize module tracking
-- This must be at the very top to prevent nil errors
_G.VUI = VUI 
VUI._loadedModules = VUI._loadedModules or {}

-- Early debug function that works even before db is loaded
function VUI:Debug(module, ...)
    -- Skip if debug is disabled or db isn't loaded yet
    local debugEnabled = false
    if self.db and self.db.profile and self.db.profile.general then
        debugEnabled = self.db.profile.general.debug == true
    end
    
    -- Always show critical errors
    local isCritical = module == "CRITICAL"
    
    if not debugEnabled and not isCritical then
        return
    end
    
    local prefix = "|cffea00ffV|r|cff00a2ffUI|r"
    if module then
        prefix = prefix .. " [" .. module .. "]"
    end
    
    local msg = ""
    local args = {...}
    for i, v in ipairs(args) do
        if type(v) == "table" then
            msg = msg .. " " .. tostring(v)
        else
            msg = msg .. " " .. tostring(v)
        end
    end
    
    print(prefix .. ":" .. msg)
end

-- Print function that can be used anywhere, even during setup
function VUI:Print(...)
    local prefix = "|cffea00ffV|r|cff00a2ffUI|r"
    local msg = ""
    local args = {...}
    
    for i, v in ipairs(args) do
        if type(v) == "table" then
            msg = msg .. " " .. tostring(v)
        else
            msg = msg .. " " .. tostring(v)
        end
    end
    
    print(prefix .. ":" .. msg)
end

-- LSB Helper function needed by modules early
function VUI:LSB_Helper(LSBList, LSBHash)
    local list = {}
    for index, name in pairs(LSBList) do
        list[index] = {}
        for k, v in pairs(LSBHash) do
            if (name == k) then
                list[index] = {
                    text = name,
                    value = v
                }
            end
        end
    end
    return list
end

-- Module Management System
-- This centralized system will handle module initialization, tracking, and resolution
VUI._pendingModules = VUI._pendingModules or {}
VUI._moduleCallbacks = VUI._moduleCallbacks or {}

-- SafeGetModule: Get a module safely with fallback options
-- If module doesn't exist yet, registers it as pending
function VUI:SafeGetModule(moduleName, callback)
    if not self or not self.GetModule then
        -- Track the pending module request
        self._pendingModules[moduleName] = true
        
        -- Register callback if provided
        if callback and type(callback) == "function" then
            self._moduleCallbacks[moduleName] = self._moduleCallbacks[moduleName] or {}
            table.insert(self._moduleCallbacks[moduleName], callback)
        end
        
        return nil
    end
    
    local module = self:GetModule(moduleName, true) -- silent = true
    
    if module then
        -- Module exists, remove from pending
        self._pendingModules[moduleName] = nil
        self._loadedModules[moduleName] = module
        
        -- Execute any pending callbacks
        if self._moduleCallbacks[moduleName] then
            for _, cb in ipairs(self._moduleCallbacks[moduleName]) do
                xpcall(function() cb(module) end, geterrorhandler())
            end
            self._moduleCallbacks[moduleName] = nil
        end
        
        return module
    else
        -- Track the pending module request
        self._pendingModules[moduleName] = true
        
        -- Register callback if provided
        if callback and type(callback) == "function" then
            self._moduleCallbacks[moduleName] = self._moduleCallbacks[moduleName] or {}
            table.insert(self._moduleCallbacks[moduleName], callback)
        end
        
        -- Start retry timer if not already running
        if not self._pendingModuleTimer then
            self:StartPendingModuleTimer()
        end
        
        return nil
    end
end

-- TryCreateModule: Attempt to create a module with standardized fallback pattern
function VUI:TryCreateModule(moduleName, lib1, lib2, lib3, lib4, lib5)
    if not self or not self.NewModule then
        -- Create temporary module
        local tempModule = {
            NAME = moduleName,
            OnEnable = function() end,
            OnDisable = function() end,
            _isPendingModule = true,
            Debug = function(self, ...) 
                if VUI and VUI.Debug then 
                    VUI:Debug(moduleName, ...) 
                else 
                    -- Silent debug in fallback mode - prevents console spam
                end 
            end
        }
        
        -- Store in VUI namespace
        self[moduleName] = tempModule
        
        -- Don't print fallback message for known VModules that commonly use fallback
        local isSilentFallback = moduleName == "VUIKeystones" or 
                                moduleName == "VUIConsumables" or
                                moduleName == "VUISkin" or
                                moduleName == "VUIScrollingText"
                                
        if not isSilentFallback then
            print(moduleName .. ": Module registered via fallback method")
        end
        
        -- Setup retry
        C_Timer.After(0.5, function()
            if self and self.NewModule then
                -- Create real module and transfer properties
                local realModule
                
                -- We have to handle each possible number of arguments explicitly to avoid varargs issues
                if lib5 then
                    realModule = self:NewModule(moduleName, lib1, lib2, lib3, lib4, lib5)
                elseif lib4 then
                    realModule = self:NewModule(moduleName, lib1, lib2, lib3, lib4)
                elseif lib3 then
                    realModule = self:NewModule(moduleName, lib1, lib2, lib3)
                elseif lib2 then
                    realModule = self:NewModule(moduleName, lib1, lib2)
                elseif lib1 then
                    realModule = self:NewModule(moduleName, lib1)
                else
                    realModule = self:NewModule(moduleName)
                end
                
                -- Transfer properties
                for k, v in pairs(tempModule) do
                    if k ~= "NAME" and k ~= "_isPendingModule" and type(v) ~= "function" then
                        realModule[k] = v
                    end
                end
                
                -- Replace reference and initialize
                self[moduleName] = realModule
                self._loadedModules[moduleName] = realModule
                
                -- Run callbacks
                if self._moduleCallbacks[moduleName] then
                    for _, cb in ipairs(self._moduleCallbacks[moduleName]) do
                        xpcall(function() cb(realModule) end, geterrorhandler())
                    end
                    self._moduleCallbacks[moduleName] = nil
                end
                
                -- Initialize if needed
                if realModule.OnInitialize then 
                    realModule:OnInitialize() 
                end
                
                if realModule.OnEnable then 
                    realModule:OnEnable() 
                end
            end
        end)
        
        return tempModule
    else
        -- Create module normally
        local realModule
        
        -- Create with appropriate number of arguments
        if lib5 then
            realModule = self:NewModule(moduleName, lib1, lib2, lib3, lib4, lib5)
        elseif lib4 then
            realModule = self:NewModule(moduleName, lib1, lib2, lib3, lib4)
        elseif lib3 then
            realModule = self:NewModule(moduleName, lib1, lib2, lib3)
        elseif lib2 then
            realModule = self:NewModule(moduleName, lib1, lib2)
        elseif lib1 then
            realModule = self:NewModule(moduleName, lib1)
        else
            realModule = self:NewModule(moduleName)
        end
        
        self._loadedModules[moduleName] = realModule
        return realModule
    end
end

-- StartPendingModuleTimer: Start a timer to periodically retry loading pending modules
function VUI:StartPendingModuleTimer()
    if self._pendingModuleTimer then return end
    
    self._pendingModuleTimer = C_Timer.NewTicker(0.5, function()
        local anyLoaded = false
        local pendingCount = 0
        
        -- Try to load pending modules
        for moduleName in pairs(self._pendingModules) do
            pendingCount = pendingCount + 1
            
            if self and self.GetModule then
                local module = self:GetModule(moduleName, true) -- silent = true
                
                if module then
                    -- Module loaded successfully
                    self._pendingModules[moduleName] = nil
                    self._loadedModules[moduleName] = module
                    anyLoaded = true
                    
                    -- Call any registered callbacks
                    if self._moduleCallbacks[moduleName] then
                        for _, callback in ipairs(self._moduleCallbacks[moduleName]) do
                            xpcall(function() callback(module) end, geterrorhandler())
                        end
                        self._moduleCallbacks[moduleName] = nil
                    end
                    
                    -- Debug output
                    self:Debug("MODULE", "Loaded pending module: " .. moduleName)
                end
            end
        end
        
        -- If no more pending modules, cancel timer
        if pendingCount == 0 then
            self._pendingModuleTimer:Cancel()
            self._pendingModuleTimer = nil
        end
        
        -- If any modules were loaded, trigger UI refresh
        if anyLoaded then
            -- Notify any system that needs to be updated
            if self.RefreshModuleUI then
                self:RefreshModuleUI()
            end
        end
    end)
end

-- RegisterModuleCallback: Register a callback to run when a module is available
function VUI:RegisterModuleCallback(moduleName, callback)
    if not callback or type(callback) ~= "function" then return end
    
    -- Check if module already exists
    local module = self:GetModule(moduleName, true)
    if module then
        -- Module already exists, call callback immediately
        xpcall(function() callback(module) end, geterrorhandler())
        return
    end
    
    -- Register callback for later
    self._moduleCallbacks[moduleName] = self._moduleCallbacks[moduleName] or {}
    table.insert(self._moduleCallbacks[moduleName], callback)
    
    -- Mark as pending
    self._pendingModules[moduleName] = true
    
    -- Start retry timer if not already running
    if not self._pendingModuleTimer then
        self:StartPendingModuleTimer()
    end
end

-- RefreshModuleUI: Notify UI components to refresh (used by Config system)
function VUI:RefreshModuleUI()
    -- Call Config.Gui:RefreshConfig if it exists
    local configGui = self:GetModule("Config.Gui", true)
    if configGui and configGui.RefreshConfig then
        configGui:RefreshConfig()
    end
end

-- SafeFindModule: Find any module by name regardless of its type
-- This is a more flexible version of GetModule that can find:
-- 1. Standard AceAddon modules through GetModule
-- 2. VUI.ModuleName direct references
-- 3. VModules with or without VUI prefix
function VUI:SafeFindModule(moduleName, silent)
    if not moduleName then return nil end
    
    -- Try standard GetModule first
    if self.GetModule then
        local module = self:GetModule(moduleName, true)
        if module then return module end
    end
    
    -- Try direct references in VUI namespace
    if self[moduleName] then
        return self[moduleName]
    end
    
    -- For VModules, check with "VUI" prefix if not already there
    if not moduleName:match("^VUI") then
        local vmoduleName = "VUI" .. moduleName
        if self[vmoduleName] then
            return self[vmoduleName]
        end
    end
    
    -- For Data modules that might be stored without the prefix
    if moduleName:match("^Data%.") then
        local shortName = moduleName:match("Data%.(.+)")
        if shortName and self[shortName] then
            return self[shortName]
        end
    end
    
    -- Not found
    if not silent then
        self:Debug("MODULE", "Module not found: " .. moduleName)
    end
    return nil
end

-- SafeFindModuleWithRetry: Get a module with multiple retry attempts
-- If module doesn't exist yet, retries after delays
function VUI:SafeFindModuleWithRetry(moduleName, callbackFn, maxAttempts)
    maxAttempts = maxAttempts or 3
    local attempts = 0
    
    local function tryGetModule()
        attempts = attempts + 1
        local module = self:SafeFindModule(moduleName, true)
        
        if module then
            -- Module found, call the callback
            if callbackFn and type(callbackFn) == "function" then
                xpcall(function() callbackFn(module) end, geterrorhandler())
            end
            return true
        elseif attempts < maxAttempts then
            -- Retry after a delay with increasing interval
            C_Timer.After(attempts * 0.5, tryGetModule)
            return false
        else
            -- Max attempts reached, one final debug message
            self:Debug("MODULE", "Failed to find module after " .. attempts .. " attempts: " .. moduleName)
            return false
        end
    end
    
    -- Try immediately first
    local module = self:SafeFindModule(moduleName, true)
    if module then
        if callbackFn and type(callbackFn) == "function" then
            xpcall(function() callbackFn(module) end, geterrorhandler())
        end
        return module
    else
        -- Start retry process
        tryGetModule()
        return nil
    end
end

C_AddOns.DisableAddOn('LortiUI')
C_AddOns.DisableAddOn('UberUI')

local defaults = {
    profile = {
        install = false,
        reset = false,
        general = {
            theme = 'VUI',
            font = [[Interface\Addons\VUI\Media\Fonts\PTSansNarrow.ttf]],
            texture = [[Interface\Addons\VUI\Media\Textures\Status\Smooth.blp]],
            color = { r = 0, g = 0, b = 0, a = 1 },
            minimap = {
                scale = 1.0,
                position = "TOPRIGHT",
                enableBlizzard = false
            },
            fonts = {
                global = "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf",
                size = 12
            },
            colors = {
                primary = {r = 0.917, g = 0, b = 1, a = 1}, -- Vortex purple
                secondary = {r = 0, g = 0.635, b = 1, a = 1} -- VUI blue
            },
            automation = {
                delete = true,
                decline = false,
                repair = 'Default',
                sell = true,
                stackbuy = true,
                invite = false,
                release = false,
                resurrect = false,
                cinematic = false
            },
            cosmetic = {
                afkscreen = true,
                talkhead = true,
                errors = false
            },
            display = {
                ilvl = true,
                fps = true,
                ms = true,
                movementSpeed = false,
                lootspec = true
            },
            playerstats = {
                enabled = true, 
                combatOnly = false,
                transparency = 0.5,
                position = {"CENTER", UIParent, "CENTER", 200, 0},
                width = 200,
                height = 160
            }
        },
        unitframes = {
            style = 'Default',
            classcolor = true,
            factioncolor = true,
            pvpbadge = false,
            combaticon = false,
            hitindicator = false,
            totemicons = true,
            classbar = true,
            cornericon = true,
            player = {
                size = 1
            },
            target = {
                size = 1
            },
            buffs = {
                size = 26,
                collapse = false
            },
            debuffs = {
                size = 20
            }
        },
        nameplates = {
            style = 'Default',
            texture = [[Interface\Addons\VUI\Media\Textures\Status\Smooth.blp]],
            arenanumber = true,
            totemicons = true,
            healthtext = true,
            server = true,
            color = true,
            casttime = true,
            stackingmode = false,
            height = 2,
            width = 1,
            decimals = 0,
            debuffs = false,
            focusHighlight = false,
            colors = true,
            npccolors = {
                -- Mists of Tirna Scithe
                { id = 164921, name = 'Drust Harvester',         color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 166275, name = 'Mistveil Shaper',         color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 166299, name = 'Mistveil Tender',         color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 167111, name = 'Spinemaw Staghorn',       color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- The Necrotic Wake
                { id = 166302, name = 'Corpse Harvester',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 165137, name = 'Zolramus Gatekeeper',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 163128, name = 'Zolramus Sorcerer',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 163618, name = 'Zolramus Necromancer',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 163126, name = 'Brittlebone Mage',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 165919, name = 'Skeletal Marauder',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 165824, name = 'Nar\'zudah',              color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 173016, name = 'Corpse Collector',        color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- Siege of Boralus
                { id = 129370, name = 'Irontide Waveshaper',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 128969, name = 'Ashvane Commander',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 135241, name = 'Bilge Rat Pillager',      color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 129367, name = 'Bilge Rat Tempest',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 144071, name = 'Irontide Waveshaper',     color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- The Stonevault
                { id = 212389, name = 'Cursedheart Invader',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 212453, name = 'Ghastly Voidsoul',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 213338, name = 'Forgebound Mender',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 221979, name = 'Void Bound Howler',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 214350, name = 'Turned Speaker',          color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 214066, name = 'Cursedforge Stoneshaper', color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 224962, name = 'Cursedforge Mender',      color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- The Dawnbreaker
                { id = 213892, name = 'Nightfall Shadowmage',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 214762, name = 'Nightfall Commander',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 210966, name = 'Sureki Webmage',          color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 213893, name = 'Nightfall Darkcaster',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 213932, name = 'Sureki Militant',         color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- Grim Batol
                { id = 224219, name = 'Twilight Earthcaller',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 40167,  name = 'Twilight Beguiler',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 224271, name = 'Twilight Warlock',        color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- Ara-Kara
                { id = 216293, name = 'Trilling Attendant',      color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 217531, name = 'Ixin',                    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 218324, name = 'Nakt',                    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 217533, name = 'Atik',                    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 223253, name = 'Bloodstained Webmage',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 216340, name = 'Sentry Stagshell',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 220599, name = 'Bloodstained Webmage',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 216364, name = 'Blood Overseer',          color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- City of Threads
                { id = 220195, name = 'Sureki Silkbinder',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 220196, name = 'Herald Of Ansurek',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 219984, name = 'Xephitik',                color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 223844, name = 'Covert Webmancer',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 224732, name = 'Covert Webmancer',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 216339, name = 'Sureki Unnaturaler',      color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 221102, name = 'Elder Shadeweaver',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
            },
            vmodules = {
                vuiplater = {
                    enabled = false,
                    useWhiiskeyz = true,
                },
                vuitgcd = {
                    enabled = false
                }
            }
        },
        raidframes = {
            texture = [[Interface\Addons\VUI\Media\Textures\Status\Flat.blp]],
            alwaysontop = false,
            size = false,
            height = 75,
            width = 100,
        },
        actionbar = {
            buttons = {
                key = true,
                macro = true,
                range = true,
                flash = false,
                size = 12
            },
            pulseEffects = {
                enabled = true,
                intensity = 0.05
            },
            menu = {
                micromenu = 'show',
                bagbar = 'show'
            },
            bars = {
                bar1 = false,
                bar2 = false,
                bar3 = false,
                bar4 = false,
                bar5 = false,
                bar6 = false,
                bar7 = false,
                bar8 = false,
                petbar = false,
                stancebar = false
            }
        },
        castbars = {
            style = 'Custom',
            timer = true,
            icon = true,
            latency = true,
            targetname = true,
            targetCastbar = true,
            focusCastbar = true,
            focusSize = 1,
            targetSize = 1,
            targetOnTop = false,
            focusOnTop = false
        },
        tooltip = {
            style = 'Custom',
            lifeontop = true,
            mouseanchor = false,
            hideincombat = false,
            targetInfo = true,
            targetedInfo = true,
            playerTitles = true,
            guildRanks = true,
            roleIcon = true,
            gender = true,
            mountInfo = true,
            inspectInfo = true
        },
        buffs = {
            buff = {
                size = 32,
                padding = 2,
                icons = 10
            },
            debuff = {
                size = 34,
                padding = 2,
                icons = 10
            }
        },
        chat = {
            style = 'Custom',
            top = true,
            link = true,
            copy = true,
            friendlist = true,
            quickjoin = true,
            looticons = true,
            roleicons = true,
            history = true,
            emojis = true,
            sounds = true,
            whisperSound = true
        },
        maps = {
            minimapsize = 1,
            style = 'Default',
            small = false,
            opacity = 1,
            coords = true,
            minimap = true,
            clock = true,
            date = false,
            garrison = true,
            tracking = false,
            buttons = true,
            expansionbutton = false,
            pulsingBorder = false,
            pulseSpeed = 1.5,
        },
        misc = {
            safequeue = true,
            tabbinder = false,
            pulltimer = false,
            interrupt = false,
            dampening = true,
            arenanameplate = false,
            surrender = false,
            losecontrol = false,
            repbar = false,
            menubutton = true,
            dragonflying = true,
            uiscale = {
                enabled = false,
                scale = 0.65,
                helpShown = false,
            },
        },
        edit = {
            statsframe = {
                point = 'BOTTOMLEFT',
                x = 5,
                y = 3
            },
            queueicon = {
                point = 'CENTER',
                x = 0,
                y = 0
            },
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
            useThemeColors = true,
            
            -- Tooltip settings
            progressTooltip = true,
            progressTooltipMDT = false,
            progressFormat = 1,
            
            -- Timer and display settings
            silverGoldTimer = false,
            splitsFormat = 1,
            completionMessage = true,
            smallAffixes = true,
            
            -- Death and progress tracking
            deathTracker = true,
            recordSplits = false,
            
            -- UI enhancements
            showLevelModifier = false,
            hideTalkingHead = true,
            resetPopup = false,
            
            -- Dungeon-specific features
            autoGossip = true,
            cosRumors = false,
            
            -- Visual settings
            scheduleColor = {r = 0.1, g = 0.6, b = 0.8},
            completedColor = {r = 0.6, g = 0.8, b = 0.1},
            
            -- Frame positions
            objectivePosition = {"CENTER", nil, "CENTER", 0, 80},
            timerPosition = {"CENTER", nil, "CENTER", 0, 110},
            deathTrackerPosition = {"CENTER", nil, "CENTER", 240, 100},
            
            -- Leaderboard enhancements
            showLeaderRunSummary = true,
            enhancedLeaderboard = true,
            
            -- Weekly best frame
            weeklyBestFramePosition = {"TOPRIGHT", nil, "TOPRIGHT", -250, -15},
            weeklyBestFrameScale = 1,
            
            -- Chat and social features
            announceKeystones = true,
            announceChannel = "PARTY",
            announceMilestones = true,
            
            -- Legacy settings
            showInChat = true,
            announceKey = true
        },
        
        VUICC = {
            enabled = true,
            disableBlizzardCooldownText = true,
            fontSize = 18,
            fontFace = "Fonts\\FRIZQT__.TTF",
            fontOutline = "OUTLINE",
            minScale = 0.5,
            minDuration = 2,
            mmssThreshold = 90,
            tenthsThreshold = 5,
            effect = "PULSE",
            useThemeColors = true,
            useClassColors = false,
            styles = {
                soon = {r = 1, g = 0.2, b = 0.2},
                seconds = {r = 1, g = 1, b = 0.2},
                minutes = {r = 0.8, g = 0.8, b = 0.8},
                hours = {r = 0.6, g = 0.6, b = 0.6},
                days = {r = 0.4, g = 0.4, b = 0.4}
            }
        },
        
        VUICD = {
            enabled = true,
            modules = { ["Party"] = true },
            theme = {
                useThemeColors = true,
                useClassColors = true
            },
            party = {
                enabled = true,
                visibility = {
                    arena = true,
                    raid = true,
                    party = true,
                    scenario = true,
                    none = false,
                    outside = false,
                    inTest = true
                },
                icons = {
                    desaturate = true,
                    showTooltip = true,
                    tooltipScale = 1,
                    showCounter = true,
                    counterScale = 0.85,
                    scale = 0.85,
                    anchor = "TOPLEFT",
                    relativePoint = "BOTTOMLEFT",
                    padding = 1,
                    columns = 10,
                    statusBar = {
                        enabled = true,
                        position = "TOP",
                        width = 2,
                        height = 12,
                        showSpark = true,
                        statusBarTexture = "OmniCD-texture_flat",
                        useClassColor = true
                    }
                },
                spells = {
                    defensive = true,
                    offensive = true,
                    covenant = true,
                    interrupt = true,
                    utility = true,
                    custom = false
                },
                highlight = {
                    glowBuffs = true,
                    glowType = "warcraft",
                    notInterruptible = true
                },
                position = {
                    anchor = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    offsetX = 0,
                    offsetY = -50
                }
            }
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
            soundsEnabled = true,
            suppressErrors = true,
            
            -- Notification types
            showInterrupts = true,
            showDispels = true,
            showMisses = true,
            showReflects = true,
            showPetStatus = true,
            
            -- Visual settings
            notificationScale = 1.0,
            notificationDuration = 3.0,
            
            -- Position
            position = {"TOP", UIParent, "TOP", 0, -120},
            
            -- Font settings
            font = "Fonts\\FRIZQT__.TTF",
            fontSize = 18,
            fontOutline = "OUTLINE",
            
            -- Theme
            useThemeColors = true,
            colors = {
                interrupt = {r = 0.41, g = 0.8, b = 0.94, a = 1.0},
                dispel = {r = 0.84, g = 0.43, b = 1.0, a = 1.0},
                reflect = {r = 1.0, g = 0.5, b = 0.0, a = 1.0},
                miss = {r = 0.82, g = 0.82, b = 0.82, a = 1.0},
                pet = {r = 0.94, g = 0.41, b = 0.45, a = 1.0}
            },
            
            -- Legacy settings
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
            
            -- Animation settings
            style = "dynamic", -- "static", "dynamic", "fountain", "threshold", "vuithemed"
            animationSpeed = 1.5,
            useThemeColors = true,
            
            -- Font settings
            masterFont = "Friz Quadrata TT",
            normalFontSize = 18,
            normalOutlineIndex = 2, -- 1=None, 2=Thin, 3=Thick
            critFontSize = 26,
            critOutlineIndex = 2,
            critScale = 1.5,
            
            -- Display settings
            showIcon = true,
            showSchoolColors = true,
            mergeThreshold = 0.3,
            
            -- Sound settings
            soundsEnabled = true,
            
            -- Areas to display
            areas = {
                incoming = {
                    enabled = true,
                    position = {"CENTER", nil, "CENTER", 0, 100},
                    size = {300, 260},
                    scrollDirection = 1, -- SCROLL_UP
                    behavior = 1, -- BEHAVIOR_SCROLL
                    textAlign = "CENTER"
                },
                outgoing = {
                    enabled = true,
                    position = {"CENTER", nil, "CENTER", 0, -100},
                    size = {300, 260},
                    scrollDirection = 2, -- SCROLL_DOWN
                    behavior = 1, -- BEHAVIOR_SCROLL
                    textAlign = "CENTER"
                },
                notifications = {
                    enabled = true,
                    position = {"TOP", nil, "TOP", 0, -120},
                    size = {400, 100},
                    scrollDirection = 4, -- SCROLL_RIGHT
                    behavior = 4, -- BEHAVIOR_STATIC
                    textAlign = "CENTER"
                }
            },
            
            -- Events to trigger scrolling text
            events = {
                combatDamage = true,
                combatMisses = true,
                combatHealing = true,
                resourceGains = true,
                deaths = true,
                honorGains = true,
                buffGains = true,
                buffFades = true,
                combatState = true,
                lootItems = true,
                skillGains = true,
                experience = true
            },
            
            -- Color settings
            colors = {
                normal = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
                crit = {r = 1.0, g = 0.0, b = 0.0, a = 1.0},
                mana = {r = 0.0, g = 0.0, b = 1.0, a = 1.0},
                rage = {r = 1.0, g = 0.0, b = 0.0, a = 1.0},
                energy = {r = 1.0, g = 1.0, b = 0.0, a = 1.0},
                runic = {r = 0.0, g = 0.8, b = 1.0, a = 1.0},
                heal = {r = 0.0, g = 1.0, b = 0.0, a = 1.0},
                buff = {r = 0.0, g = 0.0, b = 1.0, a = 1.0},
                debuff = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
            }
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
            enabled = true,
            trailCount = 25,
            trailType = "PARTICLE",
            trailShape = "V_SHAPE",
            trailTexture = "flame01",
            trailSize = 25,
            trailAlpha = 0.7,
            trailDecay = 0.92,
            trailVariation = 0.2,
            trailSmoothing = 60,
            colorMode = "THEME",
            customColorR = 1.0,
            customColorG = 1.0,
            customColorB = 1.0,
            textureCategory = "Basic",
            connectSegments = false,
            enableGlow = false,
            pulsingGlow = false,
            showInCombat = true,
            showInInstances = true,
            showInRestArea = true,
            showInWorld = true,
            requireMouseButton = false,
            requireModifierKey = false,
            useThemeColor = true
        },
        
        VUIHealerMana = {
            enabled = true,
            scale = 1.0,
            point = "CENTER",
            relativePoint = "CENTER",
            xOffset = -200,
            yOffset = 0,
            width = 250,
            height = 20,
            spacing = 2,
            barTexture = "VUI Gradient",
            fontName = "Arial Narrow",
            fontSize = 12,
            showSelf = true,
            showParty = true,
            showRaid = true,
            
            -- Visual settings
            outlineMode = "OUTLINE",
            textPosition = "CENTER",
            useClassColors = true,
            useThemeColors = true,
            
            -- Behavior
            sortOrder = "ASCENDING",
            hideOOC = false,
            hideInCombat = false,
            hideNotInGroup = true,
            onlyShowLowMana = false,
            lowManaThreshold = 20,
            
            -- Color settings
            barColor = {r = 0.2, g = 0.4, b = 1.0, a = 1.0},
            textColor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            backgroundColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0.0, g = 0.0, b = 0.0, a = 1.0},
            
            -- Legacy settings
            showInParty = true,
            showInRaid = true,
            position = {"CENTER", UIParent, "CENTER", -200, 0}
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
        },
        
        VUISkin = {
            enabled = true,
            autoApply = true,
        },
    }
}

-- Function to be called from the installation wizard
function VUI:ConfigureFirstTimeSetup()
    -- Set defaults for all modules
    self:Print("First-time setup: Applying recommended settings to all modules")
    
    -- No need to copy settings from defaults table as they're already applied when creating the database
    -- This is just a placeholder for potential future custom logic
    
    self:Print("First-time setup complete: Applied recommended settings to all modules")
end

function VUI:OnInitialize()
    -- VUI DB Reset 10.0
    -- Also check _Install.lua for the next reset!
    if (VUI_SavedVariables and not VUI_SavedVariables.profiles.Default.reset) then
        VUI_SavedVariables = {}
        print(
            '|cffea00ffV|r|cff00a2ffUI|r: |cffff0000You had a broken database from a previous version of VUI, unfortunately we had to reset the profile.|r')
    end

    -- Database
    self.db = LibStub("AceDB-3.0"):New("VUI_SavedVariables", defaults, true)

    -- Colors
    local _, class = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[class]
    local customColor = self.db.profile.general.color
    local themes = {
        Blizzard = nil,
        Dark = { 0.3, 0.3, 0.3 },
        Class = { classColor.r, classColor.g, classColor.b },
        Custom = { customColor.r, customColor.g, customColor.b },
        VUI = { 0.05, 0.61, 0.9 }, -- #0D9DE6 (medium blue)
    }
    local theme = themes[self.db.profile.general.theme]

    self.Theme = {
        Register = function(n, f)
            --print('register')
            --if (self.Theme.Frames[n]) then f(true, self.Theme.Data) end
        end,
        Update = function()
            -- print("update")
            for n, f in pairs(self.Theme.Frames) do
                -- print(n)
                f(false, self.Theme.Data)
            end
        end,
        Data = function()
            local themes = {
                Blizzard = nil,
                Dark = { 0.3, 0.3, 0.3 },
                Class = { classColor.r, classColor.g, classColor.b },
                Custom = { customColor.r, customColor.g, customColor.b },
                VUI = { 0.05, 0.61, 0.9 }, -- #0D9DE6 (medium blue)
            }
            local theme = themes[self.db.profile.general.theme]
            return {
                style = self.db.profile.general.theme,
                color = self.db.profile.general.color
            }
        end,
        Frames = {
            Tooltip = function() end
        }
    }

    function self:Color(sub, alpha)
        if (theme) then
            if not (alpha) then alpha = 1 end
            local color = { 0, 0, 0, alpha }
            for key, value in pairs(theme) do
                if (sub) then color[key] = value - sub else color[key] = value end
            end
            return color
        end
    end
    
    function self:GetThemeColor()
        local currentTheme = self.db.profile.general.theme
        
        if currentTheme == 'VUI' then
            return {r = 0.05, g = 0.61, b = 0.9, a = 1.0} -- VUI blue
        elseif currentTheme == 'PhoenixFlame' then
            return {r = 0.90, g = 0.30, b = 0.05, a = 1.0} -- Phoenix Flame orange/red
        elseif currentTheme == 'FelEnergy' then
            return {r = 0.10, g = 0.80, b = 0.10, a = 1.0} -- Fel Energy green
        elseif currentTheme == 'ArcaneMystic' then
            return {r = 0.60, g = 0.20, b = 0.80, a = 1.0} -- Arcane Mystic purple
        elseif currentTheme == 'Custom' and self.db.profile.general.colors and self.db.profile.general.colors.primary then
            -- Use custom color if set
            return self.db.profile.general.colors.primary
        else
            -- Fallback to VUI blue if theme not recognized
            return {r = 0.05, g = 0.61, b = 0.9, a = 1.0}
        end
    end
    
    -- Stores modules that need to be updated when theme changes
    self.skinModules = {}
    
    -- Register a module to be notified of theme changes
    function self:RegisterSkinModule(module)
        if not module then return end
        
        -- Add to skin modules list if not already present
        for i, mod in ipairs(self.skinModules) do
            if mod == module then return end
        end
        
        table.insert(self.skinModules, module)
        self:Debug("Registered skin module: " .. (module.moduleName or "Unknown"))
    end
    
    -- Notify all skin modules of theme changes
    function self:NotifySkinModules()
        for _, module in ipairs(self.skinModules) do
            if module.OnThemeChanged then
                module:OnThemeChanged()
            end
        end
    end

    -- VUI Version check
    local currentVersion = C_AddOns.GetAddOnMetadata(addonName, "version")

    local function GetDefaultCommChannel()
        if IsInRaid() then
            return IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
        elseif IsInGroup() then
            return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
        elseif IsInGuild() then
            return "GUILD"
        else
            return "YELL"
        end
    end

    function self:ReceiveVersion(_, version, _, sender)
        if not VUI.db.profile.new_version then
            if (version > currentVersion) then
                print("|cffff00d5S|r|cff027bffUI|r:",
                    "A newer version is available. If you experience any errors or bugs, updating is highly recommended.")

                VUI.db.profile.new_version = version
            end
        elseif (VUI.db.profile.new_version == currentVersion) or (VUI.db.profile.new_version <= currentVersion) then
            VUI.db.profile.new_version = false
        end
    end

    function self:SendVersion(channel)
        self:SendCommMessage("VUIVersion", currentVersion, channel or GetDefaultCommChannel())
    end

    self:RegisterComm("VUIVersion", "ReceiveVersion")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        self:SendVersion()
        if IsInGuild() then self:SendVersion("GUILD") end
    end)
    C_Timer.After(30, function()
        self:SendVersion()
        if IsInGuild() then self:SendVersion("GUILD") end
        self:SendVersion("YELL")
    end)

    if (VUI.db.profile.new_version and VUI.db.profile.new_version > currentVersion) then
        print("|cffff00d5S|r|cff027bffUI|r:",
            "A newer version is available. If you experience any errors or bugs, updating is highly recommended.")
    end

    function self:Skin(frame, customColor, isTable)
        VUI_forbiddenFrames = {
            ["CalendarCreateEventIcon"] = true,
            ["FriendsFrameIcon"] = true,
            ["MacroFramePortrait"] = true,
            [select(3, GossipFrame:GetRegions())] = true,
            ["QuestFrameDetailPanelBg"] = true,
            [select(3, DressUpFrame:GetRegions())] = true,
            [select(2, ChatFrame1EditBox:GetRegions())] = true,
            [select(2, ChatFrame2EditBox:GetRegions())] = true,
            [select(2, ChatFrame3EditBox:GetRegions())] = true,
            [select(2, ChatFrame4EditBox:GetRegions())] = true,
            [select(2, ChatFrame5EditBox:GetRegions())] = true,
            [select(2, ChatFrame6EditBox:GetRegions())] = true,
            [select(2, ChatFrame7EditBox:GetRegions())] = true,
            [select(1, TradeFrame.RecipientOverlay:GetRegions())] = true,
            ["StaticPopup1AlertIcon"] = true,
            ["StaticPopup2AlertIcon"] = true,
            ["StaticPopup3AlertIcon"] = true,
            ["PVPReadyDialogBackground"] = true,
            ["LFGDungeonReadyDialogBackground"] = true,
            [select(4, LFGListInviteDialog:GetRegions())] = true,
        }

        if (frame) then
            local currentTheme = self.db.profile.general.theme
            local skinColor
            
            -- Determine color based on theme
            if currentTheme == "VUI" then
                -- Special case for VUI theme - use a slightly different approach
                -- Less desaturation for VUI theme to preserve the blue tint
                if customColor then
                    skinColor = { 0.05, 0.61, 0.9, 0.85 } -- Use VUI blue with reduced alpha
                else
                    skinColor = { 0.15, 0.15, 0.15, 1.0 }
                end
            else
                -- Use standard approach for other themes
                if customColor then
                    skinColor = VUI:Color(.15)
                else
                    skinColor = { 0.15, 0.15, 0.15, 1.0 }
                end
            end
            
            if not (isTable) then
                for _, v in pairs({ frame:GetRegions() }) do
                    if (not VUI_forbiddenFrames[v:GetName()]) and (not VUI_forbiddenFrames[v]) then
                        if v:GetObjectType() == "Texture" then
                            -- For VUI theme, apply limited desaturation to preserve color
                            if currentTheme == "VUI" and customColor then
                                v:SetDesaturated(false)
                            else
                                v:SetDesaturated(true)
                            end
                            v:SetVertexColor(unpack(skinColor))
                        end
                    end
                end
            else
                for _, v in pairs(frame) do
                    if (v) then
                        -- For VUI theme, apply limited desaturation to preserve color
                        if currentTheme == "VUI" and customColor then
                            v:SetDesaturated(false)
                        else
                            v:SetDesaturated(true)
                        end
                        v:SetVertexColor(unpack(skinColor))
                    end
                end
            end
        end
    end

    -- Create a minimal VUlegMixin implementation to prevent errors with frames trying to use it
    if not _G.VUlegMixin then
        _G.VUlegMixin = {
            OnLoad = function() end,
            InitMixin = function(self, frame)
                if not frame then return end
                frame.Loaded = function() end
                return frame
            end
        }
        
        -- Log that we've created the mixin
        if VUI and VUI.Debug then
            VUI:Debug("Core", "Created minimal VUlegMixin implementation")
        end
    end

    -- Create a VUIepfMixin implementation to prevent errors with VUIepf frames
    if not _G.VUIepfMixin then
        _G.VUIepfMixin = {
            Loaded = function(self)
                -- Minimal implementation to prevent 'Unknown method Loaded in element OnLoad' errors
                if VUI and VUI.Debug then
                    VUI:Debug("VUIepf", "VUIepfMixin.Loaded called")
                end
            end,
            
            Event_Received = function(self, event, ...)
                -- Empty implementation to prevent errors
            end
        }
        
        -- Log that we've created the mixin
        if VUI and VUI.Debug then
            VUI:Debug("Core", "Created minimal VUIepfMixin implementation")
        end
    end

    -- Add missing AddAddOnsLoaded function referenced by VUIMainBar
    if not _G.AddAddOnsLoaded then
        _G.AddAddOnsLoaded = function(addon, callback)
            if not addon or not callback then return end
            
            -- Check if the addon is already loaded
            if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(addon) then
                callback()
                return
            end
            
            -- Create event frame to wait for addon to load
            local frame = CreateFrame("Frame")
            frame:RegisterEvent("ADDON_LOADED")
            frame:SetScript("OnEvent", function(self, event, loadedAddon)
                if event == "ADDON_LOADED" and loadedAddon == addon then
                    callback()
                    self:UnregisterAllEvents()
                end
            end)
        end
    end
end

function VUI:OnEnable()
    -- Start the pending module timer to process any modules that were created before OnInitialize
    self:Debug("CORE", "VUI core addon enabled")
    
    -- Start the pending module timer if there are any pending modules
    if next(self._pendingModules) then
        self:Debug("MODULE", "Starting module loader for pending modules")
        self:StartPendingModuleTimer()
    end
    
    -- Force-load module placeholders that might have been created
    self:DelayedFixModules()
    
    -- Notify the user that VUI is loaded
    print("|cffea00ffV|r|cff00a2ffUI|r: Loaded successfully")
end

-- DelayedFixModules: Try to find and replace placeholder modules
function VUI:DelayedFixModules()
    C_Timer.After(1, function()
        -- Check for module placeholders
        for k, v in pairs(_G.VUI) do
            if type(v) == "table" and v._isPendingModule then
                self:Debug("MODULE", "Found pending module: " .. k)
                -- Replace with real module
                if type(self.NewModule) == "function" then
                    local realModule = self:NewModule(v.NAME or k)
                    
                    -- Transfer properties
                    for propK, propV in pairs(v) do
                        if propK ~= "NAME" and propK ~= "_isPendingModule" and type(propV) ~= "function" then
                            realModule[propK] = propV
                        end
                    end
                    
                    -- Replace reference
                    _G.VUI[k] = realModule
                    
                    -- Initialize if needed
                    if realModule.OnInitialize then
                        realModule:OnInitialize()
                    end
                    
                    if realModule.OnEnable then
                        realModule:OnEnable()
                    end
                    
                    self:Debug("MODULE", "Successfully replaced placeholder for: " .. k)
                end
            end
        end
    end)
end
