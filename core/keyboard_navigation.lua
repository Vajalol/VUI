--[[
    VUI - Keyboard Navigation System
    Author: VortexQ8
    
    This file implements enhanced keyboard navigation functionality for VUI,
    allowing the addon to be operated with keyboard controls for improved
    accessibility and convenience.
    
    Key features:
    1. Tab navigation between UI elements
    2. Arrow key movement between related elements
    3. Enhanced keyboard shortcuts with visual indicators
    4. Focus indicators for currently selected elements
    5. Contextual shortcut suggestions
]]

local _, VUI = ...
local L = VUI.L

-- Create the KeyboardNavigation system
local KeyboardNavigation = {}
VUI.KeyboardNavigation = KeyboardNavigation

-- Keyboard navigation mode constants
local NAV_MODE = {
    DISABLED = 0,    -- Keyboard navigation disabled
    BASIC = 1,       -- Basic tab navigation only
    ENHANCED = 2,    -- Enhanced navigation with arrows and context shortcuts
    FULL = 3         -- Full keyboard control of all UI elements
}

-- Keybinding modes
local KEYBIND_MODE = {
    STANDARD = 1,    -- Standard WoW keybindings
    COMPACT = 2,     -- Space-efficient keybindings
    ACCESSIBLE = 3,  -- Accessibility-focused keybindings
    CUSTOM = 4       -- Custom user-defined keybindings
}

-- Focus state tracking
local currentFocus = nil        -- Currently focused frame
local focusHistory = {}         -- History of focused frames
local focusGroups = {}          -- Logical groupings of UI elements for navigation
local registeredElements = {}   -- All elements registered for keyboard navigation
local defaultBindings = {}      -- Default key mappings
local customBindings = {}       -- Custom key mappings

-- Default settings
local defaultSettings = {
    enabled = false,
    navigationMode = NAV_MODE.BASIC,
    keybindMode = KEYBIND_MODE.STANDARD,
    showFocusIndicators = true,
    focusIndicatorType = "glow", -- Options: glow, border, highlight, arrow
    focusIndicatorColor = {r = 1, g = 0.8, b = 0, a = 0.8}, -- Gold color
    tabCycling = true,          -- Whether tab cycles through all elements or just current group
    arrowNavigation = true,     -- Use arrow keys to navigate within groups
    escapeClosesWindows = true, -- ESC closes windows in reverse opening order
    enhancedTooltips = true,    -- Add keyboard shortcut info to tooltips
    hotkeyVisibility = true,    -- Show hotkeys on buttons
    useAltKey = true,           -- Whether to use Alt key for navigation
    useCtrlKey = true,          -- Whether to use Ctrl key for navigation
    focusStartPosition = "topleft", -- Where to begin focus when entering a new frame
    autoFocus = true,           -- Auto-focus first element when frame shown
    rememberLastFocus = true,   -- Remember last focused element per frame
    customKeybinds = {},        -- Custom keybind overrides
    groupOrder = {},            -- Custom order for tab navigation between groups
    audioFeedback = true,       -- Play sound on focus changes
    audioFeedbackVolume = 0.5,  -- Volume for audio feedback (0.0-1.0)
}

-- Runtime data
local hotkeyTexts = {}          -- Original hotkey texts for restoration
local keyDownHandlers = {}      -- Handlers for key down events
local keyUpHandlers = {}        -- Handlers for key up events
local mouseFocusFrame = nil     -- Last frame focused via mouse
local isInitializing = true     -- Whether we're in initialization
local isPendingFocusUpdate = false -- Whether a focus update is pending
local isInCombat = false        -- Whether the player is in combat
local pendingKeyState = {}      -- Key state info for pending updates

-- Initialize with default or saved settings
local settings = {}

-- Initialize module
function KeyboardNavigation:Initialize()
    -- Load saved settings or initialize with defaults
    if VUI.db and VUI.db.profile.keyboardNavigation then
        settings = VUI.db.profile.keyboardNavigation
    else
        settings = CopyTable(defaultSettings)
        if VUI.db and VUI.db.profile then
            VUI.db.profile.keyboardNavigation = settings
        end
    end
    
    -- Create the module frame
    self.frame = CreateFrame("Frame", "VUIKeyboardNavigationFrame", UIParent)
    
    -- Create focus indicator frame if needed
    if settings.showFocusIndicators then
        self:CreateFocusIndicator()
    end
    
    -- Register events
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Set up event handler
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:OnPlayerEnteringWorld()
        elseif event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "VUI" then
                self:OnAddonLoaded()
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            isInCombat = true
            -- Special handling during combat
            self:OnEnterCombat()
        elseif event == "PLAYER_REGEN_ENABLED" then
            isInCombat = false
            -- Restore state after combat ends
            self:OnLeaveCombat()
        end
    end)
    
    -- Set up key handler
    self.frame:SetPropagateKeyboardInput(true)
    self.frame:EnableKeyboard(true)
    self.frame:SetScript("OnKeyDown", function(_, key)
        self:ProcessKeyDown(key)
    end)
    self.frame:SetScript("OnKeyUp", function(_, key)
        self:ProcessKeyUp(key)
    end)
    
    -- Setup default key bindings
    self:SetupDefaultBindings()
    
    -- Initialize system based on current settings
    if settings.enabled then
        self:Enable()
    else
        self:Disable()
    end
    
    -- Register with VUI Config
    self:RegisterConfig()
    
    -- Initialization complete
    isInitializing = false
    
    -- Print initialization message if in debug mode
    if VUI.debug then
        VUI:Print("Keyboard Navigation system initialized")
    end
end

-- Handle player entering world
function KeyboardNavigation:OnPlayerEnteringWorld()
    -- Register with existing frames
    self:RegisterWithExistingFrames()
    
    -- Apply keyboard shortcuts if enabled
    if settings.enabled and settings.hotkeyVisibility then
        self:ApplyKeybindVisuals()
    end
end

-- Handle addon loaded
function KeyboardNavigation:OnAddonLoaded()
    -- Nothing specific to do here yet
end

