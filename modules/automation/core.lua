-- VUI Automation Module - Core Functionality
local _, VUI = ...
local Automation = VUI.automation

-- Create event frame if it doesn't exist
Automation.eventFrame = Automation.eventFrame or CreateFrame("Frame")

-- Register an event and its handler
function Automation:RegisterEvent(event, handler)
    if not self.eventMap then
        self.eventMap = {}
        
        -- Set up OnEvent handler for the event frame
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            local handlers = Automation.eventMap[event]
            if handlers then
                for _, func in ipairs(handlers) do
                    func(...)
                end
            end
        end)
    end
    
    -- Register the event if not already registered
    if not self.eventMap[event] then
        self.eventMap[event] = {}
        self.eventFrame:RegisterEvent(event)
    end
    
    -- Add the handler to the event map
    table.insert(self.eventMap[event], handler)
end

-- Constants for better code readability
local QUALITY_POOR = 0     -- Gray
local QUALITY_COMMON = 1   -- White
local QUALITY_UNCOMMON = 2 -- Green
local QUALITY_RARE = 3     -- Blue
local QUALITY_EPIC = 4     -- Purple

-- Cache frequently used global functions
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local UseContainerItem = UseContainerItem
local GetItemInfo = GetItemInfo
local CanMerchantRepair = CanMerchantRepair
local GetRepairAllCost = GetRepairAllCost
local RepairAllItems = RepairAllItems
local GetQuestReward = GetQuestReward
local CompleteQuest = CompleteQuest
local GetNumQuestChoices = GetNumQuestChoices
local AcceptQuest = AcceptQuest
local SelectGossipOption = SelectGossipOption
local SelectGossipAvailableQuest = SelectGossipAvailableQuest
local SelectGossipActiveQuest = SelectGossipActiveQuest
local GetGossipAvailableQuests = GetGossipAvailableQuests
local GetGossipActiveQuests = GetGossipActiveQuests
local GetGossipOptions = GetGossipOptions
local ConfirmSummon = ConfirmSummon
local AcceptResurrect = AcceptResurrect
local Screenshot = Screenshot
local DeclineDuel = DeclineDuel
local RollOnLoot = RollOnLoot
local RepopMe = RepopMe
local StaticPopup_Hide = StaticPopup_Hide
local InCombatLockdown = InCombatLockdown
local GetTime = GetTime
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName
local UnitIsFriend = UnitIsFriend
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID
local GetFPS = GetFPS
local SendChatMessage = SendChatMessage

-- Update vendor hooks
function Automation:UpdateVendorHooks()
    if not self.enabled or not self.settings.vendor.enabled then return end
    
    -- Already hooked
    if self.vendorHooksCreated then return end
    
    -- Mark hooks as created
    self.vendorHooksCreated = true
end

-- Update quest hooks
function Automation:UpdateQuestHooks()
    if not self.enabled or not self.settings.quest.enabled then return end
    
    -- Already hooked
    if self.questHooksCreated then return end
    
    -- Mark hooks as created
    self.questHooksCreated = true
end

-- Update chat hooks
function Automation:UpdateChatHooks()
    if not self.enabled or not self.settings.chat.enabled then return end
    
    -- Already hooked
    if self.chatHooksCreated then return end
    
    -- Hook achievements if screenshot enabled
    if self.settings.chat.autoScreenshot and not self.achievementHooked then
        self:RegisterEvent("ACHIEVEMENT_EARNED", self.OnAchievementEarned)
        self.achievementHooked = true
    end
    
    -- Set up chat timestamps if enabled
    if self.settings.chat.chatTimestamps then
        self:UpdateChatTimestamps()
    end
    
    -- Set up URL copying if enabled
    if self.settings.chat.chatURLCopy then
        self:SetupChatURLCopy()
    end
    
    -- Handle hiding chat during combat
    if self.settings.chat.hideChatDuringCombat and not self.combatHooked then
        self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
            self:UpdateChatVisibilityForCombat(true)
        end)
        
        self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
            self:UpdateChatVisibilityForCombat(false)
        end)
        
        self.combatHooked = true
    end
    
    -- Handle highlighting Mythic+ and Raid messages
    if (self.settings.chat.highlightMythicPlus or self.settings.chat.highlightRaids) and not self.chatHighlightHooked then
        -- Hook chat messages to highlight keywords
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame.AddMessage then
                local originalAddMessage = chatFrame.AddMessage
                chatFrame.AddMessage = function(self, text, ...)
                    if type(text) == "string" then
                        -- Highlight Mythic+ related messages
                        if Automation.settings.chat.highlightMythicPlus then
                            text = text:gsub("([Mm]ythic%+)", "|cff00FFFF%1|r")
                            text = text:gsub("([Mm]%+)", "|cff00FFFF%1|r")
                            text = text:gsub("([Kk]ey%s?[Ss]tone)", "|cff00FFFF%1|r")
                            text = text:gsub("([Kk]ey%s?[Ll]evel)", "|cff00FFFF%1|r")
                        end
                        
                        -- Highlight Raid related messages
                        if Automation.settings.chat.highlightRaids then
                            text = text:gsub("([Rr]aid)", "|cffFF8000%1|r")
                            text = text:gsub("([Bb]oss)", "|cffFF8000%1|r")
                            text = text:gsub("([Pp]rogress)", "|cffFF8000%1|r")
                            text = text:gsub("([Ll]oot)", "|cffFF8000%1|r")
                        end
                    end
                    return originalAddMessage(self, text, ...)
                end
            end
        end
        
        self.chatHighlightHooked = true
    end
    
    -- Handle mythic keystone announcement
    if self.settings.chat.mythicPlusKeyAnnouncement and not self.keystoneHooked then
        self:RegisterEvent("GROUP_JOINED", function()
            -- Delay to ensure we're fully in the group
            C_Timer.After(2, function()
                if not IsInGroup() then return end
                
                -- Check if we have a keystone in bags
                local keystoneLink = nil
                for bag = 0, NUM_BAG_SLOTS do
                    for slot = 1, GetContainerNumSlots(bag) do
                        local itemID = GetContainerItemID(bag, slot)
                        if itemID and itemID == 180653 then -- Mythic Keystone ID
                            local itemLink = GetContainerItemLink(bag, slot)
                            local dungeonName, keystoneLevel = itemLink:match("|h%[Keystone: (.+) %((%d+)%)%]|h")
                            if dungeonName and keystoneLevel then
                                keystoneLink = itemLink
                                
                                -- Announce keystone to group
                                SendChatMessage("My keystone: " .. dungeonName .. " +" .. keystoneLevel, "PARTY")
                                return
                            end
                        end
                    end
                end
            end)
        end)
        
        self.keystoneHooked = true
    end
    
    -- Handle chat message filtering if enabled
    if self.settings.chat.filterRaidSpam and not self.filterRaidSpamHooked then
        -- Simple chat filter
        local spamPatterns = {
            "wts",
            "wtb",
            "guild.*recruit",
            "buy.*gold",
            "sell.*gold",
            "boost.*run",
            "carry.*raid",
            "carry.*dungeon",
            "www%.",
            "%.com",
            "discord",
        }
        
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_, _, message, _, _, _, _, _, channelName, _, _, _, lineID)
            -- Skip if it's not a trade/general/LFG channel
            if not channelName:match("Trade") and not channelName:match("General") and not channelName:match("LookingForGroup") then
                return false
            end
            
            -- Check against spam patterns
            message = message:lower()
            for _, pattern in ipairs(spamPatterns) do
                if message:match(pattern) then
                    return true -- Filter this message
                end
            end
            
            return false -- Allow the message
        end)
        
        self.filterRaidSpamHooked = true
    end
    
    -- Mark hooks as created
    self.chatHooksCreated = true
