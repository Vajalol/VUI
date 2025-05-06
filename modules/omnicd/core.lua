-- VUI OmniCD Core Implementation
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local OmniCD = VUI.omnicd

-- Constants
local SPELL_COOLDOWN_TIME = {}  -- Table to track cooldown times for spells
local CLASS_SPELL_LIST = {}     -- Table to define which spells to track by class
local SPELL_PRIORITY = {}       -- Priority for spells (higher number = higher priority)

-- Module functionality
function OmniCD:SetupModule()
    -- Initialize the cooldown tracking frame
    self:CreateAnchor()
    self:SetupHooks()
    
    -- Initialize new systems
    self:InitializeCooldowns()
    self:UpdateAllUIWithTheme()
    
    -- Create frames to display cooldowns
    self:CreateCooldownDisplay()
end

-- Create the anchor/container frame
function OmniCD:CreateAnchor()
    -- Create main anchor
    self.anchor = CreateFrame("Frame", "VUIOmniCDAnchor", UIParent)
    self.anchor:SetSize(200, 30)
    self.anchor:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 150)
    self.anchor:EnableMouse(true)
    self.anchor:SetMovable(true)
    self.anchor:Hide()
    
    -- Add a backdrop to make it visible when moving
    self.anchor.bg = self.anchor:CreateTexture(nil, "BACKGROUND")
    self.anchor.bg:SetAllPoints()
    self.anchor.bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Add a title
    self.anchor.title = self.anchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.anchor.title:SetPoint("CENTER")
    self.anchor.title:SetText("OmniCD Anchor")
    
    -- Allow dragging
    self.anchor:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    self.anchor:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            VUI.db.profile.modules.omnicd.position = {point, relativePoint, xOfs, yOfs}
        end
    end)
end

-- Set up hooks to monitor cooldown usage
function OmniCD:SetupHooks()
    -- Create event frame
    self.eventFrame = CreateFrame("Frame")
    
    -- Register for combat log events
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    
    -- Event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            self:ProcessCombatLogEvent(CombatLogGetCurrentEventInfo())
        elseif event == "GROUP_ROSTER_UPDATE" then
            self:UpdateGroupMembers()
        elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            self:UpdateZoneType()
        end
    end)
end

-- Process combat log events to track cooldown usage
function OmniCD:ProcessCombatLogEvent(...)
    local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, _, _, _, spellID, spellName = ...
    
    -- Only track group members
    if not UnitInParty(sourceName) and not UnitInRaid(sourceName) then
        return
    end
    
    -- Get the class of the unit
    local _, class = GetPlayerInfoByGUID(sourceGUID)
    if not class then return end
    
    -- Check if the spell is one we want to track
    if self:ShouldTrackSpell(spellID, class) then
        if eventType == "SPELL_CAST_SUCCESS" then
            -- Start cooldown tracking
            self:StartCooldown(sourceGUID, sourceName, class, spellID, spellName)
        end
    end
end

-- Check if a spell should be tracked
function OmniCD:ShouldTrackSpell(spellID, class)
    -- First check if it's in our class spell list
    if not CLASS_SPELL_LIST[class] or not tContains(CLASS_SPELL_LIST[class], spellID) then
        return false
    end
    
    -- Check if it's filtered by user settings
    if self.db.spellFilters[spellID] == false then
        return false
    end
    
    return true
end

-- Start tracking a cooldown
function OmniCD:StartCooldown(unitGUID, unitName, class, spellID, spellName)
    -- Get the cooldown duration for this spell
    local duration = SPELL_COOLDOWN_TIME[spellID] or 0
    
    if duration <= 0 then
        -- Try to get the cooldown from spell data
        local start, cooldownTime = GetSpellCooldown(spellID)
        if cooldownTime and cooldownTime > 0 then
            duration = cooldownTime
        end
    end
    
    -- Bail if we couldn't determine cooldown
    if duration <= 0 then return end
    
    -- Add to active cooldowns
    local cooldownInfo = {
        guid = unitGUID,
        name = unitName,
        class = class,
        spellID = spellID,
        spellName = spellName,
        startTime = GetTime(),
        duration = duration,
        endTime = GetTime() + duration,
        priority = SPELL_PRIORITY[spellID] or 0
    }
    
    -- Store in our active cooldowns
    if not self.activeCooldowns then self.activeCooldowns = {} end
    if not self.activeCooldowns[unitGUID] then self.activeCooldowns[unitGUID] = {} end
    
    -- See if we're already tracking this spell for this unit
    for i, cd in ipairs(self.activeCooldowns[unitGUID]) do
        if cd.spellID == spellID then
            -- Update existing entry
            self.activeCooldowns[unitGUID][i] = cooldownInfo
            self:UpdateCooldownDisplay()
            return
        end
    end
    
    -- Add new cooldown
    table.insert(self.activeCooldowns[unitGUID], cooldownInfo)
    
    -- Sort cooldowns by priority
    table.sort(self.activeCooldowns[unitGUID], function(a, b)
        return a.priority > b.priority
    end)
    
    -- Update the display
    self:UpdateCooldownDisplay()
    
    -- Start tracking if we're not already
    self:StartTrackingTick()
end

-- Start the timer to update cooldowns
function OmniCD:StartTrackingTick()
    if not self.ticker then
        self.ticker = C_Timer.NewTicker(0.5, function()
            self:UpdateCooldowns()
        end)
    end
