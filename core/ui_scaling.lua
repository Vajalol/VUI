--[[
    VUI - UI Scaling System
    Author: VortexQ8
    
    This file implements the UI scaling functionality for VUI,
    allowing the addon to adjust interface element sizes based on 
    screen resolution, user preferences, and accessibility needs.
    
    Key features:
    1. Global UI scaling controls
    2. Module-specific element scaling
    3. Automatic resolution detection
    4. Accessibility-friendly preset profiles
    5. Runtime scaling adjustments
]]

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local L = VUI.L

-- Create the UIScaling system
local UIScaling = {}
VUI.UIScaling = UIScaling

-- UI element scaling categories
local ELEMENT_CATEGORY = {
    CRITICAL = "critical",    -- Mission-critical UI elements (unit frames, action bars)
    IMPORTANT = "important",  -- Important but not critical (buffs, cooldowns)
    OPTIONAL = "optional",    -- Optional information (damage meters, tooltips)
    DECORATIVE = "decorative" -- Purely decorative elements
}

-- Default settings
local defaultSettings = {
    enabled = true,
    globalScale = 1.0,
    automaticScaling = true,
    moduleScales = {},
    elementCategories = {
        [ELEMENT_CATEGORY.CRITICAL] = 1.0,    -- Base scale for critical elements
        [ELEMENT_CATEGORY.IMPORTANT] = 0.95,  -- Slightly smaller for important elements
        [ELEMENT_CATEGORY.OPTIONAL] = 0.9,    -- Smaller for optional elements
        [ELEMENT_CATEGORY.DECORATIVE] = 0.85  -- Smallest for decorative elements
    },
    preserveTextSize = true,    -- Preserve text readability when scaling down
    scaleOnFrameStrata = true,  -- Scale elements based on frame strata
    scalingProfiles = {},       -- Named scaling profiles
    resolutionMultipliers = {   -- Multipliers for different resolutions
        ["3840x2160"] = 1.5,    -- 4K
        ["2560x1440"] = 1.25,   -- 1440p
        ["1920x1080"] = 1.0,    -- 1080p (baseline)
        ["1366x768"] = 0.9,     -- 768p
        ["1280x720"] = 0.9,     -- 720p
        ["800x600"] = 0.8       -- Low resolution
    }
}

-- Runtime data
local currentScale = 1.0
local originalScales = {}
local registeredElements = {}
local moduleFrames = {}
local screenWidth, screenHeight = 0, 0

-- Initialize with default or saved settings
local settings = {}

-- Initialize module
function UIScaling:Initialize()
    -- Load saved settings or initialize with defaults
    if VUI.db and VUI.db.profile.uiScaling then
        settings = VUI.db.profile.uiScaling
    else
        settings = CopyTable(defaultSettings)
        if VUI.db and VUI.db.profile then
            VUI.db.profile.uiScaling = settings
        end
    end
    
    -- Create the module frame
    self.frame = CreateFrame("Frame", "VUIUIScalingFrame", UIParent)
    
    -- Register events
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
    self.frame:RegisterEvent("UI_SCALE_CHANGED")
    
    -- Set up event handler
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:DetectScreenResolution()
            self:ApplyScaling()
        elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
            self:DetectScreenResolution()
            self:ApplyScaling()
        end
    end)
    
    -- Set up visibility changed handler for modules
    self.frame:SetScript("OnUpdate", function()
        self:ProcessPendingScalingUpdates()
    end)
    
    -- Register with modules
    self:RegisterWithModules()
    
    -- Register with VUI Config
    self:RegisterConfig()
    
    -- Print initialization message if in debug mode
    if VUI.debug then
        VUI:Print("UI Scaling system initialized")
    end
end

-- Detect screen resolution
function UIScaling:DetectScreenResolution()
    screenWidth, screenHeight = GetPhysicalScreenSize()
    
    if VUI.debug then
        VUI:Print("Screen resolution detected: " .. screenWidth .. "x" .. screenHeight)
    end
    
    -- Apply automatic scaling if enabled
    if settings.automaticScaling then
        self:CalculateAutomaticScaling()
    end
end