end

-- Update combat hooks
function Automation:UpdateCombatHooks()
    if not self.enabled or not self.settings.combat.enabled then return end
    
    -- Already hooked
    if self.combatHooksCreated then return end
    
    -- Mark hooks as created
    self.combatHooksCreated = true
end

-- Update QoL hooks
function Automation:UpdateQoLHooks()
    if not self.enabled or not self.settings.qol.enabled then return end
    
    -- Already hooked
    if self.qolHooksCreated then return end
    
    -- Mark hooks as created
    self.qolHooksCreated = true
end

-- Update UI hooks
function Automation:UpdateUIHooks()
    if not self.enabled or not self.settings.ui.enabled then return end
    
    -- Already hooked
    if self.uiHooksCreated then return end
    
    -- Hook talking head frame if needed
    if self.settings.ui.hideTalkingHead then
        if TalkingHeadFrame then
            hooksecurefunc(TalkingHeadFrame, "Show", function(self)
                self:Hide()
            end)
        end
    end
    
    -- Mark hooks as created
    self.uiHooksCreated = true
end

-- Update performance hooks
function Automation:UpdatePerformanceHooks()
    if not self.enabled or not self.settings.performance.enabled then return end
    
    -- Already hooked
    if self.performanceHooksCreated then return end
    
    -- Set up FPS monitoring if needed
    if self.settings.performance.autoAdjustEffects or self.settings.performance.autoAdjustDistance then
        if not self.fpsMonitorFrame then
            self.fpsMonitorFrame = CreateFrame("Frame")
            
            -- Initialize variables
            self.currentFPS = GetFPS()
            self.fpsHistory = {}
            self.fpsHistoryIndex = 1
            self.fpsHistorySize = 20 -- Store the last 20 FPS readings
            self.lastFPSUpdate = GetTime()
            self.lastCVarAdjustment = GetTime()
            
            -- Set up the FPS monitoring
            self.fpsMonitorFrame:SetScript("OnUpdate", function(_, elapsed)
                if not Automation.enabled or not Automation.settings.performance.enabled then
                    Automation.fpsMonitorFrame:SetScript("OnUpdate", nil)
                    return
                end
                
                -- Only update every 1 second
                local currentTime = GetTime()
                if currentTime - Automation.lastFPSUpdate < 1 then
                    return
                end
                
                -- Get current FPS
                Automation.currentFPS = GetFPS()
                
                -- Store in history
                Automation.fpsHistory[Automation.fpsHistoryIndex] = Automation.currentFPS
                Automation.fpsHistoryIndex = (Automation.fpsHistoryIndex % Automation.fpsHistorySize) + 1
                
                -- Update the timestamp
                Automation.lastFPSUpdate = currentTime
                
                -- Only adjust CVars every 10 seconds to avoid thrashing
                if currentTime - Automation.lastCVarAdjustment < 10 then
                    return
                end
                
                -- Calculate average FPS
                local totalFPS = 0
                local count = 0
                for _, fps in ipairs(Automation.fpsHistory) do
                    if fps and fps > 0 then
                        totalFPS = totalFPS + fps
                        count = count + 1
                    end
                end
                
                local averageFPS = count > 0 and totalFPS / count or Automation.currentFPS
                
                -- Adjust CVars if necessary
                Automation:AdjustCVarsBasedOnFPS(averageFPS)
                
                -- Update the timestamp
                Automation.lastCVarAdjustment = currentTime
            end)
        end
    end
    
    -- Mark hooks as created
    self.performanceHooksCreated = true
end

-- Adjust CVars based on FPS
function Automation:AdjustCVarsBasedOnFPS(averageFPS)
    if not self.enabled or not self.settings.performance.enabled then return end
    
    local targetFPS = self.settings.performance.targetFPS
    
    -- Adjust effect density if enabled
    if self.settings.performance.autoAdjustEffects then
        local currentEffectDensity = tonumber(GetCVar("effectDensity") or "1.0")
        
        if averageFPS < targetFPS * 0.8 and currentEffectDensity > 0.1 then
            -- FPS is too low, reduce effects
            local newDensity = math.max(0.1, currentEffectDensity - 0.1)
            SetCVar("effectDensity", newDensity)
            VUI:DebugPrint("Reduced effect density to " .. newDensity .. " (FPS: " .. averageFPS .. ")")
        elseif averageFPS > targetFPS * 1.2 and currentEffectDensity < 1.0 then
            -- FPS is high, can increase effects
            local newDensity = math.min(1.0, currentEffectDensity + 0.1)
            SetCVar("effectDensity", newDensity)
            VUI:DebugPrint("Increased effect density to " .. newDensity .. " (FPS: " .. averageFPS .. ")")
        end
    end
    
    -- Adjust view distance if enabled
    if self.settings.performance.autoAdjustDistance then
        local currentDistance = tonumber(GetCVar("farclip") or "1000")
        
        if averageFPS < targetFPS * 0.8 and currentDistance > 500 then
            -- FPS is too low, reduce view distance
            local newDistance = math.max(500, currentDistance - 100)
            SetCVar("farclip", newDistance)
            VUI:DebugPrint("Reduced view distance to " .. newDistance .. " (FPS: " .. averageFPS .. ")")
        elseif averageFPS > targetFPS * 1.2 and currentDistance < 2000 then
            -- FPS is high, can increase view distance
            local newDistance = math.min(2000, currentDistance + 100)
            SetCVar("farclip", newDistance)
            VUI:DebugPrint("Increased view distance to " .. newDistance .. " (FPS: " .. averageFPS .. ")")
        end
    end
