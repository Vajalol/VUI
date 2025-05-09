-- VUIAnyFrame - Register Widgets
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")
local L = VUIAnyFrame.L

-- Local storage for registered widgets
local registeredWidgets = {}

-- Register a widget for movement
function VUIAnyFrame:RegisterWidget(frameRef, displayName, category)
    if not frameRef then return end
    
    -- If we have a string, convert it to a frame reference
    if type(frameRef) == "string" then
        frameRef = _G[frameRef]
    end
    
    -- Check if we have a valid frame
    if not frameRef or type(frameRef) ~= "table" or not frameRef.SetMovable then
        return
    end
    
    -- Store registered widget info
    registeredWidgets[frameRef:GetName()] = {
        frame = frameRef,
        name = displayName or frameRef:GetName(),
        category = category or "Miscellaneous"
    }
    
    -- Make it movable
    VUIAnyFrame:MakeFrameMovable(frameRef, displayName)
    
    -- Add it to the options panel
    self:AddWidgetToOptions(frameRef, displayName, category)
end

-- Add a widget to the options panel
function VUIAnyFrame:AddWidgetToOptions(frame, displayName, category)
    if not frame or not frame:GetName() then return end
    
    -- For now, just add it to the frames category
    -- In a more complete implementation, we could organize by the category parameter
    local frameName = frame:GetName()
    local name = displayName or frameName
    
    -- Create category if it doesn't exist
    if not self.optionsFrame or not self.optionsFrame.args or not self.optionsFrame.args.frames then
        return
    end
    
    -- Add the frame options
    self.optionsFrame.args.frames.args[frameName] = {
        type = "group",
        name = name,
        args = {
            resetPosition = {
                order = 1,
                type = "execute",
                name = L["Reset Position"],
                func = function() self:ResetFramePosition(frame) end,
                width = "full",
            },
            scale = {
                order = 2,
                type = "range",
                name = L["Scale"],
                min = 0.5,
                max = 2.0,
                step = 0.05,
                get = function() return self.db.profile.frames[frameName] and self.db.profile.frames[frameName].scale or 1.0 end,
                set = function(_, value)
                    if not self.db.profile.frames[frameName] then
                        self.db.profile.frames[frameName] = {}
                    end
                    self.db.profile.frames[frameName].scale = value
                    frame:SetScale(value)
                end,
            },
            alpha = {
                order = 3,
                type = "range",
                name = L["Alpha"],
                min = 0.1,
                max = 1.0,
                step = 0.05,
                get = function() return self.db.profile.frames[frameName] and self.db.profile.frames[frameName].alpha or 1.0 end,
                set = function(_, value)
                    if not self.db.profile.frames[frameName] then
                        self.db.profile.frames[frameName] = {}
                    end
                    self.db.profile.frames[frameName].alpha = value
                    frame:SetAlpha(value)
                end,
            },
            visibility = {
                order = 4,
                type = "toggle",
                name = L["Hide"],
                get = function() return self.db.profile.frames[frameName] and self.db.profile.frames[frameName].hidden end,
                set = function(_, value)
                    if not self.db.profile.frames[frameName] then
                        self.db.profile.frames[frameName] = {}
                    end
                    self.db.profile.frames[frameName].hidden = value
                    
                    if value then
                        self:HideFrame(frame)
                    else
                        self:ShowFrame(frame)
                    end
                end,
            },
            clickthrough = {
                order = 5,
                type = "toggle",
                name = L["Click-through"],
                desc = L["Make this frame click-through (mouse events pass through it)"],
                get = function() return self.db.profile.frames[frameName] and self.db.profile.frames[frameName].clickthrough end,
                set = function(_, value)
                    if not self.db.profile.frames[frameName] then
                        self.db.profile.frames[frameName] = {}
                    end
                    self.db.profile.frames[frameName].clickthrough = value
                    
                    -- Enable/disable mouse interaction
                    if value then
                        frame:EnableMouse(false)
                    else
                        frame:EnableMouse(true)
                    end
                end,
            },
        },
    }
end

-- Return the list of registered widgets
function VUIAnyFrame:GetRegisteredWidgets()
    return registeredWidgets
end

-- Register multiple common UI widgets
function VUIAnyFrame:RegisterCommonWidgets()
    -- This will be populated by each element module
end