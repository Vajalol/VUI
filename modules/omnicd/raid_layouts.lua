-- VUI OmniCD Raid Layouts
local _, VUI = ...
local OmniCD = VUI.omnicd

-- Layout types
OmniCD.LAYOUT_TYPES = {
    GRID = "grid",          -- Grid formation
    CLASS_GROUPS = "class", -- Grouped by class
    ROLE = "role",          -- Grouped by role
    COMPACT = "compact",    -- Compact horizontal/vertical bars
    PRIORITY = "priority"   -- Dynamic priority-based
}

-- Default raid layout settings
OmniCD.defaultRaidSettings = {
    enabled = true,
    layoutType = OmniCD.LAYOUT_TYPES.GRID,
    iconSize = 24,          -- Smaller than party frames
    iconSpacing = 2,
    maxIcons = 40,          -- Support for full raid
    showIcons = {
        interrupt = true,   -- Show interrupt cooldowns
        defensive = true,   -- Show defensive cooldowns
        offensive = false,  -- Hide offensive cooldowns by default
        utility = false     -- Hide utility cooldowns by default
    },
    position = {
        point = "TOPLEFT",
        relativeTo = nil,
        relativePoint = "TOPLEFT",
        xOffset = 300,
        yOffset = -200
    },
    showTooltips = true,
    borderWidth = 1,
    useClassColors = true,  -- Color borders by class
    showNames = false,      -- Hide names in raid layout to save space
    focusTarget = true,     -- Highlight cooldowns of focused target
    growDirection = {       -- Different grow directions for different layouts
        [OmniCD.LAYOUT_TYPES.GRID] = "RIGHT_DOWN",
        [OmniCD.LAYOUT_TYPES.CLASS_GROUPS] = "RIGHT_DOWN",
        [OmniCD.LAYOUT_TYPES.ROLE] = "RIGHT_DOWN",
        [OmniCD.LAYOUT_TYPES.COMPACT] = "RIGHT",
        [OmniCD.LAYOUT_TYPES.PRIORITY] = "DOWN"
    },
    -- Grid layout specific settings
    gridSettings = {
        columns = 5,
        sortMethod = "CLASS", -- Sort by CLASS, ROLE, ALPHABETICAL
    },
    -- Class groups specific settings
    classGroupSettings = {
        showHeaders = true,
        headerHeight = 18,
        headerFont = "GameFontNormalSmall",
    },
    -- Role specific settings
    roleSettings = {
        showHeaders = true,
        headerHeight = 18,
        headerFont = "GameFontNormalSmall",
        sortOrder = {"TANK", "HEALER", "DAMAGER"},
    },
    -- Compact specific settings
    compactSettings = {
        showLabels = false,
        maxRows = 2,
        iconSize = 20, -- Even smaller icons
    },
    -- Priority specific settings
    prioritySettings = {
        maxShown = 10,
        dynamicSize = true, -- More important = bigger icon
        prioritySpells = {
            -- Examples of high-priority cooldowns
            [62618] = 100, -- Power Word: Barrier (Priest)
            [98008] = 100, -- Spirit Link Totem (Shaman)
            [31821] = 100, -- Aura Mastery (Paladin)
            [740] = 100,   -- Tranquility (Druid)
            [64843] = 100, -- Divine Hymn (Priest)
            -- Add more priority cooldowns
        }
    }
}

-- Initialize raid frame layout
function OmniCD:InitializeRaidLayouts()
    -- Create config if it doesn't exist
    if not self.db.raidFrames then
        self.db.raidFrames = CopyTable(self.defaultRaidSettings)
    end
    
    -- Register for events
    self:RegisterRaidFrameEvents()
    
    -- Create main container for raid cooldowns
    self:CreateRaidCooldownContainer()
    
    -- Apply current layout
    self:ApplyRaidLayout()
    
    -- Debug message
    self:Debug("Raid layout system initialized")
end

-- Register event handlers for raid frames
function OmniCD:RegisterRaidFrameEvents()
    if not self.raidEventFrame then
        self.raidEventFrame = CreateFrame("Frame")
        
        -- Register for raid-related events
        self.raidEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        self.raidEventFrame:RegisterEvent("ENCOUNTER_START")
        self.raidEventFrame:RegisterEvent("ENCOUNTER_END")
        self.raidEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.raidEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        
        -- Event handler
        self.raidEventFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "GROUP_ROSTER_UPDATE" then
                -- Update raid roster and layout
                self:UpdateRaidRoster()
                self:ApplyRaidLayout()
            elseif event == "ENCOUNTER_START" then
                -- Boss encounter started, update layout with encounter-specific settings
                local encounterId = ...
                self:UpdateLayoutForEncounter(encounterId)
            elseif event == "ENCOUNTER_END" then
                -- Boss encounter ended, restore default layout
                self:RestoreDefaultRaidLayout()
            elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
                -- Zone changed, check if we're in a raid instance
                self:CheckInstanceType()
            end
        end)
    end
end

