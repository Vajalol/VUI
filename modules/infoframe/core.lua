-- VUI InfoFrame Module - Core Functionality
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local InfoFrame = VUI.modules.infoframe

-- Cache frequently used globals
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetLootSpecialization = GetLootSpecialization
local GetItemLevelColor = GetItemLevelColor
local GetAverageItemLevel = GetAverageItemLevel
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitRace = UnitRace
local UnitStat = UnitStat
local GetCritChance = GetCritChance
local GetHaste = GetHaste
local GetMastery = GetMastery
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetVersatilityBonus = GetVersatilityBonus
local UnitIsDead = UnitIsDead
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitExists = UnitExists
local UnitName = UnitName
local GetSpellInfo = GetSpellInfo
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitIsUnit = UnitIsUnit
local UnitCreatureFamily = UnitCreatureFamily
local UnitCreatureType = UnitCreatureType
local GetTime = GetTime
local C_Timer = C_Timer

-- Constants for bloodlust/heroism spell IDs
local BLOODLUST_SPELL_IDS = {
    [2825] = true,   -- Bloodlust (Horde Shaman)
    [32182] = true,  -- Heroism (Alliance Shaman)
    [80353] = true,  -- Time Warp (Mage)
    [90355] = true,  -- Ancient Hysteria (Hunter pets)
    [160452] = true, -- Netherwinds (Hunter pets)
    [264667] = true, -- Primal Rage (Hunter pets)
    [272678] = true, -- Primal Rage (Hunter pets)
}

-- Constants for battle resurrection spell IDs
local BATTLE_RES_SPELL_IDS = {
    [20484] = true,  -- Rebirth (Druid)
    [20707] = true,  -- Soulstone (Warlock)
    [95750] = true,  -- Soulstone (Warlock)
    [61999] = true,  -- Raise Ally (Death Knight)
    [126393] = true, -- Eternal Guardian (Hunter Quilen pet)
    [345130] = true, -- Disposable Spectrophasic Reanimator (Engineering)
}

-- Cache class colors for easier access
local CLASS_COLORS = RAID_CLASS_COLORS

----------------------------------
-- Module Setup
----------------------------------

function InfoFrame:Initialize()
    self.enabled = true
    
    -- Create info frame
    self:CreateInfoFrame()
    
    -- Initialize tooltips
    self:InitializeTooltips()
    
    -- Register events
    self:RegisterEvents()
    
    -- Initialize theme integration
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    VUI:Print("Info Frame module initialized")
end

