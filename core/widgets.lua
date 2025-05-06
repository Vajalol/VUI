-- VUI Widgets
-- This file provides advanced UI widgets built on top of the basic UI framework
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create widgets namespace 
VUI.Widgets = {}

-- Store created widgets for tracking
VUI.Widgets.elements = {}

-- Container Panel widget (a frame with title, border, and optional content)
function VUI.Widgets:CreatePanel(name, parent, width, height, title)
    parent = parent or UIParent
    width = width or 300
    height = height or 200
    
    -- Create the panel frame
    local panel = VUI.UI:CreateFrame(name, parent)
    panel:SetSize(width, height)
    
    -- Add title if specified
    if title then
        panel.titleBar = VUI.UI:CreateFrame(name .. "TitleBar", panel)
        panel.titleBar:SetPoint("TOPLEFT", 0, 0)
        panel.titleBar:SetPoint("TOPRIGHT", 0, 0)
        panel.titleBar:SetHeight(24)
        
        panel.title = panel.titleBar:CreateFontString(nil, "OVERLAY")
        panel.title:SetPoint("CENTER", panel.titleBar, "CENTER", 0, 0)
        panel.title:SetText(title)
        
        -- Apply font settings
        local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
        local fontSize = VUI.db.profile.appearance.fontSize + 2
        local colors = VUI.UI:GetThemeColors()
        
        panel.title:SetFont(fontName, fontSize, "OUTLINE")
        panel.title:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
        
        -- Adjust content area to make room for title
        panel.content = VUI.UI:CreateFrame(name .. "Content", panel)
        panel.content:SetPoint("TOPLEFT", panel.titleBar, "BOTTOMLEFT", 0, 0)
        panel.content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    else
        -- No title, content takes full panel area
        panel.content = VUI.UI:CreateFrame(name .. "Content", panel)
        panel.content:SetAllPoints(panel)
    end
    
    -- Add to tracking
    table.insert(VUI.Widgets.elements, panel)
    
    -- Add method to update title font/color when needed
    panel.UpdateTitle = function(self, appearance)
        if not self.title then return end
        
        appearance = appearance or VUI.db.profile.appearance
        local fontName = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize + 2
        local colors = VUI.UI:GetThemeColors()
        
        self.title:SetFont(fontName, fontSize, "OUTLINE")
        self.title:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
    end
    
    return panel
end

-- Icon Grid widget (displays a grid of icon buttons)
function VUI.Widgets:CreateIconGrid(name, parent, columns, iconSize, spacing)
    parent = parent or UIParent
    columns = columns or 5
    iconSize = iconSize or 32
    spacing = spacing or 4
    
    -- Create the grid frame
    local grid = VUI.UI:CreateFrame(name, parent)
    grid.buttons = {}
    grid.columns = columns
    grid.iconSize = iconSize
    grid.spacing = spacing
    
    -- Add method to add an icon
    grid.AddIcon = function(self, texture, tooltip, callback)
        local index = #self.buttons + 1
        local row = math.floor((index - 1) / self.columns)
        local col = (index - 1) % self.columns
        
        local button = VUI.UI:CreateIconButton(name .. "Button" .. index, self, texture, self.iconSize)
        button:SetPoint("TOPLEFT", self, "TOPLEFT", col * (self.iconSize + self.spacing), -row * (self.iconSize + self.spacing))
        
        if tooltip then
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltip)
                GameTooltip:Show()
            end)
            
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
        
        if callback then
            button:SetScript("OnClick", callback)
        end
        
        self.buttons[index] = button
        
        -- Resize the grid to accommodate the new button
        local rows = math.ceil(index / self.columns)
        self:SetSize(
            self.columns * self.iconSize + (self.columns - 1) * self.spacing,
            rows * self.iconSize + (rows - 1) * self.spacing
        )
        
        return button
    end
    
    -- Add method to clear all icons
    grid.Clear = function(self)
        for _, button in ipairs(self.buttons) do
            button:Hide()
        end
        self.buttons = {}
        self:SetSize(1, 1)
    end
    
    -- Add to tracking
    table.insert(VUI.Widgets.elements, grid)
    
    return grid
end