-- Create the main container for raid cooldowns
function OmniCD:CreateRaidCooldownContainer()
    -- Create main frame
    if not self.raidContainer then
        self.raidContainer = CreateFrame("Frame", "VUIOmniCDRaidContainer", UIParent)
        self.raidContainer:SetMovable(true)
        self.raidContainer:EnableMouse(true)
        
        -- Make it draggable when unlocked
        self.raidContainer:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and OmniCD.unlocked then
                self:StartMoving()
            end
        end)
        
        self.raidContainer:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and OmniCD.unlocked then
                self:StopMovingOrSizing()
                -- Save position
                local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
                OmniCD.db.raidFrames.position.point = point
                OmniCD.db.raidFrames.position.relativePoint = relativePoint
                OmniCD.db.raidFrames.position.xOffset = xOfs
                OmniCD.db.raidFrames.position.yOffset = yOfs
            end
        end)
        
        -- Background (only visible when unlocked)
        self.raidContainer.bg = self.raidContainer:CreateTexture(nil, "BACKGROUND")
        self.raidContainer.bg:SetAllPoints()
        self.raidContainer.bg:SetColorTexture(0, 0, 0, 0.3)
        self.raidContainer.bg:Hide()
        
        -- Header text (only visible when unlocked)
        self.raidContainer.header = self.raidContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.raidContainer.header:SetPoint("TOP", self.raidContainer, "TOP", 0, 15)
        self.raidContainer.header:SetText("OmniCD Raid Cooldowns")
        self.raidContainer.header:Hide()
        
        -- Position based on saved settings
        local pos = self.db.raidFrames.position
        self.raidContainer:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOffset, pos.yOffset)
        
        -- Initially hidden
        self.raidContainer:Hide()
    end
    
    -- Storage for cooldown icons
    self.raidCooldownFrames = self.raidCooldownFrames or {}
    self.layoutHeaders = self.layoutHeaders or {}
end

-- Apply the selected raid layout
function OmniCD:ApplyRaidLayout()
    if not self.raidContainer then return end
    
    -- Clear existing layout
    self:ClearRaidLayout()
    
    -- Check if we should show raid frames
    local inRaid = IsInRaid()
    local inParty = IsInGroup()
    local raidSize = inRaid and GetNumGroupMembers() or (inParty and GetNumGroupMembers() or 0)
    
    -- Only show if in a group
    if not (inRaid or inParty) or raidSize < 1 then
        self.raidContainer:Hide()
        return
    end
    
    -- Get current layout type
    local layoutType = self.db.raidFrames.layoutType
    
    -- Apply the specific layout
    if layoutType == self.LAYOUT_TYPES.GRID then
        self:ApplyGridLayout()
    elseif layoutType == self.LAYOUT_TYPES.CLASS_GROUPS then
        self:ApplyClassGroupLayout()
    elseif layoutType == self.LAYOUT_TYPES.ROLE then
        self:ApplyRoleLayout()
    elseif layoutType == self.LAYOUT_TYPES.COMPACT then
        self:ApplyCompactLayout()
    elseif layoutType == self.LAYOUT_TYPES.PRIORITY then
        self:ApplyPriorityLayout()
    end
    
    -- Show the container
    self.raidContainer:Show()
    
    -- Update the cooldown display
    self:UpdateAllRaidCooldowns()
end

-- Clear current raid layout
function OmniCD:ClearRaidLayout()
    if not self.raidCooldownFrames then return end
    
    -- Hide all cooldown frames
    for _, frame in pairs(self.raidCooldownFrames) do
        if frame then
            frame:Hide()
        end
    end
    
    -- Clear any class/role headers
    if self.layoutHeaders then
        for _, header in pairs(self.layoutHeaders) do
            if header then
                header:Hide()
            end
        end
    end
    
    -- Reset container size
    self.raidContainer:SetSize(10, 10)
end

-- GRID LAYOUT IMPLEMENTATION
function OmniCD:ApplyGridLayout()
    local settings = self.db.raidFrames
    local gridSettings = settings.gridSettings
    local iconSize = settings.iconSize
    local spacing = settings.iconSpacing
    local columns = gridSettings.columns
    
    -- Get raid roster sorted according to settings
    local sortedRoster = self:GetSortedRaidRoster(gridSettings.sortMethod)
    local raidSize = #sortedRoster
    
    -- Calculate rows needed
    local rows = math.ceil(raidSize / columns)
    
    -- Size the container
    local containerWidth = (iconSize + spacing) * columns
    local containerHeight = (iconSize + spacing) * rows
    self.raidContainer:SetSize(containerWidth, containerHeight)
    
    -- Position cooldown frames
    local index = 0
    for i, playerInfo in ipairs(sortedRoster) do
        local column = index % columns
        local row = math.floor(index / columns)
        local xPos = column * (iconSize + spacing)
        local yPos = -row * (iconSize + spacing)
        
        -- Create or get cooldown frame for this player
        local cooldownFrame = self:GetPlayerRaidCooldownFrame(playerInfo.guid, playerInfo.name, playerInfo.class)
        
        -- Position the frame
        cooldownFrame:ClearAllPoints()
        cooldownFrame:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", xPos, yPos)
        
        -- Show the frame
        cooldownFrame:Show()
        
        index = index + 1
    end
    
    -- Apply theme
    self:ApplyThemeToRaidFrames()
end

