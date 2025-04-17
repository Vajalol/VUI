-- VUI idTip Core Implementation
local _, VUI = ...
local idTip = VUI.idtip

-- Cache globals
local select, UnitBuff, UnitDebuff = select, UnitBuff, UnitDebuff
local UnitAura, GetAchievementInfo = UnitAura, GetAchievementInfo
local GetCurrentMapAreaID, LE_PARTY_CATEGORY_HOME = GetCurrentMapAreaID, LE_PARTY_CATEGORY_HOME
local GetInstanceInfo, EJ_GetCurrentInstance = GetInstanceInfo, EJ_GetCurrentInstance
local GetLFGDungeonInfo, GetLFGDungeonRewards = GetLFGDungeonInfo, GetLFGDungeonRewards
local C_Map = C_Map

-- Module functionality
function idTip:SetupModule()
    self:HookTooltips()
end

-- Hook into all relevant tooltips
function idTip:HookTooltips()
    -- Item tooltips
    GameTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
    ItemRefTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
    
    -- Spell tooltips
    GameTooltip:HookScript("OnTooltipSetSpell", self.OnTooltipSetSpell)
    
    -- Achievement tooltips
    GameTooltip:HookScript("OnTooltipSetAchievement", self.OnTooltipSetAchievement)
    
    -- Unit tooltips
    GameTooltip:HookScript("OnTooltipSetUnit", self.OnTooltipSetUnit)
    
    -- Quest tooltips
    GameTooltip:HookScript("OnTooltipSetQuest", self.OnTooltipSetQuest)
    
    -- LFG tooltips
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", self.OnTooltipSetLFG)
    
    -- Mount tooltips
    hooksecurefunc("GameTooltip_SetMountBySpellID", self.OnTooltipSetMount)
    
    -- Map tooltips
    hooksecurefunc("WorldMapFrame_SetTooltip", self.OnTooltipSetMap)
    
    -- Journal tooltips
    hooksecurefunc("EncounterJournal_SetTooltipWithEncounterID", self.OnTooltipSetEncounter)
    
    -- Azerite trait tooltips
    hooksecurefunc(GameTooltip, "SetAzeritePower", self.OnTooltipSetAzeritePower)
    
    -- Azerite essence tooltips
    hooksecurefunc(GameTooltip, "SetAzeriteEssence", self.OnTooltipSetAzeriteEssence)
    
    -- PVP talent tooltips
    hooksecurefunc(GameTooltip, "SetPvpTalent", self.OnTooltipSetPvpTalent)
    
    -- Currency tooltips
    hooksecurefunc(GameTooltip, "SetCurrencyToken", self.OnTooltipSetCurrency)
    
    -- Covenant tooltips
    hooksecurefunc("CovenantPreviewFrame_SetupTooltip", self.OnTooltipSetCovenant)
end

-- Helper function to add a line to the tooltip with ID
function idTip:AddLine(tooltip, id, idType)
    if not tooltip or not id or not idType or not self.db.enabled then return end
    
    -- Skip if tooltip already has this ID
    for i = 1, tooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        local text = line and line:GetText()
        
        if text and text:match(idType .. " ID: " .. id) then
            return
        end
    end
    
    -- Set color based on type
    local r, g, b = 1, 1, 1
    if idType == "Spell" or idType == "Aura" then
        r, g, b = 0.7, 0.8, 1 -- Light blue
    elseif idType == "Item" then
        r, g, b = 1, 0.7, 0.7 -- Light red
    elseif idType == "Quest" then
        r, g, b = 1, 0.8, 0.5 -- Light orange
    elseif idType == "Achievement" then
        r, g, b = 0.9, 0.8, 0.1 -- Gold
    elseif idType == "Currency" then
        r, g, b = 0.9, 0.9, 0.5 -- Light yellow
    elseif idType == "Zone" or idType == "Map" then
        r, g, b = 0.5, 1, 0.5 -- Light green
    else
        r, g, b = 0.7, 0.7, 0.7 -- Light gray
    end
    
    -- Add the line to the tooltip
    tooltip:AddLine(idType .. " ID: " .. id, r, g, b)
    
    -- Show the tooltip to refresh it
    tooltip:Show()
end

-- Item tooltip hook
function idTip.OnTooltipSetItem(tooltip)
    if not tooltip or not VUI.idtip.db.enabled then return end
    
    local name, link = tooltip:GetItem()
    if not link then return end
    
    -- Extract item ID from link
    local id = link:match("item:(%d+)")
    if id then
        -- Try to extract extra info
        local bonusID = link:match("bonus:(%d+)")
        local setID = C_LootJournal and link:match("set:(%d+)")
        local craftingQuality = C_TradeSkillUI and link:match("crafting:(%d+)")
        
        -- Add item ID to tooltip
        VUI.idtip:AddLine(tooltip, id, "Item")
        
        -- Add bonus ID if present
        if bonusID then
            VUI.idtip:AddLine(tooltip, bonusID, "Bonus")
        end
        
        -- Add set ID if present
        if setID then
            VUI.idtip:AddLine(tooltip, setID, "Set")
        end
        
        -- Add crafting quality if present
        if craftingQuality then
            VUI.idtip:AddLine(tooltip, craftingQuality, "Quality")
        end
    end
end

-- Spell tooltip hook
function idTip.OnTooltipSetSpell(tooltip)
    if not tooltip or not VUI.idtip.db.enabled then return end
    
    local name, id = tooltip:GetSpell()
    if id then
        VUI.idtip:AddLine(tooltip, id, "Spell")
    end
