local _, VUI = ...

-- Font Integration System
VUI.FontIntegration = {}

-- Initialize font integration system
function VUI.FontIntegration:Initialize()
    -- Register a callback for theme changes
    VUI.ThemeIntegration:RegisterCallback("FontIntegration", function(theme, themeData)
        self:UpdateFonts()
    end)
    
    -- Initial font update
    self:UpdateFonts()
end

-- Update fonts across the addon
function VUI.FontIntegration:UpdateFonts()
    -- Get current font settings
    local fontName = VUI.db.profile.appearance.font or "VUI PT Sans Narrow"
    local fontSize = VUI.db.profile.appearance.fontSize or 12
    
    -- Apply to modules that support font customization
    self:UpdateModuleFonts(fontName, fontSize)
    
    -- Notify about font update
    VUI:Print("Updated fonts to " .. fontName)
end

-- Update fonts in modules
function VUI.FontIntegration:UpdateModuleFonts(fontName, fontSize)
    local modules = {
        "chat",
        "detailsskin",
        "msbt",
        "omnicc",
        "tooltip",
        "spellnotifications"
    }
    
    -- Get font path
    local fontPath = VUI:GetFont(fontName)
    
    -- Update each module
    for _, moduleName in ipairs(modules) do
        if VUI[moduleName] and VUI[moduleName].SetFont then
            VUI[moduleName]:SetFont(fontPath, fontSize)
        end
    end
end

-- Apply a specific font to a frame
function VUI.FontIntegration:ApplyFontToFrame(frame, fontName, fontSize, flags)
    if not frame then return end
    
    local fontPath = VUI:GetFont(fontName)
    fontSize = fontSize or VUI.db.profile.appearance.fontSize or 12
    flags = flags or ""
    
    if frame.SetFont then
        frame:SetFont(fontPath, fontSize, flags)
    end
end

-- Register a custom font
function VUI.FontIntegration:RegisterFont(name, path)
    -- Add to VUI media
    VUI.media.fonts[name:lower()] = path
    
    -- Register with LibSharedMedia if available
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        LSM:Register("font", "VUI " .. name, path)
    end
end

-- Hook into VUI initialization
function VUI:InitializeFontIntegration()
    VUI.FontIntegration:Initialize()
end