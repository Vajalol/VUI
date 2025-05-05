-- VUI Visual Configuration Module - Core Functionality
local _, VUI = ...
local VisualConfig = VUI.visualconfig

-- Get Ace libraries
local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Constants for better code readability
local MAX_COLOR_HISTORY = 20
local MAX_RECENT_OPTIONS = 10
local GRID_COLOR = {r = 0.5, g = 0.5, b = 0.5, a = 0.3}
local HIGHLIGHT_COLOR = {r = 0.2, g = 0.6, b = 1.0, a = 0.5}
local GUIDE_COLOR = {r = 1.0, g = 0.5, b = 0.0, a = 0.7}

-- Module icons for various parts of VUI
local moduleIcons = {
    unitframes = "Interface\\AddOns\\VUI\\media\\textures\\unitframes",
    automation = "Interface\\AddOns\\VUI\\media\\textures\\automation",
    profiles = "Interface\\AddOns\\VUI\\media\\textures\\profiles",
    skins = "Interface\\AddOns\\VUI\\media\\textures\\skins",
    visualconfig = "Interface\\AddOns\\VUI\\media\\textures\\visualconfig",
    -- Default fallback
    default = "Interface\\AddOns\\VUI\\media\\textures\\default"
}

-- Set up Ace3 config hooks
function VisualConfig:SetupConfigHooks()
    if not self.enabled then return end
    
    -- Hook into AceConfigDialog for enhancements
    if not self.configHooksCreated then
        -- Hook into the Open method
        local originalOpen = AceConfigDialog.Open
        AceConfigDialog.Open = function(self, appName, container, ...)
            local result = originalOpen(self, appName, container, ...)
            
            -- Check if we need to enhance the config UI
            if VisualConfig.enabled then
                -- Apply enhancements after a short delay to ensure the frame is created
                C_Timer.After(0.1, function()
                    if appName:match("^VUI") then
                        VisualConfig:EnhanceConfigUI(appName, container)
                    end
                end)
            end
            
            return result
        end
        
        -- Hook into ConfigTableChanged method
        local originalTCH = AceConfigDialog.ConfigTableChanged
        AceConfigDialog.ConfigTableChanged = function(self, appName, ...)
            local result = originalTCH(self, appName, ...)
            
            -- Check if we need to refresh our enhancements
            if VisualConfig.enabled and appName:match("^VUI") then
                -- Refresh enhancements after a short delay
                C_Timer.After(0.1, function()
                    VisualConfig:RefreshConfigUI()
                end)
            end
            
            return result
        end
        
        self.configHooksCreated = true
    end
end