-- Calculate automatic scaling based on resolution
function UIScaling:CalculateAutomaticScaling()
    -- Skip if automatic scaling is disabled
    if not settings.automaticScaling then
        return
    end
    
    -- Exact resolution match
    local resKey = screenWidth .. "x" .. screenHeight
    local scaleFactor = settings.resolutionMultipliers[resKey]
    
    -- If no exact match, find closest resolution
    if not scaleFactor then
        local closestWidth = 0
        local closestDiff = math.huge
        
        for res, factor in pairs(settings.resolutionMultipliers) do
            local width = tonumber(res:match("(%d+)x"))
            if width then
                local diff = math.abs(width - screenWidth)
                if diff < closestDiff then
                    closestDiff = diff
                    closestWidth = width
                    scaleFactor = factor
                end
            end
        end
        
        if VUI.debug then
            VUI:Print("No exact resolution match. Using closest match: " .. closestWidth .. "px, scale: " .. scaleFactor)
        end
    end
    
    -- Default to 1.0 if no match found
    scaleFactor = scaleFactor or 1.0
    
    -- Update global scale
    settings.globalScale = scaleFactor
    
    if VUI.db and VUI.db.profile then
        VUI.db.profile.uiScaling.globalScale = scaleFactor
    end
    
    -- Apply the new scale
    self:ApplyScaling()
end

-- Apply scaling to UI elements
function UIScaling:ApplyScaling()
    -- Skip if disabled
    if not settings.enabled then
        self:ResetScaling()
        return
    end
    
    -- Apply global scaling
    self:ApplyGlobalScaling()
    
    -- Apply module-specific scaling
    self:ApplyModuleScaling()
    
    -- Apply element category scaling
    self:ApplyElementCategoryScaling()
    
    -- Refresh frames that need special handling
    self:RefreshSpecialFrames()
    
    -- Notify modules about scaling change
    VUI:CallModuleFunction("OnUIScalingChanged", settings.enabled, settings.globalScale)
    
    -- Update current scale
    currentScale = settings.globalScale
end

-- Apply global scaling to UI
function UIScaling:ApplyGlobalScaling()
    -- Store original scale if not already stored
    if not originalScales.uiParent then
        originalScales.uiParent = UIParent:GetScale()
    end
    
    -- Apply new scale
    UIParent:SetScale(settings.globalScale)
end

-- Apply scaling to specific modules
function UIScaling:ApplyModuleScaling()
    for moduleName, scale in pairs(settings.moduleScales) do
        local module = VUI:GetModule(moduleName)
        if module and module.frame then
            if not originalScales[moduleName] then
                originalScales[moduleName] = module.frame:GetScale()
            end
            
            -- Apply the combined scale (module scale * global scale)
            local combinedScale = scale * settings.globalScale
            module.frame:SetScale(combinedScale)
            
            -- Track module frames for later reference
            moduleFrames[moduleName] = module.frame
        end
    end
end

-- Apply scaling based on element categories
function UIScaling:ApplyElementCategoryScaling()
    for elementID, data in pairs(registeredElements) do
        local frame = data.frame
        local category = data.category
        
        if frame and frame:IsVisible() and category and settings.elementCategories[category] then
            if not originalScales[elementID] then
                originalScales[elementID] = frame:GetScale()
            end
            
            -- Apply the combined scale (category scale * global scale)
            local combinedScale = settings.elementCategories[category] * settings.globalScale
            frame:SetScale(combinedScale)
            
            -- Special handling for text elements if preserve text size is enabled
            if settings.preserveTextSize and data.hasText then
                self:AdjustTextScaling(frame, combinedScale)
            end
        end
    end
end

-- Reset all scaling to defaults
function UIScaling:ResetScaling()
    -- Reset UI parent scale
    if originalScales.uiParent then
        UIParent:SetScale(originalScales.uiParent)
    end
    
    -- Reset module scales
    for moduleName, frame in pairs(moduleFrames) do
        if frame and originalScales[moduleName] then
            frame:SetScale(originalScales[moduleName])
        end
    end
    
    -- Reset element scales
    for elementID, data in pairs(registeredElements) do
        if data.frame and originalScales[elementID] then
            data.frame:SetScale(originalScales[elementID])
            
            -- Reset text scaling if needed
            if settings.preserveTextSize and data.hasText then
                self:ResetTextScaling(data.frame)
            end
        end
    end
    
    -- Clear tracking tables
    originalScales = {}
    
    -- Notify modules about scaling reset
    VUI:CallModuleFunction("OnUIScalingChanged", false, 1.0)
    
    -- Update current scale
    currentScale = 1.0