-- Progress Bar widget (enhanced status bar with label, value text, and border)
function VUI.Widgets:CreateProgressBar(name, parent, width, height, label)
    parent = parent or UIParent
    width = width or 200
    height = height or 24
    
    -- Create frame to hold the bar and text elements
    local frame = VUI.UI:CreateFrame(name, parent)
    frame:SetSize(width, height)
    
    -- Create the status bar
    frame.bar = VUI.UI:CreateStatusBar(name .. "Bar", frame, width - 4, height - 4)
    frame.bar:SetPoint("CENTER")
    
    -- Add label text
    frame.label = frame:CreateFontString(nil, "OVERLAY")
    frame.label:SetPoint("LEFT", frame, "LEFT", 6, 0)
    frame.label:SetText(label or "")
    
    -- Add value text
    frame.value = frame:CreateFontString(nil, "OVERLAY")
    frame.value:SetPoint("RIGHT", frame, "RIGHT", -6, 0)
    frame.value:SetText("")
    
    -- Apply font settings
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = VUI.UI:GetThemeColors()
    
    frame.label:SetFont(fontName, fontSize, "OUTLINE")
    frame.value:SetFont(fontName, fontSize, "OUTLINE")
    frame.label:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    frame.value:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    
    -- Add update method
    frame.SetValue = function(self, value, maxValue)
        maxValue = maxValue or 1
        value = math.min(value, maxValue)
        
        -- Update the bar
        self.bar:SetMinMaxValues(0, maxValue)
        self.bar:SetValue(value)
        
        -- Update the text
        self.value:SetText(value .. " / " .. maxValue)
    end
    
    -- Add method to set color
    frame.SetColor = function(self, r, g, b, a)
        self.bar:SetStatusBarColor(r, g, b, a or 1)
    end
    
    -- Add to tracking
    table.insert(VUI.Widgets.elements, frame)
    
    -- Add update method for appearance
    frame.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        local fontName = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        local colors = VUI.UI:GetThemeColors()
        
        self.label:SetFont(fontName, fontSize, "OUTLINE")
        self.value:SetFont(fontName, fontSize, "OUTLINE")
        self.label:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        self.value:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    end
    
    return frame
end

