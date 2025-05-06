-- MoveAny Config Implementation
-- This file contains the configuration options for the MoveAny module
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
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
        {text = "Presets", value = "presets"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "frames" then
            self:CreateFramesTab(container)
        elseif group == "presets" then
            self:CreatePresetsTab(container)
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
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Show grid checkbox
    local gridCheckbox = AceGUI:Create("CheckBox")
    gridCheckbox:SetLabel("Show Grid When Moving Frames")
    gridCheckbox:SetWidth(300)
    gridCheckbox:SetValue(VUI.db.profile.modules.moveany.showGrid)
    gridCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.showGrid = value
    end)
    container:AddChild(gridCheckbox)
    
    -- Grid size slider
    local gridSizeSlider = AceGUI:Create("Slider")
    gridSizeSlider:SetLabel("Grid Size")
    gridSizeSlider:SetWidth(300)
    gridSizeSlider:SetSliderValues(2, 64, 2)
    gridSizeSlider:SetValue(VUI.db.profile.modules.moveany.gridSize)
    gridSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.gridSize = value
    end)
    container:AddChild(gridSizeSlider)
    
    -- Snap to grid checkbox
    local snapCheckbox = AceGUI:Create("CheckBox")
    snapCheckbox:SetLabel("Snap to Grid")
    snapCheckbox:SetWidth(200)
    snapCheckbox:SetValue(VUI.db.profile.modules.moveany.snapToGrid)
    snapCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.snapToGrid = value
    end)
    container:AddChild(snapCheckbox)
    
    -- Use class colors checkbox
    local classColorsCheckbox = AceGUI:Create("CheckBox")
    classColorsCheckbox:SetLabel("Use Class Colors for Frame Borders")
    classColorsCheckbox:SetWidth(300)
    classColorsCheckbox:SetValue(VUI.db.profile.modules.moveany.useClassColors)
    classColorsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.useClassColors = value
    end)
    container:AddChild(classColorsCheckbox)
    
    -- Highlight frame under mouse checkbox
    local highlightCheckbox = AceGUI:Create("CheckBox")
    highlightCheckbox:SetLabel("Highlight Frame Under Mouse")
    highlightCheckbox:SetWidth(300)
    highlightCheckbox:SetValue(VUI.db.profile.modules.moveany.highlightFrames)
    highlightCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.moveany.highlightFrames = value
    end)
    container:AddChild(highlightCheckbox)
    
    -- Create buttons group
    local buttonsGroup = AceGUI:Create("SimpleGroup")
    buttonsGroup:SetLayout("Flow")
    buttonsGroup:SetFullWidth(true)
    container:AddChild(buttonsGroup)
    
    -- Unlock all button
    local unlockButton = AceGUI:Create("Button")
    unlockButton:SetText("Unlock All Frames")
    unlockButton:SetWidth(150)
    unlockButton:SetCallback("OnClick", function()
        self:UnlockAllFrames()
    end)
    buttonsGroup:AddChild(unlockButton)
    
    -- Lock all button
    local lockButton = AceGUI:Create("Button")
    lockButton:SetText("Lock All Frames")
    lockButton:SetWidth(150)
    lockButton:SetCallback("OnClick", function()
        self:LockAllFrames()
    end)
    buttonsGroup:AddChild(lockButton)
    
    -- Reset all button
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset All Frames")
    resetButton:SetWidth(150)
    resetButton:SetCallback("OnClick", function()
        StaticPopupDialogs["VUI_MOVEANY_CONFIRM_RESET"] = {
            text = "Are you sure you want to reset all frame positions?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                self:ResetAllFrames()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_MOVEANY_CONFIRM_RESET")
    end)
    buttonsGroup:AddChild(resetButton)
end

-- Create the Frames tab
function MoveAny:CreateFramesTab(container)
    -- Create a scroll frame for the frames list
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(400)
    container:AddChild(scrollFrame)
    
    -- Search box
    local searchBox = AceGUI:Create("EditBox")
    searchBox:SetLabel("Search Frames")
    searchBox:SetWidth(250)
    searchBox:SetCallback("OnTextChanged", function(widget, event, text)
        self:RefreshFramesList(scrollFrame, text)
    end)
    scrollFrame:AddChild(searchBox)
    
    -- Category dropdown
    local categoryDropdown = AceGUI:Create("Dropdown")
    categoryDropdown:SetLabel("Category")
    categoryDropdown:SetWidth(250)
    categoryDropdown:SetList({
        ["all"] = "All Frames",
        ["action"] = "Action Bars",
        ["bags"] = "Bags",
        ["unitframes"] = "Unit Frames",
        ["minimap"] = "Minimap",
        ["other"] = "Other"
    })
    categoryDropdown:SetValue("all")
    categoryDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:RefreshFramesList(scrollFrame, searchBox:GetText(), value)
    end)
    scrollFrame:AddChild(categoryDropdown)
    
    -- Add header
    scrollFrame:AddChild(AceGUI:Create("Heading"):SetText("Movable Frames"):SetFullWidth(true))
    
    -- Initialize the frames list (empty for now)
    self:RefreshFramesList(scrollFrame, "", "all")
