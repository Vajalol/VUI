--[[
    VUI - BuffOverlay Enhanced Display
    Version: 0.2.0
    Author: VortexQ8
    
    This file implements enhanced visibility options for the BuffOverlay module:
    - High-contrast borders and background
    - Aura category-based coloring
    - Customizable glow effects based on importance
    - Dynamic scaling based on aura importance
    - Fade-in/fade-out animations
    - Text clarity enhancements
    - Configurable filtering and visibility options
]]

local addonName, VUI = ...

if not VUI.modules.buffoverlay then return end

-- Namespaces
local BuffOverlay = VUI.modules.buffoverlay
BuffOverlay.EnhancedDisplay = {}

-- Import frequently used globals into locals for performance
local CreateFrame = CreateFrame
local UnitAura = UnitAura
local GetTime = GetTime
local abs = math.abs
local min, max = math.min, math.max
local tinsert, tremove = table.insert, table.remove

-- Defaults for enhanced display settings
local enhancedDisplayDefaults = {
    enabled = true,
    highContrast = false,
    categoryColoring = true,
    importantGlow = true,
    dynamicScale = true,
    fadeAnimations = true,
    textEnhancements = true,
    scaleImportantAuras = true,
    minScale = 0.8,
    maxScale = 1.2,
    filterOptions = {
        showBuffs = true,
        showDebuffs = true,
        showSelfCast = true,
        showOthersCast = true,
        filterDispellable = false,
        onlyShowDispellable = false,
        minDuration = 0,
        maxDuration = 600,
    },
    categoryColors = {
        magic = {0.2, 0.6, 1.0, 1.0},
        curse = {0.6, 0.0, 1.0, 1.0},
        disease = {0.6, 0.4, 0.0, 1.0},
        poison = {0.0, 0.6, 0.0, 1.0},
        physical = {1.0, 0.0, 0.0, 1.0},
        none = {0.5, 0.5, 0.5, 1.0},
        enrage = {1.0, 0.5, 0.0, 1.0},
        buff = {0.0, 1.0, 0.0, 1.0},
        importantBuff = {0.2, 1.0, 0.8, 1.0},
        importantDebuff = {1.0, 0.2, 0.2, 1.0},
    },
    borderThickness = 1,
    glowIntensity = 0.8,
    countTextScale = 1.1,
    countTextOutlineThickness = 1.5,
    durationTextScale = 0.9,
    durationTextOutlineThickness = 1.0,
    glowSize = 2,
    auraOpacity = 1.0,
    showCountText = true,
    showDurationText = true,
    countTextYOffset = 0,
    durationTextYOffset = -14,
    glowStyle = "default", -- Options: default, pulse, border
}

-- Initialize enhanced display module
function BuffOverlay:InitializeEnhancedDisplay()
    -- Register defaults if not already registered
    VUI.db.profile.modules.buffoverlay.enhancedDisplay = VUI.db.profile.modules.buffoverlay.enhancedDisplay or enhancedDisplayDefaults
    
    -- Update any missing fields (for version compatibility)
    for k, v in pairs(enhancedDisplayDefaults) do
        if VUI.db.profile.modules.buffoverlay.enhancedDisplay[k] == nil then
            VUI.db.profile.modules.buffoverlay.enhancedDisplay[k] = v
        end
        
        -- If it's a table, update any missing nested fields
        if type(v) == "table" and type(VUI.db.profile.modules.buffoverlay.enhancedDisplay[k]) == "table" then
            for nestedKey, nestedValue in pairs(v) do
                if VUI.db.profile.modules.buffoverlay.enhancedDisplay[k][nestedKey] == nil then
                    VUI.db.profile.modules.buffoverlay.enhancedDisplay[k][nestedKey] = nestedValue
                end
            end
        end
    end
    
    -- Register options for the configuration UI
    self:RegisterEnhancedDisplayOptions()
    
    -- Log initialization
    if VUI.debug then
        VUI:Debug("BuffOverlay Enhanced Display initialized")
    end
end

