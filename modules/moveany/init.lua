local _, VUI = ...

-- Create the MoveAny module
local MoveAny = {}
VUI:RegisterModule("moveany", MoveAny)

-- Initialize the module
function MoveAny:Initialize()
    -- Create table to store moveable frames
    self.frames = {}
    self.anchors = {}
    self.registered = {}
    
    -- Setup grid overlay
    self:SetupGrid()
    
    -- Register default frames
    self:RegisterDefaultFrames()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("ADDON_LOADED")
end

-- Set up the grid overlay for precise positioning
function MoveAny:SetupGrid()
    -- Create grid frame
    self.gridFrame = CreateFrame("Frame", "VUIMoveAnyGrid", UIParent)
    self.gridFrame:SetAllPoints(UIParent)
    self.gridFrame:SetFrameStrata("BACKGROUND")
    self.gridFrame:Hide()
    
    -- Add horizontal and vertical grid lines
    self.gridFrame.horizontal = {}
    self.gridFrame.vertical = {}
    
    local gridSize = VUI.db.profile.modules.moveany.gridSize or 32
    
    -- Calculate number of lines needed based on screen dimensions
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    
    -- Create horizontal grid lines
    for i = 0, math.ceil(screenHeight / gridSize) do
        local line = self.gridFrame:CreateTexture(nil, "BACKGROUND")
        line:SetTexture(1, 1, 1, 0.2)
        line:SetHeight(1)
        line:SetPoint("TOPLEFT", self.gridFrame, "TOPLEFT", 0, -i * gridSize)
        line:SetPoint("TOPRIGHT", self.gridFrame, "TOPRIGHT", 0, -i * gridSize)
        table.insert(self.gridFrame.horizontal, line)
    end
    
    -- Create vertical grid lines
    for i = 0, math.ceil(screenWidth / gridSize) do
        local line = self.gridFrame:CreateTexture(nil, "BACKGROUND")
        line:SetTexture(1, 1, 1, 0.2)
        line:SetWidth(1)
        line:SetPoint("TOPLEFT", self.gridFrame, "TOPLEFT", i * gridSize, 0)
        line:SetPoint("BOTTOMLEFT", self.gridFrame, "BOTTOMLEFT", i * gridSize, 0)
        table.insert(self.gridFrame.vertical, line)
    end
end

-- Update grid display based on current settings
function MoveAny:UpdateGrid()
    -- Clear existing grid lines
    for _, line in ipairs(self.gridFrame.horizontal) do
        line:Hide()
    end
    for _, line in ipairs(self.gridFrame.vertical) do
        line:Hide()
    end
    
    self.gridFrame.horizontal = {}
    self.gridFrame.vertical = {}
    
    local gridSize = VUI.db.profile.modules.moveany.gridSize or 32
    
    -- Calculate number of lines needed based on screen dimensions
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    
    -- Create horizontal grid lines
    for i = 0, math.ceil(screenHeight / gridSize) do
        local line = self.gridFrame:CreateTexture(nil, "BACKGROUND")
        line:SetTexture(1, 1, 1, 0.2)
        line:SetHeight(1)
        line:SetPoint("TOPLEFT", self.gridFrame, "TOPLEFT", 0, -i * gridSize)
        line:SetPoint("TOPRIGHT", self.gridFrame, "TOPRIGHT", 0, -i * gridSize)
        table.insert(self.gridFrame.horizontal, line)
    end
    
    -- Create vertical grid lines
    for i = 0, math.ceil(screenWidth / gridSize) do
        local line = self.gridFrame:CreateTexture(nil, "BACKGROUND")
        line:SetTexture(1, 1, 1, 0.2)
        line:SetWidth(1)
        line:SetPoint("TOPLEFT", self.gridFrame, "TOPLEFT", i * gridSize, 0)
        line:SetPoint("BOTTOMLEFT", self.gridFrame, "BOTTOMLEFT", i * gridSize, 0)
        table.insert(self.gridFrame.vertical, line)
    end
end

-- Show or hide the grid
function MoveAny:ToggleGrid()
    if self.gridFrame:IsShown() then
        self.gridFrame:Hide()
    else
        self.gridFrame:Show()
    end
end

