-- MoveAny Core Implementation
-- This file contains the core logic for the MoveAny module
local _, VUI = ...
local MoveAny = VUI.modules.moveany

-- Utility Functions

-- Function to find a frame by name, supporting parent.child notation
function MoveAny:FindFrame(frameName)
    -- Check if the frame already exists
    local frame = _G[frameName]
    if frame then return frame end
    
    -- Handle parent.child notation
    if frameName:find("%.") then
        local parts = {}
        for part in frameName:gmatch("[^%.]+") do
            table.insert(parts, part)
        end
        
        -- Start with the first part
        local currentFrame = _G[parts[1]]
        if not currentFrame then return nil end
        
        -- Navigate through children
        for i = 2, #parts do
            if currentFrame[parts[i]] then
                currentFrame = currentFrame[parts[i]]
            else
                return nil -- Child not found
            end
        end
        
        return currentFrame
    end
    
    return nil
end

-- Function to snap a frame to the nearest grid line
function MoveAny:SnapToGrid(frame)
    if not frame or not VUI.db.profile.modules.moveany.snapToGrid then return end
    
    local gridSize = VUI.db.profile.modules.moveany.gridSize or 32
    local threshold = VUI.db.profile.modules.moveany.snapThreshold or 10
    
    -- Get current position
    local scale = frame:GetScale()
    local x, y = frame:GetCenter()
    
    if not x or not y then return end
    
    -- Calculate closest grid positions
    local gridX = math.floor(x / gridSize + 0.5) * gridSize
    local gridY = math.floor(y / gridSize + 0.5) * gridSize
    
    -- Check if within threshold
    if math.abs(x - gridX) <= threshold / scale and math.abs(y - gridY) <= threshold / scale then
        -- Snap to grid
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", gridX, gridY)
    end
end

-- Function to register a frame by name
function MoveAny:RegisterFrameByName(frameName)
    if not frameName then return end
    
    local frame = self:FindFrame(frameName)
    if frame then
        self:RegisterFrame(frame, frameName)
        return true
    else
        -- Frame doesn't exist yet, register for when it's created
        self:RegisterDelayedFrame(frameName)
        return false
    end
end

-- Function to register a frame after it's created
function MoveAny:RegisterDelayedFrame(frameName)
    if not self.delayedFrames then
        self.delayedFrames = {}
        
        -- Create a frame to periodically check for delayed frames
        self.delayedCheckFrame = CreateFrame("Frame")
        self.delayedCheckFrame:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = (self.elapsed or 0) + elapsed
            if self.elapsed < 1 then return end
            self.elapsed = 0
            
            -- Check each delayed frame
            for name, _ in pairs(MoveAny.delayedFrames) do
                local frame = MoveAny:FindFrame(name)
                if frame then
                    MoveAny:RegisterFrame(frame, name)
                    MoveAny.delayedFrames[name] = nil
                end
            end
            
            -- Stop checking if no more delayed frames
            if not next(MoveAny.delayedFrames) then
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
    
    self.delayedFrames[frameName] = true
    self.delayedCheckFrame:SetScript("OnUpdate", self.delayedCheckFrame:GetScript("OnUpdate"))
end

-- Function to scale a frame to a specific size
function MoveAny:ScaleFrame(frame, name, scale)
    if not frame or not name then return end
    
    -- Set the new scale
    frame:SetScale(scale)
    
    -- Update saved position with new scale
    self:SavePosition(frame, name)
    
    -- Update the frame's anchor if it exists
    if self.anchors[name] then
        self.anchors[name]:ClearAllPoints()
        self.anchors[name]:SetPoint("CENTER", frame, "CENTER")
    end
end

