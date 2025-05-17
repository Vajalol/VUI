-- VUIAnyFrame - Register Widgets
local AddonName, VUI = ...
local M = _G["VUIAnyFrame"]
local L = M.L

-- Element frames tracking
local MAEF = {}
local MACurrentEle = nil

-- Store current element for reference
function M:GetCurrentEle()
    return MACurrentEle
end

-- Access element frames
function M:GetEleFrames()
    return MAEF
end

-- Alpha frames tracking
local MAAF = {}
function M:GetAlphaFrames()
    return MAAF
end

-- Frame name tracking
local fnt = {}
function M:AddFrameName(frame, name)
    if frame == nil then
        M:Print("AddFrameName: frame is nil")
        return false
    end

    if name == nil then
        M:Print("AddFrameName: name is nil")
        return false
    end

    fnt[frame] = name
    return true
end

function M:GetFrameName(frame)
    if frame == nil then
        M:Print("GetFrameName: frame is nil")
        return "FAILED"
    end

    return fnt[frame]
end

-- Widget categories
M.CATEGORIES = {
    "Action Bars",
    "Player",
    "Target",
    "Focus",
    "Party",
    "Raid",
    "Arena",
    "Maps",
    "Unit Frames",
    "Boss Frames",
    "Casting",
    "Bags",
    "Chat",
    "Minimap",
    "Tooltips",
    "Misc"
}

-- Create slider for configuration options
function M:CreateSlider(parent, x, y, name, key, value, steps, vmin, vmax, func, lanArray)
    local slider = CreateFrame("Slider", nil, parent, "UISliderTemplate")
    slider:SetSize(parent:GetWidth() - 20 - x, 16)
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    
    if slider.Low == nil then
        slider.Low = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.Low:SetPoint("BOTTOMLEFT", slider, "BOTTOMLEFT", 0, -12)
        slider.Low:SetFont(slider.Low:GetFont(), 10, "THINOUTLINE")
        slider.Low:SetTextColor(1, 1, 1)
    end

    if slider.High == nil then
        slider.High = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.High:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", 0, -12)
        slider.High:SetFont(slider.High:GetFont(), 10, "THINOUTLINE")
        slider.High:SetTextColor(1, 1, 1)
    end

    if slider.Text == nil then
        slider.Text = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.Text:SetPoint("TOP", slider, "TOP", 0, 16)
        slider.Text:SetFont(slider.Text:GetFont(), 12, "THINOUTLINE")
        slider.Text:SetTextColor(1, 1, 1)
    end

    slider.Low:SetText(vmin)
    slider.High:SetText(vmax)
    
    local currentValue = M:GetFrameSetting(name, key) or value
    
    if lanArray then
        slider.Text:SetText(L[key] .. ": " .. lanArray[currentValue])
    else
        slider.Text:SetText(L[key] .. ": " .. currentValue)
    end

    slider:SetMinMaxValues(vmin, vmax)
    slider:SetObeyStepOnDrag(true)
    slider:SetValueStep(steps)
    slider:SetValue(currentValue)
    
    slider:SetScript("OnValueChanged", function(sel, val)
        val = tonumber(string.format("%" .. steps .. "f", val))
        if val then
            M:SaveFrameSetting(name, key, val)
            
            if lanArray then
                slider.Text:SetText(L[key] .. ": " .. lanArray[val])
            else
                slider.Text:SetText(L[key] .. ": " .. val)
            end

            if func then
                func()
            end
        end
    end)

    return slider
end

