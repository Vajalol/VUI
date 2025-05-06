-- VUI Tooltip Module - Core Functionality
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Tooltip = VUI.modules.tooltip

-- Cache frequently used globals
local GameTooltip = GameTooltip
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitExists = UnitExists
local UnitName = UnitName
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsPVP = UnitIsPVP
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local GetGuildInfo = GetGuildInfo
local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemLink = GetInventoryItemLink
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
local GetSpellInfo = GetSpellInfo
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

-- Patterns for extracting item and spell IDs
local ITEM_ID_PATTERN = "item:(%d+)"
local SPELL_ID_PATTERN = "spell:(%d+)"

----------------------------------
-- Module Setup
----------------------------------

function Tooltip:Initialize()
    self.enabled = true
    
    -- Set up local cache
    self.cache = {}
    self.tooltipsHooked = false
    
    -- Hook tooltips
    self:HookTooltips()
    
    -- Register events
    self:RegisterEvents()
    
    VUI:Print("Tooltip module initialized")
end

function Tooltip:RegisterEvents()
    -- Create frame for events if it doesn't exist
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        
        -- Set up event handling
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                self:OnPlayerEnteringWorld(...)
            elseif event == "PLAYER_REGEN_DISABLED" then
                self:OnEnterCombat(...)
            elseif event == "PLAYER_REGEN_ENABLED" then
                self:OnLeaveCombat(...)
            elseif event == "UPDATE_MOUSEOVER_UNIT" then
                self:OnUpdateMouseoverUnit(...)
            end
        end)
    end
    
    -- Register events
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
end

function Tooltip:OnPlayerEnteringWorld()
    -- Update tooltip settings when entering the world
    self:UpdateTooltipStyle()
end

function Tooltip:OnEnterCombat()
    -- Apply combat settings to tooltips
    self:ApplyCombatSettings(true)
end

function Tooltip:OnLeaveCombat()
    -- Remove combat settings from tooltips
    self:ApplyCombatSettings(false)
end

function Tooltip:OnUpdateMouseoverUnit()
    -- Update tooltip information when mouseover unit changes
    if GameTooltip:IsShown() then
        GameTooltip:RefreshData()
    end
end

----------------------------------
-- Tooltip Customization
----------------------------------

function Tooltip:HookTooltips()
    -- Don't hook tooltips more than once
    if self.tooltipsHooked then return end
    
    -- Hook into tooltip creation functions
    self:HookTooltipFunctions()
    
    -- Flag tooltips as hooked
    self.tooltipsHooked = true
end

function Tooltip:HookTooltipFunctions()
    -- Cache the original GameTooltip_SetDefaultAnchor function
    if not self.originalSetDefaultAnchor then
        self.originalSetDefaultAnchor = GameTooltip_SetDefaultAnchor
    end
    
    -- Replace with our custom anchor function
    GameTooltip_SetDefaultAnchor = function(tooltip, parent)
        if self.enabled and self.settings.general.anchorToCursor then
            tooltip:SetOwner(parent, "ANCHOR_CURSOR")
        else
            self.originalSetDefaultAnchor(tooltip, parent)
        end
    end
    
    -- Hook all existing tooltips
    local tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3}
    for _, tooltip in ipairs(tooltips) do
        self:HookTooltip(tooltip)
    end
    
    -- Hook into tooltip show/hide events
    GameTooltip:HookScript("OnShow", function(tooltip)
        if not self.enabled then return end
        self:UpdateTooltipStyle(tooltip)
    end)
    
    -- Hook into tooltip unit display
    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        if not self.enabled then return end
        self:OnTooltipSetUnit(tooltip)
    end)
    
    -- Hook into tooltip item display
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        if not self.enabled then return end
        self:OnTooltipSetItem(tooltip)
    end)
    
    -- Hook into tooltip spell display
    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip)
        if not self.enabled then return end
        self:OnTooltipSetSpell(tooltip)
    end)
    
    -- Hook into tooltip clearing
    GameTooltip:HookScript("OnTooltipCleared", function(tooltip)
        if not self.enabled then return end
        self:OnTooltipCleared(tooltip)
    end)