-- Handle entering combat
function KeyboardNavigation:OnEnterCombat()
    -- Temporarily disable certain features during combat to avoid UI errors
    if settings.enabled then
        -- Store current state for restoration after combat
        self.preCombatFocus = currentFocus
        
        -- Optionally disable keyboard navigation during combat
        -- or switch to a "combat safe" mode
    end
end

-- Handle leaving combat
function KeyboardNavigation:OnLeaveCombat()
    -- Restore pre-combat state
    if settings.enabled and self.preCombatFocus then
        self:SetFocus(self.preCombatFocus)
        self.preCombatFocus = nil
    end
end

-- Create focus indicator
function KeyboardNavigation:CreateFocusIndicator()
    -- Create a frame for showing focus indicators
    self.focusIndicator = CreateFrame("Frame", "VUIKeyboardNavigationFocusIndicator", UIParent)
    self.focusIndicator:SetFrameStrata("HIGH")
    
    -- Create different indicator types
    
    -- Glow effect
    self.focusIndicator.glow = self.focusIndicator:CreateTexture("VUIKeyboardNavigationFocusGlow", "BACKGROUND")
    self.focusIndicator.glow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\glow")
    self.focusIndicator.glow:SetBlendMode("ADD")
    self.focusIndicator.glow:SetVertexColor(
        settings.focusIndicatorColor.r,
        settings.focusIndicatorColor.g,
        settings.focusIndicatorColor.b,
        settings.focusIndicatorColor.a
    )
    self.focusIndicator.glow:SetAllPoints(self.focusIndicator)
    self.focusIndicator.glow:Hide()
    
    -- Border effect
    self.focusIndicator.border = CreateFrame("Frame", "VUIKeyboardNavigationFocusBorder", self.focusIndicator)
    self.focusIndicator.border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\white_border",
        edgeSize = 2,
    })
    self.focusIndicator.border:SetBackdropBorderColor(
        settings.focusIndicatorColor.r,
        settings.focusIndicatorColor.g,
        settings.focusIndicatorColor.b,
        settings.focusIndicatorColor.a
    )
    self.focusIndicator.border:SetAllPoints(self.focusIndicator)
    self.focusIndicator.border:Hide()
    
    -- Highlight effect
    self.focusIndicator.highlight = self.focusIndicator:CreateTexture("VUIKeyboardNavigationFocusHighlight", "BACKGROUND")
    self.focusIndicator.highlight:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\solid")
    self.focusIndicator.highlight:SetVertexColor(
        settings.focusIndicatorColor.r,
        settings.focusIndicatorColor.g,
        settings.focusIndicatorColor.b,
        settings.focusIndicatorColor.a * 0.3
    )
    self.focusIndicator.highlight:SetAllPoints(self.focusIndicator)
    self.focusIndicator.highlight:Hide()
    
    -- Arrow indicator
    self.focusIndicator.arrow = self.focusIndicator:CreateTexture("VUIKeyboardNavigationFocusArrow", "OVERLAY")
    self.focusIndicator.arrow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arrow")
    self.focusIndicator.arrow:SetVertexColor(
        settings.focusIndicatorColor.r,
        settings.focusIndicatorColor.g,
        settings.focusIndicatorColor.b,
        settings.focusIndicatorColor.a
    )
    self.focusIndicator.arrow:SetPoint("LEFT", self.focusIndicator, "LEFT", -20, 0)
    self.focusIndicator.arrow:SetSize(16, 16)
    self.focusIndicator.arrow:Hide()
    
    -- Hide the main indicator
    self.focusIndicator:Hide()
end

-- Enable keyboard navigation
function KeyboardNavigation:Enable()
    -- Skip if already enabled
    if self.isEnabled then return end
    
    -- Set enabled flag
    settings.enabled = true
    self.isEnabled = true
    
    -- Enable keyboard handling
    self.frame:EnableKeyboard(true)
    self.frame:SetPropagateKeyboardInput(true)
    
    -- Apply keybind visuals if enabled
    if settings.hotkeyVisibility then
        self:ApplyKeybindVisuals()
    end
    
    -- Register with frames
    self:RegisterWithExistingFrames()
    
    -- Notify modules about keyboard navigation
    VUI:CallModuleFunction("OnKeyboardNavigationChanged", true, settings.navigationMode)
    
    -- Show focus indicators if enabled
    if settings.showFocusIndicators and self.focusIndicator then
        -- Make sure indicators are ready
        self:UpdateFocusIndicator()
    end
    
    -- Set initial focus if auto focus is enabled
    if settings.autoFocus then
        self:SetInitialFocus()
    end
    
    if VUI.debug then
        VUI:Print("Keyboard Navigation enabled")
    end
end

-- Disable keyboard navigation
function KeyboardNavigation:Disable()
    -- Skip if already disabled
    if not self.isEnabled then return end
    
    -- Set disabled flag
    settings.enabled = false
    self.isEnabled = false
    
    -- Disable keyboard handling
    self.frame:EnableKeyboard(false)
    
    -- Restore original hotkey visuals
    self:RestoreKeybindVisuals()
    
    -- Clear focus
    self:ClearFocus()
    
    -- Hide focus indicators
    if self.focusIndicator then
        self.focusIndicator:Hide()
    end
    
    -- Notify modules about keyboard navigation
    VUI:CallModuleFunction("OnKeyboardNavigationChanged", false, NAV_MODE.DISABLED)
    
    if VUI.debug then
        VUI:Print("Keyboard Navigation disabled")
    end
end