-- Register a frame/widget to be movable
function M:RegisterWidget(frameRef, displayName, category)
    if not frameRef then
        self:Print("Failed to register widget: frame reference is nil")
        return
    end
    
    -- Default to Misc category if none specified
    category = category or "Misc"
    
    -- Try to get the frame by name if passed a string
    local frame = frameRef
    if type(frameRef) == "string" then
        frame = _G[frameRef]
        if not frame then
            self:Print("Failed to register widget: " .. frameRef .. " does not exist")
            return
        end
    end
    
    -- Default displayName to frame's name
    if not displayName then
        displayName = frame:GetName() or "UnnamedFrame"
    end
    
    -- Store frame name for reference
    M:AddFrameName(frame, displayName)
    
    -- Make the frame movable
    local mover = M:MakeFrameMovable(frame, displayName)
    
    -- Add to options
    self:AddWidgetToOptions(frame, displayName, category)
    
    -- Store in element frames
    MAEF[displayName] = frame
    
    return mover
end

-- Add widget to options panel
function M:AddWidgetToOptions(frame, displayName, category)
    -- Skip if frame or name is missing
    if not frame or not displayName then
        return
    end
    
    -- Ensure frame registry exists
    if not self.registeredWidgets then
        self.registeredWidgets = {}
    end
    
    -- Ensure category exists
    if not self.registeredWidgets[category] then
        self.registeredWidgets[category] = {}
    end
    
    -- Register the frame
    table.insert(self.registeredWidgets[category], {
        frame = frame,
        name = displayName
    })
end

-- Get position of an element
function M:GetElePoint(name)
    local frame = MAEF[name]
    if not frame then
        return nil
    end
    
    local point, relativeTo, relativePoint, x, y = frame:GetPoint()
    return point, relativeTo, relativePoint, x, y
end

-- Set position of an element
function M:SetElePoint(name, point, relativeTo, relativePoint, x, y)
    local frame = MAEF[name]
    if not frame then
        return false
    end
    
    if InCombatLockdown() and frame:IsProtected() then
        return false
    end
    
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, x, y)
    
    -- Save position
    local settings = M:GetFrameSettings(name) or {}
    settings.point = point
    settings.relativePoint = relativePoint
    settings.x = x
    settings.y = y
    M:SaveFrameSettings(name, settings)
    
    return true
end

-- Get element option
function M:GetEleOption(name, key, default)
    local value = M:GetFrameSetting(name, key)
    if value == nil then
        return default
    end
    return value
end

-- Set element option
function M:SetEleOption(name, key, value)
    M:SaveFrameSetting(name, key, value)
    return value
end

-- Get element options table
function M:GetEleOptions(name)
    return M:GetFrameSettings(name) or {}
end

-- Generate options from registered widgets
function M:GetWidgetOptions()
    if not self.registeredWidgets then
        return {}
    end
    
    local options = {}
    
    -- Create category groups
    for _, category in ipairs(M.CATEGORIES) do
        if self.registeredWidgets[category] and #self.registeredWidgets[category] > 0 then
            options[category] = {
                type = "group",
                name = category,
                order = 10,
                args = {}
            }
            
            -- Add frames to each category
            for i, widget in ipairs(self.registeredWidgets[category]) do
                local name = widget.name:gsub("%s+", ""):gsub("[^%w]", "")
                options[category].args[name] = {
                    type = "execute",
                    name = widget.name,
                    desc = "Click to configure " .. widget.name,
                    order = i,
                    func = function()
                        -- Set current element
                        MACurrentEle = widget.name
                        
                        -- Find the mover for this frame
                        for _, df in pairs(M:GetDragFrames()) do
                            if df.mover and df.mover.frame == widget.frame then
                                M:CreateFrameOptions(df.mover)
                                break
                            end
                        end
                    end
                }
            end
        end
    end
    
    return options
end

-- Get list of registered widgets
function M:GetRegisteredWidgets()
    return self.registeredWidgets or {}
end