end

function Tooltip:HookTooltip(tooltip)
    -- Apply style to the tooltip
    tooltip:HookScript("OnShow", function(tip)
        if not self.enabled then return end
        self:StyleTooltip(tip)
    end)
    
    tooltip:HookScript("OnHide", function(tip)
        if not self.enabled then return end
        -- Reset tooltip scale/alpha
        tip:SetScale(self.settings.general.scale)
        tip:SetAlpha(self.settings.general.alpha)
    end)
end

function Tooltip:StyleTooltip(tooltip)
    -- Apply the tooltip styling
    tooltip:SetScale(self.settings.general.scale)
    tooltip:SetAlpha(self.settings.general.alpha)
    
    -- Apply backdrop
    if not tooltip.SetBackdrop then return end
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    
    if not self.settings.general.showBorder then
        backdrop.edgeFile = nil
        backdrop.edgeSize = 0
    end
    
    tooltip:SetBackdrop(backdrop)
    
    -- Apply colors based on theme settings or custom colors
    if self.settings.useThemeColors and self.ThemeIntegration then
        -- Use theme colors
        local bgColor = self.ThemeIntegration:GetColor("background")
        local borderColor = self.ThemeIntegration:GetColor("border")
        
        tooltip:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 0.85)
        tooltip:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1.0)
    else
        -- Use custom colors
        local bg = self.settings.general.backdropColor
        tooltip:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
        
        local border = self.settings.general.borderColor
        tooltip:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
    end
    
    -- Check if we're in combat and apply combat settings
    if InCombatLockdown() then
        self:ApplyCombatSettings(true, tooltip)
    end
end

function Tooltip:UpdateTooltipStyle(tooltip)
    -- Update all tooltips if no specific tooltip is provided
    if not tooltip then
        local tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3}
        for _, tip in ipairs(tooltips) do
            if tip:IsShown() then
                self:StyleTooltip(tip)
            end
        end
    else
        -- Apply style to the specified tooltip
        self:StyleTooltip(tooltip)
    end
end

-- Apply theme colors to all tooltips
function Tooltip:StyleAllTooltips()
    -- Only proceed if the module is enabled
    if not self.enabled then return end
    
    -- Update tooltips that are currently shown
    self:UpdateTooltipStyle()
    
    -- Make sure hooks are set up for newly shown tooltips
    self:SetupTooltipHooks()
end

function Tooltip:ApplyCombatSettings(inCombat, tooltip)
    -- Only apply if the module is enabled
    if not self.enabled then return end
    
    -- Check if we should hide tooltips in combat
    if inCombat and self.settings.combat.hideInCombat then
        -- Hide tooltip if it's shown
        if tooltip and tooltip:IsShown() then
            tooltip:Hide()
        end
        return
    end
    
    -- Get the tooltips to modify
    local tooltips = {}
    if tooltip then
        tooltips = {tooltip}
    else
        tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3}
    end
    
    -- Apply combat settings to each tooltip
    for _, tip in ipairs(tooltips) do
        if tip:IsShown() then
            if inCombat then
                -- Apply combat settings
                tip:SetScale(self.settings.combat.scaleInCombat)
                tip:SetAlpha(self.settings.combat.opacityInCombat)
            else
                -- Restore normal settings
                tip:SetScale(self.settings.general.scale)
                tip:SetAlpha(self.settings.general.alpha)
            end
        end
    end
end

----------------------------------
-- Tooltip Content Customization
----------------------------------