function InfoFrame:RegisterEvents()
    -- Create frame for events if it doesn't exist
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        
        -- Set up event handling
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                self:OnPlayerEnteringWorld(...)
            elseif event == "UNIT_AURA" then
                self:OnUnitAura(...)
            elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
                self:OnSpecializationChanged(...)
            elseif event == "COMBAT_RATING_UPDATE" then
                self:UpdateStatsData()
            elseif event == "PLAYER_EQUIPMENT_CHANGED" then
                self:UpdateStatsData()
            elseif event == "GROUP_ROSTER_UPDATE" then
                self:UpdateRaidCooldowns()
            end
        end)
    end
    
    -- Register events
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("UNIT_AURA")
    self.eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self.eventFrame:RegisterEvent("COMBAT_RATING_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function InfoFrame:OnPlayerEnteringWorld()
    -- Update info frame when entering the world
    self:UpdateAllData()
    
    -- Start the timer for continuous updates
    self:StartUpdateTimer()
end

function InfoFrame:OnUnitAura(unit)
    -- Update cooldowns when auras change for relevant units
    if unit == "player" or UnitInParty(unit) or UnitInRaid(unit) then
        self:UpdateRaidCooldowns()
    end
end

function InfoFrame:OnSpecializationChanged(unit)
    if unit == "player" or not unit then
        self:UpdateSpecData()
    end
end

function InfoFrame:StartUpdateTimer()
    -- Cancel existing timer if any
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
    
    -- Create new timer
    self.updateTimer = C_Timer.NewTicker(self.settings.features.updateInterval, function()
        self:UpdateAllData()
    end)
end

----------------------------------
-- Info Frame Creation
----------------------------------

function InfoFrame:CreateInfoFrame()
    -- Don't create it twice
    if self.frame then return end
    
    -- Create main frame
    self.frame = CreateFrame("Frame", "VUIInfoFrame", UIParent)
    self.frame:SetSize(self.settings.general.width, self.settings.general.height)
    self.frame:SetPoint(unpack(self.settings.general.position))
    self.frame:SetScale(self.settings.general.scale)
    self.frame:SetAlpha(self.settings.general.alpha)
    self.frame:SetFrameStrata(self.settings.general.strata)
    
    -- Make it draggable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame)
        if not self.settings.general.locked then
            frame:StartMoving()
        end
    end)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        -- Save position
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
        self.settings.general.position = {point, relativeTo:GetName(), relativePoint, xOffset, yOffset}
    end)
    
    -- Create backdrop
    self.frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    
    -- Set background color
    local bg = self.settings.general.backdropColor
    self.frame:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
    
    -- Set border color based on class if enabled
    if self.settings.general.classColored then
        local _, class = UnitClass("player")
        if class and CLASS_COLORS[class] then
            local color = CLASS_COLORS[class]
            self.frame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
        else
            local border = self.settings.general.borderColor
            self.frame:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
        end
    else
        local border = self.settings.general.borderColor
        self.frame:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
    end
    
    -- Store frame reference for theme integration
    self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.bg:SetAllPoints(self.frame)
    self.frame.borderFrame = self.frame
    
    -- Create header (title)
    self.frame.header = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.header:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize + 2, self.settings.general.fontOutline)
    self.frame.header:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -10)
    self.frame.header:SetText("VUI Info")
    
    -- Add section for spec and loot spec
    self.frame.spec = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.spec:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.spec:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 0, -10)
    self.frame.spec:SetText("Spec: Unknown")
    
    self.frame.lootSpec = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.lootSpec:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.lootSpec:SetPoint("TOPLEFT", self.frame.spec, "BOTTOMLEFT", 0, -5)
    self.frame.lootSpec:SetText("Loot Spec: Unknown")
    
    -- Add section for item level
    self.frame.itemLevel = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.itemLevel:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.itemLevel:SetPoint("TOPLEFT", self.frame.lootSpec, "BOTTOMLEFT", 0, -5)
    self.frame.itemLevel:SetText("Item Level: 0")
    
    -- Create the player stats frame (transparent, movable)
    self:CreatePlayerStatsFrame()
    
    -- Add section for stats
    self.frame.stats = CreateFrame("Frame", nil, self.frame)
    self.frame.stats:SetPoint("TOPLEFT", self.frame.itemLevel, "BOTTOMLEFT", 0, -10)
    self.frame.stats:SetSize(self.settings.general.width - 20, 80)
    
    -- Create stat strings
    self.frame.stats.title = self.frame.stats:CreateFontString(nil, "OVERLAY")
    self.frame.stats.title:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.stats.title:SetPoint("TOPLEFT", self.frame.stats, "TOPLEFT", 0, 0)
    self.frame.stats.title:SetText("Stats:")
    
    -- Create strings for each stat
    self.statStrings = {}
    local statOffsetY = -15
    
    -- Helper function to create stat strings
    local function CreateStatString(statName, displayName)
        self.statStrings[statName] = self.frame.stats:CreateFontString(nil, "OVERLAY")
        self.statStrings[statName]:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
        self.statStrings[statName]:SetPoint("TOPLEFT", self.frame.stats.title, "BOTTOMLEFT", 0, statOffsetY)
        self.statStrings[statName]:SetText(displayName .. ": 0%")
        statOffsetY = statOffsetY - 15
    end
    
    -- Create stat strings for each displayed stat
    CreateStatString("crit", "Critical Strike")
    CreateStatString("haste", "Haste")
    CreateStatString("mastery", "Mastery")
    CreateStatString("versatility", "Versatility")
    CreateStatString("leech", "Leech")
    CreateStatString("avoidance", "Avoidance")
    CreateStatString("movementSpeed", "Movement Speed")
    
    -- Add section for raid cooldowns
    self.frame.cooldowns = CreateFrame("Frame", nil, self.frame)
    self.frame.cooldowns:SetPoint("TOPLEFT", self.frame.stats, "BOTTOMLEFT", 0, -10)
    self.frame.cooldowns:SetSize(self.settings.general.width - 20, 40)
    
    -- Create cooldown title
    self.frame.cooldowns.title = self.frame.cooldowns:CreateFontString(nil, "OVERLAY")
    self.frame.cooldowns.title:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.cooldowns.title:SetPoint("TOPLEFT", self.frame.cooldowns, "TOPLEFT", 0, 0)
    self.frame.cooldowns.title:SetText("Raid Cooldowns:")
    
    -- Create strings for each cooldown
    self.frame.cooldowns.battleRes = self.frame.cooldowns:CreateFontString(nil, "OVERLAY")
    self.frame.cooldowns.battleRes:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.cooldowns.battleRes:SetPoint("TOPLEFT", self.frame.cooldowns.title, "BOTTOMLEFT", 0, -5)
    self.frame.cooldowns.battleRes:SetText("Battle Rez: Ready")
    
    self.frame.cooldowns.bloodlust = self.frame.cooldowns:CreateFontString(nil, "OVERLAY")
    self.frame.cooldowns.bloodlust:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.cooldowns.bloodlust:SetPoint("TOPLEFT", self.frame.cooldowns.battleRes, "BOTTOMLEFT", 0, -5)
    self.frame.cooldowns.bloodlust:SetText("Bloodlust: Ready")
    
    -- Add section for system info
    self.frame.system = CreateFrame("Frame", nil, self.frame)
    self.frame.system:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 10, 10)
    self.frame.system:SetSize(self.settings.general.width - 20, 30)
    
    -- Create system info strings
    self.frame.system.fps = self.frame.system:CreateFontString(nil, "OVERLAY")
    self.frame.system.fps:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.system.fps:SetPoint("BOTTOMLEFT", self.frame.system, "BOTTOMLEFT", 0, 15)
    self.frame.system.fps:SetText("FPS: 0")
    
    self.frame.system.latency = self.frame.system:CreateFontString(nil, "OVERLAY")
    self.frame.system.latency:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.system.latency:SetPoint("BOTTOMLEFT", self.frame.system.fps, "BOTTOMRIGHT", 10, 0)
    self.frame.system.latency:SetText("MS: 0")
    
    self.frame.system.gold = self.frame.system:CreateFontString(nil, "OVERLAY")
    self.frame.system.gold:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.system.gold:SetPoint("BOTTOMLEFT", self.frame.system, "BOTTOMLEFT", 0, 0)
    self.frame.system.gold:SetText("Gold: 0g 0s 0c")
    
    self.frame.system.durability = self.frame.system:CreateFontString(nil, "OVERLAY")
    self.frame.system.durability:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize, self.settings.general.fontOutline)
    self.frame.system.durability:SetPoint("BOTTOMLEFT", self.frame.system.gold, "BOTTOMRIGHT", 10, 0)
    self.frame.system.durability:SetText("Durability: 100%")
    
    -- Initialize data
    self:UpdateAllData()
    
    -- Setup visibility
    if self.enabled then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