-- Tree View widget (hierarchical list with expandable sections)
function VUI.Widgets:CreateTreeView(name, parent, width, height)
    parent = parent or UIParent
    width = width or 200
    height = height or 400
    
    -- Create the main frame and scrollframe
    local frame, content = VUI.UI:CreateScrollFrame(name, parent, width, height)
    
    -- Initialize tree data
    frame.items = {}
    frame.nodes = {}
    frame.expandedNodes = {}
    frame.selectedNode = nil
    
    -- Add a node to the tree
    frame.AddNode = function(self, text, parent, data, icon)
        local node = {
            text = text,
            parent = parent,
            children = {},
            data = data,
            icon = icon,
            level = parent and (self.nodes[parent].level + 1) or 0
        }
        
        local nodeId = #self.nodes + 1
        self.nodes[nodeId] = node
        
        -- Add to parent's children if it has a parent
        if parent and self.nodes[parent] then
            table.insert(self.nodes[parent].children, nodeId)
        else
            -- It's a root node
            table.insert(self.items, nodeId)
        end
        
        -- Mark as needing rebuild
        self.needsRebuild = true
        
        return nodeId
    end
    
    -- Build the visual representation of the tree
    frame.RebuildTree = function(self)
        -- Clear existing buttons
        for i = 1, #self.buttons do
            self.buttons[i]:Hide()
        end
        
        self.buttons = self.buttons or {}
        local index = 1
        
        -- Function to recursively add nodes to the tree
        local function AddNodeToTree(nodeId, indent)
            local node = self.nodes[nodeId]
            if not node then return index end
            
            -- Create or reuse a button for this node
            local button = self.buttons[index]
            if not button then
                button = CreateFrame("Button", name .. "Node" .. index, content)
                button:SetHeight(20)
                
                -- Background for highlighting
                button.bg = button:CreateTexture(nil, "BACKGROUND")
                button.bg:SetAllPoints()
                button.bg:SetColorTexture(0.2, 0.2, 0.2, 0)
                
                -- Expand/collapse texture
                button.expand = button:CreateTexture(nil, "ARTWORK")
                button.expand:SetSize(16, 16)
                button.expand:SetPoint("LEFT", 0, 0)
                
                -- Icon texture (if any)
                button.icon = button:CreateTexture(nil, "ARTWORK")
                button.icon:SetSize(16, 16)
                button.icon:SetPoint("LEFT", button.expand, "RIGHT", 2, 0)
                
                -- Text label
                button.text = button:CreateFontString(nil, "OVERLAY")
                button.text:SetPoint("LEFT", button.icon, "RIGHT", 4, 0)
                button.text:SetJustifyH("LEFT")
                
                -- Apply font settings
                local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
                local fontSize = VUI.db.profile.appearance.fontSize
                button.text:SetFont(fontName, fontSize, "")
                
                -- Selection highlight
                button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
                
                -- Click handler
                button:SetScript("OnClick", function(clickedButton, mouseButton)
                    local nodeData = clickedButton.nodeData
                    local nodeId = clickedButton.nodeId
                    
                    if mouseButton == "LeftButton" then
                        -- Expand/collapse if it has children
                        if #self.nodes[nodeId].children > 0 then
                            if self.expandedNodes[nodeId] then
                                self.expandedNodes[nodeId] = nil
                            else
                                self.expandedNodes[nodeId] = true
                            end
                            self:RebuildTree()
                        end
                        
                        -- Select the node
                        self.selectedNode = nodeId
                        self:SelectNode(nodeId)
                        
                        -- Fire callback
                        if self.OnNodeSelected then
                            self:OnNodeSelected(nodeId, self.nodes[nodeId])
                        end
                    end
                end)
                
                self.buttons[index] = button
            end
            
            -- Update button data
            button.nodeId = nodeId
            button.nodeData = node.data
            
            -- Update expand/collapse texture
            if #node.children > 0 then
                button.expand:Show()
                if self.expandedNodes[nodeId] then
                    button.expand:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
                else
                    button.expand:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
                end
            else
                button.expand:Hide()
            end
            
            -- Update icon
            if node.icon then
                button.icon:SetTexture(node.icon)
                button.icon:Show()
            else
                button.icon:Hide()
            end
            
            -- Update text
            button.text:SetText(node.text)
            local colors = VUI.UI:GetThemeColors()
            if nodeId == self.selectedNode then
                button.text:SetTextColor(colors.accent.r, colors.accent.g, colors.accent.b, colors.accent.a)
                button.bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            else
                button.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
                button.bg:SetColorTexture(0, 0, 0, 0)
            end
            
            -- Position the button
            button:SetPoint("TOPLEFT", content, "TOPLEFT", indent * 20, -(index - 1) * 20)
            button:SetPoint("RIGHT", content, "RIGHT", 0, 0)
            button:Show()
            
            index = index + 1
            
            -- Add children if expanded
            if self.expandedNodes[nodeId] then
                for _, childId in ipairs(node.children) do
                    index = AddNodeToTree(childId, indent + 1)
                end
            end
            
            return index
        end
        
        -- Add all root nodes
        for _, nodeId in ipairs(self.items) do
            index = AddNodeToTree(nodeId, 0)
        end
        
        -- Resize the content
        content:SetHeight(math.max(height, (index - 1) * 20))
        
        self.needsRebuild = false
    end
    
    -- Select a node
    frame.SelectNode = function(self, nodeId)
        self.selectedNode = nodeId
        
        -- Update visual selection
        for i = 1, #self.buttons do
            local button = self.buttons[i]
            local colors = VUI.UI:GetThemeColors()
            
            if button.nodeId == nodeId then
                button.text:SetTextColor(colors.accent.r, colors.accent.g, colors.accent.b, colors.accent.a)
                button.bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            else
                button.text:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
                button.bg:SetColorTexture(0, 0, 0, 0)
            end
        end
    end
    
    -- Expand a node
    frame.ExpandNode = function(self, nodeId, recursive)
        if not self.nodes[nodeId] then return end
        
        self.expandedNodes[nodeId] = true
        
        if recursive then
            for _, childId in ipairs(self.nodes[nodeId].children) do
                self:ExpandNode(childId, recursive)
            end
        end
        
        self.needsRebuild = true
    end
    
    -- Collapse a node
    frame.CollapseNode = function(self, nodeId, recursive)
        if not self.nodes[nodeId] then return end
        
        self.expandedNodes[nodeId] = nil
        
        if recursive then
            for _, childId in ipairs(self.nodes[nodeId].children) do
                self:CollapseNode(childId, recursive)
            end
        end
        
        self.needsRebuild = true
    end
    
    -- Clear all nodes
    frame.Clear = function(self)
        self.items = {}
        self.nodes = {}
        self.expandedNodes = {}
        self.selectedNode = nil
        
        for i = 1, #self.buttons do
            self.buttons[i]:Hide()
        end
    end
    
    -- Set up update handler
    frame:SetScript("OnUpdate", function(self)
        if self.needsRebuild then
            self:RebuildTree()
        end
    end)
    
    -- Add to tracking
    table.insert(VUI.Widgets.elements, frame)
    
    -- Add appearance update method
    frame.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        local fontName = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        
        for i = 1, #self.buttons do
            local button = self.buttons[i]
            if button and button.text then
                button.text:SetFont(fontName, fontSize, "")
            end
        end
        
        -- If we have buttons already, trigger a rebuild to update colors
        if #self.buttons > 0 then
            self.needsRebuild = true
        end
    end
    
    return frame
