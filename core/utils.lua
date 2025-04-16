-- VUI Utility Functions

-- Print colored message to chat
function VUI:Print(msg)
    print("|cff1784d1VUI:|r " .. tostring(msg))
end

-- Create a debug print function that only shows when debugging is enabled
function VUI:Debug(...)
    if self.db and self.db.profile.debug then
        print("|cff1784d1VUI Debug:|r", ...)
    end
end

-- Round a number to the nearest decimal places
function VUI:Round(num, decimals)
    if not decimals then decimals = 0 end
    local mult = 10^decimals
    return math.floor(num * mult + 0.5) / mult
end

-- Format time (seconds) into a readable string
function VUI:FormatTime(seconds)
    if seconds <= 0 then
        return "0s"
    elseif seconds < 60 then
        return string.format("%.1fs", seconds)
    elseif seconds < 3600 then
        local minutes = math.floor(seconds / 60)
        seconds = seconds % 60
        return string.format("%dm %ds", minutes, seconds)
    else
        local hours = math.floor(seconds / 3600)
        seconds = seconds % 3600
        local minutes = math.floor(seconds / 60)
        seconds = seconds % 60
        return string.format("%dh %dm %ds", hours, minutes, seconds)
    end
end

-- Format large numbers with commas
function VUI:FormatNumber(number)
    if not number then return 0 end
    if number >= 1000000 then
        return string.format("%.1fm", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fk", number / 1000)
    else
        return number
    end
end

-- Get player class
function VUI:GetPlayerClass()
    local _, class = UnitClass("player")
    return class
end

-- Get player spec
function VUI:GetPlayerSpec()
    local specID = GetSpecialization()
    if specID then
        local _, name, _, icon = GetSpecializationInfo(specID)
        return name, icon, specID
    end
    return nil, nil, nil
end

-- Check if player is in combat
function VUI:IsInCombat()
    return UnitAffectingCombat("player")
end

-- Check if player is in a group
function VUI:IsInGroup()
    return IsInGroup() or IsInRaid()
end

-- Get group size
function VUI:GetGroupSize()
    if IsInRaid() then
        return GetNumGroupMembers()
    elseif IsInGroup() then
        return GetNumGroupMembers()
    else
        return 1
    end
end

-- Utility function to create a frame with a border
function VUI:CreateBorderFrame(name, parent, width, height, r, g, b, a)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetSize(width, height)
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, a or 0.7)
    
    -- Border
    frame.border = CreateFrame("Frame", nil, frame)
    frame.border:SetPoint("TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", 1, -1)
    frame.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame.border:SetBackdropBorderColor(r or 0.3, g or 0.3, b or 0.3, 1)
    
    return frame
end

-- Create a status bar
function VUI:CreateStatusBar(name, parent, width, height, value, min, max, r, g, b)
    local bar = CreateFrame("StatusBar", name, parent)
    bar:SetSize(width, height)
    bar:SetStatusBarTexture(self:GetTexture("statusbar"))
    bar:SetMinMaxValues(min or 0, max or 1)
    bar:SetValue(value or 0)
    
    if r and g and b then
        bar:SetStatusBarColor(r, g, b)
    else
        bar:SetStatusBarColor(self:GetColor("primary"))
    end
    
    -- Background
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetTexture(self:GetTexture("statusbar"))
    bar.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    
    -- Border
    bar.border = CreateFrame("Frame", nil, bar)
    bar.border:SetPoint("TOPLEFT", -1, 1)
    bar.border:SetPoint("BOTTOMRIGHT", 1, -1)
    bar.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    bar.border:SetBackdropBorderColor(0, 0, 0, 1)
    
    return bar
end

-- Create frame backdrop
function VUI:CreateBackdrop(frame, bgColor, borderColor, inset)
    if not frame.backdrop then
        if frame:GetObjectType() == "Button" then
            frame.backdrop = CreateFrame("Frame", nil, frame)
        else
            frame.backdrop = frame:CreateTexture(nil, "BACKGROUND")
        end
        
        inset = inset or -2
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -inset, inset)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", inset, -inset)
        
        if frame.backdrop:GetObjectType() == "Frame" then
            frame.backdrop:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            
            if not borderColor then
                borderColor = {0, 0, 0, 1}
            end
            frame.backdrop:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
            
            if not bgColor then
                bgColor = {0.1, 0.1, 0.1, 0.8}
            end
            frame.backdrop:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
        else
            frame.backdrop:SetColorTexture(bgColor[1] or 0.1, bgColor[2] or 0.1, bgColor[3] or 0.1, bgColor[4] or 0.8)
        end
    end
end

-- Position and size functions
function VUI:RepositionFrame(frame, point, relativeTo, relativePoint, xOffset, yOffset)
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
end

-- Copy table function
function VUI:CopyTable(src)
    local copy = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            copy[k] = self:CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Merge two tables
function VUI:MergeTable(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if type(target[k] or false) == "table" then
                self:MergeTable(target[k], v)
            else
                target[k] = self:CopyTable(v)
            end
        else
            target[k] = v
        end
    end
    return target
end

-- Parse item link
function VUI:ParseItemLink(link)
    if not link then return nil end
    
    local itemID = link:match("item:(%d+)")
    if not itemID then return nil end
    
    local itemName, _, itemRarity, itemLevel, _, itemType, itemSubType = GetItemInfo(link)
    
    return {
        id = tonumber(itemID),
        name = itemName,
        link = link,
        rarity = itemRarity,
        level = itemLevel,
        type = itemType,
        subType = itemSubType
    }
end

-- Get player stats
function VUI:GetPlayerStats()
    local stats = {}
    
    -- Base stats
    stats.strength = UnitStat("player", 1)
    stats.agility = UnitStat("player", 2)
    stats.stamina = UnitStat("player", 3)
    stats.intellect = UnitStat("player", 4)
    
    -- Derived stats
    stats.health = UnitHealthMax("player")
    stats.power = UnitPowerMax("player")
    stats.powerType = UnitPowerType("player")
    
    -- Combat stats
    stats.attackPower = GetAttackPowerForStat(1, stats.strength)
    stats.spellPower = GetSpellBonusDamage(2) -- 2 = Holy (arbitrary magic school)
    stats.crit = GetCritChance()
    stats.haste = GetHaste()
    stats.mastery = GetMasteryEffect()
    stats.versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    
    -- Defense stats
    stats.armor = UnitArmor("player")
    stats.dodge = GetDodgeChance()
    stats.parry = GetParryChance()
    stats.block = GetBlockChance()
    
    return stats
end

-- Get current zone info
function VUI:GetZoneInfo()
    local zoneText = GetZoneText()
    local subZoneText = GetSubZoneText()
    local minimapZoneText = GetMinimapZoneText()
    
    return {
        zone = zoneText,
        subZone = subZoneText,
        minimapZone = minimapZoneText,
        pvp = {
            isPvP = IsInPvP(),
            isArena = IsInArena(),
            isBattleground = IsInBattleground()
        },
        instance = {
            name = GetInstanceInfo()
        }
    }
end