-- Process key down events
function KeyboardNavigation:ProcessKeyDown(key)
    -- Skip if disabled or in combat (optional)
    if not self.isEnabled then return end
    
    -- Store key state
    pendingKeyState[key] = true
    
    -- Handle special navigation keys
    if key == "TAB" then
        -- Tab navigation
        if IsShiftKeyDown() then
            -- Shift+Tab - focus previous element
            self:FocusPrevious()
        else
            -- Tab - focus next element
            self:FocusNext()
        end
        
        -- Don't propagate the Tab key to prevent default WoW behavior
        self.frame:SetPropagateKeyboardInput(false)
        return
    elseif key == "ESCAPE" and settings.escapeClosesWindows then
        -- ESC key closes windows
        if self:HandleEscapeKey() then
            -- We handled the escape key, don't propagate
            self.frame:SetPropagateKeyboardInput(false)
            return
        end
    elseif settings.arrowNavigation and (key == "UP" or key == "DOWN" or key == "LEFT" or key == "RIGHT") then
        -- Arrow key navigation
        if self:HandleArrowNavigation(key) then
            -- We handled the arrow key, don't propagate
            self.frame:SetPropagateKeyboardInput(false)
            return
        end
    end
    
    -- Check for registered key handlers
    local handler = keyDownHandlers[key]
    if handler then
        local success = handler(key, IsShiftKeyDown(), IsControlKeyDown(), IsAltKeyDown())
        if success then
            -- Key was handled by a registered handler, don't propagate
            self.frame:SetPropagateKeyboardInput(false)
            return
        end
    end
    
    -- If we get here, we didn't handle the key, so propagate it
    self.frame:SetPropagateKeyboardInput(true)
end

-- Process key up events
function KeyboardNavigation:ProcessKeyUp(key)
    -- Skip if disabled
    if not self.isEnabled then return end
    
    -- Clear key state
    pendingKeyState[key] = nil
    
    -- Check for registered key up handlers
    local handler = keyUpHandlers[key]
    if handler then
        handler(key, IsShiftKeyDown(), IsControlKeyDown(), IsAltKeyDown())
    end
    
    -- Always propagate key up events
    self.frame:SetPropagateKeyboardInput(true)
end

-- Handle escape key
function KeyboardNavigation:HandleEscapeKey()
    -- Close windows in reverse opening order
    -- Implementation depends on how we're tracking open windows
    
    -- For now, we'll just use a simple approach that closes the current focus
    -- and returns to the previous focus
    if currentFocus and currentFocus:IsVisible() then
        -- Check if the current focus is a window that can be closed
        if currentFocus.Hide then
            currentFocus:Hide()
            
            -- Return to previous focus if exists
            if #focusHistory > 0 then
                local previousFocus = table.remove(focusHistory)
                self:SetFocus(previousFocus)
            else
                self:ClearFocus()
            end
            
            -- Play sound if audio feedback is enabled
            if settings.audioFeedback then
                PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
            end
            
            return true
        end
    end
    
    return false
end

-- Handle arrow key navigation
function KeyboardNavigation:HandleArrowNavigation(key)
    if not currentFocus then
        return false
    end
    
    -- Get the current focus group
    local group = self:GetFocusGroup(currentFocus)
    if not group then
        return false
    end
    
    -- Find the next element in the arrow direction
    local nextFocus = nil
    
    if key == "UP" then
        nextFocus = self:FindElementInDirection(currentFocus, group, "UP")
    elseif key == "DOWN" then
        nextFocus = self:FindElementInDirection(currentFocus, group, "DOWN")
    elseif key == "LEFT" then
        nextFocus = self:FindElementInDirection(currentFocus, group, "LEFT")
    elseif key == "RIGHT" then
        nextFocus = self:FindElementInDirection(currentFocus, group, "RIGHT")
    end
    
    -- Set focus to the next element if found
    if nextFocus then
        self:SetFocus(nextFocus)
        return true
    end
    
    return false
end

-- Find element in a specific direction
function KeyboardNavigation:FindElementInDirection(currentElement, group, direction)
    if not currentElement or not group then
        return nil
    end
    
    -- Get the center coordinates of the current element
    local currentFrame = currentElement.frame or currentElement
    local currentCenterX, currentCenterY = self:GetFrameCenter(currentFrame)
    
    -- Best candidate frame and its score (lower is better)
    local bestMatch = nil
    local bestScore = math.huge
    
    -- Search for the best candidate in the specified direction
    for _, element in ipairs(group.elements) do
        if element ~= currentElement and element:IsVisible() then
            local frame = element.frame or element
            local centerX, centerY = self:GetFrameCenter(frame)
            
            -- Calculate distance and direction
            local deltaX = centerX - currentCenterX
            local deltaY = centerY - currentCenterY
            
            -- Process elements in the correct direction
            local isCorrectDirection = true
            
            -- Check if element is in the wrong direction
            if (direction == "UP" and deltaY <= 0) or
               (direction == "DOWN" and deltaY >= 0) or
               (direction == "LEFT" and deltaX <= 0) or
               (direction == "RIGHT" and deltaX >= 0) then
                isCorrectDirection = false
            end
            
            -- Only process elements in the correct direction
            if isCorrectDirection then
                -- Calculate score based on distance and alignment
                local score = 0
                
                if direction == "UP" or direction == "DOWN" then
                    -- For vertical movement, prefer elements that are aligned horizontally
                    score = math.abs(deltaX) * 2 + math.abs(deltaY)
                else
                    -- For horizontal movement, prefer elements that are aligned vertically
                    score = math.abs(deltaY) * 2 + math.abs(deltaX)
                end
                
                -- Update best match if this element has a better score
                if score < bestScore then
                    bestMatch = element
                    bestScore = score
                end
            end
        end
    end
    
    return bestMatch
end

-- Get the center coordinates of a frame
function KeyboardNavigation:GetFrameCenter(frame)
    local scale = frame:GetEffectiveScale()
    local left, bottom, width, height = frame:GetRect()
    
    if left and bottom and width and height then
        local centerX = (left + width / 2) * scale
        local centerY = (bottom + height / 2) * scale
        return centerX, centerY
    else
        -- Fallback if frame has no dimensions yet
        local x, y = frame:GetCenter()
        if x and y then
            return x * scale, y * scale
        else
            return 0, 0
        end
    end
end

