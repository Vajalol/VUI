-- MoveAny Config Implementation
-- This file contains the configuration options for the MoveAny module
local _, VUI = ...
local MoveAny = VUI.modules.moveany
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function MoveAny:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI MoveAny Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Frames", value = "frames"},
        {text = "Advanced", value = "advanced"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "frames" then
            self:CreateFramesTab(container)
        elseif group == "advanced" then
            self:CreateAdvancedTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function MoveAny:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable MoveAny")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("moveany"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("moveany")
        else
            VUI:DisableModule("moveany")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Lock/unlock toggle
    local lockCheckbox = AceGUI:Create("CheckBox")
    lockCheckbox:SetLabel("Lock Frames")
    lockCheckbox:SetWidth(200)
    lockCheckbox:SetValue(VUI.db.profile.modules.moveany.lockFrames)
    lockCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.lockFrames = value
        if value then
            MoveAny:LockFrames()
        else
            MoveAny:UnlockFrames()
        end
    end)
    container:AddChild(lockCheckbox)
    
    -- Show grid toggle
    local gridCheckbox = AceGUI:Create("CheckBox")
    gridCheckbox:SetLabel("Show Grid")
    gridCheckbox:SetWidth(200)
    gridCheckbox:SetValue(VUI.db.profile.modules.moveany.showGrid)
    gridCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.showGrid = value
        if value and not VUI.db.profile.modules.moveany.lockFrames then
            MoveAny.gridFrame:Show()
        else
            MoveAny.gridFrame:Hide()
        end
    end)
    container:AddChild(gridCheckbox)
    
    -- Grid size slider
    local gridSizeSlider = AceGUI:Create("Slider")
    gridSizeSlider:SetLabel("Grid Size")
    gridSizeSlider:SetWidth(300)
    gridSizeSlider:SetSliderValues(8, 64, 4)
    gridSizeSlider:SetValue(VUI.db.profile.modules.moveany.gridSize)
    gridSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.gridSize = value
        MoveAny:UpdateGrid()
    end)
    container:AddChild(gridSizeSlider)
    
    -- Snap to grid toggle
    local snapCheckbox = AceGUI:Create("CheckBox")
    snapCheckbox:SetLabel("Snap to Grid")
    snapCheckbox:SetWidth(200)
    snapCheckbox:SetValue(VUI.db.profile.modules.moveany.snapToGrid)
    snapCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.snapToGrid = value
    end)
    container:AddChild(snapCheckbox)
    
    -- Snap threshold slider
    local thresholdSlider = AceGUI:Create("Slider")
    thresholdSlider:SetLabel("Snap Threshold")
    thresholdSlider:SetWidth(300)
    thresholdSlider:SetSliderValues(1, 20, 1)
    thresholdSlider:SetValue(VUI.db.profile.modules.moveany.snapThreshold)
    thresholdSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.snapThreshold = value
    end)
    container:AddChild(thresholdSlider)
    
    -- Show tooltips toggle
    local tooltipsCheckbox = AceGUI:Create("CheckBox")
    tooltipsCheckbox:SetLabel("Show Tooltips")
    tooltipsCheckbox:SetWidth(200)
    tooltipsCheckbox:SetValue(VUI.db.profile.modules.moveany.showTooltips)
    tooltipsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.showTooltips = value
        MoveAny:UpdateSettings()
    end)
    container:AddChild(tooltipsCheckbox)
    
    -- Button to lock/unlock frames
    local toggleButton = AceGUI:Create("Button")
    toggleButton:SetText(VUI.db.profile.modules.moveany.lockFrames and "Unlock Frames" or "Lock Frames")
    toggleButton:SetWidth(200)
    toggleButton:SetCallback("OnClick", function()
        if VUI.db.profile.modules.moveany.lockFrames then
            MoveAny:UnlockFrames()
            toggleButton:SetText("Lock Frames")
        else
            MoveAny:LockFrames()
            toggleButton:SetText("Unlock Frames")
        end
        lockCheckbox:SetValue(VUI.db.profile.modules.moveany.lockFrames)
    end)
    container:AddChild(toggleButton)
    
    -- Button to reset all frames
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset All Frames")
    resetButton:SetWidth(200)
    resetButton:SetCallback("OnClick", function()
        StaticPopupDialogs["VUI_MOVEANY_RESET_ALL"] = {
            text = "Are you sure you want to reset all frame positions to default?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                VUI.db.profile.modules.moveany.savedFrames = {}
                for name, frame in pairs(MoveAny.registered) do
                    MoveAny:ResetPosition(name)
                end
                VUI:Print("All frame positions have been reset")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_MOVEANY_RESET_ALL")
    end)
    container:AddChild(resetButton)
end

-- Create the Frames tab
function MoveAny:CreateFramesTab(container)
    -- Create a scroll frame to display the list of frames
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)
    
    -- Add instructions
    local instructions = AceGUI:Create("Label")
    instructions:SetText("List of registered frames that can be moved:")
    instructions:SetFullWidth(true)
    scroll:AddChild(instructions)
    
    -- Add button to add a custom frame
    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add Custom Frame")
    addButton:SetWidth(200)
    addButton:SetCallback("OnClick", function()
        local dialog = MoveAny:CreateAddFrameDialog()
        dialog:Show()
    end)
    scroll:AddChild(addButton)
    
    -- Create a header for the frame list
    local header = AceGUI:Create("SimpleGroup")
    header:SetLayout("Flow")
    header:SetFullWidth(true)
    header:SetHeight(24)
    
    local nameHeader = AceGUI:Create("Label")
    nameHeader:SetText("Frame Name")
    nameHeader:SetWidth(200)
    header:AddChild(nameHeader)
    
    local statusHeader = AceGUI:Create("Label")
    statusHeader:SetText("Status")
    statusHeader:SetWidth(100)
    header:AddChild(statusHeader)
    
    local actionsHeader = AceGUI:Create("Label")
    actionsHeader:SetText("Actions")
    actionsHeader:SetWidth(200)
    header:AddChild(actionsHeader)
    
    scroll:AddChild(header)
    
    -- Sort frame names
    local frameNames = {}
    for name, _ in pairs(self.registered) do
        table.insert(frameNames, name)
    end
    table.sort(frameNames)
    
    -- Create a row for each registered frame
    for _, name in ipairs(frameNames) do
        local row = AceGUI:Create("SimpleGroup")
        row:SetLayout("Flow")
        row:SetFullWidth(true)
        row:SetHeight(30)
        
        local frameName = AceGUI:Create("Label")
        frameName:SetText(name)
        frameName:SetWidth(200)
        row:AddChild(frameName)
        
        local frameStatus = AceGUI:Create("Label")
        frameStatus:SetText(VUI.db.profile.modules.moveany.savedFrames[name] and "Modified" or "Default")
        frameStatus:SetWidth(100)
        row:AddChild(frameStatus)
        
        local resetButton = AceGUI:Create("Button")
        resetButton:SetText("Reset")
        resetButton:SetWidth(80)
        resetButton:SetCallback("OnClick", function()
            MoveAny:ResetPosition(name)
            frameStatus:SetText("Default")
        end)
        row:AddChild(resetButton)
        
        local configButton = AceGUI:Create("Button")
        configButton:SetText("Configure")
        configButton:SetWidth(100)
        configButton:SetCallback("OnClick", function()
            local dialog = MoveAny:CreateFrameControlPanel(name)
            dialog:Show()
        end)
        row:AddChild(configButton)
        
        scroll:AddChild(row)
    end
    
    -- If no frames registered, show a message
    if #frameNames == 0 then
        local noFrames = AceGUI:Create("Label")
        noFrames:SetText("No frames have been registered yet.")
        noFrames:SetFullWidth(true)
        scroll:AddChild(noFrames)
    end