-- Apply enhanced display effects to a frame
function BuffOverlay:ApplyEnhancedDisplayToFrame(frame, auraInfo)
    local settings = VUI.db.profile.modules.buffoverlay.enhancedDisplay
    
    -- Skip if enhanced display is disabled
    if not settings.enabled then return end
    
    -- Apply high contrast if enabled
    if settings.highContrast then
        frame.icon:SetDesaturated(false)
        frame.icon:SetVertexColor(1, 1, 1, settings.auraOpacity)
        
        -- Increase border thickness for better visibility
        frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -settings.borderThickness, settings.borderThickness)
        frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", settings.borderThickness, -settings.borderThickness)
    end
    
    -- Apply category coloring if enabled
    if settings.categoryColoring and auraInfo and auraInfo.dispelType then
        local colorKey = auraInfo.dispelType
        
        -- Handle special cases
        if auraInfo.isDebuff and auraInfo.isImportant then
            colorKey = "importantDebuff"
        elseif not auraInfo.isDebuff and auraInfo.isImportant then
            colorKey = "importantBuff"
        elseif not auraInfo.isDebuff then
            colorKey = "buff"
        end
        
        -- Set border color based on category
        local color = settings.categoryColors[colorKey] or settings.categoryColors.none
        frame.border:SetVertexColor(unpack(color))
    end
    
    -- Apply glow effect for important auras if enabled
    if settings.importantGlow and auraInfo and auraInfo.isImportant then
        -- Set the glow texture and make it visible
        frame.glow:SetAlpha(settings.glowIntensity)
        frame.glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -settings.glowSize, settings.glowSize)
        frame.glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", settings.glowSize, -settings.glowSize)
        
        -- Apply glow style
        if settings.glowStyle == "pulse" then
            -- Create pulse animation if it doesn't exist
            if not frame.pulseAnim then
                frame.pulseAnim = frame:CreateAnimationGroup()
                frame.pulseAnim:SetLooping("REPEAT")
                
                local fadeOut = frame.pulseAnim:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(settings.glowIntensity)
                fadeOut:SetToAlpha(settings.glowIntensity * 0.4)
                fadeOut:SetDuration(0.8)
                fadeOut:SetSmoothing("IN_OUT")
                fadeOut:SetOrder(1)
                
                local fadeIn = frame.pulseAnim:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(settings.glowIntensity * 0.4)
                fadeIn:SetToAlpha(settings.glowIntensity)
                fadeIn:SetDuration(0.8)
                fadeIn:SetSmoothing("IN_OUT")
                fadeIn:SetOrder(2)
            end
            
            frame.pulseAnim:Play()
        elseif settings.glowStyle == "border" then
            -- Use border glow instead of full glow
            frame.glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
            frame.glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
        end
        
        frame.glow:Show()
    else
        if frame.pulseAnim then
            frame.pulseAnim:Stop()
        end
        frame.glow:Hide()
    end
    
    -- Apply dynamic scaling for important auras if enabled
    if settings.dynamicScale and settings.scaleImportantAuras and auraInfo and auraInfo.isImportant then
        local importance = auraInfo.importance or 0
        local maxImportance = 150  -- Defined max importance in GetSpellImportance
        local scaleFactor = settings.minScale + ((importance / maxImportance) * (settings.maxScale - settings.minScale))
        
        -- Ensure scale stays within bounds
        scaleFactor = max(settings.minScale, min(settings.maxScale, scaleFactor))
        
        -- Apply scale to the frame
        frame:SetScale(scaleFactor)
    else
        -- Reset to normal scale
        frame:SetScale(1.0)
    end
    
    -- Apply text enhancements if enabled
    if settings.textEnhancements then
        -- Enhance count text
        if frame.count and settings.showCountText then
            local font, size, flags = frame.count:GetFont()
            frame.count:SetFont(font, size * settings.countTextScale, "OUTLINE")
            frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, settings.countTextYOffset)
            frame.count:SetTextColor(1, 1, 1, 1)
            
            -- Add a shadow for better visibility
            if not frame.count.shadow then
                frame.count.shadow = frame:CreateFontString(nil, "OVERLAY")
                frame.count.shadow:SetFont(font, size * settings.countTextScale, "OUTLINE")
                frame.count.shadow:SetPoint("BOTTOMRIGHT", frame.count, "BOTTOMRIGHT", 1, -1)
                frame.count.shadow:SetTextColor(0, 0, 0, 0.8)
            end
            
            frame.count.shadow:SetText(frame.count:GetText())
            frame.count.shadow:Show()
        elseif frame.count then
            frame.count:Hide()
            if frame.count.shadow then
                frame.count.shadow:Hide()
            end
        end
        
        -- Enhance duration text
        if frame.duration and settings.showDurationText then
            local font, size, flags = frame.duration:GetFont()
            frame.duration:SetFont(font, size * settings.durationTextScale, "OUTLINE")
            frame.duration:SetPoint("TOP", frame, "BOTTOM", 0, settings.durationTextYOffset)
            frame.duration:SetTextColor(1, 1, 1, 1)
            
            -- Add a shadow for better visibility
            if not frame.duration.shadow then
                frame.duration.shadow = frame:CreateFontString(nil, "OVERLAY")
                frame.duration.shadow:SetFont(font, size * settings.durationTextScale, "OUTLINE")
                frame.duration.shadow:SetPoint("TOP", frame.duration, "TOP", 1, -1)
                frame.duration.shadow:SetTextColor(0, 0, 0, 0.8)
            end
            
            frame.duration.shadow:SetText(frame.duration:GetText())
            frame.duration.shadow:Show()
        elseif frame.duration then
            frame.duration:Hide()
            if frame.duration.shadow then
                frame.duration.shadow:Hide()
            end
        end
    end
    
    -- Apply fade animations if enabled
    if settings.fadeAnimations and not frame.fadeAnim then
        frame.fadeAnim = frame:CreateAnimationGroup()
        
        -- Fade in animation
        local fadeIn = frame.fadeAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.3)
        fadeIn:SetOrder(1)
        
        -- Trigger immediate play of fade in
        frame.fadeAnim:Play()
    end
