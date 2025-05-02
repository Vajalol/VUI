--[[
    VUI - TrufiGCD Timeline View
    Version: 0.3.0
    Author: VortexQ8
    
    This file implements a timeline view for TrufiGCD spell history:
    - Visual timeline representation of spell casts
    - Categorized display based on spell types
    - Interactive filtering and customization
    - Integrated with existing spell categorization system
]]

local _, VUI = ...
local TrufiGCD = VUI.modules.trufigcd
local Categories = TrufiGCD.Categories

-- Create timeline namespace
TrufiGCD.Timeline = {}
local Timeline = TrufiGCD.Timeline

-- Import frequently used globals
local CreateFrame = CreateFrame
local GetTime = GetTime
local UIParent = UIParent
local tinsert, tremove, wipe = table.insert, table.remove, table.wipe
local min, max, floor = math.min, math.max, math.floor
local pairs, ipairs = pairs, ipairs
local format = string.format

-- Timeline settings
Timeline.settings = {
    width = 600,                 -- Width of timeline window
    height = 300,                -- Height of timeline window
    rowHeight = 24,              -- Height of each row
    maxRows = 8,                 -- Maximum number of rows to display
    padding = 8,                 -- Padding inside the window
    headerHeight = 28,           -- Height of the header section
    scrollStep = 3,              -- How many items to scroll per step
    historyBuffer = 100,         -- Number of spells to keep in history
    iconSize = 22,               -- Size of spell icons on timeline
    lineHeight = 2,              -- Height of timeline lines
    categoryRows = true,         -- Whether to group spells by category
    timeScale = 30,              -- Default time scale in seconds
    timeScaleOptions = {10, 30, 60, 120, 300}, -- Available time scale options in seconds
    minTimeGap = 0.1,            -- Minimum gap between events to display separately (seconds)
    showTooltips = true,         -- Whether to show tooltips on hover
    showCooldowns = true,        -- Whether to show cooldown durations
    fadeTime = 20                -- How long to keep spells in history (seconds)
}

-- Spell history storage
Timeline.history = {}            -- Complete history of tracked spells
Timeline.filteredHistory = {}    -- Filtered view of history (by category, etc.)
Timeline.categoryRows = {}       -- Row assignments for categories
Timeline.isActive = false        -- Whether the timeline window is currently shown
Timeline.timeStart = 0           -- Start time for the visible timeline section
Timeline.timeEnd = 0             -- End time for the visible timeline section
Timeline.colorMods = {}          -- Category color modifications by theme

-- Initialize the timeline system
function Timeline:Initialize()
    -- Create the timeline frame
    self:CreateTimelineFrame()
    
    -- Register callbacks
    self:RegisterCallbacks()
    
    -- Hook into spell tracking
    self:HookSpellTracking()
    
    -- Apply theme colors
    self:UpdateThemeColors()
    
    -- Register slash command
    self:RegisterSlashCommands()
    
    VUI:Print("TrufiGCD Timeline view initialized")
end

-- Register slash commands
function Timeline:RegisterSlashCommands()
    -- Add to TrufiGCD's existing slash commands
    VUI:RegisterChatCommand("timeline", function()
        if self.isActive then
            self:HideTimeline()
        else
            self:ShowTimeline()
        end
    end)
end

