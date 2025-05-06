local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Font Integration System
-- Enhanced with font atlas, caching, and performance optimizations
VUI.FontIntegration = {}

-- Font cache for optimized memory usage
local fontCache = {}
local fontObjectCache = {}
local fontStats = {
    getCalls = 0,
    cacheHits = 0,
    cacheMisses = 0,
    fontObjectsCreated = 0,
    fontObjectsReused = 0,
    memoryEstimate = 0
}

-- Font atlas system
VUI.FontAtlas = {}

-- Initialize font integration system
function VUI.FontIntegration:Initialize()
    -- Initialize the Font Atlas system
    VUI.FontAtlas:Initialize()
    
    -- Register a callback for theme changes
    VUI.ThemeIntegration:RegisterCallback("FontIntegration", function(theme, themeData)
        self:UpdateFonts(theme)
    end)
    
    -- Initial font update
    self:UpdateFonts()
    
    -- Set update interval to clear font cache
    C_Timer.After(300, function() self:CleanupFontCache() end)
end

-- Update fonts across the addon
function VUI.FontIntegration:UpdateFonts(theme)
    -- Get current font settings
    local fontName = VUI.db.profile.appearance.font or "VUI PT Sans Narrow"
    local fontSize = VUI.db.profile.appearance.fontSize or 12
    
    -- Determine theme-specific font if applicable
    if theme then
        local themeData = VUI:GetTheme(theme)
        if themeData and themeData.fonts and themeData.fonts.primary then
            fontName = themeData.fonts.primary
        end
    end
    
    -- Apply to modules that support font customization
    self:UpdateModuleFonts(fontName, fontSize, theme)
    
    -- Only print notification when called directly, not from theme change
    if not theme then
        VUI:Print("Updated fonts to " .. fontName)
    end
end

-- Clean font cache periodically to free memory
function VUI.FontIntegration:CleanupFontCache(forceFullCleanup)
    -- Count items before cleanup
    local beforeCount = 0
    for _ in pairs(fontObjectCache) do
        beforeCount = beforeCount + 1
    end
    
    -- Clear font objects that haven't been used recently
    local now = GetTime()
    local threshold = forceFullCleanup and 0 or 300 -- 0 seconds for force cleanup, otherwise 5 minutes
    local removed = 0
    
    for key, data in pairs(fontObjectCache) do
        if forceFullCleanup or (now - data.lastUsed > threshold) then
            -- Keep only essential fonts even during forced cleanup
            if forceFullCleanup and data.useCount > 50 then
                -- Keep fonts that are frequently used, but mark them for refresh
                data.lastUsed = now - 240 -- Make them eligible for cleanup soon
            else
                fontObjectCache[key] = nil
                removed = removed + 1
            end
        end
    end
    
    -- Update memory estimate
    local count = 0
    for _ in pairs(fontObjectCache) do
        count = count + 1
    end
    fontStats.memoryEstimate = count * 1024 -- Estimate ~1KB per font object
    
    -- Schedule next cleanup if not forced
    if not forceFullCleanup then
        C_Timer.After(300, function() self:CleanupFontCache() end)
    else
        -- Force garbage collection after a full cleanup
        collectgarbage("collect")
    end
    
    -- Debug info
    if VUI.debug or forceFullCleanup then
        VUI:Debug("Font Integration", "Font cache cleanup: removed " .. removed .. " of " .. beforeCount .. " cached font objects")
    end
    
    return removed, beforeCount
end

-- Get performance statistics
function VUI.FontIntegration:GetStats()
    return fontStats
end

-- Update fonts in modules
function VUI.FontIntegration:UpdateModuleFonts(fontName, fontSize, theme)
    local modules = {
        "chat",
        "detailsskin",
        "msbt",
        "omnicc",
        "tooltip",
        "spellnotifications",
        "buffs",
        "unitframes",
        "actionbars",
        "nameplates"
    }
    
    -- Get font path
    local fontPath = VUI:GetFont(fontName)
    
    -- Update each module
    for _, moduleName in ipairs(modules) do
        if VUI[moduleName] and VUI[moduleName].SetFont then
            VUI[moduleName]:SetFont(fontPath, fontSize, theme)
        end
    end
end

-- Apply a specific font to a frame with caching
function VUI.FontIntegration:ApplyFontToFrame(frame, fontName, fontSize, flags)
    if not frame then return end
    
    local fontPath = VUI:GetFont(fontName)
    fontSize = fontSize or VUI.db.profile.appearance.fontSize or 12
    flags = flags or ""
    
    if frame.SetFont then
        -- Create cache key
        local cacheKey = fontPath .. "_" .. fontSize .. "_" .. flags
        
        -- Check if we have this font object cached
        if fontObjectCache[cacheKey] then
            fontObjectCache[cacheKey].lastUsed = GetTime()
            fontObjectCache[cacheKey].useCount = fontObjectCache[cacheKey].useCount + 1
            fontStats.cacheHits = fontStats.cacheHits + 1
            fontStats.fontObjectsReused = fontStats.fontObjectsReused + 1
        else
            -- Create new cache entry
            fontObjectCache[cacheKey] = {
                path = fontPath,
                size = fontSize,
                flags = flags,
                lastUsed = GetTime(),
                useCount = 1
            }
            fontStats.cacheMisses = fontStats.cacheMisses + 1
            fontStats.fontObjectsCreated = fontStats.fontObjectsCreated + 1
        end
        
        -- Apply the font
        frame:SetFont(fontPath, fontSize, flags)
        fontStats.getCalls = fontStats.getCalls + 1
    end
