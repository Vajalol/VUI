-- VUIIDs Module
-- An exact recreation of idTip functionality for VUI
-- Original: https://github.com/silverwind/idTip

local AddonName, VUI = ...

-- Create a global placeholder to ensure references work even during initialization
_G["VUIIDs"] = _G["VUIIDs"] or {}

-- Create the module and namespace
local Module
if VUI and type(VUI.NewModule) == "function" then
    -- If VUI is available and ready, create module normally
    Module = VUI:NewModule("VUIIDs", "AceEvent-3.0")
    VUI.VUIIDs = Module
    -- Update global reference
    _G["VUIIDs"] = Module
else
    -- If VUI isn't fully loaded, use a placeholder until it is
    Module = _G["VUIIDs"]
    
    -- Register module with VUI when it becomes available
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self, event, loadedAddon)
        if event == "ADDON_LOADED" and loadedAddon == "VUI" then
            if VUI and type(VUI.NewModule) == "function" then
                -- Register with VUI once it's available
                Module = VUI:NewModule("VUIIDs", "AceEvent-3.0")
                VUI.VUIIDs = Module
                _G["VUIIDs"] = Module
                
                -- Initialize if we're past PLAYER_LOGIN
                if IsLoggedIn() then
                    Module:OnInitialize()
                    if Module.db and Module.db.profile and Module.db.profile.enabled then
                        Module:OnEnable()
                    end
                end
            end
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
    
    -- Ensure module has basic functionality even if VUI isn't ready
    if not Module.RegisterEvent then
        Module.RegisterEvent = function() end
    end
    if not Module.UnregisterEvent then
        Module.UnregisterEvent = function() end
    end
end

-- Set up API reference caching
local GetSpellTexture = (C_Spell and C_Spell.GetSpellTexture) and C_Spell.GetSpellTexture or GetSpellTexture
local GetItemIconByID = (C_Item and C_Item.GetItemIconByID) and C_Item.GetItemIconByID or GetItemIconByID
local GetItemInfo = (C_Item and C_Item.GetItemInfo) and C_Item.GetItemInfo or GetItemInfo
local GetItemGem = (C_Item and C_Item.GetItemGem) and C_Item.GetItemGem or GetItemGem
local GetItemSpell = (C_Item and C_Item.GetItemSpell) and C_Item.GetItemSpell or GetItemSpell
local GetRecipeReagentItemLink = (C_TradeSkillUI and C_TradeSkillUI.GetRecipeReagentItemLink) and C_TradeSkillUI.GetRecipeReagentItemLink or GetTradeSkillReagentItemLink
local GetItemLinkByGUID = (C_Item and C_Item.GetItemLinkByGUID) and C_Item.GetItemLinkByGUID

-- Define ID types with display text
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
  companion = "CompanionID",
  macro = "MacroID",
  set = "SetID",
  visual = "VisualID",
  source = "SourceID",
  species = "SpeciesID",
  icon = "IconID",
  areapoi = "AreaPoiID",
  vignette = "VignetteID",
  expansion = "ExpansionID",
  object = "ObjectID",
  traitnode = "TraitNodeID",
  traitentry = "TraitEntryID",
  traitdef = "TraitDefinitionID",
}

-- TooltipData types mapping to our kinds
local kindsByID = {
  [0]  = "item",      -- Item
  [1]  = "spell",     -- Spell
  [2]  = "unit",      -- Unit
  [3]  = "unit",      -- Corpse
  [4]  = "object",    -- Object
  [5]  = "currency",  -- Currency
  [6]  = "unit",      -- BattlePet
  [7]  = "spell",     -- UnitAura
  [8]  = "spell",     -- AzeriteEssence
  [9]  = "unit",      -- CompanionPet
  [10] = "mount",     -- Mount
  [11] = "spell",     -- PetAction
  [12] = "achievement", -- Achievement
  [13] = "spell",     -- EnhancedConduit
  [14] = "set",       -- EquipmentSet
  [15] = "",          -- InstanceLock
  [16] = "",          -- PvPBrawl
  [17] = "spell",     -- RecipeRankInfo
  [18] = "spell",     -- Totem
  [19] = "item",      -- Toy
  [20] = "",          -- CorruptionCleanser
  [21] = "",          -- MinimapMouseover
  [22] = "",          -- Flyout
  [23] = "quest",     -- Quest
  [24] = "quest",     -- QuestPartyProgress
  [25] = "macro",     -- Macro
  [26] = "",          -- Debug
}

