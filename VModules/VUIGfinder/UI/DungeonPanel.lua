-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module: DungeonPanel - Panel for dungeon filtering
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L
local C = VUIGfinder.C

-- Create the DungeonPanel submodule
VUIGfinder.DungeonPanel = {}
local DungeonPanel = VUIGfinder.DungeonPanel

-- Initialize the panel
function DungeonPanel:Initialize(parentFrame)
    if not self.frame then
        self:CreateFrame(parentFrame)
    end
    
    self:UpdateControls()
end

-- Create the panel frame and controls
function DungeonPanel:CreateFrame(parentFrame)
    -- Main frame
    self.frame = CreateFrame("Frame", nil, parentFrame)
    self.frame:SetAllPoints()
    
    -- Title
    self.title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.title:SetPoint("TOPLEFT", 10, -10)
    self.title:SetText(L["Dungeon"])
    
    -- Difficulty section
    self:CreateDifficultySection()
    
    -- Mythic+ section
    self:CreateMythicPlusSection()
    
    -- Group composition section
    self:CreateGroupCompositionSection()
    
    -- Role requirements section
    self:CreateRoleRequirementsSection()
    
    -- Additional filters section
    self:CreateAdditionalFiltersSection()
end

-- Create the difficulty filter section
function DungeonPanel:CreateDifficultySection()
    -- Section title
    local sectionTitle = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -15)
    sectionTitle:SetText(L["Difficulty"])
    
    -- Create checkbox for each difficulty
    local difficulties = {
        { id = "normal", label = L["Normal"], difficulty = C.NORMAL },
        { id = "heroic", label = L["Heroic"], difficulty = C.HEROIC },
        { id = "mythic", label = L["Mythic"], difficulty = C.MYTHIC },
        { id = "mythicplus", label = L["Mythic+"], difficulty = C.MYTHICPLUS }
    }
    
    self.difficultyCheckboxes = {}
    
    for i, info in ipairs(difficulties) do
        local checkbox = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
        checkbox:SetSize(24, 24)
        
        if i == 1 then
            checkbox:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -5)
        else
            checkbox:SetPoint("TOPLEFT", self.difficultyCheckboxes[i-1], "TOPRIGHT", 70, 0)
        end
        
        checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.text:SetText(info.label)
        
        -- Set initial state based on min/max difficulty
        local minDiff = Module.db.profile.dungeon.minimumDifficulty
        local maxDiff = Module.db.profile.dungeon.maximumDifficulty
        checkbox:SetChecked(info.difficulty >= minDiff and info.difficulty <= maxDiff)
        
        -- Update on click
        checkbox:SetScript("OnClick", function()
            self:UpdateDifficultySettings()
        end)
        
        -- Store reference
        self.difficultyCheckboxes[i] = checkbox
        checkbox.info = info
    end
end

