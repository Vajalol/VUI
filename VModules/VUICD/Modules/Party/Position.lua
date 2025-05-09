local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local Pos = {}
P.Position = Pos

-- Local variables
local defaultPosition = {
    point = "TOPLEFT",
    relativePoint = "TOPLEFT",
    xOffset = 10,
    yOffset = -10,
    anchorFrame = "UIParent"
}

-- Initialize position module
function Pos:Initialize()
    self.db = VUICD:GetPartySettings()
    
    -- Create position settings if they don't exist
    if not self.db.position then
        self.db.position = defaultPosition
    end
    
    -- Make the container movable
    self:MakeMovable(P.container)
    
    -- Set initial position
    self:ApplyPosition()
    
    -- Register for events
    P.container:HookScript("OnShow", function()
        self:ApplyPosition()
    end)
end

-- Make a frame movable
function Pos:MakeMovable(frame)
    if not frame then return end
    
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    
    -- Create overlay for drag handling
    if not frame.dragOverlay then
        frame.dragOverlay = CreateFrame("Frame", nil, frame)
        frame.dragOverlay:SetAllPoints(frame)
        frame.dragOverlay:SetFrameStrata("HIGH")
        
        -- Create background texture
        local bg = frame.dragOverlay:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.3)
        bg:Hide()
        frame.dragOverlay.bg = bg
        
        -- Create header
        local header = frame.dragOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOP", 0, -5)
        header:SetText("VUICD Party Frames")
        header:Hide()
        frame.dragOverlay.header = header
        
        -- Create drag indication
        local dragText = frame.dragOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dragText:SetPoint("BOTTOM", 0, 5)
        dragText:SetText("Drag to Move")
        dragText:Hide()
        frame.dragOverlay.dragText = dragText
        
        -- Set scripts
        frame.dragOverlay:SetScript("OnMouseDown", function(_, button)
            if button == "LeftButton" then
                frame:StartMoving()
            end
        end)
        
        frame.dragOverlay:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" then
                frame:StopMovingOrSizing()
                self:SavePosition(frame)
            end
        end)
    end
    
    -- Enable mouse interaction for dragging
    frame.dragOverlay:EnableMouse(true)
    frame.dragOverlay:SetFrameLevel(frame:GetFrameLevel() + 10)
end

-- Lock or unlock frame for movement
function Pos:SetLocked(locked)
    if not P.container.dragOverlay then return end
    
    if locked then
        -- Lock frame
        P.container.dragOverlay:EnableMouse(false)
        P.container.dragOverlay.bg:Hide()
        P.container.dragOverlay.header:Hide()
        P.container.dragOverlay.dragText:Hide()
    else
        -- Unlock frame
        P.container.dragOverlay:EnableMouse(true)
        P.container.dragOverlay.bg:Show()
        P.container.dragOverlay.header:Show()
        P.container.dragOverlay.dragText:Show()
    end
    
    -- Update setting
    self.db.position.locked = locked
end

-- Apply saved position to frame
function Pos:ApplyPosition()
    if not P.container or not self.db.position then return end
    
    local pos = self.db.position
    P.container:ClearAllPoints()
    
    -- Handle different anchor frames
    local anchorFrame = _G[pos.anchorFrame] or UIParent
    
    P.container:SetPoint(pos.point, anchorFrame, pos.relativePoint, pos.xOffset, pos.yOffset)
    
    -- Make sure lock state is correct
    self:SetLocked(pos.locked ~= false)
end

-- Save current position
function Pos:SavePosition(frame)
    if not frame or not self.db.position then return end
    
    local pos = self.db.position
    local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
    
    pos.point = point
    pos.relativePoint = relativePoint
    pos.xOffset = xOffset
    pos.yOffset = yOffset
    
    -- Store anchor frame name
    if relativeTo then
        pos.anchorFrame = relativeTo:GetName() or "UIParent"
    else
        pos.anchorFrame = "UIParent"
    end
end

-- Reset position to default
function Pos:ResetPosition()
    if not self.db.position then return end
    
    -- Apply default position
    for k, v in pairs(defaultPosition) do
        self.db.position[k] = v
    end
    
    -- Apply the position
    self:ApplyPosition()
end

-- Toggle lock state
function Pos:ToggleLock()
    if not self.db.position then return end
    
    self:SetLocked(not self.db.position.locked)
end