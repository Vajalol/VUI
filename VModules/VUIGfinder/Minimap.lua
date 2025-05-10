-- VUIGfinder Minimap Button
-- Handles the minimap button with theme integration

local L = PGFinderLocals; -- Strings
local VUI, VUIGfinderModule

-- LibDBIcon reference
local LDBIcon
local minimapButton

-- Initialize the minimap button
function InitializeMinimapButton()
    VUI = _G.VUI
    VUIGfinderModule = VUI and VUI:GetModule("VUIGfinder")
    
    -- Check for LibDataBroker and LibDBIcon
    if not LibStub then return end
    
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then return end
    
    LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDBIcon then return end
    
    -- Create the data broker
    local dataBroker = LDB:NewDataObject("VUIGfinder", {
        type = "launcher",
        text = L.OPTIONS_TITLE,
        icon = "Interface\\AddOns\\VUI\\VModules\\VUIGfinder\\Media\\Icons\\minimap",
        OnClick = function(self, button)
            if button == "LeftButton" then
                if VUIGfinder.ToggleUI then
                    VUIGfinder.ToggleUI()
                end
            elseif button == "RightButton" then
                -- Toggle minimap button visibility for quick access
                if VUIGfinderModule and VUIGfinderModule.db and VUIGfinderModule.db.profile then
                    VUIGfinderModule.db.profile.minimap.hide = not VUIGfinderModule.db.profile.minimap.hide
                    if VUIGfinderModule.db.profile.minimap.hide then
                        LDBIcon:Hide("VUIGfinder")
                    else
                        LDBIcon:Show("VUIGfinder")
                    end
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(L.OPTIONS_TITLE)
            tooltip:AddLine("|cFFFFFFFF" .. L.OPTIONS_AUTHOR .. "|r")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cFF00FF00" .. "Left-click:|r Open VUI Gfinder")
            tooltip:AddLine("|cFF00FF00" .. "Right-click:|r Hide minimap button")
        end,
    })
    
    -- Register the button with LibDBIcon
    LDBIcon:Register("VUIGfinder", dataBroker, VUIGfinderModule.db.profile.minimap)
    
    -- Show or hide based on settings
    if VUIGfinderModule.db.profile.minimap.hide then
        LDBIcon:Hide("VUIGfinder")
    else
        LDBIcon:Show("VUIGfinder")
    end
    
    -- Store reference for theme updates
    minimapButton = LDBIcon:GetMinimapButton("VUIGfinder")
    
    -- Apply VUI theme
    ApplyVUITheme()
    
    -- Register for theme changes
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if VUIGfinderModule.db.profile.theme.useVUITheme then
                ApplyVUITheme()
            end
        end)
    end
end

-- Apply VUI theme to the minimap button
function ApplyVUITheme()
    if not minimapButton then return end
    
    -- Get current theme color
    local r, g, b = 0.0, 0.44, 0.87 -- Default blue
    if VUIGfinder.GetThemeColor then
        r, g, b = VUIGfinder.GetThemeColor()
    end
    
    -- Apply to minimap button border or other elements
    if minimapButton.border then
        minimapButton.border:SetVertexColor(r, g, b, 1)
    end
end

-- Export functions
VUIGfinder.InitializeMinimapButton = InitializeMinimapButton
VUIGfinder.ApplyMinimapTheme = ApplyVUITheme