-- Initialize the layout editor
function VisualConfig:InitLayoutEditor()
    if not self.enabled or not self.settings.layoutEditor.enabled then return end
    
    -- Create the layout editor if it doesn't exist yet
    if not self.layoutEditor then
        self.layoutEditor = {}
        
        -- Initialize layout editor state
        self.layoutEditor.frames = {}
        self.layoutEditor.selectedFrames = {}
        self.layoutEditor.isDragging = false
        self.layoutEditor.isResizing = false
        self.layoutEditor.undoStack = {}
        self.layoutEditor.redoStack = {}
        
        -- Function to create the layout editor UI
        self.layoutEditor.Create = function()
            if self.layoutEditor.frame then
                self.layoutEditor.frame:Show()
                return
            end
            
            -- Create the main frame
            local frame = CreateFrame("Frame", "VUILayoutEditorFrame", UIParent)
            frame:SetSize(800, 600)
            frame:SetPoint("CENTER")
            frame:SetFrameStrata("DIALOG")
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetClampedToScreen(true)
            frame:SetScript("OnDragStart", frame.StartMoving)
            frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
            
            -- Set up basic frame appearance
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })
            
            -- Add title
            frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            frame.title:SetPoint("TOP", 0, -16)
            frame.title:SetText("VUI Layout Editor")
            
            -- Add close button
            frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
            frame.closeButton:SetPoint("TOPRIGHT", -5, -5)
            
            -- Add grid layer
            frame.gridLayer = CreateFrame("Frame", nil, frame)
            frame.gridLayer:SetAllPoints()
            frame.gridLayer:SetFrameLevel(frame:GetFrameLevel() + 1)
            
            -- Add control panel
            frame.controlPanel = CreateFrame("Frame", nil, frame)
            frame.controlPanel:SetSize(150, frame:GetHeight() - 30)
            frame.controlPanel:SetPoint("TOPRIGHT", -15, -30)
            frame.controlPanel:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add work area
            frame.workArea = CreateFrame("Frame", nil, frame)
            frame.workArea:SetPoint("TOPLEFT", 15, -30)
            frame.workArea:SetPoint("BOTTOMRIGHT", frame.controlPanel, "BOTTOMLEFT", -10, 15)
            frame.workArea:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add status bar
            frame.statusBar = CreateFrame("Frame", nil, frame)
            frame.statusBar:SetHeight(20)
            frame.statusBar:SetPoint("BOTTOMLEFT", 15, 5)
            frame.statusBar:SetPoint("BOTTOMRIGHT", -15, 5)
            frame.statusBar:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add status text
            frame.statusText = frame.statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.statusText:SetPoint("LEFT", 10, 0)
            frame.statusText:SetText("Ready")
            
            -- Create the grid
            self.layoutEditor.UpdateGrid()
            
            -- Add the frame to the editor
            self.layoutEditor.frame = frame
            
            -- Save initial state
            self:SaveWindowPosition(frame, "layoutEditor")
        end
        
        -- Function to update the grid
        self.layoutEditor.UpdateGrid = function()
            if not self.layoutEditor.frame then return end
            
            -- Clear existing grid
            if self.layoutEditor.gridLines then
                for _, line in ipairs(self.layoutEditor.gridLines) do
                    line:Hide()
                end
                wipe(self.layoutEditor.gridLines)
            else
                self.layoutEditor.gridLines = {}
            end
            
            -- If grid is disabled, return
            if not self.settings.layoutEditor.showGrid then
                return
            end
            
            local workArea = self.layoutEditor.frame.workArea
            local gridSize = self.settings.layoutEditor.gridSize
            
            -- Calculate grid dimensions
            local width = workArea:GetWidth()
            local height = workArea:GetHeight()
            local xLines = floor(width / gridSize)
            local yLines = floor(height / gridSize)
            
            -- Create vertical grid lines
            for i = 1, xLines do
                local line = self.layoutEditor.frame.gridLayer:CreateTexture(nil, "BACKGROUND")
                line:SetColorTexture(GRID_COLOR.r, GRID_COLOR.g, GRID_COLOR.b, GRID_COLOR.a)
                line:SetSize(1, height)
                line:SetPoint("TOPLEFT", workArea, "TOPLEFT", i * gridSize, 0)
                table.insert(self.layoutEditor.gridLines, line)
            end
            
            -- Create horizontal grid lines
            for i = 1, yLines do
                local line = self.layoutEditor.frame.gridLayer:CreateTexture(nil, "BACKGROUND")
                line:SetColorTexture(GRID_COLOR.r, GRID_COLOR.g, GRID_COLOR.b, GRID_COLOR.a)
                line:SetSize(width, 1)
                line:SetPoint("TOPLEFT", workArea, "TOPLEFT", 0, -i * gridSize)
                table.insert(self.layoutEditor.gridLines, line)
            end
        end
        
        -- Function to capture frame positions
        self.layoutEditor.CaptureFrames = function()
            -- Reset the frame list
            wipe(self.layoutEditor.frames)
            
            -- Add UIParent as the root frame
            self.layoutEditor.frames["UIParent"] = {
                frame = UIParent,
                children = {},
                level = 0,
                position = self:GetFramePosition(UIParent)
            }
            
            -- Add all modules' frames
            for moduleName, module in pairs(VUI.modules) do
                if module.frames then
                    for frameName, frame in pairs(module.frames) do
                        if frame:IsVisible() then
                            self.layoutEditor.frames[frameName] = {
                                frame = frame,
                                module = moduleName,
                                level = 1,
                                position = self:GetFramePosition(frame)
                            }
                            
                            -- Add to UIParent's children
                            table.insert(self.layoutEditor.frames["UIParent"].children, frameName)
                        end
                    end
                end
            end
            
            -- Update the work area to show frames
            self.layoutEditor.UpdateWorkArea()
        end
        
        -- Function to update the work area display
        self.layoutEditor.UpdateWorkArea = function()
            -- Clear existing frame visualizations
            if self.layoutEditor.frameVisuals then
                for _, visual in pairs(self.layoutEditor.frameVisuals) do
                    visual:Hide()
                end
                wipe(self.layoutEditor.frameVisuals)
            else
                self.layoutEditor.frameVisuals = {}
            end
            
            -- Create visualizations for each frame
            for frameName, frameData in pairs(self.layoutEditor.frames) do
                if frameName ~= "UIParent" then
                    -- Create a visual representation
                    local visual = CreateFrame("Frame", nil, self.layoutEditor.frame.workArea)
                    visual:SetFrameLevel(self.layoutEditor.frame.workArea:GetFrameLevel() + frameData.level)
                    
                    -- Set size and position based on the actual frame
                    local frame = frameData.frame
                    local width, height = frame:GetSize()
                    visual:SetSize(width, height)
                    
                    -- Calculate position relative to work area
                    local position = frameData.position
                    if position then
                        visual:SetPoint(position.point, self.layoutEditor.frame.workArea, position.relativePoint, position.xOfs, position.yOfs)
                    else
                        visual:SetPoint("CENTER")
                    end
                    
                    -- Add background
                    local bg = visual:CreateTexture(nil, "BACKGROUND")
                    bg:SetAllPoints()
                    bg:SetColorTexture(0.2, 0.2, 0.8, 0.3)
                    
                    -- Add border
                    local border = CreateFrame("Frame", nil, visual)
                    border:SetAllPoints()
                    border:SetBackdrop({
                        edgeFile = "Interface\\Buttons\\WHITE8x8",
                        edgeSize = 1,
                    })
                    border:SetBackdropBorderColor(0.5, 0.5, 1.0, 0.8)
                    
                    -- Add label
                    local label = visual:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    label:SetPoint("CENTER")
                    label:SetText(frameName)
                    
                    -- Store additional data
                    visual.frameData = frameData
                    visual.frameName = frameName
                    
                    -- Add drag functionality
                    visual:SetMovable(true)
                    visual:EnableMouse(true)
                    visual:RegisterForDrag("LeftButton")
                    
                    visual:SetScript("OnDragStart", function(self)
                        if VisualConfig.layoutEditor.isResizing then return end
                        VisualConfig.layoutEditor.isDragging = true
                        self:StartMoving()
                        
                        -- Show dimensions if enabled
                        if VisualConfig.settings.layoutEditor.showDimensions then
                            VisualConfig.layoutEditor.ShowDimensions(self)
                        end
                    end)
                    
                    visual:SetScript("OnDragStop", function(self)
                        self:StopMovingOrSizing()
                        VisualConfig.layoutEditor.isDragging = false
                        
                        -- Snap to grid if enabled
                        if VisualConfig.settings.layoutEditor.snapToGrid then
                            VisualConfig.layoutEditor.SnapToGrid(self)
                        end
                        
                        -- Update position data
                        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
                        frameData.position = {
                            point = point,
                            relativePoint = relativePoint,
                            xOfs = xOfs,
                            yOfs = yOfs
                        }
                        
                        -- Hide dimensions
                        VisualConfig.layoutEditor.HideDimensions()
                        
                        -- Update status
                        VisualConfig.layoutEditor.UpdateStatus(string.format("Moved %s to: %d, %d", frameName, xOfs, yOfs))
                    end)
                    
                    -- Add click selection
                    visual:SetScript("OnMouseDown", function(self, button)
                        if button == "LeftButton" then
                            -- Select this frame
                            VisualConfig.layoutEditor.SelectFrame(frameName)
                        end
                    end)
                    
                    -- Store the visual
                    self.layoutEditor.frameVisuals[frameName] = visual
                end
            end
        end
        
        -- Function to show dimensions during resizing/moving
        self.layoutEditor.ShowDimensions = function(frame)
            if not self.layoutEditor.dimensionsFrame then
                local dimensions = CreateFrame("Frame", nil, self.layoutEditor.frame)
                dimensions:SetSize(100, 40)
                dimensions:SetPoint("BOTTOMLEFT", self.layoutEditor.frame.statusBar, "TOPLEFT", 0, 5)
                dimensions:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true,
                    tileSize = 16,
                    edgeSize = 16,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
                
                dimensions.text = dimensions:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                dimensions.text:SetPoint("CENTER")
                
                self.layoutEditor.dimensionsFrame = dimensions
            end
            
            -- Update dimension text
            local width, height = frame:GetSize()
            local point, _, _, xOfs, yOfs = frame:GetPoint()
            self.layoutEditor.dimensionsFrame.text:SetText(string.format("Size: %dx%d\nPos: %d, %d", width, height, xOfs, yOfs))
            self.layoutEditor.dimensionsFrame:Show()
        end
        
        -- Function to hide dimensions display
        self.layoutEditor.HideDimensions = function()
            if self.layoutEditor.dimensionsFrame then
                self.layoutEditor.dimensionsFrame:Hide()
            end
        end
        
        -- Function to snap a frame to the grid
        self.layoutEditor.SnapToGrid = function(frame)
            local gridSize = self.settings.layoutEditor.gridSize
            local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
            
            -- Round position to nearest grid point
            xOfs = floor(xOfs / gridSize + 0.5) * gridSize
            yOfs = floor(yOfs / gridSize + 0.5) * gridSize
            
            -- Reposition the frame
            frame:ClearAllPoints()
            frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        end
        
        -- Function to select a frame
        self.layoutEditor.SelectFrame = function(frameName)
            -- Clear existing selection
            for _, visual in pairs(self.layoutEditor.frameVisuals) do
                local bg = visual:GetRegions()
                bg:SetColorTexture(0.2, 0.2, 0.8, 0.3)
            end
            
            -- Select the new frame
            self.layoutEditor.selectedFrames = { frameName }
            
            -- Highlight the selected frame
            local visual = self.layoutEditor.frameVisuals[frameName]
            if visual then
                local bg = visual:GetRegions()
                bg:SetColorTexture(0.8, 0.2, 0.2, 0.5)
                
                -- Update status
                self.layoutEditor.UpdateStatus(string.format("Selected: %s", frameName))
            end
        end
        
        -- Function to update status text
        self.layoutEditor.UpdateStatus = function(text)
            self.layoutEditor.frame.statusText:SetText(text)
        end
        
        -- Function to apply changes to actual frames
        self.layoutEditor.ApplyChanges = function()
            -- Create a backup first
            if self.settings.layoutEditor.saveBackup then
                VUI.profiles:CreateBackup("Pre-Layout Edit")
            end
            
            -- Apply positions to actual frames
            for frameName, frameData in pairs(self.layoutEditor.frames) do
                if frameName ~= "UIParent" and frameData.position then
                    local frame = frameData.frame
                    if frame then
                        frame:ClearAllPoints()
                        frame:SetPoint(
                            frameData.position.point,
                            UIParent,
                            frameData.position.relativePoint,
                            frameData.position.xOfs,
                            frameData.position.yOfs
                        )
                    end
                end
            end
            
            -- Update status
            self.layoutEditor.UpdateStatus("Changes applied")
        end
    end
