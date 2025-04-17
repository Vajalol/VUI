-- VUI Automation Module - Core Functionality
local _, VUI = ...
local Automation = VUI.automation

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
            SendChatMessage("Thanks for the resurrection, " .. resser .. "!", "WHISPER", nil, resser)
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
                    SendChatMessage("Thanks for the summon, " .. summoner .. "!", "WHISPER", nil, summoner)
                else
                    SendChatMessage("Thanks for the summon!", "PARTY")
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
                        SendChatMessage("Farewell, " .. name .. "!", "PARTY")
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
                    SendChatMessage("Welcome, " .. name .. "!", "PARTY")
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
                SendChatMessage("Thanks for the portal, " .. casterName .. "!", "WHISPER", nil, casterName)
            end
        end
    end
end

-- Register the automation module with VUI
VUI.automation = Automation