-- Focus next element
function KeyboardNavigation:FocusNext()
    if not currentFocus then
        -- If no focus, set initial focus
        self:SetInitialFocus()
        return
    end
    
    -- Get the current focus group
    local currentGroup = self:GetFocusGroup(currentFocus)
    if not currentGroup then
        -- If no group, try to set initial focus
        self:SetInitialFocus()
        return
    end
    
    -- Find the index of the current element in the group
    local currentIndex = 0
    for i, element in ipairs(currentGroup.elements) do
        if element == currentFocus then
            currentIndex = i
            break
        end
    end
    
    -- Find the next visible element in the group
    local nextIndex = currentIndex + 1
    local startIndex = nextIndex
    local foundElement = false
    
    while true do
        -- Wrap around to the beginning if necessary
        if nextIndex > #currentGroup.elements then
            if settings.tabCycling then
                nextIndex = 1
            else
                -- Move to the next group if not cycling within group
                self:FocusNextGroup()
                return
            end
        end
        
        -- Check if we've tried all elements in the group
        if nextIndex == startIndex then
            -- We've come full circle, no visible elements found
            break
        end
        
        -- Check if this element is visible
        local element = currentGroup.elements[nextIndex]
        if element:IsVisible() and self:IsElementNavigable(element) then
            self:SetFocus(element)
            foundElement = true
            break
        end
        
        -- Move to the next element
        nextIndex = nextIndex + 1
    end
    
    -- If no visible element found in this group, try the next group
    if not foundElement then
        self:FocusNextGroup()
    end
end

-- Focus previous element
function KeyboardNavigation:FocusPrevious()
    if not currentFocus then
        -- If no focus, set initial focus
        self:SetInitialFocus()
        return
    end
    
    -- Get the current focus group
    local currentGroup = self:GetFocusGroup(currentFocus)
    if not currentGroup then
        -- If no group, try to set initial focus
        self:SetInitialFocus()
        return
    end
    
    -- Find the index of the current element in the group
    local currentIndex = 0
    for i, element in ipairs(currentGroup.elements) do
        if element == currentFocus then
            currentIndex = i
            break
        end
    end
    
    -- Find the previous visible element in the group
    local prevIndex = currentIndex - 1
    local startIndex = prevIndex
    local foundElement = false
    
    while true do
        -- Wrap around to the end if necessary
        if prevIndex < 1 then
            if settings.tabCycling then
                prevIndex = #currentGroup.elements
            else
                -- Move to the previous group if not cycling within group
                self:FocusPreviousGroup()
                return
            end
        end
        
        -- Check if we've tried all elements in the group
        if prevIndex == startIndex then
            -- We've come full circle, no visible elements found
            break
        end
        
        -- Check if this element is visible
        local element = currentGroup.elements[prevIndex]
        if element:IsVisible() and self:IsElementNavigable(element) then
            self:SetFocus(element)
            foundElement = true
            break
        end
        
        -- Move to the previous element
        prevIndex = prevIndex - 1
    end
    
    -- If no visible element found in this group, try the previous group
    if not foundElement then
        self:FocusPreviousGroup()
    end
end

-- Focus next group
function KeyboardNavigation:FocusNextGroup()
    -- Get the current group
    local currentGroup = currentFocus and self:GetFocusGroup(currentFocus) or nil
    local currentGroupIndex = 0
    
    -- Find the index of the current group
    for i, group in ipairs(focusGroups) do
        if group == currentGroup then
            currentGroupIndex = i
            break
        end
    end
    
    -- Find the next group with visible elements
    local nextGroupIndex = currentGroupIndex + 1
    local startGroupIndex = nextGroupIndex
    
    while true do
        -- Wrap around to the beginning if necessary
        if nextGroupIndex > #focusGroups then
            nextGroupIndex = 1
        end
        
        -- Check if we've tried all groups
        if nextGroupIndex == startGroupIndex then
            -- We've come full circle, no visible groups found
            break
        end
        
        -- Check if this group has visible elements
        local group = focusGroups[nextGroupIndex]
        local firstVisibleElement = self:FindFirstVisibleElementInGroup(group)
        
        if firstVisibleElement then
            self:SetFocus(firstVisibleElement)
            return
        end
        
        -- Move to the next group
        nextGroupIndex = nextGroupIndex + 1
    end
end

-- Focus previous group
function KeyboardNavigation:FocusPreviousGroup()
    -- Get the current group
    local currentGroup = currentFocus and self:GetFocusGroup(currentFocus) or nil
    local currentGroupIndex = 0
    
    -- Find the index of the current group
    for i, group in ipairs(focusGroups) do
        if group == currentGroup then
            currentGroupIndex = i
            break
        end
    end
    
    -- Find the previous group with visible elements
    local prevGroupIndex = currentGroupIndex - 1
    local startGroupIndex = prevGroupIndex
    
    while true do
        -- Wrap around to the end if necessary
        if prevGroupIndex < 1 then
            prevGroupIndex = #focusGroups
        end
        
        -- Check if we've tried all groups
        if prevGroupIndex == startGroupIndex then
            -- We've come full circle, no visible groups found
            break
        end
        
        -- Check if this group has visible elements
        local group = focusGroups[prevGroupIndex]
        local firstVisibleElement = self:FindFirstVisibleElementInGroup(group)
        
        if firstVisibleElement then
            self:SetFocus(firstVisibleElement)
            return
        end
        
        -- Move to the previous group
        prevGroupIndex = prevGroupIndex - 1
    end
end

-- Find the first visible element in a group
function KeyboardNavigation:FindFirstVisibleElementInGroup(group)
    if not group or not group.elements then
        return nil
    end
    
    for _, element in ipairs(group.elements) do
        if element:IsVisible() and self:IsElementNavigable(element) then
            return element
        end
    end
    
    return nil
end

-- Set initial focus
function KeyboardNavigation:SetInitialFocus()
    -- Look for the first visible element in the first group with visible elements
    for _, group in ipairs(focusGroups) do
        local element = self:FindFirstVisibleElementInGroup(group)
        if element then
            self:SetFocus(element)
            return
        end
    end
    
    -- If no visible elements found, clear focus
    self:ClearFocus()
end