end

-- Tooltip Scanner widget (creates a tooltip for scanning spell/item info)
function VUI.Widgets:CreateTooltipScanner(name)
    local scanner = CreateFrame("GameTooltip", name, nil, "GameTooltipTemplate")
    scanner:SetOwner(UIParent, "ANCHOR_NONE")
    
    -- Method to scan an item tooltip
    scanner.ScanItem = function(self, itemID, itemLink)
        self:ClearLines()
        
        if itemLink then
            self:SetHyperlink(itemLink)
        elseif itemID then
            self:SetItemByID(itemID)
        else
            return nil
        end
        
        -- Collect lines from tooltip
        local lines = {}
        for i = 1, self:NumLines() do
            local left = _G[self:GetName() .. "TextLeft" .. i]
            local right = _G[self:GetName() .. "TextRight" .. i]
            
            if left and left:GetText() then
                table.insert(lines, {left = left:GetText(), right = right:GetText()})
            end
        end
        
        return lines
    end
    
    -- Method to scan a spell tooltip
    scanner.ScanSpell = function(self, spellID)
        self:ClearLines()
        self:SetSpellByID(spellID)
        
        -- Collect lines from tooltip
        local lines = {}
        for i = 1, self:NumLines() do
            local left = _G[self:GetName() .. "TextLeft" .. i]
            local right = _G[self:GetName() .. "TextRight" .. i]
            
            if left and left:GetText() then
                table.insert(lines, {left = left:GetText(), right = right:GetText()})
            end
        end
        
        return lines
    end
    
    -- Method to scan a unit tooltip
    scanner.ScanUnit = function(self, unit)
        self:ClearLines()
        self:SetUnit(unit)
        
        -- Collect lines from tooltip
        local lines = {}
        for i = 1, self:NumLines() do
            local left = _G[self:GetName() .. "TextLeft" .. i]
            local right = _G[self:GetName() .. "TextRight" .. i]
            
            if left and left:GetText() then
                table.insert(lines, {left = left:GetText(), right = right:GetText()})
            end
        end
        
        return lines
    end
    
    return scanner
end