-- Register a frame to be movable
function MoveAny:RegisterFrame(frame, name, skipSavePosition)
    if not frame or not name then return end
    
    -- Avoid registering the same frame twice
    if self.registered[name] then return end
    
    -- Store reference to frame
    self.registered[name] = frame
    
    -- Set movable properties
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    
    -- Create anchor if it doesn't exist
    if not self.anchors[name] then
        self:CreateAnchor(frame, name)
    end
    
    -- Apply saved position
    if not skipSavePosition then
        self:ApplySavedPosition(frame, name)
    end
    
    -- Add to moveable frames list
    table.insert(self.frames, {frame = frame, name = name})
end

-- Create an anchor for a frame
function MoveAny:CreateAnchor(frame, name)
    local anchor = CreateFrame("Frame", "VUIMoveAnyAnchor"..name, UIParent)
    anchor:SetSize(frame:GetWidth(), frame:GetHeight())
    anchor:SetPoint("CENTER", frame, "CENTER")
    anchor:SetFrameStrata("HIGH")
    anchor:EnableMouse(true)
    anchor:SetMovable(true)
    anchor:Hide()
    
    -- Create visible border
    local border = anchor:CreateTexture(nil, "OVERLAY")
    border:SetTexture(1, 0.5, 0, 0.4)
    border:SetAllPoints()
    
    -- Create label
    local label = anchor:CreateFontString(nil, "OVERLAY")
    label:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), 10, "OUTLINE")
    label:SetText(name)
    label:SetPoint("TOP", anchor, "TOP", 0, 12)
    
    -- Allow dragging
    anchor:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    anchor:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            
            -- Save position
            local frameName = self:GetName():gsub("VUIMoveAnyAnchor", "")
            local registeredFrame = MoveAny.registered[frameName]
            
            if registeredFrame then
                -- Update frame position to match anchor
                registeredFrame:ClearAllPoints()
                registeredFrame:SetPoint("CENTER", self, "CENTER")
                
                -- Save position
                MoveAny:SavePosition(registeredFrame, frameName)
            end
        end
    end)
    
    -- Tooltip display
    if VUI.db.profile.modules.moveany.showTooltips then
        anchor:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(name)
            GameTooltip:AddLine("Left-click and drag to move", 1, 1, 1)
            GameTooltip:AddLine("Right-click for options", 1, 1, 1)
            GameTooltip:Show()
        end)
        
        anchor:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    -- Right-click menu
    anchor:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        elseif button == "RightButton" then
            -- Create context menu
            local menu = {
                { text = name, isTitle = true },
                { text = "Reset Position", func = function() MoveAny:ResetPosition(name) end },
                { text = "Cancel", func = function() end }
            }
            EasyMenu(menu, CreateFrame("Frame", "VUIMoveAnyMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
        end
    end)
    
    self.anchors[name] = anchor
end

-- Save the position of a frame
function MoveAny:SavePosition(frame, name)
    if not frame or not name then return end
    
    -- Get current position relative to screen
    local scale = frame:GetEffectiveScale()
    local worldScale = UIParent:GetEffectiveScale()
    local x, y = frame:GetCenter()
    
    if not x or not y then return end
    
    -- Convert to screen coordinates
    x = x * scale
    y = y * scale
    
    -- Convert to UIParent coordinates
    x = x / worldScale
    y = y / worldScale
    
    -- Store position
    VUI.db.profile.modules.moveany.savedFrames[name] = {
        x = x,
        y = y,
        scale = frame:GetScale()
    }
end

-- Apply saved position to a frame
function MoveAny:ApplySavedPosition(frame, name)
    if not frame or not name then return end
    
    local savedPosition = VUI.db.profile.modules.moveany.savedFrames[name]
    if not savedPosition then return end
    
    -- Set scale if stored
    if savedPosition.scale then
        frame:SetScale(savedPosition.scale)
    end
    
    -- Position frame at saved location
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", savedPosition.x, savedPosition.y)
    
    -- Update anchor if it exists
    if self.anchors[name] then
        self.anchors[name]:ClearAllPoints()
        self.anchors[name]:SetPoint("CENTER", frame, "CENTER")
    end
end

-- Reset a frame to its default position
function MoveAny:ResetPosition(name)
    if not name then return end
    
    -- Remove saved position
    VUI.db.profile.modules.moveany.savedFrames[name] = nil
    
    -- Get frame
    local frame = self.registered[name]
    if not frame then return end
    
    -- Reset scale
    frame:SetScale(1)
    
    -- Let WoW reposition the frame
    if frame.SetUserPlaced then
        frame:SetUserPlaced(false)
    end
    
    -- Update anchor if it exists
    if self.anchors[name] then
        self.anchors[name]:ClearAllPoints()
        self.anchors[name]:SetPoint("CENTER", frame, "CENTER")
    end
    
    -- Print confirmation
    VUI:Print("Reset position for " .. name)
end

-- Register default UI frames
function MoveAny:RegisterDefaultFrames()
    -- Combat frames
    self:RegisterFrame(PlayerFrame, "PlayerFrame")
    self:RegisterFrame(TargetFrame, "TargetFrame")
    self:RegisterFrame(FocusFrame, "FocusFrame")
    
    -- Action bars
    self:RegisterFrame(MainMenuBar, "MainMenuBar")
    
    -- Minimap
    self:RegisterFrame(MinimapCluster, "MinimapCluster")
    
    -- Chat frames
    self:RegisterFrame(ChatFrame1, "ChatFrame1")
    
    -- More frames will be registered as they are created by the game (in ADDON_LOADED)
end

-- Lock all frames to prevent movement
function MoveAny:LockFrames()
    for _, frameInfo in ipairs(self.frames) do
        local frame = frameInfo.frame
        local name = frameInfo.name
        
        if self.anchors[name] then
            self.anchors[name]:Hide()
        end
    end
    
    -- Hide grid
    self.gridFrame:Hide()
    
    -- Set locked state
    VUI.db.profile.modules.moveany.lockFrames = true
end

-- Unlock all frames for movement
function MoveAny:UnlockFrames()
    -- Show anchors for all registered frames
    for _, frameInfo in ipairs(self.frames) do
        local frame = frameInfo.frame
        local name = frameInfo.name
        
        if self.anchors[name] then
            -- Update anchor position
            self.anchors[name]:ClearAllPoints()
            self.anchors[name]:SetPoint("CENTER", frame, "CENTER")
            
            -- Show anchor
            self.anchors[name]:Show()
        end
    end
    
    -- Show grid if enabled
    if VUI.db.profile.modules.moveany.showGrid then
        self.gridFrame:Show()
    end
    
    -- Set locked state
    VUI.db.profile.modules.moveany.lockFrames = false
end

-- Event handlers
function MoveAny:PLAYER_ENTERING_WORLD()
    -- Apply saved positions to all registered frames
    for name, frame in pairs(self.registered) do
        self:ApplySavedPosition(frame, name)
    end
end

function MoveAny:PLAYER_REGEN_DISABLED()
    -- Lock frames in combat to prevent accidental movement
    if not VUI.db.profile.modules.moveany.lockFrames then
        self:LockFrames()
        VUI:Print("MoveAny: Frames locked during combat")
    end
end

function MoveAny:PLAYER_REGEN_ENABLED()
    -- Restore previous lock state
    if not VUI.db.profile.modules.moveany.lockFrames then
        self:UnlockFrames()
        VUI:Print("MoveAny: Frames unlocked after combat")
    end
end

function MoveAny:ADDON_LOADED(event, addonName)
    -- Register additional frames as they're created
    if addonName == "Blizzard_AchievementUI" then
        self:RegisterFrame(AchievementFrame, "AchievementFrame")
    elseif addonName == "Blizzard_Calendar" then
        self:RegisterFrame(CalendarFrame, "CalendarFrame")
    elseif addonName == "Blizzard_InspectUI" then
        self:RegisterFrame(InspectFrame, "InspectFrame")
    -- And so on for other Blizzard UI addons...
    end
end

-- Module enable/disable functions
function MoveAny:Enable()
    -- Apply saved positions
    for name, frame in pairs(self.registered) do
        self:ApplySavedPosition(frame, name)
    end
    
    -- Enable event processing
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", self.PLAYER_REGEN_DISABLED)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
    self:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED)
    
    -- Default to locked state
    if VUI.db.profile.modules.moveany.lockFrames then
        self:LockFrames()
    else
        self:UnlockFrames()
    end
    
    VUI:Print("MoveAny module enabled")