end

-- Update UI elements
function Automation:UpdateUIElements()
    if not self.enabled or not self.settings.ui.enabled then return end
    
    -- Hide gryphons if needed
    if self.settings.ui.hideGryphons then
        if MainMenuBarLeftEndCap and MainMenuBarRightEndCap then
            MainMenuBarLeftEndCap:Hide()
            MainMenuBarRightEndCap:Hide()
        end
    else
        if MainMenuBarLeftEndCap and MainMenuBarRightEndCap then
            MainMenuBarLeftEndCap:Show()
            MainMenuBarRightEndCap:Show()
        end
    end
    
    -- Set up hiding objective tracker in combat
    if self.settings.ui.hideObjectiveTracker then
        if not self.objectiveTrackerHooked and ObjectiveTrackerFrame then
            self.objectiveTrackerOriginalState = ObjectiveTrackerFrame:IsVisible()
            
            -- Hook into combat events
            self.eventFrame:HookScript("OnEvent", function(_, event)
                if event == "PLAYER_REGEN_DISABLED" then -- Entering combat
                    self.objectiveTrackerOriginalState = ObjectiveTrackerFrame:IsVisible()
                    ObjectiveTrackerFrame:Hide()
                elseif event == "PLAYER_REGEN_ENABLED" then -- Leaving combat
                    if self.objectiveTrackerOriginalState then
                        ObjectiveTrackerFrame:Show()
                    end
                end
            end)
            
            self.objectiveTrackerHooked = true
        end
    end
end

-- Update fast loot
function Automation:UpdateFastLoot(enabled)
    if not self.enabled or not self.settings.qol.enabled then return end
    
    -- Clear previous setup if any
    if self.fastLootHooked then
        if self.lootEventFrame then
            self.lootEventFrame:UnregisterAllEvents()
            self.lootEventFrame:SetScript("OnEvent", nil)
            self.lootEventFrame = nil
        end
        self.fastLootHooked = false
    end
    
    -- Set up fast loot if needed
    if enabled then
        if not self.lootEventFrame then
            self.lootEventFrame = CreateFrame("Frame")
            self.lootEventFrame:RegisterEvent("LOOT_READY")
            self.lootEventFrame:SetScript("OnEvent", function()
                if InCombatLockdown() and not Automation.settings.qol.lootInCombat then
                    return
                end
                
                if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
                    for i = GetNumLootItems(), 1, -1 do
                        LootSlot(i)
                    end
                end
            end)
            
            self.fastLootHooked = true
        end
    end
end

-- Event handler for when a merchant window opens
function Automation:OnMerchantShow()
    if not self.enabled or not self.settings.vendor.enabled then return end
    
    -- Delay to ensure merchant frame is fully loaded
    C_Timer.After(0.2, function()
        -- Auto-repair equipment if enabled
        if self.settings.vendor.autoRepair and CanMerchantRepair() then
            local repairCost, canRepair = GetRepairAllCost()
            
            if canRepair and repairCost > 0 then
                -- Try to use guild funds if allowed
                if self.settings.vendor.useGuildRepair and CanGuildBankRepair() and repairCost <= GetGuildBankWithdrawMoney() then
                    RepairAllItems(true) -- Use guild funds
                    if self.settings.vendor.detailedReportRepair then
                        VUI:Print(string.format("Repair cost of %.2f gold paid from guild bank.", repairCost / 10000))
                    end
                else
                    -- Use player funds
                    RepairAllItems(false)
                    if self.settings.vendor.detailedReportRepair then
                        VUI:Print(string.format("Repair cost: %.2f gold", repairCost / 10000))
                    end
                end
            end
        end
        
        -- Auto-sell items if enabled
        if self.settings.vendor.autoSell then
            local soldItems = {}
            local totalValue = 0
            local itemsSold = 0
            
            -- Function to check if an item should be kept
            local function shouldKeepItem(link, quality)
                -- Check keep list
                if self.settings.vendor.keepList[link] then
                    return true
                end
                
                -- Check quality threshold
                if quality >= self.settings.vendor.sellBelowQuality then
                    return true
                end
                
                -- Check specific list of items to sell
                if self.settings.vendor.sellList[link] then
                    return false
                end
                
                return false
            end
            
            -- Loop through all bags
            for bag = 0, NUM_BAG_SLOTS do
                local numSlots = GetContainerNumSlots(bag)
                
                for slot = 1, numSlots do
                    -- Check if we've hit the maximum items to sell per visit
                    if itemsSold >= self.settings.vendor.maxSellsPerVisit then
                        break
                    end
                    
                    local link = GetContainerItemLink(bag, slot)
                    
                    if link then
                        local _, _, quality, _, _, _, _, _, _, _, value = GetItemInfo(link)
                        
                        -- Skip items that should be kept or are too valuable
                        if not shouldKeepItem(link, quality) and 
                           value <= self.settings.vendor.autoSellLimit then
                            -- Sell the item
                            UseContainerItem(bag, slot)
                            
                            -- Track sold items
                            if self.settings.vendor.detailedReportSell then
                                soldItems[link] = (soldItems[link] or 0) + 1
                                totalValue = totalValue + value
                                itemsSold = itemsSold + 1
                            end
                        end
                    end
                end
            end
            
            -- Report sold items if requested
            if self.settings.vendor.detailedReportSell and totalValue > 0 then
                VUI:Print("Items sold:")
                
                for link, count in pairs(soldItems) do
                    local _, _, quality, _, _, _, _, _, _, _, value = GetItemInfo(link)
                    VUI:Print(string.format("  %s x%d (%.2f gold)", link, count, (value * count) / 10000))
                end
                
                VUI:Print(string.format("Total value: %.2f gold", totalValue / 10000))
            end
        end
    end)
