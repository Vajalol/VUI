-- VUIAnyFrame - Frame Movement Handler
local AddonName, VUI = ...
local M = _G["VUIAnyFrame"]
local L = M.L

-- Track drag frames
local VADF = {}
function M:GetDragFrames()
    return VADF
end

--[[ HIDDEN PANEL ]]
M.HIDDEN_FRAME = CreateFrame("Frame", "VUIHIDDEN")
M.HIDDEN_FRAME:Hide()
M.HIDDEN_FRAME.unit = "player"
M.HIDDEN_FRAME.auraRows = 0
local sethidden = {}
local sethiddenSetup = {}

-- Hide a frame
function M:HideFrame(frame, soft)
    if not soft then
        if InCombatLockdown() then
            C_Timer.After(
                0.1,
                function()
                    M:HideFrame(frame, soft)
                end
            )
            return
        end

        sethidden[frame] = true
        if sethiddenSetup[frame] == nil then
            sethiddenSetup[frame] = true
            local setparent = false
            hooksecurefunc(
                frame,
                "SetParent",
                function(sel, parent)
                    if sethidden[sel] == nil then return end
                    if setparent then return end
                    setparent = true
                    sel:SetParent(M.HIDDEN_FRAME)
                    setparent = false
                end
            )
        end

        frame:SetParent(M.HIDDEN_FRAME)
        return
    end

    sethidden[frame] = true
    if sethiddenSetup[frame] == nil then
        sethiddenSetup[frame] = true
        local setalpha = false
        hooksecurefunc(
            frame,
            "SetAlpha",
            function(sel, alpha)
                if sethidden[sel] == nil then return end
                if setalpha then return end
                setalpha = true
                sel:SetAlpha(0)
                if not InCombatLockdown() then
                    sel:EnableMouse(false)
                end

                if sel.GetChildren then
                    M:ForeachChildren(
                        sel,
                        function(child)
                            child:SetAlpha(0)
                            if not InCombatLockdown() then
                                child:EnableMouse(false)
                            end
                        end, "HideFrame"
                    )
                end

                setalpha = false
            end
        )
    end

    frame:SetAlpha(0)
    frame:EnableMouse(false)
    if InCombatLockdown() then
        C_Timer.After(
            0.1,
            function()
                M:HideFrame(frame, soft)
            end
        )
    end
end

-- Show a previously hidden frame
function M:ShowFrame(frame)
    sethidden[frame] = nil
    frame:SetAlpha(1)
    if not InCombatLockdown() then
        frame:EnableMouse(true)
    else
        C_Timer.After(
            0.1,
            function()
                M:ShowFrame(frame)
            end
        )
    end
end

--[[ UI PARENT REPLACEMENT ]]
M.UI_PARENT = CreateFrame("Frame", "VUIUIP")
M.UI_PARENT:SetAllPoints(UIParent)
M.UI_PARENT.unit = "player"
M.UI_PARENT.auraRows = 0

-- Set UI Parent Alpha
function M:SetUIParentAlpha(alpha)
    if UIParent:IsShown() then
        M.UI_PARENT:SetAlpha(alpha)
    else
        M.UI_PARENT:SetAlpha(0)
    end
end

-- Update UI Scale based on CVars
local uiscalecvar = CreateFrame("Frame")
uiscalecvar:RegisterEvent("CVAR_UPDATE")
uiscalecvar:SetScript(
    "OnEvent",
    function(self, event, target, value)
        if event == "CVAR_UPDATE" and (target == "uiScale" or target == "useUiScale") then
            if GetCVar("useUiScale") == "1" then
                M.UI_PARENT:SetScale(GetCVar("uiScale"))
            else
                M.UI_PARENT:SetScale(UIParent:GetScale())
            end
            
            M:UpdateGrid()
        end
    end
)

-- Hook UIParent scale changes
hooksecurefunc(
    UIParent,
    "SetScale",
    function(sel, scale)
        if InCombatLockdown() and sel:IsProtected() then return false end
        if GetCVar("useUiScale") == "0" and type(scale) == "number" then
            M.UI_PARENT:SetScale(scale)
        end
    end
)

