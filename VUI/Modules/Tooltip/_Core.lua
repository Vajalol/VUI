local Module = VUI:NewModule("Tooltip.Core");

-- Cache frequently accessed globals for better performance
local UnitExists = UnitExists
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitName = UnitName
local UnitReaction = UnitReaction
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local GetGuildInfo = GetGuildInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local UnitSex = UnitSex
local UnitGUID = UnitGUID
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitBattlePetType = UnitBattlePetType
local UnitIsPVP = UnitIsPVP
local UnitIsMercenary = UnitIsMercenary
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local INSPECT_ACHIEVEMENTS_DATA = INSPECT_ACHIEVEMENTS_DATA
local select, pairs, ipairs, unpack = select, pairs, ipairs, unpack
local format, find, match = string.format, string.find, string.match
local floor = math.floor

-- Local variables
local inspectCache = {}
local LOADING_ITEM_LEVEL = "Loading..."
local LOADING_MOUNT_INFO = "Loading..."
local genders = {
    [1] = "Unknown",
    [2] = "Male",
    [3] = "Female"
}

-- Role Icons
local roleIcons = {
    TANK = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t",
    HEALER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t",
    DAMAGER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t",
    NONE = ""
}

function Module:OnEnable()
    local db = VUI.db.profile.tooltip

    local TooltipFrame = CreateFrame('Frame', "TooltipFrame", UIParent)
    TooltipFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 120)
    TooltipFrame:SetSize(150, 25)

    -- Create a frame for inspect scanning
    local inspectFrame = CreateFrame("Frame")
    
    -- Tooltip anchor
    if (db.mouseanchor) then
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
            tooltip:SetOwner(parent, "ANCHOR_CURSOR")
        end)
    else
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
            tooltip:SetOwner(parent, "ANCHOR_NONE")
        end)
    end

    if (db.style == "Custom") then
        FONT = STANDARD_TEXT_FONT
        local classColorHex, factionColorHex = {}, {}

        local cfg = {
            textColor = { 0.4, 0.4, 0.4 },
            bossColor = { 1, 0, 0 },
            eliteColor = { 1, 0, 0.5 },
            rareeliteColor = { 1, 0.5, 0 },
            rareColor = { 1, 0.5, 0 },
            levelColor = { 0.8, 0.8, 0.5 },
            deadColor = { 0.5, 0.5, 0.5 },
            targetColor = { 1, 0.5, 0.5 },
            guildColor = { 0.8, 0.0, 0.6 },
            afkColor = { 0, 1, 1 },
            scale = 0.95,
            fontFamily = STANDARD_TEXT_FONT,
        }

        if (db) then
            GameTooltipStatusBar:SetStatusBarTexture(
                "Interface\\Addons\\VUI\\Media\\Textures\\Tooltip\\UI-TargetingFrame-BarFill_test")
        end

        local function GetHexColor(color)
            if color.r then
                return ("%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
            else
                local r, g, b, a = unpack(color)
                return ("%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)
            end
        end

        local function GetTarget(unit)
            if UnitIsUnit(unit, "player") then
                return ("|cffff0000%s|r"):format("<YOU>")
            elseif UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                return ("|cff%s%s|r"):format(classColorHex[class], UnitName(unit))
            elseif UnitReaction(unit, "player") then
                return ("|cff%s%s|r"):format(factionColorHex[UnitReaction(unit, "player")], UnitName(unit))
            else
                return ("|cffffffff%s|r"):format(UnitName(unit))
            end
        end

        local function OnTooltipSetUnit(self)
            if self ~= _G.GameTooltip then
                return
            end

            local unitName, unit = self:GetUnit()
            if not unit then return end
            --color tooltip textleft
            for i = 2, GameTooltip:NumLines() do
                local line = _G["GameTooltipTextLeft" .. i]
                if line then
                    if not line == 4 then
                        line:SetTextColor(unpack(cfg.textColor))
                    end
                end
            end
            --position raidicon
            if unit and GetRaidTargetIndex(unit) then
                local raidIconIndex = GetRaidTargetIndex(unit)
                if GetRaidTargetIndex(unit) == 16 then
                    GameTooltipTextLeft1:SetText(("%s"):format(unitName))
                else
                    GameTooltipTextLeft1:SetText(("%s %s"):format(ICON_LIST[raidIconIndex] .. "14|t", unitName))
                end
            end
            if not UnitIsPlayer(unit) then
                local reaction = UnitReaction(unit, "player")
                if reaction then
                    local color = FACTION_BAR_COLORS[reaction]
                    if color then
                        cfg.barColor = color
                        GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
                        GameTooltipTextLeft1:SetTextColor(color.r, color.g, color.b)
                    end
                end
                --color textleft2 by classificationcolor
                local unitClassification = UnitClassification(unit)
                local levelLine
                if string.find(GameTooltipTextLeft2:GetText() or "empty", "%a%s%d") then
                    levelLine = GameTooltipTextLeft2
                elseif GameTooltipTextLeft3 ~= nil and string.find(GameTooltipTextLeft3:GetText() or "empty", "%a%s%d") then
                    GameTooltipTextLeft2:SetTextColor(unpack(cfg.guildColor))
                    levelLine = GameTooltipTextLeft3
                end
                if levelLine then
                    local l = UnitLevel(unit)
                    local color = GetCreatureDifficultyColor((l > 0) and l or 999)
                    levelLine:SetTextColor(color.r, color.g, color.b)
                end
                if unitClassification == "worldboss" or UnitLevel(unit) == -1 then
                    self:AppendText(" |cffff0000[B]|r")
                    GameTooltipTextLeft2:SetTextColor(unpack(cfg.bossColor))
                elseif unitClassification == "rare" then
                    self:AppendText(" |cffff9900[R]|r")
                elseif unitClassification == "rareelite" then
                    self:AppendText(" |cffff0000[R+]|r")
                elseif unitClassification == "elite" then
                    self:AppendText(" |cffff6666[E]|r")
                end
            else
                --unit is any player
                local _, unitClass = UnitClass(unit)
                --color textleft1 and statusbar by class color
                local color = RAID_CLASS_COLORS[unitClass]
                cfg.barColor = color
                GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
                _G["GameTooltipTextLeft1"]:SetTextColor(color.r, color.g, color.b)
                --color textleft2 by guildcolor
                local guildName, guildRank = GetGuildInfo(unit)
                if guildName then
                    _G["GameTooltipTextLeft2"]:SetText("<" .. guildName .. "> [" .. guildRank .. "]")
                    _G["GameTooltipTextLeft2"]:SetTextColor(unpack(cfg.guildColor))
                end
                local levelLine = guildName and _G["GameTooltipTextLeft3"] or _G["GameTooltipTextLeft2"]
                local l = UnitLevel(unit)
                local color = GetCreatureDifficultyColor((l > 0) and l or 999)
                levelLine:SetTextColor(color.r, color.g, color.b)
                --afk?
                if UnitIsAFK(unit) then
                    self:AppendText((" |cff%s<AFK>|r"):format(cfg.afkColorHex))
                end
            end
            --dead?
            if UnitIsDeadOrGhost(unit) then
                _G["GameTooltipTextLeft1"]:SetTextColor(unpack(cfg.deadColor))
            end
            --target line
            if (UnitExists(unit .. "target")) then
                GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(cfg.targetColorHex, "Target"),
                    GetTarget(unit .. "target") or "Unknown")
            end
        end

        local function SetStatusBarColor(self, r, g, b)
            if not cfg.barColor then return end
            if r == cfg.barColor.r and g == cfg.barColor.g and b == cfg.barColor.b then return end
            self:SetStatusBarColor(cfg.barColor.r, cfg.barColor.g, cfg.barColor.b)
        end

        --hex class colors
        for class, color in next, RAID_CLASS_COLORS do
            classColorHex[class] = GetHexColor(color)
        end
        --hex reaction colors
        --for idx, color in next, FACTION_BAR_COLORS do
        for i = 1, #FACTION_BAR_COLORS do
            factionColorHex[i] = GetHexColor(FACTION_BAR_COLORS[i])
        end

        cfg.targetColorHex = GetHexColor(cfg.targetColor)
        cfg.afkColorHex = GetHexColor(cfg.afkColor)

        --GameTooltipHeaderText:SetFont(cfg.fontFamily, 14)
        --GameTooltipHeaderText:SetShadowOffset(1,-2)
        --GameTooltipHeaderText:SetShadowColor(0,0,0,0.75)
        --GameTooltipText:SetFont(cfg.fontFamily, 12, "NONE")
        --GameTooltipText:SetShadowOffset(1,-2)
        --GameTooltipText:SetShadowColor(0,0,0,0.75)
        --Tooltip_Small:SetFont(cfg.fontFamily, 11, "NONE")
        --Tooltip_Small:SetShadowOffset(1,-2)
        --Tooltip_Small:SetShadowColor(0,0,0,0.75)

        if (db.lifeontop) then
            GameTooltipStatusBar:ClearAllPoints()
            GameTooltipStatusBar:SetPoint("LEFT", 4.5, 0)
            GameTooltipStatusBar:SetPoint("RIGHT", -4.5, 0)
            GameTooltipStatusBar:SetPoint("TOP", 0, -3)
            GameTooltipStatusBar:SetHeight(4)
        else
            GameTooltipStatusBar:ClearAllPoints()
            GameTooltipStatusBar:SetPoint("LEFT", 4.5, 0)
            GameTooltipStatusBar:SetPoint("RIGHT", -4.5, 0)
            GameTooltipStatusBar:SetPoint("BOTTOM", 0, 3)
            GameTooltipStatusBar:SetHeight(4)
        end

        --gametooltip statusbar bg
        GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND", nil, -8)
        GameTooltipStatusBar.bg:SetAllPoints()
        GameTooltipStatusBar.bg:SetColorTexture(1, 1, 1)
        GameTooltipStatusBar.bg:SetVertexColor(0, 0, 0, 0.5)

        --GameTooltipStatusBar:SetStatusBarColor()
        hooksecurefunc(GameTooltipStatusBar, "SetStatusBarColor", SetStatusBarColor)
        --OnTooltipSetUnit
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
        --GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

        --loop over menues
        local menues = {
            DropDownList1MenuBackdrop,
            DropDownList2MenuBackdrop,
        }
        for i, menu in next, menues do
            menu:SetScale(cfg.scale)
        end

        --TooltipAddSpellID
        local function TooltipAddSpellID(self, spellid)
            if not spellid then return end
            if type(spellid) == "table" and #spellid == 1 then spellid = spellid[1] end
            local frame, text
            for i = 1, 15 do
                frame = _G[self:GetName() .. "TextLeft" .. i]
                if frame then text = frame:GetText() end
                if text and string.find(text, "|cff0099ffID|r") then return end
            end
            self:AddDoubleLine("|cff0099ffID|r", spellid)
            self:Show()
        end

        local function TooltipAddBuffSource(self, caster)
            local name = caster and UnitName(caster)
            if name then
                self:AddDoubleLine("|cff0099ffCast by|r", name, nil, nil, nil, 1, 1, 1)
                self:Show()
            end
        end

        --hooksecurefunc GameTooltip SetUnitBuff
        hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unitToken, index, filter)
            TooltipAddSpellID(self,
                select(10, AuraUtil.UnpackAuraData(C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter))))
        end)

        --hooksecurefunc GameTooltip SetUnitDebuff
        hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unitToken, index, filter)
            TooltipAddSpellID(self,
                select(10, AuraUtil.UnpackAuraData(C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter))))
        end)

        --hooksecurefunc GameTooltip SetUnitAura
        hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unitToken, index, filter)
            TooltipAddSpellID(self,
                select(10, AuraUtil.UnpackAuraData(C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter))))
            TooltipAddBuffSource(self,
                select(7, AuraUtil.UnpackAuraData(C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter))))
        end)

        --hooksecurefunc SetItemRef
        hooksecurefunc("SetItemRef", function(link)
            local type, value = link:match("(%a+):(.+)")
            if type == "spell" then
                TooltipAddSpellID(ItemRefTooltip, value:match("([^:]+)"))
            end
        end)

        --HookScript GameTooltip OnTooltipSetSpell
        local function OnTooltipSetSpell(self, data)
            TooltipAddSpellID(self, data.id)
        end

        local function OnMacroTooltipSetSpell(self)
            if self:GetTooltipData() and self:GetTooltipData().lines and self:GetTooltipData().lines[2] and
                self:GetTooltipData().lines[2].leftText then
                local tooltipData = self:GetTooltipData()
                local tooltipName = tooltipData.lines[2].leftText
                local spellInfo   = C_Spell.GetSpellInfo(tooltipName)

                if (spellInfo and spellInfo.spellID) then
                    TooltipAddSpellID(self, spellInfo.spellID)
                end
            end
        end

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, OnMacroTooltipSetSpell)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, OnTooltipSetSpell)
        
        -- Enhanced Tooltip Features
        
        -- Function to get unit mount information
        local function GetUnitMountInfo(unit)
            if not UnitIsPlayer(unit) or not UnitIsVisible(unit) then return nil end
            
            local mountID = nil
            
            -- Use TipTop-style mount detection
            for i = 1, 100 do
                local _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, i)
                if not spellID then break end
                
                -- Check if the buff is a mount aura (certain spell IDs range)
                if C_MountJournal then
                    -- Try to get mount info from mount journal
                    local mountIDs = C_MountJournal.GetMountIDs()
                    for _, id in ipairs(mountIDs) do
                        local _, spellID2, _, _, _, _, _, _, _, _, _, _ = C_MountJournal.GetMountInfoByID(id)
                        if spellID == spellID2 then
                            mountID = id
                            break
                        end
                    end
                    
                    if mountID then
                        local name, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                        if name then
                            return name
                        end
                    end
                end
            end
            
            return nil
        end
        
        -- Function to get player item level
        local function GetPlayerItemLevel(unit)
            if not UnitIsPlayer(unit) or not UnitIsVisible(unit) then return nil end
            
            local guid = UnitGUID(unit)
            if not guid then return nil end
            
            -- Return cached ilvl if available
            if inspectCache[guid] and inspectCache[guid].itemLevel then
                return inspectCache[guid].itemLevel
            end
            
            -- Initialize cache entry if needed
            if not inspectCache[guid] then 
                inspectCache[guid] = {
                    lastUpdate = 0,
                    itemLevel = nil
                }
            end
            
            -- Only request inspect if enough time has passed since the last one
            local currentTime = GetTime()
            if currentTime - inspectCache[guid].lastUpdate > 5 then
                inspectCache[guid].lastUpdate = currentTime
                
                -- Use NotifyInspect if it exists and unit is in range
                if CheckInteractDistance(unit, 1) and CanInspect(unit) then
                    NotifyInspect(unit)
                    
                    -- Schedule a function to get the item level after a short delay
                    C_Timer.After(0.5, function()
                        -- Get the average item level if possible
                        local totalItemLevel = 0
                        local itemCount = 0
                        
                        -- Try to get item level from equipped items
                        if unit and UnitIsVisible(unit) then
                            for i = 1, 17 do -- Check all equipment slots
                                if i ~= 4 then -- Skip shirt slot
                                    local itemLink = GetInventoryItemLink(unit, i)
                                    if itemLink then
                                        local _, _, _, itemLevel = GetItemInfo(itemLink)
                                        if itemLevel and itemLevel > 0 then
                                            totalItemLevel = totalItemLevel + itemLevel
                                            itemCount = itemCount + 1
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- Calculate average item level
                        if itemCount > 0 then
                            local avgItemLevel = floor(totalItemLevel / itemCount)
                            inspectCache[guid].itemLevel = avgItemLevel
                            -- Force tooltip refresh if GameTooltip's unit is still this unit
                            local tooltipUnit = GameTooltip:GetUnit()
                            if tooltipUnit and UnitGUID(tooltipUnit) == guid then
                                GameTooltip:RefreshData()
                            end
                        end
                    end)
                end
            end
            
            -- Return the cached value (might be nil if still being fetched)
            return inspectCache[guid].itemLevel or LOADING_ITEM_LEVEL
        end
        
        -- Function to enhance tooltips with additional player information
        local function EnhancePlayerTooltip(tooltip, unit)
            if not unit or not UnitIsPlayer(unit) then return end
            
            -- Role information (tank, healer, dps)
            if db.roleIcon then
                local role = UnitGroupRolesAssigned(unit)
                if role and role ~= "NONE" then
                    local roleIcon = roleIcons[role] or ""
                    local roleText = role
                    tooltip:AddLine(" ")
                    tooltip:AddLine(format("%s Role: %s", roleIcon, roleText))
                end
            end
            
            -- Gender information
            if db.gender then
                local genderIndex = UnitSex(unit)
                if genderIndex and genderIndex > 1 then
                    tooltip:AddLine(format("Gender: %s", genders[genderIndex] or "Unknown"))
                end
            end
            
            -- Mount information
            if db.mountInfo then
                local mountName = GetUnitMountInfo(unit)
                if mountName then
                    tooltip:AddLine(format("Mount: |cff00FF00%s|r", mountName))
                end
            end
            
            -- Item level information
            if db.inspectInfo then
                local itemLevel = GetPlayerItemLevel(unit)
                if itemLevel then
                    local colorCode = "|cffffffff"
                    if itemLevel ~= LOADING_ITEM_LEVEL then
                        -- Color based on item level ranges
                        if itemLevel >= 500 then colorCode = "|cffff00ff"      -- Epic (purple)
                        elseif itemLevel >= 460 then colorCode = "|cff0070ff"  -- Rare (blue)
                        elseif itemLevel >= 420 then colorCode = "|cff1eff00"  -- Uncommon (green)
                        else colorCode = "|cffffffff" end                       -- Common (white)
                    end
                    tooltip:AddLine(format("Item Level: %s%s|r", colorCode, itemLevel))
                end
            end
        end
        
        -- Function to display who is targeting the unit
        local function AddTargetedBy(tooltip, unit)
            if not IsInGroup() or not db.targetedInfo then return end
            
            local targetedList = {}
            local isInRaid = IsInRaid()
            local numGroup = isInRaid and GetNumGroupMembers() or GetNumSubgroupMembers()
            local inInstance, instanceType = IsInInstance()
            
            -- Build a list of group members targeting this unit
            for i = 1, numGroup do
                local groupUnit = (isInRaid and "raid"..i or "party"..i)
                if UnitIsUnit(groupUnit.."target", unit) and not UnitIsUnit(groupUnit, "player") then
                    local _, classFilename = UnitClass(groupUnit)
                    local classColorHex = classFilename and RAID_CLASS_COLORS[classFilename].colorStr or "ffffffff"
                    tinsert(targetedList, format("|c%s%s|r", classColorHex, UnitName(groupUnit)))
                end
            end
            
            -- Check if player is targeting this unit
            if UnitIsUnit("target", unit) and not UnitIsUnit("player", unit) then
                local _, classFilename = UnitClass("player")
                local classColorHex = classFilename and RAID_CLASS_COLORS[classFilename].colorStr or "ffffffff"
                tinsert(targetedList, format("|c%s%s|r", classColorHex, "YOU"))
            end
            
            -- Add the targeted by line if anyone is targeting the unit
            if #targetedList > 0 then
                tooltip:AddLine(" ")
                tooltip:AddLine("Targeted by: "..table.concat(targetedList, ", "), 1, 1, 1)
            end
        end
        
        -- Function to enhance tooltip with player titles
        local function EnhanceWithTitle(tooltip, unit, unitName)
            if not db.playerTitles or not UnitIsPlayer(unit) then return unitName end
            
            local titleName = UnitPVPName(unit)
            -- If the unit has a title and it's not the same as the regular name
            if titleName and titleName ~= unitName then
                return titleName
            end
            
            return unitName
        end
        
        -- Function to enhance guild info display in tooltips
        local function EnhanceGuildInfo(tooltip, unit)
            if not db.guildRanks or not UnitIsPlayer(unit) then return false end
            
            local guildName, guildRank, guildRankIndex, guildRealm = GetGuildInfo(unit)
            if guildName then
                if guildRealm and guildRealm ~= "" then
                    guildName = guildName.."-"..guildRealm
                end
                
                local rankColor = "|cff00ff00"
                if guildRankIndex and guildRankIndex > 0 then
                    -- Less green for lower ranks
                    local greenValue = max(100 - (guildRankIndex * 10), 0)
                    rankColor = format("|cff00%02xff", greenValue)
                end
                
                tooltip:AddLine(format("<|cff00aeff%s|r> %s%s|r", guildName, rankColor, guildRank), 1, 1, 1)
                return true
            end
            
            return false
        end
        
        -- Enhanced tooltip handler
        local function EnhancedOnTooltipSetUnit(self, tooltipData)
            if self ~= GameTooltip then return end
            
            local unitName, unit = self:GetUnit()
            if not unit then return end
            
            -- Player titles
            if db.playerTitles and UnitIsPlayer(unit) then
                local titleName = EnhanceWithTitle(self, unit, unitName)
                if titleName ~= unitName then
                    -- Set the first line to the title name with appropriate class color
                    local _, classFilename = UnitClass(unit)
                    if classFilename then
                        local classColor = RAID_CLASS_COLORS[classFilename]
                        GameTooltipTextLeft1:SetText(titleName)
                        GameTooltipTextLeft1:SetTextColor(classColor.r, classColor.g, classColor.b)
                    end
                end
            end
            
            -- Target information
            if db.targetInfo and UnitExists(unit.."target") then
                local targetName = UnitName(unit.."target")
                local _, targetClass = UnitClass(unit.."target")
                local targetReaction = UnitReaction(unit.."target", "player")
                
                if targetName then
                    local targetColor = "|cffffffff"
                    if UnitIsPlayer(unit.."target") and targetClass then
                        local classColor = RAID_CLASS_COLORS[targetClass]
                        targetColor = format("|cff%02x%02x%02x", classColor.r*255, classColor.g*255, classColor.b*255)
                    elseif targetReaction then
                        local reactionColor = FACTION_BAR_COLORS[targetReaction]
                        targetColor = format("|cff%02x%02x%02x", reactionColor.r*255, reactionColor.g*255, reactionColor.b*255)
                    end
                    
                    self:AddLine(format("Target: %s%s|r", targetColor, targetName))
                end
            end
            
            -- Add who's targeting this unit (in raid/party)
            AddTargetedBy(self, unit)
            
            -- Enhanced player information
            EnhancePlayerTooltip(self, unit)
            
            self:Show() -- Ensure tooltip size updates with new lines
        end
        
        -- Hook tooltip processing for unit tooltips
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, EnhancedOnTooltipSetUnit)
        
        -- Register events for inspect info management
        local inspectFrame = CreateFrame("Frame")
        inspectFrame:RegisterEvent("INSPECT_READY")
        inspectFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        inspectFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        inspectFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        
        inspectFrame:SetScript("OnEvent", function(self, event, guid)
            if event == "INSPECT_READY" and guid then
                -- If we have cached data for this GUID, update the item level
                local unit = "mouseover"
                if UnitExists(unit) and UnitGUID(unit) == guid then
                    -- Use a small delay to ensure inspect data is available
                    C_Timer.After(0.1, function()
                        if UnitExists(unit) and UnitGUID(unit) == guid then
                            local tooltipUnit = GameTooltip:GetUnit()
                            if tooltipUnit and UnitGUID(tooltipUnit) == guid then
                                GameTooltip:RefreshData()
                            end
                        end
                    end)
                end
            elseif event == "UPDATE_MOUSEOVER_UNIT" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
                -- Check if this is a player that we can inspect
                local unit = event == "UPDATE_MOUSEOVER_UNIT" and "mouseover" or
                             (event == "PLAYER_FOCUS_CHANGED" and "focus" or "target")
                
                if UnitExists(unit) and UnitIsPlayer(unit) and CanInspect(unit) and not InspectFrame then
                    -- Reset the cache counter to trigger a refresh on next tooltip display
                    local guid = UnitGUID(unit)
                    if guid and inspectCache[guid] then
                        inspectCache[guid].lastUpdate = 0
                    end
                end
            end
        end)
    end

    if (db.hideincombat) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_REGEN_DISABLED")
        f:RegisterEvent("PLAYER_REGEN_ENABLED")
        f:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_REGEN_DISABLED" then
                GameTooltip:SetScript('OnShow', GameTooltip.Hide)
            else
                GameTooltip:SetScript('OnShow', GameTooltip.Show)
            end
        end)
    end
end
