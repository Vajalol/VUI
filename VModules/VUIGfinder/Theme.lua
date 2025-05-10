-- VUIGfinder Theme Integration
-- Handles theme color integration with VUI

local VUI, VUIGfinderModule
local L = PGFinderLocals; -- Strings

-- Theme elements that need to be updated
local themeElements = {}

-- Get current theme color
function VUIGfinder.GetThemeColor()
    if VUIGfinderModule and VUIGfinderModule.db.profile.theme.useVUITheme then
        local color = VUI and VUI:GetThemeColor() or {r=0.0, g=0.44, b=0.87}
        return color.r, color.g, color.b
    else
        -- Default PGFinder blue if not using VUI theme
        return 0.0, 0.44, 0.87
    end
end

-- Apply theme color to an element
local function ApplyThemeToElement(element, r, g, b)
    if not element then return end
    
    if element.SetColorTexture then
        element:SetColorTexture(r, g, b)
    elseif element.SetTextColor then
        element:SetTextColor(r, g, b)
    elseif element.SetVertexColor then
        element:SetVertexColor(r, g, b)
    elseif element.GetNormalTexture and element:GetNormalTexture() then
        element:GetNormalTexture():SetVertexColor(r, g, b)
    end
end

-- Register an element to be themed
function VUIGfinder.RegisterThemeElement(element)
    if element then
        table.insert(themeElements, element)
        -- Apply theme immediately
        ApplyThemeToElement(element, VUIGfinder.GetThemeColor())
    end
end

-- Refresh all themed elements
function VUIGfinder.RefreshTheme()
    local r, g, b = VUIGfinder.GetThemeColor()
    
    for _, element in ipairs(themeElements) do
        ApplyThemeToElement(element, r, g, b)
    end
    
    -- Fire an event for other parts of the addon to respond to
    if VUIGfinder.OnThemeChanged then
        VUIGfinder.OnThemeChanged(r, g, b)
    end
end

-- Initialize theme support
function InitializeThemeSupport()
    VUI = _G.VUI
    VUIGfinderModule = VUI:GetModule("VUIGfinder")
    
    -- Set up callback when theme changes
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if VUIGfinderModule.db.profile.theme.useVUITheme then
                VUIGfinder.RefreshTheme()
            end
        end)
    end
end