end

-- Register an element for scaling
function UIScaling:RegisterElement(frame, category, options)
    if not frame then return end
    
    -- Generate a unique ID for this element
    local elementID = tostring(frame)
    
    -- Determine if the frame has text elements
    local hasText = options and options.hasText or false
    
    -- Store the element data
    registeredElements[elementID] = {
        frame = frame,
        category = category or ELEMENT_CATEGORY.OPTIONAL,
        hasText = hasText,
        options = options or {}
    }
    
    -- Apply initial scaling if already initialized
    if settings.enabled and currentScale ~= 1.0 then
        if not originalScales[elementID] then
            originalScales[elementID] = frame:GetScale()
        end
        
        -- Apply category-based scaling
        if category and settings.elementCategories[category] then
            local combinedScale = settings.elementCategories[category] * settings.globalScale
            frame:SetScale(combinedScale)
            
            -- Handle text scaling if needed
            if hasText and settings.preserveTextSize then
                self:AdjustTextScaling(frame, combinedScale)
            end
        end
    end
    
    return elementID
end

-- Unregister an element
function UIScaling:UnregisterElement(elementID)
    if not elementID then return end
    
    local data = registeredElements[elementID]
    if data and data.frame then
        -- Restore original scale if available
        if originalScales[elementID] then
            data.frame:SetScale(originalScales[elementID])
            originalScales[elementID] = nil
        end
        
        -- Reset text scaling if needed
        if settings.preserveTextSize and data.hasText then
            self:ResetTextScaling(data.frame)
        end
    end
    
    -- Remove from registered elements
    registeredElements[elementID] = nil
end

-- Adjust text size to maintain readability when scaling
function UIScaling:AdjustTextScaling(frame, scale)
    -- Skip if scale is close to 1.0
    if scale > 0.95 and scale < 1.05 then return end
    
    -- Inverse scale factor for text elements
    local inverseScale = 1 / scale
    
    -- Process FontStrings directly attached to the frame
    for _, region in pairs({frame:GetRegions()}) do
        if region:IsObjectType("FontString") then
            local fontFile, fontSize, fontFlags = region:GetFont()
            if not region.originalFontSize then
                region.originalFontSize = fontSize
            end
            
            -- Apply inverse scaling to font size to maintain readability
            region:SetFont(fontFile, region.originalFontSize * (scale > 1 and 1 or inverseScale), fontFlags)
        end
    end
    
    -- Process child font strings recursively if needed
    self:ProcessChildFontStrings(frame, scale)
end

-- Process child font strings recursively
function UIScaling:ProcessChildFontStrings(frame, scale)
    -- Skip if scale is close to 1.0
    if scale > 0.95 and scale < 1.05 then return end
    
    -- Inverse scale factor for text elements
    local inverseScale = 1 / scale
    
    -- Process children up to 2 levels deep to avoid performance issues
    for _, child in pairs({frame:GetChildren()}) do
        -- Process FontStrings in this child
        for _, region in pairs({child:GetRegions()}) do
            if region:IsObjectType("FontString") then
                local fontFile, fontSize, fontFlags = region:GetFont()
                if not region.originalFontSize then
                    region.originalFontSize = fontSize
                end
                
                -- Apply inverse scaling to font size
                region:SetFont(fontFile, region.originalFontSize * (scale > 1 and 1 or inverseScale), fontFlags)
            end
        end
        
        -- Process one more level of children
        for _, grandchild in pairs({child:GetChildren()}) do
            for _, region in pairs({grandchild:GetRegions()}) do
                if region:IsObjectType("FontString") then
                    local fontFile, fontSize, fontFlags = region:GetFont()
                    if not region.originalFontSize then
                        region.originalFontSize = fontSize
                    end
                    
                    -- Apply inverse scaling to font size
                    region:SetFont(fontFile, region.originalFontSize * (scale > 1 and 1 or inverseScale), fontFlags)
                end
            end
        end
    end