-- Set focus to an element
function KeyboardNavigation:SetFocus(element)
    if not element or not self.isEnabled then
        return
    end
    
    -- Skip if element is not navigable
    if not self:IsElementNavigable(element) then
        return
    end
    
    -- Skip if element is the same as current focus
    if element == currentFocus then
        return
    end
    
    -- Add current focus to history if it exists
    if currentFocus then
        table.insert(focusHistory, currentFocus)
        
        -- Limit history size
        if #focusHistory > 10 then
            table.remove(focusHistory, 1)
        end
        
        -- Remove focus from current element
        self:RemoveFocus(currentFocus)
    end
    
    -- Set new focus
    currentFocus = element
    
    -- Apply focus to the element
    self:ApplyFocus(element)
    
    -- Update focus indicator
    self:UpdateFocusIndicator()
    
    -- Play sound if audio feedback is enabled
    if settings.audioFeedback then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, "SFX", settings.audioFeedbackVolume)
    end
    
    -- Fire focus changed event
    self:FireEvent("OnFocusChanged", element)
end

-- Clear focus
function KeyboardNavigation:ClearFocus()
    if not currentFocus then
        return
    end
    
    -- Remove focus from current element
    self:RemoveFocus(currentFocus)
    
    -- Clear current focus
    currentFocus = nil
    
    -- Hide focus indicator
    if self.focusIndicator then
        self.focusIndicator:Hide()
    end
    
    -- Fire focus changed event
    self:FireEvent("OnFocusChanged", nil)
end

-- Apply focus to an element
function KeyboardNavigation:ApplyFocus(element)
    if not element then
        return
    end
    
    -- Get the frame from the element
    local frame = element.frame or element
    
    -- Apply focus highlight if frame supports it
    if frame.SetFocus and type(frame.SetFocus) == "function" then
        frame:SetFocus()
    elseif frame.LockHighlight and type(frame.LockHighlight) == "function" then
        frame:LockHighlight()
    end
    
    -- Call OnFocus handler if it exists
    if element.OnFocus and type(element.OnFocus) == "function" then
        element:OnFocus()
    end
    
    -- Mark the element as focused
    element.isFocused = true
    
    -- Enable keyboard for the element if needed
    if frame.EnableKeyboard then
        frame:EnableKeyboard(true)
    end
end

-- Remove focus from an element
function KeyboardNavigation:RemoveFocus(element)
    if not element then
        return
    end
    
    -- Get the frame from the element
    local frame = element.frame or element
    
    -- Remove focus highlight if frame supports it
    if frame.ClearFocus and type(frame.ClearFocus) == "function" then
        frame:ClearFocus()
    elseif frame.UnlockHighlight and type(frame.UnlockHighlight) == "function" then
        frame:UnlockHighlight()
    end
    
    -- Call OnBlur handler if it exists
    if element.OnBlur and type(element.OnBlur) == "function" then
        element:OnBlur()
    end
    
    -- Mark the element as not focused
    element.isFocused = false
    
    -- Disable keyboard for the element if needed
    if frame.EnableKeyboard then
        frame:EnableKeyboard(false)
    end
end

-- Update focus indicator
function KeyboardNavigation:UpdateFocusIndicator()
    -- Skip if indicators disabled or no focus
    if not settings.showFocusIndicators or not self.focusIndicator or not currentFocus then
        if self.focusIndicator then
            self.focusIndicator:Hide()
        end
        return
    end
    
    -- Get the frame from the element
    local frame = currentFocus.frame or currentFocus
    
    -- Position the indicator around the focused element
    self.focusIndicator:ClearAllPoints()
    self.focusIndicator:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    self.focusIndicator:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
    
    -- Show the appropriate indicator type
    self.focusIndicator.glow:Hide()
    self.focusIndicator.border:Hide()
    self.focusIndicator.highlight:Hide()
    self.focusIndicator.arrow:Hide()
    
    if settings.focusIndicatorType == "glow" then
        self.focusIndicator.glow:Show()
    elseif settings.focusIndicatorType == "border" then
        self.focusIndicator.border:Show()
    elseif settings.focusIndicatorType == "highlight" then
        self.focusIndicator.highlight:Show()
    elseif settings.focusIndicatorType == "arrow" then
        self.focusIndicator.arrow:Show()
    end
    
    -- Show the indicator
    self.focusIndicator:Show()
end

-- Register with existing frames
function KeyboardNavigation:RegisterWithExistingFrames()
    -- Register with all VUI modules
    for name, module in VUI:IterateModules() do
        -- Only register modules with frames
        if module.frame then
            -- Create a focus group for the module
            local groupName = "VUI_" .. name
            local group = self:GetOrCreateFocusGroup(groupName)
            
            -- Register the main module frame
            self:RegisterElement(module.frame, {
                group = groupName,
                priority = 100,  -- High priority for main module frames
                navigable = true
            })
        end
        -- No need for goto/continue in Lua 5.1
    end
    
    -- Register with WoW UI elements that we want to make navigable
    self:RegisterWoWUIElements()
end

-- Register WoW UI elements
function KeyboardNavigation:RegisterWoWUIElements()
    -- Register main UI panels
    local mainFrames = {
        PlayerFrame = "Player",
        TargetFrame = "Target",
        MainMenuBar = "MainMenu",
        MiniMapFrame = "Minimap",
        CharacterFrame = "Character",
        SpellBookFrame = "SpellBook",
        TalentFrame = "Talents",
        FriendsFrame = "Social",
        GuildFrame = "Guild",
        PVEFrame = "Group",
        GameMenuFrame = "GameMenu",
        InterfaceOptionsFrame = "Options",
        VideoOptionsFrame = "VideoOptions",
        AudioOptionsFrame = "AudioOptions",
    }
    
    -- Register each main frame that exists
    for frameName, groupName in pairs(mainFrames) do
        local frame = _G[frameName]
        if frame then
            self:RegisterElement(frame, {
                group = groupName,
                priority = 90, -- High priority for main WoW frames
                navigable = true
            })
        end
    end
    
    -- Register action buttons
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then
            self:RegisterElement(button, {
                group = "ActionBar",
                priority = 80,
                navigable = true
            })
        end
    end
    
    -- Register buff frames
    for i = 1, 32 do
        local button = _G["BuffButton" .. i]
        if button then
            self:RegisterElement(button, {
                group = "Buffs",
                priority = 70,
                navigable = true
            })
        end
    end