function Tooltip:OnTooltipSetUnit(tooltip)
    -- Get the unit being shown
    local _, unit = tooltip:GetUnit()
    if not unit then return end
    
    -- Check if the unit exists
    if not UnitExists(unit) then return end
    
    -- Add unit information
    self:AddUnitInfo(tooltip, unit)
    
    -- Add targeting information if enabled
    if self.settings.features.showTargetingInfo then
        self:AddTargetingInfo(tooltip, unit)
    end
    
    -- Add mount information if enabled and unit is mounted
    if self.settings.features.showMountInfo and IsMounted(unit) then
        self:AddMountInfo(tooltip, unit)
    end
    
    -- Add health and power values if enabled
    if self.settings.features.showHealthValues then
        self:AddHealthInfo(tooltip, unit)
    end
    
    -- Color the tooltip border based on the unit's class if it's a player
    if self.settings.general.classColoredBorder and UnitIsPlayer(unit) then
        self:ColorBorderByClass(tooltip, unit)
    end
end

function Tooltip:OnTooltipSetItem(tooltip)
    -- Get the item being shown
    local name, link = tooltip:GetItem()
    if not name then return end
    
    -- Add item ID information if enabled
    if self.settings.features.showItemID then
        self:AddItemIDInfo(tooltip, link)
    end
    
    -- Add item level information if enabled
    if self.settings.features.showItemLevelInfo then
        self:AddItemLevelInfo(tooltip, link)
    end
    
    -- Add item count information if enabled
    if self.settings.features.showItemCount then
        self:AddItemCountInfo(tooltip, link)
    end
end

function Tooltip:OnTooltipSetSpell(tooltip)
    -- Get the spell being shown
    local name, spellID = tooltip:GetSpell()
    if not name then return end
    
    -- Add spell ID information if enabled
    if self.settings.features.showSpellID then
        self:AddSpellIDInfo(tooltip, spellID)
    end
    
    -- Add spell source information if available
    if self.settings.features.showAuraSource then
        self:AddSpellSourceInfo(tooltip, spellID)
    end
end

function Tooltip:OnTooltipCleared(tooltip)
    -- Reset tooltip border color
    if tooltip.SetBackdropBorderColor then
        local border = self.settings.general.borderColor
        tooltip:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
    end
end

----------------------------------
-- Tooltip Information Functions
----------------------------------

function Tooltip:AddUnitInfo(tooltip, unit)
    -- Only add information for valid units
    if not UnitExists(unit) then return end
    
    -- Get basic unit information
    local name = UnitName(unit)
    local level = UnitLevel(unit)
    local classDisplayName, className = UnitClass(unit)
    local race = UnitRace(unit)
    local unitClassification = UnitClassification(unit)
    local creatureType = UnitCreatureType(unit)
    local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
    local isAFK = UnitIsAFK(unit)
    local isDND = UnitIsDND(unit)
    local isPVP = UnitIsPVP(unit)
    
    -- Replace the name line with a class-colored version if it's a player
    if UnitIsPlayer(unit) and self.settings.features.classColoredNames then
        if className and RAID_CLASS_COLORS[className] then
            local color = RAID_CLASS_COLORS[className]
            local displayName = name
            
            -- Add status if AFK or DND
            if isAFK then
                displayName = displayName .. " |cffE7E716[AFK]|r"
            elseif isDND then
                displayName = displayName .. " |cffff0000[DND]|r"
            end
            
            -- Set the colored name as the first line
            _G["GameTooltipTextLeft1"]:SetText("|cff" .. string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) .. displayName .. "|r")
        end
    end
    
    -- Add guild information
    if guildName and self.settings.features.showGuildRank then
        -- Find the guild line (usually the second line)
        for i = 2, tooltip:NumLines() do
            local line = _G["GameTooltipTextLeft" .. i]
            if line and line:GetText() and line:GetText():find(guildName) then
                -- Add guild rank to the guild line
                line:SetText(line:GetText() .. " |cff00ff00(" .. guildRankName .. ")|r")
                break
            end
        end
    end
    
    -- Add role information for players in groups
    if UnitIsPlayer(unit) and self.settings.features.showUnitRole and (IsInGroup() or IsInRaid()) then
        local role = UnitGroupRolesAssigned(unit)
        if role and role ~= "NONE" then
            local roleText = ""
            if role == "TANK" then
                roleText = "|cffa0a0ff[Tank]|r"
            elseif role == "HEALER" then
                roleText = "|cff00ff00[Healer]|r"
            elseif role == "DAMAGER" then
                roleText = "|cffff0000[DPS]|r"
            end
            
            if roleText ~= "" then
                tooltip:AddLine(roleText)
            end
        end
    end
    
    -- Add PvP information
    if isPVP and self.settings.features.showPvPInfo then
        local factionGroup = UnitFactionGroup(unit)
        if factionGroup then
            local pvpText = ""
            if factionGroup == "Alliance" then
                pvpText = "|cff0070dd[PvP - Alliance]|r"
            elseif factionGroup == "Horde" then
                pvpText = "|cffff0000[PvP - Horde]|r"
            else
                pvpText = "|cff808080[PvP]|r"
            end
            
            tooltip:AddLine(pvpText)
        end
    end