-- Module default settings
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
    showCompanionID = true,
    showMacroID = true,
    showSetID = true,
    showVisualID = true,
    showSourceID = true,
    showSpeciesID = true,
    showIconID = true,
    showAreaPoiID = true,
    showVignetteID = true,
    showExpansionID = true,
    showObjectID = true,
    showTraitNodeID = false,
    showTraitEntryID = false,
    showTraitDefID = false,
  }
}

-- Helper functions
local function contains(table, element)
  for _, value in pairs(table) do
    if value == element then return true end
  end
  return false
end

local function configKey(key)
  return "show" .. kinds[key]:gsub(" ", "")
end

local function getTooltipName(tooltip)
  return tooltip:GetName() or nil
end

-- Add a line to the tooltip with the ID type and value
local function addLine(tooltip, id, kind)
  if not id or id == "" or not tooltip or not tooltip.GetName then return end
  if not Module.db.profile.enabled or not Module.db.profile[configKey(kind)] then return end
  if type(id) == "table" and #id == 1 then id = id[1] end

  -- Abort when tooltip has no name or when :GetName throws
  local ok, name = pcall(getTooltipName, tooltip)
  if not ok or not name then return end

  -- Check if we already added to this tooltip
  local frame, text
  for i = tooltip:NumLines(), 1, -1 do
    frame = _G[name .. "TextLeft" .. i]
    if frame then text = frame:GetText() end
    if text and string.find(text, kinds[kind]) then return end
  end

  local left, right
  if type(id) == "table" then
    left = NORMAL_FONT_COLOR_CODE .. kinds[kind] .. "s" .. FONT_COLOR_CODE_CLOSE
    right = HIGHLIGHT_FONT_COLOR_CODE .. table.concat(id, ",") .. FONT_COLOR_CODE_CLOSE
  else
    left = NORMAL_FONT_COLOR_CODE .. kinds[kind] .. FONT_COLOR_CODE_CLOSE
    right = HIGHLIGHT_FONT_COLOR_CODE .. id .. FONT_COLOR_CODE_CLOSE
  end

  tooltip:AddDoubleLine(left, right)
  tooltip:Show()
end

local function isStringOrNumber(val)
  local t = type(val)
  return (t == "string") or (t == "number")
end

-- Process an ID and add to tooltip, handling related IDs as well
local function add(tooltip, id, kind)
  addLine(tooltip, id, kind)

  -- spell texture
  if kind == "spell" and GetSpellTexture and isStringOrNumber(id) then
    local iconId = GetSpellTexture(id)
    if iconId then add(tooltip, iconId, "icon") end
  end

  -- item icon
  if kind == "item" and GetItemIconByID and isStringOrNumber(id) then
    local iconId = GetItemIconByID(id)
    if iconId then add(tooltip, iconId, "icon") end
  end

  -- item spell
  if kind == "item" and GetItemSpell and isStringOrNumber(id) then
    local spellId = select(2, GetItemSpell(id))
    if spellId then add(tooltip, spellId, "spell") end
  end

  -- macro spell
  if kind == "macro" and tooltip.GetPrimaryTooltipData then
    local data = tooltip:GetPrimaryTooltipData()
    if data and data.lines and data.lines[1] and data.lines[1].tooltipID then
      add(tooltip, data.lines[1].tooltipID, "spell")
    end
  end