end

-- Filter auras based on enhanced display settings
function BuffOverlay:FilterAuraWithEnhancedDisplay(auraInfo)
    local settings = VUI.db.profile.modules.buffoverlay.enhancedDisplay
    
    -- Skip filtering if enhanced display is disabled
    if not settings.enabled then return true end
    
    local filterOptions = settings.filterOptions
    
    -- Check aura type (buff/debuff)
    if auraInfo.isDebuff and not filterOptions.showDebuffs then
        return false
    elseif not auraInfo.isDebuff and not filterOptions.showBuffs then
        return false
    end
    
    -- Check caster
    if auraInfo.isMine and not filterOptions.showSelfCast then
        return false
    elseif not auraInfo.isMine and not filterOptions.showOthersCast then
        return false
    end
    
    -- Check dispellable status
    if filterOptions.filterDispellable then
        if filterOptions.onlyShowDispellable and not auraInfo.isDispellable then
            return false
        end
    end
    
    -- Check duration bounds
    if auraInfo.duration and auraInfo.duration > 0 then
        if auraInfo.duration < filterOptions.minDuration then
            return false
        end
        if filterOptions.maxDuration > 0 and auraInfo.duration > filterOptions.maxDuration then
            return false
        end
    end
    
    -- Passed all filters
    return true
end