end

-- Create the Presets tab
function MoveAny:CreatePresetsTab(container)
    -- Create presets list
    local presetsList = AceGUI:Create("SimpleGroup")
    presetsList:SetLayout("Flow")
    presetsList:SetFullWidth(true)
    container:AddChild(presetsList)
    
    -- Add header
    container:AddChild(AceGUI:Create("Heading"):SetText("Layout Presets"):SetFullWidth(true))
    
    -- Add preset layouts
    local presetsData = {
        ["default"] = "Default UI",
        ["centered"] = "Centered",
        ["minimal"] = "Minimal",
        ["dps"] = "DPS Focused",
        ["healer"] = "Healer Focused",
        ["tank"] = "Tank Focused",
        ["pvp"] = "PvP"
    }
    
    for value, text in pairs(presetsData) do
        local presetGroup = AceGUI:Create("SimpleGroup")
        presetGroup:SetLayout("Flow")
        presetGroup:SetFullWidth(true)
        
        local presetName = AceGUI:Create("Label")
        presetName:SetText(text)
        presetName:SetWidth(150)
        presetGroup:AddChild(presetName)
        
        local loadButton = AceGUI:Create("Button")
        loadButton:SetText("Load")
        loadButton:SetWidth(80)
        loadButton:SetCallback("OnClick", function()
            StaticPopupDialogs["VUI_MOVEANY_CONFIRM_PRESET"] = {
                text = "Load the " .. text .. " preset? Current frame positions will be lost.",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    self:LoadPreset(value)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUI_MOVEANY_CONFIRM_PRESET")
        end)
        presetGroup:AddChild(loadButton)
        
        container:AddChild(presetGroup)
    end
    
    -- Save current layout
    container:AddChild(AceGUI:Create("Heading"):SetText("Save Current Layout"):SetFullWidth(true))
    
    local saveGroup = AceGUI:Create("SimpleGroup")
    saveGroup:SetLayout("Flow")
    saveGroup:SetFullWidth(true)
    
    local nameInput = AceGUI:Create("EditBox")
    nameInput:SetLabel("Preset Name")
    nameInput:SetWidth(200)
    saveGroup:AddChild(nameInput)
    
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText("Save Current Layout")
    saveButton:SetWidth(150)
    saveButton:SetCallback("OnClick", function()
        local name = nameInput:GetText()
        if name and name ~= "" then
            self:SaveCurrentLayout(name)
            VUI:Print("Layout saved as: " .. name)
        else
            VUI:Print("Please enter a name for the layout")
        end
    end)
    saveGroup:AddChild(saveButton)
    
    container:AddChild(saveGroup)
end

-- Refresh the frames list in the Frames tab
function MoveAny:RefreshFramesList(container, searchText, category)
    -- Clear existing list (except search box and dropdown)
    local children = {container:GetChildren()}
    for i = 3, #children do
        container:RemoveChild(children[i])
    end
    
    -- Add header
    container:AddChild(AceGUI:Create("Heading"):SetText("Movable Frames"):SetFullWidth(true))
    
    -- Get all registered frames
    local frames = self:GetRegisteredFrames()
    searchText = searchText:lower()
    
    -- Filter frames by search text and category
    for _, frameData in ipairs(frames) do
        local frameName = frameData.name:lower()
        local frameCategory = frameData.category or "other"
        
        if (searchText == "" or frameName:find(searchText)) and 
           (category == "all" or frameCategory == category) then
            -- Create frame entry
            local frameGroup = AceGUI:Create("SimpleGroup")
            frameGroup:SetLayout("Flow")
            frameGroup:SetFullWidth(true)
            
            -- Frame name
            local nameWidget = AceGUI:Create("Label")
            nameWidget:SetText(frameData.name)
            nameWidget:SetWidth(200)
            frameGroup:AddChild(nameWidget)
            
            -- Status label
            local statusWidget = AceGUI:Create("Label")
            statusWidget:SetText(frameData.moved and "Modified" or "Default")
            statusWidget:SetWidth(80)
            frameGroup:AddChild(statusWidget)
            
            -- Move button
            local moveButton = AceGUI:Create("Button")
            moveButton:SetText("Move")
            moveButton:SetWidth(80)
            moveButton:SetCallback("OnClick", function()
                self:ToggleFrameMovable(frameData.frame)
            end)
            frameGroup:AddChild(moveButton)
            
            -- Reset button
            local resetButton = AceGUI:Create("Button")
            resetButton:SetText("Reset")
            resetButton:SetWidth(80)
            resetButton:SetCallback("OnClick", function()
                self:ResetFrame(frameData.frame)
            end)
            frameGroup:AddChild(resetButton)
            
            container:AddChild(frameGroup)
        end
    end
end

-- Functions to handle frame movement
function MoveAny:UnlockAllFrames()
    for _, frameData in ipairs(self:GetRegisteredFrames()) do
        self:MakeFrameMovable(frameData.frame)
    end
    VUI:Print("All frames unlocked for movement")
end

function MoveAny:LockAllFrames()
    for _, frameData in ipairs(self:GetRegisteredFrames()) do
        self:MakeFrameStatic(frameData.frame)
    end
    VUI:Print("All frames locked")
end

function MoveAny:ResetAllFrames()
    for _, frameData in ipairs(self:GetRegisteredFrames()) do
        self:ResetFrame(frameData.frame)
    end
    VUI:Print("All frames reset to default positions")
end

function MoveAny:ToggleFrameMovable(frame)
    if frame.__isMoveAnyMovable then
        self:MakeFrameStatic(frame)
    else
        self:MakeFrameMovable(frame)
    end
end

function MoveAny:GetRegisteredFrames()
    -- This would return the actual list of frames from the MoveAny module
    -- For now we'll just return a placeholder list
    return self.registeredFrames or {}
end

function MoveAny:LoadPreset(presetName)
    if presetName == "default" then
        self:ResetAllFrames()
    else
        -- Load the preset from saved configurations
        local preset = VUI.db.profile.modules.moveany.presets[presetName]
        
        if preset then
            for frameName, position in pairs(preset) do
                self:ApplyFramePosition(frameName, position)
            end
            VUI:Print("Loaded " .. presetName .. " preset")
        else
            VUI:Print("Preset not found: " .. presetName)
        end
    end
end

function MoveAny:SaveCurrentLayout(name)
    if not VUI.db.profile.modules.moveany.presets then
        VUI.db.profile.modules.moveany.presets = {}
    end
    
    local preset = {}
    
    -- Save the current position of all registered frames
    for _, frameData in ipairs(self:GetRegisteredFrames()) do
        if frameData.moved then
            preset[frameData.name] = self:GetFramePosition(frameData.frame)
        end
    end
    
    VUI.db.profile.modules.moveany.presets[name] = preset
end

-- Dummy functions for API compatibility
function MoveAny:MakeFrameMovable(frame) end
function MoveAny:MakeFrameStatic(frame) end
function MoveAny:ResetFrame(frame) end
function MoveAny:ApplyFramePosition(frameName, position) end
function MoveAny:GetFramePosition(frame) return {} end

-- Get options for the config panel
function MoveAny:GetOptions()
    return {
        type = "group",
        name = "MoveAny",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the MoveAny module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("moveany") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("moveany")
                    else
                        VUI:DisableModule("moveany")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
                args = {
                    showGrid = {
                        type = "toggle",
                        name = "Show Grid",
                        desc = "Show alignment grid when moving frames",
                        order = 1,
                        get = function() return VUI.db.profile.modules.moveany.showGrid end,
                        set = function(_, value)
                            VUI.db.profile.modules.moveany.showGrid = value
                        end,
                    },
                    gridSize = {
                        type = "range",
                        name = "Grid Size",
                        desc = "Size of grid cells",
                        min = 2,
                        max = 64,
                        step = 2,
                        order = 2,
                        get = function() return VUI.db.profile.modules.moveany.gridSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.moveany.gridSize = value
                        end,
                    },
                    snapToGrid = {
                        type = "toggle",
                        name = "Snap to Grid",
                        desc = "Snap frames to grid when moving",
                        order = 3,
                        get = function() return VUI.db.profile.modules.moveany.snapToGrid end,
                        set = function(_, value)
                            VUI.db.profile.modules.moveany.snapToGrid = value
                        end,
                    }
                }
            },
            actions = {
                type = "group",
                name = "Actions",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
                args = {
                    unlockAll = {
                        type = "execute",
                        name = "Unlock All Frames",
                        desc = "Make all frames movable",
                        func = function() MoveAny:UnlockAllFrames() end,
                        order = 1,
                    },
                    lockAll = {
                        type = "execute",
                        name = "Lock All Frames",
                        desc = "Lock all frames in their current positions",
                        func = function() MoveAny:LockAllFrames() end,
                        order = 2,
                    },
                    resetAll = {
                        type = "execute",
                        name = "Reset All Frames",
                        desc = "Reset all frames to their default positions",
                        func = function() 
                            StaticPopupDialogs["VUI_MOVEANY_CONFIRM_RESET"] = {
                                text = "Are you sure you want to reset all frame positions?",
                                button1 = "Yes",
                                button2 = "No",
                                OnAccept = function()
                                    MoveAny:ResetAllFrames()
                                end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            StaticPopup_Show("VUI_MOVEANY_CONFIRM_RESET")
                        end,
                        order = 3,
                    }
                }
            }
        }
    }
end