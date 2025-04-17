-- VUI Module Template
-- This file provides a standard template for modules to connect to the VUI framework
local _, VUI = ...

-- Create the module template
VUI.ModuleTemplate = {}

-- Function to create a new module
function VUI.ModuleTemplate:Create(name)
    -- Create module namespace
    local module = {}
    
    -- Set module metadata
    module.name = name
    module.enabled = false
    module.uiConnected = false
    
    -- UI elements storage
    module.frames = {}
    
    -- Connect to UI framework
    function module:ConnectUI(UI)
        if not UI then return end
        
        -- Store UI reference
        self.UI = UI
        
        -- Add helper functions for creating UI elements
        self.CreateFrame = function(self, frameName, parent)
            local frame = UI:CreateFrame(frameName, parent)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, frame)
            
            return frame
        end
        
        self.CreateButton = function(self, buttonName, parent, text)
            local button = UI:CreateButton(buttonName, parent, text)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, button)
            
            return button
        end
        
        self.CreateCheckButton = function(self, checkName, parent, text)
            local check = UI:CreateCheckButton(checkName, parent, text)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, check)
            
            return check
        end
        
        self.CreateSlider = function(self, parent, sliderName, label, min, max, step)
            local slider = UI:CreateSlider(parent, sliderName, label, min, max, step)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, slider)
            
            return slider
        end
        
        self.CreateEditBox = function(self, editName, parent, width, height)
            local edit = UI:CreateEditBox(editName, parent, width, height)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, edit)
            
            return edit
        end
        
        self.CreateIconButton = function(self, iconName, parent, texture, size)
            local icon = UI:CreateIconButton(iconName, parent, texture, size)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, icon)
            
            return icon
        end
        
        return true
    end
    
    -- Connect to widget framework
    function module:ConnectWidgets(Widgets)
        if not Widgets then return end
        
        -- Store widgets reference
        self.Widgets = Widgets
        
        -- Add helper functions for creating widgets
        self.CreatePanel = function(self, name, parent, width, height, title)
            local panel = Widgets:CreatePanel(name, parent, width, height, title)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, panel)
            
            return panel
        end
        
        self.CreateProgressBar = function(self, name, parent, width, height, label)
            local bar = Widgets:CreateProgressBar(name, parent, width, height, label)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, bar)
            
            return bar
        end
        
        self.CreateIconGrid = function(self, name, parent, columns, iconSize, spacing)
            local grid = Widgets:CreateIconGrid(name, parent, columns, iconSize, spacing)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, grid)
            
            return grid
        end
        
        self.CreateTreeView = function(self, name, parent, width, height)
            local tree = Widgets:CreateTreeView(name, parent, width, height)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, tree)
            
            return tree
        end
        
        self.CreateDialog = function(self, name, parent, width, height, title, text)
            local dialog = Widgets:CreateDialog(name, parent, width, height, title, text)
            
            -- Add to module's frames collection for tracking
            table.insert(self.frames, dialog)
            
            return dialog
        end
        
        return true
    end
    
    -- Connect to media system
    function module:ConnectMedia(media)
        if not media then return end
        
        -- Store media reference
        self.media = media
        
        return true
    end
    
    -- Apply a theme to the module UI
    function module:ApplyTheme(theme, themeData)
        if not themeData or not self.frames then return end
        
        -- Update all module frames with the theme
        for _, frame in ipairs(self.frames) do
            if frame.UpdateAppearance then
                frame:UpdateAppearance()
            end
        end
        
        return true
    end
    
    -- Update UI when settings change
    function module:UpdateUI()
        if not self.frames then return end
        
        -- Update all module frames
        for _, frame in ipairs(self.frames) do
            if frame.UpdateAppearance then
                frame:UpdateAppearance()
            end
        end
        
        return true
    end
    
    -- Function called when module is enabled
    function module:Enable()
        self.enabled = true
        
        -- Additional enabling code to be added by the module
        
        return true
    end
    
    -- Function called when module is disabled
    function module:Disable()
        self.enabled = false
        
        -- Hide all frames
        for _, frame in ipairs(self.frames) do
            if frame.Hide then
                frame:Hide()
            end
        end
        
        -- Additional disabling code to be added by the module
        
        return true
    end
    
    -- Return the new module
    return module
end

-- Function to extend an existing module with our template
function VUI.ModuleTemplate:Extend(module)
    if not module then return nil end
    
    -- Add UI connection if missing
    if not module.ConnectUI then
        module.ConnectUI = self:Create("temp").ConnectUI
    end
    
    -- Add Widgets connection if missing
    if not module.ConnectWidgets then
        module.ConnectWidgets = self:Create("temp").ConnectWidgets
    end
    
    -- Add Media connection if missing
    if not module.ConnectMedia then
        module.ConnectMedia = self:Create("temp").ConnectMedia
    end
    
    -- Add theme handling if missing
    if not module.ApplyTheme then
        module.ApplyTheme = self:Create("temp").ApplyTheme
    end
    
    -- Add UI updating if missing
    if not module.UpdateUI then
        module.UpdateUI = self:Create("temp").UpdateUI
    end
    
    -- Initialize frames table if missing
    if not module.frames then
        module.frames = {}
    end
    
    return module
end