end

-- Create the Advanced tab
function MoveAny:CreateAdvancedTab(container)
    -- Add persistent toggle button settings
    local toggleButtonCheckbox = AceGUI:Create("CheckBox")
    toggleButtonCheckbox:SetLabel("Show Toggle Button")
    toggleButtonCheckbox:SetWidth(200)
    toggleButtonCheckbox:SetValue(VUI.db.profile.modules.moveany.showToggleButton)
    toggleButtonCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.showToggleButton = value
        if value then
            MoveAny:CreateToggleButton()
            MoveAny.toggleButton:Show()
        elseif MoveAny.toggleButton then
            MoveAny.toggleButton:Hide()
        end
    end)
    container:AddChild(toggleButtonCheckbox)
    
    -- Toggle position button
    local positionButton = AceGUI:Create("Button")
    positionButton:SetText("Position Toggle Button")
    positionButton:SetWidth(200)
    positionButton:SetCallback("OnClick", function()
        if MoveAny.toggleButton then
            if VUI.db.profile.modules.moveany.lockFrames then
                MoveAny:UnlockFrames()
            end
            -- Highlight the toggle button's anchor
            if MoveAny.anchors["MoveAnyToggleButton"] then
                MoveAny.anchors["MoveAnyToggleButton"]:Show()
            end
        else
            VUI:Print("Toggle button is not created. Enable it first.")
        end
    end)
    container:AddChild(positionButton)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Combat behavior heading
    local combatHeading = AceGUI:Create("Heading")
    combatHeading:SetText("Combat Behavior")
    combatHeading:SetFullWidth(true)
    container:AddChild(combatHeading)
    
    -- Auto lock in combat checkbox
    local combatLockCheckbox = AceGUI:Create("CheckBox")
    combatLockCheckbox:SetLabel("Auto-Lock Frames in Combat")
    combatLockCheckbox:SetWidth(300)
    combatLockCheckbox:SetValue(VUI.db.profile.modules.moveany.autoLockInCombat)
    combatLockCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.autoLockInCombat = value
    end)
    container:AddChild(combatLockCheckbox)
    
    -- Auto restore state after combat checkbox
    local restoreCheckbox = AceGUI:Create("CheckBox")
    restoreCheckbox:SetLabel("Auto-Restore State After Combat")
    restoreCheckbox:SetWidth(300)
    restoreCheckbox:SetValue(VUI.db.profile.modules.moveany.restoreStateAfterCombat)
    restoreCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.restoreStateAfterCombat = value
    end)
    container:AddChild(restoreCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Frame appearance heading
    local appearanceHeading = AceGUI:Create("Heading")
    appearanceHeading:SetText("Frame Appearance")
    appearanceHeading:SetFullWidth(true)
    container:AddChild(appearanceHeading)
    
    -- Anchor opacity slider
    local opacitySlider = AceGUI:Create("Slider")
    opacitySlider:SetLabel("Anchor Opacity")
    opacitySlider:SetWidth(300)
    opacitySlider:SetSliderValues(0.1, 1.0, 0.05)
    opacitySlider:SetValue(VUI.db.profile.modules.moveany.anchorOpacity or 0.4)
    opacitySlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.anchorOpacity = value
        -- Update all anchors with new opacity
        for _, anchor in pairs(MoveAny.anchors) do
            if anchor.border then
                anchor.border:SetAlpha(value)
            end
        end
    end)
    container:AddChild(opacitySlider)
    
    -- Anchor border color picker
    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetLabel("Anchor Border Color")
    colorPicker:SetWidth(200)
    colorPicker:SetColor(
        VUI.db.profile.modules.moveany.anchorColor.r or 1,
        VUI.db.profile.modules.moveany.anchorColor.g or 0.5,
        VUI.db.profile.modules.moveany.anchorColor.b or 0,
        VUI.db.profile.modules.moveany.anchorColor.a or 0.4
    )
    colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.moveany.anchorColor = {r = r, g = g, b = b, a = a}
        -- Update all anchors with new color
        for _, anchor in pairs(MoveAny.anchors) do
            if anchor.border then
                anchor.border:SetVertexColor(r, g, b, a)
            end
        end
    end)
    container:AddChild(colorPicker)
    
    -- Export/Import section
    local exportImportHeading = AceGUI:Create("Heading")
    exportImportHeading:SetText("Export/Import")
    exportImportHeading:SetFullWidth(true)
    container:AddChild(exportImportHeading)
    
    -- Export button
    local exportButton = AceGUI:Create("Button")
    exportButton:SetText("Export Frame Positions")
    exportButton:SetWidth(200)
    exportButton:SetCallback("OnClick", function()
        -- Create a dialog to show the export string
        local dialog = AceGUI:Create("Frame")
        dialog:SetTitle("Export Frame Positions")
        dialog:SetLayout("Flow")
        dialog:SetWidth(500)
        dialog:SetHeight(400)
        
        local desc = AceGUI:Create("Label")
        desc:SetText("Copy the text below to export your frame positions:")
        desc:SetFullWidth(true)
        dialog:AddChild(desc)
        
        local export = AceGUI:Create("MultiLineEditBox")
        export:SetLabel("")
        export:SetFullWidth(true)
        export:SetFullHeight(true)
        export:SetText(MoveAny:ExportFramePositions())
        export:SetFocus()
        export:HighlightText()
        dialog:AddChild(export)
        
        local closeButton = AceGUI:Create("Button")
        closeButton:SetText("Close")
        closeButton:SetWidth(100)
        closeButton:SetCallback("OnClick", function()
            dialog:Hide()
        end)
        dialog:AddChild(closeButton)
    end)
    container:AddChild(exportButton)
    
    -- Import button
    local importButton = AceGUI:Create("Button")
    importButton:SetText("Import Frame Positions")
    importButton:SetWidth(200)
    importButton:SetCallback("OnClick", function()
        -- Create a dialog to enter the import string
        local dialog = AceGUI:Create("Frame")
        dialog:SetTitle("Import Frame Positions")
        dialog:SetLayout("Flow")
        dialog:SetWidth(500)
        dialog:SetHeight(400)
        
        local desc = AceGUI:Create("Label")
        desc:SetText("Paste the export string below to import frame positions:")
        desc:SetFullWidth(true)
        dialog:AddChild(desc)
        
        local import = AceGUI:Create("MultiLineEditBox")
        import:SetLabel("")
        import:SetFullWidth(true)
        import:SetFullHeight(true)
        dialog:AddChild(import)
        
        local importButton = AceGUI:Create("Button")
        importButton:SetText("Import")
        importButton:SetWidth(100)
        importButton:SetCallback("OnClick", function()
            local success = MoveAny:ImportFramePositions(import:GetText())
            if success then
                VUI:Print("Frame positions imported successfully.")
                dialog:Hide()
            else
                VUI:Print("Failed to import frame positions. Invalid format.")
            end
        end)
        dialog:AddChild(importButton)
        
        local cancelButton = AceGUI:Create("Button")
        cancelButton:SetText("Cancel")
        cancelButton:SetWidth(100)
        cancelButton:SetCallback("OnClick", function()
            dialog:Hide()
        end)
        dialog:AddChild(cancelButton)
    end)
    container:AddChild(importButton)
end

-- Function to export frame positions as a string
function MoveAny:ExportFramePositions()
    local export = {}
    
    -- Gather frame positions
    for name, position in pairs(VUI.db.profile.modules.moveany.savedFrames) do
        export[name] = position
    end
    
    -- Convert to string
    return LibStub("AceSerializer-3.0"):Serialize(export)
end

-- Function to import frame positions from a string
function MoveAny:ImportFramePositions(str)
    if not str or str == "" then return false end
    
    local success, data = LibStub("AceSerializer-3.0"):Deserialize(str)
    if not success or type(data) ~= "table" then return false end
    
    -- Apply imported positions
    for name, position in pairs(data) do
        VUI.db.profile.modules.moveany.savedFrames[name] = position
        
        -- Apply position to frame if it exists
        if self.registered[name] then
            self:ApplySavedPosition(self.registered[name], name)
        end
    end
    
    return true
end
