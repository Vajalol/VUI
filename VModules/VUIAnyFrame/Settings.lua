-- VUIAnyFrame - Settings Handler
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIAnyFrame = _G["VUIAnyFrame"]
local L = VUIAnyFrame.L

-- Default settings that match MoveAny functionality closely
VUIAnyFrame.defaults = {
    profile = {
        enabled = true,
        
        -- Frame settings (position, scale, etc. saved per frame)
        frames = {},
        
        -- Global settings
        global = {
            grid = 10,                   -- Grid size
            snapToGrid = false,          -- Snap to grid when dragging
            lockFrames = true,           -- Lock all frames
            showGrid = false,            -- Show grid when moving frames
            allowScaling = true,         -- Allow frame scaling
            combatLock = true,           -- Lock frames during combat
            hideBlizzardFrames = {
                -- Default frames to hide (will be populated in RegisterWidgets)
                PlayerFrame = false,
                TargetFrame = false,
                MinimapCluster = false, 
                BuffFrame = false,
                ChatFrame1 = false,
                MainMenuBar = false,
                ObjectiveTrackerFrame = false
            }
        },
        
        -- Minimap button
        minimap = {
            hide = false,
            minimapPos = 180
        }
    }
}

-- Initialize settings
function VUIAnyFrame:InitSettings()
    -- Make sure we have our db
    if not self.db or not self.db.profile then
        -- This is a fallback if db wasn't created in OnInitialize
        self.db = LibStub("AceDB-3.0"):New("VUIAnyFrameDB", self.defaults)
    end
    
    -- Ensure settings exist
    if not self.db.profile.global then
        self.db.profile.global = self.defaults.profile.global
    end
    
    if not self.db.profile.frames then
        self.db.profile.frames = {}
    end
    
    -- Update minimap button if available
    if LibStub and LibStub("LibDBIcon-1.0", true) then
        local LDBIcon = LibStub("LibDBIcon-1.0")
        if LDBIcon and LDBIcon.objects["VUIAnyFrame"] then
            LDBIcon:Refresh("VUIAnyFrame", self.db.profile.minimap)
        end
    end
end

-- Save frame settings (position, scale, etc.)
function VUIAnyFrame:SaveFrameSettings(frameName, settings)
    if not frameName or not settings then return end
    
    if not self.db.profile.frames[frameName] then
        self.db.profile.frames[frameName] = {}
    end
    
    -- Update with provided settings
    for k, v in pairs(settings) do
        self.db.profile.frames[frameName][k] = v
    end
end

-- Get frame settings
function VUIAnyFrame:GetFrameSettings(frameName)
    if not frameName then return nil end
    
    return self.db.profile.frames[frameName]
end

-- Reset all frame settings
function VUIAnyFrame:ResetAllFrameSettings()
    self.db.profile.frames = {}
    self:Print("All frame settings have been reset")
    
    -- Apply changes immediately
    self:ApplyAllFrameSettings()
end

-- Toggle a global setting
function VUIAnyFrame:ToggleSetting(settingName)
    if not settingName or not self.db.profile.global[settingName] then return end
    
    self.db.profile.global[settingName] = not self.db.profile.global[settingName]
    
    -- Apply the change
    if settingName == "lockFrames" then
        self:UpdateFrameVisibility()
    elseif settingName == "showGrid" then
        if self.GridFrame then
            if self.db.profile.global.showGrid and not self.db.profile.global.lockFrames then
                self.GridFrame:Show()
            else
                self.GridFrame:Hide()
            end
        end
    end
    
    return self.db.profile.global[settingName]
end

-- Set a global setting to a specific value
function VUIAnyFrame:SetSetting(settingName, value)
    if not settingName then return end
    
    self.db.profile.global[settingName] = value
    
    -- Apply the change for certain settings
    if settingName == "lockFrames" then
        self:UpdateFrameVisibility()
    elseif settingName == "grid" and self.GridFrame then
        -- Recreate grid with new size
        self.GridFrame = nil
        self:UpdateGrid()
        
        if self.db.profile.global.showGrid and not self.db.profile.global.lockFrames then
            self.GridFrame:Show()
        end
    end
    
    return self.db.profile.global[settingName]
end

-- Get a global setting
function VUIAnyFrame:GetSetting(settingName)
    if not settingName then return nil end
    
    return self.db.profile.global[settingName]
end

-- Set blizzard frame visibility
function VUIAnyFrame:SetBlizzardFrameVisibility(frameName, hidden)
    if not frameName then return end
    
    self.db.profile.global.hideBlizzardFrames[frameName] = hidden
    
    -- Apply the visibility change
    local frame = _G[frameName]
    if frame then
        if hidden then
            self:HideFrame(frame, false)
        else
            self:ShowFrame(frame)
        end
    end
end

-- Get blizzard frame visibility
function VUIAnyFrame:GetBlizzardFrameVisibility(frameName)
    if not frameName then return nil end
    
    return self.db.profile.global.hideBlizzardFrames[frameName]
end

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