-- Create the Mythic+ level filter section
function DungeonPanel:CreateMythicPlusSection()
    -- Section title
    local sectionTitle = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", self.difficultyCheckboxes[1], "BOTTOMLEFT", 0, -20)
    sectionTitle:SetText(L["Mythic+ Level"])
    
    -- Min level slider
    self.minLevelSlider = CreateFrame("Slider", nil, self.frame, "OptionsSliderTemplate")
    self.minLevelSlider:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -25)
    self.minLevelSlider:SetWidth(150)
    self.minLevelSlider:SetMinMaxValues(2, 30)
    self.minLevelSlider:SetValueStep(1)
    self.minLevelSlider:SetObeyStepOnDrag(true)
    self.minLevelSlider.Low:SetText("2")
    self.minLevelSlider.High:SetText("30")
    self.minLevelSlider:SetValue(Module.db.profile.dungeon.minMythicPlusLevel)
    self.minLevelSlider.Text:SetText(L["Min Mythic+ Level"] .. ": " .. Module.db.profile.dungeon.minMythicPlusLevel)
    
    self.minLevelSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer
        value = math.floor(value + 0.5)
        Module.db.profile.dungeon.minMythicPlusLevel = value
        self.Text:SetText(L["Min Mythic+ Level"] .. ": " .. value)
        
        -- Ensure max >= min
        if Module.db.profile.dungeon.maxMythicPlusLevel < value then
            Module.db.profile.dungeon.maxMythicPlusLevel = value
            DungeonPanel.maxLevelSlider:SetValue(value)
        end
    end)
    
    -- Max level slider
    self.maxLevelSlider = CreateFrame("Slider", nil, self.frame, "OptionsSliderTemplate")
    self.maxLevelSlider:SetPoint("TOPLEFT", self.minLevelSlider, "BOTTOMLEFT", 0, -25)
    self.maxLevelSlider:SetWidth(150)
    self.maxLevelSlider:SetMinMaxValues(2, 30)
    self.maxLevelSlider:SetValueStep(1)
    self.maxLevelSlider:SetObeyStepOnDrag(true)
    self.maxLevelSlider.Low:SetText("2")
    self.maxLevelSlider.High:SetText("30")
    self.maxLevelSlider:SetValue(Module.db.profile.dungeon.maxMythicPlusLevel)
    self.maxLevelSlider.Text:SetText(L["Max Mythic+ Level"] .. ": " .. Module.db.profile.dungeon.maxMythicPlusLevel)
    
    self.maxLevelSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer
        value = math.floor(value + 0.5)
        Module.db.profile.dungeon.maxMythicPlusLevel = value
        self.Text:SetText(L["Max Mythic+ Level"] .. ": " .. value)
        
        -- Ensure min <= max
        if Module.db.profile.dungeon.minMythicPlusLevel > value then
            Module.db.profile.dungeon.minMythicPlusLevel = value
            DungeonPanel.minLevelSlider:SetValue(value)
        end
    end)
end

-- Create the group composition section
function DungeonPanel:CreateGroupCompositionSection()
    -- Section title
    local sectionTitle = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", self.maxLevelSlider, "BOTTOMLEFT", 0, -25)
    sectionTitle:SetText(L["Group Composition"])
    
    -- Members slider
    self.minMembersSlider = CreateFrame("Slider", nil, self.frame, "OptionsSliderTemplate")
    self.minMembersSlider:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -25)
    self.minMembersSlider:SetWidth(150)
    self.minMembersSlider:SetMinMaxValues(1, 5)
    self.minMembersSlider:SetValueStep(1)
    self.minMembersSlider:SetObeyStepOnDrag(true)
    self.minMembersSlider.Low:SetText("1")
    self.minMembersSlider.High:SetText("5")
    self.minMembersSlider:SetValue(Module.db.profile.dungeon.minMembers or 1)
    self.minMembersSlider.Text:SetText(L["Min Members"] .. ": " .. (Module.db.profile.dungeon.minMembers or 1))
    
    self.minMembersSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer
        value = math.floor(value + 0.5)
        Module.db.profile.dungeon.minMembers = value
        self.Text:SetText(L["Min Members"] .. ": " .. value)
        
        -- Ensure max >= min
        if (Module.db.profile.dungeon.maxMembers or 5) < value then
            Module.db.profile.dungeon.maxMembers = value
            DungeonPanel.maxMembersSlider:SetValue(value)
        end
    end)
    
    -- Max members slider
    self.maxMembersSlider = CreateFrame("Slider", nil, self.frame, "OptionsSliderTemplate")
    self.maxMembersSlider:SetPoint("TOPLEFT", self.minMembersSlider, "BOTTOMLEFT", 0, -25)
    self.maxMembersSlider:SetWidth(150)
    self.maxMembersSlider:SetMinMaxValues(1, 5)
    self.maxMembersSlider:SetValueStep(1)
    self.maxMembersSlider:SetObeyStepOnDrag(true)
    self.maxMembersSlider.Low:SetText("1")
    self.maxMembersSlider.High:SetText("5")
    self.maxMembersSlider:SetValue(Module.db.profile.dungeon.maxMembers or 5)
    self.maxMembersSlider.Text:SetText(L["Max Members"] .. ": " .. (Module.db.profile.dungeon.maxMembers or 5))
    
    self.maxMembersSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer
        value = math.floor(value + 0.5)
        Module.db.profile.dungeon.maxMembers = value
        self.Text:SetText(L["Max Members"] .. ": " .. value)
        
        -- Ensure min <= max
        if (Module.db.profile.dungeon.minMembers or 1) > value then
            Module.db.profile.dungeon.minMembers = value
            DungeonPanel.minMembersSlider:SetValue(value)
        end
    end)