-- Initial scale setup
if GetCVar("useUiScale") == "1" then
    M.UI_PARENT:SetScale(GetCVar("uiScale"))
else
    C_Timer.After(
        0,
        function()
            M.UI_PARENT:SetScale(UIParent:GetScale())
        end
    )
end

-- Mirror UIParent visibility
M:SetUIParentAlpha(UIParent:GetAlpha())
hooksecurefunc(
    UIParent,
    "Show",
    function(self)
        M:SetUIParentAlpha(1)
    end
)

hooksecurefunc(
    UIParent,
    "Hide",
    function(self)
        M:SetUIParentAlpha(0)
    end
)

hooksecurefunc(
    _G,
    "SetUIVisibility",
    function(show, ...)
        if show then
            M:SetUIParentAlpha(1)
        else
            M:SetUIParentAlpha(0)
        end
    end
)

-- Return the main panel
function M:GetMainPanel()
    return M.UI_PARENT
end

--[[ LOCK/UNLOCK FUNCTIONS ]]
local isToggling = false

-- Unlock frames for movement
function M:Unlock()
    if isToggling then
        M:Print("[Unlock] Already toggling lock state")
        return
    end
    
    isToggling = true
    self.db.profile.global.lockFrames = false
    
    -- Show all drag frames
    for i, df in pairs(M:GetDragFrames()) do
        df:Show()
        if df.opt then
            df.opt:Show()
        end
    end
    
    -- Show options panel if exists
    if M.LockFrame then
        M.LockFrame:Show()
        if M.GridFrame then
            M.GridFrame:Show()
        end
    end
    
    -- Update grid display
    M:UpdateGrid()
    
    M:Print("Frames unlocked - drag to reposition")
    isToggling = false
end

-- Lock frames to prevent movement
function M:Lock()
    if isToggling then
        M:Print("[Lock] Already toggling lock state")
        return
    end
    
    isToggling = true
    self.db.profile.global.lockFrames = true
    
    -- Hide all drag frames
    for i, df in pairs(M:GetDragFrames()) do
        df:Hide()
        if df.opt then
            df.opt:Hide()
        end
    end
    
    -- Hide options panel if exists
    if M.LockFrame then
        M.LockFrame:Hide()
        if M.GridFrame then
            M.GridFrame:Hide()
        end
    end
    
    M:Print("Frames locked")
    isToggling = false
end

