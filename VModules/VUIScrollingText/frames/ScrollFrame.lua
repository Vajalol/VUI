-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Scroll Frame
-- Author: Vortex-WoW
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local ST = VUI.ScrollingText
if not ST then return end

-- Local references
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Create a scroll area frame for configuration
function ST.CreateScrollAreaFrame(name, parent)
    -- Create the main frame
    local frame = CreateFrame("Frame", "VUIScrollingText" .. name .. "Frame", parent or UIParent, "BackdropTemplate")
    frame:SetSize(200, 100)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("BACKGROUND")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Update position
        local x, y = self:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        x = x - parentX
        y = y - parentY
        
        -- Update scroll area settings
        if ST.scrollAreas[name] then
            ST.scrollAreas[name].positionX = x
            ST.scrollAreas[name].positionY = y
        end
    end)
    
    -- Set frame appearance
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Add VUI theme support
    frame.useVUITheme = true
    frame.UpdateTheme = function(self)
        if not VUI or not VUI.GetThemeColor then return end
        local themeColor = VUI:GetThemeColor()
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    end
    
    -- Create title text
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -8)
    title:SetText(name)
    
    -- Create drag instruction text
    local instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    instructions:SetPoint("BOTTOM", 0, 8)
    instructions:SetText("Drag to position")
    
    -- Store references for theme updates
    if ST.themeElements then
        table.insert(ST.themeElements, {frame = frame, type = "scrollframe"})
    end
    
    return frame
end

-- Apply VUI theme to all scroll frames
function ST.UpdateScrollFrameThemes()
    if not VUI or not VUI.GetThemeColor then return end
    
    for name, scrollArea in pairs(ST.scrollAreas or {}) do
        local frame = _G["VUIScrollingText" .. name .. "Frame"]
        if frame and frame.UpdateTheme then
            frame:UpdateTheme()
        end
    end
end

-- Register with theme system
if VUI and VUI.RegisterCallback then
    VUI:RegisterCallback("OnThemeChanged", function()
        ST.UpdateScrollFrameThemes()
    end)
end