end

-- Update cooldowns (check for expired ones)
function OmniCD:UpdateCooldowns()
    local now = GetTime()
    local updated = false
    
    -- Check all active cooldowns
    for guid, cooldowns in pairs(self.activeCooldowns or {}) do
        for i = #cooldowns, 1, -1 do
            if cooldowns[i].endTime <= now then
                -- Remove expired cooldown
                table.remove(cooldowns, i)
                updated = true
            end
        end
        
        -- If no more cooldowns for this unit, remove the entry
        if #cooldowns == 0 then
            self.activeCooldowns[guid] = nil
        end
    end
    
    -- If we removed any cooldowns, update the display
    if updated then
        self:UpdateCooldownDisplay()
    end
    
    -- If no more active cooldowns, stop tracking
    if not next(self.activeCooldowns) then
        if self.ticker then
            self.ticker:Cancel()
            self.ticker = nil
        end
    end
end

-- Create the cooldown display
function OmniCD:CreateCooldownDisplay()
    -- Main container
    self.container = CreateFrame("Frame", "VUIOmniCDContainer", UIParent)
    
    -- Position from saved variable
    local position = self.db.position or {"TOPLEFT", "CENTER", 0, 150}
    self.container:SetSize(200, 30)
    self.container:SetPoint(position[1], UIParent, position[2], position[3], position[4])
    
    -- Add a slight background
    self.container.bg = self.container:CreateTexture(nil, "BACKGROUND")
    self.container.bg:SetAllPoints()
    self.container.bg:SetColorTexture(0, 0, 0, 0.1)
    
    -- Container for icon frames
    self.iconFrames = {}
    
    -- Position container based on grow direction
    self:SetContainerLayout()
    
    -- Initially hidden until we have cooldowns to show
    self.container:Hide()
end

-- Set the container layout and size
function OmniCD:SetContainerLayout()
    local growDirection = self.db.growDirection or "RIGHT"
    local iconSize = self.db.iconSize or 30
    local iconSpacing = self.db.iconSpacing or 2
    local numIcons = self.db.maxIcons or 10
    
    -- Resize container based on grow direction
    if growDirection == "RIGHT" or growDirection == "LEFT" then
        -- Horizontal layout
        self.container:SetSize((iconSize + iconSpacing) * numIcons, iconSize)
    else
        -- Vertical layout
        self.container:SetSize(iconSize, (iconSize + iconSpacing) * numIcons)
    end
    
    -- Set anchors for all icon frames
    for i = 1, numIcons do
        if not self.iconFrames[i] then
            -- Create icon frame if it doesn't exist
            self:CreateIconFrame(i)
        end
        
        -- Position based on grow direction
        self:PositionIconFrame(self.iconFrames[i], i)
    end
end

-- Create an individual icon frame
function OmniCD:CreateIconFrame(index)
    local iconSize = self.db.iconSize or 30
    
    -- Create frame
    local frame = CreateFrame("Frame", "VUIOmniCDIcon"..index, self.container)
    frame:SetSize(iconSize, iconSize)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the borders
    
    -- Cooldown overlay
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetReverse(false)
    frame.cooldown:SetHideCountdownNumbers(true)
    
    -- Get cached textures from atlas system
    local borderTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\border.tga")
    local iconFrameTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\icon-frame.tga")
    local cooldownSwipeTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\cooldown-swipe.tga")
    local readyPulseTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\ready-pulse.tga")
    local highlightTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\omnicd\\highlight.tga")
    
    -- Border (using atlas texture)
    frame.border = frame:CreateTexture(nil, "OVERLAY")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    
    -- Apply the atlas texture and coordinates if available
    if borderTexture and borderTexture.isAtlas then
        frame.border:SetTexture(borderTexture.path)
        frame.border:SetTexCoord(
            borderTexture.coords.left,
            borderTexture.coords.right,
            borderTexture.coords.top,
            borderTexture.coords.bottom
        )
    else
        -- Fallback to original texture if atlas is not available
        frame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
        frame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    end
    
    -- Icon frame overlay (new from atlas)
    frame.iconFrame = frame:CreateTexture(nil, "OVERLAY", nil, 1)
    frame.iconFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    frame.iconFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
    
    if iconFrameTexture and iconFrameTexture.isAtlas then
        frame.iconFrame:SetTexture(iconFrameTexture.path)
        frame.iconFrame:SetTexCoord(
            iconFrameTexture.coords.left,
            iconFrameTexture.coords.right,
            iconFrameTexture.coords.top,
            iconFrameTexture.coords.bottom
        )
    end
    
    -- Cooldown swipe (custom for better theme integration)
    frame.cooldownSwipe = frame:CreateTexture(nil, "OVERLAY", nil, 2)
    frame.cooldownSwipe:SetAllPoints(frame)
    frame.cooldownSwipe:SetAlpha(0) -- Hidden by default, shown during animation
    
    if cooldownSwipeTexture and cooldownSwipeTexture.isAtlas then
        frame.cooldownSwipe:SetTexture(cooldownSwipeTexture.path)
        frame.cooldownSwipe:SetTexCoord(
            cooldownSwipeTexture.coords.left,
            cooldownSwipeTexture.coords.right,
            cooldownSwipeTexture.coords.top,
            cooldownSwipeTexture.coords.bottom
        )
    end
    
    -- Ready pulse effect
    frame.readyPulse = frame:CreateTexture(nil, "OVERLAY", nil, 3)
    frame.readyPulse:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
    frame.readyPulse:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
    frame.readyPulse:SetAlpha(0) -- Hidden until ready
    
    if readyPulseTexture and readyPulseTexture.isAtlas then
        frame.readyPulse:SetTexture(readyPulseTexture.path)
        frame.readyPulse:SetTexCoord(
            readyPulseTexture.coords.left,
            readyPulseTexture.coords.right,
            readyPulseTexture.coords.top,
            readyPulseTexture.coords.bottom
        )
    end
    
    -- Highlight effect
    frame.highlight = frame:CreateTexture(nil, "OVERLAY", nil, 4)
    frame.highlight:SetAllPoints(frame)
    frame.highlight:SetAlpha(0) -- Hidden by default
    
    if highlightTexture and highlightTexture.isAtlas then
        frame.highlight:SetTexture(highlightTexture.path)
        frame.highlight:SetTexCoord(
            highlightTexture.coords.left,
            highlightTexture.coords.right,
            highlightTexture.coords.top,
            highlightTexture.coords.bottom
        )
    end
    
    -- Timer text
    frame.timer = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.timer:SetPoint("BOTTOM", frame, "BOTTOM", 0, -2)
    
    -- Spell count text (for charges)
    frame.count = frame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    frame.count:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    
    -- Player name
    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.name:SetPoint("TOP", frame, "TOP", 0, 12)
    
    -- Store in our frames table
    self.iconFrames[index] = frame
    frame:Hide()
    
    return frame