end

function Tooltip:AddTargetingInfo(tooltip, unit)
    -- Get the unit's target
    local targetUnit = unit .. "target"
    
    -- Check if the unit has a target
    if UnitExists(targetUnit) then
        local targetName = UnitName(targetUnit)
        local relationship = ""
        
        -- Determine the relationship between the unit and their target
        if UnitIsUnit(targetUnit, "player") then
            relationship = "|cffff0000Targeting You|r"
        elseif UnitIsUnit(targetUnit, "pet") then
            relationship = "|cffff9900Targeting Your Pet|r"
        elseif UnitInParty(targetUnit) or UnitInRaid(targetUnit) then
            -- If target is in our group, show their class-colored name
            local _, targetClass = UnitClass(targetUnit)
            if targetClass and RAID_CLASS_COLORS[targetClass] and self.settings.features.classColoredNames then
                local color = RAID_CLASS_COLORS[targetClass]
                relationship = "|cffffffff" .. "Targeting |r" .. 
                               "|cff" .. string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) .. 
                               targetName .. "|r"
            else
                relationship = "|cffffffff" .. "Targeting " .. targetName .. "|r"
            end
        else
            relationship = "|cffffffff" .. "Targeting " .. targetName .. "|r"
        end
        
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine(relationship)
    end
end

function Tooltip:AddMountInfo(tooltip, unit)
    -- Check if the unit is mounted
    if not IsMounted(unit) then return end
    
    -- Try to get the mount's name
    local mountName = "Unknown Mount"
    local mountSpellID = nil
    
    -- Look for mount buffs
    for i = 1, 40 do
        local name, icon, _, _, duration, expirationTime, source, _, _, spellID = UnitBuff(unit, i)
        
        -- If the buff is no longer found, break
        if not name then break end
        
        -- Check if this is a mount spell by checking mount categories
        if spellID then
            local mountIDs = C_MountJournal and C_MountJournal.GetMountIDs and C_MountJournal.GetMountIDs() or {}
            for _, mountID in ipairs(mountIDs) do
                local _, spellId, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                if spellId == spellID then
                    mountName = name
                    mountSpellID = spellID
                    break
                end
            end
            
            -- If we found a mount, break the loop
            if mountSpellID then break end
        end
    end
    
    -- If we couldn't find a mount aura, try to check model animations
    if mountName == "Unknown Mount" then
        -- Check if the unit has a mount animation
        local hasMount = true -- Placeholder, no direct API for this
        
        if hasMount then
            -- If we can't identify the specific mount, just say they're mounted
            mountName = "A Mount"
        end
    end
    
    -- Add the information to the tooltip
    tooltip:AddLine(" ")
    tooltip:AddLine("|cff00ff00Mounted on: |r" .. mountName)
    
    -- Add mount spell ID if available and enabled
    if mountSpellID and self.settings.features.showSpellID then
        tooltip:AddLine("|cff00ffffMount Spell ID: |r" .. mountSpellID)
    end
end