function InfoFrame:CreatePlayerStatsFrame()
    -- Create a dedicated player stats frame
    self.statsFrame = CreateFrame("Frame", "VUIPlayerStatsFrame", UIParent)
    self.statsFrame:SetSize(180, 180)
    self.statsFrame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
    
    -- Make it movable
    self.statsFrame:SetMovable(true)
    self.statsFrame:EnableMouse(true)
    self.statsFrame:RegisterForDrag("LeftButton")
    self.statsFrame:SetScript("OnDragStart", function(frame)
        if not self.settings.statsFrame.locked then
            frame:StartMoving()
        end
    end)
    self.statsFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        -- Save position
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
        self.settings.statsFrame.position = {point, relativeTo:GetName(), relativePoint, xOffset, yOffset}
    end)
    
    -- Create transparent backdrop
    self.statsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    
    -- Set background color (transparent)
    self.statsFrame:SetBackdropColor(0, 0, 0, 0.4)
    
    -- Set border color (slightly visible)
    self.statsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
    
    -- Store frame reference for theme integration
    self.statsFrame.bg = self.statsFrame:CreateTexture(nil, "BACKGROUND")
    self.statsFrame.bg:SetAllPoints(self.statsFrame)
    self.statsFrame.borderFrame = self.statsFrame
    
    -- Create header
    self.statsFrame.header = self.statsFrame:CreateFontString(nil, "OVERLAY")
    self.statsFrame.header:SetFont(self.settings.general.fontFamily, self.settings.general.fontSize + 2, self.settings.general.fontOutline)
    self.statsFrame.header:SetPoint("TOPLEFT", self.statsFrame, "TOPLEFT", 10, -10)
    self.statsFrame.header:SetText("Player Stats")
    
    -- Create colored stat strings
    local statOffsetY = -30
    local statHeight = 16
    local fontSize = self.settings.general.fontSize
    local fontFamily = self.settings.general.fontFamily
    local fontOutline = self.settings.general.fontOutline
    
    -- Define stat colors
    local statColors = {
        crit = {r = 0.9, g = 0.3, b = 0.3},        -- Light Red
        haste = {r = 0.9, g = 0.9, b = 0.2},        -- Yellow
        mastery = {r = 0.2, g = 0.6, b = 0.9},      -- Light Blue
        versatility = {r = 0.2, g = 0.9, b = 0.2},  -- Green
        speed = {r = 0.7, g = 0.4, b = 0.9},        -- Light Purple
        leech = {r = 0.2, g = 0.9, b = 0.4},        -- Green
        avoidance = {r = 1.0, g = 1.0, b = 1.0}     -- White
    }
    
    -- Add colored stat strings
    self.playerStatStrings = {}
    
    local function CreatePlayerStatString(statName, displayName, color)
        self.playerStatStrings[statName] = self.statsFrame:CreateFontString(nil, "OVERLAY")
        self.playerStatStrings[statName]:SetFont(fontFamily, fontSize, fontOutline)
        self.playerStatStrings[statName]:SetPoint("TOPLEFT", self.statsFrame, "TOPLEFT", 10, statOffsetY)
        self.playerStatStrings[statName]:SetText(displayName .. ": 0%")
        self.playerStatStrings[statName]:SetTextColor(color.r, color.g, color.b)
        statOffsetY = statOffsetY - statHeight
    end
    
    CreatePlayerStatString("crit", "Crit", statColors.crit)
    CreatePlayerStatString("haste", "Haste", statColors.haste)
    CreatePlayerStatString("mastery", "Mastery", statColors.mastery)
    CreatePlayerStatString("versatility", "Versatility", statColors.versatility)
    CreatePlayerStatString("speed", "Speed", statColors.speed)
    CreatePlayerStatString("leech", "Leech", statColors.leech)
    CreatePlayerStatString("avoidance", "Avoidance", statColors.avoidance)
    
    -- Create cooldown trackers section
    statOffsetY = statOffsetY - 10  -- Add some spacing
    
    -- Bloodlust Cooldown Tracker
    self.statsFrame.bloodlustIcon = CreateFrame("Frame", nil, self.statsFrame)
    self.statsFrame.bloodlustIcon:SetSize(24, 24)
    self.statsFrame.bloodlustIcon:SetPoint("TOPLEFT", self.statsFrame, "TOPLEFT", 10, statOffsetY)
    
    self.statsFrame.bloodlustIcon.texture = self.statsFrame.bloodlustIcon:CreateTexture(nil, "OVERLAY")
    self.statsFrame.bloodlustIcon.texture:SetAllPoints()
    self.statsFrame.bloodlustIcon.texture:SetTexture(GetSpellTexture(2825)) -- Bloodlust spell texture
    
    self.statsFrame.bloodlustIcon.cooldown = CreateFrame("Cooldown", nil, self.statsFrame.bloodlustIcon, "CooldownFrameTemplate")
    self.statsFrame.bloodlustIcon.cooldown:SetAllPoints()
    self.statsFrame.bloodlustIcon.cooldown:SetDrawEdge(true)
    self.statsFrame.bloodlustIcon.cooldown:SetDrawSwipe(true)
    
    self.statsFrame.bloodlustText = self.statsFrame:CreateFontString(nil, "OVERLAY")
    self.statsFrame.bloodlustText:SetFont(fontFamily, fontSize - 1, fontOutline)
    self.statsFrame.bloodlustText:SetPoint("LEFT", self.statsFrame.bloodlustIcon, "RIGHT", 5, 0)
    self.statsFrame.bloodlustText:SetText("Bloodlust: Ready")
    self.statsFrame.bloodlustText:SetTextColor(0.2, 0.9, 0.2)
    
    -- Combat Rez Cooldown Tracker
    self.statsFrame.combatRezIcon = CreateFrame("Frame", nil, self.statsFrame)
    self.statsFrame.combatRezIcon:SetSize(24, 24)
    self.statsFrame.combatRezIcon:SetPoint("TOPLEFT", self.statsFrame.bloodlustIcon, "BOTTOMLEFT", 0, -5)
    
    self.statsFrame.combatRezIcon.texture = self.statsFrame.combatRezIcon:CreateTexture(nil, "OVERLAY")
    self.statsFrame.combatRezIcon.texture:SetAllPoints()
    self.statsFrame.combatRezIcon.texture:SetTexture(GetSpellTexture(20484)) -- Rebirth spell texture
    
    self.statsFrame.combatRezIcon.cooldown = CreateFrame("Cooldown", nil, self.statsFrame.combatRezIcon, "CooldownFrameTemplate")
    self.statsFrame.combatRezIcon.cooldown:SetAllPoints()
    self.statsFrame.combatRezIcon.cooldown:SetDrawEdge(true)
    self.statsFrame.combatRezIcon.cooldown:SetDrawSwipe(true)
    
    self.statsFrame.combatRezText = self.statsFrame:CreateFontString(nil, "OVERLAY")
    self.statsFrame.combatRezText:SetFont(fontFamily, fontSize - 1, fontOutline)
    self.statsFrame.combatRezText:SetPoint("LEFT", self.statsFrame.combatRezIcon, "RIGHT", 5, 0)
    self.statsFrame.combatRezText:SetText("Battle Rez: Ready")
    self.statsFrame.combatRezText:SetTextColor(0.2, 0.9, 0.2)
    
    -- Set frame visibility based on settings
    if self.settings.features.showPlayerStatsFrame then
        self.statsFrame:Show()
    else
        self.statsFrame:Hide()
    end