end

-- Position an icon frame based on index and grow direction
function OmniCD:PositionIconFrame(frame, index)
    local growDirection = self.db.growDirection or "RIGHT"
    local iconSize = self.db.iconSize or 30
    local iconSpacing = self.db.iconSpacing or 2
    
    frame:ClearAllPoints()
    
    if index == 1 then
        -- First icon is always at the container's anchor point
        if growDirection == "RIGHT" then
            frame:SetPoint("LEFT", self.container, "LEFT", 0, 0)
        elseif growDirection == "LEFT" then
            frame:SetPoint("RIGHT", self.container, "RIGHT", 0, 0)
        elseif growDirection == "UP" then
            frame:SetPoint("BOTTOM", self.container, "BOTTOM", 0, 0)
        else -- DOWN
            frame:SetPoint("TOP", self.container, "TOP", 0, 0)
        end
    else
        -- Position relative to previous icon
        local prevFrame = self.iconFrames[index-1]
        
        if growDirection == "RIGHT" then
            frame:SetPoint("LEFT", prevFrame, "RIGHT", iconSpacing, 0)
        elseif growDirection == "LEFT" then
            frame:SetPoint("RIGHT", prevFrame, "LEFT", -iconSpacing, 0)
        elseif growDirection == "UP" then
            frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, iconSpacing)
        else -- DOWN
            frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -iconSpacing)
        end
    end
end

-- Update the cooldown display
function OmniCD:UpdateCooldownDisplay()
    -- Check if we have any cooldowns to display
    if not self.activeCooldowns or not next(self.activeCooldowns) then
        -- Hide container if no cooldowns
        self.container:Hide()
        return
    end
    
    -- Show container
    self.container:Show()
    
    -- Flatten the cooldowns into a single list
    local cooldownList = {}
    for _, unitCooldowns in pairs(self.activeCooldowns) do
        for _, cd in ipairs(unitCooldowns) do
            table.insert(cooldownList, cd)
        end
    end
    
    -- Sort by most important first (highest priority)
    table.sort(cooldownList, function(a, b)
        return a.priority > b.priority
    end)
    
    -- Update the icon frames
    for i = 1, #self.iconFrames do
        local frame = self.iconFrames[i]
        local cd = cooldownList[i]
        
        if cd then
            -- Update frame with cooldown info
            local _, _, texture = GetSpellInfo(cd.spellID)
            
            -- Set border color based on class
            local classColor = RAID_CLASS_COLORS[cd.class]
            if classColor then
                frame.border:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
            else
                frame.border:SetVertexColor(1, 1, 1, 1)
            end
            
            -- Set spell icon
            frame.icon:SetTexture(texture)
            
            -- Set cooldown
            local remaining = cd.endTime - GetTime()
            if remaining > 0 then
                -- Format time text
                local timeText
                if remaining > 60 then
                    timeText = math.floor(remaining / 60) .. "m"
                else
                    timeText = math.floor(remaining + 0.5) .. "s"
                end
                
                frame.timer:SetText(timeText)
                
                -- Start cooldown animation if not already running
                if cd.startTime and cd.duration then
                    frame.cooldown:SetCooldown(cd.startTime, cd.duration)
                end
            else
                frame.timer:SetText("")
                frame.cooldown:Clear()
            end
            
            -- Show unit name if enabled
            if self.db.showNames then
                frame.name:SetText(cd.name)
                frame.name:Show()
            else
                frame.name:Hide()
            end
            
            frame:Show()
        else
            -- No cooldown for this index, hide the frame
            frame:Hide()
        end
    end