function Tooltip:AddHealthInfo(tooltip, unit)
    -- Check if the unit has health
    if not UnitExists(unit) or UnitIsDead(unit) then return end
    
    -- Get health information
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    
    if health and maxHealth and maxHealth > 0 then
        -- Calculate health percentage
        local healthPercent = health / maxHealth * 100
        
        -- Format the health text
        local healthText = string.format("|cff71d5ff%.0f%%|r |cffffffff(%s / %s)|r", 
                                        healthPercent, 
                                        self:FormatNumber(health), 
                                        self:FormatNumber(maxHealth))
        
        -- Add the health text to the tooltip
        tooltip:AddLine("Health: " .. healthText)
    end
    
    -- Add power information if the unit has power
    local powerType, powerToken = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    
    if power and maxPower and maxPower > 0 then
        -- Get power color
        local powerColor = _G.PowerBarColor[powerToken] or _G.PowerBarColor["MANA"]
        
        -- Calculate power percentage
        local powerPercent = power / maxPower * 100
        
        -- Format the power text
        local powerText = string.format("|cff%02x%02x%02x%.0f%%|r |cffffffff(%s / %s)|r", 
                                       powerColor.r * 255, powerColor.g * 255, powerColor.b * 255, 
                                       powerPercent, 
                                       self:FormatNumber(power), 
                                       self:FormatNumber(maxPower))
        
        -- Add the power text to the tooltip
        local powerName = _G[powerToken] or "Power"
        tooltip:AddLine(powerName .. ": " .. powerText)
    end
end

function Tooltip:AddItemIDInfo(tooltip, itemLink)
    -- Extract the item ID from the item link
    local itemID = itemLink and itemLink:match(ITEM_ID_PATTERN)
    
    if itemID then
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ffffItem ID: |r" .. itemID)
    end
end

function Tooltip:AddItemLevelInfo(tooltip, itemLink)
    -- Get the item level from the item link
    local itemLevel = itemLink and GetDetailedItemLevelInfo(itemLink)
    
    if itemLevel then
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ffffItem Level: |r" .. itemLevel)
    end
end

function Tooltip:AddItemCountInfo(tooltip, itemLink)
    -- Get the item info from the link
    local itemID = itemLink and itemLink:match(ITEM_ID_PATTERN)
    
    if itemID then
        -- Get the item count
        local count = GetItemCount(itemID)
        
        if count and count > 0 then
            -- Add the information to the tooltip
            tooltip:AddLine(" ")
            tooltip:AddLine("|cff00ffffYou have: |r" .. count)
        end
    end
end

function Tooltip:AddSpellIDInfo(tooltip, spellID)
    -- Add the spell ID to the tooltip
    if spellID then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ffffSpell ID: |r" .. spellID)
    end
end

function Tooltip:AddSpellSourceInfo(tooltip, spellID)
    -- This function would add information about who cast a spell/aura
    -- For this implementation, we'll leave it as a placeholder
    -- as getting the source of an aura requires context not available here
end

function Tooltip:ColorBorderByClass(tooltip, unit)
    -- Color the tooltip border based on the unit's class
    if UnitIsPlayer(unit) then
        local _, className = UnitClass(unit)
        if className and RAID_CLASS_COLORS[className] then
            local color = RAID_CLASS_COLORS[className]
            if tooltip.SetBackdropBorderColor then
                tooltip:SetBackdropBorderColor(color.r, color.g, color.b, 1)
            end
        end
    end
end

----------------------------------
-- Helper Functions
----------------------------------

function Tooltip:FormatNumber(number)
    -- Format large numbers to be more readable
    if number >= 1000000 then
        return string.format("%.1fm", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fk", number / 1000)
    else
        return tostring(number)
    end
end

----------------------------------
-- Settings Management
----------------------------------

function Tooltip:UpdateSettings()
    -- Only apply if the module is enabled
    if not self.enabled then return end
    
    -- Update tooltip style
    self:UpdateTooltipStyle()
    
    -- Apply combat settings if in combat
    if InCombatLockdown() then
        self:ApplyCombatSettings(true)
    end
end

-- Register with VUI for initialization
VUI.Tooltip = Tooltip