-- Create the main timeline frame
function Timeline:CreateTimelineFrame()
    -- Main frame
    self.frame = CreateFrame("Frame", "VUITrufiGCDTimeline", UIParent)
    self.frame:SetSize(self.settings.width, self.settings.height)
    self.frame:SetPoint("CENTER", 0, 0)
    self.frame:SetFrameStrata("MEDIUM")
    self.frame:SetFrameLevel(10)
    self.frame:EnableMouse(true)
    self.frame:SetMovable(true)
    self.frame:SetResizable(true)
    self.frame:SetClampedToScreen(true)
    self.frame:SetUserPlaced(true)
    self.frame:Hide()
    
    -- Background
    self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.bg:SetAllPoints()
    self.frame.bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- Border
    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetPoint("TOPLEFT", -1, 1)
    self.frame.border:SetPoint("BOTTOMRIGHT", 1, -1)
    self.frame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    self.frame.border:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Header
    self:CreateHeader()
    
    -- Timeline content area
    self:CreateTimelineContent()
    
    -- Footer with controls
    self:CreateFooter()
    
    -- Make draggable
    self.frame:SetScript("OnMouseDown", function(frame, button)
        if button == "LeftButton" and not frame.isResizing then
            frame:StartMoving()
            frame.isMoving = true
        end
    end)
    
    self.frame:SetScript("OnMouseUp", function(frame, button)
        if button == "LeftButton" then
            if frame.isMoving then
                frame:StopMovingOrSizing()
                frame.isMoving = false
            end
            if frame.isResizing then
                frame:StopMovingOrSizing()
                frame.isResizing = false
                -- Update content based on new dimensions
                Timeline:RefreshDisplay()
            end
        end
    end)
    
    -- Catch ESC key to close timeline
    tinsert(UISpecialFrames, "VUITrufiGCDTimeline")
end

-- Create the header section
function Timeline:CreateHeader()
    local header = CreateFrame("Frame", nil, self.frame)
    header:SetHeight(self.settings.headerHeight)
    header:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
    
    -- Header background
    header.bg = header:CreateTexture(nil, "BACKGROUND")
    header.bg:SetAllPoints()
    header.bg:SetColorTexture(0.1, 0.1, 0.1, 1)
    
    -- Title
    header.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header.title:SetPoint("LEFT", header, "LEFT", 8, 0)
    header.title:SetText("TrufiGCD Timeline")
    
    -- Close button
    header.closeButton = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    header.closeButton:SetPoint("RIGHT", header, "RIGHT", 0, 0)
    header.closeButton:SetScript("OnClick", function() Timeline:HideTimeline() end)
    
    -- Filter button
    header.filterButton = CreateFrame("Button", nil, header)
    header.filterButton:SetSize(22, 22)
    header.filterButton:SetPoint("RIGHT", header.closeButton, "LEFT", -4, 0)
    
    header.filterButton.icon = header.filterButton:CreateTexture(nil, "ARTWORK")
    header.filterButton.icon:SetAllPoints()
    header.filterButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
    header.filterButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    header.filterButton:SetScript("OnClick", function() Timeline:ToggleFilterMenu() end)
    header.filterButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Filter Timeline")
        GameTooltip:Show()
    end)
    header.filterButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Time display
    header.timeDisplay = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header.timeDisplay:SetPoint("RIGHT", header.filterButton, "LEFT", -10, 0)
    header.timeDisplay:SetText("0:00 - 0:30")
    
    self.frame.header = header
end

-- Create the timeline content area
function Timeline:CreateTimelineContent()
    -- Content frame (scrollable)
    local content = CreateFrame("Frame", nil, self.frame)
    content:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.settings.padding, -self.settings.headerHeight)
    content:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -self.settings.padding, self.settings.padding + 30) -- Leave space for footer
    
    -- Timeline rows container
    local rowsContainer = CreateFrame("Frame", nil, content)
    rowsContainer:SetAllPoints()
    
    -- Create row frames
    local rows = {}
    for i = 1, self.settings.maxRows do
        local row = CreateFrame("Frame", nil, rowsContainer)
        row:SetHeight(self.settings.rowHeight)
        row:SetPoint("LEFT", rowsContainer, "LEFT", 0, 0)
        row:SetPoint("RIGHT", rowsContainer, "RIGHT", 0, 0)
        
        if i == 1 then
            row:SetPoint("TOP", rowsContainer, "TOP", 0, 0)
        else
            row:SetPoint("TOP", rows[i-1], "BOTTOM", 0, 0)
        end
        
        -- Background with alternating colors
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        if i % 2 == 0 then
            row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        else
            row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.1)
        end
        
        -- Row label
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
        row.label:SetWidth(100)
        row.label:SetJustifyH("LEFT")
        row.label:SetText("Row " .. i)
        
        -- Timeline area
        row.timeline = CreateFrame("Frame", nil, row)
        row.timeline:SetPoint("LEFT", row.label, "RIGHT", 5, 0)
        row.timeline:SetPoint("RIGHT", row, "RIGHT", -5, 0)
        row.timeline:SetHeight(self.settings.rowHeight)
        
        -- Add horizontal line
        row.line = row.timeline:CreateTexture(nil, "ARTWORK")
        row.line:SetHeight(self.settings.lineHeight)
        row.line:SetPoint("LEFT", row.timeline, "LEFT", 0, 0)
        row.line:SetPoint("RIGHT", row.timeline, "RIGHT", 0, 0)
        row.line:SetPoint("CENTER", row.timeline, "CENTER", 0, 0)
        row.line:SetColorTexture(0.3, 0.3, 0.3, 0.5)
        
        -- Container for spell icons
        row.icons = {}
        
        rows[i] = row
    end
    
    content.rows = rows
    self.frame.content = content
    self.rows = rows
    
    -- Time markers
    self:CreateTimeMarkers()
    
    -- Scroll buttons
    self:CreateScrollButtons()