end

----------------------------------
-- Info Frame Data Updates
----------------------------------

function InfoFrame:UpdateAllData()
    -- Only update if the frame exists and the module is enabled
    if not self.frame or not self.enabled then return end
    
    -- Update spec information
    self:UpdateSpecData()
    
    -- Update stats information
    self:UpdateStatsData()
    
    -- Update raid cooldowns
    self:UpdateRaidCooldowns()
    
    -- Update system info
    self:UpdateSystemInfo()
end

function InfoFrame:UpdateSpecData()
    -- Only update if the frame exists and the feature is enabled
    if not self.frame or not self.settings.features.showSpecAndLootSpec then return end
    
    -- Get current specialization
    local specIndex = GetSpecialization()
    if specIndex then
        local specID, specName, _, specIcon = GetSpecializationInfo(specIndex)
        if specName then
            self.frame.spec:SetText("Spec: " .. specName)
        else
            self.frame.spec:SetText("Spec: Unknown")
        end
    else
        self.frame.spec:SetText("Spec: None")
    end
    
    -- Get loot specialization
    local lootSpecID = GetLootSpecialization()
    if lootSpecID and lootSpecID ~= 0 then
        local _, lootSpecName = GetSpecializationInfoByID(lootSpecID)
        if lootSpecName then
            self.frame.lootSpec:SetText("Loot Spec: " .. lootSpecName)
        else
            self.frame.lootSpec:SetText("Loot Spec: Unknown")
        end
    else
        -- If loot spec is set to current spec
        local specIndex = GetSpecialization()
        if specIndex then
            local _, specName = GetSpecializationInfo(specIndex)
            if specName then
                self.frame.lootSpec:SetText("Loot Spec: " .. specName .. " (Current)")
            else
                self.frame.lootSpec:SetText("Loot Spec: Current Spec")
            end
        else
            self.frame.lootSpec:SetText("Loot Spec: Current Spec")
        end
    end
    
    -- Update item level
    if self.settings.features.showItemLevel then
        local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
        if avgItemLevel and avgItemLevelEquipped then
            local displayLevel = math.floor(avgItemLevelEquipped * 10) / 10
            local levelColor = GetItemLevelColor(displayLevel)
            local coloredText = string.format("|cff%02x%02x%02xItem Level: %.1f|r", 
                levelColor.r * 255, 
                levelColor.g * 255, 
                levelColor.b * 255, 
                displayLevel)
            self.frame.itemLevel:SetText(coloredText)
        else
            self.frame.itemLevel:SetText("Item Level: Unknown")
        end
    else
        self.frame.itemLevel:SetText("")
    end