end

-- Add ID to tooltip based on kind
local function addByKind(tooltip, id, kind)
  if not kind or not id then return end
  if kind == "spell" or kind == "enchant" or kind == "trade" then
    add(tooltip, id, "spell")
  elseif (kinds[kind]) then
    add(tooltip, id, kind)
  end
end

-- Process item link and extract all relevant IDs
local function addItemInfo(tooltip, link)
  if not link then return end
  local itemString = string.match(link, "item:([%-?%d:]+)")
  if not itemString then return end

  local bonuses = {}
  local itemSplit = {}

  for v in string.gmatch(itemString, "(%d*:?)") do
    if v == ":" then
      itemSplit[#itemSplit + 1] = 0
    else
      itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
    end
  end

  for index = 1, tonumber(itemSplit[13] or 0) do
    bonuses[#bonuses + 1] = itemSplit[13 + index]
  end

  local gems = {}
  if GetItemGem then
    for i = 1, 4 do
      local gemLink = select(2, GetItemGem(link, i))
      if gemLink then
        local gemDetail = string.match(gemLink, "item[%-?%d:]+")
        gems[#gems + 1] = string.match(gemDetail, "item:(%d+):")
      elseif itemSplit[3 + i] and itemSplit[3 + i] ~= "0" and itemSplit[3 + i] ~= "" then
        gems[#gems + 1] = itemSplit[3 + i]
      end
    end
  end

  local itemId = string.match(link, "item:(%d*)")
  if (itemId == "" or itemId == "0") and TradeSkillFrame and TradeSkillFrame.RecipeList and TradeSkillFrame:IsVisible() and GetRecipeReagentItemLink and GetMouseFocus and GetMouseFocus().reagentIndex then
    local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
    for i = 1, 8 do
      if GetMouseFocus().reagentIndex == i then
        itemId = GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d*)") or nil
        break
      end
    end
  end

  if itemId then
    add(tooltip, itemId, "item")

    if itemSplit[2] and itemSplit[2] ~= "0" then add(tooltip, itemSplit[2], "enchant") end
    if #bonuses ~= 0 then add(tooltip, bonuses, "bonus") end
    if #gems ~= 0 then add(tooltip, gems, "gem") end

    local expansionId = select(15, GetItemInfo(itemId))
    if expansionId and expansionId ~= 254 then -- always 254 on classic, therefor uninteresting
      add(tooltip, expansionId, "expansion")
    end

    local setId = select(16, GetItemInfo(itemId))
    if setId and setId ~= 0 then
      add(tooltip, setId, "set")
    end
  end
end

-- Attach item info to tooltip
local function attachItemTooltip(tooltip, id)
  if (tooltip == ShoppingTooltip1 or tooltip == ShoppingTooltip2) and tooltip.info and tooltip.info.tooltipData and tooltip.info.tooltipData.guid and GetItemLinkByGUID then
    local link = GetItemLinkByGUID(tooltip.info.tooltipData.guid)
    if link then
      addItemInfo(tooltip, link)
    else
      add(tooltip, id, "item")
    end
  elseif tooltip.GetItem then
    local link = select(2, tooltip:GetItem())
    if link then
      addItemInfo(tooltip, link)
    else
      add(tooltip, id, "item")
    end
  else
    add(tooltip, id, "item")
  end
end

-- Achievement criteria handler
local function achievementOnEnter(btn)
  GameTooltip:SetOwner(btn, "ANCHOR_NONE")
  GameTooltip:SetPoint("TOPLEFT", btn, "TOPRIGHT", 0, 0)
  add(GameTooltip, btn.id, "achievement")
  GameTooltip:Show()
end

-- Achievement criteria handler
local function criteriaOnEnter(enterIndex)
  return function(frame)
    if not GetAchievementCriteriaInfo then return end
    local btn = frame:GetParent() and frame:GetParent():GetParent()
    if not btn or not btn.id then return end
    local achievementId = btn.id
    local index = frame.___index or enterIndex
    if index > GetAchievementNumCriteria(achievementId) then return end
    local criteriaId = select(10, GetAchievementCriteriaInfo(achievementId, index))
    if criteriaId then
      if not GameTooltip:IsVisible() then
        GameTooltip:SetOwner(btn:GetParent(), "ANCHOR_NONE")
      end
      GameTooltip:SetPoint("TOPLEFT", btn, "TOPRIGHT", 0, 0)
      add(GameTooltip, achievementId, "achievement")
      add(GameTooltip, criteriaId, "criteria")
      GameTooltip:Show()
    end
  end
end

-- Module initialization
function Module:OnInitialize()
  -- Initialize database
  self.db = VUI.db:RegisterNamespace("VUIIDs", {
    profile = self.defaults.profile
  })
  
  -- Register with VUI Config if available
  if VUI.Config then
    VUI.Config:RegisterModuleOptions("VUIIDs", self:GetOptions(), "VUI IDs")
  end
  
  -- Register events
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterEvent("PLAYER_LOGIN")
end

-- Event handling
function Module:ADDON_LOADED(_, addon)
  if addon == "Blizzard_AchievementUI" then
    if AchievementTemplateMixin then
      -- Dragonflight achievement system
      hooksecurefunc(AchievementTemplateMixin, "OnEnter", achievementOnEnter)
      hooksecurefunc(AchievementTemplateMixin, "OnLeave", GameTooltip_Hide)

      local hooked = {}
      local getter = function(pool)
        return function(self, index)
          if not self or not self[pool] then return end
          local frame = self[pool][index]
          frame.___index = index
          if frame and not hooked[frame] then
            frame:HookScript("OnEnter", criteriaOnEnter(index))
            frame:HookScript("OnLeave", GameTooltip_Hide)
            hooked[frame] = true
          end
        end
      end
      local objectiveFrame = AchievementTemplateMixin:GetObjectiveFrame()
      if objectiveFrame then
        hooksecurefunc(objectiveFrame, "GetCriteria", getter("criterias"))
        hooksecurefunc(objectiveFrame, "GetMiniAchievement", getter("miniAchivements"))
        hooksecurefunc(objectiveFrame, "GetMeta", getter("metas"))
        hooksecurefunc(objectiveFrame, "GetProgressBar", getter("progressBars"))
      end
    elseif AchievementFrameAchievementsContainer then
      -- Pre-Dragonflight achievement system
      for _, button in ipairs(AchievementFrameAchievementsContainer.buttons) do
        button:HookScript("OnEnter", achievementOnEnter)
        button:HookScript("OnLeave", GameTooltip_Hide)

        local hooked = {}
        hooksecurefunc("AchievementButton_GetCriteria", function(index, renderOffScreen)
          local frame = _G["AchievementFrameCriteria" .. (renderOffScreen and "OffScreen" or "") .. index]
          if frame and not hooked[frame] then
            frame:HookScript("OnEnter", criteriaOnEnter(index))
            frame:HookScript("OnLeave", GameTooltip_Hide)
            hooked[frame] = true
          end
        end)
      end
    end
  elseif addon == "Blizzard_Collections" then
    -- Transmog/Collections tooltips
    if CollectionWardrobeUtil then
      hooksecurefunc(CollectionWardrobeUtil, "SetAppearanceTooltip", function(_frame, sources)
        local visualIDs = {}
        local sourceIDs = {}
        local itemIDs = {}

        for i = 1, #sources do
          if sources[i].visualID and not contains(visualIDs, sources[i].visualID) then table.insert(visualIDs, sources[i].visualID) end
          if sources[i].sourceID and not contains(sourceIDs, sources[i].sourceID) then table.insert(sourceIDs, sources[i].sourceID) end
          if sources[i].itemID and not contains(itemIDs, sources[i].itemID) then table.insert(itemIDs, sources[i].itemID) end
        end

        if #visualIDs == 1 then add(GameTooltip, visualIDs[1], "visual") end
        if #sourceIDs == 1 then add(GameTooltip, sourceIDs[1], "source") end
        if #itemIDs == 1 then add(GameTooltip, itemIDs[1], "item") end

        if #visualIDs > 1 then add(GameTooltip, visualIDs, "visual") end
        if #sourceIDs > 1 then add(GameTooltip, sourceIDs, "source") end
        if #itemIDs > 1 then add(GameTooltip, itemIDs, "item") end
      end)
    end

    -- Pet Journal pet info
    if PetJournalPetCardPetInfo then
      PetJournalPetCardPetInfo:HookScript("OnEnter", function()
        if not C_PetJournal or not C_PetJournal.GetPetInfoBySpeciesID then return end
        if PetJournalPetCard.speciesID then
          local npcId = select(4, C_PetJournal.GetPetInfoBySpeciesID(PetJournalPetCard.speciesID))
          add(GameTooltip, PetJournalPetCard.speciesID, "species")
          add(GameTooltip, npcId, "unit")
        end
      end)
    end
  elseif addon == "Blizzard_GarrisonUI" then
    -- Garrison/Covenant ability IDs
    if _G.AddAutoCombatSpellToTooltip then
      hooksecurefunc("AddAutoCombatSpellToTooltip", function(tooltip, info)
        if info and info.autoCombatSpellID then
          add(tooltip, info.autoCombatSpellID, "ability")
        end
      end)
    end
  end
end

-- Player login event handler
function Module:PLAYER_LOGIN()
  if self.db.profile.enabled then
    self:Enable()
  end
end

-- Enable module
function Module:OnEnable()
  self:HookTooltips()
end

-- Hook all tooltips
function Module:HookTooltips()
  -- Modern TooltipDataProcessor support (Dragonflight+)
  if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
      if not data or not data.type then return end
      local kind = kindsByID[tonumber(data.type)]

      -- Unit special handling
      if kind == "unit" and data and data.guid then
        local unitId = tonumber(data.guid:match("-(%d+)-%x+$"), 10)
        if unitId and data.guid:match("%a+") ~= "Player" then
          add(tooltip, unitId, "unit")
        else
          add(tooltip, data.id, "unit")
        end
      elseif kind == "item" and data and data.guid and GetItemLinkByGUID then
        local link = GetItemLinkByGUID(data.guid)
        if link then
          addItemInfo(tooltip, link)
        else
          add(tooltip, data.id, kind)
        end
      elseif kind then
        add(tooltip, data.id, kind)
      end
    end)
  end

  -- Action bars
  if GetActionInfo then
    hooksecurefunc(GameTooltip, "SetAction", function(tooltip, slot)
      local kind, id = GetActionInfo(slot)
      addByKind(tooltip, id, kind)
    end)
  end

  -- Dragon talents
  if TalentDisplayMixin then
    hooksecurefunc(TalentDisplayMixin, "SetTooltipInternal", function(btn)
      if not btn then return end
      add(GameTooltip, btn.entryID, "traitentry")
      add(GameTooltip, btn.definitionID, "traitdef")
      if btn.GetNodeInfo then
        add(GameTooltip, btn:GetNodeInfo().ID, "traitnode")
      end
    end)
  end

  -- Item and spell hyperlinks
  local function onSetHyperlink(tooltip, link)
    local kind, id = string.match(link,"^(%a+):(%d+)")
    addByKind(tooltip, id, kind)
  end
  hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
  hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)

  -- Buffs and debuffs
  if UnitBuff then
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(tooltip, ...)
      local id = select(10, UnitBuff(...))
      add(tooltip, id, "spell")
    end)
  end

  if UnitDebuff then
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(tooltip, ...)
      local id = select(10, UnitDebuff(...))
      add(tooltip, id, "spell")
    end)
  end

  if UnitAura then
    hooksecurefunc(GameTooltip, "SetUnitAura", function(tooltip, ...)
      local id = select(10, UnitAura(...))
      add(tooltip, id, "spell")
    end)
  end

  -- Spells
  hooksecurefunc(GameTooltip, "SetSpellByID", function(tooltip, id)
    addByKind(tooltip, id, "spell")
  end)

  hooksecurefunc("SetItemRef", function(link)
    local id = tonumber(link:match("spell:(%d+)"))
    add(ItemRefTooltip, id, "spell")
  end)

  GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip)
    local id = select(2, tooltip:GetSpell())
    add(tooltip, id, "spell")
  end)

  -- Spellbook
  if SpellBook_GetSpellBookSlot then
    hooksecurefunc("SpellButton_OnEnter", function(btn)
      local slot = SpellBook_GetSpellBookSlot(btn)
      local spellID = select(2, GetSpellBookItemInfo(slot, SpellBookFrame.bookType))
      add(GameTooltip, spellID, "spell")
    end)
  end

  -- Recipe info
  hooksecurefunc(GameTooltip, "SetRecipeResultItem", function(tooltip, id)
    add(tooltip, id, "spell")
  end)

  hooksecurefunc(GameTooltip, "SetRecipeRankInfo", function(tooltip, id)
    add(tooltip, id, "spell")
  end)

  -- Artifact powers (Legion)
  if C_ArtifactUI and C_ArtifactUI.GetPowerInfo then
    hooksecurefunc(GameTooltip, "SetArtifactPowerByID", function(tooltip, powerID)
      local powerInfo = C_ArtifactUI.GetPowerInfo(powerID)
      add(tooltip, powerID, "artifactpower")
      add(tooltip, powerInfo.spellID, "spell")
    end)
  end

  -- Talents
  if GetTalentInfoByID then
    hooksecurefunc(GameTooltip, "SetTalent", function(tooltip, id)
      local spellID = select(6, GetTalentInfoByID(id))
      add(tooltip, id, "talent")
      add(tooltip, spellID, "spell")
    end)
  end

  if GetPvpTalentInfoByID then
    hooksecurefunc(GameTooltip, "SetPvpTalent", function(tooltip, id)
      local spellID = select(6, GetPvpTalentInfoByID(id))
      add(tooltip, id, "talent")
      add(tooltip, spellID, "spell")
    end)
  end

  -- Pet Journal team icon
  if C_PetJournal and C_PetJournal.GetPetInfoByPetID then
    hooksecurefunc(GameTooltip, "SetCompanionPet", function(_tooltip, petId)
      local speciesId = select(1, C_PetJournal.GetPetInfoByPetID(petId))
      if speciesId then
        local npcId = select(4, C_PetJournal.GetPetInfoBySpeciesID(speciesId))
        add(GameTooltip, speciesId, "species")
        add(GameTooltip, npcId, "unit")
      end
    end)
  end

  -- Units/NPCs
  GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
    if C_PetBattles and C_PetBattles.IsInBattle and C_PetBattles.IsInBattle() then return end
    local unit = select(2, tooltip:GetUnit())
    if unit and UnitGUID then
      local guid = UnitGUID(unit) or ""
      local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
      if id and guid:match("%a+") ~= "Player" then add(GameTooltip, id, "unit") end
    end
  end)

  -- Toys
  hooksecurefunc(GameTooltip, "SetToyByItemID", function(tooltip, id)
    add(tooltip, id, "item")
  end)

  -- Recipe reagents
  hooksecurefunc(GameTooltip, "SetRecipeReagentItem", function(tooltip, id)
    add(tooltip, id, "item")
  end)

  -- Items
  local function onSetItem(tooltip)
    attachItemTooltip(tooltip, nil)
  end
  GameTooltip:HookScript("OnTooltipSetItem", onSetItem)
  ItemRefTooltip:HookScript("OnTooltipSetItem", onSetItem)
  if ItemRefShoppingTooltip1 then
    ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", onSetItem)
  end
  if ItemRefShoppingTooltip2 then
    ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", onSetItem)
  end
  if ShoppingTooltip1 then
    ShoppingTooltip1:HookScript("OnTooltipSetItem", onSetItem)
  end
  if ShoppingTooltip2 then
    ShoppingTooltip2:HookScript("OnTooltipSetItem", onSetItem)
  end

  -- Pet battles
  if C_PetBattles and C_PetBattles.GetActivePet and C_PetBattles.GetAbilityInfo then
    hooksecurefunc("PetBattleAbilityButton_OnEnter", function(btn)
      local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
      if btn:GetEffectiveAlpha() > 0 then
        local id = select(1, C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, btn:GetID()))
        if id then
          local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
          PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
        end
      end
    end)
  end

  if C_PetBattles and C_PetBattles.GetAuraInfo then
    hooksecurefunc("PetBattleAura_OnEnter", function(frame)
      local parent = frame:GetParent()
      local id = select(1, C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, frame.auraIndex))
      if id then
        local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
        PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
      end
    end)
  end

  -- Currency
  if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink then
    hooksecurefunc(GameTooltip, "SetCurrencyToken", function(tooltip, index)
      local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index),"currency:(%d+)"))
      add(tooltip, id, "currency")
    end)
  end

  hooksecurefunc(GameTooltip, "SetCurrencyByID", function(tooltip, id)
    add(tooltip, id, "currency")
  end)

  hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(tooltip, id)
    add(tooltip, id, "currency")
  end)

  -- Quest tooltips
  if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(tooltip)
      local id = C_QuestLog.GetQuestIDForLogIndex(tooltip.questLogIndex)
      add(GameTooltip, id, "quest")
    end)
  end

  hooksecurefunc("TaskPOI_OnEnter", function(tooltip)
    if tooltip and tooltip.questID then add(GameTooltip, tooltip.questID, "quest") end
  end)

  -- Map points of interest
  if AreaPOIPinMixin then
    hooksecurefunc(AreaPOIPinMixin, "TryShowTooltip", function(tooltip)
      if tooltip and tooltip.areaPoiID then add(GameTooltip, tooltip.areaPoiID, "areapoi") end
    end)
  end

  -- Map vignettes
  if VignettePinMixin then
    hooksecurefunc(VignettePinMixin, "OnMouseEnter", function(tooltip)
      if tooltip and tooltip.vignetteInfo and tooltip.vignetteInfo.vignetteID then add(GameTooltip, tooltip.vignetteInfo.vignetteID, "vignette") end
    end)
  end
end

-- Options interface
function Module:GetOptions()
  local options = {
    name = "VUI IDs",
    type = "group",
    args = {
      enabled = {
        name = "Enable",
        desc = "Show IDs in tooltips",
        type = "toggle",
        width = "full",
        order = 1,
        get = function() return self.db.profile.enabled end,
        set = function(_, value)
          self.db.profile.enabled = value
          if value then
            self:Enable()
          else
            self:Disable()
          end
        end
      },
      spacer1 = {
        type = "header",
        name = "IDs to Show",
        order = 10
      }
    }
  }
  
  -- Add toggle for each ID type
  local order = 20
  for key, display in pairs(kinds) do
    local configKey = configKey(key)
    options.args[configKey] = {
      name = display,
      desc = "Show " .. display .. " in tooltips",
      type = "toggle",
      width = "normal",
      order = order,
      get = function() return self.db.profile[configKey] end,
      set = function(_, value) self.db.profile[configKey] = value end
    }
    order = order + 1
  end
  
  return options
end

-- Disable module - just sets the enabled flag to false
function Module:OnDisable()
  self.db.profile.enabled = false
end