end

-- Register an element for keyboard navigation
function KeyboardNavigation:RegisterElement(element, options)
    if not element then return end
    
    -- Generate a unique ID for this element
    local elementID = tostring(element)
    
    -- Default options
    options = options or {}
    local groupName = options.group or "default"
    local priority = options.priority or 50
    local navigable = options.navigable ~= false -- Default to true if not specified
    
    -- Create or get the focus group
    local group = self:GetOrCreateFocusGroup(groupName)
    
    -- Store the element data
    registeredElements[elementID] = {
        element = element,
        group = groupName,
        priority = priority,
        navigable = navigable,
        options = options
    }
    
    -- Add the element to the group
    table.insert(group.elements, element)
    
    -- Sort group elements by priority (highest first)
    table.sort(group.elements, function(a, b)
        local aData = registeredElements[tostring(a)]
        local bData = registeredElements[tostring(b)]
        
        if not aData or not bData then
            return false
        end
        
        return aData.priority > bData.priority
    end)
    
    -- Set up mouse handler to remember last clicked frame
    local frame = element.frame or element
    frame:HookScript("OnMouseDown", function(f)
        mouseFocusFrame = f
        self:SetFocus(element)
    end)
    
    return elementID
end

-- Unregister an element
function KeyboardNavigation:UnregisterElement(elementID)
    if not elementID then return end
    
    local data = registeredElements[elementID]
    if not data then return end
    
    -- Remove the element from its group
    local group = focusGroups[data.group]
    if group then
        for i, element in ipairs(group.elements) do
            if element == data.element then
                table.remove(group.elements, i)
                break
            end
        end
    end
    
    -- Remove the element data
    registeredElements[elementID] = nil
    
    -- Clear focus if this was the focused element
    if currentFocus == data.element then
        self:ClearFocus()
    end
end

-- Get or create a focus group
function KeyboardNavigation:GetOrCreateFocusGroup(groupName)
    if not focusGroups[groupName] then
        focusGroups[groupName] = {
            name = groupName,
            elements = {},
            visible = true,
            enabled = true,
            priority = 50
        }
    end
    
    return focusGroups[groupName]
end

-- Get focus group for an element
function KeyboardNavigation:GetFocusGroup(element)
    -- Find the element data
    local elementID = tostring(element)
    local data = registeredElements[elementID]
    
    -- Return the group if found
    if data and data.group then
        return focusGroups[data.group]
    end
    
    return nil
end

-- Check if an element is navigable
function KeyboardNavigation:IsElementNavigable(element)
    if not element then
        return false
    end
    
    -- Find the element data
    local elementID = tostring(element)
    local data = registeredElements[elementID]
    
    -- Return navigable status if found
    if data then
        return data.navigable and element:IsVisible()
    end
    
    -- Default to not navigable
    return false
end

-- Set up default key bindings
function KeyboardNavigation:SetupDefaultBindings()
    -- Tab navigation
    defaultBindings["TAB"] = {
        action = function() self:FocusNext() end,
        description = "Focus next element"
    }
    
    defaultBindings["SHIFT-TAB"] = {
        action = function() self:FocusPrevious() end,
        description = "Focus previous element"
    }
    
    -- Arrow navigation
    defaultBindings["UP"] = {
        action = function() self:HandleArrowNavigation("UP") end,
        description = "Move focus up"
    }
    
    defaultBindings["DOWN"] = {
        action = function() self:HandleArrowNavigation("DOWN") end,
        description = "Move focus down"
    }
    
    defaultBindings["LEFT"] = {
        action = function() self:HandleArrowNavigation("LEFT") end,
        description = "Move focus left"
    }
    
    defaultBindings["RIGHT"] = {
        action = function() self:HandleArrowNavigation("RIGHT") end,
        description = "Move focus right"
    }
    
    -- Activation key (Space or Enter)
    defaultBindings["SPACE"] = {
        action = function()
            if currentFocus then
                -- Simulate a click on the focused element
                local frame = currentFocus.frame or currentFocus
                if frame:IsEnabled() and frame:GetObjectType() == "Button" then
                    frame:Click()
                    return true
                end
            end
            return false
        end,
        description = "Activate focused element"
    }
    
    defaultBindings["ENTER"] = {
        action = function()
            if currentFocus then
                -- Simulate a click on the focused element
                local frame = currentFocus.frame or currentFocus
                if frame:IsEnabled() and frame:GetObjectType() == "Button" then
                    frame:Click()
                    return true
                end
            end
            return false
        end,
        description = "Activate focused element"
    }
    
    -- Register default key handlers
    for key, binding in pairs(defaultBindings) do
        self:RegisterKeyHandler(key, binding.action)
    end
end

-- Apply keybind visuals
function KeyboardNavigation:ApplyKeybindVisuals()
    -- Skip if hotkey visibility is disabled
    if not settings.hotkeyVisibility then
        return
    end
    
    -- Apply to action buttons
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button and button.HotKey then
            -- Store original text
            if not hotkeyTexts["ActionButton" .. i] then
                hotkeyTexts["ActionButton" .. i] = button.HotKey:GetText()
            end
            
            -- Set enhanced visibility
            local text = hotkeyTexts["ActionButton" .. i] or ""
            button.HotKey:SetText(text)
            button.HotKey:SetTextColor(1, 0.8, 0, 1)
            button.HotKey:Show()
        end
    end
    
    -- Apply to other buttons with hotkeys
    for frameName, frame in pairs(_G) do
        if type(frame) == "table" and frame.HotKey and frame:IsObjectType("Button") then
            -- Store original text
            if not hotkeyTexts[frameName] and frame.HotKey:GetText() then
                hotkeyTexts[frameName] = frame.HotKey:GetText()
            end
            
            -- Set enhanced visibility
            local text = hotkeyTexts[frameName] or ""
            if text ~= "" then
                frame.HotKey:SetText(text)
                frame.HotKey:SetTextColor(1, 0.8, 0, 1)
                frame.HotKey:Show()
            end
        end
    end