-- Register common Blizzard UI frames
function M:RegisterCommonWidgets()
    -- Skip registration if in combat
    if InCombatLockdown() then
        C_Timer.After(0.5, function() self:RegisterCommonWidgets() end)
        return
    end
    
    -- Check if already registered
    if self.commonWidgetsRegistered then
        return
    end
    
    -- Player Frame
    if PlayerFrame then
        self:RegisterWidget(PlayerFrame, "PlayerFrame", "Player")
    end
    
    -- Target Frame
    if TargetFrame then
        self:RegisterWidget(TargetFrame, "TargetFrame", "Target")
    end
    
    -- Focus Frame
    if FocusFrame then
        self:RegisterWidget(FocusFrame, "FocusFrame", "Focus")
    end
    
    -- Minimap
    if MinimapCluster then
        self:RegisterWidget(MinimapCluster, "MinimapCluster", "Minimap")
    end
    
    -- Buff Frame
    if BuffFrame then
        self:RegisterWidget(BuffFrame, "BuffFrame", "Player")
    end
    
    -- Chat Frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            self:RegisterWidget(chatFrame, "ChatFrame" .. i, "Chat")
        end
    end
    
    -- Action Bars
    if MainMenuBar then
        self:RegisterWidget(MainMenuBar, "MainMenuBar", "Action Bars")
    end
    
    if MultiBarBottomLeft then
        self:RegisterWidget(MultiBarBottomLeft, "MultiBarBottomLeft", "Action Bars")
    end
    
    if MultiBarBottomRight then
        self:RegisterWidget(MultiBarBottomRight, "MultiBarBottomRight", "Action Bars")
    end
    
    if MultiBarRight then
        self:RegisterWidget(MultiBarRight, "MultiBarRight", "Action Bars")
    end
    
    if MultiBarLeft then
        self:RegisterWidget(MultiBarLeft, "MultiBarLeft", "Action Bars")
    end
    
    -- Add support for MultiBar5-7 if they exist (Retail WoW)
    for i = 5, 7 do
        local multiBar = _G["MultiBar" .. i]
        if multiBar then
            self:RegisterWidget(multiBar, "MultiBar" .. i, "Action Bars")
        end
    end
    
    -- Objective Tracker
    if ObjectiveTrackerFrame then
        self:RegisterWidget(ObjectiveTrackerFrame, "ObjectiveTrackerFrame", "Misc")
    end
    
    -- Cast Bar
    if CastingBarFrame then
        self:RegisterWidget(CastingBarFrame, "CastingBarFrame", "Casting")
    end
    
    -- Bags
    if MicroButtonAndBagsBar then
        self:RegisterWidget(MicroButtonAndBagsBar, "MicroButtonAndBagsBar", "Bags")
    end
    
    -- Boss Frames
    if Boss1TargetFrame then
        for i = 1, MAX_BOSS_FRAMES do
            local bossFrame = _G["Boss" .. i .. "TargetFrame"]
            if bossFrame then
                self:RegisterWidget(bossFrame, "Boss" .. i .. "TargetFrame", "Boss Frames")
            end
        end
    end
    
    -- Arena Frames
    if ArenaEnemyFrame1 then
        for i = 1, 5 do
            local arenaFrame = _G["ArenaEnemyFrame" .. i]
            if arenaFrame then
                self:RegisterWidget(arenaFrame, "ArenaEnemyFrame" .. i, "Arena")
            end
        end
    end
    
    -- Raid frames (if available)
    if CompactRaidFrameContainer then
        self:RegisterWidget(CompactRaidFrameContainer, "CompactRaidFrameContainer", "Raid")
    end
    
    -- Party frames
    if CompactPartyFrame then
        self:RegisterWidget(CompactPartyFrame, "CompactPartyFrame", "Party")
    end
    
    -- Pet Bar
    if PetActionBarFrame then
        self:RegisterWidget(PetActionBarFrame, "PetActionBarFrame", "Action Bars")
    end
    
    -- Stance Bar
    if StanceBarFrame then
        self:RegisterWidget(StanceBarFrame, "StanceBarFrame", "Action Bars")
    end
    
    -- Register special frames handled by ele scripts
    -- These will be initialized by the specific element modules
    self:RegisterElementFrames()
    
    -- Mark as registered
    self.commonWidgetsRegistered = true
