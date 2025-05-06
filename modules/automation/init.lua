-- VUI Automation Module - Initialization
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the module using the module API
local Automation = VUI.ModuleAPI:CreateModule("automation")

-- Get configuration options for main UI integration
function Automation:GetConfig()
    local config = {
        name = "Automation",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Automation",
                desc = "Enable or disable the Automation module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            vendorHeader = {
                type = "header",
                name = "Vendor Automation",
                order = 10
            },
            autoSell = {
                type = "toggle",
                name = "Auto Sell Junk",
                desc = "Automatically sell junk items when visiting a vendor",
                get = function() return self.db.vendor.autoSell end,
                set = function(_, value) 
                    self.db.vendor.autoSell = value 
                end,
                order = 11
            },
            autoRepair = {
                type = "toggle",
                name = "Auto Repair",
                desc = "Automatically repair equipment when visiting a vendor",
                get = function() return self.db.vendor.autoRepair end,
                set = function(_, value) 
                    self.db.vendor.autoRepair = value 
                end,
                order = 12
            },
            useGuildRepair = {
                type = "toggle",
                name = "Use Guild Repairs",
                desc = "Use guild funds for repairs when possible",
                get = function() return self.db.vendor.useGuildRepair end,
                set = function(_, value) 
                    self.db.vendor.useGuildRepair = value 
                end,
                order = 13
            },
            questHeader = {
                type = "header",
                name = "Quest Automation",
                order = 20
            },
            autoAcceptQuests = {
                type = "toggle",
                name = "Auto Accept Quests",
                desc = "Automatically accept quests",
                get = function() return self.db.quest.autoAccept end,
                set = function(_, value) 
                    self.db.quest.autoAccept = value 
                end,
                order = 21
            },
            autoTurnIn = {
                type = "toggle",
                name = "Auto Turn In Quests",
                desc = "Automatically turn in completed quests",
                get = function() return self.db.quest.autoTurnIn end,
                set = function(_, value) 
                    self.db.quest.autoTurnIn = value 
                end,
                order = 22
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
-- Module config registration is done later with extended options

-- Set up module defaults
local defaults = {
    enabled = true,
    
    -- Vendor Automation
    vendor = {
        enabled = true,
        autoSell = true,           -- Auto-sell junk items
        autoRepair = true,         -- Auto-repair equipment
        useGuildRepair = true,     -- Use guild funds for repairs when possible
        detailedReportSell = true, -- Detailed report when selling items
        detailedReportRepair = true, -- Detailed report when repairing
        sellBelowQuality = 1,      -- Sell items below this quality (0-7, 0=Poor, 1=Common, etc.)
        sellList = {},             -- List of specific items to sell
        keepList = {},             -- List of specific items to keep (overrides other rules)
        maxSellsPerVisit = 12,     -- Maximum number of different items to sell per vendor visit
        autoSellLimit = 5000,      -- Gold limit for auto-selling (won't auto-sell items worth more)
    },
    
    -- Quest Automation
    quest = {
        enabled = true,
        autoAccept = true,           -- Auto-accept quests
        autoAcceptFromFriends = true, -- Only auto-accept quests from friends
        autoComplete = true,         -- Auto-complete quests
        autoSkipGossip = true,       -- Auto-skip NPC gossip text
        autoAcceptSharing = true,    -- Auto-accept shared quests from party members
        autoShareQuests = true,      -- Auto-share quests with party members
    },
    
    -- Chat Automation
    chat = {
        enabled = true,
        autoScreenshot = true,       -- Auto-screenshot achievements 
        autoFarewell = true,         -- Auto-say goodbye when party/raid disbands
        autoWelcome = true,          -- Auto-welcome players when they join party/raid
        autoThankRes = true,         -- Auto-thank players when they resurrect you
        autoThankSummon = true,      -- Auto-thank players when they summon you
        autoThankPortals = true,     -- Auto-thank mages for portals
        autoThankBuffs = true,       -- Auto-thank players for buffs
        autoInviteKeywords = {},     -- Keywords that trigger auto-invite when whispered
        
        -- Enhanced chat features
        useCustomMessages = true,    -- Use custom messages for automated responses
        customMessages = {
            welcome = "Welcome to the group, %s!",
            farewell = "Thanks for the group, everyone!",
            resurrect = "Thanks for the resurrection, %s!",
            summon = "Thanks for the summon, %s!",
            portal = "Thanks for the portal, %s!",
            buff = "Thanks for the %s, %s!"
        },
        colorizeNames = true,        -- Colorize player names by class in messages
        linkAchievements = true,     -- Link achievements in chat when congratulating
        highlightMythicPlus = true,  -- Highlight Mythic+ related messages
        highlightRaids = true,       -- Highlight Raid related messages
        mythicPlusKeyAnnouncement = true, -- Announce your keystone to the group
        hideChatDuringCombat = false, -- Hide chat frames during combat
        restoreChatAfterCombat = true, -- Restore chat frames after combat ends
        chatTimestamps = true,       -- Show timestamps in chat
        timestampFormat = "[%H:%M:%S] ", -- Format for chat timestamps
        filterRaidSpam = true,       -- Filter out common raid spam messages
        chatURLCopy = true,          -- Make URLs in chat clickable for easy copying
    },
    
    -- Combat Automation
    combat = {
        enabled = true,
        autoRoll = true,             -- Auto-roll on loot
        autoRollChoice = "need",     -- "need", "greed", or "pass"
        autoRelease = true,          -- Auto-release in battlegrounds
        autoDeclineDuels = true,     -- Auto-decline duel requests
        autoAcceptResurrect = true,  -- Auto-accept resurrection
        autoAcceptSummon = true,     -- Auto-accept summons
    },
    
    -- Quality of Life Improvements
    qol = {
        enabled = true,
        autoTrackQuests = true,       -- Auto-track quests when accepted
        autoTrackResourceNodes = true, -- Auto-track resource nodes on minimap
        instantLoot = true,           -- Instant loot without loot window
        improvedCinematic = true,     -- Enhanced cinematics (hide UI, etc.)
        autoDisableChatMoving = true, -- Auto-lock chat frames after moving
        mailboxTools = true,          -- Enhanced mailbox functionality
        fastLoot = true,              -- Faster looting
    },
    
    -- Mail Automation
    mail = {
        enabled = true,
        autoCollectAttachments = true, -- Auto-collect mail attachments
        autoMailItems = {},           -- Items to automatically mail to specific characters
        openAll = true,               -- Open all mail with one click
        keepFreeSlots = 5,            -- Keep this many bag slots free when auto-collecting
    },
    
    -- UI Automation
    ui = {
        enabled = true,
        hideErrorMessages = false,    -- Hide UI error messages (e.g., "Not enough energy")
        hideGryphons = true,          -- Hide the gryphon graphics on the action bar
        hideTalkingHead = true,       -- Hide talking head frame (NPC dialog popups)
        hideObjectiveTracker = false, -- Hide objective tracker during combat
        hideUIInCombat = false,       -- Hide non-essential UI elements during combat
        lockFramesAfterMoving = true, -- Lock frames after they've been moved
    },
    
    -- Auto Currency Tracking
    currencyTracking = {
        enabled = true,
        watchValor = true,           -- Track Valor Points
        watchConquest = true,        -- Track Conquest Points
        watchHonor = true,           -- Track Honor Points
        watchJustice = true,         -- Track Justice Points
        customCurrencies = {},       -- Custom currencies to track
    },
    
    -- Performance Optimizations
    performance = {
        enabled = true,
        combatCVars = {},           -- CVars to change during combat
        outOfCombatCVars = {},      -- CVars to change out of combat
        instanceCVars = {},         -- CVars to change in instances
        worldCVars = {},            -- CVars to change in the open world
        raidCVars = {},             -- CVars to change in raids
        autoAdjustEffects = true,   -- Auto-adjust effect density based on FPS
        autoAdjustDistance = true,  -- Auto-adjust view distance based on FPS
        targetFPS = 60,             -- Target frames per second
    },
}

-- Initialize module settings
Automation.settings = VUI.ModuleAPI:InitializeModuleSettings("automation", defaults)

-- Register module configuration
local config = {
    type = "group",
    name = "Automation",
    desc = "Automation and Quality of Life Improvements",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable automation module",
            order = 1,
            get = function() return VUI:IsModuleEnabled("automation") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("automation")
                else
                    VUI:DisableModule("automation")
                end
            end,
        },
        vendorHeader = {
            type = "header",
            name = "Vendor Automation",
            order = 2,
        },
        vendorEnabled = {
            type = "toggle",
            name = "Enable Vendor Automation",
            desc = "Enable or disable vendor automation features",
            order = 3,
            get = function() return Automation.settings.vendor.enabled end,
            set = function(_, value) 
                Automation.settings.vendor.enabled = value 
                Automation:UpdateVendorHooks()
            end,
        },
        autoSell = {
            type = "toggle",
            name = "Auto-sell Junk",
            desc = "Automatically sell junk (gray) items when visiting a vendor",
            order = 4,
            get = function() return Automation.settings.vendor.autoSell end,
            set = function(_, value) Automation.settings.vendor.autoSell = value end,
            disabled = function() return not Automation.settings.vendor.enabled end,
        },
        autoRepair = {
            type = "toggle",
            name = "Auto-repair Equipment",
            desc = "Automatically repair equipment when visiting a vendor",
            order = 5,
            get = function() return Automation.settings.vendor.autoRepair end,
            set = function(_, value) Automation.settings.vendor.autoRepair = value end,
            disabled = function() return not Automation.settings.vendor.enabled end,
        },
        useGuildRepair = {
            type = "toggle",
            name = "Use Guild Funds for Repairs",
            desc = "Use guild funds for repairs when possible",
            order = 6,
            get = function() return Automation.settings.vendor.useGuildRepair end,
            set = function(_, value) Automation.settings.vendor.useGuildRepair = value end,
            disabled = function() return not (Automation.settings.vendor.enabled and Automation.settings.vendor.autoRepair) end,
        },
        detailedReportSell = {
            type = "toggle",
            name = "Detailed Sell Report",
            desc = "Show detailed report when auto-selling items",
            order = 7,
            get = function() return Automation.settings.vendor.detailedReportSell end,
            set = function(_, value) Automation.settings.vendor.detailedReportSell = value end,
            disabled = function() return not (Automation.settings.vendor.enabled and Automation.settings.vendor.autoSell) end,
        },
        detailedReportRepair = {
            type = "toggle",
            name = "Detailed Repair Report",
            desc = "Show detailed report when auto-repairing",
            order = 8,
            get = function() return Automation.settings.vendor.detailedReportRepair end,
            set = function(_, value) Automation.settings.vendor.detailedReportRepair = value end,
            disabled = function() return not (Automation.settings.vendor.enabled and Automation.settings.vendor.autoRepair) end,
        },
        sellBelowQuality = {
            type = "select",
            name = "Sell Items Below Quality",
            desc = "Automatically sell items below this quality level",
            order = 9,
            values = {
                [0] = "Poor (Gray)",
                [1] = "Common (White)",
                [2] = "Uncommon (Green)",
                [3] = "Rare (Blue)",
                [4] = "Epic (Purple)",
            },
            get = function() return Automation.settings.vendor.sellBelowQuality end,
            set = function(_, value) Automation.settings.vendor.sellBelowQuality = value end,
            disabled = function() return not (Automation.settings.vendor.enabled and Automation.settings.vendor.autoSell) end,
        },
        autoSellLimit = {
            type = "range",
            name = "Auto-Sell Value Limit",
            desc = "Maximum value in gold per item for auto-selling (0 = no limit)",
            order = 10,
            min = 0,
            max = 1000000,
            step = 100,
            get = function() return Automation.settings.vendor.autoSellLimit end,
            set = function(_, value) Automation.settings.vendor.autoSellLimit = value end,
            disabled = function() return not (Automation.settings.vendor.enabled and Automation.settings.vendor.autoSell) end,
        },
        questHeader = {
            type = "header",
            name = "Quest Automation",
            order = 11,
        },
        questEnabled = {
            type = "toggle",
            name = "Enable Quest Automation",
            desc = "Enable or disable quest automation features",
            order = 12,
            get = function() return Automation.settings.quest.enabled end,
            set = function(_, value) 
                Automation.settings.quest.enabled = value 
                Automation:UpdateQuestHooks()
            end,
        },
        autoAccept = {
            type = "toggle",
            name = "Auto-accept Quests",
            desc = "Automatically accept quests when talking to NPCs",
            order = 13,
            get = function() return Automation.settings.quest.autoAccept end,
            set = function(_, value) Automation.settings.quest.autoAccept = value end,
            disabled = function() return not Automation.settings.quest.enabled end,
        },
        autoAcceptFromFriends = {
            type = "toggle",
            name = "Only Auto-accept from Friends",
            desc = "Only auto-accept quests from friends and guildmates",
            order = 14,
            get = function() return Automation.settings.quest.autoAcceptFromFriends end,
            set = function(_, value) Automation.settings.quest.autoAcceptFromFriends = value end,
            disabled = function() return not (Automation.settings.quest.enabled and Automation.settings.quest.autoAccept) end,
        },
        autoComplete = {
            type = "toggle",
            name = "Auto-complete Quests",
            desc = "Automatically complete quests when talking to NPCs",
            order = 15,
            get = function() return Automation.settings.quest.autoComplete end,
            set = function(_, value) Automation.settings.quest.autoComplete = value end,
            disabled = function() return not Automation.settings.quest.enabled end,
        },
        autoSkipGossip = {
            type = "toggle",
            name = "Auto-skip Gossip",
            desc = "Automatically skip NPC gossip text",
            order = 16,
            get = function() return Automation.settings.quest.autoSkipGossip end,
            set = function(_, value) Automation.settings.quest.autoSkipGossip = value end,
            disabled = function() return not Automation.settings.quest.enabled end,
        },
        chatHeader = {
            type = "header",
            name = "Chat Automation",
            order = 17,
        },
        chatEnabled = {
            type = "toggle",
            name = "Enable Chat Automation",
            desc = "Enable or disable chat automation features",
            order = 18,
            get = function() return Automation.settings.chat.enabled end,
            set = function(_, value) 
                Automation.settings.chat.enabled = value 
                Automation:UpdateChatHooks()
            end,
        },
        autoScreenshot = {
            type = "toggle",
            name = "Auto-screenshot Achievements",
            desc = "Automatically take a screenshot when you earn an achievement",
            order = 19,
            get = function() return Automation.settings.chat.autoScreenshot end,
            set = function(_, value) Automation.settings.chat.autoScreenshot = value end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        autoThankRes = {
            type = "toggle",
            name = "Auto-thank for Resurrection",
            desc = "Automatically thank players when they resurrect you",
            order = 20,
            get = function() return Automation.settings.chat.autoThankRes end,
            set = function(_, value) Automation.settings.chat.autoThankRes = value end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        autoThankSummon = {
            type = "toggle",
            name = "Auto-thank for Summon",
            desc = "Automatically thank players when they summon you",
            order = 21,
            get = function() return Automation.settings.chat.autoThankSummon end,
            set = function(_, value) Automation.settings.chat.autoThankSummon = value end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        chatEnhancedHeader = {
            type = "header",
            name = "Enhanced Chat Features",
            order = 22,
        },
        useCustomMessages = {
            type = "toggle",
            name = "Use Custom Messages",
            desc = "Use custom messages for automated responses",
            order = 23,
            get = function() return Automation.settings.chat.useCustomMessages end,
            set = function(_, value) Automation.settings.chat.useCustomMessages = value end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        colorizeNames = {
            type = "toggle",
            name = "Colorize Player Names by Class",
            desc = "Colorize player names by their class in automated messages",
            order = 24,
            get = function() return Automation.settings.chat.colorizeNames end,
            set = function(_, value) Automation.settings.chat.colorizeNames = value end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        chatTimestamps = {
            type = "toggle",
            name = "Show Timestamps in Chat",
            desc = "Add timestamps to all chat messages",
            order = 25,
            get = function() return Automation.settings.chat.chatTimestamps end,
            set = function(_, value) 
                Automation.settings.chat.chatTimestamps = value 
                Automation:UpdateChatTimestamps()
            end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        filterRaidSpam = {
            type = "toggle",
            name = "Filter Trade/General Spam",
            desc = "Filter common spam messages from trade and general channels",
            order = 26,
            get = function() return Automation.settings.chat.filterRaidSpam end,
            set = function(_, value) 
                Automation.settings.chat.filterRaidSpam = value
                -- Needs UI reload to take effect if toggling off
                if not value and Automation.filterRaidSpamHooked then
                    VUI:Print("You'll need to reload your UI for this change to take effect.")
                end
            end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        chatURLCopy = {
            type = "toggle",
            name = "Clickable URLs in Chat",
            desc = "Make URLs in chat clickable for easy copying",
            order = 27,
            get = function() return Automation.settings.chat.chatURLCopy end,
            set = function(_, value) 
                Automation.settings.chat.chatURLCopy = value 
                if value then
                    Automation:SetupChatURLCopy()
                else
                    VUI:Print("You'll need to reload your UI for this change to take effect.")
                end
            end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        chatSettingsButton = {
            type = "execute",
            name = "Open Chat Settings",
            desc = "Open the enhanced chat settings panel",
            order = 28,
            func = function()
                -- Create a standalone config window
                if not VUI.chatConfigFrame then
                    local AceGUI = LibStub("AceGUI-3.0")
                    local frame = AceGUI:Create("Frame")
                    frame:SetTitle("VUI Enhanced Chat Settings")
                    frame:SetLayout("Flow")
                    frame:SetWidth(550)
                    frame:SetHeight(600)
                    frame:EnableResize(false)
                    
                    -- Pass the frame to our config function
                    Automation:CreateEnhancedChatConfigTab(frame)
                    
                    VUI.chatConfigFrame = frame
                else
                    if VUI.chatConfigFrame:IsShown() then
                        VUI.chatConfigFrame:Hide()
                    else
                        -- Refresh content
                        VUI.chatConfigFrame:ReleaseChildren()
                        Automation:CreateEnhancedChatConfigTab(VUI.chatConfigFrame)
                        VUI.chatConfigFrame:Show()
                    end
                end
            end,
            disabled = function() return not Automation.settings.chat.enabled end,
        },
        combatHeader = {
            type = "header",
            name = "Combat Automation",
            order = 22,
        },
        combatEnabled = {
            type = "toggle",
            name = "Enable Combat Automation",
            desc = "Enable or disable combat automation features",
            order = 23,
            get = function() return Automation.settings.combat.enabled end,
            set = function(_, value) 
                Automation.settings.combat.enabled = value 
                Automation:UpdateCombatHooks()
            end,
        },
        autoRoll = {
            type = "toggle",
            name = "Auto-roll on Loot",
            desc = "Automatically roll on loot",
            order = 24,
            get = function() return Automation.settings.combat.autoRoll end,
            set = function(_, value) Automation.settings.combat.autoRoll = value end,
            disabled = function() return not Automation.settings.combat.enabled end,
        },
        autoRollChoice = {
            type = "select",
            name = "Auto-roll Choice",
            desc = "Choose how to roll on loot automatically",
            order = 25,
            values = {
                ["need"] = "Need",
                ["greed"] = "Greed",
                ["pass"] = "Pass",
            },
            get = function() return Automation.settings.combat.autoRollChoice end,
            set = function(_, value) Automation.settings.combat.autoRollChoice = value end,
            disabled = function() return not (Automation.settings.combat.enabled and Automation.settings.combat.autoRoll) end,
        },
        autoRelease = {
            type = "toggle",
            name = "Auto-release in Battlegrounds",
            desc = "Automatically release when you die in battlegrounds",
            order = 26,
            get = function() return Automation.settings.combat.autoRelease end,
            set = function(_, value) Automation.settings.combat.autoRelease = value end,
            disabled = function() return not Automation.settings.combat.enabled end,
        },
        autoDeclineDuels = {
            type = "toggle",
            name = "Auto-decline Duels",
            desc = "Automatically decline duel requests",
            order = 27,
            get = function() return Automation.settings.combat.autoDeclineDuels end,
            set = function(_, value) Automation.settings.combat.autoDeclineDuels = value end,
            disabled = function() return not Automation.settings.combat.enabled end,
        },
        qolHeader = {
            type = "header",
            name = "Quality of Life",
            order = 28,
        },
        qolEnabled = {
            type = "toggle",
            name = "Enable QoL Features",
            desc = "Enable or disable quality of life features",
            order = 29,
            get = function() return Automation.settings.qol.enabled end,
            set = function(_, value) 
                Automation.settings.qol.enabled = value 
                Automation:UpdateQoLHooks()
            end,
        },
        instantLoot = {
            type = "toggle",
            name = "Instant Loot",
            desc = "Automatically loot items without showing the loot window",
            order = 30,
            get = function() return Automation.settings.qol.instantLoot end,
            set = function(_, value) 
                Automation.settings.qol.instantLoot = value 
                -- Update the CVar based on the setting
                SetCVar("autoLootDefault", value and "1" or "0")
            end,
            disabled = function() return not Automation.settings.qol.enabled end,
        },
        fastLoot = {
            type = "toggle",
            name = "Fast Loot",
            desc = "Increases looting speed",
            order = 31,
            get = function() return Automation.settings.qol.fastLoot end,
            set = function(_, value) 
                Automation.settings.qol.fastLoot = value 
                Automation:UpdateFastLoot(value)
            end,
            disabled = function() return not Automation.settings.qol.enabled end,
        },
        uiHeader = {
            type = "header",
            name = "UI Automation",
            order = 32,
        },
        uiEnabled = {
            type = "toggle",
            name = "Enable UI Automation",
            desc = "Enable or disable UI automation features",
            order = 33,
            get = function() return Automation.settings.ui.enabled end,
            set = function(_, value) 
                Automation.settings.ui.enabled = value 
                Automation:UpdateUIHooks()
            end,
        },
        hideGryphons = {
            type = "toggle",
            name = "Hide Gryphons",
            desc = "Hide the gryphon graphics on the action bar",
            order = 34,
            get = function() return Automation.settings.ui.hideGryphons end,
            set = function(_, value) 
                Automation.settings.ui.hideGryphons = value 
                Automation:UpdateUIElements()
            end,
            disabled = function() return not Automation.settings.ui.enabled end,
        },
        hideTalkingHead = {
            type = "toggle",
            name = "Hide Talking Head",
            desc = "Hide the talking head frame (NPC dialog popups)",
            order = 35,
            get = function() return Automation.settings.ui.hideTalkingHead end,
            set = function(_, value) 
                Automation.settings.ui.hideTalkingHead = value 
                Automation:UpdateUIElements()
            end,
            disabled = function() return not Automation.settings.ui.enabled end,
        },
        hideObjectiveTracker = {
            type = "toggle",
            name = "Hide Objective Tracker in Combat",
            desc = "Hide objective tracker during combat",
            order = 36,
            get = function() return Automation.settings.ui.hideObjectiveTracker end,
            set = function(_, value) 
                Automation.settings.ui.hideObjectiveTracker = value 
                Automation:UpdateUIElements()
            end,
            disabled = function() return not Automation.settings.ui.enabled end,
        },
        performanceHeader = {
            type = "header",
            name = "Performance Optimizations",
            order = 37,
        },
        performanceEnabled = {
            type = "toggle",
            name = "Enable Performance Optimizations",
            desc = "Enable or disable performance optimization features",
            order = 38,
            get = function() return Automation.settings.performance.enabled end,
            set = function(_, value) 
                Automation.settings.performance.enabled = value 
                Automation:UpdatePerformanceHooks()
            end,
        },
        autoAdjustEffects = {
            type = "toggle",
            name = "Auto-adjust Effects",
            desc = "Automatically adjust effect density based on FPS",
            order = 39,
            get = function() return Automation.settings.performance.autoAdjustEffects end,
            set = function(_, value) Automation.settings.performance.autoAdjustEffects = value end,
            disabled = function() return not Automation.settings.performance.enabled end,
        },
        targetFPS = {
            type = "range",
            name = "Target FPS",
            desc = "Target frames per second for auto-adjustments",
            order = 40,
            min = 30,
            max = 144,
            step = 5,
            get = function() return Automation.settings.performance.targetFPS end,
            set = function(_, value) Automation.settings.performance.targetFPS = value end,
            disabled = function() return not (Automation.settings.performance.enabled and 
                (Automation.settings.performance.autoAdjustEffects or Automation.settings.performance.autoAdjustDistance)) end,
        },
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("automation", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("automation", "vuiauto", function(input)
    if not input or input:trim() == "" then
        -- Show configuration panel
        VUI.ModuleAPI:OpenModuleConfig("automation")
    elseif input:trim() == "toggle" then
        -- Toggle the module
        if VUI:IsModuleEnabled("automation") then
            VUI:DisableModule("automation")
            VUI:Print("Automation module disabled.")
        else
            VUI:EnableModule("automation")
            VUI:Print("Automation module enabled.")
        end
    elseif input:trim() == "vendor" then
        -- Toggle vendor automation
        Automation.settings.vendor.enabled = not Automation.settings.vendor.enabled
        VUI:Print("Vendor automation " .. (Automation.settings.vendor.enabled and "enabled" or "disabled") .. ".")
        Automation:UpdateVendorHooks()
    elseif input:trim() == "quest" then
        -- Toggle quest automation
        Automation.settings.quest.enabled = not Automation.settings.quest.enabled
        VUI:Print("Quest automation " .. (Automation.settings.quest.enabled and "enabled" or "disabled") .. ".")
        Automation:UpdateQuestHooks()
    elseif input:trim() == "help" then
        -- Show help
        VUI:Print("Automation Commands:")
        VUI:Print("  /vuiauto - Open configuration panel")
        VUI:Print("  /vuiauto toggle - Toggle automation module")
        VUI:Print("  /vuiauto vendor - Toggle vendor automation")
        VUI:Print("  /vuiauto quest - Toggle quest automation")
        VUI:Print("  /vuiauto help - Show this help")
    else
        -- Unknown command, show help
        VUI:Print("Unknown command: " .. input)
        VUI:Print("Type /vuiauto help for a list of commands.")
    end
end)

-- Initialize module
function Automation:Initialize()
    -- Register with VUI
    VUI:Print("Automation module initialized")
    
    -- Create debug counter to track performance
    self.debugCounter = 0
    
    -- Register for UI integration
    VUI.ModuleAPI:EnableModuleUI("automation", function(module)
        module:SetupHooks()
    end)
    
    -- Register events
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
    self:RegisterEvent("QUEST_DETAIL", "OnQuestDetail")
    self:RegisterEvent("QUEST_PROGRESS", "OnQuestProgress")
    self:RegisterEvent("QUEST_COMPLETE", "OnQuestComplete")
    self:RegisterEvent("GOSSIP_SHOW", "OnGossipShow")
    self:RegisterEvent("PLAYER_DEAD", "OnPlayerDead")
    self:RegisterEvent("RESURRECT_REQUEST", "OnResurrectRequest")
    self:RegisterEvent("CONFIRM_SUMMON", "OnConfirmSummon")
    self:RegisterEvent("DUEL_REQUESTED", "OnDuelRequested")
    self:RegisterEvent("ACHIEVEMENT_EARNED", "OnAchievementEarned")
    self:RegisterEvent("LOOT_READY", "OnLootReady")
    self:RegisterEvent("PARTY_INVITE_REQUEST", "OnPartyInviteRequest")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate")
    self:RegisterEvent("START_LOOT_ROLL", "OnStartLootRoll")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeaveCombat")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("MAIL_SHOW", "OnMailShow")
    self:RegisterEvent("MAIL_CLOSED", "OnMailClosed")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnUnitSpellcastSucceeded")
    
    -- Initialize state variables
    self.inCombat = InCombatLockdown()
    self.lootItems = {}
    self.partyMembers = {}
    self.mailOpened = false
    self.mailCollecting = false
    self.gossipDialogOpen = false
    
    -- Initialize fast loot
    self:UpdateFastLoot(self.settings.qol.fastLoot)
end

-- Enable module
function Automation:Enable()
    self.enabled = true
    
    -- Set up hooks and integrations
    self:SetupHooks()
    
    -- Update UI elements
    self:UpdateUIElements()
    
    VUI:Print("Automation module enabled")
end

-- Disable module
function Automation:Disable()
    self.enabled = false
    
    VUI:Print("Automation module disabled")
end

-- Event registration helper
function Automation:RegisterEvent(event, method)
    if type(method) == "string" and self[method] then
        method = self[method]
    end
    
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    self.eventFrame:RegisterEvent(event)
    self[event] = method
end

-- Set up hooks
function Automation:SetupHooks()
    -- We'll use separate functions for each category of hooks
    self:UpdateVendorHooks()
    self:UpdateQuestHooks()
    self:UpdateChatHooks()
    self:UpdateCombatHooks()
    self:UpdateQoLHooks()
    self:UpdateUIHooks()
    self:UpdatePerformanceHooks()
    
    -- Mark hooks as created
    self.hooksCreated = true
end

-- Update vendor hooks
function Automation:UpdateVendorHooks()
    -- This function will be implemented in core.lua
end

-- Update quest hooks
function Automation:UpdateQuestHooks()
    -- This function will be implemented in core.lua
end

-- Update chat hooks
function Automation:UpdateChatHooks()
    -- This function will be implemented in core.lua
end

-- Update combat hooks
function Automation:UpdateCombatHooks()
    -- This function will be implemented in core.lua
end

-- Update QoL hooks
function Automation:UpdateQoLHooks()
    -- This function will be implemented in core.lua
end

-- Update UI hooks
function Automation:UpdateUIHooks()
    -- This function will be implemented in core.lua
end

-- Update performance hooks
function Automation:UpdatePerformanceHooks()
    -- This function will be implemented in core.lua
end

-- Update UI elements
function Automation:UpdateUIElements()
    -- This function will be implemented in core.lua
end

-- Update fast loot
function Automation:UpdateFastLoot(enabled)
    -- This function will be implemented in core.lua
end

-- Event handlers - these will be detailed in core.lua
function Automation:OnMerchantShow() end
function Automation:OnMerchantClosed() end
function Automation:OnQuestDetail() end
function Automation:OnQuestProgress() end
function Automation:OnQuestComplete() end
function Automation:OnGossipShow() end
function Automation:OnPlayerDead() end
function Automation:OnResurrectRequest() end
function Automation:OnConfirmSummon() end
function Automation:OnDuelRequested() end
function Automation:OnAchievementEarned() end
function Automation:OnLootReady() end
function Automation:OnPartyInviteRequest() end
function Automation:OnGroupRosterUpdate() end
function Automation:OnStartLootRoll() end
function Automation:OnEnterCombat() self.inCombat = true end
function Automation:OnLeaveCombat() self.inCombat = false end
function Automation:OnPlayerEnteringWorld() end
function Automation:OnMailShow() end
function Automation:OnMailClosed() end
function Automation:OnUnitSpellcastSucceeded() end

-- Register the module with VUI
VUI.automation = Automation