end

-- Reset text scaling to original values
function UIScaling:ResetTextScaling(frame)
    -- Process FontStrings directly attached to the frame
    for _, region in pairs({frame:GetRegions()}) do
        if region:IsObjectType("FontString") and region.originalFontSize then
            local fontFile, _, fontFlags = region:GetFont()
            region:SetFont(fontFile, region.originalFontSize, fontFlags)
        end
    end
    
    -- Process child font strings recursively
    self:ResetChildFontStrings(frame)
end

-- Reset child font strings recursively
function UIScaling:ResetChildFontStrings(frame)
    -- Process children up to 2 levels deep
    for _, child in pairs({frame:GetChildren()}) do
        -- Reset FontStrings in this child
        for _, region in pairs({child:GetRegions()}) do
            if region:IsObjectType("FontString") and region.originalFontSize then
                local fontFile, _, fontFlags = region:GetFont()
                region:SetFont(fontFile, region.originalFontSize, fontFlags)
            end
        end
        
        -- Process one more level of children
        for _, grandchild in pairs({child:GetChildren()}) do
            for _, region in pairs({grandchild:GetRegions()}) do
                if region:IsObjectType("FontString") and region.originalFontSize then
                    local fontFile, _, fontFlags = region:GetFont()
                    region:SetFont(fontFile, region.originalFontSize, fontFlags)
                end
            end
        end
    end
end

-- Scale by frame strata
function UIScaling:ApplyFrameStrataScaling()
    if not settings.scaleOnFrameStrata then return end
    
    -- Define scale adjustments for different strata levels
    local strataScales = {
        ["BACKGROUND"] = 0.95,
        ["LOW"] = 0.98,
        ["MEDIUM"] = 1.0,   -- Baseline
        ["HIGH"] = 1.02,
        ["DIALOG"] = 1.05,
        ["FULLSCREEN"] = 1.08,
        ["FULLSCREEN_DIALOG"] = 1.1,
        ["TOOLTIP"] = 1.05
    }
    
    -- Apply scaling to all registered elements based on strata
    for elementID, data in pairs(registeredElements) do
        local frame = data.frame
        if frame and frame:IsVisible() then
            local strata = frame:GetFrameStrata()
            local strataScale = strataScales[strata] or 1.0
            
            -- Apply the combined scale (strata scale * category scale * global scale)
            local categoryScale = settings.elementCategories[data.category] or 1.0
            local combinedScale = strataScale * categoryScale * settings.globalScale
            
            -- Store original scale if not already stored
            if not originalScales[elementID] then
                originalScales[elementID] = frame:GetScale()
            end
            
            -- Apply the scale
            frame:SetScale(combinedScale)
            
            -- Handle text scaling if needed
            if settings.preserveTextSize and data.hasText then
                self:AdjustTextScaling(frame, combinedScale)
            end
        end
    end
end