-- Function to create a control panel for a frame
function MoveAny:CreateFrameControlPanel(name)
    if not name or not self.registered[name] then return end
    
    local frame = self.registered[name]
    local savedData = VUI.db.profile.modules.moveany.savedFrames[name] or {}
    
    -- Create a configuration dialog
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Configure " .. name)
    dialog:SetLayout("Flow")
    dialog:SetWidth(300)
    dialog:SetHeight(250)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetWidth(280)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(savedData.scale or frame:GetScale())
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self:ScaleFrame(frame, name, value)
    end)
    dialog:AddChild(scaleSlider)
    
    -- Alpha slider
    local alphaSlider = AceGUI:Create("Slider")
    alphaSlider:SetLabel("Alpha")
    alphaSlider:SetWidth(280)
    alphaSlider:SetSliderValues(0.1, 1.0, 0.05)
    alphaSlider:SetValue(savedData.alpha or frame:GetAlpha())
    alphaSlider:SetCallback("OnValueChanged", function(widget, event, value)
        frame:SetAlpha(value)
        savedData.alpha = value
        VUI.db.profile.modules.moveany.savedFrames[name] = savedData
    end)
    dialog:AddChild(alphaSlider)
    
    -- Strata dropdown
    local strataDropdown = AceGUI:Create("Dropdown")
    strataDropdown:SetLabel("Frame Strata")
    strataDropdown:SetWidth(280)
    strataDropdown:SetList({
        ["BACKGROUND"] = "Background",
        ["LOW"] = "Low",
        ["MEDIUM"] = "Medium",
        ["HIGH"] = "High",
        ["DIALOG"] = "Dialog",
        ["FULLSCREEN"] = "Fullscreen",
        ["FULLSCREEN_DIALOG"] = "Fullscreen Dialog",
        ["TOOLTIP"] = "Tooltip"
    })
    strataDropdown:SetValue(savedData.strata or frame:GetFrameStrata())
    strataDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        frame:SetFrameStrata(value)
        savedData.strata = value
        VUI.db.profile.modules.moveany.savedFrames[name] = savedData
    end)
    dialog:AddChild(strataDropdown)
    
    -- Reset button
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset Position")
    resetButton:SetWidth(280)
    resetButton:SetCallback("OnClick", function()
        self:ResetPosition(name)
        dialog:Hide()
    end)
    dialog:AddChild(resetButton)
    
    -- Hide button
    local hideButton = AceGUI:Create("Button")
    hideButton:SetText("Close")
    hideButton:SetWidth(280)
    hideButton:SetCallback("OnClick", function()
        dialog:Hide()
    end)
    dialog:AddChild(hideButton)
    
    return dialog
end

-- Function to check if a frame can be moved safely
function MoveAny:CanMove(frame)
    -- Don't move frames in combat if they're protected
    if InCombatLockdown() and frame:IsProtected() then
        return false
    end
    
    return true
end

-- Function to list all known frames
function MoveAny:ListKnownFrames()
    local result = {}
    
    -- Add all registered frames
    for name, _ in pairs(self.registered) do
        table.insert(result, name)
    end
    
    -- Add common Blizzard frames that might not be registered yet
    local commonFrames = {
        "PlayerFrame", "TargetFrame", "FocusFrame", "MinimapCluster",
        "MainMenuBar", "ChatFrame1", "ChatFrame2", "BuffFrame",
        "QuestWatchFrame", "DurabilityFrame", "VehicleSeatIndicator",
        "GroupLootContainer", "UIWidgetTopCenterContainerFrame",
        "ObjectiveTrackerFrame", "GameTooltip", "WorldMapFrame",
        "MirrorTimer1", "CastingBarFrame", "QuestTimerFrame"
    }
    
    -- Add frames from common Blizzard addons
    local blizzardAddons = {
        "AchievementFrame", "CalendarFrame", "InspectFrame", "ItemSocketingFrame",
        "AuctionHouseFrame", "CollectionsJournal", "EncounterJournal", "GuildFrame",
        "LFGParentFrame", "PVPMatchScoreboard", "TradeSkillFrame", "ClassTrainerFrame"
    }
    
    -- Merge all frame lists
    for _, frameName in ipairs(commonFrames) do
        if not tContains(result, frameName) and _G[frameName] then
            table.insert(result, frameName)
        end
    end
    
    for _, frameName in ipairs(blizzardAddons) do
        if not tContains(result, frameName) and _G[frameName] then
            table.insert(result, frameName)
        end
    end
    
    -- Sort alphabetically
    table.sort(result)
    
    return result
