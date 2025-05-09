-- VUIAnyFrame - Frame Movement Handler
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Local storage
local movedFrames = {}
local savedFrameInfo = {}
local dragFrame = nil

-- Function to create a drag frame
function VUIAnyFrame:CreateDragFrame(frame, name)
    if not frame or movedFrames[frame] then return end
    
    -- Create a frame to handle the dragging
    local moveFrame = CreateFrame("Frame", nil, frame)
    moveFrame:SetAllPoints(frame)
    moveFrame:SetFrameStrata("DIALOG")
    
    -- Make it visible when dragging
    moveFrame.texture = moveFrame:CreateTexture(nil, "OVERLAY")
    moveFrame.texture:SetAllPoints(moveFrame)
    moveFrame.texture:SetColorTexture(VUIAnyFrame:GetColor("el"))
    moveFrame.texture:SetAlpha(0.3)
    
    -- Add name text
    moveFrame.text = moveFrame:CreateFontString(nil, "OVERLAY")
    moveFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    moveFrame.text:SetPoint("TOP", moveFrame, "TOP", 0, 15)
    moveFrame.text:SetText(name or frame:GetName() or "Unknown Frame")
    
    -- Make it draggable
    moveFrame:EnableMouse(true)
    moveFrame:SetMovable(true)
    
    -- Add mouse handlers
    moveFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not VUIAnyFrame.db.profile.general.lockFrames then
            frame:StartMoving()
            self.isMoving = true
        elseif button == "RightButton" then
            VUIAnyFrame:OpenFrameOptions(frame)
        end
    end)
    
    moveFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            frame:StopMovingOrSizing()
            self.isMoving = false
            
            -- Save the position
            local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
            
            if not VUIAnyFrame.db.profile.frames[frame:GetName()] then
                VUIAnyFrame.db.profile.frames[frame:GetName()] = {}
            end
            
            VUIAnyFrame.db.profile.frames[frame:GetName()].position = {
                point = point,
                relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
                relativePoint = relativePoint,
                xOfs = xOfs,
                yOfs = yOfs
            }
        end
    end)
    
    moveFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("VUI AnyFrame")
        GameTooltip:AddLine(name or frame:GetName() or "Unknown Frame", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Left-click to move"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["Right-click for options"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["Ctrl+click to reset position"], 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    
    moveFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Initially hide the frame
    moveFrame:Hide()
    
    -- Add to saved frame list
    movedFrames[frame] = moveFrame
    
    -- Return the created frame
    return moveFrame
end

-- Function to make a frame movable
function VUIAnyFrame:MakeFrameMovable(frame, name)
    if not frame or type(frame) ~= "table" or not frame.SetMovable then
        return false
    end
    
    -- Check if we've already processed this frame
    if movedFrames[frame] then
        return true
    end
    
    -- Make the frame movable
    frame:SetMovable(true)
    
    -- Create the drag frame
    local dragFrame = self:CreateDragFrame(frame, name)
    
    -- Add to managed frames list
    savedFrameInfo[frame:GetName()] = {
        frame = frame,
        dragFrame = dragFrame,
        name = name
    }
    
    -- Apply saved position if any
    self:ApplySavedPosition(frame)
    
    return true
end

-- Apply a saved position to a frame
function VUIAnyFrame:ApplySavedPosition(frame)
    if not frame or not frame:GetName() then return end
    
    local name = frame:GetName()
    local savedPos = self.db.profile.frames[name] and self.db.profile.frames[name].position
    
    if savedPos then
        frame:ClearAllPoints()
        
        -- Handle the relativeTo reference
        local relTo = savedPos.relativeTo == "UIParent" and UIParent or _G[savedPos.relativeTo]
        
        if relTo then
            frame:SetPoint(savedPos.point, relTo, savedPos.relativePoint, savedPos.xOfs, savedPos.yOfs)
        else
            -- Fallback if the relative frame doesn't exist
            frame:SetPoint(savedPos.point, UIParent, savedPos.relativePoint, savedPos.xOfs, savedPos.yOfs)
        end
    end
end

-- Reset a frame's position
function VUIAnyFrame:ResetFramePosition(frame)
    if not frame or not frame:GetName() then return end
    
    local name = frame:GetName()
    
    if self.db.profile.frames[name] then
        self.db.profile.frames[name].position = nil
    end
    
    -- You might need custom code here to set specific frames back to their default positions
    -- For now, we just clear points and let the game position it
    frame:ClearAllPoints()
    -- Let the original OnShow/etc handlers reposition it
    
    VUIAnyFrame:Print(name .. " position has been reset")
end

-- Update frame visibility based on lock state
function VUIAnyFrame:UpdateFrameVisibility()
    for frame, moveFrame in pairs(movedFrames) do
        if self.db.profile.general.lockFrames then
            moveFrame:Hide()
        else
            moveFrame:Show()
        end
    end
end

-- Open options for a specific frame
function VUIAnyFrame:OpenFrameOptions(frame)
    if not frame or not frame:GetName() then return end
    
    -- This function would show a specialized options panel for this specific frame
    -- For now, we'll just open the general options
    self:OpenOptions()
end