-- CLASS GROUPS LAYOUT IMPLEMENTATION
function OmniCD:ApplyClassGroupLayout()
    local settings = self.db.raidFrames
    local classSettings = settings.classGroupSettings
    local iconSize = settings.iconSize
    local spacing = settings.iconSpacing
    
    -- Get raid roster grouped by class
    local classGroups = self:GetRaidRosterByClass()
    
    -- Sort the class names alphabetically
    local sortedClasses = {}
    for className, _ in pairs(classGroups) do
        table.insert(sortedClasses, className)
    end
    table.sort(sortedClasses)
    
    -- Track current position for layout
    local currentYOffset = 0
    local maxWidth = 0
    
    -- Process each class group
    for _, className in ipairs(sortedClasses) do
        local players = classGroups[className]
        
        -- Skip empty classes
        if #players == 0 then
            goto continue
        end
        
        -- Create/update class header
        local headerHeight = classSettings.showHeaders and classSettings.headerHeight or 0
        local header = self:GetHeaderFrame(className)
        
        if classSettings.showHeaders then
            -- Position and setup header
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", 0, -currentYOffset)
            
            -- Get class color for the header text
            local classColorTable = RAID_CLASS_COLORS[className]
            local r, g, b = 1, 1, 1 -- Fallback white
            if classColorTable then
                r, g, b = classColorTable.r, classColorTable.g, classColorTable.b
            end
            
            -- Set header text with class color
            local localizedClassName = LOCALIZED_CLASS_NAMES_MALE[className] or className
            header.text:SetText(localizedClassName)
            header.text:SetTextColor(r, g, b)
            
            -- Size the header
            local columns = math.min(#players, 5) -- Max 5 players per row
            local headerWidth = (iconSize + spacing) * columns
            header:SetSize(headerWidth, headerHeight)
            header:Show()
            
            -- Update max width
            maxWidth = math.max(maxWidth, headerWidth)
            
            -- Move down after header
            currentYOffset = currentYOffset + headerHeight + spacing
        end
        
        -- Position player frames
        local columns = math.min(#players, 5) -- Max 5 players per row
        local rows = math.ceil(#players / columns)
        
        for i, playerInfo in ipairs(players) do
            local column = (i - 1) % columns
            local row = math.floor((i - 1) / columns)
            local xPos = column * (iconSize + spacing)
            local yPos = currentYOffset + (row * (iconSize + spacing))
            
            -- Create or get cooldown frame for this player
            local cooldownFrame = self:GetPlayerRaidCooldownFrame(playerInfo.guid, playerInfo.name, playerInfo.class)
            
            -- Position the frame
            cooldownFrame:ClearAllPoints()
            cooldownFrame:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", xPos, -yPos)
            
            -- Show the frame
            cooldownFrame:Show()
            
            -- Update max width
            maxWidth = math.max(maxWidth, (column + 1) * (iconSize + spacing))
        end
        
        -- Update Y position for next class group
        currentYOffset = currentYOffset + (rows * (iconSize + spacing)) + spacing
        
        ::continue::
    end
    
    -- Size the container
    self.raidContainer:SetSize(maxWidth, currentYOffset)
    
    -- Apply theme
    self:ApplyThemeToRaidFrames()
end

-- ROLE LAYOUT IMPLEMENTATION
function OmniCD:ApplyRoleLayout()
    local settings = self.db.raidFrames
    local roleSettings = settings.roleSettings
    local iconSize = settings.iconSize
    local spacing = settings.iconSpacing
    
    -- Get raid roster grouped by role
    local roleGroups = self:GetRaidRosterByRole()
    
    -- Display in proper order (TANK, HEALER, DAMAGER)
    local roleOrder = roleSettings.sortOrder
    local currentYOffset = 0
    local maxWidth = 0
    
    -- Process each role group
    for _, role in ipairs(roleOrder) do
        local players = roleGroups[role] or {}
        
        -- Skip empty roles
        if #players == 0 then
            goto continue
        end
        
        -- Create/update role header
        local headerHeight = roleSettings.showHeaders and roleSettings.headerHeight or 0
        local header = self:GetHeaderFrame("role_" .. role)
        
        if roleSettings.showHeaders then
            -- Position and setup header
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", 0, -currentYOffset)
            
            -- Set header text with role color
            local roleText = role
            local r, g, b = 1, 1, 1 -- Default white
            
            if role == "TANK" then
                roleText = "Tanks"
                r, g, b = 0.2, 0.5, 0.9 -- Blue for tanks
            elseif role == "HEALER" then
                roleText = "Healers"
                r, g, b = 0.0, 0.8, 0.0 -- Green for healers
            elseif role == "DAMAGER" then
                roleText = "DPS"
                r, g, b = 0.8, 0.0, 0.0 -- Red for DPS
            end
            
            header.text:SetText(roleText)
            header.text:SetTextColor(r, g, b)
            
            -- Size the header
            local columns = math.min(#players, 6) -- Max 6 players per row for roles
            local headerWidth = (iconSize + spacing) * columns
            header:SetSize(headerWidth, headerHeight)
            header:Show()
            
            -- Update max width
            maxWidth = math.max(maxWidth, headerWidth)
            
            -- Move down after header
            currentYOffset = currentYOffset + headerHeight + spacing
        end
        
        -- Position player frames
        local columns = math.min(#players, 6) -- Max 6 players per row for roles
        local rows = math.ceil(#players / columns)
        
        for i, playerInfo in ipairs(players) do
            local column = (i - 1) % columns
            local row = math.floor((i - 1) / columns)
            local xPos = column * (iconSize + spacing)
            local yPos = currentYOffset + (row * (iconSize + spacing))
            
            -- Create or get cooldown frame for this player
            local cooldownFrame = self:GetPlayerRaidCooldownFrame(playerInfo.guid, playerInfo.name, playerInfo.class)
            
            -- Position the frame
            cooldownFrame:ClearAllPoints()
            cooldownFrame:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", xPos, -yPos)
            
            -- Show the frame
            cooldownFrame:Show()
            
            -- Update max width
            maxWidth = math.max(maxWidth, (column + 1) * (iconSize + spacing))
        end
        
        -- Update Y position for next role group
        currentYOffset = currentYOffset + (rows * (iconSize + spacing)) + spacing
        
        ::continue::
    end
    
    -- Size the container
    self.raidContainer:SetSize(maxWidth, currentYOffset)
    
    -- Apply theme
    self:ApplyThemeToRaidFrames()
end

-- COMPACT LAYOUT IMPLEMENTATION
function OmniCD:ApplyCompactLayout()
    local settings = self.db.raidFrames
    local compactSettings = settings.compactSettings
    local iconSize = compactSettings.iconSize or settings.iconSize
    local spacing = settings.iconSpacing
    local maxRows = compactSettings.maxRows or 2
    
    -- Get sorted raid roster
    local sortedRoster = self:GetSortedRaidRoster("ROLE") -- Sort by role for compact view
    local raidSize = #sortedRoster
    
    -- Calculate columns needed
    local columns = math.ceil(raidSize / maxRows)
    
    -- Size the container
    local containerWidth = (iconSize + spacing) * columns
    local containerHeight = (iconSize + spacing) * maxRows
    self.raidContainer:SetSize(containerWidth, containerHeight)
    
    -- Position cooldown frames
    for i, playerInfo in ipairs(sortedRoster) do
        local column = math.floor((i - 1) / maxRows)
        local row = (i - 1) % maxRows
        local xPos = column * (iconSize + spacing)
        local yPos = row * (iconSize + spacing)
        
        -- Create or get cooldown frame for this player
        local cooldownFrame = self:GetPlayerRaidCooldownFrame(playerInfo.guid, playerInfo.name, playerInfo.class)
        
        -- Make it compact (smaller)
        cooldownFrame:SetSize(iconSize, iconSize)
        
        -- Hide names for compact view
        cooldownFrame.nameBackground:Hide()
        cooldownFrame.name:Hide()
        
        -- Position the frame
        cooldownFrame:ClearAllPoints()
        cooldownFrame:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", xPos, -yPos)
        
        -- Show the frame
        cooldownFrame:Show()
    end
    
    -- Apply theme
    self:ApplyThemeToRaidFrames()
end

-- PRIORITY LAYOUT IMPLEMENTATION
function OmniCD:ApplyPriorityLayout()
    local settings = self.db.raidFrames
    local prioritySettings = settings.prioritySettings
    local iconSize = settings.iconSize
    local spacing = settings.iconSpacing
    
    -- This layout focuses on important cooldowns rather than players
    -- Get all cooldowns from all players
    local allCooldowns = self:GetAllRaidCooldowns()
    
    -- Sort by priority (custom priority from settings)
    table.sort(allCooldowns, function(a, b)
        local aPriority = prioritySettings.prioritySpells[a.spellID] or 0
        local bPriority = prioritySettings.prioritySpells[b.spellID] or 0
        if aPriority == bPriority then
            -- If same priority, sort by remaining time
            return (a.endTime - GetTime()) < (b.endTime - GetTime())
        end
        return aPriority > bPriority
    end)
    
    -- Limit to max shown
    local maxShown = prioritySettings.maxShown
    if #allCooldowns > maxShown then
        -- Truncate the table to maxShown entries
        for i = maxShown + 1, #allCooldowns do
            allCooldowns[i] = nil
        end
    end
    
    -- Vertical layout for priority view
    local height = (iconSize + spacing) * #allCooldowns
    local width = iconSize * 3 -- Make it wider for spell names
    self.raidContainer:SetSize(width, height)
    
    -- Create frames for each priority cooldown
    for i, cooldown in ipairs(allCooldowns) do
        -- Create a special frame for priority cooldowns
        local frame = self:GetPriorityCooldownFrame(i, cooldown)
        local yPos = (i - 1) * (iconSize + spacing)
        
        -- Position the frame
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", self.raidContainer, "TOPLEFT", 0, -yPos)
        
        -- Show the frame
        frame:Show()
    end
    
    -- Apply theme
    self:ApplyThemeToRaidFrames()
end

-- Create or get a header frame
function OmniCD:GetHeaderFrame(key)
    if not self.layoutHeaders[key] then
        local header = CreateFrame("Frame", "VUIOmniCDRaidHeader_" .. key, self.raidContainer)
        
        -- Background for header
        header.bg = header:CreateTexture(nil, "BACKGROUND")
        header.bg:SetAllPoints()
        header.bg:SetColorTexture(0, 0, 0, 0.5)
        
        -- Header text
        header.text = header:CreateFontString(nil, "OVERLAY")
        header.text:SetPoint("LEFT", header, "LEFT", 5, 0)
        header.text:SetFontObject(self.db.raidFrames.classGroupSettings.headerFont)
        
        self.layoutHeaders[key] = header
    end
    
    return self.layoutHeaders[key]
end

-- Create or get a cooldown frame for a player
function OmniCD:GetPlayerRaidCooldownFrame(guid, name, class)
    -- Create if it doesn't exist
    if not self.raidCooldownFrames[guid] then
        local settings = self.db.raidFrames
        local frame = CreateFrame("Frame", "VUIOmniCDRaid_" .. name, self.raidContainer)
        frame:SetSize(settings.iconSize, settings.iconSize)
        
        -- Player indicator
        frame.nameBackground = frame:CreateTexture(nil, "BACKGROUND")
        frame.nameBackground:SetPoint("BOTTOM", frame, "TOP", 0, 0)
        frame.nameBackground:SetSize(settings.iconSize * 1.5, 15)
        frame.nameBackground:SetColorTexture(0, 0, 0, 0.7)
        
        -- Player name
        frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.name:SetPoint("CENTER", frame.nameBackground, "CENTER", 0, 0)
        frame.name:SetText(name)
        
        -- Class color for name
        if settings.useClassColors then
            local color = RAID_CLASS_COLORS[class]
            if color then
                frame.name:SetTextColor(color.r, color.g, color.b)
            end
        end
        
        -- Hide name if setting is disabled
        if not settings.showNames then
            frame.nameBackground:Hide()
            frame.name:Hide()
        end
        
        -- Border with class color
        frame.border = frame:CreateTexture(nil, "BORDER")
        frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
        frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
        
        -- Get class color for border
        if settings.useClassColors then
            local color = RAID_CLASS_COLORS[class]
            if color then
                frame.border:SetColorTexture(color.r, color.g, color.b)
            else
                frame.border:SetColorTexture(0.7, 0.7, 0.7) -- Default gray
            end
        else
            frame.border:SetColorTexture(0.7, 0.7, 0.7) -- Default gray
        end
        
        -- Player icon background (class icon or portrait)
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetAllPoints()
        local classIcon = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
        local coords = CLASS_ICON_TCOORDS[class]
        if coords then
            frame.icon:SetTexture(classIcon)
            frame.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        else
            -- Fallback to question mark
            frame.icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
        end
        
        -- Cooldown icon area
        frame.cooldownContainer = CreateFrame("Frame", nil, frame)
        frame.cooldownContainer:SetPoint("TOP", frame, "BOTTOM", 0, -2)
        frame.cooldownContainer:SetSize(settings.iconSize * 3, settings.iconSize * 2)
        
        -- Store cooldown icons
        frame.cooldownIcons = {}
        
        -- Store reference
        self.raidCooldownFrames[guid] = frame
        
        -- Store metadata
        frame.playerGuid = guid
        frame.playerName = name
        frame.playerClass = class
    end
    
    return self.raidCooldownFrames[guid]
end

-- Get a special frame for priority cooldowns
function OmniCD:GetPriorityCooldownFrame(index, cooldown)
    local frameKey = "priority_" .. index
    if not self.raidCooldownFrames[frameKey] then
        local settings = self.db.raidFrames
        local prioritySettings = settings.prioritySettings
        local iconSize = settings.iconSize
        
        -- Create the frame
        local frame = CreateFrame("Frame", "VUIOmniCDRaidPriority_" .. index, self.raidContainer)
        frame:SetSize(iconSize * 3, iconSize)
        
        -- Dynamic sizing based on priority
        if prioritySettings.dynamicSize and cooldown and cooldown.spellID then
            local priority = prioritySettings.prioritySpells[cooldown.spellID] or 0
            local sizeMultiplier = 1 + (priority / 200) -- Up to 1.5x size for highest priority
            iconSize = iconSize * sizeMultiplier
        end
        
        -- Spell icon
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetSize(iconSize, iconSize)
        frame.icon:SetPoint("LEFT", frame, "LEFT", 0, 0)
        
        -- Cooldown overlay
        frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        frame.cooldown:SetAllPoints(frame.icon)
        frame.cooldown:SetReverse(false)
        frame.cooldown:SetHideCountdownNumbers(true)
        
        -- Spell name
        frame.spellName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.spellName:SetPoint("LEFT", frame.icon, "RIGHT", 5, 0)
        frame.spellName:SetJustifyH("LEFT")
        
        -- Timer text
        frame.timer = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.timer:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
        
        -- Player name (who has this cooldown)
        frame.playerName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.playerName:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
        frame.playerName:SetTextColor(0.7, 0.7, 0.7)
        
        -- Border
        frame.border = frame:CreateTexture(nil, "BORDER")
        frame.border:SetPoint("TOPLEFT", frame.icon, "TOPLEFT", -1, 1)
        frame.border:SetPoint("BOTTOMRIGHT", frame.icon, "BOTTOMRIGHT", 1, -1)
        frame.border:SetColorTexture(0.7, 0.7, 0.7)
        
        -- Store reference
        self.raidCooldownFrames[frameKey] = frame
    end
    
    local frame = self.raidCooldownFrames[frameKey]
    
    -- Update with cooldown data
    if cooldown then
        -- Set spell icon
        local spellTexture = select(3, GetSpellInfo(cooldown.spellID))
        if spellTexture then
            frame.icon:SetTexture(spellTexture)
        end
        
        -- Set spell name
        local spellName = GetSpellInfo(cooldown.spellID)
        frame.spellName:SetText(spellName or "Unknown")
        
        -- Set player name
        frame.playerName:SetText(cooldown.name or "")
        
        -- Set cooldown status
        local now = GetTime()
        local remaining = cooldown.endTime - now
        if remaining <= 0 then
            -- Ready
            frame.cooldown:Clear()
            frame.timer:SetText("READY")
            frame.timer:SetTextColor(0, 1, 0)
        else
            -- On cooldown
            frame.cooldown:SetCooldown(cooldown.startTime, cooldown.duration)
            
            -- Format remaining time
            if remaining <= 60 then
                frame.timer:SetText(math.floor(remaining) .. "s")
            else
                local minutes = math.floor(remaining / 60)
                local seconds = math.floor(remaining % 60)
                frame.timer:SetText(string.format("%d:%02d", minutes, seconds))
            end
            frame.timer:SetTextColor(1, 0.82, 0)
        end
        
        -- Apply class color to border if available
        if cooldown.class then
            local color = RAID_CLASS_COLORS[cooldown.class]
            if color then
                frame.border:SetColorTexture(color.r, color.g, color.b)
            end
        end
    end
    
    return frame
end

-- Get sorted raid roster based on method
function OmniCD:GetSortedRaidRoster(sortMethod)
    local roster = {}
    
    -- Create the roster
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            local name = GetUnitName(unit, true)
            local guid = UnitGUID(unit)
            local _, class = UnitClass(unit)
            local _, _, subgroup = GetRaidRosterInfo(i)
            local role = UnitGroupRolesAssigned(unit)
            
            if name and guid then
                table.insert(roster, {
                    name = name,
                    guid = guid,
                    class = class,
                    role = role,
                    subgroup = subgroup,
                    unit = unit
                })
            end
        end
    else
        -- If in party, include player and party members
        -- Player first
        local playerName = GetUnitName("player", true)
        local playerGuid = UnitGUID("player")
        local _, playerClass = UnitClass("player")
        local playerRole = UnitGroupRolesAssigned("player")
        
        table.insert(roster, {
            name = playerName,
            guid = playerGuid,
            class = playerClass,
            role = playerRole,
            subgroup = 1,
            unit = "player"
        })
        
        -- Then party members
        for i = 1, GetNumGroupMembers() - 1 do
            local unit = "party" .. i
            local name = GetUnitName(unit, true)
            local guid = UnitGUID(unit)
            local _, class = UnitClass(unit)
            local role = UnitGroupRolesAssigned(unit)
            
            if name and guid then
                table.insert(roster, {
                    name = name,
                    guid = guid,
                    class = class,
                    role = role,
                    subgroup = 1,
                    unit = unit
                })
            end
        end
    end
    
    -- Sort based on method
    if sortMethod == "CLASS" then
        -- Sort by class
        table.sort(roster, function(a, b)
            if a.class == b.class then
                return a.name < b.name
            end
            return a.class < b.class
        end)
    elseif sortMethod == "ROLE" then
        -- Sort by role (Tank > Healer > DPS)
        table.sort(roster, function(a, b)
            if a.role == b.role then
                return a.name < b.name
            end
            if a.role == "TANK" then return true end
            if b.role == "TANK" then return false end
            if a.role == "HEALER" then return true end
            if b.role == "HEALER" then return false end
            return a.name < b.name
        end)
    else
        -- Alphabetical (default)
        table.sort(roster, function(a, b)
            return a.name < b.name
        end)
    end
    
    return roster
end

-- Get raid roster grouped by class
function OmniCD:GetRaidRosterByClass()
    local roster = self:GetSortedRaidRoster("ALPHABETICAL")
    local classGroups = {}
    
    -- Initialize all classes
    for className, _ in pairs(RAID_CLASS_COLORS) do
        classGroups[className] = {}
    end
    
    -- Group players by class
    for _, player in ipairs(roster) do
        if player.class and classGroups[player.class] then
            table.insert(classGroups[player.class], player)
        end
    end
    
    return classGroups
end

-- Get raid roster grouped by role
function OmniCD:GetRaidRosterByRole()
    local roster = self:GetSortedRaidRoster("ALPHABETICAL")
    local roleGroups = {
        ["TANK"] = {},
        ["HEALER"] = {},
        ["DAMAGER"] = {}
    }
    
    -- Group players by role
    for _, player in ipairs(roster) do
        -- Default to DAMAGER if no role is assigned
        local role = player.role
        if not role or role == "NONE" then
            role = "DAMAGER"
        end
        
        if roleGroups[role] then
            table.insert(roleGroups[role], player)
        else
            -- Fallback for unknown roles
            table.insert(roleGroups["DAMAGER"], player)
        end
    end
    
    return roleGroups
end

-- Get all cooldowns from all players in the raid
function OmniCD:GetAllRaidCooldowns()
    local allCooldowns = {}
    
    -- If no active cooldowns, return empty table
    if not self.activeCooldowns then
        return allCooldowns
    end
    
    -- Get all player GUIDs
    local playerGuids = {}
    local roster = self:GetSortedRaidRoster("ALPHABETICAL")
    
    for _, player in ipairs(roster) do
        playerGuids[player.guid] = player
    end
    
    -- Collect all cooldowns from all players
    for guid, cooldowns in pairs(self.activeCooldowns) do
        -- Only include players who are in our raid/party
        if playerGuids[guid] then
            for _, cooldown in ipairs(cooldowns) do
                -- Add player info to the cooldown
                cooldown.playerGuid = guid
                cooldown.playerName = playerGuids[guid].name
                cooldown.playerClass = playerGuids[guid].class
                
                -- Only add cooldowns that match our filter criteria
                local filtered = self:FilterCooldownsByRaidSettings({cooldown})
                if #filtered > 0 then
                    table.insert(allCooldowns, cooldown)
                end
            end
        end
    end
    
    return allCooldowns
end

-- Update all raid cooldowns
function OmniCD:UpdateAllRaidCooldowns()
    if not self.raidCooldownFrames then return end
    
    -- Get current layout type
    local layoutType = self.db.raidFrames.layoutType
    
    -- For Priority layout, we need to update differently
    if layoutType == self.LAYOUT_TYPES.PRIORITY then
        self:UpdatePriorityCooldowns()
        return
    end
    
    -- Process each player in the raid
    for guid, frame in pairs(self.raidCooldownFrames) do
        -- Skip priority frames
        if type(guid) ~= "string" or guid:sub(1, 9) == "priority_" then
            goto continue
        end
        
        -- Get this player's cooldowns
        local unitCooldowns = self.activeCooldowns and self.activeCooldowns[guid] or {}
        
        -- Filter cooldowns based on raid settings
        local filteredCooldowns = self:FilterCooldownsByRaidSettings(unitCooldowns)
        
        -- Update cooldown icons for this player
        self:UpdatePlayerRaidCooldowns(guid, filteredCooldowns)
        
        ::continue::
    end
end

-- Update player-specific raid cooldowns
function OmniCD:UpdatePlayerRaidCooldowns(guid, cooldowns)
    local frame = self.raidCooldownFrames[guid]
    if not frame then return end
    
    -- Clear existing cooldown icons
    for _, icon in pairs(frame.cooldownIcons or {}) do
        icon:Hide()
    end
    
    -- If no cooldowns, we're done
    if not cooldowns or #cooldowns == 0 then return end
    
    -- Get settings
    local settings = self.db.raidFrames
    local iconSize = settings.iconSize * 0.8 -- Slightly smaller than player icon
    local spacing = settings.iconSpacing
    
    -- Layout cooldown icons horizontally
    for i, cooldown in ipairs(cooldowns) do
        -- Get or create icon frame
        local icon = frame.cooldownIcons[i]
        if not icon then
            icon = CreateFrame("Frame", nil, frame.cooldownContainer)
            icon:SetSize(iconSize, iconSize)
            
            -- Icon texture
            icon.texture = icon:CreateTexture(nil, "ARTWORK")
            icon.texture:SetAllPoints()
            icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim borders
            
            -- Cooldown overlay
            icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
            icon.cooldown:SetAllPoints()
            icon.cooldown:SetReverse(false)
            icon.cooldown:SetHideCountdownNumbers(true)
            
            -- Timer text
            icon.timer = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            icon.timer:SetPoint("CENTER", icon, "CENTER", 0, 0)
            icon.timer:SetTextColor(1, 1, 1)
            
            -- Store reference
            frame.cooldownIcons[i] = icon
        end
        
        -- Position the icon
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", frame.cooldownContainer, "LEFT", (i-1) * (iconSize + spacing), 0)
        
        -- Set spell texture
        local spellTexture = select(3, GetSpellInfo(cooldown.spellID))
        if spellTexture then
            icon.texture:SetTexture(spellTexture)
        end
        
        -- Set cooldown status
        local now = GetTime()
        local remaining = cooldown.endTime - now
        if remaining <= 0 then
            -- Ready
            icon.cooldown:Clear()
            icon.timer:SetText("")
            icon.texture:SetAlpha(1.0)
        else
            -- On cooldown
            icon.cooldown:SetCooldown(cooldown.startTime, cooldown.duration)
            
            -- Format remaining time
            if remaining <= 60 then
                icon.timer:SetText(math.floor(remaining))
            else
                local minutes = math.floor(remaining / 60)
                local seconds = math.floor(remaining % 60)
                icon.timer:SetText(string.format("%d:%02d", minutes, seconds))
            end
            
            -- Dim the texture
            icon.texture:SetAlpha(0.7)
        end
        
        -- Show the icon
        icon:Show()
    end
end

-- Update priority cooldown layout
function OmniCD:UpdatePriorityCooldowns()
    -- This completely rebuilds the priority layout with fresh data
    self:ApplyPriorityLayout()
end

-- Filter cooldowns based on raid frame settings
function OmniCD:FilterCooldownsByRaidSettings(cooldowns)
    if not cooldowns or #cooldowns == 0 then return {} end
    
    local filtered = {}
    local settings = self.db.raidFrames.showIcons
    
    -- Filter by type
    for _, cooldown in ipairs(cooldowns) do
        local spellID = cooldown.spellID
        local shouldInclude = false
        
        -- Check spell category against filters
        local group = self:GetSpellGroup(spellID)
        if group then
            local groupName = group.name:lower()
            
            if groupName:find("interrupt") and settings.interrupt then
                shouldInclude = true
            elseif groupName:find("defensive") and settings.defensive then
                shouldInclude = true
            elseif groupName:find("offensive") and settings.offensive then
                shouldInclude = true
            elseif (groupName:find("utility") or groupName:find("other")) and settings.utility then
                shouldInclude = true
            end
        end
        
        if shouldInclude then
            table.insert(filtered, cooldown)
        end
    end
    
    -- Sort by priority
    table.sort(filtered, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    
    return filtered
end

-- Apply theme to raid frames
function OmniCD:ApplyThemeToRaidFrames()
    local currentTheme = VUI:GetTheme()
    
    -- Apply theme to all frames
    for frameKey, frame in pairs(self.raidCooldownFrames) do
        -- Skip non-existent frames
        if not frame or not frame.border then goto continue end
        
        -- Apply theme colors to frame elements
        if frame.nameBackground then
            local bgColor = self:GetThemeElementColor("background")
            if bgColor then
                frame.nameBackground:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 0.7)
            end
        end
        
        -- Apply theme to cooldown icons
        if frame.cooldownIcons then
            for _, icon in pairs(frame.cooldownIcons) do
                if icon and icon.timer then
                    local textColor = self:GetThemeElementColor("text")
                    if textColor then
                        icon.timer:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1.0)
                    end
                end
            end
        end
        
        ::continue::
    end
    
    -- Apply theme to headers
    for _, header in pairs(self.layoutHeaders) do
        if header and header.bg then
            local bgColor = self:GetThemeElementColor("headerBackground")
            if bgColor then
                header.bg:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 0.5)
            end
        end
    end
end

-- Get theme element color 
function OmniCD:GetThemeElementColor(elementType)
    local theme = VUI:GetTheme()
    if not theme or not elementType then return nil end
    
    local colors = {
        border = {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        background = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
        highlight = {r = 1.0, g = 0.8, b = 0.0, a = 0.7},
        text = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
        headerBackground = {r = 0.1, g = 0.1, b = 0.1, a = 0.5},
        ready = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
    }
    
    -- Apply theme-specific colors
    if theme == "phoenixflame" then
        colors.border = {r = 0.9, g = 0.3, b = 0.05, a = 1.0}
        colors.highlight = {r = 1.0, g = 0.64, b = 0.1, a = 0.7}
        colors.headerBackground = {r = 0.15, g = 0.07, b = 0.03, a = 0.8}
    elseif theme == "thunderstorm" then
        colors.border = {r = 0.05, g = 0.62, b = 0.9, a = 1.0}
        colors.highlight = {r = 0.4, g = 0.8, b = 1.0, a = 0.7}
        colors.headerBackground = {r = 0.05, g = 0.05, b = 0.15, a = 0.8}
    elseif theme == "arcanemystic" then
        colors.border = {r = 0.62, g = 0.05, b = 0.9, a = 1.0}
        colors.highlight = {r = 1.0, g = 0.4, b = 1.0, a = 0.7}
        colors.headerBackground = {r = 0.1, g = 0.05, b = 0.2, a = 0.8}
    elseif theme == "felenergy" then
        colors.border = {r = 0.1, g = 1.0, b = 0.1, a = 1.0}
        colors.highlight = {r = 0.75, g = 1.0, b = 0.0, a = 0.7}
        colors.headerBackground = {r = 0.05, g = 0.15, b = 0.05, a = 0.8}
    end
    
    return colors[elementType]
end

-- Hook this into the main module initialization
local originalSetupModule = OmniCD.SetupModule
OmniCD.SetupModule = function(self)
    originalSetupModule(self)
    
    -- Initialize raid layouts
    self:InitializeRaidLayouts()
end

-- Hook into cooldown updates to update raid layout as well
local originalUpdateCooldownDisplay = OmniCD.UpdateCooldownDisplay
OmniCD.UpdateCooldownDisplay = function(self)
    originalUpdateCooldownDisplay(self)
    
    -- Update raid cooldowns as well
    self:UpdateAllRaidCooldowns()
end

-- Update raid roster
function OmniCD:UpdateRaidRoster()
    -- Check if raid layout is enabled
    if not self.db.raidFrames.enabled then return end
    
    -- Check if we're in a group
    local inRaid = IsInRaid()
    local inParty = IsInGroup()
    
    if not (inRaid or inParty) then
        -- Solo, hide raid frames
        if self.raidContainer then
            self.raidContainer:Hide()
        end
        return
    end
    
    -- We are in a group, update the raid layout
    self:ApplyRaidLayout()
end

-- Check instance type and adjust layout
function OmniCD:CheckInstanceType()
    local inInstance, instanceType = IsInInstance()
    
    if inInstance then
        -- We're in an instance, check type
        if instanceType == "raid" then
            -- In a raid instance, make sure raid layout is visible
            self:UpdateRaidRoster()
        elseif instanceType == "party" then
            -- In a dungeon, make sure raid layout is visible
            self:UpdateRaidRoster()
        end
    else
        -- Not in an instance, normal update
        self:UpdateRaidRoster()
    end
end

-- Update layout for specific encounter
function OmniCD:UpdateLayoutForEncounter(encounterId)
    -- This would customize the layout based on encounter-specific needs
    -- For example, certain bosses might need different priority cooldowns
    -- This is a placeholder for future encounter-specific customization
    
    -- For now, just ensure the layout is up to date
    self:UpdateRaidRoster()
end

-- Restore default raid layout
function OmniCD:RestoreDefaultRaidLayout()
    -- Reset any encounter-specific customizations
    -- Then update the layout
    self:UpdateRaidRoster()
end