end

-- Create role requirements section
function DungeonPanel:CreateRoleRequirementsSection()
    -- Section title
    local sectionTitle = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", self.minLevelSlider, "TOPRIGHT", 50, 0)
    sectionTitle:SetText(L["Role Requirements"])
    
    -- Create checkbox for each role
    local roles = {
        { id = "tank", label = L["Tank"] },
        { id = "healer", label = L["Healer"] },
        { id = "dps", label = L["DPS"] }
    }
    
    self.roleCheckboxes = {}
    
    for i, info in ipairs(roles) do
        local checkbox = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
        checkbox:SetSize(24, 24)
        
        if i == 1 then
            checkbox:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -5)
        else
            checkbox:SetPoint("TOPLEFT", self.roleCheckboxes[i-1], "BOTTOMLEFT", 0, -5)
        end
        
        checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.text:SetText(info.label)
        
        -- Set initial state
        checkbox:SetChecked(Module.db.profile.dungeon["filterRole" .. info.id:gsub("^%l", string.upper)])
        
        -- Update on click
        checkbox:SetScript("OnClick", function(self)
            Module.db.profile.dungeon["filterRole" .. info.id:gsub("^%l", string.upper)] = self:GetChecked()
        end)
        
        -- Store reference
        self.roleCheckboxes[i] = checkbox
        checkbox.info = info
    end
end

-- Create additional filters section
function DungeonPanel:CreateAdditionalFiltersSection()
    -- Section title
    local sectionTitle = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", self.maxMembersSlider, "BOTTOMLEFT", 0, -25)
    sectionTitle:SetText(L["Additional Filters"])
    
    -- Create various filter checkboxes
    local filters = {
        { id = "noFullGroups", label = L["Hide Full Groups"] },
        { id = "hideVoiceChat", label = L["Hide Voice Chat Required"] },
        { id = "showLeaderScore", label = L["Show Leader Score"] }
    }
    
    self.filterCheckboxes = {}
    
    for i, info in ipairs(filters) do
        local checkbox = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
        checkbox:SetSize(24, 24)
        
        if i == 1 then
            checkbox:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -5)
        else
            checkbox:SetPoint("TOPLEFT", self.filterCheckboxes[i-1], "BOTTOMLEFT", 0, -5)
        end
        
        checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.text:SetText(info.label)
        
        -- Set initial state
        checkbox:SetChecked(Module.db.profile.dungeon[info.id])
        
        -- Update on click
        checkbox:SetScript("OnClick", function(self)
            Module.db.profile.dungeon[info.id] = self:GetChecked()
        end)
        
        -- Store reference
        self.filterCheckboxes[i] = checkbox
        checkbox.info = info
    end
end

-- Update difficulty settings based on checkboxes
function DungeonPanel:UpdateDifficultySettings()
    local minDifficulty = C.MYTHICPLUS -- Start with highest
    local maxDifficulty = C.NORMAL -- Start with lowest
    
    -- Find the min and max selected difficulties
    for i, checkbox in ipairs(self.difficultyCheckboxes) do
        if checkbox:GetChecked() then
            minDifficulty = math.min(minDifficulty, checkbox.info.difficulty)
            maxDifficulty = math.max(maxDifficulty, checkbox.info.difficulty)
        end
    end
    
    -- Ensure at least one checkbox is checked
    if maxDifficulty < minDifficulty then
        -- If none checked, check the Normal one
        self.difficultyCheckboxes[1]:SetChecked(true)
        minDifficulty = C.NORMAL
        maxDifficulty = C.NORMAL
    end
    
    -- Update settings
    Module.db.profile.dungeon.minimumDifficulty = minDifficulty
    Module.db.profile.dungeon.maximumDifficulty = maxDifficulty
end