-- Dialog widget (modal dialog box with title, content, and buttons)
function VUI.Widgets:CreateDialog(name, parent, width, height, title, text)
    parent = parent or UIParent
    width = width or 400
    height = height or 200
    
    -- Create the main frame
    local dialog = VUI.UI:CreateFrame(name, parent)
    dialog:SetSize(width, height)
    dialog:SetPoint("CENTER", parent, "CENTER", 0, 0)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetFrameLevel(100)
    dialog:EnableMouse(true)
    
    -- Add title
    dialog.title = dialog:CreateFontString(nil, "OVERLAY")
    dialog.title:SetPoint("TOP", dialog, "TOP", 0, -10)
    dialog.title:SetText(title or "Dialog")
    
    -- Add message text
    dialog.message = dialog:CreateFontString(nil, "OVERLAY")
    dialog.message:SetPoint("TOP", dialog.title, "BOTTOM", 0, -15)
    dialog.message:SetPoint("LEFT", dialog, "LEFT", 15, 0)
    dialog.message:SetPoint("RIGHT", dialog, "RIGHT", -15, 0)
    dialog.message:SetJustifyH("CENTER")
    dialog.message:SetJustifyV("TOP")
    dialog.message:SetText(text or "")
    
    -- Apply font settings
    local fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    local colors = VUI.UI:GetThemeColors()
    
    dialog.title:SetFont(fontName, fontSize + 4, "OUTLINE")
    dialog.title:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
    
    dialog.message:SetFont(fontName, fontSize + 1, "")
    dialog.message:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    
    -- Create button container
    dialog.buttonContainer = CreateFrame("Frame", name .. "ButtonContainer", dialog)
    dialog.buttonContainer:SetHeight(40)
    dialog.buttonContainer:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 10, 10)
    dialog.buttonContainer:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -10, 10)
    
    -- Button creation helper
    dialog.buttons = {}
    dialog.AddButton = function(self, text, callback, isDefault)
        local index = #self.buttons + 1
        local button = VUI.UI:CreateButton(name .. "Button" .. index, self.buttonContainer, text)
        button:SetHeight(30)
        
        -- Handle button click
        button:SetScript("OnClick", function()
            if callback then
                callback(self)
            end
            self:Hide()
        end)
        
        -- Store the button
        self.buttons[index] = button
        
        -- Position the buttons evenly
        local buttonWidth = (self.buttonContainer:GetWidth() - 10 * (#self.buttons + 1)) / #self.buttons
        for i, btn in ipairs(self.buttons) do
            btn:SetWidth(buttonWidth)
            btn:ClearAllPoints()
            btn:SetPoint("BOTTOMLEFT", self.buttonContainer, "BOTTOMLEFT", 10 + (buttonWidth + 10) * (i - 1), 5)
        end
        
        -- If this is the default button, set focus to it
        if isDefault then
            self.defaultButton = button
            button:SetFrameLevel(button:GetFrameLevel() + 1)
        end
        
        return button
    end
    
    -- Set dialog content
    dialog.SetContent = function(self, text)
        self.message:SetText(text or "")
    end
    
    -- Add backdrop overlay to block clicking behind
    dialog.overlay = CreateFrame("Frame", name .. "Overlay", dialog)
    dialog.overlay:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    dialog.overlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    dialog.overlay:SetFrameStrata("DIALOG")
    dialog.overlay:SetFrameLevel(dialog:GetFrameLevel() - 1)
    dialog.overlay:EnableMouse(true)
    dialog.overlay:SetScript("OnShow", function(self)
        self.fadeIn = self:CreateAnimationGroup()
        local fade = self.fadeIn:CreateAnimation("Alpha")
        fade:SetFromAlpha(0)
        fade:SetToAlpha(0.5)
        fade:SetDuration(0.25)
        self.fadeIn:Play()
    end)
    
    -- Set overlay appearance
    dialog.overlay.bg = dialog.overlay:CreateTexture(nil, "BACKGROUND")
    dialog.overlay.bg:SetAllPoints()
    dialog.overlay.bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Handle dialog close
    dialog:SetScript("OnHide", function(self)
        self.overlay:Hide()
    end)
    
    -- Show the dialog
    dialog.Show = function(self)
        self.overlay:Show()
        self:Show()
        
        -- Focus the default button if there is one
        if self.defaultButton then
            self.defaultButton:SetFocus()
        end
    end
    
    -- Initially hidden
    dialog:Hide()
    dialog.overlay:Hide()
    
    -- Add to tracking
    table.insert(VUI.Widgets.elements, dialog)
    
    -- Add appearance update method
    dialog.UpdateAppearance = function(self, appearance)
        appearance = appearance or VUI.db.profile.appearance
        local fontName = VUI:GetFont(appearance.font)
        local fontSize = appearance.fontSize
        local colors = VUI.UI:GetThemeColors()
        
        -- Update title and message fonts
        self.title:SetFont(fontName, fontSize + 4, "OUTLINE")
        self.title:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
        
        self.message:SetFont(fontName, fontSize + 1, "")
        self.message:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
    end
    
    return dialog
end

-- Update the appearance of all widgets when settings change
function VUI.Widgets:UpdateAppearance()
    for _, widget in ipairs(self.elements) do
        if widget.UpdateAppearance then
            widget:UpdateAppearance(VUI.db.profile.appearance)
        end
    end
end

-- Register with the main UI system for updates
VUI:RegisterEvent("ADDON_LOADED", function()
    table.insert(VUI.modules, {
        name = "Widgets",
        UpdateAppearance = function()
            VUI.Widgets:UpdateAppearance()
        end
    })
end)