-- VUI Module Template
-- This file provides a standard template for modules to connect to the VUI framework
-- Enhanced with deeper Ace3 integration while maintaining SUI design approach
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the module template
VUI.ModuleTemplate = {}

-- Function to create a new module
function VUI.ModuleTemplate:Create(name)
    -- Create module namespace as an Ace3-style object
    local module = {}
    
    -- Set module metadata
    module.name = name
    module.enabled = false
    module.uiConnected = false
    
    -- UI elements storage
    module.frames = {}
    
    -- Enhanced Ace3 event handling with method calls (AceEvent-3.0 style)
    function module:RegisterEvent(event, callback)
        if not self.eventFrame then
            self.eventFrame = CreateFrame("Frame")
            self.eventFrame.events = {}
            self.eventFrame:SetScript("OnEvent", function(_, event, ...)
                local handler = self.eventFrame.events[event]
                if type(handler) == "function" then
                    handler(self, event, ...)
                elseif type(handler) == "string" and self[handler] then
                    self[handler](self, event, ...)
                end
            end)
        end
        
        -- Support method name or function handler (AceEvent style)
        self.eventFrame.events[event] = callback or event
        self.eventFrame:RegisterEvent(event)
        return self
    end
    
    function module:UnregisterEvent(event)
        if self.eventFrame and self.eventFrame.events[event] then
            self.eventFrame:UnregisterEvent(event)
            self.eventFrame.events[event] = nil
        end
        return self
    end
    
    function module:UnregisterAllEvents()
        if self.eventFrame then
            self.eventFrame:UnregisterAllEvents()
            self.eventFrame.events = {}
        end
        return self
    end
    
    -- Enhanced timer functions using AceTimer patterns
    function module:ScheduleTimer(callback, delay, ...)
        if not self.timers then self.timers = {} end
        local args = {...}
        
        -- Use VUI's AceTimer
        local handle = VUI:ScheduleTimer(function() 
            if type(callback) == "function" then
                callback(unpack(args))
            elseif type(callback) == "string" and self[callback] then
                self[callback](self, unpack(args))
            end
        end, delay)
        
        -- Store the timer handle for cancellation
        table.insert(self.timers, handle)
        return handle
    end
    
    function module:CancelTimer(handle)
        if not self.timers then return false end
        
        -- Find and remove the timer
        for i, timerHandle in ipairs(self.timers) do
            if timerHandle == handle then
                VUI:CancelTimer(handle)
                table.remove(self.timers, i)
                return true
            end
        end
        
        return false
    end
    
    function module:CancelAllTimers()
        if not self.timers then return end
        
        for _, handle in ipairs(self.timers) do
            VUI:CancelTimer(handle)
        end
        
        self.timers = {}
    end
    
    -- Hook functions similar to AceHook but adapted for our module system
    function module:Hook(object, method, hook, secure)
        if not self.hooks then self.hooks = {} end
        
        -- Use VUI's AceHook
        local hookResult = VUI:Hook(object, method, function(...)
            return hook(self, ...)
        end, secure)
        
        if hookResult then
            -- Store hook reference
            if not self.hooks[object] then self.hooks[object] = {} end
            self.hooks[object][method] = true
        end
        
        return hookResult
    end
    
    function module:RawHook(object, method, hook, secure)
        if not self.hooks then self.hooks = {} end
        
        -- Use VUI's AceHook RawHook
        local hookResult = VUI:RawHook(object, method, function(...)
            return hook(self, ...)
        end, secure)
        
        if hookResult then
            -- Store hook reference
            if not self.hooks[object] then self.hooks[object] = {} end
            self.hooks[object][method] = true
        end
        
        return hookResult
    end
    
    function module:SecureHook(object, method, hook)
        return self:Hook(object, method, hook, true)
    end
    
    function module:Unhook(object, method)
        if not self.hooks or not self.hooks[object] or not self.hooks[object][method] then
            return false
        end
        
        -- Use VUI's AceHook Unhook
        VUI:Unhook(object, method)
        self.hooks[object][method] = nil
        
        -- Clean up empty tables
        if not next(self.hooks[object]) then
            self.hooks[object] = nil
        end
        
        return true
    end
    
    function module:UnhookAll()
        if not self.hooks then return end
        
        for object, methods in pairs(self.hooks) do
            for method in pairs(methods) do
                VUI:Unhook(object, method)
            end
        end
        
        self.hooks = {}
    end
    
    -- Messaging system using AceComm patterns
    function module:RegisterComm(prefix, callback)
        if not self.registeredComms then self.registeredComms = {} end
        
        -- Use VUI's AceComm if it exists
        if VUI.RegisterComm then
            VUI:RegisterComm(prefix, function(_, msgType, message, distribution, sender)
                if type(callback) == "function" then
                    callback(self, msgType, message, distribution, sender)
                elseif type(callback) == "string" and self[callback] then
                    self[callback](self, msgType, message, distribution, sender)
                end
            end)
            
            -- Store comm registration info
            self.registeredComms[prefix] = callback
        end
        
        return self
    end
    
    function module:UnregisterComm(prefix)
        if not self.registeredComms or not self.registeredComms[prefix] then return end
        
        if VUI.UnregisterComm then
            VUI:UnregisterComm(prefix)
        end
        
        self.registeredComms[prefix] = nil
        return self
    end
    
    function module:SendCommMessage(prefix, text, distribution, target, priority)
        if VUI.SendCommMessage then
            return VUI:SendCommMessage(prefix, text, distribution, target, priority)
        end
    end
    
    -- Enhanced database access with default profiles (AceDB style)
    function module:GetDB()
        if not VUI.db then return {} end
        if not VUI.db.profile.modules[self.name] then
            VUI.db.profile.modules[self.name] = {}
        end
        return VUI.db.profile.modules[self.name]
    end
    
    function module:SetDBValue(key, value)
        local db = self:GetDB()
        db[key] = value
        return value
    end
    
    function module:GetDBValue(key, default)
        local db = self:GetDB()
        if db[key] == nil then
            return default
        end
        return db[key]
    end
    
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
    
    -- AceAddon lifecycle methods
    function module:OnInitialize()
        -- Default initialization logic

        
        -- Get module settings from VUI main database
        if self.name then
            -- Get direct reference to our module's profile settings
            self.db = VUI.db
            self.settings = VUI.db.profile.modules[self.name] or {}
            
            -- Add profile change callback - calls UpdateUI when profile changes
            if not self._profileCallbackRegistered then
                VUI.db.RegisterCallback(self, "OnProfileChanged", "UpdateUI")
                VUI.db.RegisterCallback(self, "OnProfileCopied", "UpdateUI")
                VUI.db.RegisterCallback(self, "OnProfileReset", "UpdateUI")
                self._profileCallbackRegistered = true
            end
        end
        
        -- If module has its own separate DB, also initialize that
        if self.name and self.dbName then
            self.moduleDB = LibStub("AceDB-3.0"):New(self.dbName, self.defaults or {})
        end
    end
    
    -- Handle profile changes
    function module:UpdateUI()

        
        -- Refresh settings reference
        if self.name then
            self.settings = VUI.db.profile.modules[self.name] or {}
        end
        
        -- Update all the module's frames
        for _, frame in pairs(self.frames) do
            if frame.UpdateAppearance then
                frame:UpdateAppearance(VUI.db.profile.appearance)
            end
        end
        
        -- Custom module UI updates
        if self.UpdateSettings then
            self:UpdateSettings()
        end
    end
    
    function module:OnEnable()
        -- This will be called when the module is enabled
        self.enabled = true
    end
    
    function module:OnDisable()
        -- This will be called when the module is disabled
        self.enabled = false
        
        -- Hide all frames
        for _, frame in ipairs(self.frames) do
            if frame.Hide then
                frame:Hide()
            end
        end
        
        -- Clean up events, hooks, and timers
        self:UnregisterAllEvents()
        self:UnhookAll()
        self:CancelAllTimers()
    end
    
    -- Compatibility with existing code
    function module:Initialize()
        self:OnInitialize()
    end
    
    function module:Enable()
        self:OnEnable()
        return true
    end
    
    function module:Disable()
        self:OnDisable()
        return true
    end
    
    -- AceConsole-style Print method
    function module:Print(...)
        VUI:Print(self.name .. ": " .. strjoin(" ", tostringall(...)))
    end
    
    -- Return the new module
    return module