end

function InfoFrame:UpdateStatsData()
    -- Only update if the frame exists and the feature is enabled
    if not self.frame or not self.settings.features.showStats then 
        if self.frame and self.frame.stats then
            self.frame.stats:Hide()
        end
        return 
    end
    
    -- Show the stats frame
    self.frame.stats:Show()
    
    -- Update each stat based on settings
    for statName, enabled in pairs(self.settings.stats) do
        if enabled and self.statStrings[statName] then
            -- Get the stat value
            local value = self:GetStatValue(statName)
            local displayValue = ""
            
            if self.settings.features.statsFormat == "percentage" then
                displayValue = string.format("%.2f%%", value)
            else
                displayValue = string.format("%.0f", value)
            end
            
            -- Update the text
            local displayName = self:GetStatDisplayName(statName)
            self.statStrings[statName]:SetText(displayName .. ": " .. displayValue)
            self.statStrings[statName]:Show()
        elseif self.statStrings[statName] then
            self.statStrings[statName]:Hide()
        end
    end
    
    -- Update the player stats frame if it exists and is enabled
    self:UpdatePlayerStatsFrame()
end

function InfoFrame:UpdatePlayerStatsFrame()
    -- Only update if the frame exists and the feature is enabled
    if not self.statsFrame or not self.settings.features.showPlayerStatsFrame then
        if self.statsFrame then
            self.statsFrame:Hide()
        end
        return
    end
    
    -- Show the player stats frame
    self.statsFrame:Show()
    
    -- Update all stats
    local stats = {
        crit = {name = "Crit", value = GetCritChance()},
        haste = {name = "Haste", value = GetHaste()},
        mastery = {name = "Mastery", value = GetMastery()},
        versatility = {name = "Versatility", value = GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)},
        speed = {name = "Speed", value = GetUnitSpeed("player") / 7 * 100},
        leech = {name = "Leech", value = GetLifesteal()},
        avoidance = {name = "Avoidance", value = GetAvoidance()}
    }
    
    -- Update the stat strings
    for statName, statInfo in pairs(stats) do
        if self.playerStatStrings[statName] then
            local displayValue = string.format("%.2f%%", statInfo.value)
            self.playerStatStrings[statName]:SetText(statInfo.name .. ": " .. displayValue)
        end
    end
    
    -- Update bloodlust cooldown
    self:UpdateBloodlustCooldown()
    
    -- Update combat rez cooldown
    self:UpdateCombatRezCooldown()
end

function InfoFrame:UpdateBloodlustCooldown()
    if not self.statsFrame then return end
    
    local bloodlustDebuffName = "Exhaustion" -- Debuff after Bloodlust/Heroism
    local bloodlustDuration = 600 -- 10 minutes cooldown
    local name, _, _, _, _, expirationTime = UnitDebuff("player", bloodlustDebuffName)
    
    if name then
        local remainingTime = expirationTime - GetTime()
        if remainingTime > 0 then
            -- Update cooldown display
            self.statsFrame.bloodlustIcon.cooldown:SetCooldown(GetTime() - (bloodlustDuration - remainingTime), bloodlustDuration)
            
            -- Format time remaining (MM:SS)
            local minutes = math.floor(remainingTime / 60)
            local seconds = math.floor(remainingTime % 60)
            self.statsFrame.bloodlustText:SetText(string.format("Bloodlust: %d:%02d", minutes, seconds))
            self.statsFrame.bloodlustText:SetTextColor(0.9, 0.3, 0.3) -- Red for on cooldown
        else
            self.statsFrame.bloodlustIcon.cooldown:Clear()
            self.statsFrame.bloodlustText:SetText("Bloodlust: Ready")
            self.statsFrame.bloodlustText:SetTextColor(0.2, 0.9, 0.2) -- Green for ready
        end
    else
        self.statsFrame.bloodlustIcon.cooldown:Clear()
        self.statsFrame.bloodlustText:SetText("Bloodlust: Ready")
        self.statsFrame.bloodlustText:SetTextColor(0.2, 0.9, 0.2) -- Green for ready
    end
end

function InfoFrame:UpdateCombatRezCooldown()
    if not self.statsFrame then return end
    
    local combatRezCooldown = 0
    local maxCharges = 0
    
    -- Check for actual battle rez availability in raid/group
    if IsInRaid() or IsInGroup() then
        local charges, maxCharges, start, duration = GetSpellCharges(20484) -- Rebirth spell ID
        
        if charges and maxCharges then
            if charges < maxCharges then
                local timeToNextCharge = duration - (GetTime() - start)
                if timeToNextCharge > 0 then
                    -- Update cooldown display
                    self.statsFrame.combatRezIcon.cooldown:SetCooldown(start, duration)
                    
                    -- Format time remaining (MM:SS)
                    local minutes = math.floor(timeToNextCharge / 60)
                    local seconds = math.floor(timeToNextCharge % 60)
                    self.statsFrame.combatRezText:SetText(string.format("Battle Rez: %d:%02d (%d/%d)", minutes, seconds, charges, maxCharges))
                    self.statsFrame.combatRezText:SetTextColor(0.9, 0.7, 0.2) -- Yellow for partial charges
                end
            else
                self.statsFrame.combatRezIcon.cooldown:Clear()
                self.statsFrame.combatRezText:SetText(string.format("Battle Rez: Ready (%d/%d)", charges, maxCharges))
                self.statsFrame.combatRezText:SetTextColor(0.2, 0.9, 0.2) -- Green for ready
            end
        else
            self.statsFrame.combatRezIcon.cooldown:Clear()
            self.statsFrame.combatRezText:SetText("Battle Rez: N/A")
            self.statsFrame.combatRezText:SetTextColor(0.7, 0.7, 0.7) -- Gray for not applicable
        end
    else
        self.statsFrame.combatRezIcon.cooldown:Clear()
        self.statsFrame.combatRezText:SetText("Battle Rez: N/A")
        self.statsFrame.combatRezText:SetTextColor(0.7, 0.7, 0.7) -- Gray for not applicable
    end
