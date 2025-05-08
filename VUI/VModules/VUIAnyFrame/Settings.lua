-- VUIAnyFrame - Settings Handler
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Apply all settings to frames
function VUIAnyFrame:ApplySettings()
    -- Skip if disabled
    if not self.db.profile.general.enabled then
        return
    end
    
    -- Apply frame-specific settings
    for frameName, frameSettings in pairs(self.db.profile.frames) do
        local frame = _G[frameName]
        
        if frame then
            -- Apply position
            if frameSettings.position then
                self:ApplySavedPosition(frame)
            end
            
            -- Apply scale
            if frameSettings.scale then
                frame:SetScale(frameSettings.scale)
            end
            
            -- Apply alpha
            if frameSettings.alpha then
                frame:SetAlpha(frameSettings.alpha)
            end
            
            -- Apply visibility
            if frameSettings.hidden then
                self:HideFrame(frame)
            else
                self:ShowFrame(frame)
            end
            
            -- Apply click-through
            if frameSettings.clickthrough then
                frame:EnableMouse(false)
            else
                frame:EnableMouse(true)
            end
        end
    end
end

-- Save a setting for a specific frame
function VUIAnyFrame:SaveFrameSetting(frameName, setting, value)
    if not frameName then return end
    
    -- Create frame settings table if it doesn't exist
    if not self.db.profile.frames[frameName] then
        self.db.profile.frames[frameName] = {}
    end
    
    -- Save the setting
    self.db.profile.frames[frameName][setting] = value
end

-- Get a setting for a specific frame
function VUIAnyFrame:GetFrameSetting(frameName, setting, default)
    if not frameName or not self.db.profile.frames[frameName] then
        return default
    end
    
    return self.db.profile.frames[frameName][setting] or default
end

-- Hook this into the VUIAnyFrame:UpdateAllFrames function
hooksecurefunc(VUIAnyFrame, "UpdateAllFrames", function(self)
    self:ApplySettings()
    self:UpdateFrameVisibility()
end)