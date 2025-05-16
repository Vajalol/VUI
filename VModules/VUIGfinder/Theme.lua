-- VUIGfinder Theme Integration
-- Handles theme color integration with VUI

-- Create global aliases for backward compatibility
_G.VUIFinder = _G.VUIFinder or _G.VUIGfinder or {}
_G.VUIGfinder = _G.VUIGfinder or {}

local VUI = _G.VUI
local VUIGfinderModule
local L = PGFinderLocals or {}; -- Strings with fallback

-- Theme elements that need to be updated
local themeElements = {}

-- Get current theme color
function VUIGfinder.GetThemeColor()
    -- Safety checks for nil values
    if not VUIGfinderModule then
        -- Default PGFinder blue if module isn't available
        return 0.0, 0.44, 0.87
    end
    
    -- Check for db and profile existence
    if not VUIGfinderModule.db or not VUIGfinderModule.db.profile then
        return 0.0, 0.44, 0.87
    end
    
    -- Check for theme settings
    if not VUIGfinderModule.db.profile.theme then
        VUIGfinderModule.db.profile.theme = {useVUITheme = true}
    end
    
    -- Now check if we should use the VUI theme
    if VUIGfinderModule.db.profile.theme.useVUITheme then
        -- Safely get theme color from VUI
        if VUI and VUI.GetThemeColor and type(VUI.GetThemeColor) == "function" then
            local success, color = pcall(function() return VUI:GetThemeColor() end)
            if success and color and color.r and color.g and color.b then
                return color.r, color.g, color.b
            end
        end
    end
    
    -- Default PGFinder blue if all else fails
    return 0.0, 0.44, 0.87
end

-- Apply theme color to an element
local function ApplyThemeToElement(element, r, g, b)
    if not element then return end
    
    -- Add safety pcall to prevent errors when setting colors
    pcall(function()
        if element.SetColorTexture then
            element:SetColorTexture(r, g, b)
        elseif element.SetTextColor then
            element:SetTextColor(r, g, b)
        elseif element.SetVertexColor then
            element:SetVertexColor(r, g, b)
        elseif element.GetNormalTexture and element:GetNormalTexture() then
            element:GetNormalTexture():SetVertexColor(r, g, b)
        end
    end)
end

-- Register an element to be themed
function VUIGfinder.RegisterThemeElement(element)
    if element then
        table.insert(themeElements, element)
        -- Apply theme immediately
        local r, g, b = VUIGfinder.GetThemeColor()
        ApplyThemeToElement(element, r, g, b)
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
local function InitializeThemeSupport()
    VUI = _G.VUI
    if not VUI then 
        -- Create a minimal fallback for VUIGfinderModule if VUI isn't available
        VUIGfinderModule = {
            db = {
                profile = {
                    theme = {useVUITheme = true}
                }
            }
        }
        return 
    end
    
    -- Try to get the module, but handle the case where it doesn't exist
    local success, module = pcall(function() 
        return VUI.GetModule and VUI:GetModule("VUIGfinder") 
    end)
    
    if success and module then
        VUIGfinderModule = module
    else
        -- Create a minimal fallback if the module doesn't exist
        VUIGfinderModule = {
            db = {
                profile = {
                    theme = {useVUITheme = true}
                }
            }
        }
    end
    
    -- Ensure module DB and theme settings exist
    if not VUIGfinderModule.db then
        VUIGfinderModule.db = {profile = {theme = {useVUITheme = true}}}
    elseif not VUIGfinderModule.db.profile then
        VUIGfinderModule.db.profile = {theme = {useVUITheme = true}}
    elseif not VUIGfinderModule.db.profile.theme then
        VUIGfinderModule.db.profile.theme = {useVUITheme = true}
    end
    
    -- Set up callback when theme changes
    if VUI and VUI.RegisterCallback and type(VUI.RegisterCallback) == "function" then
        pcall(function()
            VUI:RegisterCallback("OnThemeChanged", function()
                -- Add safety checks
                if not VUIGfinderModule or not VUIGfinderModule.db then return end
                if not VUIGfinderModule.db.profile then return end
                if not VUIGfinderModule.db.profile.theme then return end
                
                if VUIGfinderModule.db.profile.theme.useVUITheme then
                    if VUIGfinder and VUIGfinder.RefreshTheme then
                        VUIGfinder.RefreshTheme()
                    end
                end
            end)
        end)
    end
end

-- Export the function
VUIGfinder.InitializeThemeSupport = InitializeThemeSupport