end

-- Register special frames that need custom handling
function M:RegisterElementFrames()
    -- This function will be called by element scripts
    -- to register special frames that need custom handling
    
    -- For example, created buff/debuff bars will call this 
    -- to register themselves
end

-- Populate options based on registered widgets
function M:GetOptions()
    local options = {
        type = "group",
        name = M.TITLE,
        args = {
            general = {
                type = "group",
                name = "General",
                order = 1,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enable VUIAnyFrame",
                        desc = "Enable or disable the addon functionality",
                        width = "full",
                        order = 1,
                        get = function() return M.db.profile.enabled end,
                        set = function(info, val)
                            M.db.profile.enabled = val
                            if val then
                                M:OnEnable()
                            else
                                M:OnDisable()
                            end
                        end
                    },
                    lockFrames = {
                        type = "toggle",
                        name = "Lock Frames",
                        desc = "Lock frames to prevent movement",
                        width = "full",
                        order = 2,
                        get = function() return M.db.profile.global.lockFrames end,
                        set = function(info, val)
                            M.db.profile.global.lockFrames = val
                            if val then
                                M:Lock()
                            else
                                M:Unlock()
                            end
                        end
                    },
                    toggleLock = {
                        type = "execute",
                        name = function()
                            return M.db.profile.global.lockFrames and "Unlock Frames" or "Lock Frames"
                        end,
                        desc = "Toggle frame locking",
                        width = "full",
                        order = 3,
                        func = function()
                            M:ToggleLock()
                        end
                    },
                    resetAll = {
                        type = "execute",
                        name = "Reset All Frames",
                        desc = "Reset all frames to their default positions",
                        width = "full",
                        confirm = true,
                        order = 4,
                        func = function()
                            M:ResetAllFrameSettings()
                            M:Print("All frames reset to default positions")
                        end
                    },
                    gridSettings = {
                        type = "group",
                        name = "Grid Settings",
                        inline = true,
                        order = 5,
                        args = {
                            grid = {
                                type = "range",
                                name = "Grid Size",
                                desc = "Size of the alignment grid",
                                min = 1,
                                max = 64,
                                step = 1,
                                width = "full",
                                order = 1,
                                get = function() return M.db.profile.global.grid end,
                                set = function(info, val)
                                    M.db.profile.global.grid = val
                                    M:UpdateGrid()
                                end
                            },
                            snapToGrid = {
                                type = "toggle",
                                name = "Snap to Grid",
                                desc = "Snap frames to grid when moving",
                                width = "full",
                                order = 2,
                                get = function() return M.db.profile.global.snapToGrid end,
                                set = function(info, val)
                                    M.db.profile.global.snapToGrid = val
                                end
                            }
                        }
                    }
                }
            },
            minimap = {
                type = "group",
                name = "Minimap Button",
                order = 2,
                args = {
                    hide = {
                        type = "toggle",
                        name = "Hide Minimap Button",
                        desc = "Show or hide the minimap button",
                        width = "full",
                        order = 1,
                        get = function() return M.db.profile.minimap.hide end,
                        set = function(info, val)
                            M.db.profile.minimap.hide = val
                            if LibStub and LibStub("LibDBIcon-1.0", true) then
                                local LDBIcon = LibStub("LibDBIcon-1.0")
                                if val then
                                    LDBIcon:Hide("VUIAnyFrame")
                                else
                                    LDBIcon:Show("VUIAnyFrame")
                                end
                            end
                        end
                    }
                }
            },
            frames = {
                type = "group",
                name = "Frames",
                order = 3,
                args = {}
            }
        }
    }
    
    -- Add widget options
    local widgetOptions = M:GetWidgetOptions()
    for category, group in pairs(widgetOptions) do
        options.args.frames.args[category:gsub("%s+", ""):lower()] = group
    end
    
    return options
end 