end

-- Update when group members change
function OmniCD:UpdateGroupMembers()
    -- Reset our cooldown tracking when group members change
    if self.activeCooldowns then
        -- Clear cooldowns for group members who left
        for guid in pairs(self.activeCooldowns) do
            local found = false
            
            -- Check if the player is still in the group
            if IsInRaid() then
                for i = 1, GetNumGroupMembers() do
                    if UnitGUID("raid" .. i) == guid then
                        found = true
                        break
                    end
                end
            else
                for i = 1, GetNumGroupMembers() do
                    if UnitGUID("party" .. i) == guid then
                        found = true
                        break
                    end
                end
            end
            
            if not found and guid ~= UnitGUID("player") then
                -- Player left the group, remove their cooldowns
                self.activeCooldowns[guid] = nil
            end
        end
        
        -- Update the display
        self:UpdateCooldownDisplay()
    end
end

-- Update settings based on zone type
function OmniCD:UpdateZoneType()
    -- Get the current zone type
    local inInstance, instanceType = IsInInstance()
    
    if inInstance then
        if instanceType == "arena" then
            self.zoneType = "ARENA"
        elseif instanceType == "raid" then
            self.zoneType = "RAID"
        elseif instanceType == "party" then
            self.zoneType = "DUNGEON"
        elseif instanceType == "pvp" then
            self.zoneType = "BATTLEGROUND"
        else
            self.zoneType = "INSTANCE"
        end
    else
        if C_PvP.IsWarModeActive() then
            self.zoneType = "OUTDOOR_PVP"
        else
            self.zoneType = "OUTDOOR"
        end
    end
    
    -- Update display based on zone
    if self.db.zoneSettings and self.db.zoneSettings[self.zoneType] then
        local settings = self.db.zoneSettings[self.zoneType]
        
        -- Apply zone-specific settings
        if settings.enabled ~= nil then
            if settings.enabled then
                self.container:Show()
            else
                self.container:Hide()
            end
        end
    end
end