end

-- Function to extend an existing module with our template
function VUI.ModuleTemplate:Extend(module)
    if not module then return nil end
    
    -- Add Ace-style event handling if missing
    if not module.RegisterEvent then
        module.RegisterEvent = self:Create("temp").RegisterEvent
        module.UnregisterEvent = self:Create("temp").UnregisterEvent
        module.UnregisterAllEvents = self:Create("temp").UnregisterAllEvents
    end
    
    -- Add timer functions if missing
    if not module.ScheduleTimer then
        module.ScheduleTimer = self:Create("temp").ScheduleTimer
        module.CancelTimer = self:Create("temp").CancelTimer
        module.CancelAllTimers = self:Create("temp").CancelAllTimers
    end
    
    -- Add hook functions if missing
    if not module.Hook then
        module.Hook = self:Create("temp").Hook
        module.RawHook = self:Create("temp").RawHook
        module.SecureHook = self:Create("temp").SecureHook
        module.Unhook = self:Create("temp").Unhook
        module.UnhookAll = self:Create("temp").UnhookAll
    end
    
    -- Add DB functions if missing
    if not module.GetDB then
        module.GetDB = self:Create("temp").GetDB
        module.SetDBValue = self:Create("temp").SetDBValue
        module.GetDBValue = self:Create("temp").GetDBValue
    end
    
    -- Add comm functions if missing
    if not module.RegisterComm then
        module.RegisterComm = self:Create("temp").RegisterComm
        module.UnregisterComm = self:Create("temp").UnregisterComm
        module.SendCommMessage = self:Create("temp").SendCommMessage
    end
    
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
    
    -- Add Print function if missing
    if not module.Print then
        module.Print = self:Create("temp").Print
    end
    
    -- Initialize frames table if missing
    if not module.frames then
        module.frames = {}
    end
    
    -- Add AceAddon lifecycle methods if missing
    if not module.OnInitialize and not module.Initialize then
        module.OnInitialize = self:Create("temp").OnInitialize
    end
    
    if not module.OnEnable and not module.Enable then
        module.OnEnable = self:Create("temp").OnEnable
    elseif module.Enable and not module.OnEnable then
        module.OnEnable = module.Enable
    end
    
    if not module.OnDisable and not module.Disable then
        module.OnDisable = self:Create("temp").OnDisable
    elseif module.Disable and not module.OnDisable then
        module.OnDisable = module.Disable
    end
    
    return module
end