end

-- Restore keybind visuals
function KeyboardNavigation:RestoreKeybindVisuals()
    -- Restore action buttons
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button and button.HotKey and hotkeyTexts["ActionButton" .. i] then
            button.HotKey:SetText(hotkeyTexts["ActionButton" .. i])
            button.HotKey:SetTextColor(0.6, 0.6, 0.6, 1)
        end
    end
    
    -- Restore other buttons
    for frameName, text in pairs(hotkeyTexts) do
        local frame = _G[frameName]
        if frame and frame.HotKey then
            frame.HotKey:SetText(text)
            frame.HotKey:SetTextColor(0.6, 0.6, 0.6, 1)
        end
    end
end

-- Register a key handler
function KeyboardNavigation:RegisterKeyHandler(key, handler, isKeyUp)
    if not key or not handler then
        return
    end
    
    -- Clean up the key name
    key = key:upper()
    
    -- Register the handler
    if isKeyUp then
        keyUpHandlers[key] = handler
    else
        keyDownHandlers[key] = handler
    end
end

-- Unregister a key handler
function KeyboardNavigation:UnregisterKeyHandler(key, isKeyUp)
    if not key then
        return
    end
    
    -- Clean up the key name
    key = key:upper()
    
    -- Unregister the handler
    if isKeyUp then
        keyUpHandlers[key] = nil
    else
        keyDownHandlers[key] = nil
    end
end

-- Fire an event to listeners
function KeyboardNavigation:FireEvent(event, ...)
    -- Call any registered event handlers
    if self[event] then
        self[event](self, ...)
    end
    
    -- Notify modules about the event
    VUI:CallModuleFunction(event, ...)
end

-- Config panel integration
function KeyboardNavigation:RegisterConfig()
    -- Register with VUI Config system
    if VUI.Config then
        VUI.Config:RegisterModule("Keyboard Navigation", self:GetConfigOptions())
    end
end