end

function InfoFrame:GetStatValue(statName)
    -- Returns the value of the specified stat
    if statName == "crit" then
        return GetCritChance()
    elseif statName == "haste" then
        return GetHaste()
    elseif statName == "mastery" then
        return GetMastery()
    elseif statName == "versatility" then
        return GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    elseif statName == "leech" then
        return GetLifesteal()
    elseif statName == "avoidance" then
        return GetAvoidance()
    elseif statName == "movementSpeed" then
        return GetUnitSpeed("player") / 7 * 100
    end
    
    return 0
end

function InfoFrame:GetStatDisplayName(statName)
    -- Returns the display name for the specified stat
    local displayNames = {
        crit = "Critical Strike",
        haste = "Haste",
        mastery = "Mastery",
        versatility = "Versatility",
        leech = "Leech",
        avoidance = "Avoidance",
        movementSpeed = "Movement Speed"
    }
    
    return displayNames[statName] or statName
end

function InfoFrame:UpdateRaidCooldowns()
    -- Only update if the frame exists and the features are enabled
    if not self.frame or (not self.settings.features.showBattleRezCooldown and not self.settings.features.showBloodlustCooldown) then 
        if self.frame and self.frame.cooldowns then
            self.frame.cooldowns:Hide()
        end
        return 
    end
    
    -- Show the cooldowns frame
    self.frame.cooldowns:Show()
    
    -- Update battle rez cooldown
    if self.settings.features.showBattleRezCooldown then
        -- Check for battle rez cooldown
        local battleRezOnCooldown = false
        local battleRezRemaining = 0
        
        -- Check if we're in a raid or party that can use battle rez
        if IsInRaid() or IsInGroup() then
            -- Get the raid cooldown info
            local charges, _, started, duration = GetSpellCharges(20484) -- Rebirth spell ID
            
            if charges and started and duration then
                if charges < 1 then
                    battleRezOnCooldown = true
                    battleRezRemaining = duration - (GetTime() - started)
                end
            end
        end
        
        -- Update the text
        if battleRezOnCooldown then
            local minutes = math.floor(battleRezRemaining / 60)
            local seconds = math.floor(battleRezRemaining % 60)
            self.frame.cooldowns.battleRes:SetText(string.format("Battle Rez: %d:%02d", minutes, seconds))
            self.frame.cooldowns.battleRes:SetTextColor(1, 0.5, 0.5) -- Red
        else
            self.frame.cooldowns.battleRes:SetText("Battle Rez: Ready")
            self.frame.cooldowns.battleRes:SetTextColor(0.5, 1, 0.5) -- Green
        end
        
        self.frame.cooldowns.battleRes:Show()
    else
        self.frame.cooldowns.battleRes:Hide()
    end
    
    -- Update bloodlust cooldown
    if self.settings.features.showBloodlustCooldown then
        -- Check for bloodlust/heroism debuff (Sated/Exhaustion)
        local bloodlustDebuffFound = false
        local bloodlustRemaining = 0
        
        -- Look for debuffs that indicate bloodlust/heroism was used
        local exhaustionDebuffs = {
            57724, -- Sated (Bloodlust)
            57723, -- Exhaustion (Heroism)
            80354, -- Temporal Displacement (Time Warp)
            95809, -- Insanity (Ancient Hysteria)
        }
        
        for _, debuffID in ipairs(exhaustionDebuffs) do
            local name, _, _, _, duration, expirationTime = UnitDebuff("player", debuffID)
            
            if name and duration and expirationTime then
                bloodlustDebuffFound = true
                bloodlustRemaining = expirationTime - GetTime()
                break
            end
        end
        
        -- Update the text
        if bloodlustDebuffFound then
            local minutes = math.floor(bloodlustRemaining / 60)
            local seconds = math.floor(bloodlustRemaining % 60)
            self.frame.cooldowns.bloodlust:SetText(string.format("Bloodlust: %d:%02d", minutes, seconds))
            self.frame.cooldowns.bloodlust:SetTextColor(1, 0.5, 0.5) -- Red
        else
            self.frame.cooldowns.bloodlust:SetText("Bloodlust: Ready")
            self.frame.cooldowns.bloodlust:SetTextColor(0.5, 1, 0.5) -- Green
        end
        
        self.frame.cooldowns.bloodlust:Show()
    else
        self.frame.cooldowns.bloodlust:Hide()
    end
end

