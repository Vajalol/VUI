-- VUIIDs (formerly idTip)
-- Shows various IDs in tooltips
-- Based on idTip by silverwind (https://github.com/wow-addon/idTip)

local VUI = select(2, ...)
local Module = VUI:NewModule("VUIIDs", "AceEvent-3.0")

-- Cache frequently used globals
local hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind, strmatch
    = hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind, strmatch

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
    runeforgePower = "RuneforgePowerID"
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
    runeforgePower = "showItemID"
}

-- Initialize module
function Module:OnInitialize()
    -- Initialize database using VUI namespace system
    self.db = VUI.db:RegisterNamespace("VUIIDs", self.defaults)
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN")
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions("VUIIDs", self:GetOptions(), "VUI IDs")
    
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
    -- Spell tooltips
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
        local id = select(10, UnitBuff(...))
        if id then Module:AddLine(self, "spell", id) end
    end)
    
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...)
        local id = select(10, UnitDebuff(...))
        if id then Module:AddLine(self, "spell", id) end
    end)
    
    hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
        local id = select(10, UnitAura(...))
        if id then Module:AddLine(self, "spell", id) end
    end)
    
    hooksecurefunc("SetItemRef", function(link, ...)
        local id = tonumber(link:match("spell:(%d+)"))
        if id then Module:AddLine(ItemRefTooltip, "spell", id) end
    end)
    
    GameTooltip:HookScript("OnTooltipSetSpell", function(self)
        local id = select(2, self:GetSpell())
        if id then Module:AddLine(self, "spell", id) end
    end)
    
    -- Item tooltips
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local link = select(2, self:GetItem())
        if not link then return end
        
        -- Item ID
        local itemID = GetItemInfoFromHyperlink(link)
        if itemID then Module:AddLine(self, "item", itemID) end
        
        -- Enchant ID
        local enchantID = link:match("item:%d+:(%d+)")
        if enchantID and enchantID ~= "0" then
            Module:AddLine(self, "enchant", enchantID)
        end
        
        -- Bonus IDs
        if Module.db.profile.showBonusID then
            local bonuses = link:match("item:%d+:%d+:%d+:%d+:%d+:%d+:[-]?%d+:[-]?%d+:%d+:(%d+:?%d*:?%d*)")
            ProcessBonusIDs(self, bonuses)
        end
        
        -- Gem IDs
        local gemIDs = link:match("item:%d+:%d+:(%d+:%d+:%d+:%d+):")
        if gemIDs then
            for gemID in gemIDs:gmatch("(%d+)") do
                if gemID ~= "0" then
                    Module:AddLine(self, "gem", gemID)
                end
            end
        end
    end)
    
    -- NPC tooltips
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local unit = select(2, self:GetUnit())
        if not unit then return end
        
        local guid = UnitGUID(unit)
        if guid then
            local id = select(6, strsplit("-", guid))
            if id and id ~= "0" then
                Module:AddLine(self, "unit", id)
            end
        end
    end)
    
    -- Achievement tooltips
    GameTooltip:HookScript("OnTooltipSetAchievement", function(self)
        local _, _, _, completed, _, _, _, _, _, id = GetAchievementInfo(self:GetAchievementID())
        if id then
            Module:AddLine(self, "achievement", id)
            
            -- Criteria IDs if achievement has criteria
            local numCriteria = GetAchievementNumCriteria(id)
            for i = 1, numCriteria do
                local _, _, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(id, i)
                if criteriaID then
                    Module:AddLine(self, "criteria", criteriaID)
                end
            end
        end
    end)
    
    -- Quest tooltips
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        local id = self.questID
        if id then Module:AddLine(GameTooltip, "quest", id) end
    end)
    
    -- Talent tooltips
    hooksecurefunc(GameTooltip, "SetTalent", function(self, ...)
        local id
        if C_ClassTalents then
            id = C_ClassTalents.GetTalentIDFromNodeID(...)
        else
            -- Fallback for older versions
            id = select(2, ...)
        end
        if id then Module:AddLine(self, "talent", id) end
    end)
    
    -- Mount tooltips
    hooksecurefunc(GameTooltip, "SetMount", function(self, id)
        if id then Module:AddLine(self, "mount", id) end
    end)
    
    -- Currency tooltips
    hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
        local id = C_CurrencyInfo.GetCurrencyListLink(index)
        if id then
            id = tonumber(id:match("currency:(%d+)"))
            if id then Module:AddLine(self, "currency", id) end
        end
    end)
    
    -- Azerite Essence tooltips (BFA specific)
    if C_AzeriteEssence then
        hooksecurefunc(GameTooltip, "SetAzeriteEssence", function(self, id)
            if id then Module:AddLine(self, "azeriteEssence", id) end
        end)
        
        hooksecurefunc(GameTooltip, "SetAzeriteEssencePower", function(self, id)
            if id then Module:AddLine(self, "azeriteEssencePower", id) end
        end)
    end
    
    -- Conduit tooltips (Shadowlands specific)
    if C_Soulbinds then
        hooksecurefunc(GameTooltip, "SetSoulbindConduit", function(self, conduitID, ...)
            if conduitID then Module:AddLine(self, "conduit", conduitID) end
        end)
    end
    
    -- Runeforge Power tooltips (Shadowlands specific)
    if C_LegendaryCrafting then
        hooksecurefunc(GameTooltip, "SetRuneforgePower", function(self, runeforgePowerID)
            if runeforgePowerID then Module:AddLine(self, "runeforgePower", runeforgePowerID) end
        end)
    end
    
    self:Debug("Tooltip hooks applied")
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