-- Make a frame movable
function M:MakeFrameMovable(frame, displayName, frameType)
    if not frame then return end
    if not frameType then frameType = "FRAME" end
    
    -- Generate a unique name for the frame if none provided
    if not displayName then
        displayName = frame:GetName() or "UnnamedFrame"
    end
    
    -- Skip if this frame is already set up
    for id, f in pairs(VADF) do
        if f.mover and f.mover.frame == frame then
            return f.mover
        end
    end
    
    -- Create mover frame
    local moaFrameBG = CreateFrame("Frame", "VAMover_BG_" .. displayName, UIParent)
    local moaFrame = CreateFrame("Frame", "VAMover_" .. displayName, moaFrameBG)
    moaFrame:SetPoint("CENTER", moaFrameBG, "CENTER", 0, 0)
    
    -- Set up appearance
    moaFrameBG:SetFrameStrata("HIGH")
    moaFrameBG:SetFrameLevel(1)
    moaFrame:SetFrameStrata("HIGH")
    moaFrame:SetFrameLevel(2)
    
    -- Create a backdrop if LibStrata is available
    if LibStub and LibStub("LibSharedMedia-3.0", true) then
        -- Use LibSharedMedia for backdrops
        local LSM = LibStub("LibSharedMedia-3.0")
        
        -- Use LibBackdrop if available
        if LibStub("LibBackdrop-1.0", true) then
            local LBD = LibStub("LibBackdrop-1.0")
            LBD:PaintFrame(moaFrameBG, {
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = {left = 0, right = 0, top = 0, bottom = 0}
            })
            moaFrameBG:SetBackdropColor(M:GetColor("bg"))
            moaFrameBG:SetBackdropBorderColor(M:GetColor("se"))
        else
            -- Fallback to basic frame styling
            moaFrameBG:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = {left = 0, right = 0, top = 0, bottom = 0}
            })
            moaFrameBG:SetBackdropColor(M:GetColor("bg"))
            moaFrameBG:SetBackdropBorderColor(M:GetColor("se"))
        end
    else
        -- Fallback to basic frame styling
        moaFrameBG:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        })
        moaFrameBG:SetBackdropColor(M:GetColor("bg"))
        moaFrameBG:SetBackdropBorderColor(M:GetColor("se"))
    end
    
    -- Add text label
    local text = moaFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    text:SetPoint("CENTER", moaFrame, "CENTER", 0, 0)
    text:SetText(displayName)
    
    -- Save reference to original frame
    moaFrame.frame = frame
    moaFrame.name = displayName
    moaFrame.type = frameType
    
    -- Set size and position
    local width, height = frame:GetSize()
    if width < 10 then width = 10 end
    if height < 10 then height = 10 end
    
    moaFrameBG:SetSize(width, height)
    moaFrame:SetSize(width, height)
    
    -- Get the frame's position
    local scale = frame:GetScale()
    local x, y = M:GetPosition(frame)
    
    -- Position the mover
    moaFrameBG:SetScale(scale)
    moaFrameBG:ClearAllPoints()
    moaFrameBG:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    
    -- Make draggable
    moaFrameBG:SetMovable(true)
    moaFrameBG:EnableMouse(true)
    moaFrameBG:RegisterForDrag("LeftButton")
    moaFrameBG:SetScript("OnDragStart", function(self)
        if InCombatLockdown() and frame:IsProtected() then
            M:Print("Cannot move protected frames during combat")
            return
        end
        self:StartMoving()
    end)
    
    moaFrameBG:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        
        -- Get the new position
        local centerX, centerY = self:GetCenter()
        local scale = self:GetScale()
        local x = centerX * scale
        local y = centerY * scale
        
        -- Snap to grid if enabled
        if M.db.profile.global.snapToGrid then
            local grid = M.db.profile.global.grid
            x = math.floor(x / grid + 0.5) * grid
            y = math.floor(y / grid + 0.5) * grid
        end
        
        -- Update the position of both the mover and the target frame
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
        
        -- Set the target frame's position
        if not InCombatLockdown() or not frame:IsProtected() then
            M:SetPosition(frame, x, y)
            
            -- Save the position
            local settings = M:GetFrameSettings(displayName) or {}
            settings.x = x
            settings.y = y
            settings.scale = frame:GetScale()
            M:SaveFrameSettings(displayName, settings)
        else
            M:Print("Position will be saved after combat")
            C_Timer.After(0.5, function()
                if not InCombatLockdown() then
                    M:SetPosition(frame, x, y)
                    
                    -- Save the position
                    local settings = M:GetFrameSettings(displayName) or {}
                    settings.x = x
                    settings.y = y
                    settings.scale = frame:GetScale()
                    M:SaveFrameSettings(displayName, settings)
                end
            end)
        end
    end)
    
    -- Add right-click menu for additional options
    moaFrameBG:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            M:CreateFrameOptions(moaFrame)
        end
    end)
    
    -- Hide when frames are locked
    moaFrameBG:Hide()
    
    -- Store in drag frames table
    table.insert(VADF, {mover = moaFrame, bg = moaFrameBG})
    
    return moaFrame
end

-- Get frame position
function M:GetPosition(frame)
    if not frame then return 0, 0 end
    
    local scale = frame:GetEffectiveScale()
    local x, y = frame:GetCenter()
    
    if not x or not y then
        return 0, 0
    end
    
    return x * scale, y * scale
end

-- Set frame position
function M:SetPosition(frame, x, y)
    if not frame then return end
    if InCombatLockdown() and frame:IsProtected() then return end
    
    local scale = frame:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