end

-- Event handler for when a merchant window closes
function Automation:OnMerchantClosed()
    -- Clean up any merchant-related state
end

-- Event handler for when quest detail is shown
function Automation:OnQuestDetail()
    if not self.enabled or not self.settings.quest.enabled then return end
    
    if self.settings.quest.autoAccept then
        -- Check if we should only accept from friends
        if self.settings.quest.autoAcceptFromFriends then
            local questOffered = QuestGetAutoAccept() or (QuestFrame and QuestFrame.questGiver)
            
            -- Only auto-accept from friends/guildmates/NPCs
            if questOffered then
                if QuestFrame and QuestFrame.questGiver and QuestFrame.questGiver.unit then
                    local isNPC = not UnitIsPlayer(QuestFrame.questGiver.unit)
                    local isFriend = UnitIsFriend("player", QuestFrame.questGiver.unit)
                    local isGuildMember = false
                    
                    -- Check if in guild
                    if UnitIsPlayer(QuestFrame.questGiver.unit) then
                        local numGuildMembers = GetNumGuildMembers()
                        local targetName = UnitName(QuestFrame.questGiver.unit)
                        
                        for i = 1, numGuildMembers do
                            local name = GetGuildRosterInfo(i)
                            if name == targetName then
                                isGuildMember = true
                                break
                            end
                        end
                    end
                    
                    -- Accept if it's an NPC, friend, or guild member
                    if isNPC or isFriend or isGuildMember then
                        AcceptQuest()
                    end
                else
                    -- Default behavior if we can't determine the quest giver
                    AcceptQuest()
                end
            else
                -- Default behavior if we can't determine the quest giver
                AcceptQuest()
            end
        else
            -- Auto-accept from anyone
            AcceptQuest()
        end
    end
end

-- Event handler for when quest progress is shown
function Automation:OnQuestProgress()
    if not self.enabled or not self.settings.quest.enabled then return end
    
    if self.settings.quest.autoComplete and IsQuestCompletable() then
        CompleteQuest()
    end
end

-- Event handler for when quest completion is shown
function Automation:OnQuestComplete()
    if not self.enabled or not self.settings.quest.enabled then return end
    
    if self.settings.quest.autoComplete then
        -- If there's a reward to select
        if GetNumQuestChoices() > 1 then
            -- We don't auto-select rewards, as this could choose the wrong item
            -- User needs to select reward manually
        else
            -- Either no reward or only one choice
            GetQuestReward(GetNumQuestChoices() > 0 and 1 or 0)
        end
    end
end

-- Event handler for when gossip is shown
function Automation:OnGossipShow()
    if not self.enabled or not self.settings.quest.enabled then return end
    
    if self.settings.quest.autoSkipGossip then
        -- Select available quests
        local availableQuests = {GetGossipAvailableQuests()}
        if #availableQuests > 0 then
            SelectGossipAvailableQuest(1)
            return
        end
        
        -- Select active quests
        local activeQuests = {GetGossipActiveQuests()}
        if #activeQuests > 0 then
            SelectGossipActiveQuest(1)
            return
        end
        
        -- Select gossip options if only one is available
        local options = {GetGossipOptions()}
        if #options == 2 then
            SelectGossipOption(1)
        end
    end
end

-- Event handler for when player dies
function Automation:OnPlayerDead()
    if not self.enabled or not self.settings.combat.enabled then return end
    
    if self.settings.combat.autoRelease then
        -- Check if we're in a battleground
        local _, instanceType = IsInInstance()
        if instanceType == "pvp" or instanceType == "arena" then
            RepopMe()
        end
    end
end

-- Event handler for when resurrection is requested
function Automation:OnResurrectRequest()
    if not self.enabled or not self.settings.combat.enabled then return end
    
    if self.settings.combat.autoAcceptResurrect then
        -- Get the name of the player resurrecting us
        local resser = UnitName("npc")
        
        AcceptResurrect()
        StaticPopup_Hide("RESURRECT")
        
        -- Thank the player if needed
        if self.settings.chat.enabled and self.settings.chat.autoThankRes and resser then
            local message = "Thanks for the resurrection, %s!"
            
            -- Use custom message if enabled
            if self.settings.chat.useCustomMessages and self.settings.chat.customMessages.resurrect then
                message = self.settings.chat.customMessages.resurrect
            end
            
            -- Format the message
            message = string.format(message, resser)
            
            -- Add class color to player name if enabled
            if self.settings.chat.colorizeNames then
                local _, class = UnitClass(resser)
                if class then
                    local classColor = RAID_CLASS_COLORS[class]
                    if classColor then
                        local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                            classColor.r * 255, 
                            classColor.g * 255, 
                            classColor.b * 255, 
                            resser)
                        message = string.gsub(message, resser, coloredName)
                    end
                end
            end
            
            SendChatMessage(message, "WHISPER", nil, resser)
        end
    end
end

-- Event handler for when summon is confirmed
function Automation:OnConfirmSummon()
    if not self.enabled or not self.settings.combat.enabled then return end
    
    if self.settings.combat.autoAcceptSummon then
        -- Auto-accept summon if not in combat
        if not InCombatLockdown() then
            ConfirmSummon()
            StaticPopup_Hide("CONFIRM_SUMMON")
            
            -- Thank the summoner if needed
            if self.settings.chat.enabled and self.settings.chat.autoThankSummon then
                -- Try to find the summoner
                local summoner = UnitName("npc")
                
                if summoner then
                    local message = "Thanks for the summon, %s!"
                    
                    -- Use custom message if enabled
                    if self.settings.chat.useCustomMessages and self.settings.chat.customMessages.summon then
                        message = self.settings.chat.customMessages.summon
                    end
                    
                    -- Format the message
                    message = string.format(message, summoner)
                    
                    -- Add class color to player name if enabled
                    if self.settings.chat.colorizeNames then
                        local _, class = UnitClass(summoner)
                        if class then
                            local classColor = RAID_CLASS_COLORS[class]
                            if classColor then
                                local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                                    classColor.r * 255, 
                                    classColor.g * 255, 
                                    classColor.b * 255, 
                                    summoner)
                                message = string.gsub(message, summoner, coloredName)
                            end
                        end
                    end
                    
                    SendChatMessage(message, "WHISPER", nil, summoner)
                else
                    -- Generic group thank you
                    local message = "Thanks for the summon!"
                    
                    -- Use custom message if enabled (but remove the %s if present)
                    if self.settings.chat.useCustomMessages and self.settings.chat.customMessages.summon then
                        message = self.settings.chat.customMessages.summon:gsub("%%s", ""):gsub("  ", " ")
                    end
                    
                    SendChatMessage(message, "PARTY")
                end
            end
        end
    end