-- Register configuration options for enhanced display
function BuffOverlay:RegisterEnhancedDisplayOptions()
    -- Add to the module's options table when it's generated
    local originalGetOptions = self.GetOptions
    
    self.GetOptions = function(self)
        local options = originalGetOptions and originalGetOptions(self) or {}
        
        -- Ensure we have args table
        options.args = options.args or {}
        
        -- Add enhanced display section
        options.args.enhancedDisplayHeader = {
            type = "header",
            name = "Enhanced Visibility Options",
            order = 50
        }
        
        options.args.enhancedDisplayEnabled = {
            type = "toggle",
            name = "Enable Enhanced Display",
            desc = "Toggle advanced visibility enhancements for buffs and debuffs",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            width = "full",
            order = 51
        }
        
        -- Category coloring option
        options.args.categoryColoring = {
            type = "toggle",
            name = "Category Coloring",
            desc = "Color buff/debuff borders based on their type (magic, poison, curse, etc.)",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.categoryColoring end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.categoryColoring = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 52
        }
        
        -- High contrast option
        options.args.highContrast = {
            type = "toggle",
            name = "High Contrast Mode",
            desc = "Increase contrast for better visibility of buff/debuff icons",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.highContrast end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.highContrast = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 53
        }
        
        -- Important aura glow effect
        options.args.importantGlow = {
            type = "toggle",
            name = "Important Aura Glow",
            desc = "Add a glow effect to important buffs and debuffs",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.importantGlow end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.importantGlow = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 54
        }
        
        -- Glow style options
        options.args.glowStyle = {
            type = "select",
            name = "Glow Style",
            desc = "Choose the style of glow effect for important auras",
            values = {
                default = "Full Glow",
                pulse = "Pulsing Effect",
                border = "Border Glow"
            },
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.glowStyle end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.glowStyle = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() 
                return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled or 
                       not VUI.db.profile.modules.buffoverlay.enhancedDisplay.importantGlow 
            end,
            width = "full",
            order = 55
        }
        
        -- Dynamic scaling option
        options.args.dynamicScale = {
            type = "toggle",
            name = "Dynamic Scaling",
            desc = "Scale auras based on their importance",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.dynamicScale end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.dynamicScale = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 56
        }
        
        -- Text enhancements option
        options.args.textEnhancements = {
            type = "toggle",
            name = "Text Clarity",
            desc = "Enhance text visibility for stack count and duration",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.textEnhancements end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.textEnhancements = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 57
        }
        
        -- Fade animations option
        options.args.fadeAnimations = {
            type = "toggle",
            name = "Fade Animations",
            desc = "Enable fade-in/fade-out animations for auras",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.fadeAnimations end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.fadeAnimations = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 58
        }
        
        -- Filter options header
        options.args.filterOptionsHeader = {
            type = "header",
            name = "Filtering Options",
            order = 60
        }
        
        -- Show buffs option
        options.args.showBuffs = {
            type = "toggle",
            name = "Show Buffs",
            desc = "Show beneficial effects",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showBuffs end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showBuffs = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "half",
            order = 61
        }
        
        -- Show debuffs option
        options.args.showDebuffs = {
            type = "toggle",
            name = "Show Debuffs",
            desc = "Show harmful effects",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showDebuffs end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showDebuffs = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "half",
            order = 62
        }
        
        -- Show self-cast option
        options.args.showSelfCast = {
            type = "toggle",
            name = "Show Self Cast",
            desc = "Show effects cast by you",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showSelfCast end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showSelfCast = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "half",
            order = 63
        }
        
        -- Show others-cast option
        options.args.showOthersCast = {
            type = "toggle",
            name = "Show Others Cast",
            desc = "Show effects cast by others",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showOthersCast end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.showOthersCast = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "half",
            order = 64
        }
        
        -- Only show dispellable option
        options.args.onlyShowDispellable = {
            type = "toggle",
            name = "Only Show Dispellable",
            desc = "Only show effects you can dispel with your current class",
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.onlyShowDispellable end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.onlyShowDispellable = value
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.filterDispellable = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 65
        }
        
        -- Duration options header
        options.args.durationOptionsHeader = {
            type = "header",
            name = "Duration Options",
            order = 70
        }
        
        -- Min duration option
        options.args.minDuration = {
            type = "range",
            name = "Minimum Duration",
            desc = "Filter out effects with duration less than this value (in seconds, 0 = no minimum)",
            min = 0,
            max = 60,
            step = 1,
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.minDuration end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.minDuration = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 71
        }
        
        -- Max duration option
        options.args.maxDuration = {
            type = "range",
            name = "Maximum Duration",
            desc = "Filter out effects with duration greater than this value (in seconds, 0 = no maximum)",
            min = 0,
            max = 3600,
            step = 60,
            get = function() return VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.maxDuration end,
            set = function(_, value)
                VUI.db.profile.modules.buffoverlay.enhancedDisplay.filterOptions.maxDuration = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            disabled = function() return not VUI.db.profile.modules.buffoverlay.enhancedDisplay.enabled end,
            width = "full",
            order = 72
        }
        
        return options
    end
end

-- Override the UpdateAura function to incorporate enhanced display
local originalUpdateAura = BuffOverlay.UpdateAura
if originalUpdateAura then
    BuffOverlay.UpdateAura = function(self, frame, auraInfo)
        -- Call the original function
        originalUpdateAura(self, frame, auraInfo)
        
        -- Apply enhanced display
        if auraInfo then
            self:ApplyEnhancedDisplayToFrame(frame, auraInfo)
        end
    end
end

-- Override the ShouldDisplayAura function to incorporate enhanced display filtering
local originalShouldDisplayAura = BuffOverlay.ShouldDisplayAura
if originalShouldDisplayAura then
    BuffOverlay.ShouldDisplayAura = function(self, auraInfo)
        -- First check with original function
        local shouldDisplay = originalShouldDisplayAura(self, auraInfo)
        
        -- If original says yes, apply enhanced filtering
        if shouldDisplay then
            return self:FilterAuraWithEnhancedDisplay(auraInfo)
        end
        
        return shouldDisplay
    end
end