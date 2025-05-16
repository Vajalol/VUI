-- VUIGfinder Minimap Button
-- Handles the minimap button with theme integration

-- Create global aliases for backward compatibility
_G.VUIFinder = _G.VUIFinder or _G.VUIGfinder or {}
_G.VUIGfinder = _G.VUIGfinder or {}

local L = PGFinderLocals or {}; -- Strings with fallback
local VUI, VUIGfinderModule

-- LibDBIcon reference
local LDBIcon
local minimapButton

-- Initialize the minimap button
function InitializeMinimapButton()
    VUI = _G.VUI
    
    -- Try to get the module, but handle the case where it doesn't exist
    if VUI then
        local success, module = pcall(function() return VUI.GetModule and VUI:GetModule("VUIGfinder") end)
        if success and module then
            VUIGfinderModule = module
        else
            VUIGfinderModule = {
                db = {
                    profile = {
                        minimap = { hide = false },
                        theme = { useVUITheme = true }
                    }
                }
            }
        end
    end
    
    -- Check for LibDataBroker and LibDBIcon
    if not LibStub then return end
    
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then return end
    
    LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDBIcon then return end
    
    -- Create the data broker
    local dataBroker = LDB:NewDataObject("VUIGfinder", {
        type = "launcher",
        text = L.OPTIONS_TITLE or "VUI Group Finder",
        icon = "Interface\\AddOns\\VUI\\VModules\\VUIGfinder\\Media\\Icons\\minimap",
        OnClick = function(self, button)
            if button == "LeftButton" then
                if VUIGfinder and VUIGfinder.ToggleUI then
                    VUIGfinder.ToggleUI()
                end
            elseif button == "RightButton" then
                -- Toggle minimap button visibility for quick access
                if VUIGfinderModule and VUIGfinderModule.db and 
                   VUIGfinderModule.db.profile and 
                   VUIGfinderModule.db.profile.minimap then
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
            if not tooltip then return end
            tooltip:AddLine(L.OPTIONS_TITLE or "VUI Group Finder")
            tooltip:AddLine("|cFFFFFFFF" .. (L.OPTIONS_AUTHOR or "Vortex UI") .. "|r")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cFF00FF00" .. "Left-click:|r Open VUI Gfinder")
            tooltip:AddLine("|cFF00FF00" .. "Right-click:|r Hide minimap button")
        end,
    })
    
    -- Get minimap settings with fallback
    local minimapSettings = (VUIGfinderModule and VUIGfinderModule.db and 
                           VUIGfinderModule.db.profile and 
                           VUIGfinderModule.db.profile.minimap) or { hide = false }
    
    -- Register the button with LibDBIcon
    LDBIcon:Register("VUIGfinder", dataBroker, minimapSettings)
    
    -- Show or hide based on settings
    if minimapSettings.hide then
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
            if VUIGfinderModule and VUIGfinderModule.db and 
               VUIGfinderModule.db.profile and 
               VUIGfinderModule.db.profile.theme and 
               VUIGfinderModule.db.profile.theme.useVUITheme then
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
    if VUIGfinder and VUIGfinder.GetThemeColor then
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

-- Also make them available through VUIFinder namespace for backward compatibility
_G.VUIFinder = _G.VUIFinder or {}
_G.VUIFinder.InitializeMinimapButton = InitializeMinimapButton
_G.VUIFinder.ApplyMinimapTheme = ApplyVUITheme