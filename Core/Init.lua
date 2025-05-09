VUI = LibStub("AceAddon-3.0"):NewAddon("VUI", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local addonName, addon = ...

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
                talkhead = false,
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
    if (VUIDB and not VUIDB.profiles.Default.reset) then
        VUIDB = {}
        print(
            '|cffea00ffS|r|cff00a2ffUI|r: |cffff0000You had a broken database from a previous version of VUI, unfortunately we had to reset the profile.|r')
    end

    -- Database
    self.db = LibStub("AceDB-3.0"):New("VUIDB", defaults, true)

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
end

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