end

-- Initialize the presets manager
function VisualConfig:InitPresetsManager()
    if not self.enabled or not self.settings.presets.enabled then return end
    
    -- Create the presets manager if it doesn't exist yet
    if not self.presetsManager then
        self.presetsManager = {}
        
        -- Initialize presets manager state
        self.presetsManager.currentPreset = nil
        
        -- Function to create the presets manager UI
        self.presetsManager.Create = function()
            if self.presetsManager.frame then
                self.presetsManager.frame:Show()
                return
            end
            
            -- Create the main frame
            local frame = CreateFrame("Frame", "VUIPresetsManagerFrame", UIParent)
            frame:SetSize(500, 400)
            frame:SetPoint("CENTER")
            frame:SetFrameStrata("DIALOG")
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetClampedToScreen(true)
            frame:SetScript("OnDragStart", frame.StartMoving)
            frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
            
            -- Set up basic frame appearance
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })
            
            -- Add title
            frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            frame.title:SetPoint("TOP", 0, -16)
            frame.title:SetText("VUI Presets Manager")
            
            -- Add close button
            frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
            frame.closeButton:SetPoint("TOPRIGHT", -5, -5)
            
            -- Add preset list
            frame.presetList = CreateFrame("Frame", nil, frame)
            frame.presetList:SetSize(150, frame:GetHeight() - 80)
            frame.presetList:SetPoint("TOPLEFT", 15, -40)
            frame.presetList:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add preset detail panel
            frame.detailPanel = CreateFrame("Frame", nil, frame)
            frame.detailPanel:SetPoint("TOPLEFT", frame.presetList, "TOPRIGHT", 10, 0)
            frame.detailPanel:SetPoint("BOTTOMRIGHT", -15, 40)
            frame.detailPanel:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add buttons
            frame.newButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            frame.newButton:SetSize(100, 22)
            frame.newButton:SetPoint("BOTTOMLEFT", 15, 10)
            frame.newButton:SetText("New Preset")
            frame.newButton:SetScript("OnClick", function()
                VisualConfig:CreatePresetFromCurrent()
            end)
            
            frame.loadButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            frame.loadButton:SetSize(100, 22)
            frame.loadButton:SetPoint("LEFT", frame.newButton, "RIGHT", 10, 0)
            frame.loadButton:SetText("Load")
            frame.loadButton:SetScript("OnClick", function()
                if self.presetsManager.currentPreset then
                    self.presetsManager.LoadPreset(self.presetsManager.currentPreset)
                end
            end)
            frame.loadButton:Disable()
            
            frame.deleteButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            frame.deleteButton:SetSize(100, 22)
            frame.deleteButton:SetPoint("LEFT", frame.loadButton, "RIGHT", 10, 0)
            frame.deleteButton:SetText("Delete")
            frame.deleteButton:SetScript("OnClick", function()
                if self.presetsManager.currentPreset then
                    self.presetsManager.DeletePreset(self.presetsManager.currentPreset)
                end
            end)
            frame.deleteButton:Disable()
            
            frame.exportButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            frame.exportButton:SetSize(100, 22)
            frame.exportButton:SetPoint("BOTTOMRIGHT", -15, 10)
            frame.exportButton:SetText("Export")
            frame.exportButton:SetScript("OnClick", function()
                if self.presetsManager.currentPreset then
                    self.presetsManager.ExportPreset(self.presetsManager.currentPreset)
                end
            end)
            frame.exportButton:Disable()
            
            -- Add empty preset list message
            frame.emptyText = frame.presetList:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.emptyText:SetPoint("CENTER")
            frame.emptyText:SetText("No presets found.\nCreate a new preset using the button below.")
            
            -- Add empty detail panel message
            frame.emptyDetailText = frame.detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.emptyDetailText:SetPoint("CENTER")
            frame.emptyDetailText:SetText("Select a preset to view details.")
            
            -- Store the frame
            self.presetsManager.frame = frame
            
            -- Update the preset list
            self.presetsManager.UpdatePresetList()
            
            -- Save initial position
            self:SaveWindowPosition(frame, "presetsManager")
        end
        
        -- Function to update the preset list
        self.presetsManager.UpdatePresetList = function()
            if not self.presetsManager.frame then return end
            
            -- Clear existing preset buttons
            if self.presetsManager.presetButtons then
                for _, button in ipairs(self.presetsManager.presetButtons) do
                    button:Hide()
                end
                wipe(self.presetsManager.presetButtons)
            else
                self.presetsManager.presetButtons = {}
            end
            
            -- Get presets
            local presets = {}
            for name, _ in pairs(self.settings.presets.savedPresets) do
                table.insert(presets, name)
            end
            table.sort(presets)
            
            -- Show/hide empty message
            if #presets == 0 then
                self.presetsManager.frame.emptyText:Show()
            else
                self.presetsManager.frame.emptyText:Hide()
                
                -- Create buttons for each preset
                local buttonHeight = 20
                local spacing = 2
                local list = self.presetsManager.frame.presetList
                local availableHeight = list:GetHeight() - 10
                
                for i, presetName in ipairs(presets) do
                    local button = CreateFrame("Button", nil, list)
                    button:SetSize(list:GetWidth() - 10, buttonHeight)
                    button:SetPoint("TOPLEFT", 5, -5 - (i-1) * (buttonHeight + spacing))
                    
                    -- Set appearance
                    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
                    
                    -- Add text
                    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    text:SetPoint("LEFT", 5, 0)
                    text:SetText(presetName)
                    
                    -- Store preset name
                    button.presetName = presetName
                    
                    -- Add click handler
                    button:SetScript("OnClick", function(self)
                        VisualConfig.presetsManager.SelectPreset(self.presetName)
                    end)
                    
                    -- Store the button
                    table.insert(self.presetsManager.presetButtons, button)
                end
                
                -- If we previously had a selection, try to re-select it
                if self.presetsManager.currentPreset and self.settings.presets.savedPresets[self.presetsManager.currentPreset] then
                    self.presetsManager.SelectPreset(self.presetsManager.currentPreset)
                end
            end
        end
        
        -- Function to select a preset
        self.presetsManager.SelectPreset = function(presetName)
            -- Update selection
            self.presetsManager.currentPreset = presetName
            
            -- Update button states
            self.presetsManager.frame.loadButton:Enable()
            self.presetsManager.frame.deleteButton:Enable()
            self.presetsManager.frame.exportButton:Enable()
            
            -- Update preset buttons
            for _, button in ipairs(self.presetsManager.presetButtons) do
                if button.presetName == presetName then
                    button:LockHighlight()
                else
                    button:UnlockHighlight()
                end
            end
            
            -- Update detail panel
            self.presetsManager.UpdateDetailPanel(presetName)
        end
        
        -- Function to update the detail panel
        self.presetsManager.UpdateDetailPanel = function(presetName)
            local frame = self.presetsManager.frame
            
            -- Hide empty message
            frame.emptyDetailText:Hide()
            
            -- Clear existing content
            if self.presetsManager.detailContent then
                for _, widget in pairs(self.presetsManager.detailContent) do
                    widget:Hide()
                end
                wipe(self.presetsManager.detailContent)
            else
                self.presetsManager.detailContent = {}
            end
            
            -- Get preset data
            local preset = self.settings.presets.savedPresets[presetName]
            if not preset then return end
            
            -- Add name label
            local nameLabel = frame.detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameLabel:SetPoint("TOPLEFT", 10, -10)
            nameLabel:SetText(presetName)
            table.insert(self.presetsManager.detailContent, nameLabel)
            
            -- Add creation date
            local dateLabel = frame.detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            dateLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -5)
            dateLabel:SetText("Created: " .. date("%Y-%m-%d %H:%M", preset.created or time()))
            table.insert(self.presetsManager.detailContent, dateLabel)
            
            -- Add description if any
            if preset.description then
                local descLabel = frame.detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                descLabel:SetPoint("TOPLEFT", dateLabel, "BOTTOMLEFT", 0, -10)
                descLabel:SetText("Description: " .. preset.description)
                descLabel:SetWidth(frame.detailPanel:GetWidth() - 20)
                descLabel:SetJustifyH("LEFT")
                descLabel:SetJustifyV("TOP")
                table.insert(self.presetsManager.detailContent, descLabel)
            end
            
            -- Add preview if enabled
            if self.settings.presets.showPresetPreviews and preset.preview then
                local previewFrame = CreateFrame("Frame", nil, frame.detailPanel)
                previewFrame:SetSize(200, 150)
                previewFrame:SetPoint("BOTTOM", 0, 10)
                previewFrame:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true,
                    tileSize = 16,
                    edgeSize = 16,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
                
                -- Add preview texture
                local previewTexture = previewFrame:CreateTexture(nil, "ARTWORK")
                previewTexture:SetAllPoints()
                previewTexture:SetTexture(preset.preview)
                
                table.insert(self.presetsManager.detailContent, previewFrame)
            end
        end
        
        -- Function to load a preset
        self.presetsManager.LoadPreset = function(presetName)
            local preset = self.settings.presets.savedPresets[presetName]
            if not preset then return end
            
            -- Show confirmation dialog
            StaticPopupDialogs["VUI_CONFIRM_LOAD_PRESET"] = {
                text = string.format("Load preset '%s'? This will replace your current settings.", presetName),
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    -- Create a backup
                    VUI.profiles:CreateBackup("Pre-Preset Load")
                    
                    -- Apply the preset
                    for moduleKey, moduleSettings in pairs(preset.settings) do
                        if VUI.modules[moduleKey] then
                            -- Copy settings
                            VUI.modules[moduleKey].settings = CopyTable(moduleSettings)
                        end
                    end
                    
                    -- Update the UI
                    VisualConfig:RefreshConfigUI()
                    
                    -- Notify the user
                    VUI:Print(string.format("Preset '%s' loaded successfully.", presetName))
                    
                    -- Close the frame
                    self.presetsManager.frame:Hide()
                    
                    -- Reload UI to apply changes
                    StaticPopupDialogs["VUI_RELOAD_UI"] = {
                        text = "Reload UI to apply all changes?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            ReloadUI()
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("VUI_RELOAD_UI")
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUI_CONFIRM_LOAD_PRESET")
        end
        
        -- Function to delete a preset
        self.presetsManager.DeletePreset = function(presetName)
            -- Show confirmation dialog
            StaticPopupDialogs["VUI_CONFIRM_DELETE_PRESET"] = {
                text = string.format("Delete preset '%s'? This cannot be undone.", presetName),
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    -- Remove the preset
                    self.settings.presets.savedPresets[presetName] = nil
                    
                    -- Clear current selection
                    self.presetsManager.currentPreset = nil
                    
                    -- Update the UI
                    self.presetsManager.UpdatePresetList()
                    
                    -- Reset detail panel
                    self.presetsManager.frame.emptyDetailText:Show()
                    if self.presetsManager.detailContent then
                        for _, widget in pairs(self.presetsManager.detailContent) do
                            widget:Hide()
                        end
                        wipe(self.presetsManager.detailContent)
                    end
                    
                    -- Disable buttons
                    self.presetsManager.frame.loadButton:Disable()
                    self.presetsManager.frame.deleteButton:Disable()
                    self.presetsManager.frame.exportButton:Disable()
                    
                    -- Notify the user
                    VUI:Print(string.format("Preset '%s' deleted.", presetName))
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUI_CONFIRM_DELETE_PRESET")
        end
        
        -- Function to export a preset
        self.presetsManager.ExportPreset = function(presetName)
            local preset = self.settings.presets.savedPresets[presetName]
            if not preset then return end
            
            -- Serialize the preset
            local serialized = self:SerializePreset(preset)
            
            -- Show export dialog
            StaticPopupDialogs["VUI_EXPORT_PRESET"] = {
                text = string.format("Export preset '%s':", presetName),
                button1 = "Close",
                hasEditBox = true,
                editBoxWidth = 350,
                OnShow = function(self)
                    self.editBox:SetText(serialized)
                    self.editBox:HighlightText()
                    self.editBox:SetFocus()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUI_EXPORT_PRESET")
        end
    end
end

-- Initialize the theme editor
function VisualConfig:InitThemeEditor()
    if not self.enabled then return end
    
    -- Create the theme editor if it doesn't exist yet
    if not self.themeEditor then
        self.themeEditor = {}
        
        -- Initialize theme editor state
        self.themeEditor.currentTheme = nil
        
        -- Function to create the theme editor UI
        self.themeEditor.Create = function()
            if self.themeEditor.frame then
                self.themeEditor.frame:Show()
                return
            end
            
            -- Create the main frame
            local frame = CreateFrame("Frame", "VUIThemeEditorFrame", UIParent)
            frame:SetSize(600, 450)
            frame:SetPoint("CENTER")
            frame:SetFrameStrata("DIALOG")
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetClampedToScreen(true)
            frame:SetScript("OnDragStart", frame.StartMoving)
            frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
            
            -- Set up basic frame appearance
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })
            
            -- Add title
            frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            frame.title:SetPoint("TOP", 0, -16)
            frame.title:SetText("VUI Theme Editor")
            
            -- Add close button
            frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
            frame.closeButton:SetPoint("TOPRIGHT", -5, -5)
            
            -- Save the frame
            self.themeEditor.frame = frame
            
            -- Save initial position
            self:SaveWindowPosition(frame, "themeEditor")
            
            -- This is a placeholder - full implementation would be more extensive
            local placeholderText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            placeholderText:SetPoint("CENTER")
            placeholderText:SetText("Theme Editor - Coming Soon")
        end
    end
end

-- Initialize the color picker
function VisualConfig:InitColorPicker()
    if not self.enabled then return end
    
    -- Hook into the standard color picker
    if not self.colorPickerHooked and self.settings.colorPicker.enhancedColorPicker then
        -- Store original functions
        self.originalColorPickerFrame_OnColorSelect = ColorPickerFrame_OnColorSelect
        
        -- Hook the color picker
        ColorPickerFrame:HookScript("OnShow", function()
            -- Only modify if our module is enabled
            if not VisualConfig.enabled or not VisualConfig.settings.colorPicker.enhancedColorPicker then
                return
            end
            
            -- Add our enhancements
            VisualConfig:EnhanceColorPicker()
        end)
        
        -- Mark as hooked
        self.colorPickerHooked = true
    end
end

-- Enhance the color picker with additional features
function VisualConfig:EnhanceColorPicker()
    if not self.enabled or not self.settings.colorPicker.enhancedColorPicker then return end
    
    local colorPicker = ColorPickerFrame
    
    -- If we've already enhanced this instance, don't do it again
    if colorPicker.VUIEnhanced then return end
    colorPicker.VUIEnhanced = true
    
    -- Remember original size
    if not colorPicker.originalWidth then
        colorPicker.originalWidth = colorPicker:GetWidth()
        colorPicker.originalHeight = colorPicker:GetHeight()
    end
    
    -- Make it larger to fit our additions
    colorPicker:SetSize(colorPicker.originalWidth + 150, colorPicker.originalHeight)
    
    -- Add color history if enabled
    if self.settings.colorPicker.showColorHistory then
        if not colorPicker.colorHistory then
            -- Create color history frame
            local history = CreateFrame("Frame", nil, colorPicker)
            history:SetSize(130, 100)
            history:SetPoint("TOPLEFT", colorPicker, "TOPRIGHT", -5, -20)
            history:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add title
            local title = history:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            title:SetPoint("TOP", 0, -5)
            title:SetText("Color History")
            
            -- Create color swatches
            local swatches = {}
            local swatchSize = 20
            local spacing = 5
            local columns = 5
            local rows = 4
            
            for i = 1, rows * columns do
                local swatch = CreateFrame("Button", nil, history)
                swatch:SetSize(swatchSize, swatchSize)
                
                -- Calculate position
                local row = ceil(i / columns)
                local col = (i - 1) % columns + 1
                swatch:SetPoint("TOPLEFT", 10 + (col-1) * (swatchSize + spacing), -20 - (row-1) * (swatchSize + spacing))
                
                -- Add background
                local tex = swatch:CreateTexture(nil, "BACKGROUND")
                tex:SetAllPoints()
                tex:SetColorTexture(0.5, 0.5, 0.5, 1)
                swatch.tex = tex
                
                -- Add border
                swatch:SetBackdrop({
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                })
                swatch:SetBackdropBorderColor(0, 0, 0, 1)
                
                -- Add click handler
                swatch:SetScript("OnClick", function(self)
                    if self.color then
                        -- Apply this color
                        ColorPickerFrame:SetColorRGB(self.color.r, self.color.g, self.color.b)
                        
                        -- Call the original color select function
                        if VisualConfig.originalColorPickerFrame_OnColorSelect then
                            VisualConfig.originalColorPickerFrame_OnColorSelect()
                        end
                        
                        -- Update the opacity slider if it exists
                        if ColorPickerFrame.hasOpacity and ColorPickerFrame.opacity and self.color.a then
                            ColorPickerFrame.opacity:SetValue(1 - self.color.a)
                        end
                    end
                end)
                
                -- Add to swatches
                swatches[i] = swatch
            end
            
            -- Store it
            colorPicker.colorHistory = history
            colorPicker.colorSwatches = swatches
            
            -- Update it with our stored colors
            self:UpdateColorPickerHistory()
        end
        
        -- Show it
        colorPicker.colorHistory:Show()
    end
    
    -- Add color presets if enabled
    if self.settings.colorPicker.showPresets then
        if not colorPicker.colorPresets then
            -- Create color presets frame
            local presets = CreateFrame("Frame", nil, colorPicker)
            presets:SetSize(130, 100)
            presets:SetPoint("TOPLEFT", colorPicker, "TOPRIGHT", -5, -130)
            presets:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add title
            local title = presets:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            title:SetPoint("TOP", 0, -5)
            title:SetText("Presets")
            
            -- Define preset colors
            local presetColors = {
                {r = 1.0, g = 0.0, b = 0.0, name = "Red"},       -- Red
                {r = 0.0, g = 1.0, b = 0.0, name = "Green"},     -- Green
                {r = 0.0, g = 0.0, b = 1.0, name = "Blue"},      -- Blue
                {r = 1.0, g = 1.0, b = 0.0, name = "Yellow"},    -- Yellow
                {r = 0.0, g = 1.0, b = 1.0, name = "Cyan"},      -- Cyan
                {r = 1.0, g = 0.0, b = 1.0, name = "Magenta"},   -- Magenta
                {r = 1.0, g = 1.0, b = 1.0, name = "White"},     -- White
                {r = 0.0, g = 0.0, b = 0.0, name = "Black"},     -- Black
                {r = 0.5, g = 0.5, b = 0.5, name = "Gray"},      -- Gray
                {r = 0.5, g = 0.0, b = 0.0, name = "Dark Red"},  -- Dark Red
                {r = 0.0, g = 0.5, b = 0.0, name = "Dark Green"},-- Dark Green
                {r = 0.0, g = 0.0, b = 0.5, name = "Dark Blue"}, -- Dark Blue
                {r = 0.5, g = 0.5, b = 0.0, name = "Olive"},     -- Olive
                {r = 0.0, g = 0.5, b = 0.5, name = "Teal"},      -- Teal
                {r = 0.5, g = 0.0, b = 0.5, name = "Purple"},    -- Purple
                {r = 0.75, g = 0.75, b = 0.75, name = "Silver"}, -- Silver
                {r = 0.94, g = 0.87, b = 0.47, name = "Gold"},   -- Gold
                {r = 0.72, g = 0.53, b = 0.04, name = "Bronze"}, -- Bronze
                {r = 0.81, g = 0.81, b = 0.81, name = "Steel"},  -- Steel
                {r = 0.67, g = 0.83, b = 0.45, name = "Lime"},   -- Lime
            }
            
            -- Create color swatches
            local swatches = {}
            local swatchSize = 20
            local spacing = 5
            local columns = 5
            local rows = 4
            
            for i = 1, min(#presetColors, rows * columns) do
                local swatch = CreateFrame("Button", nil, presets)
                swatch:SetSize(swatchSize, swatchSize)
                
                -- Calculate position
                local row = ceil(i / columns)
                local col = (i - 1) % columns + 1
                swatch:SetPoint("TOPLEFT", 10 + (col-1) * (swatchSize + spacing), -20 - (row-1) * (swatchSize + spacing))
                
                -- Add background
                local tex = swatch:CreateTexture(nil, "BACKGROUND")
                tex:SetAllPoints()
                tex:SetColorTexture(presetColors[i].r, presetColors[i].g, presetColors[i].b, 1)
                swatch.tex = tex
                
                -- Add border
                swatch:SetBackdrop({
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                })
                swatch:SetBackdropBorderColor(0, 0, 0, 1)
                
                -- Add tooltip
                swatch:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(presetColors[i].name)
                    GameTooltip:Show()
                end)
                
                swatch:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Add click handler
                swatch:SetScript("OnClick", function()
                    -- Apply this color
                    ColorPickerFrame:SetColorRGB(presetColors[i].r, presetColors[i].g, presetColors[i].b)
                    
                    -- Call the original color select function
                    if VisualConfig.originalColorPickerFrame_OnColorSelect then
                        VisualConfig.originalColorPickerFrame_OnColorSelect()
                    end
                end)
                
                -- Store the color info
                swatch.color = presetColors[i]
                
                -- Add to swatches
                swatches[i] = swatch
            end
            
            -- Store it
            colorPicker.colorPresets = presets
            colorPicker.presetSwatches = swatches
        end
        
        -- Show it
        colorPicker.colorPresets:Show()
    end
    
    -- Add class colors if enabled
    if self.settings.colorPicker.showClassColors then
        if not colorPicker.classColors then
            -- Create class colors frame
            local classFrame = CreateFrame("Frame", nil, colorPicker)
            classFrame:SetSize(130, 100)
            classFrame:SetPoint("TOPLEFT", colorPicker, "TOPRIGHT", -5, -240)
            classFrame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            
            -- Add title
            local title = classFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            title:SetPoint("TOP", 0, -5)
            title:SetText("Class Colors")
            
            -- Create color swatches
            local swatches = {}
            local swatchSize = 20
            local spacing = 5
            local columns = 4
            
            local classInfo = {
                {"WARRIOR", "Warrior"},
                {"PALADIN", "Paladin"},
                {"HUNTER", "Hunter"},
                {"ROGUE", "Rogue"},
                {"PRIEST", "Priest"},
                {"DEATHKNIGHT", "Death Knight"},
                {"SHAMAN", "Shaman"},
                {"MAGE", "Mage"},
                {"WARLOCK", "Warlock"},
                {"MONK", "Monk"},
                {"DRUID", "Druid"},
                {"DEMONHUNTER", "Demon Hunter"},
            }
            
            for i, info in ipairs(classInfo) do
                local classToken, className = unpack(info)
                
                -- Get the color
                local color = RAID_CLASS_COLORS[classToken]
                if color then
                
                local swatch = CreateFrame("Button", nil, classFrame)
                swatch:SetSize(swatchSize, swatchSize)
                
                -- Calculate position
                local row = ceil(i / columns)
                local col = (i - 1) % columns + 1
                swatch:SetPoint("TOPLEFT", 10 + (col-1) * (swatchSize + spacing), -20 - (row-1) * (swatchSize + spacing))
                
                -- Add background
                local tex = swatch:CreateTexture(nil, "BACKGROUND")
                tex:SetAllPoints()
                tex:SetColorTexture(color.r, color.g, color.b, 1)
                swatch.tex = tex
                
                -- Add border
                swatch:SetBackdrop({
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                })
                swatch:SetBackdropBorderColor(0, 0, 0, 1)
                
                -- Add tooltip
                swatch:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(className)
                    GameTooltip:Show()
                end)
                
                swatch:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Add click handler
                swatch:SetScript("OnClick", function()
                    -- Apply this color
                    ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
                    
                    -- Call the original color select function
                    if VisualConfig.originalColorPickerFrame_OnColorSelect then
                        VisualConfig.originalColorPickerFrame_OnColorSelect()
                    end
                end)
                
                -- Add to swatches
                swatches[i] = swatch
                end -- End of if color
            end
            
            -- Store it
            colorPicker.classColors = classFrame
            colorPicker.classSwatches = swatches
        end
        
        -- Show it
        colorPicker.classColors:Show()
    end
    
    -- Hook up the color selection for history
    if not colorPicker.VUISelectionHooked then
        colorPicker:HookScript("OnColorSelect", function()
            -- Only if our module is enabled
            if not VisualConfig.enabled or not VisualConfig.settings.colorPicker.enhancedColorPicker then
                return
            end
            
            -- Add to history if color changes
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = 1
            if ColorPickerFrame.hasOpacity then
                a = 1 - OpacitySliderFrame:GetValue()
            end
            
            -- Add to history
            VisualConfig:AddColorToHistory(r, g, b, a)
        end)
        
        colorPicker.VUISelectionHooked = true
    end
    
    -- Hook the okay button to remember the final color
    if not colorPicker.VUIOkayHooked then
        local okayButton = ColorPickerFrame.OkayButton or _G["ColorPickerOkayButton"]
        if okayButton then
            okayButton:HookScript("OnClick", function()
                -- Only if our module is enabled
                if not VisualConfig.enabled or not VisualConfig.settings.colorPicker.enhancedColorPicker then
                    return
                end
                
                -- Remember the final color
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = 1
                if ColorPickerFrame.hasOpacity then
                    a = 1 - OpacitySliderFrame:GetValue()
                end
                
                -- Add to history
                VisualConfig:AddColorToHistory(r, g, b, a)
            end)
            
            colorPicker.VUIOkayHooked = true
        end
    end
end

-- Add a color to the history
function VisualConfig:AddColorToHistory(r, g, b, a)
    -- Skip if not enabled
    if not self.enabled or not self.settings.colorPicker.enhancedColorPicker or not self.settings.colorPicker.showColorHistory then
        return
    end
    
    -- Make sure we have a color history table
    if not self.colorHistory then
        self.colorHistory = {}
    end
    
    -- Check if this color is already in history
    for i, color in ipairs(self.colorHistory) do
        -- If it's very similar, move it to the front instead of adding duplicate
        if abs(color.r - r) < 0.01 and abs(color.g - g) < 0.01 and abs(color.b - b) < 0.01 and abs(color.a - a) < 0.01 then
            -- Remove from current position
            table.remove(self.colorHistory, i)
            -- Add to front
            table.insert(self.colorHistory, 1, {r = r, g = g, b = b, a = a})
            -- Update the swatches
            self:UpdateColorPickerHistory()
            return
        end
    end
    
    -- Add to history
    table.insert(self.colorHistory, 1, {r = r, g = g, b = b, a = a})
    
    -- Limit history size
    while #self.colorHistory > MAX_COLOR_HISTORY do
        table.remove(self.colorHistory)
    end
    
    -- Update the swatches
    self:UpdateColorPickerHistory()
end

-- Update the color picker history swatches
function VisualConfig:UpdateColorPickerHistory()
    -- Skip if not enabled
    if not self.enabled or not self.settings.colorPicker.enhancedColorPicker or not self.settings.colorPicker.showColorHistory then
        return
    end
    
    -- Make sure we have a color history table
    if not self.colorHistory then
        self.colorHistory = {}
    end
    
    -- Need the color picker to be visible
    if not ColorPickerFrame:IsVisible() or not ColorPickerFrame.colorSwatches then
        return
    end
    
    -- Update swatches
    for i, swatch in ipairs(ColorPickerFrame.colorSwatches) do
        if i <= #self.colorHistory then
            -- Set color
            local color = self.colorHistory[i]
            swatch.tex:SetColorTexture(color.r, color.g, color.b, 1)
            swatch.color = color
            swatch:Show()
        else
            -- Hide unused swatches
            swatch:Hide()
        end
    end
end

-- Open the color picker
function VisualConfig:OpenColorPicker()
    -- This is just a basic color picker - in a full implementation,
    -- this would be more advanced with additional features
    local r, g, b = 1, 1, 1
    
    -- Open the native color picker with our enhancements
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.opacity = 1
    ColorPickerFrame.previousValues = {r, g, b, 1}
    ColorPickerFrame:Hide() -- Need to hide it first to reset it
    ColorPickerFrame:Show()
end

-- Create a preset from current settings
function VisualConfig:CreatePresetFromCurrent()
    if not self.enabled or not self.settings.presets.enabled then
        VUI:Print("Presets are not enabled.")
        return
    end
    
    -- Show prompt for name and description
    StaticPopupDialogs["VUI_CREATE_PRESET"] = {
        text = "Enter a name for your preset:",
        button1 = "Create",
        button2 = "Cancel",
        hasEditBox = true,
        editBoxWidth = 250,
        OnShow = function(self)
            self.editBox:SetText("")
            self.editBox:SetFocus()
        end,
        OnAccept = function(self)
            local name = self.editBox:GetText()
            if name and name ~= "" then
                -- Check if preset with this name already exists
                if VisualConfig.settings.presets.savedPresets[name] then
                    -- Show confirmation dialog
                    StaticPopupDialogs["VUI_CONFIRM_OVERWRITE_PRESET"] = {
                        text = string.format("A preset named '%s' already exists. Overwrite?", name),
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            VisualConfig:FinalizePresetCreation(name)
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("VUI_CONFIRM_OVERWRITE_PRESET")
                else
                    VisualConfig:FinalizePresetCreation(name)
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    StaticPopup_Show("VUI_CREATE_PRESET")
end

-- Finalize the creation of a preset
function VisualConfig:FinalizePresetCreation(name)
    -- Collect current settings
    local settings = {}
    
    -- Copy settings from all modules
    for moduleName, module in pairs(VUI.modules) do
        if module.settings then
            settings[moduleName] = CopyTable(module.settings)
        end
    end
    
    -- Create the preset
    self.settings.presets.savedPresets[name] = {
        created = time(),
        description = "Created from current settings",
        settings = settings,
        -- Preview would be generated here in a full implementation
    }
    
    -- Notify the user
    VUI:Print(string.format("Preset '%s' created successfully.", name))
    
    -- Update the presets manager if it's open
    if self.presetsManager and self.presetsManager.frame and self.presetsManager.frame:IsVisible() then
        self.presetsManager.UpdatePresetList()
    end
end

-- Serialize a preset for export
function VisualConfig:SerializePreset(preset)
    -- In a real implementation, this would use more robust serialization
    -- For now, we'll just use a simple table-to-string function
    local serialized = "VUI:Preset:" .. self:TableToString(preset)
    return serialized
end

-- Deserialize a preset from a string
function VisualConfig:DeserializePreset(str)
    -- Check for our header
    if not str:match("^VUI:Preset:") then
        return nil
    end
    
    -- Remove the header
    str = str:gsub("^VUI:Preset:", "")
    
    -- Parse the string
    local success, preset = pcall(self.StringToTable, self, str)
    if not success or not preset then
        return nil
    end
    
    return preset
end

-- Convert a table to a string
function VisualConfig:TableToString(tbl)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end
    
    local str = "{"
    
    -- Serialize each key-value pair
    local first = true
    for k, v in pairs(tbl) do
        if not first then
            str = str .. ","
        end
        first = false
        
        -- Serialize key
        if type(k) == "string" then
            str = str .. string.format("[%q]", k)
        else
            str = str .. "[" .. tostring(k) .. "]"
        end
        
        str = str .. "="
        
        -- Serialize value
        if type(v) == "table" then
            str = str .. self:TableToString(v)
        elseif type(v) == "string" then
            str = str .. string.format("%q", v)
        else
            str = str .. tostring(v)
        end
    end
    
    str = str .. "}"
    return str
end

-- Convert a string to a table
function VisualConfig:StringToTable(str)
    -- In a real implementation, this would use more robust deserialization
    -- with security measures to prevent code execution
    local func, err = loadstring("return " .. str)
    if not func then
        error(err or "Invalid string format")
    end
    
    -- Create a secure environment
    setfenv(func, {})
    
    -- Execute the function
    local success, result = pcall(func)
    if not success then
        error(result)
    end
    
    return result
end

-- Get the position of a frame
function VisualConfig:GetFramePosition(frame)
    if not frame then return nil end
    
    -- Make sure the frame is valid
    if not frame.GetPoint then
        return nil
    end
    
    -- Get the first point (frames can have multiple points)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    if not point then
        return nil
    end
    
    -- Return the position details
    return {
        point = point,
        relativeTo = relativeTo and (relativeTo:GetName() or "UIParent") or "UIParent",
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
end

-- Save window position
function VisualConfig:SaveWindowPosition(frame, key)
    if not frame or not key then return end
    
    -- Get position
    local position = self:GetFramePosition(frame)
    if not position then return end
    
    -- Save it
    self.windowPositions[key] = position
end

-- Restore window position
function VisualConfig:RestoreWindowPosition(frame, key)
    if not frame or not key then return end
    
    -- Get saved position
    local position = self.windowPositions[key]
    if not position then return end
    
    -- Apply it
    frame:ClearAllPoints()
    frame:SetPoint(
        position.point,
        _G[position.relativeTo] or UIParent,
        position.relativePoint,
        position.xOfs,
        position.yOfs
    )
end

-- Save all window positions
function VisualConfig:SaveWindowPositions()
    if not self.enabled then return end
    
    -- Save layout editor position
    if self.layoutEditor and self.layoutEditor.frame and self.layoutEditor.frame:IsVisible() then
        self:SaveWindowPosition(self.layoutEditor.frame, "layoutEditor")
    end
    
    -- Save presets manager position
    if self.presetsManager and self.presetsManager.frame and self.presetsManager.frame:IsVisible() then
        self:SaveWindowPosition(self.presetsManager.frame, "presetsManager")
    end
    
    -- Save theme editor position
    if self.themeEditor and self.themeEditor.frame and self.themeEditor.frame:IsVisible() then
        self:SaveWindowPosition(self.themeEditor.frame, "themeEditor")
    end
    
    -- Save config positions
    for appName, container in pairs(AceConfigDialog.OpenFrames) do
        if appName:match("^VUI") and container.frame then
            self:SaveWindowPosition(container.frame, "config_" .. appName)
        end
    end
end

-- Restore all window positions
function VisualConfig:RestoreWindowPositions()
    if not self.enabled then return end
    
    -- Restore layout editor position
    if self.layoutEditor and self.layoutEditor.frame then
        self:RestoreWindowPosition(self.layoutEditor.frame, "layoutEditor")
    end
    
    -- Restore presets manager position
    if self.presetsManager and self.presetsManager.frame then
        self:RestoreWindowPosition(self.presetsManager.frame, "presetsManager")
    end
    
    -- Restore theme editor position
    if self.themeEditor and self.themeEditor.frame then
        self:RestoreWindowPosition(self.themeEditor.frame, "themeEditor")
    end
    
    -- Config positions will be restored when they are opened
end

-- Show intro tutorial
function VisualConfig:ShowIntroTutorial()
    if not self.enabled then return end
    
    -- Simple intro message
    VUI:Print("Welcome to the VUI Visual Configuration module!")
    VUI:Print("To access the enhanced configuration options, type /vuivisual")
    VUI:Print("You can also use the layout editor (/vuivisual editor) to visually arrange UI elements.")
end

-- Configuration UI callbacks
function VisualConfig:OnConfigShow()
    if not self.enabled then return end
    
    -- Enhance the config table before showing
    local appName = "VUI_Options"
    local configTable = AceConfig.registry[appName]
    if configTable then
        self:EnhanceConfigTable(configTable)
    end
end

function VisualConfig:OnConfigShown()
    if not self.enabled then return end
    
    -- Restore window position if needed
    if self.settings.general.saveWindowPosition then
        for appName, container in pairs(AceConfigDialog.OpenFrames) do
            if appName:match("^VUI") and container.frame then
                self:RestoreWindowPosition(container.frame, "config_" .. appName)
            end
        end
    end
end

function VisualConfig:OnConfigHide()
    if not self.enabled then return end
    
    -- Save window position if needed
    if self.settings.general.saveWindowPosition then
        self:SaveWindowPositions()
    end
end

-- Enhance Ace3 config table with icons, better organization, etc.
function VisualConfig:EnhanceConfigTable(configTable)
    if not self.enabled or not configTable or not configTable.args then return end
    
    -- Don't enhance if features are disabled
    if not self.settings.general.showModuleIcons and 
       not self.settings.moduleConfig.groupRelatedOptions then
        return
    end
    
    -- Add icons to modules if enabled
    if self.settings.general.showModuleIcons then
        for key, group in pairs(configTable.args) do
            if group.type == "group" and group.name then
                -- Find matching module icon
                local iconPath = moduleIcons[key:lower()] or moduleIcons.default
                
                -- Add icon to the name
                if iconPath then
                    group.icon = iconPath
                end
            end
        end
    end
    
    -- Group related options if enabled
    if self.settings.moduleConfig.groupRelatedOptions then
        -- This would be more complex in a full implementation,
        -- requiring knowledge of which options are related
    end
    
    -- Add search functionality if enabled
    if self.settings.moduleConfig.searchEnabled then
        -- This would require modifying the Ace3 dialog to add a search box
    end
    
    -- Track module status if enabled
    if self.settings.moduleConfig.showModuleStatus then
        for key, group in pairs(configTable.args) do
            if group.type == "group" and key:match("^module_") then
                local moduleName = key:gsub("^module_", "")
                local module = VUI.modules[moduleName]
                
                -- Add status indicator to the name
                if module then
                    local status = module.enabled and " |cFF00FF00(Enabled)|r" or " |cFFFF0000(Disabled)|r"
                    group.name = group.name .. status
                end
            end
        end
    end
    
    -- Add recently changed options if enabled
    if self.settings.moduleConfig.showRecentOptions and #self.recentOptions > 0 then
        -- This would require tracking option changes and adding a "recent" section
    end
end

-- Apply theme to configuration UI
function VisualConfig:ApplyTheme()
    if not self.enabled or not self.settings.general.useVUITheme then return end
    
    -- This would apply our custom theme to the Ace3 config dialogs
end

-- Remove enhancements from configuration UI
function VisualConfig:RemoveEnhancements()
    if not self.enabled then return end
    
    -- Close any of our open windows
    if self.layoutEditor and self.layoutEditor.frame and self.layoutEditor.frame:IsVisible() then
        self.layoutEditor.frame:Hide()
    end
    
    if self.presetsManager and self.presetsManager.frame and self.presetsManager.frame:IsVisible() then
        self.presetsManager.frame:Hide()
    end
    
    if self.themeEditor and self.themeEditor.frame and self.themeEditor.frame:IsVisible() then
        self.themeEditor.frame:Hide()
    end
    
    -- Reset the color picker if hooked
    if self.colorPickerHooked then
        -- Restore the original color picker function
        if self.originalColorPickerFrame_OnColorSelect then
            ColorPickerFrame_OnColorSelect = self.originalColorPickerFrame_OnColorSelect
        end
    end
end

-- Refresh configuration UI
function VisualConfig:RefreshConfigUI()
    if not self.enabled then return end
    
    -- Refresh open config dialogs
    for appName, container in pairs(AceConfigDialog.OpenFrames) do
        if appName:match("^VUI") then
            AceConfigDialog:Open(appName, container.frame.object)
        end
    end
end

-- Register the module with VUI
VUI.visualconfig = VisualConfig