-- Create options menu for a frame
function M:CreateFrameOptions(mover)
    if InCombatLockdown() then
        M:Print("Cannot modify frame options during combat")
        return
    end
    
    -- Only create if we don't already have one
    if not mover.opt then
        local frame = mover.frame
        local name = mover.name
        
        -- Create options frame
        local opt = CreateFrame("Frame", "VAOpt_" .. name, UIParent)
        opt:SetSize(200, 250)
        opt:SetPoint("TOPLEFT", mover, "TOPRIGHT", 5, 0)
        opt:SetFrameStrata("HIGH")
        opt:SetFrameLevel(100)
        
        -- Backdrop
        opt:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        opt:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        opt:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        
        -- Title
        local title = opt:CreateFontString(nil, "OVERLAY")
        title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        title:SetPoint("TOP", opt, "TOP", 0, -10)
        title:SetText(mover.name)
        
        -- Create buttons
        local buttons = {}
        local y = -40
        
        -- Reset button
        buttons.reset = M:CreateButton(opt, "Reset Position", y)
        buttons.reset:SetScript("OnClick", function()
            if InCombatLockdown() and frame:IsProtected() then
                M:Print("Cannot reset protected frames during combat")
                return
            end
            
            -- Remove saved settings
            M:ResetFrameSettings(name)
            
            -- Reset position and scale
            frame:ClearAllPoints()
            frame:SetPoint(frame.defaultPoint or "CENTER", UIParent, "CENTER", 0, 0)
            frame:SetScale(frame.defaultScale or 1.0)
            
            -- Update mover position and scale
            local x, y = M:GetPosition(frame)
            local scale = frame:GetScale()
            
            mover.bg:SetScale(scale)
            mover.bg:ClearAllPoints()
            mover.bg:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
            
            M:Print("Reset " .. name .. " to default position")
        end)
        
        -- Scale controls
        y = y - 40
        local scaleText = opt:CreateFontString(nil, "OVERLAY")
        scaleText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        scaleText:SetPoint("TOP", opt, "TOP", 0, y)
        scaleText:SetText("Scale: " .. string.format("%.2f", frame:GetScale()))
        
        y = y - 25
        buttons.scaleDown = M:CreateButton(opt, "-", y, 40)
        buttons.scaleDown:SetPoint("LEFT", opt, "LEFT", 20, y)
        buttons.scaleDown:SetScript("OnClick", function()
            if InCombatLockdown() and frame:IsProtected() then
                M:Print("Cannot scale protected frames during combat")
                return
            end
            
            local scale = math.max(0.1, frame:GetScale() - 0.1)
            frame:SetScale(scale)
            scaleText:SetText("Scale: " .. string.format("%.2f", scale))
            
            -- Update mover scale
            local x, y = M:GetPosition(frame)
            mover.bg:SetScale(scale)
            
            -- Save settings
            local settings = M:GetFrameSettings(name) or {}
            settings.scale = scale
            M:SaveFrameSettings(name, settings)
        end)
        
        buttons.scaleUp = M:CreateButton(opt, "+", y, 40)
        buttons.scaleUp:SetPoint("RIGHT", opt, "RIGHT", -20, y)
        buttons.scaleUp:SetScript("OnClick", function()
            if InCombatLockdown() and frame:IsProtected() then
                M:Print("Cannot scale protected frames during combat")
                return
            end
            
            local scale = math.min(3.0, frame:GetScale() + 0.1)
            frame:SetScale(scale)
            scaleText:SetText("Scale: " .. string.format("%.2f", scale))
            
            -- Update mover scale
            local x, y = M:GetPosition(frame)
            mover.bg:SetScale(scale)
            
            -- Save settings
            local settings = M:GetFrameSettings(name) or {}
            settings.scale = scale
            M:SaveFrameSettings(name, settings)
        end)
        
        -- Hide button
        y = y - 40
        buttons.hide = M:CreateButton(opt, "Hide Frame", y)
        buttons.hide:SetScript("OnClick", function()
            if InCombatLockdown() and frame:IsProtected() then
                M:Print("Cannot hide protected frames during combat")
                return
            end
            
            -- Update settings
            local settings = M:GetFrameSettings(name) or {}
            settings.hidden = true
            M:SaveFrameSettings(name, settings)
            
            -- Hide the frame
            M:HideFrame(frame)
            
            M:Print("Hid " .. name .. " (use /va reset to restore)")
            opt:Hide()
        end)
        
        -- Close button
        y = y - 40
        buttons.close = M:CreateButton(opt, "Close", y)
        buttons.close:SetScript("OnClick", function()
            opt:Hide()
        end)
        
        -- Store options frame
        mover.opt = opt
        opt:Hide()
    end
    
    -- Toggle visibility
    if mover.opt:IsShown() then
        mover.opt:Hide()
    else
        mover.opt:Show()
    end