end

-- Create time markers
function Timeline:CreateTimeMarkers() 
    local timeMarkers = CreateFrame("Frame", nil, self.frame.content)
    timeMarkers:SetHeight(20)
    timeMarkers:SetPoint("LEFT", self.frame.content, "LEFT", 105, 0) -- Adjust for row labels
    timeMarkers:SetPoint("RIGHT", self.frame.content, "RIGHT", -5, 0)
    timeMarkers:SetPoint("BOTTOM", self.frame.content, "TOP", 0, 2)
    
    -- Background
    timeMarkers.bg = timeMarkers:CreateTexture(nil, "BACKGROUND")
    timeMarkers.bg:SetAllPoints()
    timeMarkers.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    
    -- Create marker frames
    timeMarkers.markers = {}
    for i = 1, 7 do -- Create 7 time markers
        local marker = timeMarkers:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        marker:SetPoint("BOTTOM", timeMarkers, "BOTTOM", 0, 2)
        
        -- Add tick mark
        local tick = timeMarkers:CreateTexture(nil, "ARTWORK")
        tick:SetSize(1, 5)
        tick:SetPoint("TOP", marker, "BOTTOM", 0, 0)
        tick:SetColorTexture(0.5, 0.5, 0.5, 0.8)
        
        timeMarkers.markers[i] = {text = marker, tick = tick}
    end
    
    self.frame.timeMarkers = timeMarkers
end

-- Create scroll buttons
function Timeline:CreateScrollButtons()
    -- Previous button
    local prevButton = CreateFrame("Button", nil, self.frame.content)
    prevButton:SetSize(24, 24)
    prevButton:SetPoint("RIGHT", self.frame.content, "LEFT", 20, 0)
    prevButton:SetPoint("CENTER", self.frame.content, "CENTER", 0, 0)
    prevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    prevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    prevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    
    prevButton:SetScript("OnClick", function()
        local timeRange = self.settings.timeScale
        self:ScrollTimeline(-timeRange / 3) -- Scroll back by 1/3 of the view
    end)
    
    -- Next button
    local nextButton = CreateFrame("Button", nil, self.frame.content)
    nextButton:SetSize(24, 24)
    nextButton:SetPoint("LEFT", self.frame.content, "RIGHT", -20, 0)
    nextButton:SetPoint("CENTER", self.frame.content, "CENTER", 0, 0)
    nextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    nextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
    nextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    
    nextButton:SetScript("OnClick", function()
        local timeRange = self.settings.timeScale
        self:ScrollTimeline(timeRange / 3) -- Scroll forward by 1/3 of the view
    end)
    
    self.frame.prevButton = prevButton
    self.frame.nextButton = nextButton
end