-- Update all controls based on current settings
function DungeonPanel:UpdateControls()
    -- Update difficulty checkboxes
    for i, checkbox in ipairs(self.difficultyCheckboxes) do
        local minDiff = Module.db.profile.dungeon.minimumDifficulty
        local maxDiff = Module.db.profile.dungeon.maximumDifficulty
        checkbox:SetChecked(checkbox.info.difficulty >= minDiff and checkbox.info.difficulty <= maxDiff)
    end
    
    -- Update Mythic+ sliders
    self.minLevelSlider:SetValue(Module.db.profile.dungeon.minMythicPlusLevel)
    self.maxLevelSlider:SetValue(Module.db.profile.dungeon.maxMythicPlusLevel)
    
    -- Update group size sliders
    self.minMembersSlider:SetValue(Module.db.profile.dungeon.minMembers or 1)
    self.maxMembersSlider:SetValue(Module.db.profile.dungeon.maxMembers or 5)
    
    -- Update role checkboxes
    for i, checkbox in ipairs(self.roleCheckboxes) do
        checkbox:SetChecked(Module.db.profile.dungeon["filterRole" .. checkbox.info.id:gsub("^%l", string.upper)])
    end
    
    -- Update filter checkboxes
    for i, checkbox in ipairs(self.filterCheckboxes) do
        checkbox:SetChecked(Module.db.profile.dungeon[checkbox.info.id])
    end
end

-- Get an expression string representing the current filters
function DungeonPanel:GetExpression()
    local expr = {}
    
    -- Difficulty filter
    if Module.db.profile.dungeon.minimumDifficulty == Module.db.profile.dungeon.maximumDifficulty then
        -- Single difficulty selected
        table.insert(expr, string.format("difficulty == %d", Module.db.profile.dungeon.minimumDifficulty))
    else
        -- Range of difficulties
        table.insert(expr, string.format("difficulty >= %d and difficulty <= %d", 
            Module.db.profile.dungeon.minimumDifficulty, 
            Module.db.profile.dungeon.maximumDifficulty))
    end
    
    -- Mythic+ level filter (only if M+ is selected)
    if Module.db.profile.dungeon.maximumDifficulty >= C.MYTHICPLUS then
        table.insert(expr, string.format("mythicplus >= %d and mythicplus <= %d",
            Module.db.profile.dungeon.minMythicPlusLevel,
            Module.db.profile.dungeon.maxMythicPlusLevel))
    end
    
    -- Group size filter
    if Module.db.profile.dungeon.minMembers or Module.db.profile.dungeon.maxMembers then
        local minMembers = Module.db.profile.dungeon.minMembers or 1
        local maxMembers = Module.db.profile.dungeon.maxMembers or 5
        
        table.insert(expr, string.format("members >= %d and members <= %d", minMembers, maxMembers))
    end
    
    -- Role filters
    local roleFilters = {}
    if Module.db.profile.dungeon.filterRoleTank then
        table.insert(roleFilters, "tankrequired")
    end
    if Module.db.profile.dungeon.filterRoleHealer then
        table.insert(roleFilters, "healerrequired")
    end
    if Module.db.profile.dungeon.filterRoleDPS then
        table.insert(roleFilters, "dpsrequired")
    end
    
    if #roleFilters > 0 then
        table.insert(expr, table.concat(roleFilters, " or "))
    end
    
    -- Additional filters
    if Module.db.profile.dungeon.noFullGroups then
        table.insert(expr, "not full")
    end
    
    if Module.db.profile.dungeon.hideVoiceChat then
        table.insert(expr, "not voicechat")
    end
    
    -- Combine all expressions with AND
    return table.concat(expr, " and ")
end

-- Reset filters to default values
function DungeonPanel:ResetFilters()
    -- Reset to default values
    Module.db.profile.dungeon.minimumDifficulty = C.NORMAL
    Module.db.profile.dungeon.maximumDifficulty = C.MYTHICPLUS
    Module.db.profile.dungeon.minMythicPlusLevel = 2
    Module.db.profile.dungeon.maxMythicPlusLevel = 30
    Module.db.profile.dungeon.minMembers = 1
    Module.db.profile.dungeon.maxMembers = 5
    Module.db.profile.dungeon.filterRoleTank = false
    Module.db.profile.dungeon.filterRoleHealer = false
    Module.db.profile.dungeon.filterRoleDPS = false
    Module.db.profile.dungeon.noFullGroups = false
    Module.db.profile.dungeon.hideVoiceChat = false
    Module.db.profile.dungeon.showLeaderScore = true
    
    -- Update UI
    self:UpdateControls()
end