end

-- Create a button helper
function M:CreateButton(parent, text, yOffset, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 160, 22)
    button:SetPoint("TOP", parent, "TOP", 0, yOffset)
    button:SetText(text)
    return button
end

-- Update grid for positioning
function M:UpdateGrid()
    if not M.GridFrame then
        -- Create grid frame
        M.GridFrame = CreateFrame("Frame", "VAGrid", UIParent)
        M.GridFrame:SetAllPoints(UIParent)
        M.GridFrame:SetFrameStrata("BACKGROUND")
        
        -- Create grid texture
        M.GridTexture = M.GridFrame:CreateTexture(nil, "BACKGROUND")
        M.GridTexture:SetAllPoints(M.GridFrame)
        M.GridTexture:SetColorTexture(1, 1, 1, 0.1)
        
        -- Hide by default
        M.GridFrame:Hide()
    end
    
    -- Update grid based on settings
    local grid = M.db.profile.global.grid or 10
    
    -- Set grid texture
    local width, height = UIParent:GetSize()
    
    -- Create new grid texture
    if grid > 0 then
        local texture = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\grid_" .. grid
        if not M.GridTexture:SetTexture(texture) then
            -- Fall back to creating a dynamic grid
            local gridTexture = M.GridTexture
            
            -- Clear texture
            gridTexture:SetColorTexture(0, 0, 0, 0)
            
            -- Add grid lines
            local size = grid
            local lineWidth = 1
            local r, g, b, a = 1, 1, 1, 0.1
            
            -- Create vertical lines
            for i = 0, math.ceil(width / size) do
                local line = M.GridFrame:CreateTexture(nil, "BACKGROUND")
                line:SetColorTexture(r, g, b, a)
                line:SetSize(lineWidth, height)
                line:SetPoint("TOPLEFT", i * size, 0)
            end
            
            -- Create horizontal lines
            for i = 0, math.ceil(height / size) do
                local line = M.GridFrame:CreateTexture(nil, "BACKGROUND")
                line:SetColorTexture(r, g, b, a)
                line:SetSize(width, lineWidth)
                line:SetPoint("TOPLEFT", 0, -i * size)
            end
        end
    end
end

-- Foreach helper function to process children
function M:ForeachChildren(frame, func, callLevel)
    if frame.GetChildren then
        local children = {frame:GetChildren()}
        for _, child in pairs(children) do
            func(child)
            M:ForeachChildren(child, func, callLevel)
        end
    end
end

-- Reset frame settings
function M:ResetFrameSettings(frameName)
    if frameName then
        -- Reset specific frame
        local settings = self.db.profile.frames[frameName]
        if settings then
            self.db.profile.frames[frameName] = nil
        end
    else
        -- Reset all frames
        self.db.profile.frames = {}
    end
end

-- Check if function is hooked
function M:IsHooked(funcName)
    if not self.hookedFunctions then
        self.hookedFunctions = {}
        return false
    end
    
    return self.hookedFunctions[funcName] ~= nil
end

-- Secure hook a function
function M:SecureHook(funcName, hookFunction)
    if not self.hookedFunctions then
        self.hookedFunctions = {}
    end
    
    if self.hookedFunctions[funcName] then
        return false
    end
    
    -- Store original function
    local originalFunc = _G[funcName]
    if not originalFunc then
        return false
    end
    
    -- Create the hook
    self.hookedFunctions[funcName] = hookFunction
    
    -- Replace the original function with our hooked version
    _G[funcName] = function(...)
        -- Call original first
        local ret = {originalFunc(...)}
        
        -- Then call our hook
        hookFunction(...)
        
        -- Return original results
        return unpack(ret)
    end
    
    return true
end 