end

-- Achievement tooltip hook
function idTip.OnTooltipSetAchievement(tooltip)
    if not tooltip or not VUI.idtip.db.enabled then return end
    
    local _, _, _, _, _, _, _, _, _, id = tooltip:GetAchievementInfo()
    if id then
        VUI.idtip:AddLine(tooltip, id, "Achievement")
    end
end

-- Unit tooltip hook
function idTip.OnTooltipSetUnit(tooltip)
    if not tooltip or not VUI.idtip.db.enabled then return end
    
    local _, unit = tooltip:GetUnit()
    if not unit then return end
    
    -- Add NPC ID if it's an NPC
    if UnitIsNPC(unit) then
        local guid = UnitGUID(unit)
        if guid then
            local id = select(6, strsplit("-", guid))
            if id then
                VUI.idtip:AddLine(tooltip, id, "NPC")
            end
        end
    end
    
    -- Add aura IDs if showing auras is enabled
    if VUI.idtip.db.showAuraIDs then
        -- Check for regular auras
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HELPFUL")
            if not name then break end
            if spellId then
                VUI.idtip:AddLine(tooltip, spellId, "Buff")
            end
        end
        
        -- Check for debuffs
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HARMFUL")
            if not name then break end
            if spellId then
                VUI.idtip:AddLine(tooltip, spellId, "Debuff")
            end
        end
    end
end

-- Quest tooltip hook
function idTip.OnTooltipSetQuest(tooltip)
    if not tooltip or not VUI.idtip.db.enabled then return end
    
    -- Try to get quest ID from the tooltip
    for i = 1, tooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        local text = line and line:GetText()
        
        if text and text:find("Quest ID:") then
            -- Already added by another addon
            return
        end
    end
    
    -- Get active quests first
    for i = 1, GetNumQuestLogEntries() do
        local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
        if questTitle and not isHeader then
            if GameTooltip:IsShown() and GameTooltipTextLeft1:GetText() == questTitle then
                VUI.idtip:AddLine(tooltip, questID, "Quest")
                return
            end
        end
    end
    
    -- Try to get quest ID from HyperLink
    local questID = GetQuestID()
    if questID and questID > 0 then
        VUI.idtip:AddLine(tooltip, questID, "Quest")
    end
end

-- LFG tooltip hook
function idTip.OnTooltipSetLFG(tooltip, resultID)
    if not tooltip or not resultID or not VUI.idtip.db.enabled then return end
    
    local _, _, _, _, _, _, _, _, _, _, _, _, instanceID = C_LFGList.GetSearchResultInfo(resultID)
    if instanceID then
        VUI.idtip:AddLine(tooltip, instanceID, "Instance")
    end
end

-- Mount tooltip hook
function idTip.OnTooltipSetMount(tooltip, id)
    if not tooltip or not id or not VUI.idtip.db.enabled then return end
    
    VUI.idtip:AddLine(tooltip, id, "Mount")
end

-- Map tooltip hook
function idTip.OnTooltipSetMap(tooltip)
    if not tooltip or not VUI.idtip.db.enabled then return end
    
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        VUI.idtip:AddLine(tooltip, mapID, "Map")
    end
end

-- Encounter journal tooltip hook
function idTip.OnTooltipSetEncounter(tooltip, encounterID)
    if not tooltip or not encounterID or not VUI.idtip.db.enabled then return end
    
    VUI.idtip:AddLine(tooltip, encounterID, "Encounter")
end

-- Azerite power tooltip hook
function idTip.OnTooltipSetAzeritePower(self, powerID)
    if not self or not powerID or not VUI.idtip.db.enabled then return end
    
    VUI.idtip:AddLine(self, powerID, "Azerite Power")
end

-- Azerite essence tooltip hook
function idTip.OnTooltipSetAzeriteEssence(self, essenceID, rank)
    if not self or not essenceID or not VUI.idtip.db.enabled then return end
    
    VUI.idtip:AddLine(self, essenceID, "Essence")
    if rank then
        VUI.idtip:AddLine(self, rank, "Rank")
    end
end

-- PvP talent tooltip hook
function idTip.OnTooltipSetPvpTalent(self, talentID)
    if not self or not talentID or not VUI.idtip.db.enabled then return end
    
    VUI.idtip:AddLine(self, talentID, "PvP Talent")
end

-- Currency tooltip hook
function idTip.OnTooltipSetCurrency(self, index)
    if not self or not index or not VUI.idtip.db.enabled then return end
    
    local name, isHeader, _, _, _, count, icon, currencyID = GetCurrencyListInfo(index)
    if currencyID and not isHeader then
        VUI.idtip:AddLine(self, currencyID, "Currency")
    end
end

-- Covenant tooltip hook
function idTip.OnTooltipSetCovenant(self, covenantID)
    if not self or not covenantID or not VUI.idtip.db.enabled then return end
    
    VUI.idtip:AddLine(GameTooltip, covenantID, "Covenant")
end

-- Initialize the module
function idTip:Initialize()
    -- Create database
    if not VUI.db.profile.modules.idtip then
        VUI.db.profile.modules.idtip = {
            enabled = true,
            showAuraIDs = true
        }
    end
    
    self.db = VUI.db.profile.modules.idtip
    
    -- Initialize the module
    if self.db.enabled then
        self:SetupModule()
        VUI:Print("idTip module initialized")
    end
end