-- Define class spells to track
function OmniCD:DefineClassSpells()
    -- Key defensive and offensive cooldowns by class
    CLASS_SPELL_LIST = {
        WARRIOR = {871, 12975, 97462, 107574, 1719, 46924},     -- Wall, Last Stand, Rally, Skull banner, Reck, Bladestorm
        PALADIN = {31850, 86659, 31884, 96231, 105809, 633},    -- AD, Guardian, Avenging Wrath, Seals, Holy Avenger, Lay on Hands
        HUNTER = {19263, 109304, 131894, 3045, 34477, 53209},   -- Deterrence, Exhil, Murder of Crows, Rapid Fire, Misdirect, Chimera
        ROGUE = {31224, 5277, 1856, 114018, 13750, 79140},      -- Cloak, Evasion, Vanish, Shroud, Adrenaline, Vendetta
        PRIEST = {33206, 62618, 47788, 47536, 109964, 47536},   -- Pain Supp, Barrier, Guard Spirit, Rapture, Spirit Shell, Rapture
        DEATHKNIGHT = {48792, 49028, 55233, 49016, 51052, 49222}, -- IBF, DC, VB, Unholy Frenzy, AMZ, Bone shield
        SHAMAN = {108271, 30823, 98008, 16188, 16166, 114050},  -- Astral Shift, Shamanistic Rage, Spirit link totem, Natures Swiftness, Ele mast, Ascendance
        MAGE = {45438, 110960, 113724, 12042, 12051, 11958},    -- Ice Block, Greater Invis, Ring of Frost, Arcane Power, Evocation, Cold Snap
        WARLOCK = {104773, 108416, 110913, 113860, 113858, 113861}, -- Unending Res, Dark Pact, Dark Bargain, Dark Soul: Misery, Dark Soul: Instability, Dark Soul: Knowledge
        MONK = {115203, 115176, 115310, 116680, 116844, 137562}, -- Fort Brew, Zen Med, Revival, Thunder Focus Tea, RoH, Nimble Brew
        DRUID = {61336, 22812, 22842, 740, 106951, 106952},    -- Survival Instincts, Barkskin, Frenzied Regen, Tranq, Berserk, Berserk
        DEMONHUNTER = {198589, 196555, 187827, 196718, 198013, 191427}, -- Blur, Netherwalk, Metamorphosis, Darkness, Eye Beam, Metamorphosis
        EVOKER = {363916, 374348, 370960, 359816, 370553, 375087} -- Obsidian Scale, Rescue, Stasis, Dream Flight, Tip the Scales, Dragonrage
    }
    
    -- Cooldown durations
    SPELL_COOLDOWN_TIME = {
        -- Warrior
        [871] = 180,      -- Shield Wall
        [12975] = 180,    -- Last Stand
        [97462] = 180,    -- Rallying Cry
        [107574] = 90,    -- Skull Banner
        [1719] = 90,      -- Recklessness
        [46924] = 90,     -- Bladestorm
        
        -- Paladin
        [31850] = 180,    -- Ardent Defender
        [86659] = 300,    -- Guardian of Ancient Kings
        [31884] = 180,    -- Avenging Wrath
        [96231] = 15,     -- Rebuke
        [105809] = 180,   -- Holy Avenger
        [633] = 600,      -- Lay on Hands
        
        -- Hunter
        [19263] = 180,    -- Deterrence
        [109304] = 120,   -- Exhilaration
        [131894] = 120,   -- A Murder of Crows
        [3045] = 180,     -- Rapid Fire
        [34477] = 30,     -- Misdirection
        [53209] = 60,     -- Chimera Shot
        
        -- Rogue
        [31224] = 90,     -- Cloak of Shadows
        [5277] = 180,     -- Evasion
        [1856] = 180,     -- Vanish
        [114018] = 360,   -- Shroud of Concealment
        [13750] = 180,    -- Adrenaline Rush
        [79140] = 120,    -- Vendetta
        
        -- Priest
        [33206] = 180,    -- Pain Suppression
        [62618] = 180,    -- Power Word: Barrier
        [47788] = 180,    -- Guardian Spirit
        [47536] = 90,     -- Rapture
        [109964] = 60,    -- Spirit Shell
        
        -- Death Knight
        [48792] = 180,    -- Icebound Fortitude
        [49028] = 120,    -- Dancing Rune Weapon
        [55233] = 60,     -- Vampiric Blood
        [49016] = 180,    -- Unholy Frenzy
        [51052] = 120,    -- Anti-Magic Zone
        [49222] = 60,     -- Bone Shield
        
        -- Shaman
        [108271] = 120,   -- Astral Shift
        [30823] = 60,     -- Shamanistic Rage
        [98008] = 180,    -- Spirit Link Totem
        [16188] = 120,    -- Nature's Swiftness
        [16166] = 120,    -- Elemental Mastery
        [114050] = 180,   -- Ascendance
        
        -- Mage
        [45438] = 300,    -- Ice Block
        [110960] = 90,    -- Greater Invisibility
        [113724] = 30,    -- Ring of Frost
        [12042] = 90,     -- Arcane Power
        [12051] = 90,     -- Evocation
        [11958] = 180,    -- Cold Snap
        
        -- Warlock
        [104773] = 180,   -- Unending Resolve
        [108416] = 60,    -- Dark Pact
        [110913] = 180,   -- Dark Bargain
        [113860] = 120,   -- Dark Soul: Misery
        [113858] = 120,   -- Dark Soul: Instability
        [113861] = 120,   -- Dark Soul: Knowledge
        
        -- Monk
        [115203] = 180,   -- Fortifying Brew
        [115176] = 180,   -- Zen Meditation
        [115310] = 180,   -- Revival
        [116680] = 30,    -- Thunder Focus Tea
        [116844] = 45,    -- Ring of Harmony
        [137562] = 120,   -- Nimble Brew
        
        -- Druid
        [61336] = 180,    -- Survival Instincts
        [22812] = 60,     -- Barkskin
        [22842] = 36,     -- Frenzied Regeneration
        [740] = 480,      -- Tranquility
        [106951] = 180,   -- Berserk (Cat)
        [106952] = 180,   -- Berserk (Bear)
        
        -- Demon Hunter
        [198589] = 60,    -- Blur
        [196555] = 120,   -- Netherwalk
        [187827] = 180,   -- Metamorphosis (Vengeance)
        [196718] = 300,   -- Darkness
        [198013] = 40,    -- Eye Beam
        [191427] = 240,   -- Metamorphosis (Havoc)
        
        -- Evoker
        [363916] = 90,    -- Obsidian Scale
        [374348] = 90,    -- Rescue
        [370960] = 60,    -- Stasis
        [359816] = 120,   -- Dream Flight
        [370553] = 60,    -- Tip the Scales
        [375087] = 120    -- Dragonrage
    }
    
    -- Spell priorities (higher number = higher priority)
    SPELL_PRIORITY = {
        -- Warrior
        [871] = 80,       -- Shield Wall
        [12975] = 75,     -- Last Stand
        [97462] = 70,     -- Rallying Cry
        [107574] = 50,    -- Skull Banner
        [1719] = 40,      -- Recklessness
        [46924] = 30,     -- Bladestorm
        
        -- Paladin
        [31850] = 80,     -- Ardent Defender
        [86659] = 90,     -- Guardian of Ancient Kings
        [31884] = 50,     -- Avenging Wrath
        [96231] = 10,     -- Rebuke
        [105809] = 40,    -- Holy Avenger
        [633] = 100,      -- Lay on Hands
        
        -- Hunter
        [19263] = 80,     -- Deterrence
        [109304] = 75,    -- Exhilaration
        [131894] = 40,    -- A Murder of Crows
        [3045] = 50,      -- Rapid Fire
        [34477] = 20,     -- Misdirection
        [53209] = 30,     -- Chimera Shot
        
        -- Rogue
        [31224] = 85,     -- Cloak of Shadows
        [5277] = 80,      -- Evasion
        [1856] = 60,      -- Vanish
        [114018] = 40,    -- Shroud of Concealment
        [13750] = 50,     -- Adrenaline Rush
        [79140] = 45,     -- Vendetta
        
        -- Priest
        [33206] = 90,     -- Pain Suppression
        [62618] = 85,     -- Power Word: Barrier
        [47788] = 95,     -- Guardian Spirit
        [47536] = 40,     -- Rapture
        [109964] = 50,    -- Spirit Shell
        
        -- Death Knight
        [48792] = 80,     -- Icebound Fortitude
        [49028] = 70,     -- Dancing Rune Weapon
        [55233] = 75,     -- Vampiric Blood
        [49016] = 40,     -- Unholy Frenzy
        [51052] = 85,     -- Anti-Magic Zone
        [49222] = 60,     -- Bone Shield
        
        -- Shaman
        [108271] = 80,    -- Astral Shift
        [30823] = 75,     -- Shamanistic Rage
        [98008] = 90,     -- Spirit Link Totem
        [16188] = 60,     -- Nature's Swiftness
        [16166] = 50,     -- Elemental Mastery
        [114050] = 55,    -- Ascendance
        
        -- Mage
        [45438] = 90,     -- Ice Block
        [110960] = 75,    -- Greater Invisibility
        [113724] = 30,    -- Ring of Frost
        [12042] = 50,     -- Arcane Power
        [12051] = 40,     -- Evocation
        [11958] = 60,     -- Cold Snap
        
        -- Warlock
        [104773] = 85,    -- Unending Resolve
        [108416] = 75,    -- Dark Pact
        [110913] = 80,    -- Dark Bargain
        [113860] = 50,    -- Dark Soul: Misery
        [113858] = 50,    -- Dark Soul: Instability
        [113861] = 50,    -- Dark Soul: Knowledge
        
        -- Monk
        [115203] = 80,    -- Fortifying Brew
        [115176] = 75,    -- Zen Meditation
        [115310] = 100,   -- Revival
        [116680] = 40,    -- Thunder Focus Tea
        [116844] = 45,    -- Ring of Harmony
        [137562] = 55,    -- Nimble Brew
        
        -- Druid
        [61336] = 80,     -- Survival Instincts
        [22812] = 70,     -- Barkskin
        [22842] = 60,     -- Frenzied Regeneration
        [740] = 95,       -- Tranquility
        [106951] = 50,    -- Berserk (Cat)
        [106952] = 50,    -- Berserk (Bear)
        
        -- Demon Hunter
        [198589] = 70,    -- Blur
        [196555] = 75,    -- Netherwalk
        [187827] = 80,    -- Metamorphosis (Vengeance)
        [196718] = 90,    -- Darkness
        [198013] = 40,    -- Eye Beam
        [191427] = 45,    -- Metamorphosis (Havoc)
        
        -- Evoker
        [363916] = 75,    -- Obsidian Scale
        [374348] = 60,    -- Rescue
        [370960] = 70,    -- Stasis
        [359816] = 65,    -- Dream Flight
        [370553] = 30,    -- Tip the Scales
        [375087] = 50     -- Dragonrage
    }