end

function MoveAny:Disable()
    -- Hide all anchors
    for name, anchor in pairs(self.anchors) do
        anchor:Hide()
    end
    
    -- Hide grid
    self.gridFrame:Hide()
    
    -- Unregister events
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("ADDON_LOADED")
    
    VUI:Print("MoveAny module disabled")
end

-- Helper functions
function MoveAny:RegisterEvent(event, handler)
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame.events = {}
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            local handler = self.eventFrame.events[event]
            if handler then
                handler(self, event, ...)
            end
        end)
    end
    
    self.eventFrame.events[event] = handler or self[event]
    self.eventFrame:RegisterEvent(event)
end

function MoveAny:UnregisterEvent(event)
    if self.eventFrame and self.eventFrame.events[event] then
        self.eventFrame:UnregisterEvent(event)
        self.eventFrame.events[event] = nil
    end
end

-- Update settings
function MoveAny:UpdateSettings()
    -- Update grid size
    self:UpdateGrid()
    
    -- Update tooltip display
    local showTooltips = VUI.db.profile.modules.moveany.showTooltips
    for name, anchor in pairs(self.anchors) do
        if showTooltips then
            anchor:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(name)
                GameTooltip:AddLine("Left-click and drag to move", 1, 1, 1)
                GameTooltip:AddLine("Right-click for options", 1, 1, 1)
                GameTooltip:Show()
            end)
            
            anchor:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        else
            anchor:SetScript("OnEnter", nil)
            anchor:SetScript("OnLeave", nil)
        end
    end
    
    -- Update lock state
    if VUI.db.profile.modules.moveany.lockFrames then
        self:LockFrames()
    else
        self:UnlockFrames()
    end