-- Create footer with controls
function Timeline:CreateFooter()
    local footer = CreateFrame("Frame", nil, self.frame)
    footer:SetHeight(30)
    footer:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
    
    -- Background
    footer.bg = footer:CreateTexture(nil, "BACKGROUND")
    footer.bg:SetAllPoints()
    footer.bg:SetColorTexture(0.1, 0.1, 0.1, 1)
    
    -- Time scale label
    footer.scaleLabel = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    footer.scaleLabel:SetPoint("LEFT", footer, "LEFT", 10, 0)
    footer.scaleLabel:SetText("Time Scale:")
    
    -- Time scale dropdown
    local timeScaleButton = CreateFrame("Button", "VUITrufiTimelineScaleButton", footer, "UIDropDownMenuTemplate")
    timeScaleButton:SetPoint("LEFT", footer.scaleLabel, "RIGHT", -5, -3)
    
    UIDropDownMenu_SetWidth(timeScaleButton, 60)
    UIDropDownMenu_SetText(timeScaleButton, self:FormatTimeScale(self.settings.timeScale))
    
    UIDropDownMenu_Initialize(timeScaleButton, function(frame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, scale in ipairs(self.settings.timeScaleOptions) do
            info.text = self:FormatTimeScale(scale)
            info.value = scale
            info.func = function(self)
                Timeline:SetTimeScale(self.value)
                UIDropDownMenu_SetText(timeScaleButton, Timeline:FormatTimeScale(self.value))
            end
            info.checked = (scale == Timeline.settings.timeScale)
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Group by category checkbox
    local groupCheck = CreateFrame("CheckButton", nil, footer, "UICheckButtonTemplate")
    groupCheck:SetSize(20, 20)
    groupCheck:SetPoint("LEFT", timeScaleButton, "RIGHT", 70, 0)
    groupCheck:SetChecked(self.settings.categoryRows)
    
    groupCheck.text = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    groupCheck.text:SetPoint("LEFT", groupCheck, "RIGHT", 2, 0)
    groupCheck.text:SetText("Group by Category")
    
    groupCheck:SetScript("OnClick", function(self)
        Timeline.settings.categoryRows = self:GetChecked()
        Timeline:RefreshDisplay()
    end)
    
    -- Clear button
    local clearButton = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
    clearButton:SetSize(60, 22)
    clearButton:SetPoint("RIGHT", footer, "RIGHT", -10, 0)
    clearButton:SetText("Clear")
    
    clearButton:SetScript("OnClick", function()
        wipe(Timeline.history)
        Timeline:RefreshDisplay()
    end)
    
    self.frame.footer = footer
end

-- Format a time scale for display
function Timeline:FormatTimeScale(seconds)
    if seconds < 60 then
        return seconds .. "s"
    else
        return (seconds / 60) .. "m"
    end
end

-- Set the time scale
function Timeline:SetTimeScale(seconds)
    self.settings.timeScale = seconds
    self:RefreshDisplay()
end

-- Update time markers based on current time range
function Timeline:UpdateTimeMarkers()
    local timeMarkers = self.frame.timeMarkers
    if not timeMarkers then return end
    
    local startTime = self.timeStart
    local endTime = self.timeEnd
    local timeRange = endTime - startTime
    local markerCount = #timeMarkers.markers
    
    for i = 1, markerCount do
        local marker = timeMarkers.markers[i]
        local position = (i - 1) / (markerCount - 1)
        local markerTime = startTime + (timeRange * position)
        
        -- Position marker horizontally
        local timelineWidth = timeMarkers:GetWidth()
        local xPos = (position * timelineWidth) - (timelineWidth / 2)
        marker.text:SetPoint("BOTTOM", timeMarkers, "BOTTOM", xPos, 2)
        marker.tick:SetPoint("TOP", marker.text, "BOTTOM", 0, 0)
        
        -- Format time as M:SS
        local timeText = self:FormatTime(markerTime - startTime)
        marker.text:SetText(timeText)
    end
end

-- Format time as M:SS
function Timeline:FormatTime(seconds)
    local mins = floor(seconds / 60)
    local secs = floor(seconds % 60)
    return format("%d:%02d", mins, secs)
end

-- Register callbacks for theme changes
function Timeline:RegisterCallbacks()
    VUI:RegisterCallback("ThemeChanged", function()
        self:UpdateThemeColors()
    end)
end

-- Update colors based on theme
function Timeline:UpdateThemeColors()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Default colors
    self.colorMods = {
        offensive = {1.0, 0.3, 0.3, 1.0},      -- Red
        defensive = {0.2, 0.8, 0.2, 1.0},      -- Green
        healing = {0.0, 1.0, 0.0, 1.0},        -- Bright green
        utility = {0.4, 0.4, 1.0, 1.0},        -- Blue
        interrupts = {1.0, 0.6, 0.0, 1.0},     -- Orange
        dispels = {0.8, 0.0, 0.8, 1.0},        -- Purple
        cooldowns = {1.0, 0.9, 0.0, 1.0},      -- Yellow/gold
        standard = {0.7, 0.7, 0.7, 0.8}        -- Gray
    }
    
    -- Apply theme-specific color modifications
    if theme == "phoenixflame" then
        -- Warm color variants for Phoenix Flame theme
        self.colorMods.offensive = {1.0, 0.4, 0.1, 1.0} -- More orange-red
        self.colorMods.cooldowns = {1.0, 0.7, 0.0, 1.0} -- More golden
    elseif theme == "thunderstorm" then
        -- Cool color variants for Thunder Storm theme
        self.colorMods.offensive = {0.9, 0.2, 0.2, 1.0} -- Deeper red
        self.colorMods.utility = {0.2, 0.5, 1.0, 1.0}  -- Brighter blue
    elseif theme == "arcanemystic" then
        -- Mystical color variants for Arcane Mystic theme
        self.colorMods.dispels = {0.9, 0.2, 1.0, 1.0}  -- Brighter purple
        self.colorMods.cooldowns = {0.8, 0.5, 1.0, 1.0} -- Arcane purple-gold
    elseif theme == "felenergy" then
        -- Fel color variants for Fel Energy theme
        self.colorMods.healing = {0.1, 0.9, 0.1, 1.0}  -- More fel green
        self.colorMods.offensive = {0.8, 1.0, 0.2, 1.0} -- Fel yellow-green
    end
    
    -- Apply to UI elements if timeline is active
    if self.isActive then
        self:RefreshDisplay()
    end
end

-- Hook into spell tracking to capture spell history
function Timeline:HookSpellTracking()
    -- Store original AddSpellToQueue function
    local originalAddSpellToQueue = VUI.TrufiGCD.AddSpellToQueue
    
    -- Replace with enhanced version that also adds to timeline history
    VUI.TrufiGCD.AddSpellToQueue = function(self, spellID, name, icon)
        -- Call original function first
        originalAddSpellToQueue(self, spellID, name, icon)
        
        -- Add to timeline history
        Timeline:AddSpellToHistory(spellID, name, icon)
    end
end

-- Add a spell to the timeline history
function Timeline:AddSpellToHistory(spellID, name, icon)
    -- Get spell category if available
    local category = "standard"
    local importance = "medium"
    
    if TrufiGCD.Categories then
        local categoryData = TrufiGCD.Categories:GetSpellCategory(spellID)
        if categoryData and categoryData.id then
            category = categoryData.id:lower()
        end
        
        local importanceData = TrufiGCD.Categories:GetSpellImportance(spellID)
        if importanceData and importanceData.id then
            importance = importanceData.id:lower()
        end
    end
    
    -- Create history entry
    local entry = {
        spellID = spellID,
        name = name,
        icon = icon,
        time = GetTime(),
        category = category,
        importance = importance
    }
    
    -- Add to history
    tinsert(self.history, 1, entry)
    
    -- Trim history if it exceeds buffer size
    while #self.history > self.settings.historyBuffer do
        tremove(self.history)
    end
    
    -- Update display if timeline is visible
    if self.isActive then
        self:RefreshDisplay()
    end
end

-- Show the timeline
function Timeline:ShowTimeline()
    self.isActive = true
    self.frame:Show()
    
    -- Set initial time range to most recent activity
    local now = GetTime()
    self.timeEnd = now
    self.timeStart = now - self.settings.timeScale
    
    -- Refresh the display
    self:RefreshDisplay()
    
    -- Start update timer
    self:StartTimelineUpdates()
end

-- Hide the timeline
function Timeline:HideTimeline()
    self.isActive = false
    self.frame:Hide()
    
    -- Stop update timer
    self:StopTimelineUpdates()
end

-- Toggle timeline visibility
function Timeline:ToggleTimeline()
    if self.isActive then
        self:HideTimeline()
    else
        self:ShowTimeline()
    end
end

-- Start timeline updates
function Timeline:StartTimelineUpdates()
    if self.updateTimer then return end
    
    self.updateTimer = C_Timer.NewTicker(0.5, function()
        if self.isActive then
            self:UpdateTimeline()
        end
    end)
end

-- Stop timeline updates
function Timeline:StopTimelineUpdates()
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
end

-- Update the timeline display
function Timeline:UpdateTimeline()
    -- Update the timeline end time if we're viewing recent activity
    local now = GetTime()
    local isViewingRecent = (now - self.timeEnd) < 1.0
    
    if isViewingRecent then
        -- Keep end time current
        local diff = now - self.timeEnd
        self.timeEnd = now
        self.timeStart = self.timeStart + diff
    end
    
    -- Check for expired spells in history
    local cutoffTime = now - self.settings.fadeTime
    for i = #self.history, 1, -1 do
        if self.history[i].time < cutoffTime then
            tremove(self.history, i)
        end
    end
    
    -- Refresh display if we have active spells
    if #self.history > 0 then
        self:RefreshDisplay()
    end
    
    -- Update time display in header
    local formatStart = self:FormatTime(0)
    local formatEnd = self:FormatTime(self.timeEnd - self.timeStart)
    self.frame.header.timeDisplay:SetText(formatStart .. " - " .. formatEnd)
end

-- Scroll the timeline by a given amount
function Timeline:ScrollTimeline(seconds)
    self.timeStart = self.timeStart + seconds
    self.timeEnd = self.timeEnd + seconds
    
    -- Don't allow scrolling past current time
    local now = GetTime()
    if self.timeEnd > now then
        local diff = self.timeEnd - now
        self.timeEnd = now
        self.timeStart = self.timeStart - diff
    end
    
    -- Update display
    self:RefreshDisplay()
end

-- Refresh the timeline display
function Timeline:RefreshDisplay()
    if not self.isActive then return end
    
    -- Update time markers
    self:UpdateTimeMarkers()
    
    -- Filter history based on current time range
    self:FilterHistory()
    
    -- Assign rows based on categories or flat list
    self:AssignRows()
    
    -- Clear existing spell icons
    self:ClearSpellIcons()
    
    -- Display spells on timeline
    self:DisplaySpells()
end

-- Filter history based on current time range
function Timeline:FilterHistory()
    wipe(self.filteredHistory)
    
    for _, spell in ipairs(self.history) do
        if spell.time >= self.timeStart and spell.time <= self.timeEnd then
            tinsert(self.filteredHistory, spell)
        end
    end
end

-- Assign rows based on categories or flat list
function Timeline:AssignRows()
    wipe(self.categoryRows)
    
    if self.settings.categoryRows then
        -- Group by category
        local categories = {
            "cooldowns",
            "defensive",
            "offensive",
            "healing",
            "interrupts",
            "dispels",
            "utility",
            "standard"
        }
        
        -- Assign categories to rows
        for i, category in ipairs(categories) do
            if i <= self.settings.maxRows then
                self.categoryRows[category] = i
                
                -- Set row label
                if Categories and Categories.TYPES and Categories.TYPES[category:upper()] then
                    local catData = Categories.TYPES[category:upper()]
                    self.rows[i].label:SetText(catData.name)
                    
                    -- Set row color
                    if self.colorMods[category] then
                        local color = self.colorMods[category]
                        self.rows[i].line:SetColorTexture(color[1], color[2], color[3], 0.4)
                    end
                else
                    self.rows[i].label:SetText(category:gsub("^%l", string.upper))
                end
            end
        end
    else
        -- Just use flat list
        for i = 1, self.settings.maxRows do
            self.rows[i].label:SetText("Spell History")
            self.rows[i].line:SetColorTexture(0.3, 0.3, 0.3, 0.5)
        end
    end
end

-- Clear all spell icons
function Timeline:ClearSpellIcons()
    for _, row in ipairs(self.rows) do
        for _, icon in ipairs(row.icons) do
            icon:Hide()
        end
        wipe(row.icons)
    end
end

-- Display spells on timeline
function Timeline:DisplaySpells()
    if not self.filteredHistory or #self.filteredHistory == 0 then
        return
    end
    
    local timelineWidth = self.rows[1].timeline:GetWidth()
    local timeRange = self.timeEnd - self.timeStart
    
    -- Sort spells by time
    table.sort(self.filteredHistory, function(a, b)
        return a.time < b.time
    end)
    
    for _, spell in ipairs(self.filteredHistory) do
        -- Determine row for this spell
        local rowIndex
        
        if self.settings.categoryRows then
            rowIndex = self.categoryRows[spell.category] or self.settings.maxRows
        else
            -- For non-categorized view, just put all spells in row 1
            rowIndex = 1
        end
        
        -- Skip if row is not available
        if not self.rows[rowIndex] then
            goto continue
        end
        
        -- Calculate position on timeline
        local relativeTime = spell.time - self.timeStart
        local position = relativeTime / timeRange
        local xPos = position * timelineWidth
        
        -- Create or reuse icon
        local icon = self:GetSpellIcon(rowIndex)
        local row = self.rows[rowIndex]
        
        -- Set icon texture
        icon.texture:SetTexture(spell.icon)
        
        -- Position icon
        icon:SetPoint("LEFT", row.timeline, "LEFT", xPos - (self.settings.iconSize / 2), 0)
        
        -- Apply styling based on spell category
        self:ApplyIconStyling(icon, spell)
        
        -- Show the icon
        icon:Show()
        
        ::continue::
    end
end

-- Get a spell icon frame (create or reuse)
function Timeline:GetSpellIcon(rowIndex)
    local row = self.rows[rowIndex]
    
    -- Create new icon if needed
    if not row.icons then row.icons = {} end
    
    local icon
    for _, existingIcon in ipairs(row.icons) do
        if not existingIcon:IsShown() then
            icon = existingIcon
            break
        end
    end
    
    if not icon then
        icon = CreateFrame("Frame", nil, row.timeline)
        icon:SetSize(self.settings.iconSize, self.settings.iconSize)
        
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        
        icon.border = icon:CreateTexture(nil, "OVERLAY")
        icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        icon.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
        icon.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        
        -- Add tooltip functionality
        icon:EnableMouse(true)
        icon:SetScript("OnEnter", function(self)
            if not Timeline.settings.showTooltips then return end
            
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.spellName)
            
            -- Add category and time info
            if self.category then
                local catName = self.category:gsub("^%l", string.upper)
                GameTooltip:AddLine(catName, 1, 1, 1)
            end
            
            if self.timeText then
                GameTooltip:AddLine(self.timeText, 0.8, 0.8, 0.8)
            end
            
            GameTooltip:Show()
        end)
        
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        tinsert(row.icons, icon)
    end
    
    return icon
end

-- Apply styling to a spell icon based on category
function Timeline:ApplyIconStyling(icon, spell)
    -- Store spell information for tooltip
    icon.spellName = spell.name
    icon.category = spell.category
    icon.timeText = self:FormatTime(spell.time - self.timeStart)
    
    -- Apply border color based on category
    if self.colorMods[spell.category] then
        local color = self.colorMods[spell.category]
        icon.border:SetVertexColor(color[1], color[2], color[3], color[4])
    else
        icon.border:SetVertexColor(0.7, 0.7, 0.7, 0.8)
    end
    
    -- Apply importance-based sizing
    local sizeMultiplier = 1.0
    if spell.importance == "high" then
        sizeMultiplier = 1.2
    elseif spell.importance == "low" then
        sizeMultiplier = 0.9
    end
    
    icon:SetSize(self.settings.iconSize * sizeMultiplier, self.settings.iconSize * sizeMultiplier)
end

-- Toggle the filter menu
function Timeline:ToggleFilterMenu()
    if not self.filterMenu then
        self:CreateFilterMenu()
    end
    
    if self.filterMenu:IsShown() then
        self.filterMenu:Hide()
    else
        self.filterMenu:Show()
    end
end

-- Create filter menu
function Timeline:CreateFilterMenu()
    local menu = CreateFrame("Frame", "VUITrufiGCDTimelineFilterMenu", self.frame)
    menu:SetSize(200, 250)
    menu:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -30, -30)
    menu:SetFrameStrata("HIGH")
    menu:EnableMouse(true)
    menu:SetClampedToScreen(true)
    menu:Hide()
    
    -- Background
    menu.bg = menu:CreateTexture(nil, "BACKGROUND")
    menu.bg:SetAllPoints()
    menu.bg:SetColorTexture(0, 0, 0, 0.9)
    
    -- Border
    menu.border = CreateFrame("Frame", nil, menu, "BackdropTemplate")
    menu.border:SetPoint("TOPLEFT", -1, 1)
    menu.border:SetPoint("BOTTOMRIGHT", 1, -1)
    menu.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    menu.border:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Title
    menu.title = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    menu.title:SetPoint("TOPLEFT", menu, "TOPLEFT", 10, -10)
    menu.title:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -10, -10)
    menu.title:SetJustifyH("CENTER")
    menu.title:SetText("Timeline Filters")
    
    -- Create category checkboxes
    local categories = {
        "cooldowns",
        "defensive",
        "offensive",
        "healing",
        "interrupts",
        "dispels",
        "utility",
        "standard"
    }
    
    menu.checkboxes = {}
    local yOffset = -40
    
    for i, category in ipairs(categories) do
        -- Create checkbox
        local checkbox = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")
        checkbox:SetSize(20, 20)
        checkbox:SetPoint("TOPLEFT", menu, "TOPLEFT", 20, yOffset)
        checkbox:SetChecked(true) -- Default to enabled
        
        -- Category name
        local catName = category:gsub("^%l", string.upper)
        checkbox.text = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.text:SetText(catName)
        
        -- Color swatch
        checkbox.swatch = menu:CreateTexture(nil, "ARTWORK")
        checkbox.swatch:SetSize(14, 14)
        checkbox.swatch:SetPoint("LEFT", checkbox.text, "RIGHT", 5, 0)
        
        if self.colorMods[category] then
            local color = self.colorMods[category]
            checkbox.swatch:SetColorTexture(color[1], color[2], color[3], color[4])
        else
            checkbox.swatch:SetColorTexture(0.7, 0.7, 0.7, 0.8)
        end
        
        -- Store in menu
        menu.checkboxes[category] = checkbox
        
        -- Update on click
        checkbox:SetScript("OnClick", function(self)
            -- Implementation for category filtering would go here
            -- For now, we'll just refresh the display
            Timeline:RefreshDisplay()
        end)
        
        yOffset = yOffset - 22
    end
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOM", menu, "BOTTOM", 0, 15)
    closeButton:SetText("Close")
    
    closeButton:SetScript("OnClick", function()
        menu:Hide()
    end)
    
    self.filterMenu = menu
end

-- Initialize the timeline when the module loads
function VUI.TrufiGCD:InitializeTimeline()
    -- Create timeline object
    Timeline:Initialize()
    
    -- Add timeline toggle button to TrufiGCD options
    self:AddTimelineToggleToOptions()
end

-- Add timeline toggle to TrufiGCD options
function VUI.TrufiGCD:AddTimelineToggleToOptions()
    -- Only add if config is available
    if not self.GetConfig then return end
    
    local originalGetConfig = self.GetConfig
    
    self.GetConfig = function(self)
        local config = originalGetConfig(self)
        
        -- Add timeline toggle button
        config.args.timelineToggle = {
            type = "execute",
            name = "Show Timeline",
            desc = "Open the spell history timeline view",
            func = function() Timeline:ToggleTimeline() end,
            order = 5 -- Position near the top
        }
        
        return config
    end
end