end

-- Event handler for when duel is requested
function Automation:OnDuelRequested()
    if not self.enabled or not self.settings.combat.enabled then return end
    
    if self.settings.combat.autoDeclineDuels then
        DeclineDuel()
    end
end

-- Event handler for when achievement is earned
function Automation:OnAchievementEarned()
    if not self.enabled or not self.settings.chat.enabled then return end
    
    if self.settings.chat.autoScreenshot then
        -- Delay the screenshot slightly to ensure the achievement popup is visible
        C_Timer.After(1, function()
            Screenshot()
        end)
    end
end

-- Event handler for when loot is ready
function Automation:OnLootReady()
    if not self.enabled or not self.settings.qol.enabled then return end
    
    -- This is handled by the fast loot system if enabled
end

-- Event handler for when party invite is requested
function Automation:OnPartyInviteRequest(sender)
    if not self.enabled or not self.settings.chat.enabled then return end
    
    -- Auto-invite based on keywords
    if #self.settings.chat.autoInviteKeywords > 0 then
        for _, keyword in ipairs(self.settings.chat.autoInviteKeywords) do
            if sender:lower():find(keyword:lower()) then
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
                break
            end
        end
    end
end

-- Event handler for when group roster updates
function Automation:OnGroupRosterUpdate()
    if not self.enabled or not self.settings.chat.enabled then return end
    
    -- Get current group members
    local currentMembers = {}
    
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = UnitName("raid" .. i)
            if name then
                currentMembers[name] = true
            end
        end
    else
        for i = 1, GetNumGroupMembers() do
            local name = UnitName("party" .. i)
            if name then
                currentMembers[name] = true
            end
        end
        
        -- Add the player
        currentMembers[UnitName("player")] = true
    end
    
    -- Check for people who left
    if self.settings.chat.autoFarewell then
        for name in pairs(self.partyMembers) do
            if not currentMembers[name] then
                -- Player left the group
                if UnitIsPlayer("player") and name ~= UnitName("player") then
                    -- Don't say farewell to ourselves, and make sure we're not the one who left
                    if IsInRaid() or IsInGroup() then
                        local message = "Farewell, %s!"
                        
                        -- Use custom message if enabled
                        if self.settings.chat.useCustomMessages and self.settings.chat.customMessages.farewell then
                            message = self.settings.chat.customMessages.farewell
                            
                            -- If there's no %s in the custom message, append the player name
                            if not message:find("%%s") then
                                message = message .. " Farewell, %s!"
                            end
                        end
                        
                        -- Format the message
                        message = string.format(message, name)
                        
                        -- Add class color to player name if enabled
                        if self.settings.chat.colorizeNames then
                            -- We can only get class color for group members, but this player already left
                            -- We could store class info when they were in the group, but that's beyond the current scope
                        end
                        
                        SendChatMessage(message, "PARTY")
                    end
                end
            end
        end
    end
    
    -- Check for new people
    if self.settings.chat.autoWelcome then
        for name in pairs(currentMembers) do
            if not self.partyMembers[name] then
                -- New player joined
                if name ~= UnitName("player") then
                    -- Don't welcome ourselves
                    local message = "Welcome, %s!"
                    
                    -- Use custom message if enabled
                    if self.settings.chat.useCustomMessages and self.settings.chat.customMessages.welcome then
                        message = self.settings.chat.customMessages.welcome
                    end
                    
                    -- Format the message
                    message = string.format(message, name)
                    
                    -- Add class color to player name if enabled
                    if self.settings.chat.colorizeNames then
                        local unit = nil
                        
                        -- Find the unit ID for this player
                        if IsInRaid() then
                            for i = 1, GetNumGroupMembers() do
                                if UnitName("raid" .. i) == name then
                                    unit = "raid" .. i
                                    break
                                end
                            end
                        else
                            for i = 1, GetNumGroupMembers() do
                                if UnitName("party" .. i) == name then
                                    unit = "party" .. i
                                    break
                                end
                            end
                        end
                        
                        if unit then
                            local _, class = UnitClass(unit)
                            if class then
                                local classColor = RAID_CLASS_COLORS[class]
                                if classColor then
                                    local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                                        classColor.r * 255, 
                                        classColor.g * 255, 
                                        classColor.b * 255, 
                                        name)
                                    message = string.gsub(message, name, coloredName)
                                end
                            end
                        end
                    end
                    
                    SendChatMessage(message, "PARTY")
                end
            end
        end
    end
    
    -- Update our record
    self.partyMembers = currentMembers
end

-- Event handler for when loot roll starts
function Automation:OnStartLootRoll(id)
    if not self.enabled or not self.settings.combat.enabled then return end
    
    if self.settings.combat.autoRoll then
        local texture, name, count, quality = GetLootRollItemInfo(id)
        
        -- Determine roll type based on settings
        local rollType = 0 -- Pass
        
        if self.settings.combat.autoRollChoice == "need" then
            rollType = 1 -- Need
        elseif self.settings.combat.autoRollChoice == "greed" then
            rollType = 2 -- Greed
        end
        
        -- Perform the roll
        RollOnLoot(id, rollType)
    end
end