end

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
            lock = {
                type = "toggle",
                name = "Lock Frames",
                desc = "Lock or unlock frames for movement",
                order = 2,
                get = function() return VUI.db.profile.modules.moveany.lockFrames end,
                set = function(_, value)
                    VUI.db.profile.modules.moveany.lockFrames = value
                    if value then
                        MoveAny:LockFrames()
                    else
                        MoveAny:UnlockFrames()
                    end
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
            },
            grid = {
                type = "toggle",
                name = "Show Grid",
                desc = "Show or hide the positioning grid",
                order = 3,
                get = function() return VUI.db.profile.modules.moveany.showGrid end,
                set = function(_, value)
                    VUI.db.profile.modules.moveany.showGrid = value
                    if value and not VUI.db.profile.modules.moveany.lockFrames then
                        MoveAny.gridFrame:Show()
                    else
                        MoveAny.gridFrame:Hide()
                    end
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
            },
            gridSize = {
                type = "range",
                name = "Grid Size",
                desc = "Size of the grid squares",
                order = 4,
                min = 8,
                max = 64,
                step = 4,
                get = function() return VUI.db.profile.modules.moveany.gridSize end,
                set = function(_, value)
                    VUI.db.profile.modules.moveany.gridSize = value
                    MoveAny:UpdateGrid()
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
            },
            snapToGrid = {
                type = "toggle",
                name = "Snap to Grid",
                desc = "Snap frames to the grid when moving",
                order = 5,
                get = function() return VUI.db.profile.modules.moveany.snapToGrid end,
                set = function(_, value)
                    VUI.db.profile.modules.moveany.snapToGrid = value
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
            },
            snapThreshold = {
                type = "range",
                name = "Snap Threshold",
                desc = "Distance from grid lines to snap to",
                order = 6,
                min = 1,
                max = 20,
                step = 1,
                get = function() return VUI.db.profile.modules.moveany.snapThreshold end,
                set = function(_, value)
                    VUI.db.profile.modules.moveany.snapThreshold = value
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") or not VUI.db.profile.modules.moveany.snapToGrid end,
            },
            showTooltips = {
                type = "toggle",
                name = "Show Tooltips",
                desc = "Show tooltips when hovering over frame anchors",
                order = 7,
                get = function() return VUI.db.profile.modules.moveany.showTooltips end,
                set = function(_, value)
                    VUI.db.profile.modules.moveany.showTooltips = value
                    MoveAny:UpdateSettings()
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
            },
            resetAll = {
                type = "execute",
                name = "Reset All Frames",
                desc = "Reset all frames to their default positions",
                order = 8,
                func = function()
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
                end,
                disabled = function() return not VUI:IsModuleEnabled("moveany") end,
            },
        }
    }
end