function InfoFrame:UpdateSystemInfo()
    -- Only update if the frame exists
    if not self.frame then return end
    
    -- Update FPS
    if self.settings.features.showFPS then
        local fps = GetFramerate()
        self.frame.system.fps:SetText(string.format("FPS: %d", math.floor(fps + 0.5)))
        
        -- Color based on FPS
        if fps < 15 then
            self.frame.system.fps:SetTextColor(1, 0, 0) -- Red
        elseif fps < 30 then
            self.frame.system.fps:SetTextColor(1, 1, 0) -- Yellow
        else
            self.frame.system.fps:SetTextColor(0, 1, 0) -- Green
        end
        
        self.frame.system.fps:Show()
    else
        self.frame.system.fps:Hide()
    end
    
    -- Update latency
    if self.settings.features.showLatency then
        local _, _, latencyHome, latencyWorld = GetNetStats()
        self.frame.system.latency:SetText(string.format("MS: %d", latencyWorld))
        
        -- Color based on latency
        if latencyWorld > 300 then
            self.frame.system.latency:SetTextColor(1, 0, 0) -- Red
        elseif latencyWorld > 100 then
            self.frame.system.latency:SetTextColor(1, 1, 0) -- Yellow
        else
            self.frame.system.latency:SetTextColor(0, 1, 0) -- Green
        end
        
        self.frame.system.latency:Show()
    else
        self.frame.system.latency:Hide()
    end
    
    -- Update gold
    if self.settings.features.showGold then
        local money = GetMoney()
        local gold = math.floor(money / 10000)
        local silver = math.floor((money % 10000) / 100)
        local copper = money % 100
        
        self.frame.system.gold:SetText(string.format("Gold: %dg %ds %dc", gold, silver, copper))
        self.frame.system.gold:Show()
    else
        self.frame.system.gold:Hide()
    end
    
    -- Update durability
    if self.settings.features.showDurability then
        local totalDurability = 0
        local totalItems = 0
        
        -- Check durability of all equipped items
        for i = 1, 18 do
            local current, maximum = GetInventoryItemDurability(i)
            if current and maximum and maximum > 0 then
                totalDurability = totalDurability + (current / maximum)
                totalItems = totalItems + 1
            end
        end
        
        if totalItems > 0 then
            local durabilityPercent = totalDurability / totalItems * 100
            self.frame.system.durability:SetText(string.format("Durability: %.0f%%", durabilityPercent))
            
            -- Color based on durability
            if durabilityPercent < 30 then
                self.frame.system.durability:SetTextColor(1, 0, 0) -- Red
            elseif durabilityPercent < 70 then
                self.frame.system.durability:SetTextColor(1, 1, 0) -- Yellow
            else
                self.frame.system.durability:SetTextColor(0, 1, 0) -- Green
            end
        else
            self.frame.system.durability:SetText("Durability: N/A")
        end
        
        self.frame.system.durability:Show()
    else
        self.frame.system.durability:Hide()
    end
end

----------------------------------
-- Enhanced Tooltips
----------------------------------

function InfoFrame:InitializeTooltips()
    -- Only proceed if enhanced tooltips are enabled
    if not self.settings.tooltips.enhanced then return end
    
    -- Hook into GameTooltip functions
    self:HookTooltips()
end

function InfoFrame:HookTooltips()
    -- Hook into the OnTooltipSetUnit event
    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        -- Only proceed if tooltips are enabled
        if not self.settings.tooltips.enhanced then return end
        
        -- Get the unit that the tooltip is showing
        local _, unit = tooltip:GetUnit()
        
        -- If we have a valid unit, add additional information
        if unit then
            -- Colorize name by class if enabled
            if self.settings.tooltips.classColors then
                self:ColorizeTooltipByClass(tooltip, unit)
            end
            
            -- Add targeting information if enabled
            if self.settings.tooltips.showTargeting then
                self:AddTargetingInfo(tooltip, unit)
            end
            
            -- Add mount information if enabled
            if self.settings.tooltips.showMountInfo then
                self:AddMountInfo(tooltip, unit)
            end
        end
    end)
    
    -- Hook into the OnTooltipSetItem event
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        -- Only proceed if tooltips are enabled
        if not self.settings.tooltips.enhanced then return end
        
        -- Get the item that the tooltip is showing
        local _, itemLink = tooltip:GetItem()
        
        -- If we have a valid item, add additional information
        if itemLink then
            -- Add item ID information if enabled
            if self.settings.tooltips.itemID then
                self:AddItemIDInfo(tooltip, itemLink)
            end
            
            -- Add item level information if enabled
            if self.settings.tooltips.itemLevel then
                self:AddItemLevelInfo(tooltip, itemLink)
            end
        end
    end)
    
    -- Hook into the OnTooltipSetSpell event
    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip)
        -- Only proceed if tooltips are enabled
        if not self.settings.tooltips.enhanced then return end
        
        -- Get the spell that the tooltip is showing
        local _, spellID = tooltip:GetSpell()
        
        -- If we have a valid spell, add additional information
        if spellID and self.settings.tooltips.spellID then
            self:AddSpellIDInfo(tooltip, spellID)
        end
    end)
end

function InfoFrame:ColorizeTooltipByClass(tooltip, unit)
    -- Get the unit's class
    local _, class = UnitClass(unit)
    
    -- If we have a class and it has a color, colorize the name line
    if class and CLASS_COLORS[class] then
        local color = CLASS_COLORS[class]
        tooltip:GetName():SetTextColor(color.r, color.g, color.b)
    end