-- Helper function to create the enhanced chat config tab
function Automation:CreateEnhancedChatConfigTab(container)
    local settings = self.settings.chat
    
    -- Use custom messages for automated responses
    local useCustomMessages = AceGUI:Create("CheckBox")
    useCustomMessages:SetLabel("Use Custom Messages")
    useCustomMessages:SetValue(settings.useCustomMessages)
    useCustomMessages:SetCallback("OnValueChanged", function(_, _, value)
        settings.useCustomMessages = value
    end)
    container:AddChild(useCustomMessages)
    
    -- Colorize player names by class
    local colorizeNames = AceGUI:Create("CheckBox")
    colorizeNames:SetLabel("Colorize Player Names by Class")
    colorizeNames:SetValue(settings.colorizeNames)
    colorizeNames:SetCallback("OnValueChanged", function(_, _, value)
        settings.colorizeNames = value
    end)
    container:AddChild(colorizeNames)
    
    -- Link achievements in chat
    local linkAchievements = AceGUI:Create("CheckBox")
    linkAchievements:SetLabel("Link Achievements in Chat")
    linkAchievements:SetValue(settings.linkAchievements)
    linkAchievements:SetCallback("OnValueChanged", function(_, _, value)
        settings.linkAchievements = value
    end)
    container:AddChild(linkAchievements)
    
    -- Highlight Mythic+ related messages
    local highlightMythicPlus = AceGUI:Create("CheckBox")
    highlightMythicPlus:SetLabel("Highlight Mythic+ Related Messages")
    highlightMythicPlus:SetValue(settings.highlightMythicPlus)
    highlightMythicPlus:SetCallback("OnValueChanged", function(_, _, value)
        settings.highlightMythicPlus = value
    end)
    container:AddChild(highlightMythicPlus)
    
    -- Highlight Raid related messages
    local highlightRaids = AceGUI:Create("CheckBox")
    highlightRaids:SetLabel("Highlight Raid Related Messages")
    highlightRaids:SetValue(settings.highlightRaids)
    highlightRaids:SetCallback("OnValueChanged", function(_, _, value)
        settings.highlightRaids = value
    end)
    container:AddChild(highlightRaids)
    
    -- Announce your keystone to the group
    local mythicPlusKeyAnnouncement = AceGUI:Create("CheckBox")
    mythicPlusKeyAnnouncement:SetLabel("Announce Your Keystone to the Group")
    mythicPlusKeyAnnouncement:SetValue(settings.mythicPlusKeyAnnouncement)
    mythicPlusKeyAnnouncement:SetCallback("OnValueChanged", function(_, _, value)
        settings.mythicPlusKeyAnnouncement = value
    end)
    container:AddChild(mythicPlusKeyAnnouncement)
    
    -- Hide chat frames during combat
    local hideChatDuringCombat = AceGUI:Create("CheckBox")
    hideChatDuringCombat:SetLabel("Hide Chat Frames During Combat")
    hideChatDuringCombat:SetValue(settings.hideChatDuringCombat)
    hideChatDuringCombat:SetCallback("OnValueChanged", function(_, _, value)
        settings.hideChatDuringCombat = value
    end)
    container:AddChild(hideChatDuringCombat)
    
    -- Restore chat frames after combat
    local restoreChatAfterCombat = AceGUI:Create("CheckBox")
    restoreChatAfterCombat:SetLabel("Restore Chat Frames After Combat")
    restoreChatAfterCombat:SetValue(settings.restoreChatAfterCombat)
    restoreChatAfterCombat:SetCallback("OnValueChanged", function(_, _, value)
        settings.restoreChatAfterCombat = value
    end)
    container:AddChild(restoreChatAfterCombat)
    
    -- Show timestamps in chat
    local chatTimestamps = AceGUI:Create("CheckBox")
    chatTimestamps:SetLabel("Show Timestamps in Chat")
    chatTimestamps:SetValue(settings.chatTimestamps)
    chatTimestamps:SetCallback("OnValueChanged", function(_, _, value)
        settings.chatTimestamps = value
        -- Apply chat timestamp setting immediately
        self:UpdateChatTimestamps()
    end)
    container:AddChild(chatTimestamps)
    
    -- Timestamp format
    local timestampFormat = AceGUI:Create("EditBox")
    timestampFormat:SetLabel("Timestamp Format")
    timestampFormat:SetText(settings.timestampFormat)
    timestampFormat:SetCallback("OnEnterPressed", function(_, _, value)
        settings.timestampFormat = value
        -- Apply chat timestamp format immediately
        self:UpdateChatTimestamps()
    end)
    container:AddChild(timestampFormat)
    
    -- Filter raid spam
    local filterRaidSpam = AceGUI:Create("CheckBox")
    filterRaidSpam:SetLabel("Filter Common Raid Spam Messages")
    filterRaidSpam:SetValue(settings.filterRaidSpam)
    filterRaidSpam:SetCallback("OnValueChanged", function(_, _, value)
        settings.filterRaidSpam = value
    end)
    container:AddChild(filterRaidSpam)
    
    -- Make URLs in chat clickable
    local chatURLCopy = AceGUI:Create("CheckBox")
    chatURLCopy:SetLabel("Make URLs in Chat Clickable")
    chatURLCopy:SetValue(settings.chatURLCopy)
    chatURLCopy:SetCallback("OnValueChanged", function(_, _, value)
        settings.chatURLCopy = value
    end)
    container:AddChild(chatURLCopy)
    
    -- Create a header for custom messages
    local customMessagesHeader = AceGUI:Create("Heading")
    customMessagesHeader:SetText("Custom Messages")
    customMessagesHeader:SetFullWidth(true)
    container:AddChild(customMessagesHeader)
    
    -- Description
    local description = AceGUI:Create("Label")
    description:SetText("Customize the automatic messages sent in chat. Use %s as a placeholder for player names.")
    description:SetFullWidth(true)
    container:AddChild(description)
    
    -- Custom welcome message
    local welcomeMessage = AceGUI:Create("EditBox")
    welcomeMessage:SetLabel("Welcome Message")
    welcomeMessage:SetText(settings.customMessages.welcome or "Welcome to the group, %s!")
    welcomeMessage:SetFullWidth(true)
    welcomeMessage:SetCallback("OnEnterPressed", function(_, _, value)
        settings.customMessages.welcome = value
    end)
    container:AddChild(welcomeMessage)
    
    -- Custom farewell message
    local farewellMessage = AceGUI:Create("EditBox")
    farewellMessage:SetLabel("Farewell Message")
    farewellMessage:SetText(settings.customMessages.farewell or "Thanks for the group, everyone!")
    farewellMessage:SetFullWidth(true)
    farewellMessage:SetCallback("OnEnterPressed", function(_, _, value)
        settings.customMessages.farewell = value
    end)
    container:AddChild(farewellMessage)
    
    -- Custom resurrection thank you message
    local resurrectMessage = AceGUI:Create("EditBox")
    resurrectMessage:SetLabel("Resurrection Thank You Message")
    resurrectMessage:SetText(settings.customMessages.resurrect or "Thanks for the resurrection, %s!")
    resurrectMessage:SetFullWidth(true)
    resurrectMessage:SetCallback("OnEnterPressed", function(_, _, value)
        settings.customMessages.resurrect = value
    end)
    container:AddChild(resurrectMessage)
    
    -- Custom summon thank you message
    local summonMessage = AceGUI:Create("EditBox")
    summonMessage:SetLabel("Summon Thank You Message")
    summonMessage:SetText(settings.customMessages.summon or "Thanks for the summon, %s!")
    summonMessage:SetFullWidth(true)
    summonMessage:SetCallback("OnEnterPressed", function(_, _, value)
        settings.customMessages.summon = value
    end)
    container:AddChild(summonMessage)
    
    -- Custom portal thank you message
    local portalMessage = AceGUI:Create("EditBox")
    portalMessage:SetLabel("Portal Thank You Message")
    portalMessage:SetText(settings.customMessages.portal or "Thanks for the portal, %s!")
    portalMessage:SetFullWidth(true)
    portalMessage:SetCallback("OnEnterPressed", function(_, _, value)
        settings.customMessages.portal = value
    end)
    container:AddChild(portalMessage)
    
    -- Custom buff thank you message
    local buffMessage = AceGUI:Create("EditBox")
    buffMessage:SetLabel("Buff Thank You Message")
    buffMessage:SetText(settings.customMessages.buff or "Thanks for the %s, %s!")
    buffMessage:SetFullWidth(true)
    buffMessage:SetCallback("OnEnterPressed", function(_, _, value)
        settings.customMessages.buff = value
    end)
    container:AddChild(buffMessage)