end

-- Initialize cooldown data
function OmniCD:InitializeCooldowns()
    -- Define cooldown times for spells
    SPELL_COOLDOWN_TIME = {
        -- Death Knight
        [48707] = 60,     -- Anti-Magic Shell
        [48792] = 180,    -- Icebound Fortitude
        [51052] = 120,    -- Anti-Magic Zone
        [49206] = 180,    -- Summon Gargoyle
        [49028] = 120,    -- Dancing Rune Weapon
        
        -- Demon Hunter
        [198589] = 60,    -- Blur
        [196718] = 300,   -- Darkness
        [196555] = 120,   -- Netherwalk
        [191427] = 240,   -- Metamorphosis (Havoc)
        [187827] = 180,   -- Metamorphosis (Vengeance)
        [198013] = 40,    -- Eye Beam
        
        -- Druid
        [61336] = 180,    -- Survival Instincts
        [22812] = 60,     -- Barkskin
        [102342] = 90,    -- Ironbark
        [29166] = 180,    -- Innervate
        [740] = 180,      -- Tranquility
        
        -- Hunter
        [186265] = 180,   -- Aspect of the Turtle
        [193530] = 120,   -- Aspect of the Wild
        [19574] = 90,     -- Bestial Wrath
        [288613] = 180,   -- Trueshot
        
        -- Mage
        [45438] = 240,    -- Ice Block
        [12472] = 180,    -- Icy Veins
        [190319] = 120,   -- Combustion
        [12042] = 90,     -- Arcane Power
        
        -- Monk
        [115203] = 420,   -- Fortifying Brew
        [122278] = 120,   -- Dampen Harm
        [116705] = 15,    -- Spear Hand Strike
        [115310] = 180,   -- Revival
        
        -- Paladin
        [642] = 300,      -- Divine Shield
        [86659] = 300,    -- Guardian of Ancient Kings
        [31850] = 120,    -- Ardent Defender
        [1022] = 300,     -- Blessing of Protection
        [31821] = 180,    -- Aura Mastery
        [31884] = 120,    -- Avenging Wrath
        
        -- Priest
        [19236] = 90,     -- Desperate Prayer
        [47585] = 120,    -- Dispersion
        [33206] = 180,    -- Pain Suppression
        [62618] = 180,    -- Power Word: Barrier
        [47788] = 180,    -- Guardian Spirit
        [64843] = 180,    -- Divine Hymn
        
        -- Rogue
        [5277] = 120,     -- Evasion
        [31224] = 120,    -- Cloak of Shadows
        [2094] = 120,     -- Blind
        [13750] = 180,    -- Adrenaline Rush
        [51690] = 120,    -- Killing Spree
        
        -- Shaman
        [108271] = 90,    -- Astral Shift
        [98008] = 180,    -- Spirit Link Totem
        [198067] = 150,   -- Fire Elemental
        [51533] = 120,    -- Feral Spirit
        [114050] = 180,   -- Ascendance (Elemental)
        
        -- Warlock
        [104773] = 180,   -- Unending Resolve
        [1122] = 180,     -- Summon Infernal
        [205180] = 180,   -- Summon Darkglare
        [265187] = 90,    -- Summon Demonic Tyrant
        
        -- Warrior
        [871] = 240,      -- Shield Wall
        [12975] = 180,    -- Last Stand
        [97462] = 180,    -- Rallying Cry
        [1719] = 90,      -- Recklessness
        [107574] = 90,    -- Avatar
        
        -- Evoker
        [363916] = 120,   -- Obsidian Scale
        [370960] = 90,    -- Stasis
        [359816] = 120,   -- Dream Flight
        [370553] = 60,    -- Tip the Scales
        [375087] = 120    -- Dragonrage
    }
    
    -- Define which spells to track for each class
    CLASS_SPELL_LIST = {
        -- Death Knight
        ["DEATHKNIGHT"] = {
            48707,  -- Anti-Magic Shell
            48792,  -- Icebound Fortitude
            51052,  -- Anti-Magic Zone
            49028,  -- Dancing Rune Weapon
            47568,  -- Empower Rune Weapon
            49206   -- Summon Gargoyle
        },
        
        -- Demon Hunter
        ["DEMONHUNTER"] = {
            198589, -- Blur
            196718, -- Darkness
            196555, -- Netherwalk
            187827, -- Metamorphosis (Vengeance)
            198013, -- Eye Beam
            191427  -- Metamorphosis (Havoc)
        },
        
        -- Druid
        ["DRUID"] = {
            61336,  -- Survival Instincts
            22812,  -- Barkskin
            102342, -- Ironbark
            29166,  -- Innervate
            740,    -- Tranquility
            194223, -- Celestial Alignment
            102560, -- Incarnation: Chosen of Elune
            106951, -- Berserk
            50334   -- Berserk (Guardian)
        },
        
        -- Hunter
        ["HUNTER"] = {
            186265, -- Aspect of the Turtle
            193530, -- Aspect of the Wild
            19574,  -- Bestial Wrath
            288613, -- Trueshot
            266779  -- Coordinated Assault
        },
        
        -- Mage
        ["MAGE"] = {
            45438,  -- Ice Block
            12472,  -- Icy Veins
            190319, -- Combustion
            12042   -- Arcane Power
        },
        
        -- Monk
        ["MONK"] = {
            115203, -- Fortifying Brew
            122278, -- Dampen Harm
            115310, -- Revival
            116849, -- Life Cocoon
            115080, -- Touch of Death
            137639, -- Storm, Earth, and Fire
            152173  -- Serenity
        },
        
        -- Paladin
        ["PALADIN"] = {
            642,    -- Divine Shield
            86659,  -- Guardian of Ancient Kings
            31850,  -- Ardent Defender
            1022,   -- Blessing of Protection
            31821,  -- Aura Mastery
            31884   -- Avenging Wrath
        },
        
        -- Priest
        ["PRIEST"] = {
            19236,  -- Desperate Prayer
            47585,  -- Dispersion
            33206,  -- Pain Suppression
            62618,  -- Power Word: Barrier
            47788,  -- Guardian Spirit
            64843,  -- Divine Hymn
            10060   -- Power Infusion
        },
        
        -- Rogue
        ["ROGUE"] = {
            5277,   -- Evasion
            31224,  -- Cloak of Shadows
            2094,   -- Blind
            13750,  -- Adrenaline Rush
            51690,  -- Killing Spree
            185313, -- Shadow Dance
            121471  -- Shadow Blades
        },
        
        -- Shaman
        ["SHAMAN"] = {
            108271, -- Astral Shift
            98008,  -- Spirit Link Totem
            198067, -- Fire Elemental
            51533,  -- Feral Spirit
            114050, -- Ascendance (Elemental)
            114051, -- Ascendance (Enhancement)
            114052  -- Ascendance (Restoration)
        },
        
        -- Warlock
        ["WARLOCK"] = {
            104773, -- Unending Resolve
            108416, -- Dark Pact
            1122,   -- Summon Infernal
            205180, -- Summon Darkglare
            265187, -- Summon Demonic Tyrant
            113858, -- Dark Soul: Instability
            113860  -- Dark Soul: Misery
        },
        
        -- Warrior
        ["WARRIOR"] = {
            871,    -- Shield Wall
            12975,  -- Last Stand
            97462,  -- Rallying Cry
            1719,   -- Recklessness
            107574, -- Avatar
            227847  -- Bladestorm
        },
        
        -- Evoker
        ["EVOKER"] = {
            363916, -- Obsidian Scale
            374348, -- Rescue
            370960, -- Stasis
            359816, -- Dream Flight
            370553, -- Tip the Scales
            375087  -- Dragonrage
        }
    }
    
    -- Spell priorities (higher number = higher priority)
    SPELL_PRIORITY = {
        -- Warrior
        [871] = 80,       -- Shield Wall
        [12975] = 75,     -- Last Stand
        [97462] = 70,     -- Rallying Cry
        [107574] = 50,    -- Avatar
        [1719] = 60,      -- Recklessness
        [227847] = 40,    -- Bladestorm
        
        -- Paladin
        [642] = 90,       -- Divine Shield
        [86659] = 85,     -- Guardian of Ancient Kings
        [31850] = 80,     -- Ardent Defender
        [1022] = 95,      -- Blessing of Protection
        [31821] = 85,     -- Aura Mastery
        [31884] = 60,     -- Avenging Wrath
        
        -- Hunter
        [186265] = 80,    -- Aspect of the Turtle
        [193530] = 60,    -- Aspect of the Wild
        [19574] = 50,     -- Bestial Wrath
        [288613] = 70,    -- Trueshot
        [266779] = 70,    -- Coordinated Assault
        
        -- Rogue
        [5277] = 80,      -- Evasion
        [31224] = 85,     -- Cloak of Shadows
        [2094] = 60,      -- Blind
        [13750] = 50,     -- Adrenaline Rush
        [51690] = 60,     -- Killing Spree
        [185313] = 50,    -- Shadow Dance
        [121471] = 65,    -- Shadow Blades
        
        -- Priest
        [19236] = 70,     -- Desperate Prayer
        [47585] = 85,     -- Dispersion
        [33206] = 90,     -- Pain Suppression
        [62618] = 85,     -- Power Word: Barrier
        [47788] = 95,     -- Guardian Spirit
        [64843] = 85,     -- Divine Hymn
        [10060] = 55,     -- Power Infusion
        
        -- Death Knight
        [48707] = 75,     -- Anti-Magic Shell
        [48792] = 85,     -- Icebound Fortitude
        [51052] = 80,     -- Anti-Magic Zone
        [49028] = 70,     -- Dancing Rune Weapon
        [47568] = 55,     -- Empower Rune Weapon
        [49206] = 50,     -- Summon Gargoyle
        
        -- Shaman
        [108271] = 75,    -- Astral Shift
        [98008] = 90,     -- Spirit Link Totem
        [198067] = 50,    -- Fire Elemental
        [51533] = 50,     -- Feral Spirit
        [114050] = 60,    -- Ascendance (Elemental)
        [114051] = 60,    -- Ascendance (Enhancement)
        [114052] = 60,    -- Ascendance (Restoration)
        
        -- Mage
        [45438] = 85,     -- Ice Block
        [12472] = 60,     -- Icy Veins
        [190319] = 65,    -- Combustion
        [12042] = 55,     -- Arcane Power
        
        -- Warlock
        [104773] = 85,    -- Unending Resolve
        [108416] = 70,    -- Dark Pact
        [1122] = 50,      -- Summon Infernal
        [205180] = 50,    -- Summon Darkglare
        [265187] = 50,    -- Summon Demonic Tyrant
        
        -- Monk
        [115203] = 85,    -- Fortifying Brew
        [122278] = 75,    -- Dampen Harm
        [115310] = 85,    -- Revival
        [116849] = 95,    -- Life Cocoon
        [115080] = 50,    -- Touch of Death
        [137639] = 55,    -- Storm, Earth, and Fire
        [152173] = 60,    -- Serenity
        
        -- Druid
        [61336] = 85,     -- Survival Instincts
        [22812] = 75,     -- Barkskin
        [102342] = 95,    -- Ironbark
        [29166] = 60,     -- Innervate
        [740] = 85,       -- Tranquility
        [194223] = 60,    -- Celestial Alignment
        
        -- Demon Hunter
        [198589] = 75,    -- Blur
        [196555] = 75,    -- Netherwalk
        [187827] = 80,    -- Metamorphosis (Vengeance)
        [196718] = 90,    -- Darkness
        [198013] = 40,    -- Eye Beam
        [191427] = 45,    -- Metamorphosis (Havoc)
        
        -- Evoker
        [363916] = 75,    -- Obsidian Scale
        [374348] = 60,    -- Rescue
        [370960] = 70,    -- Stasis
        [359816] = 65,    -- Dream Flight
        [370553] = 30,    -- Tip the Scales
        [375087] = 50     -- Dragonrage
    }
    
    -- Initialize the priority system if available
    if self.PrioritySystem then
        self.PrioritySystem:Initialize()
    end
    
    -- Initialize config if available
    if self.PriorityConfig then
        self.PriorityConfig:Initialize()
    end
end

-- Initialize the module
function OmniCD:Initialize()
    -- Create database
    if not VUI.db.profile.modules.omnicd then
        VUI.db.profile.modules.omnicd = {
            enabled = true,
            growDirection = "RIGHT",
            iconSize = 30,
            iconSpacing = 2,
            maxIcons = 10,
            showNames = true,
            showCooldownText = true,
            showTooltips = true,
            spellFilters = {},
            position = {"TOPLEFT", "CENTER", 0, 150},
            zoneSettings = {
                ARENA = {enabled = true},
                RAID = {enabled = true},
                DUNGEON = {enabled = true},
                BATTLEGROUND = {enabled = true},
                OUTDOOR_PVP = {enabled = false},
                OUTDOOR = {enabled = false}
            }
        }
    end
    
    self.db = VUI.db.profile.modules.omnicd
    
    -- Initialize the module
    if self.db.enabled then
        self:SetupModule()
        -- Module initialization complete
    end
end