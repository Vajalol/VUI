-- VUIIDs (formerly idTip)
-- Shows various IDs in tooltips
-- Based on idTip by silverwind (https://github.com/wow-addon/idTip)

local _ = ...
local VUI = _G["VUI"]
local MODNAME = "VUIIDs"

-- Create a global placeholder to ensure references work even during initialization
_G["VUIIDs"] = _G["VUIIDs"] or {}

-- Create minimal fallback if global VUI doesn't exist
if not VUI then
    VUI = {}
    VUI.NewModule = function() return {} end
    VUI.db = { RegisterNamespace = function() return { profile = {} } end }
    _G["VUI"] = VUI
end

-- Safety check to ensure VUI is available before calling NewModule
local Module
if VUI and VUI.NewModule then
    Module = VUI:NewModule(MODNAME, "AceEvent-3.0")
    -- Update the global references with the actual module
    _G["VUIIDs"] = Module
else
    -- If VUI isn't ready, use the placeholder as a fallback
    Module = _G["VUIIDs"]
    
    -- Add minimal Ace library functionality to the placeholder
    if not Module.RegisterEvent then
        Module.RegisterEvent = function(self, ...) end
    end
    if not Module.UnregisterEvent then
        Module.UnregisterEvent = function(self, ...) end
    end
end

-- Ensure module has a valid NAME property for namespace registration
Module.NAME = Module.NAME or MODNAME

-- Cache frequently used globals
local hooksecurefunc = hooksecurefunc
local select = select
-- Modern WoW (Dragonflight+) uses C_UnitAuras instead of the global functions
local C_UnitAuras = C_UnitAuras
-- Create safe references to UnitBuff/UnitDebuff that work across versions
local UnitBuff = function(unit, index, filter)
    if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
        local data = C_UnitAuras.GetBuffDataByIndex(unit, index, filter)
        if data then
            return data.name, data.icon, data.applications, data.dispelName, data.duration, 
                   data.expirationTime, data.sourceUnit, data.isStealable, data.nameplateShowPersonal, 
                   data.spellId, data.canApplyAura, data.isBossAura, data.isFromPlayerOrPlayerPet, 
                   data.nameplateShowAll, data.timeMod
        end
        return nil
    elseif _G.UnitBuff then
        return _G.UnitBuff(unit, index, filter)
    end
    return nil
end

local UnitDebuff = function(unit, index, filter)
    if C_UnitAuras and C_UnitAuras.GetDebuffDataByIndex then
        local data = C_UnitAuras.GetDebuffDataByIndex(unit, index, filter)
        if data then
            return data.name, data.icon, data.applications, data.dispelName, data.duration, 
                   data.expirationTime, data.sourceUnit, data.isStealable, data.nameplateShowPersonal, 
                   data.spellId, data.canApplyAura, data.isBossAura, data.isFromPlayerOrPlayerPet, 
                   data.nameplateShowAll, data.timeMod
        end
        return nil
    elseif _G.UnitDebuff then
        return _G.UnitDebuff(unit, index, filter)
    end
    return nil
end

local UnitGUID = UnitGUID
local tonumber = tonumber
local strfind = strfind
local strmatch = strmatch

-- In newer WoW versions, UnitAura was replaced with specific functions UnitBuff and UnitDebuff
-- Create a compatibility wrapper for UnitAura that works across all WoW versions
local function SafeUnitAura(unit, index, filter)
    if not unit or not index then 
        if Module and Module.Debug then
            Module:Debug("SafeUnitAura called with invalid parameters: unit=" .. tostring(unit) .. ", index=" .. tostring(index))
        end
        return 
    end
    
    -- First try C_UnitAuras if available (Dragonflight+)
    if C_UnitAuras then
        if filter == "HARMFUL" then
            return UnitDebuff(unit, index, filter)
        else
            return UnitBuff(unit, index, filter)
        end
    end
    
    -- If original UnitAura exists, use it
    if _G.UnitAura then
        return _G.UnitAura(unit, index, filter)
    else
        -- In modern API, determine whether to use UnitBuff or UnitDebuff based on filter
        if filter == "HARMFUL" then
            if Module and Module.Debug then
                Module:Debug("Using UnitDebuff as fallback for UnitAura")
            end
            return UnitDebuff(unit, index, filter)
        else
            -- Default to UnitBuff for HELPFUL or if filter is not specified
            if Module and Module.Debug then
                Module:Debug("Using UnitBuff as fallback for UnitAura")
            end
            return UnitBuff(unit, index, filter)
        end
    end
end

-- Default settings
Module.defaults = {
    profile = {
        enabled = true,
        showSpellID = true,
        showItemID = true,
        showNPCID = true,
        showQuestID = true,
        showTalentID = true,
        showAchievementID = true,
        showCriteriaID = true,
        showAbilityID = true,
        showCurrencyID = true,
        showArtifactPowerID = true,
        showEnchantID = true,
        showBonusID = true,
        showGemID = true,
        showMountID = true,
        showAzeriteEssenceID = true,
        showTraitNodeID = true,
        showTraitEntryID = true,
        showTraitDefID = true,
        showCompanionID = true,
        showMacroID = true,
        showSetID = true,
        showTransmogSetID = true,
        showTransmogIllusionID = true,
        colorText = {r = 0.1, g = 1.0, b = 0.1, a = 1.0},
        textFormat = "%s: |cff00ff00%d|r"
    }
}

-- ID kinds and their display names
local kinds = {
    spell = "SpellID",
    item = "ItemID",
    unit = "NPC ID",
    quest = "QuestID",
    talent = "TalentID",
    achievement = "AchievementID",
    criteria = "CriteriaID",
    ability = "AbilityID",
    currency = "CurrencyID",
    artifactpower = "ArtifactPowerID",
    enchant = "EnchantID",
    bonus = "BonusID",
    gem = "GemID",
    mount = "MountID",
    azeriteEssence = "AzeriteEssenceID",
    azeriteEssencePower = "AzeriteEssencePowerID",
    conduit = "ConduitID",
    soulbind = "SoulbindID",
    runeforgePower = "RuneforgePowerID",
    traitnode = "TraitNodeID",
    traitentry = "TraitEntryID",
    traitdef = "TraitDefinitionID",
    companion = "CompanionID",
    macro = "MacroID",
    set = "SetID",
    equipmentset = "EquipmentSetID",
    transmogset = "TransmogSetID",
    transmogillusion = "TransmogIllusionID"
}

-- Setting keys for each kind
local kindOptions = {
    spell = "showSpellID",
    item = "showItemID",
    unit = "showNPCID",
    quest = "showQuestID",
    talent = "showTalentID",
    achievement = "showAchievementID",
    criteria = "showCriteriaID",
    ability = "showAbilityID",
    currency = "showCurrencyID",
    artifactpower = "showArtifactPowerID",
    enchant = "showEnchantID",
    bonus = "showBonusID",
    gem = "showGemID",
    mount = "showMountID",
    azeriteEssence = "showAzeriteEssenceID",
    azeriteEssencePower = "showAzeriteEssenceID",
    conduit = "showItemID",
    soulbind = "showItemID",
    runeforgePower = "showItemID",
    traitnode = "showTalentID",
    traitentry = "showTalentID",
    traitdef = "showTalentID",
    companion = "showItemID",
    macro = "showItemID",
    set = "showItemID",
    equipmentset = "showItemID",
    transmogset = "showItemID",
    transmogillusion = "showItemID"
}

-- Initialize module
function Module:OnInitialize()
    -- Initialize database using VUI namespace system with safety checks
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if the namespace already exists before creating a new one
        if VUI.db.namespaces[self.NAME] then
            self.db = VUI.db.namespaces[self.NAME]
        else
            -- Create new namespace
            self.db = VUI.db:RegisterNamespace(self.NAME, {
                profile = self.defaults.profile
            })
        end
    else
        -- Create a basic database structure if VUI.db isn't available
        self.db = {
            profile = self.defaults.profile,
            RegisterCallback = function() end
        }
        self:Debug("Using fallback database")
    end
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN")
    
    -- Register settings with VUI Config (with safety check)
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions("VUIIDs", self:GetOptions(), "VUI IDs")
    end
    
    -- Debug message
    self:Debug("VUIIDs initialized")
end

-- Handle player login event
function Module:PLAYER_LOGIN()
    if self.db.profile.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

-- Enable the module
function Module:OnEnable()
    self:HookTooltips()
    self:Debug("VUIIDs enabled")
end

-- Disable the module
function Module:OnDisable()
    -- We can't really unhook the tooltips, but we can set a flag to prevent adding IDs
    self:Debug("VUIIDs disabled")
end

-- Debug function
function Module:Debug(message)
    if self.db.profile.debug then
        print("|cff33ff99VUIIDs:|r " .. message)
    end
end

-- Format ID text with settings
function Module:FormatID(kind, id)
    if not kind or not id or not kinds[kind] then return end
    
    -- Check if this kind of ID should be shown
    local optionKey = kindOptions[kind]
    if optionKey and self.db.profile[optionKey] == false then
        return
    end
    
    local r, g, b, a = self.db.profile.colorText.r, self.db.profile.colorText.g, self.db.profile.colorText.b, self.db.profile.colorText.a
    local colorHex = string.format("%02x%02x%02x%02x", a * 255, r * 255, g * 255, b * 255)
    
    return string.format(self.db.profile.textFormat, kinds[kind], id)
end

-- Add line to tooltip
function Module:AddLine(tooltip, kind, id)
    if not tooltip or not kind or not id then return end
    
    local text = self:FormatID(kind, id)
    if text then
        tooltip:AddLine(text)
    end
end

-- Add a bonus ID line to a tooltip
local function AddBonusLine(tooltip, bonusID)
    tooltip:AddLine(Module:FormatID("bonus", bonusID))
end

-- Helper function to add multiple bonus IDs
local function ProcessBonusIDs(tooltip, bonuses)
    if bonuses then
        for bonusID in string.gmatch(bonuses, "%d+") do
            AddBonusLine(tooltip, bonusID)
        end
    end
end

-- Hook all tooltips
function Module:HookTooltips()
    local success, err = pcall(function()
        -- Spell tooltips
        if GameTooltip.SetUnitBuff then
            hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
                local unit, index = ...
                if not unit or not index then return end
                
                local id
                if UnitBuff then
                    id = select(10, UnitBuff(unit, index))
                end
                
                if id then Module:AddLine(self, "spell", id) end
            end)
        end
        
        if GameTooltip.SetUnitDebuff then
            hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...)
                local unit, index = ...
                if not unit or not index then return end
                
                local id
                if UnitDebuff then
                    id = select(10, UnitDebuff(unit, index))
                end
                
                if id then Module:AddLine(self, "spell", id) end
            end)
        end
        
        if GameTooltip.SetUnitAura then
            hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
                local unit, index, filter = ...
                if not unit or not index then return end
                
                local id
                -- Use the SafeUnitAura wrapper which handles API differences
                id = select(10, SafeUnitAura(unit, index, filter))
                
                if id then Module:AddLine(self, "spell", id) end
            end)
        end
        
        if SetItemRef then
            hooksecurefunc("SetItemRef", function(link, ...)
                if type(link) == "string" then
                    local id = tonumber(link:match("spell:(%d+)"))
                    if id then Module:AddLine(ItemRefTooltip, "spell", id) end
                end
            end)
        end
        
        -- Modern TooltipDataProcessor for Spell tooltips (Dragonflight+)
        if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Spell then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
                if data and data.id then
                    Module:AddLine(tooltip, "spell", data.id)
                end
            end)
        end
        
        -- Modern TooltipDataProcessor for Item tooltips (Dragonflight+)
        if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
                -- Get item link using the TooltipUtil if available
                local itemLink
                if TooltipUtil and TooltipUtil.GetDisplayedItem then
                    itemLink = select(2, TooltipUtil.GetDisplayedItem(tooltip))
                elseif tooltip.GetItem then
                    -- Fallback to the old method
                    itemLink = select(2, tooltip:GetItem())
                end
                
                if not itemLink then return end
                
                -- Item ID
                local itemID = GetItemInfoFromHyperlink and GetItemInfoFromHyperlink(itemLink) or tonumber(itemLink:match("item:(%d+)"))
                if itemID then Module:AddLine(tooltip, "item", itemID) end
                
                -- Enchant ID
                local enchantID = itemLink:match("item:%d+:(%d+)")
                if enchantID and enchantID ~= "0" then
                    Module:AddLine(tooltip, "enchant", enchantID)
                end
                
                -- Bonus IDs
                if Module.db.profile.showBonusID then
                    local bonuses = itemLink:match("item:%d+:%d+:%d+:%d+:%d+:%d+:[-]?%d+:[-]?%d+:%d+:(%d+:?%d*:?%d*)")
                    if bonuses then
                        for bonusID in string.gmatch(bonuses, "%d+") do
                            Module:AddLine(tooltip, "bonus", bonusID)
                        end
                    end
                end
            end)
        end
        
        -- Modern TooltipDataProcessor for NPC tooltips (Dragonflight+)
        if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
                if data and data.guid then
                    local id = select(6, strsplit("-", data.guid))
                    if id and id ~= "0" then
                        Module:AddLine(tooltip, "unit", id)
                    end
                end
            end)
        end
        
        -- Quest tooltips
        if QuestMapLogTitleButton_OnEnter then
            hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
                local id = self and self.questID
                if id then Module:AddLine(GameTooltip, "quest", id) end
            end)
        end
        
        -- Talent tooltips
        if GameTooltip.SetTalent then
            hooksecurefunc(GameTooltip, "SetTalent", function(self, ...)
                local id
                if C_ClassTalents and C_ClassTalents.GetTalentIDFromNodeID then
                    id = C_ClassTalents.GetTalentIDFromNodeID(...)
                else
                    -- Fallback for older versions
                    id = select(2, ...)
                end
                if id then Module:AddLine(self, "talent", id) end
            end)
        end
        
        -- Mount tooltips - Only hook if the function exists
        if GameTooltip.SetMount then
            hooksecurefunc(GameTooltip, "SetMount", function(self, id)
                if id then Module:AddLine(self, "mount", id) end
            end)
        else
            -- Alternative hook for mounts in newer API versions
            if C_MountJournal and TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Mount then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, function(tooltip, data)
                    if data and data.id then
                        Module:AddLine(tooltip, "mount", data.id)
                    end
                end)
            end
        end
        
        -- Currency tooltips
        if GameTooltip.SetCurrencyToken then
            hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
                local id = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink and C_CurrencyInfo.GetCurrencyListLink(index)
                if id then
                    id = tonumber(id:match("currency:(%d+)"))
                    if id then Module:AddLine(self, "currency", id) end
                end
            end)
        end
        
        -- Azerite Essence tooltips (BFA specific)
        if C_AzeriteEssence then
            if GameTooltip.SetAzeriteEssence then
                hooksecurefunc(GameTooltip, "SetAzeriteEssence", function(self, id)
                    if id then Module:AddLine(self, "azeriteEssence", id) end
                end)
            end
            
            if GameTooltip.SetAzeriteEssencePower then
                hooksecurefunc(GameTooltip, "SetAzeriteEssencePower", function(self, id)
                    if id then Module:AddLine(self, "azeriteEssencePower", id) end
                end)
            end
        end
        
        -- Conduit tooltips (Shadowlands specific)
        if C_Soulbinds and GameTooltip.SetSoulbindConduit then
            hooksecurefunc(GameTooltip, "SetSoulbindConduit", function(self, conduitID, ...)
                if conduitID then Module:AddLine(self, "conduit", conduitID) end
            end)
        end
        
        -- Runeforge Power tooltips (Shadowlands specific)
        if C_LegendaryCrafting and GameTooltip.SetRuneforgePower then
            hooksecurefunc(GameTooltip, "SetRuneforgePower", function(self, runeforgePowerID)
                if runeforgePowerID then Module:AddLine(self, "runeforgePower", runeforgePowerID) end
            end)
        end
        
        -- Achievement tooltips
        if GameTooltip.HookScript and GameTooltip.GetAchievementID then
            local achievementSuccess, achievementErr = pcall(function()
                GameTooltip:HookScript("OnTooltipSetAchievement", function(self)
                    local achievementID = self:GetAchievementID()
                    if not achievementID then return end
                    
                    local _, _, _, completed, _, _, _, _, _, id = GetAchievementInfo(achievementID)
                    if id then
                        Module:AddLine(self, "achievement", id)
                        
                        -- Criteria IDs if achievement has criteria
                        if GetAchievementNumCriteria then
                            local numCriteria = GetAchievementNumCriteria(id)
                            for i = 1, numCriteria do
                                local _, _, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(id, i)
                                if criteriaID then
                                    Module:AddLine(self, "criteria", criteriaID)
                                end
                            end
                        end
                    end
                end)
            end)
            
            if not achievementSuccess then
                Module:Debug("Error hooking OnTooltipSetAchievement: " .. (achievementErr or "unknown error"))
            end
        elseif GameTooltip.SetAchievementByID then
            -- Alternative hook for achievements in newer API versions
            hooksecurefunc(GameTooltip, "SetAchievementByID", function(self, id)
                if id then Module:AddLine(self, "achievement", id) end
            end)
        end
        
        -- Dragonflight Trait System (Talent Trees)
        if C_Traits and TooltipDataProcessor and Enum and Enum.TooltipDataType then
            -- Trait Node tooltips
            if Enum.TooltipDataType.TraitNode then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.TraitNode, function(tooltip, data)
                    if data and data.nodeID then
                        Module:AddLine(tooltip, "traitnode", data.nodeID)
                    end
                end)
            end
            
            -- Trait Entry tooltips
            if Enum.TooltipDataType.TraitEntry then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.TraitEntry, function(tooltip, data)
                    if data and data.entryID then
                        Module:AddLine(tooltip, "traitentry", data.entryID)
                    end
                end)
            end
            
            -- Trait Definition tooltips
            if Enum.TooltipDataType.Trait then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Trait, function(tooltip, data)
                    if data and data.traitID then
                        Module:AddLine(tooltip, "traitdef", data.traitID)
                    end
                end)
            end
        end
        
        -- Companion Journal tooltips
        if C_PetJournal then
            -- Hook BattlePet tooltips via TooltipDataProcessor if available
            if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.BattlePet then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.BattlePet, function(tooltip, data)
                    if data and data.speciesID then
                        Module:AddLine(tooltip, "companion", data.speciesID)
                    end
                end)
            end
            
            -- Legacy hook for older clients
            if GameTooltip.SetCompanionCreature then
                hooksecurefunc(GameTooltip, "SetCompanionCreature", function(self, creatureID)
                    if creatureID then Module:AddLine(self, "companion", creatureID) end
                end)
            end
        end
        
        -- Macro tooltips
        if GameTooltip.SetMacroItem then
            hooksecurefunc(GameTooltip, "SetMacroItem", function(self, itemLink)
                if itemLink then
                    local id = itemLink:match("item:(%d+)")
                    if id then Module:AddLine(self, "item", id) end
                end
            end)
        end
        
        -- Set tooltips (Equipment Sets)
        if C_EquipmentSet and GameTooltip.SetEquipmentSet then
            hooksecurefunc(GameTooltip, "SetEquipmentSet", function(self, name)
                local id = C_EquipmentSet.GetEquipmentSetID(name)
                if id then Module:AddLine(self, "equipmentset", id) end
            end)
        end
        
        -- Transmog Set tooltips
        if C_TransmogSets and TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.TransmogSet then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.TransmogSet, function(tooltip, data)
                if data and data.setID then
                    Module:AddLine(tooltip, "transmogset", data.setID)
                end
            end)
        end
        
        -- Transmog Illusion tooltips
        if C_TransmogCollection and GameTooltip.SetItemIllusion then
            hooksecurefunc(GameTooltip, "SetItemIllusion", function(self, illusionID)
                if illusionID then Module:AddLine(self, "transmogillusion", illusionID) end
            end)
        end
        
        -- Item Gem tooltips - Extract gem IDs from item links
        if Module.db.profile.showGemID then
            -- Hook to standard item tooltip processing
            if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
                    -- Get item link
                    local itemLink
                    if TooltipUtil and TooltipUtil.GetDisplayedItem then
                        itemLink = select(2, TooltipUtil.GetDisplayedItem(tooltip))
                    elseif tooltip.GetItem then
                        itemLink = select(2, tooltip:GetItem())
                    end
                    
                    if not itemLink then return end
                    
                    -- Extract gem IDs - pattern match for gem IDs in the item link
                    -- The format is usually item:itemID:enchantID:gemID1:gemID2:gemID3:gemID4:...
                    local _, _, _, gemID1, gemID2, gemID3, gemID4 = itemLink:match("item:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*)")
                    
                    -- Add each gem ID to the tooltip
                    if gemID1 and gemID1 ~= "0" and gemID1 ~= "" then
                        Module:AddLine(tooltip, "gem", gemID1)
                    end
                    if gemID2 and gemID2 ~= "0" and gemID2 ~= "" then
                        Module:AddLine(tooltip, "gem", gemID2)
                    end
                    if gemID3 and gemID3 ~= "0" and gemID3 ~= "" then
                        Module:AddLine(tooltip, "gem", gemID3)
                    end
                    if gemID4 and gemID4 ~= "0" and gemID4 ~= "" then
                        Module:AddLine(tooltip, "gem", gemID4)
                    end
                end)
            end
        end
    end)
    
    if not success then
        self:Debug("Error in HookTooltips: " .. (err or "unknown error"))
    else
        self:Debug("Tooltip hooks applied successfully")
    end