-- Register with modules
function UIScaling:RegisterWithModules()
    -- Get all loaded modules
    for name, module in VUI:IterateModules() do
        -- Skip modules without frames or already registered ones
        if not module.frame then
            if VUI.debug then
                VUI:Print("Module " .. name .. " has no frame, skipping UI scaling registration.")
            end
        -- Skip to next iteration without using goto (not available in WoW's Lua 5.1)
        elseif not moduleFrames[name] then
            -- Register the main module frame if not already registered
            local category = ELEMENT_CATEGORY.IMPORTANT -- Default category for module frames
        
        -- Determine the appropriate category based on module type
        if name == "UnitFrames" or name == "ActionBars" then
            category = ELEMENT_CATEGORY.CRITICAL
        elseif name == "MiniMap" or name == "BuffOverlay" or name == "MultiNotification" then
            category = ELEMENT_CATEGORY.IMPORTANT
        elseif name == "DetailsSkin" or name == "Tooltips" then
            category = ELEMENT_CATEGORY.OPTIONAL
        else
            category = ELEMENT_CATEGORY.OPTIONAL
        end
        
        -- Register the module frame
        self:RegisterElement(module.frame, category, {hasText = true})
        
        -- Add to module scales if not already present
        if not settings.moduleScales[name] then
            settings.moduleScales[name] = 1.0
        end
        
        -- Track module frames
        moduleFrames[name] = module.frame
        end
    end
end

-- Refresh frames that need special handling after scaling
function UIScaling:RefreshSpecialFrames()
    -- Some frames need to be manually refreshed after scaling
    -- This is a list of known frames that need special handling
    local specialFrames = {
        PlayerFrame = true,
        TargetFrame = true,
        MiniMapFrame = true,
        ObjectiveTrackerFrame = true,
        ChatFrame1 = true,
        MainMenuBar = true
    }
    
    -- Process special frames
    for frameName, _ in pairs(specialFrames) do
        local frame = _G[frameName]
        if frame then
            -- Different frames need different refresh methods
            if frame.UpdateLayout then
                frame:UpdateLayout()
            elseif frame.SetPoint and frame.ClearAllPoints then
                -- Save points and restore them to force layout update
                local points = {}
                for i = 1, frame:GetNumPoints() do
                    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(i)
                    table.insert(points, {point, relativeTo, relativePoint, xOfs, yOfs})
                end
                
                frame:ClearAllPoints()
                for _, pointData in ipairs(points) do
                    frame:SetPoint(unpack(pointData))
                end
            end
            
            -- Force frame update
            if frame.UpdateFrame then
                frame:UpdateFrame()
            end
        end
    end
end

-- Process pending scaling updates
function UIScaling:ProcessPendingScalingUpdates()
    -- This runs on OnUpdate to catch any newly visible frames
    -- We'll limit it to processing a few elements per frame for performance
    
    -- Skip if disabled or no scaling is applied
    if not settings.enabled or currentScale == 1.0 then return end
    
    -- Track elements that need scaling updates
    local updatesNeeded = {}
    
    -- Check for elements that need updates
    for elementID, data in pairs(registeredElements) do
        local frame = data.frame
        if frame and frame:IsVisible() and not frame.scalingProcessed then
            table.insert(updatesNeeded, elementID)
            
            -- Process only a few elements per frame
            if #updatesNeeded >= 5 then
                break
            end
        end
    end
    
    -- Process updates
    for _, elementID in ipairs(updatesNeeded) do
        local data = registeredElements[elementID]
        local frame = data.frame
        
        -- Apply scaling
        if not originalScales[elementID] then
            originalScales[elementID] = frame:GetScale()
        end
        
        -- Apply category-based scaling
        if data.category and settings.elementCategories[data.category] then
            local combinedScale = settings.elementCategories[data.category] * settings.globalScale
            frame:SetScale(combinedScale)
            
            -- Handle text scaling if needed
            if data.hasText and settings.preserveTextSize then
                self:AdjustTextScaling(frame, combinedScale)
            end
        end
        
        -- Mark as processed
        frame.scalingProcessed = true
    end
end

-- Save a named scaling profile
function UIScaling:SaveProfile(profileName, description)
    if not profileName then return false end
    
    -- Create profile from current settings
    local profile = {
        name = profileName,
        description = description or "",
        globalScale = settings.globalScale,
        elementCategories = CopyTable(settings.elementCategories),
        moduleScales = CopyTable(settings.moduleScales),
        preserveTextSize = settings.preserveTextSize,
        scaleOnFrameStrata = settings.scaleOnFrameStrata
    }
    
    -- Store the profile
    settings.scalingProfiles[profileName] = profile
    
    -- Save to database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.uiScaling = settings
    end
    
    return true
end

-- Load a named scaling profile
function UIScaling:LoadProfile(profileName)
    if not profileName or not settings.scalingProfiles[profileName] then
        return false
    end
    
    -- Get the profile
    local profile = settings.scalingProfiles[profileName]
    
    -- Apply settings from profile
    settings.globalScale = profile.globalScale
    settings.elementCategories = CopyTable(profile.elementCategories)
    settings.moduleScales = CopyTable(profile.moduleScales)
    settings.preserveTextSize = profile.preserveTextSize
    settings.scaleOnFrameStrata = profile.scaleOnFrameStrata
    
    -- Save to database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.uiScaling = settings
    end
    
    -- Apply the new settings
    self:ApplyScaling()
    
    return true
end

-- Delete a named scaling profile
function UIScaling:DeleteProfile(profileName)
    if not profileName or not settings.scalingProfiles[profileName] then
        return false
    end
    
    -- Remove the profile
    settings.scalingProfiles[profileName] = nil
    
    -- Save to database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.uiScaling = settings
    end
    
    return true
end

-- Config panel integration
function UIScaling:RegisterConfig()
    -- Register with VUI Config system
    if VUI.Config then
        VUI.Config:RegisterModule("UI Scaling", self:GetConfigOptions())
    end
end

-- Get config options for the settings panel
function UIScaling:GetConfigOptions()
    local options = {
        name = "UI Scaling",
        type = "group",
        args = {
            generalSection = {
                order = 1,
                type = "group",
                name = "General Settings",
                inline = true,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = "Enable UI Scaling",
                        desc = "Enable or disable UI scaling system",
                        get = function() return settings.enabled end,
                        set = function(_, value) 
                            settings.enabled = value
                            VUI.db.profile.uiScaling.enabled = value
                            if value then
                                self:ApplyScaling()
                            else
                                self:ResetScaling()
                            end
                        end,
                        width = "full",
                    },
                    globalScale = {
                        order = 2,
                        type = "range",
                        name = "Global UI Scale",
                        desc = "Adjust the overall scale of the UI",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.globalScale end,
                        set = function(_, value) 
                            settings.globalScale = value
                            VUI.db.profile.uiScaling.globalScale = value
                            self:ApplyScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    automaticScaling = {
                        order = 3,
                        type = "toggle",
                        name = "Automatic Resolution Scaling",
                        desc = "Automatically adjust UI scale based on screen resolution",
                        get = function() return settings.automaticScaling end,
                        set = function(_, value) 
                            settings.automaticScaling = value
                            VUI.db.profile.uiScaling.automaticScaling = value
                            if value then
                                self:CalculateAutomaticScaling()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    preserveTextSize = {
                        order = 4,
                        type = "toggle",
                        name = "Preserve Text Readability",
                        desc = "Keep text readable when scaling UI elements down",
                        get = function() return settings.preserveTextSize end,
                        set = function(_, value) 
                            settings.preserveTextSize = value
                            VUI.db.profile.uiScaling.preserveTextSize = value
                            self:ApplyScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    scaleOnFrameStrata = {
                        order = 5,
                        type = "toggle",
                        name = "Scale by Frame Strata",
                        desc = "Slightly adjust scaling based on frame strata level",
                        get = function() return settings.scaleOnFrameStrata end,
                        set = function(_, value) 
                            settings.scaleOnFrameStrata = value
                            VUI.db.profile.uiScaling.scaleOnFrameStrata = value
                            if value then
                                self:ApplyFrameStrataScaling()
                            else
                                self:ApplyScaling() -- Reset to normal scaling
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                },
            },
            
            categoriesSection = {
                order = 2,
                type = "group",
                name = "Element Categories",
                inline = true,
                args = {
                    categoriesHeader = {
                        order = 1,
                        type = "header",
                        name = "Element Category Scaling",
                    },
                    criticalScale = {
                        order = 2,
                        type = "range",
                        name = "Critical Elements Scale",
                        desc = "Scaling for critical UI elements (unit frames, action bars)",
                        min = 0.5,
                        max = 1.5,
                        step = 0.05,
                        get = function() return settings.elementCategories[ELEMENT_CATEGORY.CRITICAL] or 1.0 end,
                        set = function(_, value) 
                            settings.elementCategories[ELEMENT_CATEGORY.CRITICAL] = value
                            VUI.db.profile.uiScaling.elementCategories[ELEMENT_CATEGORY.CRITICAL] = value
                            self:ApplyScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    importantScale = {
                        order = 3,
                        type = "range",
                        name = "Important Elements Scale",
                        desc = "Scaling for important UI elements (buffs, minimap)",
                        min = 0.5,
                        max = 1.5,
                        step = 0.05,
                        get = function() return settings.elementCategories[ELEMENT_CATEGORY.IMPORTANT] or 0.95 end,
                        set = function(_, value) 
                            settings.elementCategories[ELEMENT_CATEGORY.IMPORTANT] = value
                            VUI.db.profile.uiScaling.elementCategories[ELEMENT_CATEGORY.IMPORTANT] = value
                            self:ApplyScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    optionalScale = {
                        order = 4,
                        type = "range",
                        name = "Optional Elements Scale",
                        desc = "Scaling for optional UI elements (damage meters, tooltips)",
                        min = 0.5,
                        max = 1.5,
                        step = 0.05,
                        get = function() return settings.elementCategories[ELEMENT_CATEGORY.OPTIONAL] or 0.9 end,
                        set = function(_, value) 
                            settings.elementCategories[ELEMENT_CATEGORY.OPTIONAL] = value
                            VUI.db.profile.uiScaling.elementCategories[ELEMENT_CATEGORY.OPTIONAL] = value
                            self:ApplyScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    decorativeScale = {
                        order = 5,
                        type = "range",
                        name = "Decorative Elements Scale",
                        desc = "Scaling for purely decorative UI elements",
                        min = 0.5,
                        max = 1.5,
                        step = 0.05,
                        get = function() return settings.elementCategories[ELEMENT_CATEGORY.DECORATIVE] or 0.85 end,
                        set = function(_, value) 
                            settings.elementCategories[ELEMENT_CATEGORY.DECORATIVE] = value
                            VUI.db.profile.uiScaling.elementCategories[ELEMENT_CATEGORY.DECORATIVE] = value
                            self:ApplyScaling()
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                },
            },
            
            profilesSection = {
                order = 3,
                type = "group",
                name = "Scaling Profiles",
                inline = true,
                args = {
                    profileSelector = {
                        order = 1,
                        type = "select",
                        name = "Load Profile",
                        desc = "Load a saved scaling profile",
                        values = function()
                            local profiles = {}
                            for name, _ in pairs(settings.scalingProfiles) do
                                profiles[name] = name
                            end
                            return profiles
                        end,
                        get = function() return "" end, -- No default selection
                        set = function(_, value) 
                            if value ~= "" then
                                self:LoadProfile(value)
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    profileName = {
                        order = 2,
                        type = "input",
                        name = "New Profile Name",
                        desc = "Enter a name for a new profile",
                        get = function() return "" end,
                        set = function(_, value) 
                            profileNameTemp = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    profileDescription = {
                        order = 3,
                        type = "input",
                        name = "Profile Description",
                        desc = "Enter a description for the new profile",
                        get = function() return "" end,
                        set = function(_, value) 
                            profileDescTemp = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    saveProfile = {
                        order = 4,
                        type = "execute",
                        name = "Save Current Settings as Profile",
                        desc = "Save all current scaling settings as a named profile",
                        func = function()
                            if profileNameTemp and profileNameTemp ~= "" then
                                self:SaveProfile(profileNameTemp, profileDescTemp)
                                profileNameTemp = ""
                                profileDescTemp = ""
                            end
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled end,
                    },
                    deleteProfile = {
                        order = 5,
                        type = "execute",
                        name = "Delete Selected Profile",
                        desc = "Delete the selected scaling profile",
                        func = function()
                            if profileNameTemp and profileNameTemp ~= "" then
                                self:DeleteProfile(profileNameTemp)
                                profileNameTemp = ""
                            end
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled end,
                    },
                    resetToDefaults = {
                        order = 6,
                        type = "execute",
                        name = "Reset to Defaults",
                        desc = "Reset all scaling settings to defaults",
                        func = function()
                            settings = CopyTable(defaultSettings)
                            if VUI.db and VUI.db.profile then
                                VUI.db.profile.uiScaling = settings
                            end
                            self:ApplyScaling()
                        end,
                        width = "full",
                    },
                },
            },
            
            resolutionSection = {
                order = 4,
                type = "group",
                name = "Resolution Settings",
                inline = true,
                args = {
                    resolutionHeader = {
                        order = 1,
                        type = "header",
                        name = "Resolution Scaling Factors",
                    },
                    currentResolution = {
                        order = 2,
                        type = "description",
                        name = function() 
                            return "Current Resolution: " .. screenWidth .. "x" .. screenHeight
                        end,
                        width = "full",
                    },
                    resolution4k = {
                        order = 3,
                        type = "range",
                        name = "4K (3840x2160) Scaling",
                        desc = "Scale factor for 4K resolution",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.resolutionMultipliers["3840x2160"] end,
                        set = function(_, value) 
                            settings.resolutionMultipliers["3840x2160"] = value
                            VUI.db.profile.uiScaling.resolutionMultipliers["3840x2160"] = value
                            if settings.automaticScaling then
                                self:CalculateAutomaticScaling()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.automaticScaling end,
                    },
                    resolution1440p = {
                        order = 4,
                        type = "range",
                        name = "1440p (2560x1440) Scaling",
                        desc = "Scale factor for 1440p resolution",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.resolutionMultipliers["2560x1440"] end,
                        set = function(_, value) 
                            settings.resolutionMultipliers["2560x1440"] = value
                            VUI.db.profile.uiScaling.resolutionMultipliers["2560x1440"] = value
                            if settings.automaticScaling then
                                self:CalculateAutomaticScaling()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.automaticScaling end,
                    },
                    resolution1080p = {
                        order = 5,
                        type = "range",
                        name = "1080p (1920x1080) Scaling",
                        desc = "Scale factor for 1080p resolution",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.resolutionMultipliers["1920x1080"] end,
                        set = function(_, value) 
                            settings.resolutionMultipliers["1920x1080"] = value
                            VUI.db.profile.uiScaling.resolutionMultipliers["1920x1080"] = value
                            if settings.automaticScaling then
                                self:CalculateAutomaticScaling()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.automaticScaling end,
                    },
                    resolution768p = {
                        order = 6,
                        type = "range",
                        name = "768p (1366x768) Scaling",
                        desc = "Scale factor for 768p resolution",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.resolutionMultipliers["1366x768"] end,
                        set = function(_, value) 
                            settings.resolutionMultipliers["1366x768"] = value
                            VUI.db.profile.uiScaling.resolutionMultipliers["1366x768"] = value
                            if settings.automaticScaling then
                                self:CalculateAutomaticScaling()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.automaticScaling end,
                    },
                    resolution720p = {
                        order = 7,
                        type = "range",
                        name = "720p (1280x720) Scaling",
                        desc = "Scale factor for 720p resolution",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        get = function() return settings.resolutionMultipliers["1280x720"] end,
                        set = function(_, value) 
                            settings.resolutionMultipliers["1280x720"] = value
                            VUI.db.profile.uiScaling.resolutionMultipliers["1280x720"] = value
                            if settings.automaticScaling then
                                self:CalculateAutomaticScaling()
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.automaticScaling end,
                    },
                },
            },
        }
    }
    
    -- Add module-specific scaling options
    local moduleSection = {
        order = 3,
        type = "group",
        name = "Module-Specific Scaling",
        inline = true,
        args = {
            modulesHeader = {
                order = 1,
                type = "header",
                name = "Module Scaling",
            }
        }
    }
    
    -- Add entries for each module
    local order = 2
    for moduleName, _ in pairs(settings.moduleScales) do
        moduleSection.args[moduleName .. "Scale"] = {
            order = order,
            type = "range",
            name = moduleName .. " Scale",
            desc = "Adjust scaling for the " .. moduleName .. " module",
            min = 0.5,
            max = 1.5,
            step = 0.05,
            get = function() return settings.moduleScales[moduleName] end,
            set = function(_, value) 
                settings.moduleScales[moduleName] = value
                VUI.db.profile.uiScaling.moduleScales[moduleName] = value
                self:ApplyScaling()
            end,
            width = "full",
            disabled = function() return not settings.enabled end,
        }
        order = order + 1
    end
    
    -- Add the module section
    options.args.moduleSection = moduleSection
    
    return options
end

-- Get element category constants
function UIScaling:GetElementCategories()
    return ELEMENT_CATEGORY
end

-- Module export for VUI
VUI.UIScaling = UIScaling

-- Initialize on VUI ready
if VUI.isInitialized then
    UIScaling:Initialize()
else
    -- Instead of using RegisterScript, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize module after VUI is initialized
        if UIScaling.Initialize then
            UIScaling:Initialize()
        end
    end
end