end

-- Function to apply scale adjustments to a frame
function MoveAny:ApplyScaling(frame, name)
    if not frame or not name then return end
    
    local scaling = VUI.db.profile.modules.moveany.frameScaling[name]
    if not scaling then return end
    
    -- Apply stored scale
    if scaling.scale and scaling.scale ~= frame:GetScale() then
        frame:SetScale(scaling.scale)
    end
    
    -- Apply stored alpha
    if scaling.alpha and scaling.alpha ~= frame:GetAlpha() then
        frame:SetAlpha(scaling.alpha)
    end
    
    -- Apply stored strata
    if scaling.strata and scaling.strata ~= frame:GetFrameStrata() then
        frame:SetFrameStrata(scaling.strata)
    end
end

-- Function to integrate with other VUI modules
function MoveAny:IntegrateWithModules()
    -- Register frames from other VUI modules
    local modules = {
        "buffoverlay", "trufigcd", "auctionator", "angrykeystone", "omnicc", "omnicd"
    }
    
    for _, moduleName in ipairs(modules) do
        local module = VUI.modules[moduleName]
        if module and module.container then
            self:RegisterFrame(module.container, moduleName .. "Container")
        end
    end
end

-- Function to create a button to toggle move mode
function MoveAny:CreateToggleButton()
    if self.toggleButton then return end
    
    -- Create button frame
    self.toggleButton = CreateFrame("Button", "VUIMoveAnyToggleButton", UIParent, "UIPanelButtonTemplate")
    self.toggleButton:SetSize(120, 30)
    self.toggleButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -100)
    self.toggleButton:SetText("Move Frames")
    self.toggleButton:SetFrameStrata("HIGH")
    
    -- Set script handlers
    self.toggleButton:SetScript("OnClick", function()
        if VUI.db.profile.modules.moveany.lockFrames then
            MoveAny:UnlockFrames()
        else
            MoveAny:LockFrames()
        end
    end)
    
    -- Register the button with itself
    self:RegisterFrame(self.toggleButton, "MoveAnyToggleButton")
end

-- Function to create a dialog to add custom frames
function MoveAny:CreateAddFrameDialog()
    -- Create dialog using AceGUI
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Add Frame to MoveAny")
    dialog:SetLayout("Flow")
    dialog:SetWidth(400)
    dialog:SetHeight(300)
    
    -- Add instructions
    local instructions = AceGUI:Create("Label")
    instructions:SetText("Enter the name of a frame to make it movable")
    instructions:SetFullWidth(true)
    dialog:AddChild(instructions)
    
    -- Add frame name input
    local input = AceGUI:Create("EditBox")
    input:SetLabel("Frame Name")
    input:SetFullWidth(true)
    dialog:AddChild(input)
    
    -- Add button to register the frame
    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add Frame")
    addButton:SetWidth(180)
    addButton:SetCallback("OnClick", function()
        local frameName = input:GetText()
        if frameName and frameName ~= "" then
            if MoveAny:RegisterFrameByName(frameName) then
                VUI:Print("Added frame: " .. frameName)
            else
                VUI:Print("Frame not found: " .. frameName .. ". It will be registered when created.")
            end
        end
    end)
    dialog:AddChild(addButton)
    
    -- Add button to close dialog
    local closeButton = AceGUI:Create("Button")
    closeButton:SetText("Close")
    closeButton:SetWidth(180)
    closeButton:SetCallback("OnClick", function()
        dialog:Hide()
    end)
    dialog:AddChild(closeButton)
    
    -- Add a list of common frames
    local frameList = AceGUI:Create("Dropdown")
    frameList:SetLabel("Common Frames")
    frameList:SetFullWidth(true)
    
    -- Populate the dropdown with common frames
    local frameOptions = {}
    for _, frameName in ipairs(self:ListKnownFrames()) do
        frameOptions[frameName] = frameName
    end
    frameList:SetList(frameOptions)
    frameList:SetCallback("OnValueChanged", function(_, _, value)
        input:SetText(value)
    end)
    
    dialog:AddChild(frameList)
    
    return dialog
end