end

-- Get a cached font object for repeated use
function VUI.FontIntegration:GetFontObject(fontName, fontSize, flags)
    local fontPath = VUI:GetFont(fontName)
    fontSize = fontSize or VUI.db.profile.appearance.fontSize or 12
    flags = flags or ""
    
    -- Create cache key
    local cacheKey = fontPath .. "_" .. fontSize .. "_" .. flags
    
    -- Check if we already have a font object created
    if not fontObjectCache[cacheKey] or not fontObjectCache[cacheKey].fontObject then
        -- Create a new font object
        local fontObject = CreateFont("VUIFont" .. fontStats.fontObjectsCreated)
        fontObject:SetFont(fontPath, fontSize, flags)
        
        -- Cache it
        fontObjectCache[cacheKey] = fontObjectCache[cacheKey] or {}
        fontObjectCache[cacheKey].fontObject = fontObject
        fontObjectCache[cacheKey].path = fontPath
        fontObjectCache[cacheKey].size = fontSize
        fontObjectCache[cacheKey].flags = flags
        fontObjectCache[cacheKey].lastUsed = GetTime()
        fontObjectCache[cacheKey].useCount = 1
        
        fontStats.fontObjectsCreated = fontStats.fontObjectsCreated + 1
        fontStats.cacheMisses = fontStats.cacheMisses + 1
    else
        -- Update usage stats
        fontObjectCache[cacheKey].lastUsed = GetTime()
        fontObjectCache[cacheKey].useCount = fontObjectCache[cacheKey].useCount + 1
        fontStats.cacheHits = fontStats.cacheHits + 1
        fontStats.fontObjectsReused = fontStats.fontObjectsReused + 1
    end
    
    fontStats.getCalls = fontStats.getCalls + 1
    return fontObjectCache[cacheKey].fontObject
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
    
    -- Clear any cached versions of this font
    for key in pairs(fontObjectCache) do
        if key:find(path) then
            fontObjectCache[key] = nil
        end
    end
end

-- Initialize the Font Atlas System
function VUI.FontAtlas:Initialize()
    -- Font collections by type
    self.fonts = {
        header = {},
        normal = {},
        mono = {},
        special = {}
    }
    
    -- Theme-specific fonts
    self.themesFonts = {
        phoenixflame = {
            primary = "Interface\\AddOns\\VUI\\media\\fonts\\phoenixflame\\phoenix.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\phoenixflame\\phoenixheader.ttf"
        },
        thunderstorm = {
            primary = "Interface\\AddOns\\VUI\\media\\fonts\\thunderstorm\\thunder.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\thunderstorm\\thunderheader.ttf"
        },
        arcanemystic = {
            primary = "Interface\\AddOns\\VUI\\media\\fonts\\arcanemystic\\arcane.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\arcanemystic\\arcaneheader.ttf"
        },
        felenergy = {
            primary = "Interface\\AddOns\\VUI\\media\\fonts\\felenergy\\fel.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\felenergy\\felheader.ttf"
        }
    }
    
    -- Register all fonts with the Font Integration system
    self:RegisterAllFonts()
end

-- Register all fonts in the atlas
function VUI.FontAtlas:RegisterAllFonts()
    -- Register theme fonts
    for theme, fonts in pairs(self.themesFonts) do
        for fontType, path in pairs(fonts) do
            local fontName = theme .. "_" .. fontType
            VUI.FontIntegration:RegisterFont(fontName, path)
        end
    end
    
    -- Register standard fonts from media
    for fontName, fontPath in pairs(VUI.media.fonts) do
        -- These are already registered in media.lua, but we track them here too
        self:AddFontToCollection(fontName, fontPath)
    end
end

-- Add a font to the appropriate collection based on its characteristics
function VUI.FontAtlas:AddFontToCollection(fontName, fontPath)
    -- Determine the font category
    if fontName:find("header") or fontName:find("title") or fontName == "morpheus" then
        self.fonts.header[fontName] = fontPath
    elseif fontName:find("mono") or fontName:find("code") then
        self.fonts.mono[fontName] = fontPath
    elseif fontName:find("special") or fontName:find("symbol") then
        self.fonts.special[fontName] = fontPath
    else
        self.fonts.normal[fontName] = fontPath
    end
end

-- Get a theme-specific font
function VUI.FontAtlas:GetThemeFont(theme, fontType)
    if not theme or not fontType then return nil end
    
    -- Check if we have a specific font for this theme and type
    if self.themesFonts[theme] and self.themesFonts[theme][fontType] then
        return self.themesFonts[theme][fontType]
    end
    
    -- Return default font based on type
    if fontType == "header" then
        return VUI.media.fonts.header
    elseif fontType == "primary" or fontType == "normal" then
        return VUI.media.fonts.normal
    elseif fontType == "bold" then
        return VUI.media.fonts.bold
    else
        return VUI.media.fonts.normal
    end
end

-- Hook into VUI initialization
function VUI:InitializeFontIntegration()
    VUI.FontIntegration:Initialize()
end