end

-- Event handler for when player enters the world
function Automation:OnPlayerEnteringWorld()
    if not self.enabled then return end
    
    -- Set up performance optimizations if needed
    if self.settings.performance.enabled then
        self:UpdatePerformanceHooks()
    end
    
    -- Set up UI elements
    if self.settings.ui.enabled then
        self:UpdateUIElements()
    end
    
    -- Set up chat timestamps if enabled
    if self.settings.chat.enabled and self.settings.chat.chatTimestamps then
        self:UpdateChatTimestamps()
    end
    
    -- Initialize group members
    self.partyMembers = {}
    
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = UnitName("raid" .. i)
            if name then
                self.partyMembers[name] = true
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local name = UnitName("party" .. i)
            if name then
                self.partyMembers[name] = true
            end
        end
        
        -- Add the player
        self.partyMembers[UnitName("player")] = true
    end
    
    -- Set up fast loot if needed
    if self.settings.qol.enabled and self.settings.qol.fastLoot then
        self:UpdateFastLoot(true)
    end
end

-- Event handler for when mail is shown
function Automation:OnMailShow()
    if not self.enabled or not self.settings.mail.enabled then return end
    
    self.mailOpened = true
    
    -- Auto-collect mail attachments if enabled
    if self.settings.mail.autoCollectAttachments and not self.mailCollecting then
        self.mailCollecting = true
        
        -- Delay slightly to ensure mail frame is fully loaded
        C_Timer.After(0.5, function()
            -- Check if we still have the mail frame open
            if not self.mailOpened then
                self.mailCollecting = false
                return
            end
            
            -- Check if auto-collect feature exists and is enabled
            if _G["VUIMailCollectAttachments"] then
                -- Use our mail collection function
                _G["VUIMailCollectAttachments"](self.settings.mail.keepFreeSlots)
            else
                -- Basic implementation
                if GetInboxNumItems() > 0 then
                    for i = 1, GetInboxNumItems() do
                        -- Check if we have enough bag space
                        local totalFree = 0
                        for bag = 0, NUM_BAG_SLOTS do
                            local freeSlots = GetContainerNumFreeSlots(bag)
                            totalFree = totalFree + freeSlots
                        end
                        
                        if totalFree <= self.settings.mail.keepFreeSlots then
                            VUI:Print("Mail collection stopped: Not enough free bag slots")
                            break
                        end
                        
                        -- Get mail info
                        local _, _, _, _, money, COD, _, hasItem = GetInboxHeaderInfo(i)
                        
                        -- Skip COD items
                        if COD <= 0 then
                            -- Take money
                            if money > 0 then
                                TakeInboxMoney(i)
                            end
                            
                            -- Take items if any
                            if hasItem then
                                for j = 1, ATTACHMENTS_MAX_RECEIVE do
                                    local itemName = GetInboxItemLink(i, j)
                                    if itemName then
                                        TakeInboxItem(i, j)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            self.mailCollecting = false
        end)
    end
end

-- Event handler for when mail is closed
function Automation:OnMailClosed()
    self.mailOpened = false
    self.mailCollecting = false
end