end

-- Get options table for config UI
function Module:GetOptions()
    return {
        name = "VUI IDs",
        desc = "Adds IDs to tooltips",
        type = "group",
        order = 60,
        args = {
            general = {
                name = "General",
                type = "group",
                order = 10,
                args = {
                    header = {
                        name = "Tooltip ID Display",
                        type = "header",
                        order = 1,
                    },
                    desc = {
                        name = "Shows various IDs in tooltips - helps with addon development and debugging.",
                        type = "description",
                        order = 2,
                    },
                    enabled = {
                        name = "Enable",
                        desc = "Enable tooltip ID display",
                        type = "toggle",
                        width = "full",
                        order = 3,
                        get = function() return Module.db.profile.enabled end,
                        set = function(info, val)
                            Module.db.profile.enabled = val
                            if val then
                                Module:Enable()
                            else
                                Module:Disable()
                            end
                        end,
                    },
                    spacer1 = {
                        name = "",
                        type = "description",
                        order = 10,
                    },
                    showSpellID = {
                        name = "Show Spell IDs",
                        desc = "Show IDs for spells",
                        type = "toggle",
                        order = 11,
                        get = function() return Module.db.profile.showSpellID end,
                        set = function(info, val) Module.db.profile.showSpellID = val end,
                    },
                    showItemID = {
                        name = "Show Item IDs",
                        desc = "Show IDs for items",
                        type = "toggle",
                        order = 12,
                        get = function() return Module.db.profile.showItemID end,
                        set = function(info, val) Module.db.profile.showItemID = val end,
                    },
                    showNPCID = {
                        name = "Show NPC IDs",
                        desc = "Show IDs for NPCs",
                        type = "toggle",
                        order = 13,
                        get = function() return Module.db.profile.showNPCID end,
                        set = function(info, val) Module.db.profile.showNPCID = val end,
                    },
                    showQuestID = {
                        name = "Show Quest IDs",
                        desc = "Show IDs for quests",
                        type = "toggle",
                        order = 14,
                        get = function() return Module.db.profile.showQuestID end,
                        set = function(info, val) Module.db.profile.showQuestID = val end,
                    },
                    showTalentID = {
                        name = "Show Talent IDs",
                        desc = "Show IDs for talents",
                        type = "toggle",
                        order = 15,
                        get = function() return Module.db.profile.showTalentID end,
                        set = function(info, val) Module.db.profile.showTalentID = val end,
                    },
                    showAchievementID = {
                        name = "Show Achievement IDs",
                        desc = "Show IDs for achievements",
                        type = "toggle",
                        order = 16,
                        get = function() return Module.db.profile.showAchievementID end,
                        set = function(info, val) Module.db.profile.showAchievementID = val end,
                    },
                    showEnchantID = {
                        name = "Show Enchant IDs",
                        desc = "Show IDs for enchants",
                        type = "toggle",
                        order = 17,
                        get = function() return Module.db.profile.showEnchantID end,
                        set = function(info, val) Module.db.profile.showEnchantID = val end,
                    },
                    showBonusID = {
                        name = "Show Bonus IDs",
                        desc = "Show bonus IDs for items",
                        type = "toggle",
                        order = 18,
                        get = function() return Module.db.profile.showBonusID end,
                        set = function(info, val) Module.db.profile.showBonusID = val end,
                    },
                    showGemID = {
                        name = "Show Gem IDs",
                        desc = "Show gem IDs for socketed items",
                        type = "toggle",
                        order = 19,
                        get = function() return Module.db.profile.showGemID end,
                        set = function(info, val) Module.db.profile.showGemID = val end,
                    },
                    -- Modern WoW tooltips
                    showTraitHeader = {
                        name = "Modern World of Warcraft",
                        type = "header",
                        order = 20,
                    },
                    showTraitNodeID = {
                        name = "Show Trait Node IDs",
                        desc = "Show IDs for trait tree nodes (Dragonflight talent trees)",
                        type = "toggle",
                        order = 21,
                        get = function() return Module.db.profile.showTraitNodeID end,
                        set = function(info, val) Module.db.profile.showTraitNodeID = val end,
                    },
                    showTraitEntryID = {
                        name = "Show Trait Entry IDs",
                        desc = "Show IDs for trait entries (Dragonflight talent tree spells)",
                        type = "toggle",
                        order = 22,
                        get = function() return Module.db.profile.showTraitEntryID end,
                        set = function(info, val) Module.db.profile.showTraitEntryID = val end,
                    },
                    showTraitDefID = {
                        name = "Show Trait Definition IDs",
                        desc = "Show IDs for trait definitions",
                        type = "toggle",
                        order = 23,
                        get = function() return Module.db.profile.showTraitDefID end,
                        set = function(info, val) Module.db.profile.showTraitDefID = val end,
                    },
                    showCompanionID = {
                        name = "Show Companion IDs",
                        desc = "Show IDs for battle pets and companions",
                        type = "toggle",
                        order = 24,
                        get = function() return Module.db.profile.showCompanionID end,
                        set = function(info, val) Module.db.profile.showCompanionID = val end,
                    },
                    showSetIDs = {
                        name = "Show Set IDs",
                        desc = "Show IDs for item sets and equipment sets",
                        type = "toggle",
                        order = 25,
                        get = function() return Module.db.profile.showSetID end,
                        set = function(info, val) Module.db.profile.showSetID = val end,
                    },
                    showTransmogIDs = {
                        name = "Show Transmog IDs",
                        desc = "Show IDs for transmog sets and illusions",
                        type = "toggle",
                        order = 26,
                        get = function() return Module.db.profile.showTransmogSetID and Module.db.profile.showTransmogIllusionID end,
                        set = function(info, val) 
                            Module.db.profile.showTransmogSetID = val
                            Module.db.profile.showTransmogIllusionID = val
                        end,
                    },
                    colorText = {
                        name = "ID Color",
                        desc = "Set the color of ID values",
                        type = "color",
                        order = 20,
                        get = function()
                            local c = Module.db.profile.colorText
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(info, r, g, b, a)
                            local c = Module.db.profile.colorText
                            c.r, c.g, c.b, c.a = r, g, b, a
                        end,
                    },
                },
            },
        },
    }
end

-- Return the module
return Module
