-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Animation Styles
-- Author: VortexQ8
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local ST = VUI.ScrollingText
if not ST then return end

-- Animation style data
local ANIMATION_STYLE_DATA = {}

-- Flag indicating if styles have been registered
local stylesRegistered = false

-- Event types
local INCOMING_PERIPHERAL_EVENT = "INCOMING_PERIPHERAL"
local INCOMING_EVENT = "INCOMING"
local OUTGOING_EVENT = "OUTGOING"

-------------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------------

-- Register available animation styles.
local function RegisterStyles()
    -- Don't register the styles more than once.
    if stylesRegistered then return end 
    
    -- Normal style.
    ANIMATION_STYLE_DATA["Normal"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 260, scrollWidth = 40, 
                                        behavior = ST.BEHAVIOR_SCROLL, textAlign = ST.ALIGN_RIGHT }
    }
    
    -- Static style.
    ANIMATION_STYLE_DATA["Static"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_UP, scrollHeight = 0, scrollWidth = 300, 
                                        behavior = ST.BEHAVIOR_STATIC, textAlign = ST.ALIGN_CENTER }
    }
    
    -- Angled style.
    ANIMATION_STYLE_DATA["Angled"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 300, scrollWidth = 300, 
                                        behavior = ST.BEHAVIOR_SCROLL, textAlign = ST.ALIGN_RIGHT }
    }
    
    -- Horizontal style.
    ANIMATION_STYLE_DATA["Horizontal"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 0, scrollWidth = 300, 
                                        behavior = ST.BEHAVIOR_SCROLL, textAlign = ST.ALIGN_RIGHT }
    }

    -- Parabola style.  
    ANIMATION_STYLE_DATA["Parabola"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 260, scrollWidth = 260, 
                                        behavior = ST.BEHAVIOR_PARABOLA, textAlign = ST.ALIGN_RIGHT }
    }
    
    -- Straight style.
    ANIMATION_STYLE_DATA["Straight"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 0, scrollWidth = 260, 
                                        behavior = ST.BEHAVIOR_STRAIGHT, textAlign = ST.ALIGN_RIGHT }
    }
    
    -- Threshold style.
    ANIMATION_STYLE_DATA["Threshold"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 260, scrollWidth = 40, 
                                        behavior = ST.BEHAVIOR_SCROLL, textAlign = ST.ALIGN_RIGHT, thresholdStyle = true }
    }

    -- Custom style for VUI theme integration
    ANIMATION_STYLE_DATA["VUIThemed"] = {
        [INCOMING_PERIPHERAL_EVENT] = { scrollDirection = ST.SCROLL_RIGHT, scrollHeight = 260, scrollWidth = 300, 
                                       behavior = ST.BEHAVIOR_SCROLL, textAlign = ST.ALIGN_RIGHT, useThemeColor = true }
    }
    
    -- Set the flag indicating that the styles have been registered.
    stylesRegistered = true
end


-- ****************************************************************************
-- Returns an animation style data object for the passed name.
-- ****************************************************************************
local function GetStyleData(styleName)
    -- Register the styles if they haven't been registered yet.
    RegisterStyles()
    
    return ANIMATION_STYLE_DATA[styleName]
end


-- ****************************************************************************
-- Returns a list of available animation style names.
-- ****************************************************************************
local function GetAvailableStyles()
    -- Register the styles if they haven't been registered yet.
    RegisterStyles()
    
    local names = {}
    for k in pairs(ANIMATION_STYLE_DATA) do
        names[#names + 1] = k
    end
    table.sort(names)
    return names
end


-- ****************************************************************************
-- Applies VUI theme to animations when theme changes
-- ****************************************************************************
local function ApplyTheme()
    -- Update any active animations that use the theme color
    if ST.scrollAreas then
        for _, scrollArea in pairs(ST.scrollAreas) do
            if scrollArea.animationStyleSettings and scrollArea.animationStyleSettings.useThemeColor then
                local r, g, b = VUI:GetThemeColor().r, VUI:GetThemeColor().g, VUI:GetThemeColor().b
                -- Update any active animations with the new color
                if scrollArea.frames then
                    for _, frame in pairs(scrollArea.frames) do
                        if frame.fontString then
                            frame.fontString:SetTextColor(r, g, b)
                        end
                    end
                end
            end
        end
    end
end


-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Module public interface
ST.AnimationStyles = {
    RegisterStyles = RegisterStyles,
    GetStyleData = GetStyleData,
    GetAvailableStyles = GetAvailableStyles,
    ApplyTheme = ApplyTheme,
}

-- Register with theme system
if VUI.RegisterCallback then
    VUI:RegisterCallback("OnThemeChanged", function()
        ApplyTheme()
    end)
end