-- Event handler for when a spell cast succeeds
function Automation:OnUnitSpellcastSucceeded(unit, _, spellID)
    if not self.enabled or not self.settings.chat.enabled then return end
    
    -- Check for resurrection spells
    if self.settings.chat.autoThankRes and unit ~= "player" then
        local resSpells = {
            [2006] = true,   -- Resurrection (Priest)
            [7328] = true,   -- Redemption (Paladin)
            [2008] = true,   -- Ancestral Spirit (Shaman)
            [50769] = true,  -- Revive (Druid)
            [115178] = true, -- Resuscitate (Monk)
            [20707] = true,  -- Soulstone (Warlock)
        }
        
        if resSpells[spellID] and UnitIsDeadOrGhost("player") then
            -- Remember who cast the resurrection
            self.lastResser = unit
        end
    end
    
    -- Check for portal/teleport spells
    if self.settings.chat.autoThankPortals and unit ~= "player" then
        local portalSpells = {
            -- Mage portal spells
            [10059] = true,  -- Portal: Stormwind
            [11416] = true,  -- Portal: Ironforge
            [11419] = true,  -- Portal: Darnassus
            [32266] = true,  -- Portal: Exodar
            [49360] = true,  -- Portal: Theramore
            [33691] = true,  -- Portal: Shattrath
            [88345] = true,  -- Portal: Tol Barad
            [132620] = true, -- Portal: Vale of Eternal Blossoms
            [176248] = true, -- Portal: Stormshield
            [11417] = true,  -- Portal: Orgrimmar
            [11418] = true,  -- Portal: Undercity
            [11420] = true,  -- Portal: Thunder Bluff
            [32267] = true,  -- Portal: Silvermoon
            [49361] = true,  -- Portal: Stonard
            [35717] = true,  -- Portal: Shattrath
            [88346] = true,  -- Portal: Tol Barad
            [132626] = true, -- Portal: Vale of Eternal Blossoms
            [176242] = true, -- Portal: Warspear
            -- Summoning portals
            [698] = true,    -- Ritual of Summoning (Warlock)
        }
        
        if portalSpells[spellID] then
            -- Thank the player who cast the portal/teleport
            local casterName = UnitName(unit)
            if casterName then
                local message = "Thanks for the portal, %s!"
                
                -- Use custom message if enabled
                if self.settings.chat.useCustomMessages and self.settings.chat.customMessages.portal then
                    message = self.settings.chat.customMessages.portal
                end
                
                -- Format the message
                message = string.format(message, casterName)
                
                -- Add class color to player name if enabled
                if self.settings.chat.colorizeNames then
                    local _, class = UnitClass(casterName)
                    if class then
                        local classColor = RAID_CLASS_COLORS[class]
                        if classColor then
                            local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                                classColor.r * 255, 
                                classColor.g * 255, 
                                classColor.b * 255, 
                                casterName)
                            message = string.gsub(message, casterName, coloredName)
                        end
                    end
                end
                
                SendChatMessage(message, "WHISPER", nil, casterName)
            end
        end
    end
end

-- Function to update chat timestamps
function Automation:UpdateChatTimestamps()
    if not self.enabled or not self.settings.chat.enabled then return end
    
    local settings = self.settings.chat
    
    -- Apply timestamp settings to all chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            if settings.chatTimestamps then
                -- Enable timestamps with custom format
                chatFrame.timeVisibleFunc = function()
                    return true
                end
                
                -- Set timestamp format if supported by client
                if chatFrame.SetTimeVisible then
                    chatFrame:SetTimeVisible(true)
                end
                
                -- Apply custom timestamp format if the function exists
                if chatFrame.SetTimestampFormat then
                    chatFrame:SetTimestampFormat(settings.timestampFormat or "[%H:%M:%S] ")
                end
            else
                -- Disable timestamps
                chatFrame.timeVisibleFunc = nil
                
                -- Hide timestamps if supported by client
                if chatFrame.SetTimeVisible then
                    chatFrame:SetTimeVisible(false)
                end
            end
        end
    end
    
    -- Update chat with the new timestamp setting
    FCF_ReloadAllWindows()
end

-- Function to handle chat frame visibility during combat
function Automation:UpdateChatVisibilityForCombat(inCombat)
    if not self.enabled or not self.settings.chat.enabled then return end
    
    local settings = self.settings.chat
    
    -- Skip if feature is not enabled
    if not settings.hideChatDuringCombat then return end
    
    -- Store original visibility state if entering combat
    if inCombat and not self.originalChatVisibility then
        self.originalChatVisibility = {}
        
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                self.originalChatVisibility[i] = chatFrame:IsVisible()
                
                -- Hide the chat frame
                chatFrame:Hide()
            end
        end
    elseif not inCombat and settings.restoreChatAfterCombat and self.originalChatVisibility then
        -- Restore original visibility
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and self.originalChatVisibility[i] then
                chatFrame:Show()
            end
        end
        
        self.originalChatVisibility = nil
    end
end

-- Function to implement URL highlighting in chat
function Automation:SetupChatURLCopy()
    if not self.enabled or not self.settings.chat.enabled or not self.settings.chat.chatURLCopy then return end
    
    -- Skip if already set up
    if self.chatURLCopyHooked then return end
    
    -- Pattern to detect URLs in chat
    local urlPatterns = {
        "https?://[%w-_%.%?%:%/%=%&]+",
        "www%.[%w-_%.%?%:%/%=%&]+",
        "[%w-_%.%?%:%/%=%&]+%.com",
        "[%w-_%.%?%:%/%=%&]+%.net",
        "[%w-_%.%?%:%/%=%&]+%.org",
        "[%w-_%.%?%:%/%=%&]+%.eu"
    }
    
    -- Function to create a clickable link
    local function CreateChatLink(url)
        return "|cff00CCFF|Hurl:" .. url .. "|h[" .. url .. "]|h|r"
    end
    
    -- Hook SetItemRef to handle our URL links
    local originalSetItemRef = SetItemRef
    SetItemRef = function(link, text, button, chatFrame)
        local linkType, urlLink = link:match("(%a+):(.+)")
        if linkType == "url" then
            -- Open URL dialog
            StaticPopupDialogs["VUI_URL_COPY"] = StaticPopupDialogs["VUI_URL_COPY"] or {
                text = "Copy this URL",
                button1 = "Close",
                hasEditBox = true,
                editBoxWidth = 350,
                OnShow = function(self, data)
                    self.editBox:SetText(data)
                    self.editBox:SetFocus()
                    self.editBox:HighlightText()
                end,
                OnHide = function(self)
                    self.editBox:SetText("")
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            
            StaticPopup_Show("VUI_URL_COPY", nil, nil, urlLink)
        else
            originalSetItemRef(link, text, button, chatFrame)
        end
    end
    
    -- Hook AddMessage to convert URLs to clickable links
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame and chatFrame.AddMessage then
            local originalAddMessage = chatFrame.AddMessage
            chatFrame.AddMessage = function(self, text, ...)
                if type(text) == "string" then
                    -- Replace URLs with clickable links
                    for _, pattern in ipairs(urlPatterns) do
                        text = text:gsub("(" .. pattern .. ")", CreateChatLink)
                    end
                end
                return originalAddMessage(self, text, ...)
            end
        end
    end
    
    self.chatURLCopyHooked = true
end

-- Register the automation module with VUI
VUI.automation = Automation