-- Get config options for the settings panel
function KeyboardNavigation:GetConfigOptions()
    local options = {
        name = "Keyboard Navigation",
        type = "group",
        args = {
            generalSection = {
                order = 1,
                type = "group",
                name = "General Settings",
                inline = true,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = "Enable Keyboard Navigation",
                        desc = "Enable or disable keyboard navigation system",
                        get = function() return settings.enabled end,
                        set = function(_, value) 
                            if value then
                                self:Enable()
                            else
                                self:Disable()
                            end
                        end,
                        width = "full",
                    },
                    navigationMode = {
                        order = 2,
                        type = "select",
                        name = "Navigation Mode",
                        desc = "Choose the level of keyboard navigation",
                        values = {
                            [NAV_MODE.BASIC] = "Basic (Tab Navigation Only)",
                            [NAV_MODE.ENHANCED] = "Enhanced (Tab and Arrow Keys)",
                            [NAV_MODE.FULL] = "Full (Complete Keyboard Control)"
                        },
                        get = function() return settings.navigationMode end,
                        set = function(_, value) 
                            settings.navigationMode = value
                            VUI.db.profile.keyboardNavigation.navigationMode = value
                            -- Apply new navigation mode
                            if self.isEnabled then
                                -- Refresh navigation with new mode
                                VUI:CallModuleFunction("OnKeyboardNavigationChanged", true, value)
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    focusIndicatorHeader = {
                        order = 3,
                        type = "header",
                        name = "Focus Indicator",
                    },
                    showFocusIndicators = {
                        order = 4,
                        type = "toggle",
                        name = "Show Focus Indicators",
                        desc = "Show visual indicators for keyboard focus",
                        get = function() return settings.showFocusIndicators end,
                        set = function(_, value) 
                            settings.showFocusIndicators = value
                            VUI.db.profile.keyboardNavigation.showFocusIndicators = value
                            if value and not self.focusIndicator then
                                self:CreateFocusIndicator()
                            end
                            self:UpdateFocusIndicator()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    focusIndicatorType = {
                        order = 5,
                        type = "select",
                        name = "Focus Indicator Type",
                        desc = "Choose the visual style for focus indicators",
                        values = {
                            ["glow"] = "Glow Effect",
                            ["border"] = "Border Highlight",
                            ["highlight"] = "Background Highlight",
                            ["arrow"] = "Arrow Pointer"
                        },
                        get = function() return settings.focusIndicatorType end,
                        set = function(_, value) 
                            settings.focusIndicatorType = value
                            VUI.db.profile.keyboardNavigation.focusIndicatorType = value
                            self:UpdateFocusIndicator()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.showFocusIndicators end,
                    },
                    focusIndicatorColor = {
                        order = 6,
                        type = "color",
                        name = "Focus Indicator Color",
                        desc = "Set the color for focus indicators",
                        hasAlpha = true,
                        get = function()
                            return 
                                settings.focusIndicatorColor.r, 
                                settings.focusIndicatorColor.g, 
                                settings.focusIndicatorColor.b,
                                settings.focusIndicatorColor.a
                        end,
                        set = function(_, r, g, b, a) 
                            settings.focusIndicatorColor.r = r
                            settings.focusIndicatorColor.g = g
                            settings.focusIndicatorColor.b = b
                            settings.focusIndicatorColor.a = a
                            VUI.db.profile.keyboardNavigation.focusIndicatorColor = settings.focusIndicatorColor
                            
                            -- Update indicator color
                            if self.focusIndicator then
                                self.focusIndicator.glow:SetVertexColor(r, g, b, a)
                                self.focusIndicator.border:SetBackdropBorderColor(r, g, b, a)
                                self.focusIndicator.highlight:SetVertexColor(r, g, b, a * 0.3)
                                self.focusIndicator.arrow:SetVertexColor(r, g, b, a)
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.showFocusIndicators end,
                    },
                },
            },
            
            navigationSection = {
                order = 2,
                type = "group",
                name = "Navigation Options",
                inline = true,
                args = {
                    tabCycling = {
                        order = 1,
                        type = "toggle",
                        name = "Tab Cycling Within Groups",
                        desc = "Tab key cycles within the current group instead of moving to the next group",
                        get = function() return settings.tabCycling end,
                        set = function(_, value) 
                            settings.tabCycling = value
                            VUI.db.profile.keyboardNavigation.tabCycling = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    arrowNavigation = {
                        order = 2,
                        type = "toggle",
                        name = "Arrow Key Navigation",
                        desc = "Use arrow keys to navigate between elements",
                        get = function() return settings.arrowNavigation end,
                        set = function(_, value) 
                            settings.arrowNavigation = value
                            VUI.db.profile.keyboardNavigation.arrowNavigation = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    escapeClosesWindows = {
                        order = 3,
                        type = "toggle",
                        name = "ESC Closes Windows",
                        desc = "ESC key closes windows in reverse opening order",
                        get = function() return settings.escapeClosesWindows end,
                        set = function(_, value) 
                            settings.escapeClosesWindows = value
                            VUI.db.profile.keyboardNavigation.escapeClosesWindows = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    enhancedTooltips = {
                        order = 4,
                        type = "toggle",
                        name = "Enhanced Tooltips",
                        desc = "Add keyboard shortcut information to tooltips",
                        get = function() return settings.enhancedTooltips end,
                        set = function(_, value) 
                            settings.enhancedTooltips = value
                            VUI.db.profile.keyboardNavigation.enhancedTooltips = value
                            
                            -- Update tooltips
                            if self.isEnabled and value then
                                self:ApplyKeybindVisuals()
                            else
                                self:RestoreKeybindVisuals()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    hotkeyVisibility = {
                        order = 5,
                        type = "toggle",
                        name = "Hotkey Visibility",
                        desc = "Enhance visibility of key bindings on buttons",
                        get = function() return settings.hotkeyVisibility end,
                        set = function(_, value) 
                            settings.hotkeyVisibility = value
                            VUI.db.profile.keyboardNavigation.hotkeyVisibility = value
                            
                            -- Update hotkey visibility
                            if self.isEnabled and value then
                                self:ApplyKeybindVisuals()
                            else
                                self:RestoreKeybindVisuals()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    modifierHeader = {
                        order = 6,
                        type = "header",
                        name = "Modifier Keys",
                    },
                    useAltKey = {
                        order = 7,
                        type = "toggle",
                        name = "Use Alt Key for Navigation",
                        desc = "Use Alt key combinations for navigation shortcuts",
                        get = function() return settings.useAltKey end,
                        set = function(_, value) 
                            settings.useAltKey = value
                            VUI.db.profile.keyboardNavigation.useAltKey = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    useCtrlKey = {
                        order = 8,
                        type = "toggle",
                        name = "Use Ctrl Key for Navigation",
                        desc = "Use Ctrl key combinations for navigation shortcuts",
                        get = function() return settings.useCtrlKey end,
                        set = function(_, value) 
                            settings.useCtrlKey = value
                            VUI.db.profile.keyboardNavigation.useCtrlKey = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                },
            },
            
            focusSection = {
                order = 3,
                type = "group",
                name = "Focus Behavior",
                inline = true,
                args = {
                    focusStartPosition = {
                        order = 1,
                        type = "select",
                        name = "Focus Start Position",
                        desc = "Where to begin focus when entering a new frame",
                        values = {
                            ["topleft"] = "Top Left",
                            ["topcenter"] = "Top Center",
                            ["topright"] = "Top Right",
                            ["centerleft"] = "Center Left",
                            ["center"] = "Center",
                            ["centerright"] = "Center Right",
                            ["bottomleft"] = "Bottom Left",
                            ["bottomcenter"] = "Bottom Center",
                            ["bottomright"] = "Bottom Right"
                        },
                        get = function() return settings.focusStartPosition end,
                        set = function(_, value) 
                            settings.focusStartPosition = value
                            VUI.db.profile.keyboardNavigation.focusStartPosition = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    autoFocus = {
                        order = 2,
                        type = "toggle",
                        name = "Auto Focus First Element",
                        desc = "Automatically focus the first element when a frame is shown",
                        get = function() return settings.autoFocus end,
                        set = function(_, value) 
                            settings.autoFocus = value
                            VUI.db.profile.keyboardNavigation.autoFocus = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    rememberLastFocus = {
                        order = 3,
                        type = "toggle",
                        name = "Remember Last Focus",
                        desc = "Remember the last focused element per frame",
                        get = function() return settings.rememberLastFocus end,
                        set = function(_, value) 
                            settings.rememberLastFocus = value
                            VUI.db.profile.keyboardNavigation.rememberLastFocus = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                },
            },
            
            audioSection = {
                order = 4,
                type = "group",
                name = "Audio Feedback",
                inline = true,
                args = {
                    audioFeedback = {
                        order = 1,
                        type = "toggle",
                        name = "Audio Feedback",
                        desc = "Play sounds when navigating with keyboard",
                        get = function() return settings.audioFeedback end,
                        set = function(_, value) 
                            settings.audioFeedback = value
                            VUI.db.profile.keyboardNavigation.audioFeedback = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    audioFeedbackVolume = {
                        order = 2,
                        type = "range",
                        name = "Audio Feedback Volume",
                        desc = "Volume level for keyboard navigation sounds",
                        min = 0.0,
                        max = 1.0,
                        step = 0.05,
                        get = function() return settings.audioFeedbackVolume end,
                        set = function(_, value) 
                            settings.audioFeedbackVolume = value
                            VUI.db.profile.keyboardNavigation.audioFeedbackVolume = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.audioFeedback end,
                    },
                },
            },
        }
    }
    
    return options
end

-- Get navigation mode constants
function KeyboardNavigation:GetNavigationModes()
    return NAV_MODE
end

-- Module export for VUI
VUI.KeyboardNavigation = KeyboardNavigation

-- Initialize on VUI ready
if VUI.isInitialized then
    KeyboardNavigation:Initialize()
else
    -- Instead of using RegisterScript, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize module after VUI is initialized
        if KeyboardNavigation.Initialize then
            KeyboardNavigation:Initialize()
        end
    end
end