end

function InfoFrame:AddTargetingInfo(tooltip, unit)
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
            relationship = "|cff00ff00Targeting |r" .. targetName
        else
            relationship = "|cffffffff" .. "Targeting " .. targetName .. "|r"
        end
        
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine(relationship)
    end
end

function InfoFrame:AddMountInfo(tooltip, unit)
    -- Check if the unit is mounted
    if IsMounted(unit) then
        -- Try to get the mount's name
        local mountName = "Unknown Mount"
        
        -- Look for mount buffs
        for i = 1, 40 do
            local name, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, i)
            
            -- If the buff is no longer found, break
            if not name then break end
            
            -- Check if this is a mount spell
            if spellID and C_MountJournal and C_MountJournal.GetMountFromSpell then
                local mountID = C_MountJournal.GetMountFromSpell(spellID)
                if mountID then
                    -- Get the mount name from the mount ID
                    local mountInfo = C_MountJournal.GetMountInfoByID(mountID)
                    if mountInfo then
                        mountName = mountInfo
                        break
                    end
                end
            end
        end
        
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ff00Mounted on: |r" .. mountName)
    end
end

function InfoFrame:AddItemIDInfo(tooltip, itemLink)
    -- Extract the item ID from the item link
    local itemID = itemLink:match("item:(%d+)")
    
    if itemID then
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ffffItem ID: |r" .. itemID)
    end
end

function InfoFrame:AddItemLevelInfo(tooltip, itemLink)
    -- Get the item level from the item link
    local itemLevel = GetDetailedItemLevelInfo(itemLink)
    
    if itemLevel then
        -- Add the information to the tooltip
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ffffItem Level: |r" .. itemLevel)
    end
end

function InfoFrame:AddSpellIDInfo(tooltip, spellID)
    -- Add the spell ID to the tooltip
    tooltip:AddLine(" ")
    tooltip:AddLine("|cff00ffffSpell ID: |r" .. spellID)
end

----------------------------------
-- Settings Management
----------------------------------

function InfoFrame:UpdateSettings()
    -- Only apply if the module is enabled
    if not self.enabled or not self.frame then return end
    
    -- Update frame properties
    self.frame:SetScale(self.settings.general.scale)
    self.frame:SetAlpha(self.settings.general.alpha)
    
    -- Apply theme if theme integration is available and not using class colors
    if not self.settings.general.classColored and self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        -- Let the theme integration handle the styling
        self.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
        return
    end
    
    -- Otherwise, use standard styling
    
    -- Update backdrop
    local bg = self.settings.general.backdropColor
    self.frame:SetBackdropColor(bg.r, bg.g, bg.b, bg.a)
    
    -- Update border
    if self.settings.general.showBorder then
        -- Set border color based on class if enabled
        if self.settings.general.classColored then
            local _, class = UnitClass("player")
            if class and CLASS_COLORS[class] then
                local color = CLASS_COLORS[class]
                self.frame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
            else
                local border = self.settings.general.borderColor
                self.frame:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
            end
        else
            local border = self.settings.general.borderColor
            self.frame:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
        end
    else
        -- Hide border
        self.frame:SetBackdropBorderColor(0, 0, 0, 0)
    end
    
    -- Update title visibility
    if self.settings.general.displayTitle then
        self.frame.header:Show()
    else
        self.frame.header:Hide()
    end
    
    -- Update feature visibility
    if self.settings.features.showSpecAndLootSpec then
        self.frame.spec:Show()
        self.frame.lootSpec:Show()
    else
        self.frame.spec:Hide()
        self.frame.lootSpec:Hide()
    end
    
    if self.settings.features.showItemLevel then
        self.frame.itemLevel:Show()
    else
        self.frame.itemLevel:Hide()
    end

    -- Update the player stats frame if it exists
    if self.statsFrame then
        -- Apply settings
        self.statsFrame:SetScale(self.settings.statsFrame.scale)
        self.statsFrame:SetAlpha(self.settings.statsFrame.alpha)
        self.statsFrame:SetFrameStrata(self.settings.statsFrame.strata)
        
        -- Show or hide the player stats frame based on settings
        if self.enabled and self.settings.features.showPlayerStatsFrame then
            self.statsFrame:Show()
        else
            self.statsFrame:Hide()
        end
    end
    
    -- Update data
    self:UpdateAllData()
    
    -- Update the timer
    self:StartUpdateTimer()
    
    -- Update tooltips
    self:UpdateTooltips()
end

function InfoFrame:UpdateLock()
    -- Update frame lock state
    if not self.frame then return end
    
    if self.settings.general.locked then
        self.frame:SetMovable(false)
        self.frame:EnableMouse(false)
    else
        self.frame:SetMovable(true)
        self.frame:EnableMouse(true)
    end
    
    -- Update player stats frame lock state
    if self.statsFrame then
        if self.settings.statsFrame.locked then
            self.statsFrame:SetMovable(false)
            self.statsFrame:EnableMouse(false)
        else
            self.statsFrame:SetMovable(true)
            self.statsFrame:EnableMouse(true)
        end
    end
end

function InfoFrame:UpdateTooltips()
    -- Initialize tooltips if they should be enhanced
    if self.settings.tooltips.enhanced then
        self:InitializeTooltips()
    end
end

-- Register with VUI for initialization
VUI.InfoFrame = InfoFrame